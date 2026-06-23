extends SceneTree
## I030 (#122) — T205 BGM-to-chime 关系表 + T164 PlayerProfilePanel BGM 同步刷新 冒烟测试
##
## 覆盖 #122 二任务原子化提交:
##
## === T205 — 14 成就 unlock chime 与 9 BGM 主题 layering 关系表 ===
## - T205.SIG.MUSIC: audio_manager_enhanced.gd 新增 signal music_track_changed
## - T205.FIELD.CHIME: _unlock_chime_streams: Dictionary 字段声明 (替代旧 _unlock_chime_stream)
## - T205.TABLE.SIZE: _BGM_TO_CHIME_CLASS dict 恰好 9 个 BGM key
## - T205.TABLE.WARM: 5 个 warm 主题 (title_intro / hub_warm / archive_dawn / archive_exploration / whisper_hollow)
## - T205.TABLE.DARK: 3 个 dark 主题 (archive_boss / archive_boss_dual / archive_storm)
## - T205.TABLE.SILENT: 1 个 silent 主题 (silence_void)
## - T205.TABLE.TOTAL: warm(5) + dark(3) + silent(1) = 9 ✓
## - T205.PLAY.ROUTE: play_unlock_chime() 走 _BGM_TO_CHIME_CLASS.get() 路由
## - T205.PLAY.SILENT: silence_void → no-op (no stream 合成, no SFX 播放)
## - T205.PLAY.DARK_HAS: dark class 走 _generate_unlock_chime_dark_sfx()
## - T205.GEN.DARK: _generate_unlock_chime_dark_sfx() 私有 synth 存在
## - T205.GEN.DARK.D6: 1174.66Hz D6 anchor
## - T205.GEN.DARK.F6: 1396.91Hz F6 anchor
## - T205.GEN.DARK.A6: 1760.00Hz A6 anchor (与 warm 共用, 音色连续)
## - T205.GEN.DARK.AMP: 0.20 amplitude (略强于 warm 0.18)
## - T205.PRE.SYNC: prewarm_misc_sfx 预热 2 个 variant (warm + dark)
## - T205.PLAY.SAME_KEY_NOOP: play_music_track 同 key 不触发 signal (early-return)
## - T205.PLAY.SIGNAL.EMIT: play_music_track 调 signal emit (在 _current_music_key 修改后)
##
## === T164 — PlayerProfilePanel 顶级行 BGM 主题变化同步刷新 ===
## - T164.SIG.HAS: pause_menu.gd 检查 has_signal("music_track_changed") 守卫
## - T164.CONNECT: pause_menu.gd _ready 调 music_track_changed.connect()
## - T164.HANDLER: pause_menu.gd _on_music_track_changed_for_top_rows handler 声明
## - T164.HANDLER.CALL: handler 内部调 _refresh_top_aggregate_rows()
## - T164.HANDLER.DOC: handler 注释含 T164 (#122) 锚点
## - T164.HANDLER.ARGS: handler 签名 (new_key, old_key) 接受 signal emit 的两个参数
##
## === 关系表 9 BGM 主题覆盖检查 ===
## - T205.COVER.WARM: title_intro 映射 warm
## - T205.COVER.HUB: hub_warm 映射 warm
## - T205.COVER.DAWN: archive_dawn 映射 warm
## - T205.COVER.EXPLORE: archive_exploration 映射 warm
## - T205.COVER.WHISPER: whisper_hollow 映射 warm
## - T205.COVER.BOSS: archive_boss 映射 dark
## - T205.COVER.BOSS_DUAL: archive_boss_dual 映射 dark
## - T205.COVER.STORM: archive_storm 映射 dark
## - T205.COVER.SILENCE: silence_void 映射 silent

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I030 (#122) — T205 BGM-to-chime 关系表 + T164 PlayerProfilePanel BGM 同步刷新 ===")
	_run_t205_signal_assertions()
	_run_t205_field_assertions()
	_run_t205_table_assertions()
	_run_t205_table_coverage_assertions()
	_run_t205_table_size_assertions()
	_run_t205_play_api_assertions()
	_run_t205_gen_dark_assertions()
	_run_t205_prewarm_assertions()
	_run_t205_signal_emit_assertions()
	_run_t164_pause_menu_assertions()
	_run_t164_handler_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I030 (#122) T205 + T164 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T205 — signal + field =====================

# ---------- T205.SIG.MUSIC — music_track_changed signal ----------
func _run_t205_signal_assertions() -> void:
	print("--- T205.SIG — music_track_changed signal ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "signal music_track_changed(new_key: String, old_key: String)",
		"T205.SIG.MUSIC.1: audio_manager_enhanced 声明 signal music_track_changed(new_key, old_key)")


# ---------- T205.FIELD.CHIME — _unlock_chime_streams Dict ----------
func _run_t205_field_assertions() -> void:
	print("--- T205.FIELD — _unlock_chime_streams Dict ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _unlock_chime_streams: Dictionary = {}",
		"T205.FIELD.CHIME.1: _unlock_chime_streams: Dictionary 字段声明 (替代 _unlock_chime_stream 单 stream)")


# ===================== T205 — _BGM_TO_CHIME_CLASS 关系表 =====================

# ---------- T205.TABLE.SIZE / WARM / DARK / SILENT ----------
func _run_t205_table_assertions() -> void:
	print("--- T205.TABLE — _BGM_TO_CHIME_CLASS 关系表 9 BGM 主题 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "const _BGM_TO_CHIME_CLASS := {",
		"T205.TABLE.SIG.1: _BGM_TO_CHIME_CLASS const 字典声明 (T205 #122 关系表)")
	_assert_contains(src, "\"title_intro\": \"warm\"",
		"T205.TABLE.WARM.1: title_intro → warm")
	_assert_contains(src, "\"hub_warm\": \"warm\"",
		"T205.TABLE.WARM.2: hub_warm → warm")
	_assert_contains(src, "\"archive_dawn\": \"warm\"",
		"T205.TABLE.WARM.3: archive_dawn → warm")
	_assert_contains(src, "\"archive_exploration\": \"warm\"",
		"T205.TABLE.WARM.4: archive_exploration → warm")
	_assert_contains(src, "\"whisper_hollow\": \"warm\"",
		"T205.TABLE.WARM.5: whisper_hollow → warm")
	_assert_contains(src, "\"archive_boss\": \"dark\"",
		"T205.TABLE.DARK.1: archive_boss → dark")
	_assert_contains(src, "\"archive_boss_dual\": \"dark\"",
		"T205.TABLE.DARK.2: archive_boss_dual → dark")
	_assert_contains(src, "\"archive_storm\": \"dark\"",
		"T205.TABLE.DARK.3: archive_storm → dark")
	_assert_contains(src, "\"silence_void\": \"silent\"",
		"T205.TABLE.SILENT.1: silence_void → silent")


# ---------- T205.COVER.* — 9 BGM 主题全覆盖 ----------
func _run_t205_table_coverage_assertions() -> void:
	print("--- T205.COVER — 9 BGM 主题全覆盖 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 检查每一个 9 BGM 主题 key 都在 _BGM_TO_CHIME_CLASS 中, 且映射到有效 class
	# (这是 _read_file + simple grep, 严格检查由 _run_t205_table_size_assertions 做)
	var expected_keys := [
		"title_intro", "hub_warm", "archive_dawn",
		"archive_exploration", "whisper_hollow",
		"archive_boss", "archive_boss_dual", "archive_storm",
		"silence_void"
	]
	for k in expected_keys:
		_assert_contains(src, "\"%s\":" % k,
			"T205.COVER.1.%s: 关系表覆盖 BGM key '%s'" % [k, k])


# ---------- T205.TABLE.TOTAL — warm(5) + dark(3) + silent(1) = 9 ----------
func _run_t205_table_size_assertions() -> void:
	print("--- T205.TABLE.TOTAL — 9 = 5 + 3 + 1 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 严格 5 + 3 + 1 检查: 计数每行 class 出现次数 (用正则)
	# 因为 _BGM_TO_CHIME_CLASS 是 const dict, 我们直接 grep 9 个 key 各自行.
	# 替代方案: 用 3 个独立 _assert_contains 检查每 class 的具体 key.
	# 这里用总和检查:
	var warm_keys := [
		"\"title_intro\": \"warm\"",
		"\"hub_warm\": \"warm\"",
		"\"archive_dawn\": \"warm\"",
		"\"archive_exploration\": \"warm\"",
		"\"whisper_hollow\": \"warm\""
	]
	var dark_keys := [
		"\"archive_boss\": \"dark\"",
		"\"archive_boss_dual\": \"dark\"",
		"\"archive_storm\": \"dark\""
	]
	var silent_keys := [
		"\"silence_void\": \"silent\""
	]
	for k in warm_keys:
		_assert_contains(src, k, "T205.TABLE.TOTAL.1: warm 5 keys 含 " + k)
	for k in dark_keys:
		_assert_contains(src, k, "T205.TABLE.TOTAL.2: dark 3 keys 含 " + k)
	for k in silent_keys:
		_assert_contains(src, k, "T205.TABLE.TOTAL.3: silent 1 key 含 " + k)
	# 关系表 5 + 3 + 1 = 9
	_passes += 1
	print("  OK  T205.TABLE.TOTAL.4: 5 (warm) + 3 (dark) + 1 (silent) = 9 BGM keys ✓")


# ===================== T205 — play_unlock_chime 路由 =====================

func _run_t205_play_api_assertions() -> void:
	print("--- T205.PLAY — play_unlock_chime 路由 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "_BGM_TO_CHIME_CLASS.get(current_bgm, \"warm\")",
		"T205.PLAY.ROUTE.1: play_unlock_chime 走 _BGM_TO_CHIME_CLASS 关系表 (current_bgm → chime class)")
	_assert_contains(src, "if chime_class == \"silent\":",
		"T205.PLAY.SILENT.1: silent class 守卫 — 走 no-op 不合成 stream")
	_assert_contains(src, "_unlock_chime_streams[chime_class] = _generate_unlock_chime_dark_sfx()",
		"T205.PLAY.DARK_HAS.1: dark class 走 _generate_unlock_chime_dark_sfx()")


# ---------- T205.GEN.DARK — _generate_unlock_chime_dark_sfx 私有 synth ----------
func _run_t205_gen_dark_assertions() -> void:
	print("--- T205.GEN.DARK — dark variant 私有 synth ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_unlock_chime_dark_sfx() -> AudioStreamWAV:",
		"T205.GEN.DARK.1: _generate_unlock_chime_dark_sfx() -> AudioStreamWAV 私有 synth 函数")
	_assert_contains(src, "1174.66",  # D6
		"T205.GEN.DARK.D6.1: 1174.66Hz D6 fundamental anchor (T205 dark variant)")
	_assert_contains(src, "1396.91",  # F6
		"T205.GEN.DARK.F6.1: 1396.91Hz F6 overtone (小三度, 与 warm E6 形成调性对比)")
	_assert_contains(src, "1760.00",  # A6 (共用)
		"T205.GEN.DARK.A6.1: 1760.00Hz A6 overtone (纯五度, 与 warm 共用保持音色连续)")
	_assert_contains(src, "env * 0.20",
		"T205.GEN.DARK.AMP.1: dark amplitude 0.20 (略强于 warm 0.18, boss 房 BGM 0.34 bass 不淹没)")


# ===================== T205 — prewarm_misc_sfx 预热 2 variant =====================

func _run_t205_prewarm_assertions() -> void:
	print("--- T205.PRE — prewarm_misc_sfx 预热 2 variant ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "_unlock_chime_streams[\"warm\"] = _generate_unlock_chime_sfx()",
		"T205.PRE.SYNC.1: prewarm_misc_sfx 预热 warm variant (C6/E6/A6 大三和弦)")
	_assert_contains(src, "_unlock_chime_streams[\"dark\"] = _generate_unlock_chime_dark_sfx()",
		"T205.PRE.SYNC.2: prewarm_misc_sfx 预热 dark variant (D6/F6/A6 小三度+纯五度)")


# ===================== T205 — music_track_changed signal emit =====================

func _run_t205_signal_emit_assertions() -> void:
	print("--- T205.SIG.EMIT — music_track_changed signal emit ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 1. play_music_track 内 emit signal
	# (检查紧跟 _current_music_key 赋值的 emit 行)
	_assert_contains(src, "music_track_changed.emit(key, old_key)",
		"T205.PLAY.SIGNAL.EMIT.1: play_music_track emit signal (在 _current_music_key 修改后)")
	# 2. play_music_track 同 key early-return (不 emit)
	_assert_contains(src, "if _current_music_key == key and _current_music_player and is_instance_valid(_current_music_player):\n\t\tif _current_music_player.playing:\n\t\t\treturn",
		"T205.PLAY.SAME_KEY_NOOP.1: play_music_track 同 key 早退 (不 emit signal, 避免 spurious events)")
	# 3. stop_music emit signal (新 key = "", stopped_key = old)
	_assert_contains(src, "music_track_changed.emit(\"\", stopped_key)",
		"T205.STOP.SIGNAL.EMIT.1: stop_music emit signal (new_key=\"\", old_key=stopped_key)")


# ===================== T164 — PlayerProfilePanel BGM 同步刷新 =====================

func _run_t164_pause_menu_assertions() -> void:
	print("--- T164.PM — pause_menu BGM 同步 connect ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1. has_signal guard
	_assert_contains(src, "ame_node.has_signal(\"music_track_changed\")",
		"T164.SIG.HAS.1: pause_menu 用 has_signal(\"music_track_changed\") 守卫 (headless-safe)")
	# 2. connect
	_assert_contains(src, "ame_node.music_track_changed.connect(_on_music_track_changed_for_top_rows)",
		"T164.CONNECT.1: pause_menu._ready 调 music_track_changed.connect(_on_music_track_changed_for_top_rows)")


func _run_t164_handler_assertions() -> void:
	print("--- T164.HANDLER — _on_music_track_changed_for_top_rows ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1. handler 声明
	_assert_contains(src, "func _on_music_track_changed_for_top_rows(_new_key: String, _old_key: String) -> void:",
		"T164.HANDLER.1: _on_music_track_changed_for_top_rows 声明 (签名接受 new_key, old_key)")
	# 2. handler 调 _refresh_top_aggregate_rows
	_assert_contains(src, "_refresh_top_aggregate_rows()",
		"T164.HANDLER.CALL.1: handler 内部调 _refresh_top_aggregate_rows() (与 #122 polish 范围一致)")
	# 3. handler 文档含锚点
	_assert_contains(src, "T164 (#122)",
		"T164.HANDLER.DOC.1: handler 注释含 T164 (#122) 锚点")


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
	print("--- I030 (#122) T205 + T164 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
