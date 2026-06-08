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
# T127 — 历史最佳 / Run 编号 单独持久化。成就持久化在 PERSIST_PATH；
# 这里用独立的 user://run_history.json 与成就文件解耦，让
# "Delete All Saves" / 单 slot 删除时不会顺手清掉历史最佳。
const HISTORY_PATH := "user://run_history.json"

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

# T127 — Run 编号 + 历史最佳
# run_number 在 reset_stats() 末尾 +1（即「新一轮开始」时递增）。
# 默认 1，因为 _ready 初始化时玩家还没开始任何 run。
# _best_stats 持久化到 user://run_history.json（与成就文件解耦，
# 让 Delete All Saves 不影响历史最佳）。每条记录都是「最高」语义
# (longest_run_seconds / most_rooms_cleared / most_shards_collected /
# most_enemies_purified) — 单调更新，不需要排序。
var run_number: int = 1
var _best_stats: Dictionary = {
	"longest_run_seconds": 0.0,
	"most_rooms_cleared": 0,
	"most_shards_collected": 0,
	"most_enemies_purified": 0
}

# T131 — Run 历史（FIFO，最多 20 局）。每条记录 = 一次 reset_stats()
# 之前 capture 下来的本 run 摘要：run_number / run_time / 4 个核心
# 统计。PauseMenu Player Profile 用它计算「近 5 / 10 / 20 局平均」，
# 让玩家看到跨 run 的"趋势"（不是单次峰值）。与 _best_stats 共存：
# 最佳 = 单调极值，趋势 = N 局平均。零样本时暂停菜单显示 "—"。
# 持久化到同一个 user://run_history.json（增字段，旧存档加载安全）。
const _RUN_HISTORY_MAX := 20
var _run_history: Array = []

func _ready() -> void:
	add_to_group("player_stats")
	_run_start_time = Time.get_ticks_msec() / 1000.0
	_load_achievements()
	_load_persistent_achievements()
	_load_best_stats()

func reset_stats() -> void:
	# T127 — 在清零之前先 snapshot 当前 run，刷新历史最佳。
	# 顺序很重要：必须先 snapshot（用旧值），再清零累加器，
	# 最后 +1 run_number 并重置 _run_start_time。
	# 这样多次 reset_run() 调用不会丢失本 run 的成绩。
	_update_best_stats_from_current_run()
	# T131 — 同步把当前 run 摘要 push 到 _run_history（FIFO，截 20）。
	# 必须在清零之前 capture（用旧值），并 append 在 _best_stats
	# 之后，让 _persist_best_stats 一次性把两者都写盘。
	_capture_run_into_history()

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
	# T127 — 新一轮开始：run 编号 +1。「新 run」的语义是
	# 玩家从存档读档后、死亡重生到 Hub 后点「重新开始」、
	# 或从 TitleScreen 开始新游戏时。当前 run 的成绩已
	# 在 _update_best_stats_from_current_run() 锁定。
	run_number += 1

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
		"best_stat_threshold":
			# T130 — 历史最佳成就条件。从 _best_stats dict 读指定字段
			# （longest_run_seconds / most_rooms_cleared /
			# most_shards_collected / most_enemies_purified），
			# 与 min 比较，达成即解锁。语义是"曾经跑出过这个成绩"
			# 而非"当前 run 累计"，让"跨 run metaprogression"
			# 有具体里程碑。min 支持 float（longest_run_seconds）。
			var best_key: String = cond.get("stat", "")
			if best_key == "" or not _best_stats.has(best_key):
				return false
			var min_val_v = cond.get("min", 1)
			if min_val_v is float or best_key == "longest_run_seconds":
				return float(_best_stats.get(best_key, 0.0)) >= float(min_val_v)
			return int(_best_stats.get(best_key, 0)) >= int(min_val_v)
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

# === T127 — Run 编号 + 历史最佳 ===

# 公开访问器：返回当前 run 编号（1-based；首次 _ready 后玩家开始
# 第一个 run 时就是 1，第一次 reset_run() 后变 2，依此类推）。
func get_run_number() -> int:
	return run_number

