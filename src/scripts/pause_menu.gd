class_name PauseMenu
extends Control

signal resume_pressed
signal restart_pressed
signal quit_to_title_pressed
signal settings_pressed
signal save_requested(slot_id: int)  # T070 — PauseMenu → GFC

@onready var _resume_btn: Button = $VBoxContainer/ResumeButton
@onready var _save_btn: Button = $VBoxContainer/SaveButton
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
@onready var _stat_lanterns: Label = $StatsPanel/StatsMargin/StatsVBox/StatList/StatLanterns
@onready var _stat_time: Label = $StatsPanel/StatsMargin/StatsVBox/StatTime
@onready var _achv_grid: HBoxContainer = $StatsPanel/StatsMargin/StatsVBox/AchvGrid

const ICON_PATH_BASE := "res://assets/ui/achievements"
const ICON_DEFAULT := "amber_dot"

var _is_paused: bool = false

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

	_resume_btn.pressed.connect(_on_resume)
	_save_btn.pressed.connect(_on_save)
	_settings_btn.pressed.connect(_on_settings)
	_restart_btn.pressed.connect(_on_restart)
	_quit_btn.pressed.connect(_on_quit_to_title)

	# T070 — SaveLoadMenu signal wiring (mode = save, so only save/delete)
	_save_load_menu.save_requested.connect(_on_save_load_saved)
	_save_load_menu.delete_requested.connect(_on_save_load_deleted)
	_save_load_menu.load_requested.connect(_on_save_load_loaded)  # defensive

	_build_achievement_grid()

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
	_stat_abilities.text = "Pulse  %d  ·  Bind  %d  ·  Cut  %d" % [
		PlayerStats.pulse_used, PlayerStats.bind_used, PlayerStats.cut_used
	]
	_stat_cuts.text = "斩断腐蚀  %d" % PlayerStats.silence_webs_cut
	_stat_lanterns.text = "存档灯笼  %d" % PlayerStats.save_lanterns_activated
	var t := int(PlayerStats.get_run_time_seconds())
	var m := t / 60
	var s := t % 60
	_stat_time.text = "回响时长  %02d:%02d" % [m, s]
	_refresh_achievement_grid()

# === 成就图标网格 ===

func _build_achievement_grid() -> void:
	# Create a TextureRect for each achievement defined in achievements.json
	# (8 cells; locked = desaturated, unlocked = full color)
	for ach in PlayerStats.get_all_achievements():
		var hint: String = ach.get("icon_hint", ICON_DEFAULT)
		var id_val: String = ach.get("id", "")
		var tex := _load_icon_texture(hint)
		var slot := TextureRect.new()
		slot.custom_minimum_size = Vector2(16, 16)
		slot.texture = tex
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.tooltip_text = "%s  %s" % [ach.get("title_zh", id_val), ach.get("description_zh", "")]
		slot.name = "AchvSlot_" + id_val
		_achv_grid.add_child(slot)

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
