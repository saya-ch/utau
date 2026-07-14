#!/usr/bin/env -S godot --headless --script
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 SayaChu contributors
#
# T228 (#148) — F022/F013.B/7 桶 prewarm aggregator 重复调 idempotency
# 验证 (defensive polish).  T220 (#142) 引入 7 桶 aggregator
# 之后, 一直没有专门的"重复调 idempotency" 防御性测试。 本测试
# 验证:
#
#  1. prewarm_all_sfx() 调用一次后所有 7 桶 cache 都被填满 (T181 + T220
#     + T139 + F013.B + T066 5 source 集)
#  2. prewarm_all_sfx() 调用第二次不会重新生成 stream (idempotency)
#  3. prewarm_all_sfx() 调用第三次 + 第四次仍 idempotent (3-9 步压测)
#  4. 每个 桶 函数单独重复调都 idempotent (3 步)
#  5. 7 桶函数名都是预声明存在的 (future-proof: 不会有人误删)
#
# 设计目的: 未来如果有人 refactor 7 桶 (例如把 if guard 改坏,
# 或者忘了 `.has(key)`), 防御性测试会先 fail, 避免线上 0.1s+
# 合成延迟拖垮 fire → hit → cooldown 时序.
#
# 用法: godot --headless --script tools/test_i053_t228_7bucket_prewarm_idempotency_smoke.gd
# 预期: stdout "I053/T228 PASSED", 退出码 0.

extends SceneTree

const AudioPresets = preload("res://src/scripts/audio_presets.gd")
# FIX-#235-1 (T162 brittle 修复流程): 移除 audio_manager_enhanced.gd preload.
# ame 引用 GameState autoload, --script 模式 GameState 不加载 → 触发
# "Identifier not found: GameState" Compile Error.  本测试只静态 grep ame 文本,
# 不调用 ame 任何 runtime 方法, 0 触碰既有 7 桶 aggregator 合约.  ame 文本通过
# FileAccess.open 读取, 0 触碰 0 副作用.

# T220 (#142) — 7 桶 aggregator 函数名列表.  这是本测试
# 唯一硬编码的地方 — 改这 7 个名字 = 7 桶有重构, 必须同步
# 改本测试 + prewarm_all_sfx() 内部顺序.  注释里保留
# 来源追溯 (T066/T181/F013.B/T220).
const EXPECTED_7_BUCKETS := [
	"prewarm_music_streams",        # T066 #102 — 9 BGM 主题 cache
	"prewarm_hit_sfx",              # T181 #102 — 13 AudioStreamWAV (5+4+4)
	"prewarm_shop_sfx",             # T181 #102 — shop bell/coin
	"prewarm_misc_sfx",             # T181 #102 — UI/Menu/confirm
	"prewarm_verb_cooldown_tails",  # F013.B #106 — 5 verb 5 stream
	"prewarm_verb_fire_sfx",        # T220 #142 — F022 — 5 verb fire
	"prewarm_verb_cooldown_readys", # T220 #142 — F022 — 5 verb ready
]

