class_name EchoVFX
extends Node2D

## Echo 声波 VFX（护盾球 + 棱镜折射 + 反弹闪光）
## 设计：短前摇期（球体扩张 + 高光 0.08s）+ 持续期（球体呼吸 + 棱镜光线旋转）+ 反弹闪光（珊瑚色 VFX 子节点，0.25s 短闪）
## 与 Pulse（圆环 cyan）/ Bind（螺旋 violet）/ Cut（弧斩 coral）形成第四类视觉组
## 视觉：Glass Cyan 玻璃护盾球体 + Pale Resonance 棱镜光线 + 中心 Amber Voice 暖点
## 风格严格遵循 STYLE_GUIDE：冷色护盾为主 + 暖色中心点 + 反弹时 Coral Pulse 闪光

@export var shield_color: Color = Color("#69C7CE")        # Glass Cyan 主色
@export var highlight_color: Color = Color("#B7E7DD")     # Pale Resonance 高光
@export var core_color: Color = Color("#F2B66E")          # Amber Voice 中心暖点
@export var reflect_color: Color = Color("#E86D5A")       # Coral Pulse 反弹闪光
@export var rim_color: Color = Color("#65506A")           # Muted Violet 阴影内圈

var _lifetime: float = 0.0
var _max_lifetime: float = 0.85
var _active: bool = false
var _radius: float = 0.0
var _max_radius: float = 30.0
var _wave_offset: float = 0.0
var _bounces: Array = []     # Array of { pos: Vector2, age: float, life: float }

const REFLECT_BURST_DURATION := 0.25
const SHIELD_POP_IN := 0.10          # 球体从 0 扩张到 max_radius
const SHIELD_HOLD := 0.55            # 球体呼吸 / 棱镜旋转
const SHIELD_POP_OUT := 0.20         # 球体收缩 / 透明度衰减

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	if not _active:
		return

	_lifetime += delta
	_wave_offset += delta * 6.0

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
	else:
		queue_redraw()

func trigger(origin: Vector2, max_radius: float) -> void:
	global_position = origin
	_max_radius = max_radius
	_lifetime = 0.0
	_radius = 0.0
	_wave_offset = 0.0
	_bounces.clear()
	_active = true
	queue_redraw()

func add_bounce_flash(pos: Vector2) -> void:
	# Called by player when a projectile reflects off the shield.
	# Stores the world-space bounce position and renders it for 0.25s.
	# The flash is drawn relative to the VFX node, so convert world → local.
	var local_pos := to_local(pos)
	_bounces.append({
		"pos": local_pos,
		"age": 0.0,
		"life": REFLECT_BURST_DURATION
	})

