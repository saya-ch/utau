class_name BindAbility
extends VerbAbilityBase

## Bind 声波能力（第二动词）
## D002.B (#98) — extends VerbAbilityBase 父类（_verb_ability_base.gd）。
## 父类集中了 5 verb byte-identical 共享代码（cooldown/windup state +
## _consume_verb_cost + _setup_windup_state + get_cooldown_ratio +
## is_winding_up + _exit_tree + _process + _has_game_state_autoload +
## _spawn_windup_vfx + _begin_verb_fire）。子类保留 verb-specific
## signal / @export / can_bind / start_bind / _execute_verb
## (verb-specific 命中检测 _perform_bind_hit_check)。
## 父类契约见 _verb_ability_base.gd docblock。

signal bind_fired(origin: Vector2, radius: float)
signal bind_hit(target: Node)
signal bind_blocked

@export var bind_radius: float = 40.0
@export var bind_cost: int = 20
@export var active_time: float = 0.15
@export var bind_duration: float = 3.0
@export var pull_force: float = 80.0


# ===== 父类虚钩 override =====

func _get_verb_name() -> String:
	return "bind"

func _apply_perk_bonuses() -> void:
	# T068 — Bind doesn't take direct damage bonuses (it's a pull/stun
	# effect, not a kill path).  The echo_charm perk refund is Pulse-only.
	# Bind 无 perk bonus，留空。
	pass


# ===== 父类虚钩 _execute_verb（verb-specific 主体）=====

# D002.B (#98) — _execute_verb() 取代旧 _execute_bind()。父类
# _begin_verb_fire("bind") 处理 5 verb 共享的 3 步（清 windup 状态
# + free _windup_vfx + 统计），子类负责 verb-specific 3 步：
#   1. emit bind_fired（player._on_bind_fired spawn fire VFX）
#   2. play bind fire SFX（T181 #97）
#   3. _perform_bind_hit_check（verb-specific 命中检测）
func _execute_verb() -> void:
	_begin_verb_fire("bind")

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


# ===== verb-specific API（保持兼容：旧 can_bind / start_bind / _perform_bind_hit_check 等）=====

func can_bind() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= bind_cost and not _is_winding_up

func start_bind(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard. See pulse_ability.start_pulse() for the
	# shared 2-step "can-fire + pay-cost" gate rationale. 父类集中后
	# 子类只写 verb-specific 部分。
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
	# D002.B (#98) — Use 父类 _spawn_windup_vfx() 4-step helper。
	_spawn_windup_vfx(origin, preload("res://src/scripts/bind_windup_vfx.gd").new(), bind_radius * 0.5)

	return true


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
