extends CharacterBody2D

signal landed

@export var move_speed: float = 90.0
@export var jump_velocity: float = -260.0
@export var gravity_multiplier: float = 1.0
@export var coyote_time: float = 0.08
@export var jump_buffer: float = 0.08
@export var fall_gravity_multiplier: float = 1.4
@export var max_fall_speed: float = 400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pulse_ability: PulseAbility = $PulseAbility

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_right: bool = true
var _is_jumping: bool = false
var _was_on_floor: bool = false
var _speed_multiplier: float = 1.0

func _ready() -> void:
	add_to_group("player")
	if pulse_ability:
		pulse_ability.pulse_fired.connect(_on_pulse_fired)

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_movement(delta)
	_handle_jump(delta)
	_handle_pulse()
	_update_animation()
	_update_facing()

	_was_on_floor = is_on_floor()
	move_and_slide()

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		var g := get_gravity().y * gravity_multiplier
		if velocity.y > 0:
			g *= fall_gravity_multiplier
		velocity.y += g * delta
		velocity.y = minf(velocity.y, max_fall_speed)
	else:
		_coyote_timer = coyote_time
		_is_jumping = false

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		velocity.x = input_dir * move_speed * _speed_multiplier
		_facing_right = input_dir > 0
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 8.0 * delta)

func _handle_jump(delta: float) -> void:
	_coyote_timer -= delta
	_jump_buffer_timer -= delta

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer

	if _jump_buffer_timer > 0 and (_coyote_timer > 0 or is_on_floor()):
		velocity.y = jump_velocity
		_is_jumping = true
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

func _handle_pulse() -> void:
	if Input.is_action_just_pressed("pulse"):
		if pulse_ability:
			var origin := global_position + Vector2(0, -8)
			var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT
			pulse_ability.start_pulse(origin, dir)

func _on_pulse_fired(origin: Vector2, radius: float) -> void:
	# Spawn VFX
	var vfx := PulseVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(origin, radius)

func _update_animation() -> void:
	if not sprite:
		return
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif absf(velocity.x) > 1.0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _update_facing() -> void:
	if not sprite:
		return
	# Critical: do NOT simply flip_h for left-facing.
	# The left-arm gauntlet must remain on the anatomical left.
	# For placeholder, we use flip_h but will replace with proper left/right spritesheets.
	# TODO: Replace with dedicated left-facing sprite sheet (A009) once available.
	sprite.flip_h = not _facing_right

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	GameState.take_damage(amount)
	velocity += knockback
	# Brief invulnerability flash could go here

func respawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO

func set_speed_multiplier(multiplier: float) -> void:
	_speed_multiplier = multiplier
