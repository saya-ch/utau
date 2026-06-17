extends SceneTree
## I014 (#102) — T184 prewarm_hit_sfx 场景复用 + F013 shop perk card SFX 冒烟测试
##
## 覆盖 #102 双任务原子化提交:
##
## === T184 — prewarm_hit_sfx 调一次扩展到 4 个场景 ready hook ===
## - T184.HUB: hub_controller.gd._ready() 调 prewarm_hit_sfx()
## - T184.HUB.HAS_METHOD: hub_controller 用 has_method 守卫 (headless-safe)
## - T184.HUB.COMMENT: hub_controller 注释含 T184 (#102) 锚点
## - T184.ROOM: room_controller.gd._ready() 调 prewarm_hit_sfx()
## - T184.ROOM.HAS_METHOD: room_controller 用 has_method 守卫
## - T184.ROOM.COMMENT: room_controller 注释含 T184 (#102) 锚点
## - T184.JSON: json_room.gd._ready() 调 prewarm_hit_sfx() (defense in depth)
## - T184.JSON.HAS_METHOD: json_room 用 has_method 守卫
## - T184.JSON.COMMENT: json_room 注释含 T184 (#102) 锚点
##
## === F013 — Hub shop perk card 购买反馈音频 (confirm bell + Lv arpeggio) ===
## - F013.AUDIO.PURCHASE_DECL: play_shop_purchase_confirm(perk_id: String) 公开方法
## - F013.AUDIO.PURCHASE_DICT: _shop_purchase_streams: Dictionary 缓存字段
## - F013.AUDIO.PURCHASE_MIDI: _SHOP_PURCHASE_MIDI 6 perk → midi 映射
## - F013.AUDIO.PURCHASE_MIDI.VALS: 6 perk midi 全在
## - F013.AUDIO.PURCHASE_MIDI.FALLBACK: 未注册 perk_id 走 C5 fallback
## - F013.AUDIO.LEVELUP_DECL: play_shop_level_up(level: int) 公开方法
## - F013.AUDIO.LEVELUP_DICT: _shop_level_up_streams: Dictionary 缓存字段
## - F013.AUDIO.LEVELUP_MIDI: _SHOP_LEVEL_UP_MIDI [C5, E5, G5] 3 步表
## - F013.AUDIO.LEVELUP_CLAMP: clampi(level, 1, size) 守卫
## - F013.AUDIO.LEVELUP_ZERO_GUARD: level <= 0 no-op 防御
## - F013.AUDIO.GEN_CONFIRM: _generate_shop_purchase_confirm(midi) 私有工厂
## - F013.AUDIO.GEN_LEVELUP: _generate_shop_level_up(level) 私有工厂
## - F013.SHOP.CALL_PURCHASE: shop_menu 调 ame.call("play_shop_purchase_confirm")
## - F013.SHOP.CALL_LEVELUP: shop_menu 调 ame.call("play_shop_level_up")
## - F013.SHOP.HAS_METHOD_PURCHASE: shop_menu 用 has_method 守卫
## - F013.SHOP.HAS_METHOD_LEVELUP: shop_menu 用 has_method 守卫
## - F013.SHOP.GET_LEVEL: shop_menu 调 GameState.get_perk_count(perk_id) 拿 new_level
## - F013.SHOP.TIMER: shop_menu 0.18s timer 调 play_shop_level_up
## - F013.SHOP.COMMENT: shop_menu 注释含 F013 (#102) 锚点

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const SHOP_MENU_GD := "res://src/scripts/shop_menu.gd"
const HUB_CONTROLLER_GD := "res://src/scripts/hub_controller.gd"
const ROOM_CONTROLLER_GD := "res://src/scripts/room_controller.gd"
const JSON_ROOM_GD := "res://src/scripts/json_room.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I014 (#102) — T184 prewarm_hit_sfx 场景复用 + F013 shop perk card SFX ===")
	_run_t184_hub_assertions()
	_run_t184_room_assertions()
	_run_t184_json_room_assertions()
	_run_f013_audio_decl_assertions()
	_run_f013_audio_data_assertions()
	_run_f013_audio_generators_assertions()
	_run_f013_shop_wiring_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I014 (#102) T184 + F013 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T184 — prewarm_hit_sfx 场景复用 =====================

# ---------- T184.HUB — hub_controller 接入 ----------
func _run_t184_hub_assertions() -> void:
	print("--- T184.HUB — hub_controller 接入 ---")
	var src := _read_file(HUB_CONTROLLER_GD)
	_assert_contains(src, "ame.call(\"prewarm_hit_sfx\")",
		"T184.HUB.1: hub_controller._ready 调 ame.call(\"prewarm_hit_sfx\")")
	_assert_contains(src, "ame.has_method(\"prewarm_hit_sfx\")",
		"T184.HUB.2: hub_controller 用 has_method 守卫 (headless-safe)")
	_assert_contains(src, "T184 (#102)",
		"T184.HUB.3: hub_controller 注释含 T184 (#102) 锚点")
	# Order: prewarm_hit_sfx 必须在 _schedule_tutorial_hints 之前 (越早 re-warm 越好)
	var prewarm_pos := src.find("ame.call(\"prewarm_hit_sfx\")")
	var tut_pos := src.find("_schedule_tutorial_hints()")
	if prewarm_pos != -1 and tut_pos != -1 and prewarm_pos < tut_pos:
		_passes += 1
		print("  OK  T184.HUB.ORDER.1: prewarm_hit_sfx 在 _schedule_tutorial_hints 之前 (early re-warm)")
	else:
		_failures.append("FAIL: T184.HUB.ORDER.1: prewarm_hit_sfx 应在 _schedule_tutorial_hints 之前, prewarm=%d tut=%d" % [prewarm_pos, tut_pos])


# ---------- T184.ROOM — room_controller 接入 ----------
func _run_t184_room_assertions() -> void:
	print("--- T184.ROOM — room_controller 接入 ---")
	var src := _read_file(ROOM_CONTROLLER_GD)
	_assert_contains(src, "ame.call(\"prewarm_hit_sfx\")",
		"T184.ROOM.1: room_controller._ready 调 ame.call(\"prewarm_hit_sfx\")")
	_assert_contains(src, "ame.has_method(\"prewarm_hit_sfx\")",
		"T184.ROOM.2: room_controller 用 has_method 守卫 (headless-safe)")
	_assert_contains(src, "T184 (#102)",
		"T184.ROOM.3: room_controller 注释含 T184 (#102) 锚点")
	# Order: prewarm_hit_sfx 应在 _schedule_tutorial_hints 之后 (与 #101 pattern 兼容)
	var prewarm_pos := src.find("ame.call(\"prewarm_hit_sfx\")")
	var tut_pos := src.find("_schedule_tutorial_hints()")
	if prewarm_pos != -1 and tut_pos != -1 and prewarm_pos > tut_pos:
		_passes += 1
		print("  OK  T184.ROOM.ORDER.1: prewarm_hit_sfx 在 _schedule_tutorial_hints 之后 (与 #101 pattern 兼容)")
	else:
		_failures.append("FAIL: T184.ROOM.ORDER.1: prewarm_hit_sfx 应在 _schedule_tutorial_hints 之后, prewarm=%d tut=%d" % [prewarm_pos, tut_pos])


# ---------- T184.JSON — json_room 接入 (defense in depth) ----------
func _run_t184_json_room_assertions() -> void:
	print("--- T184.JSON — json_room 接入 (defense in depth) ---")
	var src := _read_file(JSON_ROOM_GD)
	_assert_contains(src, "ame.call(\"prewarm_hit_sfx\")",
		"T184.JSON.1: json_room._ready 调 ame.call(\"prewarm_hit_sfx\")")
	_assert_contains(src, "ame.has_method(\"prewarm_hit_sfx\")",
		"T184.JSON.2: json_room 用 has_method 守卫 (headless-safe)")
	_assert_contains(src, "T184 (#102)",
		"T184.JSON.3: json_room 注释含 T184 (#102) 锚点")
	# Order: prewarm_hit_sfx 应在 _loader 初始化之前 (early re-warm)
	var prewarm_pos := src.find("ame.call(\"prewarm_hit_sfx\")")
	var loader_pos := src.find("_loader = RoomLoader.new()")
	if prewarm_pos != -1 and loader_pos != -1 and prewarm_pos < loader_pos:
		_passes += 1
		print("  OK  T184.JSON.ORDER.1: prewarm_hit_sfx 在 _loader 初始化之前 (early re-warm)")
	else:
		_failures.append("FAIL: T184.JSON.ORDER.1: prewarm_hit_sfx 应在 _loader 初始化之前, prewarm=%d loader=%d" % [prewarm_pos, loader_pos])


# ===================== F013 — shop perk card SFX =====================

# ---------- F013.AUDIO — 公开方法 + 缓存字段 ----------
func _run_f013_audio_decl_assertions() -> void:
	print("--- F013.AUDIO — 公开方法 + 缓存字段 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_shop_purchase_confirm(perk_id: String) -> void:",
		"F013.AUDIO.PURCHASE_DECL.1: play_shop_purchase_confirm(perk_id) 公开方法声明")
	_assert_contains(src, "var _shop_purchase_streams: Dictionary = {}",
		"F013.AUDIO.PURCHASE_DICT.1: _shop_purchase_streams Dictionary 缓存字段")
	_assert_contains(src, "func play_shop_level_up(level: int) -> void:",
		"F013.AUDIO.LEVELUP_DECL.1: play_shop_level_up(level) 公开方法声明")
	_assert_contains(src, "var _shop_level_up_streams: Dictionary = {}",
		"F013.AUDIO.LEVELUP_DICT.1: _shop_level_up_streams Dictionary 缓存字段")


# ---------- F013.AUDIO.DATA — 6 perk midi + 3 level 表 ----------
func _run_f013_audio_data_assertions() -> void:
	print("--- F013.AUDIO.DATA — 6 perk midi + 3 level 表 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# _SHOP_PURCHASE_MIDI 字典
	_assert_contains(src, "const _SHOP_PURCHASE_MIDI := {",
		"F013.AUDIO.PURCHASE_MIDI.1: _SHOP_PURCHASE_MIDI 常量字典声明")
	# 6 perk midi 全在
	for perk_id in ["heart_crystal", "resonance_chime", "pulse_focus", "echo_charm", "wave_focus", "silence_breaker"]:
		var needle := "\"%s\":" % perk_id
		if src.contains(needle):
			_passes += 1
			print("  OK  F013.AUDIO.PURCHASE_MIDI.VALS.%-18s: _SHOP_PURCHASE_MIDI 字典含 %s" % [perk_id, needle])
		else:
			_failures.append("FAIL: F013.AUDIO.PURCHASE_MIDI.VALS.%s: _SHOP_PURCHASE_MIDI 字典缺 %s" % [perk_id, needle])
	# fallback C5 (midi 72)
	_assert_contains(src, "_SHOP_PURCHASE_MIDI.get(perk_id, 72)",
		"F013.AUDIO.PURCHASE_MIDI.FALLBACK.1: 未注册 perk_id 走 C5 (midi 72) fallback")
	# _SHOP_LEVEL_UP_MIDI 3 步表
	_assert_contains(src, "const _SHOP_LEVEL_UP_MIDI := [72, 76, 79]",
		"F013.AUDIO.LEVELUP_MIDI.1: _SHOP_LEVEL_UP_MIDI [C5, E5, G5] 3 步表")
	# clamp 守卫
	_assert_contains(src, "clampi(level, 1, _SHOP_LEVEL_UP_MIDI.size())",
		"F013.AUDIO.LEVELUP_CLAMP.1: play_shop_level_up clampi(level, 1, size) 守卫")
	# level <= 0 no-op
	_assert_contains(src, "if level <= 0:",
		"F013.AUDIO.LEVELUP_ZERO_GUARD.1: level <= 0 fallback no-op")
	_assert_contains(src, "return",
		"F013.AUDIO.LEVELUP_ZERO_GUARD.2: level <= 0 early return")


# ---------- F013.AUDIO.GEN — 私有 generator 工厂 ----------
func _run_f013_audio_generators_assertions() -> void:
	print("--- F013.AUDIO.GEN — 私有 generator 工厂 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_shop_purchase_confirm(midi: int) -> AudioStreamWAV:",
		"F013.AUDIO.GEN_CONFIRM.1: _generate_shop_purchase_confirm(midi) 私有工厂声明")
	_assert_contains(src, "func _generate_shop_level_up(level: int) -> AudioStreamWAV:",
		"F013.AUDIO.GEN_LEVELUP.1: _generate_shop_level_up(level) 私有工厂声明")
	# F013 (#102) docblock 锚点
	_assert_contains(src, "F013 (#102)",
		"F013.AUDIO.GEN.DOC.1: 注释含 F013 (#102) 锚点")


# ---------- F013.SHOP — shop_menu 接入 ----------
func _run_f013_shop_wiring_assertions() -> void:
	print("--- F013.SHOP — shop_menu 接入 ---")
	var src := _read_file(SHOP_MENU_GD)
	# ame.call("play_shop_purchase_confirm")
	_assert_contains(src, "ame.call(\"play_shop_purchase_confirm\", perk_id)",
		"F013.SHOP.CALL_PURCHASE.1: shop_menu 调 ame.call(\"play_shop_purchase_confirm\", perk_id)")
	_assert_contains(src, "ame.has_method(\"play_shop_purchase_confirm\")",
		"F013.SHOP.HAS_METHOD_PURCHASE.1: shop_menu 用 has_method 守卫")
	# ame.call("play_shop_level_up")
	_assert_contains(src, "ame.call(\"play_shop_level_up\", new_level)",
		"F013.SHOP.CALL_LEVELUP.1: shop_menu 调 ame.call(\"play_shop_level_up\", new_level)")
	_assert_contains(src, "ame.has_method(\"play_shop_level_up\")",
		"F013.SHOP.HAS_METHOD_LEVELUP.1: shop_menu 用 has_method 守卫")
	# new_level 读 GameState.get_perk_count(perk_id)
	_assert_contains(src, "GameState.get_perk_count(perk_id)",
		"F013.SHOP.GET_LEVEL.1: shop_menu 调 GameState.get_perk_count(perk_id) 拿 new_level")
	# 0.18s timer (play_sfx 0.18s 尾后)
	_assert_contains(src, "create_timer(0.18)",
		"F013.SHOP.TIMER.1: shop_menu 0.18s timer 调 play_shop_level_up")
	# F013 (#102) 锚点
	_assert_contains(src, "F013 (#102)",
		"F013.SHOP.COMMENT.1: shop_menu 注释含 F013 (#102) 锚点")
	# Order: ame.call("play_shop_purchase_confirm", perk_id) 必须在 ame.call("play_shop_level_up", new_level) 之前
	var purchase_pos := src.find("ame.call(\"play_shop_purchase_confirm\", perk_id)")
	var levelup_pos := src.find("ame.call(\"play_shop_level_up\", new_level)")
	if purchase_pos != -1 and levelup_pos != -1 and purchase_pos < levelup_pos:
		_passes += 1
		print("  OK  F013.SHOP.ORDER.1: purchase_confirm 在 level_up 之前 (bell 先响, jingle 跟在 0.18s 后)")
	else:
		_failures.append("FAIL: F013.SHOP.ORDER.1: purchase_confirm 应在 level_up 之前, purchase=%d levelup=%d" % [purchase_pos, levelup_pos])


# ===================== helpers =====================
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _assert_not_contains(src: String, needle: String, label: String) -> void:
	if not src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (forbidden needle still present: " + needle + ")")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _print_summary() -> void:
	print("--- I014 (#102) T184 + F013 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
