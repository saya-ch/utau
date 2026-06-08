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
@onready var _reset_defaults_btn: Button = $VBoxContainer/Content/ControlsPanel/ResetDefaultsButton
@onready var _save_count_label: Label = $VBoxContainer/Content/SavesPanel/SaveCountLabel
@onready var _delete_all_btn: Button = $VBoxContainer/Content/SavesPanel/DeleteAllButton
@onready var _respawn_hub_check: CheckBox = $VBoxContainer/Content/SavesPanel/RespawnHubCheck
# T136 — auto-save controls (SavesPanel second half).  Read in
# _load_settings(), pushed to SaveSystem on toggle / slider /
# option change.  Slider shows 10–600 seconds in 10s steps.
# Slot dropdown lists 0..SLOT_COUNT-1 so the runtime cap on
# SaveSystem propagates without re-saving the scene.
@onready var _autosave_enabled_check: CheckBox = $VBoxContainer/Content/SavesPanel/AutoSaveEnabledCheck
@onready var _autosave_interval_slider: HSlider = $VBoxContainer/Content/SavesPanel/AutoSaveIntervalSlider
@onready var _autosave_interval_value: Label = $VBoxContainer/Content/SavesPanel/AutoSaveIntervalRow/AutoSaveIntervalValue
@onready var _autosave_slot_options: OptionButton = $VBoxContainer/Content/SavesPanel/AutoSaveSlotRow/AutoSaveSlotOptions
@onready var _close_btn: Button = $VBoxContainer/CloseButton

# T072 — modal confirmation dialog for "Delete All Saves"
var _confirm_dialog: ConfirmationDialog = null

const ACTION_NAMES := {
	"move_left": "向左移动",
	"move_right": "向右移动",
	"jump": "跳跃",
	"pulse": "Pulse 声波",
	"bind": "Bind 牵引",
	"cut": "Cut 斩断",
	"interact": "交互",
}

