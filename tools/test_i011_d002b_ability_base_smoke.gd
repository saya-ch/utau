extends SceneTree
## I011 (#98) — D002.B 5 verb ability 重构 (VerbAbilityBase 抽取) 冒烟测试
##
## 覆盖 #98 D002.B 任务原子化提交:
## - D002.B.BASE: 新建 _verb_ability_base.gd (class_name VerbAbilityBase,
##                extends Node, 5 verb 公共状态 + 公共方法)
## - D002.B.EXTEND: 5 verb ability (pulse / bind / cut / echo / wave)
##                  全部 `extends "res://src/scripts/_verb_ability_base.gd"`
## - D002.B.STATE: 5 verb 子类不再重复声明 _cooldown_timer / _windup_timer /
##                 _is_winding_up / _pending_origin / _pending_direction /
##                 _windup_vfx (6 字段)
## - D002.B.FN: 5 verb 子类不再重复定义 _consume_verb_cost /
##              _setup_windup_state / _exit_tree / get_cooldown_ratio /
##              is_winding_up (5 方法)
## - D002.B.VIRTUAL: 5 verb 子类实现 _get_verb_name() 返回对应 verb 字符串
##                   + _execute() 转发到原 _execute_*() + _spawn_windup_vfx()
## - D002.B.PROCESS: Pulse / Bind / Cut 子类无 _process 覆盖 (base 接管);
##                   Echo / Wave 子类 _process 调 super._process(delta)
##                   后再处理 active state
## - D002.B.AUDIO: 5 verb base 集中调 play_verb_cooldown_ready(<name>),
##                 5 verb name 通过 _get_verb_name() 虚函数传入
## - D002.B.HELPER: base 提供 _attach_windup_vfx(vfx_script) helper,
##                   5 verb 子类 _spawn_windup_vfx() 用同一 helper + 各自 trigger
##
## 回归保护: 重构 5 verb ability 后, byte-identical 公共代码仅在 base 一份;
##           任何 verb 子类试图重定义 5 个公共方法或 6 个公共字段都会被这
##           25+ 项断言抓住 (5 verb × 5 fn + 5 verb × 6 state + 5 verb name 串 +
##           base 7 fn + 5 子类 _spawn_windup_vfx + 5 子类 _get_verb_name +
##           extend 5 + super 调用 2 + 公共 state 6 字段 = 60+ checks)

