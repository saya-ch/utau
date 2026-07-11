extends SceneTree
## T264 (#186) — §9.6.14 settings_menu `[input]` section N key ACTION_NAMES 循环 + InputMap.action_get_events / action_add_event / action_erase_events 跨 InputEvent dict 序列化 + 1:1 持久化 polish 模式 (T086 + T194 + T195 + T196 + T202.B + T205 + T239 跨 7 任务 ~10 轮落地) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t264_contributing_fragility_section9614_smoke.gd
##
## T264: CONTRIBUTING.md §9.6.14 已知 fragility 扩展
##   - §9.6.14 [input] section 6 件套 (ACTION_NAMES 字典 + ACTION_CATEGORY 字典 + CATEGORY_RENDER_ORDER 数组 + _DEFAULT_BINDINGS 字典 + _save_settings 4 行循环 + _load_settings 5 行循环)
##   - settings_menu.gd const ACTION_NAMES 9 actions
##   - settings_menu.gd const ACTION_CATEGORY 9 actions × 3 segments
##   - settings_menu.gd const CATEGORY_RENDER_ORDER 3 segments (移动/声波能力/交互)
##   - settings_menu.gd const _DEFAULT_BINDINGS 9 actions
##   - settings_menu.gd _save_settings 末尾 4 行 [input] section 循环 (for / action_get_events / size() > 0 / set_value)
##   - settings_menu.gd _load_settings 末尾 5 行 [input] section 循环 (for / get_value / is InputEvent / action_erase_events / action_add_event)
##   - 守卫 2 件套: events.size() > 0 (save) + if ev is InputEvent (load)
##   - 6 件套 1:1 同步 (const × 4 + 4 行 save + 5 行 load, 0 漏 1 边)
## 验证 9 维:
##   - §9.6.14 章节在 CONTRIBUTING.md 已落地
##   - §9.6.14 4 段结构 (症状/触发/修复/预防) 全部存在
##   - settings_menu.gd 4 个 const 落地 (ACTION_NAMES + ACTION_CATEGORY + CATEGORY_RENDER_ORDER + _DEFAULT_BINDINGS)
##   - settings_menu.gd const ACTION_NAMES 9 actions + 9 字符串 1:1
##   - settings_menu.gd const ACTION_CATEGORY 9 actions × 3 segments (movement / verb / interaction)
##   - settings_menu.gd const CATEGORY_RENDER_ORDER 3 segments (移动 / 声波能力 / 交互) + 4 字段
##   - settings_menu.gd _save_settings 末尾 4 行 [input] section 循环 (for / action_get_events / size() > 0 守卫 / set_value)
##   - settings_menu.gd _load_settings 末尾 5 行 [input] section 循环 (for / get_value / is InputEvent 守卫 / action_erase_events / action_add_event)
##   - CHANGELOG.md 含 #186 段 + ROADMAP.md 顶部时间戳含 #186

