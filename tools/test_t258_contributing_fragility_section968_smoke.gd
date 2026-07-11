extends SceneTree
## T258 (#178) — §9.6.8 ProfileQuickStats 4 段独立 hover 联动 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t258_contributing_fragility_section968_smoke.gd
##
## T258: CONTRIBUTING.md §9.6.8 已知 fragility 扩展
##   - §9.6.8 ProfileQuickStats 4 段独立 hover 联动 polish 模式
##     (T217 #138 4 sub-Label 拆分 + 1 段 idx 状态 + 1 对 hover_in/out handler + T225 #147 0.3s tween 渐变落地)
##   - T214 旧版 1 Label + 4 BBCode 段 → T217 4 sub-Label 1:1 拆分
##   - 4 sub-Label modulate 0.3s 渐变 (idx 段 WHITE + 其他 3 段 _QUICK_STATS_DIM 0.5 alpha)
##   - 4 段 click 联动 _quick_stats_pulse_tweens Dictionary 独立 track 各自 target (T218 #139)
## 验证 5 维:
##   - §9.6.8 章节在 CONTRIBUTING.md 已落地
##   - §9.6.8 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - pause_menu.gd _quick_stats_hovered_idx 状态字段 (T217)
##     - pause_menu.gd _QUICK_STATS_HOVER_FADE_DURATION 0.3 (T225)
##     - pause_menu.gd _QUICK_STATS_DIM 0.5 alpha (T217)
##     - pause_menu.gd _quick_stats_hover_tween 全局 tween (T225)
##     - pause_menu.gd _quick_stats_pulse_tweens Dictionary (T218)
##   - CHANGELOG.md 含 #178 段 + ROADMAP.md 顶部时间戳含 #178

