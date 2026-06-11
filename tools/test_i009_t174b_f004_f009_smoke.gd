extends SceneTree
## I009 (#94) — T174.B + F004 + F009 三连击冒烟测试
##
## 覆盖 #94 三任务原子化提交:
## - T174.B: VerbWindupVFXBase 父类抽取 5 verb windup VFX 公共代码 (state +
##           _ready z_index=10 + _process lifetime tracker + _activate_windup_tween
##           ramp-in tween + fade_out_and_free 退出 tween); 5 verb windup 类
##           `extends VerbWindupVFXBase` 继承
## - F004:   PulseAbility._execute_pulse() 调 AudioManagerEnhanced.play_pulse()
##           闭合 5 verb 音频家族（之前 4 verb Bind/Cut/Echo/Wave 都有命中
##           audio caller，Pulse 是缺的 —— 5 verb 音频闭环最后一格）
## - F009:   STYLE_GUIDE.md 增 "4 Verb 命中色查表常量" 段，定义 4 verb
##           VERB_HIT_*_COLOR 4 元组 + 调用契约 + 6th verb 接入流程
##
## 与 I008 (#93) / I007 (#92) 模式一致：源码扫描 + 字符串锚定（不实例化 Node2D
## 避免 headless mock tween 边界）。
## 回归保护：5 verb windup VFX 共享父类 + 5 verb 音频家族 + 4 verb 命中色查表
## 三个宪法级约束是 Voxglass "5 表面层"之一。任一文件被无意识删除或参数漂移
## 都会被这 25+ 项断言抓住。

const VERB_WINDUP_VFX_BASE_GD := "res://src/scripts/_verb_windup_vfx_base.gd"
const PULSE_WINDUP_VFX_GD := "res://src/scripts/pulse_windup_vfx.gd"
const BIND_WINDUP_VFX_GD := "res://src/scripts/bind_windup_vfx.gd"
const ECHO_WINDUP_VFX_GD := "res://src/scripts/echo_windup_vfx.gd"
const CUT_WINDUP_VFX_GD := "res://src/scripts/cut_windup_vfx.gd"
const WAVE_WINDUP_VFX_GD := "res://src/scripts/wave_windup_vfx.gd"

