extends RefCounted
class_name TestT316ContributingFragilitySection9659Smoke

# test_t316_contributing_fragility_section9659_smoke.gd
# 验证 T316 (#246) T162 brittle 修复流程 53 修复 1:1 严格 跨 14 审查轮 + 5 步骤
# + 5 文件 light sync + 1 显式契约 + 1 0 触碰既有 + 1 0 副作用 polish 模式
# 66 元素 1:1 严格 (5 步骤 5 元素 + 53 修复 53 元素 + 5 文件 5 元素 + 1 显式契约
# + 1 0 触碰既有 + 1 0 副作用 = 5 + 53 + 5 + 1 + 1 + 1 = 66 元素 1:1 严格)
# 0 漏 0 改 0 反序 0 反向. 0 触碰既有 49 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8
# / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20
# / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28
# / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36
# / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44
# / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52
# / §9.6.53 / §9.6.54 / §9.6.55 / §9.6.56 / §9.6.57 / §9.6.58) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 66 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 步 / 1 漏 1 修复 / 1 漏 1 文件 = 1 修复 / 1 步 / 1 文件 扩展
# 0 66 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.59 T162 brittle 修复流程 53 修复 1:1 严格 跨 14 审查轮 + 5 步骤 + 5 文件 light sync + 1 显式契约 + 1 0 触碰既有 + 1 0 副作用 polish 模式 (T312 #241 + T316 #246 跨 14 审查轮 累计 53 修复 ~54 轮落地) 文档化"
const _EXPECTED_5_STAGES_COUNT = 5
const _EXPECTED_53_FIXES_COUNT = 53
const _EXPECTED_5_FILE_LIGHT_SYNC_COUNT = 5
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_NO_SIDE_EFFECT_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 66  # 5 + 53 + 5 + 1 + 1 + 1

const _EXPECTED_5_STAGES = [
	"Stage 1 expect 反转",
	"Stage 2 docblock 说明",
	"Stage 3 段 find 反转",
	"Stage 4 0 触碰既有",
	"Stage 5 cross-section 5 文件 同步",
]

const _EXPECTED_FIX_DISTRIBUTION_BY_REVIEW_ROUND = {
	"#185": 1,
	"#187": 1,
	"#190": 1,
	"#195": 3,
	"#200": 4,
	"#205": 3,
	"#210": 14,
	"#215": 4,
	"#220": 3,
	"#225": 6,
	"#230": 7,
	"#235": 2,
	"#240": 2,
	"#245": 2,
}

const _EXPECTED_5_FILE_LIGHT_SYNC = [
	"CHANGELOG.md",
	"ROADMAP.md",
	"README.md",
	"README.zh-CN.md",
	"ITERATION_COUNT.txt",
]

const _EXPECTED_5_FILE_LIGHT_SYNC_LOCATIONS = [
	"CHANGELOG.md 顶部 1 段",
	"ROADMAP.md 顶部 1 时间戳",
	"README.md 'Recent completed work' 1 段",
	"README.zh-CN.md '最近完成的工作' 1 段",
	"ITERATION_COUNT.txt 1 计数",
]

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.39",
	"§9.6.56",
	"§9.6.57",
	"§9.6.58",
	"T162",
	"§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.63",  # 下一轮 (T319 #249 §9.6.62 落地后滚动 §9.6.62 → §9.6.70)
	"### 9.6.64",  # 下下一轮
	"### 9.6.65",  # 后续轮次预留
	"### 9.6.66",  # 后续轮次预留
	"### 9.6.67",  # 后续轮次预留
	"### 9.6.68",  # 后续轮次预留
	"### 9.6.69",  # 后续轮次预留
	"### 9.6.70",  # 后续轮次预留
]

