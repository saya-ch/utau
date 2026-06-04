class_name InkWarden
extends CharacterBody2D

signal died
signal damaged
signal shield_broken
signal stunned

@export var patrol_speed: float = 25.0
@export var patrol_range: float = 50.0
@export var chase_speed: float = 45.0
@export var chase_range: float = 100.0
@export var lose_interest_range: float = 160.0
@export var health: int = 5
@export var contact_damage: int = 2
@export var knockback_resistance: float = 0.6
@export var shield_health: int = 3
@export var stun_duration: float = 2.5
@export var projectile_cooldown: float = 2.0
@export var projectile_speed: float = 50.0

var _start_position: Vector2
var _patrol_direction: int = 1
var _is_dead: bool = false
var _is_purified: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _shield_active: bool = true
var _is_stunned: bool = false
var _stun_timer: float = 0.0
var _projectile_timer: float = 0.0

enum State { PATROL, CHASE, STUNNED }
var _state: State = State.PATROL
var _player_ref: Node2D = null

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _shield_vfx: Node2D = $ShieldVFX

# T067 — Boss music override is ref-counted in AudioManagerEnhanced.
# We track whether THIS instance ever requested an override, so the
# _exit_tree cleanup only decrements the counter if we were the ones
# who incremented it.  Without this flag, a boss that died normally
# (calling release_boss_music in _purify) would double-decrement
# on _exit_tree and end up with a negative override count.
var _requested_boss_music: bool = false

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("elite_enemies")
	_start_position = global_position
	_projectile_timer = randf() * projectile_cooldown

	if _hurtbox:
		_hurtbox.body_entered.connect(_on_hurtbox_body_entered)

	_update_shield_visuals()

	# T071 — Request boss music when an InkWarden is alive in the
	# scene.  The AudioManagerEnhanced transparently overrides the
	# GFC's standard "archive_exploration" routing until the boss
	# is purified.  Defensive has_method check: AudioManagerEnhanced
	# is an autoload that always exists at runtime, but smoke tests
	# can run without the full autoload chain registered.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("request_boss_music"):
		ame.call("request_boss_music", "archive_boss", 800)
		_requested_boss_music = true

func _exit_tree() -> void:
	# T067 — If we left the scene tree without being purified
	# (e.g. the player left the room mid-fight, the JsonRoom was
	# unloaded, or the room is being reset), release the boss
	# music override we requested in _ready.  Only decrements
	# once per InkWarden instance thanks to _requested_boss_music,
	# so a normal purify() flow isn't double-counted.
	if _requested_boss_music and not _is_purified:
		var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
		if ame and ame.has_method("release_boss_music"):
			ame.call("release_boss_music", 400)
		_requested_boss_music = false

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
	
	if _is_stunned:
		_stun_timer -= delta
		velocity.x = _knockback_velocity.x
		velocity.y += get_gravity().y * delta
		velocity.y = minf(velocity.y, 200.0)
		move_and_slide()
		if _stun_timer <= 0:
			_end_stun()
		return
	
	# Update player reference and state logic
	_update_player_detection()
	_update_state(delta)
	
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
	
	# Projectile logic (only when shield is broken)
	if not _shield_active and _state == State.CHASE:
		_projectile_timer -= delta
		if _projectile_timer <= 0:
			_fire_projectile()
			_projectile_timer = projectile_cooldown

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
				_state = State.CHASE
		State.CHASE:
			if not player_in_lose_range:
				_state = State.PATROL
		State.STUNNED:
			pass

func _process_patrol(delta: float) -> void:
	var target_x := _start_position.x + _patrol_direction * patrol_range
	var move_dir := signf(target_x - global_position.x)
	
	velocity.x = move_dir * patrol_speed + _knockback_velocity.x
	
	if _sprite:
		_sprite.flip_h = move_dir < 0
	
	if absf(global_position.x - _start_position.x) >= patrol_range:
		_patrol_direction *= -1

func _process_chase(delta: float) -> void:
	if not _player_ref:
		return
	
	var chase_dir := signf(_player_ref.global_position.x - global_position.x)
	velocity.x = chase_dir * chase_speed + _knockback_velocity.x
	
	if _sprite:
		_sprite.flip_h = chase_dir < 0
	
	# Chase visual: slightly redder
	if _sprite and _sprite.modulate == Color.WHITE:
		_sprite.modulate = Color("#E86D5A").lerp(Color.WHITE, 0.3)

