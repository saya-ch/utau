extends Node

## SaveSystem — 存档系统（autoload）
##
## 职责：
## 1. 提供 3 个存档槽位 (slot_0/1/2) 的写盘 / 读档 / 删除
## 2. 序列化 GameState 当前状态 + PlayerStats 已解锁成就
## 3. 持久化到 `user://saves/slot_N.json`，跨会话保留
## 4. 暴露查询 API：has_save(slot) / get_save_info(slot) / list_slots()
##
## 用法：
##   SaveSystem.save_to_slot(0)             # 自动收集 GameState + PlayerStats
##   SaveSystem.load_from_slot(0)           # 反序列化并 apply 到 autoload
##   SaveSystem.delete_slot(0)              # 删档
##   SaveSystem.get_save_info(0)            # 元数据（时间、房间、health 等）
##   SaveSystem.has_save(0)                 # 槽位是否有数据
##
## 数据契约：
##   save JSON 顶层包含 "version": 1（未来版本兼容用）
##   "game_state" 段：current_room / health / resonance / shards /
##                    rooms_completed / abilities / checkpoint_position /
##                    run_time_seconds
##   "achievements" 段：unlocked_ids（数组）
##   "meta" 段：slot_id / saved_at_unix / version

const SAVE_DIR := "user://saves"
const SLOT_COUNT := 3
const SAVE_VERSION := 1

# Mapping from room_id (as stored in GameState.current_room) to scene file
# path. Used to resume a save by loading the correct .tscn. The "main" entry
# is the legacy name for archive_01's first build (which still uses main.tscn
# as the scene path).
const ROOM_ID_TO_SCENE := {
	"archive_01": "res://src/scenes/main.tscn",
	"archive_02": "res://src/scenes/room_archive_02.tscn",
	"archive_03": "res://src/scenes/room_archive_03.tscn",
	"hub_room":   "res://src/scenes/hub_room.tscn"
}

signal save_completed(slot_id: int, success: bool, error_msg: String)
signal load_completed(slot_id: int, success: bool, error_msg: String)
signal delete_completed(slot_id: int, success: bool)

func _ready() -> void:
	add_to_group("save_system")
	_ensure_save_dir()

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var err := DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		if err != OK:
			push_warning("SaveSystem: failed to create save dir %s (err %d)" % [SAVE_DIR, err])

# === 公共 API ===

func get_scene_path_for_room(room_id: String) -> String:
	return ROOM_ID_TO_SCENE.get(room_id, "")

func get_current_scene_path() -> String:
	# Look up the scene path for whatever room the player is currently in.
	return get_scene_path_for_room(GameState.current_room)

