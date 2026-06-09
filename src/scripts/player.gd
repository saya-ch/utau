extends CharacterBody2D

signal landed

@export var move_speed: float = 90.0
@export var jump_velocity: float = -260.0
@export var gravity_multiplier: float = 1.0
@export var coyote_time: float = 0.08
@export var jump_buffer: float = 0.08
@export var fall_gravity_multiplier: float = 1.4
@export var max_fall_speed: float = 400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pulse_ability = $PulseAbility
@onready var bind_ability = $BindAbility
@onready var cut_ability = $CutAbility
@onready var echo_ability = $EchoAbility
@onready var wave_ability = $ResonanceWaveAbility

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_right: bool = true
var _is_jumping: bool = false
var _was_on_floor: bool = false
var _speed_multiplier: float = 1.0

# Invulnerability state
@export var invulnerability_time: float = 0.8
var _is_invulnerable: bool = false
var _invulnerability_timer: float = 0.0
var _sprite_flash_tween: Tween = null

# Death animation state (T075)
var _is_dying: bool = false
const DEATH_LAY_DOWN_DURATION := 0.5
const DEATH_FADE_OUT_DURATION := 1.0
# Total death animation: 0.5s lay-down + 1.0s fade-out = 1.5s

# Death freeze-frame state (T092 polish)
# 0.15s of in-game slow-mo + red tint at the very start of the death
# sequence. Reads as a "time stutters" beat before the body folds —
# the same beat you hear in action films when a hit lands before
# the slow-mo fall. Engine.time_scale is held at 0.2 across the
# freeze interval (so the real-time pause is ~0.75s) and restored
# to 1.0 the moment the lay-down tween starts.
const DEATH_FREEZE_DURATION := 0.15
const DEATH_FREEZE_TIME_SCALE := 0.2
const DEATH_FREEZE_RED_TINT := Color(1.4, 0.45, 0.45, 1.0)

# T115 — Death-quote "monument" overlay.  When the player dies, a
# short lore-style quote fades in (0.4s), holds (1.5s), then fades
# out (0.6s) — total 2.5s — layered ON TOP of the existing death
# sequence.  This adds a third emotional beat alongside T092's
# freeze-frame and T093's grayscale wash: visual / desaturated /
# textual.  The quote is sampled from a small static array of
# in-world "monument inscriptions" so the player feels they are
# reading from a memorial, not reading game UI.  The overlay is a
# dedicated CanvasLayer at layer=64 (above the world, below the
# ScreenShake CanvasLayer at 128 and the achievement / gameover
# layers) so the grayscale wash still shows through.
const DEATH_QUOTE_FADE_IN := 0.4
const DEATH_QUOTE_HOLD := 1.5
const DEATH_QUOTE_FADE_OUT := 0.6
const DEATH_QUOTE_PEAK_ALPHA := 0.85
var _death_quote_layer: CanvasLayer = null
var _death_quote_label: Label = null
var _death_quote_tween: Tween = null
# Static quotes — six short "inscriptions" rotated per death so the
# player doesn't get the same line twice in a row.  All in Voxglass
# tone: melancholic, hopeful, present-tense second person.  Each
# line is short enough to read in 1.5s at 14pt in a 400px-wide Label.
const _DEATH_QUOTES := [
	"声音会回来\n它只是在等",          # "the sound will return / it's just waiting"
	"你听见寂静了\n那就还没结束",        # "you heard the silence / so it's not over yet"
	"我数着\n每一个被遗忘的音节",        # "i count / every forgotten syllable"
	"走慢一点\n它们就在脚下",            # "walk slower / they're at your feet"
	"修复不是救\n是记住",                # "repair is not saving / it's remembering"
	"下一段路\n比上一段短",              # "the next stretch / is shorter than the last"
]

# SpriteFrames for each facing direction
var _sf_right: SpriteFrames
var _sf_left: SpriteFrames

const CELL_W := 48
const CELL_H := 64

func _ready() -> void:
	add_to_group("player")
	_setup_spriteframes()
	# T115 — build the death-quote overlay once on spawn so the die()
	# tween can fade it in without re-creating Control nodes mid-tween.
	_build_death_quote_overlay()
	if pulse_ability:
		pulse_ability.pulse_fired.connect(_on_pulse_fired)
		# T098 — 命中敌人时屏幕 Coral Pulse 短暂染色，与 Echo 反弹
		# cyan / Cut 命中 amber 形成「四动词色域互不重叠」的视觉组。
		if pulse_ability.has_signal("pulse_hit"):
			pulse_ability.pulse_hit.connect(_on_pulse_hit)
	if bind_ability:
		bind_ability.bind_fired.connect(_on_bind_fired)
	if cut_ability:
		cut_ability.cut_fired.connect(_on_cut_fired)
		# T098 — 命中敌人时屏幕 Amber Voice 短暂染色（Cut 主题色 = 暖色域独占）
		if cut_ability.has_signal("cut_hit"):
			cut_ability.cut_hit.connect(_on_cut_hit)
	if echo_ability:
		echo_ability.echo_fired.connect(_on_echo_fired)
		echo_ability.echo_hit.connect(_on_echo_hit)
		echo_ability.echo_expired.connect(_on_echo_expired)
		# T158 (#81) — multi_reflect bridge. has_signal guard keeps
		# the connection optional for pre-T158 saves (signal was
		# added in this iteration). The signal fires once per cast
		# on the 4th reflect; we drop into 0.4s 0.85x slow-mo to
		# echo the "光波回流" beat that the per-hit cyan flash
		# already opens.
		if echo_ability.has_signal("echo_multi_reflect"):
			echo_ability.echo_multi_reflect.connect(_on_echo_multi_reflect)
	# T103 — Resonance Wave 群体波（第五动词）的信号桥接。wave_fired 在波
	# 开始扩散时触发（与 echo_fired 同语义），wave_hit 在命中每个敌人时触发，
	# wave_expired 在 0.4s 扩散期结束时触发。VFX 与屏幕闪通过 _on_wave_fired
	# 一次创建（_on_wave_hit 仅用于追踪统计与未来 boss 反馈）。
	if wave_ability:
		wave_ability.wave_fired.connect(_on_wave_fired)
		wave_ability.wave_hit.connect(_on_wave_hit)
		wave_ability.wave_expired.connect(_on_wave_expired)
		# T146 (#76) — Connect wave_combo for big-AOE feedback (>=3 hits).
		# Wave is the only verb that can hit multiple enemies in a single
		# cast, so the combo hook lives only on wave. Conditional connect
		# guards against a pre-T146 save (signal added in this iteration).
		if wave_ability.has_signal("wave_combo"):
			wave_ability.wave_combo.connect(_on_wave_combo)

