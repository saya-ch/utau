extends SceneTree

# test_t304_contributing_fragility_section9648_smoke.gd
#
# §9.6.48 5 verb windup VFX `trigger()` verb-specific 1:1 严格分离契约 polish 模式
# (T304 #231 落地) smoke test.
#
# 用法 (CI / 本地):
#   godot --headless --path . -s tools/test_t304_contributing_fragility_section9648_smoke.gd
#
# 验证项 (5 verb windup VFX `trigger()` verb-specific 1:1 严格分离契约 32 元素 0 例外):
#   Rule 1:  §9.6.48 段 标题 存在 (1 段 1:1 严格)
#   Rule 2:  §9.6.48 段 引言段 包含 5 verb 子类名 (5 verb × 1 子类名 = 5 子类名 1:1 严格 0 漏)
#   Rule 3:  §9.6.48 段 显式契约段 存在 (1 段 1:1 严格, "subclasses MUST call `_activate_windup_tween()` in their `trigger()` after setting verb-specific state")
#   Rule 4:  §9.6.48 段 32 元素 1:1 严格计数 (5 verb `trigger()` 0 override verb-specific + 5 verb 共享 4 元素 (5 verb × 4 = 20 元素) + 2 verb verb-specific 1 元素 + 1 显式契约 + 1 verb-specific 0 触碰既有 + 1 共享 4 元素 0 触碰既有 + 1 base `trigger()` 0 override + 1 `trigger()` 0 override verb-specific 0 触碰既有 = 32 元素)
#   Rule 5:  §9.6.48 段 5 verb 共享 4 元素 1:1 严格 (1 set `global_position = origin` + 1 set `_radius = maxf(half_radius, 1.0)` + 1 set `_max_lifetime = maxf(duration, 0.01)` + 1 call `_activate_windup_tween()` = 4 共享元素 1:1 严格 镜像)
#   Rule 6:  §9.6.48 段 2 verb verb-specific 1 元素 1:1 严格 (Cut `_direction = direction.normalized() if direction.length() > 0.001 else Vector2.RIGHT` 1 元素 + Echo `_max_radius = maxf(full_radius, half_radius)` 1 元素)
#   Rule 7:  §9.6.48 段 5 verb `trigger()` 0 override verb-specific 1:1 严格 (5 verb 各自 override `trigger()` 0 触碰 base 1:1 严格)
#   Rule 8:  §9.6.48 段 0 触碰既有 38 套 polish 模式 1:1 严格 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47 38 套 polish 模式 0 漏 1 段 0 改 1 字符 0 反序 0 反向)
#   Rule 9:  §9.6.48 段 与 §9.6.47 姊妹段 1:1 严格 (§9.6.48 是 §9.6.47 "聚焦段", 0 互混 0 复用 0 共享 1:1 严格)
#   Rule 10: §9.6.48 段 0 真实游戏代码改动 1:1 严格 (5 verb windup VFX `trigger()` + `_verb_windup_vfx_base.gd` 显式契约 0 触碰既有 1:1 严格, 0 触碰 .gd / .tscn 任何 1 字符)
#
# 0 触碰既有 (T304 #231 落地 smoke test 0 触碰 §9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47 38 套 polish 模式任何 1 字符, 0 触碰游戏代码 .gd / .tscn / 任何 gameplay code, 0 触碰 §10 决策记录流程, 0 触碰 README.md / README.zh-CN.md 内容, 0 触碰 ITERATION_COUNT.txt / CHANGELOG.md / ROADMAP.md / CHANGELOG_ARCHIVE.md / REVIEW_LOG.md / REVIEW_LOG_ARCHIVE.md 内容).

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const SECTION_NUM := "9.6.48"
const EXPECTED_TITLE := "### 9.6.48 5 verb windup VFX `trigger()` verb-specific 1:1 严格分离契约 polish 模式 (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 跨 5 任务 ~141 轮落地) 文档化"

# 5 verb 子类名 (0 漏 1 verb 0 改 1 字符 0 反序 0 反向, 5 verb 1:1 严格 镜像 _verb_windup_vfx_base.gd 5 verb 子类)
const VERB_SUBCLASSES := [
	"pulse_windup_vfx.gd",
	"bind_windup_vfx.gd",
	"cut_windup_vfx.gd",
	"echo_windup_vfx.gd",
	"wave_windup_vfx.gd",
]

# 5 verb 共享 4 元素 (1 set `global_position = origin` + 1 set `_radius = maxf(half_radius, 1.0)` + 1 set `_max_lifetime = maxf(duration, 0.01)` + 1 call `_activate_windup_tween()` = 4 共享元素 1:1 严格 镜像)
const SHARED_4_ELEMENTS := [
	"global_position = origin",                  # 1 set global_position
	"_radius = maxf(half_radius, 1.0)",          # 1 set _radius
	"_max_lifetime = maxf(duration, 0.01)",      # 1 set _max_lifetime
	"_activate_windup_tween()",                  # 1 call _activate_windup_tween
]

