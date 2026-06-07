class_name PauseMenu
extends Control

signal resume_pressed
signal restart_pressed
signal quit_to_title_pressed
signal settings_pressed
signal save_requested(slot_id: int)  # T070 — PauseMenu → GFC

@onready var _resume_btn: Button = $VBoxContainer/ResumeButton
@onready var _save_btn: Button = $VBoxContainer/SaveButton
@onready var _profile_btn: Button = $VBoxContainer/ProfileButton  # T126
@onready var _settings_btn: Button = $VBoxContainer/SettingsButton
@onready var _restart_btn: Button = $VBoxContainer/RestartButton
@onready var _quit_btn: Button = $VBoxContainer/QuitToTitleButton
@onready var _save_load_menu: SaveLoadMenu = $SaveLoadMenu

# Statistics panel nodes
@onready var _stats_panel: PanelContainer = $StatsPanel
@onready var _achv_progress: Label = $StatsPanel/StatsMargin/StatsVBox/AchvProgress
@onready var _stat_rooms: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatRoomsCleared
@onready var _stat_enemies: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatEnemiesPurified
@onready var _stat_shards: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatShards
@onready var _stat_deaths: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatDeaths
@onready var _stat_abilities: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatAbilities
@onready var _stat_cuts: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatCuts
@onready var _stat_reflects: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatReflects
@onready var _stat_lanterns: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatLanterns
@onready var _stat_time: Label = $StatsPanel/StatsMargin/StatsVBox/StatTime
@onready var _achv_grid: HBoxContainer = $StatsPanel/StatsMargin/StatsVBox/AchvGrid
@onready var _latest_unlock: Label = $StatsPanel/StatsMargin/StatsVBox/LatestUnlock

# T126 — Player Profile panel nodes (full-screen modal with detailed stats + achievement list)
@onready var _profile_panel: PanelContainer = $PlayerProfilePanel
@onready var _profile_time: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTime
@onready var _profile_deaths: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileDeaths
@onready var _profile_rooms: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRooms
@onready var _profile_abilities: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAbilities
@onready var _profile_shards: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileShards
@onready var _profile_reflects: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileReflects
@onready var _profile_achv_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAchvScroll/ProfileAchvList
@onready var _profile_close_btn: Button = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileCloseButton

const ICON_PATH_BASE := "res://assets/ui/achievements"
const ICON_DEFAULT := "amber_dot"

