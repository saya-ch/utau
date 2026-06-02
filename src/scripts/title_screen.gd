class_name TitleScreen
extends Control

signal start_game_pressed
signal quit_game_pressed

@export var title_text: String = "VOXGLASS"
@export var subtitle_text: String = "修复被寂静吞噬的声音"

@onready var _title_label: Label = $VBoxContainer/TitleLabel
@onready var _subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var _start_btn: Button = $VBoxContainer/StartButton
@onready var _quit_btn: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	_title_label.text = title_text
	_subtitle_label.text = subtitle_text
	
	_start_btn.pressed.connect(_on_start)
	_quit_btn.pressed.connect(_on_quit)
	
	# Fade in
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.8)

func _on_start() -> void:
	_start_btn.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(func() -> void:
		start_game_pressed.emit()
		hide()
	)

func _on_quit() -> void:
	quit_game_pressed.emit()
	get_tree().quit()

func show_screen() -> void:
	show()
	modulate = Color.TRANSPARENT
	_start_btn.disabled = false
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
