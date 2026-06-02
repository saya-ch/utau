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

func _ready() -> void:
	reset_run()

func reset_run() -> void:
	health = max_health
	resonance = max_resonance
	shards = 0
	rooms_completed.clear()
	current_room = ""
	checkpoint_position = Vector2.ZERO

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
