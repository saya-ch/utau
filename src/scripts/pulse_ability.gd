class_name PulseAbility
extends "res://src/scripts/_verb_ability_base.gd"

# D002.B (#98) — Now extends VerbAbilityBase, which owns the common
# cooldown timer + windup-state setup + cost consume + _process +
# _exit_tree fade-out + cooldown jingle (T181 #97).  Verb-specific
# state (`pulse_radius` / `pulse_cost` / `knockback_force` / `damage`
# / `pulse_kill_refund`) and verb-specific logic (`can_pulse` /
# `start_pulse` / `_execute_pulse` / `_perform_pulse_hit_check` /
# `_spawn_windup_vfx`) remain here.  Subclass responsibilities
# documented in _verb_ability_base.gd.
#
# Pre-D002.B state (5 vars: `_cooldown_timer` / `_windup_timer` /
# `_is_winding_up` / `_pending_origin` / `_pending_direction` +
# `_windup_vfx`) all moved to the base.  Common functions
# (`_consume_verb_cost` / `_setup_windup_state` / `_exit_tree` /
# `get_cooldown_ratio` / `is_winding_up`) all deleted from this
# file (now inherited).  This is the D002推全 that T174.B (#94)
# validated the pattern for on 5 windup VFX files.

signal pulse_fired(origin: Vector2, radius: float)
signal pulse_hit(target: Node, knockback: Vector2)
signal pulse_blocked

# D002.B (#98) — `cooldown` and `windup_time` @export defaults now
# set in `_ready()` (per-verb base defaults are 0.5 / 0.10).  The
# `@export` declarations live in the base (VerbAbilityBase) — subclasses
# may not redeclare @export variables (GDScript 4 parse error).  See
# _verb_ability_base.gd for the rationale.
var pulse_radius: float = 48.0
var pulse_cost: int = 15
# T166 (#85) — Bumped 0.08s → 0.10s so the pre-pulse windup VFX
# (pulse_windup_vfx.gd) has a readable window.  Matches Bind's
# windup_time (0.1s) so all 4 verb windups share the same "tell"
# pacing — players learn "ring appears for 0.10s → verb fires" once
# and apply it to all 4 verbs.
var active_time: float = 0.12
var knockback_force: float = 200.0
var damage: int = 1

# T068 — Sourced from GameState.get_pulse_kill_refund() at _ready.
# When > 0, every Pulse-kill refunds this much resonance. Set by
# the echo_charm perk in data/shop_catalog.json.
var pulse_kill_refund: int = 0

func _ready() -> void:
	# D002.B (#98) — Parent VerbAbilityBase._ready() asserts
	# _player is non-null; this subclass _ready extends with the
	# GameState perk application that was previously in the local
	# _ready (T068).
	super._ready()
	# D002.B (#98) — Per-verb @export defaults.  See _verb_ability_base.gd.
	cooldown = 0.5
	windup_time = 0.10
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

# D002.B (#98) — `_process` is now in the base (cooldown timer +
# cooldown jingle + windup timer + _execute dispatch).  This
# subclass no longer needs a _process override.

# D002.B (#98) — Virtual override.  Returns "pulse" for the
# T181 cooldown jingle (A4 → C5 ascending major-3rd, 0.10s).
func _get_verb_name() -> String:
	return "pulse"

func can_pulse() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= pulse_cost and not _is_winding_up

func start_pulse(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  Now inherits the 2-step
	# "can-fire + pay-cost" gate from the base (`_consume_verb_cost`
	# + `_setup_windup_state`).  The base owns the helpers; this
	# subclass owns the verb-specific can_X / start_X surface.
	if not can_pulse():
		return false

	if not _consume_verb_cost(pulse_cost):
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
# the verb-specific happy-path body: free windup VFX, start cooldown,
# emit fire signal, play audio, perform hit check.
func _execute() -> void:
	_execute_pulse()

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

# D002.B (#98) — `_spawn_windup_vfx` virtual from base.  Subclass
# implements the verb-specific spawn: queue_free old (via base
# helper), create new windup VFX, add to scene (via base helper),
# trigger with verb-specific args.
func _spawn_windup_vfx() -> void:
	_attach_windup_vfx(preload("res://src/scripts/pulse_windup_vfx.gd"))
	# _attach_windup_vfx adds to scene; safe to trigger now (the
	# node is in the tree, so create_tween() inside the VFX's
	# _activate_windup_tween works deterministically).
	_windup_vfx.trigger(_pending_origin, pulse_radius * 0.5, windup_time)

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

# D002.B (#98) — `_consume_verb_cost` / `_setup_windup_state` /
# `_exit_tree` / `get_cooldown_ratio` / `is_winding_up` all moved to
# the base (VerbAbilityBase).  This subclass inherits them verbatim.
# The pre-D002.B copies (F007 #87 + T166 #85 + T173 #92) are deleted
# from this file.
