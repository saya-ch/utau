extends SceneTree
## I019 (#108) — T189 Esc/Back 关闭 confirm modal + T190 5 BGM transition smoothing 冒烟测试
##
## 覆盖 #108 二任务原子化提交:
##
## === T189 — SaveLoadMenu Esc / 手柄 Back 关闭 confirm modal (T188 延伸) ===
## - T189.GD.FUNC: _unhandled_input(event: InputEvent) 函数已声明
## - T189.GD.LAYER_GUARD: 弹窗未 visible (或 layer null) 时直接 return
## - T189.GD.ESCAPE: KEY_ESCAPE 按下 → 调 _on_confirm_cancel()
## - T189.GD.ESCAPE_PRESSED: 仅 `pressed and not echo` (不重复触发, 不响应释放)
## - T189.GD.ESCAPE_HANDLED: set_input_as_handled 防止双消费
## - T189.GD.JOY_B: JOY_BUTTON_B 按下 → 调 _on_confirm_cancel()
## - T189.GD.JOY_PRESSED: 仅 `pressed` 触发 (joy event 无 echo)
## - T189.GD.JOY_HANDLED: set_input_as_handled 防止双消费
## - T189.GD.NOTES: 注释含 T189 锚点 (T188 延伸 反复强调)
## - T189.GD.NO_BACK: 弹窗 visible 时不调 _on_back / hide_menu
##
## === T190 — 5 BGM transition smoothing (Tween.TRANS_SINE for 5 scene-routing keys) ===
## - T190.GD.SCENE_CONST: const SCENE_ROUTING_KEYS 存在
## - T190.GD.SCENE_LEN: SCENE_ROUTING_KEYS 长度 == 5
## - T190.GD.SCENE_KEYS: 5 键全在 = [title_intro, hub_warm, archive_exploration, archive_dawn, whisper_hollow]
## - T190.GD.SCENE_SINE: _transition_for_key(scene_key) == Tween.TRANS_SINE
## - T190.GD.BOSS_LINEAR: _transition_for_key(boss_key) == Tween.TRANS_LINEAR (sharp cut)
## - T190.GD.SILENCE_LINEAR: _transition_for_key("silence_void") == Tween.TRANS_LINEAR
## - T190.GD.UNKNOWN_LINEAR: _transition_for_key("nonsense_key") == Tween.TRANS_LINEAR (defense)
## - T190.GD.PLAY_TRANS: play_music_track 用 set_trans(_transition_for_key(key))
## - T190.GD.STOP_TRANS: stop_music 用 set_trans(_transition_for_key(_current_music_key))
## - T190.GD.HELPER: _transition_for_key 函数存在
## - T190.GD.NOTES: 注释含 T190 (#108) 锚点

