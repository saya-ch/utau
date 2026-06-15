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

# T169 (#87) — Live handle to the pre-cut windup VFX so _execute_cut()
# can free it the instant the cut_vfx.gd arc swings (avoids a 1-frame
# overlap where both visuals are visible).  Null when no windup is
# active.  Mirrors pulse_ability._windup_vfx (T166 #85) /
# bind_ability._windup_vfx (T167 #86) / echo_ability._windup_vfx
# (T168 #86) — the 4 verb windup VFX pattern.
var _windup_vfx: Node2D = null

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
		# T181 (#97 first half) — Cooldown "ready" jingle. E5→G5
		# ascending minor-3rd (0.10s). Mirrors pulse_ability's
		# T181 jingle cross-from-positive guard. Minor-3rd (not
		# major-3rd) chosen for Cut to keep the 5 jingles
		# pitch-contour-varied (M3-M3-m3-M2-M3) so the family
		# doesn't sound "same-y" but still feels related.
		if _cooldown_timer <= 0:
			if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_verb_cooldown_ready"):
				AudioManagerEnhanced.play_verb_cooldown_ready("cut")

	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_cut()

func can_cut() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= cut_cost and not _is_winding_up

func start_cut(origin: Vector2, direction: Vector2) -> bool:
	# F007 (#87) — Pre-fire guard.  See pulse_ability.start_pulse() for the
	# shared 2-step "can-fire + pay-cost" gate rationale.  Each verb
	# carries its own _consume_verb_cost() helper (GDScript limitation).
	if not can_cut():
		return false

	if not _consume_verb_cost(cut_cost):
		return false

	# F007 (#87) — Shared windup-state setup.  See _consume_verb_cost.
	_setup_windup_state(origin, direction)

	# T169 (#87) — Spawn the pre-cut windup VFX at the predicted origin
	# so the player sees a 0.5× Amber Voice line streak extend outward
	# for 0.06s before the cut_vfx.gd arc swings.  Parented to the
	# current scene (not the player) so its world position stays stable
	# if the player keeps moving during windup.  Pattern mirrors
	# pulse_ability.start_pulse() (T166 #85) / bind_ability.start_bind()
	# (T167 #86) / echo_ability.start_echo() (T168 #86).  The streak
	# is the 4th visual motif in the verb windup family (Pulse=ring /
	# Bind=spiral / Echo=sphere / Cut=streak) so the player can tell
	# *which* verb is charging even before it fires — critical for the
	# 5-verb chain anti-misinput design (T142 / F005 / F006).
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance.
		_windup_vfx.queue_free()
	_windup_vfx = preload("res://src/scripts/cut_windup_vfx.gd").new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		_windup_vfx.trigger(origin, cut_radius * 0.5, direction, windup_time)

	return true

func _execute_cut() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T169 (#87) — Free the windup VFX *before* emitting cut_fired so
	# the cut_vfx.gd arc (spawned in player._on_cut_fired) replaces the
	# windup streak in the same frame — no 1-frame overlap.  Mirrors
	# pulse_ability._execute_pulse (T166 #85) / bind_ability._execute_bind
	# (T167 #86) / echo_ability._execute_echo (T168 #86).
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking
	PlayerStats.record_ability_used("cut")

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

# T169 (#87) — Clean up the windup VFX if the player / scene is freed
# mid-windup (e.g. on a room transition while the windup tween is
# still ticking).  Without this, the VFX node would stay parented to
# a freed scene and crash on its next _process tick.  Pattern mirrors
# pulse_ability._exit_tree() (T166 #85) / bind_ability._exit_tree()
# (T167 #86) / echo_ability._exit_tree() (T168 #86).
#
# T173 (#92) — Switched from hard queue_free() to fade_out_and_free()
# (0.05s modulate.a 1→0 tween then free).  Avoids a "hard pop" when
# the verb is interrupted (player death, room transition during the
# 0.04s windup window).  See cut_windup_vfx.gd:fade_out_and_free
# for the contract.
func _exit_tree() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.fade_out_and_free()
	_windup_vfx = null

# F007 (#87) — Shared cost-consumption step.  See pulse_ability.gd for
# the full rationale; byte-identical copy in pulse / bind / echo
# abilities (GDScript no-cross-script-inheritance limitation).
func _consume_verb_cost(cost: int) -> bool:
	if GameState == null:
		return false
	return GameState.consume_resonance(cost)

# F007 (#87) — Shared windup-state setup step.  See _consume_verb_cost
# for the GDScript cross-script inheritance note.
func _setup_windup_state(origin: Vector2, direction: Vector2) -> void:
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction
