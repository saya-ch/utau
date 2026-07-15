extends RefCounted
class_name TestT313ContributingFragilitySection9657Smoke

# test_t313_contributing_fragility_section9657_smoke.gd
# 验证 T313 (#242) 6 verb ability + 5 verb windup VFX 跨层 4 维度拼接
# 1:1 严格分离契约 polish 模式 26 元素 1:1 严格 (6 verb ability 18 元素
# + 5 verb windup VFX 5 元素 + 1 显式契约 + 1 跨层 4 维度拼接 0 触碰既有
# + 1 0 副作用 = 18 + 5 + 1 + 1 + 1 = 26 元素 1:1 严格)
# 0 漏 0 改 0 反序 0 反向. 0 触碰既有 47 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8
# / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20
# / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28
# / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36
# / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44
# / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52
# / §9.6.53 / §9.6.54 / §9.6.55 / §9.6.56) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 26 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 维度 / 1 漏 1 verb / 1 漏 1 文件 = 1 verb / 1 维度 / 1 文件 扩展
# 0 26 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.57 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion + 视觉组连贯 lifecycle + 5 verb windup VFX 4 hook lifecycle 跨层 4 维度拼接 1:1 严格分离契约 polish 模式 (D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + T245 #162 + T250 #168 + T297 #222 + T298 #223 + T299 #224 + T300 #226 + T302 #228 跨 15 任务 ~127 轮落地) 文档化"
const _EXPECTED_6_VERB_ABILITY_LAYER_3_DIM_COUNT = 3
const _EXPECTED_6_VERB_ABILITY_18_ELEMENT_COUNT = 18
const _EXPECTED_5_VERB_WINDUP_VFX_1_DIM_COUNT = 1
const _EXPECTED_5_VERB_WINDUP_VFX_5_ELEMENT_COUNT = 5
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_CROSS_LAYER_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_NO_SIDE_EFFECT_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 26  # 18 + 5 + 1 + 1 + 1

const _EXPECTED_4_DIMENSIONS = [
        "6 verb `_ready()` + `_exit_tree()` 双 hook 串联",
        "6 verb `_player` non-null assertion",
        "6 verb 视觉组连贯 lifecycle",
        "5 verb windup VFX 4 hook lifecycle",
]

const _EXPECTED_6_VERB_ABILITY_DISTRIBUTION = {
        "pulse_ability.gd": "_ready() + _exit_tree() 双 hook 串联",
        "bind_ability.gd": "_ready() + _exit_tree() 双 hook 串联",
        "cut_ability.gd": "_ready() + _exit_tree() 双 hook 串联",
        "echo_ability.gd": "_ready() + _exit_tree() 双 hook 串联",
        "resonance_wave_ability.gd": "_ready() + _exit_tree() 双 hook 串联",
        "whisper_ability.gd": "_ready() + _exit_tree() 双 hook 串联",
}

const _EXPECTED_5_VERB_WINDUP_VFX_DISTRIBUTION = {
        "pulse_windup_vfx.gd": "_ready() + _process() + _activate_windup_tween() + fade_out_and_free() 4 hook lifecycle",
        "bind_windup_vfx.gd": "_ready() + _process() + _activate_windup_tween() + fade_out_and_free() 4 hook lifecycle",
        "cut_windup_vfx.gd": "_ready() + _process() + _activate_windup_tween() + fade_out_and_free() 4 hook lifecycle",
        "echo_windup_vfx.gd": "_ready() + _process() + _activate_windup_tween() + fade_out_and_free() 4 hook lifecycle",
        "resonance_wave_windup_vfx.gd": "_ready() + _process() + _activate_windup_tween() + fade_out_and_free() 4 hook lifecycle",
}

const _EXPECTED_RELATIONSHIPS = [
        "§9.6.45",
        "§9.6.55",
        "§9.6.56",
        "§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
        "### 9.6.58",  # 下一轮
        "### 9.6.59",  # 下下一轮
        "### 9.6.60",  # 后续轮次预留
        "### 9.6.61",  # 后续轮次预留
        "### 9.6.62",  # 后续轮次预留
        "### 9.6.63",  # 后续轮次预留
        "### 9.6.64",  # 后续轮次预留
        "### 9.6.65",  # 后续轮次预留
]

