class_name SettingsMenu
extends Control

signal closed

enum Tab { AUDIO, VIDEO, CONTROLS, SAVES }

var _current_tab: Tab = Tab.AUDIO

# Audio settings
var _master_volume: float = 1.0
var _sfx_volume: float = 1.0
var _music_volume: float = 1.0
var _ambience_volume: float = 1.0

# Video settings
var _fullscreen: bool = false
var _window_scale: int = 4  # 480 * 4 = 1920

# Controls remapping
var _remapping_action: String = ""
var _remapping_button: Button = null

# T079 — Death respawn policy.  When true (default), the player
# respawns at the Hub safe-room after dying.  When false, the
# player respawns at the last Save Lantern checkpoint ("continue
# in current room" — the classic, less forgiving mode).
var _respawn_to_hub: bool = true

@onready var _tab_audio: Button = $VBoxContainer/TabRow/AudioTab
@onready var _tab_video: Button = $VBoxContainer/TabRow/VideoTab
@onready var _tab_controls: Button = $VBoxContainer/TabRow/ControlsTab
@onready var _tab_saves: Button = $VBoxContainer/TabRow/SavesTab

@onready var _audio_panel: Control = $VBoxContainer/Content/AudioPanel
@onready var _video_panel: Control = $VBoxContainer/Content/VideoPanel
@onready var _controls_panel: Control = $VBoxContainer/Content/ControlsPanel
@onready var _saves_panel: Control = $VBoxContainer/Content/SavesPanel

@onready var _master_slider: HSlider = $VBoxContainer/Content/AudioPanel/MasterSlider
@onready var _sfx_slider: HSlider = $VBoxContainer/Content/AudioPanel/SFXSlider
@onready var _music_slider: HSlider = $VBoxContainer/Content/AudioPanel/MusicSlider
@onready var _ambience_slider: HSlider = $VBoxContainer/Content/AudioPanel/AmbienceSlider

@onready var _fullscreen_check: CheckBox = $VBoxContainer/Content/VideoPanel/FullscreenCheck
@onready var _scale_options: OptionButton = $VBoxContainer/Content/VideoPanel/ScaleOptions

@onready var _controls_list: VBoxContainer = $VBoxContainer/Content/ControlsPanel/ControlsList
@onready var _save_count_label: Label = $VBoxContainer/Content/SavesPanel/SaveCountLabel
@onready var _delete_all_btn: Button = $VBoxContainer/Content/SavesPanel/DeleteAllButton
@onready var _respawn_hub_check: CheckBox = $VBoxContainer/Content/SavesPanel/RespawnHubCheck
@onready var _close_btn: Button = $VBoxContainer/CloseButton

# T072 — modal confirmation dialog for "Delete All Saves"
var _confirm_dialog: ConfirmationDialog = null

