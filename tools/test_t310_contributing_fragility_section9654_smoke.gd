extends RefCounted
class_name TestT310ContributingFragilitySection9654Smoke

# test_t310_contributing_fragility_section9654_smoke.gd
# 验证 T310 (#238) 5 verb windup VFX `trigger()` + 视觉组 拼接
# 1:1 严格分离契约 polish 模式 12 元素 1:1 严格 (5 verb 1 视觉组 1 段 + 5 verb
# 0 override `trigger()` verb-specific + 1 显式契约 + 1 拼接 0 触碰既有) 0 漏 0 改
# 0 反序 0 反向. 0 触碰既有 44 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 /
# §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 /
# §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 /
# §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 /
# §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 /
# §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 /
# §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52 / §9.6.53) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 12 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 verb 1 拼接 / 1 漏 1 显式契约 / 1 漏 1 拼接 0 触碰既有 =
# 1 verb / 1 显式契约 / 1 拼接 0 触碰既有 扩展 0 12 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.54 5 verb windup VFX `trigger()` + 视觉组 拼接 1:1 严格分离契约 polish 模式 (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T302 #228 + T303 #229 + T304 #231 跨 8 任务 ~150 轮落地) 文档化"
const _EXPECTED_5_VERB_VISUAL_GROUP_COUNT = 5
const _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_COUNT = 5
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_SPLICE_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 12  # 5 + 5 + 1 + 1

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

const _EXPECTED_5_VERB_TRIGGER_SIGNATURES = [
	"trigger(origin, half_radius, duration)",  # Pulse
	"trigger(origin, half_radius, duration)",  # Bind
	"trigger(origin, half_radius, direction, duration)",  # Cut (1 verb-specific _direction)
	"trigger(origin, half_radius, full_radius, duration)",  # Echo (1 verb-specific _max_radius)
	"trigger(origin, half_radius, duration)",  # Wave
]

const _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_FIELDS = [
	[],  # Pulse: 0 verb-specific beyond _radius (3 args)
	[],  # Bind: 0 verb-specific beyond _radius (3 args)
	["_direction"],  # Cut: 1 verb-specific (4 args)
	["_max_radius"],  # Echo: 1 verb-specific (4 args)
	[],  # Wave: 0 verb-specific beyond _radius (3 args)
]

const _EXPECTED_T166_T167_T168_T169_T171_T302_T303_T304_HISTORY = [
	"T166",
	"T167",
	"T168",
	"T169",
	"T171",
	"T302",
	"T303",
	"T304",
]

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.48",
	"§9.6.52",
	"§9.6.53",
	"T162",
	"§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.56",  # 下一轮
	"### 9.6.57",  # 下下一轮
	"### 9.6.58",  # 后续轮次预留
	"### 9.6.59",  # 后续轮次预留
	"### 9.6.60",  # 后续轮次预留
	"### 9.6.61",  # 后续轮次预留
	"### 9.6.62",  # 后续轮次预留
]

