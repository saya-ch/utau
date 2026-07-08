class_name WhisperVFX
extends Node2D

## F013.E (#159) — Whisper 6 verb 静默场 VFX
## 设计：0.15s 持续期间在玩家位置绘制 1 个 Mauve 球 (constant radius)
##   - L1 OUTER_FILL    whisper_color  1.00× R  α0.18 (球内柔光)
##   - L2 SPHERE_RING   whisper_color  1.00× R  α0.85 (球外 2px 描边)
##   - L3 EDGE_HIGHLIGHT whisper_color  1.04× R  α0.40 (外侧 1px 高亮, T251 #169 玩家可读性强化)
##   - L4 CORE_DOT      whisper_color  0.20× R  αblink (球心)
##   - L5 HIT_FLASH×N   hit_flash_color 2..4 px  α0.70 (命中闪烁, T251 #169 玩家可读性强化)
##   - L6 EXPANDING_RING whisper_color  0.60→1.20× R  α0.50→0 1px (0.15s 涟漪外环, T270 #189 玩家可读性 v7 强化)
## 与 Wave 的「扩散光环」形成对比:
##   - Wave = 圆环从 0 扩散到 max (向外, 范围 80px)
##   - Whisper = constant 球 (原地静默) + 1 个 0.15s 短程涟漪 (0.6×→1.2× R ~ 50→100px)
## Whisper 是 6 verb, 比 5 verb 简单, VFX 也保持短小精悍.
## T251 (#169) — 玩家可读性强化:
##   - 加 1 层 EDGE_HIGHLIGHT (R+4% 1px 描边) 让 constant 球在深背景
##     边缘可读 (L2 2px 主描边在 Ink Navy / Archive Blue 上对比已经够,
##     EDGE_HIGHLIGHT 给 "外侧薄光" 让球边界更立体).
##   - 实现 flash_hit(target_pos) (之前是 pass 占位), 仿 _on_wave_hit
##     模式: 命中敌人时 1 个 Warm Parchment 小圆 0.15s 衰减, 给玩家
##     "silence 场真的吃到了" 视觉确认. 与 5 verb hit 反馈同语义.
## T270 (#189) — 玩家可读性 v7 强化:
##   - 加 L6 EXPANDING_RING 1 个 1px 涟漪外环, 0.15s 期间 0.6×R → 1.2×R 短程
##     扩散, α 0.50 → 0 衰减. 解决 "Whisper 是 constant 球" 的「感知不到
##     sphere 真的生效」问题: 0.6→1.2× 短程扩散给玩家「球在轻轻涨起再收回」
##     的视觉确认, 但仍属「短程静态」对比 Wave 的「长程 0→80px 动态扩散」.
##   - 1px 描边 + 0.50 起始 alpha + 0.0 终点 alpha + 与 _max_lifetime 同步
##     0.15s, 0 影响游戏性能 (每帧 1 个 draw_arc), 0 触碰 5 verb VFX 家族.

@export var whisper_color: Color = Color("#C8A4D8")    # Muted Mauve 主色
@export var hit_flash_color: Color = Color("#E6D5B8") # Warm Parchment 命中闪烁

const RING_THICKNESS: float = 2.0
const EDGE_HIGHLIGHT_THICKNESS: float = 1.0
const EDGE_HIGHLIGHT_RADIUS_RATIO: float = 1.04
const EDGE_HIGHLIGHT_ALPHA: float = 0.40
const CORE_DOT_RADIUS_RATIO: float = 0.20
const HIT_FLASH_LIFETIME: float = 0.15   # T251 (#169) — 0.15s = 与 active_time 同步
const HIT_FLASH_BASE_RADIUS: float = 2.0
const HIT_FLASH_MAX_RADIUS: float = 4.0
const HIT_FLASH_ALPHA: float = 0.70
# T270 (#189) — L6 EXPANDING_RING 涟漪外环 3 const.
# 0.6×R 起始 (短程 30px @ R=50) → 1.2×R 终点 (短程 60px @ R=50), 与 Wave
# 0→80px 全程扩散形成「短程涟漪 vs 长程扩散」语义对比. 1px 描边 + 0.50 起始
# alpha + 0.0 终点 alpha 让涟漪"轻轻涨起再收回", 0 持续占屏, 0 干扰 5 verb VFX.
const EXPANDING_RING_THICKNESS: float = 1.0
const EXPANDING_RING_BASE_RATIO: float = 0.6
const EXPANDING_RING_PEAK_RATIO: float = 1.2
const EXPANDING_RING_PEAK_ALPHA: float = 0.50

