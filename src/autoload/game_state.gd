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

# T079 — Death respawn policy.  When true (default), the player is
# teleported back to the Hub safe-room after dying, regardless of
# which archive they were in.  This is the forgiving default — the
# game is short, a 5-10 minute skill-check isn't the point, and the
# Hub is the natural "lobby" anyway.  When false, the player
# respawns at the last Save Lantern checkpoint (or scene default).
# Toggle lives in SettingsMenu → Saves tab; persisted to settings.cfg.
var respawn_to_hub: bool = true
const HUB_SAFE_ROOM_PATH := "res://src/scenes/hub_room.tscn"
const HUB_SAFE_SPAWN := Vector2(240, 210)

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
		# T075 — prefer animated death sequence. If the player has a
		# die() method (production), it plays the 1.5s lay-down + fade
		# animation and then calls _respawn() itself at the end of the
		# tween. If not (test / older code), fall back to the instant
		# respawn so we never leave the player stuck at 0 HP.
		var tree := Engine.get_main_loop() as SceneTree
		if tree:
			var player := tree.get_first_node_in_group("player") as Node
			if player and player.has_method("die"):
				player.die()
				return
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
	# Always restore vitals first — Hub teleport and checkpoint respawn
	# both need the player at full strength.
	health = max_health
	resonance = max_resonance

	# T079 — Death respawn policy.  Default = teleport to Hub safe-room
	# (forgiving, prevents the "die in archive_03 → respawn inside
	# archive_03, fail again, infinite loop" trap the previous build
	# had when the checkpoint was unset).  The toggle in SettingsMenu
	# flips respawn_to_hub off for the classic "continue in current
	# room" experience.
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		return
	var root := tree.current_scene
	var is_hub: bool = root != null and root.has_node("HubController")

	if respawn_to_hub and not is_hub:
		# Need to teleport.  Set up the same transition fields the
		# GFC uses for door-entered transitions, then change scene.
		# The new Hub scene's GFC._ready will see _is_transitioning
		# and call _recover_from_transition() to land the player at
		# the Hub safe-spawn point.
		_pending_room_path = HUB_SAFE_ROOM_PATH
		_pending_spawn_point = HUB_SAFE_SPAWN
		_is_transitioning = true
		save_persistent_state()
		# Defensive: if a save_lantern was activated after the death
		# animation started (race-y in extreme edge cases), the
		# checkpoint survives the scene switch via the persistent
		# state.  Clear it so the next room respawn uses the Hub
		# spawn, not the soon-to-be-undefined checkpoint.
		checkpoint_position = Vector2.ZERO
		tree.change_scene_to_file(HUB_SAFE_ROOM_PATH)
		return

	# "Continue in current room" path (or already in Hub).  Land the
	# player at the last Save Lantern checkpoint, falling back to
	# the Hub safe-spawn in Hub or to (60, 180) in any archive that
	# has no Save Lantern set.
	var spawn: Vector2
	if is_hub:
		spawn = HUB_SAFE_SPAWN
	elif checkpoint_position != Vector2.ZERO:
		spawn = checkpoint_position
	else:
		spawn = Vector2(60, 180)
	var player := tree.get_first_node_in_group("player") as Node2D
	if player and player.has_method("respawn_at"):
		player.respawn_at(spawn)

func set_respawn_to_hub(value: bool) -> void:
	respawn_to_hub = value

func get_respawn_to_hub() -> bool:
	return respawn_to_hub
