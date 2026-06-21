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
# T195 (#112) — accessibility 减弱视觉反馈 (reduce_shake / reduce_flash).
# 视频标签末尾, "无障碍" 副标题之下. live-push 到 ScreenShake autoload
# 让玩家勾选立即生效, 不用关闭 menu. 配置持久化在 user://settings.cfg
# [accessibility] section.
@onready var _reduce_shake_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceShakeCheck
@onready var _reduce_flash_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceFlashCheck
# T196 (#113) — accessibility 减弱触觉反馈 第三个 CheckBox. 与 T195 reduce_shake
# / reduce_flash 同一区域 (VideoPanel 末尾), 跨设备: 桌面手柄 + iOS/Android
# 振动统一走 ScreenShake.vibrate() 路由, 玩家勾选后 vibrate() 早退.
@onready var _reduce_vibration_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceVibrationCheck
# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度 4 滑块 (HUD 5 verb
# cooldown bar 灰化). 与 T195 减弱屏幕震动 / T195 减弱屏幕闪烁 / T196 减
# 弱手柄振动 同一区域 (VideoPanel 末尾, 4 滑块并列). 玩家勾选后 5 verb
# cooldown bar (Pulse / Bind / Cut / Echo / Wave) 立即从 5 主题色降饱和
# 度到 0.55 灰度 75% 透明 (modulate 乘到 ProgressBar), 色相差保留, 5 verb
# 仍可一眼区分. 与 T195/T196 不同: 此 flag 不拦截 ScreenShake 内部任何
# 路由, 它是 hud.gd 主动查询的状态字段, 互不耦合. T200 (#117) 原本把
# 此视觉绑定到 is_reduce_flash(), T203 (#118) 拆出独立 4 滑块, 玩家可
# 分别控制 "屏幕闪" (verb 命中 / 死亡灰洗) 和 "HUD 冷却条色饱和度"
# (常驻 HUD 反馈). 配置持久化在 user://settings.cfg [accessibility]
# section reduce_cooldown_color key.
@onready var _reduce_cooldown_color_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceCooldownColorCheck
# T203 (#118) — accessibility 1 总开关. 联动 4 滑块 (reduce_shake /
# reduce_flash / reduce_vibration / reduce_cooldown_color). 玩家一键勾
# 选 = 4 个子开关全部 ON, 一键取消 = 4 个子开关全部 OFF. 玩家在总开关
# ON 后仍可单独关闭其中任意 1 个 (独立 toggle 不被 master 反向覆盖, 之
# 后改 master 才再次覆盖). 适合 "全部减弱" 玩家 1 键配置. 配置持久化
# 在 user://settings.cfg [accessibility] section accessibility_master
# key (默认 false = 总开关关闭, 子开关状态独立). 总开关与子开关是 OR
# 关系: _on_reduce_*_toggled 写实际状态时 master 状态不影响 4 子字段,
# 但 master toggle 时强制把 4 个子字段同步到 master 状态.
@onready var _accessibility_master_check: CheckBox = $VBoxContainer/Content/VideoPanel/AccessibilityMasterCheck

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
# T161 — 一键"还原所有推荐设置"按钮。位于 VBoxContainer 底部
# (Close 之上), 颜色 = Amber Voice (0.949, 0.714, 0.431) 以便
# 与"恢复默认按键"区分层级 (后者仅恢复 keys, 前者恢复全部).
@onready var _restore_all_btn: Button = $VBoxContainer/RestoreAllButton

# T072 — modal confirmation dialog for "Delete All Saves"
var _confirm_dialog: ConfirmationDialog = null

# T103 — 第五动词 Wave 群体波（V 键）从 #74 轮起加入重映射菜单。
# 跟 Pulse(J)/Bind(K)/Cut(L)/Echo(B)/Wave(V) 的 5 动词组对称，
# 玩家可以在设置里改键。
# T194 (#112) — Echo (Q) 之前遗漏, 5 动词只显示 4 个 (Pulse/Bind/Cut/Wave).
# 修复: 在 cut 与 wave 之间补回 echo = "Echo 反射护盾", 让 5 动词全部可重映射.
# 顺序: pulse → bind → cut → echo → wave 严格按 verb 听觉坐标 (T181 5 verb audio
# family 顺序) + STYLE_GUIDE 5 verb 调色五元组顺序, 让 settings 列表与游戏内
# HUD 5 verb 冷却条顺序完全一致 (玩家从左到右看: pulse / bind / cut / echo / wave).
const ACTION_NAMES := {
	"move_left": "向左移动",
	"move_right": "向右移动",
	"jump": "跳跃",
	"pulse": "Pulse 声波",
	"bind": "Bind 牵引",
	"cut": "Cut 斩断",
	"echo": "Echo 反射护盾",
	"interact": "交互",
	"wave": "Wave 群体波",
}

