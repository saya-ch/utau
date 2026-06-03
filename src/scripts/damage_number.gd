class_name DamageNumber
extends Node2D

# Single floating damage number. Spawns, pops in, drifts up, fades out.
# Used to give players concrete feedback on hits/heals/purifies.
#
# Use the static helper `DamageNumber.spawn(parent, pos, value, kind)` to avoid
# manually creating the node.

enum Kind { DMG, CRIT, HEAL, PURIFY, SHIELD, MISS }

# Color palette aligned with STYLE_GUIDE.md
const COLOR_DMG := Color("#E86D5A")      # Coral Pulse
const COLOR_CRIT := Color("#F2B66E")     # Amber Voice (bigger hits)
const COLOR_HEAL := Color("#B7E7DD")     # Pale Resonance
const COLOR_PURIFY := Color("#F2B66E")   # Amber Voice
const COLOR_SHIELD := Color("#69C7CE")   # Glass Cyan
const COLOR_MISS := Color("#65506A")     # Muted Violet

const LIFETIME := 0.6
const RISE_DISTANCE := 28.0
const POP_DURATION := 0.08
const POP_SCALE := 0.6  # start small, pop up to 1.0

var _value: int = 0
var _kind: int = Kind.DMG
var _text: String = ""
var _elapsed: float = 0.0
var _label: Label
var _rng_jitter: float = 0.0
var _origin_x: float = 0.0
var _origin_y: float = 0.0

func _ready() -> void:
	# Build label as a child for crisp text rendering
	_label = Label.new()
	_label.add_theme_color_override("font_outline_color", Color("#05070D"))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.modulate.a = 0.0
	add_child(_label)

	# Apply text/style first so label.size is valid for pivot math
	_apply_style()

	# Center the label on (0,0) and set pivot to its own center for symmetric pop-in
	if _label.size.x > 0:
		_label.position = -_label.size / 2.0
		_label.pivot_offset = _label.size / 2.0
	_label.scale = Vector2(POP_SCALE, POP_SCALE)

	# Pop-in tween (parallel: scale + fade-in)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_label, "scale", Vector2(1.0, 1.0), POP_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_label, "modulate:a", 1.0, POP_DURATION)

func _apply_style() -> void:
	if _label == null:
		return
	match _kind:
		Kind.DMG:
			_label.text = "-%d" % _value
			_label.add_theme_color_override("font_color", COLOR_DMG)
			_label.add_theme_font_size_override("font_size", 8)
			_label.add_theme_constant_override("outline_size", 2)
		Kind.CRIT:
			_label.text = "-%d!" % _value
			_label.add_theme_color_override("font_color", COLOR_CRIT)
			_label.add_theme_font_size_override("font_size", 10)
			_label.add_theme_constant_override("outline_size", 2)
		Kind.HEAL:
			_label.text = "+%d" % _value
			_label.add_theme_color_override("font_color", COLOR_HEAL)
			_label.add_theme_font_size_override("font_size", 8)
			_label.add_theme_constant_override("outline_size", 2)
		Kind.PURIFY:
			_label.text = _text if _text != "" else "净化"
			_label.add_theme_color_override("font_color", COLOR_PURIFY)
			_label.add_theme_font_size_override("font_size", 9)
			_label.add_theme_constant_override("outline_size", 2)
		Kind.SHIELD:
			_label.text = _text if _text != "" else "盾"
			_label.add_theme_color_override("font_color", COLOR_SHIELD)
			_label.add_theme_font_size_override("font_size", 8)
			_label.add_theme_constant_override("outline_size", 2)
		Kind.MISS:
			_label.text = _text if _text != "" else "—"
			_label.add_theme_color_override("font_color", COLOR_MISS)
			_label.add_theme_font_size_override("font_size", 8)
			_label.add_theme_constant_override("outline_size", 2)

func _process(delta: float) -> void:
	_elapsed += delta
	# Rise (ease-out quadratic)
	var t: float = clampf(_elapsed / LIFETIME, 0.0, 1.0)
	var rise: float = -RISE_DISTANCE * (1.0 - (1.0 - t) * (1.0 - t))
	# Slight horizontal jitter so multi-hits don't perfectly stack
	var drift: float = _rng_jitter * sin(_elapsed * 6.0) * (1.0 - t)
	position.y = _origin_y + rise
	position.x = _origin_x + drift

	# Fade out in the second half
	if t > 0.4:
		var alpha_t: float = (t - 0.4) / 0.6
		if _label:
			_label.modulate.a = clampf(1.0 - alpha_t, 0.0, 1.0)

	if _elapsed >= LIFETIME:
		queue_free()

func setup(value: int, kind: int, custom_text: String = "", jitter: float = 0.0) -> void:
	_value = value
	_kind = kind
	_text = custom_text
	_rng_jitter = jitter
	_origin_x = position.x
	_origin_y = position.y

## Static helper — call from any script:
##   DamageNumber.spawn(get_tree().current_scene, hit_pos, 2, DamageNumber.Kind.DMG)
static func spawn(parent: Node, pos: Vector2, value: int, kind: int = Kind.DMG, custom_text: String = "") -> void:
	if parent == null:
		return
	var dn := DamageNumber.new()
	dn.position = pos
	parent.add_child(dn)
	# Slight horizontal jitter so multi-hits don't stack
	var jitter: float = randf_range(-8.0, 8.0) if kind == Kind.DMG else 0.0
	dn.setup(value, kind, custom_text, jitter)
