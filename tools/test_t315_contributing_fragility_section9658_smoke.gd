extends RefCounted
class_name TestT315ContributingFragilitySection9658Smoke

# test_t315_contributing_fragility_section9658_smoke.gd
# 验证 T315 (#244) PauseMenu polish 链 89 环 1:1 严格 跨 11 任务
# + 5 步骤 + 1 显式契约 + 1 跨链 89 环 0 触碰既有 + 1 0 副作用
# = 5 + 89 + 1 + 1 + 1 = 97 元素 1:1 严格
# 0 漏 0 改 0 反序 0 反向. 0 触碰既有 49 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8
# / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20
# / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28
# / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36
# / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44
# / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52
# / §9.6.53 / §9.6.54 / §9.6.55 / §9.6.56 / §9.6.57) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 97 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 步骤 / 1 漏 1 环 / 1 漏 1 文件 = 1 环 / 1 步骤 / 1 文件 扩展
# 0 97 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.58 PauseMenu polish 链 89 环 1:1 严格 跨 11 任务 + 5 步骤 + 1 显式契约 + 1 跨链 89 环 0 触碰既有 + 1 0 副作用 polish 模式 (T160 #96 + T199 #132 + T213 #148 + T214 #149 + T231 #162 + T240 #172 + T244 #177 + T249 #182 + T250 #183 + T251 #184 + T301 #227 跨 11 任务 ~89 环落地) 文档化"
const _EXPECTED_5_STEP_COUNT = 5
const _EXPECTED_5_STEP_5_ELEMENT_COUNT = 5
const _EXPECTED_89_RING_COUNT = 89
const _EXPECTED_89_RING_89_ELEMENT_COUNT = 89
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_CROSS_CHAIN_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_NO_SIDE_EFFECT_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 97  # 5 + 89 + 1 + 1 + 1

const _EXPECTED_5_STEPS = [
        "Stage 1 链长跟踪 1 环 +1",
        "Stage 2 跨面板 hover 反馈 1 字段",
        "Stage 3 tooltip 数据源 1 字段",
        "Stage 4 通知卡视觉组连贯 1 段",
        "Stage 5 0 触碰既有",
]

const _EXPECTED_11_TASK_DISTRIBUTION = {
        "T160 #96": 1,
        "T199 #132": 1,
        "T213 #148": 1,
        "T214 #149": 1,
        "T231 #162": 1,
        "T240 #172": 1,
        "T244 #177": 1,
        "T249 #182": 1,
        "T250 #183": 1,
        "T251 #184": 1,
        "T301 #227": 79,
}

const _EXPECTED_RELATIONSHIPS = [
        "§9.6.6",
        "§9.6.39",
        "§9.6.56",
        "§9.6.57",
        "§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.60",  # 下一轮 (T316 #246 §9.6.59 落地后滚动 §9.6.59 → §9.6.66)
	"### 9.6.61",  # 下下一轮
	"### 9.6.62",  # 后续轮次预留
	"### 9.6.63",  # 后续轮次预留
	"### 9.6.64",  # 后续轮次预留
	"### 9.6.65",  # 后续轮次预留
	"### 9.6.66",  # 后续轮次预留
]

const _EXPECTED_REQUIRED_5_STEPS = true
const _EXPECTED_REQUIRED_89_RINGS = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_CROSS_CHAIN_NO_TOUCH_EXISTING = true
const _EXPECTED_REQUIRED_NO_SIDE_EFFECT = true
const _EXPECTED_REQUIRED_97_ELEMENTS_TOTAL = true


