extends SceneTree
## I019 (#108) — T189 SaveLoadMenu Esc 关闭 confirm modal + F016.B Death SFX audit + BGM transition smoothing 冒烟测试
##
## 覆盖 #108 主任务 T189 + F016.B. 验证:
##
## === T189 — Esc 关闭 confirm modal UX 升级 ===
## - T189.GD.HANDLER: _unhandled_input 函数存在
## - T189.GD.HELPER: _is_confirm_modal_visible helper 函数存在
## - T189.GD.MODAL_GUARD: 弹窗不可见时 _unhandled_input 早退 (不拦截 Esc)
## - T189.GD.UI_CANCEL: 监听 ui_cancel 动作 (Esc/Backspace)
## - T189.GD.CANCEL_CALL: ui_cancel pressed 走 _on_confirm_cancel
## - T189.GD.HANDLED: 走 get_viewport().set_input_as_handled (防止穿透到 _on_back)
## - T189.GD.TAG: _unhandled_input 与 _is_confirm_modal_visible 含 T189 锚点
##
## === F016.B — Death SFX idempotency guard ===
## - F016B.GD.FLAG: _death_sfx_playing 字段
## - F016B.GD.DUR: _DEATH_SFX_DURATION = 0.4 常量
## - F016B.GD.BUF: _DEATH_SFX_GUARD_BUFFER = 0.1 常量
## - F016B.GD.GUARD: play_death_lay_down 入口守卫 (flag==true → return)
## - F016B.GD.TIMER: 0.5s Timer 清 flag
## - F016B.PLAYER.READY: player.gd die() 入口调 play_death_lay_down
##
## === F016.B — BGM transition smoothing (cubic ease_in_out) ===
## - F016B.BGM.TRANS: play_music_track 用 Tween.TRANS_CUBIC
## - F016B.BGM.EASE: play_music_track 用 Tween.EASE_IN_OUT
## - F016B.BGM.STOP_TRANS: stop_music 用 Tween.TRANS_CUBIC
## - F016B.BGM.STOP_EASE: stop_music 用 Tween.EASE_IN_OUT
## - F016B.BGM.PARALLEL: play_music_track 保留 set_parallel(true) (fade_in/out 同步)

