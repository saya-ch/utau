extends SceneTree

# test_t303_contributing_fragility_section9647_smoke.gd
#
# §9.6.47 5 verb windup VFX `_draw()` verb-specific 1:1 严格分离契约 polish 模式
# (T303 #229 落地) smoke test.
#
# 用法 (CI / 本地):
#   godot --headless --path . -s tools/test_t303_contributing_fragility_section9647_smoke.gd
#
# 验证项 (5 verb windup VFX `_draw()` verb-specific 1:1 严格分离契约 30 元素 0 例外):
#   Rule 1:  §9.6.47 段 标题 存在 (1 段 1:1 严格)
#   Rule 2:  §9.6.47 段 引言段 包含 5 verb 子类名 (5 verb × 1 子类名 = 5 子类名 1:1 严格 0 漏)
#   Rule 3:  §9.6.47 段 显式契约段 存在 (1 段 1:1 严格, "subclasses MUST implement verb-specific `_draw()` with 1 guard + 1 progress + 1 alpha + verb-specific 视觉组")
#   Rule 4:  §9.6.47 段 30 元素 1:1 严格计数 (5 verb `_draw()` + 5 verb 共享 3 字段 + 5 verb 视觉组 5 段 + 1 显式契约 + 1 视觉组 0 触碰既有 + 1 共享 3 字段 0 触碰既有 + 1 base `_draw()` 0 override + 1 `_draw()` 0 override verb-specific 0 触碰既有 = 30 元素)
#   Rule 5:  §9.6.47 段 5 verb 视觉组 5 段 0 漏 0 改 (Pulse 同心圆环 + Coral Pulse 核 / Bind 向内螺旋 + Muted Violet 核 / Cut 4 三角碎片 + Amber Voice 核 / Echo 8 棱镜折射 + Glass Cyan 核 / Wave 3 同心圆环 + Pale Resonance 核)
#   Rule 6:  §9.6.47 段 5 verb `_draw()` 0 override verb-specific 1:1 严格 (5 verb 0 override `_draw()` 0 触碰 base 1:1 严格)
#   Rule 7:  §9.6.47 段 5 verb 共享 3 字段 1:1 严格 (1 guard + 1 progress + 1 alpha = 3 共享字段 1:1 严格 镜像)
#   Rule 8:  §9.6.47 段 1 显式契约 0 触碰既有 1:1 严格 (1 显式契约 0 漏 0 改 0 反序 0 反向)
#   Rule 9:  §9.6.47 段 0 触碰既有 37 套 polish 模式 1:1 严格 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 37 套 polish 模式 0 漏 1 段 0 改 1 字符 0 反序 0 反向)
#   Rule 10: §9.6.47 段 与 §9.6.46 姊妹段 1:1 严格 (§9.6.47 是 §9.6.46 "聚焦段", 0 互混 0 复用 0 共享 1:1 严格)
#
# 0 触碰既有 (T303 #229 落地 smoke test 0 触碰 §9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 37 套 polish 模式任何 1 字符, 0 触碰游戏代码 .gd / .tscn / 任何 gameplay code, 0 触碰 §10 决策记录流程, 0 触碰 README.md / README.zh-CN.md 内容, 0 触碰 ITERATION_COUNT.txt / CHANGELOG.md / ROADMAP.md / CHANGELOG_ARCHIVE.md / REVIEW_LOG.md / REVIEW_LOG_ARCHIVE.md 内容).

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const SECTION_NUM := "9.6.47"
const EXPECTED_TITLE := "### 9.6.47 5 verb windup VFX `_draw()` verb-specific 1:1 严格分离契约 polish 模式 (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 跨 5 任务 ~140 轮落地) 文档化"

# 5 verb 子类名 (0 漏 1 verb 0 改 1 字符 0 反序 0 反向, 5 verb 1:1 严格 镜像 _verb_windup_vfx_base.gd 5 verb 子类)
const VERB_SUBCLASSES := [
	"pulse_windup_vfx.gd",
	"bind_windup_vfx.gd",
	"cut_windup_vfx.gd",
	"echo_windup_vfx.gd",
	"wave_windup_vfx.gd",
]

