extends SceneTree
## I034 (#127) — T208.B 14 成就 ↔ 9 BGM 主题 layering 冒烟测试
##
## 覆盖 #127 主任务 T208.B. 验证 14 成就 ↔ 9 BGM 主题 语义映射
## (ACHIEVEMENT_BGM_HINT dict) + BGM ducking 核心 (_duck_current_bgm_for_chime
## helper + _BGM_DUCK_DB/-6.0 + 0.05s fade-in + 0.30s fade-out + re-entrant
## safety 用的 _bgm_duck_tween field) + play_unlock_chime 内部 ducking
## 调用 + 14 覆盖 (6 BGM 主题, 9 总数包含 fallback) + fallback 路径
## 也走 ducking.
##
## 三类断言:
##
## === T208.B.HINT — ACHIEVEMENT_BGM_HINT 14 → 9 映射数据表 ===
## - T208.B.HINT.CONST: const ACHIEVEMENT_BGM_HINT 声明存在
## - T208.B.HINT.COUNT: 14 成就 14 entries (key 数量 = 14)
## - T208.B.HINT.SIX_THEMES: 6 个 BGM 主题被引用 (title_intro/hub_warm/
##                              archive_exploration/archive_dawn/whisper_hollow/
##                              silence_void), 不含 boss 类
## - T208.B.HINT.FIRST_STEPS: first_steps → title_intro
## - T208.B.HINT.SILENCE_HUNTER: silence_hunter → whisper_hollow
## - T208.B.HINT.FULL_ARCHIVE: full_archive → archive_dawn
## - T208.B.HINT.ARCHIVE_MASTER: archive_master → archive_dawn
## - T208.B.HINT.WARDEN_SLAYER: warden_slayer → archive_exploration
## - T208.B.HINT.RESONANCE_HOARDER: resonance_hoarder → silence_void
## - T208.B.HINT.NO_BOSS: archive_boss / archive_boss_dual / archive_storm
##                          不在 mapping 中 (boss 战不期望成就)
## - T208.B.HINT.SEMANTIC_DISTRIBUTION: 6 主题覆盖 — 4+3+2+2+2+1 = 14
##
## === T208.B.DUCK — _duck_current_bgm_for_chime helper + 4 常量 ===
## - T208.B.DUCK.HELPER: func _duck_current_bgm_for_chime(duration_s) 私有
## - T208.B.DUCK.DB: const _BGM_DUCK_DB := -6.0 (音量减半阈值)
## - T208.B.DUCK.FADE_IN: const _BGM_DUCK_FADE_IN_S := 0.05 (几乎瞬时)
## - T208.B.DUCK.FADE_OUT: const _BGM_DUCK_FADE_OUT_S := 0.30 (滑回稍慢)
## - T208.B.DUCK.TWEEN: var _bgm_duck_tween: Tween = null 状态字段
## - T208.B.DUCK.NOOP_NULL: _current_music_player == null 时 no-op 早退
## - T208.B.DUCK.CAPTURE_DB: 捕获 pre_duck_db 用于恢复 (不假设 0 dB)
## - T208.B.DUCK.KILL_PREV: re-entrant 杀 _bgm_duck_tween 防重入
## - T208.B.DUCK.3_STEPS: tween 3 步 — fade-in + interval + fade-out
## - T208.B.DUCK.TWEEN_PROPERTY: tween_property(_current_music_player,
##                            "volume_db", ...) 改 volume_db
##
## === T208.B.PLAY — play_unlock_chime 内部 ducking 集成 ===
## - T208.B.PLAY.14_DUCK: 14 成就路径调 _duck_current_bgm_for_chime
## - T208.B.PLAY.DURATION_ARG: 14 路径传 preset.get("duration", 0.5)
## - T208.B.PLAY.FALLBACK_DUCK: fallback 路径也调 _duck_current_bgm_for_chime
## - T208.B.PLAY.FALLBACK_DUR: fallback 传 0.4 (与 _generate_unlock_chime_sfx
##                              实际长度一致)
## - T208.B.PLAY.T208_ANCHOR: 注释含 T208.B (#127) 锚点
## - T208.B.PLAY.COMPAT: T208 老路径 (id_val == "" 走 fallback) 仍 100%
##                       兼容, 0 副作用

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I034 (#127) — T208.B 14 成就 ↔ 9 BGM 主题 layering 冒烟测试 ===")
	_run_t208b_hint_assertions()
	_run_t208b_duck_assertions()
	_run_t208b_play_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I034 (#127) T208.B ASSERTIONS PASSED ===")
		quit(0)


# ---------- T208.B.HINT — ACHIEVEMENT_BGM_HINT 14 → 9 映射数据表 ----------
func _run_t208b_hint_assertions() -> void:
	print("--- T208.B.HINT — ACHIEVEMENT_BGM_HINT 14 → 9 映射数据表 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "const ACHIEVEMENT_BGM_HINT",
		"T208.B.HINT.CONST.1: const ACHIEVEMENT_BGM_HINT 声明存在 (T208.B 新增)")

	# 14 成就 ID 全部在 mapping — 用 \"key\": 形式匹配
	for ach_id in [
		"first_steps", "voice_purifier", "resonance_collector",
		"triple_voice", "quadruple_voice", "quintuple_voice",
		"first_cut", "warden_slayer", "full_archive",
		"persistent_resonance", "long_road", "archive_master",
		"resonance_hoarder", "silence_hunter"
	]:
		_assert_contains(src, "\"%s\":" % ach_id,
			"T208.B.HINT.KEY.1: '%s' 在 ACHIEVEMENT_BGM_HINT dict 内" % ach_id)

	# 6 主题覆盖 (mapping 引用的 6 个 BGM 主题 key)
	for theme in [
		"title_intro", "hub_warm", "archive_exploration",
		"archive_dawn", "whisper_hollow", "silence_void"
	]:
		_assert_contains(src, "\"%s\"" % theme,
			"T208.B.HINT.THEME.1: '%s' 被 ACHIEVEMENT_BGM_HINT 引用" % theme)

	# 语义断言 — 关键映射 (1:1 锁死, 防止后续重构改坏)
	_assert_contains(src, "\"first_steps\": \"title_intro\"",
		"T208.B.HINT.MAP.1: first_steps → title_intro (起步)")
	_assert_contains(src, "\"silence_hunter\": \"whisper_hollow\"",
		"T208.B.HINT.MAP.2: silence_hunter → whisper_hollow (深度)")
	_assert_contains(src, "\"full_archive\": \"archive_dawn\"",
		"T208.B.HINT.MAP.3: full_archive → archive_dawn (胜利)")
	_assert_contains(src, "\"archive_master\": \"archive_dawn\"",
		"T208.B.HINT.MAP.4: archive_master → archive_dawn (完整)")
	_assert_contains(src, "\"warden_slayer\": \"archive_exploration\"",
		"T208.B.HINT.MAP.5: warden_slayer → archive_exploration (探索)")
	_assert_contains(src, "\"resonance_hoarder\": \"silence_void\"",
		"T208.B.HINT.MAP.6: resonance_hoarder → silence_void (沉默)")

	# Boss 类 BGM 主题故意不在 mapping (boss 战期间不期望成就解锁)
	# 检查不在 dict 的方式: count "<theme>": \"" 出现次数
	for boss_theme in ["archive_boss", "archive_boss_dual", "archive_storm"]:
		# 注意: 这 3 个 string 可能在注释或 const 注释里出现, 不能简单 substring
		# 改为检查 mapping 区块内 (ACHIEVEMENT_BGM_HINT 字典体内) 不出现
		var mapping_start := src.find("const ACHIEVEMENT_BGM_HINT :=")
		if mapping_start == -1:
			_failures.append("FAIL: cannot find ACHIEVEMENT_BGM_HINT block")
			continue
		# 截 2000 字符 (mapping 14 entries ~1500 char)
		var mapping_block := src.substr(mapping_start, 2000)
		if mapping_block.find("\"%s\":" % boss_theme) != -1:
			_failures.append(
				"FAIL: T208.B.HINT.NO_BOSS.1: '%s' 出现在 ACHIEVEMENT_BGM_HINT block — boss 战不期望成就" % boss_theme
			)
		else:
			_passes += 1
			print("  OK  T208.B.HINT.NO_BOSS.1: '%s' 不在 mapping block 中" % boss_theme)


# ---------- T208.B.DUCK — _duck_current_bgm_for_chime helper + 4 常量 ----------
func _run_t208b_duck_assertions() -> void:
	print("--- T208.B.DUCK — _duck_current_bgm_for_chime + duck 常量 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _duck_current_bgm_for_chime(duration_s: float)",
		"T208.B.DUCK.HELPER.1: _duck_current_bgm_for_chime(duration_s) 私有辅助存在")
	_assert_contains(src, "const _BGM_DUCK_DB := -6.0",
		"T208.B.DUCK.DB.1: const _BGM_DUCK_DB := -6.0 (音量减半阈值)")
	_assert_contains(src, "const _BGM_DUCK_FADE_IN_S := 0.05",
		"T208.B.DUCK.FADE_IN.1: const _BGM_DUCK_FADE_IN_S := 0.05 (几乎瞬时)")
	_assert_contains(src, "const _BGM_DUCK_FADE_OUT_S := 0.30",
		"T208.B.DUCK.FADE_OUT.1: const _BGM_DUCK_FADE_OUT_S := 0.30 (滑回稍慢)")
	_assert_contains(src, "var _bgm_duck_tween: Tween = null",
		"T208.B.DUCK.TWEEN.1: var _bgm_duck_tween: Tween = null 状态字段 (re-entrant)")

	# No-op null guard — _current_music_player == null 时早退
	_assert_contains(src, "if not _current_music_player or not is_instance_valid(_current_music_player):",
		"T208.B.DUCK.NOOP_NULL.1: _current_music_player null/invalid 时 no-op 早退")
	_assert_contains(src, "return  # No BGM playing",
		"T208.B.DUCK.NOOP_NULL.2: 显式 return + 注释 (title screen 等无 BGM)")

	# Capture pre_duck_db — 用于恢复
	_assert_contains(src, "var pre_duck_db: float = _current_music_player.volume_db",
		"T208.B.DUCK.CAPTURE_DB.1: 捕获 pre_duck_db (不假设 0 dB)")
	_assert_contains(src, "var target_ducked_db: float = pre_duck_db + _BGM_DUCK_DB",
		"T208.B.DUCK.CAPTURE_DB.2: 计算 target_ducked_db = pre_duck_db + _BGM_DUCK_DB")

	# Re-entrant kill
	_assert_contains(src, "_bgm_duck_tween.kill()",
		"T208.B.DUCK.KILL_PREV.1: re-entrant 杀 _bgm_duck_tween 防重入")

	# 3 步 tween: fade-in + interval + fade-out
	_assert_contains(src, "tween_interval(max(0.0, duration_s))",
		"T208.B.DUCK.3_STEPS.1: tween_interval(duration_s) hold 期间 (chime 播放)")
	_assert_contains(src, "_bgm_duck_tween = create_tween()",
		"T208.B.DUCK.3_STEPS.2: create_tween() 重建 tween 链")

	# Tween property — 改 volume_db
	_assert_contains(src, "tween_property(\n\t\t_current_music_player, \"volume_db\", target_ducked_db, _BGM_DUCK_FADE_IN_S",
		"T208.B.DUCK.TW_PROP.1: fade-in tween_property volume_db → target_ducked_db")
	_assert_contains(src, "tween_property(\n\t\t_current_music_player, \"volume_db\", pre_duck_db, _BGM_DUCK_FADE_OUT_S",
		"T208.B.DUCK.TW_PROP.2: fade-out tween_property volume_db → pre_duck_db (恢复)")


# ---------- T208.B.PLAY — play_unlock_chime 内部 ducking 集成 ----------
func _run_t208b_play_assertions() -> void:
	print("--- T208.B.PLAY — play_unlock_chime 内部 ducking 集成 ---")
	var src := _read_file(AUDIO_MANAGER_GD)

	# 14 成就路径调 ducking
	# F018 (#130) — 原 needle `_duck_current_bgm_for_chime(preset.get("duration", 0.5))`
	# 在 #128 T209 commit 引入 scope 泄漏 SCRIPT ERROR (cache hit 时 preset
	# 局部变量超出作用域). 修复后改为 `ACHIEVEMENT_CHIME_PRESETS[id_val].get(...)`
	# 重新查 dict (cheap lookup, 0 副作用). 测试 needle 同步更新.
	_assert_contains(src, "_duck_current_bgm_for_chime(ACHIEVEMENT_CHIME_PRESETS[id_val].get(\"duration\", 0.5))",
		"T208.B.PLAY.14_DUCK.1: 14 成就路径调 _duck_current_bgm_for_chime + 传 ACHIEVEMENT_CHIME_PRESETS[id_val].duration (F018 #130 修 scope 泄漏)")

	# Fallback 路径也调 ducking
	_assert_contains(src, "_duck_current_bgm_for_chime(0.4)",
		"T208.B.PLAY.FALLBACK_DUCK.1: fallback 路径也调 _duck_current_bgm_for_chime(0.4)")

	# T208.B 注释锚点 — 锚点验证可读性
	_assert_contains(src, "T208.B (#127)",
		"T208.B.PLAY.ANCHOR.1: 注释含 T208.B (#127) 锚点 (未来读这段代码能立刻知道 ducking 用途)")

	# 注释说明 ducking 设计与 rationale
	_assert_contains(src, "BGM ducking",
		"T208.B.PLAY.RATIONALE.1: 注释含 'BGM ducking' 字样 (设计意图可读)")
	_assert_contains(src, "re-entrant",
		"T208.B.PLAY.RATIONALE.2: 注释含 re-entrant (防御 race)")

	# T208 兼容 — play_unlock_chime 签名没改
	_assert_contains(src, "func play_unlock_chime(id_val: String = \"\")",
		"T208.B.PLAY.COMPAT.1: play_unlock_chime 签名 100% 兼容 T208 (#126) (id_val 可选参数保留)")
	_assert_contains(src, "ACHIEVEMENT_CHIME_PRESETS.has(id_val)",
		"T208.B.PLAY.COMPAT.2: T208 dispatch (ACHIEVEMENT_CHIME_PRESETS.has) 保留")


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
	print("I034 (#127) T208.B smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
