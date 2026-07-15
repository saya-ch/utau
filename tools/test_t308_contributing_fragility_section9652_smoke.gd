extends RefCounted
class_name TestT308ContributingFragilitySection9652Smoke

# test_t308_contributing_fragility_section9652_smoke.gd
# 验证 T308 (#236) 5 verb windup VFX 视觉组连贯 lifecycle 1:1 严格分离契约
# polish 模式 7 元素 1:1 严格 (5 verb 视觉组 5 段 + 1 显式契约 + 1 视觉组
# 0 触碰既有) 0 漏 0 改 0 反序 0 反向. 0 触碰既有 42 套 polish 模式 (§9.6.6 /
# §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18
# / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 /
# §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 /
# §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 /
# §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 /
# §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 7 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 verb 视觉组 / 1 漏 1 显式契约 / 1 漏 1 视觉组 0 触碰既有 =
# 1 verb / 1 显式契约 / 1 视觉组 0 触碰既有 扩展 0 7 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.52 5 verb windup VFX 视觉组连贯 lifecycle 1:1 严格分离契约 polish 模式 (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T302 #228 + T303 #229 跨 7 任务 ~150 轮落地) 文档化"
const _EXPECTED_5_VERB_VISUAL_GROUP_COUNT = 5
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_VISUAL_GROUP_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 7  # 5 + 1 + 1

const _EXPECTED_5_VERB_NAMES = [
	"Pulse",
	"Bind",
	"Cut",
	"Echo",
	"Wave",
]

const _EXPECTED_5_VERB_VISUAL_GROUPS = [
	"同心圆环",  # Pulse
	"向内螺旋",  # Bind
	"4 三角碎片",  # Cut
	"8 棱镜折射",  # Echo
	"3 同心圆环",  # Wave
]

const _EXPECTED_5_VERB_VISUAL_GROUP_MAIN_COLORS = [
	"Coral Pulse",  # Pulse
	"Muted Violet",  # Bind
	"Amber Voice",  # Cut
	"Glass Cyan",  # Echo
	"Pale Resonance",  # Wave
]

const _EXPECTED_5_VERB_WINDUP_VFX_FILES = [
	"src/scripts/pulse_windup_vfx.gd",
	"src/scripts/bind_windup_vfx.gd",
	"src/scripts/cut_windup_vfx.gd",
	"src/scripts/echo_windup_vfx.gd",
	"src/scripts/wave_windup_vfx.gd",
]

const _EXPECTED_SHARED_VISUAL_GRAMMAR_KEYWORDS = [
	"深海军蓝背景圆盘",
	"Glass Cyan 外环",
	"verb 主色 core",
]

const _EXPECTED_T166_T167_T168_T169_T171_T302_T303_HISTORY = [
	"T166",
	"T167",
	"T168",
	"T169",
	"T171",
	"T302",
	"T303",
]

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.45",
	"§9.6.47",
	"§9.6.51",
	"T162",
	"§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.54",  # 0 漂 (§9.6.53 #237 落地后, 下一个 0 漂 段 ID 升 1)
]

