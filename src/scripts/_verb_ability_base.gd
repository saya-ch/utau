class_name VerbAbilityBase
extends Node
# D002.B (#98) — Common base class for the 5 verb ability scripts
# (PulseAbility / BindAbility / CutAbility / EchoAbility /
# ResonanceWaveAbility).  Extracts the byte-identical shared
# contract from #85-#97 13 轮 polish (F007 #87 共享 cost-consume +
# windup-state-setup 6 行) + T181 #97 5 verb cooldown jingle 跨帧守卫
# + T173 #92 5 verb _exit_tree fade_out_and_free hook + T166 #85-#87
# 5 verb get_cooldown_ratio / is_winding_up public API — into a
# single parent so future 6th-verb additions inherit the contract
# by `extends` rather than copy-paste.
#
# Why a true base class (vs a helper script / autoload):
#   - GDScript allows single-inheritance for class_name scripts, and
#     the 5 verb abilities all `extends Node` (sibling to each other),
#     so a Node-derived base class is the natural fit.  Mirrors the
#     #94 T174.B VerbWindupVFXBase pattern (also Node2D base +
#     5 verb windup extends), so the codebase has a consistent
#     "verb family has a base" convention.
#   - The 5 verb abilities share state fields (`_cooldown_timer` /
#     `_windup_timer` / `_is_winding_up` / `_pending_origin` /
#     `_pending_direction` / `_windup_vfx`) AND share process-step
#     behaviour (cooldown tick + cross-frame jingle trigger + windup
#     tick) AND share exit-step behaviour (_exit_tree fade-out).
#     Putting these in a base lets the verb-specific subclasses
#     focus on their unique parts: start_<verb>() entry gate,
#     _execute_<verb>() verb-specific fire logic, and any verb-
#     specific state (Echo `_is_active` shield, Wave `_active_timer`
#     + `_current_radius` expansion).
#
# Lifecycle contract (subclasses override the verb-specific parts):
#   1. `func get_verb_cost() -> int` — virtual: subclass returns its
#      cost (pulse_cost / bind_cost / cut_cost / echo_cost / wave_cost).
#      MUST return the subclass's verb-specific @export field, not a
#      magic number, so future per-verb tuning flows through.
#   2. `func get_verb_name() -> StringName` — virtual: returns the
#      verb id used by the T181 cooldown jingle lookup table
#      ("pulse" / "bind" / "cut" / "echo" / "wave").  Also used by
#      PlayerStats.record_ability_used(name).
#   3. `func _can_fire_extra() -> bool` — virtual: extra "can fire"
#      checks beyond the base (cooldown ready + resonance enough +
#      not winding up).  Default returns true; EchoAbility overrides
#      to add `not _is_active` (can't recast while shield is up);
#      ResonanceWaveAbility overrides to add `not _is_active` (can't
#      recast while wave is expanding).
#   4. `func _on_windup_expired() -> void` — virtual: subclass
#      implements the verb-specific fire (hit detection for
#      Pulse/Bind/Cut, shield activation for Echo, wave expansion
#      for Wave).  Base calls this from _process when the windup
#      timer hits zero.  Subclasses should call _execute_verb_common()
#      at the start to do the common bookkeeping.
#   5. `func _on_extra_process(delta) -> void` — virtual: optional
#      verb-specific per-frame work (Echo shield check, Wave
#      expansion).  Default no-op; Pulse / Bind / Cut don't need it.
#   6. `func start_<verb>(origin: Vector2, [direction: Vector2]) -> bool`
#      — public entry: subclasses call `_consume_verb_cost(get_verb_cost())`
#      + `_setup_windup_state(origin, dir)` + spawn their verb-specific
#      windup VFX.  The base does NOT own the windup VFX spawn — each
#      verb has its own VFX class (pulse_windup_vfx / bind_windup_vfx
#      / etc.), so that's still subclass responsibility.
#   7. `func _exit_tree() -> void` — base owns the fade_out_and_free
#      cleanup.  Subclasses do NOT need to override this.
#
# Public API the base owns (no subclass override needed):
#   - `func get_cooldown_ratio() -> float`
#   - `func is_winding_up() -> bool`
#   - `func _consume_verb_cost(cost: int) -> bool`
#   - `func _setup_windup_state(origin: Vector2, direction: Vector2) -> void`
#   - `func _execute_verb_common() -> void` (called by subclass _on_windup_expired)
#
# Pattern source: F007 (#87) explicitly identified the shared
# `_consume_verb_cost` + `_setup_windup_state` as "byte-identical
# copy in the other 3 verb abilities.  See ... GDScript
# cross-script inheritance note."  D002.B finally delivers the
# inheritance the #87 review flagged as a TODO.

# ===== Common state — owned by base, shared by 5 verb abilities =====
# (T166 #85 / T167 #86 / T168 #86 / T169 #87 / T171 #89) — 5 verb
# ability 共同 state 抽到 base。Subclasses 不重新声明（避免 shadow）。
var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO
# T166 / T167 / T168 / T169 / T171 / T173 — 5 verb ability 共同 windup
# VFX 句柄（每个 verb 各自一个引用，但 type/语义一致）。T173 (#92) 把
# `_exit_tree` hook 改 fade_out_and_free 时这字段也升级为共享契约。
var _windup_vfx: Node2D = null