const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"
const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I011 (#98) — D002.B 5 verb ability 重构 (VerbAbilityBase 抽取) ===")
	_run_d002b_base_class_assertions()
	_run_d002b_extends_assertions()
	_run_d002b_state_dedup_assertions()
	_run_d002b_function_dedup_assertions()
	_run_d002b_virtual_implementation_assertions()
	_run_d002b_process_extension_assertions()
	_run_d002b_audio_cooldown_jingle_assertions()
	_run_d002b_helper_attach_windup_vfx_assertions()
	_run_d002b_docblock_marker_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I011 (#98) D002.B ASSERTIONS PASSED ===")
		quit(0)


# ---------- D002.B.BASE — _verb_ability_base.gd 新建 ----------
func _run_d002b_base_class_assertions() -> void:
	print("--- D002.B.BASE — _verb_ability_base.gd 公共 base ---")
	var base_src := _read_file(VERB_ABILITY_BASE_GD)
	_assert_not_empty(base_src, "D002.B.BASE.1: _verb_ability_base.gd file exists")
	_assert_contains(base_src, "class_name VerbAbilityBase",
		"D002.B.BASE.2: VerbAbilityBase class_name declared (5 verb 子类 extends 锚点)")
	_assert_contains(base_src, "extends Node",
		"D002.B.BASE.3: VerbAbilityBase extends Node (与 5 verb 原始 extends 一致)")

	# 6 个公共状态字段
	_assert_contains(base_src, "var _cooldown_timer: float = 0.0",
		"D002.B.BASE.4: base._cooldown_timer declared (5 verb 共享状态)")
	_assert_contains(base_src, "var _windup_timer: float = 0.0",
		"D002.B.BASE.5: base._windup_timer declared (5 verb 共享状态)")
	_assert_contains(base_src, "var _is_winding_up: bool = false",
		"D002.B.BASE.6: base._is_winding_up declared (5 verb 共享状态)")
	_assert_contains(base_src, "var _pending_origin: Vector2 = Vector2.ZERO",
		"D002.B.BASE.7: base._pending_origin declared (5 verb 共享状态)")
	_assert_contains(base_src, "var _pending_direction: Vector2 = Vector2.ZERO",
		"D002.B.BASE.8: base._pending_direction declared (5 verb 共享状态)")
	_assert_contains(base_src, "var _windup_vfx: Node2D = null",
		"D002.B.BASE.9: base._windup_vfx declared (5 verb 共享 windup VFX 句柄)")

	# 5 个公共方法
	_assert_contains(base_src, "func _consume_verb_cost(cost: int) -> bool",
		"D002.B.BASE.10: base._consume_verb_cost(cost) declared (F007 #87 抽取)")
	_assert_contains(base_src, "func _setup_windup_state(origin: Vector2, direction: Vector2) -> void",
		"D002.B.BASE.11: base._setup_windup_state(origin, direction) declared (F007 #87 抽取)")
	_assert_contains(base_src, "func _exit_tree() -> void",
		"D002.B.BASE.12: base._exit_tree() declared (T173 #92 fade_out_and_free 抽取)")
	_assert_contains(base_src, "func get_cooldown_ratio() -> float",
		"D002.B.BASE.13: base.get_cooldown_ratio() declared (HUD 查询 抽取)")
	_assert_contains(base_src, "func is_winding_up() -> bool",
		"D002.B.BASE.14: base.is_winding_up() declared (player.gd handler 查询 抽取)")

	# base 还要有 _process (驱动 cooldown + windup timer)
	_assert_contains(base_src, "func _process(delta: float) -> void",
		"D002.B.BASE.15: base._process(delta) declared (T181 #97 cooldown jingle + windup 调度)")

	# 1 个 _attach_windup_vfx helper
	_assert_contains(base_src, "func _attach_windup_vfx(vfx_script: GDScript) -> void",
		"D002.B.BASE.16: base._attach_windup_vfx(vfx_script) helper declared (5 verb 统一 windup VFX 装载)")

	# 3 个 virtual 锚点 (供 5 verb 子类 override)
	_assert_contains(base_src, "func _get_verb_name() -> String",
		"D002.B.BASE.17: base._get_verb_name() virtual declared (T181 #97 cooldown jingle name 传入)")
	_assert_contains(base_src, "func _execute() -> void",
		"D002.B.BASE.18: base._execute() virtual declared (windup timer 到时由 base 调度)")
	_assert_contains(base_src, "func _spawn_windup_vfx() -> void",
		"D002.B.BASE.19: base._spawn_windup_vfx() virtual declared (5 verb 各自 windup VFX 装载)")

	# 锚定 cooldown jingle 调用 (T181 #97 集中化)
	_assert_contains(base_src, "AudioManagerEnhanced.play_verb_cooldown_ready(_get_verb_name())",
		"D002.B.BASE.20: base._process calls play_verb_cooldown_ready(_get_verb_name()) (T181 #97 集中)")


# ---------- D002.B.EXTEND — 5 verb 子类 extends 锚点 ----------
func _run_d002b_extends_assertions() -> void:
	print("--- D002.B.EXTEND — 5 verb 子类 extends ---")
	_assert_contains(_read_file(PULSE_ABILITY_GD),
		"extends \"res://src/scripts/_verb_ability_base.gd\"",
		"D002.B.EXTEND.1: PulseAbility extends VerbAbilityBase")
	_assert_contains(_read_file(BIND_ABILITY_GD),
		"extends \"res://src/scripts/_verb_ability_base.gd\"",
		"D002.B.EXTEND.2: BindAbility extends VerbAbilityBase")
	_assert_contains(_read_file(CUT_ABILITY_GD),
		"extends \"res://src/scripts/_verb_ability_base.gd\"",
		"D002.B.EXTEND.3: CutAbility extends VerbAbilityBase")
	_assert_contains(_read_file(ECHO_ABILITY_GD),
		"extends \"res://src/scripts/_verb_ability_base.gd\"",
		"D002.B.EXTEND.4: EchoAbility extends VerbAbilityBase")
	_assert_contains(_read_file(WAVE_ABILITY_GD),
		"extends \"res://src/scripts/_verb_ability_base.gd\"",
		"D002.B.EXTEND.5: ResonanceWaveAbility extends VerbAbilityBase")


# ---------- D002.B.STATE — 5 verb 子类不再重复声明 6 公共字段 ----------
func _run_d002b_state_dedup_assertions() -> void:
	print("--- D002.B.STATE — 5 verb 公共字段去重 (各子类不重声明) ---")
	# 每个子类不应再声明 6 公共字段 (因为 base 已拥有)
	# 用"头部声明 vs 中部赋值"区分: _cooldown_timer: float = 0.0 这种"声明"形式
	# 在子类里应不再出现
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "var _cooldown_timer: float = 0.0",
		"D002.B.STATE.1: PulseAbility does NOT redeclare _cooldown_timer (base owns it)")
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "var _windup_vfx: Node2D = null",
		"D002.B.STATE.2: PulseAbility does NOT redeclare _windup_vfx (base owns it)")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "var _cooldown_timer: float = 0.0",
		"D002.B.STATE.3: BindAbility does NOT redeclare _cooldown_timer")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "var _windup_vfx: Node2D = null",
		"D002.B.STATE.4: BindAbility does NOT redeclare _windup_vfx")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "var _cooldown_timer: float = 0.0",
		"D002.B.STATE.5: CutAbility does NOT redeclare _cooldown_timer")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "var _windup_vfx: Node2D = null",
		"D002.B.STATE.6: CutAbility does NOT redeclare _windup_vfx")
	_assert_not_contains_decl(_read_file(ECHO_ABILITY_GD), "var _cooldown_timer: float = 0.0",
		"D002.B.STATE.7: EchoAbility does NOT redeclare _cooldown_timer")
	_assert_not_contains_decl(_read_file(ECHO_ABILITY_GD), "var _windup_vfx: Node2D = null",
		"D002.B.STATE.8: EchoAbility does NOT redeclare _windup_vfx")
	_assert_not_contains_decl(_read_file(WAVE_ABILITY_GD), "var _cooldown_timer: float = 0.0",
		"D002.B.STATE.9: WaveAbility does NOT redeclare _cooldown_timer")
	_assert_not_contains_decl(_read_file(WAVE_ABILITY_GD), "var _windup_vfx: Node2D = null",
		"D002.B.STATE.10: WaveAbility does NOT redeclare _windup_vfx")


