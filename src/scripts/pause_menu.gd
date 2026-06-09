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
# T150 — 上次使用的 verb 行（5 动词 BBCode 调色板）。
@onready var _profile_last_verb: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileLastVerb
# T127 — Run 编号 + 历史最佳 4 行
@onready var _profile_run: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRun
# T133 — Quick Stats 摘要行（一行总览：成就进度 + 最佳单局 + Run #）
@onready var _profile_quick_stats: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileQuickStats
# T135 — Share button.  Click → copy the Quick Stats line
# (achievements + best time + run # + date) to the system
# clipboard via DisplayServer.clipboard_set().  Feedback
# flips the label to "已复制 ✓" for 1.5s then restores.
@onready var _profile_share_btn: Button = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileShareButton
# T138 — 上次自动存档时间戳。每次 PauseMenu 打开时刷新；auto-save
# 期间可能多次更新，所以显示 HH:MM:SS（与 SaveLoadMenu 的 HH:MM
# 区分，因为 PauseMenu 是在 session 内高频查看，秒级精度更有用）。
@onready var _profile_auto_save: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAutoSave
@onready var _profile_best_time: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestTime
@onready var _profile_best_rooms: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestRooms
@onready var _profile_best_shards: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestShards
@onready var _profile_best_enemies: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestEnemies
# T131 — 近 N 局平均（5/10/20 三档）趋势行
@onready var _profile_trend5: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTrend5
@onready var _profile_trend10: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTrend10
@onready var _profile_trend20: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileTrend20
@onready var _profile_achv_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAchvScroll/ProfileAchvList
@onready var _profile_close_btn: Button = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileCloseButton

const ICON_PATH_BASE := "res://assets/ui/achievements"
const ICON_DEFAULT := "amber_dot"

# T152 (#79) — 0 数灰阶占位色。在 _refresh_stats() / _refresh_profile()
# 末尾的 stat 数字 0 时，把 Label 的 font_color 设为这个暖灰
# (0.5, 0.5, 0.55, 1)，让"未使用"状态在视觉组里"灰掉"，与
# 已有数字（暖白 0.875, 0.835, 0.784）形成对比。Echo 反弹行
# (T100 Glass Cyan) 也会被灰掉——保留"刚刚开始"的语义一致性：
# 数据存在但还没使用，就不抢眼。
# 不应用到 5 动词 BBCode 行（颜色 token 自身就是 verb 身份，
# 灰掉会切断"5 动词色域贯穿表层"的设计）。也不应用到时间字段
# (回响时长)——0:00 是合法的"刚开始"状态，与"已死 0 次"语义
# 不同。回响时长始终以暖白显示。
const _COLOR_ZERO_STAT := Color(0.5, 0.5, 0.55, 1.0)

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
	# T135 — share-to-clipboard button.  Idempotent: pressing
	# repeatedly just rewrites the clipboard with the same
	# text and refreshes the "已复制 ✓" feedback timer.
	_profile_share_btn.pressed.connect(_on_share_pressed)

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
	# T152 (#79) — 0 数灰阶占位：值 0 → 文本 "—" + 暖灰；
	# 值 > 0 → 暖白 + 数字。当前 run 状态行用 _set_zero_aware_stat
	# 统一处理 rooms/enemies/shards/deaths/cuts/reflects/lanterns。
	_set_zero_aware_stat(_stat_rooms, PlayerStats.rooms_cleared, "完成房间  %d")
	_set_zero_aware_stat(_stat_enemies, PlayerStats.enemies_purified, "净化敌人  %d")
	_set_zero_aware_stat(_stat_shards, PlayerStats.shards_collected, "收集碎片  %d")
	_set_zero_aware_stat(_stat_deaths, PlayerStats.deaths, "共鸣消散  %d")
	# T102/T103 — 五动词 row 颜色对齐：每个动词用 STYLE_GUIDE 色域 HEX
	# BBCode 包裹 — Pulse = Coral Pulse #E86D5A / Bind = Muted Violet
	# #65506A / Cut = Amber Voice #F2B66E / Echo = Glass Cyan #69C7CE /
	# Wave = Pale Resonance #B7E6DC（#74 轮新加第五动词，与
	# resonance_wave_ability.gd 主色一致；冷色+1 颜色饱和度=5 动词中
	# 最"光波"的暖冷梯度末端）。
	# 数字也跟着动词上色，让"用得越多 = 颜色越跳"成为可读统计。
	# bbcode_enabled 在 pause_menu.tscn 节点上预设；分隔符 " · " 仍
	# 用默认暖白 (0.875, 0.835, 0.784) 作为「中性框架」，5 动词色
	# 块在视觉组里跳出来。视觉组层面：5 动词色域贯穿 6 处（HUD 5
	# 冷却条 + 屏幕命中闪 + PauseMenu 5 动词行 + 商店 echo_charm +
	# 成就图标 A025/A033/A038/A061 + 新增 A066 quintuple_voice），
	# 1px 8pt 小字也能分辨。
	_stat_abilities.text = "[color=#E86D5A]Pulse %d[/color]  ·  [color=#65506A]Bind %d[/color]  ·  [color=#F2B66E]Cut %d[/color]  ·  [color=#69C7CE]Echo %d[/color]  ·  [color=#B7E6DC]Wave %d[/color]" % [
		PlayerStats.pulse_used, PlayerStats.bind_used,
		PlayerStats.cut_used, PlayerStats.echo_used,
		PlayerStats.wave_used
	]
	# T152 (#79) — 斩断腐蚀 / Echo 反弹 / 存档灯笼 同样 0 数灰阶。
	# Echo 反弹原本带 Glass Cyan 调色 (T100) —— >0 时还原回 cyan，
	# 0 时按规则"灰掉" (灰阶 + "—" 占位)。色彩与"刚刚开始"的语
	# 义一致：数据存在但还没使用，就不抢眼。
	_set_zero_aware_stat(_stat_cuts, PlayerStats.silence_webs_cut, "斩断腐蚀  %d")
	if PlayerStats.echo_reflects > 0:
		_stat_reflects.text = "Echo 反弹  %d" % PlayerStats.echo_reflects
		_stat_reflects.add_theme_color_override("font_color", Color(0.412, 0.78, 0.808, 1.0))
	else:
		_stat_reflects.text = "Echo 反弹  —"
		_stat_reflects.add_theme_color_override("font_color", _COLOR_ZERO_STAT)
	_set_zero_aware_stat(_stat_lanterns, PlayerStats.save_lanterns_activated, "存档灯笼  %d")
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

