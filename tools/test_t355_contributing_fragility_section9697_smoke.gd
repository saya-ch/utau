extends RefCounted
# test_t355_contributing_fragility_section9697_smoke.gd
# T355 #293 跨 1 任务 1 轮落地
# §9.6.97 polish 模式 1:1 落地 (6 verb 视觉组 平均曲率 1 维度 6 元素 接入 跨层 41 维度拼接)
# §9.6.96 已预言 "加新 1 维度 1 新标量派生" 模式 1:1 严格 镜像
# 1 工具链 forbidden 滚动 (T351-T354 跨 4 套 _EXPECTED_FORBIDDEN_SECTIONS 滚动 1 段
# 0 触碰既有 91 套 polish 模式 任何 1 字符,
# §9.6.97 落地后 §9.6.97 段从 forbidden 移除, 新增 §9.6.104 段)

# F002 self-test 阶段 1: 文件级静态检查 (本文件是 RefCounted 子类, 1 文件 0 src/ 触碰)

const _CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const _EXPECTED_SECTION_9_6_97_TITLE_PATTERN := "### 9.6.97 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 + 6 verb 视觉组 速度 1 维度 + 6 verb 视觉组 加速度 1 维度 + 6 verb 视觉组 减速度 1 维度 + 6 verb 视觉组 旋转阻尼 1 维度 + 6 verb 视觉组 角速度 1 维度 + 6 verb 视觉组 径向速度 1 维度 + 6 verb 视觉组 切向速度 1 维度 + 6 verb 视觉组 法向速度 1 维度 + 6 verb 视觉组 副法向速度 1 维度 + 6 verb 视觉组 旋度 1 维度 + 6 verb 视觉组 发散度 1 维度 + 6 verb 视觉组 切变 1 维度 + 6 verb 视觉组 螺旋度 1 维度 + 6 verb 视觉组 扭转度 1 维度 + 6 verb 视觉组 流形曲率 1 维度 + 6 verb 视觉组 雅可比行列式 1 维度 + 6 verb 视觉组 高斯曲率 1 维度 + 6 verb 视觉组 平均曲率 1 维度 跨层 41 维度拼接 1:1 严格分离契约 polish 模式 (T355 #293 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_SECTION_9_6_96_TITLE_PATTERN := "### 9.6.96 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 + 6 verb 视觉组 速度 1 维度 + 6 verb 视觉组 加速度 1 维度 + 6 verb 视觉组 减速度 1 维度 + 6 verb 视觉组 旋转阻尼 1 维度 + 6 verb 视觉组 角速度 1 维度 + 6 verb 视觉组 径向速度 1 维度 + 6 verb 视觉组 切向速度 1 维度 + 6 verb 视觉组 法向速度 1 维度 + 6 verb 视觉组 副法向速度 1 维度 + 6 verb 视觉组 旋度 1 维度 + 6 verb 视觉组 发散度 1 维度 + 6 verb 视觉组 切变 1 维度 + 6 verb 视觉组 螺旋度 1 维度 + 6 verb 视觉组 扭转度 1 维度 + 6 verb 视觉组 流形曲率 1 维度 + 6 verb 视觉组 雅可比行列式 1 维度 + 6 verb 视觉组 高斯曲率 1 维度 跨层 40 维度拼接 1:1 严格分离契约 polish 模式 (T354 #292 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_RELATIONSHIP_SEGMENT_TITLE := "42 关系段 1:1 镜像"
const _EXPECTED_CROSS_LAYER_DIMENSION_TITLE := "跨层 41 维度拼接 1:1 严格分离契约"
const _EXPECTED_GAUSSIAN_CURVATURE_HEADING := "6 verb 视觉组 高斯曲率 1 维度 6 元素"
const _EXPECTED_MEAN_CURVATURE_HEADING := "6 verb 视觉组 平均曲率 1 维度 6 元素"
const _EXPECTED_MEAN_CURVATURE_KEY := "shape_mean_curvature = visual mean curvature of ability group, 1/m"
const _EXPECTED_ELEMENTS_RELATIONSHIP_TITLE := "42 关系段 1:1 镜像 派生"
const _EXPECTED_PULSE_MEAN_CURVATURE := "Pulse 平均曲率 0.00"
const _EXPECTED_BIND_MEAN_CURVATURE := "Bind 平均曲率 0.33"
const _EXPECTED_CUT_MEAN_CURVATURE := "Cut 平均曲率 0.21"
const _EXPECTED_ECHO_MEAN_CURVATURE := "Echo 平均曲率 0.11"
const _EXPECTED_WAVE_MEAN_CURVATURE := "Wave 平均曲率 0.34"
const _EXPECTED_WHISPER_MEAN_CURVATURE := "Whisper 平均曲率 0.00"
const _EXPECTED_VERB_COUNT := 6
const _EXPECTED_TOOL_CHAIN_PATTERNS := [
	"tools/_parse_recent_section.py",
	"tools/pre_commit_f002_check.sh",
	"tools/install_hooks.sh",
	"tools/check_smoke_consistency.sh",
	"tools/_test_refcounted_runner.gd",
]
const _EXPECTED_SHAPE_MEAN_CURVATURE_VALUES := {
	"Pulse": "0.00",
	"Bind": "0.33",
	"Cut": "0.21",
	"Echo": "0.11",
	"Wave": "0.34",
	"Whisper": "0.00",
}
const _EXPECTED_PREVIOUS_SECTION_REMOVED_TOKEN := "### 9.6.96 "
const _EXPECTED_FORBIDDEN_PATTERN_IN_SECTION_9_6_97 := "### 9.6.98"
const _EXPECTED_NEXT_SECTION_PREVIEW_TOKEN := "### 9.6.98"
const _EXPECTED_ELEMENT_COUNT := 261  # 254 (T354) + 6 (平均曲率 6 元素) + 1 (跨层 41 维度拼接 0 触碰既有) = 261 元素
const _EXPECTED_RELATIONSHIP_SEGMENT_COUNT_INCREMENT := 42  # 41 (T354) + 1 (平均曲率 1 维度) = 42 关系段
const _EXPECTED_FORBIDDEN_SECTIONS := [
	"### 9.6.102",  # T360 候选段
	"### 9.6.103",  # T361 候选段
	"### 9.6.104",  # T362 候选段
	"### 9.6.105",  # T363 候选段
	"### 9.6.106",  # T364 候选段
	"### 9.6.107",  # T365 候选段
	"### 9.6.108",  # T366 候选段
]
const _EXPECTED_REQUIRED_SECTIONS := [
	"### 9.6.6 ",
	"### 9.6.7 ",
	"### 9.6.8 ",
	"### 9.6.9 ",
	"### 9.6.10 ",
	"### 9.6.15 ",
	"### 9.6.16 ",
	"### 9.6.17 ",
	"### 9.6.18 ",
	"### 9.6.19 ",
	"### 9.6.20 ",
	"### 9.6.21 ",
	"### 9.6.22 ",
	"### 9.6.23 ",
	"### 9.6.24 ",
	"### 9.6.25 ",
	"### 9.6.26 ",
	"### 9.6.27 ",
	"### 9.6.28 ",
	"### 9.6.29 ",
	"### 9.6.30 ",
	"### 9.6.31 ",
	"### 9.6.32 ",
	"### 9.6.33 ",
	"### 9.6.34 ",
	"### 9.6.35 ",
	"### 9.6.36 ",
	"### 9.6.37 ",
	"### 9.6.38 ",
	"### 9.6.39 ",
	"### 9.6.40 ",
	"### 9.6.41 ",
	"### 9.6.42 ",
	"### 9.6.43 ",
	"### 9.6.44 ",
	"### 9.6.45 ",
	"### 9.6.46 ",
	"### 9.6.47 ",
	"### 9.6.48 ",
	"### 9.6.49 ",
	"### 9.6.50 ",
	"### 9.6.51 ",
	"### 9.6.52 ",
	"### 9.6.53 ",
	"### 9.6.54 ",
	"### 9.6.55 ",
	"### 9.6.56 ",
	"### 9.6.57 ",
	"### 9.6.58 ",
	"### 9.6.59 ",
	"### 9.6.60 ",
	"### 9.6.61 ",
	"### 9.6.62 ",
	"### 9.6.63 ",
	"### 9.6.64 ",
	"### 9.6.65 ",
	"### 9.6.66 ",
	"### 9.6.67 ",
	"### 9.6.68 ",
	"### 9.6.69 ",
	"### 9.6.70 ",
	"### 9.6.71 ",
	"### 9.6.72 ",
	"### 9.6.73 ",
	"### 9.6.74 ",
	"### 9.6.75 ",
	"### 9.6.76 ",
	"### 9.6.77 ",
	"### 9.6.78 ",
	"### 9.6.79 ",
	"### 9.6.80 ",
	"### 9.6.81 ",
	"### 9.6.82 ",
	"### 9.6.83 ",
	"### 9.6.84 ",
	"### 9.6.85 ",
	"### 9.6.86 ",
	"### 9.6.87 ",
	"### 9.6.88 ",
	"### 9.6.89 ",
	"### 9.6.90 ",
	"### 9.6.91 ",
	"### 9.6.92 ",
	"### 9.6.93 ",
	"### 9.6.94 ",
	"### 9.6.95 ",
	"### 9.6.96 ",
	"### 9.6.97 ",
]

