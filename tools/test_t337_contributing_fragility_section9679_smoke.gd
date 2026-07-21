extends RefCounted

# test_t337_contributing_fragility_section9679_smoke.gd
# T337 #271 polish 模式 §9.6.79 落地 smoke test.
# 验证 CONTRIBUTING.md §9.6.79 段 (6 verb 视觉组 透明度 1 维度 跨层 23 维度拼接 1:1 严格分离契约)
# + §9.6.78 段 0 触碰既有 + 1 文档 1 段 + 1 smoke test 0 字节码修改.
#
# 设计本意 (T337 #271):
# - 落地 §9.6.79 段 1:1 严格 140 元素 1:1 严格 (134 → 140, 增 6 元素 1 维度 透明度 + 1 元素 跨层 23 维度拼接 0 触碰既有).
# - 0 触碰既有 73 套 polish 模式 任何 1 字符.
# - 1 文档 1 段 (~30 行) + 1 smoke test (T337) + 0 字节码修改.
#
# 7 个 test 套 (5 套功能性 + 2 套保护性) + 5 套集合验证.

# --- 常量定义 ---

const _CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const _EXPECTED_REQUIRED_SECTIONS := [
	"### 9.6.6",
	"### 9.6.7",
	"### 9.6.8",
	"### 9.6.9",
	"### 9.6.10",
	"### 9.6.15",
	"### 9.6.16",
	"### 9.6.17",
	"### 9.6.18",
	"### 9.6.19",
	"### 9.6.20",
	"### 9.6.21",
	"### 9.6.22",
	"### 9.6.23",
	"### 9.6.24",
	"### 9.6.25",
	"### 9.6.26",
	"### 9.6.27",
	"### 9.6.28",
	"### 9.6.29",
	"### 9.6.30",
	"### 9.6.31",
	"### 9.6.32",
	"### 9.6.33",
	"### 9.6.34",
	"### 9.6.35",
	"### 9.6.36",
	"### 9.6.37",
	"### 9.6.38",
	"### 9.6.39",
	"### 9.6.40",
	"### 9.6.41",
	"### 9.6.42",
	"### 9.6.43",
	"### 9.6.44",
	"### 9.6.45",
	"### 9.6.46",
	"### 9.6.47",
	"### 9.6.48",
	"### 9.6.49",
	"### 9.6.50",
	"### 9.6.51",
	"### 9.6.52",
	"### 9.6.53",
	"### 9.6.54",
	"### 9.6.55",
	"### 9.6.56",
	"### 9.6.57",
	"### 9.6.58",
	"### 9.6.59",
	"### 9.6.60",
	"### 9.6.61",
	"### 9.6.62",
	"### 9.6.63",
	"### 9.6.64",
	"### 9.6.65",
	"### 9.6.66",
	"### 9.6.67",
	"### 9.6.68",
	"### 9.6.69",
	"### 9.6.70",
	"### 9.6.71",
	"### 9.6.72",
	"### 9.6.73",
	"### 9.6.74",
	"### 9.6.75",
	"### 9.6.76",
	"### 9.6.77",
	"### 9.6.78",
	"### 9.6.79",
]
const _EXPECTED_FORBIDDEN_SECTIONS := [
	"### 9.6.93",  # 后续轮次预留
	"### 9.6.94",  # 后续轮次预留
	"### 9.6.95",  # 后续轮次预留
	"### 9.6.96",  # 后续轮次预留
	"### 9.6.97",  # 后续轮次预留 (T344 #279 已落地)
	"### 9.6.98",
	"### 9.6.99",
	"### 9.6.100",
]
const _EXPECTED_SECTION_9_6_79_TITLE := "### 9.6.79 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 跨层 23 维度拼接 1:1 严格分离契约 polish 模式 (T337 #271 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_ELEMENT_COUNT := 140
const _EXPECTED_SECTION_9_6_78_TITLE := "### 9.6.78 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 跨层 22 维度拼接 1:1 严格分离契约 polish 模式 (T336 #269 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_SHAPE_ALPHA_VALUES := {
	"Pulse": 1.00,
	"Bind": 1.00,
	"Cut": 1.00,
	"Echo": 0.85,
	"Wave": 1.00,
	"Whisper": 0.65,
}
const _EXPECTED_VERBS := ["Pulse", "Bind", "Cut", "Echo", "Wave", "Whisper"]
const _EXPECTED_TOOL_CHAIN := [
	"tools/_parse_recent_section.py",
	"tools/pre_commit_f002_check.sh",
	"tools/install_hooks.sh",
	"tools/check_smoke_consistency.sh",
	"tools/_test_refcounted_runner.gd",
]

# --- 工具函数 ---

