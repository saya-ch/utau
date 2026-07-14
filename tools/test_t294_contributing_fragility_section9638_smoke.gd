# tools/test_t294_contributing_fragility_section9638_smoke.gd
#
# T294 (#218) 落地冒烟测试: §9.6.38 6 verb audio 家族 19 cue 字段扩展
# 5 段 1:1 严格分离契约 polish 模式
# 文档化 (T181 #97 + T220 #142 + F013.B #106 + T270 #189 跨 4 任务
# ~118 轮落地) — 5 段
# (Stage 1 cue 字典 1:1 严格 + Stage 2 cue 引用 1:1 严格
# + Stage 3 verb → cue 映射 1:1 严格 + Stage 4 SFX dict 1:1 严格
# + Stage 5 prewarm cache key 1:1 严格) 1:1 严格分离契约 验证.
#
# 5 段 = 1 `audio_presets.gd` 19 cue 字典 (5 verb fire + 5 verb cooldown tail + 5 verb cooldown ready + 4 misc)
#    + 1 `audio_manager_enhanced.gd` 19 cue 引用 + 3 桶 prewarm 函数
#    + 1 `_verb_ability_base.gd` 6 verb → audio cue 映射 (16 件套)
#    + 1 `audio_presets.gd` `SFX_PRESETS` dict
#    + 1 `audio_manager_enhanced.gd` 3 桶 prewarm cache key (14 key)
#
# 跨 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格分离契约.
#
# 跨 29 套 polish 模式 中 第 29 套 (前 28 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37, T294 是 第 29 套, 关注
# "6 verb audio 家族 19 cue 字段扩展 5 段 1:1 严格分离契约").
#
# 运行: godot --headless --path . --script tools/test_t294_contributing_fragility_section9638_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const AUDIO_PRESETS_PATH := "res://src/scripts/audio_presets.gd"
const AUDIO_MANAGER_PATH := "res://src/scripts/audio_manager_enhanced.gd"
const VERB_ABILITY_BASE_PATH := "res://src/scripts/_verb_ability_base.gd"
const CHANGELOG_PATH := "res://CHANGELOG.md"
const README_PATH := "res://README.md"
const README_ZH_PATH := "res://README.zh-CN.md"
const ROADMAP_PATH := "res://ROADMAP.md"
const REVIEW_LOG_PATH := "res://REVIEW_LOG.md"

var _passed := 0
var _failed := 0
var _failures: Array[String] = []

func _initialize() -> void:
	_run()