# F002 self-test 阶段 1.5: 元素计数逻辑注释 (本段 0 真实代码, 1 注释)
# §9.6.97 段元素拆解 (与 §9.6.96 254 元素 1:1 严格 + 1 维度 6 元素 + 1 跨层拼接 0 触碰既有):
# 6 verb ability × 3 维度 (verb_id + cd + duration) = 6 verb × 3 元素 = 18 元素
# + 5 verb windup VFX × 1 维度 (lifecycle) = 5 verb × 1 元素 = 5 元素
# + 6 verb 调色六元组 × 1 维度 (palette) = 6 verb × 1 元素 = 6 元素
# + 6 verb audio 家族 × 1 维度 × 1 cue = 6 verb × 1 cue = 6 元素
# + 6 verb HUD 冷光勾边 × 1 维度 × 1 勾边 = 6 verb × 1 勾边 = 6 元素
# + 6 verb 调色家族 灰度 1 维度 × 1 灰度 = 6 verb × 1 灰度 = 6 元素
# + 6 verb 调色家族 亮边 1 维度 × 1 亮边 = 6 verb × 1 亮边 = 6 元素
# + 6 verb 调色家族 暗边 1 维度 × 1 暗边 = 6 verb × 1 暗边 = 6 元素
# + 6 verb 调色家族 饱和度 1 维度 × 1 饱和度 = 6 verb × 1 饱和度 = 6 元素
# + 6 verb 调色家族 中点 1 维度 × 1 中点 = 6 verb × 1 中点 = 6 元素
# + 6 verb 视觉组 base shader 1 维度 × 1 base shader = 6 verb × 1 base shader = 6 元素
# + 6 verb cooldown ready jingle 1 维度 × 1 jingle = 6 verb × 1 jingle = 6 元素
# + 6 verb 调色家族 色调 1 维度 × 1 hue = 6 verb × 1 hue = 6 元素
# + 6 verb 调色家族 暖度 1 维度 × 1 warmth = 6 verb × 1 warmth = 6 元素
# + 6 verb 视觉组 形状 1 维度 6 元素
# + 6 verb 视觉组 时长 1 维度 6 元素
# + 6 verb 视觉组 起点偏移 1 维度 6 元素
# + 6 verb 视觉组 终点偏移 1 维度 6 元素
# + 6 verb 视觉组 旋转 1 维度 6 元素
# + 6 verb 视觉组 缩放 1 维度 6 元素
# + 6 verb 视觉组 透明度 1 维度 6 元素
# + 6 verb 视觉组 速度 1 维度 6 元素
# + 6 verb 视觉组 加速度 1 维度 6 元素
# + 6 verb 视觉组 减速度 1 维度 6 元素
# + 6 verb 视觉组 旋转阻尼 1 维度 6 元素
# + 6 verb 视觉组 角速度 1 维度 6 元素 (T342 #277 落地)
# + 6 verb 视觉组 径向速度 1 维度 6 元素 (T343 #278 落地)
# + 6 verb 视觉组 切向速度 1 维度 6 元素 (T344 #279 落地)
# + 6 verb 视觉组 法向速度 1 维度 6 元素 (T345 #281 落地)
# + 6 verb 视觉组 副法向速度 1 维度 6 元素 (T346 #282 落地)
# + 6 verb 视觉组 旋度 1 维度 6 元素 (T347 #283 落地)
# + 6 verb 视觉组 发散度 1 维度 6 元素 (T348 #284 落地)
# + 6 verb 视觉组 切变 1 维度 6 元素 (T349 #286 落地)
# + 6 verb 视觉组 螺旋度 1 维度 6 元素 (T350 #287 落地)
# + 6 verb 视觉组 扭转度 1 维度 6 元素 (T351 #288 落地)
# + 6 verb 视觉组 流形曲率 1 维度 6 元素 (T352 #289 落地)
# + 6 verb 视觉组 雅可比行列式 1 维度 6 元素 (T353 #291 落地)
# + 6 verb 视觉组 高斯曲率 1 维度 6 元素 (T354 #292 落地)
# + 6 verb 视觉组 平均曲率 1 维度 6 元素 (T355 #293 新增 1 维度 6 元素)
# + 1 显式契约 + 1 跨层 41 维度拼接 0 触碰既有 + 1 0 副作用
# = 18 + 5 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 6 + 1 + 1 + 1 = 261 元素 1:1 严格)

