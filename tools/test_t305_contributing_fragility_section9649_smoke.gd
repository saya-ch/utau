extends SceneTree
# T305 (#232) — §9.6.49 CONTRIBUTING 文档化 5 verb windup VFX 共享 4 hook
# (`_ready()` + `_process()` + `_activate_windup_tween()` + `fade_out_and_free()`)
# 0 override verb-specific 0 触碰既有 1:1 严格分离契约 聚焦段 polish 模式
# (T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 跨 5 任务 ~142 轮落地) smoke test.
#
# 镜像 test_t304_contributing_fragility_section9648_smoke.gd 结构. 9 元素 1:1 严格:
# 5 verb 0 override 4 hook + 1 base 4 hook 0 触碰既有 + 1 Whisper 1 hook override +
# 1 显式契约 + 1 4 hook 0 override verb-specific 0 触碰既有 = 9 元素.

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const WINDUP_VFX_BASE_PATH := "res://src/scripts/_verb_windup_vfx_base.gd"
const WHISPER_WINDUP_VFX_PATH := "res://src/scripts/whisper_windup_vfx.gd"

var _pass_count := 0
var _fail_count := 0
var _fail_details: Array[String] = []


func _init() -> void:
	print("=== §9.6.49 5 verb windup VFX 共享 4 hook 0 override verb-specific 0 触碰既有 1:1 严格分离契约 聚焦段 smoke test ===")
	print("")

	var f := FileAccess.open(CONTRIBUTING_PATH, FileAccess.READ)
	if f == null:
		_record_fail("CONTRIBUTING.md 不可访问")
		_finish()
		return
	var text := f.get_as_text()
	f.close()

	var base_f := FileAccess.open(WINDUP_VFX_BASE_PATH, FileAccess.READ)
	if base_f == null:
		_record_fail("_verb_windup_vfx_base.gd 不可访问")
		_finish()
		return
	var base_text := base_f.get_as_text()
	base_f.close()

	var whisper_f := FileAccess.open(WHISPER_WINDUP_VFX_PATH, FileAccess.READ)
	if whisper_f == null:
		_record_fail("whisper_windup_vfx.gd 不可访问")
		_finish()
		return
	var whisper_text := whisper_f.get_as_text()
	whisper_f.close()

	# Rule 1: §9.6.49 段 标题 存在
	_check_rule_1_title_exists(text)

	# Rule 2: §9.6.49 段 5 verb 子类名 包含 (pulse, bind, cut, echo, wave)
	_check_rule_2_5_verb_names(text)

	# Rule 3: §9.6.49 段 1 显式契约 存在
	_check_rule_3_explicit_contract(text)

	# Rule 4: §9.6.49 段 9 元素 1:1 严格计数 存在
	_check_rule_4_element_count_9(text)

	# Rule 5: §9.6.49 段 5 verb 共享 4 hook 0 override 1:1 严格 5/5
	_check_rule_5_5_verb_0_override_4_hook(text)

	# Rule 6: §9.6.49 段 1 base 4 hook 0 触碰既有 1:1 严格 (base has 4 hooks)
	_check_rule_6_base_4_hook_0_touch(base_text)

	# Rule 7: §9.6.49 段 1 Whisper 1 hook override 0 触碰既有 1:1 严格
	_check_rule_7_whisper_1_hook_override(whisper_text)

	# Rule 8: §9.6.49 段 0 触碰 39 套 polish 模式 1:1 严格
	_check_rule_8_0_touch_39_polish_patterns(text)

	# Rule 9: §9.6.49 段 姊妹段 §9.6.48 存在
	_check_rule_9_sister_section_9648(text)

	# Rule 10: §9.6.49 段 0 触碰游戏代码 1:1 严格 0 触碰既有说明 存在
	_check_rule_10_0_touch_game_code(text)

	_finish()


