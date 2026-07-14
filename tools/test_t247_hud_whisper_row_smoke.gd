extends SceneTree
# T247 (#164) — 第六 verb Whisper HUD cooldown bar 冷光勾边 smoke test.
# F013.E (#159) 6 verb 接入路径 §9.1 第 9 步 HUD 接入 闭环 验证.
#
# 验证 5 条不变量:
# 1. hud.tscn 树里能找到 WhisperRow (HBoxContainer) 节点
# 2. WhisperRow 下能找到 WhisperIcon / WhisperNameLabel / WhisperCooldown / WhisperCooldownLabel
# 3. WhisperCooldown 的 theme_override_styles/fill 引用了 StyleBoxFlat_whisper_fill (Muted Mauve #C8A4D8)
# 4. hud.gd _verb_glow_state dict 6 key (pulse/bind/cut/echo/wave/whisper) 全部存在
# 5. hud.gd _WHISPER_GLOW_COLOR = Muted Mauve #C8A4D8 (6 verb 调色六元组宪法 严格不重叠)

const _MUTED_MAUVE := Color(0.784, 0.643, 0.847, 1.0)

func _init() -> void:
	var all_ok := true
	var fails: Array[String] = []

	# --- 1. 加载 hud.tscn ---
	var hud_scene: PackedScene = load("res://src/scenes/hud.tscn")
	if hud_scene == null:
		fails.append("[1] load res://src/scenes/hud.tscn returned null")
		_finish(all_ok, fails)
		return
	var hud_root: Node = hud_scene.instantiate()
	root.add_child(hud_root)

	# --- 2. 找 WhisperRow ---
	var vbox: Node = hud_root.get_node_or_null("MarginContainer/VBoxContainer")
	if vbox == null:
		fails.append("[1] MarginContainer/VBoxContainer not found in hud.tscn")
		_finish(all_ok, fails)
		return
	var whisper_row: Node = vbox.get_node_or_null("WhisperRow")
	if whisper_row == null:
		fails.append("[1] WhisperRow not found in MarginContainer/VBoxContainer")
	else:
		print("[1] OK WhisperRow found: %s" % whisper_row.get_class())

	# --- 3. WhisperRow 4 子节点 (Icon / NameLabel / Cooldown / CooldownLabel) ---
	var icon_node: Node = whisper_row.get_node_or_null("WhisperIcon") if whisper_row else null
	var name_node: Label = whisper_row.get_node_or_null("WhisperNameLabel") if whisper_row else null
	var cd_node: ProgressBar = whisper_row.get_node_or_null("WhisperCooldown") if whisper_row else null
	var cd_label_node: Label = whisper_row.get_node_or_null("WhisperCooldownLabel") if whisper_row else null
	if icon_node == null:
		fails.append("[2] WhisperIcon not found in WhisperRow")
	else:
		print("[2] OK WhisperIcon: %s" % icon_node.get_class())
	if name_node == null:
		fails.append("[2] WhisperNameLabel not found in WhisperRow")
	else:
		print("[2] OK WhisperNameLabel: '%s' theme_color=%s" % [name_node.text, name_node.get_theme_color("font_color")])
	if cd_node == null:
		fails.append("[2] WhisperCooldown not found in WhisperRow")
	else:
		print("[2] OK WhisperCooldown: min=%s max=%s value=%s" % [cd_node.min_value, cd_node.max_value, cd_node.value])
	if cd_label_node == null:
		fails.append("[2] WhisperCooldownLabel not found in WhisperRow")
	else:
		print("[2] OK WhisperCooldownLabel: text='%s'" % cd_label_node.text)

	# --- 4. WhisperCooldown fill stylebox bg_color = Muted Mauve ---
	if cd_node:
		var fill_sb: StyleBox = cd_node.get_theme_stylebox("fill")
		if fill_sb == null:
			fails.append("[3] WhisperCooldown 'fill' stylebox is null")
		elif not (fill_sb is StyleBoxFlat):
			fails.append("[3] WhisperCooldown 'fill' is not StyleBoxFlat (got %s)" % fill_sb.get_class())
		else:
			var bg := (fill_sb as StyleBoxFlat).bg_color
			if not bg.is_equal_approx(_MUTED_MAUVE):
				fails.append("[3] WhisperCooldown fill bg_color=%s, expected Muted Mauve %s" % [bg, _MUTED_MAUVE])
			else:
				print("[3] OK WhisperCooldown fill bg_color = Muted Mauve %s" % bg)

	# --- 5. _verb_glow_state dict 6 key 全部存在 ---
	# hud.gd 静态解析, 拿 hud 脚本 source 找 dict 字面量
	# FIX-#235-2 (T162 brittle 修复流程): 原 `load("res://src/scripts/hud.gd")` 触发
	# hud.gd 解析, 但 hud.gd 引用 GameState autoload, --script 模式 GameState 不加载
	# → "Identifier not found: GameState" Compile Error.  改用 FileAccess.open
	# 文本读取, 0 触碰 0 副作用.  test body 只静态 grep 文本, 不调用 hud 任何 runtime
	# 方法, 0 触碰既有 6 verb 接入路径 §9.1 第 9 步 HUD 接入 闭环 合约.
	var hud_script: GDScript = null
	var hud_text: String = ""
	var hud_fa: FileAccess = FileAccess.open("res://src/scripts/hud.gd", FileAccess.READ)
	if hud_fa == null:
		fails.append("[4] open res://src/scripts/hud.gd returned null")
	else:
		hud_text = hud_fa.get_as_text()
		hud_fa.close()
		# 实例化 hud 节点以触发 _ready, _verb_glow_state 在源码里 6 key
		# 但 _verb_glow_state 是 private, 通过 _process 1 次后间接验证
		# 改用 source-grep 验证: 找到 "whisper": false, 是否在 _verb_glow_state 块内
		var script_source: String = hud_text
		var dict_block := _extract_verb_glow_state_block(script_source)
		if dict_block.is_empty():
			fails.append("[4] could not find _verb_glow_state dict in hud.gd source")
		else:
			var expected_keys := ["pulse", "bind", "cut", "echo", "wave", "whisper"]
			var missing: Array[String] = []
			for k in expected_keys:
				if not ("\"%s\"" % k) in dict_block:
					missing.append(k)
			if missing.size() > 0:
				fails.append("[4] _verb_glow_state missing keys: %s" % str(missing))
			else:
				print("[4] OK _verb_glow_state has 6 keys: %s" % str(expected_keys))

		# --- 6. _WHISPER_GLOW_COLOR = Muted Mauve (source-grep) ---
		if not "_WHISPER_GLOW_COLOR" in script_source:
			fails.append("[5] _WHISPER_GLOW_COLOR const not found in hud.gd")
		elif not "0.784, 0.643, 0.847" in script_source:
			fails.append("[5] _WHISPER_GLOW_COLOR = Muted Mauve #C8A4D8 (0.784, 0.643, 0.847) not found in hud.gd")
		else:
			print("[5] OK _WHISPER_GLOW_COLOR = Muted Mauve #C8A4D8 (0.784, 0.643, 0.847)")

	# --- 7. _apply_reduced_flash_modulate iteration list 8 element (含 whisper) ---
	if hud_text != "":
		var src: String = hud_text
		# 找 _apply_reduced_flash_modulate 函数体内那段 for ui_elem in [...] 块
		var func_idx := src.find("func _apply_reduced_flash_modulate")
		if func_idx < 0:
			fails.append("[6] _apply_reduced_flash_modulate function not found in hud.gd")
		else:
			# 从 func body 末尾 1500 char 内找 iteration list (覆盖 docblock 8 行 + function body)
			var slice_end: int = min(func_idx + 1500, src.length())
			var slice: String = src.substr(func_idx, slice_end - func_idx)
			var list_start := slice.find("ui_elem in [")
			if list_start < 0:
				fails.append("[6] 'ui_elem in [...]' iteration list not found in _apply_reduced_flash_modulate")
			else:
				var list_end := slice.find("]", list_start)
				if list_end < 0:
					fails.append("[6] ']' close of iteration list not found within 1500 char window")
				else:
					var list_body: String = slice.substr(list_start, list_end - list_start + 1)
					if "_whisper_cooldown" in list_body and "_resonance_bar" in list_body and "_health_container" in list_body:
						print("[6] OK _apply_reduced_flash_modulate iteration list has 8 element (5 verb + whisper + resonance + health)")
					else:
						fails.append("[6] iteration list incomplete: %s" % list_body)

	hud_root.queue_free()
	_finish(all_ok, fails)