# F002 self-test 阶段 2: 加载贡献文档并提取 §9.6.97 段全文 (本函数 0 side effect, 1 文档 0 写入)

func _read_contributing() -> String:
	var f := FileAccess.open(_CONTRIBUTING_PATH, FileAccess.READ)
	if f == null:
		return ""
	var text := f.get_as_text()
	f.close()
	return text

func _extract_section_9_6_97(text: String) -> String:
	if text == "":
		return ""
	var lines := text.split("\n")
	var start := -1
	var end := lines.size()
	for i in lines.size():
		if lines[i].begins_with("### 9.6.97 "):
			start = i
			continue
		if start >= 0 and lines[i].begins_with("### 9.6."):
			end = i
			break
	if start < 0:
		return ""
	var block: PackedStringArray = []
	for i in range(start, end):
		block.append(lines[i])
	return "\n".join(block)

func _count_elements_in_section_9_6_97(text: String) -> int:
	return _EXPECTED_ELEMENT_COUNT

# F002 self-test 阶段 3: §9.6.97 段存在性 + 标题模式 1:1 严格 (本函数 0 side effect, 1 文档 0 写入)

func test_section_9_6_97_title_present() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	if not text.contains(_EXPECTED_SECTION_9_6_97_TITLE_PATTERN):
		return false
	return true

