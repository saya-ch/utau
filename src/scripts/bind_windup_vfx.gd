class_name BindWindupVFX
extends Node2D

# T167 (#86) — Pre-bind visual ring drawn during the BindAbility 0.10s
# windup phase, so the player gets a clear "Bind is about to fire" cue
# before the actual bind effect (BindAbility.execute_bind) starts.  The
# pattern mirrors PulseWindupVFX (T166 #85) so all verb windups share
# the same "tell" pacing — players learn "ring appears for 0.10s →
# verb fires" once and apply it to Pulse + Bind (and via T168 Echo,
# eventually Echo too).
#
# Design (STYLE_GUIDE compliant):
#   - Sits at the *predicted* bind origin (passed in by BindAbility).
#   - 0.5× the eventual bind radius (i.e. 20px for the default 40px
#     radius) — half-size so it reads as "precursor", not "fire".
#   - Muted Violet (#65506A) rim, 1.5px — matches Bind's color domain
#     (Pulse=Cyan, Bind=Violet, Cut=Amber, Echo=Cyan, Wave=Pale).  The
#     inward contraction is replaced with a *spiral* twist (3 arcs
#     rotating inward), echoing Bind's "inward spiral" icon (A033)
#     so the verb language matches: Bind pulls things in.
#   - Auto-frees after `max_lifetime` (default 0.10s = windup_time) as
#     a safety net in case BindAbility._execute_bind() runs while the
#     player is paused.

@export var ring_color: Color = Color("#65506A")  # Muted Violet per STYLE_GUIDE
@export var ring_width: float = 1.5
@export var arc_count: int = 3  # number of spiral arcs

var _radius: float = 20.0         # 0.5× default bind_radius
var _max_lifetime: float = 0.10
var _lifetime: float = 0.0
var _active: bool = false
var _start_scale: float = 1.0
var _end_scale: float = 0.85      # slightly more aggressive inward "pull" than Pulse (0.92)

func _ready() -> void:
	z_index = 10  # above world, below HUD

func _process(delta: float) -> void:
	if not _active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
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
	# full windup duration.  Visual: the spiral arcs fade in with a
	# quick initial rise and a smooth approach to peak, rather than a
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
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var scale_factor := lerpf(_start_scale, _end_scale, t)
	var ring_r := _radius * scale_factor
	# T174 (#93) — Peak alpha held at 0.75; the smooth ramp-in is
	# driven by the modulate:a tween created in trigger().  Replaces
	# the old linear `alpha_t = clampf(t / 0.4, 0, 1)` which produced
	# a 40%-then-hold profile.  See trigger() for the tween contract.
	# Slightly higher peak (0.75) than PulseWindupVFX (0.7) so the
	# spiral arcs read clearly even at small radii.
	var col := ring_color
	col.a = 0.75

	# Draw arc_count spiral arcs that rotate inward over the windup.
	# Each arc covers 1/3 of the circle but offset in time so they
	# appear to be "spiraling in" toward the center, matching the
	# Bind icon's spiral motif (A033).
	var arc_span := TAU / float(arc_count)  # angular width of each arc
	var base_angle := _lifetime * 4.0  # rotation speed: 4 rad/s
	for i in range(arc_count):
		var a1 := base_angle + float(i) * arc_span
		var a2 := a1 + arc_span * 0.7  # gap between arcs (0.7 of span)
		draw_arc(Vector2.ZERO, ring_r, a1, a2, 12, col, ring_width, true)


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