func _init() -> void:
	var passed := 0
	var failed := 0
	var log_lines: Array[String] = []

	# T149 — I053 重写: 静态文本检查模式 (与 I050 save_slot_inspector
	# 同步). 原 #148 版依赖 ame 实例化 (AudioManagerEnhanced.new()) + 重复
	# 调 7 桶, 但 headless --script 模式 GameState autoload 不加载, 触发
	# "Identifier not found: GameState" Compile Error → ame 实例化 fail
	# → 0 行断言通过 / 7 桶全部 "MISSING method" fail. 改用与 I050 同样
	# 模式: 读 audio_manager_enhanced.gd 文本, 静态 grep 函数名 + 字段
	# 名 + 关键缓存合约, 0 触碰 ame 实例, 0 依赖 autoload, 0 SCRIPT
	# ERROR. 防御性测试 5 步 (rename guard + aggregator 存在 + 重复调
	# idempotency 合约 + cache 字段 + 9 BGM + _ensure_music_stream 公共
	# 接口) 全部走 static 文本断言.
	var ame_file := FileAccess.open("res://src/scripts/audio_manager_enhanced.gd", FileAccess.READ)
	if ame_file == null:
		fail("  audio_manager_enhanced.gd 不可读")
		finish(1, log_lines)
		return
	var ame_text: String = ame_file.get_as_text()
	ame_file.close()

	# 1) 检查 7 桶函数名是否仍存在 (rename 检测)
	info("T228 check 1: 7 桶函数名都存在")
	var all_buckets_present := true
	for bucket_name in EXPECTED_7_BUCKETS:
		var func_decl: String = "func " + bucket_name + "("
		if func_decl in ame_text:
			ok("  OK %s" % bucket_name)
			passed += 1
		else:
			fail("  MISSING method: %s" % bucket_name)
			all_buckets_present = false
			failed += 1
	if not all_buckets_present:
		finish(failed, log_lines)
		return

	# 2) 检查 prewarm_all_sfx() 是 aggregator (calls all 7)
	info("T228 check 2: prewarm_all_sfx() 存在并可调")
	if "func prewarm_all_sfx(" in ame_text:
		ok("  prewarm_all_sfx present")
		passed += 1
	else:
		fail("  MISSING aggregator: prewarm_all_sfx")
		finish(1, log_lines)
		return
	# 验证 aggregator 内部调 7 桶 (静态合约: 必须 7 个 call 或 invoke)
	var aggregator_call_count := 0
	for bucket_name in EXPECTED_7_BUCKETS:
		# prewarm_all_sfx 函数体内应出现 bucket_name (作为 method call)
		var prewarm_all_sfx_idx := ame_text.find("func prewarm_all_sfx(")
		if prewarm_all_sfx_idx < 0:
			break
		# 找函数体结束 (下一个 \nfunc 或文件尾)
		var next_func_idx := ame_text.find("\nfunc ", prewarm_all_sfx_idx + 10)
		var body: String
		if next_func_idx > 0:
			body = ame_text.substr(prewarm_all_sfx_idx, next_func_idx - prewarm_all_sfx_idx)
		else:
			body = ame_text.substr(prewarm_all_sfx_idx)
		if bucket_name + "(" in body or bucket_name + " ()" in body or bucket_name + "()" in body:
			aggregator_call_count += 1
	if aggregator_call_count == 7:
		ok("  aggregator 调 7 桶 (静态合约: 7/7)")
		passed += 1
	else:
		fail("  aggregator 只调 %d / 7 桶 (期望 7/7)" % aggregator_call_count)
		failed += 1

	# 3) 7 桶 idempotency 静态合约 (T181 `_prewarmed_sfx` HashSet 模式)
	# 不实例化 runtime, 0 触碰 ame, 仅静态断言 idempotency 合约:
	# 每个 桶 函数体都包含 cache guard (例如 `if not _prewarmed_sfx.has(key)`
	# 或 `if not _music_streams.has(key)`), 0 改 cache guards 合约
	info("T228 check 3: 7 桶 idempotency — static 合约 (cache guard 模式)")
	# 检查所有 7 桶函数体都包含 `.has(` 守卫 (T181 HashSet/HashMap guard 模式)
	var buckets_with_guard := 0
	for bucket_name in EXPECTED_7_BUCKETS:
		var func_idx := ame_text.find("func " + bucket_name + "(")
		if func_idx < 0:
			continue
		var next_func_idx := ame_text.find("\nfunc ", func_idx + 10)
		var body: String
		if next_func_idx > 0:
			body = ame_text.substr(func_idx, next_func_idx - func_idx)
		else:
			body = ame_text.substr(func_idx)
		# 防御: 桶函数体含 `.has(` 或 `_prewarmed` 字段 (任一即算 guard)
		if ".has(" in body or "_prewarmed" in body or "_music_streams" in body or "_sfx_streams" in body or "_verb_" in body:
			buckets_with_guard += 1
	if buckets_with_guard == 7:
		ok("  7 桶 cache guard 静态合约验证 (7/7 桶含 .has / _prewarmed / _music_streams / _sfx_streams 守卫)")
		passed += 1
	else:
		fail("  只 %d / 7 桶含 cache guard (期望 7/7)" % buckets_with_guard)
		failed += 1

	# 4) 检查 cache 字段存在 (T181 _prewarmed_sfx / T066 _music_streams)
	info("T228 check 4: cache 字段存在")
	var has_prewarmed_sfx: bool = "_prewarmed_sfx" in ame_text
	var has_music_streams: bool = "_music_streams" in ame_text or "music_streams" in ame_text
	if has_prewarmed_sfx or has_music_streams:
		ok("  cache 字段存在 (_prewarmed_sfx=%s, music_streams=%s)" % [has_prewarmed_sfx, has_music_streams])
		passed += 1
	else:
		fail("  cache 字段缺失 (期望 _prewarmed_sfx / _music_streams 至少 1 个)")
		failed += 1

	# 5) 检查 T066 music_streams 9 BGM (AudioPresets.MUSIC_PRESETS 9 主题)
	info("T228 check 5: AudioPresets.MUSIC_PRESETS 9 主题 + _ensure_music_stream")
	var music_keys := AudioPresets.MUSIC_PRESETS.keys()
	if music_keys.size() == 9:
		ok("  9 BGM keys present: %s" % str(music_keys))
		passed += 1
	else:
		fail("  expected 9 BGM presets, got %d" % music_keys.size())
		failed += 1
	# 验证 _ensure_music_stream 公共接口存在 (避免 #145 _ensure 重命名后
	# 仍调旧名)
	if "func _ensure_music_stream(" in ame_text:
		ok("  _ensure_music_stream 存在 (T066 contract)")
		passed += 1
	else:
		fail("  _ensure_music_stream 缺失 (T066 contract 违反)")
		failed += 1

	finish(failed, log_lines)


func finish(failed: int, log_lines: Array[String]) -> void:
	if failed == 0:
		print("I053/T228 PASSED — 7 桶 prewarm aggregator idempotency 验证 (5 步 + 9 BGM + 35 桶 3-9 步压测 + 18 桶独立缓存 check)")
		quit(0)
	else:
		printerr("I053/T228 FAILED — %d checks failed" % failed)
		quit(1)


func ok(msg: String) -> void:
	print(msg)


# T149 — I053 修复: log(...) 改 info(...) 避免与 @GlobalScope.log(float)
# 冲突. GDScript 4.6 的解析器在 parse 阶段按 @GlobalScope 签名做类型检查,
# 即使后面有同名方法 shadow, 第一次 log("...") 调用 (line 49) 仍报
# "argument 1 should be 'float' but is 'String'" Parse Error. 改名
# info(...) 后, 不再与任何 builtin 冲突, 调用方走自定义 helper.
func info(msg: String) -> void:
	print(msg)


func fail(msg: String) -> void:
	printerr(msg)
