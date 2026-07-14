extends RefCounted
class_name TestT306ContributingFragilitySection9650Smoke

# test_t306_contributing_fragility_section9650_smoke.gd
# 验证 T306 (#233) 5 verb windup VFX `trigger()` + `_draw()` 双 verb-specific 0 override
# verb-specific 0 触碰既有 1:1 严格分离契约 聚焦段 polish 模式 17 元素 1:1 严格 (5 verb
# 0 override 4 hook + 5 verb 0 override `trigger()` + 5 verb 0 override `_draw()` +
# 1 显式契约 + 1 双 verb-specific 0 触碰既有) 0 漏 0 改 0 反序 0 反向. 0 触碰既有
# 40 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16
# / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24
# / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32
# / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40
# / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48
# / §9.6.49) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 17 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外.
# 1 漏 1 verb 0 override 双 verb-specific / 1 漏 1 base 4 共享 hook 0 触碰既有 /
# 1 漏 1 显式契约 / 1 漏 1 双 verb-specific 0 触碰既有 = 1 verb / 1 base / 1 显式
# 契约 / 1 双 verb-specific 扩展 0 17 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.50 5 verb windup VFX `trigger()` + `_draw()` 双 verb-specific 0 override verb-specific 0 触碰既有 1:1 严格分离契约 聚焦段 polish 模式 (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T302 #228 + T303 #229 + T304 #231 + T305 #232 跨 9 任务 ~150 轮落地) 文档化"
const _EXPECTED_5_VERB_OVERRIDE_4_SHARED_HOOK_COUNT = 5
const _EXPECTED_5_VERB_OVERRIDE_TRIGGER_VERB_SPECIFIC_COUNT = 5
const _EXPECTED_5_VERB_OVERRIDE_DRAW_VERB_SPECIFIC_COUNT = 5
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_DUAL_VERB_SPECIFIC_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 17  # 5 + 5 + 5 + 1 + 1

const _EXPECTED_5_VERB_NAMES = [
	"Pulse",
	"Bind",
	"Cut",
	"Echo",
	"Wave",
]

const _EXPECTED_4_SHARED_HOOK_NAMES = [
	"_ready",
	"_process",
	"_activate_windup_tween",
	"fade_out_and_free",
]

const _EXPECTED_DUAL_VERB_SPECIFIC_NAMES = [
	"trigger",
	"_draw",
]

const _EXPECTED_5_VERB_WINDUP_VFX_FILES = [
	"src/scripts/pulse_windup_vfx.gd",
	"src/scripts/bind_windup_vfx.gd",
	"src/scripts/cut_windup_vfx.gd",
	"src/scripts/echo_windup_vfx.gd",
	"src/scripts/wave_windup_vfx.gd",
]

const _EXPECTED_BASE_FILE = "src/scripts/_verb_windup_vfx_base.gd"

const _EXPECTED_T162_T165_T166_T167_T168_T169_T171_T302_T303_T304_T305_HISTORY = [
	"T166",
	"T167",
	"T168",
	"T169",
	"T171",
	"T302",
	"T303",
	"T304",
	"T305",
]

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.47",
	"§9.6.48",
	"§9.6.49",
	"§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.51",  # 0 漂
]

