class_name EchoVFX
extends Node2D

## EchoVFX — Echo 护盾视觉
## 设计：玻璃青球体 + 8 方向棱镜光线 + 中心 Amber Voice 暖点 + 持
## 续期间 1.2Hz 呼吸缩放 + 反弹命中 Coral Pulse 闪光 + 破碎时碎片
## 飞溅。EchoAbility 通过 trigger_rebound / trigger_destroyed 回
## 调驱动命中反馈；shield 默认 0.6s 寿命，结束自动 queue_free。
##
## 关键差异（与其他动词 VFX）：
## - 持续时间较长（0.6s vs Pulse 0.4s），因此画风偏"驻留"而非"闪
##   逝"：呼吸 + 棱镜光线持续可见。
## - 反弹命中时直接重绘中心 Coral Pulse 闪光（1 帧到 0.1s 衰减），
##   而非走新 spawn — 减少 Node 计数 + 视觉连续性更好。
## - 破碎时 8 个碎片向外飞 0.4s 衰减，淡出。

@export var shield_color: Color = Color("#69C7CE")      # Glass Cyan 主色
@export var prism_color: Color = Color("#B7E7DD")      # Pale Resonance 棱镜
@export var core_color: Color = Color("#F2B66E")       # Amber Voice 中心
@export var reflect_color: Color = Color("#E86D5A")    # Coral Pulse 反弹

var _lifetime: float = 0.0
var _max_lifetime: float = 0.6
var _active: bool = false
var _max_radius: float = 44.0
var _origin: Vector2 = Vector2.ZERO

# 反弹命中 — 多次叠加会取最新一次（避免同帧反弹两颗时颜色洗白）
var _rebound_flash: float = 0.0
const REBOUND_FLASH_DECAY := 0.1
# 破碎 — 一次性，触发后置 _breaking=true，1 帧后 shield 切到破碎
# 动画 (0.4s 碎片飞溅)
var _breaking: bool = false
var _break_lifetime: float = 0.0
const BREAK_DURATION := 0.4

# 8 个棱镜光线的角度（用于碎片飞溅复用）
const PRISM_ANGLES := [0.0, PI * 0.25, PI * 0.5, PI * 0.75, PI, PI * 1.25, PI * 1.5, PI * 1.75]
# 8 碎片"种子" — 用角度+距离做径向运动
var _break_pieces: Array = []

func _ready() -> void:
	z_index = 9  # 略低于 PulseVFX (10)，避免覆盖玩家 sprite
	add_to_group("echo_vfx")
	set_meta("echo_vfx_active", true)

func _process(delta: float) -> void:
	if _breaking:
		_break_lifetime += delta
		if _break_lifetime >= BREAK_DURATION:
			_active = false
			queue_free()
			return
		queue_redraw()
		return

	if not _active:
		return

	_lifetime += delta
	if _rebound_flash > 0:
		_rebound_flash = maxf(0.0, _rebound_flash - delta)
	if _lifetime >= _max_lifetime:
		# 优雅结束 — 不走破碎（破碎仅在 trigger_destroyed 时）
		_active = false
		queue_free()
		return
	queue_redraw()

func trigger(origin: Vector2, max_radius: float) -> void:
	global_position = origin
	_origin = origin
	_max_radius = max_radius
	_lifetime = 0.0
	_rebound_flash = 0.0
	_breaking = false
	_break_lifetime = 0.0
	_break_pieces.clear()
	_active = true
	queue_redraw()

func trigger_rebound(at: Vector2) -> void:
	# 反弹命中 — 在指定位置闪一次 Coral Pulse，0.1s 衰减
	if not _active:
		return
	_rebound_flash = 1.0
	queue_redraw()

func trigger_destroyed(at: Vector2) -> void:
	# 护盾被过近投射物砸碎 — 切到破碎动画 0.4s
	if _breaking:
		return
	_breaking = true
	_break_lifetime = 0.0
	# 在 at 位置生成 8 颗碎片，每颗带角度 + 速度
	for ang in PRISM_ANGLES:
		_break_pieces.append({
			"angle": ang + randf_range(-0.15, 0.15),
			"speed": randf_range(40.0, 80.0),
			"size": randf_range(1.5, 2.5),
		})
	queue_redraw()

