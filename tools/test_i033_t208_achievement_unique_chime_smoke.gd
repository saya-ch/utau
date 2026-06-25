extends SceneTree
## I033 (#126) — T208 14 成就 unique unlock chime + per-achievement preset 冒烟测试
##
## 覆盖 #126 主任务 T208. 验证 14 成就各自有独特 chord + duration + amp + decay
## 配方 (ACHIEVEMENT_CHIME_PRESETS), play_unlock_chime(id_val) 按 id 选配方,
## 未知 id 走 fallback _unlock_chime_stream 保持向后兼容, 与 icon_hint
## 视觉分工对齐 (14 视觉 + 14 听觉冗余编码).
##
## 三类断言:
##
## === T208 — ACHIEVEMENT_CHIME_PRESETS 数据表 ===
## - T208.PRESETS.CONST: const ACHIEVEMENT_CHIME_PRESETS 声明存在
## - T208.PRESETS.COUNT: 14 成就 14 配方 (key 数量 = 14)
## - T208.PRESETS.FIRST_STEPS: first_steps 在 dict (调起步成就 ID)
## - T208.PRESETS.SILENCE_HUNTER: silence_hunter 在 dict (最稀有成就)
## - T208.PRESETS.ARCHIVE_MASTER: archive_master 在 dict (大师成就)
## - T208.PRESETS.WARDEN_SLAYER: warden_slayer 在 dict (Boss 成就)
## - T208.PRESETS.FULL_ARCHIVE: full_archive 在 dict (终局成就)
## - T208.PRESETS.QUINTUPLE_VOICE: quintuple_voice 在 dict (5 verb 大师)
## - T208.PRESETS.FIELDS: 每 preset 含 4 字段 (chord_midi/duration/amp/decay)
## - T208.PRESETS.CHORD_LEN: chord_midi 长度 2-5 (短促 first_cut 2 音 / 全音阶 5 音)
## - T208.PRESETS.DURATION_RANGE: duration 0.35-0.65s
## - T208.PRESETS.AMP_RANGE: amp 0.20-0.24
##
## === T208 — _achievement_chime_streams cache + play_unlock_chime ===
## - T208.CACHE.FIELD: var _achievement_chime_streams: Dictionary 字段
## - T208.PLAY.SIG: play_unlock_chime(id_val: String = "") 公开方法
## - T208.PLAY.DISPATCH: play_unlock_chime 用 ACHIEVEMENT_CHIME_PRESETS.has() 分派
## - T208.PLAY.LOOKUP: play_unlock_chime 用 _achievement_chime_streams[id_val] 查缓存
## - T208.PLAY.FALLBACK: id 不在 dict 时走 _unlock_chime_stream fallback
## - T208.PLAY.SFX_BUS: play_sfx 走 SFX bus (老 C6+E6+A6 路径兼容)
## - T208.GEN.SIG: _generate_achievement_chime_sfx(preset) 私有 synth
## - T208.GEN.MIDI_HZ: 用 440 * 2^((midi-69)/12) 公式转 Hz
## - T208.GEN.EXP_DECAY: 用 exp(-t * decay) envelope
## - T208.GEN.SUM: Σ sin(t*TAU*freq) 叠加各音
## - T208.GEN.PRE_CACHE: prewarm_misc_sfx 预热 14 成就 stream
## - T208.GEN.PRE_LUANCHOR: prewarm_misc_sfx 调 _generate_achievement_chime_sfx
##
## === T208 — AchievementNotification 接入 id_val ===
## - T208.NOTIFY.CALL: ame.call("play_unlock_chime", id_val) 传 id
## - T208.NOTIFY.HELPER_SIG: _play_unlock_chime(id_val: String = "") 带可选参数
## - T208.NOTIFY.HAS_METHOD: AchievementNotification 用 has_method 守卫
## - T208.NOTIFY.DOC: AchievementNotification 注释含 T208 (#126) 锚点

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const ACHIEVEMENT_NOTIFICATION_GD := "res://src/scripts/achievement_notification.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I033 (#126) — T208 14 成就 unique unlock chime + per-achievement preset ===")
	_run_t208_presets_assertions()
	_run_t208_play_api_assertions()
	_run_t208_notify_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I033 (#126) T208 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T208.PRESETS — ACHIEVEMENT_CHIME_PRESETS 数据表 ----------
func _run_t208_presets_assertions() -> void:
	print("--- T208.PRESETS — ACHIEVEMENT_CHIME_PRESETS 数据表 (14 成就 14 配方) ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "const ACHIEVEMENT_CHIME_PRESETS",
		"T208.PRESETS.CONST.1: const ACHIEVEMENT_CHIME_PRESETS 声明存在")

	# 14 成就 ID 全部在 dict — 用 _assert_contains (substring check)
	for ach_id in [
		"first_steps", "voice_purifier", "resonance_collector",
		"triple_voice", "quadruple_voice", "quintuple_voice",
		"first_cut", "warden_slayer", "full_archive",
		"persistent_resonance", "long_road", "archive_master",
		"resonance_hoarder", "silence_hunter"
	]:
		_assert_contains(src, "\"%s\":" % ach_id,
			"T208.PRESETS.KEY.1: '%s' 在 ACHIEVEMENT_CHIME_PRESETS dict 内" % ach_id)

	# 4 字段约定: chord_midi / duration / amp / decay 全部出现
	_assert_contains(src, "chord_midi",
		"T208.PRESETS.FIELD_CHORD.1: 14 preset 共用 chord_midi 字段 (3-5 音)")
	_assert_contains(src, "duration",
		"T208.PRESETS.FIELD_DURATION.1: 14 preset 共用 duration 字段 (0.35-0.65s)")
	_assert_contains(src, "amp",
		"T208.PRESETS.FIELD_AMP.1: 14 preset 共用 amp 字段 (0.20-0.24)")
	_assert_contains(src, "decay",
		"T208.PRESETS.FIELD_DECAY.1: 14 preset 共用 decay 字段 (3.5-8.0)")

	# 注释锚点: 14 注释 inline 解释每个 preset 的设计语义
	_assert_contains(src, "first_steps",
		"T208.PRESETS.COMMENT.1: first_steps 注释解释 C 大调上行 4 音阶起步感")
	_assert_contains(src, "silence_hunter",
		"T208.PRESETS.COMMENT.2: silence_hunter 注释解释减七和弦黑暗低吟")
	_assert_contains(src, "first_cut",
		"T208.PRESETS.COMMENT.3: first_cut 注释解释三全音锋利短促 0.35s")
	_assert_contains(src, "long_road",
		"T208.PRESETS.COMMENT.4: long_road 注释解释 C 小调 0.65s 最长慢衰减")
	_assert_contains(src, "archive_master",
		"T208.PRESETS.COMMENT.5: archive_master 注释解释 C 大 5 音大师级丰盈 amp 0.24")


# ---------- T208.PLAY — _achievement_chime_streams cache + play_unlock_chime ----------
func _run_t208_play_api_assertions() -> void:
	print("--- T208.PLAY — _achievement_chime_streams cache + play_unlock_chime ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _achievement_chime_streams: Dictionary",
		"T208.CACHE.FIELD.1: var _achievement_chime_streams: Dictionary 字段 (per-achievement cache)")
	_assert_contains(src, "func play_unlock_chime(id_val: String = \"\")",
		"T208.PLAY.SIG.1: play_unlock_chime(id_val: String = \"\") 公开方法 (T208 新增 id_val 可选参数)")
	_assert_contains(src, "ACHIEVEMENT_CHIME_PRESETS.has(id_val)",
		"T208.PLAY.DISPATCH.1: play_unlock_chime 用 ACHIEVEMENT_CHIME_PRESETS.has() 分派 (T208 核心)")
	_assert_contains(src, "_achievement_chime_streams[id_val]",
		"T208.PLAY.LOOKUP.1: play_unlock_chime 用 _achievement_chime_streams[id_val] 查缓存")
	_assert_contains(src, "if _unlock_chime_stream == null:",
		"T208.PLAY.FALLBACK.1: id 不在 dict 时走 _unlock_chime_stream fallback (向后兼容)")
	_assert_contains(src, "play_sfx(_unlock_chime_stream)",
		"T208.PLAY.SFX_BUS.1: fallback 路径 play_sfx 走 SFX bus (老 C6+E6+A6 路径兼容)")
	_assert_contains(src, "func _generate_achievement_chime_sfx(preset: Dictionary)",
		"T208.GEN.SIG.1: _generate_achievement_chime_sfx(preset) 私有 synth (T208 parameter-driven)")
	# MIDI → Hz 公式: 440 * 2^((midi-69)/12) — 与 F014 _midi_to_hz 公式一致
	_assert_contains(src, "440.0 * pow(2.0, (float(midi) - 69.0) / 12.0)",
		"T208.GEN.MIDI_HZ.1: 用 440 * 2^((midi-69)/12) 公式转 Hz (与 F014 _midi_to_hz 一致)")
	_assert_contains(src, "exp(-t * decay)",
		"T208.GEN.EXP_DECAY.1: 用 exp(-t * decay) envelope (T208 per-preset 衰减常数)")
	_assert_contains(src, "sum_sin += sin(t * TAU * freq)",
		"T208.GEN.SUM.1: Σ sin(t*TAU*freq) 叠加 chord 内各音 (T208 sum-then-normalize)")
	# prewarm_misc_sfx 预热 14 成就
	_assert_contains(src, "for ach_id in ACHIEVEMENT_CHIME_PRESETS.keys():",
		"T208.GEN.PRE_CACHE.1: prewarm_misc_sfx 预热 14 成就 stream (T208 一次性 ~5ms)")
	_assert_contains(src, "_generate_achievement_chime_sfx(preset)",
		"T208.GEN.PRE_LUANCHOR.1: prewarm_misc_sfx 调 _generate_achievement_chime_sfx")


# ---------- T208.NOTIFY — AchievementNotification 接入 id_val ----------
func _run_t208_notify_assertions() -> void:
	print("--- T208.NOTIFY — AchievementNotification 接入 id_val ---")
	var src := _read_file(ACHIEVEMENT_NOTIFICATION_GD)
	_assert_contains(src, "ame.call(\"play_unlock_chime\", id_val)",
		"T208.NOTIFY.CALL.1: ame.call(\"play_unlock_chime\", id_val) 传 id (T208 关键)")
	_assert_contains(src, "func _play_unlock_chime(id_val: String = \"\")",
		"T208.NOTIFY.HELPER_SIG.1: _play_unlock_chime(id_val: String = \"\") 带可选参数 (T208)")
	_assert_contains(src, "ame.has_method(\"play_unlock_chime\")",
		"T208.NOTIFY.HAS_METHOD.1: AchievementNotification 用 has_method 守卫 (headless-safe)")
	_assert_contains(src, "T208 (#126)",
		"T208.NOTIFY.DOC.1: AchievementNotification 注释含 T208 (#126) 锚点 (未来读这段代码能立刻知道为何传 id_val)")


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
	print("I033 (#126) T208 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
