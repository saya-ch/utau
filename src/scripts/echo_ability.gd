class_name EchoAbility
extends Node

## Echo 声波能力（第四动词）
## 设计：短前摇 + 球形护盾 + 0.6s 持续 + 反弹投射物
## 功能：在玩家周围生成玻璃护盾，护盾持续期间：
##   - 反弹敌人投射物（NoteProjectile）180° 反射
##   - 弹开的投射物对敌人造成伤害（pulse_charm/echo_charm 不叠加）
##   - 接触护盾的敌人被短促推开 + 致盲 0.3s
## 与 Pulse（推/破盾，圆环）、Bind（牵引/暂停，螺旋）、Cut（切断腐蚀链，弧斩）形成对比
## Echo 是防御性动词，让玩家在 NoteWisp 弹幕/精英 Boss 多投射物场景下有喘息空间

signal echo_fired(origin: Vector2, radius: float)
signal echo_hit(target: Node, is_reflect: bool)
signal echo_blocked
signal echo_expired
# T158 (#81) — multi_reflect 4+ signal. When the player successfully
# reflects 4 or more projectiles in a single Echo cast, fire this
# signal so player.gd can drop into a brief slow-motion beat (0.4s
# 0.85x time_scale, "光波回流" 延展感) — the same audio/visual
# pattern of "time stutters on a big moment" that T092 uses for
# death freeze-frame and T146 uses for wave_combo shake. The
# signal carries the reflect count for future scaling (e.g. UI
# "x4" counter). Emitted exactly once per cast on the 4th reflect;
# subsequent reflects in the same cast are silent on this signal
# (避免连续慢动作 spam 让玩家眩晕).
signal echo_multi_reflect(count: int)

@export var echo_radius: float = 30.0
@export var echo_cost: int = 30
@export var cooldown: float = 4.0
@export var windup_time: float = 0.08
@export var active_time: float = 0.6
@export var reflect_speed_multiplier: float = 1.5
@export var reflect_damage: int = 1
@export var enemy_knockback: float = 120.0
@export var enemy_stun_duration: float = 0.3
# T158 (#81) — multi_reflect threshold. Default 4 reflects per cast
# triggers the slow-motion beat; lower for "feels-good" floor, raise
# for hardcore-only. Tunes in tandem with the in-script emit guard.
const MULTI_REFLECT_THRESHOLD: int = 4

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _active_timer: float = 0.0
var _is_winding_up: bool = false
var _is_active: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
# F007 (#87) — Echo doesn't take a direction (shield is omnidirectional)
# so this field is always Vector2.ZERO, but it exists so the
# _setup_windup_state helper (byte-identical to pulse/bind/cut copies)
# can write to it without a "field not declared" parse error.
var _pending_direction: Vector2 = Vector2.ZERO

# Track reflected projectiles this cast to prevent double-reflect chains
# (projectile that just bounced off shouldn't bounce off again mid-flight)
var _reflected_this_cast: Array = []

# T168 (#86) — Live handle to the pre-echo windup VFX so _execute_echo()
# can free it the instant the echo_vfx.gd shield pops into existence
# (avoids a 1-frame overlap where both visuals are visible).  Mirrors
# pulse_ability._windup_vfx (T166 #85) and bind_ability._windup_vfx
# (T167 #86) — the 3 verb windup VFX pattern.
var _windup_vfx: Node2D = null

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "EchoAbility must be child of CharacterBody2D")
	# T068 — Echo has no direct damage bonus from shop perks. The reflect_damage
	# is fixed (1) and serves as a "soft punish" for enemies that shoot at you.
	# The echo_charm perk boosts Echo, not Pulse. silence_breaker adds to all
	# damage abilities but Echo doesn't do direct damage — only reflect damage,
	# which is intentionally kept low to preserve the "defensive verb" identity.

	# T096 — Apply the echo_charm perk bonus to the shield radius. The @export
	# value (default 30.0) is the visual-design base; the bonus adds 8px per
	# level bought from the shop. We re-apply here AND from ShopMenu._on_buy_pressed
	# (so the radius updates immediately on purchase without needing a scene
	# reload). GameState is an autoload so `is null` only in headless test
	# contexts — guard with has_method to keep the smoke tests runnable.
	if GameState and GameState.has_method("get_echo_radius_bonus"):
		echo_radius += float(GameState.get_echo_radius_bonus())

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_echo()

	if _is_active:
		_active_timer -= delta
		_perform_shield_check()
		if _active_timer <= 0:
			_deactivate_shield()

