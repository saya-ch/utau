class_name TutorialHint
extends CanvasLayer

## TutorialHint — 屏幕底部淡入淡出文字提示
##
## 用于首次游玩引导。教程文字按"提示组"管理，每组只显示一次。
## 显示后自动等待 N 秒后淡出，或被新提示顶替。
##
## 接入方式：
##   1. 在场景根节点添加 TutorialHint 实例
##   2. 通过 `queue_hint(group_id, text, duration)` 显示提示
##   3. 同一 group_id 不会重复显示

const FADE_DURATION: float = 0.4
const DEFAULT_DURATION: float = 4.0

@onready var _panel: PanelContainer = $Panel
@onready var _hint_label: Label = $Panel/MarginContainer/HintLabel

var _display_timer: float = 0.0
var _is_showing: bool = false
var _tween: Tween = null
var _shown_groups: Dictionary = {}  # group_id -> true

func _ready() -> void:
	add_to_group("tutorial_hint")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.modulate.a = 0.0
	_panel.position.y += 20
	_panel.visible = false

func queue_hint(group_id: String, text: String, duration: float = DEFAULT_DURATION) -> void:
	# Skip if already shown
	if _shown_groups.get(group_id, false):
		return
	_shown_groups[group_id] = true
	_show_hint(text, duration)

func queue_hint_force(text: String, duration: float = DEFAULT_DURATION) -> void:
	# Force show regardless of group_id
	_show_hint(text, duration)

func _show_hint(text: String, duration: float) -> void:
	if _tween:
		_tween.kill()

	_hint_label.text = text
	_panel.visible = true
	_is_showing = true
	_display_timer = duration

	_panel.position.y = 220  # Bottom of 270 viewport
	_panel.modulate.a = 0.0
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_panel, "position:y", 220.0, 0.0)
	_tween.tween_property(_panel, "modulate:a", 1.0, FADE_DURATION)

func _process(delta: float) -> void:
	if _is_showing:
		_display_timer -= delta
		if _display_timer <= 0:
			_dismiss()

func _dismiss() -> void:
	_is_showing = false
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_panel, "modulate:a", 0.0, FADE_DURATION)
	_tween.tween_callback(func():
		_panel.visible = false
	)

func reset_shown() -> void:
	_shown_groups.clear()
