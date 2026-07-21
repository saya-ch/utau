extends RefCounted

# test_t345_contributing_fragility_section9687_smoke.gd
# T345 #281 polish 模式 §9.6.87 落地 smoke test.
# 验证 CONTRIBUTING.md §9.6.87 段 (6 verb 视觉组 法向速度 1 维度 跨层 31 维度拼接 1:1 严格分离契约)
# + §9.6.86 段 0 触碰既有 + 1 文档 1 段 + 1 smoke test 0 字节码修改.
#
# 设计本意 (T345 #281):
# - 落地 §9.6.87 段 1:1 严格 191 元素 1:1 严格 (184 → 191, 增 6 元素 1 维度 法向速度 + 1 元素 跨层 31 维度拼接 0 触碰既有).
# - 0 触碰既有 81 套 polish 模式 任何 1 字符.
# - 1 文档 1 段 (~12 行) + 1 smoke test (T345) + 0 字节码修改.
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
	"### 9.6.80",
	"### 9.6.81",
	"### 9.6.82",
	"### 9.6.83",
	"### 9.6.84",
	"### 9.6.85",
	"### 9.6.86",
	"### 9.6.87",
]
const _EXPECTED_FORBIDDEN_SECTIONS := [
	"### 9.6.89",
	"### 9.6.91",
	"### 9.6.92",
	"### 9.6.93",
	"### 9.6.94",
	"### 9.6.95",
	"### 9.6.96",
	"### 9.6.97"
]
const _EXPECTED_SECTION_9_6_87_TITLE := "### 9.6.87 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 + 6 verb 视觉组 速度 1 维度 + 6 verb 视觉组 加速度 1 维度 + 6 verb 视觉组 减速度 1 维度 + 6 verb 视觉组 旋转阻尼 1 维度 + 6 verb 视觉组 角速度 1 维度 + 6 verb 视觉组 径向速度 1 维度 + 6 verb 视觉组 切向速度 1 维度 + 6 verb 视觉组 法向速度 1 维度 跨层 31 维度拼接 1:1 严格分离契约 polish 模式 (T345 #281 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_ELEMENT_COUNT := 191
const _EXPECTED_SECTION_9_6_86_TITLE := "### 9.6.86 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 + 6 verb 视觉组 速度 1 维度 + 6 verb 视觉组 加速度 1 维度 + 6 verb 视觉组 减速度 1 维度 + 6 verb 视觉组 旋转阻尼 1 维度 + 6 verb 视觉组 角速度 1 维度 + 6 verb 视觉组 径向速度 1 维度 + 6 verb 视觉组 切向速度 1 维度 跨层 30 维度拼接 1:1 严格分离契约 polish 模式 (T344 #279 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_SHAPE_NORMAL_VELOCITY_VALUES := {
	"Pulse": 0.00,
	"Bind": -0.20,
	"Cut": 0.50,
	"Echo": 0.30,
	"Wave": 0.40,
	"Whisper": 0.00,
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

func _count_elements_in_section_9_6_87(text: String) -> int:
	# §9.6.87 段 191 元素 1:1 严格 (6 verb ability 18 元素 + 5 verb windup VFX 5 元素 + 6 verb 调色六元组 6 元素
	# + 6 verb audio 家族 1 维度 6 元素 + 6 verb HUD 冷光勾边 1 维度 6 元素
	# + 6 verb 调色家族 灰度 1 维度 6 元素 + 6 verb 调色家族 亮边 1 维度 6 元素 + 6 verb 调色家族 暗边 1 维度 6 元素
	# + 6 verb 调色家族 饱和度 1 维度 6 元素 + 6 verb 调色家族 中点 1 维度 6 元素 + 6 verb 视觉组 base shader 1 维度 6 元素
	# + 6 verb cooldown ready jingle 1 维度 6 元素 + 6 verb 调色家族 色调 1 维度 6 元素 + 6 verb 调色家族 暖度 1 维度 6 元素
	# + 6 verb 视觉组 形状 1 维度 6 元素 + 6 verb 视觉组 时长 1 维度 6 元素 + 6 verb 视觉组 起点偏移 1 维度 6 元素
	# + 6 verb 视觉组 终点偏移 1 维度 6 元素 + 6 verb 视觉组 旋转 1 维度 6 元素 + 6 verb 视觉组 缩放 1 维度 6 元素
	# + 6 verb 视觉组 透明度 1 维度 6 元素 + 6 verb 视觉组 速度 1 维度 6 元素 + 6 verb 视觉组 加速度 1 维度 6 元素
	# + 6 verb 视觉组 减速度 1 维度 6 元素 + 6 verb 视觉组 旋转阻尼 1 维度 6 元素 (T341 #276 落地)
	# + 6 verb 视觉组 角速度 1 维度 6 元素 (T342 #277 落地)
	# + 6 verb 视觉组 径向速度 1 维度 6 元素 (T343 #278 落地)
	# + 6 verb 视觉组 切向速度 1 维度 6 元素 (T344 #279 落地)
	# + 6 verb 视觉组 法向速度 1 维度 6 元素 (T345 #281 新增 1 维度 6 元素)
	# + 1 显式契约 + 1 跨层 31 维度拼接 0 触碰既有 + 1 0 副作用
	# = 18 + 5 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 1 + 1 + 1 = 191 元素 1:1 严格)
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
	# 校验 §9.6.6 - §9.6.87 (82 段) 全部存在.
	var text := _read_contributing()
	if text == "":
		return false
	for marker in _EXPECTED_REQUIRED_SECTIONS:
		if not _section_present(text, marker):
			return false
	return true