# T194 (#112) — ACTION_CATEGORY 把 9 个 actions 切成 3 组 (移动 / 声波能力 / 交互).
# 用于 _build_controls_list() 渲染时插入分组标题 Label, 让玩家一眼区分
# "这是走路用的" / "这是 5 verb 用的" / "这是对话用的". 渲染顺序与 ACTION_NAMES
# 一致 (移动 3 个 → 5 verb → 交互 1 个); 9 actions 严格字典序. 任何 ACTION_NAMES
# 增删都需要同步更新这里的 section_index, 否则 smoke test 会 fail.
const ACTION_CATEGORY := {
	"move_left": "movement",
	"move_right": "movement",
	"jump": "movement",
	"pulse": "verb",
	"bind": "verb",
	"cut": "verb",
	"echo": "verb",
	"wave": "verb",
	"interact": "interact",
}

# T194 (#112) — 渲染顺序常量, 控制 _build_controls_list 插入分组标题的位置.
# 每项: section_index = 第一个该组 action 在 ACTION_NAMES 字典里的位置.
# "移动" 在 0/1/2, "声波能力" 在 3-7 (5 verb), "交互" 在 8.
const CATEGORY_RENDER_ORDER := [
	{"name": "移动",     "key": "movement", "color": Color(0.718, 0.906, 0.867, 1)},  # Pale Resonance
	{"name": "声波能力", "key": "verb",     "color": Color(0.949, 0.714, 0.431, 1)},  # Amber Voice
	{"name": "交互",     "key": "interact", "color": Color(0.412, 0.78, 0.808, 1)},   # Glass Cyan
]

