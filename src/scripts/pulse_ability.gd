class_name PulseAbility
extends VerbAbilityBase

## Pulse 声波能力（第一动词）
## D002.B (#98) — extends VerbAbilityBase 父类（_verb_ability_base.gd）。
## 父类集中了 5 verb byte-identical 共享代码（cooldown/windup state +
## _consume_verb_cost + _setup_windup_state + get_cooldown_ratio +
## is_winding_up + _exit_tree + _process + _has_game_state_autoload +
## _spawn_windup_vfx + _begin_verb_fire）。子类保留 verb-specific
## signal / @export / can_pulse / start_pulse / _execute_verb
## (verb-specific 命中检测 _perform_pulse_hit_check)。
## 父类契约见 _verb_ability_base.gd docblock。

signal pulse_fired(origin: Vector2, radius: float)
signal pulse_hit(target: Node, knockback: Vector2)
signal pulse_blocked

@export var pulse_radius: float = 48.0
@export var pulse_cost: int = 15
@export var active_time: float = 0.12
@export var knockback_force: float = 200.0
@export var damage: int = 1

# T068 — Sourced from GameState.get_pulse_kill_refund() at _ready.
# When > 0, every Pulse-kill refunds this much resonance. Set by
# the echo_charm perk in data/shop_catalog.json.
var pulse_kill_refund: int = 0


# ===== 父类虚钩 override =====

func _get_verb_name() -> String:
	return "pulse"

func _apply_perk_bonuses() -> void:
	# T068 — Apply shop-bought pulse radius bonus. Sums onto the
	# exported base value so .tscn overrides still win for the default
	# gameplay; perks stack additively on top.
	if _has_game_state_autoload():
		pulse_radius += GameState.get_pulse_radius_bonus()
		damage += GameState.get_damage_bonus()
		pulse_kill_refund = GameState.get_pulse_kill_refund()


# ===== 父类虚钩 _execute_verb（verb-specific 主体）=====

# D002.B (#98) — _execute_verb() 取代旧 _execute_pulse()。父类
# _begin_verb_fire("pulse") 处理 5 verb 共享的 3 步（清 windup 状态
# + free _windup_vfx + 统计），子类负责 verb-specific 4 步：
#   1. emit pulse_fired（player._on_pulse_fired spawn fire VFX）
#   2. play pulse fire SFX（F004 #94）
#   3. _perform_pulse_hit_check（verb-specific 命中检测）
func _execute_verb() -> void:
	_begin_verb_fire("pulse")

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


# ===== verb-specific API（保持兼容：旧 can_pulse / start_pulse / _perform_pulse_hit_check 等）=====

func can_pulse() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= pulse_cost and not _is_winding_up

func start_pulse(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard. The 5 verb abilities all share the
	# same 2-step "can-fire + pay-cost" gate (pulse / bind / cut / echo /
	# wave). 父类集中了 _consume_verb_cost + _setup_windup_state 后
	# 子类只写 verb-specific 部分。
	if not can_pulse():
		return false

	if not _consume_verb_cost(pulse_cost):
		return false

	_setup_windup_state(origin, direction)

	# T166 (#85) — Spawn the pre-pulse windup VFX at the predicted origin
	# so the player sees a 0.5× Glass Cyan ring grow inward for 0.10s
	# before the fire VFX (pulse_vfx.gd) explodes outward.  Parented to
	# the current scene (not the player) so its world position stays
	# stable if the player keeps moving during windup.
	# D002.B (#98) — Use 父类 _spawn_windup_vfx() 4-step helper 替换原本
	# 5 verb 内联 4-step（防御性 free + add_child + trigger + stash）。
	_spawn_windup_vfx(origin, preload("res://src/scripts/pulse_windup_vfx.gd").new(), pulse_radius * 0.5)

	return true


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
