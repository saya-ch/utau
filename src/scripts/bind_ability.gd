class_name BindAbility
extends "res://src/scripts/_verb_ability_base.gd"

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

# D002.B (#97) — _cooldown_timer / _windup_timer / _is_winding_up /
# _pending_origin / _pending_direction / _windup_vfx are now inherited
# from VerbAbilityBase.  See _verb_ability_base.gd for shared state.

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "BindAbility must be child of CharacterBody2D")
	# T068 — Bind doesn't take direct damage bonuses (it's a pull/stun
	# effect, not a kill path).  The echo_charm perk refund is Pulse-only.

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
	# F007 (#87) — Pre-fire guard.  See pulse_ability.start_pulse() for the
	# shared 2-step "can-fire + pay-cost" gate rationale.  Each verb
	# carries its own _consume_verb_cost() helper (GDScript limitation).
	if not can_bind():
		return false

	if not _consume_verb_cost(bind_cost):
		return false

	# F007 (#87) — Shared windup-state setup.  See _consume_verb_cost.
	_setup_windup_state(origin, direction, windup_time)

	# T167 (#86) — Spawn the pre-bind windup VFX at the predicted origin
	# so the player sees a 0.5× Muted Violet spiral draw inward for
	# 0.10s before the bind_vfx.gd pulls the targets in.  Parented to
	# the current scene (not the player) so its world position stays
	# stable if the player keeps moving during windup.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance.
		_windup_vfx.queue_free()
	_windup_vfx = preload("res://src/scripts/bind_windup_vfx.gd").new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		_windup_vfx.trigger(origin, bind_radius * 0.5, windup_time)

	return true

func _execute_bind() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T167 (#86) — Free the windup VFX *before* emitting bind_fired so
	# the bind effect (handled in player._on_bind_fired) replaces the
	# windup spiral in the same frame — no 1-frame overlap.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking
	PlayerStats.record_ability_used("bind")

	bind_fired.emit(_pending_origin, bind_radius)

	# T181 (#97) — Play Bind fire audio cue paired with bind_fired. Closes
	# the 5-verb audio family loop (F004 #94 Pulse + F004.B #96 4 verb
	# function definition layer).  Stream is lazy-allocated by the manager
	# itself on first call.  Mirrors pulse_ability._execute_pulse F004
	# caller.  Bind 220Hz low rumble matches the Bind windup VFX spiral
	# motif (#86 T167).  Guarded by is_instance_valid on _player so an
	# interrupted windup (player freed by death during the 0.10s windup)
	# doesn't crash on a stale reference.
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_bind()

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
	var pull_dir: Vector2 = (_pending_origin - enemy.global_position).normalized()
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

# T167 (#86) — Clean up the windup VFX if the player / scene is freed
# mid-windup (e.g. on a room transition while the windup tween is
# still ticking).  Without this, the VFX node would stay parented to
# a freed scene and crash on its next _process tick.  Pattern mirrors
# pulse_ability._exit_tree() (T166 #85).
#
# T173 (#92) — Switched from hard queue_free() to fade_out_and_free()
# (0.05s modulate.a 1→0 tween then free).  Avoids a "hard pop" when
# the verb is interrupted (player death, room transition during the
# 0.10s windup window).  See bind_windup_vfx.gd:fade_out_and_free
# for the contract.
#
# D002.B (#97) — _exit_tree() / _consume_verb_cost / _setup_windup_state
# now inherited from VerbAbilityBase.  Byte-identical implementation
# lives in the base.  Subclasses no longer need to redefine.
