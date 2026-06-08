class_name ResonanceWaveAbility
extends Node

## Resonance Wave 声波能力（第五动词）
## 设计：短前摇 + 圆形扩散波（0.4s 内 0→wave_radius）+ 群体判定
## 功能：在玩家位置向四周扩散一道声波圆环，对路径上所有敌人造成：
##   - 1 点直接伤害（与 Echo 反弹伤害一致，作为"群攻"的 soft punish）
##   - 短促击退（80px，温和）
##   - 短暂减速/眩晕（0.5s）
## 与 Pulse（推/破盾，圆环）/ Bind（牵引/暂停，螺旋）/ Cut（切断腐蚀链，弧斩）/ Echo（护盾反弹）形成对比
## Resonance Wave 是"群攻"动词，让玩家在多个弱敌人场景下有横扫手段
##
## 色域：Pale Resonance (#B7E7DD) — 区别于 Pulse(Coral) / Bind(Violet) / Cut(Amber) / Echo(Cyan)
## 5 动词色域互不重叠：
##   - Pulse = Coral Pulse (暖珊瑚)
##   - Bind = Muted Violet (暗紫)
##   - Cut = Amber Voice (暖琥珀)
##   - Echo = Glass Cyan (冷青)
##   - Wave = Pale Resonance (淡青白) — 偏冷最浅色，作为"光"区别于 Echo 的"盾"
##
## 设计哲学：Wave 是"共振"，是声音本身在扩散（光波感），不是 Echo 的"盾"
## 也不是 Pulse 的"冲击"。视觉上应该是"光晕式扩散"而不是"实心环"。

signal wave_fired(origin: Vector2, radius: float)
signal wave_hit(target: Node, knockback: Vector2)
signal wave_expired

@export var wave_radius: float = 80.0
@export var wave_cost: int = 50
@export var cooldown: float = 6.0
@export var windup_time: float = 0.10
@export var active_time: float = 0.4
@export var wave_damage: int = 1
@export var enemy_knockback: float = 80.0
@export var enemy_slow_duration: float = 0.5

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _active_timer: float = 0.0
var _is_winding_up: bool = false
var _is_active: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _current_radius: float = 0.0
# Track enemies already hit by this cast to prevent multi-hit chains
# (the wave passes through each enemy exactly once)
var _hit_this_cast: Array = []

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "ResonanceWaveAbility must be child of CharacterBody2D")
	# T103 (#74 second half) — Apply wave_focus perk bonus to base radius.
	# Mirrors EchoAbility's pattern of pulling get_echo_radius_bonus() and
	# adding to its base — keeps the 5-verb symmetry intact when a fifth
	# perk lands.  Idempotent: re-apply on shop purchase re-call (see
	# ShopMenu._on_buy_pressed for the manual re-pull path).
	# GameState is an autoload so `is null` only in headless test contexts —
	# guard with has_method to keep the smoke tests runnable.
	if GameState and GameState.has_method("get_wave_radius_bonus"):
		wave_radius += float(GameState.get_wave_radius_bonus())

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_wave()

	if _is_active:
		_active_timer -= delta
		# Expand the wave radius linearly over the active window
		_current_radius = wave_radius * (1.0 - _active_timer / active_time)
		_perform_wave_check()
		if _active_timer <= 0:
			_deactivate_wave()

func can_wave() -> bool:
	# Cannot fire while winding up OR while a previous wave is still expanding.
	# The wave locks re-casting until it fully expands, otherwise spamming
	# Wave would trivialize the AOE game.
	return _cooldown_timer <= 0 \
		and GameState.resonance >= wave_cost \
		and not _is_winding_up \
		and not _is_active

func start_wave(origin: Vector2) -> bool:
	if not can_wave():
		return false

	if not GameState.consume_resonance(wave_cost):
		return false

	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_hit_this_cast.clear()

	return true

func _execute_wave() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# Stats tracking
	PlayerStats.record_ability_used("wave")

	# Activate the wave (start expanding)
	_is_active = true
	_active_timer = active_time
	_current_radius = 0.0

	# Emit signal so VFX + SFX can react at the exact moment the wave
	# starts expanding (rather than at the windup start, which would
	# be misleading — the wave doesn't exist during windup).
	wave_fired.emit(_pending_origin, wave_radius)

func _perform_wave_check() -> void:
	# Origin follows the player so the wave stays centered as they move.
	# Using _pending_origin (frozen at fire time) would leave the wave
	# trailing behind for moving characters.
	var origin := _player.global_position + Vector2(0, -8)

	# Hit all enemies inside the current expanding radius (one-shot per cast)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		# Already hit by this cast — skip to prevent multi-hit chains
		if _hit_this_cast.has(enemy):
			continue
		var dist: float = enemy.global_position.distance_to(origin)
		if dist > _current_radius:
			continue
		_apply_wave_to_enemy(enemy, origin)
		_hit_this_cast.append(enemy)

func _apply_wave_to_enemy(enemy: Node, origin: Vector2) -> void:
	# Push the enemy outward (knockback away from wave center)
	var push_dir: Vector2 = (enemy.global_position - origin).normalized()
	if push_dir == Vector2.ZERO:
		push_dir = Vector2.UP
	var knockback: Vector2 = push_dir * enemy_knockback

	# Apply damage first (1, soft punish — Wave is AOE, not a single-target nuke)
	if enemy.has_method("take_damage"):
		enemy.take_damage(wave_damage, knockback)

	# Apply slow/stun (reuses apply_bind which BindAbility uses for the same purpose)
	if enemy.has_method("apply_bind"):
		enemy.apply_bind(enemy_slow_duration)

	wave_hit.emit(enemy, knockback)

func _deactivate_wave() -> void:
	_is_active = false
	_hit_this_cast.clear()
	_current_radius = 0.0
	wave_expired.emit()

func is_wave_active() -> bool:
	return _is_active

func get_current_wave_radius() -> float:
	return _current_radius

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up
