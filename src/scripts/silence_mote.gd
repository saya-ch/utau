class_name SilenceMote
extends CharacterBody2D

const _DamageNumberScript := preload("res://src/scripts/damage_number.gd")
const _RepairVFXScript := preload("res://src/scripts/repair_vfx.gd")

signal died
signal damaged

@export var patrol_speed: float = 30.0
@export var patrol_range: float = 60.0
@export var chase_speed: float = 60.0
@export var chase_range: float = 80.0
@export var lose_interest_range: float = 120.0
@export var health: int = 1
@export var contact_damage: int = 1
@export var knockback_resistance: float = 0.3
@export var wave_warn_time: float = 0.6
@export var wave_warn_interval: float = 2.5
@export var drop_shard_on_purify: bool = true

var _start_position: Vector2
var _patrol_direction: int = 1
var _is_dead: bool = false
var _is_purified: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _wave_warn_timer: float = 0.0
var _is_warning: bool = false
var _warning_flash_timer: float = 0.0

# Chase state
enum State { PATROL, CHASE, WARNING }
var _state: State = State.PATROL
var _player_ref: Node2D = null
var _chase_cooldown: float = 0.0

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

	# Update player reference and chase logic
	_update_player_detection()
	_update_state(delta)

	# State-specific behavior
	match _state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.WARNING:
			_process_warning(delta)

	# Gravity
	velocity.y += get_gravity().y * delta
	velocity.y = minf(velocity.y, 200.0)

	move_and_slide()

	# Turn around if hitting a wall
	if is_on_wall():
		_patrol_direction *= -1

func _update_player_detection() -> void:
	var tree := get_tree()
	if not tree:
		return
	
	_player_ref = tree.get_first_node_in_group("player") as Node2D

func _update_state(delta: float) -> void:
	if not _player_ref:
		_state = State.PATROL
		return

	var dist_to_player := global_position.distance_to(_player_ref.global_position)
	var player_in_chase_range := dist_to_player <= chase_range
	var player_in_lose_range := dist_to_player <= lose_interest_range

	match _state:
		State.PATROL:
			if player_in_chase_range:
				_state = State.WARNING
				_start_warning()
		State.WARNING:
			if not player_in_chase_range:
				_state = State.PATROL
				_end_warning()
		State.CHASE:
			if not player_in_lose_range:
				_state = State.PATROL
				_chase_cooldown = 0.0

func _process_patrol(delta: float) -> void:
	# Wave warning logic (only in patrol)
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

	# Flip sprite based on movement direction
	if _sprite:
		_sprite.flip_h = move_dir < 0

	# Turn around at patrol bounds
	if absf(global_position.x - _start_position.x) >= patrol_range:
		_patrol_direction *= -1

func _process_chase(delta: float) -> void:
	if not _player_ref:
		return

	var chase_dir := signf(_player_ref.global_position.x - global_position.x)
	velocity.x = chase_dir * chase_speed + _knockback_velocity.x

	# Face player
	if _sprite:
		_sprite.flip_h = chase_dir < 0

	# Chase visual: slightly redder
	if _sprite and _sprite.modulate == Color.WHITE:
		_sprite.modulate = Color("#E86D5A").lerp(Color.WHITE, 0.5)

func _process_warning(delta: float) -> void:
	# Stop and flash warning
	velocity.x = _knockback_velocity.x
	_warning_flash_timer -= delta
	_update_warning_visuals()

	if _warning_flash_timer <= 0:
		_end_warning()
		_state = State.CHASE

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
	if _sprite and _state != State.CHASE:
		_sprite.modulate = Color.WHITE

func _update_warning_visuals() -> void:
	if not _sprite:
		return
	var flash_progress := 1.0 - (_warning_flash_timer / wave_warn_time)
	var flash := int(flash_progress * 10.0) % 2 == 0
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

	# Show damage number on hit
	_DamageNumberScript.spawn(get_tree().current_scene, global_position + Vector2(0, -12), amount, _DamageNumberScript.Kind.DMG)

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

	# Stats tracking
	PlayerStats.record_enemy_purified("silence_mote")

	# Show purification number (Amber Voice, custom "净化" text)
	_DamageNumberScript.spawn(get_tree().current_scene, global_position + Vector2(0, -16), 0, _DamageNumberScript.Kind.PURIFY, "净化")

	# Spawn purification VFX
	var vfx := _RepairVFXScript.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 24.0)

	# Drop shard if enabled
	if drop_shard_on_purify:
		_drop_shard()

	# Visual: turn warm and float up
	if _sprite:
		# Try to load purified texture
		var purified_tex := load("res://assets/sprites/silence_mote_purified.png") as Texture2D
		if purified_tex:
			_sprite.texture = purified_tex
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.0, 1.0)
		tween.tween_callback(_finish_death)

	# Disable hurtbox
	if _hurtbox:
		_hurtbox.monitoring = false
	if _collision:
		_collision.disabled = true

func _drop_shard() -> void:
	var shard_scene := load("res://src/scenes/resonance_shard.tscn") as PackedScene
	if shard_scene:
		var shard := shard_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(shard)
		shard.global_position = global_position
		# Launch upward with slight horizontal spread
		var launch_vel := Vector2(randf_range(-40, 40), randf_range(-120, -80))
		shard.launch(launch_vel)
	else:
		# Fallback: directly give player a shard
		GameState.add_shards(1)
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_repair_hint"):
			hud.show_repair_hint("+1◆")

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
