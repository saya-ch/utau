extends SceneTree
## I010 (#97) — T181 5 verb 音频家族完整闭环冒烟测试
##
## 覆盖 #97 T181 first half 任务原子化提交:
## - T181.FIRE: 4 verb (Bind/Cut/Echo/Wave) 能力 _execute_*() 调
##              AudioManagerEnhanced.play_bind/play_cut/play_echo/play_wave_fire
##              (Pulse F004 #94 已存在,本轮 4 闭环)
## - T181.HIT:  audio_manager_enhanced.gd 新增 4 verb hit SFX
##              (play_pulse_hit / play_bind_hit / play_cut_hit / play_echo_hit)
##              + 4 _generate_*_hit_sfx() 合成器
## - T181.HIT.CALLER: player.gd _on_*_hit 4 个 handler 调对应 play_*_hit()
## - T181.COOLDOWN: 5 verb _process() 调 play_verb_cooldown_ready(<name>)
##              (跨 >0 → <=0 帧守卫) + audio_manager 5 verb 起始 MIDI 查表
## - T181.JINGLE: _verb_cooldown_start_midi() 5 verb MIDI (Pulse=69/Bind=72/
##              Cut=76/Echo=79/Wave=81) + 未知 verb 静默 no-op
##
## 与 I009 (#94) 模式一致：源码扫描 + 字符串锚定（不实例化 Node2D
## 避免 headless mock tween 边界）。回归保护：5 verb 音频家族闭环
## = fire (5) + hit (5) + cooldown (5) = 15 cue 全部就位。任一 caller
## / SFX 函数被无意识删除或参数漂移都会被这 30+ 项断言抓住。

