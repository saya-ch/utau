extends SceneTree
## I011 (#97) — T181 + D002.B 5 verb 音频家族 + 共享基类三连击冒烟测试
##
## 覆盖 #97 三任务原子化提交:
## - T181:   Audio 5 verb 音频家族完整闭环 12 cue (5 fire + 5 hit + 5 cooldown
##           ready + 2 wave hit 等已有). 5 verb fire caller 接入 5 verb
##           ability._execute_*, 5 verb cooldown ready API + factory
##           + cache field 完整.
## - D002.B: Code 推 VerbWindupVFXBase 经验到 5 verb ability 家族
##           _VerbAbilityBase. 5 verb ability extends VerbAbilityBase,
##           _has_audio_manager_enhanced + _has_game_state_autoload 共享
##           helper 抽到 base, 5 verb 删本地副本.
## - 额外:   5 verb _cooldown_was_active field + _process edge detect
##           5 verb 各就位, 防 cooldown 期间 ready jingle 重复触发
##           (F142 #75 5-verb 链防误触同模式).
##
## 与 I010 (#96) / I009 (#94) / I008 (#93) 模式一致：源码扫描 + 字符串
## 锚定 (不实例化 Node2D / autoload 避免 headless mock 边界). 回归
## 保护: 5 verb 音频家族完整 12 cue + 5 verb 共享基类 _VerbAbilityBase
## 是 5 verb 系统级架构闭环, 任一文件被无意识删除或参数漂移都会被
## 这 30+ 项断言抓住.

