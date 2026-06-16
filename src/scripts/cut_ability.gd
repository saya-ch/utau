class_name CutAbility
extends VerbAbilityBase

## Cut 声波能力（第三动词）
## 设计：短前摇 + 弧形/扇形判定 + 水平斩击
## 功能：切断腐蚀链、沉默雾墙、脆弱连接；对敌人造成贯穿伤害
## 与 Pulse（推/破盾，圆环）和 Bind（牵引/暂停，螺旋）形成对比
##
## D002.B (#98) — extends VerbAbilityBase 父类（_verb_ability_base.gd）。
## 父类集中了 5 verb byte-identical 共享代码（cooldown/windup state +
## _consume_verb_cost + _setup_windup_state + get_cooldown_ratio +
## is_winding_up + _exit_tree + _process + _has_game_state_autoload +
## _spawn_windup_vfx + _begin_verb_fire）。子类保留 verb-specific
## signal / @export / can_cut / start_cut / _execute_verb
## (verb-specific 命中检测 _perform_cut_hit_check + wrap_angle)。
## 父类契约见 _verb_ability_base.gd docblock。

signal cut_fired(origin: Vector2, direction: Vector2, radius: float, arc_degrees: float)
signal cut_hit(target: Node)
signal cut_blocked

@export var cut_radius: float = 64.0
@export var cut_arc_degrees: float = 90.0
@export var cut_cost: int = 25
@export var max_targets: int = 6
@export var damage: int = 2


# ===== 父类虚钩 override =====

func _get_verb_name() -> String:
	return "cut"

func _apply_perk_bonuses() -> void:
	# T068 — Apply shop-bought damage bonus (silence_breaker perk).
	# Cut's piercing damage doubles on shattered web chains, so the
	# extra damage is felt most strongly on webs + clustered swarms.
	if _has_game_state_autoload():
		damage += GameState.get_damage_bonus()


# ===== 父类虚钩 _execute_verb（verb-specific 主体）=====

# D002.B (#98) — _execute_verb() 取代旧 _execute_cut()。父类
# _begin_verb_fire("cut") 处理 5 verb 共享的 3 步（清 windup 状态
# + free _windup_vfx + 统计），子类负责 verb-specific 3 步：
#   1. emit cut_fired（player._on_cut_fired spawn fire VFX）
#   2. play cut fire SFX（T181 #97）
#   3. _perform_cut_hit_check（verb-specific 弧形命中检测）
func _execute_verb() -> void:
	_begin_verb_fire("cut")

	# Emit signal for VFX
	cut_fired.emit(_pending_origin, _pending_direction, cut_radius, cut_arc_degrees)

	# T181 (#97 first half) — Play Cut fire audio cue paired with
	# the fire-VFX frame (cut_vfx.gd's amber slash arc).  Mirrors
	# the Pulse caller in pulse_ability.gd:_execute_pulse (F004 #94)
	# which fires AFTER pulse_fired.emit.  Closes the 5-verb audio
	# family loop so every verb has synchronised fire-VFX + fire-SFX.
	# See _generate_cut_sfx (F004.B #96) for timbre: 1500→750Hz sharp
	# slash + noise burst (0.08s).  Highest amplitude of the 4 verb
	# fire SFX (0.40) because Cut is the most "kinetic" verb and the
	# slash has to be heard over Bind/Wave drone.  Guarded by
	# _player-validity so an interrupted windup (player freed by
	# death during the 0.04s windup) doesn't crash on a stale
	# reference.
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_cut()

	# Perform hit detection
	_perform_cut_hit_check()


# ===== verb-specific API（保持兼容：旧 can_cut / start_cut / _perform_cut_hit_check 等）=====

func can_cut() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= cut_cost and not _is_winding_up