func _check_rule_1_title_exists(text: String) -> void:
	var needle := "### 9.6.49 5 verb windup VFX 共享 4 hook 0 override verb-specific 0 触碰既有 1:1 严格分离契约 聚焦段 polish 模式"
	if text.contains(needle):
		_record_pass("Rule 1: §9.6.49 段 标题 存在 1:1 严格")
	else:
		_record_fail("Rule 1: §9.6.49 段 标题 缺失 — 期望: " + needle)


func _check_rule_2_5_verb_names(text: String) -> void:
	# 在 §9.6.49 段内 (从 Rule 1 标题到下一个 ## 段或文件末尾) 验证 5 verb 子类名
	var section := _extract_section_9649(text)
	for verb in ["pulse_windup_vfx.gd", "bind_windup_vfx.gd", "cut_windup_vfx.gd", "echo_windup_vfx.gd", "wave_windup_vfx.gd"]:
		if section.contains(verb):
			_record_pass("Rule 2: §9.6.49 段 5 verb 子类名 包含 %s 1:1 严格" % verb)
		else:
			_record_fail("Rule 2: §9.6.49 段 5 verb 子类名 缺失 %s" % verb)


func _check_rule_3_explicit_contract(text: String) -> void:
	var section := _extract_section_9649(text)
	# 1 显式契约 "5 verb windup VFX subclasses 0 override 4 base shared hook 1:1 严格 + Whisper 1 hook override 业务需求 1:1 严格"
	if section.contains("5 verb windup VFX subclasses 0 override 4 base shared hook 1:1 严格") \
		and section.contains("Whisper 1 hook override 业务需求 1:1 严格"):
		_record_pass("Rule 3: §9.6.49 段 1 显式契约 存在 1:1 严格")
	else:
		_record_fail("Rule 3: §9.6.49 段 1 显式契约 缺失")


func _check_rule_4_element_count_9(text: String) -> void:
	var section := _extract_section_9649(text)
	# 9 元素 = 5 verb + 1 base + 1 Whisper + 1 显式契约 + 1 4 hook 0 override verb-specific 0 触碰既有
	# 找 "9 元素 1:1 严格" 计数
	if section.contains("9 元素 1:1 严格"):
		_record_pass("Rule 4: §9.6.49 段 9 元素 1:1 严格计数 存在 1:1 严格")
	else:
		_record_fail("Rule 4: §9.6.49 段 9 元素 1:1 严格计数 缺失")


func _check_rule_5_5_verb_0_override_4_hook(text: String) -> void:
	var section := _extract_section_9649(text)
	# 5 verb 各自 0 override 4 共享 hook — 5 个 verb 名字 + 0 override 4 hook 标识
	var verb_count := 0
	for verb in ["pulse_windup_vfx.gd", "bind_windup_vfx.gd", "cut_windup_vfx.gd", "echo_windup_vfx.gd", "wave_windup_vfx.gd"]:
		# 找 "verb 0 override 4 共享 hook" 模式
		if section.contains("%s 0 override 4 共享 hook" % verb.replace("_windup_vfx.gd", "").capitalize()):
			verb_count += 1
		elif section.contains("%s 0 override 4 共享 hook" % verb):
			verb_count += 1
	if verb_count == 5:
		_record_pass("Rule 5: §9.6.49 段 5 verb 共享 4 hook 0 override 1:1 严格 %d/5 1:1 严格" % verb_count)
	else:
		_record_fail("Rule 5: §9.6.49 段 5 verb 共享 4 hook 0 override 缺失 %d/5" % verb_count)


func _check_rule_6_base_4_hook_0_touch(base_text: String) -> void:
	# 1 base 4 hook 0 触碰既有 = base has 4 shared methods (_ready, _process, _activate_windup_tween, fade_out_and_free)
	var hook_count := 0
	for hook in ["func _ready()", "func _process(", "func _activate_windup_tween()", "func fade_out_and_free()"]:
		if base_text.contains(hook):
			hook_count += 1
	if hook_count == 4:
		_record_pass("Rule 6: §9.6.49 段 1 base 4 hook 0 触碰既有 1:1 严格 %d/4 1:1 严格" % hook_count)
	else:
		_record_fail("Rule 6: §9.6.49 段 1 base 4 hook 0 触碰既有 缺失 %d/4" % hook_count)


