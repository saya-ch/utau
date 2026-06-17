class_name SaveLoadMenu
extends Control

## SaveLoadMenu — 存档/读档菜单（T088 升级 3→5 slots + 列表视图 / T105 房间进度时间线）
##
## 显示 5 个 slot 的状态（空/有数据），并提供 覆盖 / 读取 / 删除 操作。
## 提供两种布局：
##   - "card"  (默认) — 每行 44px 高，含标题/摘要 + 3 个按钮 (覆盖/读取/删除) + 4 档案房进度时间线
##   - "list"  (紧凑) — 每行 28px 高，单按钮单击即触发主要动作（按 mode 区分） + 4 档案房进度 unicode
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

# T129 — 存档健康度视觉标识（ok / legacy / corrupted / missing）
# 颜色严格遵循 STYLE_GUIDE：✓ ok = Glass Cyan / ⚠ legacy = Amber Voice /
# ✖ corrupted = Coral Pulse / 空 = 不显示。corrupted 槽位的 LoadBtn
# 强制 disabled（防读取崩溃；CRC32 mismatch 时 _read_json 返回空）。
const _INTEGRITY_OK_TEXT := "[color=#69C7CE]✓[/color]"
const _INTEGRITY_LEGACY_TEXT := "[color=#F2B66E]⚠[/color]"
const _INTEGRITY_CORRUPTED_TEXT := "[color=#E86D5A]✖[/color]"

# T105 — 4 个核心档案房进度时间线（顺序与玩家推进一致：01 → 02 → 03 → 04）
# 进度条 4 格分别对应 archive_01/02/03/04，已完成用 Amber Voice 实心，未完成用 Ink Navy + Glass Cyan 描边
const ARCHIVE_ROOMS := ["archive_01", "archive_02", "archive_03", "archive_04"]
# 颜色严格遵循 STYLE_GUIDE
const _COLOR_PROGRESS_FILLED := Color(0.949, 0.714, 0.431, 1.0)  # Amber Voice
const _COLOR_PROGRESS_EMPTY := Color(0.031, 0.071, 0.118, 1.0)   # Ink Navy
const _COLOR_PROGRESS_BORDER := Color(0.412, 0.78, 0.808, 0.7)   # Glass Cyan 1px 描边

@onready var _title_label: Label = $RootPanel/Margin/VBox/TitleLabel
@onready var _slot_container: VBoxContainer = $RootPanel/Margin/VBox/SlotContainer
@onready var _back_btn: Button = $RootPanel/Margin/VBox/BackButton
@onready var _hint_label: Label = $RootPanel/Margin/VBox/HintLabel
@onready var _layout_btn: Button = $RootPanel/Margin/VBox/LayoutButton  # T088: card/list 切换
@onready var _quick_load_btn: Button = $RootPanel/Margin/VBox/QuickLoadButton  # T137: 快速加载最近自动存档

var _slot_panels: Array = []  # N 个 slot 节点（card 或 list 行）

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	# 标题按 mode 切换文案
	if mode == "save":
		_title_label.text = "保存进度"
		_hint_label.text = "选择一个槽位写入或覆盖  ·  ✓ 完整  ⚠ 旧版  ✖ 已损坏"
	else:
		_title_label.text = "继续修复"
		_hint_label.text = "选择一个槽位继续你的旅程  ·  ✓ 完整  ⚠ 旧版  ✖ 已损坏"
	_back_btn.pressed.connect(_on_back)
	_layout_btn.pressed.connect(_on_toggle_layout)
	# T137 — 快速加载最近自动存档按钮。如果玩家在本会话内没有触发
	# 任何 auto-save（_last_autosave_unix == 0），按钮保持 hidden。
	# 仅在 mode == "select" 时显示（Title 屏读档用），PauseMenu 存档
	# 时不显示（"快速加载"在写档语境下无意义）。
	if _quick_load_btn:
		_quick_load_btn.pressed.connect(_on_quick_load)
		_refresh_quick_load_btn()
	_build_slots()
	_refresh_slots()
	_refresh_layout_btn_text()

# T137 — 根据 SaveSystem._last_autosave_unix 决定 QuickLoadButton 是否
# 显示 + 文本是否带时间戳。如果 SaveSystem autoload 不可用（test
# harness），保持 hidden（has_method 防御）。
func _refresh_quick_load_btn() -> void:
	if _quick_load_btn == null:
		return
	# 仅在 select mode（Title 读档）显示快速加载
	if mode != "select":
		_quick_load_btn.visible = false
		return
	if not (SaveSystem and SaveSystem.has_method("get_last_autosave_unix")):
		_quick_load_btn.visible = false
		return
	var last_unix: int = int(SaveSystem.get_last_autosave_unix())
	if last_unix <= 0:
		_quick_load_btn.visible = false
		return
	_quick_load_btn.visible = true
	# 格式化 HH:MM（与 _format_save_summary 风格一致）
	var dt := Time.get_datetime_dict_from_unix_time(last_unix)
	_quick_load_btn.text = "⚡ 快速加载最近自动存档  (%02d:%02d)" % [dt["hour"], dt["minute"]]