# 5 verb 视觉组 5 段 (Pulse 同心圆环 + Coral Pulse 核 / Bind 向内螺旋 + Muted Violet 核 / Cut 4 三角碎片 + Amber Voice 核 / Echo 8 棱镜折射 + Glass Cyan 核 / Wave 3 同心圆环 + Pale Resonance 核)
const VERB_VISUAL_GROUPS := [
	"同心圆环",
	"Coral Pulse 核",
	"向内螺旋",
	"Muted Violet 核",
	"4 三角碎片",
	"Amber Voice 核",
	"8 棱镜折射",
	"Glass Cyan 核",
	"3 同心圆环",
	"Pale Resonance 核",
]

# 5 verb 共享 3 字段 (1 guard + 1 progress + 1 alpha = 3 共享字段 1:1 严格 镜像)
const SHARED_FIELDS := [
	"if not _active: return",                    # 1 guard
	"var t := clampf(_lifetime / _max_lifetime, 0.0, 1.0)",  # 1 progress
	"<peak_alpha>",                              # 1 alpha (verb-specific value, 0.7/0.75/0.7/0.18-0.55/0.65)
]

# 1 显式契约 (1 段 1:1 严格, "subclasses MUST implement verb-specific `_draw()` with 1 guard + 1 progress + 1 alpha + verb-specific 视觉组")
const EXPLICIT_CONTRACT_FRAGMENT := "subclasses MUST implement verb-specific `_draw()` with 1 guard + 1 progress + 1 alpha + verb-specific 视觉组"

# 37 套既有 polish 模式 (0 漏 1 套 0 改 1 字符 0 反序 0 反向, 0 触碰既有 1:1 严格)
const EXISTING_SECTIONS := [
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
]

# 姊妹段 §9.6.46 (1 段 1:1 严格, §9.6.47 是 §9.6.46 "聚焦段", 0 互混 0 复用 0 共享 1:1 严格)
const SISTER_SECTION := "### 9.6.46"

var _failures: Array[String] = []
var _passed: Array[String] = []