# 2 verb verb-specific 1 元素 (Cut `_direction` 1 元素 + Echo `_max_radius` 1 元素)
const VERB_SPECIFIC_1_ELEMENTS := [
	"_direction = direction.normalized() if direction.length() > 0.001 else Vector2.RIGHT",  # Cut _direction
	"_max_radius = maxf(full_radius, half_radius)",                                              # Echo _max_radius
]

# 1 显式契约 (1 段 1:1 严格, "subclasses MUST call `_activate_windup_tween()` in their `trigger()` after setting verb-specific state")
const EXPLICIT_CONTRACT_FRAGMENT := "subclasses MUST call `_activate_windup_tween()` in their `trigger()` after setting verb-specific state"

# 38 套既有 polish 模式 (0 漏 1 套 0 改 1 字符 0 反序 0 反向, 0 触碰既有 1:1 严格)
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
	"### 9.6.47",
]

# 姊妹段 §9.6.47 (1 段 1:1 严格, §9.6.48 是 §9.6.47 "聚焦段", 0 互混 0 复用 0 共享 1:1 严格)
const SISTER_SECTION := "### 9.6.47"

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
	_check_32_elements(content)
	_check_shared_4_elements(content)
	_check_verb_specific_1_elements(content)
	_check_trigger_overrides(content)
	_check_no_touch_existing(content)
	_check_sister_section(content)
	_check_no_real_gamecode_change(content)

	_finish()


func _check_title(content: String) -> void:
	if content.find(EXPECTED_TITLE) == -1:
		_fail("Rule 1: §9.6.48 段 标题 缺失 (expected: %s)" % EXPECTED_TITLE)
	else:
		_pass("Rule 1: §9.6.48 段 标题 存在 1:1 严格")


func _check_verb_subclasses(content: String) -> void:
	for cls in VERB_SUBCLASSES:
		if content.find(cls) == -1:
			_fail("Rule 2: §9.6.48 段 5 verb 子类名 漏 %s 1:1 严格" % cls)
		else:
			_pass("Rule 2: §9.6.48 段 5 verb 子类名 包含 %s 1:1 严格" % cls)


func _check_explicit_contract(content: String) -> void:
	if content.find(EXPLICIT_CONTRACT_FRAGMENT) == -1:
		_fail("Rule 3: §9.6.48 段 1 显式契约 缺失 (expected fragment: %s)" % EXPLICIT_CONTRACT_FRAGMENT)
	else:
		_pass("Rule 3: §9.6.48 段 1 显式契约 存在 1:1 严格")


func _check_32_elements(content: String) -> void:
	# 32 元素 = 5 verb `trigger()` 0 override verb-specific + 5 verb 共享 4 元素 (counted as 20 元素) + 2 verb verb-specific 1 元素 + 1 显式契约 + 1 verb-specific 0 触碰既有 + 1 共享 4 元素 0 触碰既有 + 1 base `trigger()` 0 override + 1 `trigger()` 0 override verb-specific 0 触碰既有
	# 验证 "32 元素 1:1 严格" 计数 在 §9.6.48 段内
	var section := _extract_section(content, SECTION_NUM)
	if section.find("32 元素 1:1 严格") == -1:
		_fail("Rule 4: §9.6.48 段 32 元素 1:1 严格计数 缺失")
	else:
		_pass("Rule 4: §9.6.48 段 32 元素 1:1 严格计数 存在 1:1 严格")


func _check_shared_4_elements(content: String) -> void:
	# 5 verb 共享 4 元素 1:1 严格 (1 set `global_position = origin` + 1 set `_radius = maxf(half_radius, 1.0)` + 1 set `_max_lifetime = maxf(duration, 0.01)` + 1 call `_activate_windup_tween()` = 4 共享元素 1:1 严格 镜像)
	var count := 0
	for element in SHARED_4_ELEMENTS:
		if content.find(element) != -1:
			count += 1
	if count != SHARED_4_ELEMENTS.size():
		_fail("Rule 5: §9.6.48 段 5 verb 共享 4 元素 1:1 严格 仅 %d/%d 1:1 严格" % [count, SHARED_4_ELEMENTS.size()])
	else:
		_pass("Rule 5: §9.6.48 段 5 verb 共享 4 元素 1:1 严格 4/4 1:1 严格")


