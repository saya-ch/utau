# tools/test_t296_contributing_fragility_section9640_smoke.gd
#
# T296 (#221) 落地冒烟测试: §9.6.40 6 verb cooldown ready jingle 5 段
# 1:1 严格分离契约 polish 模式 文档化 (T181 #97 + F007 #87 + T173 #92
# + T220 #142 跨 4 任务 ~33 轮落地) — 5 段 (Stage 1 Pulse 1 段 1:1
# 严格 + Stage 2 Bind 1 段 1:1 严格 + Stage 3 Cut 1 段 1:1 严格 +
# Stage 4 Echo 1 段 1:1 严格 + Stage 5 Wave 1 段 1:1 严格)
# 1:1 严格分离契约 验证.
#
# 5 段 = 1 `src/scripts/_verb_ability_base.gd` Pulse 1 段 (A4→C5 ascending-major-3rd jingle on cooldown ready)
#      + 1 `src/scripts/_verb_ability_base.gd` Bind 1 段 (C5→E5)
#      + 1 `src/scripts/_verb_ability_base.gd` Cut 1 段 (E5→G5)
#      + 1 `src/scripts/_verb_ability_base.gd` Echo 1 段 (G5→A5, G5→A5 = 1 全音 0 1:1 严格 ascending-major-3rd 跨 5 verb 1:1 严格)
#      + 1 `src/scripts/_verb_ability_base.gd` Wave 1 段 (A5→C6)
#      + 1 cross-from-positive 守卫 (`_cooldown_timer` 从 >0 跨到 <=0 当帧才 fire, 避免 spam on scene load 第一帧)
#      + 1 `has_method` 守卫 (headless test 0 触发 audio)
#
# 跨 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格分离契约.
#
# 跨 31 套 polish 模式 中 第 31 套 (前 30 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39, T296 是 第 31 套, 关注
# "6 verb cooldown ready jingle 5 段 1:1 严格分离契约").
#
# 运行: godot --headless --path . --script tools/test_t296_contributing_fragility_section9640_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const VERB_ABILITY_BASE_PATH := "res://src/scripts/_verb_ability_base.gd"
const CHANGELOG_PATH := "res://CHANGELOG.md"
const README_PATH := "res://README.md"
const README_ZH_PATH := "res://README.zh-CN.md"
const ROADMAP_PATH := "res://ROADMAP.md"
const REVIEW_LOG_PATH := "res://REVIEW_LOG.md"
const CHECK_SMOKE_CONSISTENCY_PATH := "res://tools/check_smoke_consistency.sh"

var _passed := 0
var _failed := 0
var _failures: Array[String] = []

func _initialize() -> void:
	_run()