const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"
const AUDIO_MANAGER_ENHANCED_GD := "res://src/scripts/audio_manager_enhanced.gd"
const PLAYER_GD := "res://src/scripts/player.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I019 (#108) — T189 + F016.B ===")
	_run_t189_handler_assertions()
	_run_t189_helper_assertions()
	_run_t189_logic_assertions()
	_run_f016b_death_guard_assertions()
	_run_f016b_player_caller_assertions()
	_run_f016b_bgm_smoothing_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I019 (#108) T189 + F016.B ASSERTIONS PASSED ===")
		quit(0)


# ---------- T189.GD — _unhandled_input handler ----------
func _run_t189_handler_assertions() -> void:
	print("--- T189.GD — _unhandled_input handler ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "func _unhandled_input(event: InputEvent) -> void:",
		"T189.GD.HANDLER.1: _unhandled_input 函数存在 (Godot 标准输入钩子)")
	# 锚点注释
	var handler_start := src.find("func _unhandled_input(event: InputEvent) -> void:")
	if handler_start == -1:
		_failures.append("FAIL: T189.GD.HANDLER.2: _unhandled_input 函数未找到 (无法 scope body)")
		return
	var handler_end := src.find("\nfunc ", handler_start + 1)
	if handler_end == -1:
		handler_end = src.length()
	var body := src.substr(handler_start, handler_end - handler_start)
	_assert_contains(body, "T189",
		"T189.GD.HANDLER.3: _unhandled_input 含 T189 锚点注释 (任务可追溯)")
	# Esc/Back 不在弹窗时早退
	_assert_contains(body, "if not _is_confirm_modal_visible():",
		"T189.GD.MODAL_GUARD.1: 弹窗不可见时 _unhandled_input 早退 (不拦截 Esc, 让 _on_back 走完整链)")
	_assert_contains(body, "return",
		"T189.GD.MODAL_GUARD.2: 早退分支 return (与 _on_back 链不冲突)")
	# ui_cancel 动作监听
	_assert_contains(body, "event.is_action_pressed(\"ui_cancel\")",
		"T189.GD.UI_CANCEL.1: 监听 ui_cancel 动作 (Project Settings 默认绑 Backspace/Esc)")
	# 调 _on_confirm_cancel
	_assert_contains(body, "_on_confirm_cancel()",
		"T189.GD.CANCEL_CALL.1: Esc 走 _on_confirm_cancel (与按钮点取消语义对称)")
	# 防止穿透到 _on_back
	_assert_contains(body, "get_viewport().set_input_as_handled()",
		"T189.GD.HANDLED.1: 标记输入已处理 (防止 Esc 穿透到 _on_back 关闭整个菜单)")


# ---------- T189.GD — _is_confirm_modal_visible helper ----------
func _run_t189_helper_assertions() -> void:
	print("--- T189.GD — _is_confirm_modal_visible helper ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "func _is_confirm_modal_visible() -> bool:",
		"T189.GD.HELPER.1: _is_confirm_modal_visible helper 函数存在")
	# T189 锚点注释在 docblock (函数前), 不是函数体内. 取 helper 之前 500 char
	# 范围 (足够覆盖 T189 (#108) docblock) 检查 T189 锚点存在.
	var helper_start := src.find("func _is_confirm_modal_visible() -> bool:")
	if helper_start == -1:
		_failures.append("FAIL: T189.GD.HELPER.2: helper 未找到")
		return
	var docblock_start: int = max(0, helper_start - 500)
	var docblock := src.substr(docblock_start, helper_start - docblock_start)
	_assert_contains(docblock, "T189",
		"T189.GD.HELPER.3: helper 上方 docblock 含 T189 锚点注释 (T189 #108 标识)")
	var helper_end := src.find("\nfunc ", helper_start + 1)
	if helper_end == -1:
		helper_end = src.length()
	var body := src.substr(helper_start, helper_end - helper_start)
	# 3 节点 OR 判定 (layer / backdrop / panel)
	_assert_contains(body, "_confirm_layer and _confirm_layer.visible",
		"T189.GD.HELPER.LAYER.1: _confirm_layer visible 状态检查")
	_assert_contains(body, "_confirm_backdrop and _confirm_backdrop.visible",
		"T189.GD.HELPER.BACKDROP.1: _confirm_backdrop visible 状态检查")
	_assert_contains(body, "_confirm_panel and _confirm_panel.visible",
		"T189.GD.HELPER.PANEL.1: _confirm_panel visible 状态检查")
	_assert_contains(body, "return true",
		"T189.GD.HELPER.OR.1: 3 节点 OR 命中 → return true")
	_assert_contains(body, "return false",
		"T189.GD.HELPER.OR.2: 3 节点都 false → return false")


# ---------- T189.GD — _on_confirm_cancel 路径 ----------
func _run_t189_logic_assertions() -> void:
	print("--- T189.GD — _on_confirm_cancel 复用 T188 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	# T189 不需要新建 _on_confirm_cancel, 直接复用 T188 那个. 校验 T188
	# 实现的 _on_confirm_cancel 在源码中仍然存在, 且只走 _hide_confirm_modal
	# (不 emit, 不删, 语义对称: Esc 与点取消按钮效果一致).
	var cancel_start := src.find("func _on_confirm_cancel() -> void:")
	if cancel_start == -1:
		_failures.append("FAIL: T189.GD.LOGIC.1: _on_confirm_cancel 函数未找到 (T189 依赖 T188)")
		return
	var cancel_end := src.find("\nfunc ", cancel_start + 1)
	if cancel_end == -1:
		cancel_end = src.length()
	var body := src.substr(cancel_start, cancel_end - cancel_start)
	_assert_contains(body, "_hide_confirm_modal()",
		"T189.GD.LOGIC.2: _on_confirm_cancel 调 _hide_confirm_modal (与点取消按钮同链)")
	if body.find("delete_requested.emit") != -1:
		_failures.append("FAIL: T189.GD.LOGIC.3: _on_confirm_cancel 不应 emit delete_requested")
	else:
		_passes += 1
		print("  OK  T189.GD.LOGIC.3: _on_confirm_cancel 路径不 emit (语义对称: Esc=点取消)")


# ---------- F016B.GD — Death SFX idempotency guard ----------
func _run_f016b_death_guard_assertions() -> void:
	print("--- F016B.GD — Death SFX idempotency guard ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	_assert_contains(src, "var _death_sfx_playing: bool = false",
		"F016B.GD.FLAG.1: _death_sfx_playing 字段 (idempotency guard flag)")
	_assert_contains(src, "const _DEATH_SFX_DURATION := 0.4",
		"F016B.GD.DUR.1: _DEATH_SFX_DURATION = 0.4 常量 (与 SFX 时长一致)")
	_assert_contains(src, "const _DEATH_SFX_GUARD_BUFFER := 0.1",
		"F016B.GD.BUF.1: _DEATH_SFX_GUARD_BUFFER = 0.1 常量 (防 SFX 未衰减就被截断)")
	# play_death_lay_down 函数体
	var play_death_start := src.find("func play_death_lay_down() -> void:")
	if play_death_start == -1:
		_failures.append("FAIL: F016B.GD.GUARD.1: play_death_lay_down 函数未找到")
		return
	var play_death_end := src.find("\nfunc ", play_death_start + 1)
	if play_death_end == -1:
		play_death_end = src.length()
	var body := src.substr(play_death_start, play_death_end - play_death_start)
	_assert_contains(body, "if _death_sfx_playing:",
		"F016B.GD.GUARD.2: play_death_lay_down 入口守卫 (flag==true → 跳过 SFX)")
	_assert_contains(body, "return",
		"F016B.GD.GUARD.3: 守卫分支 return (早退防叠加)")
	_assert_contains(body, "_death_sfx_playing = true",
		"F016B.GD.GUARD.4: 实际播放时设 flag=true")
	_assert_contains(body, "_DEATH_SFX_DURATION + _DEATH_SFX_GUARD_BUFFER",
		"F016B.GD.TIMER.1: Timer 时长 = SFX 时长 + 缓冲 (0.5s)")
	_assert_contains(body, "_death_sfx_playing = false",
		"F016B.GD.TIMER.2: Timer.timeout 清 flag (恢复接受下一次调用)")
	_assert_contains(body, "F016.B",
		"F016B.GD.TAG.1: play_death_lay_down 含 F016.B 锚点注释")


# ---------- F016B.PLAYER — player.gd 调用方 ----------
func _run_f016b_player_caller_assertions() -> void:
	print("--- F016B.PLAYER — player.gd 调用方 ---")
	var src := _read_file(PLAYER_GD)
	# die() 函数体调 play_death_lay_down
	var die_start := src.find("func die() -> void:")
	if die_start == -1:
		_failures.append("FAIL: F016B.PLAYER.1: die() 函数未找到")
		return
	var die_end := src.find("\nfunc ", die_start + 1)
	if die_end == -1:
		die_end = src.length()
	var body := src.substr(die_start, die_end - die_start)
	_assert_contains(body, "play_death_lay_down",
		"F016B.PLAYER.2: die() 调 play_death_lay_down (调用方锚点)")
	_assert_contains(body, "if ame and ame.has_method(\"play_death_lay_down\"):",
		"F016B.PLAYER.3: has_method 守卫保持老版本兼容 (autoload 老 build 不崩)")
	_assert_contains(body, "_is_dying = true",
		"F016B.PLAYER.4: die() 入口设 _is_dying=true (调用方重入守卫, 与 callee flag 双重防御)")


# ---------- F016B.BGM — transition smoothing (cubic ease_in_out) ----------
func _run_f016b_bgm_smoothing_assertions() -> void:
	print("--- F016B.BGM — transition smoothing ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	# play_music_track 函数体
	var play_music_start := src.find("func play_music_track(key: String, fade_ms: int = 1500) -> void:")
	if play_music_start == -1:
		_failures.append("FAIL: F016B.BGM.1: play_music_track 函数未找到")
		return
	var play_music_end := src.find("\nfunc ", play_music_start + 1)
	if play_music_end == -1:
		play_music_end = src.length()
	var play_body := src.substr(play_music_start, play_music_end - play_music_start)
	_assert_contains(play_body, "F016.B",
		"F016B.BGM.TAG.1: play_music_track 含 F016.B 锚点注释")
	_assert_contains(play_body, "Tween.TRANS_CUBIC",
		"F016B.BGM.TRANS.1: play_music_track 用 Tween.TRANS_CUBIC (cubic 曲线)")
	_assert_contains(play_body, "Tween.EASE_IN_OUT",
		"F016B.BGM.EASE.1: play_music_track 用 Tween.EASE_IN_OUT (双向缓动)")
	_assert_contains(play_body, "set_parallel(true)",
		"F016B.BGM.PARALLEL.1: play_music_track 保留 set_parallel(true) (fade_in/fade_out 同步, 不被 cubic 错位)")
	# stop_music 函数体
	var stop_music_start := src.find("func stop_music(fade_ms: int = 1000) -> void:")
	if stop_music_start == -1:
		_failures.append("FAIL: F016B.BGM.2: stop_music 函数未找到")
		return
	var stop_music_end := src.find("\nfunc ", stop_music_start + 1)
	if stop_music_end == -1:
		stop_music_end = src.length()
	var stop_body := src.substr(stop_music_start, stop_music_end - stop_music_start)
	_assert_contains(stop_body, "F016.B",
		"F016B.BGM.TAG.2: stop_music 含 F016.B 锚点注释")
	_assert_contains(stop_body, "Tween.TRANS_CUBIC",
		"F016B.BGM.STOP_TRANS.1: stop_music 用 Tween.TRANS_CUBIC (与 play_music_track 同步)")
	_assert_contains(stop_body, "Tween.EASE_IN_OUT",
		"F016B.BGM.STOP_EASE.1: stop_music 用 Tween.EASE_IN_OUT (与 play_music_track 同步)")
	# 注释里说明影响范围
	if play_body.find("9") != -1 and play_body.find("BGM") != -1:
		_passes += 1
		print("  OK  F016B.BGM.COVERAGE.1: play_music_track 注释覆盖 9 BGM 主题 (title_intro/hub_warm/...)")
	else:
		_failures.append("FAIL: F016B.BGM.COVERAGE.1: play_music_track 注释应说明 9 BGM 主题覆盖")


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I019 (#108) T189 + F016.B smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
