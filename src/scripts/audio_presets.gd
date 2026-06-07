extends RefCounted
class_name AudioPresets

# AudioPresets — procedural BGM preset data
# ==========================================
# Extracted from `audio_manager_enhanced.gd` (T121 #63) so the audio
# synthesis logic and the data tables can evolve independently.
# This file is **pure data + comments** — no methods, no signals,
# no autoload state.  Loaded via `const AudioPresets = preload(...)`
# in audio_manager_enhanced.gd, then read as
# `AudioPresets.MUSIC_PRESETS` / `AudioPresets.BOSS_MUSIC_TIER`.
#
# Design rules (enforced by smoke tests):
# - 9 presets total: title_intro, hub_warm, archive_exploration,
#   archive_boss, archive_boss_dual, archive_dawn, archive_storm,
#   silence_void, **whisper_hollow** (T118 #63).
# - 13 required fields per preset: bpm, duration, root_midi,
#   chord_midi, arp_midi, shimmer_midi, lfo_freq, lfo_depth,
#   shimmer_mod, arp_volume, pad_volume, bass_volume, shimmer_volume.
# - Boss tier table is 3 entries (archive_boss=1 / archive_boss_dual=2
#   / archive_storm=3).  silence_void / whisper_hollow are NOT in
#   the boss tier table (they are ambient / scene-routing themes,
#   not boss-fight overrides).
#
# Tonal map (referenced by README Game States table):
#   title_intro         D major  / sparse / hopeful
#   hub_warm            F major  / warm / bright
#   archive_exploration A minor  / melancholic / deep
#   archive_boss        A minor  / tritone / single boss
#   archive_boss_dual   A minor  / +aug5 / dual boss / frantic
#   archive_dawn        G major  / bright / victory
#   archive_storm       E minor  / aug4+raised7 / chaos / phase 2
#   silence_void        (silent) / "emptiness" / failure + finale phase 1
#   whisper_hollow      D minor  / min7th / "deep quiet" / 9th preset

# Boss music intensity tier (#39 T080, #59 T107).
# Higher tier overrides lower tier mid-fight (e.g. archive_boss →
# archive_boss_dual when a second boss appears, → archive_storm
# when InkWarden enters phase 2).  Tiers reset to 0 on
# release_boss_music().  Keys NOT in this table have implicit
# tier 0 (treat as "no override preference").
const BOSS_MUSIC_TIER := {
	"archive_boss": 1,
	"archive_boss_dual": 2,
	"archive_storm": 3,
}

