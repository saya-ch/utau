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
		# T170a (#88) — Bind 命中反馈：Muted Violet 屏幕染色 + LIGHT 屏抖
		# 与 Pulse Coral / Cut Amber / Echo Cyan 命中反馈形成 4 verb
		# 色域对称。Bind 命中频率较低 (1 cast → 多 enemy), shake
		# 走 LIGHT 1.0/0.08s 防止与多 enemy 同帧命中叠加 (LIGHT preset
		# 单 shake 不叠加 = 仅最后一次"吞掉"前序, 视觉上是清晰的
		# "凝固了一瞬"而不是乱震).
		if bind_ability.has_signal("bind_hit"):
			bind_ability.bind_hit.connect(_on_bind_hit)
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

	# D001 (#82) — Register with the PlayerActionGate autoload so the
	# gate's is_blocked() can probe our _is_dying flag + wave windup
	# in one place.  See player_action_gate.gd for the rationale (we
	# keep the local is_action_globally_blocked() as a thin delegate
	# so callers that already use it don't need to be rewritten).
	if Engine.has_singleton("PlayerActionGate") or _has_player_action_gate_autoload():
		PlayerActionGate.register_player(self)


func _exit_tree() -> void:
	# D001 (#82) — symmetric unregister.  See the registration comment
	# in _ready().  We only clear if WE are the registered player
	# (PlayerActionGate's unregister handles that internally).
	if Engine.has_singleton("PlayerActionGate") or _has_player_action_gate_autoload():
		PlayerActionGate.unregister_player(self)


func _has_player_action_gate_autoload() -> bool:
	# Defensive helper: PlayerActionGate is an autoload, but in some
	# test contexts (e.g. direct scene previews) the root may not
	# have all autoloads.  Check the SceneTree first so player.gd
	# still loads in those harnesses.
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("PlayerActionGate")

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
	#      same gate. D001 (#82) further refactored the gate into
	#      the PlayerActionGate autoload — see player_action_gate.gd
	#      for the single source of truth that all callers now use.
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
	# F005 (#85) — Single _pre_verb_block_check() guard shared by the
	# 4 directional verbs (pulse / bind / cut / echo).  Replaces the
	# duplicated `if is_action_globally_blocked(): return` lines.
	# F006 (#86) — Handler body now 1 line: delegate to _try_verb() which
	# runs the shared block-guard + just_pressed + origin/dir calc +
	# verb.start + blocked-HUD-feedback pattern.  See _try_verb() for
	# the centralised logic.
	_try_verb("pulse", _start_pulse_at)

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
	# F005 (#85) — same _pre_verb_block_check() guard as the other 3 verbs.
	# F006 (#86) — delegate to _try_verb() (1-line body, shared pattern).
	_try_verb("bind", _start_bind_at)

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
	# F005 (#85) — same _pre_verb_block_check() guard as the other 3 verbs.
	# F006 (#86) — delegate to _try_verb() (1-line body, shared pattern).
	_try_verb("cut", _start_cut_at)

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
	# F005 (#85) — same _pre_verb_block_check() guard as the other 3 verbs.
	# F006 (#86) — delegate to _try_verb() (1-line body, shared pattern).
	# Echo ignores the `dir` parameter — it always pops at the player's
	# location (it's a centered shield, not a directional projectile).
	_try_verb("echo", _start_echo_at)

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
	# T170b (#88) — Echo 命中非反弹反馈：之前 is_reflect=false 早退
	# 导致 echo_ability.gd:278 emit(echo_hit, false) 没有任何屏幕反馈。
	# 语义：非反弹 = 敌人物理接触护盾被 _apply_bind_to_enemy 短致盲 +
	# 0 伤 (echo 是"挡住来袭"而非"攻击"动词)。视觉上需要补一层
	# "我的护盾接住了它"反馈。Glass Cyan (#69C7CE) 是 Echo 主题色，
	# 0.06s / peak 0.12 比反弹路径 (T097 0.08s / peak 0.20) **更短更暗**：
	# 反弹是"成功回击"高反馈，非反弹是"温和挡下"低反馈，两者节奏区分
	# 让玩家从屏幕闪强度就能区分"我弹回去了" vs "我挡住了"。
	#
	# 数值设计: 反弹 0.20 peak (强烈) / 非反弹 0.12 peak (温和) =
	# 6:3 比例，让"反" > "挡"的视觉权重正确。
	if not is_reflect:
		if ScreenShake and ScreenShake.has_method("flash_color"):
			ScreenShake.flash_color(ScreenShake.VERB_HIT_ECHO_COLOR, 0.06, 0.12)
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
		ScreenShake.flash_color(ScreenShake.VERB_HIT_ECHO_COLOR, 0.08, 0.2)
	# T181 (#97 first half) — Echo reflect hit audio cue (1980Hz
	# glass tap).  Pairs with the echo_fired cue (T181 caller in
	# echo_ability.gd) to close the 2-beat "fire→hit" audio loop.
	# Fires ONLY on reflect path (not the non-reflect enemy-contact
	# path) so "I reflected a shot" reads distinct from "the shield
	# bumped an enemy".  Throttled internally by _VERB_HIT_THROTTLE
	# (50ms) so a 4-reflect multi_reflect chain doesn't stack 4 taps.
	if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_echo_hit"):
		AudioManagerEnhanced.play_echo_hit()

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
# suppressed this frame?".  Replaces the #75 _is_wave_globally_blocking()
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
# to be OR'd in here, not in N call-sites.
#
# D001 (#82) — Now a thin delegate to the PlayerActionGate autoload
# (see player_action_gate.gd).  The composite logic moved there so
# future boss / cutscene scripts can probe the same gate without
# reaching into player internals.  We keep this method (instead of
# rewriting every call site) for backwards compatibility — every
# caller in player.gd can be migrated gradually, and the hud.gd
# comment reference stays valid.
# Returns false if PlayerActionGate isn't loaded (e.g. test
# harness running player.gd without the full autoload set) — in
# that case we fall through to the legacy local composite so the
# game still suppresses actions correctly.
func is_action_globally_blocked() -> bool:
	if Engine.has_singleton("PlayerActionGate") or _has_player_action_gate_autoload():
		return bool(PlayerActionGate.is_blocked())
	# Fallback: local composite (matches pre-D001 behaviour exactly)
	if _is_dying:
		return true
	if wave_ability == null:
		return false
	if not wave_ability.has_method("is_globally_blocking"):
		return false
	return bool(wave_ability.is_globally_blocking())


