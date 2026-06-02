class_name GlassLock
extends StaticBody2D

signal unlocked
signal repair_progress_changed(progress: float)

@export var repair_required: int = 1
@export var repair_sound_pitch: float = 1.0

var _current_repair: int = 0
var _is_unlocked: bool = false

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("interactable")
	_update_visual_state()

func on_pulse_triggered() -> void:
	if _is_unlocked:
		return
	
	_current_repair += 1
	var progress := float(_current_repair) / float(repair_required)
	repair_progress_changed.emit(progress)
	
	# Visual feedback: brief flash
	if _sprite:
		_sprite.modulate = Color("#F2B66E")
		await get_tree().create_timer(0.1).timeout
		if _sprite:
			_sprite.modulate = Color.WHITE
	
	if _current_repair >= repair_required:
		_unlock()

func _unlock() -> void:
	_is_unlocked = true
	unlocked.emit()
	
	# Disable collision
	if _collision:
		_collision.disabled = true
	
	# Visual: fade out or change to "repaired" state
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#69C7CE"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.3, 0.5)

func _update_visual_state() -> void:
	if _sprite:
		_sprite.modulate = Color.WHITE

func is_unlocked() -> bool:
	return _is_unlocked

func get_repair_progress() -> float:
	if repair_required <= 0:
		return 1.0
	return clampf(float(_current_repair) / float(repair_required), 0.0, 1.0)
