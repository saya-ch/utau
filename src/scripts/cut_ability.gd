class_name CutAbility
extends VerbAbilityBase

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
# T169 (#87) — Cut's windup is the shortest of the 5 verbs (0.04s was
# too fast to read; #87 bumped to 0.06s for the windup streak VFX to
# register).  Override the base default (0.10) with 0.06 here so the
# shared _process uses this verb's specific pacing.
@export var windup_time: float = 0.06
@export var damage: int = 2
@export var max_targets: int = 6

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

# D002.B (#98) — _process delegated to base.  Cut has no verb-specific
# _on_extra_process work (Cut is single-shot, no shield, no expansion).
func _process(delta: float) -> void:
	super(delta)

func can_cut() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= cut_cost and not _is_winding_up and _can_fire_extra()

func start_cut(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  The 2-step "can-fire + pay-cost"
	# gate is now in the base (F007 #87 shared contract).
	if not can_cut():
		return false

	if not _consume_verb_cost(cut_cost):
		return false

	_setup_windup_state(origin, direction)

	# T169 (#87) — Spawn the pre-cut windup VFX at the predicted origin
	# so the player sees a 0.5× Amber Voice line streak extend outward
	# for 0.06s before the cut_vfx.gd arc swings.  Parented to the
	# current scene (not the player) so its world position stays stable
	# if the player keeps moving during windup.  Pattern mirrors
	# pulse_ability.start_pulse() (T166 #85) / bind_ability.start_bind()
	# (T167 #86).  The streak is the 4th visual motif in the verb
	# windup family (Pulse=ring / Bind=spiral / Echo=sphere / Cut=streak)
	# so the player can tell *which* verb is charging even before it
	# fires — critical for the 5-verb chain anti-misinput design.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance.
		_windup_vfx.queue_free()
	_windup_vfx = preload("res://src/scripts/cut_windup_vfx.gd").new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		_windup_vfx.trigger(origin, cut_radius * 0.5, direction, windup_time)

	return true

# D002.B (#98) — _on_windup_expired (was _execute_cut) — verb-specific
# fire logic.  Calls _execute_verb_common() for shared bookkeeping.
func _on_windup_expired() -> void:
	_execute_verb_common()

	# T169 (#87) — Free the windup VFX *before* emitting cut_fired so
	# the cut_vfx.gd arc (spawned in player._on_cut_fired) replaces the
	# windup streak in the same frame — no 1-frame overlap.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Emit signal for VFX
	cut_fired.emit(_pending_origin, _pending_direction, cut_radius, cut_arc_degrees)

	# T181 (#97) — Play Cut fire audio cue paired with the fire-VFX
	# frame (cut_vfx.gd's amber slash arc).  See _generate_cut_sfx
	# (F004.B #96) for timbre: 1500→750Hz sharp slash + noise burst
	# (0.08s).  Highest amplitude of the 4 verb fire SFX (0.40)
	# because Cut is the most "kinetic" verb and the slash has to be
	# heard over Bind/Wave drone.
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

# D002.B (#98) — verb cost / verb name virtuals (overrides base).
func get_verb_cost() -> int:
	return cut_cost

func get_verb_name() -> StringName:
	return &"cut"