# T135 — Share button handler.  Reads the live Quick Stats
# fields (achievements / best time / run #) and writes a
# one-line plain-text summary to the system clipboard.
# DisplayServer.clipboard_set returns void; we don't try
# to confirm the write because the OS clipboard is opaque
# (and the player will paste somewhere visible to verify).
# On success, flash the button label to "已复制 ✓" for 1.5s
# so the player gets visual confirmation.  On failure
# (extremely rare — DisplayServer unavailable in headless
# or some Linux compositors), flash "复制失败" instead.
# Either way the label restores after 1.5s; pressing the
# button again before the restore just restarts the timer.
func _on_share_pressed() -> void:
	if _profile_share_btn == null:
		return
	var text: String = _format_share_text()
	# DisplayServer may be absent in some headless test setups;
	# guard with has_method so a unit test that instantiates
	# the panel directly doesn't crash on a missing singleton.
	var ok: bool = false
	if DisplayServer.has_method("clipboard_set"):
		DisplayServer.clipboard_set(text)
		ok = true
	var original_text: String = "分享到剪贴板"
	if _profile_share_btn.text != original_text:
		# Stash the original only on the first press; subsequent
		# presses keep whatever the original was before the
		# "已复制 ✓" overwrite.  This avoids the case where
		# a slow restore timer overwrites the stashed "已复制 ✓"
		# with itself instead of the canonical label.
		original_text = _profile_share_btn.text
	_profile_share_btn.text = "已复制 ✓" if ok else "复制失败"
	# Kill any in-flight timer so a quick second click doesn't
	# race against the previous 1.5s restore callback.
	var t := get_tree().create_timer(1.5)
	t.timeout.connect(func() -> void:
		if _profile_share_btn != null and is_instance_valid(_profile_share_btn):
			_profile_share_btn.text = original_text
	)