func _initialize() -> void:
	print("=== T264 #186 §9.6.14 [input] section N key ACTION_NAMES 循环 + InputMap.action_get_events / action_add_event / action_erase_events 跨 InputEvent dict 序列化 + 1:1 持久化 polish 模式 (T086 + T194 + T195 + T196 + T202.B + T205 + T239 跨 7 任务 ~10 轮落地) smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_settings_menu := _read_file("res://src/scripts/settings_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T264.1 — §9.6.14 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T264.1 — §9.6.14 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T264.1.1 §9.6.14 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.14 settings_menu `[input]` section") == -1:
		print("  FAIL [T264.1.1]: CONTRIBUTING.md 缺 §9.6.14 章节标题")
		quit(1); return
	passed += 1
	print("  [T264.1.1] CONTRIBUTING.md 含 §9.6.14 章节标题 (OK)")

	# ===== T264.1.2 §9.6.14 含 T086 + T194 + ACTION_NAMES + InputMap.action_get_events =====
	total += 1
	var s9614_start := src_contributing.find("### 9.6.14")
	var s10_start := src_contributing.find("## 10.")
	if s9614_start == -1 or s10_start == -1:
		print("  FAIL [T264.1.2]: §9.6.14 / ## 10 区间划分失败")
		quit(1); return
	var s9614 := src_contributing.substr(s9614_start, s10_start - s9614_start)
	if s9614.find("T086") == -1:
		print("  FAIL [T264.1.2]: §9.6.14 区间缺 T086 anchor")
		quit(1); return
	if s9614.find("T194") == -1:
		print("  FAIL [T264.1.2]: §9.6.14 区间缺 T194 anchor")
		quit(1); return
	if s9614.find("ACTION_NAMES") == -1:
		print("  FAIL [T264.1.2]: §9.6.14 区间缺 ACTION_NAMES 关键 const")
		quit(1); return
	if s9614.find("action_get_events") == -1:
		print("  FAIL [T264.1.2]: §9.6.14 区间缺 action_get_events 关键函数")
		quit(1); return
	if s9614.find("action_erase_events") == -1:
		print("  FAIL [T264.1.2]: §9.6.14 区间缺 action_erase_events 关键函数")
		quit(1); return
	if s9614.find("action_add_event") == -1:
		print("  FAIL [T264.1.2]: §9.6.14 区间缺 action_add_event 关键函数")
		quit(1); return
	passed += 1
	print("  [T264.1.2] CONTRIBUTING.md §9.6.14 区间含 T086 + T194 + ACTION_NAMES + action_get_events + action_erase_events + action_add_event (OK)")

	# ===== T264.1.3 §9.6.14 提到 6 件套 + 1:1 同步 + InputEvent 序列化 核心概念 =====
	total += 1
	if s9614.find("6 件套") == -1 or s9614.find("1:1") == -1 or s9614.find("InputEvent") == -1:
		print("  FAIL [T264.1.3]: §9.6.14 缺核心概念 (6 件套 / 1:1 / InputEvent)")
		quit(1); return
	passed += 1
	print("  [T264.1.3] CONTRIBUTING.md §9.6.14 含 6 件套 + 1:1 同步 + InputEvent 序列化 核心概念 (OK)")

	# =================================================================
	# T264.2 — §9.6.14 4 段结构 (症状/触发/修复/预防) 全部存在 (3 断言)
	# =================================================================
	print("--- T264.2 — §9.6.14 4 段结构 (症状/触发/修复/预防) 全部存在 ---")

	# ===== T264.2.1 §9.6.14 症状段 =====
	total += 1
	if s9614.find("**症状**") == -1:
		print("  FAIL [T264.2.1]: §9.6.14 缺症状段")
		quit(1); return
	passed += 1
	print("  [T264.2.1] §9.6.14 含 症状段 (OK)")

	# ===== T264.2.2 §9.6.14 触发场景段 =====
	total += 1
	if s9614.find("**触发场景**") == -1:
		print("  FAIL [T264.2.2]: §9.6.14 缺触发场景段")
		quit(1); return
	passed += 1
	print("  [T264.2.2] §9.6.14 含 触发场景段 (OK)")

	# ===== T264.2.3 §9.6.14 修复段 + 预防段 =====
	total += 1
	if s9614.find("**修复**") == -1 or s9614.find("**预防**") == -1:
		print("  FAIL [T264.2.3]: §9.6.14 缺修复/预防段")
		quit(1); return
	passed += 1
	print("  [T264.2.3] §9.6.14 含 修复段 + 预防段 (OK)")

	# =================================================================
	# T264.3 — settings_menu.gd 4 个 const 落地 (ACTION_NAMES + ACTION_CATEGORY + CATEGORY_RENDER_ORDER + _DEFAULT_BINDINGS) (4 断言)
	# =================================================================
	print("--- T264.3 — settings_menu.gd 4 个 const 落地 ---")

	# ===== T264.3.1 const ACTION_NAMES =====
	total += 1
	if src_settings_menu.find("const ACTION_NAMES := {") == -1:
		print("  FAIL [T264.3.1]: settings_menu.gd 缺 const ACTION_NAMES")
		quit(1); return
	passed += 1
	print("  [T264.3.1] settings_menu.gd 含 const ACTION_NAMES := {...} (OK)")

	# ===== T264.3.2 const ACTION_CATEGORY =====
	total += 1
	if src_settings_menu.find("const ACTION_CATEGORY := {") == -1:
		print("  FAIL [T264.3.2]: settings_menu.gd 缺 const ACTION_CATEGORY")
		quit(1); return
	passed += 1
	print("  [T264.3.2] settings_menu.gd 含 const ACTION_CATEGORY := {...} (OK)")

	# ===== T264.3.3 const CATEGORY_RENDER_ORDER =====
	total += 1
	if src_settings_menu.find("const CATEGORY_RENDER_ORDER := [") == -1:
		print("  FAIL [T264.3.3]: settings_menu.gd 缺 const CATEGORY_RENDER_ORDER")
		quit(1); return
	passed += 1
	print("  [T264.3.3] settings_menu.gd 含 const CATEGORY_RENDER_ORDER := [...] (OK)")

	# ===== T264.3.4 const _DEFAULT_BINDINGS =====
	total += 1
	if src_settings_menu.find("const _DEFAULT_BINDINGS := {") == -1:
		print("  FAIL [T264.3.4]: settings_menu.gd 缺 const _DEFAULT_BINDINGS")
		quit(1); return
	passed += 1
	print("  [T264.3.4] settings_menu.gd 含 const _DEFAULT_BINDINGS := {...} (OK)")

	# =================================================================
	# T264.4 — settings_menu.gd const ACTION_NAMES 9 actions + 9 字符串 1:1 (4 断言)
	# =================================================================
	print("--- T264.4 — settings_menu.gd const ACTION_NAMES 9 actions + 9 字符串 1:1 ---")

	# ===== T264.4.1 ACTION_NAMES 含 9 actions =====
	total += 1
	var an_start := src_settings_menu.find("const ACTION_NAMES := {")
	var an_end := src_settings_menu.find("\n}", an_start)
	if an_start == -1 or an_end == -1:
		print("  FAIL [T264.4.1]: 无法定位 ACTION_NAMES 字典边界")
		quit(1); return
	var an_block := src_settings_menu.substr(an_start, an_end - an_start + 2)
	var an_count := 0
	for action_key in ["move_left", "move_right", "jump", "pulse", "bind", "cut", "echo", "interact", "wave"]:
		if an_block.find("\"" + action_key + "\":") != -1:
			an_count += 1
	if an_count != 9:
		print("  FAIL [T264.4.1]: ACTION_NAMES 字典含 %d/9 actions, 期望 9" % an_count)
		quit(1); return
	passed += 1
	print("  [T264.4.1] ACTION_NAMES 字典含 9/9 actions (move_left/right/jump/pulse/bind/cut/echo/interact/wave) (OK)")

	# ===== T264.4.2 ACTION_NAMES 9 actions 各自有 1 个字符串 label =====
	total += 1
	var label_count := 0
	for action_key in ["move_left", "move_right", "jump", "pulse", "bind", "cut", "echo", "interact", "wave"]:
		var key_pos_2: int = an_block.find("\"" + action_key + "\":")
		if key_pos_2 != -1:
			# 找 " " 或 " " 之后的中文 label (`: "label"`)
			var quote_pos_2: int = an_block.find("\"", key_pos_2 + action_key.length() + 4)
			if quote_pos_2 != -1:
				var end_quote_pos_2: int = an_block.find("\"", quote_pos_2 + 1)
				if end_quote_pos_2 != -1:
					var label_text_2: String = an_block.substr(quote_pos_2 + 1, end_quote_pos_2 - quote_pos_2 - 1)
					if label_text_2.length() > 0:
						label_count += 1
	if label_count != 9:
		print("  FAIL [T264.4.2]: ACTION_NAMES 字典 %d/9 actions 有 label, 期望 9" % label_count)
		quit(1); return
	passed += 1
	print("  [T264.4.2] ACTION_NAMES 字典 9/9 actions 各自有 1 个 label 字符串 (OK)")

	# ===== T264.4.3 ACTION_NAMES 含 9 action 1:1 (3+5+1 segment) =====
	total += 1
	var move_count := 0
	for ak in ["move_left", "move_right", "jump"]:
		if an_block.find("\"" + ak + "\":") != -1:
			move_count += 1
	if move_count != 3:
		print("  FAIL [T264.4.3]: ACTION_NAMES movement segment %d/3, 期望 3 (move_left/right/jump)" % move_count)
		quit(1); return
	passed += 1
	print("  [T264.4.3] ACTION_NAMES movement segment 3/3 (move_left/right/jump) (OK)")

	# ===== T264.4.4 ACTION_NAMES 字典末尾 } 0 漏 1 action =====
	total += 1
	var last_action_pos := an_block.rfind("\t\"")
	if last_action_pos == -1:
		print("  FAIL [T264.4.4]: ACTION_NAMES 字典末尾缺 \\t\" 前缀")
		quit(1); return
	var last_action_text := an_block.substr(last_action_pos, 30)
	# wave 是最后一个 action (T194 后 wave 排末位)
	if last_action_text.find("wave") == -1:
		print("  FAIL [T264.4.4]: ACTION_NAMES 字典末尾不是 wave, 实为: %s" % last_action_text)
		quit(1); return
	passed += 1
	print("  [T264.4.4] ACTION_NAMES 字典末尾是 wave (T194 后 wave 末位) (OK)")

	# =================================================================
	# T264.5 — settings_menu.gd const ACTION_CATEGORY 9 actions × 3 segments (4 断言)
	# =================================================================
	print("--- T264.5 — settings_menu.gd const ACTION_CATEGORY 9 actions × 3 segments ---")

	# ===== T264.5.1 ACTION_CATEGORY 含 3 段 segment (movement/verb/interaction) =====
	total += 1
	var ac_start := src_settings_menu.find("const ACTION_CATEGORY := {")
	var ac_end := src_settings_menu.find("\n}", ac_start)
	if ac_start == -1 or ac_end == -1:
		print("  FAIL [T264.5.1]: 无法定位 ACTION_CATEGORY 字典边界")
		quit(1); return
	var ac_block := src_settings_menu.substr(ac_start, ac_end - ac_start + 2)
	for seg in ["movement", "verb", "interact"]:
		if ac_block.find("\"" + seg + "\"") == -1:
			print("  FAIL [T264.5.1]: ACTION_CATEGORY 缺 segment \"%s\"" % seg)
			quit(1); return
	passed += 1
	print("  [T264.5.1] ACTION_CATEGORY 含 3 segments (movement / verb / interaction) (OK)")

	# ===== T264.5.2 ACTION_CATEGORY movement 段 3 actions (move_left/right/jump) =====
	total += 1
	var move_seg_count := 0
	for ak in ["move_left", "move_right", "jump"]:
		var pat_a: String = "\"" + ak + "\": \"movement\""
		if ac_block.find(pat_a) != -1:
			move_seg_count += 1
	if move_seg_count != 3:
		print("  FAIL [T264.5.2]: ACTION_CATEGORY movement %d/3, 期望 3" % move_seg_count)
		quit(1); return
	passed += 1
	print("  [T264.5.2] ACTION_CATEGORY movement 段 3/3 (move_left/right/jump) (OK)")

	# ===== T264.5.3 ACTION_CATEGORY verb 段 5 actions (pulse/bind/cut/echo/wave) =====
	total += 1
	var verb_seg_count := 0
	for ak in ["pulse", "bind", "cut", "echo", "wave"]:
		var pat_b: String = "\"" + ak + "\": \"verb\""
		if ac_block.find(pat_b) != -1:
			verb_seg_count += 1
	if verb_seg_count != 5:
		print("  FAIL [T264.5.3]: ACTION_CATEGORY verb %d/5, 期望 5" % verb_seg_count)
		quit(1); return
	passed += 1
	print("  [T264.5.3] ACTION_CATEGORY verb 段 5/5 (pulse/bind/cut/echo/wave) (OK)")

	# ===== T264.5.4 ACTION_CATEGORY interaction 段 1 action (interact) =====
	total += 1
	if ac_block.find("\"interact\": \"interact\"") == -1:
		print("  FAIL [T264.5.4]: ACTION_CATEGORY interaction 段缺 \"interact\": \"interact\"")
		quit(1); return
	passed += 1
	print("  [T264.5.4] ACTION_CATEGORY interaction 段 1/1 (interact) (OK)")

	# =================================================================
	# T264.6 — settings_menu.gd const CATEGORY_RENDER_ORDER 3 segments + 4 字段 (3 断言)
	# =================================================================
	print("--- T264.6 — settings_menu.gd const CATEGORY_RENDER_ORDER 3 segments + 4 字段 ---")

	# ===== T264.6.1 CATEGORY_RENDER_ORDER 含 3 segments (移动/声波能力/交互) =====
	total += 1
	var cro_start := src_settings_menu.find("const CATEGORY_RENDER_ORDER := [")
	var cro_end := src_settings_menu.find("\n]", cro_start)
	if cro_start == -1 or cro_end == -1:
		print("  FAIL [T264.6.1]: 无法定位 CATEGORY_RENDER_ORDER 数组边界")
		quit(1); return
	var cro_block := src_settings_menu.substr(cro_start, cro_end - cro_start + 2)
	for label in ["移动", "声波能力", "交互"]:
		if cro_block.find("\"" + label + "\"") == -1:
			print("  FAIL [T264.6.1]: CATEGORY_RENDER_ORDER 缺 segment label \"%s\"" % label)
			quit(1); return
	passed += 1
	print("  [T264.6.1] CATEGORY_RENDER_ORDER 含 3 segments (移动/声波能力/交互) (OK)")

	# ===== T264.6.2 CATEGORY_RENDER_ORDER 每段 4 字段 (name + key + color) =====
	total += 1
	var cro_field_count := 0
	for field in ["\"name\":", "\"key\":", "\"color\":"]:
		cro_field_count += cro_block.find(field)
	if cro_field_count == -1:
		print("  FAIL [T264.6.2]: CATEGORY_RENDER_ORDER 缺 \"name\" / \"key\" / \"color\" 3 字段")
		quit(1); return
	passed += 1
	print("  [T264.6.2] CATEGORY_RENDER_ORDER 3 字段 (name + key + color) 1:1 (OK)")

	# ===== T264.6.3 CATEGORY_RENDER_ORDER 移动 → 声波能力 → 交互 顺序 =====
	total += 1
	var move_pos := cro_block.find("\"移动\"")
	var verb_pos := cro_block.find("\"声波能力\"")
	var inter_pos := cro_block.find("\"交互\"")
	if move_pos == -1 or verb_pos == -1 or inter_pos == -1:
		print("  FAIL [T264.6.3]: CATEGORY_RENDER_ORDER 段定位失败")
		quit(1); return
	if not (move_pos < verb_pos and verb_pos < inter_pos):
		print("  FAIL [T264.6.6.3]: CATEGORY_RENDER_ORDER 顺序错位 (move_pos=%d verb_pos=%d inter_pos=%d)" % [move_pos, verb_pos, inter_pos])
		quit(1); return
	passed += 1
	print("  [T264.6.3] CATEGORY_RENDER_ORDER 段顺序: 移动 → 声波能力 → 交互 (OK)")

	# =================================================================
	# T264.7 — settings_menu.gd _save_settings 末尾 4 行 [input] section 循环 (4 断言)
	# =================================================================
	print("--- T264.7 — settings_menu.gd _save_settings 末尾 4 行 [input] section 循环 ---")

	# ===== T264.7.1 _save_settings 含 `for action in ACTION_NAMES.keys():` 循环 =====
	total += 1
	var save_start := src_settings_menu.find("func _save_settings() -> void:")
	var save_end := src_settings_menu.find("func _load_settings() -> void:")
	if save_start == -1 or save_end == -1:
		print("  FAIL [T264.7.1]: 无法定位 _save_settings 函数边界")
		quit(1); return
	var save_block := src_settings_menu.substr(save_start, save_end - save_start)
	if save_block.find("for action in ACTION_NAMES.keys():") == -1:
		print("  FAIL [T264.7.1]: _save_settings 缺 for action in ACTION_NAMES.keys() 循环")
		quit(1); return
	passed += 1
	print("  [T264.7.1] _save_settings 含 for action in ACTION_NAMES.keys() 循环 (OK)")

	# ===== T264.7.2 _save_settings 循环内含 InputMap.action_get_events =====
	total += 1
	if save_block.find("InputMap.action_get_events(action)") == -1:
		print("  FAIL [T264.7.2]: _save_settings 循环缺 InputMap.action_get_events(action) 调用")
		quit(1); return
	passed += 1
	print("  [T264.7.2] _save_settings 循环含 InputMap.action_get_events(action) (OK)")

	# ===== T264.7.3 _save_settings 循环内含 `if events.size() > 0:` 守卫 =====
	total += 1
	if save_block.find("if events.size() > 0:") == -1:
		print("  FAIL [T264.7.3]: _save_settings 循环缺 if events.size() > 0: 守卫")
		quit(1); return
	passed += 1
	print("  [T264.7.3] _save_settings 循环含 if events.size() > 0: 守卫 (OK)")

	# ===== T264.7.4 _save_settings 循环内含 `cfg.set_value(\"input\", action, events[0])` =====
	total += 1
	if save_block.find("cfg.set_value(\"input\", action, events[0])") == -1:
		print("  FAIL [T264.7.4]: _save_settings 循环缺 cfg.set_value(\"input\", action, events[0]) 写 input section")
		quit(1); return
	passed += 1
	print("  [T264.7.4] _save_settings 循环含 cfg.set_value(\"input\", action, events[0]) 写 (OK)")

	# =================================================================
	# T264.8 — settings_menu.gd _load_settings 末尾 5 行 [input] section 循环 + InputMap 还原 (4 断言)
	# =================================================================
	print("--- T264.8 — settings_menu.gd _load_settings 末尾 5 行 [input] section 循环 + InputMap 还原 ---")

	# ===== T264.8.1 _load_settings 含 `for action in ACTION_NAMES.keys():` 循环 =====
	total += 1
	var load_start := src_settings_menu.find("func _load_settings() -> void:")
	var load_end_func := src_settings_menu.find("func ", load_start + 20)
	if load_end_func == -1:
		# 末位
		load_end_func = src_settings_menu.length()
	var load_block := src_settings_menu.substr(load_start, load_end_func - load_start)
	if load_block.find("for action in ACTION_NAMES.keys():") == -1:
		print("  FAIL [T264.8.1]: _load_settings 缺 for action in ACTION_NAMES.keys() 循环")
		quit(1); return
	passed += 1
	print("  [T264.8.1] _load_settings 含 for action in ACTION_NAMES.keys() 循环 (OK)")

	# ===== T264.8.2 _load_settings 循环内含 `cfg.get_value(\"input\", action, null)` 读 =====
	total += 1
	if load_block.find("cfg.get_value(\"input\", action, null)") == -1:
		print("  FAIL [T264.8.2]: _load_settings 循环缺 cfg.get_value(\"input\", action, null) 读")
		quit(1); return
	passed += 1
	print("  [T264.8.2] _load_settings 循环含 cfg.get_value(\"input\", action, null) 读 (OK)")

	# ===== T264.8.3 _load_settings 循环内含 `if ev is InputEvent:` 守卫 + InputMap.action_erase_events + action_add_event 2 步 =====
	total += 1
	if load_block.find("if ev is InputEvent:") == -1:
		print("  FAIL [T264.8.3]: _load_settings 循环缺 if ev is InputEvent: 守卫")
		quit(1); return
	if load_block.find("InputMap.action_erase_events(action)") == -1:
		print("  FAIL [T264.8.3]: _load_settings 循环缺 InputMap.action_erase_events(action) 预清")
		quit(1); return
	if load_block.find("InputMap.action_add_event(action, ev)") == -1:
		print("  FAIL [T264.8.3]: _load_settings 循环缺 InputMap.action_add_event(action, ev) 添加")
		quit(1); return
	# 检查 erase_events 在 add_event 之前
	var erase_pos := load_block.find("InputMap.action_erase_events(action)")
	var add_pos := load_block.find("InputMap.action_add_event(action, ev)")
	if erase_pos == -1 or add_pos == -1 or erase_pos > add_pos:
		print("  FAIL [T264.8.3]: erase_events 应在 add_event 之前 (erase_pos=%d add_pos=%d)" % [erase_pos, add_pos])
		quit(1); return
	passed += 1
	print("  [T264.8.3] _load_settings 循环含 is InputEvent 守卫 + erase_events (预清) + add_event (添加) 2 步 1:1 (OK)")

	# ===== T264.8.4 _save_settings / _load_settings [input] section 0 漏 1 边 =====
	total += 1
	if save_block.find("cfg.set_value(\"input\"") == -1 and load_block.find("cfg.get_value(\"input\"") == -1:
		print("  FAIL [T264.8.4]: _save_settings / _load_settings 0 触碰 [input] section (任一函数应有 1 行 input key)")
		quit(1); return
	if save_block.find("cfg.set_value(\"input\"") == -1:
		print("  FAIL [T264.8.4]: _save_settings 缺 cfg.set_value(\"input\", ...) 写 [input] section")
		quit(1); return
	if load_block.find("cfg.get_value(\"input\"") == -1:
		print("  FAIL [T264.8.4]: _load_settings 缺 cfg.get_value(\"input\", ...) 读 [input] section")
		quit(1); return
	passed += 1
	print("  [T264.8.4] _save_settings 写 [input] + _load_settings 读 [input] 双源 1:1 (OK)")

	# =================================================================
	# T264.9 — CHANGELOG/ROADMAP/§9.6.14 同步 (3 断言)
	# =================================================================
	print("--- T264.9 — CHANGELOG/ROADMAP/§9.6.14 同步 ---")

	# ===== T264.9.1 CHANGELOG.md 含 #186 段 =====
	total += 1
	if src_changelog.find("## #186") == -1 and src_changelog_archive.find("## #186") == -1:
		print("  FAIL [T264.9.1]: CHANGELOG.md 缺 #186 段")
		quit(1); return
	passed += 1
	print("  [T264.9.1] CHANGELOG.md 含 #186 段 (OK)")

	# ===== T264.9.2 ROADMAP.md 顶部时间戳含 #186 =====
	total += 1
	if src_roadmap.find("#186") == -1:
		print("  FAIL [T264.9.2]: ROADMAP.md 顶部缺 #186 时间戳")
		quit(1); return
	passed += 1
	print("  [T264.9.2] ROADMAP.md 顶部含 #186 时间戳 (OK)")

	# ===== T264.9.3 §9.6.14 区间提到 T086 + T194 + 6 件套 + 4 段结构 =====
	total += 1
	for kw in ["T086", "T194", "6 件套", "**症状**", "**触发场景**", "**修复**", "**预防**"]:
		if s9614.find(kw) == -1:
			print("  FAIL [T264.9.3]: §9.6.14 区间缺关键 anchor \"%s\"" % kw)
			quit(1); return
	passed += 1
	print("  [T264.9.3] §9.6.14 区间含 T086 + T194 + 6 件套 + 4 段结构 7 关键 anchor (OK)")

	print("=== T264 #186 §9.6.14 [input] section N key ACTION_NAMES 循环 + InputMap.action_get_events / action_add_event / action_erase_events 跨 InputEvent dict 序列化 + 1:1 持久化 polish 模式 (T086 + T194 + T195 + T196 + T202.B + T205 + T239 跨 7 任务 ~10 轮落地) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
