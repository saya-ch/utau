extends Node

## SaveSystem — 持久化存档系统 (autoload)
##
## 职责：
## 1. 将 GameState.to_snapshot() 序列化到 user://saves/slot_N.json
## 2. 反序列化回 Dictionary 供 GameState.from_snapshot() 恢复
## 3. 列出 / 删除存档槽位供 SaveLoadMenu 使用
##
## 存档布局（v1）：
##   user://saves/slot_0.json  — 玩家手动存档
##   user://saves/slot_1.json
##   user://saves/slot_2.json
##   user://saves/slot_auto.json — SaveLantern 触发的自动存档
##
## 格式：
##   {
##     "version": 1,
##     "slot_index": 0,         // -1 表示 auto slot
##     "timestamp_unix": 12345,
##     "room_count": 3,         // rooms_completed.size() 缓存
##     "shard_total": 42,       // 共鸣碎片总数
##     "snapshot": { ... }      // GameState.to_snapshot() 输出
##   }
##
## 隔离原则：PlayerStats（成就/累计统计）独立持久化，不进入本系统。

const SAVE_DIR: String = "user://saves"
const SLOT_COUNT: int = 3              # 玩家手动存档槽数
const AUTO_SLOT_KEY: String = "slot_auto"  # 自动存档路径与手动槽互不冲突
const SLOT_FORMAT_VERSION: int = 1

signal slot_saved(slot_index: int, is_auto: bool)
signal slot_loaded(slot_index: int, is_auto: bool)
signal slot_deleted(slot_index: int, is_auto: bool)

func _ready() -> void:
	add_to_group("save_system")
	_ensure_dir()

# === 路径辅助 ===

func _ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var err: int = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		if err != OK:
			push_warning("SaveSystem: failed to create %s (err=%d)" % [SAVE_DIR, err])

func slot_path(slot_index: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot_index]

func auto_slot_path() -> String:
	return "%s/%s.json" % [SAVE_DIR, AUTO_SLOT_KEY]

# === 核心 API ===

func save_slot(slot_index: int, snapshot: Dictionary) -> bool:
	_ensure_dir()
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		push_warning("SaveSystem: invalid slot_index=%d" % slot_index)
		return false
	var envelope := _build_envelope(slot_index, false, snapshot)
	return _write_envelope(slot_path(slot_index), envelope)

func save_auto(snapshot: Dictionary) -> bool:
	_ensure_dir()
	var envelope := _build_envelope(-1, true, snapshot)
	return _write_envelope(auto_slot_path(), envelope)

func load_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		push_warning("SaveSystem: invalid slot_index=%d" % slot_index)
		return {}
	return _read_envelope(slot_path(slot_index))

func load_auto() -> Dictionary:
	return _read_envelope(auto_slot_path())

func delete_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false
	var path := slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return false
	var err: int = DirAccess.remove_absolute(path)
	if err != OK:
		push_warning("SaveSystem: failed to delete %s (err=%d)" % [path, err])
		return false
	slot_deleted.emit(slot_index, false)
	return true

func delete_auto() -> bool:
	var path := auto_slot_path()
	if not FileAccess.file_exists(path):
		return false
	var err: int = DirAccess.remove_absolute(path)
	if err != OK:
		push_warning("SaveSystem: failed to delete auto (err=%d)" % path)
		return false
	slot_deleted.emit(-1, true)
	return true

func has_slot(slot_index: int) -> bool:
	return FileAccess.file_exists(slot_path(slot_index))

func has_auto() -> bool:
	return FileAccess.file_exists(auto_slot_path())

# === 槽位摘要（供 UI 显示） ===

func get_slot_summary(slot_index: int) -> Dictionary:
	var env := load_slot(slot_index)
	if env.is_empty():
		return {"exists": false, "slot_index": slot_index}
	return {
		"exists": true,
		"slot_index": slot_index,
		"timestamp_unix": int(env.get("timestamp_unix", 0)),
		"room_count": int(env.get("room_count", 0)),
		"shard_total": int(env.get("shard_total", 0)),
		"version": int(env.get("version", 0)),
	}

func get_auto_summary() -> Dictionary:
	var env := load_auto()
	if env.is_empty():
		return {"exists": false, "slot_index": -1}
	return {
		"exists": true,
		"slot_index": -1,
		"timestamp_unix": int(env.get("timestamp_unix", 0)),
		"room_count": int(env.get("room_count", 0)),
		"shard_total": int(env.get("shard_total", 0)),
		"version": int(env.get("version", 0)),
	}

func list_all_summaries() -> Array:
	var out: Array = []
	for i in range(SLOT_COUNT):
		out.append(get_slot_summary(i))
	return out

# === 内部 ===

func _build_envelope(slot_index: int, is_auto: bool, snapshot: Dictionary) -> Dictionary:
	var rooms: Dictionary = snapshot.get("rooms_completed", {})
	var shards: int = int(snapshot.get("shards", 0))
	return {
		"version": SLOT_FORMAT_VERSION,
		"slot_index": slot_index if not is_auto else -1,
		"is_auto": is_auto,
		"timestamp_unix": int(Time.get_unix_time_from_system()),
		"room_count": rooms.size(),
		"shard_total": shards,
		"snapshot": snapshot,
	}

func _write_envelope(path: String, envelope: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveSystem: failed to open %s for write (err=%d)" % [path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(envelope, "\t"))
	file.close()
	if envelope.get("is_auto", false):
		slot_saved.emit(-1, true)
	else:
		slot_saved.emit(int(envelope.get("slot_index", -1)), false)
	return true

func _read_envelope(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("SaveSystem: failed to open %s for read (err=%d)" % [path, FileAccess.get_open_error()])
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_warning("SaveSystem: invalid JSON in %s" % path)
		return {}
	var version: int = int(parsed.get("version", 0))
	if version != SLOT_FORMAT_VERSION:
		push_warning("SaveSystem: unknown save version=%d in %s" % [version, path])
		return {}
	return parsed

# === 辅助格式化（供 UI 使用） ===

func format_timestamp(unix_seconds: int) -> String:
	if unix_seconds <= 0:
		return "—"
	var dt := Time.get_datetime_dict_from_unix_time(unix_seconds)
	return "%04d-%02d-%02d %02d:%02d" % [
		dt.get("year", 0), dt.get("month", 0), dt.get("day", 0),
		dt.get("hour", 0), dt.get("minute", 0)
	]
