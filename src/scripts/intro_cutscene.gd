class_name IntroCutscene
extends CanvasLayer

# T073 — Opening cutscene. Plays on game start, before the TitleScreen
# is revealed. Sequence (~8 s total):
#   0.0 - 1.0s : pure black
#   1.0 - 3.0s : text "声音被寂静吞噬" fades in (2 s)
#   3.0 - 5.0s : hold (2 s)
#   5.0 - 7.0s : black + text fade out together (2 s)
#   7.0 - 8.0s : hold invisible (1 s) before signaling done
# Pressing any key/clicking skips the cutscene to its end.

signal cutscene_finished

const TOTAL_DURATION := 8.0

var _skipped: bool = false
var _finished_emitted: bool = false

@onready var _black_rect: ColorRect = $BlackRect
@onready var _text_label: Label = $CenterContainer/TextLabel

func _ready() -> void:
	# Ensure the cutscene is on top of everything and grabs input
	# so the player can't interact with the title screen underneath.
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Start invisible / blank — text already at modulate alpha 0 in scene.
	_text_label.modulate = Color(1, 1, 1, 0)
	_black_rect.modulate = Color(1, 1, 1, 1)
	_play_sequence()

func _play_sequence() -> void:
	var tween := create_tween()
	# 0.0 - 1.0s : pure black hold
	tween.tween_interval(1.0)
	# 1.0 - 3.0s : text fades in over 2 s
	tween.tween_property(_text_label, "modulate:a", 1.0, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# 3.0 - 5.0s : hold at full opacity
	tween.tween_interval(2.0)
	# 5.0 - 7.0s : fade out black + text together
	tween.parallel().tween_property(_black_rect, "modulate:a", 0.0, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_text_label, "modulate:a", 0.0, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# 7.0 - 8.0s : hold invisible
	tween.tween_interval(1.0)
	# Finish
	tween.tween_callback(_emit_finished_once)

func _emit_finished_once() -> void:
	if _finished_emitted:
		return
	_finished_emitted = true
	cutscene_finished.emit()
	# After a short beat, fully hide so the underlying title screen
	# can be interacted with (the cutscene CanvasLayer is no longer needed).
	var t := get_tree().create_timer(0.2)
	t.timeout.connect(func() -> void:
		if is_instance_valid(self):
			visible = false
			# Re-enable input by dropping the layer below UI. The title
			# screen at layer 0 will now receive clicks.
			layer = -1
	)

func _unhandled_input(event: InputEvent) -> void:
	if _finished_emitted:
		return
	# Only skip on press (not release), and only on key/click/touch.
	if not event.is_pressed():
		return
	var is_key := event is InputEventKey
	var is_mouse := event is InputEventMouseButton
	var is_touch := event is InputEventScreenTouch
	var is_joypad := event is InputEventJoypadButton
	if is_key or is_mouse or is_touch or is_joypad:
		# Consume the event so it doesn't fall through to the title
		# screen beneath us (we want clicks to skip, not to also fire
		# "Start New Game" / "Continue").
		get_viewport().set_input_as_handled()
		_skip()

func _skip() -> void:
	if _skipped or _finished_emitted:
		return
	_skipped = true
	# Fast-forward: tween is not directly killable on a specific time, so
	# just snap to the end state and emit.
	if is_instance_valid(_text_label):
		_text_label.modulate = Color(1, 1, 1, 0)
	if is_instance_valid(_black_rect):
		_black_rect.modulate = Color(1, 1, 1, 0)
	_emit_finished_once()
