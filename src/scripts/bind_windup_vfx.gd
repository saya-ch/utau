class_name BindWindupVFX
extends "res://src/scripts/_verb_windup_vfx_base.gd"

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
#
# T174.B (#94) — Now extends VerbWindupVFXBase (see pulse_windup_vfx.gd
# for the full base-class contract).  The byte-identical
# `fade_out_and_free()` from T173 (#92) and the 4-line T174 (#93) ramp-in
# tween are now inherited from the base.  Verb-specific state and the
# spiral-arc `_draw()` rendering remain here.

@export var ring_color: Color = Color("#65506A")  # Muted Violet per STYLE_GUIDE
@export var ring_width: float = 1.5
@export var arc_count: int = 3  # number of spiral arcs

var _radius: float = 20.0         # 0.5× default bind_radius
var _start_scale: float = 1.0
var _end_scale: float = 0.85      # slightly more aggressive inward "pull" than Pulse (0.92)

func trigger(origin: Vector2, half_radius: float, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_max_lifetime = maxf(duration, 0.01)
	# T174.B (#94) — Delegate ramp-in tween + state reset to base.
	_activate_windup_tween()

func _draw() -> void:
	if not _active:
		return
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var scale_factor := lerpf(_start_scale, _end_scale, t)
	var ring_r := _radius * scale_factor
	# T174 (#93) — Peak alpha held at 0.75; the smooth ramp-in is
	# driven by the modulate:a tween in VerbWindupVFXBase.
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