func _draw() -> void:
	if _breaking:
		_draw_break()
		return
	if not _active:
		return

	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	# 0→0.15s 渐入到全亮，0.45s→0.6s 渐出
	var envelope: float
	if t < 0.25:
		envelope = t / 0.25
	elif t > 0.75:
		envelope = (1.0 - t) / 0.25
	else:
		envelope = 1.0
	envelope = clampf(envelope, 0.0, 1.0)

	# 呼吸缩放：1.2Hz 振幅 4%
	var breath := 1.0 + sin(_lifetime * TAU * 1.2) * 0.04
	var r := _max_radius * breath

	# --- 1. 球体半透明底 ---
	var body_alpha := 0.22 * envelope
	var body := shield_color
	body.a = body_alpha
	draw_circle(Vector2.ZERO, r, body)

	# --- 2. 球体高光（左上 Pale Resonance 小光斑）---
	var hl := prism_color
	hl.a = 0.55 * envelope
	draw_circle(Vector2(-r * 0.35, -r * 0.35), r * 0.18, hl)

	# --- 3. 8 方向棱镜光线（淡出）---
	for ang in PRISM_ANGLES:
		var ray_len := r * (0.55 + 0.15 * sin(_lifetime * 3.0 + ang * 2.0))
		var ray_col := prism_color
		ray_col.a = 0.45 * envelope
		var dir := Vector2(cos(ang), sin(ang))
		var inner := dir * r * 0.55
		var outer := dir * (r * 0.55 + ray_len * 0.5)
		draw_line(inner, outer, ray_col, 1.5)

	# --- 4. 球体外环 1px Glass Cyan ---
	var ring := shield_color
	ring.a = 0.85 * envelope
	draw_arc(Vector2.ZERO, r, 0, TAU, 48, ring, 1.5)

	# --- 5. 中心 Amber Voice 暖点 + 暖白高光 ---
	var core_alpha := 0.7 * envelope
	var core := core_color
	core.a = core_alpha
	draw_circle(Vector2.ZERO, r * 0.12, core)
	var core_hl := Color(1.0, 0.97, 0.85)
	core_hl.a = core_alpha * 0.7
	draw_circle(Vector2(-r * 0.04, -r * 0.04), r * 0.04, core_hl)

	# --- 6. 反弹命中闪光（覆盖中心）---
	if _rebound_flash > 0:
		var flash_alpha := _rebound_flash * 0.7
		var flash_col := reflect_color
		flash_col.a = flash_alpha
		draw_circle(Vector2.ZERO, r * 0.35, flash_col)
		# 8 个放射箭头短线
		for ang in PRISM_ANGLES:
			var dir := Vector2(cos(ang), sin(ang))
			var p1 := dir * r * 0.4
			var p2 := dir * r * (0.6 + 0.2 * _rebound_flash)
			var c := reflect_color
			c.a = flash_alpha
			draw_line(p1, p2, c, 2.0)

func _draw_break() -> void:
	# 8 颗碎片径向飞溅，0.4s 内 alpha 1→0
	var t := clampf(_break_lifetime / BREAK_DURATION, 0.0, 1.0)
	var alpha := 1.0 - t
	for piece in _break_pieces:
		var dist: float = float(piece["speed"]) * _break_lifetime
		var pos := Vector2(cos(piece["angle"]), sin(piece["angle"])) * dist
		# 旋转：4 帧抖动
		var rot_t := _break_lifetime * 8.0
		var offset := Vector2(cos(rot_t) * piece["size"], sin(rot_t) * piece["size"])
		var col := shield_color
		col.a = 0.85 * alpha
		draw_circle(pos + offset, piece["size"], col)
		# 暖琥珀中心点
		var core := core_color
		core.a = 0.6 * alpha
		draw_circle(pos + offset, piece["size"] * 0.5, core)