func has_save(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		return false
	return FileAccess.file_exists(_slot_path(slot_id))

func list_slots() -> Array:
	# Returns [{slot_id, exists, info_dict or null}, ...]
	var result: Array = []
	for i in range(SLOT_COUNT):
		var entry := {"slot_id": i, "exists": has_save(i), "info": null}
		if entry["exists"]:
			entry["info"] = get_save_info(i)
		result.append(entry)
	return result

func get_save_info(slot_id: int) -> Dictionary:
	# Reads header-only info without applying the save.
	if not has_save(slot_id):
		return {}
	var data := _read_json(_slot_path(slot_id))
	if data.is_empty():
		return {}
	var meta = data.get("meta", {})
	var gs = data.get("game_state", {})
	var achv_count = (data.get("achievements", {}).get("unlocked_ids", []) as Array).size()
	return {
		"slot_id": slot_id,
		"version": data.get("version", 0),
		"saved_at_unix": meta.get("saved_at_unix", 0),
		"current_room": gs.get("current_room", ""),
		"current_scene": gs.get("current_scene", ""),
		"checkpoint_x": float(gs.get("checkpoint_x", 0.0)),
		"checkpoint_y": float(gs.get("checkpoint_y", 0.0)),
		"health": int(gs.get("health", 0)),
		"resonance": int(gs.get("resonance", 0)),
		"shards": int(gs.get("shards", 0)),
		"rooms_cleared": (gs.get("rooms_completed", []) as Array).size(),
		"achievements_unlocked": achv_count,
		"run_time_seconds": float(gs.get("run_time_seconds", 0.0))
	}

func get_continue_scene_path(slot_id: int) -> String:
	# Returns the scene path to load for a "Continue from slot N" action.
	# Reads from the slot directly so we don't have to fully apply the
	# snapshot just to discover which scene to switch to.
	if not has_save(slot_id):
		return ""
	var data := _read_json(_slot_path(slot_id))
	if data.is_empty():
		return ""
	var gs: Dictionary = data.get("game_state", {})
	var scene_path: String = String(gs.get("current_scene", ""))
	if scene_path.is_empty():
		# Fallback for old saves: derive from current_room id.
		scene_path = get_scene_path_for_room(String(gs.get("current_room", "")))
	return scene_path

func save_to_slot(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		save_completed.emit(slot_id, false, "invalid slot id")
		return false
	var snapshot := _build_snapshot()
	var path := _slot_path(slot_id)
	var err := _write_json(path, snapshot)
	if err != OK:
		save_completed.emit(slot_id, false, "write failed (err %d)" % err)
		return false
	save_completed.emit(slot_id, true, "")
	return true

func load_from_slot(slot_id: int) -> bool:
	if not has_save(slot_id):
		load_completed.emit(slot_id, false, "slot empty")
		return false
	var data := _read_json(_slot_path(slot_id))
	if data.is_empty():
		load_completed.emit(slot_id, false, "read failed or empty")
		return false
	if int(data.get("version", 0)) != SAVE_VERSION:
		load_completed.emit(slot_id, false, "version mismatch (have %d, want %d)" % [int(data.get("version", 0)), SAVE_VERSION])
		return false
	_apply_snapshot(data)
	load_completed.emit(slot_id, true, "")
	return true

func delete_slot(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		delete_completed.emit(slot_id, false)
		return false
	var err := DirAccess.remove_absolute(_slot_path(slot_id))
	if err != OK:
		delete_completed.emit(slot_id, false)
		return false
	delete_completed.emit(slot_id, true)
	return true

# T072 — Bulk delete all save slots at once.
# Used by the Settings menu "Delete All Saves" button. Iterates all
# configured slots, removes any file present, and emits
# delete_completed for each one. Returns the number of slots that
# were actually deleted (so the caller can show a "Deleted N saves"
# toast if it wants to).
func delete_all_saves() -> int:
	var deleted_count := 0
	for i in range(SLOT_COUNT):
		if not has_save(i):
			continue
		var err := DirAccess.remove_absolute(_slot_path(i))
		if err != OK:
			push_warning("SaveSystem: failed to delete slot %d (err %d)" % [i, err])
			delete_completed.emit(i, false)
			continue
		deleted_count += 1
		delete_completed.emit(i, true)
	return deleted_count

# === 内部：构建快照 / 反序列化 ===

func _build_snapshot() -> Dictionary:
	# Collect from GameState (per-run) + PlayerStats (achievements, persistent).
	# Use the autoload lookup pattern so this works whether the autoloads are
	# registered via project.godot (production) or instantiated manually
	# with their canonical names (tests).
	var gs := _get_autoload("GameState")
	var ps := _get_autoload("PlayerStats")
	if not gs or not ps:
		push_warning("SaveSystem: cannot build snapshot, autoloads missing (gs=%s ps=%s)" % [gs, ps])
		return {}
	var gs_dict := {
		"current_room": gs.current_room,
		"current_scene": get_scene_path_for_room(gs.current_room),
		"health": gs.health,
		"resonance": gs.resonance,
		"shards": gs.shards,
		"rooms_completed": gs.rooms_completed.keys(),
		"abilities": gs.abilities.duplicate(),
		"checkpoint_x": gs.checkpoint_position.x,
		"checkpoint_y": gs.checkpoint_position.y,
		"run_time_seconds": ps.get_run_time_seconds()
	}
	var unlocked: Array = []
	for id_val in ps._unlocked_ids.keys():
		unlocked.append(id_val)
	var achv_dict := {
		"unlocked_ids": unlocked
	}
	var meta_dict := {
		"slot_id": 0,  # overwritten by caller if needed
		"saved_at_unix": int(Time.get_unix_time_from_system())
	}
	return {
		"version": SAVE_VERSION,
		"meta": meta_dict,
		"game_state": gs_dict,
		"achievements": achv_dict
	}

func _apply_snapshot(data: Dictionary) -> void:
	var gs := _get_autoload("GameState")
	var ps := _get_autoload("PlayerStats")
	if not gs or not ps:
		push_warning("SaveSystem: cannot apply snapshot, autoloads missing")
		return
	var gs_data: Dictionary = data.get("game_state", {})
	# GameState mutation: use setters to ensure signals fire and clamping.
	gs.health = int(gs_data.get("health", gs.max_health))
	gs.resonance = int(gs_data.get("resonance", gs.max_resonance))
	gs.shards = int(gs_data.get("shards", 0))
	gs.rooms_completed.clear()
	for room_id in gs_data.get("rooms_completed", []):
		gs.rooms_completed[room_id] = true
	gs.abilities.clear()
	for ability in gs_data.get("abilities", {}).keys():
		gs.abilities[ability] = true
	gs.current_room = String(gs_data.get("current_room", ""))
	var cx: float = float(gs_data.get("checkpoint_x", 0.0))
	var cy: float = float(gs_data.get("checkpoint_y", 0.0))
	gs.checkpoint_position = Vector2(cx, cy)
	# Achievements: merge into PlayerStats._unlocked_ids without resetting.
	var achv: Dictionary = data.get("achievements", {})
	for id_val in achv.get("unlocked_ids", []):
		ps._unlocked_ids[id_val] = true
	# Emit stat_changed once so UI (pause menu, achievement grid) can refresh
	# for the freshly-restored achievements.
	for stat_name in ps._stat_names():
		ps.stat_changed.emit(stat_name, ps.get_stat(stat_name))
	# Re-emit achievement_unlocked? No — these were unlocked in a previous
	# session, we don't want to show a notification on load. The UI reads
	# PlayerStats.is_unlocked() to determine icon state.

func _get_autoload(name: String) -> Node:
	# Look up an autoload by its canonical name. Works in production
	# (where the autoloads are registered in project.godot) and in tests
	# (where they were manually added to the root with their canonical names).
	var main_loop: Object = Engine.get_main_loop()
	if main_loop == null:
		return null
	var root_node: Node = main_loop.root
	if root_node == null:
		return null
	return root_node.get_node_or_null(name)

# === 内部：文件 I/O ===

func _slot_path(slot_id: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot_id]

func _is_valid_slot(slot_id: int) -> bool:
	return slot_id >= 0 and slot_id < SLOT_COUNT

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("SaveSystem: failed to open %s (err %d)" % [path, FileAccess.get_open_error()])
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		push_warning("SaveSystem: invalid JSON in %s" % path)
		return {}
	return parsed

func _write_json(path: String, data: Dictionary) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var json_str := JSON.stringify(data, "  ")
	file.store_string(json_str)
	file.close()
	return OK

# === 调试辅助 ===

func format_slot_summary(slot_id: int) -> String:
	if not has_save(slot_id):
		return "槽位 %d: 空" % slot_id
	var info := get_save_info(slot_id)
	var unix := int(info.get("saved_at_unix", 0))
	var dt := Time.get_datetime_dict_from_unix_time(unix)
	var ts := "%04d-%02d-%02d %02d:%02d" % [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"]]
	return "槽位 %d: %s | 房间 %s | ♥%d  ◆%d  ✦%d  ⏱%ds" % [
		slot_id, ts, info.get("current_room", "?"),
		int(info.get("health", 0)), int(info.get("shards", 0)),
		int(info.get("achievements_unlocked", 0)), int(info.get("run_time_seconds", 0.0))
	]
