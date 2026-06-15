extends Node

# Enhanced Audio Manager for Voxglass
# Provides placeholder SFX using procedural audio generation
# Plus procedural BGM themes (T062) — melancholic ambient pads with bell arpeggios.
#
# T121 #63 — BGM preset data (9 entries) and boss tier table
# (3 entries) extracted to `src/scripts/audio_presets.gd` (pure
# data, no methods) so this file stays focused on synthesis +
# state management.  Loaded below as a `const` (compile-time
# preload), then read as `AudioPresets.MUSIC_PRESETS` and
# `AudioPresets.BOSS_MUSIC_TIER` throughout this file.

const AudioPresets = preload("res://src/scripts/audio_presets.gd")

var _sfx_bus: int = 0
var _music_bus: int = 0
var _ambience_bus: int = 0

# Cached procedural streams
var _pulse_stream: AudioStreamWAV
var _footstep_stream: AudioStreamWAV
var _glass_break_stream: AudioStreamWAV
var _enemy_hum_stream: AudioStreamWAV
var _repair_stream: AudioStreamWAV
# F004.B (#96) — 4 verb fire SFX streams (Bind / Cut / Echo / Wave).
# Lazy-initialised in their respective play_*() functions so _ready()
# stays cheap; the SFX are rare compared to footsteps/damage.  Cached
# after first play so subsequent calls reuse the synthesised stream.
# Each verb matches the visual motif of its windup VFX (Bind 螺旋 /
# Cut 斩 / Echo 撑 / Wave 涟漪) so the audio + visual tell are
# 1-shot cognitively.  See _generate_bind_sfx / _generate_cut_sfx /
# _generate_echo_sfx / _generate_wave_fire_sfx for timbre design.
var _bind_stream: AudioStreamWAV
var _cut_stream: AudioStreamWAV
var _echo_stream: AudioStreamWAV
var _wave_fire_stream: AudioStreamWAV
# T141 (#75) — Wave 命中 soft chime.  Cached on first play so we don't
# re-synthesise the 0.20s waveform on every hit.  Distinct from
# glass_break (noisy) — this is a clean high-frequency bell ping.
# T144 (#78) — Per wave_focus perk level (0-3) we keep 4 distinct
# streams in `_wave_hit_streams` keyed by int level.  Each level adds
# one higher harmonic on top of the base 1320Hz fundamental + 2.4x,
# so the player can *hear* the Wave radius grow (visual radius +
# 10/stack) as aural brightness +1 octave / stack.  Level 0 keeps
# the T141 signature (back-compat for saves / pre-T144 audio code).
var _wave_hit_streams: Dictionary = {}
# Minimum interval (s) between two wave_hit plays.  Prevents the
# SFX from stacking when wave hits 3-5 enemies in the same frame
# (the wave is AOE so a single cast can fan out across many targets).
const _WAVE_HIT_THROTTLE := 0.05
var _last_wave_hit_time_ms: int = -1

# T148 (#78) — Wave-combo "big AOE" chime tail.  Distinct from
# per-hit ping — fires once on a wave_combo (>=3 hits in a single
# cast, threshold defined in resonance_wave_ability.gd). 0.6s
# E6 + G#6 tritone (a small-major-third pair — not the harsh
# tritone we used for archive_storm, but a *sweeter* major-third
# stacked 6ths — gives "hero beat" rather than "danger beat")
# with a 0.6s decay envelope so the screen flash + this chime
# read as one event. Cached on first play (rare event, lazy
# init keeps _ready() cheap).
var _wave_combo_stream: AudioStreamWAV

# T153 (#79) — 存档槽位 jingle 区分。每个存档槽位 (0-4) 关联一个
# 上行 3 度五声音阶 (C5/E5/G5/C6/E6) 短 bell 音，让玩家在
# SaveLoadMenu 选择槽位时"听得出选的是哪个"。缓存按 slot_id
# 索引，因为每个槽位 jingle 都会在 save/load 时播放一次。
# 设计哲学：与存档槽位 1:1 映射，未来若加 slot 5+ 仍走
# 五声音阶上行模式（不会撞色也不会撞音）。amplitude 较低
# (0.10) 让 jingle 不抢 BGM / SFX 风头，0.25s 短促清晰。
const _SAVE_SLOT_MIDI_NOTES := [72, 76, 79, 84, 88]  # C5 / E5 / G5 / C6 / E6
var _save_slot_streams: Dictionary = {}

# Cached BGM streams (T062)
var _music_streams: Dictionary = {}
var _current_music_player: AudioStreamPlayer = null
var _current_music_key: String = ""

# T071 — Boss music override.  When non-empty, all play_music_track()
# calls are redirected to this key (transparently overriding the GFC
# state-machine routing).  Cleared by release_boss_music().
var _boss_override_key: String = ""
# Ref-count for active boss overrides (T067 — multiple bosses in
# the same room, e.g. archive_04 with 2 InkWardens).  Override
# stays active until count drops back to 0.
var _boss_override_count: int = 0

# Music presets: each track is a melancholic ambient pad + bell arpeggio + glass shimmer.
# MIDI numbers — A4 = 69, C4 = 60.  Chord = 3-note triad around root.
# Frequencies are derived via 440 * 2^((midi-69)/12).
#
# T121 #63 — 9 presets moved to `audio_presets.gd` (see AudioPresets
# const above).  Per-preset design notes (tempo, key, dissonance,
# volume ratios, LFO design philosophy) preserved verbatim in that
# file as long-form comments.  Code below reads them as
# `AudioPresets.MUSIC_PRESETS` and `AudioPresets.BOSS_MUSIC_TIER`.

func _ready() -> void:
	_setup_buses()
	_generate_placeholder_sfx()

func _setup_buses() -> void:
	_sfx_bus = AudioServer.get_bus_index("SFX")
	if _sfx_bus == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		_sfx_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_sfx_bus, "SFX")
	
	_music_bus = AudioServer.get_bus_index("Music")
	if _music_bus == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		_music_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_music_bus, "Music")
	
	_ambience_bus = AudioServer.get_bus_index("Ambience")
	if _ambience_bus == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		_ambience_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_ambience_bus, "Ambience")