func _on_quick_load() -> void:
	# T137 — 玩家点击"快速加载"时直接走 SaveSystem.load_from_slot，
	# 复用已有 _on_load 路径（_on_load 内部已经处理 corrupt 检测 + 
	# emit load_requested → TitleScreen 走 continue_game_pressed）。
	if not (SaveSystem and SaveSystem.has_method("get_last_autosave_unix")):
		return
	var last_unix: int = int(SaveSystem.get_last_autosave_unix())
	if last_unix <= 0:
		return
	if not SaveSystem.has_method("get_autosave_slot"):
		return
	var slot: int = int(SaveSystem.get_autosave_slot())
	# Slot may have been overwritten or deleted between the time the
	# timestamp was set and the time the player pressed the button.
	# Re-check existence to avoid loading a stale "I autosaved to 0"
	# when slot 0 is now empty.
	if not SaveSystem.has_save(slot):
		_refresh_quick_load_btn()
		return
	# Reuse _on_load which emits load_requested and refreshes the list.
	_on_load(slot)

func show_menu() -> void:
	# T137 — 重新计算 QuickLoadButton 可见性 + 时间戳。玩家可能在
	# PauseMenu 期间 auto-save 了几次，回到 SaveLoadMenu 时按钮应
	# 反映最新时间戳。
	_refresh_quick_load_btn()
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
	panel.custom_minimum_size = Vector2(0, 56)  # T105: 44→56 容纳 4 格进度时间线
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

	# Left: VBox of title + summary + progress timeline
	var left := VBoxContainer.new()
	left.name = "LeftVBox"
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 1)
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
	# T105 — 4 格房间进度时间线 (4 archive rooms 4 mini ColorRects)
	var progress_row := HBoxContainer.new()
	progress_row.name = "ProgressRow"
	progress_row.add_theme_constant_override("separation", 2)
	left.add_child(progress_row)
	for i in range(ARCHIVE_ROOMS.size()):
		var cell := _make_progress_cell(i)
		progress_row.add_child(cell)

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
	left.bbcode_enabled = true  # T105: 让 _format_progress_inline 的 [color=…]BBCode 生效
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
	# T151 (#79) — 找最近一次写入的存档槽位（max saved_at_unix）。
	# 一次刷新里所有 5 行共用同一个"最近"判定；不重复扫描。
	# 没有任何存档时 most_recent_slot = -1，调用方跳过 badge。
	var most_recent_slot: int = _find_most_recent_slot()
	for i in range(_slot_panels.size()):
		var panel: PanelContainer = _slot_panels[i]
		if layout == "list":
			_refresh_list_row(panel, i, most_recent_slot)
		else:
			_refresh_card(panel, i, most_recent_slot)

# T151 (#79) — 找出 saved_at_unix 最大的槽位。空槽位被跳过。
# 若所有槽位都空（首次启动），返回 -1。所有 5 槽都有数据时
# 返回 max；并列时取第一个命中（slot 0 优先于 slot 4）。
func _find_most_recent_slot() -> int:
	var best_slot: int = -1
	var best_unix: int = 0
	for i in range(SaveSystem.SLOT_COUNT):
		if not SaveSystem.has_save(i):
			continue
		var info := SaveSystem.get_save_info(i)
		var unix := int(info.get("saved_at_unix", 0))
		if unix > best_unix:
			best_unix = unix
			best_slot = i
	return best_slot

# T151 (#79) — 格式化"最近"标识符。BBCode 形式：[color=#B7E6DC]★
# 最近[/color] （Pale Resonance 8pt 强调），用于标题末尾追加。
# slot_id 不等于 most_recent_slot → 返回空字符串（不显示）。
# 这是"T151 [候选] Polish RunHistoryList 为每行加 '—' 与
# '最近' 状态码" 的 subset：候选原始列了 4 个状态字符
# ([·]/[—]/[✓]/[✗])，本轮只取「最近」一档。其他 3 档
# ([·]=[已用] 已隐含 / [—]=[空] 通过 empty_text 显示 /
# [✗]=[损坏] T129 已有 ✖ badge)，本轮加的"最近"是
# 第 4 维（"时间维最近"）— 视觉组"4 维状态"完整化。
func _format_recent_badge(slot_id: int, most_recent_slot: int) -> String:
	if slot_id != most_recent_slot:
		return ""
	return "[color=#B7E6DC]★ 最近[/color]"

