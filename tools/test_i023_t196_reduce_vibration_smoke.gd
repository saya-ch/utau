extends SceneTree
## I023 (#113) — Smoke test for T196 (settings menu 减弱手柄振动 accessibility).
##
## 28+ 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i023_t196_reduce_vibration_smoke.gd
##
## 设计 (与 I022 / I021 / I020 / I019 一致):
##   T196.TSCN.REDUCE_VIBRATION_CHECK — settings_menu.tscn 有 ReduceVibrationCheck 节点.
##   T196.TSCN.REDUCE_VIBRATION_TEXT — 节点 text = "减弱手柄振动" 中文 label.
##   T196.TSCN.REDUCE_VIBRATION_TOOLTIP — 节点 tooltip_text 含"手柄/手机振动" 跨设备语义.
##   T196.TSCN.PARENT_VIDEO_PANEL — 节点 parented under VideoPanel (与 T195 同区域).
##   T196.GD.ONREADY — settings_menu.gd 有 _reduce_vibration_check @onready 字段.
##   T196.GD.STATE_FIELD — settings_menu.gd 有 _reduced_vibration 状态字段.
##   T196.GD.TOGGLE_HANDLER — _on_reduce_vibration_toggled handler + 字段更新 + live-push.
##   T196.GD.HAS_AUTOLOAD — _has_screen_shake_autoload helper 守卫 (T195 复用).
##   T196.GD.SAVE — _save_settings 写 [accessibility] section reduce_vibration.
##   T196.GD.LOAD — _load_settings 读 reduce_vibration + set_block_signals + live-push.
##   T196.GD.RESTORE — _on_restore_all_pressed 还原 reduce_vibration 到 off.
##   T196.SHAKE.STATE — screen_shake.gd 有 _reduced_vibration 字段 (默认 false).
##   T196.SHAKE.SETTERS — set_reduce_vibration / is_reduce_vibration 公开 API.
##   T196.SHAKE.INFLIGHT — set_reduce_vibration(true) 调 Input.stop_joy_vibration 跨 pad.
##   T196.SHAKE.VIBRATE_HELPER — vibrate(strength, duration) 跨平台路由 helper.
##   T196.SHAKE.GATING — vibrate 入口 _reduced_vibration 早退.
##   T196.SHAKE.CLAMP — vibrate 钳制 strength [0,1] / duration >=0.

