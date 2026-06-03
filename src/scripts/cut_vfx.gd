class_name CutVFX
extends Node2D

## Cut 声波 VFX
## 视觉：水平弧形斩击 + 锋利碎片 + 闪光拖尾
## 与 Pulse（圆环扩散）和 Bind（向内螺旋）形成对比

@export var slash_color: Color = Color("#E86D5A")  # Coral Pulse - 锋利/危险
@export var edge_color: Color = Color("#B7E7DD")    # Pale Resonance - 刀刃边缘
@export var flash_color: Color = Color("#F2B66E")   # Amber Voice - 切中闪光

var _lifetime: float = 0.0
var _max_lifetime: float = 0.32
var _active: bool = false
var _origin: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.RIGHT
var _radius: float = 64.0
var _arc_degrees: float = 90.0

# Slash trail (a few points from start to end of slash)
var _slash_points: Array = []  # Vector2[]
var _spark_positions: Array = []  # Vector2[] (random sparks at impact)
var _spark_velocities: Array = []  # Vector2[]

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	if not _active:
		return

	_lifetime += delta
	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)

	# Animate sparks
	for i in range(_spark_positions.size()):
		var pos: Vector2 = _spark_positions[i]
		var vel: Vector2 = _spark_velocities[i]
		pos += vel * delta
		vel *= 0.92  # drag
		_spark_positions[i] = pos
		_spark_velocities[i] = vel

	if _lifetime >= _max_lifetime:
		_active = false
		queue_free()
	else:
		queue_redraw()

func trigger(origin: Vector2, direction: Vector2, radius: float, arc_degrees: float) -> void:
	global_position = origin
	_origin = origin
	_direction = direction.normalized() if direction.length() > 0 else Vector2.RIGHT
	_radius = radius
	_arc_degrees = arc_degrees
	_lifetime = 0.0
	_active = true

	# Build slash arc points
	_slash_points.clear()
	var segments := 24
	var facing_angle := atan2(_direction.y, _direction.x)
	var half_arc := deg_to_rad(arc_degrees) * 0.5
	for i in range(segments + 1):
		var t := float(i) / segments
		var angle := facing_angle - half_arc + t * (half_arc * 2.0)
		var r := radius * (0.85 + 0.15 * t)
		_slash_points.append(Vector2(cos(angle), sin(angle)) * r)

	# Generate sparks at random points along the slash
	_spark_positions.clear()
	_spark_velocities.clear()
	var spark_count := 10
	for i in range(spark_count):
		var angle_offset := randf_range(-half_arc, half_arc)
		var angle := facing_angle + angle_offset
		var dist := radius * randf_range(0.7, 1.0)
		var pos := Vector2(cos(angle), sin(angle)) * dist
		_spark_positions.append(pos)
		# Velocity outward + slight randomness
		var vel := Vector2(cos(angle), sin(angle)) * randf_range(40.0, 90.0)
		vel += Vector2(randf_range(-20, 20), randf_range(-20, 20))
		_spark_velocities.append(vel)

	queue_redraw()

func _draw() -> void:
	if not _active:
		return

	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var alpha := 1.0 - t

	# Slash trail: draws with a delayed alpha for trailing effect
	# The slash should appear to "sweep" across the arc
	# Use 3 passes for layered slash effect
	_pass_slash(alpha * 0.4, 6.0, edge_color)
	_pass_slash(alpha * 0.7, 3.0, slash_color)
	_pass_slash(alpha * 1.0, 1.5, flash_color)

	# Sparks
	for i in range(_spark_positions.size()):
		var pos: Vector2 = _spark_positions[i]
		var spark_alpha := alpha * 0.9 * (1.0 - t * 0.7)
		var col := slash_color if i % 2 == 0 else flash_color
		col.a = spark_alpha
		var size := 1.0 + (1.0 - t) * 1.5
		draw_circle(pos, size, col)

	# Bright flash at center (the "snap" of the cut)
	if t < 0.15:
		var flash_t := t / 0.15
		var flash_alpha := (1.0 - flash_t) * 0.8
		var col := flash_color
		col.a = flash_alpha
		# Small radial flash lines
		var flash_segments := 6
		for i in range(flash_segments):
			var angle := float(i) / flash_segments * TAU
			var start := Vector2(cos(angle), sin(angle)) * 4.0
			var end := Vector2(cos(angle), sin(angle)) * 12.0 * (1.0 - flash_t)
			draw_line(start, end, col, 1.5)

func _pass_slash(alpha: float, line_width: float, color: Color) -> void:
	if _slash_points.size() < 2:
		return
	var c := color
	c.a = alpha
	for i in range(_slash_points.size() - 1):
		draw_line(_slash_points[i], _slash_points[i + 1], c, line_width)