const ACTION_NAMES := {
	"move_left": "向左移动",
	"move_right": "向右移动",
	"jump": "跳跃",
	"pulse": "Pulse 声波",
	"interact": "交互",
}

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_tab_audio.pressed.connect(func() -> void: _switch_tab(Tab.AUDIO))
	_tab_video.pressed.connect(func() -> void: _switch_tab(Tab.VIDEO))
	_tab_controls.pressed.connect(func() -> void: _switch_tab(Tab.CONTROLS))
	_tab_saves.pressed.connect(func() -> void: _switch_tab(Tab.SAVES))
	_close_btn.pressed.connect(_on_close)
	
	# Audio sliders
	_master_slider.value_changed.connect(_on_master_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	_ambience_slider.value_changed.connect(_on_ambience_changed)
	
	# Video
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_scale_options.item_selected.connect(_on_scale_selected)
	
	# T072 — Saves tab
	_delete_all_btn.pressed.connect(_on_delete_all_pressed)

	# T079 — Respawn policy toggle
	_respawn_hub_check.toggled.connect(_on_respawn_hub_toggled)
	
	# Init scale options
	_scale_options.clear()
	_scale_options.add_item("480x270 (1x)")
	_scale_options.add_item("960x540 (2x)")
	_scale_options.add_item("1440x810 (3x)")
	_scale_options.add_item("1920x1080 (4x)")
	_scale_options.select(3)
	
	_load_settings()
	_build_controls_list()
	_switch_tab(Tab.AUDIO)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if _remapping_action != "":
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if event.pressed and not event.is_echo():
				_accept_remap(event)
				get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("ui_cancel"):
		_on_close()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	show()
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	_load_settings()
	_refresh_save_count()

func _on_close() -> void:
	_save_settings()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(func() -> void:
		hide()
		closed.emit()
	)

func _switch_tab(tab: Tab) -> void:
	_current_tab = tab
	_audio_panel.visible = tab == Tab.AUDIO
	_video_panel.visible = tab == Tab.VIDEO
	_controls_panel.visible = tab == Tab.CONTROLS
	_saves_panel.visible = tab == Tab.SAVES

	_tab_audio.modulate = Color.WHITE if tab == Tab.AUDIO else Color(0.5, 0.5, 0.5)
	_tab_video.modulate = Color.WHITE if tab == Tab.VIDEO else Color(0.5, 0.5, 0.5)
	_tab_controls.modulate = Color.WHITE if tab == Tab.CONTROLS else Color(0.5, 0.5, 0.5)
	_tab_saves.modulate = Color.WHITE if tab == Tab.SAVES else Color(0.5, 0.5, 0.5)
	
	# Refresh save count when entering the Saves tab
	if tab == Tab.SAVES:
		_refresh_save_count()

# === T079 — Respawn policy toggle ===

func _on_respawn_hub_toggled(enabled: bool) -> void:
	_respawn_to_hub = enabled
	# Live-apply to GameState so the next death follows the new
	# policy without waiting for a settings save.  This matters
	# for "I want classic mode right now" — the player doesn't
	# have to close the menu first.
	GameState.set_respawn_to_hub(enabled)

func _has_game_state_autoload() -> bool:
	# Defensive helper: GameState is an autoload, but in some test
	# contexts (e.g. direct scene previews) the root may not have
	# all autoloads.  Check the SceneTree first.
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("GameState")

# === T072 — Saves tab / Delete All Saves ===

func _refresh_save_count() -> void:
	# Count how many of the 3 slots are currently occupied, and disable
	# the delete button if there are none to delete.
	var count := 0
	for i in range(SaveSystem.SLOT_COUNT):
		if SaveSystem.has_save(i):
			count += 1
	_save_count_label.text = "当前存档：%d / %d" % [count, SaveSystem.SLOT_COUNT]
	_delete_all_btn.disabled = (count == 0)

func _on_delete_all_pressed() -> void:
	# Show a modal ConfirmationDialog. The dialog is created on demand
	# so it can be sized / themed consistently with the rest of the UI.
	# process_mode = ALWAYS so it can fire while the menu is open.
	if _confirm_dialog == null:
		_confirm_dialog = ConfirmationDialog.new()
		_confirm_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
		_confirm_dialog.title = "确认删除"
		_confirm_dialog.dialog_text = "确定要删除所有存档吗？\n此操作不可撤销，成就不会被删除。\n（成就独立保存在 user://achievements.json）"
		_confirm_dialog.ok_button_text = "删除"
		_confirm_dialog.cancel_button_text = "取消"
		# Style the OK button to communicate danger (red text).
		_confirm_dialog.get_ok_button().modulate = Color(0.91, 0.427, 0.353, 1)
		_confirm_dialog.confirmed.connect(_on_delete_all_confirmed)
		add_child(_confirm_dialog)
	# Center the dialog over the Settings menu.
	_confirm_dialog.popup_centered(Vector2i(280, 140))

func _on_delete_all_confirmed() -> void:
	var deleted := SaveSystem.delete_all_saves()
	_refresh_save_count()
	# Toast-style feedback: mutate the save count label briefly.
	if deleted > 0:
		_save_count_label.text = "已删除 %d 个存档" % deleted
		# Restore the regular format after 1.5s.
		var t := get_tree().create_timer(1.5)
		t.timeout.connect(func() -> void: _refresh_save_count())

# Audio
func _on_master_changed(value: float) -> void:
	_master_volume = value / 100.0
	AudioServer.set_bus_volume_db(0, linear_to_db(_master_volume))

func _on_sfx_changed(value: float) -> void:
	_sfx_volume = value / 100.0
	var idx := AudioServer.get_bus_index("SFX")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(_sfx_volume))

func _on_music_changed(value: float) -> void:
	_music_volume = value / 100.0
	var idx := AudioServer.get_bus_index("Music")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(_music_volume))

func _on_ambience_changed(value: float) -> void:
	_ambience_volume = value / 100.0
	var idx := AudioServer.get_bus_index("Ambience")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(_ambience_volume))

# Video
func _on_fullscreen_toggled(enabled: bool) -> void:
	_fullscreen = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_apply_window_scale()

