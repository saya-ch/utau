class_name VerbAbilityBase
extends Node
# D002.B (#97) — VerbAbilityBase 父类
#
# 5 verb ability (Pulse / Bind / Cut / Echo / Wave) 共享契约:
# - 共享状态: _cooldown_timer / _windup_timer / _is_winding_up /
#   _pending_origin / _pending_direction / _windup_vfx
# - 共享方法: _consume_verb_cost(cost) / _setup_windup_state(origin, direction, windup_time)
#   / _exit_tree() / _safe_free_windup_vfx()
# - 共享语义: 5 verb 都是 0.04~0.10s windup + cooldown + cost + state
#   tracking, 实现 byte-identical
#
# 5 verb 接入模板:
#   extends "res://src/scripts/_verb_ability_base.gd"
#   # (1) 设 @export var windup_time / cooldown / cost / radius 等
#   # (2) 实现 start_X(origin, direction) -> bool (用 _consume_verb_cost + _setup_windup_state(origin, direction, windup_time))
#   # (3) 实现 _execute_X() (用 emit _fired + play_X() 5 verb audio cue T181)
#   # (4) _exit_tree() 继承自动处理 windup VFX fade-and-free
#
# D002.B (#97) 决策: path-based extends (与 T174.B #94 windup VFX base 同模式)
#   避免 class_name load order 边角:
#     - class_name 模式: 5 verb 5 个全局注册 + base 1 个全局注册 + 5 verb 引用 base
#       形成 11 个 load-order 边角, 在 headless smoke test 中可能滞后
#     - path-based 模式: 5 verb 直接加载 .gd 文件, load-order 决定性
#   GDScript 4.6.3 解析器优先 file-based extends, 无运行时开销差异
#
# D002.B (#97) windup_time 边界: 5 verb 各自 @export var windup_time: float =
# X.X (Pulse=0.10 / Bind=0.10 / Cut=0.04 / Echo=0.08 / Wave=0.10).  GDScript
# parser 不允许子类重新声明父类同名字段, 所以 windup_time 留在 5 verb
# 上, base 的 _setup_windup_state 改为显式接受 windup_time 参数.  这样
# base 自身 parse 不会触发 "Identifier windup_time not declared" 错,
# 5 verb 调用时传 self.windup_time 即可.

# === 共享 state (5 verb byte-identical) ===

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO

# T166/T167/T168/T169/T171 (#85-#89) — Live handle to the pre-X windup VFX
# so _execute_X() can free it the instant the X VFX (e.g. pulse_vfx.gd /
# bind_vfx.gd / cut_vfx.gd / echo_vfx.gd / wave_vfx.gd) takes over (avoids
# a 1-frame overlap where both visuals are visible).  Null when no windup
# is active.  This is the 5-verb windup VFX pattern from T166-#171.
var _windup_vfx: Node2D = null

# === 共享方法 (5 verb byte-identical) ===

# F007 (#87) — Shared cost-consumption step across the 5 verb abilities
# (pulse / bind / cut / echo / wave).  Returns true if cost was paid,
# false if the GameState autoload is missing or resonance is insufficient.
# D002.B (#97) — Promoted from F007 byte-identical copy in 5 verb files
# to a true base class method.  Single source of truth.
func _consume_verb_cost(cost: int) -> bool:
	if GameState == null:
		return false
	return GameState.consume_resonance(cost)

# F007 (#87) — Shared windup-state setup step across the 5 verb abilities.
# Sets the 4 internal fields that _process() and _execute_X() read on the
# next frame.  Idempotent within a single cast (the verb's can_X() check
# at start_X entry guarantees we're not already winding up).
# D002.B (#97) — windup_time is now passed as a parameter (5 verb
# subclasses each have their own @export var windup_time: float = X.X
# with different defaults — Pulse 0.10, Bind 0.10, Cut 0.04, Echo
# 0.08, Wave 0.10 — and GDScript parser disallows re-declaring
# inherited fields, so we can't put it on the base).  Callers pass
# `self.windup_time` to keep the byte-identical semantics.
func _setup_windup_state(origin: Vector2, direction: Vector2, windup_time: float) -> void:
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction

# T173 (#92) — Clean up the windup VFX if the player / scene is freed
# mid-windup.  Switched from hard queue_free() to fade_out_and_free()
# (0.05s modulate.a 1→0 tween then free).  Avoids a "hard pop" when
# the verb is interrupted (player death, room transition during the
# 0.04~0.10s windup window).  See <verb>_windup_vfx.gd:fade_out_and_free
# for the contract.
# D002.B (#97) — Promoted from T166/T167/T168/T169/T173 5 verb
# byte-identical _exit_tree() copies to base class.  Single source of truth.
func _exit_tree() -> void:
	_safe_free_windup_vfx()

# Internal helper for _exit_tree + manual interrupt cleanup.  Idempotent —
# safe to call multiple times (subsequent calls are no-ops if VFX is null).
func _safe_free_windup_vfx() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.fade_out_and_free()
	_windup_vfx = null
