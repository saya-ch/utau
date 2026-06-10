class_name CutWindupVFX
extends Node2D

# T169 (#87) — Pre-cut visual line streak drawn during the CutAbility 0.06s
# windup phase, so the player gets a clear "Cut is about to fire" cue
# before the actual cut_vfx.gd arc swings.  Pattern mirrors
# PulseWindupVFX (T166 #85) / BindWindupVFX (T167 #86) /
# EchoWindupVFX (T168 #86) so all 4 verb windups share the same "tell"
# pacing — players learn "ring/spiral/sphere/streak appears for Xs →
# verb fires" once and apply it across all 4 verbs.
#
# Design (STYLE_GUIDE compliant):
#   - Sits at the *predicted* cut origin (passed in by CutAbility).
#   - A diagonal line streak (0.5× the eventual cut radius, 32px for
#     the default 64px radius) extending from origin in the cut
#     direction.  The streak is the 4th visual motif in the verb
#     windup family (Pulse=ring / Bind=spiral / Echo=sphere /
#     Cut=streak) — each verb has a distinct silhouette so the
#     player can tell *which* verb is charging even before it fires
#     (critical for the 5-verb chain anti-misinput design from T142).
#   - Amber Voice (#F2B66E) — the Cut domain color (5 verb 4th
#     color, distinct from Pulse Coral / Bind Violet / Echo Cyan
#     / Wave Pale).  2.0px stroke so the streak reads at 0.5×
#     scale on small resolutions.
#   - Scales 0.0 → 1.0 over the windup (the streak "extends outward"
#     toward the eventual cut direction, matching the cut_vfx.gd's
#     own swing motion).  Alpha 0 → 0.7 ramp-in over first 40% of
#     the windup (Cut is the shortest windup at 0.06s, so the ramp
#     must be fast).
#   - Auto-frees after `max_lifetime` (default 0.06s = windup_time)
#     as a safety net in case CutAbility._execute_cut() runs while
#     the player is paused.

@export var streak_color: Color = Color("#F2B66E")  # Amber Voice per STYLE_GUIDE
@export var streak_width: float = 2.0

var _radius: float = 32.0         # 0.5× default cut_radius
var _direction: Vector2 = Vector2.RIGHT
var _max_lifetime: float = 0.06
var _lifetime: float = 0.0
var _active: bool = false

func _ready() -> void:
	z_index = 10  # above world, below HUD

func _process(delta: float) -> void:
	if not _active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		# Safety net: CutAbility should free us on _execute_cut(), but
		# if something interrupts (e.g. scene change mid-windup) we
		# self-destruct rather than leak.
		_active = false
		queue_free()
		return
	queue_redraw()

func trigger(origin: Vector2, half_radius: float, direction: Vector2, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_direction = direction.normalized() if direction.length() > 0.001 else Vector2.RIGHT
	_max_lifetime = maxf(duration, 0.01)
	_lifetime = 0.0
	_active = true
	queue_redraw()

func _draw() -> void:
	if not _active:
		return
	# Linear scale interpolation: 0.0 → 1.0 across the windup.
	# The streak "extends outward" toward the eventual cut direction,
	# mirroring the cut_vfx.gd's own arc-swing motion so the
	# transition from windup to fire reads as continuous.
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var streak_len := _radius * t
	# Alpha: ramp 0 → 0.7 over the first 40% of the windup so the
	# streak fades in cleanly.  Cut's windup is the shortest of the
	# 4 verbs (0.06s vs Pulse/Bind 0.10s vs Echo 0.08s), so the
	# ramp must complete fast — the eye only has ~0.024s of
	# "alpha-build" time before fire.
	var alpha_t := clampf(t / 0.4, 0.0, 1.0)
	var col := streak_color
	col.a = alpha_t * 0.7
	# Streak: from origin (0,0) extending in the cut direction.
	# Tilt the line slightly (1.5px perpendicular offset) so the
	# streak has visible "thickness" against the world background
	# even at small scales — a 1px line disappears on dark tilesets.
	var perp := Vector2(-_direction.y, _direction.x) * (streak_width * 0.5)
	draw_line(perp, _direction * streak_len + perp, col, streak_width, true)
	draw_line(-perp, _direction * streak_len - perp, col, streak_width, true)