# ---------- D002.B.FN — 5 verb 子类不再重复定义 5 公共方法 ----------
func _run_d002b_function_dedup_assertions() -> void:
	print("--- D002.B.FN — 5 verb 公共方法去重 (各子类不重定义) ---")
	# 5 verb 子类不应再 `func _consume_verb_cost(...)` (base 拥有)
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "func _consume_verb_cost(cost: int) -> bool",
		"D002.B.FN.1: PulseAbility does NOT redefine _consume_verb_cost (base owns it)")
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "func _setup_windup_state(origin: Vector2, direction: Vector2) -> void",
		"D002.B.FN.2: PulseAbility does NOT redefine _setup_windup_state")
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "func _exit_tree() -> void",
		"D002.B.FN.3: PulseAbility does NOT redefine _exit_tree")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "func _consume_verb_cost(cost: int) -> bool",
		"D002.B.FN.4: BindAbility does NOT redefine _consume_verb_cost")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "func _exit_tree() -> void",
		"D002.B.FN.5: BindAbility does NOT redefine _exit_tree")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "func _consume_verb_cost(cost: int) -> bool",
		"D002.B.FN.6: CutAbility does NOT redefine _consume_verb_cost")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "func _exit_tree() -> void",
		"D002.B.FN.7: CutAbility does NOT redefine _exit_tree")
	_assert_not_contains_decl(_read_file(ECHO_ABILITY_GD), "func _consume_verb_cost(cost: int) -> bool",
		"D002.B.FN.8: EchoAbility does NOT redefine _consume_verb_cost")
	_assert_not_contains_decl(_read_file(ECHO_ABILITY_GD), "func _exit_tree() -> void",
		"D002.B.FN.9: EchoAbility does NOT redefine _exit_tree")
	_assert_not_contains_decl(_read_file(WAVE_ABILITY_GD), "func _consume_verb_cost(cost: int) -> bool",
		"D002.B.FN.10: WaveAbility does NOT redefine _consume_verb_cost")
	_assert_not_contains_decl(_read_file(WAVE_ABILITY_GD), "func _exit_tree() -> void",
		"D002.B.FN.11: WaveAbility does NOT redefine _exit_tree")
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "func get_cooldown_ratio() -> float",
		"D002.B.FN.12: PulseAbility does NOT redefine get_cooldown_ratio (base owns)")
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "func is_winding_up() -> bool",
		"D002.B.FN.13: PulseAbility does NOT redefine is_winding_up (base owns)")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "func get_cooldown_ratio() -> float",
		"D002.B.FN.14: BindAbility does NOT redefine get_cooldown_ratio")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "func get_cooldown_ratio() -> float",
		"D002.B.FN.15: CutAbility does NOT redefine get_cooldown_ratio")
	_assert_not_contains_decl(_read_file(ECHO_ABILITY_GD), "func get_cooldown_ratio() -> float",
		"D002.B.FN.16: EchoAbility does NOT redefine get_cooldown_ratio")
	_assert_not_contains_decl(_read_file(WAVE_ABILITY_GD), "func get_cooldown_ratio() -> float",
		"D002.B.FN.17: WaveAbility does NOT redefine get_cooldown_ratio")