var _is_paused: bool = false
var _profile_open: bool = false  # T126 — track panel state

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

	_resume_btn.pressed.connect(_on_resume)
	_save_btn.pressed.connect(_on_save)
	_profile_btn.pressed.connect(_on_profile)  # T126
	_settings_btn.pressed.connect(_on_settings)
	_restart_btn.pressed.connect(_on_restart)
	_quit_btn.pressed.connect(_on_quit_to_title)

	# T070 — SaveLoadMenu signal wiring (mode = save, so only save/delete)
	_save_load_menu.save_requested.connect(_on_save_load_saved)
	_save_load_menu.delete_requested.connect(_on_save_load_deleted)
	_save_load_menu.load_requested.connect(_on_save_load_loaded)  # defensive

	# T126 — Profile panel close button
	_profile_close_btn.pressed.connect(_on_profile_close)

	_build_achievement_grid()
	_build_profile_achievement_list()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	_is_paused = not _is_paused
	get_tree().paused = _is_paused
	visible = _is_paused

	if _is_paused:
		# If a SaveLoadMenu is somehow already open from previous state, close it
		if _save_load_menu.visible:
			_save_load_menu.hide_menu()
		# T126 — make sure profile panel is closed when re-opening pause
		if _profile_open:
			_on_profile_close()
		modulate = Color.TRANSPARENT
		_refresh_stats()
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func _refresh_stats() -> void:
	_achv_progress.text = "成就: %d/%d" % [PlayerStats.get_unlocked_count(), PlayerStats.get_total_count()]
	_stat_rooms.text = "完成房间  %d" % PlayerStats.rooms_cleared
	_stat_enemies.text = "净化敌人  %d" % PlayerStats.enemies_purified
	_stat_shards.text = "收集碎片  %d" % PlayerStats.shards_collected
	_stat_deaths.text = "共鸣消散  %d" % PlayerStats.deaths
	# T102 — 四动词 row 颜色对齐：每个动词用 STYLE_GUIDE 色域 HEX
	# BBCode 包裹 — Pulse = Coral Pulse #E86D5A / Bind = Muted Violet
	# #65506A / Cut = Amber Voice #F2B66E / Echo = Glass Cyan #69C7CE。
	# 数字也跟着动词上色，让"用得越多 = 颜色越跳"成为可读统计。
	# bbcode_enabled 在 pause_menu.tscn 节点上预设；分隔符 " · " 仍
	# 用默认暖白 (0.875, 0.835, 0.784) 作为「中性框架」，4 动词色
	# 块在视觉组里跳出来。视觉组层面：四动词色域贯穿 5 处（HUD 4
	# 冷却条 + 屏幕命中闪 + PauseMenu 4 动词行 + 商店 echo_charm +
	# 成就图标 A025/A033/A038/A061），1px 8pt 小字也能分辨。
	_stat_abilities.text = "[color=#E86D5A]Pulse %d[/color]  ·  [color=#65506A]Bind %d[/color]  ·  [color=#F2B66E]Cut %d[/color]  ·  [color=#69C7CE]Echo %d[/color]" % [
		PlayerStats.pulse_used, PlayerStats.bind_used,
		PlayerStats.cut_used, PlayerStats.echo_used
	]
	_stat_cuts.text = "斩断腐蚀  %d" % PlayerStats.silence_webs_cut
	# T096 — Echo reflect count lives on its own stat (echo_reflects) so
	# the player can see how many enemy projectiles they bounced back. The
	# number is purely informational — it's not used to unlock anything
	# today, but the stat hook is already wired in EchoAbility._reflect_projectile
	# via PlayerStats.record_echo_reflect().  Future "reflect N projectiles"
	# achievement can use the same field without re-plumbing.
	_stat_reflects.text = "Echo 反弹  %d" % PlayerStats.echo_reflects
	# T100 — Echo 反弹行用 Glass Cyan (#69C7CE) 高亮，与 _stat_time 同色。
	# 视觉组层面：「Echo = Glass Cyan」贯穿整游戏（HUD EchoCooldown / 反弹
	# flash / 暂停统计行）。其他行保留暖白 (0.875, 0.835, 0.784) 让 Echo
	# 反弹在统计面板里跳出来，引导玩家关注「反弹成就」信号。
	_stat_reflects.add_theme_color_override("font_color", Color(0.412, 0.78, 0.808, 1.0))
	_stat_lanterns.text = "存档灯笼  %d" % PlayerStats.save_lanterns_activated
	var t := int(PlayerStats.get_run_time_seconds())
	var m := t / 60
	var s := t % 60
	_stat_time.text = "回响时长  %02d:%02d" % [m, s]
	# T109 — 最近解锁行：取解锁时间戳最大的成就 + 时间。
	# 未解锁时显示 "—" 占位（与 tooltip 一致）。
	var sorted_unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	if sorted_unlocked.is_empty():
		_latest_unlock.text = "最近解锁：—"
	else:
		var latest: Array = sorted_unlocked[sorted_unlocked.size() - 1]
		var latest_title: String = latest[1]
		var latest_ts: int = int(latest[3])
		var ts_str := "—"
		if latest_ts > 0:
			var dt := Time.get_datetime_dict_from_unix_time(latest_ts)
			ts_str = "%02d-%02d %02d:%02d" % [dt.month, dt.day, dt.hour, dt.minute]
		_latest_unlock.text = "最近解锁：%s  %s" % [latest_title, ts_str]
	_refresh_achievement_grid()