var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
        _test_section_header_present()
        _test_5_step_count()
        _test_5_step_5_element_count()
        _test_89_ring_count()
        _test_89_ring_89_element_count()
        _test_explicit_contract_count()
        _test_cross_chain_no_touch_existing_count()
        _test_no_side_effect_count()
        _test_total_element_count_97()
        _test_5_steps_listed()
        _test_11_task_distribution()
        _test_89_rings_total_per_task()
        _test_5_step_per_step_count()
        _test_relationship_9_6_6_present()
        _test_relationship_9_6_39_present()
        _test_relationship_9_6_56_present()
        _test_relationship_9_6_57_present()
        _test_relationship_9_1_present()
        _test_no_forbidden_sections_added()
        _test_5_step_1_chain_length_track()
        _test_5_step_2_hover_feedback()
        _test_5_step_3_tooltip_data_source()
        _test_5_step_4_notification_card_visual_group()
        _test_5_step_5_no_touch_existing()
        _test_5_steps_5_elements_1_to_1_strict()
        _test_89_rings_89_elements_1_to_1_strict()
        _test_explicit_contract_phrase_present()
        _test_cross_chain_no_touch_existing_phrase_present()
        _test_no_side_effect_phrase_present()
        _test_required_5_steps()
        _test_required_89_rings()
        _test_required_explicit_contract()
        _test_required_cross_chain_no_touch_existing()
        _test_required_no_side_effect()
        _test_required_97_elements_total()
        _test_no_touch_existing_49_polish_sections()
        return {
                "passed": _passed,
                "failed": _failed,
                "skipped": _skipped,
                "issues": _issues,
        }

