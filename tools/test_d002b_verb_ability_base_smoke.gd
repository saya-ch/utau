extends SceneTree
## D002.B (#98) — VerbAbilityBase 父类抽取 + 5 verb ability 继承 冒烟测试
##
## 覆盖 #98 D002.B 原子化任务:
## - D002.B.1: 新建 src/scripts/_verb_ability_base.gd (VerbAbilityBase
##              父类), 包含 6 共享字段 + @onready _player + 4 共享方法
##              (_process_cooldown / _consume_verb_cost / _setup_windup_state
##              / _exit_tree) + 2 公开 accessor (get_cooldown_ratio /
##              is_winding_up)
## - D002.B.2: 5 verb ability (pulse / bind / cut / echo / wave) `extends`
##              "res://src/scripts/_verb_ability_base.gd", 删去 6 共享字段 +
##              @onready + 4 共享方法 (byte-identical since #87 / #92 /
##              #97) → 改 _ready() 调 super._ready(), 改 _process() 调
##              _process_cooldown(delta, verb_name)
##
## 与 I009 (#94) 模式一致：源码扫描 + 字符串锚定（不实例化 Node 避免
## headless mock autoload 边界）。回归保护：D002.B 5 verb ability
## 继承 VerbAbilityBase 是 5 verb code-sharing 宪法级约束，任一文件被
## 无意识改回 `extends Node` 或 helper 重复回弹都会被这 30+ 项断言抓住。