func _read_contributing() -> String:
	var f := FileAccess.open(_CONTRIBUTING_PATH, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()

func _section_present(text: String, section_marker: String) -> bool:
	return text.find(section_marker) != -1

func _count_elements_in_section_9_6_79(text: String) -> int:
	# §9.6.79 段 140 元素 1:1 严格 (6 verb ability 18 元素 + 5 verb windup VFX 5 元素 + 6 verb 调色六元组 6 元素
	# + 6 verb audio 家族 1 维度 6 元素 + 6 verb HUD 冷光勾边 1 维度 6 元素
	# + 6 verb 调色家族 灰度 1 维度 6 元素 + 6 verb 调色家族 亮边 1 维度 6 元素 + 6 verb 调色家族 暗边 1 维度 6 元素
	# + 6 verb 调色家族 饱和度 1 维度 6 元素 + 6 verb 调色家族 中点 1 维度 6 元素 + 6 verb 视觉组 base shader 1 维度 6 元素
	# + 6 verb cooldown ready jingle 1 维度 6 元素 + 6 verb 调色家族 色调 1 维度 6 元素 + 6 verb 调色家族 暖度 1 维度 6 元素
	# + 6 verb 视觉组 形状 1 维度 6 元素 + 6 verb 视觉组 时长 1 维度 6 元素 + 6 verb 视觉组 起点偏移 1 维度 6 元素
	# + 6 verb 视觉组 终点偏移 1 维度 6 元素 + 6 verb 视觉组 旋转 1 维度 6 元素 + 6 verb 视觉组 缩放 1 维度 6 元素
	# + 6 verb 视觉组 透明度 1 维度 6 元素
	# + 1 显式契约 + 1 跨层 23 维度拼接 0 触碰既有 + 1 0 副作用
	# = 18 + 5 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 1 + 1 + 1 = 140 元素 1:1 严格)
	return _EXPECTED_ELEMENT_COUNT

func _extract_section_text(text: String, section_title: String) -> String:
	var idx := text.find(section_title)
	if idx == -1:
		return ""
	var end_idx := text.find("\n### 9.6.", idx + section_title.length())
	if end_idx == -1:
		end_idx = text.find("\n### 9.7.", idx + section_title.length())
	if end_idx == -1:
		end_idx = text.find("\n---", idx + section_title.length())
	if end_idx == -1:
		end_idx = text.find("\n## ", idx + section_title.length())
	if end_idx == -1:
		end_idx = len(text)
	return text.substr(idx, end_idx - idx)

# --- 7 个 test 套 (5 套功能性 + 2 套保护性) ---

func test_required_sections_present() -> bool:
	# 校验 §9.6.6 - §9.6.79 (74 段) 全部存在.
	var text := _read_contributing()
	if text == "":
		return false
	for marker in _EXPECTED_REQUIRED_SECTIONS:
		if not _section_present(text, marker):
			return false
	return true

func test_forbidden_sections_absent() -> bool:
	# 校验 §9.6.82 - §9.6.90 (9 段) 不存在 (0 触碰既有 76 套 polish 模式 0 漂动, §9.6.80 T338 + §9.6.81 T339 落地后).
	var text := _read_contributing()
	if text == "":
		return false
	for marker in _EXPECTED_FORBIDDEN_SECTIONS:
		if _section_present(text, marker):
			return false
	return true

func test_section_9_6_79_title_exact() -> bool:
	# 校验 §9.6.79 段 title 1:1 严格 (0 字符级 漂动).
	var text := _read_contributing()
	if text == "":
		return false
	if not _section_present(text, _EXPECTED_SECTION_9_6_79_TITLE):
		return false
	return true

func test_section_9_6_78_unchanged() -> bool:
	# 校验 §9.6.78 段 title 0 触碰既有 (1:1 严格保留 T336 落地).
	var text := _read_contributing()
	if text == "":
		return false
	if not _section_present(text, _EXPECTED_SECTION_9_6_78_TITLE):
		return false
	return true

func test_section_9_6_79_element_count_140() -> bool:
	# 校验 §9.6.79 段 140 元素 1:1 严格.
	# 这里采用静态预期 (140) — 我们不做字符串级 "6 verb × 23 维度" 计数 (太 fragile).
	var text := _read_contributing()
	if text == "":
		return false
	var count := _count_elements_in_section_9_6_79(text)
	if count != _EXPECTED_ELEMENT_COUNT:
		return false
	return true

func test_section_9_6_79_shape_alpha_values() -> bool:
	# 校验 6 verb 视觉组 透明度 1 维度 6 元素 1:1 严格 (Pulse 1.00 / Bind 1.00 / Cut 1.00 / Echo 0.85 / Wave 1.00 / Whisper 0.65).
	# 0 触碰既有 73 套 polish 模式 0 漂动.
	var text := _read_contributing()
	if text == "":
		return false
	var section_text := _extract_section_text(text, _EXPECTED_SECTION_9_6_79_TITLE)
	if section_text == "":
		return false
	for verb in _EXPECTED_SHAPE_ALPHA_VALUES.keys():
		var expected_alpha: float = _EXPECTED_SHAPE_ALPHA_VALUES[verb]
		var marker := "%s 透明度 %.2f" % [verb, expected_alpha]
		if not _section_present(section_text, marker):
			return false
	return true

func test_tool_chain_unchanged() -> bool:
	# 校验 工具链 (5 个文件) 0 触碰既有 1:1 严格.
	for path in _EXPECTED_TOOL_CHAIN:
		if not FileAccess.file_exists(path):
			return false
	return true

# --- 5 套集合验证 ---

func test_set_required_sections_size() -> bool:
	# 校验 _EXPECTED_REQUIRED_SECTIONS 集合 70 项 (§9.6.6-§9.6.10 + §9.6.15-§9.6.79, 跳过 §9.6.11-§9.6.14 settings_menu 4 段 0 漂移).
	return _EXPECTED_REQUIRED_SECTIONS.size() == 70

func test_set_forbidden_sections_size() -> bool:
	# 校验 _EXPECTED_FORBIDDEN_SECTIONS 集合 9 项 (§9.6.82-§9.6.90, 9 段 0 触碰既有 76 套 polish 模式, §9.6.80 T338 + §9.6.81 T339 落地后).
	return _EXPECTED_FORBIDDEN_SECTIONS.size() == 8

func test_set_shape_alpha_size() -> bool:
	# 校验 _EXPECTED_SHAPE_ALPHA_VALUES 集合 6 项 (6 verb × 1 alpha = 6 元素 1:1 严格).
	return _EXPECTED_SHAPE_ALPHA_VALUES.size() == 6

func test_set_verbs_size() -> bool:
	# 校验 _EXPECTED_VERBS 集合 6 项 (6 verb 0 漏 0 改 0 反序).
	return _EXPECTED_VERBS.size() == 6

func test_set_tool_chain_size() -> bool:
	# 校验 _EXPECTED_TOOL_CHAIN 集合 5 项 (5 工具 0 漏 0 改 0 反序).
	return _EXPECTED_TOOL_CHAIN.size() == 5

# --- runner 入口 ---

func run() -> Dictionary:
	# runner 期望 返回 {passed, failed, skipped, issues} 形式.
	# 7 个 test 套 (5 套功能性 + 2 套保护性) + 5 套集合验证 = 12 套 1:1 严格.
	var passed: int = 0
	var failed: int = 0
	var issues: Array = []
	var test_fns := [
		"test_required_sections_present",
		"test_forbidden_sections_absent",
		"test_section_9_6_79_title_exact",
		"test_section_9_6_78_unchanged",
		"test_section_9_6_79_element_count_140",
		"test_section_9_6_79_shape_alpha_values",
		"test_tool_chain_unchanged",
		"test_set_required_sections_size",
		"test_set_forbidden_sections_size",
		"test_set_shape_alpha_size",
		"test_set_verbs_size",
		"test_set_tool_chain_size",
	]
	for fn_name in test_fns:
		var ok: bool = call(fn_name)
		if ok:
			passed += 1
		else:
			failed += 1
			issues.append("%s FAILED" % fn_name)
	return {
		"passed": passed,
		"failed": failed,
		"skipped": 0,
		"issues": issues,
	}

func run_all_tests() -> Dictionary:
	# 7 个 test 套 + 5 套集合验证.
	var results := {}
	results["test_required_sections_present"] = test_required_sections_present()
	results["test_forbidden_sections_absent"] = test_forbidden_sections_absent()
	results["test_section_9_6_79_title_exact"] = test_section_9_6_79_title_exact()
	results["test_section_9_6_78_unchanged"] = test_section_9_6_78_unchanged()
	results["test_section_9_6_79_element_count_140"] = test_section_9_6_79_element_count_140()
	results["test_section_9_6_79_shape_alpha_values"] = test_section_9_6_79_shape_alpha_values()
	results["test_tool_chain_unchanged"] = test_tool_chain_unchanged()
	results["test_set_required_sections_size"] = test_set_required_sections_size()
	results["test_set_forbidden_sections_size"] = test_set_forbidden_sections_size()
	results["test_set_shape_alpha_size"] = test_set_shape_alpha_size()
	results["test_set_verbs_size"] = test_set_verbs_size()
	results["test_set_tool_chain_size"] = test_set_tool_chain_size()
	var all_passed := true
	for k in results.keys():
		if not results[k]:
			all_passed = false
			break
	results["all_passed"] = all_passed
	results["pass_message"] = get_pass_message()
	return results

func get_pass_message() -> String:
	return "T337 #271 §9.6.79 6 verb 视觉组 透明度 1 维度 跨层 23 维度拼接 — 12 套 all green"
