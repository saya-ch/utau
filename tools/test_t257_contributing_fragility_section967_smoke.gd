extends SceneTree
## T257 (#177) — §9.6.7 ProfileRecentList 5 行 row hover feedback 三件套 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t257_contributing_fragility_section967_smoke.gd
##
## T257: CONTRIBUTING.md §9.6.7 已知 fragility 扩展
##   - §9.6.7 ProfileRecentList 5 行 row hover feedback 三件套 polish 模式
##     (T231 #151 + T240 #158 + T235 #154 落地)
##   - 5 行 hover +0.1 alpha boost (T231) + 5 行 font_color 0.12s tween (T240) +
##     5 行 row 文本字段间 ·  middle-dot 分隔符 (T235) 三件套
##   - 跨面板 hover 反馈节奏 100% 闭环 (T225 + T226 + T231 + T240)
##   - 0.12s 节奏同步 (T231 alpha + T240 font_color + T226 slot)
## 验证 5 维:
##   - §9.6.7 章节在 CONTRIBUTING.md 已落地
##   - §9.6.7 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - pause_menu.gd _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST 0.1 (T231)
##     - pause_menu.gd _RECENT_ROW_HOVER_FADE_DURATION 0.12 (T231)
##     - pause_menu.gd _RECENT_ROW_FONT_COLOR_FADE_DURATION 0.12 (T240)
##     - pause_menu.gd _recent_row_hover_alpha_base 字典 (T231)
##     - pause_menu.gd _recent_row_font_color_tween 单 tween (T240)
##     - pause_menu.gd _RECENT_ROW_FIELD_SEP = "  ·  " middle-dot (T235)
##   - CHANGELOG.md 含 #177 段 + ROADMAP.md 顶部时间戳含 #177

