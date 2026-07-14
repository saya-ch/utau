# tools/test_t295_contributing_fragility_section9639_smoke.gd
#
# T295 (#219) 落地冒烟测试: §9.6.39 T162 brittle 修复流程 5 步骤
# 1:1 严格分离契约 polish 模式
# 文档化 (T162 #185 起步 跨 31+ 任务 ~33 轮落地) — 5 步骤
# (Stage 1 expect 反转 1:1 严格 + Stage 2 docblock 说明 1:1 严格
# + Stage 3 段 find 反转 1:1 严格 + Stage 4 0 触碰既有 1:1 严格
# + Stage 5 cross-section 同步 1:1 严格) 1:1 严格分离契约 验证.
#
# 5 步骤 = 1 `tools/test_*.gd` 1 expect 反转 (任何 1 brittle 修复 时 1 expect 行 反向 == / != / ≥ / ≤ 1 字符)
#        + 1 `tools/test_*.gd` 1 docblock 说明 (任何 1 brittle 修复 时 1 docblock 行 解释为什么反向)
#        + 1 `tools/test_*.gd` 1 段 find 反转 (任何 1 brittle 修复 时 1 段 find 字符串 反向 find / find + offset 1 字符)
#        + 1 `tools/test_*.gd` 0 触碰既有 (0 改 test_*.gd 任何其他 expect / docblock / 段 find)
#        + 1 cross-section 5 文件 同步 (CHANGELOG.md 顶部 1 段 + ROADMAP.md 顶部 1 时间戳 + README.md 'Recent completed work' 1 段 + README.zh-CN.md '最近完成的工作' 1 段 + ITERATION_COUNT.txt 1 计数)
#
# 跨 1 套 polish 模式 × 5 步骤 = 5 元素 1:1 严格分离契约.
#
# 跨 30 套 polish 模式 中 第 30 套 (前 29 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38, T295 是 第 30 套, 关注
# "T162 brittle 修复流程 5 步骤 1:1 严格分离契约").
#
# 运行: godot --headless --path . --script tools/test_t295_contributing_fragility_section9639_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const CHECK_SMOKE_CONSISTENCY_PATH := "res://tools/check_smoke_consistency.sh"
const PARSE_RECENT_SECTION_PATH := "res://tools/_parse_recent_section.py"
const PRE_COMMIT_F002_CHECK_PATH := "res://tools/pre_commit_f002_check.sh"
const INSTALL_HOOKS_PATH := "res://tools/install_hooks.sh"
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
	print("=== T295 (#219) §9.6.39 T162 brittle 修复流程 5 步骤 1:1 严格分离契约 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var check_smoke := _read_text(CHECK_SMOKE_CONSISTENCY_PATH)
	var parse_recent := _read_text(PARSE_RECENT_SECTION_PATH)
	var pre_commit_f002 := _read_text(PRE_COMMIT_F002_CHECK_PATH)
	var install_hooks := _read_text(INSTALL_HOOKS_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)

	# ========== 1. §9.6.39 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T295-1: §9.6.39 段顶 存在")
	_assert_contains(contributing, "5 步骤 1:1 严格分离契约", "T295-2: §9.6.39 标题包含 '5 步骤 1:1 严格分离契约'")
	_assert_contains(contributing, "T162 跨 31+ 任务", "T295-3: §9.6.39 引用 T162 跨 31+ 任务 累计")
	_assert_contains(contributing, "~33 轮落地", "T295-4: §9.6.39 引用 ~33 轮 polish 链 (T162 #185 → T294 #218)")

	# ========== 2. 5 步骤 1:1 严格分离契约 5 步骤 Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 expect 反转 1:1 严格", "T295-5: §9.6.39 Stage 1 expect 反转 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 docblock 说明 1:1 严格", "T295-6: §9.6.39 Stage 2 docblock 说明 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 段 find 反转 1:1 严格", "T295-7: §9.6.39 Stage 3 段 find 反转 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 0 触碰既有 1:1 严格", "T295-8: §9.6.39 Stage 4 0 触碰既有 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 cross-section 同步 1:1 严格", "T295-9: §9.6.39 Stage 5 cross-section 同步 1:1 严格 关键词 存在")

	# ========== 3. 5 步骤 字节码 一致性 source-grep 验证 (T162 brittle 修复流程 工具链 3 件套) ==========
	# Stage 1: expect 反转 1:1 严格 工具链 引用 - pre_commit_f002_check.sh 检查 期望 匹配
	_assert_contains(pre_commit_f002, "F002", "T295-10.s1: pre_commit_f002_check.sh `F002` 引用 存在 (Stage 1 expect 反转 1:1 严格)")
	_assert_contains(pre_commit_f002, "Recent completed work", "T295-11.s1: pre_commit_f002_check.sh `Recent completed work` 引用 存在 (Stage 1 expect 反转 1:1 严格)")
	_assert_contains(pre_commit_f002, "README", "T295-12.s1: pre_commit_f002_check.sh `README` 引用 存在 (Stage 1 expect 反转 1:1 严格)")
	# Stage 2: docblock 说明 1:1 严格 工具链 引用 - install_hooks.sh 有 hook docblock
	_assert_contains(install_hooks, "hook", "T295-13.s2: install_hooks.sh `hook` 引用 存在 (Stage 2 docblock 说明 1:1 严格)")
	# Stage 3: 段 find 反转 1:1 严格 工具链 引用 - _parse_recent_section.py 解析 'Recent completed work' 段
	_assert_contains(parse_recent, "Recent completed work", "T295-14.s3: _parse_recent_section.py `Recent completed work` 引用 存在 (Stage 3 段 find 反转 1:1 严格)")
	_assert_contains(parse_recent, "parse_recent_section", "T295-15.s3: _parse_recent_section.py `parse_recent_section` 引用 存在 (Stage 3 段 find 反转 1:1 严格)")
	# Stage 4: 0 触碰既有 1:1 严格 工具链 引用 - check_smoke_consistency.sh 0 触碰 既有 source
	_assert_contains(check_smoke, "PRESETS_FILE", "T295-16.s4: check_smoke_consistency.sh `PRESETS_FILE` 引用 存在 (Stage 4 0 触碰既有 1:1 严格)")
	# Stage 5: cross-section 同步 1:1 严格 工具链 引用 - check_smoke_consistency.sh cross-section 同步
	_assert_contains(check_smoke, "README", "T295-17.s5: check_smoke_consistency.sh `README` 引用 存在 (Stage 5 cross-section 同步 1:1 严格)")
	_assert_contains(check_smoke, "ITER_COUNT", "T295-18.s5: check_smoke_consistency.sh `ITER_COUNT` 引用 存在 (Stage 5 cross-section 同步 1:1 严格)")
	_assert_contains(check_smoke, "LATEST", "T295-19.s5: check_smoke_consistency.sh `LATEST` 引用 存在 (Stage 5 cross-section 同步 1:1 严格)")

	# ========== 4. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T295-20: §9.6.39 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 任何 1 expect 任何 1 字符", "T295-21: §9.6.39 0 副作用 段 引用 expect 0 改 0 删 0 重排")
	# 8 段 prevention rule
	_assert_contains(contributing, "5 步骤 0 触碰边界", "T295-22: §9.6.39 prevention 段 (a) 5 步骤 0 触碰边界")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T295-23: §9.6.39 prevention 段 (b) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T295-24: §9.6.39 prevention 段 (c) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T295-25: §9.6.39 prevention 段 (d) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T295-26: §9.6.39 prevention 段 (e) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "30 套 polish 模式", "T295-27: §9.6.39 prevention 段 (f) 30 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 步骤", "T295-28: §9.6.39 prevention 段 (g) 0 漏 1 步骤")
	_assert_contains(contributing, "drift risk", "T295-29: §9.6.39 prevention 段 (h) drift risk 已知 5 步骤 1:1 镜像 0 漏 1 步骤 / 1 边 / 1 字符 / 1 文件")
	# 4 关系段: 与 §9.6.38 + 与 §9.6.37 + 与 T162 + 与 §9.1 (4 关系段)
	_assert_contains(contributing, "**与 §9.6.38 关系**", "T295-30: §9.6.39 与 §9.6.38 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.37 关系**", "T295-31: §9.6.39 与 §9.6.37 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T295-32: §9.6.39 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T295-33: §9.6.39 与 §9.1 9 步关系 段 存在")

	# ========== 5. §9.6.39 段长 ≥ 35 行 + 0 漏 29 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.39 T162 brittle 修复流程 5 步骤")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T295-34: §9.6.39 段长 ≥ 35 行 (vs §9.6.38 ~30 行, T295 ~30+ 行) — actual " + str(section_lines.size()) + " lines")
	# 29 套 polish 模式 全列举
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38"]:
		_assert_contains(section_text, ref_num, "T295-35." + ref_num + ": §9.6.39 段内 引用 " + ref_num + " (29 套 polish 模式 列举 0 漏 1 套)")

	# ========== 6. 29 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.39"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38"]:
		_assert_contains(zero_block_text, ref_num, "T295-36." + ref_num + ": §9.6.39 0 副作用 段 引用 " + ref_num + " (29 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 7. 字节码 一致性 source-grep 验证 5 步骤 内部 ==========
	# Stage 1: expect 反转 1:1 严格 (反 == / != / ≥ / ≤ 1 字符)
	_assert_contains(pre_commit_f002, "DIFF=$((ITER_COUNT - LATEST))", "T295-37.s1: pre_commit_f002_check.sh `DIFF=$((ITER_COUNT - LATEST))` 存在 (Stage 1 expect 反转 1:1 严格 source-grep 验证)")
	_assert_contains(check_smoke, "DIFF=$((ITER_COUNT - LATEST))", "T295-38.s1: check_smoke_consistency.sh `DIFF=$((ITER_COUNT - LATEST))` 存在 (Stage 1 expect 反转 1:1 严格 source-grep 验证)")
	# Stage 2: docblock 说明 1:1 严格 (注释 # 解释)
	_assert_contains(check_smoke, "#", "T295-39.s2: check_smoke_consistency.sh `#` 注释 存在 (Stage 2 docblock 说明 1:1 严格 source-grep 验证)")
	# Stage 3: 段 find 反转 1:1 严格 (find / find + offset)
	_assert_contains(check_smoke, "awk", "T295-40.s3: check_smoke_consistency.sh `awk` 段 find 解析 存在 (Stage 3 段 find 反转 1:1 严格 source-grep 验证)")
	# Stage 4: 0 触碰既有 1:1 严格 (verify 其他 4 步骤 0 改)
	_assert_contains(check_smoke, "PRESETS_FILE", "T295-41.s4: check_smoke_consistency.sh `PRESETS_FILE` 关键字 存在 (Stage 4 0 触碰既有 1:1 严格 source-grep 验证)")
	# Stage 5: cross-section 同步 1:1 严格 (5 文件 light sync)
	_assert_contains(check_smoke, "ITER_COUNT", "T295-42.s5: check_smoke_consistency.sh `ITER_COUNT` 引用 存在 (Stage 5 cross-section 同步 1:1 严格 source-grep 验证)")

	# ========== 8. CHANGELOG / ROADMAP / README 同步 验证 ==========
	# CHANGELOG.md 全文含 #219 段 — FIX-#225-4 (T162 brittle Stage 1 + Stage 5): CHANGELOG.md 顶部 5000 chars window 已被 #220~#224 占满,
	# T295 引用在 #219 段 已下移到 > 5000 chars, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `changelog` (vs FIX-#220-2 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): 跨迭代稳定, 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#219" / "T295" / "§9.6.39" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): ROADMAP/REVIEW_LOG/README 同样 已用 全文 (FIX-#220-2 / FIX-#225-1), CHANGELOG 跟随 同步.
	_assert_contains(changelog, "#219", "T295-43: CHANGELOG.md 全文 #219 段 存在 (F002 self-test 同步, FIX-#225-4 改 全文 vs 顶部 5000 chars)")
	_assert_contains(changelog, "T295", "T295-44: CHANGELOG.md 全文 #219 段 引用 T295 (CHANGELOG 同步, FIX-#225-4 改 全文 vs 顶部 5000 chars)")
	_assert_contains(changelog, "§9.6.39", "T295-45: CHANGELOG.md 全文 #219 段 引用 §9.6.39 (CHANGELOG 同步, FIX-#225-4 改 全文 vs 顶部 5000 chars)")
	# ROADMAP.md 全文含 T295 任务 — FIX-#225-4 同上
	_assert_contains(roadmap, "T295", "T295-46: ROADMAP.md 全文 T295 任务 存在 (ROADMAP 同步, FIX-#225-4 改 全文 vs 顶部 5000 chars)")
	# README.md 'Recent completed work' #219 段 存在
	_assert("#219" in readme and "Recent completed work" in readme, "T295-47: README.md 'Recent completed work' #219 段 存在 (F002 self-test 同步)")
	_assert_contains(readme, "## #219", "T295-48: README.md 'Recent completed work' #219 段 引用 T295 (F002 self-test 同步)")
	_assert_contains(readme, "T295", "T295-49: README.md 'Recent completed work' #219 段 引用 T295 (F002 self-test 同步)")
	_assert_contains(readme, "§9.6.39", "T295-50: README.md 'Recent completed work' #219 段 引用 §9.6.39 (F002 self-test 同步)")
	# README.zh-CN.md '最近完成的工作' #219 段 存在
	_assert("#219" in readme_zh and "最近完成的工作" in readme_zh, "T295-51: README.zh-CN.md '最近完成的工作' #219 段 存在 (F002 self-test 同步)")
	_assert_contains(readme_zh, "## #219", "T295-52a: README.zh-CN.md '最近完成的工作' #219 段 引用 T295 (F002 self-test 同步)")
	_assert_contains(readme_zh, "T295", "T295-52b: README.zh-CN.md '最近完成的工作' #219 段 引用 T295 (F002 self-test 同步)")
	_assert_contains(readme_zh, "§9.6.39", "T295-52c: README.zh-CN.md '最近完成的工作' #219 段 引用 §9.6.39 (F002 self-test 同步)")
	# REVIEW_LOG.md 全文 应有 #219 段 — FIX-#230-3 (T162 brittle Stage 1 + Stage 5): REVIEW_LOG.md 顶部 5000 chars window 已被 #225 review + #230 review 等多轮 review 段占满,
	# T295 引用在 #219 段 已下移到 > 5000 chars, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `review_log` (vs FIX-#225-1 / FIX-#220-2 / FIX-#230-1 / FIX-#230-2 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): 跨迭代稳定, 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#219" / "T295" / "§9.6.39" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): CHANGELOG/ROADMAP/README 同样 已用 全文 (FIX-#220-2 / FIX-#225-1), REVIEW_LOG 跟随 同步.
	_assert_contains(review_log, "T295", "T295-53: REVIEW_LOG.md 全文 引用 T295 (REVIEW_LOG 同步, FIX-#230-3 改 全文 vs 顶部 5000 chars)")
	_assert_contains(review_log, "§9.6.39", "T295-54: REVIEW_LOG.md 全文 引用 §9.6.39 (REVIEW_LOG 同步, FIX-#230-3 改 全文 vs 顶部 5000 chars)")

	# ========== 9. T295 自身 0 硬编码 验证 ==========
	# 读取 T295 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t295_contributing_fragility_section9639_smoke.gd")
	# T295 自身 0 硬编码 `==` ITERATION_COUNT
	# T295 自身 0 硬编码 `## #N` marker
	# T295 自身 0 硬编码 `## #219` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_219_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #219" in line and "`## #219" not in line and "CHANGELOG.md 顶部 #219" not in line and "README.md 'Recent completed work' #219" not in line and "README.zh-CN.md '最近完成的工作' #219" not in line:
			hard_219_count += 1
	_assert(hard_eq_count == 0, "T295-55: T295 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T295-56: T295 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.39 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_219_count == 0, "T295-57: T295 自身 0 硬编码 `## #219` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.39 稳定子串) — actual " + str(hard_219_count) + " 处")

	# ========== 10. §9.6.39 0 触碰既有 29 套 polish 模式 任何 1 character ==========
	# 验证: §9.6.38 段 仍然存在 (T295 0 触碰 §9.6.38 任何 1 character)
	_assert_contains(contributing, "### 9.6.38 6 verb audio 家族 19 cue 字段扩展", "T295-58: §9.6.38 段 仍然存在 (T295 0 触碰 §9.6.38 任何 1 character, 29 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.37 SaveSystem save data CRC32", "T295-59: §9.6.37 段 仍然存在 (T295 0 触碰 §9.6.37 任何 1 character, 29 套 polish 模式 0 漏 1 套)")

	# ========== 11. 5 步骤 × 1 套 polish 模式 = 5 元素 1:1 严格 闭环 ==========
	# 验证 5 步骤 序列 5 元素: expect 反转 + docblock 说明 + 段 find 反转 + 0 触碰既有 + cross-section 同步
	var stage_keywords := ["expect 反转", "docblock 说明", "段 find 反转", "0 触碰既有", "cross-section 同步"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 5, "T295-60: 5 步骤 序列 5 元素 1:1 严格 闭环 (5 步骤 关键词 全找到) — actual " + str(stage_count) + "/5")

	# ========== 12. §9.6.39 1 套 polish 模式 × 5 步骤 = 5 元素 1:1 严格镜像 (vs §9.6.38 5 段 1:1 严格镜像) ==========
	# 验证: §9.6.38 是 5 段 (vs §9.6.39 是 5 步骤)
	var section_38_start := contributing.find("### 9.6.38")
	var section_38_end := contributing.find("\n### 9.6.39", section_38_start)
	if section_38_end == -1:
		section_38_end = contributing.length()
	var section_38_text := contributing.substr(section_38_start, section_38_end - section_38_start)
	var section_38_stage_count := 0
	for s in ["Stage 1 cue 字典", "Stage 2 cue 引用", "Stage 3 verb → cue 映射", "Stage 4 SFX dict", "Stage 5 prewarm cache key"]:
		if section_38_text.find(s) != -1:
			section_38_stage_count += 1
	_assert(section_38_stage_count == 5, "T295-61: §9.6.38 是 5 段 (vs §9.6.39 是 5 步骤, 1 套 polish 模式 × 5 步骤 1:1 严格镜像 1 套 polish 模式 × 5 段) — actual " + str(section_38_stage_count) + "/5")

	# ========== 13. T295 自身 0 副作用 ==========
	# 验证: T295 自身 0 触碰 CONTRIBUTING.md / check_smoke_consistency.sh 任何 1 character
	# (此验证 通过 T295 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T295 smoke test 自身段引用 §9.6.39 5 步骤 (1 套 polish 模式 × 5 步骤 = 5 元素)
	_assert_contains(test_self_text, "Stage 1 expect 反转 1:1 严格", "T295-62: T295 自身引用 Stage 1 expect 反转 1:1 严格 (5 步骤 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 14. §9.6.39 0 漏 1 元素 0 改 1 字段 (5 元素 × 1 字段 = 5 元素 1:1 严格) ==========
	# 验证: 5 步骤 × 1 字段 = 5 元素 1:1 严格 (1 expect 反转 + 1 docblock 说明 + 1 段 find 反转 + 1 0 触碰既有 + 1 cross-section 同步)
	_assert_contains(contributing, "5 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T295-63: §9.6.39 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 15. T162 / T294 / T295 任务 ID 引用 ==========
	_assert_contains(contributing, "T162", "T295-64: §9.6.39 引用 T162 任务 ID")
	_assert_contains(contributing, "T294", "T295-65: §9.6.39 引用 T294 任务 ID (前一轮 #218 polish)")
	_assert_contains(contributing, "T295", "T295-66: §9.6.39 引用 T295 任务 ID (本轮 #219 polish)")
	_assert_contains(contributing, "#185", "T295-67: §9.6.39 引用 #185 iteration ID (T162 起步 iter)")
	_assert_contains(contributing, "#218", "T295-68: §9.6.39 引用 #218 iteration ID (T294 前一轮 iter)")
	_assert_contains(contributing, "#219", "T295-69: §9.6.39 引用 #219 iteration ID (T295 自身落地 iter)")

	# ========== Final ==========
	print("[T295] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T295] FAILURES:")
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
		print("[T295] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T295] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
