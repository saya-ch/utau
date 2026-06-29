extends SceneTree

# I044 — T218 (#139) ProfileQuickStats 4 段 click 联动 smoke test
# 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd 中 T218 实现的
# 4 大模块 (3 常量 + 1 state 字段 / 4 cursor_shape + 4 gui_input.connect /
# 1 click handler + 1 pulse helper / 4 idx → target 映射) + 5 大回归保护
# (T217 hover 联动 0 触碰 / T213 tooltip 0 触碰 / T210 数据源 0 改 /
# T215 5 行 RecentList hover 0 触碰 / T160 banner 起始态 0 触碰) + 1 大
# 废弃验证 (旧版 pulse 全局单 tween 模式 0 残留). 期望: 35 断言全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i044_t218_quick_stats_4seg_click_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#
# === T218.CONST — 3 pulse 节奏参数常量 ===
# - T218.CONST.DURATION_IN: _QUICK_STATS_PULSE_DURATION_IN = 0.15
# - T218.CONST.DURATION_OUT: _QUICK_STATS_PULSE_DURATION_OUT = 0.25
# - T218.CONST.ALPHA_LOW: _QUICK_STATS_PULSE_ALPHA_LOW = 0.4
#
# === T218.STATE — 1 per-target tween 引用表字段 ===
# - T218.STATE.DICT: _quick_stats_pulse_tweens Dictionary 字段
#
# === T218.WIRING — 4 sub-Label cursor_shape + gui_input.connect ===
# - T218.WIRING.CURSOR_ACHV: _quick_stats_achievement.mouse_default_cursor_shape = CURSOR_POINTING_HAND
# - T218.WIRING.CURSOR_BEST: _quick_stats_best_time.mouse_default_cursor_shape = CURSOR_POINTING_HAND
# - T218.WIRING.CURSOR_LONG: _quick_stats_longest_room.mouse_default_cursor_shape = CURSOR_POINTING_HAND
# - T218.WIRING.CURSOR_RUN: _quick_stats_run_number.mouse_default_cursor_shape = CURSOR_POINTING_HAND
# - T218.WIRING.GUI_ACHV: _quick_stats_achievement.gui_input.connect(_on_quick_stats_clicked.bind(0))
# - T218.WIRING.GUI_BEST: _quick_stats_best_time.gui_input.connect(_on_quick_stats_clicked.bind(1))
# - T218.WIRING.GUI_LONG: _quick_stats_longest_room.gui_input.connect(_on_quick_stats_clicked.bind(2))
# - T218.WIRING.GUI_RUN: _quick_stats_run_number.gui_input.connect(_on_quick_stats_clicked.bind(3))
#
# === T218.HANDLERS — 1 click handler + 1 pulse helper 函数 ===
# - T218.HANDLERS.CLICK: _on_quick_stats_clicked(idx, event) 函数声明
# - T218.HANDLERS.MOUSE_FILTER: 仅 InputEventMouseButton
# - T218.HANDLERS.LEFT_BUTTON: mb.pressed && mb.button_index == MOUSE_BUTTON_LEFT
# - T218.HANDLERS.MATCH_4: match idx 4 段 (0/1/2/3)
# - T218.HANDLERS.TARGET_ACHV: idx 0 → _profile_achv_list
# - T218.HANDLERS.TARGET_BEST: idx 1 → _profile_best_streak
# - T218.HANDLERS.TARGET_LONG: idx 2 → _profile_longest_room
# - T218.HANDLERS.TARGET_RUN: idx 3 → _profile_recent_list
# - T218.HANDLERS.PULSE: _pulse_quick_stats_target(target) 函数声明
# - T218.HANDLERS.KILL_OLD: kill 旧 tween (该 target)
# - T218.HANDLERS.RESET_ALPHA: target.modulate.a = 1.0 reset
# - T218.HANDLERS.TWEEN_IN: tween_property target modulate:a 0.4 0.15s
# - T218.HANDLERS.TWEEN_OUT: tween_property target modulate:a 1.0 0.25s
# - T218.HANDLERS.STORE_TWEEN: 存 _quick_stats_pulse_tweens[target] = t
#
# === T218.REGRESS — 回归 (T217/T213/T210/T215/T160 不动) ===
# - T218.REGRESS.1: T217 4 sub-Label mouse_filter STOP 0 删
# - T218.REGRESS.2: T217 4 sub-Label mouse_entered.connect 0 删
# - T218.REGRESS.3: T217 4 sub-Label mouse_exited.connect 0 删
# - T218.REGRESS.4: T217 _quick_stats_hovered_idx / _apply_quick_stats_hover_state 0 删
# - T218.REGRESS.5: T213 _QUICK_STATS_HINT / _build_quick_stats_tooltip 0 删
# - T218.REGRESS.6: T210 数据源 4 段 0 改
# - T218.REGRESS.7: T215 5 行 RecentList hover 字段 0 删
# - T218.REGRESS.8: T160 banner 起始态 0 改
# - T218.REGRESS.NO_OLD_PULSE: 旧版单 tween 全局模式 (无 Dictionary) 0 残留
# - T218.REGRESS.ANCHOR: T218 (#139) 注释锚点 ≥ 5 处

