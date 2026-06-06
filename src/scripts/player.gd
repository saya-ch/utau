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

# SpriteFrames for each facing direction
var _sf_right: SpriteFrames
var _sf_left: SpriteFrames

const CELL_W := 48
const CELL_H := 64

func _ready() -> void:
	add_to_group("player")
	_setup_spriteframes()
	if pulse_ability:
		pulse_ability.pulse_fired.connect(_on_pulse_fired)
	if bind_ability:
		bind_ability.bind_fired.connect(_on_bind_fired)
	if cut_ability:
		cut_ability.cut_fired.connect(_on_cut_fired)

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

	# Chained tween: freeze interval → restore time_scale → lay-down
	# → fade-out → finish. All on one tween so the freeze and the
	# death animation share a single timing pipeline (no drift
	# between the freeze end and the lay-down start). Tween.interval
	# advances at Engine.time_scale, so DEATH_FREEZE_DURATION (0.15
	# in-game) takes ~0.75s of real time at 0.2 scale.
	var tween := create_tween()
	tween.tween_interval(DEATH_FREEZE_DURATION)
	tween.tween_callback(_end_death_freeze_frame)
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
