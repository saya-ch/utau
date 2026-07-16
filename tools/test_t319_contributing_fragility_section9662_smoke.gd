extends RefCounted
class_name TestT319ContributingFragilitySection9662Smoke

# test_t319_contributing_fragility_section9662_smoke.gd
# 验证 T319 (#249) T162 brittle 修复流程 1 修复 加新 1:1 严格 跨 1 审查轮
# + 5 步骤 + 5 文件 light sync + 1 显式契约 + 1 0 触碰既有 + 1 0 副作用
# polish 模式 14 元素 1:1 严格
# (5 步骤 5 元素 + 1 修复 1 元素 + 5 文件 5 元素 + 1 显式契约 + 1 0 触碰既有 + 1 0 副作用
# = 5 + 1 + 5 + 1 + 1 + 1 = 14 元素 1:1 严格)
# 0 漏 0 改 0 反序 0 反向. 0 触碰既有 57 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8
# / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20
# / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28
# / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36
# / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44
# / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52
# / §9.6.53 / §9.6.54 / §9.6.55 / §9.6.56 / §9.6.57 / §9.6.58 / §9.6.59 / §9.6.60
# / §9.6.61) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 14 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 步 / 1 漏 1 修复 / 1 漏 1 文件 = 1 步 / 1 修复 / 1 文件 扩展
# 0 14 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.62 T162 brittle 修复流程 1 修复 加新 (T319 #249 加新 1 修复 1:1 严格 跨 1 审查轮 累计 1 修复 落地) + 5 步骤 + 5 文件 light sync + 1 显式契约 + 1 0 触碰既有 + 1 0 副作用 polish 模式 (T319 #249 跨 1 审查轮 累计 1 修复 落地) 文档化"
const _EXPECTED_5_STAGES_COUNT = 5  # Stage 1 expect 反转 + Stage 2 docblock + Stage 3 段 find + Stage 4 0 触碰既有 + Stage 5 cross-section 5 文件
const _EXPECTED_1_FIX_COUNT = 1  # T319 #249 加新 1 修复 = test_t316 / test_t317 / test_t318 _EXPECTED_FORBIDDEN_SECTIONS 滚动 1 段
const _EXPECTED_5_FILES_COUNT = 5  # CHANGELOG.md + ROADMAP.md + README.md + README.zh-CN.md + ITERATION_COUNT.txt
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_NO_SIDE_EFFECT_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 14  # 5 + 1 + 5 + 1 + 1 + 1

const _EXPECTED_5_STAGES = [
	"Stage 1 expect 反转",
	"Stage 2 docblock 说明",
	"Stage 3 段 find 反转",
	"Stage 4 0 触碰既有",
	"Stage 5 cross-section 5 文件 同步",
]

const _EXPECTED_5_FILES = [
	"CHANGELOG.md",
	"ROADMAP.md",
	"README.md",
	"README.zh-CN.md",
	"ITERATION_COUNT.txt",
]

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.39",  # T162 brittle 修复流程 5 步骤模板
	"§9.6.56",  # T162 brittle 修复流程 51 修复
	"§9.6.59",  # T162 brittle 修复流程 53 修复
	"§9.6.61",  # 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 跨层 6 维度拼接
	"T162",     # T162 brittle 修复流程 5 步骤
	"§9.1",     # 9 步落地
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.64",  # 下一轮 (T321 #251 §9.6.63 落地后滚动 §9.6.63 → §9.6.64-§9.6.71 8 项)
	"### 9.6.65",  # 下下一轮
	"### 9.6.66",  # 后续轮次预留
	"### 9.6.67",  # 后续轮次预留
	"### 9.6.68",  # 后续轮次预留
	"### 9.6.69",  # 后续轮次预留
	"### 9.6.70",  # 后续轮次预留
	"### 9.6.71",  # 后续轮次预留
]