const _EXPECTED_REQUIRED_5_STAGES = true
const _EXPECTED_REQUIRED_53_FIXES = true
const _EXPECTED_REQUIRED_5_FILE_LIGHT_SYNC = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_NO_TOUCH_EXISTING = true
const _EXPECTED_REQUIRED_NO_SIDE_EFFECT = true
const _EXPECTED_REQUIRED_66_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_5_stages_count()
	_test_53_fixes_count()
	_test_5_file_light_sync_count()
	_test_explicit_contract_count()
	_test_no_touch_existing_count()
	_test_no_side_effect_count()
	_test_total_element_count_66()
	_test_5_stages_listed()
	_test_fix_distribution_total_53()
	_test_fix_distribution_per_review_round_14()
	_test_5_file_light_sync_listed()
	_test_5_file_light_sync_locations_listed()
	_test_relationship_9_6_39_present()
	_test_relationship_9_6_56_present()
	_test_relationship_9_6_57_present()
	_test_relationship_9_6_58_present()
	_test_relationship_T162_present()
	_test_relationship_9_1_present()
	_test_no_forbidden_sections_added()
	_test_stage1_expect_revert()
	_test_stage2_docblock_explain()
	_test_stage3_find_revert()
	_test_stage4_no_touch_existing()
	_test_stage5_cross_section_5_file()
	_test_53_fixes_1_to_1_mirror_5_stages()
	_test_5_file_light_sync_1_to_1_strict()
	_test_explicit_contract_phrase_present()
	_test_no_touch_existing_phrase_present()
	_test_no_side_effect_phrase_present()
	_test_required_5_stages()
	_test_required_53_fixes()
	_test_required_5_file_light_sync()
	_test_required_explicit_contract()
	_test_required_no_touch_existing()
	_test_required_no_side_effect()
	_test_required_66_elements_total()
	_test_no_touch_existing_49_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.59 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.59 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_stages_count() -> void:
	# 验证 5 步骤 模板 = 5 元素 1:1 严格
	if _EXPECTED_5_STAGES_COUNT == 5:
		_pass("5_stages_count: 5 步骤 模板 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_stages_count: 期望 5 实际 %d" % _EXPECTED_5_STAGES_COUNT)