func can_echo() -> bool:
	# Cannot fire while already winding up OR while a previous shield is up.
	# The shield locks the player out of re-casting until it expires or
	# the cooldown resets — otherwise Echo would trivially chain into a
	# permanent invincibility frame.
	return _cooldown_timer <= 0 \
		and GameState.resonance >= echo_cost \
		and not _is_winding_up \
		and not _is_active

func start_echo(origin: Vector2) -> bool:
	# F007 (#87) — Pre-fire guard.  See pulse_ability.start_pulse() for the
	# shared 2-step "can-fire + pay-cost" gate rationale.  Each verb
	# carries its own _consume_verb_cost() helper (GDScript limitation).
	if not can_echo():
		return false

	if not _consume_verb_cost(echo_cost):
		return false

	# F007 (#87) — Shared windup-state setup.  Echo doesn't take a
	# direction (shield is omnidirectional) so we pass Vector2.ZERO
	# for the unused parameter — _setup_windup_state is byte-identical
	# to the other 3 verb abilities' copies.
	_setup_windup_state(origin, Vector2.ZERO)
	_reflected_this_cast.clear()

	# T168 (#86) — Spawn the pre-echo windup VFX at the predicted origin
	# so the player sees a 0.5× → 1.0× Glass Cyan sphere expand OUT for
	# 0.08s before the echo_vfx.gd shield pops into existence.  Parented
	# to the current scene (not the player) so its world position stays
	# stable if the player keeps moving during windup.  Pattern mirrors
	# pulse_ability.start_pulse() (T166 #85) and
	# bind_ability.start_bind() (T167 #86).
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance.
		_windup_vfx.queue_free()
	_windup_vfx = preload("res://src/scripts/echo_windup_vfx.gd").new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		_windup_vfx.trigger(origin, echo_radius * 0.5, echo_radius, windup_time)

	return true