# F005 (#85) — Private guard shared by the 4 directional verb handlers
# (_handle_pulse / _handle_bind / _handle_cut / _handle_echo).  Returns
# true if the player should *skip* its verb-cast attempt this frame.
#
# Wraps the public is_action_globally_blocked() (which other call sites
# like _handle_jump and _on_echo_multi_reflect still use directly) so
# we have a *single* chokepoint for "should I bail before pressing
# the verb?" logic.  If we later need to OR in a new condition (e.g.
# "dialogue open" or "shop UI focused"), it lands here once instead
# of being copy-pasted into 4 handlers.
#
# Naming: the leading underscore marks it private to this file; the
# suffix "_block_check" (returns bool, "true = blocked") matches the
# codebase's existing "check" convention (e.g. _has_*_autoload).
func _pre_verb_block_check() -> bool:
	return is_action_globally_blocked()

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
	#
	# T170c (#88) — Pulse 命中补 LIGHT 屏抖 (1.0/0.08s)。_on_pulse_fired
	# 已经在 cast 起始 emit shake_preset(PULSE 2.0/0.10s), 但 fire shake
	# 是"我在释放"语义, hit 应该有"我打到了"语义. 两 shake 间隔
	# 取决于 pulse 环扩散 + 敌人距离, 通常 0.05~0.15s, 不会重叠
	# (fire shake 0.10s 衰减完 = hit shake 0.08s 才开始, 视觉上
	# 是 "推→中"两步触觉)。LIGHT 而非 HEAVY 因为 Pulse 单体命中
	# 反馈已经很强 (环扩散 + 击退 + Coral 闪), 多一个 HEAVY 反而
	# 喧宾夺主. LIGHT 让 hit 触感"补"在 fire 之上, 玩家感到
	# "我的 Pulse 不仅推开了, 还把对方钉了一下"。
	if target == null:
		return
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(ScreenShake.VERB_HIT_PULSE_COLOR, 0.10, 0.18)
	if ScreenShake and ScreenShake.has_method("shake_preset"):
		ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)
	# T181 (#97 first half) — Pulse hit audio cue (220Hz thud). Pairs
	# with the pulse_fired cue (F004 #94 caller in pulse_ability.gd)
	# to close the 2-beat "fire→hit" audio loop. Throttled
	# internally by AudioManagerEnhanced._VERB_HIT_THROTTLE (50ms)
	# so a Pulse that hits 4 enemies in 0.05s doesn't stack 4 thuds.
	if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_pulse_hit"):
		AudioManagerEnhanced.play_pulse_hit()

