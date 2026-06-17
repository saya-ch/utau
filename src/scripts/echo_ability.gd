class_name EchoAbility
extends "res://src/scripts/_verb_ability_base.gd"

## Echo 声波能力（第四动词）
## 设计：短前摇 + 球形护盾 + 0.6s 持续 + 反弹投射物
## 功能：在玩家周围生成玻璃护盾，护盾持续期间：
##   - 反弹敌人投射物（NoteProjectile）180° 反射
##   - 弹开的投射物对敌人造成伤害（pulse_charm/echo_charm 不叠加）
##   - 接触护盾的敌人被短促推开 + 致盲 0.3s
## 与 Pulse（推/破盾，圆环）、Bind（牵引/暂停，螺旋）、Cut（切断腐蚀链，弧斩）形成对比
## Echo 是防御性动词，让玩家在 NoteWisp 弹幕/精英 Boss 多投射物场景下有喘息空间
##
## D002.B (#98) — Now extends VerbAbilityBase.  Echo is unique among
## the 5 verbs in 3 ways:
##   1. start_echo() signature is (origin) only — omnidirectional, no
##      `_pending_direction` — passes `Vector2.ZERO` to the base
##      `_setup_windup_state` (the field is set but unused by _execute).
##   2. The windup VFX's `trigger()` takes 4 args (origin, half_radius,
##      echo_radius, windup_time) vs 3 for pulse/bind/wave — the extra
##      `echo_radius` lets the windup sphere hint at the full shield
##      radius that will pop on fire.
##   3. `_is_active` / `_active_timer` / `_reflected_this_cast` /
##      `_perform_shield_check` / `_reflect_projectile` /
##      `_apply_enemy_contact` / `_deactivate_shield` —
##      *post-fire* shield active state.  These stay in the subclass
##      (base owns the pre-fire windup lifecycle only).
##
## All common state (`_cooldown_timer` / `_windup_timer` /
## `_is_winding_up` / `_pending_origin` / `_pending_direction` /
## `_windup_vfx`) and common functions (`_consume_verb_cost` /
## `_setup_windup_state` / `_exit_tree` / `get_cooldown_ratio` /
## `is_winding_up`) now inherited from VerbAbilityBase.

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

# F006 (#90) — Live active-state for the reflection window.  Echo is
# the only verb with a *post-fire* active state (Pulse / Bind / Cut /
# Wave all resolve in a single frame).  When `_is_active == true`,
# the wave is still reflecting off enemies and damageable obstacles
# for the remainder of `active_time` seconds.  Stays here (not in
# the base) because the 4 other verbs (Pulse / Bind / Cut / Wave)
# are all "single frame resolve" — they don't need this loop.
var _is_active: bool = false
var _active_timer: float = 0.0
# Track reflected projectiles this cast to prevent double-reflect chains
# (projectile that just bounced off shouldn't bounce off again mid-flight)
var _reflected_this_cast: Array = []

func _ready() -> void:
	# D002.B (#98) — Parent VerbAbilityBase._ready() asserts
	# _player is non-null; subclass _ready extends with the
	# T096 echo_charm perk application + per-verb @export defaults.
	# T068 — Echo has no direct damage bonus from shop perks (only
	# reflect_damage is fixed at 1 to preserve the "defensive verb"
	# identity).
	super._ready()
	# D002.B (#98) — Per-verb @export defaults.  See _verb_ability_base.gd.
	cooldown = 4.0
	windup_time = 0.08

	# T096 — Apply the echo_charm perk bonus to the shield radius.
	# GameState is an autoload so `is null` only in headless test
	# contexts — guard with has_method to keep the smoke tests runnable.
	if GameState and GameState.has_method("get_echo_radius_bonus"):
		echo_radius += float(GameState.get_echo_radius_bonus())