# T086 — Default keybindings for the "Reset to Defaults" button.
# Mirrors the InputMap defaults in project.godot.  When the player
# hits the reset button we erase all current bindings and apply
# these, then rebuild the controls list to show the new labels.
const _DEFAULT_BINDINGS := {
	"move_left":  {"type": "key", "physical_keycode": 65},   # A
	"move_right": {"type": "key", "physical_keycode": 68},   # D
	"jump":       {"type": "key", "physical_keycode": 32},   # Space
	"pulse":      {"type": "key", "physical_keycode": 74},   # J
	"bind":       {"type": "key", "physical_keycode": 75},   # K
	"cut":        {"type": "key", "physical_keycode": 76},   # L
	"echo":       {"type": "key", "physical_keycode": 81},   # Q
	"interact":   {"type": "key", "physical_keycode": 69},   # E
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

	# T086 — Reset to defaults
	_reset_defaults_btn.pressed.connect(_on_reset_defaults_pressed)

	# T136 — auto-save controls.  Pushed live to SaveSystem so
	# the change takes effect immediately (no need to close +
	# reopen the menu).  SaveSystem also re-persists to
	# settings.cfg on every setter so a crash mid-session
	# doesn't lose the new value.
	_autosave_enabled_check.toggled.connect(_on_autosave_enabled_toggled)
	_autosave_interval_slider.value_changed.connect(_on_autosave_interval_changed)
	_autosave_slot_options.item_selected.connect(_on_autosave_slot_selected)
	
	# Init scale options
	_scale_options.clear()
	_scale_options.add_item("480x270 (1x)")
	_scale_options.add_item("960x540 (2x)")
	_scale_options.add_item("1440x810 (3x)")
	_scale_options.add_item("1920x1080 (4x)")
	_scale_options.select(3)
	
	_load_settings()
	_build_controls_list()
	# T134 — Make the Saves tab count placeholder honour
	# SaveSystem.SLOT_COUNT dynamically (was hard-coded "0 / 3" in
	# the scene file pre-#55).  Calling _refresh_save_count() here
	# re-formats the label from the live SLOT_COUNT constant so a
	# future bump (e.g. 5 → 8) propagates without re-saving the
	# scene.  Guarded with autoload presence so the menu still
	# opens in the test harness where SaveSystem is not autoloaded.
	if _save_count_label and _has_save_system_autoload():
		_refresh_save_count()

	_switch_tab(Tab.AUDIO)

func _has_save_system_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("SaveSystem")

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if _remapping_action != "":
		# T086 — Allow ESC to cancel an in-progress remap.  The
		# remap_button's text is restored to the previously bound
		# key name and the listening state ends without altering
		# the InputMap.  Without this, a player who accidentally
		# entered remap mode and isn't sure what to do had no way
		# out (ui_cancel below closes the entire settings menu).
		if event.is_action_pressed("ui_cancel"):
			_cancel_remap()
			get_viewport().set_input_as_handled()
			return
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

# === T136 — auto-save config ===

# Build the slot dropdown once, at menu open.  Listing 0..SLOT_COUNT-1
# means a future bump (5 → 8) auto-propagates through the live
# SaveSystem constant without editing the scene file.  Default
# selection is whatever the cfg says (caller passes that index).
func _build_autosave_slot_options(select_index: int) -> void:
	if _autosave_slot_options == null:
		return
	_autosave_slot_options.clear()
	for i in range(SaveSystem.SLOT_COUNT):
		_autosave_slot_options.add_item("槽位 %d" % i, i)
	_autosave_slot_options.select(clampi(select_index, 0, SaveSystem.SLOT_COUNT - 1))

# Populate all three auto-save controls from the cfg (or from
# the live SaveSystem state, which already loaded the cfg in
# its own _ready).  If SaveSystem is missing (test harness),
# fall back to the cfg values directly.  Always updates the
# visual value label too, so the slider and the "60 秒" readout
# can't drift apart after a fresh load.
func _populate_autosave_controls_from_cfg(cfg: ConfigFile) -> void:
	if _autosave_enabled_check == null:
		return
	var enabled: bool
	var interval: float
	var slot: int
	if _has_save_system_autoload():
		enabled = SaveSystem.get_autosave_enabled()
		interval = SaveSystem.get_autosave_interval()
		slot = SaveSystem.get_autosave_slot()
	else:
		enabled = bool(cfg.get_value("gameplay", "autosave_enabled", true))
		interval = float(cfg.get_value("gameplay", "autosave_interval", 60.0))
		slot = int(cfg.get_value("gameplay", "autosave_slot", 0))
	# set_block_signals so the live-edits below don't fire the
	# _on_autosave_*_changed handlers and immediately re-push
	# the (unchanged) values back to SaveSystem.  Saves one
	# cfg write per menu open.
	_autosave_enabled_check.set_block_signals(true)
	_autosave_enabled_check.button_pressed = enabled
	_autosave_enabled_check.set_block_signals(false)
	_autosave_interval_slider.set_block_signals(true)
	_autosave_interval_slider.value = clampf(interval, _autosave_interval_slider.min_value, _autosave_interval_slider.max_value)
	_autosave_interval_slider.set_block_signals(false)
	_refresh_autosave_interval_label(_autosave_interval_slider.value)
	_build_autosave_slot_options(slot)

# The interval slider doesn't auto-update its readout label
# (it only changes the slider thumb), so we drive the "60 秒"
# text manually on every value_changed.  Kept tiny because the
# label is the entire UI affordance for the interval — a bug
# here would silently leave the player with a 5-minute auto
# save and a "30 秒" label.
func _refresh_autosave_interval_label(value: float) -> void:
	if _autosave_interval_value == null:
		return
	_autosave_interval_value.text = "%d 秒" % int(round(value))

# Handler for the "启用自动存档" toggle.  Pushes to SaveSystem
# live (no need to close the menu).  SaveSystem's setter
# also re-persists to settings.cfg, so the next menu open will
# show the same state.
func _on_autosave_enabled_toggled(enabled: bool) -> void:
	if _has_save_system_autoload():
		SaveSystem.set_autosave_enabled(enabled)

# Handler for the interval slider.  Same live-push contract as
# the toggle — SaveSystem clamps to its own [MIN, MAX] window
# so the player can't go below 10s even by dragging past the
# floor (defensive against a future scene that overrides the
# slider's min_value).
func _on_autosave_interval_changed(value: float) -> void:
	_refresh_autosave_interval_label(value)
	if _has_save_system_autoload():
		SaveSystem.set_autosave_interval(value)

# Handler for the slot OptionButton.  Index → id mapping is
# 1:1 in this build (slot 0..4 = index 0..4), but the dropdown
# stores the id as the second arg to add_item so we read it via
# get_item_id(selected) instead of selected directly — that way
# future reorganisations (e.g. "槽位 0" removed) don't break
# saves.
func _on_autosave_slot_selected(index: int) -> void:
	if _autosave_slot_options == null:
		return
	var slot_id := _autosave_slot_options.get_item_id(index)
	if _has_save_system_autoload():
		SaveSystem.set_autosave_slot(slot_id)

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
	# Count how many of the SLOT_COUNT slots are currently occupied, and disable
	# the delete button if there are none to delete.
	# (T088: SLOT_COUNT 3 → 5, dynamically via SaveSystem)
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
	# T086 — More informative "listening" prompt: tell the player
	# the new key will REPLACE the current binding and that ESC
	# cancels.  Also visually pulse the button so it's obvious
	# which row is active.
	btn.text = "按下新键... (ESC 取消)"
	btn.modulate = Color(0.949, 0.714, 0.431, 1)  # amber voice
	# Pulse the button every 0.4s while listening so the player
	# has a clear visual signal of "we're waiting for you".
	if not btn.has_meta("remap_pulse_tween"):
		pass
	var pulse_tween := create_tween().set_loops()
	pulse_tween.tween_property(btn, "modulate:a", 0.4, 0.4)
	pulse_tween.tween_property(btn, "modulate:a", 1.0, 0.4)
	btn.set_meta("remap_pulse_tween", pulse_tween)

func _stop_remap_pulse(btn: Button) -> void:
	# T086 — Stop the listening pulse, restore normal color.
	if btn.has_meta("remap_pulse_tween"):
		var tw: Tween = btn.get_meta("remap_pulse_tween")
		if tw and tw.is_valid():
			tw.kill()
		btn.remove_meta("remap_pulse_tween")
	btn.modulate = Color.WHITE

func _cancel_remap() -> void:
	# T086 — Restore the button text to whatever the action is
	# currently bound to (the input map hasn't been touched, so
	# InputMap.action_get_events still returns the original event).
	# This makes the cancel path completely non-destructive.
	if _remapping_action == "" or _remapping_button == null:
		return
	var events := InputMap.action_get_events(_remapping_action)
	var display_text := "未绑定"
	if events.size() > 0:
		display_text = _event_to_string(events[0])
	_remapping_button.text = display_text
	_stop_remap_pulse(_remapping_button)
	_remapping_action = ""
	_remapping_button = null

func _accept_remap(event: InputEvent) -> void:
	if _remapping_action == "" or _remapping_button == null:
		return

	# Only accept key/button/motion, not mouse
	if event is InputEventMouseButton:
		return

	# T086 — Conflict detection: check if the same event is already
	# bound to a DIFFERENT action in ACTION_NAMES.  If so, swap the
	# bindings (the old action loses this event, the new action
	# gains it).  Without this, two actions could end up sharing
	# a single key, which makes the game unresponsive (press the
	# key, both actions fire).
	var other_action := _find_conflicting_action(event, _remapping_action)
	if other_action != "":
		# Remove the event from the OTHER action so each key only
		# drives one action.  The new action gets the event.
		InputMap.action_erase_events(other_action)

	InputMap.action_erase_events(_remapping_action)
	InputMap.action_add_event(_remapping_action, event)

	_remapping_button.text = _event_to_string(event)
	# T086 — Brief green flash on successful remap so the player
	# sees a positive confirmation.
	_remap_flash_confirm(_remapping_button)
	_stop_remap_pulse(_remapping_button)
	_remapping_action = ""
	_remapping_button = null

func _remap_flash_confirm(btn: Button) -> void:
	# T086 — Green Glass Cyan flash (0.15s) for successful remap.
	# Reuses the STYLE_GUIDE Glass Cyan to communicate "ok".
	var original_mod := Color.WHITE
	btn.modulate = Color(0.412, 0.78, 0.808, 1)
	var tween := create_tween()
	tween.tween_property(btn, "modulate", original_mod, 0.4)

func _find_conflicting_action(event: InputEvent, exclude_action: String) -> String:
	# T086 — Scan ACTION_NAMES for any action that already has this
	# event bound.  Return the action name (or "" if no conflict).
	# Comparing via event.as_text_physical_keycode() is good enough
	# for keyboard; for joypad buttons the full InputEvent is
	# compared via .as_text() which is robust to device IDs.
	var event_str := _event_to_canonical_string(event)
	for action in ACTION_NAMES.keys():
		if action == exclude_action:
			continue
		var bound_events := InputMap.action_get_events(action)
		for bound in bound_events:
			if _event_to_canonical_string(bound) == event_str:
				return action
	return ""

func _event_to_canonical_string(event: InputEvent) -> String:
	# T086 — Used for conflict detection.  Returns a stable string
	# representation of an input event, ignoring transient fields
	# like pressed/echo/device-id that don't matter for "is this
	# the same key".  Falls back to as_text() for completeness.
	if event is InputEventKey:
		var ke: InputEventKey = event
		# physical_keycode is the layout-independent key, which is
		# what rebinding cares about (A on QWERTY == A on AZERTY
		# if using physical_keycode).
		return "key:%d" % ke.physical_keycode
	elif event is InputEventJoypadButton:
		var jb: InputEventJoypadButton = event
		return "joy_btn:%d" % jb.button_index
	elif event is InputEventJoypadMotion:
		var jm: InputEventJoypadMotion = event
		return "joy_motion:%d:%d" % [jm.axis, signf(jm.axis_value)]
	return event.as_text()

func _on_reset_defaults_pressed() -> void:
	# T086 — Wipe all current bindings and apply the project defaults.
	# If a remap is in progress, cancel it first so the listening
	# button doesn't end up displaying a stale event.
	if _remapping_action != "":
		_cancel_remap()

	for action in ACTION_NAMES.keys():
		InputMap.action_erase_events(action)
		var def: Dictionary = _DEFAULT_BINDINGS.get(action, {})
		if def.is_empty():
			continue
		if def["type"] == "key":
			var ev := InputEventKey.new()
			ev.physical_keycode = int(def["physical_keycode"])
			InputMap.action_add_event(action, ev)

	# Rebuild the list so the buttons reflect the new bindings.
	_build_controls_list()
	# Brief cyan flash on the reset button as positive feedback.
	_remap_flash_confirm(_reset_defaults_btn)

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
	# T136 — auto-save config (the Settings menu is one of two
	# writers; SaveSystem also writes on every setter).  The
	# last-writer-wins per session — the next _save_settings()
	# at menu-close will overwrite anything SaveSystem wrote
	# in the meantime, so always read live state from the
	# controls (not from the cfg) when populating these.
	if _autosave_enabled_check:
		cfg.set_value("gameplay", "autosave_enabled", _autosave_enabled_check.button_pressed)
	if _autosave_interval_slider:
		cfg.set_value("gameplay", "autosave_interval", _autosave_interval_slider.value)
	if _autosave_slot_options:
		cfg.set_value("gameplay", "autosave_slot", _autosave_slot_options.selected)

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

	# T136 — auto-save config.  Read from cfg, populate the
	# controls, and (when SaveSystem is present) push the values
	# in so a freshly-loaded settings file is the source of truth
	# even if SaveSystem._ready read the file a moment earlier.
	# Without this push, SaveSystem would keep the defaults it
	# loaded at startup and the UI would lie about the active
	# configuration.  The setter also re-persists, so the next
	# menu close is idempotent.
	_populate_autosave_controls_from_cfg(cfg)
	
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