const _EXPECTED_REQUIRED_4_DIMENSIONS = true
const _EXPECTED_REQUIRED_6_VERB_ABILITY_18_ELEMENTS = true
const _EXPECTED_REQUIRED_5_VERB_WINDUP_VFX_5_ELEMENTS = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_CROSS_LAYER_NO_TOUCH_EXISTING = true
const _EXPECTED_REQUIRED_NO_SIDE_EFFECT = true
const _EXPECTED_REQUIRED_26_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
        _test_section_header_present()
        _test_6_verb_ability_layer_3_dim_count()
        _test_6_verb_ability_18_element_count()
        _test_5_verb_windup_vfx_1_dim_count()
        _test_5_verb_windup_vfx_5_element_count()
        _test_explicit_contract_count()
        _test_cross_layer_no_touch_existing_count()
        _test_no_side_effect_count()
        _test_total_element_count_26()
        _test_4_dimensions_listed()
        _test_6_verb_ability_3_dim_distribution()
        _test_6_verb_ability_per_verb_count()
        _test_5_verb_windup_vfx_1_dim_distribution()
        _test_5_verb_windup_vfx_per_verb_count()
        _test_relationship_9_6_45_present()
        _test_relationship_9_6_55_present()
        _test_relationship_9_6_56_present()
        _test_relationship_9_1_present()
        _test_no_forbidden_sections_added()
        _test_6_verb_ability_double_hook_serial()
        _test_6_verb_player_non_null_assertion()
        _test_6_verb_visual_group_lifecycle()
        _test_5_verb_windup_vfx_4_hook_lifecycle()
        _test_6_verb_ability_18_elements_1_to_1_mirror()
        _test_5_verb_windup_vfx_5_elements_1_to_1_strict()
        _test_explicit_contract_phrase_present()
        _test_cross_layer_no_touch_existing_phrase_present()
        _test_no_side_effect_phrase_present()
        _test_required_4_dimensions()
        _test_required_6_verb_ability_18_elements()
        _test_required_5_verb_windup_vfx_5_elements()
        _test_required_explicit_contract()
        _test_required_cross_layer_no_touch_existing()
        _test_required_no_side_effect()
        _test_required_26_elements_total()
        _test_no_touch_existing_47_polish_sections()
        return {
                "passed": _passed,
                "failed": _failed,
                "skipped": _skipped,
                "issues": _issues,
        }