func _check_rule_7_whisper_1_hook_override(whisper_text: String) -> void:
	# 1 Whisper 1 hook override = whisper_windup_vfx.gd has _ready() override (for z_index=50)
	if whisper_text.contains("func _ready()"):
		_record_pass("Rule 7: §9.6.49 段 1 Whisper 1 hook override 0 触碰既有 1:1 严格 1/1 1:1 严格")
	else:
		_record_fail("Rule 7: §9.6.49 段 1 Whisper 1 hook override 0 触碰既有 缺失 — whisper_windup_vfx.gd 应有 _ready() override")


func _check_rule_8_0_touch_39_polish_patterns(text: String) -> void:
	var section := _extract_section_9649(text)
	# 0 触碰 39 套 polish 模式 — count 段内 polish 模式引用
	# §9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 = 39 套
	var count := 0
	for i in [6, 7, 8, 9, 10, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48]:
		if section.contains("§9.6.%d " % i) or section.contains("§9.6.%d/" % i):
			count += 1
	if count >= 39:
		_record_pass("Rule 8: §9.6.49 段 0 触碰 39 套 polish 模式 1:1 严格 %d/39 1:1 严格" % count)
	else:
		_record_fail("Rule 8: §9.6.49 段 0 触碰 39 套 polish 模式 缺失 %d/39" % count)


func _check_rule_9_sister_section_9648(text: String) -> void:
	var section := _extract_section_9649(text)
	if section.contains("§9.6.48"):
		_record_pass("Rule 9: §9.6.49 段 姊妹段 §9.6.48 存在 1:1 严格")
	else:
		_record_fail("Rule 9: §9.6.49 段 姊妹段 §9.6.48 缺失")


func _check_rule_10_0_touch_game_code(text: String) -> void:
	var section := _extract_section_9649(text)
	if section.contains("0 触碰游戏代码") or section.contains("0 触碰既有"):
		_record_pass("Rule 10: §9.6.49 段 0 触碰游戏代码 1:1 严格 0 触碰既有说明 存在 1:1 严格")
	else:
		_record_fail("Rule 10: §9.6.49 段 0 触碰游戏代码 1:1 严格 0 触碰既有说明 缺失")


func _extract_section_9649(text: String) -> String:
	# 提取从 "### 9.6.49" 到下一个 "## " 段 (或文件末尾) 的内容
	var start_marker := "### 9.6.49"
	var start_idx := text.find(start_marker)
	if start_idx == -1:
		return ""
	# 找下一个 "## " (注意 "###" 是 sub-section, "## " 是新 section)
	var search_from := start_idx + start_marker.length()
	var end_idx := -1
	var i := search_from
	while i < text.length():
		# 找 "\n## " (next top-level section)
		if i + 4 <= text.length() and text[i] == "\n" and text[i + 1] == "#" and text[i + 2] == "#" and text[i + 3] == " ":
			end_idx = i
			break
		i += 1
	if end_idx == -1:
		return text.substr(start_idx)
	return text.substr(start_idx, end_idx - start_idx)


func _record_pass(msg: String) -> void:
	_pass_count += 1
	print("[PASS] %s" % msg)


func _record_fail(msg: String) -> void:
	_fail_count += 1
	_fail_details.append(msg)
	print("[FAIL] %s" % msg)


func _finish() -> void:
	print("")
	print("=== §9.6.49 smoke test summary ===")
	print("PASS: %d" % _pass_count)
	print("FAIL: %d" % _fail_count)
	if _fail_count > 0:
		print("FAIL details:")
		for d in _fail_details:
			print("  - %s" % d)
		print("ALL CHECKS FAILED — §9.6.49 9 元素 1:1 严格分离契约 polish 模式 未落地")
		quit(1)
	else:
		print("ALL CHECKS PASSED — §9.6.49 9 元素 1:1 严格分离契约 polish 模式 落地 0 例外")
		quit(0)
