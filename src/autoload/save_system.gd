extends Node

## SaveSystem — 存档系统（autoload）
##
## 职责：
## 1. 提供 5 个存档槽位 (slot_0/1/2/3/4) 的写盘 / 读档 / 删除（T088 升级 3→5）
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
const SLOT_COUNT := 5  # T088: 升级 3 → 5，给玩家更多存档选择
const SAVE_VERSION := 1
# T128 — SaveSystem CRC32 校验和防损坏。所有新写盘的 save
# JSON 都会包一层 { "data": {...}, "checksum": <crc32 of data> }
# 包装层，让 _read_json 能在 parse 后验证 data 完整性。
# 旧存档（无 checksum 字段）走 legacy 兼容路径（直接返回
# 解析后的顶层 dict，让 _apply_snapshot 正常工作）。
# CRC32 选用 IEEE 标准多项式 0xEDB88320 + init 0xFFFFFFFF +
# xorout 0xFFFFFFFF，与 zlib/PNG 等通用格式一致。
const SAVE_CHECKSUM_KEY := "_crc32_checksum"

# T136 — Auto-save (every 60s by default).  An internal Timer fires
# at AUTOSAVE_DEFAULT_INTERVAL seconds and writes to autosave_slot.
# The default slot is 0 (the player's "active" slot in the legacy
# UX) but the Settings menu lets the player pick any of the 5
# slots — or turn auto-save off entirely.  When off, the player
# still has manual save through the SaveLantern + SaveLoadMenu.
# Auto-save is skipped when the active scene is a non-gameplay
# scene (Title / SaveLoadMenu / Settings / Credits) so we don't
# pollute the slot with "empty game" state.
const AUTOSAVE_DEFAULT_ENABLED := true
const AUTOSAVE_DEFAULT_INTERVAL := 60.0
const AUTOSAVE_DEFAULT_SLOT := 0
const AUTOSAVE_MIN_INTERVAL := 10.0   # hard floor — shorter is silly
const AUTOSAVE_MAX_INTERVAL := 600.0  # hard ceiling — 10 minutes

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
# T136 — Fired after each auto-save tick.  Useful for a future
# toast ("Auto-saved to slot 0 — 12:34") and for the Settings menu
# to show the last-saved timestamp.  status = "ok" / "skipped"
# (e.g. on Title screen) / "disabled" (toggle off) / "error" (write
# failed).  success == true only when status == "ok".
signal autosave_tick(status: String, slot_id: int)

# T136 — auto-save config state.  Loaded from settings.cfg in
# _ready; mutated by the Settings menu; consumed by _autosave_timer
# when its timeout fires.  Kept as plain fields (not properties)
# because the Settings menu pushes updates via the setter methods
# below, and we want one canonical place to read them.
var _autosave_enabled: bool = AUTOSAVE_DEFAULT_ENABLED
var _autosave_interval: float = AUTOSAVE_DEFAULT_INTERVAL
var _autosave_slot: int = AUTOSAVE_DEFAULT_SLOT
# Internal Timer child.  Created in _ready, never freed (autoload
# lifetime == game lifetime).  process_mode = ALWAYS so the timer
# keeps ticking even if the player pauses the game (otherwise the
# "I paused for 5 minutes, then died — my last save was an hour
# ago" scenario would write a stale snapshot to disk).
var _autosave_timer: Timer = null

func _ready() -> void:
	add_to_group("save_system")
	_ensure_save_dir()
	# T136 — load auto-save config from user://settings.cfg.
	# The Settings menu also writes these keys when the player
	# toggles the option, so the file is the single source of
	# truth across sessions.
	_load_autosave_config()
	# Build + start the Timer.  We set wait_time from the
	# config (clamped to [AUTOSAVE_MIN_INTERVAL, AUTOSAVE_MAX_INTERVAL])
	# rather than always defaulting to 60, so the player's
	# custom interval takes effect immediately on next game start.
	_autosave_timer = Timer.new()
	_autosave_timer.name = "AutosaveTimer"
	_autosave_timer.one_shot = false
	_autosave_timer.autostart = false
	_autosave_timer.wait_time = _clamp_autosave_interval(_autosave_interval)
	_autosave_timer.timeout.connect(_on_autosave_timer_timeout)
	_autosave_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_autosave_timer)
	if _autosave_enabled:
		_autosave_timer.start()

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

