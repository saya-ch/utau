class_name SaveLoadMenu
extends Control

## SaveLoadMenu — 存档/读档菜单（T088 升级 3→5 slots + 列表视图）
##
## 显示 5 个 slot 的状态（空/有数据），并提供 覆盖 / 读取 / 删除 操作。
## 提供两种布局：
##   - "card"  (默认) — 每行 44px 高，含标题/摘要 + 3 个按钮 (覆盖/读取/删除)
##   - "list"  (紧凑) — 每行 28px 高，单按钮单击即触发主要动作（按 mode 区分）
## 启动流程：
##   TitleScreen -> SaveLoadMenu (mode=select) -> 选 slot -> 读档 -> emit continue_game_pressed
##   PauseMenu -> SaveLoadMenu (mode=save) -> 选 slot -> 写档 -> emit saved
##
## mode:
##   "select" — TitleScreen 用，玩家可读任一 slot 继续游戏
##   "save"   — PauseMenu 用，玩家只能覆盖已有 slot 或写入空 slot

signal closed
signal save_requested(slot_id: int)        # mode=save: 玩家在 slot N 上点"覆盖/新建"
signal load_requested(slot_id: int)        # mode=select: 玩家在 slot N 上点"继续"
signal delete_requested(slot_id: int)      # 玩家在 slot N 上点"删除"
signal layout_changed(layout: String)      # T088: 玩家切换 list/card 布局

@export var mode: String = "select"  # "select" or "save"
@export var layout: String = "card"  # T088: "card" (默认) 或 "list" (紧凑视图)

const SLOT_COUNT := 5  # T088: 升级 3 → 5
const EMPTY_TEXT := "[ 空槽位 ]"
const NO_SAVE_TEXT := "—"

@onready var _title_label: Label = $RootPanel/Margin/VBox/TitleLabel
@onready var _slot_container: VBoxContainer = $RootPanel/Margin/VBox/SlotContainer
@onready var _back_btn: Button = $RootPanel/Margin/VBox/BackButton
@onready var _hint_label: Label = $RootPanel/Margin/VBox/HintLabel
@onready var _layout_btn: Button = $RootPanel/Margin/VBox/LayoutButton  # T088: card/list 切换

var _slot_panels: Array = []  # N 个 slot 节点（card 或 list 行）

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	# 标题按 mode 切换文案
	if mode == "save":
		_title_label.text = "保存进度"
		_hint_label.text = "选择一个槽位写入或覆盖"
	else:
		_title_label.text = "继续修复"
		_hint_label.text = "选择一个槽位继续你的旅程"
	_back_btn.pressed.connect(_on_back)
	_layout_btn.pressed.connect(_on_toggle_layout)
	_build_slots()
	_refresh_slots()
	_refresh_layout_btn_text()

func show_menu() -> void:
	_refresh_slots()
	show()
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)

func hide_menu() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(func() -> void:
		hide()
		closed.emit()
	)

# === 内部 ===

func _build_slots() -> void:
	# 清空占位节点
	for child in _slot_container.get_children():
		child.queue_free()
	_slot_panels.clear()
	for i in range(SLOT_COUNT):
		var slot := _make_slot_panel(i)
		_slot_container.add_child(slot)
		_slot_panels.append(slot)

# T088 — 工厂方法，按 layout 决定生成 card 或 list 行
func _make_slot_panel(slot_id: int) -> PanelContainer:
	if layout == "list":
		return _make_list_row(slot_id)
	return _make_card_panel(slot_id)