# === 成就图标网格 ===

func _build_achievement_grid() -> void:
	# T109 — 按解锁时间排序：先建所有节点，最后按解锁时间戳
	# 重排顺序（早解锁靠左 → 晚解锁靠右）。未解锁的成就保留
	# 在末尾，按 id 字母序保持稳定。
	var all: Array = PlayerStats.get_all_achievements()
	var unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	var unlocked_ids: Array = []
	for row in unlocked:
		unlocked_ids.append(row[0])
	var locked: Array = []
	for ach in all:
		var id_val: String = ach.get("id", "")
		if id_val == "":
			continue
		if not unlocked_ids.has(id_val):
			locked.append(ach)
	locked.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	var ordered: Array = unlocked.duplicate()  # [id, title, desc, ts]
	for ach in locked:
		ordered.append([ach.get("id", ""), ach.get("title_zh", ach.get("id", "")), ach.get("description_zh", ""), 0])

	# Create a TextureRect for each achievement, in time-sorted order
	for row in ordered:
		var id_val: String = row[0]
		var title_zh: String = row[1]
		var desc_zh: String = row[2]
		var ts: int = int(row[3])
		# Find the original definition to get the icon_hint
		var hint: String = ICON_DEFAULT
		for ach in all:
			if ach.get("id", "") == id_val:
				hint = ach.get("icon_hint", ICON_DEFAULT)
				break
		var tex := _load_icon_texture(hint)
		var slot := TextureRect.new()
		slot.custom_minimum_size = Vector2(16, 16)
		slot.texture = tex
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# T109 — tooltip 加解锁时间："解锁于 MM-DD HH:MM"（未解锁显示 "-"）
		var ts_str := "—"
		if ts > 0:
			var dt := Time.get_datetime_dict_from_unix_time(ts)
			ts_str = "%02d-%02d %02d:%02d" % [dt.month, dt.day, dt.hour, dt.minute]
		slot.tooltip_text = "%s  %s\n解锁于 %s" % [title_zh, desc_zh, ts_str]
		slot.name = "AchvSlot_" + id_val
		# T111 — hover 高亮支持：mouse_filter STOP + mouse_entered / mouse_exited signal。
		# TextureRect 默认 mouse_filter = IGNORE，hover 不会触发。设为 STOP 让 Control
		# 接收鼠标进入/离开事件。_on_slot_hover_in / _on_slot_hover_out 做放大 1.5x +
		# 暖色边框 tween，过渡 0.12s。
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.mouse_entered.connect(_on_slot_hover_in.bind(slot))
		slot.mouse_exited.connect(_on_slot_hover_out.bind(slot))
		_achv_grid.add_child(slot)

