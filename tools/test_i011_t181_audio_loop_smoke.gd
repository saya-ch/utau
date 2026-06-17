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
const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"
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
	# (1) 4 个 play_*_hit() public 函数
	_assert_contains(ame_src, "func play_pulse_hit()",
		"T181.HIT.1: AudioManagerEnhanced.play_pulse_hit() declared (Pulse hit 闭环)")
	_assert_contains(ame_src, "func play_bind_hit()",
		"T181.HIT.2: AudioManagerEnhanced.play_bind_hit() declared (Bind hit 闭环)")
	_assert_contains(ame_src, "func play_cut_hit()",
		"T181.HIT.3: AudioManagerEnhanced.play_cut_hit() declared (Cut hit 闭环)")
	_assert_contains(ame_src, "func play_echo_hit()",
		"T181.HIT.4: AudioManagerEnhanced.play_echo_hit() declared (Echo hit 闭环)")
	# (2) 4 个 _generate_*_hit_sfx() 私有合成器
	_assert_contains(ame_src, "func _generate_pulse_hit_sfx()",
		"T181.HIT.5: _generate_pulse_hit_sfx() synth declared")
	_assert_contains(ame_src, "func _generate_bind_hit_sfx()",
		"T181.HIT.6: _generate_bind_hit_sfx() synth declared")
	_assert_contains(ame_src, "func _generate_cut_hit_sfx()",
		"T181.HIT.7: _generate_cut_hit_sfx() synth declared")
	_assert_contains(ame_src, "func _generate_echo_hit_sfx()",
		"T181.HIT.8: _generate_echo_hit_sfx() synth declared")
	# (3) 4 verb 缓存 stream 字段
	_assert_contains(ame_src, "var _pulse_hit_stream: AudioStreamWAV",
		"T181.HIT.9: _pulse_hit_stream cache field declared")
	_assert_contains(ame_src, "var _bind_hit_stream: AudioStreamWAV",
		"T181.HIT.10: _bind_hit_stream cache field declared")
	_assert_contains(ame_src, "var _cut_hit_stream: AudioStreamWAV",
		"T181.HIT.11: _cut_hit_stream cache field declared")
	_assert_contains(ame_src, "var _echo_hit_stream: AudioStreamWAV",
		"T181.HIT.12: _echo_hit_stream cache field declared")
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


# ---------- T181.COOLDOWN — 5 verb 集中化 base 调 play_verb_cooldown_ready(_get_verb_name()) ----------
# D002.B (#98) — 5 verb _process 内联 play_verb_cooldown_ready(<name>) 调用
# 集中到 base (VerbAbilityBase)，由 _get_verb_name() 虚函数提供 verb name。
# 5 verb 子类不再有内联调用，但需提供 _get_verb_name() 返回正确 verb 名。
func _run_t181_cooldown_5_verb_ability_caller_assertions() -> void:
	print("--- T181.COOLDOWN — 5 verb 集中化 (base + _get_verb_name) ---")
	# (1) base 集中调 play_verb_cooldown_ready(_get_verb_name())
	var base_src := _read_file(VERB_ABILITY_BASE_GD)
	_assert_contains(base_src,
		"AudioManagerEnhanced.play_verb_cooldown_ready(_get_verb_name())",
		"T181.COOLDOWN.BASE.1: VerbAbilityBase._process calls play_verb_cooldown_ready(_get_verb_name()) (T181 + D002.B #98 集中)")

	# (2) 5 verb 子类 _get_verb_name 返回对应 verb 名
	_assert_contains(_read_file(PULSE_ABILITY_GD),
		"return \"pulse\"",
		"T181.COOLDOWN.1: PulseAbility._get_verb_name returns \"pulse\" (D002.B #98 集中前移)")
	_assert_contains(_read_file(BIND_ABILITY_GD),
		"return \"bind\"",
		"T181.COOLDOWN.2: BindAbility._get_verb_name returns \"bind\"")
	_assert_contains(_read_file(CUT_ABILITY_GD),
		"return \"cut\"",
		"T181.COOLDOWN.3: CutAbility._get_verb_name returns \"cut\"")
	_assert_contains(_read_file(ECHO_ABILITY_GD),
		"return \"echo\"",
		"T181.COOLDOWN.4: EchoAbility._get_verb_name returns \"echo\"")
	_assert_contains(_read_file(WAVE_ABILITY_GD),
		"return \"wave\"",
		"T181.COOLDOWN.5: ResonanceWaveAbility._get_verb_name returns \"wave\"")

	# (3) 5 verb 子类 _process 不再有内联 play_verb_cooldown_ready(<name>) 调用
	# (D002.B 验证: 5 verb 内联调用已集中到 base)
	_assert_not_contains(_read_file(PULSE_ABILITY_GD),
		"AudioManagerEnhanced.play_verb_cooldown_ready(\"pulse\")",
		"T181.COOLDOWN.NOINLINE.1: PulseAbility has NO inline play_verb_cooldown_ready call (D002.B 集中)")
	_assert_not_contains(_read_file(BIND_ABILITY_GD),
		"AudioManagerEnhanced.play_verb_cooldown_ready(\"bind\")",
		"T181.COOLDOWN.NOINLINE.2: BindAbility has NO inline play_verb_cooldown_ready call")
	_assert_not_contains(_read_file(CUT_ABILITY_GD),
		"AudioManagerEnhanced.play_verb_cooldown_ready(\"cut\")",
		"T181.COOLDOWN.NOINLINE.3: CutAbility has NO inline play_verb_cooldown_ready call")
	_assert_not_contains(_read_file(ECHO_ABILITY_GD),
		"AudioManagerEnhanced.play_verb_cooldown_ready(\"echo\")",
		"T181.COOLDOWN.NOINLINE.4: EchoAbility has NO inline play_verb_cooldown_ready call")
	_assert_not_contains(_read_file(WAVE_ABILITY_GD),
		"AudioManagerEnhanced.play_verb_cooldown_ready(\"wave\")",
		"T181.COOLDOWN.NOINLINE.5: ResonanceWaveAbility has NO inline play_verb_cooldown_ready call")


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


# D002.B (#98) — Inverse of _assert_contains: 5 verb 子类不应再有内联
# play_verb_cooldown_ready(<name>) 调用（已集中到 base）。
func _assert_not_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_failures.append("FAIL: " + label + " (forbidden needle present: " + needle + ")")
	else:
		_passes += 1


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