func _on_scale_selected(index: int) -> void:
	_window_scale = index + 1
	if not _fullscreen:
		_apply_window_scale()

func _apply_window_scale() -> void:
	var base_w := 480
	var base_h := 270
	DisplayServer.window_set_size(Vector2i(base_w * _window_scale, base_h * _window_scale))

# Controls
func _build_controls_list() -> void:
	# Clear existing
	for child in _controls_list.get_children():
		child.queue_free()
	
	for action in ACTION_NAMES.keys():
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label := Label.new()
		label.text = ACTION_NAMES[action]
		label.custom_minimum_size = Vector2(100, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		
		var events := InputMap.action_get_events(action)
		var display_text := "未绑定"
		if events.size() > 0:
			display_text = _event_to_string(events[0])
		
		var btn := Button.new()
		btn.text = display_text
		btn.custom_minimum_size = Vector2(120, 24)
		btn.pressed.connect(func() -> void: _start_remap(action, btn))
		row.add_child(btn)
		
		_controls_list.add_child(row)

func _event_to_string(event: InputEvent) -> String:
	if event is InputEventKey:
		return event.as_text_physical_keycode()
	elif event is InputEventJoypadButton:
		return "手柄 %d" % event.button_index
	elif event is InputEventJoypadMotion:
		return "摇杆"
	return "未知"

func _start_remap(action: String, btn: Button) -> void:
	_remapping_action = action
	_remapping_button = btn
	btn.text = "按任意键..."

func _accept_remap(event: InputEvent) -> void:
	if _remapping_action == "" or _remapping_button == null:
		return
	
	# Only accept key/button/motion, not mouse
	if event is InputEventMouseButton:
		return
	
	InputMap.action_erase_events(_remapping_action)
	InputMap.action_add_event(_remapping_action, event)
	
	_remapping_button.text = _event_to_string(event)
	_remapping_action = ""
	_remapping_button = null

# Persistence
func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", _master_volume)
	cfg.set_value("audio", "sfx", _sfx_volume)
	cfg.set_value("audio", "music", _music_volume)
	cfg.set_value("audio", "ambience", _ambience_volume)
	cfg.set_value("video", "fullscreen", _fullscreen)
	cfg.set_value("video", "window_scale", _window_scale)
	cfg.set_value("gameplay", "respawn_to_hub", _respawn_to_hub)  # T079

	# Save input map
	for action in ACTION_NAMES.keys():
		var events := InputMap.action_get_events(action)
		if events.size() > 0:
			cfg.set_value("input", action, events[0])

	var err := cfg.save("user://settings.cfg")
	if err != OK:
		push_warning("Failed to save settings: %d" % err)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://settings.cfg")
	if err != OK:
		return

	_master_volume = cfg.get_value("audio", "master", 1.0)
	_sfx_volume = cfg.get_value("audio", "sfx", 1.0)
	_music_volume = cfg.get_value("audio", "music", 1.0)
	_ambience_volume = cfg.get_value("audio", "ambience", 1.0)

	_master_slider.value = _master_volume * 100.0
	_sfx_slider.value = _sfx_volume * 100.0
	_music_slider.value = _music_volume * 100.0
	_ambience_slider.value = _ambience_volume * 100.0

	_fullscreen = cfg.get_value("video", "fullscreen", false)
	_window_scale = cfg.get_value("video", "window_scale", 4)
	_fullscreen_check.button_pressed = _fullscreen
	_scale_options.select(clampi(_window_scale - 1, 0, 3))

	# T079 — Respawn policy (default = Hub safe-room)
	_respawn_to_hub = cfg.get_value("gameplay", "respawn_to_hub", true)
	_respawn_hub_check.button_pressed = _respawn_to_hub
	if Engine.has_singleton("GameState") or _has_game_state_autoload():
		GameState.set_respawn_to_hub(_respawn_to_hub)
	
	# Apply loaded settings
	AudioServer.set_bus_volume_db(0, linear_to_db(_master_volume))
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(_sfx_volume))
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx != -1:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(_music_volume))
	var amb_idx := AudioServer.get_bus_index("Ambience")
	if amb_idx != -1:
		AudioServer.set_bus_volume_db(amb_idx, linear_to_db(_ambience_volume))
	
	if _fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_apply_window_scale()
	
	# Load input map
	for action in ACTION_NAMES.keys():
		var ev = cfg.get_value("input", action, null)
		if ev is InputEvent:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, ev)
