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

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_right: bool = true
var _is_jumping: bool = false
var _was_on_floor: bool = false
var _speed_multiplier: float = 1.0

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

func _setup_spriteframes() -> void:
	"""Load the new spritesheets and build SpriteFrames for both directions."""
	var tex_right := load("res://assets/sprites/saya_spritesheet_right.png") as Texture2D
	var tex_left := load("res://assets/sprites/saya_spritesheet_left.png") as Texture2D
	
	if tex_right == null or tex_left == null:
		push_warning("Saya spritesheets not found, using placeholder")
		return
	
	_sf_right = _build_spriteframes(tex_right)
	_sf_left = _build_spriteframes(tex_left)
	
	# Start with right-facing
	sprite.sprite_frames = _sf_right
	sprite.animation = "idle"
	sprite.play()

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
	_handle_gravity(delta)
	_handle_movement(delta)
	_handle_jump(delta)
	_handle_pulse()
	_update_animation()
	_update_facing()

	_was_on_floor = is_on_floor()
	move_and_slide()

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
			var success := pulse_ability.start_pulse(origin, dir)
			if not success:
				var hud = get_tree().get_first_node_in_group("hud")
				if hud and hud.has_method("show_pulse_blocked"):
					hud.show_pulse_blocked()

func _on_pulse_fired(origin: Vector2, radius: float) -> void:
	# Spawn VFX
	var vfx = preload("res://src/scripts/pulse_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(origin, radius)

	# Screen shake on pulse
	var camera := get_tree().get_first_node_in_group("camera") as Camera2D
	if camera:
		var shake_tween := create_tween()
		shake_tween.tween_property(camera, "offset", Vector2(randf_range(-2, 2), randf_range(-2, 2)), 0.05)
		shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

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
	GameState.take_damage(amount)
	velocity += knockback
	# Brief invulnerability flash could go here

func respawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO

func set_speed_multiplier(multiplier: float) -> void:
	_speed_multiplier = multiplier
