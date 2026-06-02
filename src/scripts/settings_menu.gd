class_name SettingsMenu
extends Control

signal closed

enum Tab { AUDIO, VIDEO, CONTROLS }

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

@onready var _tab_audio: Button = $VBoxContainer/TabRow/AudioTab
@onready var _tab_video: Button = $VBoxContainer/TabRow/VideoTab
@onready var _tab_controls: Button = $VBoxContainer/TabRow/ControlsTab

@onready var _audio_panel: Control = $VBoxContainer/Content/AudioPanel
@onready var _video_panel: Control = $VBoxContainer/Content/VideoPanel
@onready var _controls_panel: Control = $VBoxContainer/Content/ControlsPanel

@onready var _master_slider: HSlider = $VBoxContainer/Content/AudioPanel/MasterSlider
@onready var _sfx_slider: HSlider = $VBoxContainer/Content/AudioPanel/SFXSlider
@onready var _music_slider: HSlider = $VBoxContainer/Content/AudioPanel/MusicSlider
@onready var _ambience_slider: HSlider = $VBoxContainer/Content/AudioPanel/AmbienceSlider

@onready var _fullscreen_check: CheckBox = $VBoxContainer/Content/VideoPanel/FullscreenCheck
@onready var _scale_options: OptionButton = $VBoxContainer/Content/VideoPanel/ScaleOptions

@onready var _controls_list: VBoxContainer = $VBoxContainer/Content/ControlsPanel/ControlsList
@onready var _close_btn: Button = $VBoxContainer/CloseButton

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
	_close_btn.pressed.connect(_on_close)
	
	# Audio sliders
	_master_slider.value_changed.connect(_on_master_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	_ambience_slider.value_changed.connect(_on_ambience_changed)
	
	# Video
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_scale_options.item_selected.connect(_on_scale_selected)
	
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
	
	_tab_audio.modulate = Color.WHITE if tab == Tab.AUDIO else Color(0.5, 0.5, 0.5)
	_tab_video.modulate = Color.WHITE if tab == Tab.VIDEO else Color(0.5, 0.5, 0.5)
	_tab_controls.modulate = Color.WHITE if tab == Tab.CONTROLS else Color(0.5, 0.5, 0.5)

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