const PAUSE_MENU_PATH := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0

func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passes += 1
		print("[PASS] %s" % msg)
	else:
		_failures.append(msg)
		print("[FAIL] %s" % msg)

func _init() -> void:
	print("=== I044 — T218 (#139) ProfileQuickStats 4 段 click 联动 smoke test ===")
	var f := FileAccess.open(PAUSE_MENU_PATH, FileAccess.READ)
	if f == null:
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()

	_run_t218_const_assertions(content)
	_run_t218_state_assertions(content)
	_run_t218_wiring_assertions(content)
	_run_t218_handlers_assertions(content)
	_run_t218_regress_assertions(content)
	_finish()


# ---------- T218.CONST — 3 pulse 节奏参数常量 ----------
func _run_t218_const_assertions(content: String) -> void:
	print("--- T218.CONST — 3 pulse 节奏参数常量 ---")

	_assert("const _QUICK_STATS_PULSE_DURATION_IN := 0.15" in content,
		"T218.CONST.DURATION_IN.1 — _QUICK_STATS_PULSE_DURATION_IN = 0.15 常量声明 (0.15s 渐入到 _ALPHA_LOW)")
	_assert("const _QUICK_STATS_PULSE_DURATION_OUT := 0.25" in content,
		"T218.CONST.DURATION_OUT.1 — _QUICK_STATS_PULSE_DURATION_OUT = 0.25 常量声明 (0.25s 渐出回 1.0)")
	_assert("const _QUICK_STATS_PULSE_ALPHA_LOW := 0.4" in content,
		"T218.CONST.ALPHA_LOW.1 — _QUICK_STATS_PULSE_ALPHA_LOW = 0.4 常量声明 (modulate.a 渐入终点, 0.0 太暗 0.6 太平)")


# ---------- T218.STATE — 1 per-target tween 引用表字段 ----------
func _run_t218_state_assertions(content: String) -> void:
	print("--- T218.STATE — 1 per-target tween 引用表字段 ---")

	_assert("var _quick_stats_pulse_tweens: Dictionary = {}" in content,
		"T218.STATE.DICT.1 — _quick_stats_pulse_tweens Dictionary = {} 字段声明 (Control → Tween 引用表, 4 段可并发 pulse)")