func _on_cut_hit(_target: Node) -> void:
	# T098 — Cut 命中敌人时屏幕短暂 Amber Voice 染色 (#F2B66E = STYLE_GUIDE
	# "Amber Voice" 色，Cut 主题色 = 暖色域独占)。0.09s / peak 0.18，
	# 比 Pulse 略短（Cut 短促锋利的动词特性）；Cut 一次可命中多个敌人
	# （最多 max_targets=6），但 flash_color 自身会取消上次闪，所以视觉
	# 上仍是"最后命中那下"为准，不会叠加。
	#
	# T170d (#89) — Cut 命中补 LIGHT 屏抖 (1.0/0.08s)。与 Pulse 的 T170c
	# (#88) 走同一 pattern：_on_cut_fired 已在 cast emit shake_preset(CUT
	# 1.5/0.06s) ——"我在释放"语义；hit 应该有"我打到了"语义。两 shake
	# 间隔取决于 cut 弧扩散 + 敌人距离，通常 0.03~0.10s，不会重叠
	# (CUT 1.5/0.06s 衰减完 = LIGHT 0.08s 才开始，视觉上是"挥→中"两步
	# 触觉)。LIGHT 而非 HEAVY 因为 Cut 单体命中反馈已经很强 (弧扩散 +
	# 击退 + Amber 闪 + 声音 cue)，多一个 HEAVY 反而喧宾夺主。
	#
	# 多目标风险评估：Cut max_targets=6，但 _perform_arc_hit_check 在
	# 同一帧遍历并逐个 emit cut_hit，ScreenShake.shake_preset 内部用
	# tween 重新启动（"新 shake 覆盖旧 shake"语义，参考 T170c 的注释
	# "最后命中那下为准"），所以 6 个 hit 也只会看到 1 次 0.08s LIGHT
	# 抖动，与 Pulse 多目标场景下的行为完全一致。
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(ScreenShake.VERB_HIT_CUT_COLOR, 0.09, 0.18)
	if ScreenShake and ScreenShake.has_method("shake_preset"):
		ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)
	# T181 (#97 first half) — Cut hit audio cue (2000Hz shing).
	# Pairs with the cut_fired cue (T181 caller in cut_ability.gd)
	# to close the 2-beat "fire→hit" audio loop. The hit is a fast
	# 0.05s decay (no tail) so the slash reads "kinetic" not
	# "thud-y". Throttled internally by _VERB_HIT_THROTTLE.
	if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_cut_hit"):
		AudioManagerEnhanced.play_cut_hit()

func _on_bind_hit(target: Node) -> void:
	# T170a (#88) — Bind 命中反馈。bind_ability.gd:117/136 在
	# _perform_bind_hit_check 末尾 emit bind_hit(target); 命中时
	# _apply_bind_to_enemy 已经把 enemy 短暂暂停 + 减速。视觉上需要
	# 一层"我的 Bind 抓住它了"反馈——Muted Violet (#65506A) 是 Bind
	# 主题色, 与 Pulse Coral / Cut Amber / Echo Cyan 三 verb 命中
	# 反馈色域不重叠 (4 verb 各占 1/4 调色板, 形成"看到闪就知道是
	# 哪个 verb"的快速识别). 0.10s duration / 0.18 peak 与 Pulse
	# 命中 (T098) 数值对称, 让 4 verb 反馈节奏统一。
	#
	# LIGHT shake (1.0/0.08s) 补充"钉住"触感——比 PULSE 2.0/0.10s
	# 弱一档, 符合 Bind 语义"温柔牵制"而非"暴力推开"。
	#
	# 守卫：target == null 时不闪（bind_ability.gd:117 占位 emit
	# bind_hit(null) 表示"cast 成功但命中区域无敌人"，与 pulse_ability
	# 同样约定）。
	if target == null:
		return
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(ScreenShake.VERB_HIT_BIND_COLOR, 0.10, 0.18)
	if ScreenShake and ScreenShake.has_method("shake_preset"):
		ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)
	# T181 (#97 first half) — Bind hit audio cue (220Hz thunk). Pairs
	# with the bind_fired cue (T181 caller in bind_ability.gd) to
	# close the 2-beat "fire→hit" audio loop. Throttled internally
	# by AudioManagerEnhanced._VERB_HIT_THROTTLE (50ms) so a Bind
	# that pulls 3+ enemies in 0.05s doesn't stack 3 thunks.
	if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_bind_hit"):
		AudioManagerEnhanced.play_bind_hit()

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

	# F016 (#104) — Death lay-down "听见坠落" 0.4s 75Hz sub-bass 嗡鸣.
	# 在 _is_dying = true 之后 + Engine.time_scale 之前调, 让
	# SFX 触发时机与 T092 freeze-frame 视觉时序同步 (SFX 与
	# 红色 tint 几乎同帧, 玩家"听见坠落" 与 "看见坠落" 一致).
	# has_method 守卫保持 ame 老版本兼容.  AudioManagerEnhanced
	# 是 autoload 一定存在, 但 has_method 用于 audio_manager_enhanced
	# 没这方法时的 fallback (T103 F014 才有 ame pattern, 未来
	# 玩家用 #103 之前存档时 ame 不带这方法, 静默 no-op 比
	# push_error 更友好).
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced")
	if ame and ame.has_method("play_death_lay_down"):
		ame.play_death_lay_down()

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