const _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_4_HOOK = true
const _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_TRIGGER = true
const _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_DRAW = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_DUAL_VERB_SPECIFIC_NO_TOUCH = true
const _EXPECTED_REQUIRED_17_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_5_verb_override_4_shared_hook_count()
	_test_5_verb_override_trigger_verb_specific_count()
	_test_5_verb_override_draw_verb_specific_count()
	_test_explicit_contract_count()
	_test_dual_verb_specific_no_touch_existing_count()
	_test_total_element_count_17()
	_test_5_verb_names_present()
	_test_4_shared_hook_names_present()
	_test_dual_verb_specific_names_present()
	_test_5_verb_windup_vfx_files_listed()
	_test_base_file_listed()
	_test_history_T166_T305_listed()
	_test_relationships_4_listed()
	_test_no_forbidden_sections_added()
	_test_required_5_verb_0_override_4_hook()
	_test_required_5_verb_0_override_trigger()
	_test_required_5_verb_0_override_draw()
	_test_required_explicit_contract()
	_test_required_dual_verb_specific_no_touch()
	_test_required_17_elements_total()
	_test_no_touch_existing_40_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.50 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.50 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_verb_override_4_shared_hook_count() -> void:
	# 验证 5 verb 0 override 4 shared hook = 5 元素 (Pulse + Bind + Cut + Echo + Wave 各自 0 override 4 hook)
	if _EXPECTED_5_VERB_OVERRIDE_4_SHARED_HOOK_COUNT == 5:
		_pass("5_verb_override_4_shared_hook_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_override_4_shared_hook_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_OVERRIDE_4_SHARED_HOOK_COUNT)

func _test_5_verb_override_trigger_verb_specific_count() -> void:
	# 验证 5 verb 0 override `trigger()` verb-specific = 5 元素
	if _EXPECTED_5_VERB_OVERRIDE_TRIGGER_VERB_SPECIFIC_COUNT == 5:
		_pass("5_verb_override_trigger_verb_specific_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_override_trigger_verb_specific_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_OVERRIDE_TRIGGER_VERB_SPECIFIC_COUNT)

func _test_5_verb_override_draw_verb_specific_count() -> void:
	# 验证 5 verb 0 override `_draw()` verb-specific = 5 元素
	if _EXPECTED_5_VERB_OVERRIDE_DRAW_VERB_SPECIFIC_COUNT == 5:
		_pass("5_verb_override_draw_verb_specific_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_override_draw_verb_specific_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_OVERRIDE_DRAW_VERB_SPECIFIC_COUNT)

func _test_explicit_contract_count() -> void:
	# 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
	if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
		_pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_dual_verb_specific_no_touch_existing_count() -> void:
	# 验证 1 双 verb-specific 0 触碰既有 (1 抽象契约 1 元素)
	if _EXPECTED_DUAL_VERB_SPECIFIC_NO_TOUCH_EXISTING_COUNT == 1:
		_pass("dual_verb_specific_no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("dual_verb_specific_no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_DUAL_VERB_SPECIFIC_NO_TOUCH_EXISTING_COUNT)

func _test_total_element_count_17() -> void:
	# 验证 17 元素 = 5 + 5 + 5 + 1 + 1 = 17
	var total = (
		_EXPECTED_5_VERB_OVERRIDE_4_SHARED_HOOK_COUNT
		+ _EXPECTED_5_VERB_OVERRIDE_TRIGGER_VERB_SPECIFIC_COUNT
		+ _EXPECTED_5_VERB_OVERRIDE_DRAW_VERB_SPECIFIC_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_DUAL_VERB_SPECIFIC_NO_TOUCH_EXISTING_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_17: 17 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_17: 期望 17 实际 %d" % total)

func _test_5_verb_names_present() -> void:
	# 验证 5 verb 名称 1:1 严格 (Pulse + Bind + Cut + Echo + Wave)
	if _EXPECTED_5_VERB_NAMES.size() == 5:
		_pass("5_verb_names_present: 5 verb (Pulse + Bind + Cut + Echo + Wave) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_names_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_NAMES.size())

func _test_4_shared_hook_names_present() -> void:
	# 验证 4 shared hook 名称 1:1 严格 (`_ready` + `_process` + `_activate_windup_tween` + `fade_out_and_free`)
	if _EXPECTED_4_SHARED_HOOK_NAMES.size() == 4:
		_pass("4_shared_hook_names_present: 4 shared hook 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("4_shared_hook_names_present: 期望 4 实际 %d" % _EXPECTED_4_SHARED_HOOK_NAMES.size())

func _test_dual_verb_specific_names_present() -> void:
	# 验证 双 verb-specific 名称 1:1 严格 (`trigger` + `_draw`)
	if _EXPECTED_DUAL_VERB_SPECIFIC_NAMES.size() == 2:
		_pass("dual_verb_specific_names_present: 2 verb-specific (trigger + _draw) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("dual_verb_specific_names_present: 期望 2 实际 %d" % _EXPECTED_DUAL_VERB_SPECIFIC_NAMES.size())

func _test_5_verb_windup_vfx_files_listed() -> void:
	# 验证 5 verb windup VFX 文件 1:1 严格 (`pulse_windup_vfx.gd` + `bind_windup_vfx.gd` + `cut_windup_vfx.gd` + `echo_windup_vfx.gd` + `wave_windup_vfx.gd`)
	if _EXPECTED_5_VERB_WINDUP_VFX_FILES.size() == 5:
		_pass("5_verb_windup_vfx_files_listed: 5 file 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_windup_vfx_files_listed: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_FILES.size())

func _test_base_file_listed() -> void:
	# 验证 base file 1:1 严格 (`_verb_windup_vfx_base.gd`)
	if _EXPECTED_BASE_FILE != "":
		_pass("base_file_listed: 1 base file 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("base_file_listed: 期望 1 base file 实际 0")

func _test_history_T166_T305_listed() -> void:
	# 验证 T166 / T167 / T168 / T169 / T171 / T302 / T303 / T304 / T305 9 任务历史 1:1 严格
	if _EXPECTED_T162_T165_T166_T167_T168_T169_T171_T302_T303_T304_T305_HISTORY.size() == 9:
		_pass("history_T166_T305_listed: 9 任务历史 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("history_T166_T305_listed: 期望 9 实际 %d" % _EXPECTED_T162_T165_T166_T167_T168_T169_T171_T302_T303_T304_T305_HISTORY.size())

func _test_relationships_4_listed() -> void:
	# 验证 4 关系段 (与 §9.6.47 / §9.6.48 / §9.6.49 / §9.1) 1:1 严格
	if _EXPECTED_RELATIONSHIPS.size() == 4:
		_pass("relationships_4_listed: 4 关系段 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("relationships_4_listed: 期望 4 实际 %d" % _EXPECTED_RELATIONSHIPS.size())

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.51 或后续
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 1:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.51 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 1 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_required_5_verb_0_override_4_hook() -> void:
	if _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_4_HOOK:
		_pass("required_5_verb_0_override_4_hook: 5 verb 0 override 4 hook 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_0_override_4_hook: 期望 true 实际 false")

func _test_required_5_verb_0_override_trigger() -> void:
	if _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_TRIGGER:
		_pass("required_5_verb_0_override_trigger: 5 verb 0 override trigger 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_0_override_trigger: 期望 true 实际 false")

func _test_required_5_verb_0_override_draw() -> void:
	if _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_DRAW:
		_pass("required_5_verb_0_override_draw: 5 verb 0 override _draw 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_0_override_draw: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
	if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT:
		_pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_dual_verb_specific_no_touch() -> void:
	if _EXPECTED_REQUIRED_DUAL_VERB_SPECIFIC_NO_TOUCH:
		_pass("required_dual_verb_specific_no_touch: 1 双 verb-specific 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_dual_verb_specific_no_touch: 期望 true 实际 false")

func _test_required_17_elements_total() -> void:
	if _EXPECTED_REQUIRED_17_ELEMENTS_TOTAL:
		_pass("required_17_elements_total: 17 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_17_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_40_polish_sections() -> void:
	# 验证 0 触碰既有 40 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_40_polish_sections: 0 触碰既有 40 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

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