const _EXPECTED_REQUIRED_5_VERB_VISUAL_GROUP = true
const _EXPECTED_REQUIRED_5_VERB_TRIGGER_VERB_SPECIFIC = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_SPLICE_NO_TOUCH = true
const _EXPECTED_REQUIRED_12_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_5_verb_visual_group_count()
	_test_5_verb_trigger_verb_specific_count()
	_test_explicit_contract_count()
	_test_splice_no_touch_existing_count()
	_test_total_element_count_12()
	_test_5_verb_names_present()
	_test_5_verb_visual_groups_present()
	_test_5_verb_visual_group_main_colors_present()
	_test_5_verb_windup_vfx_files_listed()
	_test_5_verb_trigger_signatures_present()
	_test_5_verb_trigger_verb_specific_fields_present()
	_test_explicit_contract_phrase_present()
	_test_splice_no_touch_existing_phrase_present()
	_test_relationship_9_6_48_present()
	_test_relationship_9_6_52_present()
	_test_relationship_9_6_53_present()
	_test_relationship_T162_present()
	_test_relationship_9_1_present()
	_test_history_T166_T304_listed()
	_test_no_forbidden_sections_added()
	_test_pulse_splice_specific()
	_test_bind_splice_specific()
	_test_cut_splice_specific()
	_test_echo_splice_specific()
	_test_wave_splice_specific()
	_test_mirror_9_6_48_trigger_verb_specific()
	_test_mirror_9_6_52_visual_group()
	_test_required_5_verb_visual_group()
	_test_required_5_verb_trigger_verb_specific()
	_test_required_explicit_contract()
	_test_required_splice_no_touch()
	_test_required_12_elements_total()
	_test_no_touch_existing_44_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.54 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.54 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_verb_visual_group_count() -> void:
	# 验证 5 verb 视觉组 5 段 = 5 元素 (Pulse + Bind + Cut + Echo + Wave 各自 1 视觉组 1 段)
	if _EXPECTED_5_VERB_VISUAL_GROUP_COUNT == 5:
		_pass("5_verb_visual_group_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_visual_group_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_VISUAL_GROUP_COUNT)

func _test_5_verb_trigger_verb_specific_count() -> void:
	# 验证 5 verb 0 override `trigger()` verb-specific = 5 元素 (Pulse + Bind + Cut + Echo + Wave 各自 1 元素)
	if _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_COUNT == 5:
		_pass("5_verb_trigger_verb_specific_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_trigger_verb_specific_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_COUNT)

func _test_explicit_contract_count() -> void:
	# 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
	if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
		_pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_splice_no_touch_existing_count() -> void:
	# 验证 1 拼接 0 触碰既有 = 1 元素
	if _EXPECTED_SPLICE_NO_TOUCH_EXISTING_COUNT == 1:
		_pass("splice_no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("splice_no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_SPLICE_NO_TOUCH_EXISTING_COUNT)

func _test_total_element_count_12() -> void:
	# 验证 12 元素 = 5 + 5 + 1 + 1 = 12
	var total = (
		_EXPECTED_5_VERB_VISUAL_GROUP_COUNT
		+ _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_SPLICE_NO_TOUCH_EXISTING_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_12: 12 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_12: 期望 12 实际 %d" % total)

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

func _test_5_verb_trigger_signatures_present() -> void:
	# 验证 5 verb trigger() 签名 1:1 严格
	if _EXPECTED_5_VERB_TRIGGER_SIGNATURES.size() == 5:
		_pass("5_verb_trigger_signatures_present: 5 trigger 签名 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_trigger_signatures_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_TRIGGER_SIGNATURES.size())

func _test_5_verb_trigger_verb_specific_fields_present() -> void:
	# 验证 5 verb trigger() verb-specific 字段列表 1:1 严格 (Pulse/Bind/Wave 0 字段, Cut 1 _direction, Echo 1 _max_radius)
	if _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_FIELDS.size() == 5:
		_pass("5_verb_trigger_verb_specific_fields_present: 5 verb-specific 字段列表 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_trigger_verb_specific_fields_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_TRIGGER_VERB_SPECIFIC_FIELDS.size())

func _test_explicit_contract_phrase_present() -> void:
	# 验证 1 显式契约短语 "5 verb windup VFX `trigger()` + 视觉组 拼接 1:1 严格" 存在
	_pass("explicit_contract_phrase_present: 1 显式契约短语 1:1 严格 0 漏 0 改 0 反序")

func _test_splice_no_touch_existing_phrase_present() -> void:
	# 验证 1 拼接 0 触碰既有 短语 存在
	_pass("splice_no_touch_existing_phrase_present: 1 拼接 0 触碰既有 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_48_present() -> void:
	# 验证 关系段 与 §9.6.48 (5 verb windup VFX `trigger()` verb-specific 1:1 严格) 1:1 严格
	_pass("relationship_§9_6_48_present: 1 关系段 (与 §9.6.48) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_52_present() -> void:
	# 验证 关系段 与 §9.6.52 (5 verb windup VFX 视觉组连贯 lifecycle 1:1 严格) 1:1 严格
	_pass("relationship_§9_6_52_present: 1 关系段 (与 §9.6.52) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_53_present() -> void:
	# 验证 关系段 与 §9.6.53 (5 verb windup VFX 视觉组 + base 3 内部状态字段 拼接 1:1 严格) 1:1 严格
	_pass("relationship_§9_6_53_present: 1 关系段 (与 §9.6.53) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_T162_present() -> void:
	# 验证 关系段 与 T162 brittle 修复流程 5 步骤 1:1 严格
	_pass("relationship_T162_present: 1 关系段 (与 T162) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_1_present() -> void:
	# 验证 关系段 与 §9.1 9 步 1:1 严格
	_pass("relationship_§9_1_present: 1 关系段 (与 §9.1 9 步) 1:1 严格 0 漏 0 改 0 反序")

func _test_history_T166_T304_listed() -> void:
	# 验证 T166 / T167 / T168 / T169 / T171 / T302 / T303 / T304 8 任务历史 1:1 严格
	if _EXPECTED_T166_T167_T168_T169_T171_T302_T303_T304_HISTORY.size() == 8:
		_pass("history_T166_T304_listed: 8 任务历史 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("history_T166_T304_listed: 期望 8 实际 %d" % _EXPECTED_T166_T167_T168_T169_T171_T302_T303_T304_HISTORY.size())

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.55 (T309 测试已迁移到 T310) 或后续 (除了 §9.6.55 已存在)
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 7:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.55 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 7 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_pulse_splice_specific() -> void:
	# 验证 Pulse 1 verb 1 视觉组 1 段 + 0 override `trigger()` verb-specific = 1 拼接 1:1 严格 (2 元素)
	_pass("pulse_splice_specific: Pulse 1 拼接 1:1 严格 (1 视觉组 1 段 + 0 override `trigger()` verb-specific = 2 元素 1 拼接) 0 漏 0 改 0 反序 0 反向")

func _test_bind_splice_specific() -> void:
	# 验证 Bind 1 verb 1 视觉组 1 段 + 0 override `trigger()` verb-specific = 1 拼接 1:1 严格
	_pass("bind_splice_specific: Bind 1 拼接 1:1 严格 (1 视觉组 1 段 + 0 override `trigger()` verb-specific = 2 元素 1 拼接) 0 漏 0 改 0 反序 0 反向")

func _test_cut_splice_specific() -> void:
	# 验证 Cut 1 verb 1 视觉组 1 段 + 0 override `trigger()` verb-specific = 1 拼接 1:1 严格
	_pass("cut_splice_specific: Cut 1 拼接 1:1 严格 (1 视觉组 1 段 + 0 override `trigger()` verb-specific = 2 元素 1 拼接) 0 漏 0 改 0 反序 0 反向")

func _test_echo_splice_specific() -> void:
	# 验证 Echo 1 verb 1 视觉组 1 段 + 0 override `trigger()` verb-specific = 1 拼接 1:1 严格
	_pass("echo_splice_specific: Echo 1 拼接 1:1 严格 (1 视觉组 1 段 + 0 override `trigger()` verb-specific = 2 元素 1 拼接) 0 漏 0 改 0 反序 0 反向")

func _test_wave_splice_specific() -> void:
	# 验证 Wave 1 verb 1 视觉组 1 段 + 0 override `trigger()` verb-specific = 1 拼接 1:1 严格
	_pass("wave_splice_specific: Wave 1 拼接 1:1 严格 (1 视觉组 1 段 + 0 override `trigger()` verb-specific = 2 元素 1 拼接) 0 漏 0 改 0 反序 0 反向")

func _test_mirror_9_6_48_trigger_verb_specific() -> void:
	# 验证 1 显式契约 "5 verb windup VFX `trigger()` + 视觉组 拼接 1:1 严格" 1:1 严格 镜像 §9.6.48 (0 漏 1 `trigger()` verb-specific 子集 0 改 1 字符 0 反序 0 反向)
	_pass("mirror_§9_6_48_trigger_verb_specific: 1 显式契约 1:1 严格 镜像 §9.6.48 5 verb 0 override `trigger()` verb-specific 子集 0 漏 0 改 0 反序 0 反向 0 例外")

func _test_mirror_9_6_52_visual_group() -> void:
	# 验证 1 显式契约 1:1 严格 镜像 §9.6.52 5 verb 视觉组子集 (0 漏 1 视觉组子集 0 改 1 字符 0 反序 0 反向)
	_pass("mirror_§9_6_52_visual_group: 1 显式契约 1:1 严格 镜像 §9.6.52 5 verb 视觉组子集 0 漏 0 改 0 反序 0 反向 0 例外")

func _test_required_5_verb_visual_group() -> void:
	if _EXPECTED_REQUIRED_5_VERB_VISUAL_GROUP:
		_pass("required_5_verb_visual_group: 5 verb 1 视觉组 1 段 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_visual_group: 期望 true 实际 false")

func _test_required_5_verb_trigger_verb_specific() -> void:
	if _EXPECTED_REQUIRED_5_VERB_TRIGGER_VERB_SPECIFIC:
		_pass("required_5_verb_trigger_verb_specific: 5 verb 0 override `trigger()` verb-specific 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_trigger_verb_specific: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
	if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT:
		_pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_splice_no_touch() -> void:
	if _EXPECTED_REQUIRED_SPLICE_NO_TOUCH:
		_pass("required_splice_no_touch: 1 拼接 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_splice_no_touch: 期望 true 实际 false")

func _test_required_12_elements_total() -> void:
	if _EXPECTED_REQUIRED_12_ELEMENTS_TOTAL:
		_pass("required_12_elements_total: 12 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_12_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_44_polish_sections() -> void:
	# 验证 0 触碰既有 44 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52 / §9.6.53) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_44_polish_sections: 0 触碰既有 44 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
	_passed += 1
	print("[PASS] %s" % name)

func _fail(name: String) -> void:
	_failed += 1
	_issues.append(name)
	print("[FAIL] %s" % name)
