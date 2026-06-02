class_name NoteWisp
extends CharacterBody2D

signal died
signal damaged

@export var move_speed: float = 40.0
@export var move_amplitude: float = 30.0
@export var move_frequency: float = 1.5
@export var health: int = 2
@export var contact_damage: int = 1
@export var knockback_resistance: float = 0.5
@export var projectile_cooldown: float = 3.0
@export var projectile_speed: float = 60.0

var _start_position: Vector2
var _time: float = 0.0
var _is_dead: bool = false
var _is_purified: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _projectile_timer: float = 0.0
var _facing_right: bool = true

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	add_to_group("enemies")
	_start_position = global_position
	_projectile_timer = randf() * projectile_cooldown
	
	if _hurtbox:
		_hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	_time += delta
	
	if _is_purified:
		velocity.y = -30.0
		velocity.x = _knockback_velocity.x
		move_and_slide()
		return
	
	# Apply knockback decay
	_knockback_velocity = _knockback_velocity.lerp(Vector2.ZERO, 3.0 * delta)
	
	# Sine wave horizontal movement
	var x_offset := sin(_time * move_frequency * TAU) * move_amplitude
	var target_x := _start_position.x + x_offset
	var move_dir := signf(target_x - global_position.x)
	
	velocity.x = move_dir * move_speed + _knockback_velocity.x
	
	# Gentle vertical bobbing
	velocity.y = sin(_time * move_frequency * 0.5 * TAU) * 10.0
	
	# Update facing
	if move_dir != 0:
		_facing_right = move_dir > 0
		if _sprite:
			_sprite.flip_h = not _facing_right
	
	move_and_slide()
	
	# Projectile logic
	_projectile_timer -= delta
	if _projectile_timer <= 0:
		_fire_projectile()
		_projectile_timer = projectile_cooldown

func _fire_projectile() -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	
	var dir := (player.global_position - global_position).normalized()
	var proj := NoteProjectile.new()
	proj.direction = dir
	proj.speed = projectile_speed
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position

func take_damage(amount: int, knockback: Vector2) -> void:
	if _is_dead or _is_purified:
		return
	
	health -= amount
	_knockback_velocity = knockback * (1.0 - knockback_resistance)
	
	damaged.emit()
	
	if health <= 0:
		_purify()
	else:
		if _sprite:
			_sprite.modulate = Color("#E86D5A")
			await get_tree().create_timer(0.1).timeout
			if _sprite and not _is_dead and not _is_purified:
				_sprite.modulate = Color.WHITE

func _purify() -> void:
	_is_purified = true
	
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 24.0)
	
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.0, 1.0)
		tween.tween_callback(_finish_death)
	
	if _hurtbox:
		_hurtbox.monitoring = false
	if _collision:
		_collision.disabled = true

func _finish_death() -> void:
	_is_dead = true
	died.emit()
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if _is_dead or _is_purified:
		return
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var knockback_dir := (body.global_position - global_position).normalized()
			body.take_damage(contact_damage, knockback_dir * 80.0)

func repel(force: Vector2) -> void:
	_knockback_velocity += force
