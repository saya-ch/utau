class_name WhisperWindupVFX
extends Node2D

## F013.E (#159) — Whisper 6 verb 风蓄期 VFX
## 设计：0.10s 期间在玩家位置绘制一个 Mauve 色柔粉紫圆球 + 4 条短促收敛线
##   - 圆球: 1.5 px 描边, alpha 0.0 → 0.6 (fade in)
##   - 收敛线: 4 条, 8 px 长, alpha 0.0 → 0.4
## 与 Wave 风蓄的 3 圈 halo (T171 #89) 形成对比:
##   - Wave = 声波扩散 (外向光晕)
##   - Whisper = 静默凝聚 (内向暗雾)
## 5 verb windup VFX 都遵循 .fade_out_and_free() 0.05s 模式 (T173 #92),
## Whisper 6 verb 也走这个, VerbAbilityBase._exit_tree() 统一调用.

@export var whisper_color: Color = Color("#C8A4D8")    # Muted Mauve 主色
@export var line_count: int = 4
@export var line_length: float = 8.0

var _lifetime: float = 0.0
var _max_lifetime: float = 0.10
var _max_radius: float = 25.0
var _is_active: bool = true


func _ready() -> void:
	z_index = 50  # VFX 在玩家上方 (与 wave_windup_vfx 一致)


func trigger(origin: Vector2, max_radius: float, duration: float) -> void:
	# F013.E (#159) — wave_windup_vfx.trigger 同模式 (T171 #89):
	# 接收 origin + radius + duration, 设置内部 state, 由 caller add_child.
	global_position = origin
	_max_radius = max_radius
	_max_lifetime = duration
	_lifetime = 0.0
	_is_active = true


func _process(delta: float) -> void:
	if not _is_active:
		return
	_lifetime += delta
	# Auto-free after duration as safety net (5 verb pattern, T171 #89).
	if _lifetime >= _max_lifetime:
		fade_out_and_free()
		return
	queue_redraw()


func fade_out_and_free() -> void:
	# T173 (#92) — 5 verb windup VFX 统一接口. 0.05s modulate.a 1→0 tween.
	# 6 verb 接入路径 §9.1 第 6 步: 必须暴露此方法, 否则
	# VerbAbilityBase._exit_tree() 调不到会 leak.
	if not is_inside_tree():
		queue_free()
		return
	_is_active = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if not _is_active:
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