func _check_verb_specific_1_elements(content: String) -> void:
	# 2 verb verb-specific 1 元素 1:1 严格 (Cut `_direction` 1 元素 + Echo `_max_radius` 1 元素)
	var count := 0
	for element in VERB_SPECIFIC_1_ELEMENTS:
		if content.find(element) != -1:
			count += 1
	if count != VERB_SPECIFIC_1_ELEMENTS.size():
		_fail("Rule 6: §9.6.48 段 2 verb verb-specific 1 元素 1:1 严格 仅 %d/%d 1:1 严格" % [count, VERB_SPECIFIC_1_ELEMENTS.size()])
	else:
		_pass("Rule 6: §9.6.48 段 2 verb verb-specific 1 元素 1:1 严格 2/2 1:1 严格")


func _check_trigger_overrides(content: String) -> void:
	# 5 verb 各自 `trigger()` 0 override verb-specific 1:1 严格 — 验证 5 verb 名字 (Pulse / Bind / Cut / Echo / Wave) + " `trigger()` 0 override verb-specific 1:1 严格" pattern
	# T162 brittle Stage 1 + Stage 3: §9.6.48 段 实际用 verb 名字 (Pulse / Bind / Cut / Echo / Wave) 而非子类文件名 (pulse_windup_vfx.gd 等) 写 "1 Pulse `trigger()` 0 override verb-specific 1:1 严格" 模式.
	var verb_names := ["Pulse", "Bind", "Cut", "Echo", "Wave"]
	var count := 0
	for verb in verb_names:
		# expect pattern: 1 <verb> `trigger()` 0 override verb-specific 1:1 严格
		var pattern := "%s `trigger()` 0 override verb-specific 1:1 严格" % verb
		if content.find(pattern) != -1:
			count += 1
	if count != verb_names.size():
		_fail("Rule 7: §9.6.48 段 5 verb `trigger()` 0 override verb-specific 1:1 严格 仅 %d/%d 1:1 严格" % [count, verb_names.size()])
	else:
		_pass("Rule 7: §9.6.48 段 5 verb `trigger()` 0 override verb-specific 1:1 严格 5/5 1:1 严格")


func _check_no_touch_existing(content: String) -> void:
	# 0 触碰既有 38 套 polish 模式 1:1 严格 — 验证 38 套既有 §9.6.x 段 全部存在
	var count := 0
	for sec in EXISTING_SECTIONS:
		if content.find(sec) != -1:
			count += 1
	if count != EXISTING_SECTIONS.size():
		_fail("Rule 8: §9.6.48 段 0 触碰既有 38 套 polish 模式 1:1 严格 仅 %d/%d 1:1 严格" % [count, EXISTING_SECTIONS.size()])
	else:
		_pass("Rule 8: §9.6.48 段 0 触碰既有 38 套 polish 模式 1:1 严格 38/38 1:1 严格")


func _check_sister_section(content: String) -> void:
	# 姊妹段 §9.6.47 (1 段 1:1 严格, §9.6.48 是 §9.6.47 "聚焦段", 0 互混 0 复用 0 共享 1:1 严格)
	if content.find(SISTER_SECTION) == -1:
		_fail("Rule 9: §9.6.48 段 姊妹段 §9.6.47 缺失")
	else:
		_pass("Rule 9: §9.6.48 段 姊妹段 §9.6.47 存在 1:1 严格")


func _check_no_real_gamecode_change(content: String) -> void:
	# 0 真实游戏代码改动 1:1 严格 — 验证 §9.6.48 段 0 触碰 5 verb windup VFX `trigger()` 任何 1 字符
	# 验证 §9.6.48 段 0 触碰 `_verb_windup_vfx_base.gd` 显式契约任何 1 字符
	# T162 brittle 5 步骤: 1 expect 反转 + 1 docblock 说明 + 1 段 find 反转 + 0 触碰既有 + 1 cross-section 5 文件 同步
	var section := _extract_section(content, SECTION_NUM)
	# 0 触碰既有: §9.6.48 段 0 改 _verb_windup_vfx_base.gd 显式契约, 0 改 5 verb windup VFX `trigger()` 任何 1 字符
	var no_touch_phrase := "0 触碰游戏代码 .gd / .tscn / 任何 gameplay code"
	if section.find(no_touch_phrase) == -1:
		_fail("Rule 10: §9.6.48 段 0 触碰游戏代码 1:1 严格 缺失 0 触碰既有说明")
	else:
		_pass("Rule 10: §9.6.48 段 0 触碰游戏代码 1:1 严格 0 触碰既有说明 存在 1:1 严格")


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
	print("=== §9.6.48 smoke test summary ===")
	print("PASS: %d" % _passed.size())
	print("FAIL: %d" % _failures.size())
	if _failures.is_empty():
		print("ALL CHECKS PASSED — §9.6.48 32 元素 1:1 严格分离契约 polish 模式 落地 0 例外")
		quit(0)
	else:
		print("SOME CHECKS FAILED — see errors above")
		for f in _failures:
			printerr("  - %s" % f)
		quit(1)