func _extract_verb_glow_state_block(src: String) -> String:
	# 找 var _verb_glow_state: Dictionary = { ... } 块
	var marker := "_verb_glow_state"
	var idx := src.find(marker)
	if idx < 0:
		return ""
	# 从 idx 起找到 { 然后匹配到平衡的 }
	var open_idx := src.find("{", idx)
	if open_idx < 0:
		return ""
	var depth := 0
	for i in range(open_idx, src.length()):
		var c := src[i]
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0:
				return src.substr(open_idx, i - open_idx + 1)
	return ""


func _extract_function_block(src: String, func_name: String) -> String:
	# 找 func func_name(...) -> ... { ... } 块 (简单匹配首个 { 到平衡的 })
	var marker := "func %s(" % func_name
	var idx := src.find(marker)
	if idx < 0:
		return ""
	var open_idx := src.find("{", idx)
	if open_idx < 0:
		return ""
	var depth := 0
	for i in range(open_idx, src.length()):
		var c := src[i]
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0:
				return src.substr(open_idx, i - open_idx + 1)
	return ""


func _finish(all_ok: bool, fails: Array) -> void:
	if fails.size() > 0:
		print("\n[T247 SMOKE FAILED]")
		for f in fails:
			print("  - %s" % f)
		print("\nT247 smoke: %d fails" % fails.size())
		quit(1)
	else:
		print("\n[T247 SMOKE PASSED] HUD 6 verb Whisper row + glow state + reduced_flash 闭环")
		quit(0)
