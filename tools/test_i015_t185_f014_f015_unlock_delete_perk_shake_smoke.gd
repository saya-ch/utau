extends SceneTree
## I015 (#103) — F014 unlock chime + F015 delete confirm + T185 perk level-up shake 冒烟测试
##
## 覆盖 #103 三任务原子化提交:
##
## === F014 — AudioManagerEnhanced 成就 unlock chime ===
## - F014.FIELD: _unlock_chime_stream: AudioStreamWAV 字段声明
## - F014.PLAY.SIG: play_unlock_chime() 公开方法已声明
## - F014.PLAY.LAZY: lazy-init 守卫 (null → 生成)
## - F014.PLAY.BUS: play_sfx(_unlock_chime_stream) 走 SFX bus
## - F014.GEN.SIG: _generate_unlock_chime_sfx() 私有 synth
## - F014.GEN.C6: 1046.50Hz C6 anchor
## - F014.GEN.E6: 1318.51Hz E6 anchor (小三度)
## - F014.GEN.A6: 1760.00Hz A6 anchor (纯五度)
## - F014.GEN.DUR: 0.4s duration
## - F014.GEN.AMP: 0.18 amplitude
## - F014.NOTIFY.HAS_METHOD: AchievementNotification 用 has_method("play_unlock_chime") 守卫
## - F014.NOTIFY.CALL: AchievementNotification._on_achievement_unlocked 调 ame.call("play_unlock_chime")
## - F014.NOTIFY.HELPER: _play_unlock_chime() helper 函数声明
##
## === F015 — SaveSlot delete confirm click ===
## - F015.FIELD: _delete_confirm_stream: AudioStreamWAV 字段声明
## - F015.PLAY.SIG: play_delete_confirm() 公开方法已声明
## - F015.PLAY.LAZY: lazy-init 守卫 (null → 生成)
## - F015.PLAY.BUS: play_sfx(_delete_confirm_stream) 走 SFX bus
## - F015.GEN.SIG: _generate_delete_confirm_sfx() 私有 synth
## - F015.GEN.FREQ: 150.0Hz 方波基频 (低音"嗒" 区分 jingle 中高频)
## - F015.GEN.OVERTONE1: 1.5x = 225Hz
## - F015.GEN.OVERTONE2: 3x = 450Hz
## - F015.GEN.DUR: 0.12s duration (短促)
## - F015.GEN.AMP: 0.20 amplitude (比 jingle 0.10 强)
## - F015.SAVE.HAS_METHOD: SaveLoadMenu 用 has_method("play_delete_confirm") 守卫
## - F015.SAVE.CALL: SaveLoadMenu._on_delete 调 ame.play_delete_confirm()
## - F015.SAVE.ORDER: delete_confirm 在 delete_requested.emit 之前
##
## === T185 — PERK_LEVEL_UP preset + shop_menu 屏抖 ===
## - T185.PRESET.ENUM: screen_shake.gd Preset enum 含 PERK_LEVEL_UP
## - T185.PRESET.PRESETS: _PRESETS dict 含 Preset.PERK_LEVEL_UP
## - T185.PRESET.VAL: Vector2(2.5, 0.15) (介于 PULSE 2.0/0.10 与 HEAVY 4.0/0.18 之间)
## - T185.SHOP.HAS_METHOD: shop_menu 用 has_method("shake_preset") 守卫
## - T185.SHOP.PRESET_HAS: shop_menu 用 Preset.has("PERK_LEVEL_UP") 守卫 (老版本 ame 安全)
## - T185.SHOP.CALL: shop_menu._on_buy_pressed 调 ScreenShake.shake_preset(PERK_LEVEL_UP)
## - T185.SHOP.THRESHOLD: 阈值 new_count >= 2 (level II+)
## - T185.SHOP.DOC: shop_menu 注释含 T185 (#103) 锚点
##
## === T185.B — prewarm_misc_sfx 聚合器扩展 ===
## - T185B.PRE.SIG: prewarm_misc_sfx() 公开方法已声明
## - T185B.PRE.UNLOCK: prewarm_misc_sfx 调 _generate_unlock_chime_sfx()
## - T185B.PRE.DELETE: prewarm_misc_sfx 调 _generate_delete_confirm_sfx()
## - T185B.PRE.ALL.SIG: prewarm_all_sfx 调 prewarm_misc_sfx (aggregator 扩展)
## - T185B.PRE.ALL.ORDER: aggregator 顺序 music → hit → shop → misc
## - T185B.TITLE.CALL: title_screen._prewarm_bgm 调 prewarm_misc_sfx
## - T185B.TITLE.HAS_METHOD: title_screen 用 has_method("prewarm_misc_sfx") 守卫

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const ACHIEVEMENT_NOTIFICATION_GD := "res://src/scripts/achievement_notification.gd"
const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"
const SCREEN_SHAKE_GD := "res://src/autoload/screen_shake.gd"
const SHOP_MENU_GD := "res://src/scripts/shop_menu.gd"
const TITLE_SCREEN_GD := "res://src/scripts/title_screen.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I015 (#103) — F014 unlock chime + F015 delete confirm + T185 perk level-up ===")
	_run_f014_field_assertions()
	_run_f014_play_api_assertions()
	_run_f014_gen_synth_assertions()
	_run_f014_notify_integration_assertions()
	_run_f015_field_assertions()
	_run_f015_play_api_assertions()
	_run_f015_gen_synth_assertions()
	_run_f015_save_integration_assertions()
	_run_t185_preset_assertions()
	_run_t185_shop_integration_assertions()
	_run_t185b_prewarm_assertions()
	_run_t185b_prewarm_all_assertions()
	_run_t185b_title_integration_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I015 (#103) F014 + F015 + T185 ASSERTIONS PASSED ===")
		quit(0)


# ===================== F014 — achievement unlock chime =====================

# ---------- F014.FIELD — 字段声明 ----------
func _run_f014_field_assertions() -> void:
	print("--- F014.FIELD — 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _unlock_chime_stream: AudioStreamWAV",
		"F014.FIELD.1: _unlock_chime_stream: AudioStreamWAV 字段声明 (单 stream cache)")


# ---------- F014.PLAY.* — 公开 API + lazy ----------
func _run_f014_play_api_assertions() -> void:
	print("--- F014.PLAY.* — 公开 API + lazy ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_unlock_chime() -> void:",
		"F014.PLAY.SIG.1: play_unlock_chime() -> void: 公开方法声明")
	_assert_contains(src, "if _unlock_chime_stream == null:",
		"F014.PLAY.LAZY.1: play_unlock_chime lazy-init 守卫 (null check)")
	_assert_contains(src, "_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"F014.PLAY.LAZY.2: lazy 路径调 _generate_unlock_chime_sfx()")
	_assert_contains(src, "play_sfx(_unlock_chime_stream)",
		"F014.PLAY.BUS.1: play_sfx(_unlock_chime_stream) 走 SFX bus")


# ---------- F014.GEN.* — 私有 synth 函数 ----------
func _run_f014_gen_synth_assertions() -> void:
	print("--- F014.GEN.* — 私有 synth 函数 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_unlock_chime_sfx() -> AudioStreamWAV:",
		"F014.GEN.SIG.1: _generate_unlock_chime_sfx() -> AudioStreamWAV 私有 synth")
	_assert_contains(src, "1046.50",  # C6
		"F014.GEN.C6.1: 1046.50Hz C6 fundamental anchor")
	_assert_contains(src, "1318.51",  # E6
		"F014.GEN.E6.1: 1318.51Hz E6 overtone (小三度) anchor")
	_assert_contains(src, "1760.00",  # A6
		"F014.GEN.A6.1: 1760.00Hz A6 overtone (纯五度) anchor")
	_assert_contains(src, "var duration := 0.4",
		"F014.GEN.DUR.1: unlock_chime 0.4s duration (与 F013 purchase_confirm 同长, 仪式感)")
	_assert_contains(src, "env * 0.18",
		"F014.GEN.AMP.1: amplitude 0.18 (比 save_slot_jingle 0.10 强, 暗示稀有事件)")


# ---------- F014.NOTIFY.* — AchievementNotification 接入 ----------
func _run_f014_notify_integration_assertions() -> void:
	print("--- F014.NOTIFY.* — AchievementNotification 接入 ---")
	var src := _read_file(ACHIEVEMENT_NOTIFICATION_GD)
	_assert_contains(src, "ame.has_method(\"play_unlock_chime\")",
		"F014.NOTIFY.HAS_METHOD.1: AchievementNotification 用 has_method(\"play_unlock_chime\") 守卫 (headless-safe)")
	_assert_contains(src, "ame.call(\"play_unlock_chime\")",
		"F014.NOTIFY.CALL.1: AchievementNotification._on_achievement_unlocked 调 ame.call(\"play_unlock_chime\")")
	_assert_contains(src, "func _play_unlock_chime() -> void:",
		"F014.NOTIFY.HELPER.1: _play_unlock_chime() helper 函数声明 (代码可复用, 便于测试)")
	_assert_contains(src, "F014 (#103)",
		"F014.NOTIFY.DOC.1: AchievementNotification 注释含 F014 (#103) 锚点")
	# 顺序: _play_unlock_chime() 在 icon lookup 之前 (audio 与 visual 并行)
	var helper_pos := src.find("_play_unlock_chime()")
	var lookup_pos := src.find("var icon_hint: String = ICON_DEFAULT")
	if helper_pos != -1 and lookup_pos != -1 and helper_pos < lookup_pos:
		_passes += 1
		print("  OK  F014.NOTIFY.ORDER.1: _play_unlock_chime() 在 icon lookup 之前 (audio + visual 并行触发)")
	else:
		_failures.append("FAIL: F014.NOTIFY.ORDER.1: 顺序错 helper=%d lookup=%d" % [helper_pos, lookup_pos])


# ===================== F015 — save slot delete confirm click =====================

# ---------- F015.FIELD — 字段声明 ----------
func _run_f015_field_assertions() -> void:
	print("--- F015.FIELD — 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _delete_confirm_stream: AudioStreamWAV",
		"F015.FIELD.1: _delete_confirm_stream: AudioStreamWAV 字段声明 (单 stream cache)")


# ---------- F015.PLAY.* — 公开 API + lazy ----------
func _run_f015_play_api_assertions() -> void:
	print("--- F015.PLAY.* — 公开 API + lazy ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_delete_confirm() -> void:",
		"F015.PLAY.SIG.1: play_delete_confirm() -> void: 公开方法声明")
	_assert_contains(src, "if _delete_confirm_stream == null:",
		"F015.PLAY.LAZY.1: play_delete_confirm lazy-init 守卫 (null check)")
	_assert_contains(src, "_delete_confirm_stream = _generate_delete_confirm_sfx()",
		"F015.PLAY.LAZY.2: lazy 路径调 _generate_delete_confirm_sfx()")
	_assert_contains(src, "play_sfx(_delete_confirm_stream)",
		"F015.PLAY.BUS.1: play_sfx(_delete_confirm_stream) 走 SFX bus")


# ---------- F015.GEN.* — 私有 synth 函数 ----------
func _run_f015_gen_synth_assertions() -> void:
	print("--- F015.GEN.* — 私有 synth 函数 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_delete_confirm_sfx() -> AudioStreamWAV:",
		"F015.GEN.SIG.1: _generate_delete_confirm_sfx() -> AudioStreamWAV 私有 synth")
	_assert_contains(src, "150.0",  # 方波基频
		"F015.GEN.FREQ.1: 150.0Hz 方波基频 anchor (低音\"嗒\" 区分 jingle 中高频)")
	_assert_contains(src, "225.0",  # 1.5x
		"F015.GEN.OVERTONE1.1: 1.5x = 225Hz overtone")
	_assert_contains(src, "450.0",  # 3x
		"F015.GEN.OVERTONE2.1: 3x = 450Hz overtone")
	_assert_contains(src, "var duration := 0.12",
		"F015.GEN.DUR.1: delete_confirm 0.12s duration (短促 ~40ms perceptual)")
	_assert_contains(src, "env * 0.20",
		"F015.GEN.AMP.1: amplitude 0.20 (比 save_slot_jingle 0.10 强一倍, 暗示破坏性)")


# ---------- F015.SAVE.* — SaveLoadMenu 接入 ----------
func _run_f015_save_integration_assertions() -> void:
	print("--- F015.SAVE.* — SaveLoadMenu 接入 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "AudioManagerEnhanced.has_method(\"play_delete_confirm\")",
		"F015.SAVE.HAS_METHOD.1: SaveLoadMenu 用 has_method(\"play_delete_confirm\") 守卫")
	_assert_contains(src, "AudioManagerEnhanced.play_delete_confirm()",
		"F015.SAVE.CALL.1: SaveLoadMenu._on_delete 调 ame.play_delete_confirm()")
	_assert_contains(src, "F015 (#103)",
		"F015.SAVE.DOC.1: SaveLoadMenu 注释含 F015 (#103) 锚点")
	# 顺序: play_delete_confirm 在 delete_requested.emit 之前
	var call_pos := src.find("AudioManagerEnhanced.play_delete_confirm()")
	var emit_pos := src.find("delete_requested.emit(slot_id)")
	if call_pos != -1 and emit_pos != -1 and call_pos < emit_pos:
		_passes += 1
		print("  OK  F015.SAVE.ORDER.1: play_delete_confirm() 在 delete_requested.emit 之前 (audio 先, signal 后)")
	else:
		_failures.append("FAIL: F015.SAVE.ORDER.1: 顺序错 call=%d emit=%d" % [call_pos, emit_pos])


# ===================== T185 — PERK_LEVEL_UP preset + shop_menu 屏抖 =====================

# ---------- T185.PRESET — screen_shake.gd Preset enum + _PRESETS dict ----------
func _run_t185_preset_assertions() -> void:
	print("--- T185.PRESET — screen_shake.gd Preset enum + _PRESETS dict ---")
	var src := _read_file(SCREEN_SHAKE_GD)
	_assert_contains(src, "PERK_LEVEL_UP",
		"T185.PRESET.ENUM.1: Preset enum 含 PERK_LEVEL_UP (T185 #103 新增)")
	_assert_contains(src, "Preset.PERK_LEVEL_UP: Vector2(2.5, 0.15)",
		"T185.PRESET.PRESETS.1: _PRESETS dict 含 Preset.PERK_LEVEL_UP: Vector2(2.5, 0.15) 强度+时长")
	_assert_contains(src, "Vector2(2.5, 0.15)",
		"T185.PRESET.VAL.1: Vector2(2.5, 0.15) 数值 anchor (介于 PULSE 2.0/0.10 与 HEAVY 4.0/0.18 之间)")


# ---------- T185.SHOP.* — shop_menu 接入屏抖 ----------
func _run_t185_shop_integration_assertions() -> void:
	print("--- T185.SHOP.* — shop_menu 接入屏抖 ---")
	var src := _read_file(SHOP_MENU_GD)
	_assert_contains(src, "ScreenShake.has_method(\"shake_preset\")",
		"T185.SHOP.HAS_METHOD.1: shop_menu 用 has_method(\"shake_preset\") 守卫 (headless-safe)")
	_assert_contains(src, "ScreenShake.Preset.has(\"PERK_LEVEL_UP\")",
		"T185.SHOP.PRESET_HAS.1: shop_menu 用 Preset.has(\"PERK_LEVEL_UP\") 守卫 (老版本 ame 安全)")
	_assert_contains(src, "ScreenShake.shake_preset(ScreenShake.Preset.PERK_LEVEL_UP)",
		"T185.SHOP.CALL.1: shop_menu._on_buy_pressed 调 ScreenShake.shake_preset(PERK_LEVEL_UP)")
	_assert_contains(src, "new_count >= 2",
		"T185.SHOP.THRESHOLD.1: 阈值 new_count >= 2 (level II+ 才屏抖, level 0=I 不抖)")
	_assert_contains(src, "T185 (#103)",
		"T185.SHOP.DOC.1: shop_menu 注释含 T185 (#103) 锚点")
	# 顺序: shake_preset 在 play_shop_level_up 之后 (audio 先, visual shake 后)
	var audio_pos := src.find("ame.play_shop_level_up(max(0, new_count - 1))")
	var shake_pos := src.find("ScreenShake.shake_preset(ScreenShake.Preset.PERK_LEVEL_UP)")
	if audio_pos != -1 and shake_pos != -1 and audio_pos < shake_pos:
		_passes += 1
		print("  OK  T185.SHOP.ORDER.1: 顺序 arpeggio → screen_shake (audio 先, visual 紧接)")
	else:
		_failures.append("FAIL: T185.SHOP.ORDER.1: 顺序错 audio=%d shake=%d" % [audio_pos, shake_pos])


# ===================== T185.B — prewarm_misc_sfx 聚合器扩展 =====================

# ---------- T185B.PRE — prewarm_misc_sfx 公开方法 ----------
func _run_t185b_prewarm_assertions() -> void:
	print("--- T185B.PRE — prewarm_misc_sfx 公开方法 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_misc_sfx() -> void:",
		"T185B.PRE.SIG.1: prewarm_misc_sfx() -> void: 公开方法声明")
	_assert_contains(src, "_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"T185B.PRE.UNLOCK.1: prewarm_misc_sfx 调 _generate_unlock_chime_sfx() (F014 集成)")
	_assert_contains(src, "_delete_confirm_stream = _generate_delete_confirm_sfx()",
		"T185B.PRE.DELETE.1: prewarm_misc_sfx 调 _generate_delete_confirm_sfx() (F015 集成)")
	_assert_contains(src, "T185.B (#103)",
		"T185B.PRE.DOC.1: prewarm_misc_sfx 注释含 T185.B (#103) 锚点")


# ---------- T185B.PRE.ALL — aggregator 扩展 ----------
func _run_t185b_prewarm_all_assertions() -> void:
	print("--- T185B.PRE.ALL — aggregator 扩展 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 顺序: music → hit → shop → misc (在 prewarm_all_sfx 体内).
	# 用更精确的 needle (前后带 \n 缩进) 避免匹配到函数定义本身.
	var prewarm_all_body := src.find("func prewarm_all_sfx() -> void:")
	if prewarm_all_body == -1:
		_failures.append("FAIL: T185B.PRE.ALL.ORDER.1: prewarm_all_sfx 函数未找到")
		return
	var body := src.substr(prewarm_all_body)
	# 找 "prewarm_xxx_sfx()" 在 body 内的相对位置, 但 src.find 也是全局,
	# 所以用更精确的子串 (e.g. "\n\tprewarm_hit_sfx()\n\tprewarm_shop_sfx()")
	# 这只在 aggregator 体内出现一次.
	var music_pos := src.find("\tprewarm_music_streams()")
	var hit_pos := src.find("\tprewarm_hit_sfx()")
	var shop_pos := src.find("\tprewarm_shop_sfx()")
	var misc_pos := src.find("\tprewarm_misc_sfx()")
	if music_pos != -1 and hit_pos != -1 and shop_pos != -1 and misc_pos != -1 \
			and music_pos < hit_pos and hit_pos < shop_pos and shop_pos < misc_pos:
		_passes += 1
		print("  OK  T185B.PRE.ALL.ORDER.1: aggregator 顺序 music → hit → shop → misc (4 桶)")
	else:
		_failures.append("FAIL: T185B.PRE.ALL.ORDER.1: aggregator 顺序错 music=%d hit=%d shop=%d misc=%d" % [music_pos, hit_pos, shop_pos, misc_pos])
	_assert_contains(src, "T185.B (#103)",
		"T185B.PRE.ALL.DOC.1: aggregator 注释含 T185.B (#103) 锚点")


# ---------- T185B.TITLE — title_screen 接入 prewarm_misc_sfx ----------
func _run_t185b_title_integration_assertions() -> void:
	print("--- T185B.TITLE — title_screen 接入 prewarm_misc_sfx ---")
	var src := _read_file(TITLE_SCREEN_GD)
	_assert_contains(src, "ame.has_method(\"prewarm_misc_sfx\")",
		"T185B.TITLE.HAS_METHOD.1: title_screen 用 has_method(\"prewarm_misc_sfx\") 守卫 (headless-safe)")
	_assert_contains(src, "ame.call(\"prewarm_misc_sfx\")",
		"T185B.TITLE.CALL.1: title_screen._prewarm_bgm 调 ame.call(\"prewarm_misc_sfx\")")
	_assert_contains(src, "T185.B (#103)",
		"T185B.TITLE.DOC.1: title_screen 注释含 T185.B (#103) 锚点")
	# 顺序: prewarm_misc_sfx 在 prewarm_shop_sfx 之后
	var shop_pos := src.find("ame.call(\"prewarm_shop_sfx\")")
	var misc_pos := src.find("ame.call(\"prewarm_misc_sfx\")")
	if shop_pos != -1 and misc_pos != -1 and shop_pos < misc_pos:
		_passes += 1
		print("  OK  T185B.TITLE.ORDER.1: title_screen 顺序 shop → misc (T184 + T185.B 增量)")
	else:
		_failures.append("FAIL: T185B.TITLE.ORDER.1: title_screen 顺序错 shop=%d misc=%d" % [shop_pos, misc_pos])


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
	print("--- I015 (#103) F014 + F015 + T185 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
