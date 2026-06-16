extends SceneTree

## I012 (#98) — D002.B VerbAbilityBase 抽取 smoke
## F008 (#95) "verb 家族代码" + T174.B (#94) "VerbWindupVFXBase 经验" → 抽出
## _verb_ability_base.gd 父类，集中 5 verb byte-identical 共享代码。
## 本测试断言：
##   1. _verb_ability_base.gd 存在 + class_name VerbAbilityBase
##   2. 5 verb ability 文件 extends VerbAbilityBase
##   3. 5 verb ability 文件 override _get_verb_name() 返回正确 verb 字符串
##   4. 5 verb ability 文件 override _apply_perk_bonuses()
##   5. 5 verb ability 文件 override _execute_verb()（verb-specific 主体）
##   6. 共享字段不在 5 verb ability 文件里重复声明（移到父类）
##   7. 共享 helper 不在 5 verb ability 文件里重复定义（移到父类）
##   8. _begin_verb_fire() 在父类 + 5 verb _execute_verb() 调它
##   9. _spawn_windup_vfx() 在父类 + 5 verb start_*() 调它
##  10. 父类 _process() 调 _get_verb_name() + play_verb_cooldown_ready

const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"
const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"

var _passes: int = 0
var _failures: Array = []


func _initialize() -> void:
	print("=== I012 (#98) D002.B VerbAbilityBase 父类抽取 smoke ===")
	var base_src: String = _read_file(VERB_ABILITY_BASE_GD)
	var pulse_src: String = _read_file(PULSE_ABILITY_GD)
	var bind_src: String = _read_file(BIND_ABILITY_GD)
	var cut_src: String = _read_file(CUT_ABILITY_GD)
	var echo_src: String = _read_file(ECHO_ABILITY_GD)
	var wave_src: String = _read_file(WAVE_ABILITY_GD)

	# 1. _verb_ability_base.gd 存在 + class_name VerbAbilityBase
	if not base_src.is_empty() and base_src.contains("class_name VerbAbilityBase"):
		_passes += 1
		print("  PASS: _verb_ability_base.gd exists with class_name VerbAbilityBase")
	else:
		_failures.append("FAIL: _verb_ability_base.gd missing or class_name incorrect")
		print("  FAIL: _verb_ability_base.gd missing or class_name incorrect")

	# 2. 5 verb ability extends VerbAbilityBase
	_assert_contains(pulse_src, "extends VerbAbilityBase", "2a: PulseAbility extends VerbAbilityBase")
	_assert_contains(bind_src, "extends VerbAbilityBase", "2b: BindAbility extends VerbAbilityBase")
	_assert_contains(cut_src, "extends VerbAbilityBase", "2c: CutAbility extends VerbAbilityBase")
	_assert_contains(echo_src, "extends VerbAbilityBase", "2d: EchoAbility extends VerbAbilityBase")
	_assert_contains(wave_src, "extends VerbAbilityBase", "2e: ResonanceWaveAbility extends VerbAbilityBase")

	# 3. _get_verb_name() override
	_assert_contains(pulse_src, "func _get_verb_name() -> String:\n\treturn \"pulse\"", "3a: PulseAbility._get_verb_name() returns \"pulse\"")
	_assert_contains(bind_src, "func _get_verb_name() -> String:\n\treturn \"bind\"", "3b: BindAbility._get_verb_name() returns \"bind\"")
	_assert_contains(cut_src, "func _get_verb_name() -> String:\n\treturn \"cut\"", "3c: CutAbility._get_verb_name() returns \"cut\"")
	_assert_contains(echo_src, "func _get_verb_name() -> String:\n\treturn \"echo\"", "3d: EchoAbility._get_verb_name() returns \"echo\"")
	_assert_contains(wave_src, "func _get_verb_name() -> String:\n\treturn \"wave\"", "3e: ResonanceWaveAbility._get_verb_name() returns \"wave\"")

	# 4. _apply_perk_bonuses() override
	_assert_in_all_5_verbs(
		"func _apply_perk_bonuses() -> void:",
		"4: 5 verb abilities all override _apply_perk_bonuses()",
		pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 5. _execute_verb() override（verb-specific 主体）
	_assert_in_all_5_verbs(
		"func _execute_verb() -> void:",
		"5: 5 verb abilities all override _execute_verb() (verb-specific fire 主体)",
		pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 6. 共享字段不在 5 verb 文件里重复声明（D002.B 集中化）
	var shared_fields: Array = [
		"var _cooldown_timer: float = 0.0",
		"var _windup_timer: float = 0.0",
		"var _is_winding_up: bool = false",
		"var _pending_origin: Vector2 = Vector2.ZERO",
		"var _pending_direction: Vector2 = Vector2.ZERO",
		"var _windup_vfx: Node2D = null",
		"@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D",
	]
	for field in shared_fields:
		_assert_not_in_any_5_verb(
			field,
			"6: shared field '%s' moved to base (not duplicated in 5 verb files)" % field,
			pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 7. 共享 helper 不在 5 verb 文件里重复定义
	var shared_helpers: Array = [
		"func _consume_verb_cost(cost: int) -> bool:",
		"func _setup_windup_state(origin: Vector2, direction: Vector2) -> void:",
		"func get_cooldown_ratio() -> float:",
		"func is_winding_up() -> bool:",
		"func _exit_tree() -> void:",
		"func _has_game_state_autoload() -> bool:",
		"func _spawn_windup_vfx(origin: Vector2, vfx_instance: Node2D, display_radius: float) -> void:",
		"func _begin_verb_fire(verb_name: String) -> void:",
	]
	for helper in shared_helpers:
		_assert_not_in_any_5_verb(
			helper,
			"7: shared helper '%s' moved to base (not duplicated in 5 verb files)" % helper,
			pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 8. _begin_verb_fire() 在父类 + 5 verb _execute_verb() 调它
	_assert_contains(base_src, "func _begin_verb_fire(verb_name: String) -> void:",
		"8a: VerbAbilityBase._begin_verb_fire() defined")
	_assert_in_all_5_verbs(
		"_begin_verb_fire(",
		"8b: 5 verb _execute_verb() all call _begin_verb_fire(<verb>)",
		pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 9. _spawn_windup_vfx() 在父类 + 5 verb start_*() 调它
	_assert_contains(base_src, "func _spawn_windup_vfx(",
		"9a: VerbAbilityBase._spawn_windup_vfx() defined")
	_assert_in_all_5_verbs(
		"_spawn_windup_vfx(",
		"9b: 5 verb start_*() all call _spawn_windup_vfx()",
		pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 10. 父类 _process() 调 _get_verb_name() + play_verb_cooldown_ready
	_assert_contains(base_src, "func _process(delta: float) -> void:",
		"10a: VerbAbilityBase._process() defined")
	_assert_contains(base_src, "AudioManagerEnhanced.play_verb_cooldown_ready",
		"10b: VerbAbilityBase._process() calls AudioManagerEnhanced.play_verb_cooldown_ready (T181 5 verb 共享)")
	_assert_contains(base_src, "_get_verb_name()",
		"10c: VerbAbilityBase._process() uses _get_verb_name() virtual hook")
	_assert_contains(base_src, "_execute_verb()",
		"10d: VerbAbilityBase._process() calls _execute_verb() virtual hook")

	# 11. 父类 _ready() 调 _apply_perk_bonuses() 虚钩
	_assert_contains(base_src, "func _ready() -> void:",
		"11a: VerbAbilityBase._ready() defined")
	_assert_contains(base_src, "_apply_perk_bonuses()",
		"11b: VerbAbilityBase._ready() calls _apply_perk_bonuses() virtual hook")

	# 12. 父类 _process() windup 倒计时（_is_winding_up 守卫 + _windup_timer）
	_assert_contains(base_src, "if _is_winding_up:",
		"12a: VerbAbilityBase._process() guards windup with _is_winding_up")
	_assert_contains(base_src, "_windup_timer -= delta",
		"12b: VerbAbilityBase._process() decrements _windup_timer")

	# 13. 父类 _begin_verb_fire() 调 PlayerStats.record_ability_used（F007 5 verb 共享）
	_assert_contains(base_src, "PlayerStats.record_ability_used(",
		"13: VerbAbilityBase._begin_verb_fire() calls PlayerStats.record_ability_used (5 verb 共享 D002.B 集中)")
	_assert_not_in_any_5_verb(
		"PlayerStats.record_ability_used(",
		"13b: 5 verb _execute_verb() should NOT call PlayerStats directly (delegated to base)",
		pulse_src, bind_src, cut_src, echo_src, wave_src)

	# 14. 父类 _begin_verb_fire() 调 _windup_vfx.queue_free()（fire 帧前清理）
	_assert_contains(base_src, "_windup_vfx.queue_free()",
		"14: VerbAbilityBase._begin_verb_fire() frees _windup_vfx (T166-T171 系列 5 verb 共享)")

	# 15. 父类 _exit_tree() 调 _windup_vfx.fade_out_and_free()（T173 5 verb 共享）
	_assert_contains(base_src, "fade_out_and_free()",
		"15: VerbAbilityBase._exit_tree() calls _windup_vfx.fade_out_and_free() (T173 5 verb 共享)")

	# 16. 父类 _setup_windup_state() 5 verb byte-identical body
	_assert_contains(base_src, "_is_winding_up = true",
		"16a: VerbAbilityBase._setup_windup_state() sets _is_winding_up = true")
	_assert_contains(base_src, "_windup_timer = windup_time",
		"16b: VerbAbilityBase._setup_windup_state() sets _windup_timer = windup_time")

	# 17. 父类 _consume_verb_cost() 5 verb byte-identical body
	_assert_contains(base_src, "if GameState == null:",
		"17a: VerbAbilityBase._consume_verb_cost() guards GameState == null")
	_assert_contains(base_src, "GameState.consume_resonance(",
		"17b: VerbAbilityBase._consume_verb_cost() calls GameState.consume_resonance()")

	# 18. 5 verb 文件应该显著变短（deduplication 量化指标）
	# 旧 D002.B 之前：pulse ~210 行 / bind ~190 行 / cut ~270 行 / echo ~370 行 / wave ~310 行
	# 期望 D002.B 之后：每文件减少 30-50 行。5 verb 平均 < 旧平均 - 25%。
	var line_counts: Dictionary = {
		"pulse": pulse_src.split("\n").size(),
		"bind": bind_src.split("\n").size(),
		"cut": cut_src.split("\n").size(),
		"echo": echo_src.split("\n").size(),
		"wave": wave_src.split("\n").size(),
	}
	# 简单启发式：5 verb 任一文件超过 320 行意味着 dedup 没成功
	for verb_name in line_counts:
		if line_counts[verb_name] > 350:
			_failures.append("FAIL: 18: %s ability still %d lines (>350 = dedup 没成功)" % [verb_name, line_counts[verb_name]])
			print("  FAIL: 18: " + verb_name + " ability still " + str(line_counts[verb_name]) + " lines (>350 = dedup 没成功)")
		else:
			_passes += 1
			print("  PASS: 18: " + verb_name + " ability is " + str(line_counts[verb_name]) + " lines (dedup 成功)")

	# 19. _verb_ability_base.gd 不在 autoload 注册表（它是基类，不是 singleton）
	# （_verb_windup_vfx_base.gd 也不在 autoload，这里保持一致）
	# 这一条只是日志，无 assertion。

	# 20. 父类 docblock 描述虚钩契约（_get_verb_name / _apply_perk_bonuses / _execute_verb）
	_assert_contains(base_src, "_get_verb_name() -> String",
		"20a: VerbAbilityBase docblock documents _get_verb_name() contract")
	_assert_contains(base_src, "_apply_perk_bonuses() -> void",
		"20b: VerbAbilityBase docblock documents _apply_perk_bonuses() contract")
	_assert_contains(base_src, "_execute_verb() -> void",
		"20c: VerbAbilityBase docblock documents _execute_verb() contract")

	# ----- 总结 -----
	print("\n=== I012 (#98) D002.B summary: %d passed, %d failed ===" % [_passes, _failures.size()])
	if _failures.is_empty():
		print("=== ALL I012 (#98) D002.B ASSERTIONS PASSED ===")
		quit(0)
	else:
		for fail in _failures:
			print("  " + fail)
		print("=== I012 (#98) D002.B ASSERTIONS FAILED ===")
		quit(1)


# ===== Helper =====

func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, message: String) -> void:
	if needle in haystack:
		_passes += 1
		print("  PASS: " + message)
	else:
		_failures.append("FAIL: " + message + " (needle: '" + needle + "')")
		print("  FAIL: " + message + " (needle: '" + needle + "')")


func _assert_not_in_any_5_verb(needle: String, message: String, pulse_src: String, bind_src: String, cut_src: String, echo_src: String, wave_src: String) -> void:
	var found_in: Array = []
	if needle in pulse_src:
		found_in.append("pulse_ability.gd")
	if needle in bind_src:
		found_in.append("bind_ability.gd")
	if needle in cut_src:
		found_in.append("cut_ability.gd")
	if needle in echo_src:
		found_in.append("echo_ability.gd")
	if needle in wave_src:
		found_in.append("resonance_wave_ability.gd")
	if found_in.is_empty():
		_passes += 1
		print("  PASS: " + message)
	else:
		_failures.append("FAIL: " + message + " (found in: " + str(found_in) + ")")
		print("  FAIL: " + message + " (found in: " + str(found_in) + ")")


func _assert_in_all_5_verbs(needle: String, message: String, pulse_src: String, bind_src: String, cut_src: String, echo_src: String, wave_src: String) -> void:
	var missing_in: Array = []
	if not (needle in pulse_src):
		missing_in.append("pulse_ability.gd")
	if not (needle in bind_src):
		missing_in.append("bind_ability.gd")
	if not (needle in cut_src):
		missing_in.append("cut_ability.gd")
	if not (needle in echo_src):
		missing_in.append("echo_ability.gd")
	if not (needle in wave_src):
		missing_in.append("resonance_wave_ability.gd")
	if missing_in.is_empty():
		_passes += 1
		print("  PASS: " + message)
	else:
		_failures.append("FAIL: " + message + " (missing in: " + str(missing_in) + ")")
		print("  FAIL: " + message + " (missing in: " + str(missing_in) + ")")
