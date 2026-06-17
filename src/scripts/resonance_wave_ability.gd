class_name ResonanceWaveAbility
extends VerbAbilityBase

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

signal wave_hit(target: Node, knockback: Vector2)
# T146 (#76) — wave_combo fires on the same frame as wave_expired, but
# only when the just-finished cast hit >= combo_threshold enemies. The
# threshold defaults to 3 (a single Wave at base radius ~80 with a
# dense encounter typically hits 2-4 enemies; 3+ means the player
# committed a real AOE, not a glancing 2-enemy pop). The signal carries
# the hit count so player.gd can scale feedback (more hits → bigger
# shake). Emitted BEFORE _hit_this_cast.clear() so listeners see the
# count even though we wipe the array right after. Per-verb combo
# signal — Pulse / Cut are single-target so they don't need a combo
# variant (each cast is at most 1 hit); Echo is a shield, not an attack.
# Wave is the only verb that can hit multiple enemies per cast, hence
# the only one that needs a combo hook today.
signal wave_combo(hit_count: int)
signal wave_expired

# T168 (#86) — wave_fired signal is defined in the base as part of
# the verb family contract.  Re-declared here for explicit visibility
# (it stays identical to the inherited one because signal names are
# additive in GDScript — declaring it again is a no-op).  We keep
# the `signal wave_fired` for smoke test compatibility
# (test_t103_resonance_wave_smoke.gd checks signal existence).
signal wave_fired(origin: Vector2, radius: float)

@export var wave_radius: float = 80.0
@export var wave_cost: int = 50
# T103 (#73) — Wave's cooldown is 6.0s (the longest of the 5 verbs,
# matching "AOE = 重武器" 心智模型).  Override the base default (0.5)
# with 6.0 here.
@export var cooldown: float = 6.0
@export var windup_time: float = 0.10
@export var active_time: float = 0.4
@export var wave_damage: int = 1
@export var enemy_knockback: float = 80.0
@export var enemy_slow_duration: float = 0.5
# T146 (#76) — Combo threshold exposed as @export so the balance team
# can tune it from the inspector without touching code. Default 3
# matches the rationale above (single Wave base radius hits 2-4 in
# typical encounters, so 3 is the "feels-good" floor). Set to 1 to
# disable combo (every hit shakes), or 5 for hardcore-only combos.
@export var wave_combo_threshold: int = 3

# D002.B (#98) — Wave has verb-specific state: _is_active (wave
# expanding or not) + _active_timer (expansion countdown) +
# _current_radius (expanding radius) + _hit_this_cast (track enemies
# to prevent multi-hit chains).  These are NOT in the base (they're
# Wave-specific) so they stay in the subclass.
var _is_active: bool = false
var _active_timer: float = 0.0
var _current_radius: float = 0.0
# Track enemies already hit by this cast to prevent multi-hit chains
# (the wave passes through each enemy exactly once)
var _hit_this_cast: Array = []

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "ResonanceWaveAbility must be child of CharacterBody2D")
	# T103 (#74 second half) — Apply wave_focus perk bonus to base radius.
	# Mirrors EchoAbility's pattern of pulling get_wave_radius_bonus() and
	# adding to its base — keeps the 5-verb symmetry intact when a fifth
	# perk lands.  Idempotent: re-apply on shop purchase re-call (see
	# ShopMenu._on_buy_pressed for the manual re-pull path).
	# GameState is an autoload so `is null` only in headless test contexts —
	# guard with has_method to keep the smoke tests runnable.
	if GameState and GameState.has_method("get_wave_radius_bonus"):
		wave_radius += float(GameState.get_wave_radius_bonus())

# D002.B (#98) — _process delegated to base.  Wave overrides
# _on_extra_process() to handle the active expansion window.
func _process(delta: float) -> void:
	super(delta)

# D002.B (#98) — Wave-specific extra process: expansion per-frame work.
# Base _process calls this AFTER the cooldown + windup ticks.
func _on_extra_process(delta: float) -> void:
	if _is_active:
		_active_timer -= delta
		# Expand the wave radius linearly over the active window
		_current_radius = wave_radius * (1.0 - _active_timer / active_time)
		_perform_wave_check()
		if _active_timer <= 0:
			_deactivate_wave()

# D002.B (#98) — Wave's extra can-fire check: can't recast while wave is expanding.
func _can_fire_extra() -> bool:
	return not _is_active

func can_wave() -> bool:
	return _cooldown_timer <= 0 \
		and GameState.resonance >= wave_cost \
		and not _is_winding_up \
		and _can_fire_extra()