# Build the plain-text share summary.  Kept in plain text
# (no BBCode) so it pastes correctly into Twitter / Discord /
# Reddit / Steam chat / clipboard-aware friends.  Format:
#
#   🎵 Voxglass
#   成就 3 / 14  ·  最佳 04:32  ·  Run #7
#   2026-06-08
#
# The 🎵 glyph is a single emoji as a Voxglass visual hook;
# players on platforms that strip emoji still get a clean
# three-line summary.  We use ASCII dot (·) instead of • so
# the line is unambiguous across encodings.
func _format_share_text() -> String:
	var unlocked_count: int = PlayerStats.get_unlocked_count()
	var total_count: int = PlayerStats.get_total_count()
	var best: Dictionary = PlayerStats.get_best_stats()
	var best_time: float = float(best.get("longest_run_seconds", 0.0))
	var best_str: String
	if best_time > 0.0:
		var bm: int = int(best_time) / 60
		var bs: int = int(best_time) % 60
		best_str = "%02d:%02d" % [bm, bs]
	else:
		best_str = "—"
	var run_number: int = PlayerStats.get_run_number()
	# Build a YYYY-MM-DD stamp from local time so the share
	# reflects "when the player copied this" not "when the
	# save was made" (those can differ by hours).
	var dt := Time.get_datetime_dict_from_system()
	var date_str: String = "%04d-%02d-%02d" % [int(dt["year"]), int(dt["month"]), int(dt["day"])]
	return "🎵 Voxglass\n成就 %d / %d  ·  最佳 %s  ·  Run #%d\n%s" % [
		unlocked_count, total_count, best_str, run_number, date_str
	]