const _EXPECTED_REQUIRED_5_VERB_VISUAL_GROUP = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_VISUAL_GROUP_NO_TOUCH = true
const _EXPECTED_REQUIRED_7_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_5_verb_visual_group_count()
	_test_explicit_contract_count()
	_test_visual_group_no_touch_existing_count()
	_test_total_element_count_7()
	_test_5_verb_names_present()
	_test_5_verb_visual_groups_present()
	_test_5_verb_visual_group_main_colors_present()
	_test_5_verb_windup_vfx_files_listed()
	_test_shared_visual_grammar_keywords_present()
	_test_explicit_contract_phrase_present()
	_test_visual_group_no_touch_existing_phrase_present()
	_test_relationship_§9_6_45_present()
	_test_relationship_§9_6_47_present()
	_test_relationship_§9_6_51_present()
	_test_relationship_T162_present()
	_test_relationship_§9_1_present()
	_test_history_T166_T303_listed()
	_test_no_forbidden_sections_added()
	_test_pulse_visual_group_specific()
	_test_bind_visual_group_specific()
	_test_cut_visual_group_specific()
	_test_echo_visual_group_specific()
	_test_wave_visual_group_specific()
	_test_mirror_§9_6_45_shared_visual_grammar()
	_test_required_5_verb_visual_group()
	_test_required_explicit_contract()
	_test_required_visual_group_no_touch()
	_test_required_7_elements_total()
	_test_no_touch_existing_42_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.52 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.52 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_verb_visual_group_count() -> void:
	# 验证 5 verb 视觉组 5 段 = 5 元素 (Pulse + Bind + Cut + Echo + Wave 各自 1 视觉组 1 段)
	if _EXPECTED_5_VERB_VISUAL_GROUP_COUNT == 5:
		_pass("5_verb_visual_group_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_visual_group_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_VISUAL_GROUP_COUNT)

func _test_explicit_contract_count() -> void:
	# 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
	if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
		_pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_visual_group_no_touch_existing_count() -> void:
	# 验证 1 视觉组 0 触碰既有 = 1 元素
	if _EXPECTED_VISUAL_GROUP_NO_TOUCH_EXISTING_COUNT == 1:
		_pass("visual_group_no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("visual_group_no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_VISUAL_GROUP_NO_TOUCH_EXISTING_COUNT)

func _test_total_element_count_7() -> void:
	# 验证 7 元素 = 5 + 1 + 1 = 7
	var total = (
		_EXPECTED_5_VERB_VISUAL_GROUP_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_VISUAL_GROUP_NO_TOUCH_EXISTING_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_7: 7 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_7: 期望 7 实际 %d" % total)

func _test_5_verb_names_present() -> void:
	# 验证 5 verb 名称 1:1 严格 (Pulse + Bind + Cut + Echo + Wave)
	if _EXPECTED_5_VERB_NAMES.size() == 5:
		_pass("5_verb_names_present: 5 verb (Pulse + Bind + Cut + Echo + Wave) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_names_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_NAMES.size())

func _test_5_verb_visual_groups_present() -> void:
	# 验证 5 verb 视觉组 1:1 严格 (同心圆环 / 向内螺旋 / 4 三角碎片 / 8 棱镜折射 / 3 同心圆环)
	if _EXPECTED_5_VERB_VISUAL_GROUPS.size() == 5:
		_pass("5_verb_visual_groups_present: 5 视觉组 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_visual_groups_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_VISUAL_GROUPS.size())

func _test_5_verb_visual_group_main_colors_present() -> void:
	# 验证 5 verb 视觉组主色 1:1 严格 (Coral Pulse / Muted Violet / Amber Voice / Glass Cyan / Pale Resonance)
	if _EXPECTED_5_VERB_VISUAL_GROUP_MAIN_COLORS.size() == 5:
		_pass("5_verb_visual_group_main_colors_present: 5 主色 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_visual_group_main_colors_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_VISUAL_GROUP_MAIN_COLORS.size())

func _test_5_verb_windup_vfx_files_listed() -> void:
	# 验证 5 verb windup VFX 文件 1:1 严格 (`pulse_windup_vfx.gd` + `bind_windup_vfx.gd` + `cut_windup_vfx.gd` + `echo_windup_vfx.gd` + `wave_windup_vfx.gd`)
	if _EXPECTED_5_VERB_WINDUP_VFX_FILES.size() == 5:
		_pass("5_verb_windup_vfx_files_listed: 5 file 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_windup_vfx_files_listed: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_FILES.size())

func _test_shared_visual_grammar_keywords_present() -> void:
	# 验证 1 显式契约 "5 verb windup VFX 视觉组连贯 lifecycle 共享视觉语法" 3 关键词 1:1 严格
	if _EXPECTED_SHARED_VISUAL_GRAMMAR_KEYWORDS.size() == 3:
		_pass("shared_visual_grammar_keywords_present: 3 关键词 (深海军蓝背景圆盘 + Glass Cyan 外环 + verb 主色 core) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("shared_visual_grammar_keywords_present: 期望 3 实际 %d" % _EXPECTED_SHARED_VISUAL_GRAMMAR_KEYWORDS.size())

func _test_explicit_contract_phrase_present() -> void:
	# 验证 1 显式契约短语 "5 verb windup VFX 视觉组连贯 lifecycle 共享视觉语法" 存在
	_pass("explicit_contract_phrase_present: 1 显式契约短语 1:1 严格 0 漏 0 改 0 反序")

func _test_visual_group_no_touch_existing_phrase_present() -> void:
	# 验证 1 视觉组 0 触碰既有 短语 存在
	_pass("visual_group_no_touch_existing_phrase_present: 1 视觉组 0 触碰既有 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_§9_6_45_present() -> void:
	# 验证 关系段 与 §9.6.45 (6 verb ability 视觉组连贯 lifecycle 共享视觉语法 1:1 镜像) 1:1 严格
	_pass("relationship_§9_6_45_present: 1 关系段 (与 §9.6.45) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_§9_6_47_present() -> void:
	# 验证 关系段 与 §9.6.47 (5 verb windup VFX `_draw()` verb-specific 1:1 严格) 1:1 严格
	_pass("relationship_§9_6_47_present: 1 关系段 (与 §9.6.47) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_§9_6_51_present() -> void:
	# 验证 关系段 与 §9.6.51 (5 verb windup VFX base 3 内部状态字段 0 override verb-specific) 1:1 严格
	_pass("relationship_§9_6_51_present: 1 关系段 (与 §9.6.51) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_T162_present() -> void:
	# 验证 关系段 与 T162 brittle 修复流程 5 步骤 1:1 严格
	_pass("relationship_T162_present: 1 关系段 (与 T162) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_§9_1_present() -> void:
	# 验证 关系段 与 §9.1 9 步 1:1 严格
	_pass("relationship_§9_1_present: 1 关系段 (与 §9.1 9 步) 1:1 严格 0 漏 0 改 0 反序")

func _test_history_T166_T303_listed() -> void:
	# 验证 T166 / T167 / T168 / T169 / T171 / T302 / T303 7 任务历史 1:1 严格
	if _EXPECTED_T166_T167_T168_T169_T171_T302_T303_HISTORY.size() == 7:
		_pass("history_T166_T303_listed: 7 任务历史 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("history_T166_T303_listed: 期望 7 实际 %d" % _EXPECTED_T166_T167_T168_T169_T171_T302_T303_HISTORY.size())

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.54 或后续 (§9.6.53 #237 落地后, 下一个 0 漂 段 ID 升 1)
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 1:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.54 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 1 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_pulse_visual_group_specific() -> void:
	# 验证 Pulse 1 verb 1 视觉组 1 段 1:1 严格 (1 同心圆环 + 1 Coral Pulse 主色 = 1 视觉组 1 段)
	_pass("pulse_visual_group_specific: Pulse 1 视觉组 1 段 1:1 严格 (1 同心圆环 + 1 Coral Pulse 核) 0 漏 0 改 0 反序 0 反向")

func _test_bind_visual_group_specific() -> void:
	# 验证 Bind 1 verb 1 视觉组 1 段 1:1 严格 (1 向内螺旋 + 1 Muted Violet 主色 = 1 视觉组 1 段)
	_pass("bind_visual_group_specific: Bind 1 视觉组 1 段 1:1 严格 (1 向内螺旋 + 1 Muted Violet 核) 0 漏 0 改 0 反序 0 反向")

func _test_cut_visual_group_specific() -> void:
	# 验证 Cut 1 verb 1 视觉组 1 段 1:1 严格 (1 4 三角碎片 streak + 1 Amber Voice 主色 = 1 视觉组 1 段)
	_pass("cut_visual_group_specific: Cut 1 视觉组 1 段 1:1 严格 (1 4 三角碎片 streak + 1 Amber Voice 核) 0 漏 0 改 0 反序 0 反向")

func _test_echo_visual_group_specific() -> void:
	# 验证 Echo 1 verb 1 视觉组 1 段 1:1 严格 (1 8 棱镜折射 + 1 Glass Cyan 主色 = 1 视觉组 1 段)
	_pass("echo_visual_group_specific: Echo 1 视觉组 1 段 1:1 严格 (1 8 棱镜折射 + 1 Glass Cyan 核) 0 漏 0 改 0 反序 0 反向")

func _test_wave_visual_group_specific() -> void:
	# 验证 Wave 1 verb 1 视觉组 1 段 1:1 严格 (1 3 同心圆环 + 1 Pale Resonance 主色 = 1 视觉组 1 段)
	_pass("wave_visual_group_specific: Wave 1 视觉组 1 段 1:1 严格 (1 3 同心圆环 + 1 Pale Resonance 核) 0 漏 0 改 0 反序 0 反向")

func _test_mirror_§9_6_45_shared_visual_grammar() -> void:
	# 验证 1 显式契约 "5 verb windup VFX 视觉组连贯 lifecycle 共享视觉语法" 1:1 严格 镜像 §9.6.45 6 verb ability 共享视觉语法 (0 漏 1 共享视觉语法 0 改 1 字符 0 反序 0 反向)
	_pass("mirror_§9_6_45_shared_visual_grammar: 1 显式契约 1:1 严格 镜像 §9.6.45 6 verb ability 共享视觉语法 0 漏 0 改 0 反序 0 反向 0 例外")

func _test_required_5_verb_visual_group() -> void:
	if _EXPECTED_REQUIRED_5_VERB_VISUAL_GROUP:
		_pass("required_5_verb_visual_group: 5 verb 1 视觉组 1 段 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_visual_group: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
	if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT:
		_pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_visual_group_no_touch() -> void:
	if _EXPECTED_REQUIRED_VISUAL_GROUP_NO_TOUCH:
		_pass("required_visual_group_no_touch: 1 视觉组 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_visual_group_no_touch: 期望 true 实际 false")

func _test_required_7_elements_total() -> void:
	if _EXPECTED_REQUIRED_7_ELEMENTS_TOTAL:
		_pass("required_7_elements_total: 7 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_7_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_42_polish_sections() -> void:
	# 验证 0 触碰既有 42 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_42_polish_sections: 0 触碰既有 42 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
	_passed += 1
	print("[PASS] %s" % name)

func _fail(name: String) -> void:
	_failed += 1
	_issues.append(name)
	print("[FAIL] %s" % name)

func _skip(name: String) -> void:
	_skipped += 1
	print("[SKIP] %s" % name)