func _generate_placeholder_sfx() -> void:
	_pulse_stream = _generate_pulse_sfx()
	_footstep_stream = _generate_footstep_sfx()
	_glass_break_stream = _generate_glass_break_sfx()
	_enemy_hum_stream = _generate_enemy_hum_sfx()
	_repair_stream = _generate_repair_sfx()
	# F004.B (#96) — 4 verb fire SFX streams are lazy-initialised in their
	# respective play_*() functions to keep _ready() cheap.  Each verb
	# gets its own timbre matching its visual motif:
	#   Bind = 220Hz low drone pull-in (0.40s, matches Bind 0.10s windup)
	#   Cut  = 1500Hz sharp slash (0.08s, matches Cut 0.04s windup)
	#   Echo = 1320Hz glass shield ping (0.15s, matches Echo 0.08s windup)
	#   Wave = 100Hz low bloom (0.30s, matches Wave 0.10s windup)
	# see play_bind() / play_cut() / play_echo() / play_wave_fire() below.
	# T141 (#75) — Wave hit chime (lazy-initialised in play_wave_hit()
	# to keep _ready() cheap; the sfx is rare compared to footsteps).

func _generate_pulse_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.3
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 440.0 * (1.0 + t * 2.0)  # Rising frequency
		var env := exp(-t * 8.0)  # Exponential decay
		var sample := sin(t * TAU * freq) * env * 0.3
		# Add harmonic
		sample += sin(t * TAU * freq * 2.5) * env * 0.15
		# Convert to 16-bit
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Bind fire SFX.
# Design: low 220Hz drone (E3) with descending pitch sweep (220→165Hz)
# over 0.40s, paired with a 2x soft harmonic.  The descending sweep
# reads as "pulling something toward you" — matching the Bind 螺旋
# windup VFX's "1.0×→0.85× spiral" contraction visual.  Slow decay
# (exp -4.0) lets the tail blend into the Bind hit chime naturally
# without abrupt cutoff.  Amplitude 0.32 matches the Bind verb's
# "mid-weight" intensity (heavier than Pulse's 0.30, lighter than
# the boss-override finales).  Used by bind_ability.gd when the
# bind_fired signal fires (T181 candidate) to close the 5 verb
# audio family loop (Bind has had play_bind_hit callers for a
# while; this is the missing fire counterpart).
func _generate_bind_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.40
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 220.0 * (1.0 - t * 0.25)  # 220 → 165Hz pull
		var env := exp(-t * 4.0)
		var sample := sin(t * TAU * freq) * env * 0.32
		sample += sin(t * TAU * freq * 2.0) * env * 0.12
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Cut fire SFX.
# Design: sharp 1500Hz transient with quick drop to 800Hz, paired
# with white-noise burst on the first 0.02s.  The "swoosh" feel
# matches the Cut streak windup VFX's "0.0×→1.0× slash" visual
# — a quick bright attack followed by a fast settling.  Very
# short (0.08s) so it doesn't overlap the Cut hit chime (which
# fires ~50ms later when the arc lands).  Amplitude 0.40 (highest
# of the 4 verb fire SFX) because Cut is the most "kinetic" verb
# in the family — the slash has to be heard over Bind/Wave.  Used
# by cut_ability.gd when the cut_fired signal fires.
func _generate_cut_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.08
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 1500.0 * (1.0 - t * 0.5)  # 1500 → 750Hz drop
		var env := exp(-t * 35.0)
		var sample := sin(t * TAU * freq) * env * 0.40
		# First 0.02s: noise burst for "whoosh"
		if t < 0.02:
			sample += randf_range(-1.0, 1.0) * env * 0.20
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Echo fire SFX.
# Design: clean 1320Hz (near E6) bell ping with 1.5x soft harmonic
# and a 0.15s decay.  Reuses the same fundamental as play_wave_hit
# (T141 #75) but with shorter decay — Echo's fire has to feel
# "instant" and "protective" while wave_hit can be longer.  Matches
# the Echo windup VFX's "0.5×→1.0× 球外撑" visual — a single
# rising-timbre note.  Amplitude 0.35 (mid-weight, like Pulse).
# Used by echo_ability.gd when the echo_fired signal fires.
func _generate_echo_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.15
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 18.0)
		var sample := sin(t * TAU * 1320.0) * env * 0.35
		sample += sin(t * TAU * 1320.0 * 1.5) * env * 0.12
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Wave fire SFX.
# Design: low 100Hz (G2) bloom with a 220Hz perfect-fifth (B2)
# layered on top, slow decay (exp -3.0) over 0.30s.  The "wide
# low rumble + soft mid bell" timbre matches the Wave windup
# VFX's "3 环 ripple outward" visual — a deep omnidirectional
# wave.  Reuses the same 100/220Hz pairing as intro_ambience
# (T122 #64) for tonal continuity between the title screen
# drone and the Wave fire.  Amplitude 0.28 (lightest of the
# 4 verb fire SFX) because Wave is "soft omnidirectional" —
# the player should *feel* the AOE without it dominating the
# mix.  Used by resonance_wave_ability.gd when wave_fired
# signal fires.
func _generate_wave_fire_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.30
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 3.0)
		var sample := sin(t * TAU * 100.0) * env * 0.28
		sample += sin(t * TAU * 220.0) * env * 0.14
		# Soft 2x harmonic on the low note for "body"
		sample += sin(t * TAU * 200.0) * env * 0.08
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Pulse hit SFX.
# Design: 220Hz low thud with 1.0× exp(-t*22) decay over 0.18s.
# Matches the Pulse fire SFX's "low energy" register (Pulse fire is
# 440→1320Hz rising; Pulse hit drops back to a 220Hz thud for the
# "shockwave landed" moment).  Amplitude 0.30 (mid-weight, matches
# Pulse fire 0.30) so the cast is balanced fire-then-hit volume.
# Called from player.gd._on_pulse_hit when an enemy enters the
# expanding pulse ring.  Throttled by _VERB_HIT_THROTTLE (50ms)
# so a Pulse that hits 4 enemies in 0.05s doesn't stack 4 thuds.
func _generate_pulse_hit_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.18
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 22.0)
		var sample := sin(t * TAU * 220.0) * env * 0.30
		# Soft 2x harmonic for "body"
		sample += sin(t * TAU * 440.0) * env * 0.12
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Bind hit SFX.
# Design: 165Hz low thunk with 1.0× exp(-t*18) decay over 0.22s.
# Matches the Bind fire SFX's 220→165Hz "pull" sweep — the hit
# drops to the *end* of the sweep at 165Hz for the "pulled target
# stuck" moment.  Slightly longer decay (0.22s) than Pulse hit
# (0.18s) because Bind is a "hold" verb (the pull keeps tension
# for ~0.6s in the windup VFX).  Amplitude 0.32 (matches Bind
# fire 0.32).  Called from player.gd._on_bind_hit.  Throttled by
# _VERB_HIT_THROTTLE.
func _generate_bind_hit_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.22
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 18.0)
		var sample := sin(t * TAU * 165.0) * env * 0.32
		# Soft 2x harmonic for "grab" body
		sample += sin(t * TAU * 330.0) * env * 0.10
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Cut hit SFX.
# Design: 2000Hz bright shing with 0.5× fast decay (exp -45, ~22ms
# perceptual "ping").  Matches the Cut fire SFX's 1500→750Hz slash
# — the hit jumps *above* the fire for the "sword landed bright"
# moment, then drops to silence fast (sharp attack, no tail).  The
# short 0.05s duration is intentionally MUCH shorter than Pulse
# (0.18s) or Bind (0.22s) hits because Cut's identity is "kinetic
# slash" — a long tail would feel like a "thump" not a "shing".
# Amplitude 0.38 (high, second only to Cut fire 0.40) so the
# landing reads above Pulse / Bind hits.  Called from
# player.gd._on_cut_hit.  Throttled by _VERB_HIT_THROTTLE.
func _generate_cut_hit_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.05
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 45.0)
		var sample := sin(t * TAU * 2000.0) * env * 0.38
		# 3x harmonic for "bright" timbre
		sample += sin(t * TAU * 6000.0) * env * 0.08
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Echo hit SFX.
# Design: 1980Hz glass tap with 0.5× fast decay (exp -38, ~26ms
# perceptual "tink").  Matches the Echo fire SFX's 1320Hz bell
# ping — the hit jumps *above* the fire for the "shield caught
# a hit" moment, with a very fast decay so it reads as "tap"
# not "ring".  Slightly longer decay than Cut (0.06s vs 0.05s)
# because glass rings longer than steel.  Amplitude 0.30 (mid,
# same as Echo fire 0.35 - 0.05 because the shield-already-popped
# fire volume is "set" — the hit can be slightly quieter).
# Called from player.gd._on_echo_hit.  Throttled by _VERB_HIT_THROTTLE.
func _generate_echo_hit_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.06
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 38.0)
		var sample := sin(t * TAU * 1980.0) * env * 0.30
		# 2.4x harmonic for "glass" timbre (matches T141 wave_hit)
		sample += sin(t * TAU * 1980.0 * 2.4) * env * 0.10
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Verb cooldown "ready" jingle synth.
# Design: short ascending two-note bell (0→0.10s) at the start_midi
# frequency, with a 4-semitone ascent over the duration
# (e.g. A4=440Hz → C5=523Hz).  The two notes are mixed 50/50
# across the duration envelope so the "ascending" feel comes from
# a single sine sweeping up rather than two distinct notes (cleaner
# at 0.10s).  exp(-t*15) envelope (0.10s perceptual).  Amplitude
# 0.18 — the jingle is the quietest of the 5-verb family because
# it's a "status" cue, not a "moment" cue (fire=0.30-0.40, hit=
# 0.30-0.38, jingle=0.18).  All 5 verbs share the same synth —
# only start_midi differs (see _verb_cooldown_start_midi).
func _generate_verb_cooldown_jingle(start_midi: int) -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.10
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# A4=69.  midi → Hz: f = 440 * 2^((midi-69)/12)
	var f0: float = 440.0 * pow(2.0, float(start_midi - 69) / 12.0)
	var f1: float = 440.0 * pow(2.0, float(start_midi - 69 + 4) / 12.0)  # 4 semitones up
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Linear frequency ramp f0 → f1 across the duration
		var freq: float = f0 + (f1 - f0) * (t / duration)
		var env := exp(-t * 15.0)
		var sample := sin(t * TAU * freq) * env * 0.18
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_footstep_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.15
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var noise := randf_range(-1.0, 1.0)
		var env := exp(-t * 20.0)
		var sample := noise * env * 0.15
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_glass_break_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.5
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var noise := randf_range(-1.0, 1.0)
		var env := exp(-t * 6.0)
		# High-frequency content for glass
		var ring := sin(t * TAU * 2000.0) * exp(-t * 15.0) * 0.2
		var sample := (noise * 0.3 + ring) * env * 0.25
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T141 (#75) — Wave hit "soft chime" SFX.
# Design: a clean high-frequency bell ping (~1320Hz fundamental, near E6)
# with a 2.4x harmonic, exponential decay over 0.20s.  Distinct from
# glass_break (which is noisy + 0.5s + 2000Hz ring) — this is a short
# "tink" that says "the wave touched a target" without dominating the
# mix.  Paired with the VFX hit_flash (Warm Parchment circle) so the
# player gets a matched visual + audio beat on every wave hit.
func _generate_wave_hit_sfx(perk_level: int = 0) -> AudioStreamWAV:
	# T144 (#78) — `perk_level` 0..3 maps to wave_focus purchase count.
	# Higher levels add one extra high harmonic on top of the base
	# fundamental + 2.4x pair, so each perk-stack sounds "brighter".
	#   level 0 (no perk) — 1320Hz + 2.4x (T141 baseline)
	#   level 1 — + 3.6x (perfect 5th above 2.4x)
	#   level 2 — + 5.0x (major 6th above 3.6x, ringing "big bell")
	#   level 3 — + 6.8x (minor 7th above 5.0x, "triumph" — almost bell-tower)
	# All harmonics decay at the same exp(-t * 14) envelope so they
	# remain in the same 0.20s window.  Clamp perk_level to [0, 3] to
	# be safe against any caller passing a value outside the buyable
	# range (max_purchases = 3 in shop_catalog.json).
	var safe_level: int = clampi(perk_level, 0, 3)
	var sample_rate := 44100
	var duration := 0.20
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 14.0)
		# Fundamental + 2.4x harmonic — detuned harmonic gives a
		# "metallic but soft" bell timbre (pure 2.0x would be octave-only
		# and feel "blunt"; 2.4x is a small-major-third above the octave
		# and adds the glassy shimmer without harshness).
		var fundamental := sin(t * TAU * 1320.0) * 0.45
		var harmonic := sin(t * TAU * 1320.0 * 2.4) * 0.15
		# Per-level extra high harmonics (T144).  Each added with
		# decreasing amplitude so they don't clip or dominate the base.
		var extra: float = 0.0
		match safe_level:
			1:
				extra = sin(t * TAU * 1320.0 * 3.6) * 0.10
			2:
				extra = sin(t * TAU * 1320.0 * 3.6) * 0.10 \
						+ sin(t * TAU * 1320.0 * 5.0) * 0.07
			3:
				extra = sin(t * TAU * 1320.0 * 3.6) * 0.10 \
						+ sin(t * TAU * 1320.0 * 5.0) * 0.07 \
						+ sin(t * TAU * 1320.0 * 6.8) * 0.05
		var sample := (fundamental + harmonic + extra) * env * 0.35
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T148 (#78) — Wave-combo tail chime.
# 0.6s decay envelope on a stacked-6th pair (E6 ≈ 1318.5Hz + G#6 ≈ 1661.2Hz
# — minor-3rd, NOT the harsh tritone used in archive_storm).  The chord
# is the "triumph" interval: evokes "the wave did something big".  The
# 0.6s duration matches ScreenShake.flash_color(0.18s) + the 0.4s shake
# roughly, so the audio + visual + tactile feedback are temporally
# aligned (the chime tail outlasts the flash, reinforcing the event).
# 0.15 amplitude (lower than per-hit 0.35) so a 0.4s long tone doesn't
# dominate over the BGM (the wave_combo is meant to be a *complement*
# to the Electric Violet flash, not a standalone fanfare).
func _generate_wave_combo_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.60
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Slower decay than per-hit (0.20s * 14 = 2.8), so the
		# 0.6s tail is fully audible but fades by t=0.5s.
		var env := exp(-t * 6.0)
		# E6 (1318.5Hz ≈ 1320Hz round) + G#6 (1661.2Hz) — minor 3rd.
		# Slight 0.5Hz LFO detune on the upper voice for "swell" feel.
		var lo := sin(t * TAU * 1318.5) * 0.5
		var hi := sin(t * TAU * (1661.2 + sin(t * 0.5) * 0.5)) * 0.4
		# 1.5x soft harmonic on the lo voice for the "bell body".
		var body := sin(t * TAU * 1318.5 * 1.5) * 0.2
		var sample := (lo + hi + body) * env * 0.35
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T153 (#79) — 生成存档槽位 jingle。每个 slot_id 对应一个 C5/E5/G5/
# C6/E6 上行 3 度五声音阶 (pentatonic 跳过 D/F/A/B 形成"无半音
# 张力"的愉快听感) 短 bell 音。基础公式: 0.25s 三角波 + 1.5x
# soft harmonic 制造 "bell body" + exp decay 0.5s 让尾音不抢。
# amplitude 0.10 — 比 per-hit wave (0.35) 弱，比 footstep (0.04)
# 强；定位是"按钮反馈"级：明显但不喧宾夺主。
# slot_id 超出 [0, 4] 范围时回退到 C5 (slot 0) — 防御性默认，
# 不抛错（因为槽位选择是高频 UI 事件，不能因为 jingle 失败
# 阻断玩家的 save/load 流程）。
func _generate_save_slot_jingle(slot_id: int) -> AudioStreamWAV:
	var sample_rate := 22050  # jingle 不需要 full 44.1k
	var duration := 0.25
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# Clamp slot_id 到 [0, 4]；越界回退到 slot 0
	var idx: int = slot_id
	if idx < 0 or idx >= _SAVE_SLOT_MIDI_NOTES.size():
		idx = 0
	var midi: int = _SAVE_SLOT_MIDI_NOTES[idx]
	var freq: float = _midi_to_hz(midi)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Bell body: fundamental + 1.5x soft harmonic
		var env := exp(-t * 8.0)  # ~0.5s decay
		# 三角波比纯正弦更"亮"，但比方波柔和；用 sin + sin(x/2)
		# 近似三角波
		var fundamental: float = sin(t * TAU * freq)
		var triangle: float = (2.0 / PI) * asin(clampf(fundamental, -1.0, 1.0))
		var body: float = sin(t * TAU * freq * 1.5) * 0.4
		var sample: float = (triangle * 0.6 + body) * env * 0.10
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_enemy_hum_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 1.0
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 80.0 + sin(t * 2.0) * 10.0  # Subtle modulation
		var sample := sin(t * TAU * freq) * 0.08
		sample += sin(t * TAU * freq * 1.5) * 0.04
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.data = data
	return stream

func _generate_repair_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.6
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 660.0 * (1.0 - t * 0.3)  # Falling pitch for "resolution"
		var env := exp(-t * 4.0)
		var sample := sin(t * TAU * freq) * env * 0.2
		sample += sin(t * TAU * freq * 1.5) * env * 0.1
		# Add sparkle
		if t > 0.1 and t < 0.4:
			sample += sin(t * TAU * 3000.0) * exp(-(t - 0.25) * 20.0) * 0.05
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_damage_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.25
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var noise := randf_range(-1.0, 1.0)
		var env := exp(-t * 12.0)
		# Low thud + sharp noise burst
		var thud := sin(t * TAU * 120.0) * exp(-t * 8.0) * 0.3
		var sample := (noise * 0.4 + thud) * env * 0.3
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# Public API

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(stream: AudioStream) -> void:
	var existing := get_node_or_null("MusicPlayer") as AudioStreamPlayer
	if existing:
		existing.stop()
		existing.queue_free()
	var player := AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	player.stream = stream
	player.bus = "Music"
	add_child(player)
	player.play()

func play_pulse() -> void:
	if _pulse_stream:
		play_sfx(_pulse_stream)

# F004.B (#96) — 4 verb fire SFX public play_*() API.  Each lazy-
# generates the stream on first call (cached after that) so _ready()
# stays cheap and the audio synth happens only when the verb is
# actually used.  Future 6th verb access pattern: add a `_xxx_stream`
# field + `_generate_xxx_sfx()` + `play_xxx()` here; the bind_ability
# / cut_ability / echo_ability / resonance_wave_ability fire signal
# handlers are the call sites.  T181 candidate closes the loop by
# adding the actual `AudioManagerEnhanced.play_bind()` etc. callers
# in each ability's _execute_*() method (parallel to the F004 #94
# Pulse caller that landed in pulse_ability.gd).
func play_bind() -> void:
	if _bind_stream == null:
		_bind_stream = _generate_bind_sfx()
	if _bind_stream:
		play_sfx(_bind_stream)

func play_cut() -> void:
	if _cut_stream == null:
		_cut_stream = _generate_cut_sfx()
	if _cut_stream:
		play_sfx(_cut_stream)

func play_echo() -> void:
	if _echo_stream == null:
		_echo_stream = _generate_echo_sfx()
	if _echo_stream:
		play_sfx(_echo_stream)

func play_wave_fire() -> void:
	if _wave_fire_stream == null:
		_wave_fire_stream = _generate_wave_fire_sfx()
	if _wave_fire_stream:
		play_sfx(_wave_fire_stream)

func play_footstep() -> void:
	if _footstep_stream:
		play_sfx(_footstep_stream)

func play_glass_break() -> void:
	if _glass_break_stream:
		play_sfx(_glass_break_stream)

# T141 (#75) — Wave hit soft chime with throttle.
# Lazy-generates the stream on first call (kept out of _ready() so the
# initial audio setup stays cheap; the wave hit SFX is rare compared
# to footsteps/damage).  The 50ms throttle prevents SFX stacking
# when the wave's AOE hits 3-5 enemies in the same frame — without
# it, a 5-enemy wave would fire 5 overlapping chimes that smear into
# a 0.20s mush.  Time is taken from Time.get_ticks_msec() which is
# monotonic; the initial -1 sentinel guarantees the first hit always
# plays.
#
# T144 (#78) — The selected stream depends on the player's current
# `wave_focus` perk count (read from GameState at call time, NOT
# cached, so purchasing a perk mid-game is immediately reflected).
# The lookup is `O(1)` via the `_wave_hit_streams` dict; if the level
# was never played, we synthesise + cache it on the first call.  This
# keeps memory bounded: max 4 cached streams of 17640 bytes each
# (~70KB) regardless of how many wave hits happen during a session.
func play_wave_hit() -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_wave_hit_time_ms >= 0 \
			and now_ms - _last_wave_hit_time_ms < int(_WAVE_HIT_THROTTLE * 1000.0):
		return
	# T144 — Read current wave_focus perk level (0..3) so the SFX
	# timbre matches the visible Wave radius.  Guarded with has_method
	# for headless test contexts (GameState autoload may not be ready).
	var perk_level: int = 0
	if GameState and GameState.has_method("get_perk_count"):
		perk_level = clampi(int(GameState.get_perk_count("wave_focus")), 0, 3)
	if not _wave_hit_streams.has(perk_level):
		_wave_hit_streams[perk_level] = _generate_wave_hit_sfx(perk_level)
	var stream: AudioStreamWAV = _wave_hit_streams.get(perk_level)
	if stream:
		play_sfx(stream)
		_last_wave_hit_time_ms = now_ms

# T181 (#97 first half) — 4 verb hit chime streams (Pulse / Bind / Cut / Echo).
# Wave already has its own play_wave_hit() (T141 #75) above — this
# adds the missing 4 (Pulse coral thud, Bind violet thunk, Cut amber
# shing, Echo cyan ping).  Each hit chime is THROTTLED at 50ms
# (mirrors the wave_hit throttle rationale: a single cast that hits
# 3-5 enemies should not stack 5 overlapping chimes into a 0.20s mush).
# Each hit SFX is THEME-DERIVED from the corresponding fire SFX so the
# cast tells a "fire → hit" two-note story:
#   - Pulse: 220Hz low thud (1.0×) — the "shockwave landed"
#   - Bind:  165Hz low thunk (1.0×) — the "pulled target stuck"
#   - Cut:   2000Hz bright shing (0.5× fast decay) — the "sword landed"
#   - Echo:  1980Hz glass tap (0.5× fast decay) — the "shield caught a hit"
# The 5 verb hit family pairs with the 5 verb fire family
# (play_pulse / play_bind / play_cut / play_echo / play_wave_fire)
# to give every cast a complete "fire → hit" two-beat audio loop.
var _pulse_hit_stream: AudioStreamWAV
var _bind_hit_stream: AudioStreamWAV
var _cut_hit_stream: AudioStreamWAV
var _echo_hit_stream: AudioStreamWAV
const _VERB_HIT_THROTTLE := 0.05  # seconds (matches _WAVE_HIT_THROTTLE)
var _last_verb_hit_time_ms: int = -1

func play_pulse_hit() -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	if _pulse_hit_stream == null:
		_pulse_hit_stream = _generate_pulse_hit_sfx()
	if _pulse_hit_stream:
		play_sfx(_pulse_hit_stream)
		_last_verb_hit_time_ms = now_ms

func play_bind_hit() -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	if _bind_hit_stream == null:
		_bind_hit_stream = _generate_bind_hit_sfx()
	if _bind_hit_stream:
		play_sfx(_bind_hit_stream)
		_last_verb_hit_time_ms = now_ms

func play_cut_hit() -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	if _cut_hit_stream == null:
		_cut_hit_stream = _generate_cut_hit_sfx()
	if _cut_hit_stream:
		play_sfx(_cut_hit_stream)
		_last_verb_hit_time_ms = now_ms

func play_echo_hit() -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	if _echo_hit_stream == null:
		_echo_hit_stream = _generate_echo_hit_sfx()
	if _echo_hit_stream:
		play_sfx(_echo_hit_stream)
		_last_verb_hit_time_ms = now_ms

# T181 (#97 first half) — 5 verb cooldown "ready" jingle.
# When a verb's cooldown finishes, the player needs a discrete audio
# cue so they can re-engage the chain without staring at the HUD.
# The 5 jingles are pentatonic and color-coded to match the verb
# theme (Coral Pulse / Muted Violet / Amber Voice / Glass Cyan /
# Pale Resonance) so the *pitch contour* is a secondary tell:
#   - Pulse: A4 → C5 (ascending major-3rd, "available now")
#   - Bind:  C5 → E5 (ascending major-3rd, "ready to pull")
#   - Cut:   E5 → G5 (ascending minor-3rd, "ready to slash")
#   - Echo:  G5 → A5 (ascending major-2nd, "ready to shield")
#   - Wave:  A5 → C6 (ascending major-3rd, "ready to bloom")
# All 5 share the same 0.10s duration + exp(-t*15) envelope so the
# family reads as one "verb ready" pattern.  Amplitude 0.18 (lowest
# of the 5-verb family) so the jingle never fights BGM / SFX.
var _verb_cooldown_streams: Dictionary = {}

func play_verb_cooldown_ready(verb_name: String) -> void:
	# Map verb name → MIDI start note (5 ascending pentatonic-ish
	# starting pitches, each exactly a major 3rd above the previous
	# so the 5 jingles spread across 1.5 octaves with no clashing
	# semitones).  See comment above the _verb_cooldown_streams
	# field for the pitch-per-verb rationale.
	var start_midi: int = _verb_cooldown_start_midi(verb_name)
	if start_midi < 0:
		return  # Unknown verb — silently no-op (future-proof for verb 6+)
	if not _verb_cooldown_streams.has(verb_name):
		_verb_cooldown_streams[verb_name] = _generate_verb_cooldown_jingle(start_midi)
	var stream: AudioStreamWAV = _verb_cooldown_streams.get(verb_name)
	if stream:
		play_sfx(stream)

func _verb_cooldown_start_midi(verb_name: String) -> int:
	# A4=69, C5=72, E5=76, G5=79, A5=81, C6=84
	match verb_name:
		"pulse": return 69  # A4 → C5 (ascending major-3rd)
		"bind":  return 72  # C5 → E5 (ascending major-3rd)
		"cut":   return 76  # E5 → G5 (ascending minor-3rd)
		"echo":  return 79  # G5 → A5 (ascending major-2nd)
		"wave":  return 81  # A5 → C6 (ascending major-3rd)
		_:       return -1  # Unknown verb — no-op

# T148 (#78) — Wave-combo tail chime (fires once per combo event).
# Lazy-cached on first call.  Called from player.gd._on_wave_combo
# right after the ScreenShake.shake + flash_color so the audio
# reinforces the visual event.  No throttle — a wave_combo is a
# rare event (>=3 hits in a single cast) and we *want* it to be
# distinct from the per-hit pings.
func play_wave_combo() -> void:
	if _wave_combo_stream == null:
		_wave_combo_stream = _generate_wave_combo_sfx()
	if _wave_combo_stream:
		play_sfx(_wave_combo_stream)

# T153 (#79) — 公开播放存档槽位 jingle。SaveLoadMenu 在
# _on_overwrite / _on_load 时按 slot_id 调用。第一次播放生成
# 并缓存 stream（_save_slot_streams），后续直接复用——避免
# 每次 save/load 都重做 0.25s 波形合成。slot_id 越界在
# _generate_save_slot_jingle 内部被 clamp，不会抛错。
func play_save_slot_jingle(slot_id: int) -> void:
	if not _save_slot_streams.has(slot_id):
		_save_slot_streams[slot_id] = _generate_save_slot_jingle(slot_id)
	var stream: AudioStreamWAV = _save_slot_streams[slot_id]
	if stream:
		play_sfx(stream)

func play_repair() -> void:
	if _repair_stream:
		play_sfx(_repair_stream)

func start_enemy_hum(node: Node) -> AudioStreamPlayer:
	if not _enemy_hum_stream:
		return null
	var player := AudioStreamPlayer.new()
	player.stream = _enemy_hum_stream
	player.bus = "Ambience"
	player.volume_db = -12.0
	node.add_child(player)
	player.play()
	return player

func stop_enemy_hum(player: AudioStreamPlayer) -> void:
	if player:
		player.stop()
		player.queue_free()

func play_damage() -> void:
	var stream := _generate_damage_sfx()
	if stream:
		play_sfx(stream)

# T122 (#64) — Intro cutscene ambient bed.
# Plays an 8-second ultra-quiet dual-sine drone on the Ambience bus so
# the title-screen black-out / text-fade is not silent. Designed to
# sit *under* whatever BGM takes over after the cutscene ends
# (title_intro fades in 1.5s after cutscene_finished), so the
# ambience is a 1-shot that simply dies on its own rather than a
# loop. Two detuned sines (D2 + G2 perfect-5th) at ~0.04 amplitude
# modulated by a 0.15Hz LFO give a "breathing" feel that matches
# the visual fade-in rhythm (the player's eyes expect something
# organic, not silence). Sample rate 22050Hz keeps the synth
# under 1ms on the main thread.
func play_intro_ambience() -> void:
	var stream := _generate_intro_ambience()
	if stream:
		play_sfx(stream, "Ambience")

func _generate_intro_ambience() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 8.0  # matches IntroCutscene TOTAL_DURATION
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# D2 + G2 perfect-5th = D minor opening gesture, no resolution
	var hz_root := 73.42  # D2
	var hz_fifth := 98.00  # G2
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# 0.15Hz LFO = 6.7s breath cycle, mirrors whisper_hollow's
		# "deep quiet" modulation so the cutscene pads feel like
		# the same room the rest of the game lives in.
		var lfo := 0.5 + 0.5 * sin(t * TAU * 0.15)
		var sample := sin(t * TAU * hz_root) * 0.04 * lfo
		sample += sin(t * TAU * hz_fifth) * 0.025 * lfo
		# Subtle second-harmonic gives the drone a tiny bit of "body"
		sample += sin(t * TAU * hz_root * 2.0) * 0.012 * lfo
		sample = clampf(sample, -1.0, 1.0)
		# ~12k headroom = ~ -9 dBFS, well below BGM so the cutscene
		# pad never competes with the upcoming title_intro fade-in.
		var s16 := int(sample * 12000.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

# ============================================================
# Procedural BGM (T062)
# ============================================================
# Three ambient themes synthesized at startup: title_intro / hub_warm /
# archive_exploration. Each is a layered ambient pad:
#   1) Bass drone (root + sub-octave)
#   2) Chord pad (3 sines) modulated by slow LFO
#   3) Bell-like arpeggio (8th notes, exp-decay envelope per note)
#   4) Glass shimmer (high-freq sine with subtle vibrato)
# All loops seamlessly because arp length divides the loop duration.

func _midi_to_hz(midi: int) -> float:
	return 440.0 * pow(2.0, (float(midi) - 69.0) / 12.0)

func _generate_music_track(key: String) -> AudioStreamWAV:
	if not AudioPresets.MUSIC_PRESETS.has(key):
		push_warning("AudioManagerEnhanced: unknown music key '%s'" % key)
		return null
	var preset: Dictionary = AudioPresets.MUSIC_PRESETS[key]
	var sample_rate := 22050  # ambient doesn't need full 44.1k
	var duration: float = preset["duration"]
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	# Precompute frequencies
	var root_hz := _midi_to_hz(preset["root_midi"])
	var chord_hz: Array[float] = []
	for n in preset["chord_midi"]:
		chord_hz.append(_midi_to_hz(n))
	var arp_hz: Array[float] = []
	for n in preset["arp_midi"]:
		arp_hz.append(_midi_to_hz(n))
	var shimmer_hz := _midi_to_hz(preset["shimmer_midi"])

	# Arpeggio timing — 8th notes
	var bpm: float = preset["bpm"]
	var arp_step_dur: float = 60.0 / bpm * 0.5
	var arp_len: int = arp_hz.size()

	var lfo_freq: float = preset["lfo_freq"]
	var lfo_depth: float = preset["lfo_depth"]
	var shimmer_mod: float = preset["shimmer_mod"]
	var arp_vol: float = preset["arp_volume"]
	var pad_vol: float = preset["pad_volume"]
	var bass_vol: float = preset["bass_volume"]
	var shimmer_vol: float = preset["shimmer_volume"]

	# Pre-multiply volume factors for inner loop speed
	var bass_root_vol := bass_vol
	var bass_sub_vol := bass_vol * 0.6

	for i in range(samples):
		var t := float(i) / float(sample_rate)

		# (1) Bass drone — root + sub-octave for body
		var bass := sin(t * TAU * root_hz) * bass_root_vol
		bass += sin(t * TAU * root_hz * 0.5) * bass_sub_vol

		# (2) Chord pad with slow LFO amplitude modulation
		var lfo := 1.0 - lfo_depth + lfo_depth * (0.5 + 0.5 * sin(t * TAU * lfo_freq))
		var pad := 0.0
		for hz in chord_hz:
			pad += sin(t * TAU * hz)
		pad *= pad_vol * lfo

		# (3) Bell arpeggio — 8th note steps with exp-decay envelope.
		# T114 — silence_void sets arp_midi to []; the empty arp case
		# is the natural extension of "no arpeggio" so we just skip
		# the envelope math instead of dividing by zero on
		# arp_idx % 0.
		var arp_note: float = 0.0
		if arp_len > 0:
			var arp_idx := int(t / arp_step_dur) % arp_len
			var arp_t_in_step := fmod(t, arp_step_dur) / arp_step_dur
			var arp_env := exp(-arp_t_in_step * 4.5)
			var arp_f := arp_hz[arp_idx]
			arp_note = sin(t * TAU * arp_f) * arp_env
			# 2x harmonic for bell-like timbre
			arp_note += sin(t * TAU * arp_f * 2.0) * arp_env * 0.35
			arp_note *= arp_vol

		# (4) Glass shimmer — high freq with subtle vibrato + slower LFO
		var shimmer_lfo := 0.5 + 0.5 * sin(t * TAU * (lfo_freq * 1.7))
		var vibrato := sin(t * 6.0) * shimmer_mod
		var shimmer := sin(t * TAU * shimmer_hz * (1.0 + vibrato))
		shimmer *= shimmer_lfo * shimmer_vol

		var sample := bass + pad + arp_note + shimmer
		sample = clampf(sample, -1.0, 1.0)
		# Leave headroom (~85% of int16 range) so mix bus doesn't clip when
		# multiple SFX play over BGM.
		var s16 := int(sample * 28000.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	stream.data = data
	return stream

func _ensure_music_stream(key: String) -> AudioStreamWAV:
	if _music_streams.has(key):
		return _music_streams[key]
	var stream := _generate_music_track(key)
	if stream:
		_music_streams[key] = stream
	return stream

## T066 — Pre-warm all preset streams to AudioStreamWAV cache.
## Call this once at app start (e.g. Title screen _ready) so that the
## first BGM switch after pressing Start incurs zero synthesis latency
## (each track is ~352800 samples = 16s @ 22050Hz, takes ~0.5-1.0s to
## generate on the main thread).  Subsequent calls are O(1) lookups.
##
## Iterates the full AudioPresets.MUSIC_PRESETS dictionary, so the 4 main themes
## (title_intro / hub_warm / archive_exploration / archive_dawn) plus
## the 3 boss variants (archive_boss / archive_boss_dual /
## archive_storm) and the silence_void "absence" theme are all
## cached automatically — no per-key call needed.  As of #61 (T114)
## there are 8 presets.
func prewarm_music_streams() -> void:
	for key in AudioPresets.MUSIC_PRESETS.keys():
		# Ensure each preset is generated and cached.  We don't
		# need the stream back; _ensure_music_stream stores it in
		# _music_streams as a side effect.
		_ensure_music_stream(key)

func play_music_track(key: String, fade_ms: int = 1500) -> void:
	# T071 — Boss override: if a boss theme is active, redirect any
	# non-boss key request (e.g. GFC's play_music_track("archive_exploration"))
	# to the boss track.  This makes the override transparently coexist
	# with the existing state-machine routing.
	if not _boss_override_key.is_empty() and key != _boss_override_key:
		key = _boss_override_key

	# No-op if same track already playing
	if _current_music_key == key and _current_music_player and is_instance_valid(_current_music_player):
		if _current_music_player.playing:
			return

	var stream := _ensure_music_stream(key)
	if not stream:
		return

	var new_player := AudioStreamPlayer.new()
	new_player.name = "MusicPlayer_%s" % key
	new_player.stream = stream
	new_player.bus = "Music"
	# Start silent, tween up to 0 dB
	new_player.volume_db = -80.0
	add_child(new_player)
	new_player.play()

	var fade_sec: float = max(0.05, float(fade_ms) / 1000.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(new_player, "volume_db", 0.0, fade_sec)

	var old_player := _current_music_player
	if old_player and is_instance_valid(old_player):
		tween.tween_property(old_player, "volume_db", -80.0, fade_sec)
		tween.chain().tween_callback(func() -> void:
			if is_instance_valid(old_player):
				old_player.queue_free()
		)

	_current_music_player = new_player
	_current_music_key = key

func stop_music(fade_ms: int = 1000) -> void:
	if not _current_music_player or not is_instance_valid(_current_music_player):
		return
	var old_player := _current_music_player
	var fade_sec: float = max(0.05, float(fade_ms) / 1000.0)
	var tween := create_tween()
	tween.tween_property(old_player, "volume_db", -80.0, fade_sec)
	tween.tween_callback(func() -> void:
		if is_instance_valid(old_player):
			old_player.queue_free()
	)
	_current_music_player = null
	_current_music_key = ""

func get_current_music_key() -> String:
	return _current_music_key

# ============================================================
# T117 — Finale music curve (silence_void → archive_dawn)
# ============================================================
# Auto-stitches the two-stage GAME_OVER_SUCCESS "resolution"
# curve: first silence_void (4s zero-amplitude — "the world
# empties out"), then archive_dawn (12.6s G major swell — "the
# world breathes back in").  Total perceived length: ~4s of
# silence then a slow 2.4s fade-in to archive_dawn.  This
# replaces the previous single-track "play_music_track
# (archive_dawn, 2400)" call in GFC GAME_OVER_SUCCESS, giving
# the success state its own audio signature (vs. GAME_OVER_FAILURE
# which only plays silence_void and never resolves).
#
# The crossfade is implemented as a chained play_music_track
# call driven by a Timer (so that Timer signals survive even
# when the GFC scene tree changes during the same beat).
# Specifically: phase 1 (silence_void, fade_in 0.4s) plays
# immediately, then after silence_void.duration (4.0s) plus
# the fade_in window, the second play_music_track (archive_dawn,
# fade_in 2.4s) fires.
#
# If the player dismisses the GAME_OVER_SUCCESS screen before
# the second phase fires (e.g. they pick "返回 hub"), the GFC
# scene transition will call play_music_track("hub_warm", 1200)
# which short-circuits the finale naturally — the Timer is
# still in flight but its callback will play archive_dawn on
# top of hub_warm for ~2.4s.  This is an acceptable artifact:
# the success fanfare resolving into hub_warm is the same
# semantic as a final fanfare-over-Hub-landing.  We do not
# defensively Timer.stop() because the cost (1-2s of audible
# archive_dawn leaking into hub) is smaller than the cost of
# tracking a "finale cancelled" flag across scene trees.
const FINALE_PHASE1_KEY := "silence_void"
const FINALE_PHASE2_KEY := "archive_dawn"
const FINALE_PHASE1_DURATION := 4.0   # matches silence_void.duration preset
const FINALE_PHASE1_FADE_MS := 400    # 0.4s fade-in to silence
const FINALE_PHASE2_FADE_MS := 2400  # 2.4s slow swell to archive_dawn

func play_music_finale() -> void:
	# T117 — fires the two-stage finale.
	# Step 1: silence_void (4s) with 0.4s fade-in.
	play_music_track(FINALE_PHASE1_KEY, FINALE_PHASE1_FADE_MS)
	# Step 2: schedule archive_dawn to begin after silence_void
	# loop has played out.
	var timer := get_tree().create_timer(FINALE_PHASE1_DURATION)
	timer.timeout.connect(func() -> void:
		# Re-check the world is still alive — if the player
		# already returned to hub/title, the GFC will have
		# routed to hub_warm or title_intro already.  In that
		# case we skip the finale phase 2 to avoid doubling
		# the BGM.  We use a simple heuristic: if the current
		# music key is still silence_void (i.e. we haven't
		# been preempted), play archive_dawn on top.
		if _current_music_key == FINALE_PHASE1_KEY:
			play_music_track(FINALE_PHASE2_KEY, FINALE_PHASE2_FADE_MS)
		# else: GFC has already routed to hub_warm / title_intro
		# during the silence phase; the success fanfare is
		# suppressed to honor the player's "return" choice.
	)

# ============================================================
# T071 — Boss music override
# ============================================================
# Used by elite enemies (InkWarden) to temporarily redirect the
# background music to a more intense variant while they are alive.
# Stacks cleanly with the GFC state-machine routing: the GFC keeps
# calling play_music_track("archive_exploration") as usual, but the
# override transparently swaps the track until the boss is defeated.
#
# Ref-counted (#38 T067) so multiple bosses in the same room
# (e.g. archive_04 with 2 InkWardens) each call request_boss_music()
# on _ready, and the override is only released after the LAST boss
# is purified.  Single request → single release still works.
#
# This pattern is idempotent — multiple request_boss_music() calls
# with the same key are safe (no re-trigger).  release_boss_music()
# restores the previous routing.

## Request a boss music override.  Ref-counted: each call increments
## the override count; the override stays active until an equal
## number of release_boss_music() calls are made.  If already in
## boss mode for the same key, this is a no-op (the existing track
## keeps playing).
##
## T080 — Intensity tier upgrade: if a boss with a HIGHER-tier key
## (e.g. archive_boss_dual = 2) requests while a lower-tier key
## (archive_boss = 1) is active, we upgrade the track with a
## short crossfade.  Lower-tier requests during a higher-tier
## override are pure ref-count bumps (don't downgrade).  Unknown
## keys fall back to no-op with a push_warning.
func request_boss_music(boss_key: String, fade_ms: int = 800) -> void:
	if not AudioPresets.MUSIC_PRESETS.has(boss_key):
		push_warning("AudioManagerEnhanced: unknown boss music key '%s'" % boss_key)
		return
	var new_tier: int = int(AudioPresets.BOSS_MUSIC_TIER.get(boss_key, 0))
	_boss_override_count += 1
	if _boss_override_key == "":
		# First request — start the override and play.
		_boss_override_key = boss_key
		play_music_track(boss_key, fade_ms)
		return
	# Already in boss mode.  Tier upgrade?
	var current_tier: int = int(AudioPresets.BOSS_MUSIC_TIER.get(_boss_override_key, 0))
	if new_tier > current_tier:
		# Switch to the more intense track.  Short crossfade
		# (300ms feels punchy for a mid-fight upgrade).  The
		# ref-count is already bumped above, so the
		# corresponding release won't accidentally clear the
		# override.
		_boss_override_key = boss_key
		play_music_track(boss_key, 300)
		# T165 (#85) — Brief 0.15s Glass Cyan screen flash on tier
		# upgrade so the player gets a clear "music just escalated"
		# cue, not just the audio crossfade.  peak_alpha 0.18 keeps
		# it as a quick vignette — not a full-screen bleach.  Layer
		# 256 is *above* the default 128 used by T097 hit flashes
		# (T163 layer param) so a simultaneous hit + tier-up stays
		# readable: the cyan tier-up vignette sits on top.
		if Engine.has_singleton("ScreenShake") or _has_screen_shake_autoload():
			ScreenShake.flash_color(
				Color("#69C7CE"),  # Glass Cyan per STYLE_GUIDE
				0.15,             # duration (fade-in + fade-out total)
				0.18,             # peak alpha
				256               # flash_layer: above hit-flash 128
			)
	# else: same or lower tier — pure ref bump, do nothing.

## Release the boss music override.  Ref-counted: decrements the
## override count and only clears the override / fades out the
## boss track when the count reaches 0.  Single request → single
## release still works (count goes 0→1 on request, 1→0 on release).
func release_boss_music(fade_ms: int = 1200) -> void:
	if _boss_override_count <= 0:
		return
	_boss_override_count -= 1
	if _boss_override_count > 0:
		# Other bosses still alive — keep boss music going.
		return
	# Last boss defeated — clear override and fade out.
	_boss_override_key = ""
	# If the boss track is still the active music, fade it out.
	# We don't auto-restore archive_exploration because the caller
	# (e.g. InkWarden._purify) usually triggers a room transition
	# whose GFC state change will pick the next track naturally.
	if _current_music_key != "" and _current_music_player and is_instance_valid(_current_music_player):
		stop_music(fade_ms)

## Returns true if a boss music override is currently active.
func is_boss_music_active() -> bool:
	return not _boss_override_key.is_empty()


# T165 (#85) — Defensive autoload probe before calling ScreenShake.  Both
# autoloads are listed in project.godot, so under normal gameplay this
# is always true; the guard exists so smoke tests / headless contexts
# (where the audio manager may be initialised before ScreenShake) can
# call request_boss_music() without crashing on a null reference.
func _has_screen_shake_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("ScreenShake")
