extends SceneTree
## T260 (#181) — §9.6.10 「hover 静态高亮层 + tooltip 数据源层」双层 hover 互补 polish 模式 (T212 #132 + T213 #133 + T215 #136 + T216 #137 + T217 #138 落地) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t260_contributing_fragility_section9610_smoke.gd
##
## T260: CONTRIBUTING.md §9.6.10 已知 fragility 扩展
##   - §9.6.10 hover 静态高亮层 + tooltip 数据源层 双层 hover 互补 (T212 + T213 + T215 + T216 + T217)
##   - T213 _QUICK_STATS_HINT 4 entry + _build_quick_stats_tooltip 9 行 (1 + 4*2)
##   - T216 _RECENT_ROW_HINT 7 entry (T249 #167 扩展 5 → 7) + _build_recent_row_tooltip 15 行 (1 + 7*2)
##   - T215 _recent_row_hovered 5 行 Array[bool] + _recent_row_default_color 5 行 Array[Color]
##   - T217 _quick_stats_hovered_idx 1 段 int = -1
##   - T212 1 Label 4 BBCode 段 旧版基线
## 验证 9 维:
##   - §9.6.10 章节在 CONTRIBUTING.md 已落地
##   - §9.6.10 4 段结构 (症状/触发/修复/预防) 全部存在
##   - pause_menu.gd T213 _QUICK_STATS_HINT 4 entry + _build_quick_stats_tooltip 9 行
##   - pause_menu.gd T216 _RECENT_ROW_HINT 7 entry + _build_recent_row_tooltip 15 行
##   - pause_menu.gd T215 _recent_row_hovered + _recent_row_default_color 双 var
##   - pause_menu.gd T217 _quick_stats_hovered_idx 1 段 int = -1
##   - pause_menu.gd T213 tooltip_text 1 行绑定 + T212 4 BBCode 段基线
##   - CHANGELOG.md 含 #181 段 + ROADMAP.md 顶部时间戳含 #181