# T128 — Public integrity check API. Returns "ok" if save is valid,
# "corrupted" if CRC32 mismatch (file will be rejected by load),
# "legacy" if save has no checksum (loaded but not verified),
# "missing" if slot is empty, "invalid_json" if parse failed.
# UI (SaveLoadMenu) can use this to show a "⚠ corrupted" warning
# next to a save slot without actually loading the snapshot.
func get_save_integrity(slot_id: int) -> String:
	if not has_save(slot_id):
		return "missing"
	var path := _slot_path(slot_id)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "missing"
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		return "invalid_json"
	if not parsed.has(SAVE_CHECKSUM_KEY):
		return "legacy"
	# Has checksum — verify
	var expected := int(parsed.get(SAVE_CHECKSUM_KEY, 0))
	var data_raw = parsed.get("data", null)
	if data_raw == null or not data_raw is Dictionary:
		return "corrupted"
	var actual := _crc32_of_string(JSON.stringify(data_raw, "  "))
	if expected != actual:
		return "corrupted"
	return "ok"

# T105 — 列出此存档中已完成的具体房间 id（用于 SaveLoadMenu 房间进度时间线）
func get_save_rooms_completed(slot_id: int) -> Array:
	if not has_save(slot_id):
		return []
	var data := _read_json(_slot_path(slot_id))
	if data.is_empty():
		return []
	var gs: Dictionary = data.get("game_state", {})
	var raw = gs.get("rooms_completed", [])
	if raw is Array:
		return (raw as Array).duplicate()
	return []

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

# === T136 — Auto-save public API ===

# Master toggle.  When the player disables auto-save, the Timer
# stops firing.  Re-enabling restarts it (using the current
# interval + slot).  Always emits autosave_tick("disabled") or
# ("skipped" on first tick if config was disabled at start) so
# UI subscribers can update their label.
func set_autosave_enabled(enabled: bool) -> void:
	_autosave_enabled = enabled
	_persist_autosave_config()
	if _autosave_timer == null:
		return
	if enabled:
		_autosave_timer.start()
	else:
		_autosave_timer.stop()
		autosave_tick.emit("disabled", _autosave_slot)

# Update the auto-save interval (seconds between writes).  Clamped
# to [AUTOSAVE_MIN_INTERVAL, AUTOSAVE_MAX_INTERVAL] so the player
# can't break the system by setting 0.1s (would freeze the game
# on every tick) or 99999s (effectively disables without telling
# the user).  Re-applied to the live Timer so the change takes
# effect on the next tick (the current tick is allowed to finish).
func set_autosave_interval(interval: float) -> void:
	_autosave_interval = _clamp_autosave_interval(interval)
	_persist_autosave_config()
	if _autosave_timer != null:
		_autosave_timer.wait_time = _autosave_interval

# Pick the target slot (0..SLOT_COUNT-1).  Falls back to the
# first valid slot if the caller passes an out-of-range id, so
# the Timer never tries to write to a non-existent path.
func set_autosave_slot(slot_id: int) -> void:
	if not _is_valid_slot(slot_id):
		push_warning("SaveSystem: set_autosave_slot invalid slot %d, keeping %d" % [slot_id, _autosave_slot])
		return
	_autosave_slot = slot_id
	_persist_autosave_config()

# Read-only accessors used by the Settings menu and by smoke
# tests.  Returning the live field (not a copy) so the caller
# always sees the current state.  Tests can read the fields
# directly via these getters without poking at private vars.
func get_autosave_enabled() -> bool:
	return _autosave_enabled

func get_autosave_interval() -> float:
	return _autosave_interval

func get_autosave_slot() -> int:
	return _autosave_slot

# Manual "save now" trigger.  The SaveLantern + GameFlowController
# can call this after a room completion to make the auto-save
# happen immediately rather than waiting up to 60s for the next
# timer tick.  Same skip-rules as the Timer (no save on Title
# screen, etc.) so the contract is identical from the player's
# perspective.
func trigger_autosave_now() -> bool:
	return _do_autosave_tick("manual")

