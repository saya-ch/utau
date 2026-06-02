class_name DialogueBox
extends Control

signal dialogue_finished
signal option_selected(option_index: int)

@export var typing_speed: float = 0.04

@onready var _portrait: TextureRect = $HBoxContainer/Portrait
@onready var _name_label: Label = $HBoxContainer/TextColumn/NameLabel
@onready var _text_label: Label = $HBoxContainer/TextColumn/TextLabel
@onready var _next_hint: Label = $HBoxContainer/TextColumn/NextHint
@onready var _options_container: VBoxContainer = $HBoxContainer/TextColumn/OptionsContainer
@onready var _bg: ColorRect = $Background

var _dialogue_lines: Array[Dictionary] = []
var _current_line: int = 0
var _is_typing: bool = false
var _typing_tween: Tween = null

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _next_hint:
		_next_hint.text = "按 E / 空格 继续"
		_next_hint.modulate = Color("#69C7CE")
		_next_hint.visible = false

func show_dialogue(lines: Array[Dictionary]) -> void:
	_dialogue_lines = lines
	_current_line = 0
	show()
	_display_line()

func _display_line() -> void:
	if _current_line >= _dialogue_lines.size():
		_close_dialogue()
		return
	
	var line := _dialogue_lines[_current_line]
	
	# Portrait
	if _portrait:
		var tex = line.get("portrait", null)
		if tex is Texture2D:
			_portrait.texture = tex
			_portrait.visible = true
		else:
			_portrait.visible = false
	
	# Name
	if _name_label:
		_name_label.text = line.get("name", "")
		_name_label.modulate = Color("#F2B66E")
	
	# Text typing effect
	if _text_label:
		_text_label.text = ""
		_is_typing = true
		var full_text: String = line.get("text", "")
		_typing_tween = create_tween()
		for i in range(full_text.length()):
			_typing_tween.tween_callback(func() -> void:
				_text_label.text = full_text.substr(0, _text_label.text.length() + 1)
			)
			_typing_tween.tween_interval(typing_speed)
		_typing_tween.tween_callback(func() -> void:
			_is_typing = false
			if _next_hint:
				_next_hint.visible = true
				_animate_next_hint()
				# Show options if present
				var options = line.get("options", [])
				if options.size() > 0:
					_show_options(options)
			else:
					if _next_hint:
						_next_hint.visible = true
						_animate_next_hint()
		)

func _animate_next_hint() -> void:
	if not _next_hint:
		return
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(_next_hint, "modulate:a", 0.4, 0.6)
	tween.tween_property(_next_hint, "modulate:a", 1.0, 0.6)

func _show_options(options: Array) -> void:
	if not _options_container:
		return
	for child in _options_container.get_children():
		child.queue_free()
	_options_container.visible = true
	
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = options[i]
		btn.custom_minimum_size = Vector2(120, 20)
		btn.theme_override_font_sizes.font_size = 9
		btn.pressed.connect(func() -> void:
			option_selected.emit(i)
			_options_container.visible = false
			_advance_line()
		)
		_options_container.add_child(btn)

func _advance_line() -> void:
	if _is_typing:
		# Skip to end of current line
		if _typing_tween:
			_typing_tween.kill()
		_is_typing = false
		if _text_label and _current_line < _dialogue_lines.size():
			_text_label.text = _dialogue_lines[_current_line].get("text", "")
		if _next_hint:
			_next_hint.visible = true
			_animate_next_hint()
		var line = _dialogue_lines[_current_line]
		if line.get("options", []).size() > 0 and _options_container.visible:
			return
	else:
		_current_line += 1
		_options_container.visible = false
		_display_line()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		_advance_line()
		get_viewport().set_input_as_handled()

func _close_dialogue() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void:
		hide()
		modulate.a = 1.0
		dialogue_finished.emit()
	)