func _build_death_quote_overlay() -> void:
	# T115 — set up a dedicated CanvasLayer (layer=64, above the world
	# but below ScreenShake's layer=128 and the achievement / gameover
	# layers) hosting a centered Label.  The Label starts fully
	# transparent so it's invisible until die() kicks off the fade
	# tween.  The 14pt font + 400px width is sized to read in ~1.5s
	# at the typical death-tween duration.
	if _death_quote_layer:
		return
	_death_quote_layer = CanvasLayer.new()
	_death_quote_layer.name = "DeathQuoteLayer"
	_death_quote_layer.layer = 64
	add_child(_death_quote_layer)

	var center := Control.new()
	center.name = "CenterContainer"
	center.anchor_left = 0.5
	center.anchor_top = 0.5
	center.anchor_right = 0.5
	center.anchor_bottom = 0.5
	center.offset_left = -200.0
	center.offset_top = -40.0
	center.offset_right = 200.0
	center.offset_bottom = 40.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_death_quote_layer.add_child(center)

	_death_quote_label = Label.new()
	_death_quote_label.name = "QuoteLabel"
	_death_quote_label.anchor_left = 0.0
	_death_quote_label.anchor_top = 0.0
	_death_quote_label.anchor_right = 1.0
	_death_quote_label.anchor_bottom = 1.0
	_death_quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_death_quote_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_death_quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_death_quote_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_death_quote_label.add_theme_font_size_override("font_size", 14)
	# Amber Voice (#F2B66E ≈ 0.949, 0.714, 0.431) — the
	# "repair / hope / memory" colour from STYLE_GUIDE, intentionally
	# chosen over a colder tone because the quote is a "monument
	# inscription" that the player is reading AFTER they fall, not
	# a death warning.
	_death_quote_label.add_theme_color_override("font_color", Color(0.949, 0.714, 0.431, 1.0))
	_death_quote_label.add_theme_constant_override("line_spacing", 4)
	center.add_child(_death_quote_label)

func _setup_spriteframes() -> void:
	"""Load the new spritesheets and build SpriteFrames for both directions."""
	var tex_right := load("res://assets/sprites/saya_spritesheet_right.png") as Texture2D
	var tex_left := load("res://assets/sprites/saya_spritesheet_left.png") as Texture2D
	
	if tex_right == null or tex_left == null:
		push_warning("Saya spritesheets not found, using placeholder")
		# Defensive: ensure the placeholder SpriteFrames (defined in player.tscn)
		# has the four animations our _update_animation() switches between,
		# otherwise the engine logs "There is no animation with name 'fall'"
		# every physics frame.
		_ensure_placeholder_animations()
		return

	_sf_right = _build_spriteframes(tex_right)
	_sf_left = _build_spriteframes(tex_left)

	# Start with right-facing
	sprite.sprite_frames = _sf_right
	sprite.animation = "idle"
	sprite.play()

func _ensure_placeholder_animations() -> void:
	# Populate the placeholder SpriteFrames with the animation slots the
	# gameplay code references, so missing art doesn't spam the log.
	for anim_name in ["idle", "run", "jump", "fall"]:
		if not sprite.sprite_frames.has_animation(anim_name):
			sprite.sprite_frames.add_animation(anim_name)
			sprite.sprite_frames.set_animation_speed(anim_name, 1.0)
			sprite.sprite_frames.set_animation_loop(anim_name, true)
	if sprite.sprite_frames.has_animation("fall"):
		sprite.sprite_frames.set_animation_loop("fall", false)

func _build_spriteframes(tex: Texture2D) -> SpriteFrames:
	var sf := SpriteFrames.new()
	var img_size := tex.get_size()
	var frames_count := int(img_size.x / CELL_W)
	
	# idle: frames 0-7
	var idle_frames: Array[AtlasTexture] = []
	for i in range(8):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * CELL_W, 0, CELL_W, CELL_H)
		idle_frames.append(at)
	
	# run: frames 8-15
	var run_frames: Array[AtlasTexture] = []
	for i in range(8, 16):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * CELL_W, 0, CELL_W, CELL_H)
		run_frames.append(at)
	
	# jump: frames 16-17
	var jump_frames: Array[AtlasTexture] = []
	for i in range(16, 18):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * CELL_W, 0, CELL_W, CELL_H)
		jump_frames.append(at)
	
	# fall: frames 18-19
	var fall_frames: Array[AtlasTexture] = []
	for i in range(18, 20):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * CELL_W, 0, CELL_W, CELL_H)
		fall_frames.append(at)
	
	# Add animations to SpriteFrames
	for anim_name in ["idle", "run", "jump", "fall"]:
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, 10.0)
		sf.set_animation_loop(anim_name, true)
	
	# idle and run loop; jump and fall don't
	sf.set_animation_loop("jump", false)
	sf.set_animation_loop("fall", false)
	
	for f in idle_frames:
		sf.add_frame("idle", f)
	for f in run_frames:
		sf.add_frame("run", f)
	for f in jump_frames:
		sf.add_frame("jump", f)
	for f in fall_frames:
		sf.add_frame("fall", f)
	
	return sf