func _make_card_panel(slot_id: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 44)  # T088: 56→44 紧凑 (5 行更易放下)
	panel.name = "Slot_%d" % slot_id
	# 用与暂停菜单一致的 StyleBoxFlat（深海军蓝 + 玻璃青边）
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.031, 0.071, 0.118, 0.85)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.412, 0.78, 0.808, 0.6)
	sb.content_margin_left = 8.0
	sb.content_margin_top = 4.0
	sb.content_margin_right = 8.0
	sb.content_margin_bottom = 4.0
	panel.add_theme_stylebox_override("panel", sb)

	# Outer row HBox (left summary | right buttons)
	var row_hbox := HBoxContainer.new()
	row_hbox.name = "RowHBox"
	row_hbox.add_theme_constant_override("separation", 8)
	panel.add_child(row_hbox)

	# Left: VBox of title + summary
	var left := VBoxContainer.new()
	left.name = "LeftVBox"
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_hbox.add_child(left)
	var title_lbl := Label.new()
	title_lbl.name = "TitleLbl"
	title_lbl.add_theme_font_size_override("font_size", 10)
	left.add_child(title_lbl)
	var summary_lbl := Label.new()
	summary_lbl.name = "SummaryLbl"
	summary_lbl.add_theme_font_size_override("font_size", 8)
	summary_lbl.add_theme_color_override("font_color", Color(0.875, 0.835, 0.784, 1))
	left.add_child(summary_lbl)

	# Right: 3 buttons in a HBox
	var right := HBoxContainer.new()
	right.name = "RightHBox"
	right.add_theme_constant_override("separation", 4)
	row_hbox.add_child(right)
	var btn_overwrite := Button.new()
	btn_overwrite.name = "OverwriteBtn"
	btn_overwrite.custom_minimum_size = Vector2(56, 22)
	btn_overwrite.add_theme_font_size_override("font_size", 8)
	btn_overwrite.text = "保存"
	right.add_child(btn_overwrite)
	var btn_load := Button.new()
	btn_load.name = "LoadBtn"
	btn_load.custom_minimum_size = Vector2(56, 22)
	btn_load.add_theme_font_size_override("font_size", 8)
	btn_load.text = "读取"
	right.add_child(btn_load)
	var btn_delete := Button.new()
	btn_delete.name = "DeleteBtn"
	btn_delete.custom_minimum_size = Vector2(40, 22)
	btn_delete.add_theme_font_size_override("font_size", 8)
	btn_delete.text = "删"
	right.add_child(btn_delete)

	# 连信号
	btn_overwrite.pressed.connect(_on_overwrite.bind(slot_id))
	btn_load.pressed.connect(_on_load.bind(slot_id))
	btn_delete.pressed.connect(_on_delete.bind(slot_id))
	return panel

# T088 — list 视图：单行 + 摘要文本 + 单按钮（按 mode 切换）+ 删除小按钮
func _make_list_row(slot_id: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 28)
	panel.name = "Slot_%d" % slot_id
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.031, 0.071, 0.118, 0.85)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.412, 0.78, 0.808, 0.4)
	sb.content_margin_left = 6.0
	sb.content_margin_top = 2.0
	sb.content_margin_right = 6.0
	sb.content_margin_bottom = 2.0
	panel.add_theme_stylebox_override("panel", sb)

	var row_hbox := HBoxContainer.new()
	row_hbox.name = "RowHBox"
	row_hbox.add_theme_constant_override("separation", 6)
	panel.add_child(row_hbox)

	# Left: 单行 Label — slot 编号 + 摘要
	var left := Label.new()
	left.name = "TitleLbl"
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_font_size_override("font_size", 9)
	left.add_theme_color_override("font_color", Color(0.875, 0.835, 0.784, 1))
	left.clip_text = true
	left.max_lines_visible = 1
	row_hbox.add_child(left)

	# Right: 主按钮 + 删除小按钮
	var right := HBoxContainer.new()
	right.name = "RightHBox"
	right.add_theme_constant_override("separation", 4)
	row_hbox.add_child(right)
	var btn_overwrite := Button.new()
	btn_overwrite.name = "OverwriteBtn"
	btn_overwrite.custom_minimum_size = Vector2(50, 20)
	btn_overwrite.add_theme_font_size_override("font_size", 8)
	btn_overwrite.text = "保存"
	right.add_child(btn_overwrite)
	var btn_load := Button.new()
	btn_load.name = "LoadBtn"
	btn_load.custom_minimum_size = Vector2(50, 20)
	btn_load.add_theme_font_size_override("font_size", 8)
	btn_load.text = "读取"
	right.add_child(btn_load)
	var btn_delete := Button.new()
	btn_delete.name = "DeleteBtn"
	btn_delete.custom_minimum_size = Vector2(32, 20)
	btn_delete.add_theme_font_size_override("font_size", 8)
	btn_delete.text = "×"
	right.add_child(btn_delete)

	btn_overwrite.pressed.connect(_on_overwrite.bind(slot_id))
	btn_load.pressed.connect(_on_load.bind(slot_id))
	btn_delete.pressed.connect(_on_delete.bind(slot_id))
	return panel