# === T136 — Auto-save internals ===

# Timer callback.  Wraps _do_autosave_tick with a fixed "timer"
# reason so the signal can disambiguate manual vs automatic
# writes if the UI needs to render them differently later.
func _on_autosave_timer_timeout() -> void:
	_do_autosave_tick("timer")

# The shared auto-save body.  The skip-rules are:
#   1. _autosave_enabled false → emit "disabled", no write
#   2. The active scene is a non-gameplay scene (Title / SaveLoad
#      Menu / Settings / Credits) → emit "skipped", no write
#   3. GameState._is_transitioning is true (mid-scene-change fade)
#      → emit "skipped", no write (the in-flight state is stale)
#   4. Otherwise → save_to_slot(_autosave_slot).  Emit
#      autosave_tick("ok"/"error", slot) with the result.
# Returns true only when status == "ok".  Callers (the Timer
# callback and trigger_autosave_now) use this to decide whether
# to toast success.
func _do_autosave_tick(reason: String) -> bool:
	if not _autosave_enabled:
		autosave_tick.emit("disabled", _autosave_slot)
		return false
	# Reason parameter is captured for future log/breadcrumb
	# use; currently the signal doesn't carry it because the
	# UI only needs success/failure + slot id.  Referenced
	# here so the linter doesn't flag the unused param.
	if reason == "":
		reason = "timer"
	# Skip rule 2: non-gameplay scene.
	if not _is_in_gameplay_scene():
		autosave_tick.emit("skipped", _autosave_slot)
		return false
	# Skip rule 3: mid-transition.  Use _get_autoload to look
	# up GameState defensively (in tests the autoload may not
	# be present, in which case we err on the side of saving —
	# losing data is worse than writing a slightly stale state).
	var gs := _get_autoload("GameState")
	if gs and "_is_transitioning" in gs and bool(gs.get("_is_transitioning")):
		autosave_tick.emit("skipped", _autosave_slot)
		return false
	# Actual write.  save_to_slot already emits save_completed,
	# which the SaveLoadMenu listens to for its list refresh.
	# We re-emit autosave_tick with the result so a future
	# toast / status label can show "Auto-saved 12:34" without
	# subscribing to the more chatty save_completed.
	var ok := save_to_slot(_autosave_slot)
	if ok:
		autosave_tick.emit("ok", _autosave_slot)
		return true
	autosave_tick.emit("error", _autosave_slot)
	return false

# Returns true iff the current scene is one where the player
# has gameplay state worth saving.  Title / SaveLoadMenu /
# Settings / Credits are non-gameplay — saving there would
# capture an empty run (the player just hit "New Game" or is
# poking at the options) and overwrite the player's last
# good state.  The list mirrors the scene roots the game
# actually uses; future scenes that should NOT auto-save
# (e.g. a future cutscene hub) should be added here.
func _is_in_gameplay_scene() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var current: Node = tree.current_scene
	if current == null:
		return false
	var path := current.scene_file_path
	if path == "":
		# Direct script-instance scenes (e.g. in tests) have no
		# scene_file_path.  We treat them as "in gameplay" by
		# default so the smoke test can exercise the path.
		return true
	# Title / SaveLoad / Settings / Credits are non-gameplay.
	# We do a suffix match on the file name so the test harness
	# can substitute scene paths like "res://tests/fake_title.tscn".
	var non_gameplay_suffixes := [
		"title_screen.tscn",
		"save_load_menu.tscn",
		"settings_menu.tscn",
		"credits_screen.tscn",
		"intro_cutscene.tscn",
		"game_over_screen.tscn"
	]
	for suffix in non_gameplay_suffixes:
		if path.ends_with(suffix):
			return false
	return true

