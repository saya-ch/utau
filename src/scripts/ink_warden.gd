class_name InkWarden
extends CharacterBody2D

signal died
signal damaged
signal shield_broken

@export var patrol_speed: float = 25.0
@export var chase_speed: float = 45.0
@export var chase_range: float = 100.0
@export var lose_interest_range: float = 160.0
@export var health: int = 5
@export var contact_damage: int = 2
@export var knockback_resistance: float = 0.6
@export var shield_pulses_required: int = 2
@export var stun_duration: float = 2.5
@export var drop_shard_on_death: bool = true
@export var shard_drop_count: int = 3

var _start_position: Vector2
var _patrol_direction: int = 1
var _is_dead: bool = false
var _is_purified: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO

# Shield state
var _shield_active: bool = true
var _shield_hits: int = 0

# Stun state
var _is_stunned: bool = false
var _stun_timer: float = 0.0

# Chase state
enum State { PATROL, CHASE, STUNNED }
var _state: State = State.PATROL
var _player_ref: Node2D = null

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _shield_visual: Node2D = $ShieldVisual

func _ready() -> void:
	add_to_group("enemies")
	_start_position = global_position
	
	if _hurtbox:
		_hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	
	_update_shield_visual()

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	# Apply knockback decay
	_knockback_velocity = _knockback_velocity.lerp(Vector2.ZERO, 4.0 * delta)
	
	if _is_purified:
		velocity.y = -30.0
		velocity.x = _knockback_velocity.x
		move_and_slide()
		return
	
	# Handle stun
	if _is_stunned:
		_stun_timer -= delta
		if _stun_timer <= 0:
			_end_stun()
		else:
			# Stunned: only apply knockback, no movement
			velocity.x = _knockback_velocity.x
			velocity.y += get_gravity().y * delta
			velocity.y = minf(velocity.y, 200.0)
			move_and_slide()
			return
	
	# Update player reference and state
	_update_player_detection()
	_update_state()
	
	# State-specific behavior
	match _state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.STUNNED:
			pass  # handled above
	
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

func _update_state() -> void:
	if not _player_ref:
		_state = State.PATROL
		return
	
	var dist_to_player := global_position.distance_to(_player_ref.global_position)
	var player_in_chase_range := dist_to_player <= chase_range
	var player_in_lose_range := dist_to_player <= lose_interest_range
	
	match _state:
		State.PATROL:
			if player_in_chase_range:
				_state = State.CHASE
		State.CHASE:
			if not player_in_lose_range:
				_state = State.PATROL

func _process_patrol(delta: float) -> void:
	var target_x := _start_position.x + _patrol_direction * 60.0
	var move_dir := signf(target_x - global_position.x)
	
	velocity.x = move_dir * patrol_speed + _knockback_velocity.x
	
	if _sprite:
		_sprite.flip_h = move_dir < 0
	
	if absf(global_position.x - _start_position.x) >= 60.0:
		_patrol_direction *= -1

func _process_chase(delta: float) -> void:
	if not _player_ref:
		return
	
	var chase_dir := signf(_player_ref.global_position.x - global_position.x)
	velocity.x = chase_dir * chase_speed + _knockback_velocity.x
	
	if _sprite:
		_sprite.flip_h = chase_dir < 0
	
	# Chase visual: shield glows more intensely
	if _shield_active and _shield_visual:
		_shield_visual.modulate = Color("#69C7CE").lerp(Color.WHITE, 0.3)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if _is_dead or _is_purified:
		return
	
	# If shield is active, absorb the hit
	if _shield_active:
		_shield_hits += 1
		_knockback_velocity = knockback * (1.0 - knockback_resistance)
		
		# Visual feedback: shield flash
		if _shield_visual:
			_shield_visual.modulate = Color("#F2B66E")
			await get_tree().create_timer(0.1).timeout
			if _shield_visual:
				_update_shield_visual()
		
		# Check if shield breaks
		if _shield_hits >= shield_pulses_required:
			_break_shield()
		
		damaged.emit()
		return
	
	# Shield is down, take real damage
	health -= amount
	_knockback_velocity = knockback * (1.0 - knockback_resistance)
	
	damaged.emit()
	
	if health <= 0:
		_purify()
	else:
		# Flash red on damage
		if _sprite:
			_sprite.modulate = Color("#E86D5A")
			await get_tree().create_timer(0.1).timeout
			if _sprite and not _is_dead and not _is_purified:
				_sprite.modulate = Color.WHITE

func _break_shield() -> void:
	_shield_active = false
	shield_broken.emit()
	
	# Visual: shield shatters
	if _shield_visual:
		var tween := create_tween()
		tween.tween_property(_shield_visual, "modulate:a", 0.0, 0.3)
		tween.tween_property(_shield_visual, "scale", Vector2(1.5, 1.5), 0.3)
		tween.tween_callback(_hide_shield_visual)
	
	# Spawn shield break VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 32.0)
	
	# Enter stun
	_start_stun()
	
	# HUD hint
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("护盾已击破!")

func _start_stun() -> void:
	_is_stunned = true
	_stun_timer = stun_duration
	_state = State.STUNNED
	
	# Visual: stunned - dizzy/swirl effect via modulate
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#B7E7DD"), 0.2)
		# Brief scale pulse to show impact
		tween.tween_property(_sprite, "scale", Vector2(0.9, 0.9), 0.1)
		tween.tween_property(_sprite, "scale", Vector2(1.0, 1.0), 0.1)

func _end_stun() -> void:
	_is_stunned = false
	_state = State.PATROL
	
	# Visual: return to normal
	if _sprite:
		_sprite.modulate = Color.WHITE

func _hide_shield_visual() -> void:
	if _shield_visual:
		_shield_visual.visible = false

func _update_shield_visual() -> void:
	if not _shield_visual:
		return
	if _shield_active:
		_shield_visual.visible = true
		_shield_visual.modulate = Color("#69C7CE")
		_shield_visual.scale = Vector2(1.0, 1.0)
	else:
		_shield_visual.visible = false

func _purify() -> void:
	_is_purified = true
	
	# Spawn purification VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 32.0)
	
	# Drop shards
	if drop_shard_on_death:
		_drop_shards()
	
	# Visual: turn warm and float up
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.0, 1.5)
		tween.tween_callback(_finish_death)
	
	# Disable hurtbox
	if _hurtbox:
		_hurtbox.monitoring = false
	if _collision:
		_collision.disabled = true

func _drop_shards() -> void:
	var shard_scene := load("res://src/scenes/resonance_shard.tscn") as PackedScene
	if not shard_scene:
		# Fallback: directly give shards
		GameState.add_shards(shard_drop_count)
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_repair_hint"):
			hud.show_repair_hint("+%d◆" % shard_drop_count)
		return
	
	for i in range(shard_drop_count):
		var shard := shard_scene.instantiate() as ResonanceShard
		get_tree().current_scene.add_child(shard)
		shard.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-5, 5))
		var launch_vel := Vector2(randf_range(-60, 60), randf_range(-140, -100))
		shard.launch(launch_vel)

func _finish_death() -> void:
	_is_dead = true
	died.emit()
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if _is_dead or _is_purified or _is_stunned:
		return
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var knockback_dir := (body.global_position - global_position).normalized()
			body.take_damage(contact_damage, knockback_dir * 120.0)

func repel(force: Vector2) -> void:
	_knockback_velocity += force
