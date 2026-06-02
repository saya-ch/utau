class_name SilenceMote
extends CharacterBody2D

signal died
signal damaged

@export var patrol_speed: float = 30.0
@export var patrol_range: float = 60.0
@export var health: int = 1
@export var contact_damage: int = 1
@export var knockback_resistance: float = 0.3
@export var wave_warn_time: float = 0.6
@export var wave_warn_interval: float = 2.5

var _start_position: Vector2
var _patrol_direction: int = 1
var _is_dead: bool = false
var _is_purified: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _wave_warn_timer: float = 0.0
var _is_warning: bool = false
var _warning_flash_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _warn_indicator: Node2D = $WarnIndicator

func _ready() -> void:
	add_to_group("enemies")
	_start_position = global_position
	_wave_warn_timer = randf() * wave_warn_interval

	if _hurtbox:
		_hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Apply knockback decay
	_knockback_velocity = _knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)

	if _is_purified:
		# Float upward and fade when purified
		velocity.y = -40.0
		velocity.x = _knockback_velocity.x
		move_and_slide()
		return

	# Wave warning logic
	_wave_warn_timer -= delta
	if _wave_warn_timer <= 0 and not _is_warning:
		_start_warning()

	if _is_warning:
		_warning_flash_timer -= delta
		_update_warning_visuals()
		if _warning_flash_timer <= 0:
			_end_warning()

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

func _start_warning() -> void:
	_is_warning = true
	_warning_flash_timer = wave_warn_time
	if _warn_indicator:
		_warn_indicator.visible = true

func _end_warning() -> void:
	_is_warning = false
	_wave_warn_timer = wave_warn_interval
	if _warn_indicator:
		_warn_indicator.visible = false

func _update_warning_visuals() -> void:
	if not _sprite:
		return
	var flash := sin(_warning_flash_timer * 15.0) > 0
	if flash:
		_sprite.modulate = Color("#E86D5A")
	else:
		_sprite.modulate = Color.WHITE

func take_damage(amount: int, knockback: Vector2) -> void:
	if _is_dead or _is_purified:
		return

	health -= amount
	_knockback_velocity = knockback * (1.0 - knockback_resistance)

	damaged.emit()

	if health <= 0:
		_purify()
	else:
		# Flash white on damage
		if _sprite:
			_sprite.modulate = Color("#E86D5A")
			await get_tree().create_timer(0.1).timeout
			if _sprite and not _is_dead and not _is_purified:
				_sprite.modulate = Color.WHITE

func _purify() -> void:
	_is_purified = true

	# Spawn purification VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 24.0)

	# Visual: turn warm and float up
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.0, 1.0)
		tween.tween_callback(_finish_death)

	# Disable hurtbox
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
			body.take_damage(contact_damage, knockback_dir * 100.0)

func repel(force: Vector2) -> void:
	_knockback_velocity += force
