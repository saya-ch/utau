class_name PulseAbility
extends "res://src/scripts/_verb_ability_base.gd"

signal pulse_fired(origin: Vector2, radius: float)
signal pulse_hit(target: Node, knockback: Vector2)
signal pulse_blocked

@export var pulse_radius: float = 48.0
@export var pulse_cost: int = 15
@export var cooldown: float = 0.5
# T166 (#85) — Bumped 0.08s → 0.10s so the pre-pulse windup VFX
# (pulse_windup_vfx.gd) has a readable window.  Matches Bind's
# windup_time (0.1s) so all 4 verb windups share the same "tell"
# pacing — players learn "ring appears for 0.10s → verb fires" once
# and apply it to all 4 verbs.
@export var windup_time: float = 0.10
@export var active_time: float = 0.12
@export var knockback_force: float = 200.0
@export var damage: int = 1

# T068 — Sourced from GameState.get_pulse_kill_refund() at _ready.
# When > 0, every Pulse-kill refunds this much resonance. Set by
# the echo_charm perk in data/shop_catalog.json.
var pulse_kill_refund: int = 0

# D002.B (#97) — _cooldown_timer / _windup_timer / _is_winding_up /
# _pending_origin / _pending_direction / _windup_vfx are now inherited
# from VerbAbilityBase (was: redeclared in 5 verb files byte-identical).
# See _verb_ability_base.gd for the shared state + 6 shared methods
# (_consume_verb_cost / _setup_windup_state / _exit_tree / etc.).

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "PulseAbility must be child of CharacterBody2D")
	# T068 — Apply shop-bought pulse radius bonus.  Sums onto the
	# exported base value so .tscn overrides still win for the default
	# gameplay; perks stack additively on top.
	if _has_game_state_autoload():
		pulse_radius += GameState.get_pulse_radius_bonus()
		damage += GameState.get_damage_bonus()
		pulse_kill_refund = GameState.get_pulse_kill_refund()

func _has_game_state_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("GameState")

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
	
	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_pulse()

func can_pulse() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= pulse_cost and not _is_winding_up

func start_pulse(origin: Vector2, direction: Vector2) -> bool:
	# F007 (#87) — Pre-fire guard.  The 4 verb abilities all share the
	# same 2-step "can-fire + pay-cost" gate (pulse / bind / cut / echo).
	# GDScript has no easy cross-script class inheritance for plain Node,
	# so each ability carries its own _consume_verb_cost() helper.  See
	# bind_ability.gd / cut_ability.gd / echo_ability.gd for the matching
	# copies — all 4 implementations are byte-identical so future 5th-verb
	# additions can copy-paste.
	if not can_pulse():
		return false

	if not _consume_verb_cost(pulse_cost):
		return false

	# F007 (#87) — Same shared windup-state setup, byte-identical copy in
	# the other 3 verb abilities.  See _consume_verb_cost note.
	_setup_windup_state(origin, direction, windup_time)

	# T166 (#85) — Spawn the pre-pulse windup VFX at the predicted origin
	# so the player sees a 0.5× Glass Cyan ring grow inward for 0.10s
	# before the fire VFX (pulse_vfx.gd) explodes outward.  Parented to
	# the current scene (not the player) so its world position stays
	# stable if the player keeps moving during windup.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance (shouldn't happen
		# since start_pulse() rejects if can_pulse()==false, but cheap
		# insurance against state corruption).
		_windup_vfx.queue_free()
	_windup_vfx = preload("res://src/scripts/pulse_windup_vfx.gd").new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		_windup_vfx.trigger(origin, pulse_radius * 0.5, windup_time)

	return true

