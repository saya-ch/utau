extends Camera2D

@export var target: NodePath
@export var smoothing: float = 8.0
@export var look_ahead: float = 16.0
@export var vertical_offset: float = -8.0

var _target_node: Node2D
var _velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("camera")
	if target:
		_target_node = get_node(target) as Node2D

func _process(delta: float) -> void:
	if not _target_node:
		return
	
	var target_pos := _target_node.global_position
	# Add slight look-ahead based on player velocity
	if _target_node is CharacterBody2D:
		var cb := _target_node as CharacterBody2D
		target_pos.x += signf(cb.velocity.x) * look_ahead
		target_pos.y += vertical_offset
	
	global_position = global_position.lerp(target_pos, smoothing * delta)
	# Snap to pixel grid after interpolation
	global_position = global_position.round()
