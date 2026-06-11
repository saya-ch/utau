class_name CutWindupVFX
extends "res://src/scripts/_verb_windup_vfx_base.gd"

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
#     own swing motion).  Cut is the shortest windup at 0.06s, so
#     the T174 (#93) ramp-in tween (TRANS_QUAD EASE_OUT) must
#     front-load visibility.
#   - Auto-frees after `max_lifetime` (default 0.06s = windup_time) as
#     a safety net in case CutAbility._execute_cut() runs while
#     the player is paused.
#
# T174.B (#94) — Now extends VerbWindupVFXBase.  The state vars
# `_lifetime` / `_max_lifetime` / `_active`, the `_ready()` z_index=10
# setup, the `_process()` lifetime tracker, the `_activate_windup_tween()`
# ramp-in tween (T174 #93), and the `fade_out_and_free()` exit (T173 #92)
# are all inherited.  Verb-specific state (`_radius` / `_direction`)
# and the streak `_draw()` rendering remain here.

@export var streak_color: Color = Color("#F2B66E")  # Amber Voice per STYLE_GUIDE
@export var streak_width: float = 2.0

var _radius: float = 32.0         # 0.5× default cut_radius
var _direction: Vector2 = Vector2.RIGHT

func trigger(origin: Vector2, half_radius: float, direction: Vector2, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_direction = direction.normalized() if direction.length() > 0.001 else Vector2.RIGHT
	_max_lifetime = maxf(duration, 0.01)
	# T174.B (#94) — Delegate ramp-in tween + state reset to base.
	_activate_windup_tween()

func _draw() -> void:
	if not _active:
		return
	# Linear scale interpolation: 0.0 → 1.0 across the windup.
	# The streak "extends outward" toward the eventual cut direction,
	# mirroring the cut_vfx.gd's own arc-swing motion so the
	# transition from windup to fire reads as continuous.
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var streak_len := _radius * t
	# T174 (#93) — Peak alpha held at 0.7; the smooth ramp-in is
	# driven by the modulate:a tween in VerbWindupVFXBase.
	var col := streak_color
	col.a = 0.7
	# Streak: from origin (0,0) extending in the cut direction.
	# Tilt the line slightly (1.5px perpendicular offset) so the
	# streak has visible "thickness" against the world background
	# even at small scales — a 1px line disappears on dark tilesets.
	var perp := Vector2(-_direction.y, _direction.x) * (streak_width * 0.5)
	draw_line(perp, _direction * streak_len + perp, col, streak_width, true)
	draw_line(-perp, _direction * streak_len - perp, col, streak_width, true)
