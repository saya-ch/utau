class_name VoiceBell
extends Area2D

signal repaired
signal shard_collected

@export var shard_value: int = 1
@export var repair_pulse_required: int = 1

var _repair_count: int = 0
var _is_repaired: bool = false
var _shard_collected: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _shard_area: Area2D = $ShardArea

func _ready() -> void:
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	_update_visual_state()

func on_pulse_triggered() -> void:
	if _is_repaired:
		return
	
	_repair_count += 1
	
	# Visual feedback: crack glow
	if _sprite:
		_sprite.modulate = Color("#F2B66E")
		await get_tree().create_timer(0.15).timeout
		if _sprite:
			_sprite.modulate = Color.WHITE
	
	if _repair_count >= repair_pulse_required:
		_repair()

func _repair() -> void:
	_is_repaired = true
	repaired.emit()

	# Spawn repair VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 28.0)

	# Visual: switch to repaired sprite and glow with warm light
	if _sprite:
		# Try to load repaired texture
		var repaired_tex := load("res://assets/sprites/voice_bell_repaired.png") as Texture2D
		if repaired_tex:
			_sprite.texture = repaired_tex
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.5)
		# Subtle pulse animation
		tween.tween_property(_sprite, "scale", Vector2(1.1, 1.1), 0.3)
		tween.tween_property(_sprite, "scale", Vector2(1.0, 1.0), 0.3)

	# Enable shard collection
	if _shard_area:
		_shard_area.monitoring = true

	# HUD hint
	var hud := get_tree().get_first_node_in_group("hud") as HUD
	if hud:
		hud.show_repair_hint("声匣已修复")

func _on_body_entered(body: Node2D) -> void:
	if not _is_repaired or _shard_collected:
		return
	
	if body.is_in_group("player"):
		_collect_shard()

func _collect_shard() -> void:
	_shard_collected = true
	GameState.add_shards(shard_value)
	shard_collected.emit()
	
	# Visual: shard absorbed
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate:a", 0.0, 0.5)
		tween.tween_callback(queue_free)

func _update_visual_state() -> void:
	if _sprite:
		_sprite.modulate = Color.WHITE

func is_repaired() -> bool:
	return _is_repaired

func is_shard_collected() -> bool:
	return _shard_collected
