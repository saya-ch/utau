class_name SaveLoadMenu
extends Control

## SaveLoadMenu — 存档/读档选择菜单
##
## 用途：
## 1. 在 TitleScreen 弹出，让玩家选择载入存档 / 新建游戏
## 2. 列出 3 个手动存档槽 + 1 个自动存档（SaveLantern 触发）
## 3. 显示每槽摘要：存档时间 / 房间完成数 / 共鸣碎片总数
##
## 接入：
##   SaveLoadMenu.slot_chosen.connect(_on_slot_chosen)
##   SaveLoadMenu.cancelled.connect(_on_cancel)
##   SaveLoadMenu.show_menu()

signal slot_chosen(slot_index: int, is_auto: bool)  # 玩家选定一个槽进入游戏
signal cancelled

const SLOT_COUNT: int = 3
const AUTO_SLOT_LABEL: String = "自动存档"
const TITLE_TEXT: String = "选择存档"
const EMPTY_LABEL: String = "—— 空存档 ——"

@onready var _panel: PanelContainer = $Panel
@onready var _title_label: Label = $Panel/MarginContainer/MainVBox/TitleLabel
@onready var _slots_container: VBoxContainer = $Panel/MarginContainer/MainVBox/SlotsContainer
@onready var _hint_label: Label = $HintLabel

var _is_open: bool = false

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_title_label.text = TITLE_TEXT
	_hint_label.modulate.a = 0.0

func show_menu() -> void:
	_rebuild_slots()
	show()
	_is_open = true
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func hide_menu() -> void:
	_is_open = false
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_callback(func() -> void:
		hide()
	)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.is_action_pressed("ui_cancel"):
			_emit_cancel()

func _rebuild_slots() -> void:
	# 清理旧条目
	for child in _slots_container.get_children():
		child.queue_free()
	# 自动存档
	_slots_container.add_child(_build_slot_row(-1))
	# 手动 3 槽
	for i in range(SLOT_COUNT):
		_slots_container.add_child(_build_slot_row(i))
	# 返回按钮
	var back_btn := Button.new()
	back_btn.text = "返回"
	back_btn.custom_minimum_size = Vector2(120, 18)
	back_btn.size_flags_horizontal = 4
	back_btn.pressed.connect(_emit_cancel)
	_slots_container.add_child(back_btn)

func _build_slot_row(slot_index: int) -> Control:
	# 每个槽位一行：左侧摘要 + 右侧"载入/删除/新建"按钮
	var summary: Dictionary
	if slot_index == -1:
		summary = SaveSystem.get_auto_summary()
	else:
		summary = SaveSystem.get_slot_summary(slot_index)

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	# 槽位标题
	var title_lbl := Label.new()
	if slot_index == -1:
		title_lbl.text = AUTO_SLOT_LABEL
	else:
		title_lbl.text = "存档槽 %d" % (slot_index + 1)
	title_lbl.custom_minimum_size = Vector2(80, 0)
	title_lbl.add_theme_font_size_override("font_size", 8)
	title_lbl.add_theme_color_override("font_color", Color(0.949, 0.714, 0.431, 1.0))  # Amber Voice
	row.add_child(title_lbl)

	# 摘要文本
	var info_lbl := Label.new()
	info_lbl.add_theme_font_size_override("font_size", 7)
	if not bool(summary.get("exists", false)):
		info_lbl.text = EMPTY_LABEL
		info_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5, 0.8))
	else:
		var ts_text: String = SaveSystem.format_timestamp(int(summary.get("timestamp_unix", 0)))
		info_lbl.text = "%s  ·  房间 %d  ·  碎片 %d" % [
			ts_text,
			int(summary.get("room_count", 0)),
			int(summary.get("shard_total", 0)),
		]
		info_lbl.add_theme_color_override("font_color", Color(0.718, 0.906, 0.867, 1.0))  # Pale Resonance
	info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info_lbl)

	# 操作按钮
	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(60, 16)
	action_btn.add_theme_font_size_override("font_size", 7)
	if not bool(summary.get("exists", false)):
		action_btn.text = "新建"
		action_btn.pressed.connect(_on_new_game.bind(slot_index))
	else:
		action_btn.text = "载入"
		action_btn.pressed.connect(_on_load.bind(slot_index))
	row.add_child(action_btn)

	# 删除按钮（仅在有存档时显示）
	if bool(summary.get("exists", false)):
		var del_btn := Button.new()
		del_btn.custom_minimum_size = Vector2(40, 16)
		del_btn.text = "删"
		del_btn.add_theme_font_size_override("font_size", 7)
		del_btn.pressed.connect(_on_delete.bind(slot_index))
		row.add_child(del_btn)

	return row

func _on_new_game(slot_index: int) -> void:
	# 玩家从空槽开始新游戏：slot_index 是玩家槽 (-1 表示 auto)
	# 流程：直接进入 main_scene，由 SaveLantern 触发的自动存档会覆盖 auto slot
	slot_chosen.emit(slot_index, false)
	hide_menu()

func _on_load(slot_index: int) -> void:
	slot_chosen.emit(slot_index, false)
	hide_menu()

func _on_delete(slot_index: int) -> void:
	if slot_index == -1:
		SaveSystem.delete_auto()
	else:
		SaveSystem.delete_slot(slot_index)
	_rebuild_slots()

func _emit_cancel() -> void:
	cancelled.emit()
	hide_menu()
