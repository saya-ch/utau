extends Node

## PlayerStats — 玩家统计与成就系统 (autoload)
##
## 职责：
## 1. 累计玩家行为（房间完成、敌人净化、碎片拾取、能力使用、死亡等）
## 2. 根据成就定义 (data/achievements.json) 判定解锁
## 3. 暴露信号供 UI 订阅（成就通知、统计面板刷新）
##
## 用法：
##   PlayerStats.record_stat("enemies_purified", 1)
##   PlayerStats.record_ability_used("pulse")

signal stat_changed(stat_name: String, new_value: int)
signal achievement_unlocked(achievement_id: String, title_zh: String, description_zh: String)

const ACHIEVEMENTS_PATH := "res://data/achievements.json"
const PERSIST_PATH := "user://achievements.json"

# === 累计统计 ===
var rooms_cleared: int = 0
var enemies_purified: int = 0
var ink_wardens_defeated: int = 0
var shards_collected: int = 0
var deaths: int = 0
var pulse_used: int = 0
var bind_used: int = 0
var cut_used: int = 0
var echo_used: int = 0
var echo_reflects: int = 0
var silence_webs_cut: int = 0
var save_lanterns_activated: int = 0

# === 成就状态 ===
var _achievements: Array = []               # 定义列表（来自 JSON）
var _unlocked_ids: Dictionary = {}          # id -> true（已解锁集合）
var _unlock_timestamps: Dictionary = {}     # id -> Unix seconds（T109 解锁时间戳）
var _definitions_by_id: Dictionary = {}      # id -> dict（快速查找）

# === 时间统计 ===
var _run_start_time: float = 0.0

func _ready() -> void:
	add_to_group("player_stats")
	_run_start_time = Time.get_ticks_msec() / 1000.0
	_load_achievements()
	_load_persistent_achievements()

func reset_stats() -> void:
	# 重置累计统计（每次新运行开始时调用）
	rooms_cleared = 0
	enemies_purified = 0
	ink_wardens_defeated = 0
	shards_collected = 0
	deaths = 0
	pulse_used = 0
	bind_used = 0
	cut_used = 0
	silence_webs_cut = 0
	save_lanterns_activated = 0
	_run_start_time = Time.get_ticks_msec() / 1000.0

	# 注意：不重置 _unlocked_ids，因为成就应当跨运行持久化
	# （也可以选择重置，看设计。这里采用 Steam 风格的「永久解锁」）

	# 触发所有 stat_changed 让 UI 同步
	for stat_name in _stat_names():
		stat_changed.emit(stat_name, get_stat(stat_name))

# === 统计读写 ===

func get_stat(stat_name: String) -> int:
	match stat_name:
		"rooms_cleared": return rooms_cleared
		"enemies_purified": return enemies_purified
		"ink_wardens_defeated": return ink_wardens_defeated
		"shards_collected": return shards_collected
		"deaths": return deaths
		"pulse_used": return pulse_used
		"bind_used": return bind_used
		"cut_used": return cut_used
		"echo_used": return echo_used
		"echo_reflects": return echo_reflects
		"silence_webs_cut": return silence_webs_cut
		"save_lanterns_activated": return save_lanterns_activated
		_: return 0

func record_stat(stat_name: String, amount: int = 1) -> void:
	var current := get_stat(stat_name)
	var new_value := current + amount
	_set_stat(stat_name, new_value)

func _set_stat(stat_name: String, value: int) -> void:
	match stat_name:
		"rooms_cleared": rooms_cleared = value
		"enemies_purified": enemies_purified = value
		"ink_wardens_defeated": ink_wardens_defeated = value
		"shards_collected": shards_collected = value
		"deaths": deaths = value
		"pulse_used": pulse_used = value
		"bind_used": bind_used = value
		"cut_used": cut_used = value
		"echo_used": echo_used = value
		"echo_reflects": echo_reflects = value
		"silence_webs_cut": silence_webs_cut = value
		"save_lanterns_activated": save_lanterns_activated = value
		_: return
	stat_changed.emit(stat_name, value)
	_check_achievements()

