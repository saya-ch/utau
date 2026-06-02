class_name PulseVFX
extends Node2D

@export var ring_color: Color = Color("#69C7CE")
@export var core_color: Color = Color("#F2B66E")
@export var fade_color: Color = Color("#E86D5A")
@export var wave_color: Color = Color("#B7E7DD")

var _radius: float = 0.0
var _max_radius: float = 48.0
var _lifetime: float = 0.0
var _max_lifetime: float = 0.4
var _active: bool = false
var _ring_count: int = 3
var _wave_offset: float = 0.0

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	if not _active:
		return

	_lifetime += delta
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	_radius = lerp(0.0, _max_radius, t)
	_wave_offset += delta * 20.0

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
	_wave_offset = 0.0
	_active = true
	queue_redraw()

func _draw() -> void:
	if not _active:
		return

	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var alpha := 1.0 - t

	# Core glow
	var core := core_color
	core.a = alpha * 0.35
	draw_circle(Vector2.ZERO, _radius * 0.5, core)

	# Multiple expanding rings with wave distortion
	for i in range(_ring_count):
		var ring_t := clampf((t - i * 0.08) / 0.7, 0.0, 1.0)
		if ring_t <= 0.0:
			continue
		var ring_alpha := (1.0 - ring_t) * alpha * 0.9
		var ring_r := _max_radius * ring_t
		var col := ring_color
		col.a = ring_alpha
		var line_w := 2.0 * (1.0 - ring_t * 0.5)
		_draw_wavy_ring(ring_r, col, line_w, i)

	# Waveform arcs
	if t < 0.7:
		var wave_alpha := alpha * 0.6 * (1.0 - t / 0.7)
		var wave_col := wave_color
		wave_col.a = wave_alpha
		_draw_waveform_arc(_radius * 0.8, wave_col, 1.5)

	# Sparks on outer edge
	if t > 0.2:
		var spark_alpha := alpha * 0.7
		var spark_col := fade_color
		spark_col.a = spark_alpha
		var spark_count := 10
		for i in range(spark_count):
			var angle := (float(i) / spark_count) * TAU + _wave_offset * 0.3 + i * 0.7
			var dist := _radius * (0.85 + 0.15 * sin(_wave_offset + i * 1.3))
			var spark_pos := Vector2(cos(angle), sin(angle)) * dist
			var spark_size := 1.2 + 0.8 * sin(_wave_offset * 2.0 + i)
			draw_circle(spark_pos, spark_size, spark_col)

func _draw_wavy_ring(radius: float, color: Color, line_width: float, seed: int) -> void:
	var segments := 48
	var points := PackedVector2Array()
	for i in range(segments + 1):
		var angle := (float(i) / segments) * TAU
		var wave := sin(angle * 6.0 + _wave_offset + seed * 2.0) * 2.0
		var r := radius + wave
		points.append(Vector2(cos(angle), sin(angle)) * r)
	for i in range(segments):
		draw_line(points[i], points[i + 1], color, line_width)

func _draw_waveform_arc(radius: float, color: Color, line_width: float) -> void:
	var segments := 32
	for i in range(segments):
		var angle1 := (float(i) / segments) * TAU
		var angle2 := (float(i + 1) / segments) * TAU
		var wave1 := sin(angle1 * 8.0 + _wave_offset) * 4.0
		var wave2 := sin(angle2 * 8.0 + _wave_offset) * 4.0
		var p1 := Vector2(cos(angle1), sin(angle1)) * (radius + wave1)
		var p2 := Vector2(cos(angle2), sin(angle2)) * (radius + wave2)
		draw_line(p1, p2, color, line_width)