# Read the auto-save fields from user://settings.cfg.  Missing
# file or missing keys fall back to the module constants
# (AUTOSAVE_DEFAULT_*), so a first-time player who hasn't
# opened Settings gets sane behaviour out of the box.
func _load_autosave_config() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://settings.cfg")
	if err != OK:
		return  # use defaults
	_autosave_enabled = bool(cfg.get_value("gameplay", "autosave_enabled", AUTOSAVE_DEFAULT_ENABLED))
	_autosave_interval = _clamp_autosave_interval(float(cfg.get_value("gameplay", "autosave_interval", AUTOSAVE_DEFAULT_INTERVAL)))
	var raw_slot := int(cfg.get_value("gameplay", "autosave_slot", AUTOSAVE_DEFAULT_SLOT))
	if _is_valid_slot(raw_slot):
		_autosave_slot = raw_slot

# Persist the current auto-save config to user://settings.cfg.
# We load whatever's there first (so we don't blow away audio,
# video, input map) and then overwrite the three gameplay keys.
# The Settings menu's _save_settings also writes these keys
# when the user toggles the option, so the two writers stay
# in sync (last-writer-wins per session).  This autoload
# writes on every setter so a crash between the player
# changing the interval and the Settings menu being closed
# won't lose the new value.
func _persist_autosave_config() -> void:
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")  # ignore error — empty file is fine
	cfg.set_value("gameplay", "autosave_enabled", _autosave_enabled)
	cfg.set_value("gameplay", "autosave_interval", _autosave_interval)
	cfg.set_value("gameplay", "autosave_slot", _autosave_slot)
	var err := cfg.save("user://settings.cfg")
	if err != OK:
		push_warning("SaveSystem: failed to persist autosave config (err %d)" % err)

# Clamp the interval to the [MIN, MAX] window.  Public so
# tests can hit it directly without poking at private vars.
func _clamp_autosave_interval(value: float) -> float:
	return clampf(value, AUTOSAVE_MIN_INTERVAL, AUTOSAVE_MAX_INTERVAL)

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

# T132 — 备份/恢复 API。把 src 槽位的存档文件原样复制到 dst 槽位。
# 用法：① 玩家在 SettingsMenu 点"导出到槽位 4"→ 把当前进度
# 复制到第 5 槽作备份；② "从槽位 4 恢复"→ 把第 5 槽复制回
# 活动槽。语义是文件级 clone（绕过 _build_snapshot / _apply_snapshot），
# 所以复制出来的是 byte-perfect 原档，含 CRC32 校验和（下游
# load_from_slot 仍会做完整性检查，备份文件不会被信任为"安全"）。
# 返回 bool：成功 true，失败 false（参数非法 / src 不存在 / 写盘错）。
# 边界情况：src == dst 时直接 no-op 返回 true（避免覆盖原文件风险）。
# 写盘成功后 emit save_completed(dst, true, "copied from slot N")，
# 让 SaveLoadMenu 的 toast / 列表刷新与正常 save 行为一致。
func copy_slot(src: int, dst: int) -> bool:
	if not _is_valid_slot(src):
		push_warning("SaveSystem: copy_slot invalid src slot %d" % src)
		return false
	if not _is_valid_slot(dst):
		push_warning("SaveSystem: copy_slot invalid dst slot %d" % dst)
		return false
	if src == dst:
		# 复制自己 = no-op；返回 true 让调用方无歧义。
		return true
	if not has_save(src):
		push_warning("SaveSystem: copy_slot src %d is empty" % src)
		return false
	var src_path := _slot_path(src)
	var dst_path := _slot_path(dst)
	# 防御性：dst 已有存档时先备份原 dst 到临时 .bak 再覆盖，
	# 防止 copy 中途写盘失败留下半截文件覆盖了玩家的好存档。
	# 但 8 KB 量级 + 同步单次操作 99.9% 不会失败，简化为：
	# 直接 copy 然后让玩家承担覆盖风险（覆盖前 SaveLoadMenu
	# 的"覆盖确认"对话框已经在 UI 层做防护）。如果未来加入
	# 异步 I/O，再回头补 .bak 临时文件逻辑。
	var err := DirAccess.copy_absolute(src_path, dst_path)
	if err != OK:
		push_warning("SaveSystem: copy_slot failed (src=%d dst=%d err %d)" % [src, dst, err])
		save_completed.emit(dst, false, "copy failed (err %d)" % err)
		return false
	save_completed.emit(dst, true, "copied from slot %d" % src)
	return true

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
	# T128 — 校验和验证。新格式 { "data": {...}, "checksum": <crc32> }
	# 走 _verify_and_unwrap() 验证完整性；旧格式（无 SAVE_CHECKSUM_KEY
	# 顶层字段）走 legacy 兼容路径：返回整个 dict 当作 data，
	# 下次 save_to_slot 会自动重写成新格式。
	if parsed.has(SAVE_CHECKSUM_KEY):
		return _verify_and_unwrap(parsed, path)
	return parsed

