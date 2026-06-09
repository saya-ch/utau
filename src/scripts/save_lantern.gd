class_name SaveLantern
extends Area2D

signal activated

@export var lantern_color: Color = Color("#F2B66E")
@export var dim_color: Color = Color("#65506A")
@export var pulse_radius: float = 32.0

var _is_activated: bool = false
var _pulse_timer: float = 0.0
# T154 (#78) — Reverse-flash token, used by silenced_web.on_cut_triggered()
# to briefly tint the lantern Coral Pulse ("the cut web revived the
# lantern").  Token is a [Color] tween that reverts to white over 0.15s.
# Null when no flash is active (idle state).
var _coral_flash_tween: Tween = null

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	add_to_group("save_lantern")
	body_entered.connect(_on_body_entered)
	
	# Setup sprite frames
	_setup_spriteframes()
	
	# Initial dim state
	if _sprite:
		_sprite.animation = "dim"
		_sprite.play()
	if _particles:
		_particles.emitting = false

func _setup_spriteframes() -> void:
	var tex := load("res://assets/sprites/save_lantern_spritesheet.png") as Texture2D
	if tex == null:
		push_warning("Save lantern spritesheet not found")
		return
	
	var sf := SpriteFrames.new()
	var cell_w := 28
	var cell_h := 36
	
	# dim: frame 0
	sf.add_animation("dim")
	sf.set_animation_speed("dim", 5.0)
	sf.set_animation_loop("dim", true)
	var dim_at := AtlasTexture.new()
	dim_at.atlas = tex
	dim_at.region = Rect2(0, 0, cell_w, cell_h)
	sf.add_frame("dim", dim_at)
	
	# lit: frames 1-4 (shimmer)
	sf.add_animation("lit")
	sf.set_animation_speed("lit", 8.0)
	sf.set_animation_loop("lit", true)
	for i in range(4):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2((i + 1) * cell_w, 0, cell_w, cell_h)
		sf.add_frame("lit", at)
	
	_sprite.sprite_frames = sf

func _process(delta: float) -> void:
	if _is_activated:
		_pulse_timer += delta

func _on_body_entered(body: Node2D) -> void:
	if _is_activated:
		return
	if not body.is_in_group("player"):
		return
	
	_activate()

func _activate() -> void:
	_is_activated = true

	# Visual activation
	if _sprite:
		_sprite.animation = "lit"
		_sprite.play()

	if _particles:
		_particles.emitting = true

	# Save checkpoint
	GameState.set_checkpoint(global_position)
	# Stats tracking
	PlayerStats.record_save_lantern_activated()

	# Feedback
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("共鸣已记录")

	# Sound
	if AudioManagerEnhanced.has_method("play_repair_success"):
		AudioManagerEnhanced.play_repair_success()

	activated.emit()

func is_activated() -> bool:
	return _is_activated

# T154 (#78) — Reverse-flash hook.
# Called by SilencedWeb.on_cut_triggered() when a corruption web is
# cut near this lantern.  Tints the AnimatedSprite2D with Coral Pulse
# (#E86D5A — the inverse of the lantern's normal Amber Voice lit
# colour) for 0.15s, then tweens back to white.  The brief "alive"
# pulse tells the player the web-clearing helped the lantern even
# before they reach it.  Idempotent: a second call mid-flash just
# restarts the tween (so consecutive web-cuts near the same lantern
# keep the flash alive).  No-op if the sprite isn't ready yet
# (headless test contexts).
func flash_coral_pulse() -> void:
	if _sprite == null:
		return
	# Kill any in-flight tween so consecutive web-cuts restart cleanly.
	if _coral_flash_tween and _coral_flash_tween.is_valid():
		_coral_flash_tween.kill()
	_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	var coral := Color(0.91, 0.427, 0.353, 1.0)  # Coral Pulse #E86D5A
	_sprite.modulate = coral
	_coral_flash_tween = create_tween()
	# 0.15s tween, single property, no parallel — keep it simple.
	# TRANS_QUAD ease-out gives a quick "snap, then relax" curve.
	_coral_flash_tween.tween_property(_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
