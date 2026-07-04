class_name WhisperVFX
extends Node2D

## F013.E (#159) — Whisper 6 verb 静默场 VFX
## 设计：0.15s 持续期间在玩家位置绘制 1 个 Mauve 球 (constant radius)
##   - L1 OUTER_FILL  whisper_color  1.00× R  α0.18 (球内柔光)
##   - L2 SPHERE_RING whisper_color  1.00× R  α0.85 (球外 2px 描边)
##   - L3 CORE_DOT    whisper_color  0.20× R  αblink (球心)
##   - L4 HIT_FLASH×N whisper_color  1..3 px  α0.70 (命中闪烁)
## 与 Wave 的「扩散光环」形成对比:
##   - Wave = 圆环从 0 扩散到 max (向外)
##   - Whisper = constant 球 (原地静默)
## Whisper 是 6 verb, 比 5 verb 简单, VFX 也保持短小精悍.

@export var whisper_color: Color = Color("#C8A4D8")    # Muted Mauve 主色
@export var hit_flash_color: Color = Color("#E6D5B8") # Warm Parchment 命中闪烁

const RING_THICKNESS: float = 2.0
const CORE_DOT_RADIUS_RATIO: float = 0.20

var _lifetime: float = 0.0
var _max_lifetime: float = 0.15
var _max_radius: float = 50.0
var _is_active: bool = true
# 6 verb 接入路径 §9.1 第 6 步: 跟 Wave VFX 一样暴露 trigger 入口.
# Wave 用 (origin, max_radius), Whisper 是 1 球 (origin 跟随 player),
# 但接口签名保持一致 (5+1 verb VFX 家族对称).


func _ready() -> void:
	z_index = 50


func trigger(origin: Vector2, max_radius: float) -> void:
	global_position = origin
	_max_radius = max_radius
	_lifetime = 0.0
	_is_active = true


func _process(delta: float) -> void:
	if not _is_active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		fade_out_and_free()
		return
	queue_redraw()


func fade_out_and_free() -> void:
	# T173 (#92) — 5+1 verb VFX 统一接口.
	if not is_inside_tree():
		queue_free()
		return
	_is_active = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	tween.tween_callback(queue_free)


func flash_hit(target_pos: Vector2) -> void:
	# 6 verb 命中闪烁接口 (player.gd handler 调), 复用 hit_flash_color
	# 与 5 verb bounce flash 同色调 (Warm Parchment).
	pass  # 6 verb 简化版: 球体本身已经在每个 _process 重绘, 不需额外 flash


func _draw() -> void:
	if not _is_active:
		return
	var t: float = clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	# Whisper 是 constant 球, 不扩散. 但 alpha 在 0.0→1.0→0.0 起伏:
	#   前半 (0.0→0.5): 0.18→0.85 渐显
	#   后半 (0.5→1.0): 0.85→0.0 渐隐
	var ring_alpha: float = sin(t * PI) * 0.85  # 0 → 0.85 → 0 起伏
	var fill_alpha: float = sin(t * PI) * 0.18

	var ring_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, ring_alpha)
	var fill_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, fill_alpha)
	var core_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, ring_alpha * 0.8)

	# L1 OUTER_FILL — 球内柔光
	draw_circle(Vector2.ZERO, _max_radius, fill_color)
	# L2 SPHERE_RING — 球外 2px 描边
	draw_arc(Vector2.ZERO, _max_radius, 0.0, TAU, 32, ring_color, RING_THICKNESS)
	# L3 CORE_DOT — 球心亮点
	draw_circle(Vector2.ZERO, _max_radius * CORE_DOT_RADIUS_RATIO, core_color)