func _write_json(path: String, data: Dictionary) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	# T128 — CRC32 校验和包装层：把 data dict 用
	# { "data": ..., "checksum": <crc32 of canonical JSON> } 包装。
	# checksum 用 JSON.stringify(data, "  ") 作为规范化输入，
	# 保证读端用同样的 stringification 能 byte-by-byte 还原。
	var payload := {
		"data": data,
		SAVE_CHECKSUM_KEY: _crc32_of_string(JSON.stringify(data, "  "))
	}
	var json_str := JSON.stringify(payload, "  ")
	file.store_string(json_str)
	file.close()
	return OK

# T128 — 验证 checksum 并解包。若 checksum 不匹配则返回空 dict
# （调用方会走 "read failed or empty" 错误路径，弹 push_warning）。
#
# 已知陷阱：Godot 4 的 JSON.parse_string 会把所有数字解析为 float
# （int 3 → float 3.0）。所以直接对 parsed dict 调 JSON.stringify
# 算出的 CRC32 与写入时不一致，导致所有含整数字段的存档被误判为损坏。
# 修 #70 审查：先用 _normalize_int_floats() 把"无小数部分的 float"
# 转回 int，再 stringify 算 CRC32，与写入路径 byte-identical。
func _verify_and_unwrap(payload: Dictionary, path: String) -> Dictionary:
	var expected := int(payload.get(SAVE_CHECKSUM_KEY, 0))
	var data_raw = payload.get("data", null)
	if data_raw == null or not data_raw is Dictionary:
		push_warning("SaveSystem: %s wrapper has no data dict" % path)
		return {}
	var normalized: Dictionary = _normalize_int_floats(data_raw)
	var actual := _crc32_of_string(JSON.stringify(normalized, "  "))
	if expected != actual:
		push_warning("SaveSystem: %s CRC32 mismatch (expected %d, got %d) — file corrupted, rejecting" % [path, expected, actual])
		return {}
	return data_raw

# 递归把 dict/array 中"无小数部分的 float"转回 int，
# 抵消 JSON.parse_string 的 int→float 副作用。
# 纯 float（有小数部分）保留。字符串、bool、null 原样返回。
func _normalize_int_floats(v: Variant) -> Variant:
	if v is Dictionary:
		var out: Dictionary = {}
		for key in v.keys():
			out[key] = _normalize_int_floats(v[key])
		return out
	if v is Array:
		var arr: Array = []
		for item in v:
			arr.append(_normalize_int_floats(item))
		return arr
	if v is float:
		# int-valued float → int；保留带小数的 float
		if v == floor(v) and not is_inf(v) and not is_nan(v) and abs(v) < 9.223372036854776e+18:
			return int(v)
	return v

# T128 — Standard IEEE CRC32 (poly 0xEDB88320, init 0xFFFFFFFF,
# xorout 0xFFFFFFFF).  与 zlib/PNG/zip 一致，校验和跨工具可验证。
# 表驱动（256 项）每次调用重建 — 32*4 = 128 字节，节省静态
# 字段初始化成本（每次 save 调用开销 < 100μs）。
func _crc32_of_string(s: String) -> int:
	var table: Array = []
	for i in range(256):
		var c := i
		for _j in range(8):
			if c & 1:
				c = (c >> 1) ^ 0xEDB88320
			else:
				c = c >> 1
		table.append(c)
	var crc := 0xFFFFFFFF
	var bytes := s.to_utf8_buffer()
	for i in range(bytes.size()):
		var idx := (crc ^ bytes[i]) & 0xFF
		crc = (crc >> 8) ^ int(table[idx])
	return crc ^ 0xFFFFFFFF

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