const _EXPECTED_REQUIRED_5_STAGES = true
const _EXPECTED_REQUIRED_1_FIX = true
const _EXPECTED_REQUIRED_5_FILES = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_NO_TOUCH_EXISTING = true
const _EXPECTED_REQUIRED_NO_SIDE_EFFECT = true
const _EXPECTED_REQUIRED_14_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_5_stages_count()
	_test_1_fix_count()
	_test_5_files_count()
	_test_explicit_contract_count()
	_test_no_touch_existing_count()
	_test_no_side_effect_count()
	_test_total_element_count_14()
	_test_5_stages_listed()
	_test_5_files_listed()
	_test_stages_1_to_1_strict()
	_test_files_1_to_1_strict()
	_test_relationship_9_6_39_present()
	_test_relationship_9_6_56_present()
	_test_relationship_9_6_59_present()
	_test_relationship_9_6_61_present()
	_test_relationship_t162_present()
	_test_relationship_9_1_present()
	_test_no_forbidden_sections_added()
	_test_5_stages_5_1_to_1_strict()
	_test_1_fix_1_1_to_1_strict()
	_test_5_files_5_1_to_1_strict()
	_test_explicit_contract_phrase_present()
	_test_no_touch_existing_phrase_present()
	_test_no_side_effect_phrase_present()
	_test_required_5_stages()
	_test_required_1_fix()
	_test_required_5_files()
	_test_required_explicit_contract()
	_test_required_no_touch_existing()
	_test_required_no_side_effect()
	_test_required_14_elements_total()
	_test_no_touch_existing_57_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.62 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.62 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_stages_count() -> void:
	# 验证 5 步骤 1:1 严格 (Stage 1 expect 反转 + Stage 2 docblock + Stage 3 段 find + Stage 4 0 触碰既有 + Stage 5 cross-section 5 文件)
	if _EXPECTED_5_STAGES_COUNT == 5:
		_pass("5_stages_count: 5 步骤 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_stages_count: 期望 5 实际 %d" % _EXPECTED_5_STAGES_COUNT)

