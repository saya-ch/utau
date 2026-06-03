class_name RoomTransition
extends CanvasLayer

signal transition_finished

@onready var _rect: ColorRect = $ColorRect

func _ready() -> void:
	add_to_group("room_transition")
	layer = 100
	_rect.color = Color.BLACK
	_rect.modulate.a = 0.0
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, duration)
	tween.tween_callback(func() -> void:
		transition_finished.emit()
	)

func fade_in(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, duration)
	tween.tween_callback(func() -> void:
		# Allow listeners to chain actions after fade-in completes
		# (fade_out already emits, but this keeps the contract symmetric)
		if not get_tree().paused:
			transition_finished.emit()
	)
