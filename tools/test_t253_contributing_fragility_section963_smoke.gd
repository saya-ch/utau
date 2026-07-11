extends SceneTree
## T253 (#172) — §9.6.3 6 verb HUD 5+1 verb 7 UI 通道 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t253_contributing_fragility_section963_smoke.gd
##
## T253: CONTRIBUTING.md §9.6.3 已知 fragility 扩展
##   - §9.6.3 6 verb HUD 5+1 verb 7 UI 通道 polish 模式 (T247 #164 落地)
## 验证 4 维:
##   - §9.6.3 章节在 CONTRIBUTING.md 已落地
##   - §9.6.3 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - hud.gd _WHISPER_GLOW_COLOR const = Muted Mauve #C8A4D8 存在
##     - hud.gd _verb_glow_state dict 6 key (pulse/bind/cut/echo/wave/whisper) 全部存在
##     - hud.gd _apply_reduced_flash_modulate iteration list 8 元素含 _whisper_cooldown
##     - hud.gd @onready var _whisper_cooldown / _whisper_cooldown_label / _whisper_name_label 3 个存在
##   - CHANGELOG.md 含 #172 段 + ROADMAP.md 顶部时间戳含 #172

func _initialize() -> void:
	print("=== T253 #172 §9.6.3 6 verb HUD 5+1 verb 7 UI 通道 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_hud := _read_file("res://src/scripts/hud.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T253.1 — §9.6.3 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T253.1 — §9.6.3 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T253.1.1 §9.6.3 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.3 6 verb HUD 5+1 verb 7 UI 通道 polish 模式") == -1:
		print("  FAIL [T253.1.1]: CONTRIBUTING.md 缺 §9.6.3 章节标题")
		quit(1); return
	passed += 1
	print("  [T253.1.1] CONTRIBUTING.md 含 §9.6.3 章节标题 (OK)")

	# ===== T253.1.2 §9.6.3 含 T247 #164 anchor =====
	total += 1
	if src_contributing.find("T247 #164") == -1:
		print("  FAIL [T253.1.2]: CONTRIBUTING.md §9.6.3 缺 T247 #164 anchor")
		quit(1); return
	passed += 1
	print("  [T253.1.2] CONTRIBUTING.md §9.6.3 含 T247 #164 anchor (OK)")

	# ===== T253.1.3 §9.6.3 提到 5+1 verb 7 UI 通道 =====
	total += 1
	if src_contributing.find("5+1 verb 7 UI 通道") == -1:
		print("  FAIL [T253.1.3]: CONTRIBUTING.md §9.6.3 缺 5+1 verb 7 UI 通道 核心概念")
		quit(1); return
	passed += 1
	print("  [T253.1.3] CONTRIBUTING.md §9.6.3 含 5+1 verb 7 UI 通道 核心概念 (OK)")

	# =================================================================
	# T253.2 — §9.6.3 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T253.2 — §9.6.3 4 段结构 ---")

	# ===== T253.2.1 §9.6.3 区间划分 =====
	total += 1
	var s963_start := src_contributing.find("### 9.6.3 6 verb HUD")
	var s963_end := src_contributing.find("## 10.")
	if s963_start == -1 or s963_end == -1:
		print("  FAIL [T253.2.1]: CONTRIBUTING.md §9.6.3 / ## 10 区间划分失败")
		quit(1); return
	var s963 := src_contributing.substr(s963_start, s963_end - s963_start)
	passed += 1
	print("  [T253.2.1] §9.6.3 区间划分成功 (OK)")

	# ===== T253.2.2 §9.6.3 症状 =====
	total += 1
	if s963.find("**症状**") == -1:
		print("  FAIL [T253.2.2]: §9.6.3 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T253.2.2] §9.6.3 含「症状」段 (OK)")

	# ===== T253.2.3 §9.6.3 触发 =====
	total += 1
	if s963.find("**触发场景**") == -1:
		print("  FAIL [T253.2.3]: §9.6.3 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T253.2.3] §9.6.3 含「触发场景」段 (OK)")

	# ===== T253.2.4 §9.6.3 修复 =====
	total += 1
	if s963.find("**修复**") == -1:
		print("  FAIL [T253.2.4]: §9.6.3 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T253.2.4] §9.6.3 含「修复」段 (OK)")

	# ===== T253.2.5 §9.6.3 预防 =====
	total += 1
	if s963.find("**预防**") == -1:
		print("  FAIL [T253.2.5]: §9.6.3 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T253.2.5] §9.6.3 含「预防」段 (OK)")

	# =================================================================
	# T253.3 — hud.gd _WHISPER_GLOW_COLOR const 实际存在 (3 断言)
	# =================================================================
	print("--- T253.3 — hud.gd _WHISPER_GLOW_COLOR const ---")

	# ===== T253.3.1 _WHISPER_GLOW_COLOR const 声明 =====
	total += 1
	if src_hud.find("const _WHISPER_GLOW_COLOR := Color(0.784, 0.643, 0.847, 1.0)") == -1:
		print("  FAIL [T253.3.1]: hud.gd 缺 _WHISPER_GLOW_COLOR const 声明 (Muted Mauve #C8A4D8)")
		quit(1); return
	passed += 1
	print("  [T253.3.1] hud.gd 含 _WHISPER_GLOW_COLOR const = Muted Mauve #C8A4D8 (OK)")

	# ===== T253.3.2 _WHISPER_GLOW_COLOR 注释锚点 T245 =====
	total += 1
	if src_hud.find("T245") == -1 or src_hud.find("_WHISPER_GLOW_COLOR") == -1:
		print("  FAIL [T253.3.2]: hud.gd _WHISPER_GLOW_COLOR 注释锚点 T245 缺失")
		quit(1); return
	# 找 _WHISPER_GLOW_COLOR 行 5 行内是否有 T245 anchor
	var whisper_glow_idx := src_hud.find("const _WHISPER_GLOW_COLOR")
	if whisper_glow_idx == -1:
		print("  FAIL [T253.3.2]: hud.gd _WHISPER_GLOW_COLOR 找不到")
		quit(1); return
	var window := src_hud.substr(max(0, whisper_glow_idx - 500), 800)
	if window.find("T245") == -1:
		print("  FAIL [T253.3.2]: hud.gd _WHISPER_GLOW_COLOR 周围 800 字符缺 T245 注释")
		quit(1); return
	passed += 1
	print("  [T253.3.2] hud.gd _WHISPER_GLOW_COLOR 注释锚点 T245 在 800 字符窗口 (OK)")

	# ===== T253.3.3 Muted Mauve hex #C8A4D8 颜色名注释 =====
	total += 1
	if src_hud.find("Muted Mauve") == -1 or src_hud.find("#C8A4D8") == -1:
		print("  FAIL [T253.3.3]: hud.gd 缺 Muted Mauve / #C8A4D8 颜色名注释")
		quit(1); return
	passed += 1
	print("  [T253.3.3] hud.gd 含 Muted Mauve #C8A4D8 颜色名注释 (OK)")

	# =================================================================
	# T253.4 — hud.gd _verb_glow_state dict 6 key 全部存在 (2 断言)
	# =================================================================
	print("--- T253.4 — hud.gd _verb_glow_state dict 6 key ---")

	# ===== T253.4.1 _verb_glow_state 6 key 全部存在 =====
	total += 1
	var glow_dict_block := _extract_dict_block(src_hud, "_verb_glow_state")
	if glow_dict_block.is_empty():
		print("  FAIL [T253.4.1]: hud.gd 找不到 _verb_glow_state dict")
		quit(1); return
	var expected_keys := ["pulse", "bind", "cut", "echo", "wave", "whisper"]
	var missing: Array[String] = []
	for k in expected_keys:
		if not ("\"%s\"" % k) in glow_dict_block:
			missing.append(k)
	if missing.size() > 0:
		print("  FAIL [T253.4.1]: _verb_glow_state 缺 key: %s" % str(missing))
		quit(1); return
	passed += 1
	print("  [T253.4.1] _verb_glow_state 含 6 key (pulse/bind/cut/echo/wave/whisper) (OK)")

	# ===== T253.4.2 _verb_glow_state T247 anchor =====
	total += 1
	if not "T247" in glow_dict_block and not "T247" in src_hud.substr(max(0, src_hud.find("_verb_glow_state") - 200), 800):
		print("  FAIL [T253.4.2]: _verb_glow_state 周围 800 字符缺 T247 anchor")
		quit(1); return
	passed += 1
	print("  [T253.4.2] _verb_glow_state 周围有 T247 anchor (OK)")

	# =================================================================
	# T253.5 — hud.gd _apply_reduced_flash_modulate iteration list 8 元素 (3 断言)
	# =================================================================
	print("--- T253.5 — hud.gd _apply_reduced_flash_modulate iteration list 8 元素 ---")

	# ===== T253.5.1 _apply_reduced_flash_modulate 函数存在 =====
	total += 1
	var reduce_func_idx := src_hud.find("func _apply_reduced_flash_modulate")
	if reduce_func_idx == -1:
		print("  FAIL [T253.5.1]: hud.gd 缺 _apply_reduced_flash_modulate 函数")
		quit(1); return
	passed += 1
	print("  [T253.5.1] hud.gd 含 _apply_reduced_flash_modulate 函数 (OK)")

	# ===== T253.5.2 iteration list 含 _whisper_cooldown =====
	total += 1
	var reduce_slice := src_hud.substr(reduce_func_idx, min(1500, src_hud.length() - reduce_func_idx))
	var list_start := reduce_slice.find("ui_elem in [")
	if list_start == -1:
		print("  FAIL [T253.5.2]: 'ui_elem in [...]' iteration list 找不到")
		quit(1); return
	var list_end := reduce_slice.find("]", list_start)
	if list_end == -1:
		print("  FAIL [T253.5.2]: iteration list 结束 ']' 找不到")
		quit(1); return
	var list_body := reduce_slice.substr(list_start, list_end - list_start + 1)
	if "_whisper_cooldown" not in list_body:
		print("  FAIL [T253.5.2]: iteration list 缺 _whisper_cooldown")
		quit(1); return
	passed += 1
	print("  [T253.5.2] iteration list 含 _whisper_cooldown (OK)")

	# ===== T253.5.3 iteration list 8 元素全部存在 =====
	total += 1
	var expected_elems := [
		"_pulse_cooldown",
		"_bind_cooldown",
		"_cut_cooldown",
		"_echo_cooldown",
		"_wave_cooldown",
		"_whisper_cooldown",
		"_resonance_bar",
		"_health_container",
	]
	var missing_elems: Array[String] = []
	for e in expected_elems:
		if e not in list_body:
			missing_elems.append(e)
	if missing_elems.size() > 0:
		print("  FAIL [T253.5.3]: iteration list 缺元素: %s" % str(missing_elems))
		quit(1); return
	passed += 1
	print("  [T253.5.3] iteration list 含 8 元素 (5 verb + whisper + resonance + health) (OK)")

	# =================================================================
	# T253.6 — hud.gd @onready var 3 个 whisper var 实际存在 (3 断言)
	# =================================================================
	print("--- T253.6 — hud.gd @onready var 3 个 whisper ---")

	# ===== T253.6.1 @onready var _whisper_cooldown =====
	total += 1
	if not "@onready var _whisper_cooldown" in src_hud:
		print("  FAIL [T253.6.1]: hud.gd 缺 @onready var _whisper_cooldown")
		quit(1); return
	passed += 1
	print("  [T253.6.1] hud.gd 含 @onready var _whisper_cooldown (OK)")

	# ===== T253.6.2 @onready var _whisper_cooldown_label =====
	total += 1
	if not "@onready var _whisper_cooldown_label" in src_hud:
		print("  FAIL [T253.6.2]: hud.gd 缺 @onready var _whisper_cooldown_label")
		quit(1); return
	passed += 1
	print("  [T253.6.2] hud.gd 含 @onready var _whisper_cooldown_label (OK)")

	# ===== T253.6.3 @onready var _whisper_name_label =====
	total += 1
	if not "@onready var _whisper_name_label" in src_hud:
		print("  FAIL [T253.6.3]: hud.gd 缺 @onready var _whisper_name_label")
		quit(1); return
	passed += 1
	print("  [T253.6.3] hud.gd 含 @onready var _whisper_name_label (OK)")

	# =================================================================
	# T253.7 — hud.gd _whisper_ability 引用 + 6 step _ready (2 断言)
	# =================================================================
	print("--- T253.7 — hud.gd _whisper_ability 引用 + 6 step _ready ---")

	# ===== T253.7.1 _whisper_ability var + get_node_or_null =====
	total += 1
	if not "var _whisper_ability" in src_hud:
		print("  FAIL [T253.7.1]: hud.gd 缺 var _whisper_ability")
		quit(1); return
	if not "get_node_or_null(\"WhisperAbility\")" in src_hud:
		print("  FAIL [T253.7.1]: hud.gd 缺 WhisperAbility get_node_or_null 守卫")
		quit(1); return
	passed += 1
	print("  [T253.7.1] hud.gd 含 _whisper_ability 引用 + WhisperAbility get_node_or_null 守卫 (OK)")

	# ===== T253.7.2 _whisper_glow_bg stylebox =====
	total += 1
	if not "_whisper_glow_bg" in src_hud:
		print("  FAIL [T253.7.2]: hud.gd 缺 _whisper_glow_bg stylebox 分配")
		quit(1); return
	if not "_whisper_glow_bg = _create_verb_glow_stylebox(_WHISPER_GLOW_COLOR)" in src_hud:
		print("  FAIL [T253.7.2]: hud.gd 缺 _whisper_glow_bg = _create_verb_glow_stylebox 分配")
		quit(1); return
	passed += 1
	print("  [T253.7.2] hud.gd 含 _whisper_glow_bg = _create_verb_glow_stylebox(_WHISPER_GLOW_COLOR) 分配 (OK)")

	# =================================================================
	# T253.8 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T253.8 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T253.8.1 CHANGELOG.md 含 #172 段 =====
	total += 1
	if src_changelog.find("## #172 — T253") == -1 and src_changelog_archive.find("## #172 — T253") == -1:
		print("  FAIL [T253.8.1]: CHANGELOG.md 缺 #172 段")
		quit(1); return
	passed += 1
	print("  [T253.8.1] CHANGELOG.md 含 #172 段 (OK)")

	# ===== T253.8.2 ROADMAP.md 顶部时间戳含 #172 =====
	total += 1
	if src_roadmap.find("#172") == -1:
		print("  FAIL [T253.8.2]: ROADMAP.md 顶部缺 #172 时间戳")
		quit(1); return
	passed += 1
	print("  [T253.8.2] ROADMAP.md 顶部含 #172 时间戳 (OK)")

	print("=== T253 #172 §9.6.3 6 verb HUD 5+1 verb 7 UI 通道 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _extract_dict_block(src: String, marker: String) -> String:
	# 找 var marker: Dictionary = { ... } 块 (从 marker 起到平衡的 } 为止)
	var idx := src.find(marker)
	if idx == -1:
		return ""
	var open_idx := src.find("{", idx)
	if open_idx == -1:
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
