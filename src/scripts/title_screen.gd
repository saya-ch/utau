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

	# T066 — Pre-warm BGM streams.  The synthesis cost (~2-3s for
	# 4 tracks at 22050Hz on the main thread) is deferred to the
	# next idle frame so the title fade-in animation keeps priority.
	# By the time the player reads the title and clicks "开始", all
	# 4 preset streams (title_intro / hub_warm / archive_exploration /
	# archive_boss) are already in the AudioManagerEnhanced cache,
	# and the first scene switch incurs zero synthesis latency.
	call_deferred("_prewarm_bgm")

func _prewarm_bgm() -> void:
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("prewarm_music_streams"):
		ame.call("prewarm_music_streams")

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
