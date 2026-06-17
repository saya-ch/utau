class_name CutAbility
extends "res://src/scripts/_verb_ability_base.gd"

## Cut 声波能力（第三动词）
## 设计：短前摇 + 弧形/扇形判定 + 水平斩击
## 功能：切断腐蚀链、沉默雾墙、脆弱连接；对敌人造成贯穿伤害
## 与 Pulse（推/破盾，圆环）和 Bind（牵引/暂停，螺旋）形成对比
##
## D002.B (#98) — Now extends VerbAbilityBase (shared cooldown +
## windup state + cost consume + _process + _exit_tree fade-out +
## cooldown jingle).  Verb-specific logic (cut_arc_degrees,
## max_targets, _perform_cut_hit_check) and the verb-specific
## `_spawn_windup_vfx` (Cut is the only verb that passes
## `direction` as the 3rd arg to its windup VFX's `trigger()`)
## remain here.

signal cut_fired(origin: Vector2, direction: Vector2, radius: float, arc_degrees: float)
signal cut_hit(target: Node)
signal cut_blocked

@export var cut_radius: float = 64.0
@export var cut_arc_degrees: float = 90.0
@export var cut_cost: int = 25
@export var damage: int = 2
@export var max_targets: int = 6

func _ready() -> void:
	# D002.B (#98) — Parent VerbAbilityBase._ready() asserts
	# _player is non-null; subclass _ready extends with the
	# GameState perk application (T068 silence_breaker).
	super._ready()
	# D002.B (#98) — Per-verb @export defaults.  See _verb_ability_base.gd.
	cooldown = 0.8
	windup_time = 0.06
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

# D002.B (#98) — `_process` is now in the base (cooldown timer +
# cooldown jingle + windup timer + _execute dispatch).  This
# subclass no longer needs a _process override.

# D002.B (#98) — Virtual override.  Returns "cut" for the
# T181 cooldown jingle (E5 → G5 ascending minor-3rd, 0.10s).
func _get_verb_name() -> String:
	return "cut"

func can_cut() -> bool:
	return _cooldown_timer <= 0 and GameState.resonance >= cut_cost and not _is_winding_up

func start_cut(origin: Vector2, direction: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  Now inherits the 2-step
	# "can-fire + pay-cost" gate from the base.
	if not can_cut():
		return false

	if not _consume_verb_cost(cut_cost):
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
	_execute_cut()

func _execute_cut() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T169 (#87) — Free the windup VFX *before* emitting cut_fired so
	# the cut_vfx.gd arc (spawned in player._on_cut_fired) replaces
	# the windup streak in the same frame — no 1-frame overlap.
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

# D002.B (#98) — `_spawn_windup_vfx` virtual from base.  Subclass
# implements the verb-specific spawn.  Cut is unique among the
# 5 verbs: its windup VFX's `trigger()` takes `direction` as the
# 3rd arg (so the streak animates in the direction the slash will
# travel) — 4-arg trigger vs 3-arg for pulse/bind/wave.
func _spawn_windup_vfx() -> void:
	_attach_windup_vfx(preload("res://src/scripts/cut_windup_vfx.gd"))
	_windup_vfx.trigger(_pending_origin, cut_radius * 0.5, _pending_direction, windup_time)

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

# D002.B (#98) — `_consume_verb_cost` / `_setup_windup_state` /
# `_exit_tree` / `get_cooldown_ratio` / `is_winding_up` all moved to
# the base (VerbAbilityBase).  This subclass inherits them verbatim.
# The pre-D002.B copies (F007 #87 + T169 #87 + T173 #92) are deleted
# from this file.