func start_wave(origin: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  The 2-step "can-fire + pay-cost"
	# gate is now in the base (F007 #87 shared contract).
	if not can_wave():
		return false

	if not _consume_verb_cost(wave_cost):
		return false

	# F007 (#87) — Wave doesn't take a direction (omnidirectional AOE).
	_setup_windup_state(origin, Vector2.ZERO)
	_hit_this_cast.clear()

	# T171 (#89) — Spawn the 5-verb windup family member for Wave.
	# The "halo" motif (3 concentric rings, phase-staggered outward)
	# reads as a sound wave radiating — distinct from Pulse's inward
	# ring, Bind's spiral twist, Echo's sphere pop, and Cut's
	# directional streak.  Half-radius (0.5× wave_radius) so the halo
	# reads as "precursor", not "fire", and auto-frees after
	# windup_time as a safety net (mirrors the 4-verb pattern).
	var windup_vfx := preload("res://src/scripts/wave_windup_vfx.gd").new()
	windup_vfx.trigger(_pending_origin, wave_radius * 0.5, windup_time)
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(windup_vfx)
	# T173 (#92) — Stash the spawned VFX reference so _exit_tree()
	# (now owned by base) can fade it out cleanly on interrupt.
	_windup_vfx = windup_vfx

	return true

# D002.B (#98) — _on_windup_expired (was _execute_wave) — verb-specific
# fire logic.  Calls _execute_verb_common() for shared bookkeeping,
# then activates the wave expansion.
func _on_windup_expired() -> void:
	_execute_verb_common()

	# Activate the wave (start expanding)
	_is_active = true
	_active_timer = active_time
	_current_radius = 0.0

	# Emit signal so VFX + SFX can react at the exact moment the wave
	# starts expanding (rather than at the windup start, which would
	# be misleading — the wave doesn't exist during windup).
	wave_fired.emit(_pending_origin, wave_radius)

	# T181 (#97) — Play Wave fire audio cue paired with the fire-VFX
	# frame (wave_vfx.gd's expanding pale ring).  See _generate_wave_fire_sfx
	# (F004.B #96) for timbre: 100Hz low bloom + 220Hz perfect-5th +
	# 200Hz 2x harmonic (0.30s, slowest decay of the 4 fire SFX).
	# Guarded by _player-validity.
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_wave_fire()

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
	# T146 (#76) — Emit wave_combo BEFORE clearing _hit_this_cast so
	# listeners see the actual count. Only emit when the cast cleared
	# the threshold; otherwise wave_combo stays silent (wave_expired
	# is always emitted). This matches the cut_combo / pulse_combo
	# pattern: silent on the "normal" cast, fired on the "rare big".
	# _hit_this_cast is local to this cast (cleared in start_wave),
	# so reading its size here is exact for the just-finished cast.
	if _hit_this_cast.size() >= wave_combo_threshold:
		wave_combo.emit(_hit_this_cast.size())
	_is_active = false
	_hit_this_cast.clear()
	_current_radius = 0.0
	wave_expired.emit()

func is_wave_active() -> bool:
	return _is_active

func get_current_wave_radius() -> float:
	return _current_radius

# T142 (#75) — 5-verb chain anti-misinput safety net.
# When Wave is in its 0.10s windup, the other 4 verbs (Pulse/Bind/Cut/Echo)
# must NOT be able to fire, otherwise a fast chain press like Wave→Pulse
# would double-cast and waste resonance.  Returns true ONLY during windup
# (not during the 0.4s active expansion — that window is the wave's own
# gameplay, and the player should be free to queue the next verb).
# Mirrors the established EchoAbility `is_shield_active()` pattern of
# exposing a single boolean for the player.gd handlers to early-out on.
#
# D001 (#82) — The composite check (_is_dying + wave_ability.is_globally_blocking)
# moved to the PlayerActionGate autoload (see src/autoload/player_action_gate.gd).
# This method stays as the canonical source for the windup flag itself —
# the autoload DELEGATES to it (via wave_ability.is_globally_blocking()),
# it doesn't shadow.  The autoload pattern lets future boss / cutscene
# scripts probe the same composite gate without reaching into player
# internals.
func is_globally_blocking() -> bool:
	return _is_winding_up

# D002.B (#98) — verb cost / verb name virtuals (overrides base).
func get_verb_cost() -> int:
	return wave_cost

func get_verb_name() -> StringName:
	return &"wave"
