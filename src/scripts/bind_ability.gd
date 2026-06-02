class_name BindAbility
extends Node

signal bind_fired(origin: Vector2, radius: float)
signal bind_hit(target: Node)
signal bind_blocked

@export var bind_radius: float = 40.0
@export var bind_cost: int = 20
@export var cooldown: float = 1.2
@export var windup_time: float = 0.1
@export var active_time: float = 0.15
@export var bind_duration: float = 3.0
@export var pull_force: float = 80.0

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "BindAbility must be child of CharacterBody2D")

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
	
	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_bind()

func can_bind() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= bind_cost and not _is_winding_up

func start_bind(origin: Vector2, direction: Vector2) -> bool:
	if not can_bind():
		return false
	
	if not GameState.consume_resonance(bind_cost):
		return false
	
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction
	
	return true

func _execute_bind() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown
	
	bind_fired.emit(_pending_origin, bind_radius)
	
	_perform_bind_hit_check()

func _perform_bind_hit_check() -> void:
	var space_state := _player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = bind_radius
	query.shape = circle
	query.transform = Transform2D(0, _pending_origin)
	query.collision_mask = 0b10100  # Layers 3 (Enemy), 5 (Interactable)
	
	var results := space_state.intersect_shape(query, 16)
	
	for result in results:
		var collider := result["collider"] as Node
		if collider == null:
			continue
		
		# Apply bind to enemies
		if collider.is_in_group("enemies"):
			_apply_enemy_bind(collider)
		# Trigger interactables
		elif collider.is_in_group("interactable"):
			_trigger_interactable(collider)
	
	bind_hit.emit(null)

func _apply_enemy_bind(enemy: Node) -> void:
	# Pull enemy toward player
	var pull_dir := (_pending_origin - enemy.global_position).normalized()
	if pull_dir == Vector2.ZERO:
		pull_dir = _pending_direction
	
	if enemy.has_method("repel"):
		# Repel with negative force = pull
		enemy.repel(pull_dir * pull_force)
	
	# Apply bind status if enemy supports it
	if enemy.has_method("apply_bind"):
		enemy.apply_bind(bind_duration)
	elif enemy.has_method("take_damage"):
		# Fallback: stun-like effect via damage + pull
		enemy.take_damage(0, pull_dir * pull_force * 0.5)
	
	bind_hit.emit(enemy)

func _trigger_interactable(obj: Node) -> void:
	if obj.has_method("on_bind_triggered"):
		obj.on_bind_triggered()
	elif obj.has_method("on_pulse_triggered"):
		obj.on_pulse_triggered()

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up