# T195 (#112) — 减弱视觉反馈选项 (accessibility). 玩家在视频标签下勾选
# "减弱屏幕震动" / "减弱屏幕闪烁" 后, ScreenShake autoload 内的 _reduced_shake
# / _reduced_flash 状态字段会被推到 1, 之后 shake() / flash_color() /
# flash_grayscale() 入口早退 (no-op). 配置持久化在 user://settings.cfg
# [accessibility] section, 与 T136 autosave 模式一致 (live-push 立即生效).
var _reduced_shake: bool = false
var _reduced_flash: bool = false
# T196 (#113) — 减弱触觉反馈选项 (accessibility). 玩家勾选 "减弱手柄振动"
# 后 ScreenShake._reduced_vibration 推到 1, 之后 vibrate() 入口早退 (no-op,
# 玩家手柄不震 / 手机不嗡 但仍听见 SFX / 看见屏抖 + VFX). 跨设备: 桌面
# 手柄 Input.start_joy_vibration + iOS/Android Input.vibrate_handheld 统一
# 走 ScreenShake.vibrate() 路由, 一处 set 全平台 no-op. 与 T195 reduce_shake
# 模式一致 (独立字段独立 CheckBox, 玩家可分别控制视觉 / 触觉反馈).
var _reduced_vibration: bool = false
# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度 (HUD 5 verb
# cooldown bar 灰化). 玩家勾选 "减弱冷却条颜色" 后 ScreenShake._reduced_
# cooldown_color 推到 1, hud.gd _process() 查询 is_reduce_cooldown_color()
# 切换 5 verb bar modulate (0.55 灰阶 75% 透明, 色相差保留). 与 T200
# (#117) 区别: T200 把此视觉绑定到 is_reduce_flash() 减少玩家调节粒度,
# T203 拆出独立 4 滑块, 玩家可分别控制 "屏幕闪" 和 "HUD 冷却条色饱和度"
# (例如: 玩家可开 screen flash 仍要 verb 命中色闪, 但常驻 HUD bar 灰化
# 减少高饱和度色块; 或反之). 与 _reduced_shake/_reduced_flash/_reduced_
# vibration 不同: 此 flag 不拦截 ScreenShake 内部 flash/shake/vibrate
# 路由, 它是 hud.gd 主动查询的状态字段, 互不耦合.
var _reduced_cooldown_color: bool = false
# T203 (#118) — accessibility 1 总开关字段. 状态在 [accessibility]
# section accessibility_master key 持久化 (默认 false). 注意: master
# 是 *联动* 状态, 不是 *OR* 状态 — _on_accessibility_master_toggled
# 把 4 个子字段强制同步到 master 状态, 子字段独立 toggle 不会反向更
# 新 master (玩家可 master=ON 后单独关 1 个, 但 master 状态保留 ON).
# 这避免了 "master=ON 子 1 单独 OFF 后下次 toggle master 误把刚被
# 玩家保留 OFF 的子 1 改回 ON" 这种认知陷阱.
var _accessibility_master: bool = false

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
	"wave":       {"type": "key", "physical_keycode": 86},   # V
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

	# T195 (#112) — accessibility 减弱视觉反馈 toggle. live-push 到
	# ScreenShake autoload, 玩家勾选立刻生效. 配置在 _load_settings() / _save_settings()
	# 走 [accessibility] section.
	_reduce_shake_check.toggled.connect(_on_reduce_shake_toggled)
	_reduce_flash_check.toggled.connect(_on_reduce_flash_toggled)
	# T196 (#113) — accessibility 减弱触觉反馈 toggle. live-push 到 ScreenShake
	# autoload, 与 T195 reduce_shake 同样模式: 玩家勾选立即生效 (不停 menu).
	_reduce_vibration_check.toggled.connect(_on_reduce_vibration_toggled)
	# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度 toggle. live-push
	# 到 ScreenShake autoload, 与 T195 reduce_shake / T196 reduce_vibration
	# 同模式: 玩家勾选立即生效 (不停 menu). 注意: 此 flag 在 ScreenShake 内
	# 仅是状态字段 (不被 shake/flash/vibrate 入口检查), 实际消费者是 hud.gd
	# _process() 主动查询 is_reduce_cooldown_color() 切 5 verb bar modulate.
	_reduce_cooldown_color_check.toggled.connect(_on_reduce_cooldown_color_toggled)
	# T203 (#118) — accessibility 1 总开关 toggle. 联动 4 滑块 (reduce_shake
	# / reduce_flash / reduce_vibration / reduce_cooldown_color). 注意: master
	# 触发后用 set_block_signals 设 4 个子开关 + 推 ScreenShake, 避免循环触
	# 发 _on_reduce_*_toggled handler + 多次 cfg 写. 子开关独立 toggle 不会
	# 反向更新 master 状态 (玩家可 master=ON 后单独关 1 个, master 状态保留
	# ON, 下次 toggle master 才再次覆盖).
	_accessibility_master_check.toggled.connect(_on_accessibility_master_toggled)
	
	# T072 — Saves tab
	_delete_all_btn.pressed.connect(_on_delete_all_pressed)

	# T079 — Respawn policy toggle
	_respawn_hub_check.toggled.connect(_on_respawn_hub_toggled)

	# T086 — Reset to defaults
	_reset_defaults_btn.pressed.connect(_on_reset_defaults_pressed)

	# T161 — 还原所有推荐设置 (按键 + 音量 + autosave)
	_restore_all_btn.pressed.connect(_on_restore_all_pressed)

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

# === T195 (#112) — accessibility 减弱视觉反馈 ===
# 玩家勾选"减弱屏幕震动" / "减弱屏幕闪烁" 后, _reduced_shake / _reduced_flash
# 状态字段被推到 1, 同时调 ScreenShake.set_reduce_shake(true) / set_reduce_flash(true)
# 立即生效 (无需要关闭 menu). ScreenShake autoload 在 shake() / flash_color() /
# flash_grayscale() 入口检查 _reduced_shake / _reduced_flash 早退 (no-op).
# 配置走 [accessibility] section, 与 [audio] / [video] / [gameplay] 对称.
# 注意 has_method + autoload 守卫 (headless 测试 SceneTree 可能无 ScreenShake).
func _has_screen_shake_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("ScreenShake")