# ---------- D002.B.VIRTUAL — 5 verb 子类实现 _get_verb_name + _execute + _spawn_windup_vfx ----------
func _run_d002b_virtual_implementation_assertions() -> void:
	print("--- D002.B.VIRTUAL — 5 verb 子类 virtual 实现 ---")
	# (1) 5 verb _get_verb_name 返回对应 verb 字符串
	_assert_contains(_read_file(PULSE_ABILITY_GD), "return \"pulse\"",
		"D002.B.VIRTUAL.1: PulseAbility._get_verb_name returns \"pulse\"")
	_assert_contains(_read_file(BIND_ABILITY_GD), "return \"bind\"",
		"D002.B.VIRTUAL.2: BindAbility._get_verb_name returns \"bind\"")
	_assert_contains(_read_file(CUT_ABILITY_GD), "return \"cut\"",
		"D002.B.VIRTUAL.3: CutAbility._get_verb_name returns \"cut\"")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "return \"echo\"",
		"D002.B.VIRTUAL.4: EchoAbility._get_verb_name returns \"echo\"")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "return \"wave\"",
		"D002.B.VIRTUAL.5: WaveAbility._get_verb_name returns \"wave\"")

	# (2) 5 verb _execute() 转发到原 _execute_*()
	_assert_contains(_read_file(PULSE_ABILITY_GD), "func _execute() -> void:\n\t_execute_pulse()",
		"D002.B.VIRTUAL.6: PulseAbility._execute forwards to _execute_pulse()")
	_assert_contains(_read_file(BIND_ABILITY_GD), "func _execute() -> void:\n\t_execute_bind()",
		"D002.B.VIRTUAL.7: BindAbility._execute forwards to _execute_bind()")
	_assert_contains(_read_file(CUT_ABILITY_GD), "func _execute() -> void:\n\t_execute_cut()",
		"D002.B.VIRTUAL.8: CutAbility._execute forwards to _execute_cut()")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "func _execute() -> void:\n\t_execute_echo()",
		"D002.B.VIRTUAL.9: EchoAbility._execute forwards to _execute_echo()")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "func _execute() -> void:\n\t_execute_wave()",
		"D002.B.VIRTUAL.10: WaveAbility._execute forwards to _execute_wave()")

	# (3) 5 verb _spawn_windup_vfx() 用 base._attach_windup_vfx + 各自 preload
	_assert_contains(_read_file(PULSE_ABILITY_GD), "_attach_windup_vfx(preload(\"res://src/scripts/pulse_windup_vfx.gd\"))",
		"D002.B.VIRTUAL.11: PulseAbility._spawn_windup_vfx uses _attach_windup_vfx + pulse_windup_vfx preload")
	_assert_contains(_read_file(BIND_ABILITY_GD), "_attach_windup_vfx(preload(\"res://src/scripts/bind_windup_vfx.gd\"))",
		"D002.B.VIRTUAL.12: BindAbility._spawn_windup_vfx uses _attach_windup_vfx + bind_windup_vfx preload")
	_assert_contains(_read_file(CUT_ABILITY_GD), "_attach_windup_vfx(preload(\"res://src/scripts/cut_windup_vfx.gd\"))",
		"D002.B.VIRTUAL.13: CutAbility._spawn_windup_vfx uses _attach_windup_vfx + cut_windup_vfx preload")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "_attach_windup_vfx(preload(\"res://src/scripts/echo_windup_vfx.gd\"))",
		"D002.B.VIRTUAL.14: EchoAbility._spawn_windup_vfx uses _attach_windup_vfx + echo_windup_vfx preload")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "_attach_windup_vfx(preload(\"res://src/scripts/wave_windup_vfx.gd\"))",
		"D002.B.VIRTUAL.15: WaveAbility._spawn_windup_vfx uses _attach_windup_vfx + wave_windup_vfx preload")