func _on_slot_hover_in(slot: TextureRect) -> void:
	# T111 — 放大 1.5x (16→24) + Pale Resonance 高亮 + 1px Amber Voice 暖边描边
	# (用 modulate.a 0.95 + self_modulate 实现「亮起来」效果，原 modulate 控制解锁
	# 灰阶)。tween 0.12s quad-ease-out 让过渡丝滑不突兀。
	if not is_instance_valid(slot):
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slot, "scale", Vector2(1.5, 1.5), 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot, "self_modulate", Color(1.4, 1.4, 1.4, 1.0), 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(slot, "modulate", Color(1.2, 1.1, 0.9, 1.0), 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_slot_hover_out(slot: TextureRect) -> void:
	# T111 — 恢复：根据解锁状态回写 modulate / self_modulate
	if not is_instance_valid(slot):
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 恢复逻辑：未解锁用淡灰调 (0.25, 0.25, 0.3, 0.5)，已解锁用纯白
	var id_val: String = slot.name.substr(9)  # strip "AchvSlot_"
	if PlayerStats.is_unlocked(id_val):
		tween.tween_property(slot, "self_modulate", Color.WHITE, 0.12)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(slot, "modulate", Color.WHITE, 0.12)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(slot, "self_modulate", Color(0.25, 0.25, 0.3, 0.5), 0.12)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(slot, "modulate", Color(0.25, 0.25, 0.3, 0.5), 0.12)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _refresh_achievement_grid() -> void:
	for child in _achv_grid.get_children():
		if not child.name.begins_with("AchvSlot_"):
			continue
		var id_val: String = child.name.substr(9)  # strip "AchvSlot_"
		if PlayerStats.is_unlocked(id_val):
			child.modulate = Color.WHITE
			child.self_modulate = Color.WHITE
		else:
			child.modulate = Color(0.25, 0.25, 0.3, 0.5)
			child.self_modulate = Color(0.25, 0.25, 0.3, 0.5)

func _load_icon_texture(icon_hint: String) -> Texture2D:
	var path := "%s/%s/%s.png" % [ICON_PATH_BASE, icon_hint, icon_hint]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

func _on_resume() -> void:
	toggle_pause()
	resume_pressed.emit()

func _on_save() -> void:
	# T070 — open SaveLoadMenu in save-mode (write only).
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
		return
	_save_load_menu.mode = "save"
	_save_load_menu.refresh()
	_save_load_menu.show_menu()

func _on_save_load_saved(slot_id: int) -> void:
	# SaveSystem writes the snapshot; GFC shows a brief toast.
	# We forward the slot id up via save_requested signal so GFC can
	# call SaveSystem.save_to_slot() and show the HUD hint.
	save_requested.emit(slot_id)
	_save_load_menu.refresh()  # refresh so overwrite button text updates

func _on_save_load_deleted(slot_id: int) -> void:
	SaveSystem.delete_slot(slot_id)
	_save_load_menu.refresh()

func _on_save_load_loaded(_slot_id: int) -> void:
	# PauseMenu's SaveLoadMenu is in save mode, load button is disabled.
	# Defensive: just close the menu if a load was somehow triggered.
	_save_load_menu.hide_menu()

func _on_settings() -> void:
	settings_pressed.emit()

func _on_restart() -> void:
	# Close SaveLoadMenu before quitting
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
	get_tree().paused = false
	_is_paused = false
	restart_pressed.emit()

func _on_quit_to_title() -> void:
	# Close SaveLoadMenu before quitting
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
	get_tree().paused = false
	_is_paused = false
	quit_to_title_pressed.emit()

# === T126 — Player Profile page ===
#
# Modal panel opened via the new "玩家档案" button (or any equivalent
# entry point).  Showcased data: player name (placeholder), run time,
# room count, death count, shard count, 4-verb colorized usage, and a
# scrollable list of all 8+ achievements with full text + unlock time.
# The panel is independent of the small StatsPanel sidebar so the
# sidebar remains a glanceable summary.

func _on_profile() -> void:
	# Toggle the profile panel; if it's already open, just close.
	if _profile_open:
		_on_profile_close()
		return
	# Close SaveLoadMenu if it's open (no two modals at once).
	if _save_load_menu.visible:
		_save_load_menu.hide_menu()
	_refresh_profile()
	_profile_panel.visible = true
	_profile_open = true

func _on_profile_close() -> void:
	_profile_panel.visible = false
	_profile_open = false

func _refresh_profile() -> void:
	var t := int(PlayerStats.get_run_time_seconds())
	var m := t / 60
	var s := t % 60
	_profile_time.text = "回响时长  %02d:%02d" % [m, s]
	_profile_deaths.text = "共鸣消散  %d" % PlayerStats.deaths
	_profile_rooms.text = "完成房间  %d" % PlayerStats.rooms_cleared
	# T102 — 四动词 BBCode 颜色主题化（与 _stat_abilities 一致）
	_profile_abilities.text = "[color=#E86D5A]Pulse %d[/color]  ·  [color=#65506A]Bind %d[/color]  ·  [color=#F2B66E]Cut %d[/color]  ·  [color=#69C7CE]Echo %d[/color]" % [
		PlayerStats.pulse_used, PlayerStats.bind_used,
		PlayerStats.cut_used, PlayerStats.echo_used
	]
	_profile_shards.text = "收集碎片  %d" % PlayerStats.shards_collected
	_profile_reflects.text = "Echo 反弹  %d" % PlayerStats.echo_reflects
	# Refresh achievement list state (new unlocks may have changed).
	_refresh_profile_achievement_list()

func _build_profile_achievement_list() -> void:
	# Build a full-text list of all achievements: 32x32 icon + title +
	# description + unlock time (or "未解锁" placeholder).  Same data
	# source as the sidebar's AchvGrid but in a more readable form.
	var sorted_unlocked: Array = PlayerStats.get_unlocked_achievements_sorted_by_time()
	var unlocked_ids: Array = []
	for row in sorted_unlocked:
		unlocked_ids.append(row[0])
	# T109 — sort unlocked by time, locked by id (stable order)
	var all: Array = PlayerStats.get_all_achievements()
	var locked: Array = []
	for ach in all:
		var id_val: String = ach.get("id", "")
		if id_val == "":
			continue
		if not unlocked_ids.has(id_val):
			locked.append(ach)
	locked.sort_custom(func(a, b): return str(a.get("id", "")) < str(b.get("id", "")))
	# Build display rows
	for row in sorted_unlocked:
		_add_profile_achv_row(row[0], row[1], row[2], int(row[3]), true)
	for ach in locked:
		var id_val: String = ach.get("id", "")
		var title_zh: String = ach.get("title_zh", id_val)
		var desc_zh: String = ach.get("description_zh", "")
		_add_profile_achv_row(id_val, title_zh, desc_zh, 0, false)

func _add_profile_achv_row(id_val: String, title_zh: String, desc_zh: String, ts: int, is_unlocked: bool) -> void:
	var hint: String = ICON_DEFAULT
	for ach in PlayerStats.get_all_achievements():
		if ach.get("id", "") == id_val:
			hint = ach.get("icon_hint", ICON_DEFAULT)
			break
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 16)
	row.name = "ProfileAchv_" + id_val
	# Icon (32x32 — same source as 16x16, but 2x scale)
	var tex := _load_icon_texture(hint)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(16, 16)
	icon.texture = tex
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if not is_unlocked:
		icon.modulate = Color(0.25, 0.25, 0.3, 0.5)
		icon.self_modulate = Color(0.25, 0.25, 0.3, 0.5)
	row.add_child(icon)
	# Text column
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title_lbl := Label.new()
	title_lbl.text = title_zh
	title_lbl.add_theme_font_size_override("font_size", 8)
	if is_unlocked:
		title_lbl.add_theme_color_override("font_color", Color(0.949, 0.714, 0.431, 1))  # Amber Voice
	else:
		title_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55, 1))  # greyed out
	text_col.add_child(title_lbl)
	var desc_lbl := Label.new()
	desc_lbl.text = desc_zh
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_color_override("font_color", Color(0.718, 0.906, 0.867, 1))  # Pale Resonance
	text_col.add_child(desc_lbl)
	row.add_child(text_col)
	# Time column
	var time_lbl := Label.new()
	if is_unlocked and ts > 0:
		var dt := Time.get_datetime_dict_from_unix_time(ts)
		time_lbl.text = "%02d-%02d %02d:%02d" % [dt.month, dt.day, dt.hour, dt.minute]
	else:
		time_lbl.text = "—"
	time_lbl.add_theme_font_size_override("font_size", 7)
	time_lbl.add_theme_color_override("font_color", Color(0.875, 0.835, 0.784, 1))
	row.add_child(time_lbl)
	_profile_achv_list.add_child(row)

func _refresh_profile_achievement_list() -> void:
	# Clear and rebuild.  Cheap: <20 rows, no expensive work.  Triggered
	# when the player opens the panel (potentially after a fresh unlock).
	for child in _profile_achv_list.get_children():
		child.queue_free()
	_build_profile_achievement_list()
