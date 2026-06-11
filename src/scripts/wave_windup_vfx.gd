class_name WaveWindupVFX
extends "res://src/scripts/_verb_windup_vfx_base.gd"

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
#   - 3 concentric rings at radii (0.40×, 0.65×, 0.92×) of the
#     half-wave-radius — half-size so it reads as "precursor",
#     not "fire".  3 rings give the "sound wave radiating" feel
#     (a single ring would look like Pulse; 3 rings give Wave its
#     own visual identity).
#   - Pale Resonance (#B7E7DD) — the Wave domain color (5 verb 5th
#     color, distinct from Pulse Cyan / Bind Violet / Cut Amber /
#     Echo Cyan).  1.2px stroke (thinner than the other 4 windup
#     VFX) because 3 rings at once need visual hierarchy, and the
#     outermost ring already has presence from its size.
#   - Per-ring brightness multipliers (0.55 / 0.78 / 1.0) and radius
#     ratios (0.40 / 0.65 / 0.92) give the "ripple outward" hierarchy —
#     outermost ring = "sound is leaving my body", innermost ring =
#     "echoes trailing behind".  T174 (#93) — the 3 rings now fade in
#     together via the global modulate:a tween (T173's per-ring
#     phase_offset was removed in #93 for consistency with the 4
#     other verbs); the "ripple outward" feel is now driven purely
#     by spatial hierarchy (radii + brightness), not temporal
#     staggering.
#   - Auto-frees after `max_lifetime` (default 0.10s = windup_time) as
#     a safety net in case ResonanceWaveAbility._execute_wave()
#     runs while the player is paused.
#
# T174.B (#94) — Now extends VerbWindupVFXBase (full contract in
# pulse_windup_vfx.gd / _verb_windup_vfx_base.gd).

@export var ring_color: Color = Color("#B7E7DD")  # Pale Resonance per STYLE_GUIDE
@export var ring_width: float = 1.2
@export var ring_count: int = 3  # 3 concentric halo rings — the "sound wave" motif

var _radius: float = 40.0         # 0.5× default wave_radius (80)

func trigger(origin: Vector2, half_radius: float, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_max_lifetime = maxf(duration, 0.01)
	# T174.B (#94) — Delegate ramp-in tween + state reset to base.
	_activate_windup_tween()

func _draw() -> void:
	if not _active:
		return
	# Linear lifetime progression.  0 → 1 across the windup.
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	# Wave is the lightest verb, so the peak alpha is intentionally
	# 0.05 lower than PulseWindupVFX (0.7) — the verb should *feel*
	# like a sound wave (transient, not solid), not a physical barrier.
	var peak_alpha: float = 0.65

	# 3 concentric halo rings.  Each ring uses the same global
	# peak_alpha multiplied by its own brightness factor, so the
	# "leading edge" hierarchy (innermost dim → outermost bright)
	# is preserved.  T174 (#93) — the smooth ramp-in is now driven
	# by the modulate:a tween in VerbWindupVFXBase, so the per-ring
	# phase_offset is removed (the 3 rings fade in together).
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
		var col := ring_color
		col.a = peak_alpha * ring_alpha_mult
		draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 24, col, ring_width, true)
