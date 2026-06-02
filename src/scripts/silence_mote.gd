class_name SilenceMote
extends CharacterBody2D

signal died
signal damaged

@export var patrol_speed: float = 30.0
@export var patrol_range: float = 60.0
@export var health: int = 1
@export var contact_damage: int = 1
@export var knockback_resistance: float = 0.3

var _start_position: Vector2
var _patrol_direction: int = 1
var _is_dead: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	add_to_group("enemies")
	_start_position = global_position
	
	if _hurtbox:
		_hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	# Apply knockback decay
	_knockback_velocity = _knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)
	
	# Patrol movement
	var target_x := _start_position.x + _patrol_direction * patrol_range
	var move_dir := signf(target_x - global_position.x)
	
	velocity.x = move_dir * patrol_speed + _knockback_velocity.x
	velocity.y += get_gravity().y * delta
	velocity.y = minf(velocity.y, 200.0)
	
	# Flip sprite based on movement direction
	if _sprite:
		_sprite.flip_h = move_dir < 0
	
	move_and_slide()
	
	# Turn around at patrol bounds
	if absf(global_position.x - _start_position.x) >= patrol_range:
		_patrol_direction *= -1
	
	# Also turn if hitting a wall
	if is_on_wall():
		_patrol_direction *= -1

func take_damage(amount: int, knockback: Vector2) -> void:
	if _is_dead:
		return
	
	health -= amount
	_knockback_velocity = knockback * (1.0 - knockback_resistance)
	
	damaged.emit()
	
	# Flash white
	if _sprite:
		_sprite.modulate = Color("#E86D5A")
		await get_tree().create_timer(0.1).timeout
		if _sprite and not _is_dead:
			_sprite.modulate = Color.WHITE
	
	if health <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	died.emit()
	
	# Death animation / fade out
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate:a", 0.0, 0.5)
		tween.tween_property(_sprite, "scale", Vector2(0.5, 0.5), 0.5)
		tween.tween_callback(queue_free)
	else:
		queue_free()
	
	# Disable collision
	if _collision:
		_collision.disabled = true
	set_physics_process(false)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if _is_dead:
		return
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var knockback_dir := (body.global_position - global_position).normalized()
			body.take_damage(contact_damage, knockback_dir * 100.0)

func repel(force: Vector2) -> void:
	_knockback_velocity += force