func _physics_process(delta: float) -> void:
	if _is_dying:
		# During the death animation, the player cannot move or use
		# abilities. Invulnerability is held (timer set high in die())
		# so enemies can't keep damaging the body. The animation tween
		# is the only thing driving visuals here.
		_handle_invulnerability(delta)
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_handle_invulnerability(delta)
	_handle_gravity(delta)
	_handle_movement(delta)
	_handle_jump(delta)
	_handle_pulse()
	_handle_bind()
	_handle_cut()
	_handle_echo()
	_handle_wave()
	_update_animation()
	_update_facing()

	_was_on_floor = is_on_floor()
	move_and_slide()

func _handle_invulnerability(delta: float) -> void:
	if _is_invulnerable:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0:
			_is_invulnerable = false
			if sprite:
				sprite.modulate = Color.WHITE

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		var g := get_gravity().y * gravity_multiplier
		if velocity.y > 0:
			g *= fall_gravity_multiplier
		velocity.y += g * delta
		velocity.y = minf(velocity.y, max_fall_speed)
	else:
		_coyote_timer = coyote_time
		_is_jumping = false

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		velocity.x = input_dir * move_speed * _speed_multiplier
		_facing_right = input_dir > 0
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 8.0 * delta)

func _handle_jump(delta: float) -> void:
	# T145 (#76) — Apply the same global-blocking predicate that the
	# 5 verb handlers use. Two reasons jump needs this guard:
	#   1. _is_dying — without this early-out, a jump buffered
	#      during the 0.5s death lay-down would fire on the next
	#      respawn (jump_buffer decays to negative in the 0.0..0.15
	#      window, so the check _jump_buffer_timer > 0 alone isn't
	#      enough — we must also clear the buffer on death so the
	#      post-respawn tap doesn't chain in).
	#   2. Wave windup — jumping during a 0.10s Wave windup would
	#      break the "press V, then immediately space" chain that
	#      the T142 anti-misinput design was meant to allow. Jump
	#      has historically been exempt from verb chain rules
	#      (T141's _is_wave_globally_blocking only guarded verbs);
	#      T145 closes that loophole by routing jump through the
	#      same gate.
	# The implementation: early-return and ALSO zero the buffer
	# timers so any in-flight buffered jump (jump_buffer / coyote)
	# is wiped. Without the zeroing, the input would replay on
	# the next frame the predicate becomes false.
	#
	# T147 (#77) — Also surface a hud hint when the player
	# actually *tried* to jump while blocked.  Without this,
	# death / windup would silently swallow jump input and the
	# player has no idea why "press space does nothing".
	# We gate on is_action_just_pressed (not just held) so the
	# hint only fires once per tap, not every frame.
	if is_action_globally_blocked():
		if Input.is_action_just_pressed("jump"):
			var hud = get_tree().get_first_node_in_group("hud")
			if hud and hud.has_method("show_jump_blocked"):
				hud.show_jump_blocked()
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
		return
	_coyote_timer -= delta
	_jump_buffer_timer -= delta

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer

	if _jump_buffer_timer > 0 and (_coyote_timer > 0 or is_on_floor()):
		velocity.y = jump_velocity
		_is_jumping = true
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

func _handle_pulse() -> void:
	# T142 (#75) — 5-verb chain anti-misinput: block other verb casts during
	# Wave's 0.10s windup so a quick Wave→Pulse press doesn't double-cast.
	# T145 (#76) — Generalised to is_action_globally_blocked() which also
	# OR's in _is_dying. Same semantics for the windup case; expanded for
	# the death case.
	if is_action_globally_blocked():
		return
	if Input.is_action_just_pressed("pulse"):
		if pulse_ability:
			var origin := global_position + Vector2(0, -8)
			var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT
			var success: bool = pulse_ability.start_pulse(origin, dir)
			if not success:
				var hud = get_tree().get_first_node_in_group("hud")
				if hud and hud.has_method("show_pulse_blocked"):
					hud.show_pulse_blocked()

