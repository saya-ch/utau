class_name TitleScreen
extends Control

signal start_game_pressed
signal quit_game_pressed
signal credits_opened
signal credits_closed

@export var title_text: String = "VOXGLASS"
@export var subtitle_text: String = "修复被寂静吞噬的声音"

@onready var _title_label: Label = $VBoxContainer/TitleLabel
@onready var _subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var _start_btn: Button = $VBoxContainer/StartButton
@onready var _credits_btn: Button = $VBoxContainer/CreditsButton
@onready var _quit_btn: Button = $VBoxContainer/QuitButton
@onready var _credits_screen: CreditsScreen = $CreditsScreen

func _ready() -> void:
	_title_label.text = title_text
	_subtitle_label.text = subtitle_text

	_start_btn.pressed.connect(_on_start)
	_credits_btn.pressed.connect(_on_credits)
	_quit_btn.pressed.connect(_on_quit)

	_credits_screen.closed.connect(_on_credits_closed)

	# Fade in
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.8)

func _on_start() -> void:
	_start_btn.disabled = true
	_credits_btn.disabled = true
	_quit_btn.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(func() -> void:
		start_game_pressed.emit()
		hide()
	)

func _on_credits() -> void:
	_start_btn.disabled = true
	_credits_btn.disabled = true
	_quit_btn.disabled = true
	credits_opened.emit()
	_credits_screen.show_screen()

func _on_credits_closed() -> void:
	credits_closed.emit()
	_start_btn.disabled = false
	_credits_btn.disabled = false
	_quit_btn.disabled = false

func _on_quit() -> void:
	quit_game_pressed.emit()
	get_tree().quit()

func show_screen() -> void:
	show()
	modulate = Color.TRANSPARENT
	_start_btn.disabled = false
	_credits_btn.disabled = false
	_quit_btn.disabled = false
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
