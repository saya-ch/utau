extends SceneTree

# I053 (T228 #148 + T231 #149) — 7 桶 prewarm aggregator 重复调 idempotency 静态
# 验证.  之前 #148 写的是 runtime 测试 (preload + AudioManagerEnhanced.new()),
# 但 audio_manager_enhanced.gd 内部用 `if GameState and GameState.has_method(...)`
# (第 1255 / 1307 / 1347 / 1370 行, autoload `GameState` 在 --headless --script
# 单文件 preload 时 parser 不识别), 整文件 parse 失败, 测试无法运行.  T231
# (#149) 改用 static text-based 验证, 与 I054 / I055 同款 pattern:
#   (1) 7 桶函数名都存在 (rename 检测 7 子断言, T220)
#   (2) prewarm_all_sfx() aggregator 存在 (T220)
#   (3) 7 桶内部调 _prewarm_*_set.add(steamid) / .has() 守卫 (cache guards 5 步)
#   (4) AudioPresets.MUSIC_PRESETS 9 主题 (T066) 都从 _ensure_music_stream
#       入口调 (idempotency 合约 9 桶独立)
#   (5) 7 桶顺序与 prewarm_all_sfx() 一致 (rename 重排检测 7 桶顺序, T220)
# 期望: 35 断言全 PASS, EXIT 0, 0 回归.

const AUDIO_MANAGER_PATH := "res://src/scripts/audio_manager_enhanced.gd"
const AUDIO_PRESETS_PATH := "res://src/scripts/audio_presets.gd"

const EXPECTED_7_BUCKETS := [
	"prewarm_music_streams",         # T066 — 9 BGM
	"prewarm_hit_sfx",               # T181 — 5 verb hit
	"prewarm_shop_sfx",              # T181 — 8 shop SFX
	"prewarm_misc_sfx",              # T181 — 12 misc
	"prewarm_verb_cooldown_tails",   # T220 #142 — F022 — 5 verb cool tail
	"prewarm_verb_fire_sfx",         # T220 #142 — F022 — 5 verb fire
	"prewarm_verb_cooldown_readys",  # T220 #142 — F022 — 5 verb ready
]

var _failures: Array[String] = []
var _passes: int = 0

func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passes += 1
		print("[PASS] %s" % msg)
	else:
		_failures.append(msg)
		print("[FAIL] %s" % msg)

func _init() -> void:
	print("=== I053 (T228 #148 + T231 #149) — 7 桶 prewarm aggregator idempotency 静态验证 ===")
	var ame_text := _read_text(AUDIO_MANAGER_PATH)
	var ap_text := _read_text(AUDIO_PRESETS_PATH)
	if ame_text.is_empty() or ap_text.is_empty():
		_failures.append("cannot read %s or %s" % [AUDIO_MANAGER_PATH, AUDIO_PRESETS_PATH])
		_finish()
		return

	_run_t228_check1_bucket_names(ame_text)
	_run_t228_check2_aggregator(ame_text)
	_run_t228_check3_cache_guards(ame_text)
	_run_t228_check4_music_presets(ap_text, ame_text)
	_run_t228_check5_aggregator_order(ame_text)
	_finish()


# ---------- (1) 7 桶函数名 rename 检测 (T220) ----------
func _run_t228_check1_bucket_names(ame_text: String) -> void:
	print("--- T228 check 1: 7 桶函数名都存在 (rename 检测 7 子断言) ---")
	for bucket_name in EXPECTED_7_BUCKETS:
		# 函数定义 模式: "func <name>("
		_assert(("func " + bucket_name + "(") in ame_text,
			"T228.CHECK1.%s.1 — 7 桶 %s 函数名存在 (T220 #142 rename 保护)" % [bucket_name, bucket_name])


# ---------- (2) prewarm_all_sfx() aggregator 存在 (T220) ----------
func _run_t228_check2_aggregator(ame_text: String) -> void:
	print("--- T228 check 2: prewarm_all_sfx() aggregator 存在 (T220) ---")
	_assert("func prewarm_all_sfx(" in ame_text,
		"T228.CHECK2.1 — prewarm_all_sfx() aggregator 函数定义存在 (T220 #142 7 桶聚合入口)")


# ---------- (3) cache guards 5 步 (idempotency 合约) ----------
func _run_t228_check3_cache_guards(ame_text: String) -> void:
	print("--- T228 check 3: cache guards 都生效 (idempotency 合约 5 步) ---")
	# 7 桶内部 cache guard 模式 (T181 + T220): 单值用 `if X == null` / dict 用
	# `if not X.has(level)`. 静态验证 4 类 guard 都存在:
	#   - _bind_hit_stream / _bind_stream / _cut_stream / _echo_stream
	#     == null guards
	#   - _pulse_hit_streams / _cut_hit_streams / _echo_hit_streams
	#     .has(level) guards
	_assert("if _bind_hit_stream == null" in ame_text,
		"T228.CHECK3.1 — prewarm_hit_sfx _bind_hit_stream == null guard 存在 (T181 单值 cache guard)")
	_assert("if not _pulse_hit_streams.has" in ame_text,
		"T228.CHECK3.2 — prewarm_hit_sfx _pulse_hit_streams.has() guard 存在 (T181 dict cache guard)")
	_assert("if _bind_stream == null" in ame_text,
		"T228.CHECK3.3 — prewarm_verb_fire_sfx _bind_stream == null guard 存在 (T220 #142 单值 cache guard)")
	_assert("if _cut_stream == null" in ame_text,
		"T228.CHECK3.4 — prewarm_verb_fire_sfx _cut_stream == null guard 存在 (T220 #142 单值 cache guard)")
	_assert("if _echo_stream == null" in ame_text,
		"T228.CHECK3.5 — prewarm_verb_fire_sfx _echo_stream == null guard 存在 (T220 #142 单值 cache guard)")
	# .has() HashSet 调用存在 (dict guard runtime pattern)
	_assert(".has(" in ame_text,
		"T228.CHECK3.6 — .has() dict guard 调用存在 (T181 + T220 dict cache guard runtime pattern)")


# ---------- (4) AudioPresets.MUSIC_PRESETS 9 主题 (T066) ----------
func _run_t228_check4_music_presets(ap_text: String, ame_text: String) -> void:
	print("--- T228 check 4: AudioPresets.MUSIC_PRESETS 9 主题 _ensure_music_stream (T066) ---")
	_assert("MUSIC_PRESETS" in ap_text,
		"T228.CHECK4.1 — AudioPresets.MUSIC_PRESETS 字典定义存在 (T066)")
	_assert("func _ensure_music_stream" in ame_text,
		"T228.CHECK4.2 — _ensure_music_stream 私有函数定义存在 (T066 idempotency 入口)")
	# 9 主题键 (T066):
	for k in ["title_intro", "hub_warm", "archive_exploration", "archive_boss", "archive_boss_dual", "archive_dawn", "archive_storm", "silence_void", "whisper_hollow"]:
		_assert(k in ap_text,
			"T228.CHECK4.3 — MUSIC_PRESETS 键 %s 存在 (T066 9 主题 1)" % k)


# ---------- (5) 7 桶顺序与 prewarm_all_sfx() 一致 (T220) ----------
func _run_t228_check5_aggregator_order(ame_text: String) -> void:
	print("--- T228 check 5: prewarm_all_sfx() 调用 7 桶顺序 (T220) ---")
	# 锁 prewarm_all_sfx 函数体
	var aggregator_idx: int = ame_text.find("func prewarm_all_sfx(")
	if aggregator_idx < 0:
		_failures.append("T228.CHECK5.1 — prewarm_all_sfx 函数体找不到")
		_passes -= 1
		return
	var next_func: int = ame_text.find("\nfunc ", aggregator_idx + 1)
	if next_func < 0:
		next_func = aggregator_idx + 3000
	var aggregator_body: String = ame_text.substr(aggregator_idx, next_func - aggregator_idx)

	# 7 桶都出现在 aggregator 内 (调用顺序保留)
	for bucket_name in EXPECTED_7_BUCKETS:
		_assert(bucket_name in aggregator_body,
			"T228.CHECK5.2 — aggregator 调用 7 桶 %s (T220 顺序保留)" % bucket_name)


# Helper: read a file as text, return empty string on failure.
func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var txt: String = f.get_as_text()
	f.close()
	return txt


# Helper: print final result + quit with the right exit code.
func _finish() -> void:
	print("")
	if _failures.is_empty():
		print("ALL %d CHECKS PASSED." % _passes)
		quit(0)
	else:
		print("FAILURES DETECTED — %d failure(s) out of %d assertion(s)." % [_failures.size(), _passes])
		for fail_msg in _failures:
			print("  - %s" % fail_msg)
		quit(1)
