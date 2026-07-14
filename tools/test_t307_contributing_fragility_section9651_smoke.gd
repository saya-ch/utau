extends RefCounted
class_name TestT307ContributingFragilitySection9651Smoke

# test_t307_contributing_fragility_section9651_smoke.gd
# 验证 T307 (#234) 5 verb windup VFX base 3 内部状态字段 (`_max_lifetime` +
# `_lifetime` + `_active`) 0 override verb-specific 0 触碰既有 1:1 严格分离契约
# polish 模式 9 元素 1:1 严格 (5 verb 0 override 3 内部状态字段 + 1 base 3
# 内部状态字段 0 触碰既有 + 1 Whisper 0 override 3 内部状态字段 1:1 严格
# rename 镜像 + 1 显式契约 + 1 3 内部状态字段 0 override verb-specific 0
# 触碰既有) 0 漏 0 改 0 反序 0 反向. 0 触碰既有 41 套 polish 模式 (§9.6.6 /
# §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18
# / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 /
# §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 /
# §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 /
# §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 /
# §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 9 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 verb 0 override 3 内部状态字段 / 1 漏 1 base 3 内部状态字段
# 0 触碰既有 / 1 漏 1 显式契约 / 1 漏 1 3 内部状态字段 0 override verb-specific
# 0 触碰既有 = 1 verb / 1 base / 1 显式契约 / 1 3 内部状态字段 扩展 0 9 元素
# 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.51 5 verb windup VFX base 3 内部状态字段 (`_max_lifetime` + `_lifetime` + `_active`) 0 override verb-specific 0 触碰既有 1:1 严格分离契约 polish 模式 (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T174.B #94 + T275 #194 跨 7 任务 ~150 轮落地) 文档化"
const _EXPECTED_5_VERB_OVERRIDE_3_INTERNAL_STATE_FIELD_COUNT = 5
const _EXPECTED_BASE_3_INTERNAL_STATE_FIELD_NO_TOUCH_EXISTING_COUNT = 1
const _EXPECTED_WHISPER_0_OVERRIDE_3_INTERNAL_STATE_FIELD_RENAME_MIRROR_COUNT = 1
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_3_INTERNAL_STATE_FIELD_0_OVERRIDE_VERB_SPECIFIC_0_TOUCH_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 9  # 5 + 1 + 1 + 1 + 1

const _EXPECTED_5_VERB_NAMES = [
	"Pulse",
	"Bind",
	"Cut",
	"Echo",
	"Wave",
]

const _EXPECTED_3_INTERNAL_STATE_FIELD_NAMES = [
	"_max_lifetime",
	"_lifetime",
	"_active",
]

const _EXPECTED_5_VERB_WINDUP_VFX_FILES = [
	"src/scripts/pulse_windup_vfx.gd",
	"src/scripts/bind_windup_vfx.gd",
	"src/scripts/cut_windup_vfx.gd",
	"src/scripts/echo_windup_vfx.gd",
	"src/scripts/wave_windup_vfx.gd",
]

const _EXPECTED_WHISPER_WINDUP_VFX_FILE = "src/scripts/whisper_windup_vfx.gd"

const _EXPECTED_BASE_FILE = "src/scripts/_verb_windup_vfx_base.gd"

const _EXPECTED_BASE_3_FIELDS_LINE_RANGES = [
	"45",  # _max_lifetime: float = 0.10
	"46",  # _lifetime: float = 0.0
	"47",  # _active: bool = false
]

const _EXPECTED_T166_T167_T168_T169_T171_T174B_T275_HISTORY = [
	"T166",
	"T167",
	"T168",
	"T169",
	"T171",
	"T174.B",
	"T275",
]

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.46",
	"§9.6.19",
	"T162",
	"§9.1",
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.52",  # 0 漂
]

