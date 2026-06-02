class_name PulseVFX
extends Node2D

@export var ring_color: Color = Color("#69C7CE")
@export var core_color: Color = Color("#F2B66E")
@export var fade_color: Color = Color("#E86D5A")

var _radius: float = 0.0
var _max_radius: float = 48.0
var _lifetime: float = 0.0
var _max_lifetime: float = 0.3
var _active: bool = false

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	if not _active:
		return
	
	_lifetime += delta
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	_radius = lerp(0.0, _max_radius, t)
	
	if _lifetime >= _max_lifetime:
		_active = false
		queue_free()
	else:
		queue_redraw()

func trigger(origin: Vector2, max_radius: float) -> void:
	global_position = origin
	_max_radius = max_radius
	_lifetime = 0.0
	_radius = 0.0
	_active = true
	queue_redraw()

func _draw() -> void:
	if not _active:
		return
	
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var alpha := 1.0 - t
	
	# Outer ring
	var outer_color := ring_color
	outer_color.a = alpha * 0.8
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 32, outer_color, 2.0)
	
	# Inner glow
	var inner_color := core_color
	inner_color.a = alpha * 0.4
	draw_circle(Vector2.ZERO, _radius * 0.6, inner_color)
	
	# Fade sparks
	if t > 0.5:
		var spark_color := fade_color
		spark_color.a = alpha * 0.6
		var spark_count := 8
		for i in spark_count:
			var angle := (float(i) / spark_count) * TAU + _lifetime * 5.0
			var spark_r := _radius * (0.7 + 0.3 * sin(_lifetime * 10.0 + i))
			var spark_pos := Vector2(cos(angle), sin(angle)) * spark_r
			draw_circle(spark_pos, 1.5, spark_color)
