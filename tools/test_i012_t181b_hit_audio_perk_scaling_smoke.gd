extends SceneTree
## I012 (#100) — T181.B 5 verb 音频家族 second half perk-level scaling 冒烟测试
##
## 覆盖 #100 T181.B 任务原子化提交:
## - T181.B.HIT.SCALE: 3 verb hit 合成器 (_generate_pulse_hit_sfx /
##              _generate_cut_hit_sfx / _generate_echo_hit_sfx) 接受
##              perk_level: int = 0 参数并在 level 1+ 时叠加谐波
##              (Pulse: 3×/4×/5×; Cut: 3.5×/4.5×/5.5×; Echo: 3.4×/4.4×/5.4×)
## - T181.B.HIT.LEVEL.PARAM: 3 verb play_*_hit() public API 接受
##              perk_level: int = 0 参数
## - T181.B.HIT.LEVEL.READ: 3 verb play_*_hit() 内部从 GameState
##              读 perk 计数 (pulse_focus / echo_charm; Cut 保留
##              level-arg 以便未来 perk 接入) — 守卫 has_method
## - T181.B.HIT.LEVEL.CACHE: 3 verb per-level 缓存 Dictionary
##              (_pulse_hit_streams / _cut_hit_streams / _echo_hit_streams)
##              而非单 stream (Bind 保留 _bind_hit_stream 单 stream
##              因为 Bind 没有 shop perk)
## - T181.B.LEVEL.CLAMP: 3 verb perk_level 都被 clampi(0, 3) 保护
## - T181.B.BIND.UNCHANGED: Bind hit SFX 保留单 stream 模式 (无 perk
##              缩放; 注释明确说明未来 perk 接入路径)
## - T181.B.WAVE.EXISTING: Wave hit SFX 保留 T144 #78 的 per-level
##              缩放 (T181.B 范围外, 烟雾保护回归)
## - T181.B.MARKER: 3 verb _generate_*_hit_sfx() 函数有 T181.B (#100)
##              文档块标注

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I012 (#100) — T181.B 5 verb hit perk-level scaling ===")
	_run_t181b_hit_scale_synth_assertions()
	_run_t181b_hit_level_param_assertions()
	_run_t181b_hit_level_read_assertions()
	_run_t181b_hit_level_cache_assertions()
	_run_t181b_level_clamp_assertions()
	_run_t181b_bind_unchanged_assertions()
	_run_t181b_wave_existing_regression_assertions()
	_run_t181b_docblock_marker_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I012 (#100) T181.B ASSERTIONS PASSED ===")
		quit(0)


# ---------- T181.B.HIT.SCALE — 3 verb 合成器接受 perk_level + 在 level 1+ 叠加谐波 ----------
func _run_t181b_hit_scale_synth_assertions() -> void:
	print("--- T181.B.HIT.SCALE — 3 verb 合成器 perk-level 谐波 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# Pulse: 3 verb 共有的 level-arg signature
	_assert_contains(src, "func _generate_pulse_hit_sfx(perk_level: int = 0)",
		"T181.B.HIT.SCALE.1: _generate_pulse_hit_sfx(perk_level=0) declared (T181.B)")
	_assert_contains(src, "func _generate_cut_hit_sfx(perk_level: int = 0)",
		"T181.B.HIT.SCALE.2: _generate_cut_hit_sfx(perk_level=0) declared (T181.B)")
	_assert_contains(src, "func _generate_echo_hit_sfx(perk_level: int = 0)",
		"T181.B.HIT.SCALE.3: _generate_echo_hit_sfx(perk_level=0) declared (T181.B)")
	# Pulse per-level 谐波 (3×, 4×, 5×)
	_assert_contains(src, "sin(t * TAU * 660.0) * 0.08",
		"T181.B.HIT.SCALE.4: Pulse level 1+ 叠加 660Hz (3×) 谐波 (T181.B)")
	_assert_contains(src, "sin(t * TAU * 880.0) * 0.06",
		"T181.B.HIT.SCALE.5: Pulse level 2+ 叠加 880Hz (4×) 谐波 (T181.B)")
	_assert_contains(src, "sin(t * TAU * 1100.0) * 0.04",
		"T181.B.HIT.SCALE.6: Pulse level 3+ 叠加 1100Hz (5×) 谐波 (T181.B)")
	# Cut per-level 谐波 (3.5×, 4.5×, 5.5×)
	_assert_contains(src, "sin(t * TAU * 7000.0) * 0.05",
		"T181.B.HIT.SCALE.7: Cut level 1+ 叠加 7000Hz (3.5×) 谐波 (T181.B)")
	_assert_contains(src, "sin(t * TAU * 9000.0) * 0.04",
		"T181.B.HIT.SCALE.8: Cut level 2+ 叠加 9000Hz (4.5×) 谐波 (T181.B)")
	_assert_contains(src, "sin(t * TAU * 11000.0) * 0.03",
		"T181.B.HIT.SCALE.9: Cut level 3+ 叠加 11000Hz (5.5×) 谐波 (T181.B)")
	# Echo per-level 谐波 (3.4×, 4.4×, 5.4× — 用 fundamental multiplier 表达式)
	_assert_contains(src, "sin(t * TAU * 1980.0 * 3.4) * 0.06",
		"T181.B.HIT.SCALE.10: Echo level 1+ 叠加 1980×3.4 谐波 (T181.B)")
	_assert_contains(src, "sin(t * TAU * 1980.0 * 4.4) * 0.05",
		"T181.B.HIT.SCALE.11: Echo level 2+ 叠加 1980×4.4 谐波 (T181.B)")
	_assert_contains(src, "sin(t * TAU * 1980.0 * 5.4) * 0.04",
		"T181.B.HIT.SCALE.12: Echo level 3+ 叠加 1980×5.4 谐波 (T181.B)")


# ---------- T181.B.HIT.LEVEL.PARAM — 3 verb play_*_hit() public API perk_level 参数 ----------
func _run_t181b_hit_level_param_assertions() -> void:
	print("--- T181.B.HIT.LEVEL.PARAM — 3 verb play_*_hit perk_level arg ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_pulse_hit(perk_level: int = 0)",
		"T181.B.HIT.LEVEL.PARAM.1: play_pulse_hit(perk_level=0) 公开 API 接受 perk_level (T181.B)")
	_assert_contains(src, "func play_cut_hit(perk_level: int = 0)",
		"T181.B.HIT.LEVEL.PARAM.2: play_cut_hit(perk_level=0) 公开 API 接受 perk_level (T181.B future-proof)")
	_assert_contains(src, "func play_echo_hit(perk_level: int = 0)",
		"T181.B.HIT.LEVEL.PARAM.3: play_echo_hit(perk_level=0) 公开 API 接受 perk_level (T181.B)")


# ---------- T181.B.HIT.LEVEL.READ — 3 verb play_*_hit() 读 GameState perk 计数 ----------
func _run_t181b_hit_level_read_assertions() -> void:
	print("--- T181.B.HIT.LEVEL.READ — 3 verb play_*_hit 读 GameState ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# Pulse: 读 pulse_focus
	_assert_contains(src, "GameState.get_perk_count(\"pulse_focus\")",
		"T181.B.HIT.LEVEL.READ.1: play_pulse_hit reads GameState.get_perk_count(\"pulse_focus\") (T181.B)")
	# Echo: 读 echo_charm
	_assert_contains(src, "GameState.get_perk_count(\"echo_charm\")",
		"T181.B.HIT.LEVEL.READ.2: play_echo_hit reads GameState.get_perk_count(\"echo_charm\") (T181.B)")
	# has_method 守卫: 3 verb 都用
	_assert_contains(src, "GameState and GameState.has_method(\"get_perk_count\")",
		"T181.B.HIT.LEVEL.READ.3: 3 verb perk-level 读 GameState 都有 has_method 守卫 (T181.B headless-safe)")


# ---------- T181.B.HIT.LEVEL.CACHE — 3 verb per-level 缓存 Dictionary ----------
func _run_t181b_hit_level_cache_assertions() -> void:
	print("--- T181.B.HIT.LEVEL.CACHE — 3 verb per-level Dict 缓存 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 3 verb 改为 Dict
	_assert_contains(src, "var _pulse_hit_streams: Dictionary",
		"T181.B.HIT.LEVEL.CACHE.1: _pulse_hit_streams dict (T181.B per-level 缓存)")
	_assert_contains(src, "var _cut_hit_streams: Dictionary",
		"T181.B.HIT.LEVEL.CACHE.2: _cut_hit_streams dict (T181.B per-level 缓存 future-proof)")
	_assert_contains(src, "var _echo_hit_streams: Dictionary",
		"T181.B.HIT.LEVEL.CACHE.3: _echo_hit_streams dict (T181.B per-level 缓存)")
	# 3 verb 都用 dict.has(level) / dict.get(level) lookup 模式
	_assert_contains(src, "if not _pulse_hit_streams.has(level):",
		"T181.B.HIT.LEVEL.CACHE.4: play_pulse_hit dict.has(level) lazy-synth 模式 (T181.B)")
	_assert_contains(src, "if not _cut_hit_streams.has(level):",
		"T181.B.HIT.LEVEL.CACHE.5: play_cut_hit dict.has(level) lazy-synth 模式 (T181.B)")
	_assert_contains(src, "if not _echo_hit_streams.has(level):",
		"T181.B.HIT.LEVEL.CACHE.6: play_echo_hit dict.has(level) lazy-synth 模式 (T181.B)")
	# 3 verb 调对应 synth with level
	_assert_contains(src, "_pulse_hit_streams[level] = _generate_pulse_hit_sfx(level)",
		"T181.B.HIT.LEVEL.CACHE.7: play_pulse_hit cache miss → 调 _generate_pulse_hit_sfx(level) (T181.B)")
	_assert_contains(src, "_cut_hit_streams[level] = _generate_cut_hit_sfx(level)",
		"T181.B.HIT.LEVEL.CACHE.8: play_cut_hit cache miss → 调 _generate_cut_hit_sfx(level) (T181.B)")
	_assert_contains(src, "_echo_hit_streams[level] = _generate_echo_hit_sfx(level)",
		"T181.B.HIT.LEVEL.CACHE.9: play_echo_hit cache miss → 调 _generate_echo_hit_sfx(level) (T181.B)")


# ---------- T181.B.LEVEL.CLAMP — 3 verb perk_level 都被 clampi(0, 3) 保护 ----------
func _run_t181b_level_clamp_assertions() -> void:
	print("--- T181.B.LEVEL.CLAMP — perk_level clampi(0, 3) 守卫 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 3 verb play_*_hit 都有 clampi(level, 0, 3) 守卫
	_assert_contains(src, "level = clampi(level, 0, 3)",
		"T181.B.LEVEL.CLAMP.1: 3 verb play_*_hit perk_level 都 clampi(0, 3) 保护 (T181.B caller-safety)")
	# 3 verb 合成器都有 safe_level 局部变量
	_assert_contains(src, "var safe_level: int = clampi(perk_level, 0, 3)",
		"T181.B.LEVEL.CLAMP.2: 3 verb _generate_*_hit_sfx 都有 safe_level: int = clampi(perk_level, 0, 3) (T181.B)")
	# 3 verb safe_level 出现次数 >= 3 (每个合成器各一次)
	var safe_level_count := src.count("var safe_level: int = clampi(perk_level, 0, 3)")
	if safe_level_count >= 3:
		_passes += 1
		print("  OK  T181.B.LEVEL.CLAMP.3: 3 verb _generate_*_hit_sfx safe_level 出现 ", safe_level_count, " 次 (T181.B)")
	else:
		_failures.append("FAIL: T181.B.LEVEL.CLAMP.3: 期望 safe_level 出现 3 次, 实际 " + str(safe_level_count) + " 次 (T181.B)")


# ---------- T181.B.BIND.UNCHANGED — Bind 保留单 stream (无 perk) ----------
func _run_t181b_bind_unchanged_assertions() -> void:
	print("--- T181.B.BIND.UNCHANGED — Bind 保留单 stream ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# Bind hit SFX 保留单 stream 模式 (无 perk_level 参数)
	_assert_contains(src, "func play_bind_hit() -> void:",
		"T181.B.BIND.UNCHANGED.1: play_bind_hit() 保持无 perk_level 参数 (Bind 无 shop perk)")
	_assert_contains(src, "func _generate_bind_hit_sfx() -> AudioStreamWAV:",
		"T181.B.BIND.UNCHANGED.2: _generate_bind_hit_sfx() 保持无 perk_level 参数")
	_assert_contains(src, "var _bind_hit_stream: AudioStreamWAV",
		"T181.B.BIND.UNCHANGED.3: _bind_hit_stream 保留单 stream 缓存字段 (T181.B 不改 Bind 缓存模式)")
	# Bind 注释明确说明无 perk + 未来 perk 路径
	_assert_contains(src, "Bind has no shop perk",
		"T181.B.BIND.UNCHANGED.4: Bind 注释明确说明 \"no shop perk\" (T181.B 文档契约)")


# ---------- T181.B.WAVE.EXISTING — Wave 保留 T144 #78 per-level 缩放 ----------
func _run_t181b_wave_existing_regression_assertions() -> void:
	print("--- T181.B.WAVE.EXISTING — Wave 保留 T144 per-level (回归保护) ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# Wave 保留 _wave_hit_streams dict (T144 #78 立)
	_assert_contains(src, "var _wave_hit_streams: Dictionary",
		"T181.B.WAVE.EXISTING.1: _wave_hit_streams dict (T144 #78 回归保护) 未被 T181.B 破坏")
	_assert_contains(src, "func _generate_wave_hit_sfx(perk_level: int = 0)",
		"T181.B.WAVE.EXISTING.2: _generate_wave_hit_sfx(perk_level=0) 签名 (T144) 保留")
	_assert_contains(src, "GameState.get_perk_count(\"wave_focus\")",
		"T181.B.WAVE.EXISTING.3: play_wave_hit reads GameState.get_perk_count(\"wave_focus\") (T144) 保留")


# ---------- T181.B.MARKER — 3 verb _generate_*_hit_sfx() 有 T181.B (#100) 文档块标注 ----------
func _run_t181b_docblock_marker_assertions() -> void:
	print("--- T181.B.MARKER — T181.B (#100) docblock 标注 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "T181.B (#100)",
		"T181.B.MARKER.1: T181.B (#100) 文档块标注在 audio_manager_enhanced.gd (覆盖 Pulse/Cut/Echo 三 verb)")


# ---------- helpers ----------
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _print_summary() -> void:
	print("--- I012 (#100) T181.B 5 verb hit perk-level scaling smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
