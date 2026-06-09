class_name PulseWindupVFX
extends Node2D

# T166 (#85) — Pre-pulse visual ring drawn during the PulseAbility 0.10s
# windup phase, so the player gets a clear "Pulse is about to fire" cue
# before the actual fire VFX (pulse_vfx.gd) starts expanding at 0× → 1×
# radius.  Previously the windup was 0.08s of *invisible* charging — a
# quick "Pulse→Bind" chain could read as a single Bind, since both fired
# in the same animation frame.
#
# Design (STYLE_GUIDE compliant):
#   - Sits at the *predicted* pulse origin (passed in by PulseAbility).
#   - 0.5× the eventual pulse radius (i.e. 24px for the default 48px
#     radius) — half-size so it reads as "precursor", not "fire".
#   - Glass Cyan (#69C7CE) rim, 1.5px, with a subtle inward contraction
#     (1.0 → 0.92 over 0.10s) so the eye sees "energy gathering" before
#     the actual explosion.  Mirrors the Bind/ResonanceWave windup cues
#     (compress → burst) so the verb language stays consistent.
#   - Auto-frees after `max_lifetime` (default 0.10s = windup_time) as
#     a safety net in case PulseAbility._execute_pulse() runs while
#     the player is paused (e.g. on a cutscene frame the ability
#     might not free it explicitly).

@export var ring_color: Color = Color("#69C7CE")  # Glass Cyan per STYLE_GUIDE
@export var ring_width: float = 1.5

var _radius: float = 24.0         # 0.5× default pulse_radius
var _max_lifetime: float = 0.10
var _lifetime: float = 0.0
var _active: bool = false
var _start_scale: float = 1.0
var _end_scale: float = 0.92     # mild inward "gathering" before fire

func _ready() -> void:
	z_index = 10  # above the world (player/sprites), below HUD (10+)

func _process(delta: float) -> void:
	if not _active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		# Safety net: PulseAbility should free us on _execute_pulse(),
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
	# Linear scale interpolation: 1.0 → 0.92 across the windup.
	# Gives a faint "pulling inward" feel just before the fire VFX
	# takes over with the opposite (outward) expansion.
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var scale_factor := lerpf(_start_scale, _end_scale, t)
	var ring_r := _radius * scale_factor
	# Alpha: ramp 0 → 0.7 over the first 40% of the windup, then hold,
	# so the ring fades in cleanly without flickering at frame 0.
	var alpha_t := clampf(t / 0.4, 0.0, 1.0)
	var col := ring_color
	col.a = alpha_t * 0.7
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, col, ring_width)