func _refresh_profile() -> void:
	# T127 — Run 编号（1-based；首次启动为 1，每次 reset_run 后 +1）。
	# 玩家看到"这是我的第 N 个 run"是一种 metaprogression 反馈。
	_profile_run.text = "Run #%d" % PlayerStats.get_run_number()
	# T133/T139 — Quick Stats 摘要行（achievements X/14 · 最佳回响 · Run #N）。
	# 设计为 BBCode 形式：3 个数据点都跨场景共享（成就=跨会话解锁 / 最佳=
	# 跨 run 持久化 / Run 编号=会话内），所以是"我的 Voxglass 生涯"的一行总览。
	# Amber Voice 暖色 + 9pt 比上下两行（Run # 8pt / 第一节统计 9pt）更显眼，作为
	# "header subtitle" 出现在标题与详细数据之间。首次启动时最佳 = "—" 占位
	# 与下方历史最佳块一致；零成就时仍显示 "成就 0 / 14" 表明进度条尚未启动。
	# T139 — 14 是动态值（`PlayerStats.get_total_count()`），不再硬编码 ——
	# #74 轮新增 quintuple_voice 成就后从 13 跳到 14；未来加成就只改 achievements.json。
	var unlocked_count: int = PlayerStats.get_unlocked_count()
	var total_count: int = PlayerStats.get_total_count()
	# Avoid shadowing the `best` dict used by the T127 historical-best
	# block further down in this function.  Read fresh into a
	# local; cheap call, no semantic dependence.
	var quick_best: Dictionary = PlayerStats.get_best_stats()
	var quick_best_time: float = float(quick_best.get("longest_run_seconds", 0.0))
	var best_time_str: String
	if quick_best_time > 0.0:
		var qbm: int = int(quick_best_time) / 60
		var qbs: int = int(quick_best_time) % 60
		best_time_str = "%02d:%02d" % [qbm, qbs]
	else:
		best_time_str = "—"
	_profile_quick_stats.text = "★ [color=#69C7CE]成就 %d / %d[/color]  ·  最佳 [color=#F2B66E]%s[/color]  ·  Run #[color=#B7E6DC]%d[/color] ★" % [
		unlocked_count, total_count, best_time_str, PlayerStats.get_run_number()
	]
	var t := int(PlayerStats.get_run_time_seconds())
	var m := t / 60
	var s := t % 60
	_profile_time.text = "回响时长  %02d:%02d" % [m, s]
	# T152 (#79) — 玩家档案 stat 行同样 0 数灰阶占位。回响时长不
	# 应用（与 QuickStatsPanel 理由一致：0:00 是合法"刚开始"）。
	_set_zero_aware_stat(_profile_deaths, PlayerStats.deaths, "共鸣消散  %d")
	_set_zero_aware_stat(_profile_rooms, PlayerStats.rooms_cleared, "完成房间  %d")
	# T102/T103 — 五动词 BBCode 颜色主题化（与 _stat_abilities 一致）
	_profile_abilities.text = "[color=#E86D5A]Pulse %d[/color]  ·  [color=#65506A]Bind %d[/color]  ·  [color=#F2B66E]Cut %d[/color]  ·  [color=#69C7CE]Echo %d[/color]  ·  [color=#B7E6DC]Wave %d[/color]" % [
		PlayerStats.pulse_used, PlayerStats.bind_used,
		PlayerStats.cut_used, PlayerStats.echo_used,
		PlayerStats.wave_used
	]
	_set_zero_aware_stat(_profile_shards, PlayerStats.shards_collected, "收集碎片  %d")
	# T152 — Echo 反弹行：>0 → 暖白 + 数字；0 → 暖灰 + "—"（档案面板
	# 没用 T100 的 Glass Cyan 强调，所以这里只走标准 zero-aware 路径）
	_set_zero_aware_stat(_profile_reflects, PlayerStats.echo_reflects, "Echo 反弹  %d")
	# T150 — 上次使用 verb（5 动词 BBCode 调色板对齐）。把 record_ability_used
	# 写入的英文 id 映射为 BBCode 形式：Pulse #E86D5A / Bind #65506A /
	# Cut #F2B66E / Echo #69C7CE / Wave #B7E6DC，色块与 _profile_abilities
	# 完全一致（"5 动词色域"贯穿 HUD / Pause / Profile / 命中闪 6 个表层）。
	# 空字符串 = 本 run 还没用过任何 verb（reset_stats 之后立即打开
	# 暂停），显示 "—" 占位让"未使用"状态明确可读。
	if _profile_last_verb:
		var last_verb: String = PlayerStats.get_last_used_verb()
		match last_verb:
			"pulse":
				_profile_last_verb.text = "上次使用：[color=#E86D5A]Pulse[/color]"
			"bind":
				_profile_last_verb.text = "上次使用：[color=#65506A]Bind[/color]"
			"cut":
				_profile_last_verb.text = "上次使用：[color=#F2B66E]Cut[/color]"
			"echo":
				_profile_last_verb.text = "上次使用：[color=#69C7CE]Echo[/color]"
			"wave":
				_profile_last_verb.text = "上次使用：[color=#B7E6DC]Wave[/color]"
			_:
				_profile_last_verb.text = "上次使用：—"
	# T127 — 历史最佳 4 行（持久化跨 run；首次启动全 0 → 显示 "—"）。
	# 视觉组：4 行用暖白 + 8pt 小字，与上方当前 run 状态形成对比。
	# 「—」占位让"还没创造记录"的状态在 UI 上明确可读。
	var best: Dictionary = PlayerStats.get_best_stats()
	var best_time := float(best.get("longest_run_seconds", 0.0))
	if best_time > 0.0:
		var bm := int(best_time) / 60
		var bs := int(best_time) % 60
		_profile_best_time.text = "最长回响  %02d:%02d" % [bm, bs]
	else:
		_profile_best_time.text = "最长回响  —"
	var best_rooms := int(best.get("most_rooms_cleared", 0))
	_profile_best_rooms.text = "最多房间  %s" % (str(best_rooms) if best_rooms > 0 else "—")
	var best_shards := int(best.get("most_shards_collected", 0))
	_profile_best_shards.text = "最多碎片  %s" % (str(best_shards) if best_shards > 0 else "—")
	var best_enemies := int(best.get("most_enemies_purified", 0))
	_profile_best_enemies.text = "最多净化  %s" % (str(best_enemies) if best_enemies > 0 else "—")
	# T138 — 上次自动存档时间（HH:MM:SS）。如果 SaveSystem autoload
	# 不可用或本会话还没 auto-save 过（_last_autosave_unix == 0），
	# 显示 "—" 占位。0 视为"无数据"（不要当作 1970-01-01 显示）。
	if _profile_auto_save and SaveSystem and SaveSystem.has_method("get_last_autosave_unix"):
		var last_unix: int = int(SaveSystem.get_last_autosave_unix())
		if last_unix > 0:
			var dt := Time.get_datetime_dict_from_unix_time(last_unix)
			_profile_auto_save.text = "上次自动存档  %02d:%02d:%02d" % [dt["hour"], dt["minute"], dt["second"]]
		else:
			_profile_auto_save.text = "上次自动存档  —"
	elif _profile_auto_save:
		_profile_auto_save.text = "上次自动存档  —"
	# T131 — 近 N 局平均（5/10/20 三档）趋势行。让玩家看到
	# "最近 N 局的平均表现"，与上方"历史最佳"形成对比：
	# 最佳 = 单一极值（峰值），趋势 = 平滑平均（成长线）。
	# 零样本（首次启动）显示 "—"，>=1 样本显示 4 字段平均。
	_refresh_trend_row(_profile_trend5, 5)
	_refresh_trend_row(_profile_trend10, 10)
	_refresh_trend_row(_profile_trend20, 20)
	# Refresh achievement list state (new unlocks may have changed).
	_refresh_profile_achievement_list()