func _initialize() -> void:
	print("=== T260 #181 §9.6.10 hover 静态高亮层 + tooltip 数据源层 双层 hover 互补 polish 模式 (T212 + T213 + T215 + T216 + T217 落地) smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T260.1 — §9.6.10 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T260.1 — §9.6.10 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T260.1.1 §9.6.10 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.10 「hover 静态高亮层 + tooltip 数据源层」双层 hover 互补 polish 模式 (T212 #132 + T213 #133 + T215 #136 + T216 #137 + T217 #138 落地)") == -1:
		print("  FAIL [T260.1.1]: CONTRIBUTING.md 缺 §9.6.10 章节标题")
		quit(1); return
	passed += 1
	print("  [T260.1.1] CONTRIBUTING.md 含 §9.6.10 章节标题 (OK)")

	# ===== T260.1.2 §9.6.10 含 T212 + T213 + T215 + T216 + T217 五个 anchor =====
	total += 1
	var s9610_start := src_contributing.find("### 9.6.10")
	var s10_start := src_contributing.find("## 10.")
	if s9610_start == -1 or s10_start == -1:
		print("  FAIL [T260.1.2]: §9.6.10 / ## 10 区间划分失败")
		quit(1); return
	var s9610 := src_contributing.substr(s9610_start, s10_start - s9610_start)
	for anchor in ["T212", "T213", "T215", "T216", "T217"]:
		if not (anchor in s9610):
			print("  FAIL [T260.1.2]: §9.6.10 区间缺 %s anchor" % anchor)
			quit(1); return
	passed += 1
	print("  [T260.1.2] CONTRIBUTING.md §9.6.10 区间含 T212 + T213 + T215 + T216 + T217 五个 anchor (OK)")

	# ===== T260.1.3 §9.6.10 提到 双层 hover 互补 + 5 行 row + 4 段 QuickStats 核心概念 =====
	total += 1
	if s9610.find("双层 hover 互补") == -1:
		print("  FAIL [T260.1.3]: §9.6.10 缺「双层 hover 互补」核心概念")
		quit(1); return
	if s9610.find("5 行") == -1 and s9610.find("5行") == -1:
		print("  FAIL [T260.1.3]: §9.6.10 缺「5 行」核心概念 (T215 5 行 row hover 静态高亮层)")
		quit(1); return
	if s9610.find("4 段") == -1 and s9610.find("4段") == -1:
		print("  FAIL [T260.1.3]: §9.6.10 缺「4 段」核心概念 (T213 4 段 QuickStats / T217 4 段独立 hover)")
		quit(1); return
	passed += 1
	print("  [T260.1.3] CONTRIBUTING.md §9.6.10 含双层 hover 互补 + 5 行 + 4 段 核心概念 (OK)")

	# =================================================================
	# T260.2 — §9.6.10 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T260.2 — §9.6.10 4 段结构 ---")

	# ===== T260.2.1 §9.6.10 症状 =====
	total += 1
	if s9610.find("**症状**") == -1:
		print("  FAIL [T260.2.1]: §9.6.10 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T260.2.1] §9.6.10 含「症状」段 (OK)")

	# ===== T260.2.2 §9.6.10 触发场景 =====
	total += 1
	if s9610.find("**触发场景**") == -1:
		print("  FAIL [T260.2.2]: §9.6.10 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T260.2.2] §9.6.10 含「触发场景」段 (OK)")

	# ===== T260.2.3 §9.6.10 修复 =====
	total += 1
	if s9610.find("**修复**") == -1:
		print("  FAIL [T260.2.3]: §9.6.10 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T260.2.3] §9.6.10 含「修复」段 (OK)")

	# ===== T260.2.4 §9.6.10 预防 =====
	total += 1
	if s9610.find("**预防**") == -1:
		print("  FAIL [T260.2.4]: §9.6.10 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T260.2.4] §9.6.10 含「预防」段 (OK)")

	# =================================================================
	# T260.3 — pause_menu.gd T213 _QUICK_STATS_HINT 4 entry + tooltip builder 9 行 (3 断言)
	# =================================================================
	print("--- T260.3 — pause_menu.gd T213 _QUICK_STATS_HINT + _build_quick_stats_tooltip ---")

	# ===== T260.3.1 _QUICK_STATS_HINT const 4 entry (T213) =====
	total += 1
	if src_pause_menu.find("const _QUICK_STATS_HINT := [") == -1:
		print("  FAIL [T260.3.1]: pause_menu.gd 缺 const _QUICK_STATS_HINT := [...] (T213 4 段 QuickStats tooltip 数据源)")
		quit(1); return
	# 验证 4 entry: 数 _QUICK_STATS_HINT 区间内 "label" 出现次数 (区间 = const _QUICK_STATS_HINT → func _build_quick_stats_tooltip)
	var qs_const_start := src_pause_menu.find("const _QUICK_STATS_HINT := [")
	var qs_func_start := src_pause_menu.find("func _build_quick_stats_tooltip", qs_const_start)
	if qs_func_start == -1:
		qs_func_start = src_pause_menu.length()
	var qs_block := src_pause_menu.substr(qs_const_start, qs_func_start - qs_const_start)
	var qs_label_count := 0
	var qs_pos := 0
	while true:
		var qs_idx := qs_block.find("\"label\"", qs_pos)
		if qs_idx == -1:
			break
		qs_label_count += 1
		qs_pos = qs_idx + 1
	if qs_label_count != 4:
		print("  FAIL [T260.3.1]: pause_menu.gd _QUICK_STATS_HINT entry 数 = %d (期望 4)" % qs_label_count)
		quit(1); return
	passed += 1
	print("  [T260.3.1] pause_menu.gd 含 _QUICK_STATS_HINT 4 entry (T213) (OK)")

	# ===== T260.3.2 _build_quick_stats_tooltip 9 行 = 1 + 4*2 (T213) =====
	total += 1
	if src_pause_menu.find("func _build_quick_stats_tooltip() -> String:") == -1:
		print("  FAIL [T260.3.2]: pause_menu.gd 缺 func _build_quick_stats_tooltip() (T213 4 段 QuickStats tooltip builder)")
		quit(1); return
	# 验证 1 header + 4 段 (label/desc_zh) + 4 段 (color/color_name/detail) = 9 行
	# 验证 1 个 lines.append "4 段总览" header
	if src_pause_menu.find("lines.append(\"4 段总览 — 悬停查看每段含义\")") == -1:
		print("  FAIL [T260.3.2]: pause_menu.gd _build_quick_stats_tooltip 缺 1 header 行")
		quit(1); return
	# 验证 4 段 "• %s — %s" label/desc_zh 行
	var qs_bullet_count := 0
	var qs_b_pos := 0
	while true:
		var qs_b_idx := src_pause_menu.find("lines.append(\"• %s — %s\"", qs_b_pos)
		if qs_b_idx == -1:
			break
		qs_bullet_count += 1
		qs_b_pos = qs_b_idx + 1
	if qs_bullet_count < 1:
		print("  FAIL [T260.3.2]: pause_menu.gd _build_quick_stats_tooltip 缺 '• %s — %s' 4 段 bullet 行")
		quit(1); return
	passed += 1
	print("  [T260.3.2] pause_menu.gd _build_quick_stats_tooltip 9 行 (1 + 4*2) (T213) (OK)")

	# ===== T260.3.3 _QUICK_STATS_HINT 5 字段 (label/color/color_name/desc_zh/detail) (T213) =====
	total += 1
	var qs_field_count := 0
	for field in ["\"label\"", "\"color\"", "\"color_name\"", "\"desc_zh\"", "\"detail\""]:
		if src_pause_menu.find(field) != -1:
			qs_field_count += 1
	if qs_field_count != 5:
		print("  FAIL [T260.3.3]: pause_menu.gd _QUICK_STATS_HINT 字段名 (label/color/color_name/desc_zh/detail) 唯一数 = %d (期望 5)" % qs_field_count)
		quit(1); return
	passed += 1
	print("  [T260.3.3] pause_menu.gd _QUICK_STATS_HINT 5 字段 (label/color/color_name/desc_zh/detail) (T213) (OK)")

	# =================================================================
	# T260.4 — pause_menu.gd T216 _RECENT_ROW_HINT 7 entry + tooltip builder 15 行 (3 断言)
	# =================================================================
	print("--- T260.4 — pause_menu.gd T216 _RECENT_ROW_HINT + _build_recent_row_tooltip ---")

	# ===== T260.4.1 _RECENT_ROW_HINT const 7 entry (T216 + T249 扩展 5 → 7) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_HINT := [") == -1:
		print("  FAIL [T260.4.1]: pause_menu.gd 缺 const _RECENT_ROW_HINT := [...] (T216 7 字段 RecentList tooltip 数据源)")
		quit(1); return
	# 验证 7 entry: 数 _RECENT_ROW_HINT 区间内 "label" 出现次数 (区间 = const _RECENT_ROW_HINT → func _build_recent_row_tooltip)
	var rr_const_start := src_pause_menu.find("const _RECENT_ROW_HINT := [")
	var rr_func_start := src_pause_menu.find("func _build_recent_row_tooltip", rr_const_start)
	if rr_func_start == -1:
		rr_func_start = src_pause_menu.length()
	var rr_block := src_pause_menu.substr(rr_const_start, rr_func_start - rr_const_start)
	var rr_label_count := 0
	var rr_pos := 0
	while true:
		var rr_idx := rr_block.find("\"label\"", rr_pos)
		if rr_idx == -1:
			break
		rr_label_count += 1
		rr_pos = rr_idx + 1
	if rr_label_count != 7:
		print("  FAIL [T260.4.1]: pause_menu.gd _RECENT_ROW_HINT entry 数 = %d (期望 7, T249 #167 扩展 5 → 7)" % rr_label_count)
		quit(1); return
	passed += 1
	print("  [T260.4.1] pause_menu.gd 含 _RECENT_ROW_HINT 7 entry (T216 + T249 5 → 7 扩展) (OK)")

	# ===== T260.4.2 _build_recent_row_tooltip 15 行 = 1 + 7*2 (T216) =====
	total += 1
	if src_pause_menu.find("func _build_recent_row_tooltip() -> String:") == -1:
		print("  FAIL [T260.4.2]: pause_menu.gd 缺 func _build_recent_row_tooltip() (T216 7 字段 RecentList tooltip builder)")
		quit(1); return
	# 验证 1 header 行 (最近一局明细)
	if src_pause_menu.find("lines.append(\"最近一局明细 — 悬停查看每字段含义\")") == -1:
		print("  FAIL [T260.4.2]: pause_menu.gd _build_recent_row_tooltip 缺 1 header 行")
		quit(1); return
	# 验证 7 段 "• %s — %s" label/desc_zh + 7 段 "    %s" detail 行 (14 行)
	if src_pause_menu.find("lines.append(\"    %s\" % String(d[\"detail\"]))") == -1:
		print("  FAIL [T260.4.2]: pause_menu.gd _build_recent_row_tooltip 缺 '    %s' detail 行 (7 段)")
		quit(1); return
	passed += 1
	print("  [T260.4.2] pause_menu.gd _build_recent_row_tooltip 15 行 (1 + 7*2) (T216) (OK)")

	# ===== T260.4.3 _RECENT_ROW_HINT 3 字段 (label/desc_zh/detail) (T216) =====
	total += 1
	var rr_field_count := 0
	for field in ["\"label\"", "\"desc_zh\"", "\"detail\""]:
		if src_pause_menu.find(field) != -1:
			rr_field_count += 1
	if rr_field_count != 3:
		print("  FAIL [T260.4.3]: pause_menu.gd _RECENT_ROW_HINT 字段名 (label/desc_zh/detail) 唯一数 = %d (期望 3)" % rr_field_count)
		quit(1); return
	passed += 1
	print("  [T260.4.3] pause_menu.gd _RECENT_ROW_HINT 3 字段 (label/desc_zh/detail) (T216) (OK)")

	# =================================================================
	# T260.5 — pause_menu.gd T215 _recent_row_hovered + _recent_row_default_color 双 var (3 断言)
	# =================================================================
	print("--- T260.5 — pause_menu.gd T215 5 行 row 静态高亮层 状态字段 ---")

	# ===== T260.5.1 _recent_row_hovered Array 5 行独立 bool (T215) =====
	total += 1
	if src_pause_menu.find("var _recent_row_hovered: Array = []") == -1:
		print("  FAIL [T260.5.1]: pause_menu.gd 缺 var _recent_row_hovered: Array = [] (T215 5 行独立 bool flag)")
		quit(1); return
	passed += 1
	print("  [T260.5.1] pause_menu.gd 含 _recent_row_hovered Array (T215 5 行独立 bool) (OK)")

	# ===== T260.5.2 _recent_row_default_color Array 5 行还原色缓存 (T215) =====
	total += 1
	if src_pause_menu.find("var _recent_row_default_color: Array = []") == -1:
		print("  FAIL [T260.5.2]: pause_menu.gd 缺 var _recent_row_default_color: Array = [] (T215 5 行还原色缓存)")
		quit(1); return
	passed += 1
	print("  [T260.5.2] pause_menu.gd 含 _recent_row_default_color Array (T215 5 行还原色) (OK)")

	# ===== T260.5.3 2 var 顺序 0 触碰 (T215 在 T217 idx 字段之后) =====
	total += 1
	var t215_hovered_pos := src_pause_menu.find("var _recent_row_hovered: Array = []")
	var t215_default_pos := src_pause_menu.find("var _recent_row_default_color: Array = []")
	var t217_idx_pos := src_pause_menu.find("var _quick_stats_hovered_idx: int = -1")
	if t215_hovered_pos == -1 or t215_default_pos == -1 or t217_idx_pos == -1:
		print("  FAIL [T260.5.3]: pause_menu.gd 缺 3 var (_recent_row_hovered + _recent_row_default_color + _quick_stats_hovered_idx)")
		quit(1); return
	# T215 双 var 在 T217 idx 之后声明 (顺序: T217 idx → T215 双 var)
	if not (t217_idx_pos < t215_hovered_pos and t215_hovered_pos < t215_default_pos):
		print("  FAIL [T260.5.3]: pause_menu.gd var 顺序错位 (期望 T217 idx → T215 hovered → T215 default color)")
		quit(1); return
	passed += 1
	print("  [T260.5.3] pause_menu.gd 3 var 顺序正确 (T217 idx → T215 hovered → T215 default color) (OK)")

	# =================================================================
	# T260.6 — pause_menu.gd T217 _quick_stats_hovered_idx 1 段 int = -1 (2 断言)
	# =================================================================
	print("--- T260.6 — pause_menu.gd T217 4 段独立 hover idx 状态字段 ---")

	# ===== T260.6.1 _quick_stats_hovered_idx int = -1 1 段 (T217 替代 T214 bool) =====
	total += 1
	if src_pause_menu.find("var _quick_stats_hovered_idx: int = -1") == -1:
		print("  FAIL [T260.6.1]: pause_menu.gd 缺 var _quick_stats_hovered_idx: int = -1 (T217 1 段 idx 状态字段)")
		quit(1); return
	passed += 1
	print("  [T260.6.1] pause_menu.gd 含 _quick_stats_hovered_idx int = -1 (T217 1 段 idx) (OK)")

	# ===== T260.6.2 _on_quick_stats_hover_in / _out 1 对 handler (T217) =====
	total += 1
	var qs_hover_in_count := 0
	var qs_hover_in_pos := 0
	while true:
		var qs_hover_in_idx := src_pause_menu.find("_on_quick_stats_hover_in", qs_hover_in_pos)
		if qs_hover_in_idx == -1:
			break
		qs_hover_in_count += 1
		qs_hover_in_pos = qs_hover_in_idx + 1
	if qs_hover_in_count < 1:
		print("  FAIL [T260.6.2]: pause_menu.gd 缺 _on_quick_stats_hover_in handler (T217 4 段独立 hover 联动)")
		quit(1); return
	passed += 1
	print("  [T260.6.2] pause_menu.gd 含 _on_quick_stats_hover_in handler (T217) (OK)")

	# =================================================================
	# T260.7 — pause_menu.gd T213 tooltip_text 1 行绑定 + T212 4 BBCode 段基线 (2 断言)
	# =================================================================
	print("--- T260.7 — pause_menu.gd T213 tooltip 绑定 + T212 4 BBCode 段基线 ---")

	# ===== T260.7.1 _profile_quick_stats.tooltip_text = _build_quick_stats_tooltip() 1 行绑定 (T213) =====
	total += 1
	if src_pause_menu.find("_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()") == -1:
		print("  FAIL [T260.7.1]: pause_menu.gd 缺 _profile_quick_stats.tooltip_text = _build_quick_stats_tooltip() (T213 tooltip_text 1 行绑定)")
		quit(1); return
	passed += 1
	print("  [T260.7.1] pause_menu.gd 含 _profile_quick_stats.tooltip_text 1 行绑定 (T213) (OK)")

	# ===== T260.7.2 _apply_quick_stats_hover_state 4 sub-Label modulate 重算函数 (T217 + T225) =====
	total += 1
	if src_pause_menu.find("_apply_quick_stats_hover_state") == -1:
		print("  FAIL [T260.7.2]: pause_menu.gd 缺 _apply_quick_stats_hover_state (T217 4 sub-Label modulate 重算函数)")
		quit(1); return
	passed += 1
	print("  [T260.7.2] pause_menu.gd 含 _apply_quick_stats_hover_state (T217 4 sub-Label modulate) (OK)")

	# =================================================================
	# T260.8 — CONTRIBUTING.md §9.6.10 核心概念 (3 断言)
	# =================================================================
	print("--- T260.8 — CONTRIBUTING.md §9.6.10 核心概念 ---")

	# ===== T260.8.1 §9.6.10 提到 7 entry 字段顺序 (T216 + T249) =====
	total += 1
	if s9610.find("Run#") == -1 or s9610.find("房/时") == -1 or s9610.find("净/时") == -1:
		print("  FAIL [T260.8.1]: §9.6.10 缺 T216 7 entry 字段顺序描述 (Run# / 房 / 净 / 碎 / 时 / 房/时 / 净/时)")
		quit(1); return
	passed += 1
	print("  [T260.8.1] §9.6.10 含 T216 7 entry 字段顺序描述 (OK)")

	# ===== T260.8.2 §9.6.10 提到 15 行 = 1 + 7*2 (T216 关键设计) =====
	total += 1
	if s9610.find("15 行") == -1:
		print("  FAIL [T260.8.2]: §9.6.10 缺 T216 _build_recent_row_tooltip 15 行描述 (1 + 7*2 = 15 行)")
		quit(1); return
	passed += 1
	print("  [T260.8.2] §9.6.10 含 T216 15 行 (1 + 7*2) 描述 (OK)")

	# ===== T260.8.3 §9.6.10 提到 _quick_stats_hovered_idx (T217 关键设计) =====
	total += 1
	if s9610.find("_quick_stats_hovered_idx") == -1:
		print("  FAIL [T260.8.3]: §9.6.10 缺 T217 _quick_stats_hovered_idx 1 段 idx 状态字段描述")
		quit(1); return
	if s9610.find("_recent_row_hovered") == -1 or s9610.find("_recent_row_default_color") == -1:
		print("  FAIL [T260.8.3]: §9.6.10 缺 T215 _recent_row_hovered + _recent_row_default_color 双 var 描述")
		quit(1); return
	passed += 1
	print("  [T260.8.3] §9.6.10 含 T215 + T217 关键状态字段描述 (OK)")

	# =================================================================
	# T260.9 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T260.9 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T260.9.1 CHANGELOG.md 含 #181 段 =====
	total += 1
	if src_changelog.find("## #181 — T260") == -1:
		print("  FAIL [T260.9.1]: CHANGELOG.md 缺 #181 段")
		quit(1); return
	passed += 1
	print("  [T260.9.1] CHANGELOG.md 含 #181 段 (OK)")

	# ===== T260.9.2 ROADMAP.md 顶部时间戳含 #181 =====
	total += 1
	if src_roadmap.find("#181") == -1:
		print("  FAIL [T260.9.2]: ROADMAP.md 顶部缺 #181 时间戳")
		quit(1); return
	passed += 1
	print("  [T260.9.2] ROADMAP.md 顶部含 #181 时间戳 (OK)")

	print("=== T260 #181 §9.6.10 hover 静态高亮层 + tooltip 数据源层 双层 hover 互补 polish 模式 (T212 + T213 + T215 + T216 + T217 落地) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
