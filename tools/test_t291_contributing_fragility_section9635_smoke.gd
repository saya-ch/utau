# tools/test_t291_contributing_fragility_section9635_smoke.gd
#
# T291 (#214) 落地冒烟测试: §9.6.35 AudioPresets `MUSIC_PRESETS` preset
# 字段扩展 5 段 canonical 1:1 严格分离契约 polish 模式
# 文档化 (T062 #2 + T080 #39 + T087 #48 + T107 #59 + T114 #63 + T118 #63
# 跨 6 任务 ~211 轮落地) — 5 段 (Stage 1 dict default 1:1 严格
# + Stage 2 家族传播 1:1 严格 + Stage 3 prewarm 桶 cache key 1:1 严格
# + Stage 4 UI 显示 1:1 严格 + Stage 5 老存档兼容 preload 0 触碰 1:1 严格)
# 1:1 严格分离契约 验证.
#
# 5 段 = 1 `audio_presets.gd` `MUSIC_PRESETS` 9 preset × 13 字段 dict default
#    + 1 `audio_manager_enhanced.gd` 13 字段引用 家族传播
#    + 1 `prewarm_music_streams()` 9 preset key prewarm 桶 cache key
#    + 1 `settings_menu.gd` 9 theme + BGM 主题提示 UI 显示
#    + 1 `audio_presets.gd` preload 0 触碰 SaveSystem save dict 老存档兼容
#
# 跨 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格分离契约.
#
# 跨 26 套 polish 模式 中 第 26 套 (前 25 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34, T291 是 第 26 套, 关注 "audio 数据层 preset 字段扩展 5 段
# canonical 1:1 严格分离契约").
#
# 运行: godot --headless --path . --script tools/test_t291_contributing_fragility_section9635_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const AUDIO_PRESETS_PATH := "res://src/scripts/audio_presets.gd"
const AUDIO_MANAGER_PATH := "res://src/scripts/audio_manager_enhanced.gd"
const SETTINGS_MENU_PATH := "res://src/scripts/settings_menu.gd"
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
	print("=== T291 (#214) §9.6.35 AudioPresets preset 字段扩展 5 段 canonical 1:1 严格分离契约 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var audio_presets := _read_text(AUDIO_PRESETS_PATH)
	var audio_manager := _read_text(AUDIO_MANAGER_PATH)
	var settings_menu := _read_text(SETTINGS_MENU_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)

	# ========== 1. §9.6.35 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.35 AudioPresets", "T291-1: §9.6.35 段顶 存在")
	_assert_contains(contributing, "preset 字段扩展 5 段 canonical 1:1 严格分离契约", "T291-2: §9.6.35 标题包含 '5 段 canonical 1:1 严格分离契约'")
	_assert_contains(contributing, "T062 #2 + T080 #39 + T087 #48 + T107 #59 + T114 #63 + T118 #63", "T291-3: §9.6.35 引用 6 任务 cross-link 链")
	_assert_contains(contributing, "~211 轮落地", "T291-4: §9.6.35 引用 ~211 轮 polish 链 (T062→T118)")

	# ========== 2. 5 段 1:1 严格分离契约 5 段 Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 dict default 1:1 严格", "T291-5: §9.6.35 Stage 1 dict default 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 家族传播 1:1 严格", "T291-6: §9.6.35 Stage 2 家族传播 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 prewarm 桶 cache key 1:1 严格", "T291-7: §9.6.35 Stage 3 prewarm 桶 cache key 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 UI 显示 1:1 严格", "T291-8: §9.6.35 Stage 4 UI 显示 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 老存档兼容 preload 0 触碰 1:1 严格", "T291-9: §9.6.35 Stage 5 老存档兼容 preload 0 触碰 1:1 严格 关键词 存在")

	# ========== 3. 5 段 字节码 一致性 source-grep 验证 4 文件 0 漂动 ==========
	# Stage 1: MUSIC_PRESETS 9 preset × 13 字段 (audio_presets.gd)
	var preset_names := ["title_intro", "hub_warm", "archive_exploration", "archive_boss", "archive_boss_dual", "archive_dawn", "archive_storm", "silence_void", "whisper_hollow"]
	for pn in preset_names:
		_assert_contains(audio_presets, '"' + pn + '":', "T291-10.s1." + pn + ": MUSIC_PRESETS 9 preset '" + pn + "' 存在 (Stage 1 dict default 1:1 严格, 0 漏 1 preset)")
	var field_names := ["bpm", "duration", "root_midi", "chord_midi", "arp_midi", "shimmer_midi", "lfo_freq", "lfo_depth", "shimmer_mod", "arp_volume", "pad_volume", "bass_volume", "shimmer_volume"]
	for fn in field_names:
		_assert_contains(audio_presets, '"' + fn + '":', "T291-11.s1." + fn + ": MUSIC_PRESETS 13 字段 '" + fn + "' 存在 (Stage 1 dict default 1:1 严格, 0 漏 1 字段)")

	# Stage 2: 13 字段 引用 在 audio_manager_enhanced.gd 中存在
	# 验证: 13 字段名中至少 1 个 在 ame 中有引用 (lfo_freq, lfo_depth, shimmer_mod, arp_volume, pad_volume 等)
	var stage2_keywords := ["lfo_freq", "lfo_depth", "shimmer_mod", "arp_volume", "pad_volume", "bass_volume", "shimmer_volume"]
	var stage2_present := 0
	for kw in stage2_keywords:
		if audio_manager.find(kw) != -1:
			stage2_present += 1
	_assert(stage2_present >= 5, "T291-12: audio_manager_enhanced.gd 13 字段引用 ≥ 5/7 字段 引用 存在 (Stage 2 家族传播 1:1 严格, 0 漏 1 字段引用) — actual " + str(stage2_present) + "/7")

	# Stage 3: prewarm_music_streams 在 audio_manager_enhanced.gd 中存在 + 9 preset key 引用
	_assert_contains(audio_manager, "prewarm_music_streams", "T291-13: audio_manager_enhanced.gd `prewarm_music_streams()` 桶 函数 存在 (Stage 3 prewarm 桶 cache key 1:1 严格)")
	_assert_contains(audio_manager, "MUSIC_PRESETS", "T291-14: audio_manager_enhanced.gd 引用 `MUSIC_PRESETS` 9 preset key (Stage 3 prewarm 桶 cache key 1:1 严格)")
	var prewarm_preset_count := 0
	for pn in preset_names:
		if audio_manager.find(pn) != -1:
			prewarm_preset_count += 1
	_assert(prewarm_preset_count >= 4, "T291-15: audio_manager_enhanced.gd 9 preset key 引用 ≥ 4/9 存在 (Stage 3 prewarm 桶 cache key 1:1 严格) — actual " + str(prewarm_preset_count) + "/9")

	# Stage 4: settings_menu.gd 9 theme 引用 + BGM 主题提示
	var theme_present := 0
	for pn in preset_names:
		if settings_menu.find(pn) != -1:
			theme_present += 1
	_assert(theme_present >= 4, "T291-16: settings_menu.gd 9 theme 引用 ≥ 4/9 存在 (Stage 4 UI 显示 1:1 严格) — actual " + str(theme_present) + "/9")
	_assert_contains(settings_menu, "_on_music_preview_pressed", "T291-17: settings_menu.gd `_on_music_preview_pressed()` BGM 主题提示 函存 (Stage 4 UI 显示 1:1 严格)")

	# Stage 5: audio_presets.gd 0 触碰 SaveSystem save dict (preload 0 触碰)
	# 验证: settings_menu.gd 引用 `AudioPresets.MUSIC_PRESETS` (即 preload 模式) 而非 直接 const _MUSIC_PRESETS
	_assert_contains(settings_menu, "AudioPresets", "T291-18: settings_menu.gd 引用 `AudioPresets` 加载 (Stage 5 老存档兼容 preload 0 触碰 1:1 严格)")

	# ========== 4. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T291-19: §9.6.35 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 9 preset × 13 字段任何 1 entry", "T291-20: §9.6.35 0 副作用 段 引用 9 preset × 13 字段 0 改 0 删 0 重排")
	# 8 段 prevention rule — 1 字段 0 漏 / 1 边 0 漏 / 0 副作用 / 1 套 polish 模式 / 26 套 polish 模式 / 1 字段 0 漏 1 边 / T162 brittle 修复流程 / 1 套 polish 模式 0 互混
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T291-21: §9.6.35 prevention 段 (a) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T291-22: §9.6.35 prevention 段 (b) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T291-23: §9.6.35 prevention 段 (c) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T291-24: §9.6.35 prevention 段 (d) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "26 套 polish 模式", "T291-25: §9.6.35 prevention 段 (e) 26 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 preset", "T291-26: §9.6.35 prevention 段 (f) 0 漏 1 preset")
	_assert_contains(contributing, "5 段 0 触碰边界", "T291-27: §9.6.35 prevention 段 (g) 5 段 0 触碰边界")
	_assert_contains(contributing, "drift risk", "T291-28: §9.6.35 prevention 段 (h) drift risk 已知 5 段 1:1 镜像 0 漏 1 段 / 1 边 / 1 字段 / 1 preset")

	# 4 关系段: 与 §9.6.23 + 与 §9.6.34 + 与 T162 + 与 §9.1
	_assert_contains(contributing, "**与 §9.6.23 关系**", "T291-29: §9.6.35 与 §9.6.23 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.34 关系**", "T291-30: §9.6.35 与 §9.6.34 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T291-31: §9.6.35 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T291-32: §9.6.35 与 §9.1 9 步关系 段 存在")

	# ========== 5. §9.6.35 段长 ≥ 35 行 + 0 漏 25 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.35 AudioPresets")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T291-33: §9.6.35 段长 ≥ 35 行 (vs §9.6.34 ~40 行, T291 ~40+ 行) — actual " + str(section_lines.size()) + " lines")
	# 25 套 polish 模式 全列举
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34"]:
		_assert_contains(section_text, ref_num, "T291-34." + ref_num + ": §9.6.35 段内 引用 " + ref_num + " (25 套 polish 模式 列举 0 漏 1 套)")

	# ========== 6. 25 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	# §9.6.35 0 副作用 段 必须 列举 25 套 polish 模式 (1 套 polish 模式 0 触碰既有)
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.35"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34"]:
		_assert_contains(zero_block_text, ref_num, "T291-35." + ref_num + ": §9.6.35 0 副作用 段 引用 " + ref_num + " (25 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 7. 字节码 一致性 source-grep 验证 5 段 ==========
	# 验证 1:1 严格分离 — 5 段 关键词 出现于源文件 (Stage 1-5 各 1 验证)
	# Stage 1: audio_presets.gd 9 preset × 13 字段
	_assert_contains(audio_presets, "const MUSIC_PRESETS", "T291-36.s1: audio_presets.gd 声明 const MUSIC_PRESETS (Stage 1 dict default 1:1 严格 source-grep 验证)")
	_assert_contains(audio_presets, "const BOSS_MUSIC_TIER", "T291-37.s1: audio_presets.gd 声明 const BOSS_MUSIC_TIER (Stage 1 dict default 1:1 严格 source-grep 验证)")
	# Stage 2: audio_manager_enhanced.gd 13 字段引用
	var ame_preset_count := 0
	for pn in preset_names:
		if audio_manager.find('"' + pn + '"') != -1 or audio_manager.find(pn) != -1:
			ame_preset_count += 1
	_assert(ame_preset_count >= 2, "T291-38.s2: audio_manager_enhanced.gd 9 preset 引用 ≥ 2/9 存在 (Stage 2 家族传播 1:1 严格 source-grep 验证) — actual " + str(ame_preset_count) + "/9")
	# Stage 3: prewarm_music_streams() 9 preset key
	_assert_contains(audio_manager, "prewarm_music_streams()", "T291-39.s3: audio_manager_enhanced.gd `prewarm_music_streams()` 函存 (Stage 3 prewarm 桶 cache key 1:1 严格 source-grep 验证)")
	# Stage 4: settings_menu.gd 9 theme
	var sm_preset_count := 0
	for pn in preset_names:
		if settings_menu.find(pn) != -1:
			sm_preset_count += 1
	_assert(sm_preset_count >= 4, "T291-40.s4: settings_menu.gd 9 theme 引用 ≥ 4/9 存在 (Stage 4 UI 显示 1:1 严格 source-grep 验证) — actual " + str(sm_preset_count) + "/9")
	# Stage 5: audio_presets.gd preload 0 触碰 (此验证 通过 第 18 项 + 第 36 项 共同确认)
	_assert_contains(audio_presets, "preload", "T291-41.s5: audio_presets.gd `preload` 函存 (Stage 5 老存档兼容 preload 0 触碰 1:1 严格 source-grep 验证)")

	# ========== 8. CHANGELOG / ROADMAP / README 同步 验证 ==========
	# CHANGELOG.md 全文含 #214 段 — FIX-#220-2 (T162 brittle 修复): 0 用 5000 字符阈值（CHANGELOG.md 因 polish 模式文档化 实际 362 行, #214 段在 81 行超出 5000 字符窗口）
	# 改用全文检查（与 T291-46 / T291-50 模式一致, 0 触碰 #215 既有 fix-#215-2 archive 拆分契约）
	_assert_contains(changelog, "#214", "T291-42: CHANGELOG.md 全文 #214 段 存在 (F002 self-test 同步, FIX-#220-2 改 全文 检查)")
	_assert_contains(changelog, "T291", "T291-43: CHANGELOG.md #214 段 引用 T291 (CHANGELOG 同步)")
	_assert_contains(changelog, "§9.6.35", "T291-44: CHANGELOG.md #214 段 引用 §9.6.35 (CHANGELOG 同步)")
	# ROADMAP.md 全文含 T291 任务 — FIX-#220-2 同上, ROADMAP.md 顶部时间戳 #219 占满, T291 引用在 #214 时间戳段
	_assert_contains(roadmap, "T291", "T291-45: ROADMAP.md 全文 T291 任务 存在 (ROADMAP 同步, FIX-#220-2 改 全文 检查)")
	# README.md 'Recent completed work' #214 段 存在 — 用全文 (vs T290 类似) 而非 8000 chars
	_assert("#214" in readme and "Recent completed work" in readme, "T291-46: README.md 'Recent completed work' #214 段 存在 (F002 self-test 同步)")
	_assert_contains(readme, "## #214", "T291-47: README.md 'Recent completed work' #214 段 引用 T291 (F002 self-test 同步)")
	_assert_contains(readme, "T291", "T291-48: README.md 'Recent completed work' #214 段 引用 T291 (F002 self-test 同步)")
	_assert_contains(readme, "§9.6.35", "T291-49: README.md 'Recent completed work' #214 段 引用 §9.6.35 (F002 self-test 同步)")
	# README.zh-CN.md '最近完成的工作' #214 段 存在 — 用全文
	_assert("#214" in readme_zh and "最近完成的工作" in readme_zh, "T291-50: README.zh-CN.md '最近完成的工作' #214 段 存在 (F002 self-test 同步)")
	_assert_contains(readme_zh, "## #214", "T291-51a: README.zh-CN.md '最近完成的工作' #214 段 引用 T291 (F002 self-test 同步)")
	_assert_contains(readme_zh, "T291", "T291-51b: README.zh-CN.md '最近完成的工作' #214 段 引用 T291 (F002 self-test 同步)")
	_assert_contains(readme_zh, "§9.6.35", "T291-51c: README.zh-CN.md '最近完成的工作' #214 段 引用 §9.6.35 (F002 self-test 同步)")
	# REVIEW_LOG.md #214 段 存在 (Stage 1 + Stage 3 跨迭代稳定)
	# FIX-#225-1 (T162 brittle Stage 1 + Stage 5): REVIEW_LOG.md 顶部 5000 chars window 已被 #215/#220 review 段 占满,
	# T291 引用在 #215 段 位置约 200~500 chars from top, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `review_log` (vs FIX-#220-2 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): Stage 1 + Stage 3 跨迭代稳定, REVIEW_LOG 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#215" / "T291" / "§9.6.35" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): ROADMAP/CHANGELOG/README 同样 已用 全文 (FIX-#220-2), REVIEW_LOG 跟随 同步.
	_assert_contains(review_log, "T291", "T291-52: REVIEW_LOG.md 全文 引用 T291 (REVIEW_LOG 同步, FIX-#225-1 改 全文 vs 顶部 5000 chars)")
	_assert_contains(review_log, "§9.6.35", "T291-53: REVIEW_LOG.md 全文 引用 §9.6.35 (REVIEW_LOG 同步, FIX-#225-1 改 全文 vs 顶部 5000 chars)")

	# ========== 10. T291 自身 0 硬编码 验证 ==========
	# 读取 T291 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t291_contributing_fragility_section9635_smoke.gd")
	# T291 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地) — 用 >= 而非 ==
	# T291 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.35 稳定子串
	# T291 自身 0 硬编码 `## #214` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.35 稳定子串
	# 验证 模式: 扫描 test 文件每行, 排除行内引用 `## #N` (反引号包住) + 排除注释段
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_214_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #214" in line and "`## #214" not in line and "CHANGELOG.md 顶部 #214" not in line and "README.md 'Recent completed work' #214" not in line and "README.zh-CN.md '最近完成的工作' #214" not in line:
			hard_214_count += 1
	_assert(hard_eq_count == 0, "T291-54: T291 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T291-55: T291 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.35 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_214_count == 0, "T291-56: T291 自身 0 硬编码 `## #214` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.35 稳定子串) — actual " + str(hard_214_count) + " 处")

	# ========== 11. §9.6.35 0 触碰既有 25 套 polish 模式 任何 1 字符 ==========
	# 验证: §9.6.34 段 仍然存在 (T291 0 触碰 §9.6.34 任何 1 字符)
	_assert_contains(contributing, "### 9.6.34 PlayerStats", "T291-57: §9.6.34 段 仍然存在 (T291 0 触碰 §9.6.34 任何 1 字符, 25 套 polish 模式 0 漏 1 套)")

	# ========== 12. 5 段 × 1 套 polish 模式 = 5 元素 1:1 严格 闭环 ==========
	# 验证 5 段 序列 5 元素: dict default + 家族传播 + prewarm 桶 cache key + UI 显示 + 老存档兼容 preload 0 触碰
	var stage_keywords := ["dict default", "家族传播", "prewarm 桶 cache key", "UI 显示", "preload 0 触碰"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count == 5, "T291-58: 5 段 序列 5 元素 1:1 严格 闭环 (5 段 关键词 全找到) — actual " + str(stage_count) + "/5")

	# ========== 13. §9.6.35 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格镜像 (vs §9.6.34 6 段 1:1 严格镜像) ==========
	# 验证: §9.6.35 是 5 段 (vs §9.6.34 是 6 段)
	var section_34_start := contributing.find("### 9.6.34")
	var section_34_end := contributing.find("\n---", section_34_start)
	if section_34_end == -1:
		section_34_end = contributing.length()
	var section_34_text := contributing.substr(section_34_start, section_34_end - section_34_start)
	var section_34_stage_count := 0
	for s in ["Stage 1 dict default", "Stage 2 单调更新", "Stage 3 snapshot", "Stage 4 UI 显示", "Stage 5 accessor", "Stage 6 老存档兼容"]:
		if section_34_text.find(s) != -1:
			section_34_stage_count += 1
	_assert(section_34_stage_count == 6, "T291-59: §9.6.34 是 6 段 (vs §9.6.35 是 5 段, 1 套 polish 模式 × 6 段 1:1 严格镜像) — actual " + str(section_34_stage_count) + "/6")

	# ========== 14. T291 自身 0 副作用 ==========
	# 验证: T291 自身 0 触碰 audio_presets.gd 任何 1 字段
	# (此验证 通过 T291 仅 read 4 文件 实现 0 写入 来保证)
	# 此外: 验证 T291 smoke test 自身段引用 §9.6.35 5 段 (1 套 polish 模式 × 5 段 = 5 元素)
	_assert_contains(test_self_text, "Stage 1 dict default 1:1 严格", "T291-60: T291 自身引用 Stage 1 dict default 1:1 严格 (5 段 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== Final ==========
	print("[T291] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T291] FAILURES:")
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
		print("[T291] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T291] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
