extends Node

signal health_changed(new_health: int, max_health: int)
signal resonance_changed(new_resonance: int, max_resonance: int)
signal shards_changed(new_count: int)
signal room_completed(room_id: String)

var max_health: int = 3
var health: int = 3:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health, max_health)

var max_resonance: int = 100
var resonance: int = 100:
	set(value):
		resonance = clampi(value, 0, max_resonance)
		resonance_changed.emit(resonance, max_resonance)

var shards: int = 0:
	set(value):
		shards = maxi(value, 0)
		shards_changed.emit(shards)

var rooms_completed: Dictionary = {}
var current_room: String = ""
var checkpoint_position: Vector2 = Vector2.ZERO

# Abilities unlocked by the player
var abilities: Dictionary = {}

# Persistent state for room-to-room transitions
var _persistent_health: int = 3
var _persistent_resonance: int = 100
var _persistent_shards: int = 0
var _persistent_rooms: Dictionary = {}

# Transition state (survives scene changes because this is an autoload)
var _is_transitioning: bool = false
var _pending_room_path: String = ""
var _pending_spawn_point: Vector2 = Vector2(60, 180)

func _ready() -> void:
	reset_run()

func reset_run() -> void:
	health = max_health
	resonance = max_resonance
	shards = 0
	rooms_completed.clear()
	abilities.clear()
	current_room = ""
	checkpoint_position = Vector2.ZERO
	_clear_persistent_state()
	_is_transitioning = false
	_pending_room_path = ""
	_pending_spawn_point = Vector2(60, 180)

func save_persistent_state() -> void:
	_persistent_health = health
	_persistent_resonance = resonance
	_persistent_shards = shards
	_persistent_rooms = rooms_completed.duplicate()

func restore_persistent_state() -> void:
	health = _persistent_health
	resonance = _persistent_resonance
	shards = _persistent_shards
	rooms_completed = _persistent_rooms.duplicate()

func unlock_ability(ability_name: String) -> void:
	abilities[ability_name] = true

func has_ability(ability_name: String) -> bool:
	return abilities.get(ability_name, false)

func _clear_persistent_state() -> void:
	_persistent_health = max_health
	_persistent_resonance = max_resonance
	_persistent_shards = 0
	_persistent_rooms.clear()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_respawn()

func heal(amount: int) -> void:
	health += amount

func consume_resonance(amount: int) -> bool:
	if resonance >= amount:
		resonance -= amount
		return true
	return false

func restore_resonance(amount: int) -> void:
	resonance += amount

func add_shards(amount: int) -> void:
	shards += amount

func mark_room_completed(room_id: String) -> void:
	rooms_completed[room_id] = true
	room_completed.emit(room_id)

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos

func _respawn() -> void:
	health = max_health
	resonance = max_resonance
	# Notify player to respawn at checkpoint
	var tree := Engine.get_main_loop() as SceneTree
	if tree:
		var player := tree.get_first_node_in_group("player") as Node2D
		if player and player.has_method("respawn_at"):
			player.respawn_at(checkpoint_position if checkpoint_position != Vector2.ZERO else Vector2(60, 180))