func _execute_pulse() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T166 (#85) — Free the windup VFX *before* emitting pulse_fired so
	# the fire VFX (spawned in player._on_pulse_fired) replaces the
	# windup ring in the same frame — no 1-frame overlap.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking
	PlayerStats.record_ability_used("pulse")

	# Emit signal for VFX
	pulse_fired.emit(_pending_origin, pulse_radius)

	# F004 (#94) — Play Pulse audio cue paired with the fire-VFX frame
	# (pulse_vfx.gd's expanding Coral ring).  Without this caller, the
	# Pulse was visually + mechanically present but silently "fire"
	# (audio desync, since the other 4 verb hit handlers implicitly
	# rely on chain audio that Pulse's first-position breaks).  The
	# audio stream is read from AudioManagerEnhanced._pulse_stream
	# (lazy-allocated by the manager itself — no need to pass audio
	# params from here).  Uses AudioManagerEnhanced (autoload) rather
	# than the older AudioManager singleton so Pulse gets the 5-verb
	# audio closure (T181 #95 candidate).  Guarded by is_instance_valid
	# on _player so an interrupted windup (player freed by death
	# during the 0.10s windup) doesn't crash on a stale reference.
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_pulse()

	# Perform collision detection
	_perform_pulse_hit_check()

func _perform_pulse_hit_check() -> void:
	var space_state := _player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = pulse_radius
	query.shape = circle
	query.transform = Transform2D(0, _pending_origin)
	query.collision_mask = 0b11100  # Layers 3 (Enemy), 4 (Hazard), 5 (Interactable)
	
	var results := space_state.intersect_shape(query, 16)
	
	for result in results:
		var collider := result["collider"] as Node
		if collider == null:
			continue
		
		var hit_pos: Vector2 = result["point"] if result.has("point") else collider.global_position
		var knockback_dir := (hit_pos - _pending_origin).normalized()
		if knockback_dir == Vector2.ZERO:
			knockback_dir = _pending_direction
		
		var knockback := knockback_dir * knockback_force
		
		# Apply damage/knockback to enemies
		if collider.is_in_group("enemies"):
			_apply_enemy_hit(collider, knockback)
		# Trigger interactables (glass locks, etc)
		elif collider.is_in_group("interactable"):
			_trigger_interactable(collider)
		# Repel hazards
		elif collider.is_in_group("hazards"):
			_apply_hazard_repel(collider, knockback)
	
	# Also check for enemy projectiles in range (Area2D, not in physics layers)
	for proj in get_tree().get_nodes_in_group("enemy_projectiles"):
		if proj.global_position.distance_to(_pending_origin) <= pulse_radius:
			if proj.has_method("queue_free"):
				var vfx := RepairVFX.new()
				get_tree().current_scene.add_child(vfx)
				vfx.trigger(proj.global_position, 8.0)
				proj.queue_free()
	
	pulse_hit.emit(null, Vector2.ZERO)

func _apply_enemy_hit(enemy: Node, knockback: Vector2) -> void:
	# T068 — Snapshot enemy health before damage so we can detect
	# a kill and refund resonance (echo_charm perk).  Both
	# SilenceMote and InkWarden expose `health`; unknown enemies
	# fall through to the no-refund branch.
	var was_alive: bool = false
	if enemy.has_method("get") and "health" in enemy:
		was_alive = int(enemy.get("health")) > 0

	if enemy.has_method("take_damage"):
		enemy.take_damage(damage, knockback)

	# Refund if the hit killed the enemy and the perk is active.
	if was_alive and pulse_kill_refund > 0:
		var still_alive: bool = true
		if "health" in enemy:
			still_alive = int(enemy.get("health")) > 0
		if not still_alive:
			GameState.restore_resonance(pulse_kill_refund)
			var hud = get_tree().get_first_node_in_group("hud")
			if hud and hud.has_method("show_repair_hint"):
				hud.show_repair_hint("+%d 共鸣 (回响)" % pulse_kill_refund)

	pulse_hit.emit(enemy, knockback)

func _trigger_interactable(obj: Node) -> void:
	if obj.has_method("on_pulse_triggered"):
		obj.on_pulse_triggered()

func _apply_hazard_repel(hazard: Node, knockback: Vector2) -> void:
	if hazard.has_method("repel"):
		hazard.repel(knockback)

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up

# T166 (#85) — Clean up the windup VFX if the player / scene is freed
# mid-windup (e.g. on a room transition while the windup tween is still
# ticking).  Without this, the VFX node would stay parented to a
# freed scene and crash on its next _process tick.
#
# T173 (#92) — _exit_tree() now inherited from VerbAbilityBase (was:
# defined byte-identical in 5 verb files).  Switched from hard
# queue_free() to fade_out_and_free() (0.05s modulate.a 1→0 tween then
# free).  Avoids a "hard pop" when the verb is interrupted (player
# death, room transition during the 0.10s windup window).  See
# pulse_windup_vfx.gd:fade_out_and_free for the contract.

# D002.B (#97) — _consume_verb_cost / _setup_windup_state now inherited
# from VerbAbilityBase.  Byte-identical implementation lives in the
# base.  Subclasses no longer need to redefine.
