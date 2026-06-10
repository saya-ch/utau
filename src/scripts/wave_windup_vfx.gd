class_name WaveWindupVFX
extends Node2D

# T171 (#89) — Pre-wave visual halo drawn during the ResonanceWaveAbility
# 0.10s windup phase, so the player gets a clear "Wave is about to fire"
# cue before the actual resonance_wave_vfx.gd main ring starts expanding
# at 0× → wave_radius over active_time (0.4s).  Pattern mirrors
# PulseWindupVFX (T166 #85) / BindWindupVFX (T167 #86) /
# EchoWindupVFX (T168 #86) / CutWindupVFX (T169 #87) so all 5 verb
# windups share the same "tell" pacing — players learn "ring/spiral/
# sphere/streak/halo appears for Xs → verb fires" once and apply it
# across all 5 verbs.
#
# Design (STYLE_GUIDE compliant):
#   - Sits at the *predicted* wave origin (passed in by
#     ResonanceWaveAbility).  Wave is a centered AOE (no facing
#     direction), so unlike Cut's streak (directional) or Pulse's ring
#     (centered on head), the windup halo is a symmetric 3-ring
#     concentric "halo" pattern.
#   - 3 concentric rings at radii (0.20×, 0.30×, 0.42×) of the
#     eventual wave_radius — half-size so it reads as "precursor",
#     not "fire".  3 rings give the "sound wave radiating" feel
#     (a single ring would look like Pulse; 3 rings give Wave its
#     own visual identity).
#   - Pale Resonance (#B7E7DD) — the Wave domain color (5 verb 5th
#     color, distinct from Pulse Cyan / Bind Violet / Cut Amber /
#     Echo Cyan).  1.2px stroke (thinner than the other 4 windup
#     VFX) because 3 rings at once need visual hierarchy, and the
#     outermost ring already has presence from its size.
#   - Each ring phase-offset by a fixed 0.5s-into-windup value so
#     they appear to ripple outward (Phase 0.0 / 0.35 / 0.65 of
#     _lifetime) — gives the "sound is leaving my body" feel that
#     Pulse's inward contraction / Bind's spiral twist also
#     express in their own motifs.
#   - Alpha 0 → 0.65 ramp-in over first 40% of the windup (matches
#     PulseWindupVFX 0.7 / BindWindupVFX 0.75 — Wave is the lightest
#     verb, so slightly lower peak alpha lets the design feel
#     "lighter than air").
#   - Auto-frees after `max_lifetime` (default 0.10s = windup_time)
#     as a safety net in case ResonanceWaveAbility._execute_wave()
#     runs while the player is paused.

@export var ring_color: Color = Color("#B7E7DD")  # Pale Resonance per STYLE_GUIDE
@export var ring_width: float = 1.2
@export var ring_count: int = 3  # 3 concentric halo rings — the "sound wave" motif

var _radius: float = 40.0         # 0.5× default wave_radius (80)
var _max_lifetime: float = 0.10
var _lifetime: float = 0.0
var _active: bool = false

func _ready() -> void:
	z_index = 10  # above world, below HUD

func _process(delta: float) -> void:
	if not _active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		# Safety net: ResonanceWaveAbility should free us on _execute_wave(),
		# but if something interrupts (e.g. scene change mid-windup)
		# we self-destruct rather than leak.
		_active = false
		queue_free()
		return
	queue_redraw()

func trigger(origin: Vector2, half_radius: float, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_max_lifetime = maxf(duration, 0.01)
	_lifetime = 0.0
	_active = true
	queue_redraw()

func _draw() -> void:
	if not _active:
		return
	# Linear lifetime progression.  0 → 1 across the windup.
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	# Wave is the lightest verb, so the peak alpha is intentionally
	# 0.05 lower than PulseWindupVFX (0.7) — the verb should *feel*
	# like a sound wave (transient, not solid), not a physical barrier.
	var peak_alpha: float = 0.65

	# 3 concentric halo rings with phase offsets.  Each ring has
	# its own alpha ramp (delayed by `phase_offset`) so the halo
	# blooms outward during the windup — the "sound wave radiating"
	# motif.  Per-ring multiplier gives visual hierarchy: the
	# outermost ring is the brightest (reading as "the leading edge").
	for i in range(ring_count):
		# Radii scale: ring 0 (innermost) = 0.40× _radius, ring 1 = 0.65×, ring 2 (outermost) = 0.92×
		# These ratios give a 3-ring concentric pattern that fills
		# the 0.5× half-radius box without overlapping the eventual
		# fire VFX (which starts at 0× radius and expands to 1.0×).
		var r_ratio: float = [0.40, 0.65, 0.92][i]
		var ring_r: float = _radius * r_ratio
		# Per-ring brightness multiplier — outermost ring = 1.0
		# (leading edge), innermost = 0.55 (so the trio reads as
		# "echoes" trailing behind, not a solid disc).
		var ring_alpha_mult: float = [0.55, 0.78, 1.0][i]
		# Phase offset on the alpha ramp gives the staggered
		# "ripple outward" feel — ring 0 reaches peak alpha first
		# (t=0.0), ring 1 next (t=0.18), ring 2 last (t=0.36).
		var phase_offset: float = [0.0, 0.18, 0.36][i]
		var local_t: float = clampf((t - phase_offset) / 0.4, 0.0, 1.0)
		var col := ring_color
		col.a = local_t * peak_alpha * ring_alpha_mult
		draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 24, col, ring_width, true)


# T173 (#92) — 0.05s fade-out tween then queue_free().  Mirrors
# PulseWindupVFX.fade_out_and_free() — pattern duplicated across all 5
# verb windup VFX scripts (GDScript no-cross-script-inheritance:
# each verb has its own copy; the implementation is byte-identical
# so future 6th-verb additions can copy-paste).
#
# Called by the parent ability's _exit_tree() when the player / scene
# is freed mid-windup (room transition or player death).  The 0.05s
# duration is short enough to vanish before the next room loads
# (room transitions are ≥0.4s) but long enough to mask the abrupt
# _exit_tree with a smooth alpha decay.
#
# Idempotent: if fade_out_and_free is called twice, the second call
# short-circuits via _active (the queue_free at end of _process is the
# safety net for the still-active case; the tween path is the primary
# exit during interrupts).
func fade_out_and_free() -> void:
	if not _active:
		# Already fading or never triggered — nothing to do, just free.
		queue_free()
		return
	_active = false  # stop _process from racing the tween
	var start_alpha: float = modulate.a
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	tween.tween_callback(queue_free)
	var _unused := start_alpha
