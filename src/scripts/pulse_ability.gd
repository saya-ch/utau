class_name PulseAbility
extends Node

signal pulse_fired(origin: Vector2, radius: float)
signal pulse_hit(target: Node, knockback: Vector2)
signal pulse_blocked

@export var pulse_radius: float = 48.0
@export var pulse_cost: int = 15
@export var cooldown: float = 0.5
@export var windup_time: float = 0.08
@export var active_time: float = 0.12
@export var knockback_force: float = 200.0
@export var damage: int = 1

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "PulseAbility must be child of CharacterBody2D")

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
	
	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_pulse()

func can_pulse() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= pulse_cost and not _is_winding_up

func start_pulse(origin: Vector2, direction: Vector2) -> bool:
	if not can_pulse():
		return false
	
	if not GameState.consume_resonance(pulse_cost):
		return false
	
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction
	
	return true

func _execute_pulse() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown
	
	# Emit signal for VFX
	pulse_fired.emit(_pending_origin, pulse_radius)
	
	# Perform collision detection
	_perform_pulse_hit_check()

func _perform_pulse_hit_check() -> void:
	var space_state := _player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = pulse_radius
	query.shape = circle
	query.transform = Transform2D(0, _pending_origin)
	query.collision_mask = 0b11100  # Layers 3 (Enemy), 4 (Hazard), 5 (Interactable)
	
	var results := space_state.intersect_shape(query, 16)
	
	for result in results:
		var collider := result["collider"] as Node
		if collider == null:
			continue
		
		var hit_pos: Vector2 = result["point"] if result.has("point") else collider.global_position
		var knockback_dir := (hit_pos - _pending_origin).normalized()
		if knockback_dir == Vector2.ZERO:
			knockback_dir = _pending_direction
		
		var knockback := knockback_dir * knockback_force
		
		# Apply damage/knockback to enemies
		if collider.is_in_group("enemies"):
			_apply_enemy_hit(collider, knockback)
		# Trigger interactables (glass locks, etc)
		elif collider.is_in_group("interactable"):
			_trigger_interactable(collider)
		# Repel hazards
		elif collider.is_in_group("hazards"):
			_apply_hazard_repel(collider, knockback)
	
	# Also check for enemy projectiles in range (Area2D, not in physics layers)
	for proj in get_tree().get_nodes_in_group("enemy_projectiles"):
		if proj.global_position.distance_to(_pending_origin) <= pulse_radius:
			if proj.has_method("destroy_by_pulse"):
				proj.destroy_by_pulse()
			elif proj.has_method("queue_free"):
				var vfx := RepairVFX.new()
				get_tree().current_scene.add_child(vfx)
				vfx.trigger(proj.global_position, 8.0)
				proj.queue_free()
	
	pulse_hit.emit(null, Vector2.ZERO)

func _apply_enemy_hit(enemy: Node, knockback: Vector2) -> void:
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage, knockback)
	pulse_hit.emit(enemy, knockback)

func _trigger_interactable(obj: Node) -> void:
	if obj.has_method("on_pulse_triggered"):
		obj.on_pulse_triggered()

func _apply_hazard_repel(hazard: Node, knockback: Vector2) -> void:
	if hazard.has_method("repel"):
		hazard.repel(knockback)

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up