func _draw() -> void:
	if not _active:
		return

	var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)
	var pop_in_t := clampf(_lifetime / SHIELD_POP_IN, 0.0, 1.0)
	var hold_t := clampf((_lifetime - SHIELD_POP_IN) / SHIELD_HOLD, 0.0, 1.0)
	var pop_out_t := clampf((_lifetime - SHIELD_POP_IN - SHIELD_HOLD) / SHIELD_POP_OUT, 0.0, 1.0)

	# === Shield sphere: scale from 0 → 1.0 during pop-in, breathe in hold, fade out in pop-out
	var sphere_scale := 1.0
	var sphere_alpha := 1.0
	if _lifetime < SHIELD_POP_IN:
		# Pop-in: back-ease-out for a satisfying "punch"
		var p := 1.0 + 2.7 * pow(pop_in_t - 1.0, 3.0) + 1.7 * pow(pop_in_t - 1.0, 2.0)
		sphere_scale = clampf(p, 0.0, 1.15)
		sphere_alpha = pop_in_t
	elif _lifetime < SHIELD_POP_IN + SHIELD_HOLD:
		# Hold: subtle breathing (4% radius oscillation)
		sphere_scale = 1.0 + 0.04 * sin(_wave_offset * 4.0)
		sphere_alpha = 1.0
	else:
		# Pop-out: scale back to 1.1, alpha fade
		sphere_scale = 1.0 + 0.10 * pop_out_t
		sphere_alpha = 1.0 - pop_out_t

	_radius = _max_radius * sphere_scale

	# === Layer 1: Muted Violet inner shadow ring (depth)
	var rim_col := rim_color
	rim_col.a = sphere_alpha * 0.35
	draw_circle(Vector2.ZERO, _radius * 0.95, rim_col)

	# === Layer 2: Glass Cyan main shield body (semi-transparent disc)
	var body_col := shield_color
	body_col.a = sphere_alpha * 0.22
	draw_circle(Vector2.ZERO, _radius, body_col)

	# === Layer 3: Glass Cyan outer rim (1px ring, 2px wide for readability)
	var rim_outer := shield_color
	rim_outer.a = sphere_alpha * 0.85
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 48, rim_outer, 2.0, true)

	# === Layer 4: Pale Resonance inner highlight (top-left crescent, "glass" feel)
	var hl_col := highlight_color
	hl_col.a = sphere_alpha * 0.5
	var hl_segments := 16
	for i in range(hl_segments):
		var a1 := (float(i) / hl_segments) * PI - PI * 0.5
		var a2 := (float(i + 1) / hl_segments) * PI - PI * 0.5
		var r1 := _radius * 0.85
		var r2 := _radius * 0.95
		var p1 := Vector2(cos(a1), sin(a1)) * r1
		var p2 := Vector2(cos(a2), sin(a2)) * r2
		draw_line(p1, p2, hl_col, 1.0)

	# === Layer 5: 8-direction prismatic rays (rotating slowly during hold)
	if _lifetime < SHIELD_POP_IN + SHIELD_HOLD:
		var ray_alpha := sphere_alpha * 0.55 * (1.0 - pop_out_t)
		var ray_col := highlight_color
		ray_col.a = ray_alpha
		var ray_count := 8
		var base_angle := _wave_offset * 0.5
		for i in range(ray_count):
			var angle := base_angle + (float(i) / ray_count) * TAU
			var ray_start := Vector2(cos(angle), sin(angle)) * (_radius * 0.6)
			var ray_end := Vector2(cos(angle), sin(angle)) * (_radius * 1.05)
			# Dashed rays: 4px on, 2px off
			var dir := (ray_end - ray_start)
			var length := dir.length()
			var seg_pos := 0.0
			while seg_pos < length:
				var s1 := ray_start + dir.normalized() * seg_pos
				var s2 := ray_start + dir.normalized() * minf(seg_pos + 4.0, length)
				draw_line(s1, s2, ray_col, 1.0)
				seg_pos += 6.0

	# === Layer 6: Amber Voice center warm dot
	var center_col := core_color
	center_col.a = sphere_alpha * 0.95
	draw_circle(Vector2.ZERO, 2.5, center_col)
	var center_glow := core_color
	center_glow.a = sphere_alpha * 0.35
	draw_circle(Vector2.ZERO, 5.0, center_glow)

	# === Layer 7: White inner sparkle (the "voice restored" feel)
	var sparkle_col := Color.WHITE
	sparkle_col.a = sphere_alpha * (0.6 + 0.4 * sin(_wave_offset * 8.0))
	draw_circle(Vector2(-1.0, -1.0), 1.0, sparkle_col)

	# === Layer 8: Bounce flashes (Coral Pulse V-burst at each reflect point)
	for b in _bounces:
		var age: float = b.get("age", 0.0)
		var life: float = b.get("life", REFLECT_BURST_DURATION)
		var b_t := clampf(age / life, 0.0, 1.0)
		var b_alpha := (1.0 - b_t) * 0.95
		var b_pos: Vector2 = b.get("pos", Vector2.ZERO)

		# Inner coral flash
		var b_col := reflect_color
		b_col.a = b_alpha
		draw_circle(b_pos, 3.0 + 4.0 * b_t, b_col)

		# V-shaped coral rays (4 directions for a "burst" feel)
		var ray_segments := 4
		for i in range(ray_segments):
			var a := (float(i) / ray_segments) * TAU + 0.4
			var r1 := 4.0 + b_t * 6.0
			var r2 := 8.0 + b_t * 10.0
			var rp1 := b_pos + Vector2(cos(a), sin(a)) * r1
			var rp2 := b_pos + Vector2(cos(a), sin(a)) * r2
			draw_line(rp1, rp2, b_col, 1.5)

		# Glass cyan ring at the bounce point (echo signature)
		var ring_col := shield_color
		ring_col.a = b_alpha * 0.7
		draw_arc(b_pos, 4.0 + b_t * 6.0, 0, TAU, 16, ring_col, 1.0, true)