# T131 — 趋势行格式化。把 4 字段平均 + 样本数压成单行 Label 文本。
# 例："近 5 局   房 1.4  净 3.2  碎 8.1  时 02:35  死 0.4 (n=5)"
# 中文 1-字 key = 紧凑排版。零样本时 "—" 占位。
func _refresh_trend_row(target: Label, n: int) -> void:
	var avg: Dictionary = PlayerStats.get_recent_runs_average(n)
	if avg.is_empty():
		target.text = "近 %d 局   —" % n
		return
	var rooms_avg: float = float(avg.get("rooms_cleared", 0.0))
	var enemies_avg: float = float(avg.get("enemies_purified", 0.0))
	var shards_avg: float = float(avg.get("shards_collected", 0.0))
	var deaths_avg: float = float(avg.get("deaths", 0.0))
	var time_avg: float = float(avg.get("run_time_seconds", 0.0))
	var tm: int = int(time_avg) / 60
	var ts: int = int(time_avg) % 60
	var sample_count: int = int(avg.get("sample_count", 0))
	# 一位小数（统计面板需要 7pt 小字可读）；0 显示 "0" 而非 ".0"
	var rooms_str: String = ("%.1f" % rooms_avg) if rooms_avg > 0.0 else "0"
	var enemies_str: String = ("%.1f" % enemies_avg) if enemies_avg > 0.0 else "0"
	var shards_str: String = ("%.1f" % shards_avg) if shards_avg > 0.0 else "0"
	var deaths_str: String = ("%.1f" % deaths_avg) if deaths_avg > 0.0 else "0"
	target.text = "近 %d 局   房 %s  净 %s  碎 %s  死 %s  时 %02d:%02d  (n=%d)" % [
		n, rooms_str, enemies_str, shards_str, deaths_str, tm, ts, sample_count
	]

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

# T152 (#79) — 0 数灰阶占位 helper。value <= 0 → 文本 "—"，色
# 调 _COLOR_ZERO_STAT（暖灰）；value > 0 → 用 format_str 格式化数
# 字，色调还原为暖白 (0.875, 0.835, 0.784)（与 STYLE_GUIDE 暖
# 白一致；不用 _COLOR_NORMAL_STAT 是因为可能 label 之前被
# 别的代码设过 Glass Cyan 调色——还原暖白是更安全的"中性
# 状态"）。format_str 不应包含 BBCode 色码：这里走纯文本 +
# 主题色调路径，与 5 动词行（BBCode 路径）区分。
func _set_zero_aware_stat(lbl: Label, value: int, format_str: String) -> void:
	if lbl == null:
		return
	if value > 0:
		lbl.text = format_str % value
		lbl.add_theme_color_override("font_color", Color(0.875, 0.835, 0.784, 1.0))
	else:
		# 把 format_str 里的 "  %d" 截掉前缀只留 label 名（"完成房间  %d" → "完成房间"）。
		# 这样 "—" 不会与 %d 错位；保留中文 label 名 + 两个空格的视觉节奏。
		var label_part: String = format_str
		var idx := label_part.find("  %d")
		if idx >= 0:
			label_part = label_part.substr(0, idx)
		lbl.text = "%s  —" % label_part
		lbl.add_theme_color_override("font_color", _COLOR_ZERO_STAT)