# ---------- T218.WIRING — 4 sub-Label cursor_shape + gui_input.connect ----------
func _run_t218_wiring_assertions(content: String) -> void:
	print("--- T218.WIRING — 4 sub-Label cursor_shape + gui_input.connect ---")

	# 4 sub-Label cursor_shape = CURSOR_POINTING_HAND
	_assert("_quick_stats_achievement.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND" in content,
		"T218.WIRING.CURSOR_ACHV.1 — Achievement sub-Label cursor = POINTING_HAND (视觉暗示可点, Label 默认箭头)")
	_assert("_quick_stats_best_time.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND" in content,
		"T218.WIRING.CURSOR_BEST.1 — BestTime sub-Label cursor = POINTING_HAND")
	_assert("_quick_stats_longest_room.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND" in content,
		"T218.WIRING.CURSOR_LONG.1 — LongestRoom sub-Label cursor = POINTING_HAND")
	_assert("_quick_stats_run_number.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND" in content,
		"T218.WIRING.CURSOR_RUN.1 — RunNumber sub-Label cursor = POINTING_HAND")

	# 4 sub-Label gui_input.connect (bind idx 0-3)
	_assert("_quick_stats_achievement.gui_input.connect(_on_quick_stats_clicked.bind(0))" in content,
		"T218.WIRING.GUI_ACHV.1 — Achievement gui_input.connect.bind(0) (idx 0 = 第 1 段)")
	_assert("_quick_stats_best_time.gui_input.connect(_on_quick_stats_clicked.bind(1))" in content,
		"T218.WIRING.GUI_BEST.1 — BestTime gui_input.connect.bind(1) (idx 1 = 第 2 段)")
	_assert("_quick_stats_longest_room.gui_input.connect(_on_quick_stats_clicked.bind(2))" in content,
		"T218.WIRING.GUI_LONG.1 — LongestRoom gui_input.connect.bind(2) (idx 2 = 第 3 段)")
	_assert("_quick_stats_run_number.gui_input.connect(_on_quick_stats_clicked.bind(3))" in content,
		"T218.WIRING.GUI_RUN.1 — RunNumber gui_input.connect.bind(3) (idx 3 = 第 4 段)")

	# 4 段 bind idx 0-3 全部出现 (与 T217 4 段 hover bind 共存)
	_assert(content.count(".bind(0)") >= 1 and content.count(".bind(1)") >= 1 and content.count(".bind(2)") >= 1 and content.count(".bind(3)") >= 1,
		"T218.WIRING.BIND_0_1_2_3.1 — 4 段 bind idx 0/1/2/3 全部出现 (4 段 click 独立 + T217 4 段 hover 共存)")


