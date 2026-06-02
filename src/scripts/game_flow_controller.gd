class_name GameFlowController
extends Node

enum State { TITLE, PLAYING, PAUSED, GAME_OVER_SUCCESS, GAME_OVER_FAILURE }

var _current_state: State = State.TITLE

@onready var _title_screen = null
@onready var _pause_menu = null
@onready var _game_over_screen = null
@onready var _room_controller = null
@onready var _player = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Find or create UI nodes
	var root := get_tree().current_scene
	
	_title_screen = root.get_node_or_null("TitleScreen")
	_pause_menu = root.get_node_or_null("PauseMenu")
	_game_over_screen = root.get_node_or_null("GameOverScreen")
	_room_controller = root.get_node_or_null("RoomController")
	_player = root.get_node_or_null("Player")
	
	if _title_screen:
		if _title_screen.has_signal("start_game_pressed"):
			_title_screen.start_game_pressed.connect(_on_start_game)
		if _title_screen.has_signal("quit_game_pressed"):
			_title_screen.quit_game_pressed.connect(_on_quit_game)
	
	if _pause_menu:
		if _pause_menu.has_signal("resume_pressed"):
			_pause_menu.resume_pressed.connect(_on_resume)
		if _pause_menu.has_signal("restart_pressed"):
			_pause_menu.restart_pressed.connect(_on_restart)
		if _pause_menu.has_signal("quit_to_title_pressed"):
			_pause_menu.quit_to_title_pressed.connect(_on_quit_to_title)
	
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
		State.GAME_OVER_SUCCESS:
			get_tree().paused = true
			if _game_over_screen and _game_over_screen.has_method("show_success"):
				var shards := _room_controller.completion_shards if _room_controller and _room_controller.has_method("is_completed") else 0
				_game_over_screen.show_success(shards)
		State.GAME_OVER_FAILURE:
			get_tree().paused = true
			if _game_over_screen and _game_over_screen.has_method("show_failure"):
				_game_over_screen.show_failure()

func _exit_state(state: State) -> void:
	pass

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

func _on_room_completed() -> void:
	_enter_state(State.GAME_OVER_SUCCESS)

func _on_room_failed() -> void:
	_enter_state(State.GAME_OVER_FAILURE)

func _reset_game() -> void:
	GameState.reset_run()
	
	if _room_controller and _room_controller.has_method("reset_room"):
		_room_controller.reset_room()
	
	if _player and _player.has_method("respawn_at"):
		_player.respawn_at(Vector2(60, 180))
		if _player.has_method("set_speed_multiplier"):
			_player.set_speed_multiplier(1.0)
	
	# Easiest way: reload the entire scene
	var root := get_tree().current_scene
	var current_path := root.scene_file_path
	if current_path:
		get_tree().change_scene_to_file(current_path)
