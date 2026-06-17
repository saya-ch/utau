class_name ResonanceWaveAbility
extends "res://src/scripts/_verb_ability_base.gd"

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
##
## D002.B (#98) — Now extends VerbAbilityBase.  Wave is unique among
## the 5 verbs in 2 ways:
##   1. start_wave() signature is (origin) only — omnidirectional, no
##      `_pending_direction` — passes `Vector2.ZERO` to the base
##      `_setup_windup_state` (the field is set but unused by _execute).
##   2. `_is_active` / `_active_timer` / `_current_radius` /
##      `_hit_this_cast` / `_perform_wave_check` /
##      `_apply_wave_to_enemy` / `_deactivate_wave` —
##      *post-fire* active state for the 0.4s expanding wave window.
##      These stay in the subclass (base owns the pre-fire windup
##      lifecycle only).
##
## All common state (`_cooldown_timer` / `_windup_timer` /
## `_is_winding_up` / `_pending_origin` / `_windup_vfx`) and
## common functions (`_consume_verb_cost` / `_setup_windup_state` /
## `_exit_tree` / `get_cooldown_ratio` / `is_winding_up`) now
## inherited from VerbAbilityBase.

signal wave_fired(origin: Vector2, radius: float)
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

@export var wave_radius: float = 80.0
@export var wave_cost: int = 50
@export var active_time: float = 0.4
@export var wave_damage: int = 1
@export var enemy_knockback: float = 80.0
@export var enemy_slow_duration: float = 0.5

# T146 (#76) — Live active-state for the 0.4s expanding wave window.
# Wave is the only verb with a *post-fire* active state that
# continuously expands (Pulse / Bind / Cut resolve in a single frame,
# Echo has a stationary shield).  Stays here (not in the base) because
# the 4 other verbs don't need this loop.
var _is_active: bool = false
var _active_timer: float = 0.0
var _current_radius: float = 0.0
# Track enemies already hit by this cast to prevent multi-hit chains
# (the wave passes through each enemy exactly once)
var _hit_this_cast: Array = []

func _ready() -> void:
	# D002.B (#98) — Parent VerbAbilityBase._ready() asserts
	# _player is non-null; subclass _ready extends with the
	# T103 wave_focus perk application + per-verb @export defaults.
	super._ready()
	# D002.B (#98) — Per-verb @export defaults.  See _verb_ability_base.gd.
	cooldown = 6.0
	windup_time = 0.10
	# T103 (#74 second half) — Apply wave_focus perk bonus to base radius.
	# Mirrors EchoAbility's pattern of pulling get_echo_radius_bonus() and
	# adding to its base — keeps the 5-verb symmetry intact when a fifth
	# perk lands.  Idempotent: re-apply on shop purchase re-call (see
	# ShopMenu._on_buy_pressed for the manual re-pull path).
	if GameState and GameState.has_method("get_wave_radius_bonus"):
		wave_radius += float(GameState.get_wave_radius_bonus())

# D002.B (#98) — `_process` overrides the base to extend the
# post-fire expanding wave check (the base handles windup +
# cooldown jingle).  Wave is the only verb with a *post-fire*
# active state that continuously expands.
func _process(delta: float) -> void:
	# D002.B (#98) — Base handles windup + cooldown jingle.
	super._process(delta)
	# F006 + T146 — Active expanding wave.  Stays here, not in
	# base, because the 4 other verbs are all "single frame
	# resolve" — they don't need this loop.
	if _is_active:
		_active_timer -= delta
		# Expand the wave radius linearly over the active window
		_current_radius = wave_radius * (1.0 - _active_timer / active_time)
		_perform_wave_check()
		if _active_timer <= 0:
			_deactivate_wave()

# D002.B (#98) — Virtual override.  Returns "wave" for the
# T181 cooldown jingle (A5 → C6 ascending major-3rd, 0.10s).
func _get_verb_name() -> String:
	return "wave"

func can_wave() -> bool:
	# Cannot fire while winding up OR while a previous wave is still expanding.
	# The wave locks re-casting until it fully expands, otherwise spamming
	# Wave would trivialize the AOE game.
	return _cooldown_timer <= 0 \
		and GameState.resonance >= wave_cost \
		and not _is_winding_up \
		and not _is_active

