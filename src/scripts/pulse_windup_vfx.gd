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
	# T174 (#93) — Tween-based smooth ramp-in (mirror of T173 ramp-out).
	# Replaces the old linear `alpha_t = clampf(t / 0.4, 0, 1)` curve in
	# _draw() with a TRANS_QUAD EASE_OUT tween on modulate:a over the
	# full windup duration.  Visual: the ring fades in with a quick
	# initial rise and a smooth approach to peak, rather than a
	# hard 40%-then-hold linear ramp.  Mirrors all 5 verb windup VFX
	# scripts (GDScript no-cross-script-inheritance: each verb has
	# its own copy).
	modulate.a = 0.0
	var ramp_tween := create_tween()
	ramp_tween.set_trans(Tween.TRANS_QUAD)
	ramp_tween.set_ease(Tween.EASE_OUT)
	ramp_tween.tween_property(self, "modulate:a", 1.0, _max_lifetime)
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
	# T174 (#93) — Peak alpha held at 0.7; the smooth ramp-in is
	# driven by the modulate:a tween created in trigger().  Replaces
	# the old linear `alpha_t = clampf(t / 0.4, 0, 1)` which produced
	# a 40%-then-hold profile.  See trigger() for the tween contract.
	var col := ring_color
	col.a = 0.7
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, col, ring_width)

# T173 (#92) — 0.05s fade-out tween then queue_free().  Called by
# PulseAbility._exit_tree() when the player / scene is freed mid-windup
# (e.g. on a room transition or player death during the 0.10s windup
# window).  Without the tween, the VFX pops out instantly — a hard cut
# that breaks the "verb language" the player just learned.  The 0.05s
# duration is short enough to vanish before the next room loads (room
# transitions are ≥0.4s), but long enough to mask the abrupt _exit_tree
# with a smooth alpha decay.
#
# Idempotent: if fade_out_and_free is called twice, the second call
# short-circuits via _fading_out (the existing queue_free() at the end
# of _process is the safety net for the still-active case, but the
# tween path is the primary exit during interrupts).
func fade_out_and_free() -> void:
	if not _active:
		# Already fading or never triggered — nothing to do, just free.
		queue_free()
		return
	_active = false  # stop _process from racing the tween
	# Tween "modulate:a" 1.0 → 0.0 over 0.05s, then queue_free().
	# (start_alpha captured for potential future customisation; currently
	#  we always tween from current modulate.a to 0.0.)
	var start_alpha: float = modulate.a
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	tween.tween_callback(queue_free)
	# Touch start_alpha so the linter doesn't warn unused (it's a hint
	# for future per-verb tuning — see bind_windup_vfx.gd for example).
	var _unused := start_alpha