# 公开访问器：返回历史最佳 dict 的副本（避免外部 mutate）。
# 字段：longest_run_seconds / most_rooms_cleared /
# most_shards_collected / most_enemies_purified。
func get_best_stats() -> Dictionary:
	return _best_stats.duplicate()

# 内部：在 reset_stats() 开头调用，snapshot 当前 run 的成绩，
# 单调更新到 _best_stats。空 run（任何字段 0）不会"破纪录"，
# 玩家至少得通关 1 个房间才能上 most_rooms_cleared_best。
# 写盘时机跟随 _persist_best_stats()，在 Update 末尾调用。
func _update_best_stats_from_current_run() -> void:
	var run_time := get_run_time_seconds()
	if run_time > float(_best_stats.get("longest_run_seconds", 0.0)):
		_best_stats["longest_run_seconds"] = run_time
	if rooms_cleared > int(_best_stats.get("most_rooms_cleared", 0)):
		_best_stats["most_rooms_cleared"] = rooms_cleared
	if shards_collected > int(_best_stats.get("most_shards_collected", 0)):
		_best_stats["most_shards_collected"] = shards_collected
	if enemies_purified > int(_best_stats.get("most_enemies_purified", 0)):
		_best_stats["most_enemies_purified"] = enemies_purified
	# Update 完毕即写盘，确保即使游戏在 run 中崩溃也保留最佳。
	_persist_best_stats()

