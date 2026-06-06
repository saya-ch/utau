extends Node

signal health_changed(new_health: int, max_health: int)
signal resonance_changed(new_resonance: int, max_resonance: int)
signal shards_changed(new_count: int)
signal room_completed(room_id: String)

var base_max_health: int = 3
var base_max_resonance: int = 100
# T068 — max_health / max_resonance are now derived (base + perk bonus).
# Keeps `health` setter's clampi(value, 0, max_health) honest after the
# player buys heart_crystal / resonance_chime.  base_* is the immutable
# starter value; perks live in max_*_bonus above.
var max_health: int:
	get: return base_max_health + max_health_bonus
var max_resonance: int:
	get: return base_max_resonance + max_resonance_bonus

var health: int = 3:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health, max_health)

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

# T068 — Shop / permanent perks. Keyed by shop item id (heart_crystal,
# resonance_chime, pulse_focus, echo_charm, silence_breaker). Each value
# is the number of times the player has bought that perk. Bonus fields
# below are derived from this map at _ready and after each purchase.
var purchased_perks: Dictionary = {}
var max_health_bonus: int = 0
var max_resonance_bonus: int = 0
var pulse_radius_bonus: int = 0
var echo_radius_bonus: int = 0
# T096 — pulse_kill_refund is kept for save-data backward compatibility
# (older runs bought `echo_charm` when it was mis-tagged as a pulse
# kill-refund perk).  The perk is now echo_radius_bonus; the field
# stays at 0 for new purchases and only gets non-zero from legacy
# save files, where it is read but not actively written to.
var pulse_kill_refund: int = 0
var damage_bonus: int = 0

# Persistent state for room-to-room transitions
var _persistent_health: int = 3
var _persistent_resonance: int = 100
var _persistent_shards: int = 0
var _persistent_rooms: Dictionary = {}
var _persistent_perks: Dictionary = {}

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
	# T068 — Perks are persistent across runs (bought with shards you earned
	# in a previous run carries over to a new run).  The bonus fields
	# derived from the perk map stay populated.
	_recompute_perk_bonuses()
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
	_persistent_perks = purchased_perks.duplicate()

func restore_persistent_state() -> void:
	health = _persistent_health
	resonance = _persistent_resonance
	shards = _persistent_shards
	rooms_completed = _persistent_rooms.duplicate()
	purchased_perks = _persistent_perks.duplicate()
	_recompute_perk_bonuses()

func unlock_ability(ability_name: String) -> void:
	abilities[ability_name] = true

func has_ability(ability_name: String) -> bool:
	return abilities.get(ability_name, false)

func _clear_persistent_state() -> void:
	_persistent_health = max_health
	_persistent_resonance = max_resonance
	_persistent_shards = 0
	_persistent_rooms.clear()
	_persistent_perks.clear()

# === T068 — Shop / permanent perks ===

# Returns the number of times the player has bought the named perk.
# 0 means never bought. ShopMenu uses this to cap purchases at max_purchases
# and to render "已购买 X/Y" labels.
func get_perk_count(perk_id: String) -> int:
	return int(purchased_perks.get(perk_id, 0))

# Attempt to buy a perk. Returns true on success, false if the player
# can't afford it, has hit the max_purchases cap, or the perk id is
# unknown.  On success, the shards balance is debited and the perk
# count is incremented, then the derived bonus fields are recomputed.
func purchase_perk(perk_id: String, price_shards: int, max_purchases: int) -> bool:
	if get_perk_count(perk_id) >= max_purchases:
		return false
	if shards < price_shards:
		return false
	shards -= price_shards
	purchased_perks[perk_id] = get_perk_count(perk_id) + 1
	_recompute_perk_bonuses()
	# Reflect the purchase in the persistent state too so a scene
	# transition that calls save_persistent_state() doesn't lose it.
	_persistent_perks = purchased_perks.duplicate()
	return true

# Internal: rebuilds the bonus fields from purchased_perks. Called by
# _ready, reset_run, restore_persistent_state, and purchase_perk.
# Lookup table mirrors data/shop_catalog.json — keep the two in sync.
func _recompute_perk_bonuses() -> void:
	max_health_bonus = get_perk_count("heart_crystal") * 1
	max_resonance_bonus = get_perk_count("resonance_chime") * 25
	pulse_radius_bonus = get_perk_count("pulse_focus") * 6
	# T096 — echo_charm now grants an Echo shield radius bonus (was
	# previously pulse_kill_refund, which was a #35 T068 mis-tag).
	echo_radius_bonus = get_perk_count("echo_charm") * 8
	# pulse_kill_refund intentionally not recomputed — see field comment.
	damage_bonus = get_perk_count("silence_breaker") * 1

# === Bonus getters — single source of truth for ability scripts and HUD ===

func get_max_health_bonus() -> int:
	return max_health_bonus

func get_max_resonance_bonus() -> int:
	return max_resonance_bonus

func get_pulse_radius_bonus() -> int:
	return pulse_radius_bonus

# T096 — Echo shield radius bonus from the echo_charm perk. EchoAbility
# adds this onto its exported echo_radius on _ready (and on shop purchase
# re-apply, see ShopMenu._on_buy_pressed).
func get_echo_radius_bonus() -> int:
	return echo_radius_bonus

func get_pulse_kill_refund() -> int:
	return pulse_kill_refund

func get_damage_bonus() -> int:
	return damage_bonus

# Emits the existing health/resonance signals without changing the
# underlying values.  Used by ShopMenu after a perk changes the max
# (e.g. buying heart_crystal bumps max_health from 3 to 4 but
# current health stays at 3 — the HUD bell layout still needs to
# re-render to show 4 bells).
func refresh_vitals() -> void:
	health_changed.emit(health, max_health)
	resonance_changed.emit(resonance, max_resonance)

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