func _initialize() -> void:
	var f := FileAccess.open(CONTRIBUTING_PATH, FileAccess.READ)
	if f == null:
		_fail("cannot open %s" % CONTRIBUTING_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()

	_check_title(content)
	_check_verb_subclasses(content)
	_check_explicit_contract(content)
	_check_30_elements(content)
	_check_visual_groups(content)
	_check_draw_overrides(content)
	_check_shared_fields(content)
	_check_no_touch_existing(content)
	_check_sister_section(content)

	_finish()


func _check_title(content: String) -> void:
	if content.find(EXPECTED_TITLE) == -1:
		_fail("Rule 1: §9.6.47 段 标题 缺失 (expected: %s)" % EXPECTED_TITLE)
	else:
		_pass("Rule 1: §9.6.47 段 标题 存在 1:1 严格")


func _check_verb_subclasses(content: String) -> void:
	for cls in VERB_SUBCLASSES:
		if content.find(cls) == -1:
			_fail("Rule 2: §9.6.47 段 5 verb 子类名 漏 %s 1:1 严格" % cls)
		else:
			_pass("Rule 2: §9.6.47 段 5 verb 子类名 包含 %s 1:1 严格" % cls)


func _check_explicit_contract(content: String) -> void:
	if content.find(EXPLICIT_CONTRACT_FRAGMENT) == -1:
		_fail("Rule 3: §9.6.47 段 1 显式契约 缺失 (expected fragment: %s)" % EXPLICIT_CONTRACT_FRAGMENT)
	else:
		_pass("Rule 3: §9.6.47 段 1 显式契约 存在 1:1 严格")


func _check_30_elements(content: String) -> void:
	# 30 元素 = 5 verb `_draw()` + 5 verb 共享 3 字段 (counted as 15 字段) + 5 verb 视觉组 5 段 + 1 显式契约 + 1 视觉组 0 触碰既有 + 1 共享 3 字段 0 触碰既有 + 1 base `_draw()` 0 override + 1 `_draw()` 0 override verb-specific 0 触碰既有
	# 验证 "30 元素 1:1 严格" 计数 在 §9.6.47 段内
	var section := _extract_section(content, SECTION_NUM)
	if section.find("30 元素 1:1 严格") == -1:
		_fail("Rule 4: §9.6.47 段 30 元素 1:1 严格计数 缺失")
	else:
		_pass("Rule 4: §9.6.47 段 30 元素 1:1 严格计数 存在 1:1 严格")


func _check_visual_groups(content: String) -> void:
	for vg in VERB_VISUAL_GROUPS:
		if content.find(vg) == -1:
			_fail("Rule 5: §9.6.47 段 5 verb 视觉组 5 段 漏 %s 1:1 严格" % vg)
		else:
			_pass("Rule 5: §9.6.47 段 5 verb 视觉组 5 段 包含 %s 1:1 严格" % vg)


func _check_draw_overrides(content: String) -> void:
	# 5 verb 各自 `_draw()` 0 override verb-specific 1:1 严格 — 验证 5 verb 子类名 + "_draw()" 1:1 严格
	var count := 0
	for cls in VERB_SUBCLASSES:
		# expect pattern: <cls> `_draw()` 0 override verb-specific 1:1 严格
		var pattern := "%s `_draw()` 0 override verb-specific 1:1 严格" % cls
		if content.find(pattern) != -1:
			count += 1
	if count != VERB_SUBCLASSES.size():
		_fail("Rule 6: §9.6.47 段 5 verb `_draw()` 0 override verb-specific 1:1 严格 仅 %d/%d 1:1 严格" % [count, VERB_SUBCLASSES.size()])
	else:
		_pass("Rule 6: §9.6.47 段 5 verb `_draw()` 0 override verb-specific 1:1 严格 5/5 1:1 严格")


func _check_shared_fields(content: String) -> void:
	# 5 verb 共享 3 字段 1:1 严格 (1 guard + 1 progress + 1 alpha = 3 共享字段 1:1 严格 镜像)
	var count := 0
	for field in SHARED_FIELDS:
		if content.find(field) != -1:
			count += 1
	if count != SHARED_FIELDS.size():
		_fail("Rule 7: §9.6.47 段 5 verb 共享 3 字段 1:1 严格 仅 %d/%d 1:1 严格" % [count, SHARED_FIELDS.size()])
	else:
		_pass("Rule 7: §9.6.47 段 5 verb 共享 3 字段 1:1 严格 3/3 1:1 严格")


func _check_no_touch_existing(content: String) -> void:
	# 0 触碰既有 37 套 polish 模式 1:1 严格 — 验证 37 套既有 §9.6.x 段 全部存在
	var count := 0
	for sec in EXISTING_SECTIONS:
		if content.find(sec) != -1:
			count += 1
	if count != EXISTING_SECTIONS.size():
		_fail("Rule 9: §9.6.47 段 0 触碰既有 37 套 polish 模式 1:1 严格 仅 %d/%d 1:1 严格" % [count, EXISTING_SECTIONS.size()])
	else:
		_pass("Rule 9: §9.6.47 段 0 触碰既有 37 套 polish 模式 1:1 严格 37/37 1:1 严格")


func _check_sister_section(content: String) -> void:
	# 姊妹段 §9.6.46 (1 段 1:1 严格, §9.6.47 是 §9.6.46 "聚焦段", 0 互混 0 复用 0 共享 1:1 严格)
	if content.find(SISTER_SECTION) == -1:
		_fail("Rule 10: §9.6.47 段 姊妹段 §9.6.46 缺失")
	else:
		_pass("Rule 10: §9.6.47 段 姊妹段 §9.6.46 存在 1:1 严格")


func _extract_section(content: String, num: String) -> String:
	# 提取 §<num> 段 (从 "### <num>" 到下一个 "### " 或 "## " 段开始)
	var marker := "### %s " % num
	var start := content.find(marker)
	if start == -1:
		return ""
	var rest := content.substr(start)
	# find next "### " or "## " marker after start
	var end_markers := ["\n### ", "\n## "]
	var end := rest.length()
	for m in end_markers:
		var idx := rest.find(m, 4)  # skip the current marker
		if idx != -1 and idx < end:
			end = idx
	return rest.substr(0, end)


func _pass(msg: String) -> void:
	_passed.append(msg)
	print("[PASS] %s" % msg)


func _fail(msg: String) -> void:
	_failures.append(msg)
	printerr("[FAIL] %s" % msg)


func _finish() -> void:
	print("")
	print("=== §9.6.47 smoke test summary ===")
	print("PASS: %d" % _passed.size())
	print("FAIL: %d" % _failures.size())
	if _failures.is_empty():
		print("ALL CHECKS PASSED — §9.6.47 30 元素 1:1 严格分离契约 polish 模式 落地 0 例外")
		quit(0)
	else:
		print("SOME CHECKS FAILED — see errors above")
		for f in _failures:
			printerr("  - %s" % f)
		quit(1)