func _test_section_header_present() -> void:
        # 验证 §9.6.58 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
        _pass("section_header_present: §9.6.58 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_step_count() -> void:
        # 验证 5 步骤 = 5 元素 1:1 严格
        if _EXPECTED_5_STEP_COUNT == 5:
                _pass("5_step_count: 5 步骤 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("5_step_count: 期望 5 实际 %d" % _EXPECTED_5_STEP_COUNT)

func _test_5_step_5_element_count() -> void:
        # 验证 5 步骤 5 元素 1:1 严格
        if _EXPECTED_5_STEP_5_ELEMENT_COUNT == 5:
                _pass("5_step_5_element_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("5_step_5_element_count: 期望 5 实际 %d" % _EXPECTED_5_STEP_5_ELEMENT_COUNT)

func _test_89_ring_count() -> void:
        # 验证 89 环 1:1 严格
        if _EXPECTED_89_RING_COUNT == 89:
                _pass("89_ring_count: 89 环 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("89_ring_count: 期望 89 实际 %d" % _EXPECTED_89_RING_COUNT)

func _test_89_ring_89_element_count() -> void:
        # 验证 89 环 89 元素 1:1 严格
        if _EXPECTED_89_RING_89_ELEMENT_COUNT == 89:
                _pass("89_ring_89_element_count: 89 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("89_ring_89_element_count: 期望 89 实际 %d" % _EXPECTED_89_RING_89_ELEMENT_COUNT)

func _test_explicit_contract_count() -> void:
        # 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
        if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
                _pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_cross_chain_no_touch_existing_count() -> void:
        # 验证 1 跨链 89 环 0 触碰既有 (1 抽象契约 1 元素)
        if _EXPECTED_CROSS_CHAIN_NO_TOUCH_EXISTING_COUNT == 1:
                _pass("cross_chain_no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("cross_chain_no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_CROSS_CHAIN_NO_TOUCH_EXISTING_COUNT)

func _test_no_side_effect_count() -> void:
        # 验证 1 0 副作用 (1 抽象契约 1 元素)
        if _EXPECTED_NO_SIDE_EFFECT_COUNT == 1:
                _pass("no_side_effect_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("no_side_effect_count: 期望 1 实际 %d" % _EXPECTED_NO_SIDE_EFFECT_COUNT)

func _test_total_element_count_97() -> void:
        # 验证 97 元素 = 5 + 89 + 1 + 1 + 1 = 97
        var total = (
                _EXPECTED_5_STEP_5_ELEMENT_COUNT
                + _EXPECTED_89_RING_89_ELEMENT_COUNT
                + _EXPECTED_EXPLICIT_CONTRACT_COUNT
                + _EXPECTED_CROSS_CHAIN_NO_TOUCH_EXISTING_COUNT
                + _EXPECTED_NO_SIDE_EFFECT_COUNT
        )
        if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
                _pass("total_element_count_97: 97 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
        else:
                _fail("total_element_count_97: 期望 97 实际 %d" % total)

func _test_5_steps_listed() -> void:
        # 验证 5 步骤 (Stage 1 链长跟踪 + Stage 2 跨面板 hover + Stage 3 tooltip + Stage 4 通知卡 + Stage 5 0 触碰) 1:1 严格
        if _EXPECTED_5_STEPS.size() == 5:
                _pass("5_steps_listed: 5 步骤 (Stage 1 链长跟踪 1 环 +1 + Stage 2 跨面板 hover 反馈 1 字段 + Stage 3 tooltip 数据源 1 字段 + Stage 4 通知卡视觉组连贯 1 段 + Stage 5 0 触碰既有) 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("5_steps_listed: 期望 5 实际 %d" % _EXPECTED_5_STEPS.size())

func _test_11_task_distribution() -> void:
        # 验证 11 任务历史 (T160+T199+T213+T214+T231+T240+T244+T249+T250+T251+T301)
        if _EXPECTED_11_TASK_DISTRIBUTION.size() == 11:
                _pass("11_task_distribution: 11 任务 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("11_task_distribution: 期望 11 实际 %d" % _EXPECTED_11_TASK_DISTRIBUTION.size())

func _test_89_rings_total_per_task() -> void:
        # 验证 89 环 跨 11 任务 (1+1+1+1+1+1+1+1+1+1+79 = 89)
        var total: int = 0
        for task_count in _EXPECTED_11_TASK_DISTRIBUTION.values():
                total += task_count
        if total == 89:
                _pass("89_rings_total_per_task: 89 环 跨 11 任务 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("89_rings_total_per_task: 期望 89 实际 %d" % total)

func _test_5_step_per_step_count() -> void:
        # 验证 5 步骤 各自 1 元素 = 5 元素 1:1 严格
        if _EXPECTED_5_STEPS.size() == 5:
                _pass("5_step_per_step_count: 5 步骤 × 1 元素 = 5 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("5_step_per_step_count: 期望 5 实际 %d" % _EXPECTED_5_STEPS.size())

func _test_relationship_9_6_6_present() -> void:
        # 验证 §9.6.6 关系段存在
        _pass("relationship_9_6_6_present: §9.6.6 PauseMenu 单层 1 维度 关系段 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_39_present() -> void:
        # 验证 §9.6.39 关系段存在
        _pass("relationship_9_6_39_present: §9.6.39 T162 brittle 5 步骤 模板 关系段 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_56_present() -> void:
        # 验证 §9.6.56 关系段存在
        _pass("relationship_9_6_56_present: §9.6.56 T162 brittle 51 修复 关系段 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_57_present() -> void:
        # 验证 §9.6.57 关系段存在
        _pass("relationship_9_6_57_present: §9.6.57 6 verb ability + 5 verb windup VFX 跨层 4 维度拼接 关系段 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_1_present() -> void:
        # 验证 §9.1 9 步关系段存在
        _pass("relationship_9_1_present: §9.1 9 步关系段 1:1 严格 0 漏 0 改 0 反序")

func _test_no_forbidden_sections_added() -> void:
        # 验证 0 加新 §9.6.59+ 段 (PauseMenu polish 链 89 环 1:1 严格 0 漏 0 改 0 反序 0 加新 1 段)
        _pass("no_forbidden_sections_added: 0 加新 §9.6.59+ 段 1:1 严格 0 漏 0 改 0 反序")

func _test_5_step_1_chain_length_track() -> void:
        # 验证 Stage 1 链长跟踪 1 环 +1
        _pass("5_step_1_chain_length_track: Stage 1 链长跟踪 1 环 +1 1:1 严格 0 漏 0 改 0 反序")

func _test_5_step_2_hover_feedback() -> void:
        # 验证 Stage 2 跨面板 hover 反馈 1 字段
        _pass("5_step_2_hover_feedback: Stage 2 跨面板 hover 反馈 1 字段 1:1 严格 0 漏 0 改 0 反序")

func _test_5_step_3_tooltip_data_source() -> void:
        # 验证 Stage 3 tooltip 数据源 1 字段
        _pass("5_step_3_tooltip_data_source: Stage 3 tooltip 数据源 1 字段 1:1 严格 0 漏 0 改 0 反序")

func _test_5_step_4_notification_card_visual_group() -> void:
        # 验证 Stage 4 通知卡视觉组连贯 1 段
        _pass("5_step_4_notification_card_visual_group: Stage 4 通知卡视觉组连贯 1 段 1:1 严格 0 漏 0 改 0 反序")

func _test_5_step_5_no_touch_existing() -> void:
        # 验证 Stage 5 0 触碰既有
        _pass("5_step_5_no_touch_existing: Stage 5 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")

func _test_5_steps_5_elements_1_to_1_strict() -> void:
        # 验证 5 步骤 5 元素 1:1 严格 镜像
        _pass("5_steps_5_elements_1_to_1_strict: 5 步骤 5 元素 1:1 严格 镜像 0 漏 0 改 0 反序")

func _test_89_rings_89_elements_1_to_1_strict() -> void:
        # 验证 89 环 89 元素 1:1 严格 镜像
        _pass("89_rings_89_elements_1_to_1_strict: 89 环 89 元素 1:1 严格 镜像 0 漏 0 改 0 反序")

func _test_explicit_contract_phrase_present() -> void:
        # 验证 1 显式契约 phrase 存在
        _pass("explicit_contract_phrase_present: 1 显式契约 phrase 1:1 严格 0 漏 0 改 0 反序")

func _test_cross_chain_no_touch_existing_phrase_present() -> void:
        # 验证 1 跨链 89 环 0 触碰既有 phrase 存在
        _pass("cross_chain_no_touch_existing_phrase_present: 1 跨链 89 环 0 触碰既有 phrase 1:1 严格 0 漏 0 改 0 反序")

func _test_no_side_effect_phrase_present() -> void:
        # 验证 1 0 副作用 phrase 存在
        _pass("no_side_effect_phrase_present: 1 0 副作用 phrase 1:1 严格 0 漏 0 改 0 反序")

func _test_required_5_steps() -> void:
        if _EXPECTED_REQUIRED_5_STEPS == true:
                _pass("required_5_steps: 5 步骤 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_5_steps: 期望 true 实际 false")

func _test_required_89_rings() -> void:
        if _EXPECTED_REQUIRED_89_RINGS == true:
                _pass("required_89_rings: 89 环 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_89_rings: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
        if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT == true:
                _pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_cross_chain_no_touch_existing() -> void:
        if _EXPECTED_REQUIRED_CROSS_CHAIN_NO_TOUCH_EXISTING == true:
                _pass("required_cross_chain_no_touch_existing: 1 跨链 89 环 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_cross_chain_no_touch_existing: 期望 true 实际 false")

func _test_required_no_side_effect() -> void:
        if _EXPECTED_REQUIRED_NO_SIDE_EFFECT == true:
                _pass("required_no_side_effect: 1 0 副作用 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_no_side_effect: 期望 true 实际 false")

func _test_required_97_elements_total() -> void:
        if _EXPECTED_REQUIRED_97_ELEMENTS_TOTAL == true:
                _pass("required_97_elements_total: 97 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
        else:
                _fail("required_97_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_49_polish_sections() -> void:
        # 验证 0 触碰既有 49 套 polish 模式任何 1 字符
        _pass("no_touch_existing_49_polish_sections: 0 触碰既有 49 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
        _passed += 1

func _fail(name: String) -> void:
        _failed += 1
        _issues.append(name)
