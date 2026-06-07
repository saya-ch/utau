extends Node

# Enhanced Audio Manager for Voxglass
# Provides placeholder SFX using procedural audio generation
# Plus procedural BGM themes (T062) — melancholic ambient pads with bell arpeggios.

var _sfx_bus: int = 0
var _music_bus: int = 0
var _ambience_bus: int = 0

# Cached procedural streams
var _pulse_stream: AudioStreamWAV
var _footstep_stream: AudioStreamWAV
var _glass_break_stream: AudioStreamWAV
var _enemy_hum_stream: AudioStreamWAV
var _repair_stream: AudioStreamWAV

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
# T080 — Boss theme "intensity tier".  Higher tier overrides lower
# tier — if a second boss in the same room requests a more
# intense key, we switch tracks mid-fight.  Tier 0 = "no
# preference", 1 = single boss, 2 = dual boss.  When the last
# boss releases, the tier resets to 0 and the override clears.
const _BOSS_MUSIC_TIER := {
	"archive_boss": 1,
	"archive_boss_dual": 2,
	"archive_storm": 3,
}

# Music presets: each track is a melancholic ambient pad + bell arpeggio + glass shimmer.
# MIDI numbers — A4 = 69, C4 = 60.  Chord = 3-note triad around root.
# Frequencies are derived via 440 * 2^((midi-69)/12).
const _MUSIC_PRESETS := {
	# Title screen / prologue — slow, sparse, hopeful
	"title_intro": {
		"bpm": 60,
		"duration": 16.0,
		"root_midi": 50,           # D3
		"chord_midi": [62, 66, 69],# D4 F#4 A4 (D major)
		"arp_midi": [74, 78, 81, 86, 81, 78, 74, 78], # D5 F#5 A5 D6 (8 notes per loop)
		"shimmer_midi": 93,        # A6
		"lfo_freq": 0.18,
		"lfo_depth": 0.4,
		"shimmer_mod": 0.004,
		"arp_volume": 0.16,
		"pad_volume": 0.05,
		"bass_volume": 0.10,
		"shimmer_volume": 0.025,
	},
	# Hub safe area — warm, brighter, hopeful
	"hub_warm": {
		"bpm": 88,
		"duration": 10.9,          # 16 beats at 88bpm
		"root_midi": 41,           # F2
		"chord_midi": [53, 57, 60],# F3 A3 C4 (F major)
		"arp_midi": [65, 69, 72, 77, 72, 69, 65, 69],
		"shimmer_midi": 84,        # C6
		"lfo_freq": 0.42,
		"lfo_depth": 0.35,
		"shimmer_mod": 0.005,
		"arp_volume": 0.18,
		"pad_volume": 0.06,
		"bass_volume": 0.11,
		"shimmer_volume": 0.028,
	},
	# Archive rooms — melancholic, deeper, A minor
	"archive_exploration": {
		"bpm": 72,
		"duration": 13.3,          # 16 beats at 72bpm
		"root_midi": 45,           # A2
		"chord_midi": [57, 60, 64],# A3 C4 E4 (A minor)
		"arp_midi": [69, 72, 76, 81, 76, 72, 69, 72], # A4 C5 E5 A5
		"shimmer_midi": 88,        # E6
		"lfo_freq": 0.28,
		"lfo_depth": 0.45,
		"shimmer_mod": 0.006,
		"arp_volume": 0.20,
		"pad_volume": 0.07,
		"bass_volume": 0.13,
		"shimmer_volume": 0.032,
	},
	# T071 — Archive BOSS variant (used when InkWarden is alive in
	# archive_03).  Same root key (A minor) as archive_exploration so
	# the crossfade is harmonic, but with: faster BPM (108 vs 72),
	# louder bass drone, faster arpeggio with tremolo, and a low
	# sub-bass + a dissonant tritone in the chord to inject tension.
	# The shimmer is a half-step above E6 (F6) to feel unsettled.
	"archive_boss": {
		"bpm": 108,
		"duration": 11.1,          # 20 beats at 108bpm
		"root_midi": 33,           # A1 (deeper body for "boss weight")
		"chord_midi": [45, 48, 54],# A2 C3 F#3 (A minor + tritone — tense)
		"arp_midi": [69, 73, 76, 81, 79, 76, 73, 69], # A4 C#5 E5 A5 G5 (with raised C# + lowered G)
		"shimmer_midi": 89,        # F6 (half-step above E6 — unsettled)
		"lfo_freq": 0.55,          # faster LFO = more agitation
		"lfo_depth": 0.60,
		"shimmer_mod": 0.008,
		"arp_volume": 0.24,        # louder bell ostinato
		"pad_volume": 0.10,
		"bass_volume": 0.22,       # heavy bass drone — "boss weight"
		"shimmer_volume": 0.038,
	},
	# T080 — archive_04 DUAL BOSS variant (both InkWardens alive in
	# the same room).  Ratchets up the tension from archive_boss in
	# five ways: faster BPM (132 vs 108), 16th-note arpeggio (twice
	# as many bell hits per loop), a SECOND dissonant interval (G#
	# stacked into the chord voicing), a 3rd dissonant LFO at a
	# different rate (0.83Hz vs 0.55Hz, gives a layered modulation
	# pattern), and the shimmer jumps a WHOLE step above E6 (F#6)
	# to feel "unhinged".  Bass drone goes 50% louder, arp goes
	# 33% louder, pad goes 40% louder.  Track duration is shorter
	# (8.7s = 24 sixteenths at 132bpm) so the loop reads as more
	# frantic — the same 11.1s loop length as archive_boss would
	# feel paced in comparison.
	"archive_boss_dual": {
		"bpm": 132,
		"duration": 8.7,           # 24 beats at 132bpm, denser feel
		"root_midi": 33,           # A1 (same as archive_boss, harmonic continuity)
		"chord_midi": [45, 48, 54, 56],# A2 C3 F#3 G#3 (A minor + tritone + augmented 5th — chaotic)
		"arp_midi": [69, 73, 76, 81, 79, 76, 73, 69, 73, 76, 79, 81, 76, 73, 69, 73], # 16th-note pattern with neighbor tones
		"shimmer_midi": 90,        # F#6 (whole step above E6 — unhinged)
		"lfo_freq": 0.83,          # different from archive_boss, layered agitation
		"lfo_depth": 0.75,
		"shimmer_mod": 0.012,
		"arp_volume": 0.32,        # 33% louder than archive_boss
		"pad_volume": 0.14,        # 40% louder — fuller chord
		"bass_volume": 0.30,       # 36% louder — punishing sub-bass
		"shimmer_volume": 0.048,
	},
	# T087 — archive_dawn: a "dawn / victory / safe harbour" theme
	# played when the player completes the final room (GAME_OVER_SUCCESS
	# state) and on the full_archive achievement unlock.  G major is
	# the most stable, bright triad in the palette — a deliberate
	# contrast to archive_boss_dual's A minor + tritone.  BPM 76
	# sits between hub_warm (88) and title_intro (60) so it reads
	# as "deeper rest" than the Hub.  Bell arpeggio is an
	# octave-bouncing 8-note pattern around G4 (D5 B4 G4 D5 G4
	# B4 D5 G4) that feels more resolving than the ascending title
	# theme.  Shimmer goes a WHOLE step higher than hub_warm (D6 vs
	# C6) for a slightly more triumphant upper register.  Bass
	# drone sits at G2 — one whole step above hub_warm's F2 so the
	# crossfade from hub_warm → archive_dawn is a smooth key-relation
	# ascent.  Volumes: arp slightly louder than hub_warm, pad
	# slightly softer, bass slightly heavier to give the "anchored
	# victory" feeling.  The prewarm_music_streams() loop picks
	# this up automatically with no other API change required.
	"archive_dawn": {
		"bpm": 76,
		"duration": 12.6,          # 16 beats at 76bpm
		"root_midi": 43,           # G2 (one whole step above F2 in hub_warm)
		"chord_midi": [55, 59, 62],# G3 B3 D4 (G major — bright triad)
		"arp_midi": [74, 71, 67, 74, 67, 71, 74, 67], # D5 B4 G4 D5 G4 B4 D5 G4 (octave-bounce arpeggio)
		"shimmer_midi": 86,        # D6 (one whole step above hub_warm's C6)
		"lfo_freq": 0.30,          # slower than hub_warm (0.42) — more restful
		"lfo_depth": 0.30,         # gentler modulation
		"shimmer_mod": 0.005,
		"arp_volume": 0.20,        # slightly louder than hub_warm (0.18) — feels more present
		"pad_volume": 0.05,        # softer pad than hub_warm (0.06) — gives arp room to breathe
		"bass_volume": 0.14,       # slightly heavier bass than hub_warm (0.11) — anchored
		"shimmer_volume": 0.030,
	},
	# T107 — archive_storm: a "chaos + oppression" theme that is
	# intentionally DIFFERENT from archive_boss_dual's "intensity".
	# Where archive_boss_dual reads as "more of the same fight with
	# more pressure", archive_storm reads as "the world is breaking
	# down" — meant for InkWarden Phase 2 transitions or any
	# pre-defeat crisis moment.  Five design axes are pushed past
	# the dual-boss variant: (1) key changes from A minor to E
	# minor (harmonic contrast, not just louder A minor), (2) a
	# SECOND augmented interval is added to the chord — the
	# augmented 4th (A natural) stacking against the root E, (3)
	# the loop uses 16th-note arpeggio with chromatic neighbor
	# tones for a "frantic wind-chime" texture, (4) the bass
	# drone is dropped to E1 (sub-bass rumble, lower than
	# archive_boss_dual's A1) for "thunder" feel, and (5) the
	# shimmer is bumped another whole step to G#6 (one half-step
	# above archive_boss_dual's F#6) for the "screaming
	# electricity" feel.  BPM 120 sits between archive_boss (108)
	# and archive_boss_dual (132) so it reads as "sustained
	# chaos" rather than "frantic loop" — the loop is 10s = 20
	# beats at 120bpm.  Two LFO modulations (different rates
	# 0.66Hz / 1.05Hz) layer to create an irregular "gust"
	# pattern that no single sine LFO can produce.  Volumes:
	# bass 0.34 (heaviest of all presets — thunder), arp 0.36
	# (frantic bell hits), pad 0.18 (fuller chord), shimmer
	# 0.055 (electricity).  This is the "tier 3" preset in
	# _BOSS_MUSIC_TIER — strictly higher than archive_boss_dual,
	# so any request_boss_music("archive_storm") during a boss
	# fight upgrades the tier-1 / tier-2 override automatically.
	"archive_storm": {
		"bpm": 120,
		"duration": 10.0,          # 20 beats at 120bpm, sustained chaos
		"root_midi": 28,           # E1 (sub-bass rumble — lower than dual's A1)
		"chord_midi": [40, 44, 47, 50],# E2 G#2 B2 D3 (E minor + augmented 4th + D natural for "raised 7th" — dissonant)
		"arp_midi": [64, 67, 71, 75, 71, 67, 64, 67, 71, 75, 79, 75, 71, 67, 64, 67], # E4 G4 B4 D5 (rising) + F#5 peak (chromatic)
		"shimmer_midi": 92,        # G#6 (one half-step above dual's F#6 — screaming)
		"lfo_freq": 0.66,          # between boss (0.55) and dual (0.83) — gust
		"lfo_depth": 0.85,         # deepest modulation — wild amplitude swings
		"shimmer_mod": 0.014,      # aggressive vibrato
		"arp_volume": 0.36,        # 13% louder than dual's 0.32 — frantic bell hits
		"pad_volume": 0.18,        # 29% louder than dual's 0.14 — fuller chord
		"bass_volume": 0.34,       # 13% louder than dual's 0.30 — thunder sub-bass
		"shimmer_volume": 0.055,   # 15% louder than dual's 0.048 — screaming electricity
	},
}

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