func _on_reduce_shake_toggled(enabled: bool) -> void:
	_reduced_shake = enabled
	if _has_screen_shake_autoload() and ScreenShake.has_method("set_reduce_shake"):
		ScreenShake.set_reduce_shake(enabled)

func _on_reduce_flash_toggled(enabled: bool) -> void:
	_reduced_flash = enabled
	if _has_screen_shake_autoload() and ScreenShake.has_method("set_reduce_flash"):
		ScreenShake.set_reduce_flash(enabled)

# T196 (#113) — accessibility 减弱触觉反馈 toggle handler. 模式与 T195 reduce_shake
# 完全一致: 玩家勾选 → _reduced_vibration 字段更新 → live-push 到 ScreenShake
# autoload → 之后所有 vibrate() 调用入口早退 (跨平台 Input.start_joy_vibration
# + Input.vibrate_handheld 全部 no-op). headless test SceneTree 可能无 ScreenShake
# autoload, _has_screen_shake_autoload() 守卫避免 SCRIPT ERROR.
func _on_reduce_vibration_toggled(enabled: bool) -> void:
	_reduced_vibration = enabled
	if _has_screen_shake_autoload() and ScreenShake.has_method("set_reduce_vibration"):
		ScreenShake.set_reduce_vibration(enabled)

# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度 toggle handler. 模式
# 与 T195 reduce_shake / T196 reduce_vibration 完全一致: 玩家勾选 → 字段
# 更新 → live-push 到 ScreenShake.autoload.set_reduce_cooldown_color → hud.gd
# _process() 下一帧查到 flag=true, 5 verb bar 立即切到 _REDUCED_COLOR_MODULATE
# (0.55 灰阶 75% 透明, 色相差保留). headless test SceneTree 可能无 ScreenShake
# autoload, _has_screen_shake_autoload() 守卫避免 SCRIPT ERROR. set_reduce_
# cooldown_color 是 T203 新增 API, has_method 守卫让 _load_settings 在老
# 存档 (没 reduce_cooldown_color key) 上不会崩.
func _on_reduce_cooldown_color_toggled(enabled: bool) -> void:
	_reduced_cooldown_color = enabled
	if _has_screen_shake_autoload() and ScreenShake.has_method("set_reduce_cooldown_color"):
		ScreenShake.set_reduce_cooldown_color(enabled)

# T203 (#118) — accessibility 1 总开关 toggle handler. 联动 4 滑块 (reduce_
# shake / reduce_flash / reduce_vibration / reduce_cooldown_color). 玩家一
# 键勾选 = 4 个子开关全部 ON, 一键取消 = 4 个子开关全部 OFF. 关键: master
# 触发后用 set_block_signals 设 4 个子开关 + 推 ScreenShake, 避免循环触发
# _on_reduce_*_toggled handler (4 handler 各写一次 cfg 浪费 4 I/O) + 多次
# ScreenShake.set_*. 子开关独立 toggle (玩家在 master=ON 后单独关 1 个)
# 不会反向更新 master 状态 — _on_reduce_*_toggled 4 个 handler 都不动
# _accessibility_master 字段, master 状态保留, 下次 toggle master 才再次
# 覆盖. 这避免了 "master=ON 子 1 单独 OFF 后下次 toggle master 误把刚被
# 玩家保留 OFF 的子 1 改回 ON" 这种认知陷阱 — master 总是 1 键同步源.
func _on_accessibility_master_toggled(enabled: bool) -> void:
	_accessibility_master = enabled
	# 用 set_block_signals 避免 4 个子开关 emit toggled → 4 handler 各
	# 写 1 次 cfg (4 I/O) + 4 次 ScreenShake.set_* call. master 一次性
	# 同步 4 个, cfg 写只在 _save_settings 关 menu 时统一做.
	_set_accessibility_subcheck(enabled)
	if _has_screen_shake_autoload():
		if ScreenShake.has_method("set_reduce_shake"):
			ScreenShake.set_reduce_shake(enabled)
		if ScreenShake.has_method("set_reduce_flash"):
			ScreenShake.set_reduce_flash(enabled)
		if ScreenShake.has_method("set_reduce_vibration"):
			ScreenShake.set_reduce_vibration(enabled)
		if ScreenShake.has_method("set_reduce_cooldown_color"):
			ScreenShake.set_reduce_cooldown_color(enabled)

