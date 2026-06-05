class_name CutAbility
extends Node

## Cut 声波能力（第三动词）
## 设计：短前摇 + 弧形/扇形判定 + 水平斩击
## 功能：切断腐蚀链、沉默雾墙、脆弱连接；对敌人造成贯穿伤害
## 与 Pulse（推/破盾，圆环）和 Bind（牵引/暂停，螺旋）形成对比

signal cut_fired(origin: Vector2, direction: Vector2, radius: float, arc_degrees: float)
signal cut_hit(target: Node)
signal cut_blocked

@export var cut_radius: float = 64.0
@export var cut_arc_degrees: float = 90.0
@export var cut_cost: int = 25
@export var cooldown: float = 0.8
@export var windup_time: float = 0.06
@export var damage: int = 2
@export var max_targets: int = 6

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "CutAbility must be child of CharacterBody2D")
	# T068 — Apply shop-bought damage bonus (silence_breaker perk).
	# Cut's piercing damage doubles on shattered web chains, so the
	# extra damage is felt most strongly on webs + clustered swarms.
	if _has_game_state_autoload():
		damage += GameState.get_damage_bonus()

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
			_execute_cut()

func can_cut() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= cut_cost and not _is_winding_up

func start_cut(origin: Vector2, direction: Vector2) -> bool:
	if not can_cut():
		return false

	if not GameState.consume_resonance(cut_cost):
		return false

	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction

	return true

func _execute_cut() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# Stats tracking
	PlayerStats.record_ability_used("cut")

	# Emit signal for VFX
	cut_fired.emit(_pending_origin, _pending_direction, cut_radius, cut_arc_degrees)

	# Perform hit detection
	_perform_cut_hit_check()

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

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up