func _execute_echo() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T168 (#86) — Free the windup VFX *before* emitting echo_fired so
	# the echo_vfx.gd shield (spawned in player._on_echo_fired) replaces
	# the windup sphere in the same frame — no 1-frame overlap.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking
	PlayerStats.record_ability_used("echo")

	# Activate the shield
	_is_active = true
	_active_timer = active_time

	# Emit signal so VFX + SFX can react at the exact moment the shield
	# pops into existence (rather than at the windup start, which would
	# be misleading — the shield doesn't exist during windup).
	echo_fired.emit(_pending_origin, echo_radius)

func _perform_shield_check() -> void:
	# Update origin every frame so the shield follows the player as they
	# move. Using _pending_origin (frozen at fire time) would leave the
	# shield trailing behind for run-speed characters.
	var origin := _player.global_position + Vector2(0, -8)

	# 1) Reflect enemy projectiles inside the shield radius
	for proj in get_tree().get_nodes_in_group("enemy_projectiles"):
		if proj == null or not is_instance_valid(proj):
			continue
		# Already reflected this cast — skip to prevent reflect chains
		if _reflected_this_cast.has(proj):
			continue
		var dist: float = proj.global_position.distance_to(origin)
		if dist > echo_radius:
			continue

		_reflect_projectile(proj, origin)
		_reflected_this_cast.append(proj)

	# 2) Knockback + brief stun for enemies that are inside the shield
	#    (e.g. a SilenceMote that ran into the player while Echo is up).
	#    NoteWisp enemies stay out of range (they fly), so this mostly
	#    catches SilenceMote + InkWarden when they get too close.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		var dist: float = enemy.global_position.distance_to(origin)
		if dist > echo_radius:
			continue
		# Skip already-handled enemies this frame (push only once per frame)
		_apply_enemy_contact(enemy, origin)

func _reflect_projectile(proj: Node, origin: Vector2) -> void:
	# Reflect the projectile 180° off the shield surface. The reflection
	# direction is from origin to projectile, then flipped — that way the
	# projectile flies back the way it came (with a slight boost).
	if not proj.has_method("get") or not "direction" in proj:
		# Unknown projectile type — just destroy it for safety
		if proj.has_method("queue_free"):
			var vfx := RepairVFX.new()
			get_tree().current_scene.add_child(vfx)
			vfx.trigger(proj.global_position, 8.0)
			proj.queue_free()
		return

	var incoming_dir: Vector2 = proj.get("direction")
	var reflect_dir: Vector2 = (proj.global_position - origin).normalized()
	if reflect_dir == Vector2.ZERO:
		# Projectile is right on top of the player — reflect back along
		# the incoming path (mirrors it).
		reflect_dir = -incoming_dir
	# Boosted speed for the reflected projectile so it actually threatens
	# the enemy that fired it (not just floats back).
	if proj.has_method("set"):
		proj.set("direction", reflect_dir)
	if "speed" in proj:
		var cur_speed: float = proj.get("speed")
		proj.set("speed", cur_speed * reflect_speed_multiplier)
	# Re-tag: the projectile was hostile, now it's "friendly" (toward the
	# original shooter). We don't change groups (would race with collision
	# layers), but the boosted speed + reversed direction means it will
	# hit the enemy that fired it.

	# Visual feedback: coral pulse flash + glass cyan burst at the bounce
	# point. Use RepairVFX as a quick burst (it's already tuned for the
	# palette), and spawn an additional dedicated EchoVFX bounce marker.
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(proj.global_position, 10.0)

	# Damage the original enemy if the projectile's "owner" is reachable.
	# NoteProjectile doesn't currently track its owner; for now we just
	# trust that the boosted projectile will hit something on its way out
	# (the enemy that fired it, or another enemy in its path).

	# Track reflect for stats
	PlayerStats.record_echo_reflect()

	echo_hit.emit(proj, true)

	# T158 (#81) — multi_reflect guard: emit the slow-motion signal
	# exactly once per cast, on the 4th reflect. Subsequent reflects
	# in the same cast are silent on this signal so the player isn't
	# dropped into 0.85x time_scale spam (which would feel like the
	# game is broken, not "epic"). The threshold matches the
	# MULTI_REFLECT_THRESHOLD constant above; raising it to 5+ would
	# only fire on truly stuffed encounters, lowering to 2 would fire
	# on every Echo cast that bounced anything.
	if _reflected_this_cast.size() == MULTI_REFLECT_THRESHOLD:
		echo_multi_reflect.emit(_reflected_this_cast.size())

func _apply_enemy_contact(enemy: Node, origin: Vector2) -> void:
	# Push the enemy out of the shield + brief stun. This is the "bump"
	# effect — silent on stats because it's a passive shield interaction,
	# not a deliberate offensive ability.
	var push_dir: Vector2 = (enemy.global_position - origin).normalized()
	if push_dir == Vector2.ZERO:
		push_dir = Vector2.UP
	if enemy.has_method("repel"):
		enemy.repel(push_dir * enemy_knockback)
	# Apply a short stun if the enemy supports it; otherwise fall back
	# to a brief apply_bind (which BindAbility uses for the same purpose).
	if enemy.has_method("apply_bind"):
		enemy.apply_bind(enemy_stun_duration)
	# Damage to encourage spacing — small (0) so we don't accidentally
	# trivialize encounters
	if enemy.has_method("take_damage"):
		enemy.take_damage(0, Vector2.ZERO)

	echo_hit.emit(enemy, false)

func _deactivate_shield() -> void:
	_is_active = false
	_reflected_this_cast.clear()
	echo_expired.emit()

func is_shield_active() -> bool:
	return _is_active

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up

# T168 (#86) — Clean up the windup VFX if the player / scene is freed
# mid-windup (e.g. on a room transition while the windup tween is
# still ticking).  Without this, the VFX node would stay parented to
# a freed scene and crash on its next _process tick.  Pattern mirrors
# pulse_ability._exit_tree() (T166 #85) and
# bind_ability._exit_tree() (T167 #86).
func _exit_tree() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

# F007 (#87) — Shared cost-consumption step.  See pulse_ability.gd for
# the full rationale; byte-identical copy in pulse / bind / cut
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