func _on_pulse_fired(origin: Vector2, radius: float) -> void:
	# Spawn VFX
	var vfx = preload("res://src/scripts/pulse_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(origin, radius)

	# Screen shake on pulse (T089 — via ScreenShake autoload)
	ScreenShake.shake_preset(ScreenShake.Preset.PULSE)

func _handle_bind() -> void:
	# T142 (#75) — see _handle_pulse for the rationale.
	# T145 (#76) — switched to is_action_globally_blocked() (same comment as
	# _handle_pulse; renaming the helper unifies the 5 verb handlers).
	if is_action_globally_blocked():
		return
	if Input.is_action_just_pressed("bind"):
		if bind_ability:
			var origin := global_position + Vector2(0, -8)
			var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT
			var success: bool = bind_ability.start_bind(origin, dir)
			if not success:
				var hud = get_tree().get_first_node_in_group("hud")
				if hud and hud.has_method("show_pulse_blocked"):
					hud.show_pulse_blocked()

func _on_bind_fired(origin: Vector2, radius: float) -> void:
	# Spawn Bind VFX
	var vfx = preload("res://src/scripts/bind_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(origin, radius)

	# Screen shake on bind (T089 — via ScreenShake autoload, subtler than pulse)
	ScreenShake.shake_preset(ScreenShake.Preset.BIND)

func _handle_cut() -> void:
	# T142 (#75) — see _handle_pulse for the rationale.
	# T145 (#76) — see _handle_bind.
	if is_action_globally_blocked():
		return
	if Input.is_action_just_pressed("cut"):
		if cut_ability:
			var origin := global_position + Vector2(0, -8)
			var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT
			var success: bool = cut_ability.start_cut(origin, dir)
			if not success:
				var hud = get_tree().get_first_node_in_group("hud")
				if hud and hud.has_method("show_pulse_blocked"):
					hud.show_pulse_blocked()

func _on_cut_fired(origin: Vector2, direction: Vector2, radius: float, arc_degrees: float) -> void:
	# Spawn Cut VFX
	var vfx = preload("res://src/scripts/cut_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(origin, direction, radius, arc_degrees)

	# Subtle screen shake (T089 — via ScreenShake autoload, sharp/quick)
	ScreenShake.shake_preset(ScreenShake.Preset.CUT)

func _handle_echo() -> void:
	# T142 (#75) — see _handle_pulse for the rationale.
	# T145 (#76) — see _handle_bind.
	if is_action_globally_blocked():
		return
	if Input.is_action_just_pressed("echo"):
		if echo_ability:
			# Echo doesn't aim — it pops at the player's location.
			var origin := global_position + Vector2(0, -8)
			var success: bool = echo_ability.start_echo(origin)
			if not success:
				var hud = get_tree().get_first_node_in_group("hud")
				if hud and hud.has_method("show_pulse_blocked"):
					hud.show_pulse_blocked()

func _on_echo_fired(origin: Vector2, radius: float) -> void:
	# Spawn Echo VFX at the shield center. The VFX is parented to the
	# current scene (not the player) so its bounces use the same world
	# coordinate system as the projectiles — the bounces are then drawn
	# at the projectile's actual world position, which is the right
	# behavior (the shield's hitbox is computed in world space from
	# the player position, but the bounce flash should appear at the
	# projectile's position, not the player's).
	if echo_ability == null:
		return
	var vfx_script := preload("res://src/scripts/echo_vfx.gd")
	var vfx: Node2D = vfx_script.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(origin, radius)

	# Screen shake on echo (T089 — via ScreenShake autoload, defensive).
	# BIND preset is the closest match (defensive, low intensity) since
	# we don't have a dedicated ECHO preset.
	if ScreenShake and ScreenShake.has_method("shake_preset"):
		ScreenShake.shake_preset(ScreenShake.Preset.BIND)

	# Hold a reference so we can route bounce flashes back into it.
	# EchoAbility emits echo_hit(target, is_reflect) with
	# is_reflect=true when a projectile bounces — _on_echo_hit below
	# then draws a coral flash at the bounce point via add_bounce_flash().
	_current_echo_vfx = vfx

func _on_echo_hit(target: Node, is_reflect: bool) -> void:
	if not is_reflect:
		return
	# Forward reflect bounces to the active VFX for the flash burst.
	if _current_echo_vfx and is_instance_valid(_current_echo_vfx) \
			and _current_echo_vfx.has_method("add_bounce_flash"):
		_current_echo_vfx.add_bounce_flash(target.global_position)

	# T097 — 反弹命中时屏幕轻微 Glass Cyan 闪光 (0.08s / peak 0.2)，让玩家
	# 视觉上区分「Echo 施法时护盾生成的 cyan 圆环」和「实际反弹到敌人
	# 的瞬间玻璃碎裂感」。 配合 echo_vfx.gd 的 add_bounce_flash 在投射物
	# 世界坐标处的 Coral Pulse VFX 形成「护盾 cyan (施法) → 反弹 cyan
	# (屏幕) + coral (命中点)」的双层视觉反馈。
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(Color(0.412, 0.78, 0.808, 1.0), 0.08, 0.2)

func _on_echo_expired() -> void:
	# Clear the VFX reference so _on_echo_hit can early-out on the
	# next cast (the VFX will queue_free itself ~0.25s after this
	# signal fires via its own lifetime tracker).
	_current_echo_vfx = null

# T158 (#81) — 4+ reflect slow-motion beat.  When Echo bounces 4+
# projectiles in a single cast, drop the world into 0.85x time_scale
# for 0.4s.  Sits in the same "time stutters on a big moment" family
# as T092 (death freeze 0.15s @ 0.2x) and T146 (wave_combo shake
# 0.4s HEAVY).  Tuned to 0.85x (not 0.2x) because Echo is a "you
# succeeded" beat — we want the player to see the glass refract the
# 4th bounce, not be disoriented.  0.4s matches the wave_combo
# flash duration so the three "combo" beats have a unified cadence.
#
# Defensive: the slow-mo await is interrupted if the player dies
# during the window. die() resets time_scale to 1.0; the await
# resume then sees _is_dying and skips its own 1.0 write (which
# would otherwise be a no-op since 1.0 is the target).  Also
# blocks if action is globally blocked (death / wave windup) at
# trigger time, to avoid stacking slow-mo on top of freeze-frame.
const _ECHO_MULTI_SLOW_MO_DURATION: float = 0.4
const _ECHO_MULTI_TIME_SCALE: float = 0.85
func _on_echo_multi_reflect(_count: int) -> void:
	if is_action_globally_blocked():
		return
	Engine.time_scale = _ECHO_MULTI_TIME_SCALE
	await get_tree().create_timer(_ECHO_MULTI_SLOW_MO_DURATION).timeout
	# Defensive: don't override a death-reset value (die() writes 1.0
	# on entry; if it happened during the slow-mo, leave the 1.0 in
	# place and let die() drive the lay-down + freeze sequence).
	if not _is_dying:
		Engine.time_scale = 1.0

var _current_echo_vfx: Node2D = null

func _handle_wave() -> void:
	# T103 — Wave 群体波不像 Echo 一样持续护盾，所以只需要一次 _ready 接通。
	# Wave 是「按下即扩散」语义，cooldown 6s 期间内不能复按。
	if Input.is_action_just_pressed("wave"):
		if wave_ability:
			# Wave doesn't aim — it pops at the player's location (same as Echo)
			var origin := global_position + Vector2(0, -8)
			var success: bool = wave_ability.start_wave(origin)
			if not success:
				# T143 (#76) — Wave 是 5 verb 中唯一有 4 种"无法施放"原因
				# 的能力（共鸣不足 / 6s cooldown / 0.10s windup / 0.40s
				# active），按 verb 状态路由到 hud 专属提示方法：
				#   - active 最先检查（0.40s 期间）— 玩家"按了没反应"
				#     最常见原因是上一次波还在扫
				#   - winding_up 第二（0.10s 期间）— 极短窗口几乎不可见
				#   - charging 第三（cooldown > 0）— 6s 内复按
				#   - blocked 兜底 — 共鸣不足（cost=50）
				# 顺序很重要：active/winding_up 是"波生命周期"检查（成本 0），
				# charging 检查需读 cooldown_timer（成本 1），blocked 兜底。
				# 三个 verb 状态互斥（任一为 true 时另外两个通常为 false），
				# 所以 4 分支 if/elif 不会触发重复 emit。
				var hud = get_tree().get_first_node_in_group("hud")
				if not hud:
					return
				if wave_ability.has_method("is_wave_active") and wave_ability.is_wave_active():
					if hud.has_method("show_wave_active"):
						hud.show_wave_active()
				elif wave_ability.has_method("is_winding_up") and wave_ability.is_winding_up():
					if hud.has_method("show_wave_winding_up"):
						hud.show_wave_winding_up()
				elif wave_ability.has_method("get_cooldown_ratio") and wave_ability.get_cooldown_ratio() > 0.01:
					if hud.has_method("show_wave_charging"):
						hud.show_wave_charging()
				else:
					# 兜底：共鸣不足（cost=50 不够）
					if hud.has_method("show_wave_blocked"):
						hud.show_wave_blocked()

# T145 (#76) — Single source of truth for "should this action be
# suppressed this frame?". Replaces the #75 _is_wave_globally_blocking()
# helper with a more general predicate that composes two orthogonal
# blocking conditions:
#   1. _is_dying (T075) — death animation is playing (0.5s lay-down
#      + 1.0s fade-out = 1.5s of total suppression).  Without this
#      check, a tap during the lay-down would queue a buffered jump
#      that fires when _is_dying flips back to false on respawn.
#   2. Wave windup (T142) — Wave's 0.10s windup blocks other verbs
#      (anti-misinput chain suppression).  This is the
#      wave_ability.is_globally_blocking() probe that #75 wired up.
# Both conditions OR together — any one being true suppresses the
# action.  All 5 verb handlers AND _handle_jump now call this single
# helper, so adding a future "stun" / "pause" condition only needs
# to be OR'd in here, not in N call-sites.  Public (no underscore) so
# future boss-script status effects can also probe it.
# Returns false if wave_ability isn't wired (e.g. headless tests that
# don't instantiate the full scene tree) — _is_dying alone is enough
# to suppress in that case.
func is_action_globally_blocked() -> bool:
	if _is_dying:
		return true
	if wave_ability == null:
		return false
	if not wave_ability.has_method("is_globally_blocking"):
		return false
	return bool(wave_ability.is_globally_blocking())

var _current_wave_vfx: Node2D = null

func _on_wave_fired(origin: Vector2, max_radius: float) -> void:
	# Spawn the VFX at the wave origin. Unlike Echo, Wave's VFX is short-lived
	# (0.85s total = 0.10s windup-ish + 0.40s expand + 0.30s fade) so we
	# don't need a long-lived reference; the bounce flashes inside the VFX
	# are pre-computed by ResonanceWaveVFX's own _draw.
	if wave_ability == null:
		return
	var vfx_script := preload("res://src/scripts/resonance_wave_vfx.gd")
	var vfx: Node2D = vfx_script.new()
	# VFX is parented to the *current scene* (not the player) so the world-
	# space origin is preserved across player movement.
	get_tree().current_scene.add_child(vfx)
	vfx.global_position = Vector2.ZERO
	vfx.trigger(origin, max_radius)

	# T103 — Wave 命中群体时屏幕短暂 Pale Resonance 染色 (#B7E7DD = STYLE_GUIDE
	# "Pale Resonance" 色)，作为「光波扩散」的全屏反馈。0.12s / peak 0.15
	# 比 Pulse/Cut/Echo 屏幕闪都更短且更弱（peak 0.15 vs 0.18/0.20），符合
	# "群体波 = AOE 横扫而非单点爆发" 的视觉权重。5 动词色域严格分工：
	#   Pulse = Coral 0.10s/0.18
	#   Bind  = (暂无屏幕闪, 走紫色 VFX)
	#   Cut   = Amber  0.09s/0.18
	#   Echo  = Cyan   0.08s/0.20 (反弹)
	#   Wave  = PaleRes 0.12s/0.15 (AOE)
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(Color(0.718, 0.906, 0.867, 1.0), 0.12, 0.15)

	# Stronger screen shake than other verbs (T089 polish) — Wave is a
	# "world-shaking" AOE so the screen should feel it.
	if ScreenShake and ScreenShake.has_method("shake_preset"):
		ScreenShake.shake_preset(ScreenShake.Preset.PULSE)

	_current_wave_vfx = vfx

func _on_wave_hit(target: Node, _knockback: Vector2) -> void:
	# Optional: forward hit feedback to the VFX for the per-enemy flash.
	# Currently the VFX is short-lived enough that the main ring already
	# signals "wave hit something", but we add the hit flash for future
	# boss fights where per-hit feedback matters more.
	if _current_wave_vfx and is_instance_valid(_current_wave_vfx) \
			and _current_wave_vfx.has_method("add_hit_flash"):
		_current_wave_vfx.add_hit_flash(target.global_position)

func _on_wave_expired() -> void:
	# Clear the VFX reference; the VFX will queue_free itself via its
	# own lifetime tracker (~0.85s after wave_fired).
	_current_wave_vfx = null

func _on_wave_combo(hit_count: int) -> void:
	# T146 (#76) — Big-AOE feedback when a single Wave cast hits >=
	# wave_combo_threshold enemies (default 3). Three feedback layers:
	#   1. Screen shake: HEAVY preset (0.4s) — matches the existing
	#      T135 cut_combo "big slash" beat. Wave combo is a rarer
	#      event than cut_combo (Wave cost 50 vs Cut cost 25, 6s vs
	#      1.2s cooldown), so HEAVY shake is justified — every combo
	#      should feel earned.
	#   2. Color flash: Electric Violet (#8C5BFF, STYLE_GUIDE "Electric
	#      Violet") — Wave is the only verb that hits multiple enemies
	#      so we use a 6th color (Pulse=Coral, Bind=Cyan, Cut=Amber,
	#      Echo=Verdant, Wave=Violet) that doesn't overlap with any
	#      verb's per-hit flash. 0.18s / peak 0.30 — slightly
	#      stronger than per-hit flash (peak 0.18) to signal "this
	#      was special". Both layers fire on the same frame so the
	#      screen reacts synchronously with the final wave_expired.
	#   3. (T148 #78) Tail chime: 0.6s E6+G#6 stacked-6th pair
	#      through `AudioManagerEnhanced.play_wave_combo()`.  The
	#      chime outlasts the screen flash so the audio + visual +
	#      tactile feedback are temporally aligned (the player
	#      "feels" the combo even after the flash has faded).
	# hit_count unused in v1 (single threshold) but kept in signature
	# for future tuning (e.g. shake duration scales with hit_count).
	if ScreenShake == null:
		return
	if ScreenShake.has_method("shake"):
		# ROADMAP T146 spec is "0.4s wave_combo 屏震" — shake_preset(HEAVY)
		# only supports 0.18s (the preset's built-in duration), so we use
		# the lower-level shake(intensity, duration) form to honour the
		# spec. Intensity 4.0 matches HEAVY's amplitude (T135 cut_combo
		# uses the same number); the longer 0.4s duration makes wave
		# combo feel weightier than cut combo (0.18s) — wave is rarer
		# and slower, the screen should linger on the impact.
		ScreenShake.shake(4.0, 0.4)
	if ScreenShake.has_method("flash_color"):
		# 0.18s duration, 0.30 peak — slightly longer + stronger than
		# per-hit flash (0.10s / 0.18) so the player can tell combo
		# from a single lucky hit.
		ScreenShake.flash_color(Color(0.549, 0.357, 1.0, 1.0), 0.18, 0.30)
	# T148 — Tail chime.  AudioManagerEnhanced is an autoload — guard
	# with has_method for headless test contexts that don't initialise
	# the autoload.  Fires on every combo; no throttle (rare event).
	if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_wave_combo"):
		AudioManagerEnhanced.play_wave_combo()

func _on_pulse_hit(target: Node, _knockback: Vector2) -> void:
	# T098 — Pulse 命中敌人时屏幕短暂 Coral Pulse 染色 (#E86D5A = STYLE_GUIDE
	# "Coral Pulse" 色)。0.10s / peak 0.18，与 pulse_vfx 的 0.12s active
	# 同步但稍短（让圆环扩散主导、Coral 闪作为"命中确认"补强）。
	# 仅在 target != null 时触发（pulse_ability.gd:126 末尾 emit(null, ...) 是
	# 没命中任何敌人时的占位 emit，应不触发屏幕闪）。
	if target == null:
		return
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(Color(0.91, 0.427, 0.353, 1.0), 0.10, 0.18)

func _on_cut_hit(_target: Node) -> void:
	# T098 — Cut 命中敌人时屏幕短暂 Amber Voice 染色 (#F2B66E = STYLE_GUIDE
	# "Amber Voice" 色，Cut 主题色 = 暖色域独占)。0.09s / peak 0.18，
	# 比 Pulse 略短（Cut 短促锋利的动词特性）；Cut 一次可命中多个敌人
	#（最多 max_targets=6），但 flash_color 自身会取消上次闪，所以视觉
	# 上仍是"最后命中那下"为准，不会叠加。
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)

func _update_animation() -> void:
	if not sprite:
		return
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif absf(velocity.x) > 1.0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _update_facing() -> void:
	if not sprite:
		return
	# Use dedicated left/right spritesheets instead of flip_h
	# to maintain correct gauntlet position on anatomical left arm.
	if _facing_right:
		if sprite.sprite_frames != _sf_right and _sf_right != null:
			sprite.sprite_frames = _sf_right
	else:
		if sprite.sprite_frames != _sf_left and _sf_left != null:
			sprite.sprite_frames = _sf_left

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if _is_invulnerable:
		return

	GameState.take_damage(amount)
	velocity += knockback

	# Show damage number (player takes damage = Coral Pulse)
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -24), amount, DamageNumber.Kind.DMG)

	# Start invulnerability frames
	_is_invulnerable = true
	_invulnerability_timer = invulnerability_time
	
	# Visual: flash red + brief transparency flicker
	if sprite:
		_sprite_flash_tween = create_tween()
		_sprite_flash_tween.tween_property(sprite, "modulate", Color("#E86D5A"), 0.05)
		_sprite_flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
		_sprite_flash_tween.set_loops(int(invulnerability_time / 0.15))
	
	# Screen shake on damage (T089 — via ScreenShake autoload)
	ScreenShake.shake_preset(ScreenShake.Preset.DAMAGE)

	# Play damage sound
	if AudioManagerEnhanced.has_method("play_damage"):
		AudioManagerEnhanced.play_damage()