# === 便捷 API ===

func record_room_cleared() -> void:
	record_stat("rooms_cleared", 1)

func record_enemy_purified(enemy_type: String = "generic") -> void:
	record_stat("enemies_purified", 1)
	if enemy_type == "ink_warden":
		record_stat("ink_wardens_defeated", 1)

func record_shard_collected(amount: int = 1) -> void:
	record_stat("shards_collected", amount)

func record_death() -> void:
	record_stat("deaths", 1)

func record_ability_used(ability_name: String) -> void:
	match ability_name:
		"pulse": record_stat("pulse_used", 1)
		"bind": record_stat("bind_used", 1)
		"cut": record_stat("cut_used", 1)
		"echo": record_stat("echo_used", 1)

func record_echo_reflect() -> void:
	# Echo reflects don't reset the cooldown and aren't a separate
	# "ability use" — they're the side effect of an active shield.
	# Count them under their own stat for future "reflect N projectiles"
	# achievement hooks (none defined today, but cheap to track).
	record_stat("echo_reflects", 1)

func record_silence_web_cut() -> void:
	record_stat("silence_webs_cut", 1)

func record_save_lantern_activated() -> void:
	record_stat("save_lanterns_activated", 1)

# === 成就系统 ===

func _load_achievements() -> void:
	if not FileAccess.file_exists(ACHIEVEMENTS_PATH):
		push_warning("PlayerStats: achievements.json not found at %s" % ACHIEVEMENTS_PATH)
		return
	var file := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.READ)
	if file == null:
		push_warning("PlayerStats: failed to open achievements.json")
		return
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		push_warning("PlayerStats: failed to parse achievements.json")
		return
	_achievements = parsed.get("achievements", [])
	for ach in _achievements:
		var id_val: String = ach.get("id", "")
		if id_val != "":
			_definitions_by_id[id_val] = ach

func _check_achievements() -> void:
	for ach in _achievements:
		var id_val: String = ach.get("id", "")
		if id_val == "":
			continue
		if _unlocked_ids.get(id_val, false):
			continue
		if _evaluate_condition(ach.get("condition", {})):
			_unlock_achievement(id_val, ach)

func _evaluate_condition(cond: Dictionary) -> bool:
	if cond == null or cond.is_empty():
		return false
	var type_val: String = cond.get("type", "")
	match type_val:
		"stat_threshold":
			var stat_name: String = cond.get("stat", "")
			var min_val: int = cond.get("min", 1)
			return get_stat(stat_name) >= min_val
		"all_abilities_used":
			# T094 — Echo added as the 4th verb. The condition
			# `all_abilities_used` now means "use all FOUR verbs
			# at least once" (Pulse + Bind + Cut + Echo). The
			# `triple_voice` achievement's description still
			# reads as 3-verb, but the runtime check is identical
			# for both `triple_voice` and `quadruple_voice` —
			# achieving quadruple automatically grants both. We
			# could split the type into `triple_abilities_used`
			# and `all_abilities_used` later, but the simpler
			# "all four" definition rewards full mastery and
			# keeps the achievement list short.
			return pulse_used >= 1 and bind_used >= 1 and cut_used >= 1 and echo_used >= 1
		_:
			return false