var _lifetime: float = 0.0
var _max_lifetime: float = 0.15
var _max_radius: float = 50.0
var _is_active: bool = true
# 6 verb 接入路径 §9.1 第 6 步: 跟 Wave VFX 一样暴露 trigger 入口.
# Wave 用 (origin, max_radius), Whisper 是 1 球 (origin 跟随 player),
# 但接口签名保持一致 (5+1 verb VFX 家族对称).
# T251 (#169) — 加 _hit_flashes 数组: 仿 _on_wave_hit 模式, 命中时 append
# 一个 {pos, age, life} dict, _process 老化, _draw 渲染. dedup 在
# whisper_ability.gd 的 _hit_this_cast 数组已完成, 此处 0 重复.
var _hit_flashes: Array = []


func _ready() -> void:
	z_index = 50


func trigger(origin: Vector2, max_radius: float) -> void:
	global_position = origin
	_max_radius = max_radius
	_lifetime = 0.0
	_is_active = true
	_hit_flashes.clear()


func _process(delta: float) -> void:
	if not _is_active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		fade_out_and_free()
		return
	# T251 (#169) — 老化 hit flash 列表. 仿 _on_wave_hit / resonance_wave_vfx.gd
	# 模式: 在 _bounces 数组里 age += delta, 满 life 移除. reversed
	# 循环防 remove_at 索引错位.
	for i in range(_hit_flashes.size() - 1, -1, -1):
		var h: Dictionary = _hit_flashes[i]
		h["age"] = h.get("age", 0.0) + delta
		_hit_flashes[i] = h
		if h["age"] >= h["life"]:
			_hit_flashes.remove_at(i)
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
	# T251 (#169) — flash_hit 实现. 之前是 pass 占位, 现在仿
	# resonance_wave_vfx.gd add_hit_flash(target_pos) 模式:
	# append 1 个 {pos, age, life} dict 到 _hit_flashes 数组,
	# _process 老化, _draw 渲染. 0 立即绘制 (下一个 _draw 帧才画).
	# F013.E (#159) 既有注释 "hit feedback 走 VFX 内部 _process
	# (alpha 起伏) 而非 per-enemy flash" 已不再准确 — 现在是 "alpha
	# 起伏 (sphere) + per-enemy flash (hit) 双层反馈", 与 5 verb
	# hit 反馈同语义, 但触发频率更克制 (Whisper 是 5s cooldown
	# 短窗口, 不像 Wave 1 cast 命中多敌).
	_hit_flashes.append({
		"pos": target_pos,
		"age": 0.0,
		"life": HIT_FLASH_LIFETIME,
	})