const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const SCREEN_SHAKE_GD := "res://src/autoload/screen_shake.gd"
const STYLE_GUIDE_MD := "res://STYLE_GUIDE.md"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I009 (#94) — T174.B + F004 + F009 三连击 ===")
	_run_t174b_base_assertions()
	_run_t174b_5verb_extends_assertions()
	_run_f004_pulse_audio_caller_assertions()
	_run_f009_style_guide_4_verb_hit_color_table_assertions()
	_run_f009_4_verb_constants_in_screen_shake_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I009 (#94) T174.B + F004 + F009 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T174.B — VerbWindupVFXBase 父类契约 ----------
func _run_t174b_base_assertions() -> void:
	print("--- T174.B — VerbWindupVFXBase 父类契约 ---")
	var src := _read_file(VERB_WINDUP_VFX_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: T174.B.BASE: cannot read " + VERB_WINDUP_VFX_BASE_GD)
		return
	# (1) class_name 声明（5 verb 引用入口）
	_assert_contains(src, "class_name VerbWindupVFXBase",
		"T174.B.BASE.1: VerbWindupVFXBase class_name declared (5 verb extends 入口)")
	# (2) extends Node2D
	_assert_contains(src, "extends Node2D",
		"T174.B.BASE.2: VerbWindupVFXBase extends Node2D (5 verb windup 是 Node2D 树)")
	# (3) 5 verb 共享状态 _max_lifetime
	_assert_contains(src, "var _max_lifetime: float",
		"T174.B.BASE.3: base declares _max_lifetime (5 verb 共享 lifetime 状态)")
	# (4) 5 verb 共享状态 _lifetime
	_assert_contains(src, "var _lifetime: float",
		"T174.B.BASE.4: base declares _lifetime (5 verb 共享 lifetime 跟踪)")
	# (5) 5 verb 共享状态 _active
	_assert_contains(src, "var _active: bool",
		"T174.B.BASE.5: base declares _active (5 verb 共享 ramp-in/fade-out 激活状态)")
	# (6) _ready() z_index = 10
	_assert_contains(src, "z_index = 10",
		"T174.B.BASE.6: base._ready() sets z_index = 10 (above world, below HUD)")
	# (7) _process() lifetime tracker
	_assert_contains(src, "func _process(",
		"T174.B.BASE.7: base declares _process() (5 verb 共享 lifetime + queue_free safety net)")
	# (8) T174 ramp-in 入口: _activate_windup_tween
	_assert_contains(src, "func _activate_windup_tween(",
		"T174.B.BASE.8: base declares _activate_windup_tween() (T174 #93 ramp-in 入口)")
	# (9) ramp-in 起点 modulate.a = 0.0
	_assert_contains(src, "modulate.a = 0.0",
		"T174.B.BASE.9: base._activate_windup_tween sets modulate.a = 0.0 (T174 ramp-in 起点)")
	# (10) ramp-in create_tween
	_assert_contains(src, "create_tween()",
		"T174.B.BASE.10: base._activate_windup_tween uses create_tween() (T174 ramp-in)")
	# (11) ramp-in 终值 modulate:a 1.0
	_assert_contains(src, "\"modulate:a\", 1.0",
		"T174.B.BASE.11: base._activate_windup_tween tween end is \"modulate:a\", 1.0")
	# (12) ramp-in 时长 _max_lifetime
	_assert_contains(src, "tween.tween_property(self, \"modulate:a\", 1.0, _max_lifetime)",
		"T174.B.BASE.12: base._activate_windup_tween duration is _max_lifetime (verb-specific 调速)")
	# (13) ramp-in TRANS_QUAD
	_assert_contains(src, "Tween.TRANS_QUAD",
		"T174.B.BASE.13: base uses Tween.TRANS_QUAD (T174 ramp-in 平滑曲线)")
	# (14) ramp-in EASE_OUT
	_assert_contains(src, "Tween.EASE_OUT",
		"T174.B.BASE.14: base uses Tween.EASE_OUT (T174 ramp-in 缓动)")
	# (15) T173 退出契约: fade_out_and_free
	_assert_contains(src, "func fade_out_and_free(",
		"T174.B.BASE.15: base declares fade_out_and_free() (T173 #92 5 verb 共享退出)")
	# (16) T173 0.05s 淡出时长
	_assert_contains(src, "0.05",
		"T174.B.BASE.16: base.fade_out_and_free uses 0.05s fade-out duration (T173 5 verb 共享)")
	# (17) T173 淡出到 0.0
	_assert_contains(src, "\"modulate:a\", 0.0",
		"T174.B.BASE.17: base.fade_out_and_free tween end is \"modulate:a\", 0.0 (T173 淡出到透明)")
	# (18) T173 queue_free() at fade end
	_assert_contains(src, "tween.tween_callback(queue_free)",
		"T174.B.BASE.18: base.fade_out_and_free calls queue_free via tween_callback (T173 fade-and-free)")
	# (19) T174.B (#94) docblock attribution
	_assert_contains(src, "T174.B (#94)",
		"T174.B.BASE.19: T174.B (#94) docblock attribution marker in base class")


# ---------- T174.B — 5 verb windup extends VerbWindupVFXBase ----------
func _run_t174b_5verb_extends_assertions() -> void:
	print("--- T174.B — 5 verb windup extends VerbWindupVFXBase ---")
	_run_one_extends_assertion("PulseWindupVFX", PULSE_WINDUP_VFX_GD, "T174.B.P")
	_run_one_extends_assertion("BindWindupVFX", BIND_WINDUP_VFX_GD, "T174.B.B")
	_run_one_extends_assertion("EchoWindupVFX", ECHO_WINDUP_VFX_GD, "T174.B.E")
	_run_one_extends_assertion("CutWindupVFX", CUT_WINDUP_VFX_GD, "T174.B.C")
	_run_one_extends_assertion("WaveWindupVFX", WAVE_WINDUP_VFX_GD, "T174.B.W")


func _run_one_extends_assertion(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	_assert_contains(src, "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"",
		prefix + ": " + class_name_str + " extends VerbWindupVFXBase (T174.B refactor)")
	_assert_contains(src, "_activate_windup_tween()",
		prefix + ": " + class_name_str + ".trigger() calls _activate_windup_tween() (T174.B contract)")


# ---------- F004 — PulseAbility._execute_pulse 加 AudioManagerEnhanced.play_pulse() ----------
func _run_f004_pulse_audio_caller_assertions() -> void:
	print("--- F004 — PulseAbility._execute_pulse 音频调用 ---")
	var pulse_src := _read_file(PULSE_ABILITY_GD)
	if pulse_src.is_empty():
		_failures.append("FAIL: F004: cannot read " + PULSE_ABILITY_GD)
		return
	# (1) PulseAbility 调 AudioManagerEnhanced.play_pulse()
	_assert_contains(pulse_src, "AudioManagerEnhanced.play_pulse()",
		"F004.1: PulseAbility calls AudioManagerEnhanced.play_pulse() (5 verb 音频闭环最后一格)")
	# (2) 调用位置在 _execute_pulse() 函数体内（在 pulse_fired.emit 之后）
	var execute_idx := pulse_src.find("func _execute_pulse()")
	var pulse_fired_idx := pulse_src.find("pulse_fired.emit")
	var play_pulse_idx := pulse_src.find("AudioManagerEnhanced.play_pulse()")
	if execute_idx < 0 or pulse_fired_idx < 0 or play_pulse_idx < 0:
		_failures.append("FAIL: F004.2: cannot find _execute_pulse / pulse_fired.emit / play_pulse() markers")
	elif not (execute_idx < pulse_fired_idx and pulse_fired_idx < play_pulse_idx):
		_failures.append("FAIL: F004.2: play_pulse() call is NOT after pulse_fired.emit inside _execute_pulse() (F004 placement wrong)")
	else:
		_passes += 1
	# (3) is_instance_valid 守卫（保护 _player 已 free 的边角情况：windup 期间玩家死亡）
	var execute_body := _extract_function_body(pulse_src, "func _execute_pulse()")
	if "is_instance_valid" in execute_body:
		_passes += 1
	else:
		_failures.append("FAIL: F004.3: _execute_pulse() should guard _player with is_instance_valid (F004 抗中断)")
	# (4) F004 (#94) docblock 标记
	_assert_contains(pulse_src, "F004 (#94)",
		"F004.4: F004 (#94) docblock attribution marker in pulse_ability.gd")


# ---------- F009 — STYLE_GUIDE.md 4 verb 命中色查表段 ----------
func _run_f009_style_guide_4_verb_hit_color_table_assertions() -> void:
	print("--- F009 — STYLE_GUIDE.md 4 verb 命中色查表段 ---")
	var src := _read_file(STYLE_GUIDE_MD)
	if src.is_empty():
		_failures.append("FAIL: F009: cannot read " + STYLE_GUIDE_MD)
		return
	# (1) 段标题存在
	_assert_contains(src, "4 Verb 命中色查表常量",
		"F009.1: STYLE_GUIDE.md has '4 Verb 命中色查表常量' section header")
	# (2) 4 verb 命中色表头（常量名）
	_assert_contains(src, "ScreenShake.VERB_HIT_PULSE_COLOR",
		"F009.2: Pulse 命中色常量在 STYLE_GUIDE.md 表格中")
	_assert_contains(src, "ScreenShake.VERB_HIT_BIND_COLOR",
		"F009.3: Bind 命中色常量在 STYLE_GUIDE.md 表格中")
	_assert_contains(src, "ScreenShake.VERB_HIT_CUT_COLOR",
		"F009.4: Cut 命中色常量在 STYLE_GUIDE.md 表格中")
	_assert_contains(src, "ScreenShake.VERB_HIT_ECHO_COLOR",
		"F009.5: Echo 命中色常量在 STYLE_GUIDE.md 表格中")
	# (3) 4 verb 命中色 hex 在表格中
	_assert_contains(src, "#E86D5A",
		"F009.6: Pulse Coral Pulse hex #E86D5A 在 4 verb 命中色表中")
	_assert_contains(src, "#65506A",
		"F009.7: Bind Muted Violet hex #65506A 在 4 verb 命中色表中")
	_assert_contains(src, "#F2B66E",
		"F009.8: Cut Amber Voice hex #F2B66E 在 4 verb 命中色表中")
	_assert_contains(src, "#69C7CE",
		"F009.9: Echo Glass Cyan hex #69C7CE 在 4 verb 命中色表中")
	# (4) 调用契约示例
	_assert_contains(src, "ScreenShake.flash_color(ScreenShake.VERB_HIT_PULSE_COLOR",
		"F009.10: 4 verb 命中色调用契约示例 (flash_color)")
	# (5) F009 (#94) 标记
	_assert_contains(src, "F009 (#94)",
		"F009.11: F009 (#94) attribution marker in STYLE_GUIDE.md")
	# (6) 未来 6th verb 接入流程说明
	_assert_contains(src, "6th verb",
		"F009.12: STYLE_GUIDE.md 解释 6th verb 接入流程 (宪法修订)")
	# (7) Wave 明确说明不参与此查表
	_assert_contains(src, "Wave",
		"F009.13: Wave verb 在 4 verb 命中色查表段被显式说明 (不参与此查表)")


# ---------- F009 — screen_shake.gd 4 verb 命中色常量实际存在 ----------
func _run_f009_4_verb_constants_in_screen_shake_assertions() -> void:
	print("--- F009 — screen_shake.gd 4 verb 命中色常量存在 ---")
	var src := _read_file(SCREEN_SHAKE_GD)
	if src.is_empty():
		_failures.append("FAIL: F009: cannot read " + SCREEN_SHAKE_GD)
		return
	# 4 verb 命中色常量在 screen_shake.gd 中存在（合约源头）
	_assert_contains(src, "VERB_HIT_PULSE_COLOR",
		"F009.14: screen_shake.gd declares VERB_HIT_PULSE_COLOR")
	_assert_contains(src, "VERB_HIT_BIND_COLOR",
		"F009.15: screen_shake.gd declares VERB_HIT_BIND_COLOR")
	_assert_contains(src, "VERB_HIT_CUT_COLOR",
		"F009.16: screen_shake.gd declares VERB_HIT_CUT_COLOR")
	_assert_contains(src, "VERB_HIT_ECHO_COLOR",
		"F009.17: screen_shake.gd declares VERB_HIT_ECHO_COLOR")


# ---------- helpers ----------
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


# Extract the body of a function (by its header line containing `header_needle`)
# from `src`.  Scans from the function header line until the next top-level
# `func ` at the same indent level (GDScript functions don't have inner
# closures, so this is reliable).
func _extract_function_body(src: String, header_needle: String) -> String:
	var lines := src.split("\n")
	var start_idx := -1
	for i in lines.size():
		if lines[i].contains(header_needle):
			start_idx = i
			break
	if start_idx < 0:
		return ""
	var func_line := lines[start_idx]
	var func_indent := func_line.length() - func_line.lstrip("\t ").length()
	var body_lines: Array[String] = []
	for j in range(start_idx + 1, lines.size()):
		var line := lines[j]
		if line.begins_with("func ") and (line.length() - line.lstrip("\t ").length()) == func_indent:
			break
		if line.strip_edges().is_empty() or line.strip_edges().begins_with("#"):
			continue
		body_lines.append(line)
	return "\n".join(body_lines)


func _print_summary() -> void:
	print("--- I009 (#94) T174.B + F004 + F009 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
