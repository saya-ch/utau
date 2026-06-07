class_name TitleScreen
extends Control

signal start_game_pressed
signal continue_game_pressed(slot_id: int)  # T070
signal quit_game_pressed
signal credits_opened
signal credits_closed
signal save_load_closed  # T070

@export var title_text: String = "VOXGLASS"
@export var subtitle_text: String = "修复被寂静吞噬的声音"

@onready var _title_label: Label = $VBoxContainer/TitleLabel
@onready var _subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var _start_btn: Button = $VBoxContainer/StartButton
@onready var _continue_btn: Button = $VBoxContainer/ContinueButton
@onready var _credits_btn: Button = $VBoxContainer/CreditsButton
@onready var _quit_btn: Button = $VBoxContainer/QuitButton
@onready var _credits_screen: CreditsScreen = $CreditsScreen
@onready var _save_load_menu: SaveLoadMenu = $SaveLoadMenu

func _ready() -> void:
	_title_label.text = title_text
	_subtitle_label.text = subtitle_text

	_start_btn.pressed.connect(_on_start)
	_credits_btn.pressed.connect(_on_credits)
	_quit_btn.pressed.connect(_on_quit)
	_continue_btn.pressed.connect(_on_continue)

	_credits_screen.closed.connect(_on_credits_closed)

	# T070 — SaveLoadMenu signal wiring
	_save_load_menu.load_requested.connect(_on_save_load_loaded)
	_save_load_menu.delete_requested.connect(_on_save_load_deleted)
	_save_load_menu.save_requested.connect(_on_save_load_saved)
	_save_load_menu.closed.connect(_on_save_load_closed_local)
	_refresh_continue_visibility()

	# Fade in
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.8)

	# T066 — Pre-warm BGM streams.  The synthesis cost (~2-3s for
	# 4 tracks at 22050Hz on the main thread) is deferred to the
	# next idle frame so the title fade-in animation keeps priority.
	# By the time the player reads the title and clicks "开始", all
	# 4 preset streams (title_intro / hub_warm / archive_exploration /
	# archive_boss) are already in the AudioManagerEnhanced cache,
	# and the first scene switch incurs zero synthesis latency.
	call_deferred("_prewarm_bgm")

func _refresh_continue_visibility() -> void:
	# Show "继续修复" only if at least one save slot has data.
	var any_save := false
	for i in range(SaveSystem.SLOT_COUNT):  # T088: 3 → SaveSystem.SLOT_COUNT (5)
		if SaveSystem.has_save(i):
			any_save = true
			break
	_continue_btn.visible = any_save

func _prewarm_bgm() -> void:
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("prewarm_music_streams"):
		ame.call("prewarm_music_streams")

func _on_start() -> void:
	_set_buttons_disabled(true)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(func() -> void:
		start_game_pressed.emit()
		hide()
	)

func _on_continue() -> void:
	_set_buttons_disabled(true)
	_save_load_menu.mode = "select"
	_save_load_menu.refresh()
	_save_load_menu.show_menu()

func _on_save_load_loaded(slot_id: int) -> void:
	# Player chose "读取" on a slot.  Fade title, then hand the slot
	# to GFC for actual load + scene switch.
	_save_load_menu.hide_menu()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.25)
	tween.tween_callback(func() -> void:
		continue_game_pressed.emit(slot_id)
		hide()
	)

func _on_save_load_saved(_slot_id: int) -> void:
	# TitleScreen SaveLoadMenu is select-only; saving here is a no-op
	# (button is disabled).  Defensive: refresh in case a save was
	# deleted from another path.
	_save_load_menu.refresh()

func _on_save_load_deleted(slot_id: int) -> void:
	SaveSystem.delete_slot(slot_id)
	_save_load_menu.refresh()
	_refresh_continue_visibility()

func _on_save_load_closed_local() -> void:
	# User pressed 返回; we restore title buttons.
	_set_buttons_disabled(false)
	# T070 — also forward to GFC so any state machine hooks can react.
	save_load_closed.emit()

func _on_credits() -> void:
	_set_buttons_disabled(true)
	credits_opened.emit()
	_credits_screen.show_screen()

func _on_credits_closed() -> void:
	credits_closed.emit()
	_set_buttons_disabled(false)

func _on_quit() -> void:
	quit_game_pressed.emit()
	get_tree().quit()

func show_screen() -> void:
	show()
	modulate = Color.TRANSPARENT
	_set_buttons_disabled(false)
	_refresh_continue_visibility()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func _set_buttons_disabled(disabled: bool) -> void:
	_start_btn.disabled = disabled
	_continue_btn.disabled = disabled
	_credits_btn.disabled = disabled
	_quit_btn.disabled = disabled
