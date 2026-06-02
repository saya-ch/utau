class_name RepairVFX
extends Node2D

@export var warm_color: Color = Color("#F2B66E")
@export var wave_color: Color = Color("#B7E7DD")
@export var core_color: Color = Color("#69C7CE")

var _lifetime: float = 0.0
var _max_lifetime: float = 0.8
var _active: bool = false
var _wave_offset: float = 0.0
var _max_radius: float = 32.0

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	if not _active:
		return

	_lifetime += delta
	_wave_offset += delta * 15.0

	if _lifetime >= _max_lifetime:
		_active = false
		queue_free()
	else:
		queue_redraw()

func trigger(origin: Vector2, radius: float = 32.0) -> void:
	global_position = origin
	_max_radius = radius
	_lifetime = 0.0
	_wave_offset = 0.0
	_active = true
	queue_redraw()

func _draw() -> void:
	if not _active:
		return

	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var alpha := 1.0 - t

	# Warm bloom core
	var core := warm_color
	core.a = alpha * 0.5 * (1.0 - t * 0.5)
	draw_circle(Vector2.ZERO, _max_radius * 0.4 * (1.0 + t * 0.5), core)

	# Rising waveform lines
	var wave_count := 4
	for i in range(wave_count):
		var wave_t := clampf((t - i * 0.1) / 0.6, 0.0, 1.0)
		if wave_t <= 0.0:
			continue
		var wave_alpha := (1.0 - wave_t) * alpha * 0.8
		var col := warm_color if i % 2 == 0 else wave_color
		col.a = wave_alpha
		var y_offset := -_max_radius * wave_t * 1.2
		var width := _max_radius * (0.5 + wave_t * 0.5)
		_draw_wave_line(y_offset, width, col, 2.0, i)

	# Expanding ring
	if t < 0.6:
		var ring_alpha := alpha * 0.7 * (1.0 - t / 0.6)
		var ring_r := _max_radius * (t / 0.6)
		var ring_col := core_color
		ring_col.a = ring_alpha
		draw_arc(Vector2.ZERO, ring_r, 0, TAU, 32, ring_col, 2.0)

	# Sparkle particles
	if t < 0.7:
		var spark_alpha := alpha * 0.9
		var spark_col := warm_color
		spark_col.a = spark_alpha
		var spark_count := 6
		for i in range(spark_count):
			var angle := (float(i) / spark_count) * TAU + _wave_offset * 0.2
			var dist := _max_radius * 0.6 * (1.0 + t)
			var spark_pos := Vector2(cos(angle), sin(angle)) * dist
			spark_pos.y -= _max_radius * t * 0.8
			var size := 1.5 * (1.0 - t / 0.7)
			draw_rect(Rect2(spark_pos - Vector2(size, size), Vector2(size * 2, size * 2)), spark_col)

func _draw_wave_line(y_offset: float, width: float, color: Color, line_width: float, seed: int) -> void:
	var segments := 24
	var points := PackedVector2Array()
	for i in range(segments + 1):
		var x := (float(i) / segments - 0.5) * width * 2.0
		var wave := sin(x * 0.3 + _wave_offset + seed * 1.5) * 3.0
		points.append(Vector2(x, y_offset + wave))
	for i in range(segments):
		draw_line(points[i], points[i + 1], color, line_width)