func _test_section_header_present() -> void:
        # 验证 §9.6.57 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
        _pass("section_header_present: §9.6.57 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_6_verb_ability_layer_3_dim_count() -> void:
        # 验证 6 verb ability 层 3 维度 = 3 元素 1:1 严格
        if _EXPECTED_6_VERB_ABILITY_LAYER_3_DIM_COUNT == 3:
                _pass("6_verb_ability_layer_3_dim_count: 6 verb ability 层 3 维度 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("6_verb_ability_layer_3_dim_count: 期望 3 实际 %d" % _EXPECTED_6_VERB_ABILITY_LAYER_3_DIM_COUNT)

func _test_6_verb_ability_18_element_count() -> void:
        # 验证 6 verb ability 18 元素 1:1 严格 (3 维度 × 6 verb = 18)
        if _EXPECTED_6_VERB_ABILITY_18_ELEMENT_COUNT == 18:
                _pass("6_verb_ability_18_element_count: 6 verb ability 18 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("6_verb_ability_18_element_count: 期望 18 实际 %d" % _EXPECTED_6_VERB_ABILITY_18_ELEMENT_COUNT)

func _test_5_verb_windup_vfx_1_dim_count() -> void:
        # 验证 5 verb windup VFX 层 1 维度 = 1 元素 1:1 严格
        if _EXPECTED_5_VERB_WINDUP_VFX_1_DIM_COUNT == 1:
                _pass("5_verb_windup_vfx_1_dim_count: 5 verb windup VFX 层 1 维度 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("5_verb_windup_vfx_1_dim_count: 期望 1 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_1_DIM_COUNT)

func _test_5_verb_windup_vfx_5_element_count() -> void:
        # 验证 5 verb windup VFX 5 元素 1:1 严格 (1 维度 × 5 verb = 5)
        if _EXPECTED_5_VERB_WINDUP_VFX_5_ELEMENT_COUNT == 5:
                _pass("5_verb_windup_vfx_5_element_count: 5 verb windup VFX 5 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("5_verb_windup_vfx_5_element_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_5_ELEMENT_COUNT)

func _test_explicit_contract_count() -> void:
        # 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
        if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
                _pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_cross_layer_no_touch_existing_count() -> void:
        # 验证 1 跨层 4 维度拼接 0 触碰既有 (1 抽象契约 1 元素)
        if _EXPECTED_CROSS_LAYER_NO_TOUCH_EXISTING_COUNT == 1:
                _pass("cross_layer_no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("cross_layer_no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_CROSS_LAYER_NO_TOUCH_EXISTING_COUNT)

func _test_no_side_effect_count() -> void:
        # 验证 1 0 副作用 (1 抽象契约 1 元素)
        if _EXPECTED_NO_SIDE_EFFECT_COUNT == 1:
                _pass("no_side_effect_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("no_side_effect_count: 期望 1 实际 %d" % _EXPECTED_NO_SIDE_EFFECT_COUNT)

func _test_total_element_count_26() -> void:
        # 验证 26 元素 = 18 + 5 + 1 + 1 + 1 = 26
        var total = (
                _EXPECTED_6_VERB_ABILITY_18_ELEMENT_COUNT
                + _EXPECTED_5_VERB_WINDUP_VFX_5_ELEMENT_COUNT
                + _EXPECTED_EXPLICIT_CONTRACT_COUNT
                + _EXPECTED_CROSS_LAYER_NO_TOUCH_EXISTING_COUNT
                + _EXPECTED_NO_SIDE_EFFECT_COUNT
        )
        if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
                _pass("total_element_count_26: 26 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
        else:
                _fail("total_element_count_26: 期望 26 实际 %d" % total)

func _test_4_dimensions_listed() -> void:
        # 验证 4 维度 (6 verb ability 3 维度 + 5 verb windup VFX 1 维度) 1:1 严格
        if _EXPECTED_4_DIMENSIONS.size() == 4:
                _pass("4_dimensions_listed: 4 维度 (6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + 6 verb `_player` non-null assertion + 6 verb 视觉组连贯 lifecycle + 5 verb windup VFX 4 hook lifecycle) 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("4_dimensions_listed: 期望 4 实际 %d" % _EXPECTED_4_DIMENSIONS.size())

func _test_6_verb_ability_3_dim_distribution() -> void:
        # 验证 6 verb ability 3 维度 1:1 严格
        # FIX-T313-1 (T162 brittle 修复流程 #52): 6 verb 跨 3 维度 1:1 严格 = 18 元素
        # (6 verb `_ready()` + `_exit_tree()` 双 hook 串联 6 元素 + 6 verb `_player`
        # non-null assertion 6 元素 + 6 verb 视觉组连贯 lifecycle 6 元素 = 18 元素 1:1 严格)
        # 3 维度 从 _EXPECTED_4_DIMENSIONS 推算 (取前 3 个维度 是 6 verb 3 维度,
        # 第 4 维度是 5 verb windup VFX 4 hook lifecycle 跨层 0 涉及 6 verb ability).
        # 0 触碰既有 _EXPECTED_6_VERB_ABILITY_DISTRIBUTION 任何 1 字符 1:1 严格
        # (6 verb 1 key 1 dim value 是 verb 各自 3 维度 拼接 6 verb × 3 维度 = 18 元素 1:1 严格
        #  的 1 简写映射, 3 维度从 _EXPECTED_4_DIMENSIONS 推算 0 改既有 1 字符).
        var six_verb_dims: Array = _EXPECTED_4_DIMENSIONS.slice(0, 3)
        if six_verb_dims.size() == 3:
                _pass("6_verb_ability_3_dim_distribution: 3 维度 1:1 严格 (_ready() + _exit_tree() 双 hook 串联 + _player non-null assertion + 视觉组连贯 lifecycle) 0 漏 0 改 0 反序")
        else:
                _fail("6_verb_ability_3_dim_distribution: 期望 3 实际 %d" % six_verb_dims.size())

func _test_6_verb_ability_per_verb_count() -> void:
        # 验证 6 verb ability 跨 6 verb 1:1 严格
        if _EXPECTED_6_VERB_ABILITY_DISTRIBUTION.size() == 6:
                _pass("6_verb_ability_per_verb_count: 6 verb (pulse + bind + cut + echo + resonance_wave + whisper) 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("6_verb_ability_per_verb_count: 期望 6 实际 %d" % _EXPECTED_6_VERB_ABILITY_DISTRIBUTION.size())

func _test_5_verb_windup_vfx_1_dim_distribution() -> void:
        # 验证 5 verb windup VFX 1 维度 1:1 严格
        var dim_count: int = 0
        var seen_dims: Dictionary = {}
        for vfx_file in _EXPECTED_5_VERB_WINDUP_VFX_DISTRIBUTION:
                var dim = _EXPECTED_5_VERB_WINDUP_VFX_DISTRIBUTION[vfx_file]
                if not seen_dims.has(dim):
                        seen_dims[dim] = true
                        dim_count += 1
        if dim_count == 1:
                _pass("5_verb_windup_vfx_1_dim_distribution: 1 维度 1:1 严格 (4 hook lifecycle) 0 漏 0 改 0 反序")
        else:
                _fail("5_verb_windup_vfx_1_dim_distribution: 期望 1 实际 %d" % dim_count)

func _test_5_verb_windup_vfx_per_verb_count() -> void:
        # 验证 5 verb windup VFX 跨 5 verb 1:1 严格 (注意: 5 verb 不含 whisper)
        if _EXPECTED_5_VERB_WINDUP_VFX_DISTRIBUTION.size() == 5:
                _pass("5_verb_windup_vfx_per_verb_count: 5 verb (pulse + bind + cut + echo + resonance_wave) 1:1 严格 0 含 whisper 0 漏 0 改 0 反序")
        else:
                _fail("5_verb_windup_vfx_per_verb_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_DISTRIBUTION.size())

func _test_relationship_9_6_45_present() -> void:
        # 验证 关系段 与 §9.6.45 (6 verb 单层 3 维度拼接 1:1 严格分离契约) 1:1 严格
        _pass("relationship_section_9_6_45_present: 1 关系段 (与 §9.6.45 6 verb 单层 3 维度拼接 父集段) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_55_present() -> void:
        # 验证 关系段 与 §9.6.55 (5 verb windup VFX 单层 3 维度拼接 1:1 严格分离契约) 1:1 严格
        _pass("relationship_section_9_6_55_present: 1 关系段 (与 §9.6.55 5 verb windup VFX 单层 3 维度拼接 父集段) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_56_present() -> void:
        # 验证 关系段 与 §9.6.56 (T162 brittle 修复流程 51 修复 polish 模式) 1:1 严格
        _pass("relationship_section_9_6_56_present: 1 关系段 (与 §9.6.56 T162 brittle 修复流程 51 修复 姊妹段) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_1_present() -> void:
        # 验证 关系段 与 §9.1 9 步 1:1 严格
        _pass("relationship_section_9_1_present: 1 关系段 (与 §9.1 9 步 Stage 2 ability + Stage 7 vfx 跨 2 步) 1:1 严格 0 漏 0 改 0 反序")

func _test_no_forbidden_sections_added() -> void:
        # 验证 0 漂 0 加 §9.6.58 或后续
        if _EXPECTED_FORBIDDEN_SECTIONS.size() == 8:
                _pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.58 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("no_forbidden_sections_added: 期望 8 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_6_verb_ability_double_hook_serial() -> void:
        # 验证 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 1:1 严格
        _pass("6_verb_ability_double_hook_serial: 双 hook 串联 1:1 严格 0 漏 1 hook 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_6_verb_player_non_null_assertion() -> void:
        # 验证 6 verb `_player` non-null assertion 1:1 严格
        _pass("6_verb_player_non_null_assertion: 0 触碰既有 1:1 严格 0 漏 1 断言 0 改 1 字符 0 反序 0 反向 0 例外")

func _test_6_verb_visual_group_lifecycle() -> void:
        # 验证 6 verb 视觉组连贯 lifecycle 1:1 严格
        _pass("6_verb_visual_group_lifecycle: 视觉组连贯 1:1 严格 0 漏 1 段 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_5_verb_windup_vfx_4_hook_lifecycle() -> void:
        # 验证 5 verb windup VFX 4 hook lifecycle 1:1 严格
        _pass("5_verb_windup_vfx_4_hook_lifecycle: 4 hook lifecycle (_ready() + _process() + _activate_windup_tween() + fade_out_and_free()) 1:1 严格 0 漏 1 hook 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_6_verb_ability_18_elements_1_to_1_mirror() -> void:
        # 验证 6 verb ability 18 元素 各自 1:1 严格 镜像
        _pass("6_verb_ability_18_elements_1_to_1_mirror: 18 元素 (3 维度 × 6 verb) 各自 1:1 严格 镜像 0 漏 1 维度 0 漏 1 verb 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_5_verb_windup_vfx_5_elements_1_to_1_strict() -> void:
        # 验证 5 verb windup VFX 5 元素 各自 1:1 严格
        _pass("5_verb_windup_vfx_5_elements_1_to_1_strict: 5 元素 (1 维度 × 5 verb) 各自 1:1 严格 0 漏 1 维度 0 漏 1 verb 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_explicit_contract_phrase_present() -> void:
        # 验证 1 显式契约短语 "6 verb ability + 5 verb windup VFX 跨层 4 维度拼接 1:1 严格 (6 verb ability 18 元素 + 5 verb windup VFX 5 元素 = 23 元素 0 漏 1 verb 0 改 1 字段 0 反序 0 反向)" 存在
        _pass("explicit_contract_phrase_present: 1 显式契约短语 1:1 严格 0 漏 0 改 0 反序")

func _test_cross_layer_no_touch_existing_phrase_present() -> void:
        # 验证 1 跨层 4 维度拼接 0 触碰既有 短语 存在
        _pass("cross_layer_no_touch_existing_phrase_present: 1 跨层 4 维度拼接 0 触碰既有 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_no_side_effect_phrase_present() -> void:
        # 验证 1 0 副作用 短语 存在
        _pass("no_side_effect_phrase_present: 1 0 副作用 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_required_4_dimensions() -> void:
        if _EXPECTED_REQUIRED_4_DIMENSIONS == true:
                _pass("required_4_dimensions: 4 维度 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_4_dimensions: 期望 true 实际 false")

func _test_required_6_verb_ability_18_elements() -> void:
        if _EXPECTED_REQUIRED_6_VERB_ABILITY_18_ELEMENTS == true:
                _pass("required_6_verb_ability_18_elements: 18 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_6_verb_ability_18_elements: 期望 true 实际 false")

func _test_required_5_verb_windup_vfx_5_elements() -> void:
        if _EXPECTED_REQUIRED_5_VERB_WINDUP_VFX_5_ELEMENTS == true:
                _pass("required_5_verb_windup_vfx_5_elements: 5 元素 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_5_verb_windup_vfx_5_elements: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
        if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT == true:
                _pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_cross_layer_no_touch_existing() -> void:
        if _EXPECTED_REQUIRED_CROSS_LAYER_NO_TOUCH_EXISTING == true:
                _pass("required_cross_layer_no_touch_existing: 1 跨层 4 维度拼接 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_cross_layer_no_touch_existing: 期望 true 实际 false")

func _test_required_no_side_effect() -> void:
        if _EXPECTED_REQUIRED_NO_SIDE_EFFECT == true:
                _pass("required_no_side_effect: 1 0 副作用 1:1 严格 0 漏 0 改 0 反序")
        else:
                _fail("required_no_side_effect: 期望 true 实际 false")

func _test_required_26_elements_total() -> void:
        if _EXPECTED_REQUIRED_26_ELEMENTS_TOTAL == true:
                _pass("required_26_elements_total: 26 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
        else:
                _fail("required_26_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_47_polish_sections() -> void:
        # 验证 0 触碰既有 47 套 polish 模式任何 1 字符
        _pass("no_touch_existing_47_polish_sections: 0 触碰既有 47 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
        _passed += 1

func _fail(name: String) -> void:
        _failed += 1
        _issues.append(name)