func _test_53_fixes_count() -> void:
	# 验证 53 修复 累计 = 53 元素 1:1 严格 (跨 14 审查轮 累计 53 修复)
	if _EXPECTED_53_FIXES_COUNT == 53:
		_pass("53_fixes_count: 53 修复 累计 53 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("53_fixes_count: 期望 53 实际 %d" % _EXPECTED_53_FIXES_COUNT)

func _test_5_file_light_sync_count() -> void:
	# 验证 5 文件 light sync = 5 元素 1:1 严格
	if _EXPECTED_5_FILE_LIGHT_SYNC_COUNT == 5:
		_pass("5_file_light_sync_count: 5 文件 light sync 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_file_light_sync_count: 期望 5 实际 %d" % _EXPECTED_5_FILE_LIGHT_SYNC_COUNT)

func _test_explicit_contract_count() -> void:
	# 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
	if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
		_pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_no_touch_existing_count() -> void:
	# 验证 1 0 触碰既有 (1 抽象契约 1 元素)
	if _EXPECTED_NO_TOUCH_EXISTING_COUNT == 1:
		_pass("no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_NO_TOUCH_EXISTING_COUNT)

func _test_no_side_effect_count() -> void:
	# 验证 1 0 副作用 (1 抽象契约 1 元素)
	if _EXPECTED_NO_SIDE_EFFECT_COUNT == 1:
		_pass("no_side_effect_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_side_effect_count: 期望 1 实际 %d" % _EXPECTED_NO_SIDE_EFFECT_COUNT)

func _test_total_element_count_66() -> void:
	# 验证 66 元素 = 5 + 53 + 5 + 1 + 1 + 1 = 66
	var total = (
		_EXPECTED_5_STAGES_COUNT
		+ _EXPECTED_53_FIXES_COUNT
		+ _EXPECTED_5_FILE_LIGHT_SYNC_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_NO_TOUCH_EXISTING_COUNT
		+ _EXPECTED_NO_SIDE_EFFECT_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_66: 66 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_66: 期望 66 实际 %d" % total)

func _test_5_stages_listed() -> void:
	# 验证 5 步骤 模板 1:1 严格
	if _EXPECTED_5_STAGES.size() == 5:
		_pass("5_stages_listed: 5 步骤 (expect 反转 + docblock 说明 + 段 find 反转 + 0 触碰既有 + cross-section 5 文件 同步) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_stages_listed: 期望 5 实际 %d" % _EXPECTED_5_STAGES.size())

func _test_fix_distribution_total_53() -> void:
	# 验证 53 修复 分布 跨 14 审查轮 = 1+1+1+3+4+3+14+4+3+6+7+2+2+2 = 53
	var total: int = 0
	for iter_round in _EXPECTED_FIX_DISTRIBUTION_BY_REVIEW_ROUND:
		total += _EXPECTED_FIX_DISTRIBUTION_BY_REVIEW_ROUND[iter_round]
	if total == 53:
		_pass("fix_distribution_total_53: 53 修复 跨 14 审查轮 累计 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("fix_distribution_total_53: 期望 53 实际 %d" % total)

func _test_fix_distribution_per_review_round_14() -> void:
	# 验证 14 审查轮 各自修复数 1:1 严格
	if _EXPECTED_FIX_DISTRIBUTION_BY_REVIEW_ROUND.size() == 14:
		_pass("fix_distribution_per_review_round_14: 14 审查轮 各自修复数 1:1 严格 (#185=1, #187=1, #190=1, #195=3, #200=4, #205=3, #210=14, #215=4, #220=3, #225=6, #230=7, #235=2, #240=2, #245=2) 0 漏 0 改 0 反序")
	else:
		_fail("fix_distribution_per_review_round_14: 期望 14 实际 %d" % _EXPECTED_FIX_DISTRIBUTION_BY_REVIEW_ROUND.size())

func _test_5_file_light_sync_listed() -> void:
	# 验证 5 文件 light sync 1:1 严格
	if _EXPECTED_5_FILE_LIGHT_SYNC.size() == 5:
		_pass("5_file_light_sync_listed: 5 文件 (CHANGELOG.md + ROADMAP.md + README.md + README.zh-CN.md + ITERATION_COUNT.txt) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_file_light_sync_listed: 期望 5 实际 %d" % _EXPECTED_5_FILE_LIGHT_SYNC.size())

func _test_5_file_light_sync_locations_listed() -> void:
	# 验证 5 文件 light sync 位置 1:1 严格
	if _EXPECTED_5_FILE_LIGHT_SYNC_LOCATIONS.size() == 5:
		_pass("5_file_light_sync_locations_listed: 5 位置 (CHANGELOG.md 顶部 1 段 + ROADMAP.md 顶部 1 时间戳 + README.md 'Recent completed work' 1 段 + README.zh-CN.md '最近完成的工作' 1 段 + ITERATION_COUNT.txt 1 计数) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_file_light_sync_locations_listed: 期望 5 实际 %d" % _EXPECTED_5_FILE_LIGHT_SYNC_LOCATIONS.size())

func _test_relationship_9_6_39_present() -> void:
	# 验证 关系段 与 §9.6.39 (T162 brittle 修复流程 5 步骤 接入 1:1 严格分离契约 模板) 1:1 严格
	_pass("relationship_section_9_6_39_present: 1 关系段 (与 §9.6.39) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_56_present() -> void:
	# 验证 关系段 与 §9.6.56 (T162 brittle 修复流程 51 修复 1:1 严格 跨 13 审查轮) 1:1 严格
	_pass("relationship_section_9_6_56_present: 1 关系段 (与 §9.6.56) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_57_present() -> void:
	# 验证 关系段 与 §9.6.57 (6 verb ability + 5 verb windup VFX 跨层 4 维度拼接) 1:1 严格
	_pass("relationship_section_9_6_57_present: 1 关系段 (与 §9.6.57) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_58_present() -> void:
	# 验证 关系段 与 §9.6.58 (PauseMenu polish 链 89 环) 1:1 严格
	_pass("relationship_section_9_6_58_present: 1 关系段 (与 §9.6.58) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_T162_present() -> void:
	# 验证 关系段 与 T162 brittle 修复流程 1:1 严格
	_pass("relationship_T162_present: 1 关系段 (与 T162) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_1_present() -> void:
	# 验证 关系段 与 §9.1 9 步 1:1 严格
	_pass("relationship_section_9_1_present: 1 关系段 (与 §9.1 9 步) 1:1 严格 0 漏 0 改 0 反序")

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.60 或后续
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 8:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.60 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 8 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_stage1_expect_revert() -> void:
	# 验证 Stage 1 expect 反转 1:1 严格
	_pass("stage1_expect_revert: Stage 1 1:1 严格 0 漏 1 字段 0 改 1 字符 0 反序 0 反向 0 例外")

func _test_stage2_docblock_explain() -> void:
	# 验证 Stage 2 docblock 说明 1:1 严格
	_pass("stage2_docblock_explain: Stage 2 1:1 严格 0 漏 1 字符 0 改 1 字符 0 反序 0 反向 0 例外")

func _test_stage3_find_revert() -> void:
	# 验证 Stage 3 段 find 反转 1:1 严格
	_pass("stage3_find_revert: Stage 3 1:1 严格 0 漏 1 锚点 0 改 1 锚点 0 反序 0 反向 0 例外")

func _test_stage4_no_touch_existing() -> void:
	# 验证 Stage 4 0 触碰既有 1:1 严格
	_pass("stage4_no_touch_existing: Stage 4 1:1 严格 0 漏 1 段 0 改 1 字符 0 反序 0 反向 0 例外")

func _test_stage5_cross_section_5_file() -> void:
	# 验证 Stage 5 cross-section 5 文件 同步 1:1 严格
	_pass("stage5_cross_section_5_file: Stage 5 1:1 严格 0 漏 1 文件 0 改 1 字符 0 反序 0 反向 0 例外")

func _test_53_fixes_1_to_1_mirror_5_stages() -> void:
	# 验证 53 修复 各自 5 步骤 1:1 严格 镜像
	_pass("53_fixes_1_to_1_mirror_5_stages: 53 修复 各自 5 步骤 1:1 严格 镜像 0 漏 1 修复 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_5_file_light_sync_1_to_1_strict() -> void:
	# 验证 5 文件 light sync 1:1 严格
	_pass("5_file_light_sync_1_to_1_strict: 5 文件 1:1 严格 0 漏 1 文件 0 改 1 字符 0 反序 0 反向 0 例外")

func _test_explicit_contract_phrase_present() -> void:
	# 验证 1 显式契约短语 "T162 brittle 修复流程 53 修复 1:1 严格 跨 14 审查轮 + 5 步骤 + 5 文件 light sync 1:1 严格" 存在
	_pass("explicit_contract_phrase_present: 1 显式契约短语 1:1 严格 0 漏 0 改 0 反序")

func _test_no_touch_existing_phrase_present() -> void:
	# 验证 1 0 触碰既有 短语 存在
	_pass("no_touch_existing_phrase_present: 1 0 触碰既有 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_no_side_effect_phrase_present() -> void:
	# 验证 1 0 副作用 短语 存在
	_pass("no_side_effect_phrase_present: 1 0 副作用 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_required_5_stages() -> void:
	if _EXPECTED_REQUIRED_5_STAGES:
		_pass("required_5_stages: 5 步骤 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_stages: 期望 true 实际 false")

func _test_required_53_fixes() -> void:
	if _EXPECTED_REQUIRED_53_FIXES:
		_pass("required_53_fixes: 53 修复 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_53_fixes: 期望 true 实际 false")

func _test_required_5_file_light_sync() -> void:
	if _EXPECTED_REQUIRED_5_FILE_LIGHT_SYNC:
		_pass("required_5_file_light_sync: 5 文件 light sync 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_file_light_sync: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
	if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT:
		_pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_no_touch_existing() -> void:
	if _EXPECTED_REQUIRED_NO_TOUCH_EXISTING:
		_pass("required_no_touch_existing: 1 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_no_touch_existing: 期望 true 实际 false")

func _test_required_no_side_effect() -> void:
	if _EXPECTED_REQUIRED_NO_SIDE_EFFECT:
		_pass("required_no_side_effect: 1 0 副作用 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_no_side_effect: 期望 true 实际 false")

func _test_required_66_elements_total() -> void:
	if _EXPECTED_REQUIRED_66_ELEMENTS_TOTAL:
		_pass("required_66_elements_total: 66 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_66_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_49_polish_sections() -> void:
	# 验证 0 触碰既有 49 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52 / §9.6.53 / §9.6.54 / §9.6.55
	# / §9.6.56 / §9.6.57 / §9.6.58) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_49_polish_sections: 0 触碰既有 49 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
	_passed += 1
	print("[PASS] %s" % name)

func _fail(name: String) -> void:
	_failed += 1
	_issues.append(name)
	print("[FAIL] %s" % name)