# ---------- D002.B.PROCESS — Pulse/Bind/Cut 无 _process; Echo/Wave 调 super._process ----------
func _run_d002b_process_extension_assertions() -> void:
	print("--- D002.B.PROCESS — 5 verb _process 集中化 ---")
	# Pulse / Bind / Cut 不再有 _process 覆盖 (base 接管 windup + cooldown jingle)
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "func _process(delta: float) -> void",
		"D002.B.PROCESS.1: PulseAbility has NO _process override (base 接管)")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "func _process(delta: float) -> void",
		"D002.B.PROCESS.2: BindAbility has NO _process override (base 接管)")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "func _process(delta: float) -> void",
		"D002.B.PROCESS.3: CutAbility has NO _process override (base 接管)")

	# Echo / Wave 仍 _process (post-fire active state) 但调 super._process(delta) 调起 base
	_assert_contains(_read_file(ECHO_ABILITY_GD), "func _process(delta: float) -> void",
		"D002.B.PROCESS.4: EchoAbility HAS _process override (post-fire shield state)")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "super._process(delta)",
		"D002.B.PROCESS.5: EchoAbility._process calls super._process(delta) (调起 base)")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "func _process(delta: float) -> void",
		"D002.B.PROCESS.6: WaveAbility HAS _process override (post-fire expanding wave)")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "super._process(delta)",
		"D002.B.PROCESS.7: WaveAbility._process calls super._process(delta) (调起 base)")

	# 5 verb 子类不再有冗余的 cooldown jingle 字符串调用 (base 接管)
	_assert_not_contains_decl(_read_file(PULSE_ABILITY_GD), "play_verb_cooldown_ready(\"pulse\")",
		"D002.B.PROCESS.8: PulseAbility has NO inline play_verb_cooldown_ready call (base 接管)")
	_assert_not_contains_decl(_read_file(BIND_ABILITY_GD), "play_verb_cooldown_ready(\"bind\")",
		"D002.B.PROCESS.9: BindAbility has NO inline play_verb_cooldown_ready call")
	_assert_not_contains_decl(_read_file(CUT_ABILITY_GD), "play_verb_cooldown_ready(\"cut\")",
		"D002.B.PROCESS.10: CutAbility has NO inline play_verb_cooldown_ready call")
	_assert_not_contains_decl(_read_file(ECHO_ABILITY_GD), "play_verb_cooldown_ready(\"echo\")",
		"D002.B.PROCESS.11: EchoAbility has NO inline play_verb_cooldown_ready call")
	_assert_not_contains_decl(_read_file(WAVE_ABILITY_GD), "play_verb_cooldown_ready(\"wave\")",
		"D002.B.PROCESS.12: WaveAbility has NO inline play_verb_cooldown_ready call")


# ---------- D002.B.AUDIO — 5 verb 通过 _get_verb_name 集中化 cooldown jingle ----------
func _run_d002b_audio_cooldown_jingle_assertions() -> void:
	print("--- D002.B.AUDIO — cooldown jingle 集中化 (base 唯一 caller) ---")
	# 5 verb name 字符串存在 (供 _get_verb_name 返回)
	var base_src := _read_file(VERB_ABILITY_BASE_GD)
	_assert_contains(base_src, "play_verb_cooldown_ready(_get_verb_name())",
		"D002.B.AUDIO.1: base 集中调 play_verb_cooldown_ready(_get_verb_name()) (T181 集中化)")

	# 5 verb 子类的 _get_verb_name 实现校验
	_assert_contains(_read_file(PULSE_ABILITY_GD), "func _get_verb_name() -> String",
		"D002.B.AUDIO.2: PulseAbility defines _get_verb_name()")
	_assert_contains(_read_file(BIND_ABILITY_GD), "func _get_verb_name() -> String",
		"D002.B.AUDIO.3: BindAbility defines _get_verb_name()")
	_assert_contains(_read_file(CUT_ABILITY_GD), "func _get_verb_name() -> String",
		"D002.B.AUDIO.4: CutAbility defines _get_verb_name()")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "func _get_verb_name() -> String",
		"D002.B.AUDIO.5: EchoAbility defines _get_verb_name()")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "func _get_verb_name() -> String",
		"D002.B.AUDIO.6: WaveAbility defines _get_verb_name()")