# F006 (#86) — Centralised "try to cast a directional verb" helper.
# 4 verb handlers (_handle_pulse / _handle_bind / _handle_cut /
# _handle_echo) all share the same 5-step pattern, so we extract it
# here and let each handler shrink to a 1-line _try_verb() call.
#
# Steps (in order):
#   1. _pre_verb_block_check()  — bail if a global block is in effect
#      (death animation, Wave windup, future stun/pause).  See F005.
#   2. Input.is_action_just_pressed(action_name) — only act on the
#      rising edge of the verb key, not on every held frame.
#   3. Compute (origin, dir) from the player's current world position
#      and facing direction.  All 4 directional verbs share the same
#      "8px above center, face the way the sprite faces" formula.
#      Echo ignores `dir` in its inner wrapper, but the (origin, dir)
#      signature is preserved so Callable.call() has a uniform shape.
#   4. Delegate to the verb's start_fn (one of _start_pulse_at /
#      _start_bind_at / _start_cut_at / _start_echo_at).  Each
#      wrapper handles ability-null defensiveness and forwards to
#      the ability's start_*(origin, dir) method.
#   5. If start_fn returned false (e.g. cost not paid, cooldown
#      not expired, or ability absent), emit a HUD "blocked"
#      feedback.  All 4 verbs route to show_pulse_blocked() (the
#      generic "resonance too low / cooldown active" toast) — only
#      Wave (#_handle_wave) needs a 4-branch state-specific toast,
#      so it stays outside this helper.
#
# Why not also include _handle_wave?  Wave has 4 distinct "can't cast"
# reasons (active / winding_up / charging / blocked — see T143) that
# need different HUD messages.  Funneling it through this single-
# toast helper would collapse those branches and lose the verb-state
# specificity.  Wave's body stays as-is.
func _try_verb(action_name: String, start_fn: Callable) -> void:
	if _pre_verb_block_check():
		return
	if not Input.is_action_just_pressed(action_name):
		return
	var origin := global_position + Vector2(0, -8)
	var dir := Vector2.RIGHT if _facing_right else Vector2.LEFT
	var success: bool = start_fn.call(origin, dir)
	if success:
		return
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_pulse_blocked"):
		hud.show_pulse_blocked()

# F006 (#86) — 4 verb start-fn wrappers.  Each takes (origin, dir) and
# returns true if the verb started successfully, false if not.  Pulled
# out of the handlers so _try_verb() can call them via Callable.call()
# with a uniform (origin, dir) signature.  Echo ignores the `dir`
# parameter (it's a centered shield, not a directional projectile).
#
# Each wrapper defensively checks the @onready ability reference
# before calling .start_X() — if the ability is somehow null (e.g.
# the script was hot-reloaded without re-instantiating the children),
# the wrapper returns false and _try_verb() shows the blocked toast.
func _start_pulse_at(origin: Vector2, dir: Vector2) -> bool:
	return pulse_ability.start_pulse(origin, dir) if pulse_ability else false

func _start_bind_at(origin: Vector2, dir: Vector2) -> bool:
	return bind_ability.start_bind(origin, dir) if bind_ability else false

func _start_cut_at(origin: Vector2, dir: Vector2) -> bool:
	return cut_ability.start_cut(origin, dir) if cut_ability else false

func _start_echo_at(origin: Vector2, _dir: Vector2) -> bool:
	# Echo always pops at the player's location, so _dir is unused.
	return echo_ability.start_echo(origin) if echo_ability else false