func _initialize() -> void:
	print("=== T257 #177 §9.6.7 ProfileRecentList 5 行 row hover feedback 三件套 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T257.1 — §9.6.7 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T257.1 — §9.6.7 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T257.1.1 §9.6.7 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.7 ProfileRecentList 5 行 row hover feedback 三件套 polish 模式 (T231 #151 + T240 #158 + T235 #154 落地)") == -1:
		print("  FAIL [T257.1.1]: CONTRIBUTING.md 缺 §9.6.7 章节标题")
		quit(1); return
	passed += 1
	print("  [T257.1.1] CONTRIBUTING.md 含 §9.6.7 章节标题 (OK)")

	# ===== T257.1.2 §9.6.7 含 T231 + T240 + T235 三个 anchor =====
	total += 1
	var s967_start := src_contributing.find("### 9.6.7")
	var s10_start := src_contributing.find("## 10.")
	if s967_start == -1 or s10_start == -1:
		print("  FAIL [T257.1.2]: §9.6.7 / ## 10 区间划分失败")
		quit(1); return
	var s967 := src_contributing.substr(s967_start, s10_start - s967_start)
	if "T231" not in s967:
		print("  FAIL [T257.1.2]: §9.6.7 区间缺 T231 anchor (T231 #151 5 行 alpha boost 0.1 落地任务)")
		quit(1); return
	if "T240" not in s967:
		print("  FAIL [T257.1.2]: §9.6.7 区间缺 T240 anchor (T240 #158 5 行 font_color 0.12s tween 落地任务)")
		quit(1); return
	if "T235" not in s967:
		print("  FAIL [T257.1.2]: §9.6.7 区间缺 T235 anchor (T235 #154 middle-dot 跨面板分隔符落地任务)")
		quit(1); return
	passed += 1
	print("  [T257.1.2] CONTRIBUTING.md §9.6.7 区间含 T231 + T240 + T235 三个 anchor (OK)")

	# ===== T257.1.3 §9.6.7 提到三件套核心概念 =====
	total += 1
	if s967.find("三件套") == -1:
		print("  FAIL [T257.1.3]: §9.6.7 缺「三件套」核心概念 (T231+T240+T235 三件套)")
		quit(1); return
	passed += 1
	print("  [T257.1.3] CONTRIBUTING.md §9.6.7 含「三件套」核心概念 (OK)")

	# =================================================================
	# T257.2 — §9.6.7 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T257.2 — §9.6.7 4 段结构 ---")

	# ===== T257.2.1 §9.6.7 症状 =====
	total += 1
	if s967.find("**症状**") == -1:
		print("  FAIL [T257.2.1]: §9.6.7 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T257.2.1] §9.6.7 含「症状」段 (OK)")

	# ===== T257.2.2 §9.6.7 触发场景 =====
	total += 1
	if s967.find("**触发场景**") == -1:
		print("  FAIL [T257.2.2]: §9.6.7 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T257.2.2] §9.6.7 含「触发场景」段 (OK)")

	# ===== T257.2.3 §9.6.7 修复 =====
	total += 1
	if s967.find("**修复**") == -1:
		print("  FAIL [T257.2.3]: §9.6.7 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T257.2.3] §9.6.7 含「修复」段 (OK)")

	# ===== T257.2.4 §9.6.7 预防 =====
	total += 1
	if s967.find("**预防**") == -1:
		print("  FAIL [T257.2.4]: §9.6.7 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T257.2.4] §9.6.7 含「预防」段 (OK)")

	# =================================================================
	# T257.3 — pause_menu.gd T231 + T240 + T235 三件套 const (5 断言)
	# =================================================================
	print("--- T257.3 — pause_menu.gd T231 + T240 + T235 三件套 const ---")

	# ===== T257.3.1 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST 0.1 (T231) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1") == -1:
		print("  FAIL [T257.3.1]: pause_menu.gd 缺 const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1 (T231 5 行 hover +0.1 alpha boost)")
		quit(1); return
	passed += 1
	print("  [T257.3.1] pause_menu.gd 含 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1 (T231) (OK)")

	# ===== T257.3.2 _RECENT_ROW_HOVER_FADE_DURATION 0.12 (T231) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_HOVER_FADE_DURATION := 0.12") == -1:
		print("  FAIL [T257.3.2]: pause_menu.gd 缺 const _RECENT_ROW_HOVER_FADE_DURATION := 0.12 (T231 alpha 0.12s fade)")
		quit(1); return
	passed += 1
	print("  [T257.3.2] pause_menu.gd 含 _RECENT_ROW_HOVER_FADE_DURATION := 0.12 (T231) (OK)")

	# ===== T257.3.3 _RECENT_ROW_FONT_COLOR_FADE_DURATION 0.12 (T240) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12") == -1:
		print("  FAIL [T257.3.3]: pause_menu.gd 缺 const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12 (T240 font_color 0.12s tween)")
		quit(1); return
	passed += 1
	print("  [T257.3.3] pause_menu.gd 含 _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12 (T240) (OK)")

	# ===== T257.3.4 _RECENT_ROW_FIELD_SEP = "  ·  " middle-dot (T235) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_FIELD_SEP := \"  ·  \"") == -1:
		print("  FAIL [T257.3.4]: pause_menu.gd 缺 const _RECENT_ROW_FIELD_SEP := \"  ·  \" (T235 middle-dot 跨面板分隔符)")
		quit(1); return
	passed += 1
	print("  [T257.3.4] pause_menu.gd 含 _RECENT_ROW_FIELD_SEP := \"  ·  \" middle-dot (T235) (OK)")

	# ===== T257.3.5 _RECENT_ROW_TIP_INDICATOR 末位保留 (T234) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_TIP_INDICATOR := \" ↗\"") == -1:
		print("  FAIL [T257.3.5]: pause_menu.gd 缺 const _RECENT_ROW_TIP_INDICATOR := \" ↗\" (T234 #153 tip indicator 末位保留)")
		quit(1); return
	passed += 1
	print("  [T257.3.5] pause_menu.gd 含 _RECENT_ROW_TIP_INDICATOR := \" ↗\" (T234 末位保留) (OK)")

	# =================================================================
	# T257.4 — pause_menu.gd _recent_row_hover_alpha_base 字典 + _recent_row_font_color_tween (3 断言)
	# =================================================================
	print("--- T257.4 — pause_menu.gd T231 base alpha 字典 + T240 font_color tween ---")

	# ===== T257.4.1 _recent_row_hover_alpha_base 字典 (T231) =====
	total += 1
	if src_pause_menu.find("var _recent_row_hover_alpha_base: Dictionary = {}") == -1:
		print("  FAIL [T257.4.1]: pause_menu.gd 缺 var _recent_row_hover_alpha_base: Dictionary = {} (T231 5 行 base alpha 字典)")
		quit(1); return
	passed += 1
	print("  [T257.4.1] pause_menu.gd 含 _recent_row_hover_alpha_base 字典 (T231) (OK)")

	# ===== T257.4.2 _recent_row_font_color_tween 单 tween (T240) =====
	total += 1
	if src_pause_menu.find("var _recent_row_font_color_tween: Tween = null") == -1:
		print("  FAIL [T257.4.2]: pause_menu.gd 缺 var _recent_row_font_color_tween: Tween = null (T240 5 行共享 1 个 tween)")
		quit(1); return
	passed += 1
	print("  [T257.4.2] pause_menu.gd 含 _recent_row_font_color_tween 单 tween (T240) (OK)")

	# ===== T257.4.3 _recent_row_hovered 数组 (T215/T231) =====
	total += 1
	if src_pause_menu.find("var _recent_row_hovered: Array = []") == -1:
		print("  FAIL [T257.4.3]: pause_menu.gd 缺 var _recent_row_hovered: Array = [] (T215/T231 5 行独立 bool re-entrant guard)")
		quit(1); return
	passed += 1
	print("  [T257.4.3] pause_menu.gd 含 _recent_row_hovered 数组 (T215/T231) (OK)")

	# =================================================================
	# T257.5 — pause_menu.gd 0.12s 节奏同步 (T231 alpha + T240 font_color 跨节奏) (2 断言)
	# =================================================================
	print("--- T257.5 — pause_menu.gd 0.12s 节奏同步 (T231 + T240) ---")

	# ===== T257.5.1 T231 _RECENT_ROW_HOVER_FADE_DURATION 在 _apply_reduced_flash_modulate / hover handler 中 =====
	total += 1
	var hover_fade_idx := src_pause_menu.find("const _RECENT_ROW_HOVER_FADE_DURATION := 0.12")
	if hover_fade_idx == -1:
		print("  FAIL [T257.5.1]: T231 _RECENT_ROW_HOVER_FADE_DURATION 找不到")
		quit(1); return
	var hover_fade_window := src_pause_menu.substr(hover_fade_idx, 200)
	if "T231" not in hover_fade_window:
		print("  FAIL [T257.5.1]: T231 _RECENT_ROW_HOVER_FADE_DURATION 周围 docblock 缺 T231 anchor")
		quit(1); return
	passed += 1
	print("  [T257.5.1] T231 _RECENT_ROW_HOVER_FADE_DURATION 周围 docblock 含 T231 anchor (OK)")

	# ===== T257.5.2 T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 与 T231 _RECENT_ROW_HOVER_FADE_DURATION 同节奏 (0.12 = 0.12) =====
	total += 1
	var font_color_fade_idx := src_pause_menu.find("const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12")
	if font_color_fade_idx == -1:
		print("  FAIL [T257.5.2]: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 找不到")
		quit(1); return
	var font_color_fade_window := src_pause_menu.substr(font_color_fade_idx, 400)
	if "T240" not in font_color_fade_window:
		print("  FAIL [T257.5.2]: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 周围 docblock 缺 T240 anchor")
		quit(1); return
	if "0.12" not in font_color_fade_window:
		print("  FAIL [T257.5.2]: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 周围 docblock 缺 0.12 节奏值")
		quit(1); return
	passed += 1
	print("  [T257.5.2] T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 周围 docblock 含 T240 anchor + 0.12 节奏值 (OK)")

	# =================================================================
	# T257.6 — CONTRIBUTING.md §9.6.7 核心三件套概念 (3 断言)
	# =================================================================
	print("--- T257.6 — CONTRIBUTING.md §9.6.7 核心三件套概念 ---")

	# ===== T257.6.1 §9.6.7 提到 T231 alpha boost 0.1 =====
	total += 1
	if s967.find("0.1") == -1 or s967.find("alpha") == -1:
		print("  FAIL [T257.6.1]: §9.6.7 缺 T231 alpha boost 0.1 描述")
		quit(1); return
	passed += 1
	print("  [T257.6.1] §9.6.7 含 T231 alpha boost 0.1 描述 (OK)")

	# ===== T257.6.2 §9.6.7 提到 T240 0.12s tween =====
	total += 1
	if s967.find("0.12") == -1 or s967.find("tween") == -1:
		print("  FAIL [T257.6.2]: §9.6.7 缺 T240 0.12s tween 描述")
		quit(1); return
	passed += 1
	print("  [T257.6.2] §9.6.7 含 T240 0.12s tween 描述 (OK)")

	# ===== T257.6.3 §9.6.7 提到 T235 middle-dot 跨面板分隔符 =====
	total += 1
	if s967.find("·") == -1 and s967.find("中点") == -1 and s967.find("middle-dot") == -1:
		print("  FAIL [T257.6.3]: §9.6.7 缺 T235 middle-dot 跨面板分隔符描述")
		quit(1); return
	passed += 1
	print("  [T257.6.3] §9.6.7 含 T235 middle-dot 跨面板分隔符描述 (OK)")

	# =================================================================
	# T257.7 — pause_menu.gd T231 + T240 + T235 三个 const docblock anchor (3 断言)
	# =================================================================
	print("--- T257.7 — pause_menu.gd T231 + T240 + T235 三个 const docblock anchor ---")

	# ===== T257.7.1 T231 _RECENT_ROW_HOVER_FADE_DURATION 周围 2000 char docblock 含 T231 anchor =====
	total += 1
	var t231_const_idx := src_pause_menu.find("const _RECENT_ROW_HOVER_FADE_DURATION := 0.12")
	if t231_const_idx == -1:
		print("  FAIL [T257.7.1]: T231 _RECENT_ROW_HOVER_FADE_DURATION 找不到")
		quit(1); return
	var t231_doc_window := src_pause_menu.substr(max(0, t231_const_idx - 2000), 2000)
	if "T231" not in t231_doc_window:
		print("  FAIL [T257.7.1]: T231 _RECENT_ROW_HOVER_FADE_DURATION 周围 2000 char docblock 缺 T231 anchor")
		quit(1); return
	passed += 1
	print("  [T257.7.1] T231 _RECENT_ROW_HOVER_FADE_DURATION 周围 2000 char docblock 含 T231 anchor (OK)")

	# ===== T257.7.2 T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 周围 1500 char docblock 含 T240 anchor =====
	total += 1
	var t240_const_idx := src_pause_menu.find("const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12")
	if t240_const_idx == -1:
		print("  FAIL [T257.7.2]: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 找不到")
		quit(1); return
	var t240_doc_window := src_pause_menu.substr(max(0, t240_const_idx - 1500), 1500)
	if "T240" not in t240_doc_window:
		print("  FAIL [T257.7.2]: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 周围 1500 char docblock 缺 T240 anchor")
		quit(1); return
	passed += 1
	print("  [T257.7.2] T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 周围 1500 char docblock 含 T240 anchor (OK)")

	# ===== T257.7.3 T235 _RECENT_ROW_FIELD_SEP 周围 800 char docblock 含 T235 anchor =====
	total += 1
	var t235_const_idx := src_pause_menu.find("const _RECENT_ROW_FIELD_SEP := \"  ·  \"")
	if t235_const_idx == -1:
		print("  FAIL [T257.7.3]: T235 _RECENT_ROW_FIELD_SEP 找不到")
		quit(1); return
	var t235_doc_window := src_pause_menu.substr(max(0, t235_const_idx - 800), 800)
	if "T235" not in t235_doc_window:
		print("  FAIL [T257.7.3]: T235 _RECENT_ROW_FIELD_SEP 周围 800 char docblock 缺 T235 anchor")
		quit(1); return
	passed += 1
	print("  [T257.7.3] T235 _RECENT_ROW_FIELD_SEP 周围 800 char docblock 含 T235 anchor (OK)")

	# =================================================================
	# T257.8 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T257.8 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T257.8.1 CHANGELOG.md 含 #177 段 =====
	total += 1
	if src_changelog.find("## #177 — T257") == -1:
		print("  FAIL [T257.8.1]: CHANGELOG.md 缺 #177 段")
		quit(1); return
	passed += 1
	print("  [T257.8.1] CHANGELOG.md 含 #177 段 (OK)")

	# ===== T257.8.2 ROADMAP.md 顶部时间戳含 #177 =====
	total += 1
	if src_roadmap.find("#177") == -1:
		print("  FAIL [T257.8.2]: ROADMAP.md 顶部缺 #177 时间戳")
		quit(1); return
	passed += 1
	print("  [T257.8.2] ROADMAP.md 顶部含 #177 时间戳 (OK)")

	print("=== T257 #177 §9.6.7 ProfileRecentList 5 行 row hover feedback 三件套 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
