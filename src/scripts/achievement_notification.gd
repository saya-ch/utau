class_name AchievementNotification
extends CanvasLayer

## AchievementNotification — 屏幕中央偏上的成就解锁通知
##
## 当 PlayerStats.achievement_unlocked 信号触发时弹出一个小卡片，
## 暖色边框 + 居中淡入，停留 3 秒后向上滑出并淡出。
##
## 一次只显示一个通知；新通知会顶替当前通知立即显示。

const DISPLAY_DURATION: float = 3.0
const SLIDE_DURATION: float = 0.5
const FADE_DURATION: float = 0.25

# Icon hint → 颜色映射
const ICON_COLORS := {
	"amber_dot": Color(0.949, 0.714, 0.431, 1.0),
	"amber_shard": Color(0.949, 0.714, 0.431, 1.0),
	"amber_bell": Color(0.949, 0.714, 0.431, 1.0),
	"amber_lantern": Color(0.949, 0.714, 0.431, 1.0),
	"coral_pulse": Color(0.91, 0.43, 0.35, 1.0),
	"coral_slash": Color(0.91, 0.43, 0.35, 1.0),
	"coral_eye": Color(0.91, 0.43, 0.35, 1.0),
	"three_circles": Color(0.718, 0.906, 0.867, 1.0),
}

@onready var _panel: PanelContainer = $Panel
@onready var _title_label: Label = $Panel/MarginContainer/HBox/VBox/TitleLabel
@onready var _desc_label: Label = $Panel/MarginContainer/HBox/VBox/DescLabel
@onready var _icon_rect: ColorRect = $Panel/MarginContainer/HBox/IconRect

var _display_timer: float = 0.0
var _is_showing: bool = false
var _tween: Tween = null

func _ready() -> void:
	# Ensure the notification continues to process even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Hide initially
	_panel.modulate.a = 0.0
	_panel.position.y -= 20
	_panel.visible = false

	# Subscribe to achievement events
	PlayerStats.achievement_unlocked.connect(_on_achievement_unlocked)

func _process(delta: float) -> void:
	if _is_showing:
		_display_timer -= delta
		if _display_timer <= 0:
			_dismiss()

func _on_achievement_unlocked(id_val: String, title_zh: String, desc_zh: String) -> void:
	# Look up icon hint from definition
	var icon_color := ICON_COLORS.get("amber_dot", Color(0.949, 0.714, 0.431, 1.0))
	for ach in PlayerStats.get_all_achievements():
		if ach.get("id", "") == id_val:
			var hint: String = ach.get("icon_hint", "amber_dot")
			icon_color = ICON_COLORS.get(hint, icon_color)
			break
	show_achievement(title_zh, desc_zh, icon_color)

func show_achievement(title_zh: String, desc_zh: String, icon_color: Color = Color(0.949, 0.714, 0.431, 1.0)) -> void:
	# Cancel any in-flight dismiss
	if _tween:
		_tween.kill()

	_title_label.text = "✦ 成就解锁 ✦  " + title_zh
	_desc_label.text = desc_zh
	_icon_rect.color = icon_color

	_panel.visible = true
	_is_showing = true
	_display_timer = DISPLAY_DURATION

	# Slide in + fade in
	_panel.position.y = 16
	_panel.modulate.a = 0.0
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_panel, "position:y", 0.0, SLIDE_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_panel, "modulate:a", 1.0, FADE_DURATION)

func _dismiss() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_panel, "modulate:a", 0.0, FADE_DURATION)
	_tween.tween_callback(func():
		_panel.visible = false
		_is_showing = false
	)
