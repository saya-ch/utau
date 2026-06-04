class_name GameFlowController
extends Node

enum State { TITLE, PLAYING, PAUSED, ROOM_TRANSITION, GAME_OVER_SUCCESS, GAME_OVER_FAILURE }

var _current_state: State = State.TITLE

@onready var _title_screen = null
@onready var _pause_menu = null
@onready var _game_over_screen = null
@onready var _room_controller = null
@onready var _player = null
@onready var _room_transition = null

var _is_final_room: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_flow_controller")

	# Find or create UI nodes
	var root := get_tree().current_scene

	# Defensive: in --script / SceneTree-only mode (e.g. smoke tests) the
	# current_scene can be null because no main scene is registered.
	# Bail out cleanly so the GFC node can still be added to a group
	# without crashing the host process.
	if root == null:
		push_warning("GameFlowController: no current_scene in _ready (deferred setup skipped)")
		return
	
	_title_screen = root.get_node_or_null("TitleScreen")
	_pause_menu = root.get_node_or_null("PauseMenu")
	_game_over_screen = root.get_node_or_null("GameOverScreen")
	_room_controller = root.get_node_or_null("RoomController")
	_player = root.get_node_or_null("Player")
	
	# Add room transition overlay if not present
	_room_transition = root.get_node_or_null("RoomTransition")
	if not _room_transition:
		var rt_scene := load("res://src/scenes/room_transition.tscn") as PackedScene
		if rt_scene:
			_room_transition = rt_scene.instantiate()
			# Defer add_child: during _ready() the parent is still mid-setup
			# and a synchronous add_child triggers
			# "Parent node is busy setting up children, add_child() failed"
			# (T052). The overlay appears next frame, which is invisible
			# because the player cannot see a single-frame delay.
			root.add_child.call_deferred(_room_transition)
	
	if _title_screen:
		if _title_screen.has_signal("start_game_pressed"):
			_title_screen.start_game_pressed.connect(_on_start_game)
		if _title_screen.has_signal("quit_game_pressed"):
			_title_screen.quit_game_pressed.connect(_on_quit_game)
		# T070 — continue from slot (TitleScreen "继续修复" button)
		if _title_screen.has_signal("continue_game_pressed"):
			_title_screen.continue_game_pressed.connect(_on_continue_game)
		if _title_screen.has_signal("save_load_closed"):
			_title_screen.save_load_closed.connect(_on_title_save_load_closed)

	if _pause_menu:
		if _pause_menu.has_signal("resume_pressed"):
			_pause_menu.resume_pressed.connect(_on_resume)
		if _pause_menu.has_signal("settings_pressed"):
			_pause_menu.settings_pressed.connect(_on_settings)
		if _pause_menu.has_signal("restart_pressed"):
			_pause_menu.restart_pressed.connect(_on_restart)
		if _pause_menu.has_signal("quit_to_title_pressed"):
			_pause_menu.quit_to_title_pressed.connect(_on_quit_to_title)
		# T070 — save to slot (PauseMenu "保存进度" button)
		if _pause_menu.has_signal("save_requested"):
			_pause_menu.save_requested.connect(_on_pause_save_requested)
	
	if _game_over_screen:
		if _game_over_screen.has_signal("retry_pressed"):
			_game_over_screen.retry_pressed.connect(_on_retry)
		if _game_over_screen.has_signal("quit_to_title_pressed"):
			_game_over_screen.quit_to_title_pressed.connect(_on_quit_to_title)
	
	if _room_controller:
		if _room_controller.has_signal("room_completed"):
			_room_controller.room_completed.connect(_on_room_completed)
		if _room_controller.has_signal("room_failed"):
			_room_controller.room_failed.connect(_on_room_failed)
		_is_final_room = _room_controller.room_id == "archive_final"
	
	# Detect hub mode: a Hub room has a HubController sibling; skip TITLE and
	# go straight to PLAYING. Hub rooms don't show a title screen — the player
	# has already started a run and is now in a safe area.
	var is_hub_mode: bool = root.has_node("HubController")

	# T079 — Check _is_transitioning FIRST so a teleport-into-Hub
	# (e.g. death → respawn to safe room) goes through the standard
	# recover path (player respawn_at, fade in, restore_persistent_state)
	# instead of skipping directly to PLAYING and leaving the player
	# at the old scene's last position (which is now freed).
	if GameState._is_transitioning:
		_recover_from_transition()
	elif is_hub_mode:
		_enter_state(State.PLAYING)
	else:
		# Initial state: show title, hide gameplay
		_enter_state(State.TITLE)

