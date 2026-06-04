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
	# Reset per-run stats (achievements persist)
	PlayerStats.reset_stats()
	# Reset tutorial hint groups so they re-show on new run
	for tut in get_tree().get_nodes_in_group("tutorial_hint"):
		if tut.has_method("reset_shown"):
			tut.reset_shown()

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
		# Stats tracking: count death before respawn
		PlayerStats.record_death()
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

# === 存档快照（T070 持久化磁盘版） ===

func to_snapshot() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"resonance": resonance,
		"max_resonance": max_resonance,
		"shards": shards,
		"rooms_completed": rooms_completed.duplicate(),
		"current_room": current_room,
		"checkpoint_position": [checkpoint_position.x, checkpoint_position.y],
		"abilities": abilities.duplicate(),
	}

func from_snapshot(snap: Dictionary) -> void:
	if snap == null or snap.is_empty():
		push_warning("GameState.from_snapshot: empty snapshot, ignoring")
		return
	max_health = int(snap.get("max_health", max_health))
	max_resonance = int(snap.get("max_resonance", max_resonance))
	# 注意：health / resonance / shards 的 setter 含 clampi / maxi 与信号触发，
	# 写入顺序应与 reset_run() 一致。
	health = max_health
	resonance = max_resonance
	shards = 0
	# 然后覆盖真实值（保留 setter 信号链路）
	health = int(snap.get("health", max_health))
	resonance = int(snap.get("resonance", max_resonance))
	shards = int(snap.get("shards", 0))
	rooms_completed = (snap.get("rooms_completed", {}) as Dictionary).duplicate(true)
	current_room = str(snap.get("current_room", ""))
	var cp_raw: Variant = snap.get("checkpoint_position", [0.0, 0.0])
	if cp_raw is Array and cp_raw.size() >= 2:
		checkpoint_position = Vector2(float(cp_raw[0]), float(cp_raw[1]))
	abilities = (snap.get("abilities", {}) as Dictionary).duplicate(true)