const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"
const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== D002.B (#98) — VerbAbilityBase + 5 verb ability extends ===")
	_run_d002b_base_contract_assertions()
	_run_d002b_5verb_extends_assertions()
	_run_d002b_5verb_removed_helpers_assertions()
	_run_d002b_5verb_super_ready_assertions()
	_run_d002b_5verb_process_cooldown_caller_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL D002.B (#98) VerbAbilityBase ASSERTIONS PASSED ===")
		quit(0)


# ---------- D002.B.1 — VerbAbilityBase 父类契约 ----------
func _run_d002b_base_contract_assertions() -> void:
	print("--- D002.B.1 — VerbAbilityBase 父类契约 ---")
	var src := _read_file(VERB_ABILITY_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: D002.B.BASE: cannot read " + VERB_ABILITY_BASE_GD)
		return
	# (1) class_name 声明（5 verb 引用入口）
	_assert_contains(src, "class_name VerbAbilityBase",
		"D002.B.BASE.1: VerbAbilityBase class_name declared (5 verb extends 入口)")
	# (2) extends Node
	_assert_contains(src, "extends Node",
		"D002.B.BASE.2: VerbAbilityBase extends Node (5 verb ability 都是 Node)")
	# (3) 5 verb 共享状态 _cooldown_timer
	_assert_contains(src, "var _cooldown_timer: float",
		"D002.B.BASE.3: base declares _cooldown_timer (5 verb 共享 cooldown 状态)")
	# (4) 5 verb 共享状态 _windup_timer
	_assert_contains(src, "var _windup_timer: float",
		"D002.B.BASE.4: base declares _windup_timer (5 verb 共享 windup 倒计时)")
	# (5) 5 verb 共享状态 _is_winding_up
	_assert_contains(src, "var _is_winding_up: bool",
		"D002.B.BASE.5: base declares _is_winding_up (5 verb 共享 windup 旗)")
	# (6) 5 verb 共享状态 _pending_origin
	_assert_contains(src, "var _pending_origin: Vector2",
		"D002.B.BASE.6: base declares _pending_origin (5 verb 共享 fire origin)")
	# (7) 5 verb 共享状态 _pending_direction
	_assert_contains(src, "var _pending_direction: Vector2",
		"D002.B.BASE.7: base declares _pending_direction (5 verb 共享 fire direction)")
	# (8) T173.C (#92) 共享状态 _windup_vfx
	_assert_contains(src, "var _windup_vfx: Node2D",
		"D002.B.BASE.8: base declares _windup_vfx (T173 #92 5 verb 共享 VFX 句柄)")
	# (9) @onready _player
	_assert_contains(src, "@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D",
		"D002.B.BASE.9: base declares @onready _player (5 verb 共享 player 引用)")
	# (10) _ready 断言 _player
	_assert_contains(src, "assert(_player != null",
		"D002.B.BASE.10: base._ready() asserts _player non-null (D002.B 错父节点保护)")
	# (11) T181 _process_cooldown 方法
	_assert_contains(src, "func _process_cooldown(",
		"D002.B.BASE.11: base declares _process_cooldown() (T181 #97 5 verb 共享 jingle)")
	# (12) T181 jingle guard
	_assert_contains(src, "play_verb_cooldown_ready",
		"D002.B.BASE.12: base._process_cooldown fires play_verb_cooldown_ready (T181 5 verb 音频)")
	# (13) F007 _consume_verb_cost 方法
	_assert_contains(src, "func _consume_verb_cost(",
		"D002.B.BASE.13: base declares _consume_verb_cost() (F007 #87 5 verb 共享 cost-consume)")
	# (14) F007 _consume_verb_cost 调 GameState.consume_resonance
	_assert_contains(src, "GameState.consume_resonance",
		"D002.B.BASE.14: base._consume_verb_cost calls GameState.consume_resonance (F007 contract)")
	# (15) F007 _setup_windup_state 方法
	_assert_contains(src, "func _setup_windup_state(",
		"D002.B.BASE.15: base declares _setup_windup_state() (F007 #87 5 verb 共享 windup setup)")
	# (16) T166 + T173.C _exit_tree 方法
	_assert_contains(src, "func _exit_tree()",
		"D002.B.BASE.16: base declares _exit_tree() (T166 #85 + T173 #92 5 verb 共享 VFX cleanup)")
	# (17) T173 fade_out_and_free 调用
	_assert_contains(src, "fade_out_and_free()",
		"D002.B.BASE.17: base._exit_tree calls _windup_vfx.fade_out_and_free() (T173 #92 5 verb 共享)")
	# (18) get_cooldown_ratio 方法
	_assert_contains(src, "func get_cooldown_ratio()",
		"D002.B.BASE.18: base declares get_cooldown_ratio() (HUD cooldown bar 5 verb 共享)")
	# (19) is_winding_up 方法
	_assert_contains(src, "func is_winding_up()",
		"D002.B.BASE.19: base declares is_winding_up() (D001 #82 PlayerActionGate 共享)")
	# (20) D002.B (#98) 标记
	_assert_contains(src, "D002.B (#98)",
		"D002.B.BASE.20: D002.B (#98) docblock attribution marker in base class")


# ---------- D002.B.2 — 5 verb ability extends VerbAbilityBase ----------
func _run_d002b_5verb_extends_assertions() -> void:
	print("--- D002.B.2 — 5 verb ability extends VerbAbilityBase ---")
	_run_one_extends_assertion("PulseAbility", PULSE_ABILITY_GD, "D002.B.P")
	_run_one_extends_assertion("BindAbility", BIND_ABILITY_GD, "D002.B.B")
	_run_one_extends_assertion("CutAbility", CUT_ABILITY_GD, "D002.B.C")
	_run_one_extends_assertion("EchoAbility", ECHO_ABILITY_GD, "D002.B.E")
	_run_one_extends_assertion("ResonanceWaveAbility", WAVE_ABILITY_GD, "D002.B.W")


func _run_one_extends_assertion(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	# (1) extends VerbAbilityBase (D002.B refactor)
	_assert_contains(src, "extends \"res://src/scripts/_verb_ability_base.gd\"",
		prefix + ".1: " + class_name_str + " extends VerbAbilityBase (D002.B refactor)")
	# (2) 不能 extend Node (避免回弹)
	var has_old_extends := src.contains("extends Node\n") or src.contains("extends Node\r\n")
	if has_old_extends:
		_failures.append("FAIL: " + prefix + ".2: " + class_name_str + " still has 'extends Node' (D002.B regression)")
	else:
		_passes += 1


# ---------- D002.B.3 — 5 verb ability 删去重复 helper / 字段 ----------
func _run_d002b_5verb_removed_helpers_assertions() -> void:
	print("--- D002.B.3 — 5 verb ability 删去重复 helper / 字段 ---")
	_check_no_duplicate_field("pulse_ability.gd", PULSE_ABILITY_GD, "var _cooldown_timer", "D002.B.R.P")
	_check_no_duplicate_field("bind_ability.gd", BIND_ABILITY_GD, "var _cooldown_timer", "D002.B.R.B")
	_check_no_duplicate_field("cut_ability.gd", CUT_ABILITY_GD, "var _cooldown_timer", "D002.B.R.C")
	_check_no_duplicate_field("echo_ability.gd", ECHO_ABILITY_GD, "var _cooldown_timer", "D002.B.R.E")
	_check_no_duplicate_field("resonance_wave_ability.gd", WAVE_ABILITY_GD, "var _cooldown_timer", "D002.B.R.W")
	# 5 verb 都不应再含 @onready var _player
	_check_no_duplicate_field("pulse_ability.gd", PULSE_ABILITY_GD, "@onready var _player", "D002.B.R.P.player")
	_check_no_duplicate_field("bind_ability.gd", BIND_ABILITY_GD, "@onready var _player", "D002.B.R.B.player")
	_check_no_duplicate_field("cut_ability.gd", CUT_ABILITY_GD, "@onready var _player", "D002.B.R.C.player")
	_check_no_duplicate_field("echo_ability.gd", ECHO_ABILITY_GD, "@onready var _player", "D002.B.R.E.player")
	_check_no_duplicate_field("resonance_wave_ability.gd", WAVE_ABILITY_GD, "@onready var _player", "D002.B.R.W.player")
	# 5 verb 不应再含 _consume_verb_cost 函数定义 (现在是 base 的)
	_check_no_duplicate_field("pulse_ability.gd", PULSE_ABILITY_GD, "func _consume_verb_cost(", "D002.B.R.P.helper1")
	_check_no_duplicate_field("bind_ability.gd", BIND_ABILITY_GD, "func _consume_verb_cost(", "D002.B.R.B.helper1")
	_check_no_duplicate_field("cut_ability.gd", CUT_ABILITY_GD, "func _consume_verb_cost(", "D002.B.R.C.helper1")
	_check_no_duplicate_field("echo_ability.gd", ECHO_ABILITY_GD, "func _consume_verb_cost(", "D002.B.R.E.helper1")
	# 5 verb 不应再含 _setup_windup_state 函数定义
	_check_no_duplicate_field("pulse_ability.gd", PULSE_ABILITY_GD, "func _setup_windup_state(", "D002.B.R.P.helper2")
	_check_no_duplicate_field("bind_ability.gd", BIND_ABILITY_GD, "func _setup_windup_state(", "D002.B.R.B.helper2")
	_check_no_duplicate_field("cut_ability.gd", CUT_ABILITY_GD, "func _setup_windup_state(", "D002.B.R.C.helper2")
	_check_no_duplicate_field("echo_ability.gd", ECHO_ABILITY_GD, "func _setup_windup_state(", "D002.B.R.E.helper2")
	# 5 verb 不应再含 _exit_tree 函数定义
	_check_no_duplicate_field("pulse_ability.gd", PULSE_ABILITY_GD, "func _exit_tree():", "D002.B.R.P.helper3")
	_check_no_duplicate_field("bind_ability.gd", BIND_ABILITY_GD, "func _exit_tree():", "D002.B.R.B.helper3")
	_check_no_duplicate_field("cut_ability.gd", CUT_ABILITY_GD, "func _exit_tree():", "D002.B.R.C.helper3")
	_check_no_duplicate_field("echo_ability.gd", ECHO_ABILITY_GD, "func _exit_tree():", "D002.B.R.E.helper3")
	_check_no_duplicate_field("resonance_wave_ability.gd", WAVE_ABILITY_GD, "func _exit_tree():", "D002.B.R.W.helper3")
	# 5 verb 不应再含 get_cooldown_ratio 函数定义
	_check_no_duplicate_field("pulse_ability.gd", PULSE_ABILITY_GD, "func get_cooldown_ratio():", "D002.B.R.P.helper4")
	_check_no_duplicate_field("bind_ability.gd", BIND_ABILITY_GD, "func get_cooldown_ratio():", "D002.B.R.B.helper4")
	_check_no_duplicate_field("cut_ability.gd", CUT_ABILITY_GD, "func get_cooldown_ratio():", "D002.B.R.C.helper4")
	_check_no_duplicate_field("echo_ability.gd", ECHO_ABILITY_GD, "func get_cooldown_ratio():", "D002.B.R.E.helper4")
	_check_no_duplicate_field("resonance_wave_ability.gd", WAVE_ABILITY_GD, "func get_cooldown_ratio():", "D002.B.R.W.helper4")


func _check_no_duplicate_field(file_label: String, path: String, needle: String, label: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + label + ": cannot read " + path)
		return
	# 关键：D002.B 后子类不应再定义此字段/方法
	# 但子类仍可引用（通过继承）— 所以检查 `needle` 后面不能跟 " = ..." 或 " (" (函数定义)
	var idx := src.find(needle)
	if idx < 0:
		_passes += 1
		return
	# 检查是否"独立声明"（被声明而非引用）
	# 简化处理：找到 needle 出现位置后,看其是否在 base 注释标记之前
	# 实际 D002.B 后这些字段不应在子类中再出现,所以直接 fail
	_failures.append("FAIL: " + label + " (" + file_label + " still has " + needle + " — D002.B should have removed this duplicate)")


# ---------- D002.B.4 — 5 verb ability _ready 调 super._ready() ----------
func _run_d002b_5verb_super_ready_assertions() -> void:
	print("--- D002.B.4 — 5 verb ability _ready 调 super._ready() ---")
	_check_ready_super(PULSE_ABILITY_GD, "D002.B.SR.P")
	_check_ready_super(BIND_ABILITY_GD, "D002.B.SR.B")
	_check_ready_super(CUT_ABILITY_GD, "D002.B.SR.C")
	_check_ready_super(ECHO_ABILITY_GD, "D002.B.SR.E")
	_check_ready_super(WAVE_ABILITY_GD, "D002.B.SR.W")


func _check_ready_super(path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	# 找到 _ready() 函数体
	var body := _extract_function_body(src, "func _ready()")
	if body.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot find _ready() body")
		return
	if body.contains("super._ready()"):
		_passes += 1
	else:
		_failures.append("FAIL: " + prefix + ": _ready() should call super._ready() (D002.B 链式初始化)")


# ---------- D002.B.5 — 5 verb ability _process 调 _process_cooldown ----------
func _run_d002b_5verb_process_cooldown_caller_assertions() -> void:
	print("--- D002.B.5 — 5 verb ability _process 调 _process_cooldown ---")
	_check_process_cooldown(PULSE_ABILITY_GD, "pulse", "D002.B.PC.P")
	_check_process_cooldown(BIND_ABILITY_GD, "bind", "D002.B.PC.B")
	_check_process_cooldown(CUT_ABILITY_GD, "cut", "D002.B.PC.C")
	_check_process_cooldown(ECHO_ABILITY_GD, "echo", "D002.B.PC.E")
	_check_process_cooldown(WAVE_ABILITY_GD, "wave", "D002.B.PC.W")


func _check_process_cooldown(path: String, verb_name: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	var body := _extract_function_body(src, "func _process(")
	if body.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot find _process() body")
		return
	var expected_call := "_process_cooldown(delta, \"%s\")" % verb_name
	if body.contains(expected_call):
		_passes += 1
	else:
		_failures.append("FAIL: " + prefix + ": _process() should call " + expected_call + " (D002.B T181 jingle delegation)")
	# 反向断言：T181 inline 实现应已被 helper 取代
	# 检查 _process body 不再含 `AudioManagerEnhanced.play_verb_cooldown_ready(`
	# (T181 jingle 调用现在在 base._process_cooldown)
	if body.contains("play_verb_cooldown_ready"):
		_failures.append("FAIL: " + prefix + ": _process() still has inline T181 jingle call (D002.B regression — should delegate to base)")
	else:
		_passes += 1


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
		body_lines.append(line)
	return "\n".join(body_lines)


func _print_summary() -> void:
	print("--- D002.B (#98) VerbAbilityBase smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