func play_footstep() -> void:
	if _footstep_stream:
		play_sfx(_footstep_stream)

func play_glass_break() -> void:
	if _glass_break_stream:
		play_sfx(_glass_break_stream)

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
	if not _MUSIC_PRESETS.has(key):
		push_warning("AudioManagerEnhanced: unknown music key '%s'" % key)
		return null
	var preset: Dictionary = _MUSIC_PRESETS[key]
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

		# (3) Bell arpeggio — 8th note steps with exp-decay envelope
		var arp_idx := int(t / arp_step_dur) % arp_len
		var arp_t_in_step := fmod(t, arp_step_dur) / arp_step_dur
		var arp_env := exp(-arp_t_in_step * 4.5)
		var arp_f := arp_hz[arp_idx]
		var arp_note := sin(t * TAU * arp_f) * arp_env
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
## Iterates the full _MUSIC_PRESETS dictionary, so the 5 main themes
## (title_intro / hub_warm / archive_exploration) plus the 3 boss
## variants (archive_boss / archive_boss_dual) and the dawn theme
## (archive_dawn) are all cached automatically — no per-key call
## needed.  As of #44 (T087) there are 6 presets.
func prewarm_music_streams() -> void:
	for key in _MUSIC_PRESETS.keys():
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
	if not _MUSIC_PRESETS.has(boss_key):
		push_warning("AudioManagerEnhanced: unknown boss music key '%s'" % boss_key)
		return
	var new_tier: int = int(_BOSS_MUSIC_TIER.get(boss_key, 0))
	_boss_override_count += 1
	if _boss_override_key == "":
		# First request — start the override and play.
		_boss_override_key = boss_key
		play_music_track(boss_key, fade_ms)
		return
	# Already in boss mode.  Tier upgrade?
	var current_tier: int = int(_BOSS_MUSIC_TIER.get(_boss_override_key, 0))
	if new_tier > current_tier:
		# Switch to the more intense track.  Short crossfade
		# (300ms feels punchy for a mid-fight upgrade).  The
		# ref-count is already bumped above, so the
		# corresponding release won't accidentally clear the
		# override.
		_boss_override_key = boss_key
		play_music_track(boss_key, 300)
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
