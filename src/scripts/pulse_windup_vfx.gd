class_name PulseWindupVFX
extends "res://src/scripts/_verb_windup_vfx_base.gd"

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
#
# T174.B (#94) — Now extends VerbWindupVFXBase, which owns the
# common state (`_lifetime` / `_max_lifetime` / `_active`), the
# `_ready()` z_index=10 setup, the `_process()` lifetime tracker,
# the `_activate_windup_tween()` ramp-in tween (T174 #93), and the
# byte-identical `fade_out_and_free()` exit (T173 #92).  Verb-specific
# state (`_radius` / `_start_scale` / `_end_scale`) and verb-specific
# `_draw()` rendering remain here.

@export var ring_color: Color = Color("#69C7CE")  # Glass Cyan per STYLE_GUIDE
@export var ring_width: float = 1.5

var _radius: float = 24.0         # 0.5× default pulse_radius
var _start_scale: float = 1.0
var _end_scale: float = 0.92     # mild inward "gathering" before fire

func trigger(origin: Vector2, half_radius: float, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_max_lifetime = maxf(duration, 0.01)
	# T174.B (#94) — Delegate ramp-in tween + _active / _lifetime reset
	# to VerbWindupVFXBase._activate_windup_tween().  Replaces the
	# 4-line tween block (modulate.a=0.0 + create_tween + TRANS_QUAD
	# EASE_OUT + tween_property) that lived here from #93 T174.  The
	# tween contract is unchanged (modulate:a 0.0→1.0 over _max_lifetime,
	# TRANS_QUAD EASE_OUT), now centralised in the base for all 5 verbs.
	_activate_windup_tween()

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
	# driven by the modulate:a tween created by the base's
	# _activate_windup_tween().  See base class for the tween contract.
	var col := ring_color
	col.a = 0.7
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, col, ring_width)

# T173 (#92) — 0.05s fade-out tween then queue_free().  Now inherited
# from VerbWindupVFXBase (T174.B #94); the implementation there is
# byte-identical to the one that lived here from #92.  PulseAbility
# / BindAbility / EchoAbility / CutAbility / ResonanceWaveAbility
# continue to call `self.fade_out_and_free()` and the dispatch
# resolves to the base class copy.