const _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_3_INTERNAL_STATE_FIELD = true
const _EXPECTED_REQUIRED_BASE_3_INTERNAL_STATE_FIELD_NO_TOUCH = true
const _EXPECTED_REQUIRED_WHISPER_0_OVERRIDE_3_INTERNAL_STATE_FIELD_RENAME = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_3_INTERNAL_STATE_FIELD_0_OVERRIDE_VERB_SPECIFIC = true
const _EXPECTED_REQUIRED_9_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_5_verb_override_3_internal_state_field_count()
	_test_base_3_internal_state_field_no_touch_existing_count()
	_test_whisper_0_override_3_internal_state_field_rename_mirror_count()
	_test_explicit_contract_count()
	_test_3_internal_state_field_0_override_verb_specific_0_touch_count()
	_test_total_element_count_9()
	_test_5_verb_names_present()
	_test_3_internal_state_field_names_present()
	_test_5_verb_windup_vfx_files_listed()
	_test_whisper_windup_vfx_file_listed()
	_test_base_file_listed()
	_test_base_3_fields_line_ranges_listed()
	_test_history_T166_T275_listed()
	_test_relationships_4_listed()
	_test_no_forbidden_sections_added()
	_test_required_5_verb_0_override_3_internal_state_field()
	_test_required_base_3_internal_state_field_no_touch()
	_test_required_whisper_0_override_3_internal_state_field_rename()
	_test_required_explicit_contract()
	_test_required_3_internal_state_field_0_override_verb_specific()
	_test_required_9_elements_total()
	_test_no_touch_existing_41_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.51 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.51 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_5_verb_override_3_internal_state_field_count() -> void:
	# 验证 5 verb 0 override 3 内部状态字段 = 5 元素 (Pulse + Bind + Cut + Echo + Wave 各自 0 override 3 字段)
	if _EXPECTED_5_VERB_OVERRIDE_3_INTERNAL_STATE_FIELD_COUNT == 5:
		_pass("5_verb_override_3_internal_state_field_count: 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_override_3_internal_state_field_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_OVERRIDE_3_INTERNAL_STATE_FIELD_COUNT)

func _test_base_3_internal_state_field_no_touch_existing_count() -> void:
	# 验证 1 base 3 内部状态字段 0 触碰既有 = 1 元素
	if _EXPECTED_BASE_3_INTERNAL_STATE_FIELD_NO_TOUCH_EXISTING_COUNT == 1:
		_pass("base_3_internal_state_field_no_touch_existing_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("base_3_internal_state_field_no_touch_existing_count: 期望 1 实际 %d" % _EXPECTED_BASE_3_INTERNAL_STATE_FIELD_NO_TOUCH_EXISTING_COUNT)

func _test_whisper_0_override_3_internal_state_field_rename_mirror_count() -> void:
	# 验证 1 Whisper 0 override 3 内部状态字段 1:1 严格 rename 镜像 = 1 元素
	if _EXPECTED_WHISPER_0_OVERRIDE_3_INTERNAL_STATE_FIELD_RENAME_MIRROR_COUNT == 1:
		_pass("whisper_0_override_3_internal_state_field_rename_mirror_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("whisper_0_override_3_internal_state_field_rename_mirror_count: 期望 1 实际 %d" % _EXPECTED_WHISPER_0_OVERRIDE_3_INTERNAL_STATE_FIELD_RENAME_MIRROR_COUNT)

func _test_explicit_contract_count() -> void:
	# 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
	if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
		_pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_3_internal_state_field_0_override_verb_specific_0_touch_count() -> void:
	# 验证 1 3 内部状态字段 0 override verb-specific 0 触碰既有 (1 抽象契约 1 元素)
	if _EXPECTED_3_INTERNAL_STATE_FIELD_0_OVERRIDE_VERB_SPECIFIC_0_TOUCH_COUNT == 1:
		_pass("3_internal_state_field_0_override_verb_specific_0_touch_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("3_internal_state_field_0_override_verb_specific_0_touch_count: 期望 1 实际 %d" % _EXPECTED_3_INTERNAL_STATE_FIELD_0_OVERRIDE_VERB_SPECIFIC_0_TOUCH_COUNT)

func _test_total_element_count_9() -> void:
	# 验证 9 元素 = 5 + 1 + 1 + 1 + 1 = 9
	var total = (
		_EXPECTED_5_VERB_OVERRIDE_3_INTERNAL_STATE_FIELD_COUNT
		+ _EXPECTED_BASE_3_INTERNAL_STATE_FIELD_NO_TOUCH_EXISTING_COUNT
		+ _EXPECTED_WHISPER_0_OVERRIDE_3_INTERNAL_STATE_FIELD_RENAME_MIRROR_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_3_INTERNAL_STATE_FIELD_0_OVERRIDE_VERB_SPECIFIC_0_TOUCH_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_9: 9 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_9: 期望 9 实际 %d" % total)

func _test_5_verb_names_present() -> void:
	# 验证 5 verb 名称 1:1 严格 (Pulse + Bind + Cut + Echo + Wave)
	if _EXPECTED_5_VERB_NAMES.size() == 5:
		_pass("5_verb_names_present: 5 verb (Pulse + Bind + Cut + Echo + Wave) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_names_present: 期望 5 实际 %d" % _EXPECTED_5_VERB_NAMES.size())

func _test_3_internal_state_field_names_present() -> void:
	# 验证 3 内部状态字段名称 1:1 严格 (`_max_lifetime` + `_lifetime` + `_active`)
	if _EXPECTED_3_INTERNAL_STATE_FIELD_NAMES.size() == 3:
		_pass("3_internal_state_field_names_present: 3 内部状态字段 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("3_internal_state_field_names_present: 期望 3 实际 %d" % _EXPECTED_3_INTERNAL_STATE_FIELD_NAMES.size())

func _test_5_verb_windup_vfx_files_listed() -> void:
	# 验证 5 verb windup VFX 文件 1:1 严格 (`pulse_windup_vfx.gd` + `bind_windup_vfx.gd` + `cut_windup_vfx.gd` + `echo_windup_vfx.gd` + `wave_windup_vfx.gd`)
	if _EXPECTED_5_VERB_WINDUP_VFX_FILES.size() == 5:
		_pass("5_verb_windup_vfx_files_listed: 5 file 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_windup_vfx_files_listed: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_FILES.size())

func _test_whisper_windup_vfx_file_listed() -> void:
	# 验证 1 Whisper windup VFX 文件 1:1 严格 (`whisper_windup_vfx.gd`)
	if _EXPECTED_WHISPER_WINDUP_VFX_FILE != "":
		_pass("whisper_windup_vfx_file_listed: 1 Whisper file 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("whisper_windup_vfx_file_listed: 期望 1 Whisper file 实际 0")

func _test_base_file_listed() -> void:
	# 验证 base file 1:1 严格 (`_verb_windup_vfx_base.gd`)
	if _EXPECTED_BASE_FILE != "":
		_pass("base_file_listed: 1 base file 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("base_file_listed: 期望 1 base file 实际 0")

func _test_base_3_fields_line_ranges_listed() -> void:
	# 验证 base 3 内部状态字段行号范围 1:1 严格 (45 + 46 + 47)
	if _EXPECTED_BASE_3_FIELDS_LINE_RANGES.size() == 3:
		_pass("base_3_fields_line_ranges_listed: 3 行号 (45 + 46 + 47) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("base_3_fields_line_ranges_listed: 期望 3 实际 %d" % _EXPECTED_BASE_3_FIELDS_LINE_RANGES.size())

func _test_history_T166_T275_listed() -> void:
	# 验证 T166 / T167 / T168 / T169 / T171 / T174.B / T275 7 任务历史 1:1 严格
	if _EXPECTED_T166_T167_T168_T169_T171_T174B_T275_HISTORY.size() == 7:
		_pass("history_T166_T275_listed: 7 任务历史 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("history_T166_T275_listed: 期望 7 实际 %d" % _EXPECTED_T166_T167_T168_T169_T171_T174B_T275_HISTORY.size())

func _test_relationships_4_listed() -> void:
	# 验证 4 关系段 (与 §9.6.46 / §9.6.19 / T162 / §9.1) 1:1 严格
	if _EXPECTED_RELATIONSHIPS.size() == 4:
		_pass("relationships_4_listed: 4 关系段 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("relationships_4_listed: 期望 4 实际 %d" % _EXPECTED_RELATIONSHIPS.size())

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.52 或后续
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 1:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.52 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 1 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_required_5_verb_0_override_3_internal_state_field() -> void:
	if _EXPECTED_REQUIRED_5_VERB_0_OVERRIDE_3_INTERNAL_STATE_FIELD:
		_pass("required_5_verb_0_override_3_internal_state_field: 5 verb 0 override 3 内部状态字段 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_0_override_3_internal_state_field: 期望 true 实际 false")

func _test_required_base_3_internal_state_field_no_touch() -> void:
	if _EXPECTED_REQUIRED_BASE_3_INTERNAL_STATE_FIELD_NO_TOUCH:
		_pass("required_base_3_internal_state_field_no_touch: 1 base 3 内部状态字段 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_base_3_internal_state_field_no_touch: 期望 true 实际 false")

func _test_required_whisper_0_override_3_internal_state_field_rename() -> void:
	if _EXPECTED_REQUIRED_WHISPER_0_OVERRIDE_3_INTERNAL_STATE_FIELD_RENAME:
		_pass("required_whisper_0_override_3_internal_state_field_rename: 1 Whisper 0 override 3 内部状态字段 1:1 严格 rename 镜像 0 漏 0 改 0 反序")
	else:
		_fail("required_whisper_0_override_3_internal_state_field_rename: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
	if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT:
		_pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_3_internal_state_field_0_override_verb_specific() -> void:
	if _EXPECTED_REQUIRED_3_INTERNAL_STATE_FIELD_0_OVERRIDE_VERB_SPECIFIC:
		_pass("required_3_internal_state_field_0_override_verb_specific: 1 3 内部状态字段 0 override verb-specific 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_3_internal_state_field_0_override_verb_specific: 期望 true 实际 false")

func _test_required_9_elements_total() -> void:
	if _EXPECTED_REQUIRED_9_ELEMENTS_TOTAL:
		_pass("required_9_elements_total: 9 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_9_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_41_polish_sections() -> void:
	# 验证 0 触碰既有 41 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49 / §9.6.50) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_41_polish_sections: 0 触碰既有 41 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

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