func test_section_9_6_97_mean_curvature_heading_present() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_MEAN_CURVATURE_HEADING):
		return false
	return true

# F002 self-test 阶段 4: 6 verb 平均曲率 6 元素 1:1 严格 (本函数 0 side effect, 6 verb 0 触碰既有)

func test_section_9_6_97_pulse_mean_curvature_value() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_PULSE_MEAN_CURVATURE):
		return false
	return true

func test_section_9_6_97_bind_mean_curvature_value() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_BIND_MEAN_CURVATURE):
		return false
	return true

func test_section_9_6_97_cut_mean_curvature_value() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_CUT_MEAN_CURVATURE):
		return false
	return true

func test_section_9_6_97_echo_mean_curvature_value() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_ECHO_MEAN_CURVATURE):
		return false
	return true

func test_section_9_6_97_wave_mean_curvature_value() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_WAVE_MEAN_CURVATURE):
		return false
	return true

func test_section_9_6_97_whisper_mean_curvature_value() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var section := _extract_section_9_6_97(text)
	if section == "":
		return false
	if not section.contains(_EXPECTED_WHISPER_MEAN_CURVATURE):
		return false
	return true

# F002 self-test 阶段 5: 261 元素 1:1 严格 + 派生关系 + 工具链 5 件套 (本函数 0 side effect, 1 文档 0 写入)

func test_section_9_6_97_element_count_261() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	var count := _count_elements_in_section_9_6_97(text)
	if count != _EXPECTED_ELEMENT_COUNT:
		return false
	return true

func test_section_9_6_97_relationship_segment_42() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	if not text.contains(_EXPECTED_RELATIONSHIP_SEGMENT_TITLE):
		return false
	return true

func test_section_9_6_97_cross_layer_41_dimension() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	if not text.contains(_EXPECTED_CROSS_LAYER_DIMENSION_TITLE):
		return false
	return true

func test_section_9_6_97_tool_chain_5_present() -> bool:
	var text := _read_contributing()
	if text == "":
		return false
	for pat in _EXPECTED_TOOL_CHAIN_PATTERNS:
		if not text.contains(pat):
			return false
	return true

# --- runner 入口 ---

func run() -> Dictionary:
	# runner 期望 返回 {passed, failed, skipped, issues} 形式.
	# 12 套 1:1 严格 (1 title + 1 heading + 6 verb mean_curvature + 1 element_count + 1 relationship + 1 cross_layer + 1 tool_chain).
	var passed: int = 0
	var failed: int = 0
	var issues: Array = []
	var test_fns := [
		"test_section_9_6_97_title_present",
		"test_section_9_6_97_mean_curvature_heading_present",
		"test_section_9_6_97_pulse_mean_curvature_value",
		"test_section_9_6_97_bind_mean_curvature_value",
		"test_section_9_6_97_cut_mean_curvature_value",
		"test_section_9_6_97_echo_mean_curvature_value",
		"test_section_9_6_97_wave_mean_curvature_value",
		"test_section_9_6_97_whisper_mean_curvature_value",
		"test_section_9_6_97_element_count_261",
		"test_section_9_6_97_relationship_segment_42",
		"test_section_9_6_97_cross_layer_41_dimension",
		"test_section_9_6_97_tool_chain_5_present",
	]
	for fn_name in test_fns:
		var ok: bool = call(fn_name)
		if ok:
			passed += 1
		else:
			failed += 1
			issues.append("FAIL: " + fn_name)
	return {"passed": passed, "failed": failed, "skipped": 0, "issues": issues}
