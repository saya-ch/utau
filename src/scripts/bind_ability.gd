class_name BindAbility
extends VerbAbilityBase

signal bind_fired(origin: Vector2, radius: float)
signal bind_hit(target: Node)
signal bind_blocked

@export var bind_radius: float = 40.0
@export var bind_cost: int = 20
@export var active_time: float = 0.15
@export var bind_duration: float = 3.0
@export var pull_force: float = 80.0

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "BindAbility must be child of CharacterBody2D")
	# T068 — Bind doesn't take direct damage bonuses (it's a pull/stun
	# effect, not a kill path).  The echo_charm perk refund is Pulse-only.

# D002.B (#98) — _process delegated to base (cooldown tick + cross-
# frame jingle + windup tick all owned by VerbAbilityBase).  Bind
# has no verb-specific _on_extra_process work.
func _process(delta: float) -> void:
	super(delta)

func can_bind() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= bind_cost and not _is_winding_up and _can_fire_extra()

func start_bind(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  The 2-step "can-fire + pay-cost"
	# gate is now in the base (F007 #87 shared contract).
	if not can_bind():
		return false

	if not _consume_verb_cost(bind_cost):
		return false

	_setup_windup_state(origin, direction)

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

# D002.B (#98) — _on_windup_expired (was _execute_bind) — verb-specific
# fire logic.  Calls _execute_verb_common() for shared bookkeeping.
func _on_windup_expired() -> void:
	_execute_verb_common()

	# T167 (#86) — Free the windup VFX *before* emitting bind_fired so
	# the bind effect (handled in player._on_bind_fired) replaces the
	# windup spiral in the same frame — no 1-frame overlap.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	bind_fired.emit(_pending_origin, bind_radius)

	# T181 (#97) — Play Bind fire audio cue paired with the fire-VFX
	# frame (bind_vfx.gd's contracting violet spiral).  See
	# _generate_bind_sfx (F004.B #96) for timbre: 220→165Hz pull drone
	# (0.40s).  Guarded by _player-validity.
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

# D002.B (#98) — verb cost / verb name virtuals (overrides base).
func get_verb_cost() -> int:
	return bind_cost

func get_verb_name() -> StringName:
	return &"bind"
