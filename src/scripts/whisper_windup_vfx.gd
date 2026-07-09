class_name WhisperWindupVFX
extends "res://src/scripts/_verb_windup_vfx_base.gd"

## F013.E (#159) — Whisper 6 verb 风蓄期 VFX
## 设计：0.10s 期间在玩家位置绘制一个 Mauve 色柔粉紫圆球 + 4 条短促收敛线
##   - 圆球: 1.5 px 描边, alpha 0.0 → 0.6 (fade in)
##   - 收敛线: 4 条, 8 px 长, alpha 0.0 → 0.4
## 与 Wave 风蓄的 3 圈 halo (T171 #89) 形成对比:
##   - Wave = 声波扩散 (外向光晕)
##   - Whisper = 静默凝聚 (内向暗雾)
##
## T275 (#194) — F013.E 落地时 WhisperWindupVFX 0 extend `_verb_windup_vfx_base.gd`,
## 0 触碰 5 verb 任何代码, 自实现 3 字段 (`_lifetime` / `_max_lifetime` / `_is_active`)
## + 自实现 `_process(delta)` + 自实现 `fade_out_and_free()` (F013.E 漂移, §9.6.19
## T274 #193 文档化该 drift). T275 (#194) 收回该 drift, 让 Whisper 也
## `extends "res://src/scripts/_verb_windup_vfx_base.gd"` + 删 3 字段 +
## 删 `_process(delta)` + 删 `fade_out_and_free()` + 字段名 `_is_active` → `_active` 1:1 rename,
## 让 6 verb windup VFX 共享契约 1:1 严格分离 100% 闭环 (5 verb 全 extends
## VerbWindupVFXBase + 1 verb Whisper extends VerbWindupVFXBase).
## 业务特例: Whisper z_index = 50 (VFX 在玩家上方, 区别于 5 verb z_index = 10 在世界上方),
## 通过 override `_ready()` 调 `super._ready()` 集中 z_index=10 + 之后重设 z_index=50 业务需求.

@export var whisper_color: Color = Color("#C8A4D8")    # Muted Mauve 主色
@export var line_count: int = 4
@export var line_length: float = 8.0

var _max_radius: float = 25.0


func _ready() -> void:
	# T275 (#194) — 业务特例: Whisper VFX 在玩家上方 (z_index = 50),
	# 区别于 5 verb z_index = 10 (VFX 在世界上方).
	# §9.6.19 5 verb 0 override `_ready()` (z_index=10 集中), Whisper
	# 因业务需求 (VFX 在玩家上方) 必须 override. 调 super 集中 z_index=10,
	# 然后重设 z_index=50 业务需求, 1 verb 显式 override (与 §9.6.18
	# Wave 显式重写 byte-identical 重复模式 镜像).
	super._ready()
	z_index = 50


func trigger(origin: Vector2, max_radius: float, duration: float) -> void:
	# F013.E (#159) — wave_windup_vfx.trigger 同模式 (T171 #89):
	# 接收 origin + radius + duration, 设置内部 state, 由 caller add_child.
	global_position = origin
	_max_radius = max_radius
	# T275 (#194) — `_max_lifetime` 由 base 1:1 提供, 0 重声明.
	_max_lifetime = duration
	# T275 (#194) — Delegate ramp-in tween + state reset to base (与 5 verb 1:1).
	# T174.B (#94) 模式: base `_activate_windup_tween()` reset `_lifetime` /
	# `_active` + 启动 ramp-in modulate:a tween + queue_redraw().
	# 替换原 F013.E 自实现的 `_lifetime = 0.0; _is_active = true` 2 行 (漂移).
	_activate_windup_tween()


func _draw() -> void:
	# T275 (#194) — `_active` 1:1 rename (F013.E `_is_active` → base `_active`).
	# 0 触碰 base `_active` 字段 (base 1:1 提供, 0 重声明).
	if not _active:
		return
	var t: float = clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	# Mauve 圆球 — alpha 0 → 0.6 fade in
	var sphere_alpha: float = 0.6 * t
	var sphere_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, sphere_alpha)
	# 半径 0.5× → 0.95× (whisper_radius × 0.5 是 windup 起点, 终点是 max_radius × 0.95)
	var r: float = lerpf(_max_radius * 0.5, _max_radius * 0.95, t)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 24, sphere_color, 1.5)

	# 4 条短收敛线 — 8 px, alpha 0 → 0.4 fade in
	var line_alpha: float = 0.4 * t
	var line_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, line_alpha)
	for i in line_count:
		var angle: float = TAU * float(i) / float(line_count)
		var p0 := Vector2(cos(angle), sin(angle)) * (r * 0.5)
		var p1 := Vector2(cos(angle), sin(angle)) * (r * 0.5 + line_length)
		draw_line(p0, p1, line_color, 1.0)
