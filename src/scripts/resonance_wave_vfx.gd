class_name ResonanceWaveVFX
extends Node2D

## Resonance Wave 声波 VFX（光晕式扩散圆环 + 8 方向棱镜光线）
## 设计：4 阶段动画
##   - 风蓄期 (windup, ~0.10s)：中心微亮点（Amber Voice）淡入
##   - 扩散期 (expand, 0.40s)：Pale Resonance 圆环从 0 扩散到 max_radius + 8 棱镜光线
##   - 命中闪烁 (per-hit, optional)：命中敌人时小型额外闪光（白色 + 短尾）
##   - 消散期 (fade, 0.20s)：圆环透明度衰减到 0
## 与 Pulse（圆环 cyan）/ Bind（螺旋 violet）/ Cut（弧斩 coral）/ Echo（护盾 cyan 球）形成第五类视觉组
## 视觉：Pale Resonance 冷白光环 + 8 方向淡光射线 + Glass Cyan 外环 + Amber Voice 中心点
## 风格严格遵循 STYLE_GUIDE：冷色光波为主 + 暖色中心点，色域不与前 4 动词重叠

@export var wave_color: Color = Color("#B7E7DD")        # Pale Resonance 主色（冷白光波）
@export var outer_ring_color: Color = Color("#69C7CE")  # Glass Cyan 外环
@export var core_color: Color = Color("#F2B66E")        # Amber Voice 中心暖点
@export var hit_flash_color: Color = Color("#E6D5B8")   # Warm Parchment 命中闪烁

var _lifetime: float = 0.0
var _max_lifetime: float = 0.85
var _active: bool = false
var _origin: Vector2 = Vector2.ZERO
var _max_radius: float = 80.0
var _current_radius: float = 0.0
var _bounces: Array = []   # Array of { pos: Vector2, age: float, life: float }

const WAVE_FADE_IN := 0.06        # 圆环从 0 开始淡入
const WAVE_EXPAND := 0.40         # 主扩散期
const WAVE_FADE_OUT := 0.30       # 消散期
const RAY_COUNT := 8              # 8 方向棱镜光线

func _ready() -> void:
	z_index = 10
	set_process(true)

func trigger(origin: Vector2, max_radius: float) -> void:
	_origin = origin
	_max_radius = max_radius
	_current_radius = 0.0
	_lifetime = 0.0
	_active = true
	position = Vector2.ZERO  # The wave is drawn at its own origin (already in world space)

func add_hit_flash(target_pos: Vector2) -> void:
	_bounces.append({"pos": target_pos, "age": 0.0, "life": 0.20})

func _process(delta: float) -> void:
	if not _active:
		return

	_lifetime += delta

	# Update bounce flashes
	for i in range(_bounces.size() - 1, -1, -1):
		var b: Dictionary = _bounces[i]
		b["age"] = b.get("age", 0.0) + delta
		_bounces[i] = b
		if b["age"] >= b["life"]:
			_bounces.remove_at(i)

	if _lifetime >= _max_lifetime:
		_active = false
		queue_free()
		return

	# Update current radius based on phase
	if _lifetime < WAVE_FADE_IN:
		# Fade-in phase: hold at 0
		_current_radius = 0.0
	elif _lifetime < WAVE_FADE_IN + WAVE_EXPAND:
		# Expand phase: 0 -> max_radius
		var t: float = (_lifetime - WAVE_FADE_IN) / WAVE_EXPAND
		_current_radius = _max_radius * t
	else:
		# Hold at max_radius during fade-out
		_current_radius = _max_radius

	queue_redraw()

func _draw() -> void:
	if not _active:
		return

	# Compute current alpha for fade-out
	var alpha: float = 1.0
	if _lifetime < WAVE_FADE_IN:
		alpha = _lifetime / WAVE_FADE_IN
	elif _lifetime > WAVE_FADE_IN + WAVE_EXPAND:
		var fade_t: float = (_lifetime - WAVE_FADE_IN - WAVE_EXPAND) / WAVE_FADE_OUT
		alpha = clampf(1.0 - fade_t, 0.0, 1.0)

	# Center: amber core dot (small, scales with wave radius)
	var core_radius: float = 1.5 + _current_radius * 0.02
	draw_circle(_origin, core_radius, Color(core_color.r, core_color.g, core_color.b, alpha * 0.9))

	if _current_radius < 1.0:
		return

	# Main ring: pale resonance filled (translucent)
	var ring_inner: Color = Color(wave_color.r, wave_color.g, wave_color.b, alpha * 0.18)
	draw_circle(_origin, _current_radius, ring_inner)

	# Outer ring stroke: glass cyan 2px
	var ring_outer: Color = Color(outer_ring_color.r, outer_ring_color.g, outer_ring_color.b, alpha * 0.85)
	draw_arc(_origin, _current_radius, 0.0, TAU, 64, ring_outer, 2.0)

	# 8 direction prism rays
	for i in range(RAY_COUNT):
		var angle: float = (TAU / RAY_COUNT) * i + _lifetime * 0.5  # slowly rotate
		var ray_end: Vector2 = _origin + Vector2(cos(angle), sin(angle)) * _current_radius
		draw_line(_origin, ray_end, Color(wave_color.r, wave_color.g, wave_color.b, alpha * 0.4), 1.0)

	# Draw bounce flashes
	for b in _bounces:
		var bf: Dictionary = b
		var bf_alpha: float = 1.0 - (bf["age"] / bf["life"])
		var bf_color: Color = Color(hit_flash_color.r, hit_flash_color.g, hit_flash_color.b, bf_alpha * 0.7)
		draw_circle(bf["pos"], 4.0 * bf_alpha + 1.0, bf_color)
