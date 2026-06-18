extends SceneTree
## I017 (#106) — F013.B 5 verb cooldown TAIL jingle + T187 cut_combo 屏抖 冒烟测试
##
## 覆盖 #106 二任务原子化提交:
##
## === F013.B — 5 verb cooldown TAIL jingle (与 T181 ready jingle 对偶) ===
## - F013.B.FIELD: _verb_cooldown_tail_streams: Dictionary 字段声明
## - F013.B.PLAY.SIG: play_verb_cooldown_tail(verb_name: String) 公开方法已声明
## - F013.B.PLAY.LAZY: lazy-init 守卫 (Dict.has(verb_name) → 生成)
## - F013.B.PLAY.BUS: play_sfx(stream) 走 SFX bus
## - F013.B.START_MIDI.PULSE: pulse → 73 (C5 → A4 降 4 半音, 镜像 T181 A4 → C5)
## - F013.B.START_MIDI.BIND:  bind → 76 (E5 → C5 降 4 半音, 镜像 T181 C5 → E5)
## - F013.B.START_MIDI.CUT:   cut → 80 (G#5 → E5 降 4 半音, 镜像 T181 E5 → G5)
## - F013.B.START_MIDI.ECHO:  echo → 81 (A5 → G5 降 4 半音, 镜像 T181 G5 → A5)
## - F013.B.START_MIDI.WAVE:  wave → 85 (C6 → A5 降 4 半音, 镜像 T181 A5 → C6)
## - F013.B.START_MIDI.UNKNOWN: 未知 verb_name → -1 (no-op 防御)
## - F013.B.GEN.SIG: _generate_verb_cooldown_tail_jingle(start_midi) 私有 synth
## - F013.B.GEN.DUR: 0.12s duration (略长于 T181 ready 0.10s 暗示 "event start")
## - F013.B.GEN.ENV: exp(-t*12) 略慢衰减
## - F013.B.GEN.AMP: 0.18 amplitude (与 T181 ready 一致)
## - F013.B.GEN.RAMP: 降 4 半音 (f1 = start_midi - 4)
## - F013.B.PRE.SIG: prewarm_verb_cooldown_tails() 公开方法
## - F013.B.PRE.LOOP: 5 verb 循环 (pulse/bind/cut/echo/wave)
## - F013.B.PRE.CACHE: 5 stream 全部 cache 到 _verb_cooldown_tail_streams
## - F013.B.PRE.AGGREGATOR: prewarm_all_sfx() 末尾追加 prewarm_verb_cooldown_tails
## - F013.B.PRE.ORDER: 5 桶 aggregator 顺序 music → hit → shop → misc → verb_cooldown_tail
## - F013.B.PULSE.CALLER: pulse_ability._execute_pulse() 末尾调 play_verb_cooldown_tail("pulse")
## - F013.B.BIND.CALLER:  bind_ability._execute_bind() 末尾调 play_verb_cooldown_tail("bind")
## - F013.B.CUT.CALLER:   cut_ability._execute_cut() 末尾调 play_verb_cooldown_tail("cut")
## - F013.B.ECHO.CALLER:  echo_ability._execute_echo() 末尾调 play_verb_cooldown_tail("echo")
## - F013.B.WAVE.CALLER:  resonance_wave_ability._execute_wave() 末尾调 play_verb_cooldown_tail("wave")
## - F013.B.HAS_METHOD: 5 verb caller 全部用 AudioManagerEnhanced.has_method 守卫
##
## === T187 — Cut combo 屏抖 PERK_LEVEL_UP preset (与 T146 wave_combo 对偶) ===
## - T187.EXPORT: cut_combo_threshold: int = 3 @export 字段
## - T187.EXPORT_DOC: 注释含 T187 (#106) 锚点
## - T187.THRESHOLD_DEFAULT: 默认 3 (max_targets=6 半数阈值)
## - T187.SHAKE.GUARD: hits.size() >= cut_combo_threshold 守卫
## - T187.SHAKE.HAS_METHOD: shake_preset 用 has_method 守卫
## - T187.SHAKE.PRESET_GUARD: Preset.get("PERK_LEVEL_UP", -1) 防御
## - T187.SHAKE.CALL: shake_preset(PERK_LEVEL_UP) 调
## - T187.FLASH.HAS_METHOD: flash_color 用 has_method 守卫
## - T187.FLASH.CALL: flash_color(...) 调
## - T187.FLASH.COLOR: Color(0.902, 0.663, 0.235, 1.0) Amber Cut #E6A93C
## - T187.FLASH.DUR: 0.15s duration (短促反馈)
## - T187.FLASH.PEAK: 0.22 peak alpha (略高于 per-hit 0.18 区分 "做对事")
## - T187.FLASH.LAYER: 256 flash_layer (T163 #84 屏抖之上, 不与 per-hit 128 互消)

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I017 (#106) — F013.B 5 verb cooldown TAIL jingle + T187 cut_combo 屏抖 ===")
	_run_f013b_field_assertions()
	_run_f013b_play_api_assertions()
	_run_f013b_start_midi_assertions()
	_run_f013b_gen_synth_assertions()
	_run_f013b_prewarm_assertions()
	_run_f013b_5_verb_caller_assertions()
	_run_t187_export_assertions()
	_run_t187_shake_assertions()
	_run_t187_flash_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I017 (#106) F013.B + T187 ASSERTIONS PASSED ===")
		quit(0)


# ===================== F013.B — 5 verb cooldown TAIL jingle =====================

# ---------- F013.B.FIELD — 字段声明 ----------
func _run_f013b_field_assertions() -> void:
	print("--- F013.B.FIELD — 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _verb_cooldown_tail_streams: Dictionary = {}",
		"F013.B.FIELD.1: _verb_cooldown_tail_streams: Dictionary 字段声明 (F013.B #106 新增)")


# ---------- F013.B.PLAY.* — 公开 API + lazy ----------
func _run_f013b_play_api_assertions() -> void:
	print("--- F013.B.PLAY.* — 公开 API + lazy ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_verb_cooldown_tail(verb_name: String) -> void:",
		"F013.B.PLAY.SIG.1: play_verb_cooldown_tail(verb_name: String) 公开方法声明")
	_assert_contains(src, "if not _verb_cooldown_tail_streams.has(verb_name):",
		"F013.B.PLAY.LAZY.1: lazy-init 守卫 (Dict.has 检查, 与 T181 ready pattern 一致)")
	_assert_contains(src, "_verb_cooldown_tail_streams[verb_name] = _generate_verb_cooldown_tail_jingle(start_midi)",
		"F013.B.PLAY.LAZY.2: lazy 路径调 _generate_verb_cooldown_tail_jingle 生成 stream")
	_assert_contains(src, "if stream:",
		"F013.B.PLAY.LAZY.3: stream 有效性 check 防御")
	_assert_contains(src, "play_sfx(stream)",
		"F013.B.PLAY.BUS.1: play_sfx(stream) 走 SFX bus")


# ---------- F013.B.START_MIDI.* — 5 verb 起始 MIDI 映射 ----------
func _run_f013b_start_midi_assertions() -> void:
	print("--- F013.B.START_MIDI.* — 5 verb 起始 MIDI 映射 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _verb_cooldown_tail_start_midi(verb_name: String) -> int:",
		"F013.B.START_MIDI.SIG.1: _verb_cooldown_tail_start_midi(verb_name) 私有 helper")
	# 5 verb 起始 MIDI: pulse=73, bind=76, cut=80, echo=81, wave=85 (镜像 T181 ready 起点 + 4 半音)
	_assert_contains(src, '"pulse": return 73',
		"F013.B.START_MIDI.PULSE.1: pulse → 73 (C5 → A4 降 4 半音, 镜像 T181 A4 → C5)")
	_assert_contains(src, '"bind":  return 76',
		"F013.B.START_MIDI.BIND.1: bind → 76 (E5 → C5 降 4 半音, 镜像 T181 C5 → E5)")
	_assert_contains(src, '"cut":   return 80',
		"F013.B.START_MIDI.CUT.1: cut → 80 (G#5 → E5 降 4 半音, 镜像 T181 E5 → G5)")
	_assert_contains(src, '"echo":  return 81',
		"F013.B.START_MIDI.ECHO.1: echo → 81 (A5 → G5 降 4 半音, 镜像 T181 G5 → A5)")
	_assert_contains(src, '"wave":  return 85',
		"F013.B.START_MIDI.WAVE.1: wave → 85 (C6 → A5 降 4 半音, 镜像 T181 A5 → C6)")
	_assert_contains(src, "return -1",
		"F013.B.START_MIDI.UNKNOWN.1: 未知 verb_name → -1 (no-op 防御, 6th verb 友好)")


# ---------- F013.B.GEN.* — 私有 synth 函数 ----------
func _run_f013b_gen_synth_assertions() -> void:
	print("--- F013.B.GEN.* — 私有 synth 函数 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_verb_cooldown_tail_jingle(start_midi: int) -> AudioStreamWAV:",
		"F013.B.GEN.SIG.1: _generate_verb_cooldown_tail_jingle(start_midi) 私有 synth")
	_assert_contains(src, "var duration := 0.12",
		"F013.B.GEN.DUR.1: 0.12s duration (略长于 T181 ready 0.10s 暗示 \"event start\")")
	_assert_contains(src, "exp(-t * 12.0)",
		"F013.B.GEN.ENV.1: exp(-t*12) 略慢衰减 (T181 ready 是 exp(-t*15), 0.02s 留 0.005s 余量)")
	_assert_contains(src, "env * 0.18",
		"F013.B.GEN.AMP.1: 0.18 amplitude (与 T181 ready 一致, 不抢 verb fire SFX 风头)")
	# 降 4 半音: f1 = start_midi - 4
	_assert_contains(src, "start_midi - 69 - 4) / 12.0",
		"F013.B.GEN.RAMP.1: f1 = (start_midi - 4) 降 4 半音 (T181 ready 升 4 半音的镜像方向)")


# ---------- F013.B.PRE.* — prewarm 钩子 ----------
func _run_f013b_prewarm_assertions() -> void:
	print("--- F013.B.PRE.* — prewarm 钩子 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_verb_cooldown_tails() -> void:",
		"F013.B.PRE.SIG.1: prewarm_verb_cooldown_tails() 公开方法 (5 桶 aggregator 最后 1 桶)")
	# 5 verb 循环: pulse/bind/cut/echo/wave
	_assert_contains(src, "for verb_name in [\"pulse\", \"bind\", \"cut\", \"echo\", \"wave\"]:",
		"F013.B.PRE.LOOP.1: 5 verb 循环 (pulse / bind / cut / echo / wave)")
	# cache 写入: _verb_cooldown_tail_streams[verb_name] = _generate_verb_cooldown_tail_jingle(...)
	# 找 prewarm_verb_cooldown_tails 函数体
	var prewarm_body_start := src.find("func prewarm_verb_cooldown_tails() -> void:")
	if prewarm_body_start == -1:
		_failures.append("FAIL: F013.B.PRE.CACHE.1: prewarm_verb_cooldown_tails 函数未找到")
	# aggregator 集成: prewarm_all_sfx() 末尾追加 prewarm_verb_cooldown_tails
	var aggregator_body_start := src.find("func prewarm_all_sfx() -> void:")
	if aggregator_body_start == -1:
		_failures.append("FAIL: F013.B.PRE.AGGREGATOR.1: prewarm_all_sfx 函数未找到")
	# 5 桶顺序: music → hit → shop → misc → verb_cooldown_tail
	# 找 aggregator body 内的 5 个 helper call
	var prewarm_calls := ["prewarm_music_streams()", "prewarm_hit_sfx()", "prewarm_shop_sfx()",
		"prewarm_misc_sfx()", "prewarm_verb_cooldown_tails()"]
	var last_pos := -1
	var order_ok := true
	var order_strs := []
	if prewarm_body_start != -1:
		var prewarm_body := src.substr(prewarm_body_start)
		_assert_contains(prewarm_body, "_verb_cooldown_tail_streams[verb_name] = _generate_verb_cooldown_tail_jingle(start_midi)",
			"F013.B.PRE.CACHE.1: 5 stream 全部 cache 到 _verb_cooldown_tail_streams (lazy-init 模式)")
	if aggregator_body_start != -1:
		var aggregator_body := src.substr(aggregator_body_start)
		_assert_contains(aggregator_body, "prewarm_verb_cooldown_tails()",
			"F013.B.PRE.AGGREGATOR.1: prewarm_all_sfx() 末尾追加 prewarm_verb_cooldown_tails (5 桶聚合)")
		for call in prewarm_calls:
			var pos := aggregator_body.find(call)
			if pos == -1:
				order_ok = false
				order_strs.append("%s=MISSING" % call)
			else:
				order_strs.append("%s=%d" % [call, pos])
				if pos <= last_pos:
					order_ok = false
				last_pos = pos
	if order_ok:
		_passes += 1
		print("  OK  F013.B.PRE.ORDER.1: 5 桶 aggregator 顺序 music → hit → shop → misc → verb_cooldown_tail (符合 1-line-per-bucket 模式)")
	else:
		_failures.append("FAIL: F013.B.PRE.ORDER.1: 5 桶顺序错: %s" % ", ".join(order_strs))


# ---------- F013.B.<verb>.CALLER — 5 verb 接入 ----------
func _run_f013b_5_verb_caller_assertions() -> void:
	print("--- F013.B.<verb>.CALLER — 5 verb 接入 ---")
	var checks := [
		[PULSE_ABILITY_GD, "F013.B.PULSE.CALLER.1", "play_verb_cooldown_tail(\"pulse\")",
			"pulse_ability._execute_pulse() 末尾调 play_verb_cooldown_tail(\"pulse\")"],
		[BIND_ABILITY_GD, "F013.B.BIND.CALLER.1", "play_verb_cooldown_tail(\"bind\")",
			"bind_ability._execute_bind() 末尾调 play_verb_cooldown_tail(\"bind\")"],
		[CUT_ABILITY_GD, "F013.B.CUT.CALLER.1", "play_verb_cooldown_tail(\"cut\")",
			"cut_ability._execute_cut() 末尾调 play_verb_cooldown_tail(\"cut\")"],
		[ECHO_ABILITY_GD, "F013.B.ECHO.CALLER.1", "play_verb_cooldown_tail(\"echo\")",
			"echo_ability._execute_echo() 末尾调 play_verb_cooldown_tail(\"echo\")"],
		[WAVE_ABILITY_GD, "F013.B.WAVE.CALLER.1", "play_verb_cooldown_tail(\"wave\")",
			"resonance_wave_ability._execute_wave() 末尾调 play_verb_cooldown_tail(\"wave\")"],
	]
	for check in checks:
		var path: String = check[0]
		var tag: String = check[1]
		var needle: String = check[2]
		var msg: String = check[3]
		var src := _read_file(path)
		_assert_contains(src, needle, "%s: %s" % [tag, msg])
		_assert_contains(src, "AudioManagerEnhanced.has_method(\"play_verb_cooldown_tail\")",
			"%s.2: 5 verb caller 全部用 has_method 守卫 (headless-safe + 老版本 ame 兼容)" % tag)


# ===================== T187 — Cut combo 屏抖 =====================

# ---------- T187.EXPORT — 阈值字段 ----------
func _run_t187_export_assertions() -> void:
	print("--- T187.EXPORT — 阈值字段 ---")
	var src := _read_file(CUT_ABILITY_GD)
	_assert_contains(src, "@export var cut_combo_threshold: int = 3",
		"T187.EXPORT.1: cut_combo_threshold: int = 3 @export 字段 (T187 #106 新增, 与 T146 wave_combo_threshold 模式同源)")
	_assert_contains(src, "T187 (#106)",
		"T187.EXPORT_DOC.1: 注释含 T187 (#106) 锚点")
	_assert_contains(src, "max_targets=6",
		"T187.THRESHOLD_DEFAULT.1: 注释解释默认 3 = max_targets/2 (避免 1-2 敌人走位顺手斩都触发)")


# ---------- T187.SHAKE — 屏抖 PERK_LEVEL_UP preset ----------
func _run_t187_shake_assertions() -> void:
	print("--- T187.SHAKE — 屏抖 PERK_LEVEL_UP preset ---")
	var src := _read_file(CUT_ABILITY_GD)
	# 找 _perform_cut_hit_check 函数体（cut_combo 屏抖实现位置）
	var body_start := src.find("func _perform_cut_hit_check() -> void:")
	if body_start == -1:
		_failures.append("FAIL: T187.SHAKE.GUARD.1: _perform_cut_hit_check 函数未找到")
		return
	var body := src.substr(body_start)
	_assert_contains(body, "if hits.size() >= cut_combo_threshold:",
		"T187.SHAKE.GUARD.1: hits.size() >= cut_combo_threshold 守卫 (cut 1 cast 命中 ≥3 敌人)")
	_assert_contains(body, "ScreenShake.has_method(\"shake_preset\")",
		"T187.SHAKE.HAS_METHOD.1: shake_preset 用 has_method 守卫 (headless-safe)")
	_assert_contains(body, "ScreenShake.Preset.get(\"PERK_LEVEL_UP\", -1)",
		"T187.SHAKE.PRESET_GUARD.1: Preset.get(\"PERK_LEVEL_UP\", -1) 防御 (老版本 enum 未注册时降级)")
	_assert_contains(body, "ScreenShake.shake_preset(preset_id)",
		"T187.SHAKE.CALL.1: shake_preset(preset_id) 调 PERK_LEVEL_UP (T185 #103 preset 2.5/0.15s)")


# ---------- T187.FLASH — Amber Cut flash ----------
func _run_t187_flash_assertions() -> void:
	print("--- T187.FLASH — Amber Cut flash ---")
	var src := _read_file(CUT_ABILITY_GD)
	var body_start := src.find("func _perform_cut_hit_check() -> void:")
	if body_start == -1:
		_failures.append("FAIL: T187.FLASH.HAS_METHOD.1: _perform_cut_hit_check 函数未找到")
		return
	var body := src.substr(body_start)
	_assert_contains(body, "ScreenShake.has_method(\"flash_color\")",
		"T187.FLASH.HAS_METHOD.1: flash_color 用 has_method 守卫")
	_assert_contains(body, "Color(0.902, 0.663, 0.235, 1.0)",
		"T187.FLASH.COLOR.1: Color(0.902, 0.663, 0.235, 1.0) Amber Cut #E6A93C (STYLE_GUIDE 限制色板 token)")
	_assert_contains(body, "0.15, 0.22, 256",
		"T187.FLASH.DUR.1: 0.15s duration + 0.22 peak + 256 layer (略短略强于 per-hit 0.10/0.18, T163 #84 layer 256 不与 per-hit 128 互消)")


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I017 (#106) F013.B + T187 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