# T203 (#118) — master 联动 4 子开关 内部 helper. master toggle 时一次性
# 设 4 个子 CheckBox + 同步 4 个 _reduced_* 字段, 用 set_block_signals 避
# 免 _on_reduce_*_toggled handler 重复触发. 4 子字段同步后 cfg 在下次
# _save_settings 关 menu 时统一写, 不写 4 次 (4 I/O → 1 I/O).
func _set_accessibility_subcheck(enabled: bool) -> void:
	var subchecks: Array = [
		_reduce_shake_check, _reduce_flash_check,
		_reduce_vibration_check, _reduce_cooldown_color_check,
	]
	for c in subchecks:
		if c:
			c.set_block_signals(true)
			c.button_pressed = enabled
			c.set_block_signals(false)
	_reduced_shake = enabled
	_reduced_flash = enabled
	_reduced_vibration = enabled
	_reduced_cooldown_color = enabled

# Controls
# T194 (#112) — _build_controls_list 渲染 3 段式 (移动 / 声波能力 / 交互).
# 之前 8 actions (echo 缺) 全部平铺, 玩家看不出 "这是 5 verb" / "这是走路".
# 现在按 ACTION_CATEGORY + CATEGORY_RENDER_ORDER 顺序, 在每组前插 1 个
# 分组标题 Label (color = CATEGORY_RENDER_ORDER[].color, font_size=8, 居左).
# 标题与 _remap_flash_confirm 一致 (PALE_RESONANCE / AMBER_VOICE / GLASS_CYAN).
func _build_controls_list() -> void:
	# Clear existing
	for child in _controls_list.get_children():
		child.queue_free()

	# 1) 先按 CATEGORY_RENDER_ORDER 顺序遍历每个分组
	for section in CATEGORY_RENDER_ORDER:
		var section_key: String = section["key"]
		# 2) 在该组第一个 action 之前插入分组标题 Label
		var section_header_added := false
		for action in ACTION_NAMES.keys():
			# 3) 跳过不属于当前分组的所有 actions
			if not ACTION_CATEGORY.has(action):
				continue
			if ACTION_CATEGORY[action] != section_key:
				continue
			# 4) 第一个匹配: 插 1 个分组标题 Label
			if not section_header_added:
				var header := Label.new()
				header.text = "— " + section["name"] + " —"
				header.modulate = section["color"]
				header.add_theme_font_size_override("font_size", 8)
				header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				_controls_list.add_child(header)
				section_header_added = true
			# 5) 渲染该 action 自己的 row (label + remap btn)
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