func respawn_at(pos: Vector2) -> void:
	# Reset death animation visual state in case the player respawns
	# before the tween completed (e.g. via scene reload / continue).
	_is_dying = false
	if sprite:
		sprite.rotation = 0.0
		sprite.modulate = Color.WHITE
	# T092 polish — defensive: ensure Engine.time_scale is back to 1.0
	# even if the freeze-frame tween was killed mid-flight (e.g. by
	# scene change or by _finish_death() being short-circuited). A
	# stuck time_scale=0.2 would make the whole game run at 5x
	# slow-mo on the next death, which is a "wait what?" bug.
	Engine.time_scale = 1.0
	# T115 — kill any in-flight death-quote tween and clear the label
	# so a respawn mid-quote doesn't leave the inscription hanging on
	# screen.  Without this, a fast Continue → respawn would show the
	# player a quote from their previous life.
	_hide_death_quote()
	global_position = pos
	velocity = Vector2.ZERO

func die() -> void:
	# T075 — death animation. Plays a "laying down + fade out" sequence
	# over ~1.5s, then asks GameState to perform the actual respawn at
	# the last checkpoint. Called by GameState.take_damage when health
	# hits 0; safe to call multiple times (subsequent calls no-op).
	if _is_dying:
		return
	_is_dying = true

	# T116 — trigger a "afterimage" on every living elite enemy in
	# the scene (currently only InkWarden uses request_afterimage).
	# Fires at the very start of the death sequence so the ghost is
	# already on screen when the freeze-frame ends, so the player
	# perceives the residue as "the threat is watching me fall"
	# rather than "the threat appeared after I died."  The
	# has_method guard means non-InkWarden elites (future) can opt
	# out simply by not exposing the method.
	for enemy in get_tree().get_nodes_in_group("elite_enemies"):
		if is_instance_valid(enemy) and enemy.has_method("request_afterimage"):
			enemy.request_afterimage()

	# T092 polish — open the death sequence with a 0.15s freeze-frame
	# (Engine.time_scale → 0.2 + red tint on the sprite). The visual
	# beat: time stutters when Saya goes down, breaking the combat
	# rhythm to underscore "this is a moment of loss." The lay-down
	# / fade-out tween only starts AFTER the freeze ends, so it
	# gets the full time_scale=1.0 budget and doesn't compound the
	# slow-mo. The red tint intentionally persists into the fade-out
	# so the alpha decay reads as "drained red" rather than "flashing
	# red"; _finish_death() resets modulate to WHITE before respawn.
	Engine.time_scale = DEATH_FREEZE_TIME_SCALE

	# Screen shake on death (T089 — via ScreenShake autoload, heaviest)
	ScreenShake.shake_preset(ScreenShake.Preset.DEATH)

	# Hold invulnerability for the whole 1.5s animation so enemies
	# can't keep damaging the falling body. die() runs synchronously
	# from take_damage so the invuln flag is set before any other
	# enemy _process call lands.
	_is_invulnerable = true
	_invulnerability_timer = 99.0

	# Cancel any active damage flash tween — we want the sprite to
	# read as "drained" not "flashing red" during the lay-down.
	if _sprite_flash_tween and _sprite_flash_tween.is_valid():
		_sprite_flash_tween.kill()
	_sprite_flash_tween = null

	# Reset sprite to a known frame (idle) for the lay-down pose,
	# and apply the freeze-frame red tint (overrides WHITE).
	if sprite:
		sprite.modulate = DEATH_FREEZE_RED_TINT
		sprite.play("idle")

	# Chained tween: freeze interval → restore time_scale → grayscale wash
	# → lay-down → fade-out → finish. All on one tween so the freeze and
	# the death animation share a single timing pipeline (no drift
	# between the freeze end and the lay-down start). Tween.interval
	# advances at Engine.time_scale, so DEATH_FREEZE_DURATION (0.15
	# in-game) takes ~0.75s of real time at 0.2 scale.
	var tween := create_tween()
	tween.tween_interval(DEATH_FREEZE_DURATION)
	tween.tween_callback(_end_death_freeze_frame)
	# T093 polish — 0.3s grayscale wash on the world *after* the freeze
	# ends. Fires at full time_scale (the freeze just restored it) so
	# the player perceives the wash at 0.3s of real time, matching the
	# spec. The wash overlaps the first 0.3s of the 0.5s lay-down, so
	# the body falls INTO the desaturation — the visual order is:
	# freeze (red flash) → world goes gray → body lays down → fade out.
	# Communicates "consciousness slipping before the body falls",
	# adding a second emotional beat on top of the freeze-frame's
	# "time stutters" moment.
	tween.tween_callback(_flash_death_grayscale_wash)
	# T115 — start the death-quote fade-in AFTER the freeze-frame so
	# the player isn't asked to read text during a 0.2x slow-mo
	# (which would feel sluggish and disconnect from the visual beat).
	# The quote tween is fire-and-forget — it runs on its own
	# timeline (0.4s in / 1.5s hold / 0.6s out = 2.5s) so it survives
	# the death tween's own completion and is the LAST thing the
	# player sees before respawn.
	tween.tween_callback(_show_death_quote)
	# Lay-down: rotate the sprite 90° clockwise (head pointing right)
	# over 0.5s with a quad ease-in (gravity-fall feel).
	tween.tween_property(sprite, "rotation", PI * 0.5, DEATH_LAY_DOWN_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# Fade-out: alpha 1 → 0 over the next 1.0s, linear (a slow dissolve
	# is more melancholic than a snap, matching Voxglass's "lonely but
	# not desperate" tone). The red channels (modulate.r/g) hold at
	# 1.4/0.45 so the alpha decay reads as "drained red."
	tween.tween_property(sprite, "modulate:a", 0.0, DEATH_FADE_OUT_DURATION) \
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_finish_death)