func _fire_projectile() -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	
	var dir := (player.global_position - global_position).normalized()
	var proj := NoteProjectile.new()
	proj.direction = dir
	proj.speed = projectile_speed
	proj.modulate = Color("#E86D5A")  # coral projectiles
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position + Vector2(0, -16)

func take_damage(amount: int, knockback: Vector2) -> void:
	if _is_dead or _is_purified or _is_stunned:
		return

	if _shield_active:
		shield_health -= amount
		_knockback_velocity = knockback * (1.0 - knockback_resistance)
		_flash_shield()
		# Show shield damage (Glass Cyan, custom "盾" text)
		DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -12), amount, DamageNumber.Kind.SHIELD, "盾")
		if shield_health <= 0:
			_break_shield()
		return

	health -= amount
	_knockback_velocity = knockback * (1.0 - knockback_resistance)

	damaged.emit()

	# Show damage number on hit
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -12), amount, DamageNumber.Kind.DMG)

	if health <= 0:
		_purify()
	else:
		if _sprite:
			_sprite.modulate = Color("#E86D5A")
			await get_tree().create_timer(0.1).timeout
			if _sprite and not _is_dead and not _is_purified and not _is_stunned:
				_sprite.modulate = Color.WHITE

func _break_shield() -> void:
	_shield_active = false
	shield_broken.emit()

	# Show shield-break notification (Amber Voice, custom "破盾" text)
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -36), 0, DamageNumber.Kind.PURIFY, "破盾")

	# Visual feedback
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_shield_broken.png") as Texture2D
		if tex:
			_sprite.texture = tex
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#E86D5A"), 0.1)
		tween.tween_property(_sprite, "modulate", Color.WHITE, 0.3)
	
	# Shield break VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 40.0)
	
	# Enter stun
	_enter_stun()

func _enter_stun() -> void:
	_is_stunned = true
	_state = State.STUNNED
	_stun_timer = stun_duration
	stunned.emit()
	
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_stunned.png") as Texture2D
		if tex:
			_sprite.texture = tex
		_sprite.modulate = Color.WHITE
	
	# Stun VFX: stars/spiral
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position + Vector2(0, -32), 16.0)

func _end_stun() -> void:
	_is_stunned = false
	_state = State.CHASE
	
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_shield_broken.png") as Texture2D
		if tex:
			_sprite.texture = tex
		_sprite.modulate = Color.WHITE

func _flash_shield() -> void:
	if _shield_vfx:
		_shield_vfx.visible = true
		var tween := create_tween()
		tween.tween_property(_shield_vfx, "modulate:a", 1.0, 0.05)
		tween.tween_property(_shield_vfx, "modulate:a", 0.0, 0.2)
		await tween.finished
		_shield_vfx.visible = false

func _update_shield_visuals() -> void:
	if _shield_vfx:
		_shield_vfx.visible = _shield_active
		# Faint visible shield when active; fully invisible when broken
		_shield_vfx.modulate.a = 0.6 if _shield_active else 0.0

func _purify() -> void:
	_is_purified = true

	# Stats tracking
	PlayerStats.record_enemy_purified("ink_warden")

	# T071 — Release boss music override when the InkWarden is
	# defeated.  The next GFC state change (e.g. ROOM_TRANSITION
	# → hub) will pick the appropriate track for the new scene.
	# If the room is finished in-place and GFC enters GAME_OVER,
	# stop_music(1200) is the right call.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("release_boss_music"):
		ame.call("release_boss_music", 1200)

	# Show purification number (Amber Voice, custom "净化" text — larger Ink Warden defeat)
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -24), 0, DamageNumber.Kind.PURIFY, "净化")

	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 32.0)
	
	# Drop multiple shards
	for i in range(3):
		_drop_shard(Vector2(randf_range(-60, 60), randf_range(-140, -100)))
	
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.0, 1.2)
		tween.tween_callback(_finish_death)
	
	if _hurtbox:
		_hurtbox.monitoring = false
	if _collision:
		_collision.disabled = true

func _drop_shard(launch_vel: Vector2) -> void:
	var shard_scene := load("res://src/scenes/resonance_shard.tscn") as PackedScene
	if shard_scene:
		var shard := shard_scene.instantiate() as ResonanceShard
		get_tree().current_scene.add_child(shard)
		shard.global_position = global_position
		shard.launch(launch_vel)
	else:
		GameState.add_shards(1)
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_repair_hint"):
			hud.show_repair_hint("+1◆")

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