# 持久化到 user://run_history.json（独立于成就和存档）。
# 写入失败 push_warning 但不抛错（与 achievements persist 风格一致）。
# T131 — 增字段 run_history 持久化（旧存档无此字段时 _load_best_stats
# 安全 fallback _run_history=[]）。
func _persist_best_stats() -> void:
	var data := {
		"version": 1,
		"best_stats": _best_stats.duplicate(),
		"run_number": run_number,
		"run_history": _run_history.duplicate()
	}
	var file := FileAccess.open(HISTORY_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("PlayerStats: failed to write %s (err %d)" % [HISTORY_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data, "  "))
	file.close()

func _load_best_stats() -> void:
	if not FileAccess.file_exists(HISTORY_PATH):
		return
	var file := FileAccess.open(HISTORY_PATH, FileAccess.READ)
	if file == null:
		return
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		return
	var best = parsed.get("best_stats", {})
	if best is Dictionary:
		for key in _best_stats.keys():
			if best.has(key):
				_best_stats[key] = best[key]
	# run_number 持久化：上次 _persist_best_stats 在 reset_stats 末尾
	# 写盘（已 +1），所以保存的是「下次开始的 run 编号」。下次 _ready
	# 直接 load 即可继续累加。0 表示首次启动（无文件），保持默认 1。
	var loaded_run := int(parsed.get("run_number", 0))
	if loaded_run > 0:
		run_number = loaded_run
	# T131 — 加载 _run_history（兼容旧存档：缺失时 fallback 为空数组）。
	# 逐条 dict 校验，丢弃字段不全或非 dict 的脏数据，防止单条
	# 损坏拖垮整个 history 加载。
	var hist_raw = parsed.get("run_history", [])
	if hist_raw is Array:
		_run_history.clear()
		for entry in hist_raw:
			if entry is Dictionary and entry.has("run_number"):
				_run_history.append(entry)
		# 防御性截断（玩家可能从老版本 50 条扩到 20 条 cap）
		# 与 _capture_run_into_history 同样使用 size 作为 end（exclusive of one-past-last）
		if _run_history.size() > _RUN_HISTORY_MAX:
			_run_history = _run_history.slice(_run_history.size() - _RUN_HISTORY_MAX, _run_history.size())

# === T131 — Run 历史（FIFO 20 局） + 近 N 局平均 ===

# 内部：在 reset_stats() 开头 capture 当前 run 摘要。
# 用 push_back + slice 维持 FIFO 长度 <= _RUN_HISTORY_MAX。
# "空 run" 也会进 history（玩家 0 房间 0 净化 = 也算一次 run），
# 让"我今天跑了 N 次"这个直觉在 history 长度上有体现。
# 写盘在 _update_best_stats_from_current_run 末尾的 _persist_best_stats 里
# 一次性做（run_history + best_stats + run_number 同盘）。
func _capture_run_into_history() -> void:
	var snapshot := {
		"run_number": run_number,
		"run_time_seconds": get_run_time_seconds(),
		"rooms_cleared": rooms_cleared,
		"enemies_purified": enemies_purified,
		"shards_collected": shards_collected,
		"deaths": deaths
	}
	_run_history.append(snapshot)
	# FIFO：超过 cap 时丢弃最早元素。Godot 4 Array.slice(begin, end) 中
	# end 是 exclusive，所以 _run_history.size()-MAX 是起始索引、_run_history.size()
	# 是终止索引（exclusive of one-past-last），让最后 20 条全保留。
	# 旧实现误用 _RUN_HISTORY_MAX 作为 end，导致多丢 1 条。
	if _run_history.size() > _RUN_HISTORY_MAX:
		_run_history = _run_history.slice(_run_history.size() - _RUN_HISTORY_MAX, _run_history.size())

# 公开访问器：返回 _run_history 防御性副本（避免外部 mutate）。
# 元素顺序：最早在前（最旧 run 索引 0），最新在后（最近 run 末尾）。
# 长度上限 _RUN_HISTORY_MAX (20)。
func get_run_history() -> Array:
	return _run_history.duplicate()

# 公开 API：取最近 N 局（按时间倒序取最后 N 条）。返回 [N 条] array，
# N=0 / history 不足 N 条时按实际长度返回。PauseMenu 用作"近 5/10/20
# 局平均"分母。
# 注意：Array.slice(begin, end) 的 end 是 exclusive，所以必须传
# _run_history.size()（数组末尾后一位）而不是 count。
func get_recent_runs(n: int) -> Array:
	if n <= 0 or _run_history.is_empty():
		return []
	var count: int = min(n, _run_history.size())
	return _run_history.slice(_run_history.size() - count, _run_history.size()).duplicate()

# 公开 API：近 N 局平均。返回 dict 含 4 字段 + 样本数：
#   { "rooms_cleared": 1.4, "enemies_purified": 3.2,
#     "shards_collected": 8.1, "run_time_seconds": 155.7,
#     "deaths": 0.4, "sample_count": 5 }
# 样本不足 N 条时按实际样本数平均（不补 0）。
# 零样本（history 空）返回空 dict，PauseMenu 据此显示 "—" 占位。
func get_recent_runs_average(n: int) -> Dictionary:
	var recent: Array = get_recent_runs(n)
	if recent.is_empty():
		return {}
	var count: float = float(recent.size())
	var sum_rooms: float = 0.0
	var sum_enemies: float = 0.0
	var sum_shards: float = 0.0
	var sum_time: float = 0.0
	var sum_deaths: float = 0.0
	for entry in recent:
		if not (entry is Dictionary):
			continue
		sum_rooms += float(entry.get("rooms_cleared", 0))
		sum_enemies += float(entry.get("enemies_purified", 0))
		sum_shards += float(entry.get("shards_collected", 0))
		sum_time += float(entry.get("run_time_seconds", 0.0))
		sum_deaths += float(entry.get("deaths", 0))
	return {
		"rooms_cleared": sum_rooms / count,
		"enemies_purified": sum_enemies / count,
		"shards_collected": sum_shards / count,
		"run_time_seconds": sum_time / count,
		"deaths": sum_deaths / count,
		"sample_count": int(count)
	}

# === 辅助 ===

func _stat_names() -> Array:
	return [
		"rooms_cleared", "enemies_purified", "ink_wardens_defeated",
		"shards_collected", "deaths", "pulse_used", "bind_used",
		"cut_used", "echo_used", "echo_reflects",
		"silence_webs_cut", "save_lanterns_activated"
	]