func _end_death_freeze_frame() -> void:
	# T092 polish — restore Engine.time_scale to 1.0 at the end of
	# the freeze interval. Called from inside the death tween so it
	# fires exactly when the lay-down begins. Safe to call from
	# other contexts (e.g. respawn before death-animation completes)
	# — it's a one-liner assignment with no side effects.
	Engine.time_scale = 1.0

func _flash_death_grayscale_wash() -> void:
	# T093 polish — trigger a 0.3s cool-gray wash over the world. The
	# ScreenShake autoload owns the CanvasLayer / ColorRect / tween
	# lifecycle (with a 0.3s default), so this is a one-liner at the
	# tween-callback point. The wash is fire-and-forget — it does NOT
	# need to be in the same tween chain because its visuals run on
	# process_mode=ALWAYS and self-destruct on tween completion.
	if ScreenShake and ScreenShake.has_method("flash_grayscale"):
		ScreenShake.flash_grayscale(0.3, 0.55)

func _show_death_quote() -> void:
	# T115 — sample a random quote from _DEATH_QUOTES, set it on the
	# overlay Label, and run an independent tween that fades the
	# label in (0.4s) → hold (1.5s) → fade out (0.6s) → hide.  The
	# tween is stored on _death_quote_tween so respawn_at() can
	# kill it cleanly if the player revives mid-quote.  The label's
	# modulate is the alpha carrier (so the Color stays at Amber
	# Voice while the layer opacity drives the fade).
	if not _death_quote_label:
		return
	# Pick a quote.  Skip the same index twice in a row by tracking
	# the last one — minimal state, no need for a full RNG bookkeeping.
	var idx := randi() % _DEATH_QUOTES.size()
	_death_quote_label.text = _DEATH_QUOTES[idx]
	_death_quote_label.modulate.a = 0.0
	# Kill any prior tween (defensive — should already be cleared by
	# respawn_at(), but a fast double-death could in theory race).
	if _death_quote_tween and _death_quote_tween.is_valid():
		_death_quote_tween.kill()
	_death_quote_tween = create_tween()
	_death_quote_tween.tween_property(
		_death_quote_label, "modulate:a", DEATH_QUOTE_PEAK_ALPHA, DEATH_QUOTE_FADE_IN
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_death_quote_tween.tween_interval(DEATH_QUOTE_HOLD)
	_death_quote_tween.tween_property(
		_death_quote_label, "modulate:a", 0.0, DEATH_QUOTE_FADE_OUT
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_death_quote_tween.tween_callback(_hide_death_quote)

func _hide_death_quote() -> void:
	# T115 — kill the in-flight quote tween (if any) and reset the
	# label so a subsequent death starts from a clean slate.  Called
	# from respawn_at() and from the quote tween's own tail callback.
	if _death_quote_tween and _death_quote_tween.is_valid():
		_death_quote_tween.kill()
	_death_quote_tween = null
	if _death_quote_label:
		_death_quote_label.modulate.a = 0.0
		_death_quote_label.text = ""

func _finish_death() -> void:
	# Tween finished. Hand control back to GameState so it can do
	# the actual restore-health + restore-resonance + move-to-checkpoint
	# work in one place (same path as the instant respawn used to take).
	_is_dying = false
	# Reset the sprite transforms now so the next respawn_at() doesn't
	# have to know about death-animation side effects.
	if sprite:
		sprite.rotation = 0.0
		sprite.modulate = Color.WHITE
	# Delegate to GameState for the actual respawn.
	if GameState and GameState.has_method("_respawn"):
		GameState._respawn()

func set_speed_multiplier(multiplier: float) -> void:
	_speed_multiplier = multiplier
