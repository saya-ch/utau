class_name EchoWindupVFX
extends Node2D

# T168 (#86) — Pre-echo visual sphere drawn during the EchoAbility 0.08s
# windup phase, so the player gets a clear "Echo shield is about to
# activate" cue before the actual echo_vfx.gd pops the shield into
# existence.  Pattern mirrors PulseWindupVFX (T166 #85) and
# BindWindupVFX (T167 #86) so all verb windups share the same
# "tell" pacing.
#
# Design (STYLE_GUIDE compliant):
#   - Sits at the *predicted* echo origin (passed in by EchoAbility).
#   - Starts at 0.5× the eventual echo radius (15px for the default
#     30px radius) and EXPANDS to 1.0× by the end of windup — opposite
#     of Pulse/Bind which contract inward.  Echo's "shield pops out"
#     language matches its defensive role (the shield comes OUT to meet
#     incoming threats) and gives Echo a distinct 3rd-stage windup feel
#     so Pulse/Bind/Echo all have different motion languages.
#   - Glass Cyan (#69C7CE) main fill (semi-transparent 0.18), Pale
#     Resonance (#B7E7DD) rim highlight (0.55), Amber Voice (#F2B66E)
#     center warm dot (0.45).  All 3 colors echo the EchoVFX palette
#     so the windup reads as a "preview" of the real shield.
#   - Auto-frees after `max_lifetime` (default 0.08s = windup_time) as
#     a safety net.

@export var fill_color: Color = Color("#69C7CE")        # Glass Cyan per STYLE_GUIDE
@export var rim_color: Color = Color("#B7E7DD")         # Pale Resonance highlight
@export var core_color: Color = Color("#F2B66E")        # Amber Voice warm dot

var _radius: float = 15.0         # 0.5× default echo_radius
var _max_radius: float = 30.0     # 1.0× default echo_radius
var _max_lifetime: float = 0.08
var _lifetime: float = 0.0
var _active: bool = false
var _start_scale: float = 0.5
var _end_scale: float = 1.0       # expand OUT — Echo's "shield pops out" language

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

func trigger(origin: Vector2, half_radius: float, full_radius: float, duration: float) -> void:
	global_position = origin
	_radius = maxf(half_radius, 1.0)
	_max_radius = maxf(full_radius, half_radius)
	_max_lifetime = maxf(duration, 0.01)
	_lifetime = 0.0
	_active = true
	queue_redraw()

func _draw() -> void:
	if not _active:
		return
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var scale_factor := lerpf(_start_scale, _end_scale, t)
	var ring_r := _radius + (_max_radius - _radius) * scale_factor
	# Alpha: ramp 0 → 1.0 over the first 50% of the windup (Echo windup
	# is short at 0.08s, so ramp faster than Pulse's 40% — visual must
	# be readable in <0.04s).
	var alpha_t := clampf(t / 0.5, 0.0, 1.0)
	# Layer 1: Glass Cyan semi-transparent fill (0.18 peak)
	var fill_col := fill_color
	fill_col.a = alpha_t * 0.18
	draw_circle(Vector2.ZERO, ring_r, fill_col)
	# Layer 2: Pale Resonance rim ring (0.55 peak, 1.5px)
	var rim_col := rim_color
	rim_col.a = alpha_t * 0.55
	draw_arc(Vector2.ZERO, ring_r, 0, TAU, 32, rim_col, 1.5, true)
	# Layer 3: Amber Voice center warm dot (0.45 peak, fixed 2px)
	var core_col := core_color
	core_col.a = alpha_t * 0.45
	draw_circle(Vector2.ZERO, 2.0, core_col)


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
