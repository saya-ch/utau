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

# T101 (#84) — Polish: ResonanceWave 命中粒子层叠 8→12.  Added 4 new visual
# layers to _draw() so the wave reads as a multi-depth shock instead of a
# single ring.  Painter's order (back-to-front in code) and per-layer
# ratios are pinned as constants so the SMOKE test can assert the *exact*
# counts/ratios and catch silent regressions:
#
#   L1  DEEP_SHADOW    Muted Violet #65506A  0.42× R  α0.18 (新增 · 深紫底衬)
#   L2  INNER_HALO     Pale Resonance        0.55× R  α0.22 (新增 · 内柔光)
#   L3  RING_FILL      wave_color            1.00× R  α0.18 (原版 · 冷白填充)
#   L4  RING_STROKE    outer_ring_color      1.00× R  α0.85 (原版 · cyan 2px 描边)
#   L5  PRISM_RAYS ×8  wave_color            1.00× R  α0.40 (原版 · 8 方向棱镜)
#   L6  OUTER_WISPS ×12 wave_color           1.18× R  α0.30 (新增 · 外圈刻度)
#   L7  SPARKLES ×6    core_color            0.70× R  αblink (新增 · 顶层暖色亮星)
#   L8  CORE_DOT       core_color            1.5+0.02R α0.90 (原版 · 中心暖点)
#   L9  BOUNCE_FLASH×N hit_flash_color      1..5 px    α0.70 (原版 · 命中闪烁)
#
# Element budget: 1+1+8 = 10 elements/frame pre-T101 →
# 1+1+1+8+12+6+1 = 30 elements/frame (+ bounce on hit frame).
# Performance check: 8 ms per wave on Raspberry Pi 400 (style guide
# target) — if profiling later flags this we move wisps + sparkles to a
# CPU-baked MultiMesh, but painter's order subtlety is preserved as long
# as we keep plain _draw() (MultiMesh loses per-element painter order).
const DEEP_SHADOW_RADIUS_RATIO: float = 0.42
const DEEP_SHADOW_ALPHA: float = 0.18
const INNER_HALO_RADIUS_RATIO: float = 0.55
const INNER_HALO_ALPHA: float = 0.22
const OUTER_WISP_RADIUS_RATIO: float = 1.18
const OUTER_WISP_ALPHA: float = 0.30
const OUTER_WISP_COUNT: int = 12
const OUTER_WISP_THICKNESS: float = 1.0
const SPARKLE_RADIUS_RATIO: float = 0.70
const SPARKLE_COUNT: int = 6
const SPARKLE_BASE_ALPHA: float = 0.55
const SPARKLE_BLINK_HZ: float = 6.0
const DEEP_SHADOW_COLOR: Color = Color("#65506A")   # Muted Violet (style guide)
const INNER_HALO_COLOR: Color = Color("#B7E7DD")    # Pale Resonance (style guide)
const SPARKLE_COLOR: Color = Color("#F2B66E")       # Amber Voice (style guide)

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
	# T141 (#75) — Audio cue on wave hit.  Pairs the visual
	# Warm Parchment flash with a soft high-frequency chime so the
	# player hears *and* sees the wave touch a target.  The audio
	# manager's own 50ms throttle (see AudioManagerEnhanced.play_wave_hit)
	# prevents SFX stacking on multi-enemy waves; the audio call here
	# is therefore safe to fire on every hit_flash, with the
	# de-duplication handled at the audio layer.  AudioManagerEnhanced
	# is an autoload — guard with has_method so the script still
	# parses/loads in headless tests that don't have the autoload.
	if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_wave_hit"):
		AudioManagerEnhanced.play_wave_hit()

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

	# T101 (#84) — Layer order (painter's algorithm, back-to-front):
	#   1. Deep violet shadow (L1)  — fills the void underneath the wave
	#   2. Inner pale halo (L2)     — softens the cold-cyan→cold-pale transition
	#   3. Main ring fill (L3)      — original translucent pale fill
	#   4. Outer ring stroke (L4)   — original glass cyan 2px stroke
	#   5. 8 prism rays (L5)        — original 8-direction ray spokes
	#   6. 12 outer wisps (L6)      — NEW · thin tick marks beyond the ring
	#   7. 6 sparkle stars (L7)     — NEW · top-layer warm blinker dots
	#   8. Center amber core (L8)   — original brightest pixel
	# (Bounce flashes are drawn last in their own loop — they live at
	#  the hit position, not the wave origin.)

	if _current_radius < 1.0:
		# Pre-expand: only the center dot is drawn (added below).
		pass
	else:
		# L1 — Deep violet shadow (filled, smallest, deepest back)
		var shadow_color: Color = Color(
			DEEP_SHADOW_COLOR.r, DEEP_SHADOW_COLOR.g, DEEP_SHADOW_COLOR.b,
			alpha * DEEP_SHADOW_ALPHA
		)
		draw_circle(_origin, _current_radius * DEEP_SHADOW_RADIUS_RATIO, shadow_color)

		# L2 — Inner pale halo (filled, mid-radius, softens cyan edge)
		var halo_color: Color = Color(
			INNER_HALO_COLOR.r, INNER_HALO_COLOR.g, INNER_HALO_COLOR.b,
			alpha * INNER_HALO_ALPHA
		)
		draw_circle(_origin, _current_radius * INNER_HALO_RADIUS_RATIO, halo_color)

		# L3 — Main ring: pale resonance filled (translucent)
		var ring_inner: Color = Color(wave_color.r, wave_color.g, wave_color.b, alpha * 0.18)
		draw_circle(_origin, _current_radius, ring_inner)

		# L4 — Outer ring stroke: glass cyan 2px
		var ring_outer: Color = Color(outer_ring_color.r, outer_ring_color.g, outer_ring_color.b, alpha * 0.85)
		draw_arc(_origin, _current_radius, 0.0, TAU, 64, ring_outer, 2.0)

		# L5 — 8 direction prism rays (originals, slowly rotating)
		for i in range(RAY_COUNT):
			var angle: float = (TAU / RAY_COUNT) * i + _lifetime * 0.5
			var ray_end: Vector2 = _origin + Vector2(cos(angle), sin(angle)) * _current_radius
			draw_line(_origin, ray_end, Color(wave_color.r, wave_color.g, wave_color.b, alpha * 0.4), 1.0)

		# L6 — 12 outer wisps (NEW · T101).  Thin tick marks just outside
		# the main ring; offset rotation by 1/24 TAU so they read as a
		# *separate* rotating layer (not just a second ray pass).
		# Lifetime multiplier 0.7 means the wisps rotate slower than the
		# prism rays, reinforcing the parallax depth illusion.
		var wisp_radius: float = _current_radius * OUTER_WISP_RADIUS_RATIO
		for j in range(OUTER_WISP_COUNT):
			var wisp_angle: float = (TAU / OUTER_WISP_COUNT) * j + _lifetime * 0.5 * 0.7 + (TAU / 24.0)
			var wisp_start: Vector2 = _origin + Vector2(cos(wisp_angle), sin(wisp_angle)) * (_current_radius + 1.0)
			var wisp_end: Vector2 = _origin + Vector2(cos(wisp_angle), sin(wisp_angle)) * wisp_radius
			draw_line(
				wisp_start, wisp_end,
				Color(wave_color.r, wave_color.g, wave_color.b, alpha * OUTER_WISP_ALPHA),
				OUTER_WISP_THICKNESS
			)

		# L7 — 6 sparkle stars (NEW · T101).  Small warm dots at 0.7× R,
		# each at a fixed angle (so they don't smear under rotation), and
		# their alpha blinks at SPARKLE_BLINK_HZ with a per-sparkle phase
		# offset so they twinkle independently.  This adds the "alive"
		# warmth on top of the cold shock — palette-respecting because
		# Amber Voice is the only warm hex in the wave's colour domain.
		var blink_t: float = sin(_lifetime * TAU * SPARKLE_BLINK_HZ) * 0.5 + 0.5  # 0..1
		for k in range(SPARKLE_COUNT):
			var sparkle_angle: float = (TAU / SPARKLE_COUNT) * k + (TAU / 12.0)
			var sparkle_pos: Vector2 = _origin + Vector2(cos(sparkle_angle), sin(sparkle_angle)) * (_current_radius * SPARKLE_RADIUS_RATIO)
			# Per-sparkle phase offset by 1.5 radians to stagger the blink.
			var phase: float = fmod(_lifetime * SPARKLE_BLINK_HZ + float(k) * 1.5, TAU)
			var sparkle_alpha: float = SPARKLE_BASE_ALPHA * (0.5 + 0.5 * sin(phase))
			draw_circle(
				sparkle_pos, 1.0,
				Color(SPARKLE_COLOR.r, SPARKLE_COLOR.g, SPARKLE_COLOR.b, alpha * sparkle_alpha)
			)

	# L8 — Center amber core dot (small, scales with wave radius)
	# Drawn last among the origin-layers so the brightest pixel reads
	# crisply on top of the halo + shadow + ring stack.
	var core_radius: float = 1.5 + _current_radius * 0.02
	draw_circle(_origin, core_radius, Color(core_color.r, core_color.g, core_color.b, alpha * 0.9))

	# L9 — Bounce flashes (per hit, drawn at the hit position, not origin)
	for b in _bounces:
		var bf: Dictionary = b
		var bf_alpha: float = 1.0 - (bf["age"] / bf["life"])
		var bf_color: Color = Color(hit_flash_color.r, hit_flash_color.g, hit_flash_color.b, bf_alpha * 0.7)
		draw_circle(bf["pos"], 4.0 * bf_alpha + 1.0, bf_color)