# T129 — 返回存档健康度标识符（BBCode 形式）+ 完整状态字符串
# 用于 _refresh_card / _refresh_list_row 末尾，视觉组与 STYLE_GUIDE
# 一致（Glass Cyan ✓ / Amber Voice ⚠ / Coral Pulse ✖）。空槽返回
# 空字符串，调用方决定是否显示。
func _format_integrity_badge(integrity: String) -> String:
	match integrity:
		"ok": return _INTEGRITY_OK_TEXT
		"legacy": return _INTEGRITY_LEGACY_TEXT
		"corrupted": return _INTEGRITY_CORRUPTED_TEXT
		_: return ""

# T105 — 4 档案房进度时间线的单个 cell：14x6 PanelContainer + StyleBoxFlat 1px 描边
# 已完成用 Amber Voice 实心，未完成用 Ink Navy 空心（border 始终显示玻璃青）
func _make_progress_cell(index: int) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.name = "Cell_%d" % index
	cell.custom_minimum_size = Vector2(14, 6)
	cell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	# 默认空心；_apply_progress 时按 rooms_completed 切换
	var sb := StyleBoxFlat.new()
	sb.bg_color = _COLOR_PROGRESS_EMPTY
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = _COLOR_PROGRESS_BORDER
	cell.add_theme_stylebox_override("panel", sb)
	# 保存 stylebox 引用供 _apply_progress 切换填充色
	cell.set_meta("stylebox", sb)
	cell.set_meta("empty_color", _COLOR_PROGRESS_EMPTY)
	cell.set_meta("filled_color", _COLOR_PROGRESS_FILLED)
	return cell

# T105 — 根据 rooms_completed 列表点亮对应 cell
func _apply_progress(panel: PanelContainer, rooms_completed: Array) -> void:
	var row := panel.get_node_or_null("RowHBox/LeftVBox/ProgressRow")
	if row == null:
		# list 视图没有 ProgressRow，由 _refresh_list_row 内联处理
		return
	for i in range(ARCHIVE_ROOMS.size()):
		var cell_name := "Cell_%d" % i
		var cell = row.get_node_or_null(cell_name)
		if cell == null:
			continue
		var filled: bool = rooms_completed.has(ARCHIVE_ROOMS[i])
		var sb: StyleBoxFlat = cell.get_meta("stylebox")
		sb.bg_color = (_COLOR_PROGRESS_FILLED if filled else _COLOR_PROGRESS_EMPTY)

# T105 — list 视图内联进度符号：[■][■][□][□] 形式（filled=■ amber / empty=□ 灰）
# 用 unicode 方块字符而非图片，节省行高
func _format_progress_inline(rooms_completed: Array) -> String:
	var parts: Array = []
	for i in range(ARCHIVE_ROOMS.size()):
		if rooms_completed.has(ARCHIVE_ROOMS[i]):
			parts.append("[color=#F2B66E]■[/color]")  # Amber Voice 实心
		else:
			parts.append("[color=#12334A]□[/color]")  # Archive Blue 空心
	return "".join(parts)

func _refresh_card(panel: PanelContainer, i: int, most_recent_slot: int = -1) -> void:
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
		_apply_progress(panel, [])  # T105: 空存档 → 4 格全空
	else:
		var info := SaveSystem.get_save_info(i)
		var unix := int(info.get("saved_at_unix", 0))
		var dt := Time.get_datetime_dict_from_unix_time(unix)
		var ts := "%02d-%02d %02d:%02d" % [dt["month"], dt["day"], dt["hour"], dt["minute"]]
		# T129 — 标题末尾追加存档健康度标识符（✓/⚠/✖）
		var integrity := SaveSystem.get_save_integrity(i)
		var badge := _format_integrity_badge(integrity)
		# T151 (#79) — "最近" 标识符放在 integrity badge 后面；
		# 视觉组：health (健康度) + recency (时间最近) 两维
		# 信息并列，标题结构 "[槽位] ✦ ts  [health] [recent]"。
		var recent_badge := _format_recent_badge(i, most_recent_slot)
		title_lbl.bbcode_enabled = true
		title_lbl.text = "槽位 %d  ✦ %s  %s%s" % [i, ts, badge, recent_badge]
		summary_lbl.text = SaveSystem.format_slot_summary(i)
		overwrite_btn.disabled = false
		overwrite_btn.text = "覆盖"
		# T129 — corrupted 存档的 LoadBtn 强制 disabled（防读取崩溃；
		# _read_json 会因 CRC32 mismatch 返回空 dict）
		load_btn.disabled = (mode != "select") or (integrity == "corrupted")
		delete_btn.disabled = false
		_apply_progress(panel, SaveSystem.get_save_rooms_completed(i))  # T105