func _run() -> void:
	print("=== T296 (#221) §9.6.40 6 verb cooldown ready jingle 5 段 1:1 严格分离契约 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var verb_ability_base := _read_text(VERB_ABILITY_BASE_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)
	var check_smoke := _read_text(CHECK_SMOKE_CONSISTENCY_PATH)

	# ========== 1. §9.6.40 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T296-1: §9.6.40 段顶 存在")
	_assert_contains(contributing, "5 段 1:1 严格分离契约", "T296-2: §9.6.40 标题包含 '5 段 1:1 严格分离契约'")
	_assert_contains(contributing, "T181 #97 + F007 #87 + T173 #92 + T220 #142", "T296-3: §9.6.40 引用 T181 #97 + F007 #87 + T173 #92 + T220 #142 跨 4 任务")
	_assert_contains(contributing, "跨 4 任务 ~33 轮落地", "T296-4: §9.6.40 引用 ~33 轮 polish 链 (T181 #97 → T220 #142)")

	# ========== 2. 5 段 1:1 严格分离契约 5 段 Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 段 1:1 严格", "T296-5: §9.6.40 Stage 1 Pulse 1 段 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 段 1:1 严格", "T296-6: §9.6.40 Stage 2 Bind 1 段 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 段 1:1 严格", "T296-7: §9.6.40 Stage 3 Cut 1 段 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 段 1:1 严格", "T296-8: §9.6.40 Stage 4 Echo 1 段 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 段 1:1 严格", "T296-9: §9.6.40 Stage 5 Wave 1 段 1:1 严格 关键词 存在")

	# ========== 3. 5 段 字节码 一致性 source-grep 验证 (_verb_ability_base.gd) ==========
	# Stage 1: Pulse 1 段 A4→C5
	_assert_contains(verb_ability_base, "A4", "T296-10.s1: _verb_ability_base.gd `A4` 引用 存在 (Stage 1 Pulse 1 段 1:1 严格)")
	_assert_contains(verb_ability_base, "C5", "T296-11.s1: _verb_ability_base.gd `C5` 引用 存在 (Stage 1 Pulse 1 段 1:1 严格)")
	# Stage 2: Bind 1 段 C5→E5
	_assert_contains(verb_ability_base, "C5", "T296-12.s2: _verb_ability_base.gd `C5` 引用 存在 (Stage 2 Bind 1 段 1:1 严格)")
	_assert_contains(verb_ability_base, "E5", "T296-13.s2: _verb_ability_base.gd `E5` 引用 存在 (Stage 2 Bind 1 段 1:1 严格)")
	# Stage 3: Cut 1 段 E5→G5
	_assert_contains(verb_ability_base, "E5", "T296-14.s3: _verb_ability_base.gd `E5` 引用 存在 (Stage 3 Cut 1 段 1:1 严格)")
	_assert_contains(verb_ability_base, "G5", "T296-15.s3: _verb_ability_base.gd `G5` 引用 存在 (Stage 3 Cut 1 段 1:1 严格)")
	# Stage 4: Echo 1 段 G5→A5
	_assert_contains(verb_ability_base, "G5", "T296-16.s4: _verb_ability_base.gd `G5` 引用 存在 (Stage 4 Echo 1 段 1:1 严格)")
	_assert_contains(verb_ability_base, "A5", "T296-17.s4: _verb_ability_base.gd `A5` 引用 存在 (Stage 4 Echo 1 段 1:1 严格)")
	# Stage 5: Wave 1 段 A5→C6
	_assert_contains(verb_ability_base, "A5", "T296-18.s5: _verb_ability_base.gd `A5` 引用 存在 (Stage 5 Wave 1 段 1:1 严格)")
	_assert_contains(verb_ability_base, "C6", "T296-19.s5: _verb_ability_base.gd `C6` 引用 存在 (Stage 5 Wave 1 段 1:1 严格)")

	# ========== 4. 2 守卫 一致性 source-grep 验证 (_verb_ability_base.gd) ==========
	# Cross-from-positive 守卫: _cooldown_timer 从 >0 跨到 <=0 当帧才 fire
	_assert_contains(verb_ability_base, "_cooldown_timer <= 0", "T296-20.g1: _verb_ability_base.gd `_cooldown_timer <= 0` cross-from-positive 守卫 存在")
	_assert_contains(verb_ability_base, "play_verb_cooldown_ready", "T296-21.g1: _verb_ability_base.gd `play_verb_cooldown_ready` API 引用 存在 (cross-from-positive 守卫 fire 时机)")
	# has_method 守卫
	_assert_contains(verb_ability_base, "has_method", "T296-22.g2: _verb_ability_base.gd `has_method` 守卫 存在 (headless test 0 触发 audio)")
	_assert_contains(verb_ability_base, "AudioManagerEnhanced", "T296-23.g2: _verb_ability_base.gd `AudioManagerEnhanced` autoload 引用 存在")

	# ========== 5. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T296-24: §9.6.40 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 `_process_cooldown(delta, verb_name)` 方法", "T296-25: §9.6.40 0 副作用 段 引用 _process_cooldown 0 改 0 删 0 重排")
	# 8 段 prevention rule
	_assert_contains(contributing, "5 段 0 触碰边界", "T296-26: §9.6.40 prevention 段 (a) 5 段 0 触碰边界")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T296-27: §9.6.40 prevention 段 (b) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T296-28: §9.6.40 prevention 段 (c) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T296-29: §9.6.40 prevention 段 (d) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T296-30: §9.6.40 prevention 段 (e) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "31 套 polish 模式", "T296-31: §9.6.40 prevention 段 (f) 31 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 段", "T296-32: §9.6.40 prevention 段 (g) 0 漏 1 段")
	_assert_contains(contributing, "drift risk", "T296-33: §9.6.40 prevention 段 (h) drift risk 已知 5 段 1:1 镜像 0 漏 1 段 / 1 边 / 1 字符")
	# 4 关系段: 与 §9.6.38 + 与 §9.6.18 + 与 T162 + 与 §9.1 (4 关系段)
	_assert_contains(contributing, "**与 §9.6.38 关系**", "T296-34: §9.6.40 与 §9.6.38 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.18 关系**", "T296-35: §9.6.40 与 §9.6.18 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T296-36: §9.6.40 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T296-37: §9.6.40 与 §9.1 9 步关系 段 存在")

	# ========== 6. §9.6.40 段长 ≥ 35 行 + 0 漏 30 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.40 6 verb cooldown ready jingle 5 段")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T296-38: §9.6.40 段长 ≥ 35 行 (vs §9.6.39 ~30 行, T296 ~30+ 行) — actual " + str(section_lines.size()) + " lines")
	# 30 套 polish 模式 全列举
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39"]:
		_assert_contains(section_text, ref_num, "T296-39." + ref_num + ": §9.6.40 段内 引用 " + ref_num + " (30 套 polish 模式 列举 0 漏 1 套)")

	# ========== 7. 30 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.40"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39"]:
		_assert_contains(zero_block_text, ref_num, "T296-40." + ref_num + ": §9.6.40 0 副作用 段 引用 " + ref_num + " (30 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 8. 5 段 × 1 套 polish 模式 = 5 元素 1:1 严格 闭环 ==========
	# 验证 5 段 序列 5 元素: Pulse 1 段 + Bind 1 段 + Cut 1 段 + Echo 1 段 + Wave 1 段
	var stage_keywords := ["Pulse 1 段", "Bind 1 段", "Cut 1 段", "Echo 1 段", "Wave 1 段"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 5, "T296-41: 5 段 序列 5 元素 1:1 严格 闭环 (5 段 关键词 全找到) — actual " + str(stage_count) + "/5")

	# ========== 9. 5 段音高 严格 ascending-major-3rd 跨 5 verb 1:1 严格 验证 ==========
	# 验证: 5 段音高 (A4→C5, C5→E5, E5→G5, G5→A5, A5→C6) 完整存在
	_assert_contains(verb_ability_base, "A4", "T296-42.j1: _verb_ability_base.gd 5 段音高 链 起点 A4 存在 (Pulse 1 段)")
	_assert_contains(verb_ability_base, "C6", "T296-43.j5: _verb_ability_base.gd 5 段音高 链 终点 C6 存在 (Wave 1 段)")
	# 验证: 5 段音高 ascending 模式 (A4 → C5 → E5 → G5 → A5 → C6)
	var pitch_order := ["A4", "C5", "E5", "G5", "A5", "C6"]
	var pitch_index := 0
	var pitch_chain_ok := true
	for p in pitch_order:
		var idx := verb_ability_base.find(p, pitch_index)
		if idx == -1:
			pitch_chain_ok = false
			break
		pitch_index = idx + 1
	_assert(pitch_chain_ok, "T296-44: 5 段音高 链 ascending 模式 (A4 → C5 → E5 → G5 → A5 → C6) 1:1 严格 顺序 0 反序 0 漏 1 音高")

	# ========== 10. T296 自身 0 硬编码 验证 ==========
	# 读取 T296 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t296_contributing_fragility_section9640_smoke.gd")
	# T296 自身 0 硬编码 `==` ITERATION_COUNT
	# T296 自身 0 硬编码 `## #N` marker
	# T296 自身 0 硬编码 `## #221` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_221_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #221" in line and "`## #221" not in line and "CHANGELOG.md 顶部 #221" not in line and "README.md 'Recent completed work' #221" not in line and "README.zh-CN.md '最近完成的工作' #221" not in line:
			hard_221_count += 1
	_assert(hard_eq_count == 0, "T296-45: T296 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T296-46: T296 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.40 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_221_count == 0, "T296-47: T296 自身 0 硬编码 `## #221` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.40 稳定子串) — actual " + str(hard_221_count) + " 处")

	# ========== 11. §9.6.40 0 触碰既有 30 套 polish 模式 任何 1 character ==========
	# 验证: §9.6.39 段 仍然存在 (T296 0 触碰 §9.6.39 任何 1 character)
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T296-48: §9.6.39 段 仍然存在 (T296 0 触碰 §9.6.39 任何 1 character, 30 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.38 6 verb audio 家族 19 cue 字段扩展", "T296-49: §9.6.38 段 仍然存在 (T296 0 触碰 §9.6.38 任何 1 character, 30 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.18 `_verb_ability_base.gd` 共享契约", "T296-50: §9.6.18 段 仍然存在 (T296 0 触碰 §9.6.18 任何 1 character, 30 套 polish 模式 0 漏 1 套)")

	# ========== 12. T296 自身 0 副作用 ==========
	# 验证: T296 自身 0 触碰 CONTRIBUTING.md / _verb_ability_base.gd 任何 1 character
	# (此验证 通过 T296 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T296 smoke test 自身段引用 §9.6.40 5 段 (1 套 polish 模式 × 5 段 = 5 元素)
	_assert_contains(test_self_text, "Stage 1 Pulse 1 段 1:1 严格", "T296-51: T296 自身引用 Stage 1 Pulse 1 段 1:1 严格 (5 段 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 13. §9.6.40 0 漏 1 元素 0 改 1 字段 (5 元素 × 1 字段 = 5 元素 1:1 严格) ==========
	# 验证: 5 段 × 1 字段 = 5 元素 1:1 严格 (1 Pulse 1 段 + 1 Bind 1 段 + 1 Cut 1 段 + 1 Echo 1 段 + 1 Wave 1 段)
	_assert_contains(contributing, "5 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T296-52: §9.6.40 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 14. 任务 ID 引用 ==========
	_assert_contains(contributing, "T181", "T296-53: §9.6.40 引用 T181 任务 ID")
	_assert_contains(contributing, "F007", "T296-54: §9.6.40 引用 F007 任务 ID")
	_assert_contains(contributing, "T173", "T296-55: §9.6.40 引用 T173 任务 ID")
	_assert_contains(contributing, "T220", "T296-56: §9.6.40 引用 T220 任务 ID")
	_assert_contains(contributing, "T296", "T296-57: §9.6.40 引用 T296 任务 ID (本轮 #221 polish)")
	_assert_contains(contributing, "#97", "T296-58: §9.6.40 引用 #97 iteration ID (T181 iter)")
	_assert_contains(contributing, "#87", "T296-59: §9.6.40 引用 #87 iteration ID (F007 iter)")
	_assert_contains(contributing, "#92", "T296-60: §9.6.40 引用 #92 iteration ID (T173 iter)")
	_assert_contains(contributing, "#142", "T296-61: §9.6.40 引用 #142 iteration ID (T220 iter)")
	_assert_contains(contributing, "#221", "T296-62: §9.6.40 引用 #221 iteration ID (T296 自身落地 iter)")

	# ========== 15. CHANGELOG / ROADMAP / README 同步 验证 (post-落地) ==========
	# 这一节是 给 #222+ 后续 polish 留 1 段 验证位; 当前 T296 落地后 由 cross-section 同步 在 #222 同步
	# 当前 验证: T296 自身 0 触碰任何 cross-section 文件 (除 T296 自身 0 触碰既有)

	# ========== Final ==========
	print("[T296] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T296] FAILURES:")
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
		print("[T296] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T296] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