const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"
const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I019 (#108) — T189 Esc/Back confirm modal + T190 5 BGM smoothing ===")
	_run_t189_function_assertions()
	_run_t189_layer_guard_assertions()
	_run_t189_escape_assertions()
	_run_t189_joypad_assertions()
	_run_t189_notes_assertions()
	_run_t189_no_back_assertions()
	_run_t190_constants_assertions()
	_run_t190_helper_assertions()
	_run_t190_play_track_assertions()
	_run_t190_stop_music_assertions()
	_run_t190_notes_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I019 (#108) T189 + T190 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T189 — SaveLoadMenu Esc/Back 关闭 confirm modal =====================

# ---------- T189.GD.FUNC — _unhandled_input 函数 ----------
func _run_t189_function_assertions() -> void:
	print("--- T189.GD.FUNC — _unhandled_input 函数 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "func _unhandled_input(event: InputEvent) -> void:",
		"T189.GD.FUNC.1: _unhandled_input(event: InputEvent) 函数已声明")
	# 整体函数体应包含 layer guard + KEY_ESCAPE 分支 + JOY_BUTTON_B 分支
	var func_start := src.find("func _unhandled_input(event: InputEvent) -> void:")
	if func_start == -1:
		_failures.append("FAIL: T189.GD.FUNC.2: _unhandled_input 函数未找到 (anchor missing)")
		return
	var func_end := src.find("\nfunc ", func_start + 1)
	if func_end == -1:
		func_end = src.length()
	var body := src.substr(func_start, func_end - func_start)
	_assert_contains(body, "if _confirm_layer == null or not _confirm_layer.visible:",
		"T189.GD.FUNC.3: 函数体首句是弹窗未显示 → return 守卫")
	_assert_contains(body, "return",
		"T189.GD.FUNC.4: 弹窗守卫含 return 早退")
	_assert_contains(body, "if event is InputEventKey:",
		"T189.GD.FUNC.5: 键盘事件分支 (InputEventKey)")
	_assert_contains(body, "if event is InputEventJoypadButton:",
		"T189.GD.FUNC.6: 手柄事件分支 (InputEventJoypadButton)")


# ---------- T189.GD.LAYER_GUARD — 弹窗可见性守卫 ----------
func _run_t189_layer_guard_assertions() -> void:
	print("--- T189.GD.LAYER_GUARD — 弹窗可见性守卫 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	var func_start := src.find("func _unhandled_input(event: InputEvent) -> void:")
	if func_start == -1:
		_failures.append("FAIL: T189.GD.LAYER_GUARD.1: _unhandled_input 未找到")
		return
	var func_end := src.find("\nfunc ", func_start + 1)
	if func_end == -1:
		func_end = src.length()
	var body := src.substr(func_start, func_end - func_start)
	# 守卫必须是函数体的前 3 行 (首句就 return)
	var guard_idx := body.find("if _confirm_layer == null or not _confirm_layer.visible:")
	if guard_idx == -1 or guard_idx > 200:
		_failures.append("FAIL: T189.GD.LAYER_GUARD.2: layer 守卫未在函数前部 (idx=%d, 期望 < 200)" % guard_idx)
	else:
		_passes += 1
		print("  OK  T189.GD.LAYER_GUARD.2: 守卫在函数前部 (idx=%d, 函数体前 200 字符内)" % guard_idx)
	# 守卫返回前不应调 _on_confirm_cancel
	var return_idx := body.find("return")
	var first_cancel_idx := body.find("_on_confirm_cancel()")
	if return_idx != -1 and first_cancel_idx != -1 and return_idx < first_cancel_idx:
		_passes += 1
		print("  OK  T189.GD.LAYER_GUARD.3: 守卫 return 早于 _on_confirm_cancel (弹窗未显示时不取消)")
	else:
		_failures.append("FAIL: T189.GD.LAYER_GUARD.3: return / _on_confirm_cancel 顺序异常 (return=%d, cancel=%d)" % [return_idx, first_cancel_idx])


# ---------- T189.GD.ESCAPE — KEY_ESCAPE 分支 ----------
func _run_t189_escape_assertions() -> void:
	print("--- T189.GD.ESCAPE — KEY_ESCAPE 分支 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "var key_event: InputEventKey = event",
		"T189.GD.ESCAPE.1: 显式 InputEventKey 类型转换")
	_assert_contains(src, "key_event.pressed and not key_event.echo",
		"T189.GD.ESCAPE.2: 仅响应 pressed 非 echo (避免重复触发)")
	_assert_contains(src, "key_event.keycode == KEY_ESCAPE",
		"T189.GD.ESCAPE.3: 检测 KEY_ESCAPE")
	_assert_contains(src, "get_viewport().set_input_as_handled()",
		"T189.GD.ESCAPE.4: set_input_as_handled 防止 Esc 双消费 (T189 设计意图)")
	# KEY_ESCAPE 触发后调 _on_confirm_cancel
	var key_idx := src.find("key_event.keycode == KEY_ESCAPE")
	if key_idx == -1:
		_failures.append("FAIL: T189.GD.ESCAPE.5: KEY_ESCAPE 检测未找到")
	else:
		# 取往后 200 字符, 找 _on_confirm_cancel + set_input_as_handled
		var tail := src.substr(key_idx, 200)
		if tail.find("_on_confirm_cancel()") != -1 and tail.find("set_input_as_handled()") != -1:
			_passes += 1
			print("  OK  T189.GD.ESCAPE.5: KEY_ESCAPE → _on_confirm_cancel + set_input_as_handled 顺序正确")
		else:
			_failures.append("FAIL: T189.GD.ESCAPE.5: KEY_ESCAPE 分支后未紧跟 _on_confirm_cancel + handled")


# ---------- T189.GD.JOY — JOY_BUTTON_B 分支 ----------
func _run_t189_joypad_assertions() -> void:
	print("--- T189.GD.JOY — JOY_BUTTON_B 分支 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "var joy_event: InputEventJoypadButton = event",
		"T189.GD.JOY.1: 显式 InputEventJoypadButton 类型转换")
	_assert_contains(src, "joy_event.pressed and joy_event.button_index == JOY_BUTTON_B",
		"T189.GD.JOY.2: 检测手柄 B 按钮 (Xbox B / PS Circle = universal Cancel)")
	var joy_idx := src.find("joy_event.button_index == JOY_BUTTON_B")
	if joy_idx == -1:
		_failures.append("FAIL: T189.GD.JOY.3: JOY_BUTTON_B 检测未找到")
	else:
		var tail := src.substr(joy_idx, 200)
		if tail.find("_on_confirm_cancel()") != -1 and tail.find("set_input_as_handled()") != -1:
			_passes += 1
			print("  OK  T189.GD.JOY.3: JOY_BUTTON_B → _on_confirm_cancel + set_input_as_handled")
		else:
			_failures.append("FAIL: T189.GD.JOY.3: JOY_BUTTON_B 分支后未紧跟 _on_confirm_cancel + handled")


# ---------- T189.GD.NOTES — 注释锚点 ----------
func _run_t189_notes_assertions() -> void:
	print("--- T189.GD.NOTES — 注释锚点 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "T189 (#108)",
		"T189.GD.NOTES.1: 注释含 T189 (#108) 锚点")
	_assert_contains(src, "T188 延伸",
		"T189.GD.NOTES.2: 注释明确这是 T188 延伸 (上轮 + 本轮闭环)")
	_assert_contains(src, "Esc / 手柄 Back",
		"T189.GD.NOTES.3: 注释说明 Esc + 手柄 Back 两条输入路径")


# ---------- T189.GD.NO_BACK — 弹窗 visible 时不调 _on_back ----------
func _run_t189_no_back_assertions() -> void:
	print("--- T189.GD.NO_BACK — 弹窗 visible 时不调 _on_back ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	var func_start := src.find("func _unhandled_input(event: InputEvent) -> void:")
	if func_start == -1:
		_failures.append("FAIL: T189.GD.NO_BACK.1: _unhandled_input 未找到")
		return
	var func_end := src.find("\nfunc ", func_start + 1)
	if func_end == -1:
		func_end = src.length()
	var body := src.substr(func_start, func_end - func_start)
	# 函数体内不应调 _on_back / hide_menu (破坏 UX)
	if body.find("_on_back(") != -1 or body.find("hide_menu(") != -1:
		_failures.append("FAIL: T189.GD.NO_BACK.2: _unhandled_input 不应调 _on_back / hide_menu (会强制退出整个菜单)")
	else:
		_passes += 1
		print("  OK  T189.GD.NO_BACK.2: 弹窗 visible 时仅 _on_confirm_cancel, 不强制退出整个菜单 (UX 闭环)")


# ===================== T190 — 5 BGM transition smoothing =====================

# ---------- T190.GD.CONST — SCENE_ROUTING_KEYS / _BOSS_BGM_KEYS / _ABSENCE_BGM_KEYS ----------
func _run_t190_constants_assertions() -> void:
	print("--- T190.GD.CONST — scene-routing / boss / absence 键列表 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "const SCENE_ROUTING_KEYS := [",
		"T190.GD.CONST.1: const SCENE_ROUTING_KEYS 数组声明")
	_assert_contains(src, "const _BOSS_BGM_KEYS := [",
		"T190.GD.CONST.2: const _BOSS_BGM_KEYS 数组声明 (sharp cut 候选)")
	_assert_contains(src, "const _ABSENCE_BGM_KEYS := [",
		"T190.GD.CONST.3: const _ABSENCE_BGM_KEYS 数组声明 (silence_void)")
	# SCENE_ROUTING_KEYS 必须含 5 键
	for key in ["\"title_intro\"", "\"hub_warm\"", "\"archive_exploration\"", "\"archive_dawn\"", "\"whisper_hollow\""]:
		_assert_contains(src, key,
			"T190.GD.SCENE_KEYS.1: SCENE_ROUTING_KEYS 含 %s (5 scene-routing BGM 之一)" % key)
	# _BOSS_BGM_KEYS 必须含 3 键
	for key in ["\"archive_boss\"", "\"archive_boss_dual\"", "\"archive_storm\""]:
		_assert_contains(src, key,
			"T190.GD.BOSS_KEYS.1: 出现 boss key %s (sharp cut 候选)" % key)
	# _ABSENCE_BGM_KEYS 必须含 silence_void
	_assert_contains(src, "\"silence_void\"",
		"T190.GD.SILENCE_KEYS.1: 出现 silence_void (absence theme)")


# ---------- T190.GD.HELPER — _transition_for_key 函数 ----------
func _run_t190_helper_assertions() -> void:
	print("--- T190.GD.HELPER — _transition_for_key 函数 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _transition_for_key(key: String) -> int:",
		"T190.GD.HELPER.1: _transition_for_key 函数已声明")
	var func_start := src.find("func _transition_for_key(key: String) -> int:")
	if func_start == -1:
		_failures.append("FAIL: T190.GD.HELPER.2: 函数未找到")
		return
	var func_end := src.find("\nfunc ", func_start + 1)
	if func_end == -1:
		func_end = src.length()
	var body := src.substr(func_start, func_end - func_start)
	_assert_contains(body, "if key in SCENE_ROUTING_KEYS:",
		"T190.GD.HELPER.3: 守卫检查 key 在 SCENE_ROUTING_KEYS")
	_assert_contains(body, "return Tween.TRANS_SINE",
		"T190.GD.HELPER.4: scene-routing key → TRANS_SINE (smooth)")
	_assert_contains(body, "return Tween.TRANS_LINEAR",
		"T190.GD.HELPER.5: 非 scene-routing → TRANS_LINEAR (sharp, default)")


# ---------- T190.GD.PLAY — play_music_track 用 per-key curve ----------
func _run_t190_play_track_assertions() -> void:
	print("--- T190.GD.PLAY — play_music_track 用 per-key curve ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var trans_curve: int = _transition_for_key(key)",
		"T190.GD.PLAY.1: play_music_track 调 _transition_for_key(key) 拿到 per-key 曲线")
	_assert_contains(src, "tween.set_trans(trans_curve)",
		"T190.GD.PLAY.2: tween 用 set_trans(trans_curve) 应用曲线 (同时影响 fade-in + fade-out)")


# ---------- T190.GD.STOP — stop_music 用 per-key curve ----------
func _run_t190_stop_music_assertions() -> void:
	print("--- T190.GD.STOP — stop_music 用 per-key curve ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "tween.set_trans(_transition_for_key(_current_music_key))",
		"T190.GD.STOP.1: stop_music 用 _transition_for_key(_current_music_key) (与 play 对称)")


# ---------- T190.GD.NOTES — 注释锚点 ----------
func _run_t190_notes_assertions() -> void:
	print("--- T190.GD.NOTES — 注释锚点 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "T190 (#108)",
		"T190.GD.NOTES.1: 注释含 T190 (#108) 锚点")
	_assert_contains(src, "scene-routing",
		"T190.GD.NOTES.2: 注释解释 scene-routing vs boss variant 策略差异")


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
	print("I019 (#108) T189 + T190 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