# T088 — list 视图刷新：单行 Label 显示「[状态] 编号 | 时间 | 房间 | ♥/◆/✦ | 进度■□□□」
func _refresh_list_row(panel: PanelContainer, i: int, most_recent_slot: int = -1) -> void:
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
		# T105 — 末尾追加 4 格进度时间线（unicode BBCode 形式，label 需 bbcode_enabled）
		var progress_str := _format_progress_inline(SaveSystem.get_save_rooms_completed(i))
		# T129 — 标题头部追加存档健康度标识符（✓/⚠/✖）
		var integrity := SaveSystem.get_save_integrity(i)
		var badge := _format_integrity_badge(integrity)
		# T151 (#79) — "最近" badge 紧跟 integrity badge。list 视图
		# 信息密度高，badge 在开头而非末尾；让"最近"在长串数字中先入眼。
		var recent_badge := _format_recent_badge(i, most_recent_slot)
		title_lbl.bbcode_enabled = true
		title_lbl.text = "%s%s[ %d ] ✦ %s  %s  ♥%d ◆%d ✦%d  %s" % [
			badge, recent_badge, i, ts, info.get("current_room", "?"),
			int(info.get("health", 0)), int(info.get("shards", 0)),
			int(info.get("achievements_unlocked", 0)),
			progress_str
		]
		overwrite_btn.disabled = false
		overwrite_btn.text = "覆盖"
		# T129 — corrupted 存档的 LoadBtn 强制 disabled
		load_btn.disabled = (mode != "select") or (integrity == "corrupted")
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
	# T153 (#79) — 槽位 jingle 反馈。覆盖存档是"写下去"的语义
	# 信号，按 slot_id 播放对应 C5/E5/G5/C6/E6 短 bell 音，让玩家
	# 听到"我把数据写在第 N 槽"。SaveLoadMenu 是 autoload-scoped
	# 的 AudioManagerEnhanced 客户端，方法名走完整路径避免
	# 命名空间歧义（_on_save_load_saved 也会调用 save_requested，
	# 不会重复触发 jingle —— 见 _on_save_load_saved 注释）。
	if _has_audio_manager():
		AudioManagerEnhanced.play_save_slot_jingle(slot_id)
	save_requested.emit(slot_id)

func _on_load(slot_id: int) -> void:
	# T153 (#79) — load 与 overwrite 共享 jingle：槽位 jingle 是
	# "选择哪个槽位"的反馈，与 save/load 方向无关。同 slot_id 同
	# 音，听到就知道"载入的是第 N 槽"。
	if _has_audio_manager():
		AudioManagerEnhanced.play_save_slot_jingle(slot_id)
	load_requested.emit(slot_id)

func _on_delete(slot_id: int) -> void:
	# F015 (#103) — SaveSlot confirm click: 0.20s 双脉冲高
	# 频 click 反馈"我点了删除"。区别于 save_slot_jingle
	# (选择哪个槽位) 和 shop purchase chord (购买奖励)：
	# confirm click 表达"小操作已 commit"的语义。
	# 守卫式 has_method 保证 headless 测试或旧版 AME 不会
	# crash。prewarm_save_slot_confirm 在 Title/Hub/GFC
	# _ready 阶段已就绪，正常 play 0 合成延迟。
	if _has_audio_manager() \
			and AudioManagerEnhanced.has_method("play_save_slot_confirm"):
		AudioManagerEnhanced.play_save_slot_confirm()
	delete_requested.emit(slot_id)

func _on_back() -> void:
	hide_menu()

# T153 (#79) — 检查 AudioManagerEnhanced autoload 是否存在。
# 单元测试或 headless 环境可能没注册 autoload，guard 防止
# null deref。autoload 名 = audio_manager_enhanced.tscn 中
# 节点名 (T062 引入)。使用 Engine.has_singleton（autoload 在
# Godot 中是 singleton）。
func _has_audio_manager() -> bool:
	return Engine.has_singleton("AudioManagerEnhanced") \
		or (Engine.get_main_loop() \
			and Engine.get_main_loop().root.has_node("/root/AudioManagerEnhanced"))

# 公共：写入后刷新一次
func refresh() -> void:
	_refresh_slots()