# T161 — 一键还原所有推荐设置：默认按键 + 默认音量 + 默认 autosave
# 三个分组一次清空，配套使用 _DEFAULT_BINDINGS / 1.0 / SaveSystem
# 默认值（与 T136 / T086 完全相同）。注意 Slider 推值后我们手动
# emit 一次 value_changed 以触发 _on_*_changed handler（_on_*
# 的设计是"手动改 Slider → handler 改 AudioServer/SaveSystem
# → 立即生效"），这样调一次 set_value 即可让所有子系统同步。
# 用 set_block_signals 避免循环重入或不必要的 cfg write。
func _on_restore_all_pressed() -> void:
	# 取消 in-flight remap, 否则监听按钮会显示陈旧 event
	if _remapping_action != "":
		_cancel_remap()

	# === 1) 按键：复用 _on_reset_defaults_pressed 的逻辑 ===
	for action in ACTION_NAMES.keys():
		InputMap.action_erase_events(action)
		var def: Dictionary = _DEFAULT_BINDINGS.get(action, {})
		if def.is_empty():
			continue
		if def["type"] == "key":
			var ev := InputEventKey.new()
			ev.physical_keycode = int(def["physical_keycode"])
			InputMap.action_add_event(action, ev)
	_build_controls_list()

	# === 2) 音量：主/音效/音乐/环境音 → 1.0 (100%) ===
	# set_block_signals 避免 slider 0..1 → 100 × 100 → handler
	# 把音量推 4 次（CPU 无关但对 0.05s 内的 4 次 db 写入是冗余），
	# 一次性手动 set_value + 主动 handler call 更干净。
	const DEFAULT_VOLUME := 1.0
	_master_slider.set_block_signals(true)
	_master_slider.value = DEFAULT_VOLUME * 100.0
	_master_slider.set_block_signals(false)
	_sfx_slider.set_block_signals(true)
	_sfx_slider.value = DEFAULT_VOLUME * 100.0
	_sfx_slider.set_block_signals(false)
	_music_slider.set_block_signals(true)
	_music_slider.value = DEFAULT_VOLUME * 100.0
	_music_slider.set_block_signals(false)
	_ambience_slider.set_block_signals(true)
	_ambience_slider.value = DEFAULT_VOLUME * 100.0
	_ambience_slider.set_block_signals(false)
	# 应用到 AudioServer（与 _on_*_changed 内的逻辑一致）
	AudioServer.set_bus_volume_db(0, linear_to_db(DEFAULT_VOLUME))
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(DEFAULT_VOLUME))
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx != -1:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(DEFAULT_VOLUME))
	var amb_idx := AudioServer.get_bus_index("Ambience")
	if amb_idx != -1:
		AudioServer.set_bus_volume_db(amb_idx, linear_to_db(DEFAULT_VOLUME))
	_master_volume = DEFAULT_VOLUME
	_sfx_volume = DEFAULT_VOLUME
	_music_volume = DEFAULT_VOLUME
	_ambience_volume = DEFAULT_VOLUME

	# === 3) Autosave: enabled=true, interval=60s, slot=0 ===
	# 同步控件视觉（block_signals 避免触发 handler 后又重写一次
	# SaveSystem）+ 主动调用 setter 推一次到 SaveSystem。Set
	# block_signals 不影响 _populate_autosave_controls_from_cfg
	# 已经做过的事，但既然 _restore_all_btn 在玩家打开 menu
	# 后就触发，控件当前就是 menu 打开时的状态（未必是默认），
	# 所以必须重新设一遍。
	_autosave_enabled_check.set_block_signals(true)
	_autosave_enabled_check.button_pressed = true
	_autosave_enabled_check.set_block_signals(false)
	_autosave_interval_slider.set_block_signals(true)
	_autosave_interval_slider.value = 60.0
	_autosave_interval_slider.set_block_signals(false)
	_refresh_autosave_interval_label(60.0)
	# Slot 0: 重建选项 + 选 0
	_build_autosave_slot_options(0)
	# 推到 SaveSystem（持久化 + 启动 timer）
	if _has_save_system_autoload():
		SaveSystem.set_autosave_enabled(true)
		SaveSystem.set_autosave_interval(60.0)
		SaveSystem.set_autosave_slot(0)

	# === 4) T195 (#112) — accessibility 减弱视觉反馈: 还原默认 (off) ===
	# "还原所有推荐设置" 的语义是"打开游戏的最原始状态", 玩家未主动勾选
	# 时 reduce_shake/flash 都应是 off, 所以这里显式 uncheck + 推 ScreenShake.
	_reduce_shake_check.set_block_signals(true)
	_reduce_shake_check.button_pressed = false
	_reduce_shake_check.set_block_signals(false)
	_reduce_flash_check.set_block_signals(true)
	_reduce_flash_check.button_pressed = false
	_reduce_flash_check.set_block_signals(false)
	_reduced_shake = false
	_reduced_flash = false
	if _has_screen_shake_autoload():
		if ScreenShake.has_method("set_reduce_shake"):
			ScreenShake.set_reduce_shake(false)
		if ScreenShake.has_method("set_reduce_flash"):
			ScreenShake.set_reduce_flash(false)
	# T196 (#113) — accessibility 减弱触觉反馈: 还原默认 (off). 与 T195 reduce_shake
	# 同模式: 显式 uncheck + 推 ScreenShake.set_reduce_vibration(false). 玩家未
	# 主动勾选时 reduce_vibration 应是 off (默认全功能, 振动开启).
	if _reduce_vibration_check:
		_reduce_vibration_check.set_block_signals(true)
		_reduce_vibration_check.button_pressed = false
		_reduce_vibration_check.set_block_signals(false)
	_reduced_vibration = false
	if _has_screen_shake_autoload() and ScreenShake.has_method("set_reduce_vibration"):
		ScreenShake.set_reduce_vibration(false)
	# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度: 还原默认 (off). 与
	# T195 reduce_shake / T196 reduce_vibration 模式一致: 显式 uncheck + 推
	# ScreenShake.set_reduce_cooldown_color(false). 玩家未主动勾选时此 flag 应
	# 是 off (默认全功能, 5 verb bar 全饱和度).
	if _reduce_cooldown_color_check:
		_reduce_cooldown_color_check.set_block_signals(true)
		_reduce_cooldown_color_check.button_pressed = false
		_reduce_cooldown_color_check.set_block_signals(false)
	_reduced_cooldown_color = false
	if _has_screen_shake_autoload() and ScreenShake.has_method("set_reduce_cooldown_color"):
		ScreenShake.set_reduce_cooldown_color(false)
	# T203 (#118) — accessibility 1 总开关: 还原默认 (off). master 关闭
	# 时不强制覆盖 4 个子开关 (玩家可保留之前的单独勾选). 这是有意的设计
	# — "还原所有推荐设置" 不应抹去玩家的细微偏好, 但 master 状态本身是
	# "全部减弱" 1 键便捷, 还原后玩家可重新 master=ON 一次性还原 4 子.
	if _accessibility_master_check:
		_accessibility_master_check.set_block_signals(true)
		_accessibility_master_check.button_pressed = false
		_accessibility_master_check.set_block_signals(false)
	_accessibility_master = false

	# 反馈：amber flash + 0.6s 文本 "✓ 已还原"
	var original_text := _restore_all_btn.text
	_restore_all_btn.modulate = Color(0.949, 0.714, 0.431, 1)
	_restore_all_btn.text = "✓ 已还原"
	var t := get_tree().create_timer(0.8)
	t.timeout.connect(func() -> void:
		if _restore_all_btn:
			_restore_all_btn.text = original_text
			_restore_all_btn.modulate = Color.WHITE
	)

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
	# T195 (#112) — accessibility 减弱视觉反馈. 写 [accessibility] section.
	# _save_settings() 走控制 live 状态而非 _reduced_shake / _reduced_flash 字段
	# (与 T136 autosave 同样的 last-writer-wins 模式), 保证 menu 关闭时 cfg
	# 反映当前勾选状态, 即使 setter live-push 提前写过一次.
	if _reduce_shake_check:
		cfg.set_value("accessibility", "reduce_shake", _reduce_shake_check.button_pressed)
	if _reduce_flash_check:
		cfg.set_value("accessibility", "reduce_flash", _reduce_flash_check.button_pressed)
	# T196 (#113) — accessibility 减弱触觉反馈. 同 T195 模式, 写 reduce_vibration
	# key 到 [accessibility] section. 玩家重启游戏后 _load_settings() 读回.
	if _reduce_vibration_check:
		cfg.set_value("accessibility", "reduce_vibration", _reduce_vibration_check.button_pressed)
	# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度. 同 T195/T196 模式,
	# 写 reduce_cooldown_color key 到 [accessibility] section. 玩家重启游戏后
	# _load_settings() 读回 (T200 #117 期间不存在此 key, 老存档 fallback 到 false,
	# 与 T200 之前 (没 reduce_flash) 行为一致 — 5 verb bar 不会因 T203 老存档错
	# 误降饱和度).
	if _reduce_cooldown_color_check:
		cfg.set_value("accessibility", "reduce_cooldown_color", _reduce_cooldown_color_check.button_pressed)
	# T203 (#118) — accessibility 1 总开关. 写 accessibility_master key 到
	# [accessibility] section. 玩家重启游戏后 _load_settings() 读回, master
	# 状态在 menu 打开时立即恢复 (4 子开关独立状态不重置, master 是 "全部减
	# 弱" 便捷入口, 玩家可 master=ON 后单独关 1 个保留, 下次 menu 打开时
	# 仍记忆这个细微偏好).
	if _accessibility_master_check:
		cfg.set_value("accessibility", "accessibility_master", _accessibility_master_check.button_pressed)

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

	# T195 (#112) — accessibility 减弱视觉反馈. 从 cfg 读 2 个 bool, 推
	# 控件 + 同步字段 + live-push 到 ScreenShake autoload (同 T136 模式).
	# set_block_signals 避免 _on_reduce_*_toggled 反复触发写 cfg, _load_settings
	# 一次写完. 写两次 (call set_reduce_*) 让 ScreenShake 立即遵守配置, 即使
	# _ready 比 settings_menu 早 1 帧.
	_reduced_shake = cfg.get_value("accessibility", "reduce_shake", false)
	_reduced_flash = cfg.get_value("accessibility", "reduce_flash", false)
	if _reduce_shake_check:
		_reduce_shake_check.set_block_signals(true)
		_reduce_shake_check.button_pressed = _reduced_shake
		_reduce_shake_check.set_block_signals(false)
	if _reduce_flash_check:
		_reduce_flash_check.set_block_signals(true)
		_reduce_flash_check.button_pressed = _reduced_flash
		_reduce_flash_check.set_block_signals(false)
	# T196 (#113) — accessibility 减弱触觉反馈. 读 reduce_vibration bool,
	# 与 T195 reduce_shake 完全同模式: 推控件 + set_block_signals + 同步
	# 字段 + live-push ScreenShake.set_reduce_vibration. 玩家重启游戏后
	# 一打开 settings menu, 之前勾选状态立即恢复.
	_reduced_vibration = cfg.get_value("accessibility", "reduce_vibration", false)
	if _reduce_vibration_check:
		_reduce_vibration_check.set_block_signals(true)
		_reduce_vibration_check.button_pressed = _reduced_vibration
		_reduce_vibration_check.set_block_signals(false)
	# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度. 读 reduce_
	# cooldown_color bool, 与 T195/T196 同模式: 推控件 + set_block_signals
	# + 同步字段 + live-push ScreenShake.set_reduce_cooldown_color. 老存档
	# (T200 #117 期间没此 key) fallback 到 false, 与 T200 之前 (没 reduce_
	# flash) 行为一致 — 5 verb bar 不会因 T203 老存档错误降饱和度.
	_reduced_cooldown_color = cfg.get_value("accessibility", "reduce_cooldown_color", false)
	if _reduce_cooldown_color_check:
		_reduce_cooldown_color_check.set_block_signals(true)
		_reduce_cooldown_color_check.button_pressed = _reduced_cooldown_color
		_reduce_cooldown_color_check.set_block_signals(false)
	# T203 (#118) — accessibility 1 总开关. 读 accessibility_master bool,
	# 推控件 + set_block_signals. master 字段仅供 4 子开关 toggle 时的联
	# 动源, _load_settings 不主动 set 4 子字段 (玩家 master=ON 后单独关 1
	# 个的状态必须保留, 不能被 master 状态反向覆盖). 老存档 fallback 到
	# false (总开关关闭, 4 子开关独立, 与无 master 设计时行为一致).
	_accessibility_master = cfg.get_value("accessibility", "accessibility_master", false)
	if _accessibility_master_check:
		_accessibility_master_check.set_block_signals(true)
		_accessibility_master_check.button_pressed = _accessibility_master
		_accessibility_master_check.set_block_signals(false)
	if _has_screen_shake_autoload():
		if ScreenShake.has_method("set_reduce_shake"):
			ScreenShake.set_reduce_shake(_reduced_shake)
		if ScreenShake.has_method("set_reduce_flash"):
			ScreenShake.set_reduce_flash(_reduced_flash)
		# T196 (#113) — accessibility 减弱触觉反馈. live-push 到 ScreenShake.
		if ScreenShake.has_method("set_reduce_vibration"):
			ScreenShake.set_reduce_vibration(_reduced_vibration)
		# T203 (#118) — accessibility 减弱 HUD 冷却条颜色饱和度. live-push
		# 到 ScreenShake. has_method 守卫让老存档 (没 reduce_cooldown_color)
		# 不会调用不存在的 API, 即使 ScreenShake 是 T203 之前版本也不崩.
		if ScreenShake.has_method("set_reduce_cooldown_color"):
			ScreenShake.set_reduce_cooldown_color(_reduced_cooldown_color)
	
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