func _draw() -> void:
	if not _is_active:
		return
	var t: float = clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	# Whisper 是 constant 球, 不扩散. 但 alpha 在 0.0→1.0→0.0 起伏:
	#   前半 (0.0→0.5): 0.18→0.85 渐显
	#   后半 (0.5→1.0): 0.85→0.0 渐隐
	var ring_alpha: float = sin(t * PI) * 0.85  # 0 → 0.85 → 0 起伏
	var fill_alpha: float = sin(t * PI) * 0.18
	var edge_alpha: float = sin(t * PI) * EDGE_HIGHLIGHT_ALPHA  # T251 (#169) — 同 sin 起伏
	# T270 (#189) — L6 EXPANDING_RING 涟漪 alpha 独立计算:
	#   0.0→0.5: alpha 0 → PEAK_ALPHA 渐显
	#   0.5→1.0: alpha PEAK_ALPHA → 0 渐隐
	# 与 5 verb 起伏 0 冲突 (5 verb 是 0→peak→0 全程, Whisper 同模式 0 漂移)
	# 但 ring 半径 0.6→1.2×R 独立变化给"短程涟漪" 视觉确认.
	var expanding_alpha: float = sin(t * PI) * EXPANDING_RING_PEAK_ALPHA
	# 半径: 0 → 1 线性从 BASE_RATIO 涨到 PEAK_RATIO
	var expanding_radius: float = _max_radius * lerpf(EXPANDING_RING_BASE_RATIO, EXPANDING_RING_PEAK_RATIO, t)

	var ring_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, ring_alpha)
	var fill_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, fill_alpha)
	var edge_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, edge_alpha)
	var core_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, ring_alpha * 0.8)
	var expanding_color := Color(whisper_color.r, whisper_color.g, whisper_color.b, expanding_alpha)

	# L1 OUTER_FILL — 球内柔光
	draw_circle(Vector2.ZERO, _max_radius, fill_color)
	# L2 SPHERE_RING — 球外 2px 描边
	draw_arc(Vector2.ZERO, _max_radius, 0.0, TAU, 32, ring_color, RING_THICKNESS)
	# L3 EDGE_HIGHLIGHT (T251 #169) — 球外 1.04×R 1px 描边, 薄薄一层外光
	# 画在 L2 之后 (painter's order) 让外侧薄光叠在主描边之上, 给 constant
	# 球"边界更亮"的可读性, 0 半径扩散 (仍是 constant 球, 6 verb 唯一不
	# 扩散几何保留).
	draw_arc(
		Vector2.ZERO,
		_max_radius * EDGE_HIGHLIGHT_RADIUS_RATIO,
		0.0, TAU, 32, edge_color, EDGE_HIGHLIGHT_THICKNESS
	)
	# L4 CORE_DOT — 球心亮点
	draw_circle(Vector2.ZERO, _max_radius * CORE_DOT_RADIUS_RATIO, core_color)
	# L6 EXPANDING_RING (T270 #189) — 涟漪外环, 0.6×R → 1.2×R 0.15s 短程
	# 扩散. 画在 L3 EDGE_HIGHLIGHT 之后 (painter's order) 让涟漪叠在
	# 静态球 + 外侧薄光之上, 给"球在轻轻涨起"的视觉确认. 仍属"短程
	# 静态"对比 Wave 的"长程 0→80px 全程扩散" — 0 触碰 6 verb 唯一
	# "不扩散" 几何定义 (L1-L4 仍 constant, L6 是 0.6→1.2 短程范围).
	draw_arc(
		Vector2.ZERO,
		expanding_radius,
		0.0, TAU, 32, expanding_color, EXPANDING_RING_THICKNESS
	)

	# L5 HIT_FLASH (T251 #169) — 命中闪烁, 在 target_pos (世界坐标) 画
	# 1 个小圆, age / life 衰减 alpha + 微扩张半径. _hit_flashes 里的 pos
	# 是 target.global_position (世界坐标), 此 VFX 的 global_position 是
	# player 位置, 所以 to_local 转换到本地坐标系.
	for h in _hit_flashes:
		var hf: Dictionary = h
		var local_pos: Vector2 = to_local(hf["pos"])
		var hf_alpha: float = 1.0 - (hf["age"] / hf["life"])
		var hf_radius: float = lerpf(HIT_FLASH_BASE_RADIUS, HIT_FLASH_MAX_RADIUS, hf["age"] / hf["life"])
		var hf_color: Color = Color(
			hit_flash_color.r, hit_flash_color.g, hit_flash_color.b,
			hf_alpha * HIT_FLASH_ALPHA
		)
		draw_circle(local_pos, hf_radius, hf_color)
