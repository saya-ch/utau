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
##
## D002.B (#98) — extends VerbAbilityBase 父类（_verb_ability_base.gd）。
## 父类集中了 5 verb byte-identical 共享代码（cooldown/windup state +
## _consume_verb_cost + _setup_windup_state + get_cooldown_ratio +
## is_winding_up + _exit_tree + _process + _has_game_state_autoload +
## _spawn_windup_vfx + _begin_verb_fire）。子类保留 verb-specific
## signal / @export / can_echo / start_echo / _execute_verb
## (verb-specific shield 状态 + _perform_shield_check + _reflect_projectile +
## _apply_enemy_contact + _deactivate_shield)。
## 父类契约见 _verb_ability_base.gd docblock。

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
@export var active_time: float = 0.6
@export var reflect_speed_multiplier: float = 1.5
@export var reflect_damage: int = 1
@export var enemy_knockback: float = 120.0
@export var enemy_stun_duration: float = 0.3
# T158 (#81) — multi_reflect threshold. Default 4 reflects per cast
# triggers the slow-motion beat; lower for "feels-good" floor, raise
# for hardcore-only. Tunes in tandem with the in-script emit guard.
const MULTI_REFLECT_THRESHOLD: int = 4

# Echo verb-specific 状态（shield 持续 + 防重复反弹）
# 与 5 verb 共享 state 区分：_is_active + _active_timer + _reflected_this_cast
# 是 Echo 独有的（其他 4 verb 是瞬发 + 一次性命中）。
var _active_timer: float = 0.0
var _is_active: bool = false
# Track reflected projectiles this cast to prevent double-reflect chains
# (projectile that just bounced off shouldn't bounce off again mid-flight)
var _reflected_this_cast: Array = []


# ===== 父类虚钩 override =====

func _get_verb_name() -> String:
	return "echo"

func _apply_perk_bonuses() -> void:
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


# ===== 父类虚钩 _execute_verb（verb-specific 主体）=====

# D002.B (#98) — _execute_verb() 取代旧 _execute_echo()。父类
# _begin_verb_fire("echo") 处理 5 verb 共享的 3 步（清 windup 状态
# + free _windup_vfx + 统计），子类负责 verb-specific 4 步：
#   1. _is_active = true + _active_timer = active_time（shield 激活）
#   2. emit echo_fired（player._on_echo_fired spawn fire VFX）
#   3. play echo fire SFX（T181 #97）
#   注：shield 状态由父类 _process() 持续驱动（5 verb 共享的 _process
#   已经处理 _is_winding_up → _execute_verb 路径；shield 持续期
#   _is_active 是 Echo 独有，由子类的 _process override 处理——见下）
func _execute_verb() -> void:
	_begin_verb_fire("echo")

	# Activate the shield
	_is_active = true
	_active_timer = active_time

	# Emit signal so VFX + SFX can react at the exact moment the shield
	# pops into existence (rather than at the windup start, which would
	# be misleading — the shield doesn't exist during windup).
	echo_fired.emit(_pending_origin, echo_radius)

	# T181 (#97 first half) — Play Echo fire audio cue paired with
	# the fire-VFX frame (echo_vfx.gd's glass cyan shield pop).
	# Mirrors the Pulse caller in pulse_ability.gd:_execute_pulse
	# (F004 #94) which fires AFTER pulse_fired.emit.  Closes the
	# 5-verb audio family loop.  See _generate_echo_sfx (F004.B #96)
	# for timbre: 1320Hz bell ping + 1.5x harmonic (0.15s).  Guarded
	# by _player-validity so an interrupted windup (player freed by
	# death during the 0.08s windup) doesn't crash on a stale
	# reference.
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_echo()


# ===== Echo verb-specific _process override（shield 持续驱动）=====

# D002.B (#98) — Echo 必须 override 父类 _process() 来额外驱动
# _is_active shield 状态（其他 4 verb 不用 override）。父类
# _process() 的 windup 倒计时 + cooldown jingle 仍需要 → 调
# super._process(delta) 复用父类实现。
func _process(delta: float) -> void:
	super._process(delta)

	# Shield 持续期驱动（5 verb 唯一 verb-specific 状态：_is_active）
	if _is_active:
		_active_timer -= delta
		_perform_shield_check()
		if _active_timer <= 0:
			_deactivate_shield()


# ===== verb-specific API（保持兼容：旧 can_echo / start_echo / _perform_shield_check 等）=====

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
	# D002.B (#98) — Pre-fire guard. 父类集中 _consume_verb_cost +
	# _setup_windup_state 后子类只写 verb-specific 部分。Echo 不传 direction
	#（omnidirectional shield 不用方向）→ 传 Vector2.ZERO 给 _setup_windup_state
	# 满足父类契约（_pending_direction 字段已在父类定义）。
	if not can_echo():
		return false

	if not _consume_verb_cost(echo_cost):
		return false

	_setup_windup_state(origin, Vector2.ZERO)
	_reflected_this_cast.clear()

	# T168 (#86) — Spawn the pre-echo windup VFX at the predicted origin
	# so the player sees a 0.5× → 1.0× Glass Cyan sphere expand OUT for
	# 0.08s before the echo_vfx.gd shield pops into existence.  Parented to
	# the current scene (not the player) so its world position stays
	# stable if the player keeps moving during windup.
	# D002.B (#98) — Use 父类 _spawn_windup_vfx() 4-step helper。
	_spawn_windup_vfx(origin, preload("res://src/scripts/echo_windup_vfx.gd").new(), echo_radius * 0.5)

	return true


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
