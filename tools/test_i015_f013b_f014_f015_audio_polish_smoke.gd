extends SceneTree
## I015 (#103) — F013.B 5 verb cooldown jingle tail + F014 14 成就 unlock
## chime + F015 SaveSlot confirm click 冒烟测试
##
## 覆盖 #103 3 任务原子化提交:
##
## === F013.B (#103) — 5 verb cooldown jingle tail ===
## - F013B.FIELD: _verb_cooldown_tail_streams: Dictionary 字段声明
## - F013B.PLAY: play_verb_cooldown_tail(verb_name) 公开方法已声明
## - F013B.PLAY.LOOKUP: 复用 _verb_cooldown_start_midi() 5 verb 查表
## - F013B.PLAY.LAZY: lazy-init 守卫 (Dict.has → 生成)
## - F013B.GEN.SIG: _generate_verb_cooldown_tail(start_midi) 私有 synth
## - F013B.GEN.DUR: 0.10s duration (与主 jingle 同步)
## - F013B.GEN.PERF5: 完美 5 度 (f0 * 1.5) 双 note bell
## - F013B.GEN.HARMONIC: 2x harmonic 装饰音 (bell body)
## - F013B.PRE: prewarm_verb_cooldown_tail_streams() 公开方法已声明
## - F013B.PRE.5: prewarm 5 verb 循环 ["pulse", "bind", "cut", "echo", "wave"]
## - F013B.BASE.CALL: _verb_ability_base.gd._process_cooldown 调 play_verb_cooldown_tail
## - F013B.BASE.HAS_METHOD: has_method 守卫 (headless-safe)
## - F013B.BASE.ORDER: 跨 >0→<=0 帧后 play_verb_cooldown_ready 之后调 tail
##
## === F014 (#103) — 14 成就 unlock chime ===
## - F014.FIELD: _unlock_chime_stream: AudioStreamWAV 字段声明
## - F014.PLAY: play_unlock_chime() 公开方法已声明
## - F014.PLAY.LAZY: lazy-init 守卫 (null check)
## - F014.GEN.SIG: _generate_unlock_chime_sfx() 私有 synth
## - F014.GEN.TRIAD: C6 1046.5Hz + E6 1318.5Hz + G6 1568.0Hz 大三和弦 (1 oct above shop)
## - F014.GEN.DUR: 0.3s duration
## - F014.GEN.ENV: exp(-t*7) 衰减 (比 shop 3.5 慢, chime rings)
## - F014.PRE: prewarm_unlock_chime() 公开方法已声明
## - F014.NOTIFY.CALL: achievement_notification._on_achievement_unlocked 调 ame.play_unlock_chime
## - F014.NOTIFY.HAS_METHOD: has_method 守卫 (headless-safe)
## - F014.NOTIFY.AUTOLOAD: 走 /root/AudioManagerEnhanced autoload 路径
##
## === F015 (#103) — SaveSlot confirm click ===
## - F015.FIELD: _save_slot_confirm_stream: AudioStreamWAV 字段声明
## - F015.PLAY: play_save_slot_confirm() 公开方法已声明
## - F015.PLAY.LAZY: lazy-init 守卫 (null check)
## - F015.GEN.SIG: _generate_save_slot_confirm_sfx() 私有 synth
## - F015.GEN.DUR: 0.20s duration
## - F015.GEN.PULSE1: 2400Hz + 2x harmonic 第一脉冲
## - F015.GEN.PULSE2: 2600Hz 第二脉冲 (8ms gap, 音调变体)
## - F015.PRE: prewarm_save_slot_confirm() 公开方法已声明
## - F015.MENU.CALL: save_load_menu._on_delete 调 ame.play_save_slot_confirm
## - F015.MENU.HAS_METHOD: has_method 守卫 (headless-safe)
##
## === T184 聚合器增量 ===
## - T184.PRE.ALL.TAIL: prewarm_all_sfx 调 prewarm_verb_cooldown_tail_streams
## - T184.PRE.ALL.UNLOCK: prewarm_all_sfx 调 prewarm_unlock_chime
## - T184.PRE.ALL.SAVE: prewarm_all_sfx 调 prewarm_save_slot_confirm

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"
const ACHIEVEMENT_NOTIFICATION_GD := "res://src/scripts/achievement_notification.gd"
const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I015 (#103) — F013.B cooldown tail + F014 unlock chime + F015 save confirm ===")
	_run_f013b_field_assertions()
	_run_f013b_play_api_assertions()
	_run_f013b_gen_synth_assertions()
	_run_f013b_prewarm_assertions()
	_run_f013b_base_integration_assertions()
	_run_f014_field_assertions()
	_run_f014_play_api_assertions()
	_run_f014_gen_synth_assertions()
	_run_f014_prewarm_assertions()
	_run_f014_notification_integration_assertions()
	_run_f015_field_assertions()
	_run_f015_play_api_assertions()
	_run_f015_gen_synth_assertions()
	_run_f015_prewarm_assertions()
	_run_f015_menu_integration_assertions()
	_run_t184_prewarm_all_aggregator_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I015 (#103) F013.B + F014 + F015 ASSERTIONS PASSED ===")
		quit(0)


# ===================== F013.B — 5 verb cooldown jingle tail =====================

# ---------- F013B.FIELD — _verb_cooldown_tail_streams 字段声明 ----------
func _run_f013b_field_assertions() -> void:
	print("--- F013B.FIELD — _verb_cooldown_tail_streams 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _verb_cooldown_tail_streams: Dictionary = {}",
		"F013B.FIELD.1: _verb_cooldown_tail_streams: Dictionary 字段声明 (5 verb 5 stream 缓存)")


# ---------- F013B.PLAY — play_verb_cooldown_tail 公开 API + lazy + lookup ----------
func _run_f013b_play_api_assertions() -> void:
	print("--- F013B.PLAY — play_verb_cooldown_tail 公开 API ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_verb_cooldown_tail(verb_name: String) -> void:",
		"F013B.PLAY.1: play_verb_cooldown_tail(verb_name) -> void: 公开方法声明")
	# 复用 _verb_cooldown_start_midi() 5 verb 查表
	_assert_contains(src, "var start_midi: int = _verb_cooldown_start_midi(verb_name)",
		"F013B.PLAY.LOOKUP.1: 复用 _verb_cooldown_start_midi(verb_name) 5 verb 查表 (与主 jingle 一致)")
	# 未知 verb 静默 no-op (与 play_verb_cooldown_ready 一致)
	_assert_contains(src, "return  # Unknown verb — silently no-op",
		"F013B.PLAY.UNKNOWN.1: 未知 verb 静默 no-op (与主 jingle 防御一致)")
	# lazy 守卫
	_assert_contains(src, "if not _verb_cooldown_tail_streams.has(verb_name):",
		"F013B.PLAY.LAZY.1: lazy-init 守卫 (Dict.has(verb_name))")
	_assert_contains(src, "_verb_cooldown_tail_streams[verb_name] = _generate_verb_cooldown_tail(start_midi)",
		"F013B.PLAY.LAZY.2: lazy 路径调 _generate_verb_cooldown_tail(start_midi)")
	# 走 SFX bus
	_assert_contains(src, "play_sfx(stream)",
		"F013B.PLAY.BUS.1: play_sfx(stream) 走 SFX bus (与主 jingle 一致)")


# ---------- F013B.GEN — _generate_verb_cooldown_tail 合成器 ----------
func _run_f013b_gen_synth_assertions() -> void:
	print("--- F013B.GEN — _generate_verb_cooldown_tail 合成器 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_verb_cooldown_tail(start_midi: int) -> AudioStreamWAV:",
		"F013B.GEN.SIG.1: _generate_verb_cooldown_tail(start_midi) -> AudioStreamWAV 私有 synth")
	# 0.10s duration (与主 jingle 同步)
	_assert_contains(src, "var duration := 0.10",
		"F013B.GEN.DUR.1: 0.10s duration (与主 jingle 同步 → 0.10s + 0.10s = 0.20s total)")
	# 完美 5 度 (f0 * 1.5) 双 note
	_assert_contains(src, "var f1: float = f0 * 1.5",
		"F013B.GEN.PERF5.1: 完美 5 度 f0 * 1.5 (与主 jingle 的 4 semitones 形成对比)")
	# 2x harmonic 装饰 (bell body)
	_assert_contains(src, "sin(t * TAU * f0 * 2.0)",
		"F013B.GEN.HARMONIC.1: 2x harmonic f0 * 2 (bell body, 与 shop/unlock 同源)")


# ---------- F013B.PRE — prewarm_verb_cooldown_tail_streams ----------
func _run_f013b_prewarm_assertions() -> void:
	print("--- F013B.PRE — prewarm_verb_cooldown_tail_streams ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_verb_cooldown_tail_streams() -> void:",
		"F013B.PRE.1: prewarm_verb_cooldown_tail_streams() -> void: 公开方法声明")
	# 5 verb 循环 ["pulse", "bind", "cut", "echo", "wave"]
	_assert_contains(src, "for verb_name in [\"pulse\", \"bind\", \"cut\", \"echo\", \"wave\"]:",
		"F013B.PRE.5.1: prewarm 5 verb 循环 [\"pulse\", \"bind\", \"cut\", \"echo\", \"wave\"]")
	# start_midi 查表 + continue 防御
	_assert_contains(src, "var start_midi: int = _verb_cooldown_start_midi(verb_name)",
		"F013B.PRE.5.2: prewarm 复用 _verb_cooldown_start_midi(verb_name) 查表")
	_assert_contains(src, "if start_midi < 0:\n\t\t\tcontinue",
		"F013B.PRE.5.3: start_midi < 0 防御 (6th verb 友好)")
	# lazy 缓存
	_assert_contains(src, "if not _verb_cooldown_tail_streams.has(verb_name):",
		"F013B.PRE.5.4: prewarm Dict.has(verb_name) lazy 缓存守卫")
	# 文档块说明
	_assert_contains(src, "F013.B (#103)",
		"F013B.PRE.DOC.1: prewarm 注释含 F013.B (#103) 锚点")


# ---------- F013B.BASE — _verb_ability_base.gd 接入 ----------
func _run_f013b_base_integration_assertions() -> void:
	print("--- F013B.BASE — _verb_ability_base.gd._process_cooldown 接入 ---")
	var src := _read_file(VERB_ABILITY_BASE_GD)
	# has_method 守卫
	_assert_contains(src, "has_method(\"play_verb_cooldown_tail\")",
		"F013B.BASE.HAS_METHOD.1: _verb_ability_base 用 has_method(\"play_verb_cooldown_tail\") 守卫 (headless-safe)")
	# 调 play_verb_cooldown_tail
	_assert_contains(src, "AudioManagerEnhanced.play_verb_cooldown_tail(verb_name)",
		"F013B.BASE.CALL.1: _verb_ability_base._process_cooldown 调 AudioManagerEnhanced.play_verb_cooldown_tail(verb_name)")
	# 顺序: play_verb_cooldown_ready 之后调 play_verb_cooldown_tail
	var ready_pos := src.find("play_verb_cooldown_ready(verb_name)")
	var tail_pos := src.find("play_verb_cooldown_tail(verb_name)")
	if ready_pos != -1 and tail_pos != -1 and ready_pos < tail_pos:
		_passes += 1
		print("  OK  F013B.BASE.ORDER.1: tail 在 ready 之后调 (主 jingle 先, 尾巴后)")
	else:
		_failures.append("FAIL: F013B.BASE.ORDER.1: 顺序错 ready=%d tail=%d" % [ready_pos, tail_pos])
	# 文档块说明
	_assert_contains(src, "F013.B (#103)",
		"F013B.BASE.DOC.1: _verb_ability_base 注释含 F013.B (#103) 锚点")


# ===================== F014 — 14 成就 unlock chime =====================

# ---------- F014.FIELD — _unlock_chime_stream 字段声明 ----------
func _run_f014_field_assertions() -> void:
	print("--- F014.FIELD — _unlock_chime_stream 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _unlock_chime_stream: AudioStreamWAV",
		"F014.FIELD.1: _unlock_chime_stream: AudioStreamWAV 字段声明")


# ---------- F014.PLAY — play_unlock_chime 公开 API + lazy ----------
func _run_f014_play_api_assertions() -> void:
	print("--- F014.PLAY — play_unlock_chime 公开 API ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_unlock_chime() -> void:",
		"F014.PLAY.1: play_unlock_chime() -> void: 公开方法声明")
	# lazy 守卫
	_assert_contains(src, "if _unlock_chime_stream == null:",
		"F014.PLAY.LAZY.1: lazy-init 守卫 (null check)")
	_assert_contains(src, "_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"F014.PLAY.LAZY.2: lazy 路径调 _generate_unlock_chime_sfx()")
	# 走 SFX bus
	_assert_contains(src, "play_sfx(_unlock_chime_stream)",
		"F014.PLAY.BUS.1: play_sfx(_unlock_chime_stream) 走 SFX bus")


# ---------- F014.GEN — _generate_unlock_chime_sfx 合成器 ----------
func _run_f014_gen_synth_assertions() -> void:
	print("--- F014.GEN — _generate_unlock_chime_sfx 合成器 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_unlock_chime_sfx() -> AudioStreamWAV:",
		"F014.GEN.SIG.1: _generate_unlock_chime_sfx() -> AudioStreamWAV 私有 synth")
	# C6 1046.5Hz + E6 1318.5Hz + G6 1568.0Hz 大三和弦 (1 oct above shop)
	_assert_contains(src, "1046.5",
		"F014.GEN.TRIAD.1: C6 1046.5Hz 大三和弦 anchor (1 oct above shop C5 523.25)")
	_assert_contains(src, "1318.5",
		"F014.GEN.TRIAD.2: E6 1318.5Hz 大三和弦 anchor (1 oct above shop E5 659.26)")
	_assert_contains(src, "1568.0",
		"F014.GEN.TRIAD.3: G6 1568.0Hz 大三和弦 anchor (1 oct above shop G5 783.99)")
	# 0.3s duration
	_assert_contains(src, "var duration := 0.3",
		"F014.GEN.DUR.1: 0.3s duration (3.0s 通知卡显示窗口内 ring out)")
	# exp(-t*7) 衰减 (比 shop 3.5 慢)
	_assert_contains(src, "exp(-t * 7.0)",
		"F014.GEN.ENV.1: exp(-t*7) 衰减 (比 shop 3.5 慢 → 'rings' longer)")


# ---------- F014.PRE — prewarm_unlock_chime ----------
func _run_f014_prewarm_assertions() -> void:
	print("--- F014.PRE — prewarm_unlock_chime ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_unlock_chime() -> void:",
		"F014.PRE.1: prewarm_unlock_chime() -> void: 公开方法声明")
	# lazy 守卫
	_assert_contains(src, "if _unlock_chime_stream == null:\n\t\t_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"F014.PRE.LAZY.1: prewarm 守卫 + _generate_unlock_chime_sfx() 调用")
	# 文档块说明
	_assert_contains(src, "F014 (#103)",
		"F014.PRE.DOC.1: prewarm 注释含 F014 (#103) 锚点")


# ---------- F014.NOTIFY — achievement_notification 接入 ----------
func _run_f014_notification_integration_assertions() -> void:
	print("--- F014.NOTIFY — achievement_notification 接入 ---")
	var src := _read_file(ACHIEVEMENT_NOTIFICATION_GD)
	# has_method 守卫
	_assert_contains(src, "has_method(\"play_unlock_chime\")",
		"F014.NOTIFY.HAS_METHOD.1: achievement_notification 用 has_method(\"play_unlock_chime\") 守卫 (headless-safe)")
	# 调 play_unlock_chime
	_assert_contains(src, "audio.play_unlock_chime()",
		"F014.NOTIFY.CALL.1: achievement_notification._on_achievement_unlocked 调 audio.play_unlock_chime()")
	# autoload 路径
	_assert_contains(src, "get_node_or_null(\"/root/AudioManagerEnhanced\")",
		"F014.NOTIFY.AUTOLOAD.1: 走 /root/AudioManagerEnhanced autoload 路径 (与其他 audio 调用一致)")
	# 文档块说明
	_assert_contains(src, "F014 (#103)",
		"F014.NOTIFY.DOC.1: achievement_notification 注释含 F014 (#103) 锚点")


# ===================== F015 — SaveSlot confirm click =====================

# ---------- F015.FIELD — _save_slot_confirm_stream 字段声明 ----------
func _run_f015_field_assertions() -> void:
	print("--- F015.FIELD — _save_slot_confirm_stream 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _save_slot_confirm_stream: AudioStreamWAV",
		"F015.FIELD.1: _save_slot_confirm_stream: AudioStreamWAV 字段声明")


# ---------- F015.PLAY — play_save_slot_confirm 公开 API + lazy ----------
func _run_f015_play_api_assertions() -> void:
	print("--- F015.PLAY — play_save_slot_confirm 公开 API ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_save_slot_confirm() -> void:",
		"F015.PLAY.1: play_save_slot_confirm() -> void: 公开方法声明")
	# lazy 守卫
	_assert_contains(src, "if _save_slot_confirm_stream == null:\n\t\t_save_slot_confirm_stream = _generate_save_slot_confirm_sfx()",
		"F015.PLAY.LAZY.1: lazy-init 守卫 (null check) + _generate_save_slot_confirm_sfx() 调用")
	# 走 SFX bus
	_assert_contains(src, "play_sfx(_save_slot_confirm_stream)",
		"F015.PLAY.BUS.1: play_sfx(_save_slot_confirm_stream) 走 SFX bus")


# ---------- F015.GEN — _generate_save_slot_confirm_sfx 合成器 ----------
func _run_f015_gen_synth_assertions() -> void:
	print("--- F015.GEN — _generate_save_slot_confirm_sfx 合成器 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_save_slot_confirm_sfx() -> AudioStreamWAV:",
		"F015.GEN.SIG.1: _generate_save_slot_confirm_sfx() -> AudioStreamWAV 私有 synth")
	# 0.20s duration
	_assert_contains(src, "var duration := 0.20",
		"F015.GEN.DUR.1: 0.20s duration (与 jingle 0.20s 同长度, 但音色 = click)")
	# 2400Hz 第一脉冲
	_assert_contains(src, "2400.0",
		"F015.GEN.PULSE1.1: 2400Hz 第一脉冲 anchor (高频 click 主体)")
	# 2600Hz 第二脉冲 (8ms gap, 音调变体)
	_assert_contains(src, "2600.0",
		"F015.GEN.PULSE2.1: 2600Hz 第二脉冲 anchor (8ms gap, 音调变体 → 'click-click')")
	_assert_contains(src, "t >= 0.08 and t < 0.14",
		"F015.GEN.PULSE2.2: 第二脉冲 0.08-0.14s 时间窗 (8ms gap after first pulse)")


# ---------- F015.PRE — prewarm_save_slot_confirm ----------
func _run_f015_prewarm_assertions() -> void:
	print("--- F015.PRE — prewarm_save_slot_confirm ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_save_slot_confirm() -> void:",
		"F015.PRE.1: prewarm_save_slot_confirm() -> void: 公开方法声明")
	# lazy 守卫
	_assert_contains(src, "if _save_slot_confirm_stream == null:\n\t\t_save_slot_confirm_stream = _generate_save_slot_confirm_sfx()",
		"F015.PRE.LAZY.1: prewarm 守卫 + _generate_save_slot_confirm_sfx() 调用")
	# 文档块说明
	_assert_contains(src, "F015 (#103)",
		"F015.PRE.DOC.1: prewarm 注释含 F015 (#103) 锚点")


# ---------- F015.MENU — save_load_menu 接入 ----------
func _run_f015_menu_integration_assertions() -> void:
	print("--- F015.MENU — save_load_menu._on_delete 接入 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	# has_method 守卫
	_assert_contains(src, "has_method(\"play_save_slot_confirm\")",
		"F015.MENU.HAS_METHOD.1: save_load_menu 用 has_method(\"play_save_slot_confirm\") 守卫 (headless-safe)")
	# 调 play_save_slot_confirm
	_assert_contains(src, "AudioManagerEnhanced.play_save_slot_confirm()",
		"F015.MENU.CALL.1: save_load_menu._on_delete 调 AudioManagerEnhanced.play_save_slot_confirm()")
	# 文档块说明
	_assert_contains(src, "F015 (#103)",
		"F015.MENU.DOC.1: save_load_menu 注释含 F015 (#103) 锚点")


# ===================== T184 聚合器增量 =====================

# ---------- T184.PRE.ALL — aggregator 增量 3 个新 prewarm ----------
func _run_t184_prewarm_all_aggregator_assertions() -> void:
	print("--- T184.PRE.ALL — aggregator 增量 3 个新 prewarm ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# prewarm_verb_cooldown_tail_streams 在 prewarm_all_sfx 内
	# Note: find() returns the FIRST occurrence which is the function
	# definition line; we need the LAST occurrence (the call site
	# inside prewarm_all_sfx).  Use rfind() to get the call site.
	var tail_pos := src.rfind("prewarm_verb_cooldown_tail_streams()")
	var unlock_pos := src.rfind("prewarm_unlock_chime()")
	var save_pos := src.rfind("prewarm_save_slot_confirm()")
	# 顺序: tail → unlock → save (按 F013.B → F014 → F015 落地顺序)
	if tail_pos != -1 and unlock_pos != -1 and save_pos != -1 \
			and tail_pos < unlock_pos and unlock_pos < save_pos:
		_passes += 1
		print("  OK  T184.PRE.ALL.TAIL.1: aggregator 顺序 tail → unlock → save (F013.B → F014 → F015)")
	else:
		_failures.append("FAIL: T184.PRE.ALL.TAIL.1: aggregator 顺序错 tail=%d unlock=%d save=%d" % [tail_pos, unlock_pos, save_pos])
	# 文档块说明
	_assert_contains(src, "F013.B (#103)",
		"T184.PRE.ALL.DOC.TAIL: aggregator 注释含 F013.B (#103) 锚点")
	_assert_contains(src, "F014 (#103)",
		"T184.PRE.ALL.DOC.UNLOCK: aggregator 注释含 F014 (#103) 锚点")
	_assert_contains(src, "F015 (#103)",
		"T184.PRE.ALL.DOC.SAVE: aggregator 注释含 F015 (#103) 锚点")


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
	print("--- I015 (#103) F013.B + F014 + F015 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