# ---------- T218.HANDLERS — 1 click handler + 1 pulse helper 函数 ----------
func _run_t218_handlers_assertions(content: String) -> void:
	print("--- T218.HANDLERS — 1 click handler + 1 pulse helper 函数 ---")

	# 1 click handler 函数声明
	_assert("func _on_quick_stats_clicked(idx: int, event: InputEvent) -> void:" in content,
		"T218.HANDLERS.CLICK.1 — _on_quick_stats_clicked(idx, event) 函数声明 (4 段 click 共享 1 对 handler)")

	# 越界检查 + MouseButton 过滤 + Left button 过滤
	var click_start := content.find("func _on_quick_stats_clicked(idx: int, event: InputEvent) -> void:")
	if click_start < 0:
		_failures.append("T218.HANDLERS.CLICK.1 — click handler not found")
		_passes -= 1
		print("[FAIL] T218.HANDLERS.CLICK.1 — click handler not found (cascading handler assertions skipped)")
		return
	var click_next := content.find("\nfunc ", click_start + 50)
	var click_body: String
	if click_next > 0:
		click_body = content.substr(click_start, click_next - click_start)
	else:
		click_body = content.substr(click_start, 1500)

	_assert("if idx < 0 or idx > 3:" in click_body,
		"T218.HANDLERS.BOUNDARY.1 — 越界检查 idx < 0 or idx > 3 (defensive, bind 0-3 不会越界)")
	_assert("InputEventMouseButton" in click_body,
		"T218.HANDLERS.MOUSE_FILTER.1 — 仅 InputEventMouseButton 过滤 (忽略鼠标移动/滚轮/键盘)")
	_assert("mb.pressed" in click_body and "MOUSE_BUTTON_LEFT" in click_body,
		"T218.HANDLERS.LEFT_BUTTON.1 — 仅左键按下 (mb.pressed && mb.button_index == MOUSE_BUTTON_LEFT)")

	# match 4 段 + 4 个 target
	_assert("match idx:" in click_body,
		"T218.HANDLERS.MATCH_4.1 — match idx 4 段 switch (GDScript 4.x 推荐枚举式, 编译期校验)")
	_assert("target = _profile_achv_list" in click_body,
		"T218.HANDLERS.TARGET_ACHV.1 — idx 0 → _profile_achv_list (成就列表 ScrollContainer 内 VBox)")
	_assert("target = _profile_best_streak" in click_body,
		"T218.HANDLERS.TARGET_BEST.1 — idx 1 → _profile_best_streak (顶级行第 2 块)")
	_assert("target = _profile_longest_room" in click_body,
		"T218.HANDLERS.TARGET_LONG.1 — idx 2 → _profile_longest_room (顶级行第 3 块)")
	_assert("target = _profile_recent_list" in click_body,
		"T218.HANDLERS.TARGET_RUN.1 — idx 3 → _profile_recent_list (最近 5 局详细行 VBox)")
	_assert("_pulse_quick_stats_target(target)" in click_body,
		"T218.HANDLERS.PULSE_CALL.1 — click handler 末尾调 _pulse_quick_stats_target(target)")

	# 1 pulse helper 函数声明
	_assert("func _pulse_quick_stats_target(target: Control) -> void:" in content,
		"T218.HANDLERS.PULSE.1 — _pulse_quick_stats_target(target) 函数声明 (per-target pulse helper)")

	# pulse helper 体内: kill 旧 tween + reset alpha + 2 段 tween_property + 存 dict
	var pulse_start := content.find("func _pulse_quick_stats_target(target: Control) -> void:")
	if pulse_start < 0:
		_failures.append("T218.HANDLERS.PULSE.1 — pulse helper not found")
		_passes -= 1
		print("[FAIL] T218.HANDLERS.PULSE.1 — pulse helper not found (cascading pulse assertions skipped)")
		return
	var pulse_next := content.find("\nfunc ", pulse_start + 50)
	var pulse_body: String
	if pulse_next > 0:
		pulse_body = content.substr(pulse_start, pulse_next - pulse_start)
	else:
		pulse_body = content.substr(pulse_start, 1500)

	_assert("_quick_stats_pulse_tweens.has(target)" in pulse_body and "old_tween.kill()" in pulse_body,
		"T218.HANDLERS.KILL_OLD.1 — kill 旧 tween (per-target, 4 段 click 可并发)")
	_assert("target.modulate.a = 1.0" in pulse_body,
		"T218.HANDLERS.RESET_ALPHA.1 — target.modulate.a = 1.0 reset 避免中间值残留")
	_assert('"modulate:a", _QUICK_STATS_PULSE_ALPHA_LOW, _QUICK_STATS_PULSE_DURATION_IN' in pulse_body,
		"T218.HANDLERS.TWEEN_IN.1 — tween_property(target, \"modulate:a\", _ALPHA_LOW, _DURATION_IN)")
	_assert('"modulate:a", 1.0, _QUICK_STATS_PULSE_DURATION_OUT' in pulse_body,
		"T218.HANDLERS.TWEEN_OUT.1 — tween_property(target, \"modulate:a\", 1.0, _DURATION_OUT)")
	_assert("_quick_stats_pulse_tweens[target] = t" in pulse_body,
		"T218.HANDLERS.STORE_TWEEN.1 — 存 _quick_stats_pulse_tweens[target] = t 用于下次 click 检测")