# ===== Shared contract constants =====
# T166 (#85) — windup_time 0.04~0.10s 5 verb 共享节拍。Cut 0.06s / Pulse
# 0.10s / Bind 0.10s / Echo 0.08s / Wave 0.10s 由各 verb 子类设自己的
# `@export var windup_time` 默认值（Godot 不允许子类重声明父类成员，
# 所以 cooldown / windup_time 这 2 个 5-verb 同名字段不能放 base 当
# @export，必须子类各自声明）。`DEFAULT_COOLDOWN` / `DEFAULT_WINDUP`
# 是参考基线，仅供子类的 `extends` 文档 + 调试 + 单元测试查表。
const DEFAULT_COOLDOWN: float = 0.5
const DEFAULT_WINDUP: float = 0.10

# ===== _process (base owns the common ticks) =====
# T181 (#97) — Cooldown "ready" jingle. 5 verb 5 jingle 5 verb name 查表。
# base._process 用 get_verb_name() 查表 → AudioManagerEnhanced.play_verb_cooldown_ready
# 子类不需要每 verb 写一遍跨帧守卫 + jingle 触发。
#
# Subclass _process() 可 super._process(delta) 先调 base 共享 tick，
# 然后处理 verb-specific 状态（Echo `_is_active` shield, Wave
# `_active_timer` 扩散等）。Pulse / Bind / Cut 完全用 base _process
# 即可，无需 override。
func _process(delta: float) -> void:
	# Cooldown tick + cross-from-positive jingle guard (T181 #97)
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0:
			if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_verb_cooldown_ready"):
				AudioManagerEnhanced.play_verb_cooldown_ready(get_verb_name())

	# Windup tick — base 触发子类的 _on_windup_expired()（包含 verb-specific 逻辑）
	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			# 1) 共同 bookkeeping (子类的 _on_windup_expired 会再调一次
			# _execute_verb_common 自己做，但是 _is_winding_up=false 必须
			# 在 _on_windup_expired 内做之前已经发生 — 故这里先做)
			# 实际上我们让 _on_windup_expired 自己做全部 bookkeeping
			# (因为它需要先 _is_winding_up=false 才能安全 emit signal
			# 给 verb-specific VFX layer)。
			_on_windup_expired()

	# Verb-specific extra process (Echo shield, Wave expansion)
	_on_extra_process(delta)

# ===== Public API =====
# 5 verb 共有，byte-identical 实现。提到 base。
func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up

# ===== Shared helpers (F007 #87 抽到 base) =====
# Byte-identical 5 verb copies lifted to base.
func _consume_verb_cost(cost: int) -> bool:
	if GameState == null:
		return false
	return GameState.consume_resonance(cost)

func _setup_windup_state(origin: Vector2, direction: Vector2) -> void:
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction

# Common execute-bookkeeping called by every verb's _on_windup_expired.
# Subclasses call _execute_verb_common() at the start of their method
# to take care of "winding-up → false" + "cooldown → cooldown" +
# PlayerStats.record_ability_used(name).  The verb-specific fire
# (hit detection, shield activation, wave expansion) follows.
func _execute_verb_common() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown
	PlayerStats.record_ability_used(get_verb_name())

# ===== _exit_tree (T173 #92 5 verb 共享 hook) =====
# Byte-identical 5 verb copies lifted to base.  Subclasses do NOT
# need to override this — the windup VFX handle is the same field
# name (`_windup_vfx`) and the fade_out_and_free contract is the
# same (#92 T173 ramp-out 0.05s tween then queue_free).
func _exit_tree() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.fade_out_and_free()
	_windup_vfx = null

# ===== Virtual / hook methods (subclasses override) =====
# GDScript has no `abstract` keyword; the base provides a default
# implementation that subclasses MUST override.  The base's
# implementation is deliberately unhelpful so a missing override
# crashes immediately with a clear error rather than silently
# doing the wrong thing.

# Returns the resonance cost of this verb.  Subclasses return their
# hard-coded cost field (pulse_cost / bind_cost / cut_cost /
# echo_cost / wave_cost).  The base returns 0 so a missing override
# means "free verb" which is visibly wrong in playtest.
func get_verb_cost() -> int:
	return 0

# Returns the verb id used by PlayerStats + the T181 jingle lookup
# table.  Must be one of "pulse" / "bind" / "cut" / "echo" / "wave"
# (or a future 6th verb id).  The base returns empty so a missing
# override causes the T181 jingle to silently no-op (defensive
# behavior — see audio_manager_enhanced.play_verb_cooldown_ready
# which returns -1 on unknown verb name).
func get_verb_name() -> StringName:
	return &""

# Extra "can fire" check beyond cooldown + resonance + not winding up.
# Default returns true (single-shot verbs Pulse / Bind / Cut).  Echo
# and Wave override to also reject when `_is_active` (shield up /
# wave still expanding).
func _can_fire_extra() -> bool:
	return true

# Called by base._process when the windup timer hits zero.  Subclass
# implements verb-specific fire (hit detection / shield / expansion).
# Should call _execute_verb_common() at the start for bookkeeping.
func _on_windup_expired() -> void:
	pass

# Optional per-frame verb-specific work.  Default no-op.  Echo
# overrides for shield check + deactivation; Wave overrides for
# expansion tracking.
func _on_extra_process(_delta: float) -> void:
	pass