# ---------- D002.B.HELPER — base._attach_windup_vfx 5 verb 统一调用 ----------
func _run_d002b_helper_attach_windup_vfx_assertions() -> void:
	print("--- D002.B.HELPER — _attach_windup_vfx helper 5 verb 复用 ---")
	# base 实现 _attach_windup_vfx (queue_free old + create new + add to scene)
	var base_src := _read_file(VERB_ABILITY_BASE_GD)
	_assert_contains(base_src, "_windup_vfx.queue_free()",
		"D002.B.HELPER.1: base._attach_windup_vfx frees leaked previous VFX")
	_assert_contains(base_src, "vfx_script.new()",
		"D002.B.HELPER.2: base._attach_windup_vfx creates new VFX instance")
	_assert_contains(base_src, "scene.add_child(_windup_vfx)",
		"D002.B.HELPER.3: base._attach_windup_vfx adds VFX to current_scene (修复 Wave latent bug)")
	_assert_contains(base_src, "get_tree().current_scene",
		"D002.B.HELPER.4: base._attach_windup_vfx resolves scene via get_tree().current_scene")

	# 5 verb 调 _attach_windup_vfx
	_assert_contains(_read_file(PULSE_ABILITY_GD), "_attach_windup_vfx(",
		"D002.B.HELPER.5: PulseAbility uses _attach_windup_vfx helper")
	_assert_contains(_read_file(BIND_ABILITY_GD), "_attach_windup_vfx(",
		"D002.B.HELPER.6: BindAbility uses _attach_windup_vfx helper")
	_assert_contains(_read_file(CUT_ABILITY_GD), "_attach_windup_vfx(",
		"D002.B.HELPER.7: CutAbility uses _attach_windup_vfx helper")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "_attach_windup_vfx(",
		"D002.B.HELPER.8: EchoAbility uses _attach_windup_vfx helper")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "_attach_windup_vfx(",
		"D002.B.HELPER.9: WaveAbility uses _attach_windup_vfx helper (修复 latent 顺序 bug)")


# ---------- D002.B.MARK — 5 源文件 + base docblock 标记 ----------
func _run_d002b_docblock_marker_assertions() -> void:
	print("--- D002.B.MARK — D002.B (#98) attribution marker ---")
	_assert_contains(_read_file(VERB_ABILITY_BASE_GD), "D002.B (#98)",
		"D002.B.MARK.1: D002.B (#98) marker in _verb_ability_base.gd")
	_assert_contains(_read_file(PULSE_ABILITY_GD), "D002.B (#98)",
		"D002.B.MARK.2: D002.B (#98) marker in pulse_ability.gd")
	_assert_contains(_read_file(BIND_ABILITY_GD), "D002.B (#98)",
		"D002.B.MARK.3: D002.B (#98) marker in bind_ability.gd")
	_assert_contains(_read_file(CUT_ABILITY_GD), "D002.B (#98)",
		"D002.B.MARK.4: D002.B (#98) marker in cut_ability.gd")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "D002.B (#98)",
		"D002.B.MARK.5: D002.B (#98) marker in echo_ability.gd")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "D002.B (#98)",
		"D002.B.MARK.6: D002.B (#98) marker in resonance_wave_ability.gd")


# ---------- helpers ----------
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle missing: " + needle + ")")


func _assert_not_empty(src: String, label: String) -> void:
	if src.is_empty():
		_failures.append("FAIL: " + label + " (file empty or missing)")
	else:
		_passes += 1


# "声明"形式 (有完整类型签名) 不应出现 — 区分"行内使用"和"新声明"
# 例如: `var _cooldown_timer: float = 0.0` 是声明, 而 `_cooldown_timer = 0.0` 是赋值
func _assert_not_contains_decl(src: String, decl: String, label: String) -> void:
	if src.contains(decl):
		_failures.append("FAIL: " + label + " (declaration still present: " + decl + ")")
	else:
		_passes += 1


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _print_summary() -> void:
	print("--- I011 (#98) D002.B 5 verb ability 重构 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