func _unlock_achievement(id_val: String, definition: Dictionary) -> void:
	_unlocked_ids[id_val] = true
	# T109 — 记录解锁时间戳（Unix 秒）。空时用 0 表示未解锁，
	# 玩家看到"解锁于 -"占位。已存在则保留首次时间，避免
	# 反复 _check_achievements 触发时刷新时间。
	if not _unlock_timestamps.has(id_val):
		_unlock_timestamps[id_val] = int(Time.get_unix_time_from_system())
	_persist_achievements()  # write-through to disk on every unlock
	var title_zh: String = definition.get("title_zh", id_val)
	var desc_zh: String = definition.get("description_zh", "")
	achievement_unlocked.emit(id_val, title_zh, desc_zh)

	# T087 — On full_archive unlock, fade BGM to the "victory / dawn"
	# theme.  The standard GFC routing only plays archive_dawn on
	# GAME_OVER_SUCCESS, but full_archive is the moment the player
	# has actually completed the main story (3 archives) and
	# deserves the triumphant theme on the spot — the result
	# screen will then layer on top of the already-fading-in
	# dawn track.  Defensive: AME is an autoload, but in --script
	# / headless test contexts the autoload chain may not be set
	# up yet.  has_method guards avoid push_error noise in tests.
	if id_val == "full_archive":
		var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
		if ame and ame.has_method("play_music_track"):
			ame.call("play_music_track", "archive_dawn", 2400)

# === 磁盘持久化（成就） ===

func _persist_achievements() -> void:
	var ids: Array = []
	for id_val in _unlocked_ids.keys():
		ids.append(id_val)
	# T109 — 持久化解锁时间戳（id -> int Unix 秒）
	var stamps: Dictionary = {}
	for id_val in _unlock_timestamps.keys():
		stamps[id_val] = int(_unlock_timestamps[id_val])
	var data := {"version": 1, "unlocked_ids": ids, "unlock_timestamps": stamps}
	var file := FileAccess.open(PERSIST_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("PlayerStats: failed to write %s (err %d)" % [PERSIST_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data, "  "))
	file.close()

func _load_persistent_achievements() -> void:
	if not FileAccess.file_exists(PERSIST_PATH):
		return
	var file := FileAccess.open(PERSIST_PATH, FileAccess.READ)
	if file == null:
		return
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		return
	var ids = parsed.get("unlocked_ids", [])
	if not ids is Array:
		return
	for id_val in ids:
		if id_val is String and id_val != "":
			_unlocked_ids[id_val] = true
	# T109 — 加载解锁时间戳（兼容旧存档：缺失时 fallback 为 0）
	var stamps = parsed.get("unlock_timestamps", {})
	if stamps is Dictionary:
		for id_val in stamps.keys():
			if id_val is String and id_val != "":
				_unlock_timestamps[id_val] = int(stamps[id_val])

func is_unlocked(id_val: String) -> bool:
	return _unlocked_ids.get(id_val, false)

# T109 — 解锁时间戳 API（Unix 秒；未解锁返回 0）。
# PauseMenu 排序 + tooltip 显示用。
func get_unlock_timestamp(id_val: String) -> int:
	return int(_unlock_timestamps.get(id_val, 0))

# T109 — 已解锁成就按时间戳升序排序。空时返回空数组。
# 返回数组元素为 [id, title_zh, description_zh, timestamp] 4 元组。
func get_unlocked_achievements_sorted_by_time() -> Array:
	var rows: Array = []
	for id_val in _unlocked_ids.keys():
		var def: Dictionary = _definitions_by_id.get(id_val, {})
		rows.append([
			id_val,
			def.get("title_zh", id_val),
			def.get("description_zh", ""),
			int(_unlock_timestamps.get(id_val, 0))
		])
	rows.sort_custom(func(a, b): return int(a[3]) < int(b[3]))
	return rows

func get_all_achievements() -> Array:
	return _achievements

func get_unlocked_count() -> int:
	return _unlocked_ids.size()

func get_total_count() -> int:
	return _achievements.size()

func get_run_time_seconds() -> float:
	return Time.get_ticks_msec() / 1000.0 - _run_start_time

# === 辅助 ===

func _stat_names() -> Array:
	return [
		"rooms_cleared", "enemies_purified", "ink_wardens_defeated",
		"shards_collected", "deaths", "pulse_used", "bind_used",
		"cut_used", "echo_used", "echo_reflects",
		"silence_webs_cut", "save_lanterns_activated"
	]