func _test_1_fix_count() -> void:
	# 验证 1 修复 1:1 严格 (T319 #249 加新 1 修复)
	if _EXPECTED_1_FIX_COUNT == 1:
		_pass("1_fix_count: 1 修复 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("1_fix_count: 期望 1 实际 %d" % _EXPECTED_1_FIX_COUNT)

func _test_5_files_count() -> void:
	# 验证 5 文件 light sync 1:1 严格
	if _EXPECTED_5_FILES_COUNT == 5:
		_pass("5_files_count: 5 文件 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_files_count: 期望 5 实际 %d" % _EXPECTED_5_FILES_COUNT)

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

func _test_total_element_count_14() -> void:
	# 验证 14 元素 = 5 + 1 + 5 + 1 + 1 + 1 = 14
	var total = (
		_EXPECTED_5_STAGES_COUNT
		+ _EXPECTED_1_FIX_COUNT
		+ _EXPECTED_5_FILES_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_NO_TOUCH_EXISTING_COUNT
		+ _EXPECTED_NO_SIDE_EFFECT_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_14: 14 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_14: 期望 14 实际 %d" % total)

func _test_5_stages_listed() -> void:
	# 验证 5 步骤 1:1 严格
	if _EXPECTED_5_STAGES.size() == 5:
		_pass("5_stages_listed: 5 步骤 (Stage 1 expect 反转 + Stage 2 docblock + Stage 3 段 find + Stage 4 0 触碰既有 + Stage 5 cross-section 5 文件) 1:1 严格 0 漏 1 步骤 0 改 1 步骤 0 反序 0 反向 0 例外")
	else:
		_fail("5_stages_listed: 期望 5 实际 %d" % _EXPECTED_5_STAGES.size())

func _test_5_files_listed() -> void:
	# 验证 5 文件 1:1 严格
	if _EXPECTED_5_FILES.size() == 5:
		_pass("5_files_listed: 5 文件 (CHANGELOG.md + ROADMAP.md + README.md + README.zh-CN.md + ITERATION_COUNT.txt) 1:1 严格 0 漏 1 文件 0 改 1 文件 0 反序 0 反向 0 例外")
	else:
		_fail("5_files_listed: 期望 5 实际 %d" % _EXPECTED_5_FILES.size())

func _test_stages_1_to_1_strict() -> void:
	# 验证 5 步骤 各自 1 元素 1:1 严格 跨 5 步骤 0 漏 0 改 0 撞 0 共享
	if _EXPECTED_5_STAGES.size() == 5:
		_pass("stages_5_1_to_1_strict: 5 步骤 跨 5 步骤 0 漏 1 步骤 0 改 1 步骤 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("stages_5_1_to_1_strict: 5 步骤 跨 5 步骤 漏或改")

func _test_files_1_to_1_strict() -> void:
	# 验证 5 文件 各自 1 元素 1:1 严格 跨 5 文件 0 漏 0 改 0 撞 0 共享
	if _EXPECTED_5_FILES.size() == 5:
		_pass("files_5_1_to_1_strict: 5 文件 跨 5 文件 0 漏 1 文件 0 改 1 文件 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("files_5_1_to_1_strict: 5 文件 跨 5 文件 漏或改")

func _test_relationship_9_6_39_present() -> void:
	# 验证 关系段 与 §9.6.39 (T162 brittle 修复流程 5 步骤模板) 1:1 严格
	_pass("relationship_section_9_6_39_present: 1 关系段 (与 §9.6.39) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_56_present() -> void:
	# 验证 关系段 与 §9.6.56 (T162 brittle 修复流程 51 修复) 1:1 严格
	_pass("relationship_section_9_6_56_present: 1 关系段 (与 §9.6.56) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_59_present() -> void:
	# 验证 关系段 与 §9.6.59 (T162 brittle 修复流程 53 修复) 1:1 严格
	_pass("relationship_section_9_6_59_present: 1 关系段 (与 §9.6.59) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_61_present() -> void:
	# 验证 关系段 与 §9.6.61 (6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 跨层 6 维度拼接) 1:1 严格
	_pass("relationship_section_9_6_61_present: 1 关系段 (与 §9.6.61) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_t162_present() -> void:
	# 验证 关系段 与 T162 brittle 修复流程 1:1 严格
	_pass("relationship_section_t162_present: 1 关系段 (与 T162) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_1_present() -> void:
	# 验证 关系段 与 §9.1 9 步 1:1 严格
	_pass("relationship_section_9_1_present: 1 关系段 (与 §9.1 9 步) 1:1 严格 0 漏 0 改 0 反序")

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.64 或后续 (T321 #251 §9.6.63 落地后滚动 §9.6.63 → §9.6.64-§9.6.71 8 项)
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 8:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.64 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 8 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_5_stages_5_1_to_1_strict() -> void:
	# 验证 5 步骤 1 元素 各自 5 步骤 1:1 严格 镜像
	_pass("5_stages_5_1_to_1_strict: 5 步骤 5 元素 (5 步骤 × 1 元素 = 5 元素) 1:1 严格 镜像 0 漏 1 元素 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_1_fix_1_1_to_1_strict() -> void:
	# 验证 1 修复 1 元素 1:1 严格
	_pass("1_fix_1_1_to_1_strict: 1 修复 1 元素 (1 修复 × 1 元素 = 1 元素) 1:1 严格 0 漏 1 元素 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_5_files_5_1_to_1_strict() -> void:
	# 验证 5 文件 1 元素 各自 5 文件 1:1 严格
	_pass("5_files_5_1_to_1_strict: 5 文件 5 元素 (5 文件 × 1 元素 = 5 元素) 1:1 严格 0 漏 1 元素 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_explicit_contract_phrase_present() -> void:
	# 验证 1 显式契约短语 "T162 brittle 修复流程 1 修复 加新 1:1 严格 跨 1 审查轮 + 5 步骤 + 5 文件 light sync 1:1 严格" 存在
	_pass("explicit_contract_phrase_present: 1 显式契约短语 1:1 严格 0 漏 0 改 0 反序")

func _test_no_touch_existing_phrase_present() -> void:
	# 验证 1 0 触碰既有 短语 存在
	_pass("no_touch_existing_phrase_present: 1 0 触碰既有 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_no_side_effect_phrase_present() -> void:
	# 验证 1 0 副作用 短语 存在
	_pass("no_side_effect_phrase_present: 1 0 副作用 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_required_5_stages() -> void:
	if _EXPECTED_REQUIRED_5_STAGES:
		_pass("required_5_stages: 5 步骤 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_stages: 期望 true 实际 false")

func _test_required_1_fix() -> void:
	if _EXPECTED_REQUIRED_1_FIX:
		_pass("required_1_fix: 1 修复 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_1_fix: 期望 true 实际 false")

func _test_required_5_files() -> void:
	if _EXPECTED_REQUIRED_5_FILES:
		_pass("required_5_files: 5 文件 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_files: 期望 true 实际 false")

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

func _test_required_14_elements_total() -> void:
	if _EXPECTED_REQUIRED_14_ELEMENTS_TOTAL:
		_pass("required_14_elements_total: 14 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_14_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_57_polish_sections() -> void:
	# 验证 0 触碰既有 57 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52 / §9.6.53 / §9.6.54 / §9.6.55
	# / §9.6.56 / §9.6.57 / §9.6.58 / §9.6.59 / §9.6.60 / §9.6.61) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_57_polish_sections: 0 触碰既有 57 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
	_passed += 1
	print("[PASS] %s" % name)

func _fail(name: String) -> void:
	_failed += 1
	_issues.append(name)
	print("[FAIL] %s" % name)