# D002.B (#98) — `_process` overrides the base to extend the
# post-fire shield check (the base handles windup + cooldown
# jingle).  Echo is the only verb with a *post-fire* active
# state (the 4 other verbs resolve in a single frame), so the
# active timer tick + shield check stays in the subclass.
func _process(delta: float) -> void:
	# D002.B (#98) — Base handles windup + cooldown jingle.
	super._process(delta)
	# F006 (#90) — Active reflection window.  Stays here, not in
	# base, because the 4 other verbs are all "single frame
	# resolve" — they don't need this loop.
	if _is_active:
		_active_timer -= delta
		_perform_shield_check()
		if _active_timer <= 0:
			_deactivate_shield()

# D002.B (#98) — Virtual override.  Returns "echo" for the
# T181 cooldown jingle (G5 → A5 ascending major-2nd, 0.10s).
func _get_verb_name() -> String:
	return "echo"

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
	# D002.B (#98) — Pre-fire guard.  Now inherits the 2-step
	# "can-fire + pay-cost" gate from the base.  Echo is
	# omnidirectional — passes `Vector2.ZERO` for direction (the
	# field is set but unused by `_execute_echo`).
	if not can_echo():
		return false

	if not _consume_verb_cost(echo_cost):
		return false

	# D002.B (#98) — Windup-state setup now in base; subclass just
	# calls it.  Echo's pre-D002.B code also cleared
	# `_reflected_this_cast` here, but that moved to `_execute_echo`
	# (right before the shield is activated) so the cleanup happens
	# at the same lifecycle moment as `_is_active = true`.
	_setup_windup_state(origin, Vector2.ZERO)

	# D002.B (#98) — Windup VFX spawn now in `_spawn_windup_vfx()`
	# virtual; this subclass implements the verb-specific preload
	# + trigger args.  Echo's windup VFX `trigger()` takes 4 args
	# (origin, half_radius, echo_radius, windup_time) — the extra
	# `echo_radius` hints at the full shield radius that will pop on
	# fire.
	_spawn_windup_vfx()

	return true

func _execute_echo() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T168 (#86) — Free the windup VFX *before* emitting echo_fired so
	# the echo VFX (spawned in player._on_echo_fired) replaces the
	# windup sphere in the same frame — no 1-frame overlap.  Mirrors
	# pulse_ability._execute_pulse (T166 #85) / bind_ability._execute_bind
	# (T167 #86) / cut_ability._execute_cut (T169 #87).
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking
	PlayerStats.record_ability_used("echo")

	# Activate the shield.  D002.B — pre-D002.B code cleared
	# `_reflected_this_cast` at start_echo; now we clear it here
	# so the cleanup happens at the same lifecycle moment as
	# `_is_active = true` (single source of truth for "cast
	# lifecycle state reset").
	_is_active = true
	_active_timer = active_time
	_reflected_this_cast.clear()

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

# D002.B (#98) — `_execute` virtual from base.  Subclass implements
# the verb-specific happy-path body.
func _execute() -> void:
	_execute_echo()

# D002.B (#98) — `_spawn_windup_vfx` virtual from base.  Subclass
# implements the verb-specific spawn.  Echo's `trigger()` takes 4
# args (vs 3 for pulse/bind/wave) — the extra `echo_radius` is
# the *full* shield radius, not the windup's `0.5 * echo_radius`
# half-radius; this hints at the size of the shield that will pop
# on fire.
func _spawn_windup_vfx() -> void:
	_attach_windup_vfx(preload("res://src/scripts/echo_windup_vfx.gd"))
	_windup_vfx.trigger(_pending_origin, echo_radius * 0.5, echo_radius, windup_time)

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

# D002.B (#98) — `_consume_verb_cost` / `_setup_windup_state` /
# `_exit_tree` / `get_cooldown_ratio` / `is_winding_up` all moved to
# the base (VerbAbilityBase).  This subclass inherits them verbatim.
# The pre-D002.B copies (F007 #87 + T168 #86 + T173 #92) are deleted
# from this file.