# ---------- T218.REGRESS — 回归 (T217/T213/T210/T215/T160 不动) ----------
func _run_t218_regress_assertions(content: String) -> void:
	print("--- T218.REGRESS — 回归 (T217/T213/T210/T215/T160 不动) ---")

	# T217 4 sub-Label mouse_filter + mouse_entered/exited.connect 0 删
	_assert("_quick_stats_achievement.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T218.REGRESS.1 — T217 Achievement mouse_filter STOP 0 删 (T218 在 _ready 同一 if 块新增 cursor + gui_input)")
	_assert("_quick_stats_achievement.mouse_entered.connect(_on_quick_stats_hover_in.bind(0))" in content,
		"T218.REGRESS.2 — T217 Achievement mouse_entered.connect 0 删 (4 段 hover 联动 0 触碰)")
	_assert("_quick_stats_achievement.mouse_exited.connect(_on_quick_stats_hover_out.bind(0))" in content,
		"T218.REGRESS.3 — T217 Achievement mouse_exited.connect 0 删")

	# T217 _quick_stats_hovered_idx + _apply_quick_stats_hover_state 0 删
	_assert("var _quick_stats_hovered_idx: int = -1" in content and "func _apply_quick_stats_hover_state() -> void:" in content,
		"T218.REGRESS.4 — T217 _quick_stats_hovered_idx + _apply_quick_stats_hover_state 0 删 (hover 联动核心 0 触碰)")

	# T213 _QUICK_STATS_HINT + _build_quick_stats_tooltip 0 删
	_assert("const _QUICK_STATS_HINT" in content and "func _build_quick_stats_tooltip() -> String:" in content,
		"T218.REGRESS.5 — T213 _QUICK_STATS_HINT const + _build_quick_stats_tooltip 函数 0 删 (tooltip 数据源 0 触碰)")

	# T210 4 段数据源 0 改
	_assert("unlocked_count" in content and "best_time_str" in content and "longest_room_str" in content and "PlayerStats.get_run_number()" in content,
		"T218.REGRESS.6 — T210 4 段数据源 (unlocked_count / best_time_str / longest_room_str / run_number) 0 改")

	# T215 5 行 RecentList hover 字段 0 删
	_assert("_recent_row_hovered" in content and "_recent_row_default_color" in content,
		"T218.REGRESS.7 — T215 5 行 RecentList hover 字段 (_recent_row_hovered / _recent_row_default_color) 0 删")

	# T160 banner 起始态 0 改
	_assert("_new_achv_banner.modulate.a = 0.0" in content,
		"T218.REGRESS.8 — T160 banner 起始态 (modulate.a = 0.0) 0 改 (T218 pulse 独立用 0 触碰 banner)")

	# 旧版 pulse 模式废弃 (无单 tween 全局变量)
	_assert(not ("var _quick_stats_pulse_tween: Tween" in content),
		"T218.REGRESS.NO_OLD_PULSE.1 — 旧版单 tween 全局模式 (var _quick_stats_pulse_tween: Tween) 0 残留 (T218 改用 Dictionary per-target)")

	# T218 注释锚点 (作为完整 round-trip)
	var t218_anchors: int = content.count("T218 (#139)")
	if t218_anchors == 0:
		# 兼容无空格变体
		t218_anchors = content.count("T218(#139)")
	_assert(t218_anchors >= 5,
		"T218.REGRESS.ANCHOR.1 — T218 (#139) 注释锚点 ≥ 5 处 (constants + state + wiring docblock + handler docblock + helper docblock), 实际 %d 处" % t218_anchors)


func _finish() -> void:
	print("=== I044 — summary ===")
	print("PASS: %d" % _passes)
	print("FAIL: %d" % _failures.size())
	if _failures.is_empty():
		print("I044 — T218 ProfileQuickStats 4 段 click 联动 smoke test: PASSED")
		quit(0)
	else:
		for fail_msg in _failures:
			print("  - %s" % fail_msg)
		print("I044 — T218 ProfileQuickStats 4 段 click 联动 smoke test: FAILED")
		quit(1)