func start_cut(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard. 父类集中 _consume_verb_cost +
	# _setup_windup_state 后子类只写 verb-specific 部分。
	if not can_cut():
		return false

	if not _consume_verb_cost(cut_cost):
		return false

	_setup_windup_state(origin, direction)

	# T169 (#87) — Spawn the pre-cut windup VFX at the predicted origin
	# so the player sees a 0.5× Amber Voice line streak extend outward
	# for 0.06s before the cut_vfx.gd arc swings.  Parented to the
	# current scene (not the player) so its world position stays stable
	# if the player keeps moving during windup.
	# D002.B (#98) — Use 父类 _spawn_windup_vfx() 4-step helper。
	_spawn_windup_vfx(origin, preload("res://src/scripts/cut_windup_vfx.gd").new(), cut_radius * 0.5)

	return true


func _perform_cut_hit_check() -> void:
	# Find all enemies in range and filter by arc
	var enemies := get_tree().get_nodes_in_group("enemies")
	var hits: Array = []

	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var to_target: Vector2 = enemy.global_position - _pending_origin
		var dist: float = to_target.length()
		if dist > cut_radius or dist < 0.001:
			continue
		# Check if in arc (within arc_degrees of facing direction)
		var angle_to_target := atan2(to_target.y, to_target.x)
		var facing_angle := atan2(_pending_direction.y, _pending_direction.x)
		var angle_diff := absf(wrap_angle(angle_to_target - facing_angle))
		var half_arc := deg_to_rad(cut_arc_degrees) * 0.5
		if angle_diff > half_arc:
			continue
		hits.append(enemy)

	# Apply damage to enemies (pierces all)
	for enemy in hits:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage, Vector2.ZERO)
		cut_hit.emit(enemy)

	# Cut corruption chains / silence walls (in arc + radius)
	# Use physics shape query for interactivables / hazards
	var space_state := _player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = cut_radius
	query.shape = circle
	query.transform = Transform2D(0, _pending_origin)
	# Layers 4 (Hazard) + 5 (Interactable) + 3 (Enemy)
	query.collision_mask = 0b11100

	var results := space_state.intersect_shape(query, max_targets)

	for result in results:
		var collider := result["collider"] as Node
		if collider == null:
			continue

		# Filter by arc
		var hit_pos: Vector2 = result["point"] if result.has("point") else collider.global_position
		var to_hit := hit_pos - _pending_origin
		if to_hit.length() < 0.001:
			continue
		var angle_to_hit := atan2(to_hit.y, to_hit.x)
		var facing_angle := atan2(_pending_direction.y, _pending_direction.x)
		var angle_diff := absf(wrap_angle(angle_to_hit - facing_angle))
		var half_arc := deg_to_rad(cut_arc_degrees) * 0.5
		if angle_diff > half_arc:
			continue

		# Try Cut interface first (preferred for cuttable obstacles)
		if collider.has_method("on_cut_triggered"):
			collider.on_cut_triggered()
		# Fallback: pulse trigger (for items that respond to either)
		elif collider.has_method("on_pulse_triggered"):
			collider.on_pulse_triggered()

	# Destroy enemy projectiles in arc (like Pulse does)
	for proj in get_tree().get_nodes_in_group("enemy_projectiles"):
		if proj == null or not is_instance_valid(proj):
			continue
		var to_proj: Vector2 = proj.global_position - _pending_origin
		var dist: float = to_proj.length()
		if dist > cut_radius or dist < 0.001:
			continue
		var angle_to_proj := atan2(to_proj.y, to_proj.x)
		var facing_angle := atan2(_pending_direction.y, _pending_direction.x)
		var angle_diff := absf(wrap_angle(angle_to_proj - facing_angle))
		var half_arc := deg_to_rad(cut_arc_degrees) * 0.5
		if angle_diff > half_arc:
			continue
		# Slice the projectile with a sharp VFX
		if proj.has_method("queue_free"):
			var vfx := RepairVFX.new()
			get_tree().current_scene.add_child(vfx)
			vfx.trigger(proj.global_position, 6.0)
			proj.queue_free()


func wrap_angle(angle: float) -> float:
	# Wrap to [-PI, PI]
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle
