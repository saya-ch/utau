extends SceneTree
## I046 (#142) — F022 7 桶 prewarm aggregator 调优 (verb_fire + verb_cooldown_ready 桶) 冒烟测试
##
## 覆盖 #142 任务 T220 原子化提交:
##
## === F022 — prewarm aggregator 5 → 7 桶扩 (verb_fire + verb_cooldown_ready) ===
## - F022.PRE.FIRE.SIG: prewarm_verb_fire_sfx() 公开方法
## - F022.PRE.FIRE.FIELDS: 4 stream cache (_bind / _cut / _echo / _wave_fire) 守卫
## - F022.PRE.FIRE.GENERATE: 4 stream 各调对应 _generate_*_sfx() (非 lazy)
## - F022.PRE.READY.SIG: prewarm_verb_cooldown_readys() 公开方法
## - F022.PRE.READY.LOOP: 5 verb 循环 (pulse / bind / cut / echo / wave)
## - F022.PRE.READY.CACHE: 5 stream 全部 cache 到 _verb_cooldown_streams
## - F022.PRE.READY.START_MIDI: 用 _verb_cooldown_start_midi (NOT tail variant) 保 69/71/73/75/77 whole-tone
## - F022.PRE.AGGREGATOR.FIRE: prewarm_all_sfx() 追加 prewarm_verb_fire_sfx (第 6 桶)
## - F022.PRE.AGGREGATOR.READY: prewarm_all_sfx() 追加 prewarm_verb_cooldown_readys (第 7 桶)
## - F022.PRE.ORDER.7B: 7 桶顺序 music → hit → shop → misc → verb_cooldown_tail → verb_fire → verb_cooldown_ready
## - F022.PRE.IDEMPOTENT: 7 helper 各 cache 守卫 (重复调 0 副作用)
## - F022.DOC.COMMENT: 注释含 T220 (#142) 锚点 + 7 桶说明

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I046 (#142) — F022 7 桶 prewarm aggregator 调优 (verb_fire + verb_cooldown_ready) ===")
	_run_f022_pre_fire_assertions()
	_run_f022_pre_ready_assertions()
	_run_f022_pre_aggregator_assertions()
	_run_f022_pre_order_7b_assertions()
	_run_f022_pre_idempotent_assertions()
	_run_f022_doc_comment_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I046 (#142) F022 7 桶 prewarm aggregator ASSERTIONS PASSED ===")
		quit(0)


# ===================== F022 — prewarm aggregator 5 → 7 桶扩 =====================

# ---------- F022.PRE.FIRE.* — verb fire SFX 预热 helper ----------
func _run_f022_pre_fire_assertions() -> void:
	print("--- F022.PRE.FIRE.* — verb fire SFX 预热 helper ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_verb_fire_sfx() -> void:",
		"F022.PRE.FIRE.SIG.1: prewarm_verb_fire_sfx() 公开方法 (T220 #142 第 6 桶 helper)")
	# 4 stream cache 守卫 (Pulse stream 已在 _ready() 设置, 不需要 lazy)
	_assert_contains(src, "if _bind_stream == null:",
		"F022.PRE.FIRE.FIELDS.1: _bind_stream null 守卫 (T220 #142 fire 桶)")
	_assert_contains(src, "if _cut_stream == null:",
		"F022.PRE.FIRE.FIELDS.2: _cut_stream null 守卫 (T220 #142 fire 桶)")
	_assert_contains(src, "if _echo_stream == null:",
		"F022.PRE.FIRE.FIELDS.3: _echo_stream null 守卫 (T220 #142 fire 桶)")
	_assert_contains(src, "if _wave_fire_stream == null:",
		"F022.PRE.FIRE.FIELDS.4: _wave_fire_stream null 守卫 (T220 #142 fire 桶)")
	# 4 stream 各调对应 _generate_*_sfx() (非 lazy)
	_assert_contains(src, "_bind_stream = _generate_bind_sfx()",
		"F022.PRE.FIRE.GENERATE.1: _bind_stream = _generate_bind_sfx() (prewarm fire 桶 synth 触发)")
	_assert_contains(src, "_cut_stream = _generate_cut_sfx()",
		"F022.PRE.FIRE.GENERATE.2: _cut_stream = _generate_cut_sfx() (prewarm fire 桶 synth 触发)")
	_assert_contains(src, "_echo_stream = _generate_echo_sfx()",
		"F022.PRE.FIRE.GENERATE.3: _echo_stream = _generate_echo_sfx() (prewarm fire 桶 synth 触发)")
	_assert_contains(src, "_wave_fire_stream = _generate_wave_fire_sfx()",
		"F022.PRE.FIRE.GENERATE.4: _wave_fire_stream = _generate_wave_fire_sfx() (prewarm fire 桶 synth 触发)")


# ---------- F022.PRE.READY.* — verb cooldown READY 预热 helper ----------
func _run_f022_pre_ready_assertions() -> void:
	print("--- F022.PRE.READY.* — verb cooldown READY 预热 helper ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_verb_cooldown_readys() -> void:",
		"F022.PRE.READY.SIG.1: prewarm_verb_cooldown_readys() 公开方法 (T220 #142 第 7 桶 helper)")
	# 5 verb 循环 (pulse / bind / cut / echo / wave) — 与 F013.B tail 模式同
	_assert_contains(src, "for verb_name in [\"pulse\", \"bind\", \"cut\", \"echo\", \"wave\"]:",
		"F022.PRE.READY.LOOP.1: 5 verb 循环 (pulse / bind / cut / echo / wave, 与 F013.B tail 一致)")
	# 5 stream 全部 cache 到 _verb_cooldown_streams (与 tail cache 到 _verb_cooldown_tail_streams 对偶)
	_assert_contains(src, "_verb_cooldown_streams[verb_name] = _generate_verb_cooldown_jingle(start_midi)",
		"F022.PRE.READY.CACHE.1: 5 stream 全部 cache 到 _verb_cooldown_streams (与 F013.B tail 对偶结构)")
	# 用 _verb_cooldown_start_midi (NOT _verb_cooldown_tail_start_midi) 保 69/71/73/75/77 whole-tone
	_assert_contains(src, "var start_midi: int = _verb_cooldown_start_midi(verb_name)",
		"F022.PRE.READY.START_MIDI.1: 用 _verb_cooldown_start_midi (NOT tail variant) 保 READY 69/71/73/75/77 whole-tone 锚点")


# ---------- F022.PRE.AGGREGATOR.* — prewarm_all_sfx 集成 ----------
func _run_f022_pre_aggregator_assertions() -> void:
	print("--- F022.PRE.AGGREGATOR.* — prewarm_all_sfx 集成 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var aggregator_body_start := src.find("func prewarm_all_sfx() -> void:")
	if aggregator_body_start == -1:
		_failures.append("FAIL: F022.PRE.AGGREGATOR.1: prewarm_all_sfx 函数未找到")
		return
	var aggregator_body := src.substr(aggregator_body_start)
	_assert_contains(aggregator_body, "prewarm_verb_fire_sfx()",
		"F022.PRE.AGGREGATOR.FIRE.1: prewarm_all_sfx() 追加 prewarm_verb_fire_sfx (T220 #142 第 6 桶)")
	_assert_contains(aggregator_body, "prewarm_verb_cooldown_readys()",
		"F022.PRE.AGGREGATOR.READY.1: prewarm_all_sfx() 追加 prewarm_verb_cooldown_readys (T220 #142 第 7 桶)")


# ---------- F022.PRE.ORDER.7B — 7 桶顺序 ----------
func _run_f022_pre_order_7b_assertions() -> void:
	print("--- F022.PRE.ORDER.7B — 7 桶顺序 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var aggregator_body_start := src.find("func prewarm_all_sfx() -> void:")
	if aggregator_body_start == -1:
		_failures.append("FAIL: F022.PRE.ORDER.7B.1: prewarm_all_sfx 函数未找到")
		return
	var aggregator_body := src.substr(aggregator_body_start)
	# 7 桶顺序: music → hit → shop → misc → verb_cooldown_tail → verb_fire → verb_cooldown_ready
	var prewarm_calls := ["prewarm_music_streams()", "prewarm_hit_sfx()", "prewarm_shop_sfx()",
		"prewarm_misc_sfx()", "prewarm_verb_cooldown_tails()",
		"prewarm_verb_fire_sfx()", "prewarm_verb_cooldown_readys()"]
	var last_pos := -1
	var order_ok := true
	var order_strs := []
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
		print("  OK  F022.PRE.ORDER.7B.1: 7 桶 aggregator 顺序 music → hit → shop → misc → verb_cooldown_tail → verb_fire → verb_cooldown_ready (T220 #142 覆盖 fire/hit/ready/tail 完整时序)")
	else:
		_failures.append("FAIL: F022.PRE.ORDER.7B.1: 7 桶顺序错: %s" % ", ".join(order_strs))


# ---------- F022.PRE.IDEMPOTENT — 7 helper cache 守卫 ----------
func _run_f022_pre_idempotent_assertions() -> void:
	print("--- F022.PRE.IDEMPOTENT — 7 helper cache 守卫 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# F022 新加的 2 个 helper 各 cache 守卫 (重复调 0 副作用)
	var fire_body_start := src.find("func prewarm_verb_fire_sfx() -> void:")
	if fire_body_start == -1:
		_failures.append("FAIL: F022.PRE.IDEMPOTENT.1: prewarm_verb_fire_sfx 函数未找到")
	else:
		var fire_body := src.substr(fire_body_start, 600)
		var null_guards := 0
		for null_check in ["if _bind_stream == null:", "if _cut_stream == null:",
				"if _echo_stream == null:", "if _wave_fire_stream == null:"]:
			if fire_body.find(null_check) != -1:
				null_guards += 1
		if null_guards == 4:
			_passes += 1
			print("  OK  F022.PRE.IDEMPOTENT.FIRE.1: prewarm_verb_fire_sfx 4 stream 全有 null 守卫 (重复调 0 副作用)")
		else:
			_failures.append("FAIL: F022.PRE.IDEMPOTENT.FIRE.1: prewarm_verb_fire_sfx 缺 null 守卫 (%d/4)" % null_guards)
	var ready_body_start := src.find("func prewarm_verb_cooldown_readys() -> void:")
	if ready_body_start == -1:
		_failures.append("FAIL: F022.PRE.IDEMPOTENT.2: prewarm_verb_cooldown_readys 函数未找到")
	else:
		var ready_body := src.substr(ready_body_start, 600)
		if ready_body.find("if not _verb_cooldown_streams.has(verb_name):") != -1:
			_passes += 1
			print("  OK  F022.PRE.IDEMPOTENT.READY.1: prewarm_verb_cooldown_readys 用 Dict.has 守卫 (重复调 0 副作用)")
		else:
			_failures.append("FAIL: F022.PRE.IDEMPOTENT.READY.1: prewarm_verb_cooldown_readys 缺 Dict.has 守卫")


# ---------- F022.DOC.COMMENT — 注释含 T220 (#142) 锚点 + 7 桶说明 ----------
func _run_f022_doc_comment_assertions() -> void:
	print("--- F022.DOC.COMMENT — 注释含 T220 (#142) 锚点 + 7 桶说明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "T220 (#142)",
		"F022.DOC.COMMENT.1: T220 (#142) 锚点在源代码注释中 (audio_manager_enhanced.gd)")
	_assert_contains(src, "F022",
		"F022.DOC.COMMENT.2: F022 标签在源代码注释中 (audio_manager_enhanced.gd)")
	_assert_contains(src, "7 桶",
		"F022.DOC.COMMENT.3: 7 桶说明在源代码注释中 (aggregator 升级文档)")


# ===================== 通用 helper =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % label)
	else:
		_failures.append("FAIL: %s (missing: %s)" % [label, needle])


func _print_summary() -> void:
	print("")
	print("--- Summary ---")
	print("  PASS: %d" % _passes)
	print("  FAIL: %d" % _failures.size())
	for fail_msg in _failures:
		print("  %s" % fail_msg)