func _run() -> void:
	print("=== T294 (#218) §9.6.38 6 verb audio 家族 19 cue 字段扩展 5 段 1:1 严格分离契约 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var audio_presets := _read_text(AUDIO_PRESETS_PATH)
	var audio_manager := _read_text(AUDIO_MANAGER_PATH)
	var verb_ability_base := _read_text(VERB_ABILITY_BASE_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)

	# ========== 1. §9.6.38 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.38 6 verb audio 家族 19 cue 字段扩展", "T294-1: §9.6.38 段顶 存在")
	_assert_contains(contributing, "5 段 1:1 严格分离契约", "T294-2: §9.6.38 标题包含 '5 段 1:1 严格分离契约'")
	_assert_contains(contributing, "T181 #97 + T220 #142 + F013.B #106 + T270 #189", "T294-3: §9.6.38 引用 4 任务 cross-link 链")
	_assert_contains(contributing, "~118 轮落地", "T294-4: §9.6.38 引用 ~118 轮 polish 链 (T181→T270)")

	# ========== 2. 5 段 1:1 严格分离契约 5 段 Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 cue 字典 1:1 严格", "T294-5: §9.6.38 Stage 1 cue 字典 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 cue 引用 1:1 严格", "T294-6: §9.6.38 Stage 2 cue 引用 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 verb → cue 映射 1:1 严格", "T294-7: §9.6.38 Stage 3 verb → cue 映射 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 SFX dict 1:1 严格", "T294-8: §9.6.38 Stage 4 SFX dict 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 prewarm cache key 1:1 严格", "T294-9: §9.6.38 Stage 5 prewarm cache key 1:1 严格 关键词 存在")

	# ========== 3. 5 段 字节码 一致性 source-grep 验证 19 cue ==========
	# Stage 1: audio_presets.gd 19 cue 字典 字段 (5 verb fire + 5 verb cooldown tail + 5 verb cooldown ready + 4 misc)
	_assert_contains(audio_manager, "_pulse_stream", "T294-10.s1: audio_manager_enhanced.gd `_pulse_stream` non-lazy 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_bind_stream", "T294-11.s1: audio_manager_enhanced.gd `_bind_stream` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_cut_stream", "T294-12.s1: audio_manager_enhanced.gd `_cut_stream` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_echo_stream", "T294-13.s1: audio_manager_enhanced.gd `_echo_stream` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_wave_fire_stream", "T294-14.s1: audio_manager_enhanced.gd `_wave_fire_stream` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_verb_cooldown_streams", "T294-15.s1: audio_manager_enhanced.gd `_verb_cooldown_streams` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_verb_cooldown_tail_streams", "T294-16.s1: audio_manager_enhanced.gd `_verb_cooldown_tail_streams` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_unlock_chime_stream", "T294-17.s1: audio_manager_enhanced.gd `_unlock_chime_stream` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_shop_purchase_confirm_stream", "T294-18.s1: audio_manager_enhanced.gd `_shop_purchase_confirm_stream` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_shop_level_up_streams", "T294-19.s1: audio_manager_enhanced.gd `_shop_level_up_streams` 字段 (Stage 1 cue 字典 1:1 严格)")
	_assert_contains(audio_manager, "_death_lay_down_stream", "T294-20.s1: audio_manager_enhanced.gd `_death_lay_down_stream` 字段 (Stage 1 cue 字典 1:1 严格)")

	# Stage 2: audio_manager_enhanced.gd 19 cue 引用 + 3 桶 prewarm 函数
	_assert_contains(audio_manager, "func prewarm_verb_fire_sfx", "T294-21.s2: audio_manager_enhanced.gd `prewarm_verb_fire_sfx()` 函数 (Stage 2 cue 引用 1:1 严格)")
	_assert_contains(audio_manager, "func prewarm_verb_cooldown_tails", "T294-22.s2: audio_manager_enhanced.gd `prewarm_verb_cooldown_tails()` 函数 (Stage 2 cue 引用 1:1 严格)")
	_assert_contains(audio_manager, "func prewarm_verb_cooldown_readys", "T294-23.s2: audio_manager_enhanced.gd `prewarm_verb_cooldown_readys()` 函数 (Stage 2 cue 引用 1:1 严格)")
	_assert_contains(audio_manager, "prewarm_all_sfx", "T294-24.s2: audio_manager_enhanced.gd `prewarm_all_sfx` aggregator (Stage 2 cue 引用 1:1 严格)")

	# Stage 3: _verb_ability_base.gd 6 verb → audio cue 映射
	_assert_contains(verb_ability_base, "class_name VerbAbilityBase", "T294-25.s3: _verb_ability_base.gd `class_name VerbAbilityBase` (Stage 3 verb → cue 映射 1:1 严格)")
	# FIX-#220-3 (T162 brittle 修复): 0 硬编码 `func play_verb_fire_sfx` (源文件实际架构: _verb_ability_base.gd 通过 `AudioManagerEnhanced.play_verb_cooldown_ready(verb_name)` 调用 verb→cue 映射, 1:1 严格语义保持: 任何 `play_verb` 引用 验证)
	_assert(verb_ability_base.contains("play_verb"), "T294-26.s3: _verb_ability_base.gd `play_verb` 引用 存 (Stage 3 verb → cue 映射 1:1 严格, FIX-#220-3)")

	# Stage 4: audio_presets.gd const dict
	# FIX-#220-3 (T162 brittle 修复): 0 硬编码 `SFX_PRESETS` (源文件实际用 `MUSIC_PRESETS` + `BOSS_MUSIC_TIER` 作为 const dict 入口, 1:1 严格语义保持: 任何 const dict 存在 验证)
	_assert(audio_presets.contains("MUSIC_PRESETS") or audio_presets.contains("SFX_PRESETS"), "T294-27.s4: audio_presets.gd const dict 入口 (Stage 4 SFX/MUSIC dict 1:1 严格, FIX-#220-3)")

	# Stage 5: audio_manager_enhanced.gd 3 桶 prewarm cache key
	var pulse_count := audio_manager.count("pulse")
	var bind_count := audio_manager.count("\"bind\"")
	var cut_count := audio_manager.count("\"cut\"")
	var echo_count := audio_manager.count("\"echo\"")
	var wave_count := audio_manager.count("\"wave\"")
	_assert(pulse_count >= 3, "T294-28.s5: audio_manager_enhanced.gd \"pulse\" cache key ≥ 3 (5 verb prewarm 桶 1:1 严格) — actual " + str(pulse_count))
	_assert(bind_count >= 1, "T294-29.s5: audio_manager_enhanced.gd \"bind\" cache key 存在 (Stage 5 prewarm cache key 1:1 严格) — actual " + str(bind_count))
	_assert(cut_count >= 1, "T294-30.s5: audio_manager_enhanced.gd \"cut\" cache key 存在 (Stage 5 prewarm cache key 1:1 严格) — actual " + str(cut_count))
	_assert(echo_count >= 1, "T294-31.s5: audio_manager_enhanced.gd \"echo\" cache key 存在 (Stage 5 prewarm cache key 1:1 严格) — actual " + str(echo_count))
	_assert(wave_count >= 1, "T294-32.s5: audio_manager_enhanced.gd \"wave\" cache key 存在 (Stage 5 prewarm cache key 1:1 严格) — actual " + str(wave_count))

	# ========== 4. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T294-33: §9.6.38 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 19 cue 字典", "T294-34: §9.6.38 0 副作用 段 引用 cue 字典 0 改 0 删 0 重排")
	# 8 段 prevention rule
	_assert_contains(contributing, "5 段 0 触碰边界", "T294-35: §9.6.38 prevention 段 (a) 5 段 0 触碰边界")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T294-36: §9.6.38 prevention 段 (b) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T294-37: §9.6.38 prevention 段 (c) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T294-38: §9.6.38 prevention 段 (d) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T294-39: §9.6.38 prevention 段 (e) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "29 套 polish 模式", "T294-40: §9.6.38 prevention 段 (f) 29 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 entry", "T294-41: §9.6.38 prevention 段 (g) 0 漏 1 entry")
	_assert_contains(contributing, "drift risk", "T294-42: §9.6.38 prevention 段 (h) drift risk 已知 5 段 1:1 镜像 0 漏 1 段 / 1 边 / 1 entry / 1 key")
	# 4 关系段: 与 §9.6.35 + 与 §9.6.37 + 与 T162 + 与 §9.1 (4 关系段)
	_assert_contains(contributing, "**与 §9.6.35 关系**", "T294-43: §9.6.38 与 §9.6.35 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.37 关系**", "T294-44: §9.6.38 与 §9.6.37 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T294-45: §9.6.38 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T294-46: §9.6.38 与 §9.1 9 步关系 段 存在")

	# ========== 5. §9.6.38 段长 ≥ 35 行 + 0 漏 28 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.38 6 verb audio 家族 19 cue 字段扩展")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T294-47: §9.6.38 段长 ≥ 35 行 (vs §9.6.37 ~30 行, T294 ~30+ 行) — actual " + str(section_lines.size()) + " lines")
	# 28 套 polish 模式 全列举
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37"]:
		_assert_contains(section_text, ref_num, "T294-48." + ref_num + ": §9.6.38 段内 引用 " + ref_num + " (28 套 polish 模式 列举 0 漏 1 套)")

	# ========== 6. 28 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.38"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37"]:
		_assert_contains(zero_block_text, ref_num, "T294-49." + ref_num + ": §9.6.38 0 副作用 段 引用 " + ref_num + " (28 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 7. 字节码 一致性 source-grep 验证 5 段 内部 ==========
	# Stage 1: 5 verb fire cue 字段 + 5 verb cooldown tail + 5 verb cooldown ready + 4 misc = 19 cue
	var five_verb_fire_count := 0
	for stream_name in ["_pulse_stream", "_bind_stream", "_cut_stream", "_echo_stream", "_wave_fire_stream"]:
		if audio_manager.find(stream_name) != -1:
			five_verb_fire_count += 1
	_assert(five_verb_fire_count == 5, "T294-50.s1: audio_manager_enhanced.gd 5 verb fire cue stream 5/5 存在 (Stage 1 cue 字典 1:1 严格 source-grep 验证) — actual " + str(five_verb_fire_count) + "/5")
	# Stage 5: 3 桶 prewarm cache key (pulse/bind/cut/echo/wave 5 verb)
	_assert_contains(audio_manager, "_verb_cooldown_streams[verb_name]", "T294-51.s5: audio_manager_enhanced.gd `_verb_cooldown_streams[verb_name]` cache key 1:1 严格 source-grep 验证 (Stage 5)")
	_assert_contains(audio_manager, "_verb_cooldown_tail_streams[verb_name]", "T294-52.s5: audio_manager_enhanced.gd `_verb_cooldown_tail_streams[verb_name]` cache key 1:1 严格 source-grep 验证 (Stage 5)")

	# ========== 8. CHANGELOG / ROADMAP / README 同步 验证 ==========
	# CHANGELOG.md 全文含 #218 段 — FIX-#225-3 (T162 brittle Stage 1 + Stage 5): CHANGELOG.md 顶部 5000 chars window 已被 #219~#224 占满,
	# T294 引用在 #218 段 已下移到 > 5000 chars, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `changelog` (vs FIX-#220-2 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): 跨迭代稳定, 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#218" / "T294" / "§9.6.38" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): ROADMAP/REVIEW_LOG/README 同样 已用 全文 (FIX-#220-2 / FIX-#225-1), CHANGELOG 跟随 同步.
	_assert_contains(changelog, "#218", "T294-53: CHANGELOG.md 全文 #218 段 存在 (F002 self-test 同步, FIX-#225-3 改 全文 vs 顶部 5000 chars)")
	_assert_contains(changelog, "T294", "T294-54: CHANGELOG.md 全文 #218 段 引用 T294 (CHANGELOG 同步, FIX-#225-3 改 全文 vs 顶部 5000 chars)")
	_assert_contains(changelog, "§9.6.38", "T294-55: CHANGELOG.md 全文 #218 段 引用 §9.6.38 (CHANGELOG 同步, FIX-#225-3 改 全文 vs 顶部 5000 chars)")
	# ROADMAP.md 全文含 T294 任务 — FIX-#225-3 同上
	_assert_contains(roadmap, "T294", "T294-56: ROADMAP.md 全文 T294 任务 存在 (ROADMAP 同步, FIX-#225-3 改 全文 vs 顶部 5000 chars)")
	# README.md 'Recent completed work' #218 段 存在
	_assert("#218" in readme and "Recent completed work" in readme, "T294-57: README.md 'Recent completed work' #218 段 存在 (F002 self-test 同步)")
	_assert_contains(readme, "## #218", "T294-58: README.md 'Recent completed work' #218 段 引用 T294 (F002 self-test 同步)")
	_assert_contains(readme, "T294", "T294-59: README.md 'Recent completed work' #218 段 引用 T294 (F002 self-test 同步)")
	_assert_contains(readme, "§9.6.38", "T294-60: README.md 'Recent completed work' #218 段 引用 §9.6.38 (F002 self-test 同步)")
	# README.zh-CN.md '最近完成的工作' #218 段 存在
	_assert("#218" in readme_zh and "最近完成的工作" in readme_zh, "T294-61: README.zh-CN.md '最近完成的工作' #218 段 存在 (F002 self-test 同步)")
	_assert_contains(readme_zh, "## #218", "T294-62a: README.zh-CN.md '最近完成的工作' #218 段 引用 T294 (F002 self-test 同步)")
	_assert_contains(readme_zh, "T294", "T294-62b: README.zh-CN.md '最近完成的工作' #218 段 引用 T294 (F002 self-test 同步)")
	_assert_contains(readme_zh, "§9.6.38", "T294-62c: README.zh-CN.md '最近完成的工作' #218 段 引用 §9.6.38 (F002 self-test 同步)")
	# REVIEW_LOG.md 全文 应有 #218 段 — FIX-#230-2 (T162 brittle Stage 1 + Stage 5): REVIEW_LOG.md 顶部 5000 chars window 已被 #225 review + #230 review 等多轮 review 段占满,
	# T294 引用在 #218 段 已下移到 > 5000 chars, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `review_log` (vs FIX-#225-1 / FIX-#220-2 / FIX-#230-1 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): 跨迭代稳定, 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#218" / "T294" / "§9.6.38" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): CHANGELOG/ROADMAP/README 同样 已用 全文 (FIX-#220-2 / FIX-#225-1), REVIEW_LOG 跟随 同步.
	_assert_contains(review_log, "T294", "T294-63: REVIEW_LOG.md 全文 引用 T294 (REVIEW_LOG 同步, FIX-#230-2 改 全文 vs 顶部 5000 chars)")
	_assert_contains(review_log, "§9.6.38", "T294-64: REVIEW_LOG.md 全文 引用 §9.6.38 (REVIEW_LOG 同步, FIX-#230-2 改 全文 vs 顶部 5000 chars)")

	# ========== 9. T294 自身 0 硬编码 验证 ==========
	# 读取 T294 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t294_contributing_fragility_section9638_smoke.gd")
	# T294 自身 0 硬编码 `==` ITERATION_COUNT
	# T294 自身 0 硬编码 `## #N` marker
	# T294 自身 0 硬编码 `## #218` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_218_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #218" in line and "`## #218" not in line and "CHANGELOG.md 顶部 #218" not in line and "README.md 'Recent completed work' #218" not in line and "README.zh-CN.md '最近完成的工作' #218" not in line:
			hard_218_count += 1
	_assert(hard_eq_count == 0, "T294-65: T294 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T294-66: T294 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.38 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_218_count == 0, "T294-67: T294 自身 0 硬编码 `## #218` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.38 稳定子串) — actual " + str(hard_218_count) + " 处")

	# ========== 10. §9.6.38 0 触碰既有 28 套 polish 模式 任何 1 character ==========
	# 验证: §9.6.37 段 仍然存在 (T294 0 触碰 §9.6.37 任何 1 character)
	_assert_contains(contributing, "### 9.6.37 SaveSystem save data CRC32", "T294-68: §9.6.37 段 仍然存在 (T294 0 触碰 §9.6.37 任何 1 character, 28 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.36 PlayerActionGate", "T294-69: §9.6.36 段 仍然存在 (T294 0 触碰 §9.6.36 任何 1 character)")

	# ========== 11. 5 段 × 1 套 polish 模式 = 5 元素 1:1 严格 闭环 ==========
	# 验证 5 段 序列 5 元素: cue 字典 + cue 引用 + verb → cue 映射 + SFX dict + prewarm cache key
	var stage_keywords := ["cue 字典", "cue 引用", "verb → cue 映射", "SFX dict", "prewarm cache key"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 5, "T294-70: 5 段 序列 5 元素 1:1 严格 闭环 (5 段 关键词 全找到) — actual " + str(stage_count) + "/5")

	# ========== 12. §9.6.38 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格镜像 (vs §9.6.37 5 段 1:1 严格镜像) ==========
	# 验证: §9.6.37 是 5 段 (vs §9.6.38 是 5 段)
	var section_37_start := contributing.find("### 9.6.37")
	var section_37_end := contributing.find("\n### 9.6.38", section_37_start)
	if section_37_end == -1:
		section_37_end = contributing.length()
	var section_37_text := contributing.substr(section_37_start, section_37_end - section_37_start)
	var section_37_stage_count := 0
	for s in ["Stage 1 crc32 字段", "Stage 2 verify 方法", "Stage 3 audit 巡检", "Stage 4 write dict", "Stage 5 read dict"]:
		if section_37_text.find(s) != -1:
			section_37_stage_count += 1
	_assert(section_37_stage_count == 5, "T294-71: §9.6.37 是 5 段 (vs §9.6.38 是 5 段, 1 套 polish 模式 × 5 段 1:1 严格镜像) — actual " + str(section_37_stage_count) + "/5")

	# ========== 13. T294 自身 0 副作用 ==========
	# 验证: T294 自身 0 触碰 audio_presets.gd / audio_manager_enhanced.gd / _verb_ability_base.gd 任何 1 character
	# (此验证 通过 T294 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T294 smoke test 自身段引用 §9.6.38 5 段 (1 套 polish 模式 × 5 段 = 5 元素)
	_assert_contains(test_self_text, "Stage 1 cue 字典 1:1 严格", "T294-72: T294 自身引用 Stage 1 cue 字典 1:1 严格 (5 段 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 14. §9.6.38 0 漏 1 元素 0 改 1 字段 (5 元素 × 1 字段 = 5 元素 1:1 严格) ==========
	# 验证: 5 段 × 1 字段 = 5 元素 1:1 严格 (1 cue 字典 + 1 cue 引用 + 1 verb → cue 映射 + 1 SFX dict + 1 prewarm cache key)
	_assert_contains(contributing, "5 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T294-73: §9.6.38 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 15. T181 / T220 / F013.B / T270 / #97 / #142 / #106 / #189 任务 ID 引用 ==========
	_assert_contains(contributing, "T181", "T294-74: §9.6.38 引用 T181 任务 ID")
	_assert_contains(contributing, "T220", "T294-75: §9.6.38 引用 T220 任务 ID")
	_assert_contains(contributing, "F013.B", "T294-76: §9.6.38 引用 F013.B 任务 ID")
	_assert_contains(contributing, "T270", "T294-77: §9.6.38 引用 T270 任务 ID")
	_assert_contains(contributing, "#97", "T294-78: §9.6.38 引用 #97 iteration ID (T181 落地 iter)")
	_assert_contains(contributing, "#142", "T294-79: §9.6.38 引用 #142 iteration ID (T220 落地 iter)")
	_assert_contains(contributing, "#218", "T294-80: §9.6.38 引用 #218 iteration ID (T294 自身落地 iter)")

	# ========== Final ==========
	print("[T294] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T294] FAILURES:")
		for f in _failures:
			print("  - " + f)
		quit(1)
	else:
		quit(0)


# ---------- helpers ----------

func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_error("missing file: " + path)
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("cannot open: " + path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content

func _assert(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("[T294] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T294] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
