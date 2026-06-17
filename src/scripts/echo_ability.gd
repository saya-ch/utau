class_name EchoAbility
extends VerbAbilityBase

## Echo 声波能力（第四动词）
## 设计：短前摇 + 球形护盾 + 0.6s 持续 + 反弹投射物
## 功能：在玩家周围生成玻璃护盾，护盾持续期间：
##   - 反弹敌人投射物（NoteProjectile）180° 反射
##   - 弹开的投射物对敌人造成伤害（pulse_charm/echo_charm 不叠加）
##   - 接触护盾的敌人被短促推开 + 致盲 0.3s
## 与 Pulse（推/破盾，圆环）、Bind（牵引/暂停，螺旋）、Cut（切断腐蚀链，弧斩）形成对比
## Echo 是防御性动词，让玩家在 NoteWisp 弹幕/精英 Boss 多投射物场景下有喘息空间

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
# T168 (#86) — Echo's windup is 0.08s (vs Pulse/Bind/Wave 0.10s, Cut
# 0.06s).  Override the base default (0.10) with 0.08 here so the
# shared _process uses this verb's specific pacing.
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

# D002.B (#98) — Echo has verb-specific state: _is_active (shield up
# or not) + _active_timer (shield countdown) + _reflected_this_cast
# (track reflects to prevent double-reflect chains).  These are
# NOT in the base (they're Echo-specific) so they stay in the subclass.
var _is_active: bool = false
var _active_timer: float = 0.0
# Track reflected projectiles this cast to prevent double-reflect chains
# (projectile that just bounced off shouldn't bounce off again mid-flight)
var _reflected_this_cast: Array = []

# T168 (#86) — echo_fired signal is defined in the base as part of
# the verb family contract.  Re-declared here for explicit visibility
# (it stays identical to the inherited one because signal names are
# additive in GDScript — declaring it again is a no-op).  We keep
# the `signal echo_fired` for smoke test compatibility
# (test_echo_smoke.gd checks signal existence).
signal echo_fired(origin: Vector2, radius: float)

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

# D002.B (#98) — _process delegated to base.  Echo overrides
# _on_extra_process() to handle the shield-active window (per-frame
# reflect check + countdown to deactivation).
func _process(delta: float) -> void:
	super(delta)

# D002.B (#98) — Echo-specific extra process: shield per-frame work.
# Base _process calls this AFTER the cooldown + windup ticks.
func _on_extra_process(delta: float) -> void:
	if _is_active:
		_active_timer -= delta
		_perform_shield_check()
		if _active_timer <= 0:
			_deactivate_shield()

# D002.B (#98) — Echo's extra can-fire check: can't recast while shield up.
func _can_fire_extra() -> bool:
	return not _is_active

func can_echo() -> bool:
	return _cooldown_timer <= 0 \
		and GameState.resonance >= echo_cost \
		and not _is_winding_up \
		and _can_fire_extra()

func start_echo(origin: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  The 2-step "can-fire + pay-cost"
	# gate is now in the base (F007 #87 shared contract).
	if not can_echo():
		return false

	if not _consume_verb_cost(echo_cost):
		return false

	# F007 (#87) — Echo doesn't take a direction (shield is omnidirectional)
	# so we pass Vector2.ZERO for the unused parameter.
	_setup_windup_state(origin, Vector2.ZERO)
	_reflected_this_cast.clear()

	# T168 (#86) — Spawn the pre-echo windup VFX at the predicted origin
	# so the player sees a 0.5× → 1.0× Glass Cyan sphere expand OUT for
	# 0.08s before the echo_vfx.gd shield pops into existence.  Parented
	# to the current scene (not the player) so its world position stays
	# stable if the player keeps moving during windup.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance.
		_windup_vfx.queue_free()
	_windup_vfx = preload("res://src/scripts/echo_windup_vfx.gd").new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		_windup_vfx.trigger(origin, echo_radius * 0.5, echo_radius, windup_time)

	return true

# D002.B (#98) — _on_windup_expired (was _execute_echo) — verb-specific
# fire logic.  Calls _execute_verb_common() for shared bookkeeping,
# then activates the shield.
func _on_windup_expired() -> void:
	_execute_verb_common()

	# T168 (#86) — Free the windup VFX *before* emitting echo_fired so
	# the echo_vfx.gd shield (spawned in player._on_echo_fired) replaces
	# the windup sphere in the same frame — no 1-frame overlap.
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Activate the shield
	_is_active = true
	_active_timer = active_time

	# Emit signal so VFX + SFX can react at the exact moment the shield
	# pops into existence (rather than at the windup start, which would
	# be misleading — the shield doesn't exist during windup).
	echo_fired.emit(_pending_origin, echo_radius)

	# T181 (#97) — Play Echo fire audio cue paired with the fire-VFX
	# frame (echo_vfx.gd's glass cyan shield pop).  See _generate_echo_sfx
	# (F004.B #96) for timbre: 1320Hz bell ping + 1.5x harmonic (0.15s).
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_echo()

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

# D002.B (#98) — verb cost / verb name virtuals (overrides base).
func get_verb_cost() -> int:
	return echo_cost

func get_verb_name() -> StringName:
	return &"echo"