const AUDIO_MANAGER_ENHANCED_GD := "res://src/scripts/audio_manager_enhanced.gd"
const VERB_ABILITY_BASE_GD := "res://src/scripts/verb_ability_base.gd"
const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const RESONANCE_WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I011 (#97) — T181 + D002.B 5 verb 音频家族 + 共享基类 ===")
	_run_t181_audio_cooldown_api_assertions()
	_run_t181_audio_cooldown_factory_assertions()
	_run_t181_5_verb_fire_caller_assertions()
	_run_t181_5_verb_cooldown_field_assertions()
	_run_t181_5_verb_cooldown_caller_assertions()
	_run_d002b_verb_ability_base_assertions()
	_run_d002b_5_verb_extends_assertions()
	_run_d002b_5_verb_local_helper_removed_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I011 (#97) T181 + D002.B ASSERTIONS PASSED ===")
		quit(0)


# ---------- T181 — 5 verb cooldown ready API 公开接口 ----------
func _run_t181_audio_cooldown_api_assertions() -> void:
	print("--- T181 — 5 verb cooldown ready API 公开接口 ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	if src.is_empty():
		_failures.append("FAIL: T181: cannot read " + AUDIO_MANAGER_ENHANCED_GD)
		return
	_assert_contains(src, "func play_pulse_cooldown_ready() -> void:",
		"T181.1: play_pulse_cooldown_ready() 公开 API (5 verb cooldown 提示 #1)")
	_assert_contains(src, "func play_bind_cooldown_ready() -> void:",
		"T181.2: play_bind_cooldown_ready() 公开 API (#2)")
	_assert_contains(src, "func play_cut_cooldown_ready() -> void:",
		"T181.3: play_cut_cooldown_ready() 公开 API (#3)")
	_assert_contains(src, "func play_echo_cooldown_ready() -> void:",
		"T181.4: play_echo_cooldown_ready() 公开 API (#4)")
	_assert_contains(src, "func play_wave_cooldown_ready() -> void:",
		"T181.5: play_wave_cooldown_ready() 公开 API (#5)")


# ---------- T181 — 5 verb cooldown ready 工厂函数 ----------
func _run_t181_audio_cooldown_factory_assertions() -> void:
	print("--- T181 — 5 verb cooldown ready 工厂函数 ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	_assert_contains(src, "func _generate_cooldown_sfx(base_freq: float) -> AudioStreamWAV:",
		"T181.6: _generate_cooldown_sfx(base_freq) 工厂函数签名 (5 verb 共用, 频率参数化)")
	_assert_contains(src, "var _pulse_cooldown_stream: AudioStreamWAV",
		"T181.7: _pulse_cooldown_stream 缓存变量 (#1)")
	_assert_contains(src, "var _bind_cooldown_stream: AudioStreamWAV",
		"T181.8: _bind_cooldown_stream 缓存变量 (#2)")
	_assert_contains(src, "var _cut_cooldown_stream: AudioStreamWAV",
		"T181.9: _cut_cooldown_stream 缓存变量 (#3)")
	_assert_contains(src, "var _echo_cooldown_stream: AudioStreamWAV",
		"T181.10: _echo_cooldown_stream 缓存变量 (#4)")
	_assert_contains(src, "var _wave_cooldown_stream: AudioStreamWAV",
		"T181.11: _wave_cooldown_stream 缓存变量 (#5)")


# ---------- T181 — 5 verb fire audio caller 接入 5 verb ability._execute_* ----------
func _run_t181_5_verb_fire_caller_assertions() -> void:
	print("--- T181 — 5 verb fire audio caller 接入 ---")
	# Pulse 已经在 #94 F004 接入, 这里只验证 4 verb 新接入
	var bind_src := _read_file(BIND_ABILITY_GD)
	var cut_src := _read_file(CUT_ABILITY_GD)
	var echo_src := _read_file(ECHO_ABILITY_GD)
	var wave_src := _read_file(RESONANCE_WAVE_ABILITY_GD)
	_assert_contains(bind_src, "AudioManagerEnhanced.play_bind()",
		"T181.12: bind_ability._execute_bind 接入 play_bind() (4 verb #1)")
	_assert_contains(cut_src, "AudioManagerEnhanced.play_cut()",
		"T181.13: cut_ability._execute_cut 接入 play_cut() (#2)")
	_assert_contains(echo_src, "AudioManagerEnhanced.play_echo()",
		"T181.14: echo_ability._execute_echo 接入 play_echo() (#3)")
	_assert_contains(wave_src, "AudioManagerEnhanced.play_wave_fire()",
		"T181.15: resonance_wave_ability._execute_wave 接入 play_wave_fire() (#4)")


# ---------- T181 — 5 verb _cooldown_was_active field ----------
func _run_t181_5_verb_cooldown_field_assertions() -> void:
	print("--- T181 — 5 verb _cooldown_was_active field ---")
	var pulse_src := _read_file(PULSE_ABILITY_GD)
	var bind_src := _read_file(BIND_ABILITY_GD)
	var cut_src := _read_file(CUT_ABILITY_GD)
	var echo_src := _read_file(ECHO_ABILITY_GD)
	var wave_src := _read_file(RESONANCE_WAVE_ABILITY_GD)
	_assert_contains(pulse_src, "var _cooldown_was_active: bool = false",
		"T181.16: pulse_ability._cooldown_was_active 字段 (#94 已就位 #97 复验)")
	_assert_contains(bind_src, "var _cooldown_was_active: bool = false",
		"T181.17: bind_ability._cooldown_was_active 字段 (#97 新增)")
	_assert_contains(cut_src, "var _cooldown_was_active: bool = false",
		"T181.18: cut_ability._cooldown_was_active 字段 (#97 新增)")
	_assert_contains(echo_src, "var _cooldown_was_active: bool = false",
		"T181.19: echo_ability._cooldown_was_active 字段 (#97 新增)")
	_assert_contains(wave_src, "var _cooldown_was_active: bool = false",
		"T181.20: resonance_wave_ability._cooldown_was_active 字段 (#97 新增)")


# ---------- T181 — 5 verb _process edge detect + cooldown ready caller ----------
func _run_t181_5_verb_cooldown_caller_assertions() -> void:
	print("--- T181 — 5 verb _process edge detect + cooldown ready caller ---")
	var pulse_src := _read_file(PULSE_ABILITY_GD)
	var bind_src := _read_file(BIND_ABILITY_GD)
	var cut_src := _read_file(CUT_ABILITY_GD)
	var echo_src := _read_file(ECHO_ABILITY_GD)
	var wave_src := _read_file(RESONANCE_WAVE_ABILITY_GD)
	_assert_contains(pulse_src, "AudioManagerEnhanced.play_pulse_cooldown_ready()",
		"T181.21: pulse_ability _process edge detect 调 play_pulse_cooldown_ready()")
	_assert_contains(bind_src, "AudioManagerEnhanced.play_bind_cooldown_ready()",
		"T181.22: bind_ability _process edge detect 调 play_bind_cooldown_ready()")
	_assert_contains(cut_src, "AudioManagerEnhanced.play_cut_cooldown_ready()",
		"T181.23: cut_ability _process edge detect 调 play_cut_cooldown_ready()")
	_assert_contains(echo_src, "AudioManagerEnhanced.play_echo_cooldown_ready()",
		"T181.24: echo_ability _process edge detect 调 play_echo_cooldown_ready()")
	_assert_contains(wave_src, "AudioManagerEnhanced.play_wave_cooldown_ready()",
		"T181.25: wave_ability _process edge detect 调 play_wave_cooldown_ready()")
	# 5 verb _execute_* 中设 _cooldown_was_active = true
	_assert_contains(bind_src, "_cooldown_was_active = true",
		"T181.26: bind_ability._execute_bind 设 _cooldown_was_active = true")
	_assert_contains(cut_src, "_cooldown_was_active = true",
		"T181.27: cut_ability._execute_cut 设 _cooldown_was_active = true")
	_assert_contains(echo_src, "_cooldown_was_active = true",
		"T181.28: echo_ability._execute_echo 设 _cooldown_was_active = true")
	_assert_contains(wave_src, "_cooldown_was_active = true",
		"T181.29: wave_ability._execute_wave 设 _cooldown_was_active = true")


# ---------- D002.B — verb_ability_base.gd 共享基类 ----------
func _run_d002b_verb_ability_base_assertions() -> void:
	print("--- D002.B — verb_ability_base.gd 共享基类 ---")
	var src := _read_file(VERB_ABILITY_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: D002.B: cannot read " + VERB_ABILITY_BASE_GD)
		return
	_assert_contains(src, "class_name VerbAbilityBase",
		"D002.B.1: VerbAbilityBase class_name 声明 (全局类型, 让 5 verb extends 直接用)")
	_assert_contains(src, "extends Node",
		"D002.B.2: VerbAbilityBase extends Node (5 verb 都 extends Node)")
	_assert_contains(src, "func _has_audio_manager_enhanced() -> bool:",
		"D002.B.3: _has_audio_manager_enhanced() 共享 helper (5 verb 各 1 份重复 → 1 份共享)")
	_assert_contains(src, "func _has_game_state_autoload() -> bool:",
		"D002.B.4: _has_game_state_autoload() 共享 helper (4 verb 各 1 份重复 → 1 份共享)")


# ---------- D002.B — 5 verb ability extends VerbAbilityBase ----------
func _run_d002b_5_verb_extends_assertions() -> void:
	print("--- D002.B — 5 verb ability extends VerbAbilityBase ---")
	var pulse_src := _read_file(PULSE_ABILITY_GD)
	var bind_src := _read_file(BIND_ABILITY_GD)
	var cut_src := _read_file(CUT_ABILITY_GD)
	var echo_src := _read_file(ECHO_ABILITY_GD)
	var wave_src := _read_file(RESONANCE_WAVE_ABILITY_GD)
	_assert_contains(pulse_src, "extends VerbAbilityBase",
		"D002.B.5: pulse_ability extends VerbAbilityBase (基类统一入口)")
	_assert_contains(bind_src, "extends VerbAbilityBase",
		"D002.B.6: bind_ability extends VerbAbilityBase")
	_assert_contains(cut_src, "extends VerbAbilityBase",
		"D002.B.7: cut_ability extends VerbAbilityBase")
	_assert_contains(echo_src, "extends VerbAbilityBase",
		"D002.B.8: echo_ability extends VerbAbilityBase")
	_assert_contains(wave_src, "extends VerbAbilityBase",
		"D002.B.9: resonance_wave_ability extends VerbAbilityBase")


# ---------- D002.B — 5 verb 删除本地 _has_* helper 副本 ----------
func _run_d002b_5_verb_local_helper_removed_assertions() -> void:
	print("--- D002.B — 5 verb 删除本地 _has_* helper 副本 ---")
	# 5 verb 都不应再有 _has_audio_manager_enhanced / _has_game_state_autoload 本地定义
	# 因为已经在 base 里, 子类重复定义会遮盖父类实现并增加维护负担
	# 这里用 "func _has_audio_manager_enhanced" 全局匹配, 排除 verb_ability_base.gd
	_assert_not_contains_in_5_verb(PULSE_ABILITY_GD, "func _has_audio_manager_enhanced",
		"D002.B.10: pulse_ability 已删本地 _has_audio_manager_enhanced 副本 (避免与 base 重复)")
	_assert_not_contains_in_5_verb(BIND_ABILITY_GD, "func _has_audio_manager_enhanced",
		"D002.B.11: bind_ability 已删本地 _has_audio_manager_enhanced 副本")
	_assert_not_contains_in_5_verb(CUT_ABILITY_GD, "func _has_audio_manager_enhanced",
		"D002.B.12: cut_ability 已删本地 _has_audio_manager_enhanced 副本")
	_assert_not_contains_in_5_verb(ECHO_ABILITY_GD, "func _has_audio_manager_enhanced",
		"D002.B.13: echo_ability 已删本地 _has_audio_manager_enhanced 副本")
	_assert_not_contains_in_5_verb(RESONANCE_WAVE_ABILITY_GD, "func _has_audio_manager_enhanced",
		"D002.B.14: wave_ability 已删本地 _has_audio_manager_enhanced 副本")
	_assert_not_contains_in_5_verb(PULSE_ABILITY_GD, "func _has_game_state_autoload",
		"D002.B.15: pulse_ability 已删本地 _has_game_state_autoload 副本")
	_assert_not_contains_in_5_verb(CUT_ABILITY_GD, "func _has_game_state_autoload",
		"D002.B.16: cut_ability 已删本地 _has_game_state_autoload 副本")


# ---------- helpers ----------
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _assert_not_contains_in_5_verb(path: String, needle: String, label: String) -> void:
	var src := _read_file(path)
	if src.contains(needle):
		_failures.append("FAIL: " + label + " (path: " + path + ", needle: " + needle + ")")
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
	print("")
	print("=== I011 (#97) summary: " + str(_passes) + " passed, " + str(_failures.size()) + " failed ===")
	if not _failures.is_empty():
		print("FAILURES:")
		for f in _failures:
			print("  " + f)