func _initialize() -> void:
	print("=== T258 #178 §9.6.8 ProfileQuickStats 4 段独立 hover 联动 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T258.1 — §9.6.8 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T258.1 — §9.6.8 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T258.1.1 §9.6.8 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.8 ProfileQuickStats 4 段独立 hover 联动 polish 模式 (T217 #138 + T225 #147 落地)") == -1:
		print("  FAIL [T258.1.1]: CONTRIBUTING.md 缺 §9.6.8 章节标题")
		quit(1); return
	passed += 1
	print("  [T258.1.1] CONTRIBUTING.md 含 §9.6.8 章节标题 (OK)")

	# ===== T258.1.2 §9.6.8 含 T217 + T225 三个 anchor =====
	total += 1
	var s968_start := src_contributing.find("### 9.6.8")
	var s10_start := src_contributing.find("## 10.")
	if s968_start == -1 or s10_start == -1:
		print("  FAIL [T258.1.2]: §9.6.8 / ## 10 区间划分失败")
		quit(1); return
	var s968 := src_contributing.substr(s968_start, s10_start - s968_start)
	if "T217" not in s968:
		print("  FAIL [T258.1.2]: §9.6.8 区间缺 T217 anchor (T217 #138 4 sub-Label 拆分 + idx 状态字段落地任务)")
		quit(1); return
	if "T225" not in s968:
		print("  FAIL [T258.1.2]: §9.6.8 区间缺 T225 anchor (T225 #147 0.3s tween 渐变落地任务)")
		quit(1); return
	if "T218" not in s968:
		print("  FAIL [T258.1.2]: §9.6.8 区间缺 T218 anchor (T218 #139 click 联动 pulse 模式落地任务)")
		quit(1); return
	passed += 1
	print("  [T258.1.2] CONTRIBUTING.md §9.6.8 区间含 T217 + T225 + T218 三个 anchor (OK)")

	# ===== T258.1.3 §9.6.8 提到 4 sub-Label 拆分 + 1 段 idx 高亮核心概念 =====
	total += 1
	if s968.find("4 sub-Label") == -1:
		print("  FAIL [T258.1.3]: §9.6.8 缺「4 sub-Label」核心概念 (T217 4 sub-Label 1:1 拆分)")
		quit(1); return
	if s968.find("idx") == -1:
		print("  FAIL [T258.1.3]: §9.6.8 缺「idx」核心概念 (T217 _quick_stats_hovered_idx 状态字段)")
		quit(1); return
	passed += 1
	print("  [T258.1.3] CONTRIBUTING.md §9.6.8 含 4 sub-Label 拆分 + idx 状态字段核心概念 (OK)")

	# =================================================================
	# T258.2 — §9.6.8 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T258.2 — §9.6.8 4 段结构 ---")

	# ===== T258.2.1 §9.6.8 症状 =====
	total += 1
	if s968.find("**症状**") == -1:
		print("  FAIL [T258.2.1]: §9.6.8 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T258.2.1] §9.6.8 含「症状」段 (OK)")

	# ===== T258.2.2 §9.6.8 触发场景 =====
	total += 1
	if s968.find("**触发场景**") == -1:
		print("  FAIL [T258.2.2]: §9.6.8 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T258.2.2] §9.6.8 含「触发场景」段 (OK)")

	# ===== T258.2.3 §9.6.8 修复 =====
	total += 1
	if s968.find("**修复**") == -1:
		print("  FAIL [T258.2.3]: §9.6.8 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T258.2.3] §9.6.8 含「修复」段 (OK)")

	# ===== T258.2.4 §9.6.8 预防 =====
	total += 1
	if s968.find("**预防**") == -1:
		print("  FAIL [T258.2.4]: §9.6.8 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T258.2.4] §9.6.8 含「预防」段 (OK)")

	# =================================================================
	# T258.3 — pause_menu.gd T217 + T225 + T218 状态/const/var (5 断言)
	# =================================================================
	print("--- T258.3 — pause_menu.gd T217 + T225 + T218 状态/const/var ---")

	# ===== T258.3.1 _quick_stats_hovered_idx 状态字段 (T217) =====
	total += 1
	if src_pause_menu.find("var _quick_stats_hovered_idx: int = -1") == -1:
		print("  FAIL [T258.3.1]: pause_menu.gd 缺 var _quick_stats_hovered_idx: int = -1 (T217 idx 状态字段, 替代 T214 bool)")
		quit(1); return
	passed += 1
	print("  [T258.3.1] pause_menu.gd 含 _quick_stats_hovered_idx: int = -1 (T217) (OK)")

	# ===== T258.3.2 _QUICK_STATS_HOVER_FADE_DURATION 0.3 (T225) =====
	total += 1
	if src_pause_menu.find("const _QUICK_STATS_HOVER_FADE_DURATION := 0.3") == -1:
		print("  FAIL [T258.3.2]: pause_menu.gd 缺 const _QUICK_STATS_HOVER_FADE_DURATION := 0.3 (T225 4 sub-Label modulate 0.3s 渐变)")
		quit(1); return
	passed += 1
	print("  [T258.3.2] pause_menu.gd 含 _QUICK_STATS_HOVER_FADE_DURATION := 0.3 (T225) (OK)")

	# ===== T258.3.3 _QUICK_STATS_DIM 0.5 alpha (T217) =====
	total += 1
	if src_pause_menu.find("const _QUICK_STATS_DIM := Color(1.0, 1.0, 1.0, 0.5)") == -1:
		print("  FAIL [T258.3.3]: pause_menu.gd 缺 const _QUICK_STATS_DIM := Color(1.0, 1.0, 1.0, 0.5) (T217 3 段 dim 50% alpha)")
		quit(1); return
	passed += 1
	print("  [T258.3.3] pause_menu.gd 含 _QUICK_STATS_DIM := Color(1.0, 1.0, 1.0, 0.5) (T217) (OK)")

	# ===== T258.3.4 _quick_stats_hover_tween 全局 tween (T225) =====
	total += 1
	if src_pause_menu.find("var _quick_stats_hover_tween: Tween = null") == -1:
		print("  FAIL [T258.3.4]: pause_menu.gd 缺 var _quick_stats_hover_tween: Tween = null (T225 4 sub-Label 共享 1 个 tween)")
		quit(1); return
	passed += 1
	print("  [T258.3.4] pause_menu.gd 含 _quick_stats_hover_tween 全局 tween (T225) (OK)")

	# ===== T258.3.5 _quick_stats_pulse_tweens Dictionary (T218) =====
	total += 1
	if src_pause_menu.find("var _quick_stats_pulse_tweens: Dictionary = {}") == -1:
		print("  FAIL [T258.3.5]: pause_menu.gd 缺 var _quick_stats_pulse_tweens: Dictionary = {} (T218 4 段 click 独立 pulse tween 字典)")
		quit(1); return
	passed += 1
	print("  [T258.3.5] pause_menu.gd 含 _quick_stats_pulse_tweens Dictionary (T218) (OK)")

	# =================================================================
	# T258.4 — pause_menu.gd 4 sub-Label @onready var (3 断言)
	# =================================================================
	print("--- T258.4 — pause_menu.gd 4 sub-Label @onready var ---")

	# ===== T258.4.1 _quick_stats_achievement @onready (T217) =====
	total += 1
	if src_pause_menu.find("@onready var _quick_stats_achievement: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsAchievement") == -1:
		print("  FAIL [T258.4.1]: pause_menu.gd 缺 @onready var _quick_stats_achievement: Label (T217 4 sub-Label 第 1 段)")
		quit(1); return
	passed += 1
	print("  [T258.4.1] pause_menu.gd 含 _quick_stats_achievement @onready (T217 段 1) (OK)")

	# ===== T258.4.2 _quick_stats_best_time @onready (T217) =====
	total += 1
	if src_pause_menu.find("@onready var _quick_stats_best_time: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsBestTime") == -1:
		print("  FAIL [T258.4.2]: pause_menu.gd 缺 @onready var _quick_stats_best_time: Label (T217 4 sub-Label 第 2 段)")
		quit(1); return
	passed += 1
	print("  [T258.4.2] pause_menu.gd 含 _quick_stats_best_time @onready (T217 段 2) (OK)")

	# ===== T258.4.3 _quick_stats_longest_room + _quick_stats_run_number @onready (T217) =====
	total += 1
	if src_pause_menu.find("@onready var _quick_stats_longest_room: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsLongestRoom") == -1:
		print("  FAIL [T258.4.3]: pause_menu.gd 缺 @onready var _quick_stats_longest_room: Label (T217 4 sub-Label 第 3 段)")
		quit(1); return
	if src_pause_menu.find("@onready var _quick_stats_run_number: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats/QuickStatsRunNumber") == -1:
		print("  FAIL [T258.4.3]: pause_menu.gd 缺 @onready var _quick_stats_run_number: Label (T217 4 sub-Label 第 4 段)")
		quit(1); return
	passed += 1
	print("  [T258.4.3] pause_menu.gd 含 _quick_stats_longest_room + _quick_stats_run_number @onready (T217 段 3+4) (OK)")

	# =================================================================
	# T258.5 — pause_menu.gd hover_in / hover_out handler + _apply 函数 (3 断言)
	# =================================================================
	print("--- T258.5 — pause_menu.gd hover_in/hover_out handler + _apply 函数 ---")

	# ===== T258.5.1 _on_quick_stats_hover_in 函数 (T217) =====
	total += 1
	var hover_in_idx := src_pause_menu.find("func _on_quick_stats_hover_in(idx: int) -> void:")
	if hover_in_idx == -1:
		print("  FAIL [T258.5.1]: pause_menu.gd 缺 func _on_quick_stats_hover_in(idx: int) (T217 hover_in handler)")
		quit(1); return
	passed += 1
	print("  [T258.5.1] pause_menu.gd 含 _on_quick_stats_hover_in handler (T217) (OK)")

	# ===== T258.5.2 _on_quick_stats_hover_out 函数 (T217) =====
	total += 1
	if src_pause_menu.find("func _on_quick_stats_hover_out(idx: int) -> void:") == -1:
		print("  FAIL [T258.5.2]: pause_menu.gd 缺 func _on_quick_stats_hover_out(idx: int) (T217 hover_out handler)")
		quit(1); return
	passed += 1
	print("  [T258.5.2] pause_menu.gd 含 _on_quick_stats_hover_out handler (T217) (OK)")

	# ===== T258.5.3 _apply_quick_stats_hover_state 函数 (T225) =====
	total += 1
	if src_pause_menu.find("func _apply_quick_stats_hover_state() -> void:") == -1:
		print("  FAIL [T258.5.3]: pause_menu.gd 缺 func _apply_quick_stats_hover_state() (T225 4 sub-Label modulate 重算函数)")
		quit(1); return
	passed += 1
	print("  [T258.5.3] pause_menu.gd 含 _apply_quick_stats_hover_state (T225) (OK)")

	# =================================================================
	# T258.6 — pause_menu.gd 4 sub-Label mouse_entered/exited connect (2 断言)
	# =================================================================
	print("--- T258.6 — pause_menu.gd 4 sub-Label mouse_entered/exited connect ---")

	# ===== T258.6.1 4 sub-Label mouse_entered.bind(idx) connect (4 段) =====
	total += 1
	var connect_entered_count := 0
	for idx in [0, 1, 2, 3]:
		var needle := "_on_quick_stats_hover_in.bind(%d)" % idx
		if src_pause_menu.find(needle) != -1:
			connect_entered_count += 1
	if connect_entered_count != 4:
		print("  FAIL [T258.6.1]: pause_menu.gd 4 sub-Label mouse_entered.bind(idx) connect 数量 = %d (期望 4)" % connect_entered_count)
		quit(1); return
	passed += 1
	print("  [T258.6.1] pause_menu.gd 4 sub-Label mouse_entered.bind(idx) connect 全部 4 段 (OK)")

	# ===== T258.6.2 4 sub-Label mouse_exited.bind(idx) connect (4 段) =====
	total += 1
	var connect_exited_count := 0
	for idx in [0, 1, 2, 3]:
		var needle := "_on_quick_stats_hover_out.bind(%d)" % idx
		if src_pause_menu.find(needle) != -1:
			connect_exited_count += 1
	if connect_exited_count != 4:
		print("  FAIL [T258.6.2]: pause_menu.gd 4 sub-Label mouse_exited.bind(idx) connect 数量 = %d (期望 4)" % connect_exited_count)
		quit(1); return
	passed += 1
	print("  [T258.6.2] pause_menu.gd 4 sub-Label mouse_exited.bind(idx) connect 全部 4 段 (OK)")

	# =================================================================
	# T258.7 — CONTRIBUTING.md §9.6.8 核心概念 (3 断言)
	# =================================================================
	print("--- T258.7 — CONTRIBUTING.md §9.6.8 核心概念 ---")

	# ===== T258.7.1 §9.6.8 提到 0.3s 渐变 (T225) =====
	total += 1
	if s968.find("0.3") == -1 or s968.find("渐变") == -1:
		print("  FAIL [T258.7.1]: §9.6.8 缺 T225 0.3s 渐变描述")
		quit(1); return
	passed += 1
	print("  [T258.7.1] §9.6.8 含 T225 0.3s 渐变描述 (OK)")

	# ===== T258.7.2 §9.6.8 提到 1 段 idx 高亮 + 3 段 dim =====
	total += 1
	if s968.find("3 段 dim") == -1 and s968.find("3段 dim") == -1:
		print("  FAIL [T258.7.2]: §9.6.8 缺「1 段高亮 + 3 段 dim」全联动描述")
		quit(1); return
	passed += 1
	print("  [T258.7.2] §9.6.8 含「1 段高亮 + 3 段 dim」全联动描述 (OK)")

	# ===== T258.7.3 §9.6.8 提到 T218 _quick_stats_pulse_tweens Dictionary =====
	total += 1
	if s968.find("_quick_stats_pulse_tweens") == -1:
		print("  FAIL [T258.7.3]: §9.6.8 缺 T218 _quick_stats_pulse_tweens Dictionary 描述")
		quit(1); return
	passed += 1
	print("  [T258.7.3] §9.6.8 含 T218 _quick_stats_pulse_tweens Dictionary 描述 (OK)")

	# =================================================================
	# T258.8 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T258.8 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T258.8.1 CHANGELOG.md 含 #178 段 =====
	total += 1
	if src_changelog.find("## #178 — T258") == -1 and src_changelog_archive.find("## #178 — T258") == -1:
		print("  FAIL [T258.8.1]: CHANGELOG.md 缺 #178 段")
		quit(1); return
	passed += 1
	print("  [T258.8.1] CHANGELOG.md 含 #178 段 (OK)")

	# ===== T258.8.2 ROADMAP.md 顶部时间戳含 #178 =====
	total += 1
	if src_roadmap.find("#178") == -1:
		print("  FAIL [T258.8.2]: ROADMAP.md 顶部缺 #178 时间戳")
		quit(1); return
	passed += 1
	print("  [T258.8.2] ROADMAP.md 顶部含 #178 时间戳 (OK)")

	print("=== T258 #178 §9.6.8 ProfileQuickStats 4 段独立 hover 联动 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