func _enter_state(new_state: State) -> void:
	_exit_state(_current_state)
	_current_state = new_state

	match new_state:
		State.TITLE:
			get_tree().paused = true
			if _title_screen and _title_screen.has_method("show_screen"):
				_title_screen.show_screen()
			if _pause_menu:
				_pause_menu.hide()
			if _game_over_screen:
				_game_over_screen.hide()
		State.PLAYING:
			get_tree().paused = false
			if _title_screen:
				_title_screen.hide()
			if _pause_menu:
				_pause_menu.hide()
			if _game_over_screen:
				_game_over_screen.hide()
		State.PAUSED:
			get_tree().paused = true
			if _pause_menu:
				_pause_menu.show()
		State.ROOM_TRANSITION:
			get_tree().paused = true
		State.GAME_OVER_SUCCESS:
			get_tree().paused = true
			if _game_over_screen and _game_over_screen.has_method("show_success"):
				var total_shards := GameState.shards
				_game_over_screen.show_success(total_shards)
		State.GAME_OVER_FAILURE:
			get_tree().paused = true
			if _game_over_screen and _game_over_screen.has_method("show_failure"):
				_game_over_screen.show_failure()

	# T063 — BGM routing: each scene type gets its own ambient theme.
	# play_music_track is a no-op when the same key is already playing,
	# so this is safe to call on every state transition.
	_play_music_for_state(new_state)

func _play_music_for_state(state: State) -> void:
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if not ame or not ame.has_method("play_music_track"):
		return

	var root := get_tree().current_scene
	# During scene transitions root may be the old scene briefly — that's
	# fine, the new scene's GFC will overwrite the BGM in its _ready.
	if not root:
		return

	match state:
		State.TITLE:
			ame.call("play_music_track", "title_intro", 1500)
		State.PLAYING:
			if root.has_node("HubController"):
				ame.call("play_music_track", "hub_warm", 1200)
			elif root.has_node("RoomController"):
				# Archive rooms (or any JSON room with a RoomController)
				ame.call("play_music_track", "archive_exploration", 1200)
		State.GAME_OVER_SUCCESS, State.GAME_OVER_FAILURE:
			# Let the result screen speak; stop the loop
			ame.call("stop_music", 1200)
		_:
			# PAUSED, ROOM_TRANSITION — keep current BGM
			pass

func _exit_state(state: State) -> void:
	pass

func _recover_from_transition() -> void:
	# Restore player position and state
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player and player.has_method("respawn_at"):
		player.respawn_at(GameState._pending_spawn_point)

	# Restore persistent stats
	GameState.restore_persistent_state()

	# Fade in
	# _room_transition may be added via call_deferred (T052), so its tree
	# entry happens one frame after _ready. Wait one extra frame so its
	# child ColorRect's _ready() also runs; otherwise tween_property hits
	# "Required object 'rp_target' is null" because the modulate property
	# doesn't exist yet.
	if _room_transition and _room_transition.has_method("fade_in"):
		if _room_transition.is_inside_tree():
			await get_tree().process_frame
		if _room_transition and is_instance_valid(_room_transition):
			_room_transition.fade_in(0.5)

	GameState._is_transitioning = false
	_enter_state(State.PLAYING)

func _on_start_game() -> void:
	_reset_game()
	_enter_state(State.PLAYING)

func _on_quit_game() -> void:
	get_tree().quit()

func _on_resume() -> void:
	_enter_state(State.PLAYING)

func _on_restart() -> void:
	_reset_game()
	_enter_state(State.PLAYING)

func _on_retry() -> void:
	_reset_game()
	_enter_state(State.PLAYING)

func _on_quit_to_title() -> void:
	_enter_state(State.TITLE)

func _on_settings() -> void:
	var settings := get_tree().current_scene.get_node_or_null("SettingsMenu") as SettingsMenu
	if settings:
		settings.show_menu()

# === T070 — 存档/读档流程 ===

func _on_continue_game(slot_id: int) -> void:
	# TitleScreen → SaveLoadMenu → 玩家选了 slot N 上的"读取"。
	# 1. 取 scene 路径
	# 2. load_from_slot 还原 GameState/PlayerStats
	# 3. 用 GFC._on_door_entered 走标准 transition 切场景
	var scene_path: String = SaveSystem.get_continue_scene_path(slot_id)
	if scene_path.is_empty():
		push_warning("GameFlowController: slot %d has no scene path" % slot_id)
		return
	if not SaveSystem.load_from_slot(slot_id):
		push_warning("GameFlowController: failed to load slot %d" % slot_id)
		return
	# The saved checkpoint becomes the spawn point for the loaded scene.
	GameState._pending_room_path = scene_path
	GameState._pending_spawn_point = GameState.checkpoint_position
	GameState._is_transitioning = true
	# The new scene's GFC._ready will see _is_transitioning and call
	# _recover_from_transition(), which sets the player at the checkpoint.
	# We bypass the fade and switch immediately because the SaveLoadMenu
	# is on top of TitleScreen, so there's no "playing state" to fade out
	# of — the player reads the slot info and we just teleport.
	_enter_state(State.ROOM_TRANSITION)
	if _room_transition and _room_transition.has_method("fade_out"):
		# Optional: short fade so the screen doesn't snap. Use a very
		# short duration so the player feels the action is responsive.
		if not _room_transition.transition_finished.is_connected(_do_room_switch):
			_room_transition.transition_finished.connect(_do_room_switch)
		_room_transition.fade_out(0.3)
	else:
		_do_room_switch()