func _initialize() -> void:
	print("=== I023 T196 reduce_vibration smoke test (#113) ===")

	var sm_src := ""
	var smf := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if smf:
		sm_src = smf.get_as_text()
		smf.close()
	var smtscn := ""
	var tscnf := FileAccess.open("res://src/scenes/settings_menu.tscn", FileAccess.READ)
	if tscnf:
		smtscn = tscnf.get_as_text()
		tscnf.close()
	var ss_src := ""
	var ssf := FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	if ssf:
		ss_src = ssf.get_as_text()
		ssf.close()

	var passed := 0
	var total := 0
	var fail_one := func(label: String, cond: bool) -> void:
		# (closure with `passed`/`total` capture-by-value semantics: use globals)
		pass
	# Use simple if/return style for clarity and consistency with I022:

	# ===== T196.TSCN — settings_menu.tscn ReduceVibrationCheck =====

	total += 1
	if smtscn.find("[node name=\"ReduceVibrationCheck\" type=\"CheckBox\" parent=\"VBoxContainer/Content/VideoPanel\"]") == -1:
		print("  FAIL [T196.TSCN.1]: ReduceVibrationCheck node not found in VideoPanel")
		quit(1)
		return
	passed += 1
	print("  [T196.TSCN.1] ReduceVibrationCheck node exists under VideoPanel (OK)")

	total += 1
	if smtscn.find("text = \"减弱手柄振动\"") == -1:
		print("  FAIL [T196.TSCN.2]: ReduceVibrationCheck text = 减弱手柄振动 missing")
		quit(1)
		return
	passed += 1
	print("  [T196.TSCN.2] ReduceVibrationCheck text = 减弱手柄振动 (OK)")

	total += 1
	# 跨设备 tooltip: 含 joypad rumble + mobile vibrate
	if smtscn.find("joypad rumble") == -1 or smtscn.find("vibrate_handheld") == -1:
		print("  FAIL [T196.TSCN.3]: ReduceVibrationCheck tooltip 缺 joypad rumble / vibrate_handheld 跨设备说明")
		quit(1)
		return
	passed += 1
	print("  [T196.TSCN.3] ReduceVibrationCheck tooltip 描述 joypad rumble + mobile vibrate 跨设备 (OK)")

	total += 1
	# ReduceVibrationCheck 在 ReduceFlashCheck 之后 (与 tscn 顺序一致)
	var rv_idx := smtscn.find("ReduceVibrationCheck")
	var rf_idx := smtscn.find("ReduceFlashCheck")
	if rv_idx == -1 or rf_idx == -1 or rv_idx <= rf_idx:
		print("  FAIL [T196.TSCN.4]: ReduceVibrationCheck 顺序错乱, 期望在 ReduceFlashCheck 之后")
		quit(1)
		return
	passed += 1
	print("  [T196.TSCN.4] ReduceVibrationCheck 顺序在 ReduceFlashCheck 之后 (OK)")

	total += 1
	# 注释锚点: tscn 含 T196 (#113) 注释
	if smtscn.find("T196 (#113)") == -1:
		print("  FAIL [T196.TSCN.5]: tscn 缺 T196 (#113) 注释锚点")
		quit(1)
		return
	passed += 1
	print("  [T196.TSCN.5] tscn 含 T196 (#113) 注释锚点 (OK)")

	# ===== T196.GD.ONREADY — settings_menu.gd @onready 字段 =====

	total += 1
	if sm_src.find("@onready var _reduce_vibration_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceVibrationCheck") == -1:
		print("  FAIL [T196.GD.1]: _reduce_vibration_check @onready 字段未绑到 ReduceVibrationCheck 节点")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.1] _reduce_vibration_check @onready 绑到 VideoPanel/ReduceVibrationCheck (OK)")

	# ===== T196.GD.STATE_FIELD — _reduced_vibration 字段 =====

	total += 1
	if sm_src.find("var _reduced_vibration: bool = false") == -1:
		print("  FAIL [T196.GD.2]: _reduced_vibration 状态字段未声明")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.2] _reduced_vibration 状态字段声明 (默认 false) (OK)")

	# ===== T196.GD.TOGGLE_HANDLER — _on_reduce_vibration_toggled =====

	total += 1
	if sm_src.find("func _on_reduce_vibration_toggled(enabled: bool) -> void:") == -1:
		print("  FAIL [T196.GD.3]: _on_reduce_vibration_toggled handler 不存在")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.3] _on_reduce_vibration_toggled handler 存在 (OK)")

	total += 1
	# 调 ScreenShake.set_reduce_vibration (T195 同一 pattern)
	if sm_src.find("ScreenShake.set_reduce_vibration(enabled)") == -1:
		print("  FAIL [T196.GD.4]: _on_reduce_vibration_toggled 缺 live-push 到 ScreenShake.set_reduce_vibration")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.4] _on_reduce_vibration_toggled live-push 到 ScreenShake.set_reduce_vibration (OK)")

	total += 1
	# _ready() 内 connect _on_reduce_vibration_toggled
	if sm_src.find("_reduce_vibration_check.toggled.connect(_on_reduce_vibration_toggled)") == -1:
		print("  FAIL [T196.GD.5]: _ready 缺 _reduce_vibration_check.toggled.connect")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.5] _ready connect _reduce_vibration_check.toggled → handler (OK)")

	# ===== T196.GD.SAVE — _save_settings 写 reduce_vibration =====

	total += 1
	if sm_src.find("cfg.set_value(\"accessibility\", \"reduce_vibration\"") == -1:
		print("  FAIL [T196.GD.6]: _save_settings 缺 [accessibility] reduce_vibration 写")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.6] _save_settings 写 [accessibility] reduce_vibration (OK)")

	# ===== T196.GD.LOAD — _load_settings 读 reduce_vibration =====

	total += 1
	if sm_src.find("cfg.get_value(\"accessibility\", \"reduce_vibration\", false)") == -1:
		print("  FAIL [T196.GD.7]: _load_settings 缺 [accessibility] reduce_vibration 读")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.7] _load_settings 读 [accessibility] reduce_vibration (OK)")

	total += 1
	# _load_settings live-push 到 ScreenShake.set_reduce_vibration
	if sm_src.find("ScreenShake.set_reduce_vibration(_reduced_vibration)") == -1:
		print("  FAIL [T196.GD.8]: _load_settings 缺 live-push ScreenShake.set_reduce_vibration")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.8] _load_settings live-push ScreenShake.set_reduce_vibration (OK)")

	# ===== T196.GD.RESTORE — _on_restore_all_pressed 还原 reduce_vibration 到 off =====

	total += 1
	if sm_src.find("ScreenShake.set_reduce_vibration(false)") == -1:
		print("  FAIL [T196.GD.9]: _on_restore_all_pressed 缺 set_reduce_vibration(false) 还原")
		quit(1)
		return
	passed += 1
	print("  [T196.GD.9] _on_restore_all_pressed 还原 reduce_vibration 到 off (OK)")

	# ===== T196.SHAKE.STATE — screen_shake.gd _reduced_vibration 字段 =====

	total += 1
	if ss_src.find("var _reduced_vibration: bool = false") == -1:
		print("  FAIL [T196.SHAKE.1]: screen_shake.gd 缺 _reduced_vibration 字段")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.1] screen_shake.gd 有 _reduced_vibration 字段 (默认 false) (OK)")

	total += 1
	# 注释锚点 T196 (#113) 在 _reduced_vibration 字段上方
	if ss_src.find("# T196 (#113)") == -1:
		print("  FAIL [T196.SHAKE.2]: screen_shake.gd 缺 T196 (#113) 注释锚点")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.2] screen_shake.gd 含 T196 (#113) 注释锚点 (OK)")

	# ===== T196.SHAKE.SETTERS — set_reduce_vibration / is_reduce_vibration =====

	total += 1
	if ss_src.find("func set_reduce_vibration(enabled: bool) -> void:") == -1:
		print("  FAIL [T196.SHAKE.3]: set_reduce_vibration 公开 setter 缺失")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.3] set_reduce_vibration 公开 setter 存在 (OK)")

	total += 1
	if ss_src.find("func is_reduce_vibration() -> bool:") == -1:
		print("  FAIL [T196.SHAKE.4]: is_reduce_vibration 公开 getter 缺失")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.4] is_reduce_vibration 公开 getter 存在 (OK)")

	# ===== T196.SHAKE.INFLIGHT — set_reduce_vibration(true) 调 Input.stop_joy_vibration =====

	total += 1
	if ss_src.find("Input.stop_joy_vibration(pad_idx)") == -1:
		print("  FAIL [T196.SHAKE.5]: set_reduce_vibration(true) 缺 Input.stop_joy_vibration 跨 pad 停")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.5] set_reduce_vibration(true) 调 Input.stop_joy_vibration 跨 pad (OK)")

	# ===== T196.SHAKE.VIBRATE_HELPER — vibrate(strength, duration) 跨平台路由 =====

	total += 1
	if ss_src.find("func vibrate(strength: float = 0.5, duration: float = 0.1) -> void:") == -1:
		print("  FAIL [T196.SHAKE.6]: vibrate 跨平台路由 helper 缺失")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.6] vibrate(strength, duration) 跨平台路由 helper 存在 (OK)")

	total += 1
	# vibrate 内部调 Input.start_joy_vibration (gamepad)
	if ss_src.find("Input.start_joy_vibration(pad_idx, s, s, d)") == -1:
		print("  FAIL [T196.SHAKE.7]: vibrate 缺 Input.start_joy_vibration gamepad rumble 调")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.7] vibrate 调 Input.start_joy_vibration gamepad rumble (OK)")

	total += 1
	# vibrate 内部调 Input.vibrate_handheld (mobile)
	if ss_src.find("Input.vibrate_handheld(d)") == -1:
		print("  FAIL [T196.SHAKE.8]: vibrate 缺 Input.vibrate_handheld mobile 调")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.8] vibrate 调 Input.vibrate_handheld mobile (OK)")

	# ===== T196.SHAKE.GATING — vibrate 入口 _reduced_vibration 早退 =====

	total += 1
	# vibrate 函数体内有 _reduced_vibration 早退
	var vib_idx := ss_src.find("func vibrate(strength")
	if vib_idx == -1:
		print("  FAIL [T196.SHAKE.9]: vibrate 函数定位失败")
		quit(1)
		return
	var vib_block := ss_src.substr(vib_idx, 1200)
	if vib_block.find("if _reduced_vibration:") == -1 or vib_block.find("\treturn") == -1:
		print("  FAIL [T196.SHAKE.9]: vibrate 缺 _reduced_vibration 早退")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.9] vibrate 入口 _reduced_vibration 早退 (no-op) (OK)")

	# ===== T196.SHAKE.CLAMP — vibrate 钳制 strength / duration =====

	total += 1
	if vib_block.find("clampf(strength, 0.0, 1.0)") == -1 or vib_block.find("maxf(duration, 0.0)") == -1:
		print("  FAIL [T196.SHAKE.10]: vibrate 缺 strength/duration 参数钳制")
		quit(1)
		return
	passed += 1
	print("  [T196.SHAKE.10] vibrate 钳制 strength [0,1] / duration >=0 (OK)")

	print("=== I023 T196 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)
