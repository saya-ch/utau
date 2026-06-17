class_name BindAbility
extends "res://src/scripts/_verb_ability_base.gd"

# D002.B (#98) — Now extends VerbAbilityBase, which owns the common
# cooldown timer + windup-state setup + cost consume + _process +
# _exit_tree fade-out + cooldown jingle (T181 #97).  Verb-specific
# state (`bind_radius` / `bind_cost` / `bind_duration` / `pull_force`)
# and verb-specific logic (`can_bind` / `start_bind` /
# `_execute_bind` / `_perform_bind_hit_check` / `_spawn_windup_vfx`)
# remain here.  Pre-D002.B state (5 vars + 5 common functions) all
# moved to / inherited from the base — see _verb_ability_base.gd.

signal bind_fired(origin: Vector2, radius: float)
signal bind_hit(target: Node)
signal bind_blocked

@export var bind_radius: float = 40.0
@export var bind_cost: int = 20
@export var active_time: float = 0.15
@export var bind_duration: float = 3.0
@export var pull_force: float = 80.0

func _ready() -> void:
	# D002.B (#98) — Parent VerbAbilityBase._ready() asserts
	# _player is non-null; subclass _ready extends with the
	# per-verb @export defaults + Bind takes no direct damage
	# bonuses (T068).
	super._ready()
	# D002.B (#98) — Per-verb @export defaults.  See _verb_ability_base.gd.
	cooldown = 1.2
	windup_time = 0.1
	# T068 — Bind doesn't take direct damage bonuses (it's a pull/stun
	# effect, not a kill path).  The echo_charm perk refund is Pulse-only.

# D002.B (#98) — `_process` is now in the base (cooldown timer +
# cooldown jingle + windup timer + _execute dispatch).  This
# subclass no longer needs a _process override.

# D002.B (#98) — Virtual override.  Returns "bind" for the
# T181 cooldown jingle (C5 → E5 ascending major-3rd, 0.10s).
func _get_verb_name() -> String:
	return "bind"

func can_bind() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= bind_cost and not _is_winding_up

func start_bind(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  Now inherits the 2-step
	# "can-fire + pay-cost" gate from the base.
	if not can_bind():
		return false

	if not _consume_verb_cost(bind_cost):
		return false

	# D002.B (#98) — Windup-state setup now in base; subclass just
	# calls it.
	_setup_windup_state(origin, direction)

	# D002.B (#98) — Windup VFX spawn now in `_spawn_windup_vfx()`
	# virtual; this subclass implements the verb-specific preload
	# + trigger args.  See _spawn_windup_vfx() below.
	_spawn_windup_vfx()

	return true

# D002.B (#98) — `_execute` virtual from base.  Subclass implements
# the verb-specific happy-path body.
func _execute() -> void:
	_execute_bind()

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

	# T181 (#97 first half) — Play Bind fire audio cue paired with
	# the fire-VFX frame (bind_vfx.gd's contracting violet spiral).
	# Mirrors the Pulse caller in pulse_ability.gd:_execute_pulse
	# (F004 #94) which fires AFTER pulse_fired.emit.  Closes the
	# 5-verb audio family loop: Pulse (F004 #94) + Bind (T181 #97) +
	# Cut (T181 #97) + Echo (T181 #97) + Wave (T181 #97) all play
	# fire SFX synchronously with the fire-VFX.  AudioManagerEnhanced
	# is an autoload (no `is null` guard needed in normal play) but
	# we still guard with _player-validity so an interrupted windup
	# (player freed by death during the 0.10s windup) doesn't crash
	# on a stale reference.  See _generate_bind_sfx (F004.B #96) for
	# timbre: 220→165Hz pull drone (0.40s).
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_bind()

	_perform_bind_hit_check()

# D002.B (#98) — `_spawn_windup_vfx` virtual from base.  Subclass
# implements the verb-specific spawn.
func _spawn_windup_vfx() -> void:
	_attach_windup_vfx(preload("res://src/scripts/bind_windup_vfx.gd"))
	_windup_vfx.trigger(_pending_origin, bind_radius * 0.5, windup_time)

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

# D002.B (#98) — `_consume_verb_cost` / `_setup_windup_state` /
# `_exit_tree` / `get_cooldown_ratio` / `is_winding_up` all moved to
# the base (VerbAbilityBase).  This subclass inherits them verbatim.
# The pre-D002.B copies (F007 #87 + T167 #86 + T173 #92) are deleted
# from this file.