func _on_pause_save_requested(slot_id: int) -> void:
	# PauseMenu → SaveLoadMenu → 玩家选了 slot N 上的"保存"。
	# 直接写盘 + HUD 提示。PauseMenu 自己负责关闭 SaveLoadMenu 并保持打开。
	var ok := SaveSystem.save_to_slot(slot_id)
	if ok:
		# Show a small toast in HUD area. Use the existing repair_hint
		# label (Amber Voice tone matches save success feedback).
		var hud := get_tree().current_scene.get_node_or_null("HUD") as Node
		if hud and hud.has_method("show_repair_hint"):
			hud.call("show_repair_hint", "进度已保存到槽位 %d" % slot_id)

func _on_title_save_load_closed() -> void:
	# SaveLoadMenu 关闭（无操作 / 返回键）— 重新显示 title。
	if _current_state == State.TITLE and _title_screen and _title_screen.has_method("show_screen"):
		_title_screen.show_screen()

func _on_room_completed() -> void:
	if _is_final_room:
		_enter_state(State.GAME_OVER_SUCCESS)
	else:
		# Find and open the room door
		var door := get_tree().get_first_node_in_group("room_door") as RoomDoor
		if door:
			door.enable_trigger()
			if door.has_signal("player_entered"):
				if not door.player_entered.is_connected(_on_door_entered):
					door.player_entered.connect(_on_door_entered)
		else:
			# No door found, show success screen
			_enter_state(State.GAME_OVER_SUCCESS)

func _on_room_failed() -> void:
	_enter_state(State.GAME_OVER_FAILURE)

func _on_door_entered(target_room_path: String) -> void:
	if target_room_path.is_empty():
		return

	# Save transition info in GameState (autoload survives scene change)
	GameState._pending_room_path = target_room_path

	# Prefer caller-supplied spawn point (e.g. HubController when multiple
	# doors each have their own target_spawn_point). Fall back to scanning
	# the first room_door in the group, which works for non-Hub rooms with
	# a single door.
	if GameState._pending_spawn_point == Vector2.ZERO:
		var door := get_tree().get_first_node_in_group("room_door") as RoomDoor
		if door:
			GameState._pending_spawn_point = door.target_spawn_point

	_enter_state(State.ROOM_TRANSITION)

	# Fade out, then switch scene
	if _room_transition and _room_transition.has_method("fade_out"):
		if not _room_transition.transition_finished.is_connected(_do_room_switch):
			_room_transition.transition_finished.connect(_do_room_switch)
		_room_transition.fade_out(0.4)
	else:
		_do_room_switch()

## Multi-door entrypoint used by HubController: explicit spawn point overrides
## the group's first door. Mirrors _on_door_entered otherwise.
func _on_door_with_spawn_entered(target_room_path: String, spawn_point: Vector2) -> void:
	if target_room_path.is_empty():
		return
	GameState._pending_room_path = target_room_path
	if spawn_point != Vector2.ZERO:
		GameState._pending_spawn_point = spawn_point
	_on_door_entered(target_room_path)

func _do_room_switch() -> void:
	if _room_transition:
		_room_transition.transition_finished.disconnect(_do_room_switch)
	
	# Save persistent state before switching
	GameState.save_persistent_state()
	GameState._is_transitioning = true
	
	# Switch to next room
	get_tree().change_scene_to_file(GameState._pending_room_path)

func _reset_game() -> void:
	GameState.reset_run()
	_is_final_room = false
	
	if _room_controller and _room_controller.has_method("reset_room"):
		_room_controller.reset_room()
	
	if _player and _player.has_method("respawn_at"):
		_player.respawn_at(Vector2(60, 180))
		if _player.has_method("set_speed_multiplier"):
			_player.set_speed_multiplier(1.0)
	
	# Reload the entire scene to reset everything
	var root := get_tree().current_scene
	var current_path := root.scene_file_path
	if current_path:
		get_tree().change_scene_to_file(current_path)
