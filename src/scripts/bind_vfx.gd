class_name BindVFX
extends Node2D

@export var core_color: Color = Color("#65506A")
@export var wave_color: Color = Color("#B7E7DD")
@export var pull_color: Color = Color("#69C7CE")

var _radius: float = 0.0
var _max_radius: float = 40.0
var _lifetime: float = 0.0
var _max_lifetime: float = 0.35
var _active: bool = false
var _wave_offset: float = 0.0
var _origin: Vector2 = Vector2.ZERO

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	if not _active:
		return

	_lifetime += delta
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	_radius = lerp(0.0, _max_radius, t)
	_wave_offset += delta * 25.0

	if _lifetime >= _max_lifetime:
		_active = false
		queue_free()
	else:
		queue_redraw()

func trigger(origin: Vector2, max_radius: float) -> void:
	global_position = origin
	_origin = origin
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

	# Inward spiral (bind/pull visual)
	var spiral_segments := 64
	var spiral_turns := 2.5
	var spiral_points := PackedVector2Array()
	for i in range(spiral_segments + 1):
		var seg_t := float(i) / spiral_segments
		var angle := seg_t * spiral_turns * TAU + _wave_offset
		var r := _radius * (1.0 - seg_t * 0.7)
		spiral_points.append(Vector2(cos(angle), sin(angle)) * r)
	
	if spiral_points.size() >= 2:
		var spiral_col := pull_color
		spiral_col.a = alpha * 0.8
		var last_idx := spiral_points.size() - 1
		for i in range(last_idx):
			var line_alpha := alpha * (1.0 - float(i) / float(last_idx)) * 0.9
			var col := pull_color
			col.a = line_alpha
			# Per-segment progress for taper: matches the spiral's
			# parametric seg_t used when spiral_points was built.
			var seg_t := float(i) / float(last_idx)
			draw_line(spiral_points[i], spiral_points[i + 1], col, 2.0 - seg_t)

	# Concentric contracting rings
	for i in range(3):
		var ring_t := clampf((t - i * 0.06) / 0.7, 0.0, 1.0)
		if ring_t <= 0.0:
			continue
		var ring_alpha := (1.0 - ring_t) * alpha * 0.7
		var ring_r := _max_radius * (1.0 - ring_t * 0.8)
		var col := wave_color
		col.a = ring_alpha
		draw_arc(Vector2.ZERO, ring_r, 0, TAU, 32, col, 1.5)

	# Core dark vortex
	var core := core_color
	core.a = alpha * 0.25 * (1.0 - t * 0.5)
	draw_circle(Vector2.ZERO, _radius * 0.3 * (1.0 + t * 0.3), core)

	# Particle sparks being pulled inward
	if t < 0.8:
		var spark_alpha := alpha * 0.8
		var spark_col := wave_color
		spark_col.a = spark_alpha
		var spark_count := 8
		for i in range(spark_count):
			var angle := (float(i) / spark_count) * TAU + _wave_offset * 0.5 + i * 0.9
			var dist := _radius * (0.5 + 0.5 * sin(_wave_offset + i * 1.5))
			var spark_pos := Vector2(cos(angle), sin(angle)) * dist
			var size := 1.0 + 0.5 * sin(_wave_offset * 2.0 + i)
			draw_circle(spark_pos, size, spark_col)