func start_wave(origin: Vector2) -> bool:
	# D002.B (#98) — Pre-fire guard.  Now inherits the 2-step
	# "can-fire + pay-cost" gate from the base.  Wave is
	# omnidirectional — passes `Vector2.ZERO` for direction.
	if not can_wave():
		return false

	if not _consume_verb_cost(wave_cost):
		return false

	# D002.B (#98) — Windup-state setup now in base; subclass just
	# calls it.  Wave's pre-D002.B code also cleared
	# `_hit_this_cast` here; that moved to `_execute_wave` (right
	# before the wave starts expanding) so the cleanup happens at
	# the same lifecycle moment as `_is_active = true`.
	_setup_windup_state(origin, Vector2.ZERO)

	# D002.B (#98) — Windup VFX spawn now in `_spawn_windup_vfx()`
	# virtual; this subclass implements the verb-specific preload
	# + trigger args.  Wave's "halo" windup (3 concentric rings,
	# phase-staggered outward) reads as a sound wave radiating —
	# distinct from Pulse's inward ring, Bind's spiral twist,
	# Echo's sphere pop, Cut's directional streak.
	_spawn_windup_vfx()

	return true

# D002.B (#98) — `_execute` virtual from base.  Subclass implements
# the verb-specific happy-path body.
func _execute() -> void:
	_execute_wave()

func _execute_wave() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# T171 (#89) — Free the windup VFX *before* emitting wave_fired so
	# the wave VFX (spawned in player._on_wave_fired) replaces the
	# windup halo in the same frame — no 1-frame overlap.  Pattern
	# mirrors pulse_ability._execute_pulse (T166 #85) /
	# bind_ability._execute_bind (T167 #86) / echo_ability._execute_echo
	# (T168 #86) / cut_ability._execute_cut (T169 #87).
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking
	PlayerStats.record_ability_used("wave")

	# Activate the wave (start expanding).  D002.B — pre-D002.B
	# code cleared `_hit_this_cast` at start_wave; now we clear
	# it here so the cleanup happens at the same lifecycle moment
	# as `_is_active = true` (single source of truth for "cast
	# lifecycle state reset").
	_is_active = true
	_active_timer = active_time
	_current_radius = 0.0
	_hit_this_cast.clear()

	# Emit signal so VFX + SFX can react at the exact moment the wave
	# starts expanding (rather than at the windup start, which would
	# be misleading — the wave doesn't exist during windup).
	wave_fired.emit(_pending_origin, wave_radius)

	# T181 (#97 first half) — Play Wave fire audio cue paired with
	# the fire-VFX frame (wave_vfx.gd's expanding pale ring).  Mirrors
	# the Pulse caller in pulse_ability.gd:_execute_pulse (F004 #94)
	# which fires AFTER pulse_fired.emit.  Closes the 5-verb audio
	# family loop.  See _generate_wave_fire_sfx (F004.B #96) for timbre:
	# 100Hz low bloom + 220Hz perfect-5th + 200Hz 2x harmonic
	# (0.30s, slowest decay of the 4 fire SFX).  Guarded by
	# _player-validity so an interrupted windup (player freed by
	# death during the 0.10s windup) doesn't crash on a stale
	# reference.
	if _player and is_instance_valid(_player):
		AudioManagerEnhanced.play_wave_fire()

# D002.B (#98) — `_spawn_windup_vfx` virtual from base.  Subclass
# implements the verb-specific spawn.  Wave's `trigger()` is 3-arg
# (origin, half_radius, windup_time) — same as pulse / bind; the
# "halo" (3 concentric rings) motif differentiates the windup from
# the other 4 verbs.
func _spawn_windup_vfx() -> void:
	_attach_windup_vfx(preload("res://src/scripts/wave_windup_vfx.gd"))
	_windup_vfx.trigger(_pending_origin, wave_radius * 0.5, windup_time)

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

# T146 (#76) — Combo threshold exposed as @export so the balance team
# can tune it from the inspector without touching code. Default 3
# matches the rationale above (single Wave base radius hits 2-4 in
# typical encounters, so 3 is the "feels-good" floor). Set to 1 to
# disable combo (every hit shakes), or 5 for hardcore-only combos.
@export var wave_combo_threshold: int = 3

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
#
# D002.B (#98) — `is_globally_blocking` is a Wave-specific verb-API
# surface (the 4 other verbs all use the base's `is_winding_up()`).
# Stays here.  Reads `_is_winding_up` from the base (inherited).
# Refactor context: D001 (autoload delegation) → D002.B (base class).
func is_globally_blocking() -> bool:
	return _is_winding_up

# D002.B (#98) — `_consume_verb_cost` / `_setup_windup_state` /
# `_exit_tree` / `get_cooldown_ratio` / `is_winding_up` all moved to
# the base (VerbAbilityBase).  This subclass inherits them verbatim.
# The pre-D002.B copies (F007 #87 + T171 #89 + T173 #92) are deleted
# from this file.