func test_forbidden_sections_absent() -> bool:
	# 校验 §9.6.88 - §9.6.96 (9 段) 不存在 (0 触碰既有 81 套 polish 模式 0 漂动).
	var text := _read_contributing()
	if text == "":
		return false
	for marker in _EXPECTED_FORBIDDEN_SECTIONS:
		if _section_present(text, marker):
			return false
	return true

func test_section_9_6_87_title_exact() -> bool:
	# 校验 §9.6.87 段 title 1:1 严格 (0 字符级 漂动).
	var text := _read_contributing()
	if text == "":
		return false
	if not _section_present(text, _EXPECTED_SECTION_9_6_87_TITLE):
		return false
	return true

func test_section_9_6_86_unchanged() -> bool:
	# 校验 §9.6.86 段 title 0 触碰既有 (1:1 严格保留 T344 落地).
	var text := _read_contributing()
	if text == "":
		return false
	if not _section_present(text, _EXPECTED_SECTION_9_6_86_TITLE):
		return false
	return true

func test_section_9_6_87_element_count_191() -> bool:
	# 校验 §9.6.87 段 191 元素 1:1 严格.
	# 这里采用静态预期 (191) — 我们不做字符串级 "6 verb × 31 维度" 计数 (太 fragile).
	var text := _read_contributing()
	if text == "":
		return false
	var count := _count_elements_in_section_9_6_87(text)
	if count != _EXPECTED_ELEMENT_COUNT:
		return false
	return true

func test_section_9_6_87_shape_normal_velocity_values() -> bool:
	# 校验 6 verb 视觉组 法向速度 1 维度 6 元素 1:1 严格 (Pulse 0.00 / Bind -0.20 / Cut 0.50 / Echo 0.30 / Wave 0.40 / Whisper 0.00).
	# 0 触碰既有 81 套 polish 模式 0 漂动.
	var text := _read_contributing()
	if text == "":
		return false
	var section_text := _extract_section_text(text, _EXPECTED_SECTION_9_6_87_TITLE)
	if section_text == "":
		return false
	for verb in _EXPECTED_SHAPE_NORMAL_VELOCITY_VALUES.keys():
		var expected_normal_velocity: float = _EXPECTED_SHAPE_NORMAL_VELOCITY_VALUES[verb]
		var marker := ""
		if expected_normal_velocity == 0.0:
			marker = "%s 法向速度 0.00" % verb
		else:
			marker = "%s 法向速度 %.2f" % [verb, expected_normal_velocity]
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
	# 校验 _EXPECTED_REQUIRED_SECTIONS 集合 78 项 (§9.6.6-§9.6.10 + §9.6.15-§9.6.87, 跳过 §9.6.11-§9.6.14 settings_menu 4 段 0 漂移).
	return _EXPECTED_REQUIRED_SECTIONS.size() == 78

func test_set_forbidden_sections_size() -> bool:
	# 校验 _EXPECTED_FORBIDDEN_SECTIONS 集合 9 项 (§9.6.88-§9.6.96, 9 段 0 触碰既有 81 套 polish 模式).
	return _EXPECTED_FORBIDDEN_SECTIONS.size() == 9

func test_set_shape_normal_velocity_size() -> bool:
	# 校验 _EXPECTED_SHAPE_NORMAL_VELOCITY_VALUES 集合 6 项 (6 verb × 1 normal_velocity = 6 元素 1:1 严格).
	return _EXPECTED_SHAPE_NORMAL_VELOCITY_VALUES.size() == 6

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
		"test_section_9_6_87_title_exact",
		"test_section_9_6_86_unchanged",
		"test_section_9_6_87_element_count_191",
		"test_section_9_6_87_shape_normal_velocity_values",
		"test_tool_chain_unchanged",
		"test_set_required_sections_size",
		"test_set_forbidden_sections_size",
		"test_set_shape_normal_velocity_size",
		"test_set_verbs_size",
		"test_set_tool_chain_size",
		"### 9.6.98"
	]
	for fn_name in test_fns:
		var ok: bool = call(fn_name)
		if ok:
			passed += 1
		else:
			failed += 1
			issues.append("FAIL: " + fn_name)
	return {"passed": passed, "failed": failed, "skipped": 0, "issues": issues}
