extends SceneTree
## I048 (#144) — T222 AchievementGrid locked slot 颜色 fade (解锁进度联动 alpha) 冒烟测试
##
## 覆盖 #144 任务 T222 原子化提交:
##
## === T222 — AchievementGrid 14 成就 locked slot 颜色 fade (解锁进度联动) ===
## - T222.CONST.START: _ACHV_LOCKED_ALPHA_START = 0.5
## - T222.CONST.END: _ACHV_LOCKED_ALPHA_END = 0.2
## - T222.CONST.RGB: _ACHV_LOCKED_COLOR_RGB = Color(0.25, 0.25, 0.3)
## - T222.REFRESH.PROGRESS: _refresh_achievement_grid 计算 progress = unlocked/total
## - T222.REFRESH.LERP: progress 0..1 → locked_alpha = lerp(START, END, progress)
## - T222.REFRESH.APPLY: locked slots modulate = locked_color (RGB + computed alpha)
## - T222.REFRESH.UNLOCKED: unlocked slots modulate = Color.WHITE (0 改)
## - T222.REGRESS.T111: T111 hover handler 仍生效 (1 字段 + 2 handler)
## - T222.REGRESS.T109: T109 时间排序 0 改 (1 function body)
## - T222.REGRESS.T213: T213 4 段 tooltip 0 改 (1 const 引用)
## - T222.REGRESS.T218: T218 click 联动 0 改 (1 per-target tween dict)
## - T222.DOC.ANCHOR: T222 (#144) 注释锚点 ≥ 2 处
## - T222.SMOKE.NO_REGRESS: 旧 0.5 硬编码 (Alpha 写死) 0 残留

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I048 (#144) — T222 AchievementGrid locked slot 颜色 fade ===")
	_run_t222_const_assertions()
	_run_t222_refresh_assertions()
	_run_t222_regress_assertions()
	_run_t222_doc_anchor_assertions()
	_run_t222_no_regress_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I048 (#144) T222 AchievementGrid 颜色 fade ASSERTIONS PASSED ===")
		quit(0)


# ===================== T222 — AchievementGrid 颜色 fade =====================

# ---------- T222.CONST.* — 3 const 端点定义 ----------
func _run_t222_const_assertions() -> void:
	print("--- T222.CONST.* — 3 const 端点定义 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _ACHV_LOCKED_ALPHA_START := 0.5",
		"T222.CONST.START.1: _ACHV_LOCKED_ALPHA_START = 0.5 (0 解锁满 muted)")
	_assert_contains(src, "const _ACHV_LOCKED_ALPHA_END := 0.2",
		"T222.CONST.END.1: _ACHV_LOCKED_ALPHA_END = 0.2 (14 解锁 fade 退场)")
	_assert_contains(src, "const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)",
		"T222.CONST.RGB.1: _ACHV_LOCKED_COLOR_RGB = Color(0.25, 0.25, 0.3) (暗灰调 RGB, 0 改 T111 既有)")

	# 端点值合理性: START > END (解锁越多越淡)
	var src_lines := src.split("\n")
	var start_val := 0.0
	var end_val := 0.0
	for line in src_lines:
		if line.find("_ACHV_LOCKED_ALPHA_START") != -1 and line.find("0.5") != -1:
			start_val = 0.5
		if line.find("_ACHV_LOCKED_ALPHA_END") != -1 and line.find("0.2") != -1:
			end_val = 0.2
	if start_val > end_val:
		_passes += 1
		print("  OK  T222.CONST.RANGE.1: _ALPHA_START (0.5) > _ALPHA_END (0.2) — 解锁越多 alpha 越低 (fade 退场)")
	else:
		_failures.append("FAIL: T222.CONST.RANGE.1: _ALPHA_START (%f) 应 > _ALPHA_END (%f)" % [start_val, end_val])


# ---------- T222.REFRESH.* — _refresh_achievement_grid 改造 ----------
func _run_t222_refresh_assertions() -> void:
	print("--- T222.REFRESH.* — _refresh_achievement_grid 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _refresh_achievement_grid() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T222.REFRESH.1: _refresh_achievement_grid 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 1500)
	# 进度计算: progress = unlocked_count / total_count
	_assert_contains(fn_body, "PlayerStats.get_unlocked_count()",
		"T222.REFRESH.PROGRESS.1: _refresh_achievement_grid 调 PlayerStats.get_unlocked_count()")
	_assert_contains(fn_body, "PlayerStats.get_total_count()",
		"T222.REFRESH.PROGRESS.2: _refresh_achievement_grid 调 PlayerStats.get_total_count()")
	_assert_contains(fn_body, "float(unlocked_count) / float(total_count)",
		"T222.REFRESH.PROGRESS.3: progress = unlocked/total 浮点除法 (避免整数除法)")
	# lerp: locked_alpha = lerp(START, END, progress)
	_assert_contains(fn_body, "lerp(_ACHV_LOCKED_ALPHA_START, _ACHV_LOCKED_ALPHA_END, progress)",
		"T222.REFRESH.LERP.1: locked_alpha = lerp(START, END, progress) (GDScript lerp 标准 API)")
	# 应用: locked_color 用 const RGB + computed alpha 组合
	_assert_contains(fn_body, "_ACHV_LOCKED_COLOR_RGB.r",
		"T222.REFRESH.APPLY.1: locked_color 用 const RGB.r 通道")
	_assert_contains(fn_body, "locked_alpha",
		"T222.REFRESH.APPLY.2: locked_color alpha 用 computed locked_alpha (非硬编码 0.5)")
	# unlocked slots 0 改
	_assert_contains(fn_body, "child.modulate = Color.WHITE",
		"T222.REFRESH.UNLOCKED.1: unlocked slots modulate = Color.WHITE (0 改)")
	_assert_contains(fn_body, "child.self_modulate = Color.WHITE",
		"T222.REFRESH.UNLOCKED.2: unlocked slots self_modulate = Color.WHITE (0 改)")
	# locked slots 用 locked_color
	_assert_contains(fn_body, "child.modulate = locked_color",
		"T222.REFRESH.APPLY.3: locked slots modulate = locked_color (RGB + computed alpha)")
	_assert_contains(fn_body, "child.self_modulate = locked_color",
		"T222.REFRESH.APPLY.4: locked slots self_modulate = locked_color (与 modulate 同步)")


# ---------- T222.REGRESS.* — T109 / T111 / T213 / T218 0 改 ----------
func _run_t222_regress_assertions() -> void:
	print("--- T222.REGRESS.* — T109 / T111 / T213 / T218 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T111 hover handler 0 改
	_assert_contains(src, "func _on_slot_hover_in(slot: TextureRect) -> void:",
		"T222.REGRESS.T111.1: _on_slot_hover_in handler 0 删 (T111 #58 锚点保留)")
	_assert_contains(src, "func _on_slot_hover_out(slot: TextureRect) -> void:",
		"T222.REGRESS.T111.2: _on_slot_hover_out handler 0 删 (T111 #58 锚点保留)")
	_assert_contains(src, "mouse_entered.connect(_on_slot_hover_in.bind(slot))",
		"T222.REGRESS.T111.3: T111 14 成就 mouse_entered.connect 0 改")
	_assert_contains(src, "mouse_exited.connect(_on_slot_hover_out.bind(slot))",
		"T222.REGRESS.T111.4: T111 14 成就 mouse_exited.connect 0 改")
	# T109 时间排序 0 改
	_assert_contains(src, "func _build_achievement_grid() -> void:",
		"T222.REGRESS.T109.1: _build_achievement_grid 函数 0 删 (T109 #70 锚点保留)")
	_assert_contains(src, "PlayerStats.get_unlocked_achievements_sorted_by_time()",
		"T222.REGRESS.T109.2: T109 get_unlocked_achievements_sorted_by_time() 0 改")
	# T213 4 段 tooltip 0 改
	_assert_contains(src, "const _QUICK_STATS_HINT",
		"T222.REGRESS.T213.1: T213 _QUICK_STATS_HINT const 0 删 (T213 #133 锚点保留)")
	_assert_contains(src, "_build_quick_stats_tooltip()",
		"T222.REGRESS.T213.2: T213 _build_quick_stats_tooltip() 函数 0 删")
	# T218 click 联动 0 改
	_assert_contains(src, "_quick_stats_pulse_tweens",
		"T222.REGRESS.T218.1: T218 per-target tween Dictionary 0 删 (T218 #139 锚点保留)")
	_assert_contains(src, "func _on_quick_stats_clicked(idx: int, event: InputEvent) -> void:",
		"T222.REGRESS.T218.2: T218 click handler 函数 0 删")


# ---------- T222.DOC.ANCHOR.* — T222 注释锚点 ≥ 2 处 ----------
func _run_t222_doc_anchor_assertions() -> void:
	print("--- T222.DOC.ANCHOR.* — T222 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T222 (#144)") != -1 or line.find("T222 (#144) ") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T222.DOC.ANCHOR.1: T222 (#144) 注释锚点 %d 处 (≥ 2)" % anchor_count)
	else:
		_failures.append("FAIL: T222.DOC.ANCHOR.1: T222 (#144) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T222.NO_REGRESS — 旧 0.5 硬编码 0 残留 ----------
func _run_t222_no_regress_assertions() -> void:
	print("--- T222.NO_REGRESS — 旧 0.5 硬编码 0 残留 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 在 _refresh_achievement_grid 内的旧 `Color(0.25, 0.25, 0.3, 0.5)` 硬编码应该 0 残留
	var fn_idx := src.find("func _refresh_achievement_grid() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T222.NO_REGRESS.1: _refresh_achievement_grid 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 1500)
	# 旧版 else 段内嵌 Color(0.25, 0.25, 0.3, 0.5) 应该被 locked_color 替代
	if fn_body.find("child.modulate = Color(0.25, 0.25, 0.3, 0.5)") != -1:
		_failures.append("FAIL: T222.NO_REGRESS.1: 旧 0.5 硬编码 modulate = Color(0.25, 0.25, 0.3, 0.5) 残留")
	else:
		_passes += 1
		print("  OK  T222.NO_REGRESS.1: 旧 0.5 硬编码 modulate 0 残留 (T222 全替为 locked_color)")
	if fn_body.find("child.self_modulate = Color(0.25, 0.25, 0.3, 0.5)") != -1:
		_failures.append("FAIL: T222.NO_REGRESS.2: 旧 0.5 硬编码 self_modulate = Color(0.25, 0.25, 0.3, 0.5) 残留")
	else:
		_passes += 1
		print("  OK  T222.NO_REGRESS.2: 旧 0.5 硬编码 self_modulate 0 残留 (T222 全替为 locked_color)")
	# locked_color 变量名应该唯一出现在 _refresh_achievement_grid
	if fn_body.find("var locked_color: Color =") != -1:
		_passes += 1
		print("  OK  T222.NO_REGRESS.3: locked_color 局部变量声明存在 (RGB + computed alpha 组合)")
	else:
		_failures.append("FAIL: T222.NO_REGRESS.3: locked_color 局部变量声明缺失")


# ===================== 通用 helper =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % label)
	else:
		_failures.append("FAIL: %s (missing: %s)" % [label, needle])


func _print_summary() -> void:
	print("")
	print("--- Summary ---")
	print("  PASS: %d" % _passes)
	print("  FAIL: %d" % _failures.size())
	for fail_msg in _failures:
		print("  %s" % fail_msg)
