class_name PauseMenu
extends Control

signal resume_pressed
signal restart_pressed
signal quit_to_title_pressed

@onready var _resume_btn: Button = $VBoxContainer/ResumeButton
@onready var _restart_btn: Button = $VBoxContainer/RestartButton
@onready var _quit_btn: Button = $VBoxContainer/QuitToTitleButton

var _is_paused: bool = false

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_resume_btn.pressed.connect(_on_resume)
	_restart_btn.pressed.connect(_on_restart)
	_quit_btn.pressed.connect(_on_quit_to_title)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	_is_paused = not _is_paused
	get_tree().paused = _is_paused
	visible = _is_paused
	
	if _is_paused:
		modulate = Color.TRANSPARENT
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func _on_resume() -> void:
	toggle_pause()
	resume_pressed.emit()

func _on_restart() -> void:
	get_tree().paused = false
	_is_paused = false
	restart_pressed.emit()

func _on_quit_to_title() -> void:
	get_tree().paused = false
	_is_paused = false
	quit_to_title_pressed.emit()