func _refresh_slots() -> void:
	for i in range(_slot_panels.size()):
		var panel: PanelContainer = _slot_panels[i]
		if layout == "list":
			_refresh_list_row(panel, i)
		else:
			_refresh_card(panel, i)

func _refresh_card(panel: PanelContainer, i: int) -> void:
	var title_lbl: Label = panel.get_node("RowHBox/LeftVBox/TitleLbl")
	var summary_lbl: Label = panel.get_node("RowHBox/LeftVBox/SummaryLbl")
	var overwrite_btn: Button = panel.get_node("RowHBox/RightHBox/OverwriteBtn")
	var load_btn: Button = panel.get_node("RowHBox/RightHBox/LoadBtn")
	var delete_btn: Button = panel.get_node("RowHBox/RightHBox/DeleteBtn")
	if not SaveSystem.has_save(i):
		title_lbl.text = "槽位 %d  %s" % [i, EMPTY_TEXT]
		summary_lbl.text = "尚未记录任何回响"
		overwrite_btn.disabled = (mode != "save")
		overwrite_btn.text = "新建" if mode == "save" else "保存"
		load_btn.disabled = true
		delete_btn.disabled = true
	else:
		var info := SaveSystem.get_save_info(i)
		var unix := int(info.get("saved_at_unix", 0))
		var dt := Time.get_datetime_dict_from_unix_time(unix)
		var ts := "%02d-%02d %02d:%02d" % [dt["month"], dt["day"], dt["hour"], dt["minute"]]
		title_lbl.text = "槽位 %d  ✦ %s" % [i, ts]
		summary_lbl.text = SaveSystem.format_slot_summary(i)
		overwrite_btn.disabled = false
		overwrite_btn.text = "覆盖"
		load_btn.disabled = (mode != "select")
		delete_btn.disabled = false

# T088 — list 视图刷新：单行 Label 显示「[状态] 编号 | 时间 | 房间 | ♥/◆/✦」
func _refresh_list_row(panel: PanelContainer, i: int) -> void:
	var title_lbl: Label = panel.get_node("RowHBox/TitleLbl")
	var overwrite_btn: Button = panel.get_node("RowHBox/RightHBox/OverwriteBtn")
	var load_btn: Button = panel.get_node("RowHBox/RightHBox/LoadBtn")
	var delete_btn: Button = panel.get_node("RowHBox/RightHBox/DeleteBtn")
	if not SaveSystem.has_save(i):
		title_lbl.text = "[ %d ]  %s" % [i, EMPTY_TEXT]
		overwrite_btn.disabled = (mode != "save")
		overwrite_btn.text = "新建" if mode == "save" else "保存"
		load_btn.disabled = true
		delete_btn.disabled = true
	else:
		var info := SaveSystem.get_save_info(i)
		var unix := int(info.get("saved_at_unix", 0))
		var dt := Time.get_datetime_dict_from_unix_time(unix)
		var ts := "%02d-%02d %02d:%02d" % [dt["month"], dt["day"], dt["hour"], dt["minute"]]
		title_lbl.text = "[ %d ] ✦ %s  %s  ♥%d ◆%d ✦%d" % [
			i, ts, info.get("current_room", "?"),
			int(info.get("health", 0)), int(info.get("shards", 0)),
			int(info.get("achievements_unlocked", 0))
		]
		overwrite_btn.disabled = false
		overwrite_btn.text = "覆盖"
		load_btn.disabled = (mode != "select")
		delete_btn.disabled = false

func _on_toggle_layout() -> void:
	# T088: 切换 card ↔ list 视图
	layout = "list" if layout == "card" else "card"
	_build_slots()
	_refresh_slots()
	_refresh_layout_btn_text()
	layout_changed.emit(layout)

func _refresh_layout_btn_text() -> void:
	if _layout_btn == null:
		return
	_layout_btn.text = "列表视图" if layout == "card" else "卡片视图"

func _on_overwrite(slot_id: int) -> void:
	save_requested.emit(slot_id)

func _on_load(slot_id: int) -> void:
	load_requested.emit(slot_id)

func _on_delete(slot_id: int) -> void:
	delete_requested.emit(slot_id)

func _on_back() -> void:
	hide_menu()

# 公共：写入后刷新一次
func refresh() -> void:
	_refresh_slots()