const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"
const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const PLAYER_GD := "res://src/scripts/player.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I010 (#97) — T181 5 verb 音频家族完整闭环 ===")
	_run_t181_fire_4_verb_caller_assertions()
	_run_t181_hit_4_verb_sfx_assertions()
	_run_t181_hit_4_verb_player_caller_assertions()
	_run_t181_cooldown_5_verb_ability_caller_assertions()
	_run_t181_jingle_audio_manager_assertions()
	_run_t181_docblock_marker_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I010 (#97) T181 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T181.FIRE — 4 verb ability _execute_*() 调 play_<verb>() ----------
func _run_t181_fire_4_verb_caller_assertions() -> void:
	print("--- T181.FIRE — 4 verb ability 音频调用 ---")
	# (1) Bind: _execute_bind() 调 play_bind()
	var bind_src := _read_file(BIND_ABILITY_GD)
	_assert_contains(bind_src, "AudioManagerEnhanced.play_bind()",
		"T181.FIRE.1: BindAbility calls AudioManagerEnhanced.play_bind() (4 verb fire 闭环)")
	_assert_execute_after_emit(bind_src, "_execute_bind()", "bind_fired.emit",
		"AudioManagerEnhanced.play_bind()", "T181.FIRE.2: play_bind() AFTER bind_fired.emit in _execute_bind()")
	# (2) Cut: _execute_cut() 调 play_cut()
	var cut_src := _read_file(CUT_ABILITY_GD)
	_assert_contains(cut_src, "AudioManagerEnhanced.play_cut()",
		"T181.FIRE.3: CutAbility calls AudioManagerEnhanced.play_cut() (4 verb fire 闭环)")
	_assert_execute_after_emit(cut_src, "_execute_cut()", "cut_fired.emit",
		"AudioManagerEnhanced.play_cut()", "T181.FIRE.4: play_cut() AFTER cut_fired.emit in _execute_cut()")
	# (3) Echo: _execute_echo() 调 play_echo()
	var echo_src := _read_file(ECHO_ABILITY_GD)
	_assert_contains(echo_src, "AudioManagerEnhanced.play_echo()",
		"T181.FIRE.5: EchoAbility calls AudioManagerEnhanced.play_echo() (4 verb fire 闭环)")
	_assert_execute_after_emit(echo_src, "_execute_echo()", "echo_fired.emit",
		"AudioManagerEnhanced.play_echo()", "T181.FIRE.6: play_echo() AFTER echo_fired.emit in _execute_echo()")
	# (4) Wave: _execute_wave() 调 play_wave_fire()
	var wave_src := _read_file(WAVE_ABILITY_GD)
	_assert_contains(wave_src, "AudioManagerEnhanced.play_wave_fire()",
		"T181.FIRE.7: ResonanceWaveAbility calls AudioManagerEnhanced.play_wave_fire() (4 verb fire 闭环)")
	_assert_execute_after_emit(wave_src, "_execute_wave()", "wave_fired.emit",
		"AudioManagerEnhanced.play_wave_fire()", "T181.FIRE.8: play_wave_fire() AFTER wave_fired.emit in _execute_wave()")
	# (5) is_instance_valid 守卫: 5 verb 都有(F004 #94 Pulse 已立 pattern, 本轮 4 复制)
	_assert_contains(bind_src, "is_instance_valid(_player)",
		"T181.FIRE.9: BindAbility._execute_bind has is_instance_valid(_player) guard")
	_assert_contains(cut_src, "is_instance_valid(_player)",
		"T181.FIRE.10: CutAbility._execute_cut has is_instance_valid(_player) guard")
	_assert_contains(echo_src, "is_instance_valid(_player)",
		"T181.FIRE.11: EchoAbility._execute_echo has is_instance_valid(_player) guard")
	_assert_contains(wave_src, "is_instance_valid(_player)",
		"T181.FIRE.12: ResonanceWaveAbility._execute_wave has is_instance_valid(_player) guard")


# ---------- T181.HIT — 4 verb hit SFX 函数存在于 audio_manager_enhanced.gd ----------
func _run_t181_hit_4_verb_sfx_assertions() -> void:
	print("--- T181.HIT — 4 verb hit SFX ---")
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	# (1) 4 个 play_*_hit() public 函数 (T181.B #100 — Pulse/Cut/Echo 加了 perk_level 参数)
	_assert_contains(ame_src, "func play_pulse_hit(perk_level: int = 0)",
		"T181.HIT.1: AudioManagerEnhanced.play_pulse_hit(perk_level=0) declared (T181.B perk-level)")
	_assert_contains(ame_src, "func play_bind_hit()",
		"T181.HIT.2: AudioManagerEnhanced.play_bind_hit() declared (Bind 无 perk, signature 保持)")
	_assert_contains(ame_src, "func play_cut_hit(perk_level: int = 0)",
		"T181.HIT.3: AudioManagerEnhanced.play_cut_hit(perk_level=0) declared (T181.B future-proof)")
	_assert_contains(ame_src, "func play_echo_hit(perk_level: int = 0)",
		"T181.HIT.4: AudioManagerEnhanced.play_echo_hit(perk_level=0) declared (T181.B perk-level)")
	# (2) 4 个 _generate_*_hit_sfx() 私有合成器 (T181.B #100 — Pulse/Cut/Echo 加了 perk_level 参数)
	_assert_contains(ame_src, "func _generate_pulse_hit_sfx(perk_level: int = 0)",
		"T181.HIT.5: _generate_pulse_hit_sfx(perk_level=0) synth declared (T181.B)")
	_assert_contains(ame_src, "func _generate_bind_hit_sfx()",
		"T181.HIT.6: _generate_bind_hit_sfx() synth declared (Bind 无 perk 缩放)")
	_assert_contains(ame_src, "func _generate_cut_hit_sfx(perk_level: int = 0)",
		"T181.HIT.7: _generate_cut_hit_sfx(perk_level=0) synth declared (T181.B future-proof)")
	_assert_contains(ame_src, "func _generate_echo_hit_sfx(perk_level: int = 0)",
		"T181.HIT.8: _generate_echo_hit_sfx(perk_level=0) synth declared (T181.B)")
	# (3) 缓存 stream 字段 — T181.B (#100) Pulse/Cut/Echo 改为 per-level Dict, Bind 保持单 stream
	_assert_contains(ame_src, "var _pulse_hit_streams: Dictionary",
		"T181.HIT.9: _pulse_hit_streams dict (T181.B per-level 缓存) declared")
	_assert_contains(ame_src, "var _bind_hit_stream: AudioStreamWAV",
		"T181.HIT.10: _bind_hit_stream single cache field declared (Bind 无 perk 缩放)")
	_assert_contains(ame_src, "var _cut_hit_streams: Dictionary",
		"T181.HIT.11: _cut_hit_streams dict (T181.B per-level 缓存 future-proof) declared")
	_assert_contains(ame_src, "var _echo_hit_streams: Dictionary",
		"T181.HIT.12: _echo_hit_streams dict (T181.B per-level 缓存) declared")
	# (4) 50ms throttle 守卫 (避免多目标 4 hit 堆叠)
	_assert_contains(ame_src, "_VERB_HIT_THROTTLE",
		"T181.HIT.13: _VERB_HIT_THROTTLE constant declared (4 verb hit 50ms 共享节流)")
	_assert_contains(ame_src, "_last_verb_hit_time_ms",
		"T181.HIT.14: _last_verb_hit_time_ms guard field declared (跨帧节流时间戳)")


# ---------- T181.HIT.CALLER — player.gd _on_*_hit 4 个 handler 调对应 play_*_hit() ----------
func _run_t181_hit_4_verb_player_caller_assertions() -> void:
	print("--- T181.HIT.CALLER — player.gd 4 handler 调 play_*_hit() ---")
	var player_src := _read_file(PLAYER_GD)
	_assert_contains(player_src, "AudioManagerEnhanced.play_pulse_hit()",
		"T181.HIT.CALLER.1: player._on_pulse_hit calls AudioManagerEnhanced.play_pulse_hit()")
	_assert_contains(player_src, "AudioManagerEnhanced.play_bind_hit()",
		"T181.HIT.CALLER.2: player._on_bind_hit calls AudioManagerEnhanced.play_bind_hit()")
	_assert_contains(player_src, "AudioManagerEnhanced.play_cut_hit()",
		"T181.HIT.CALLER.3: player._on_cut_hit calls AudioManagerEnhanced.play_cut_hit()")
	_assert_contains(player_src, "AudioManagerEnhanced.play_echo_hit()",
		"T181.HIT.CALLER.4: player._on_echo_hit (reflect path) calls AudioManagerEnhanced.play_echo_hit()")


# ---------- T181.COOLDOWN — 5 verb _process() 调 _process_cooldown(<name>) → base 调 play_verb_cooldown_ready ----------
func _run_t181_cooldown_5_verb_ability_caller_assertions() -> void:
	print("--- T181.COOLDOWN — 5 verb _process() 调 _process_cooldown ---")
	# D002.B (#98) — Cooldown jingle caller moved from each verb's
	# _process body into the shared VerbAbilityBase._process_cooldown.
	# Each subclass now calls _process_cooldown(delta, <name>) from
	# its own _process, and the base internally calls
	# play_verb_cooldown_ready(verb_name).  I011 was written for the
	# pre-#98 layout (subclass direct call) — updated to match the
	# new base-class delegation.
	_assert_contains(_read_file(PULSE_ABILITY_GD),
		"_process_cooldown(delta, \"pulse\")",
		"T181.COOLDOWN.1: PulseAbility._process calls _process_cooldown(\"pulse\") (D002.B base delegation)")
	_assert_contains(_read_file(BIND_ABILITY_GD),
		"_process_cooldown(delta, \"bind\")",
		"T181.COOLDOWN.2: BindAbility._process calls _process_cooldown(\"bind\") (D002.B base delegation)")
	_assert_contains(_read_file(CUT_ABILITY_GD),
		"_process_cooldown(delta, \"cut\")",
		"T181.COOLDOWN.3: CutAbility._process calls _process_cooldown(\"cut\") (D002.B base delegation)")
	_assert_contains(_read_file(ECHO_ABILITY_GD),
		"_process_cooldown(delta, \"echo\")",
		"T181.COOLDOWN.4: EchoAbility._process calls _process_cooldown(\"echo\") (D002.B base delegation)")
	_assert_contains(_read_file(WAVE_ABILITY_GD),
		"_process_cooldown(delta, \"wave\")",
		"T181.COOLDOWN.5: ResonanceWaveAbility._process calls _process_cooldown(\"wave\") (D002.B base delegation)")
	# Base class (_verb_ability_base.gd) delegates the jingle call
	# to AudioManagerEnhanced.play_verb_cooldown_ready(verb_name).
	_assert_contains(_read_file("res://src/scripts/_verb_ability_base.gd"),
		"AudioManagerEnhanced.play_verb_cooldown_ready(verb_name)",
		"T181.COOLDOWN.6: VerbAbilityBase._process_cooldown delegates to AudioManagerEnhanced.play_verb_cooldown_ready(verb_name) (D002.B)")


# ---------- T181.JINGLE — audio_manager 5 verb 起始 MIDI 查表 + 合成 ----------
func _run_t181_jingle_audio_manager_assertions() -> void:
	print("--- T181.JINGLE — audio_manager 5 verb jingle 查表 ---")
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	# (1) play_verb_cooldown_ready + 查表函数
	_assert_contains(ame_src, "func play_verb_cooldown_ready(verb_name: String)",
		"T181.JINGLE.1: play_verb_cooldown_ready(verb_name) public API declared")
	_assert_contains(ame_src, "func _verb_cooldown_start_midi(verb_name: String)",
		"T181.JINGLE.2: _verb_cooldown_start_midi(verb_name) lookup declared")
	# (2) 5 verb 起始 MIDI (Pulse=69/Bind=72/Cut=76/Echo=79/Wave=81)
	_assert_contains(ame_src, "\"pulse\": return 69",
		"T181.JINGLE.3: Pulse 起始 MIDI 69 (A4)")
	_assert_contains(ame_src, "\"bind\":  return 72",
		"T181.JINGLE.4: Bind 起始 MIDI 72 (C5)")
	_assert_contains(ame_src, "\"cut\":   return 76",
		"T181.JINGLE.5: Cut 起始 MIDI 76 (E5)")
	_assert_contains(ame_src, "\"echo\":  return 79",
		"T181.JINGLE.6: Echo 起始 MIDI 79 (G5)")
	_assert_contains(ame_src, "\"wave\":  return 81",
		"T181.JINGLE.7: Wave 起始 MIDI 81 (A5)")
	# (3) 未知 verb 静默 no-op (未来 6th verb 友好)
	_assert_contains(ame_src, "return -1",
		"T181.JINGLE.8: 未知 verb 返回 -1 静默 no-op (6th verb 友好)")
	# (4) jingle 合成器存在
	_assert_contains(ame_src, "func _generate_verb_cooldown_jingle(start_midi: int)",
		"T181.JINGLE.9: _generate_verb_cooldown_jingle(start_midi) synth declared")
	# (5) 缓存 dict
	_assert_contains(ame_src, "var _verb_cooldown_streams: Dictionary",
		"T181.JINGLE.10: _verb_cooldown_streams cache dict declared")


# ---------- T181 docblock 标记 5 源文件 ----------
func _run_t181_docblock_marker_assertions() -> void:
	print("--- T181 docblock attribution marker ---")
	_assert_contains(_read_file(AUDIO_MANAGER_GD), "T181 (#97",
		"T181.MARK.1: T181 (#97) marker in audio_manager_enhanced.gd")
	_assert_contains(_read_file(BIND_ABILITY_GD), "T181 (#97",
		"T181.MARK.2: T181 (#97) marker in bind_ability.gd")
	_assert_contains(_read_file(CUT_ABILITY_GD), "T181 (#97",
		"T181.MARK.3: T181 (#97) marker in cut_ability.gd")
	_assert_contains(_read_file(ECHO_ABILITY_GD), "T181 (#97",
		"T181.MARK.4: T181 (#97) marker in echo_ability.gd")
	_assert_contains(_read_file(WAVE_ABILITY_GD), "T181 (#97",
		"T181.MARK.5: T181 (#97) marker in resonance_wave_ability.gd")
	_assert_contains(_read_file(PLAYER_GD), "T181 (#97",
		"T181.MARK.6: T181 (#97) marker in player.gd")


# ---------- helpers ----------
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _assert_execute_after_emit(src: String, func_needle: String, emit_needle: String, play_needle: String, label: String) -> void:
	var func_idx := src.find(func_needle)
	var emit_idx := src.find(emit_needle)
	var play_idx := src.find(play_needle)
	if func_idx < 0 or emit_idx < 0 or play_idx < 0:
		_failures.append("FAIL: " + label + " (markers missing)")
		return
	# Need: func < emit < play
	if func_idx < emit_idx and emit_idx < play_idx:
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (order wrong: func=" + str(func_idx) + " emit=" + str(emit_idx) + " play=" + str(play_idx) + ")")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _print_summary() -> void:
	print("--- I010 (#97) T181 5 verb 音频家族闭环 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
