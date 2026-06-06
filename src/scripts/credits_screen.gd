class_name CreditsScreen
extends Control

## CreditsScreen — 致谢屏
##
## 极简可滚动 Label，按 ESC / Enter / 任意键关闭。
## 列出引擎/工具/作者/受启发的游戏占位。纯文案，背景半透明。

signal closed

const SCROLL_SPEED: float = 18.0  # px/sec

# 致谢内容（每行一段，按顺序滚动）
const CREDITS_LINES: Array[String] = [
	"",
	"",
	"VOXGLASS",
	"修复被寂静吞噬的声音",
	"",
	"",
	"—— 制作 ——",
	"",
	"设计 / 程序 / 美术 / 音乐 (占位)",
	"独立开发者",
	"",
	"",
	"—— 引擎 ——",
	"",
	"Godot Engine 4.6.3",
	"https://godotengine.org",
	"",
	"",
	"—— 素材 ——",
	"",
	"全部像素艺术 / 声波 / 程序化音乐",
	"由独立开发者程序化生成",
	"",
	"",
	"—— 音效 ——",
	"",
	"Pulse / Bind / Cut / Echo / 修复",
	"由 AudioManager 程序化合成",
	"",
	"",
	"—— 灵感 ——",
	"",
	"Hollow Knight",
	"深色地下世界与氛围密度",
	"",
	"Celeste",
	"小机制的高精度手感",
	"",
	"Dead Cells",
	"短局动作反馈与节奏",
	"",
	"Ori and the Blind Forest",
	"修复世界与情绪奖励",
	"",
	"Rhythm Doctor",
	"音频 / 视觉节奏反馈",
	"",
	"",
	"—— 玩家 ——",
	"",
	"感谢你愿意把声音还给寂静。",
	"",
	"",
	"",
	"✦ THE END ✦",
	"",
	"",
	"",
]

@onready var _scroll_container: ScrollContainer = $Panel/MarginContainer/ScrollContainer
@onready var _content_label: RichTextLabel = $Panel/MarginContainer/ScrollContainer/ContentLabel
@onready var _hint_label: Label = $HintLabel

var _is_open: bool = false
var _close_timer: float = 0.0

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_text()
	_hint_label.modulate.a = 0.0
	_hint_label.text = "按 ESC / Enter / 任意键 返回"
	# 提示淡入循环
	_pulse_hint()

func _build_text() -> void:
	var bb := "[center]"
	for line in CREDITS_LINES:
		bb += line + "\n"
	bb += "[/center]"
	_content_label.bbcode_enabled = true
	_content_label.text = bb

func _process(delta: float) -> void:
	if not _is_open:
		return
	# 自动滚动
	var bar := _scroll_container.get_v_scroll_bar()
	if bar:
		bar.value += SCROLL_SPEED * delta
		bar.value = min(bar.value, bar.max_value)
	# 滚到底部时显示关闭提示
	if bar and bar.value >= bar.max_value - 1.0:
		_close_timer += delta
	else:
		_close_timer = 0.0
	# 6 秒静止在末尾后允许关闭
	_hint_label.visible = _close_timer > 1.0

func _pulse_hint() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_hint_label, "modulate:a", 0.8, 0.8)
	tween.tween_property(_hint_label, "modulate:a", 0.3, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		_close()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	_is_open = false
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_callback(func() -> void:
		hide()
		closed.emit()
	)

func show_screen() -> void:
	show()
	_is_open = true
	_close_timer = 0.0
	# 重置到顶部
	var bar := _scroll_container.get_v_scroll_bar()
	if bar:
		bar.value = 0
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
