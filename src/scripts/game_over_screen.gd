class_name GameOverScreen
extends Control

signal retry_pressed
signal quit_to_title_pressed

@export var success_text: String = "房间已修复"
@export var failure_text: String = "共鸣消散..."

@onready var _result_label: Label = $VBoxContainer/ResultLabel
@onready var _hint_label: Label = $VBoxContainer/HintLabel
@onready var _retry_btn: Button = $VBoxContainer/RetryButton
@onready var _quit_btn: Button = $VBoxContainer/QuitToTitleButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_retry_btn.pressed.connect(_on_retry)
	_quit_btn.pressed.connect(_on_quit)

func show_success(shards_gained: int = 0) -> void:
	_result_label.text = success_text
	_result_label.modulate = Color("#F2B66E")
	_hint_label.text = "获得 %d ◆ 共鸣碎片" % shards_gained if shards_gained > 0 else ""
	_show_screen()

func show_failure() -> void:
	_result_label.text = failure_text
	_result_label.modulate = Color("#65506A")
	_hint_label.text = "按 Retry 再次尝试"
	_show_screen()

func _show_screen() -> void:
	show()
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func _on_retry() -> void:
	_retry_btn.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(func() -> void:
		hide()
		retry_pressed.emit()
	)

func _on_quit() -> void:
	quit_to_title_pressed.emit()