# Procedural BGM presets (T062 / T080 / T087 / T107 / T114 / T118).
# MIDI numbers — A4 = 69, C4 = 60. Chord = 3-note triad around root
# (some presets add a 4th for dissonance).  Frequencies are derived
# via 440 * 2^((midi-69)/12) at synth time (see
# audio_manager_enhanced.gd _midi_to_hz()).
const MUSIC_PRESETS := {
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
	# BOSS_MUSIC_TIER — strictly higher than archive_boss_dual,
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
	# T114 — silence_void: a deliberate "absence" theme that
	# expresses emptiness rather than music.  Plays in three
	# situations: (1) GAME_OVER_FAILURE — when the player dies, the
	# result screen sits on a 4-second zero-amplitude loop instead
	# of cutting straight to dead silence.  The audible effect
	# matches the existing T093 cold-gray visual wash: the world
	# "empties out" rather than snapping off.  (2) **T117 finale
	# phase 1** — `play_music_finale()` auto-stitches silence_void
	# (4s "the world is gone") → archive_dawn (12.6s "but the
	# world breathes back in"), giving GAME_OVER_SUCCESS a
	# two-stage resolution.  (3) Reusable for any "the room
	# itself is dead" beat (empty transitions, post-credits
	# silence).  All four volume channels are zeroed, so the
	# synth is genuinely silent (no bass rumble, no shimmer,
	# no chord pad).  The track is the shortest preset (4.0s) so
	# that switching to/from silence_void is fast and the loop
	# boundary is inaudible (there is no boundary content to
	# begin with).  BPM 60 mirrors title_intro's resting tempo
	# so the silence_void → archive_dawn finale crossfade feels
	# like "the world is breathing back in."
	"silence_void": {
		"bpm": 60,
		"duration": 4.0,
		"root_midi": 28,           # E1 (declared for API consistency — not audible)
		"chord_midi": [],          # empty — no chord pad
		"arp_midi": [],            # empty — no bell arpeggio
		"shimmer_midi": 0,         # disabled
		"lfo_freq": 0.0,           # disabled
		"lfo_depth": 0.0,
		"shimmer_mod": 0.0,
		"arp_volume": 0.0,         # all four channels zeroed
		"pad_volume": 0.0,
		"bass_volume": 0.0,
		"shimmer_volume": 0.0,
	},
	# T118 — whisper_hollow: a "deep quiet" ambient theme
	# designed for the "no enemies, just listening" zone of the
	# archive.  Where silence_void expresses *emptiness* (no
	# sound, just air), whisper_hollow expresses *deep quiet*
	# (sound is present, but it is so soft and slow that the
	# room feels suspended).  Design axes: (1) D minor key
	# (the only D-minor preset — all others are D-major /
	# F-major / A-minor / E-minor), (2) root D3 (deeper than
	# title_intro's D3 by zero semitones — the deepness comes
	# from the chord, not the root), (3) 4-note chord D3 F3
	# A3 C4 (D minor 7th — D F A C — gives the "hollow" / "open"
	# sound because the 7th clashes gently with the major-3rd
	# resolution expectation), (4) **no arpeggio** (arp_midi: []
	# like silence_void — the silence_void precedent for empty
	# arp means the synth can skip envelope math safely), (5)
	# 4-note static pad only with a very slow LFO (0.15Hz
	# breath cycle = one inhale every 6.7 seconds = feels
	# "meditative"), (6) BPM 50 is the slowest of all presets
	# (slower than title_intro's 60), but BPM is only meaningful
	# when arp_midi is non-empty, so this is mostly semantic.
	# Duration 16.0s matches title_intro for a sense of "this
	# room takes its time".  Volumes: bass 0.12 (deeper than
	# hub_warm's 0.11 but lighter than archive_dawn's 0.14) +
	# pad 0.08 (the dominant sound — chord pad with breath
	# LFO) + shimmer 0.018 (slightly above silence_void's 0
	# but well below any other preset's 0.025-0.055 range) +
	# arp 0.0 (no arpeggio to play).  Prewarm auto-covers this
	# (MUSIC_PRESETS dict iteration).  NOT in BOSS_MUSIC_TIER
	# — this is a scene-routing theme, not a boss-fight override.
	"whisper_hollow": {
		"bpm": 50,
		"duration": 16.0,          # matches title_intro for "this room takes its time"
		"root_midi": 50,           # D3
		"chord_midi": [53, 57, 60, 64],# F3 A3 C4 E4 (D minor 7th voicing — D F A C across two octaves)
		"arp_midi": [],            # empty — no bell arpeggio (meditative, no rhythm)
		"shimmer_midi": 81,        # A5 (one octave below title_intro's A6 — warmer, less "icy")
		"lfo_freq": 0.15,          # 6.7s breath cycle — slowest of all presets
		"lfo_depth": 0.55,         # deep modulation — the chord *swells*
		"shimmer_mod": 0.002,      # subtle vibrato
		"arp_volume": 0.0,         # no arpeggio
		"pad_volume": 0.08,        # chord pad is the dominant voice
		"bass_volume": 0.12,       # deeper than hub_warm (0.11) but lighter than archive_dawn (0.14)
		"shimmer_volume": 0.018,   # just-above-silence presence
	},
}
