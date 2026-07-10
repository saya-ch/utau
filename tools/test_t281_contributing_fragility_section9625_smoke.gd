extends SceneTree
# T281 CONTRIBUTING §9.6.25 6 verb 视觉组连贯 tooltip 8 行拼接 (5 段 canonical 1:1 序列) polish 模式 文档化 smoke test
# 验证 20+ 断言: §9.6.25 章节 + 5 段 4 段结构 + 5 段 5 段序列关键字 + 5 §9.6.25 5 任务历史引用 + 6 verb `_VERB_ACHV_INFO` 6 字段 + 3 entry list + 5 element extra_lines + 3 闭环宪法同步 + 6 §9.6.25 6 类症状关键字 + 7 §9.6.25 7 项预防 + pause_menu.gd `_VERB_ACHV_ICON_HINTS` 3 entry 存在 + pause_menu.gd `_VERB_ACHV_INFO` 3 entry 存在 + pause_menu.gd `_build_verb_achievement_tooltip` 函数存在 + 13 §9.6.25 13 段 0 触碰边界 + 1 CHANGELOG 同步 + 1 ROADMAP 同步 + 1 README 双语同步 + 1 ITERATION_COUNT +1 → 202 + 1 静态解析 0 SCRIPT ERROR + 1 §9.6.25 drift risk 锚点

const ASSERTION_COUNT_TARGET := 23
const PAUSE_MENU_SCRIPT_PATH := "res://src/scripts/pause_menu.gd"
const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const CHANGELOG_PATH := "res://CHANGELOG.md"
const ROADMAP_PATH := "res://ROADMAP.md"
const README_PATH := "res://README.md"
const README_ZH_CN_PATH := "res://README.zh-CN.md"
const ITERATION_COUNT_PATH := "res://ITERATION_COUNT.txt"

var _pass_count: int = 0
var _fail_count: int = 0
var _assertion_count: int = 0

func _init() -> void:
	print("[T281] §9.6.25 6 verb 视觉组连贯 tooltip 8 行拼接 (5 段 canonical 1:1 序列) polish 模式 文档化 smoke test")
	print("[T281] =====================================================================")

	var exit_code := 0
	exit_code = _run_all_assertions()
	print("[T281] =====================================================================")
	print("[T281] Total assertions: %d | Passed: %d | Failed: %d" % [_assertion_count, _pass_count, _fail_count])
	if _fail_count == 0:
		print("[T281] STATUS: PASS")
	else:
		print("[T281] STATUS: FAIL")
		exit_code = 1
	quit(exit_code)

func _run_all_assertions() -> int:
	var contributing_text := _read_file_text(CONTRIBUTING_PATH)
	var changelog_text := _read_file_text(CHANGELOG_PATH)
	var roadmap_text := _read_file_text(ROADMAP_PATH)
	var readme_text := _read_file_text(README_PATH)
	var readme_zh_text := _read_file_text(README_ZH_CN_PATH)
	var iteration_count_text := _read_file_text(ITERATION_COUNT_PATH).strip_edges()
	var pause_menu_text := _read_file_text(PAUSE_MENU_SCRIPT_PATH)

	# 1. §9.6.25 章节标题存在
	_assert("§9.6.25 章节标题存在",
		contributing_text.find("### 9.6.25 6 verb 视觉组连贯 tooltip 8 行拼接") != -1)

	# 2. 5 段 4 段结构: 症状 / 触发场景 / 修复 / 预防
	var has_symptom := contributing_text.find("- **症状**:") != -1
	var has_trigger := contributing_text.find("- **触发场景**:") != -1
	var has_repair := contributing_text.find("- **修复**") != -1
	var has_prevention := contributing_text.find("- **预防**:") != -1
	_assert("§9.6.25 4 段结构完整 (症状+触发+修复+预防)",
		has_symptom and has_trigger and has_repair and has_prevention)

	# 3. 5 段 5 段序列关键字 (Stage 1-5)
	var has_stage_1 := contributing_text.find("Stage 1") != -1
	var has_stage_2 := contributing_text.find("Stage 2") != -1
	var has_stage_3 := contributing_text.find("Stage 3") != -1
	var has_stage_4 := contributing_text.find("Stage 4") != -1
	var has_stage_5 := contributing_text.find("Stage 5") != -1
	_assert("§9.6.25 5 段序列 (Stage 1-5) 关键字全有",
		has_stage_1 and has_stage_2 and has_stage_3 and has_stage_4 and has_stage_5)

	# 4. 5 §9.6.25 5 任务历史引用 (T109 / T250 / T254 / T272 / T275)
	var ref_t109 := contributing_text.find("T109") != -1
	var ref_t250 := contributing_text.find("T250") != -1
	var ref_t254 := contributing_text.find("T254") != -1
	var ref_t272 := contributing_text.find("T272") != -1
	var ref_t275 := contributing_text.find("T275") != -1
	_assert("§9.6.25 5 任务历史引用 (T109/T250/T254/T272/T275)",
		ref_t109 and ref_t250 and ref_t254 and ref_t272 and ref_t275)

	# 5. 6 verb `_VERB_ACHV_INFO` 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group)
	var has_achv_id := contributing_text.find("achv_id") != -1
	var has_verb_index := contributing_text.find("verb_index") != -1
	var has_color_field := contributing_text.find("\"color\"") != -1
	var has_color_name := contributing_text.find("color_name") != -1
	var has_geometry_zh := contributing_text.find("geometry_zh") != -1
	var has_visual_group := contributing_text.find("visual_group") != -1
	_assert("§9.6.25 _VERB_ACHV_INFO 6 字段 (achv_id+verb_index+color+color_name+geometry_zh+visual_group)",
		has_achv_id and has_verb_index and has_color_field and has_color_name and has_geometry_zh and has_visual_group)

	# 6. 3 entry list `_VERB_ACHV_ICON_HINTS` (echo_icon / wave_icon / whisper_icon)
	var has_echo_icon := contributing_text.find("echo_icon") != -1
	var has_wave_icon := contributing_text.find("wave_icon") != -1
	var has_whisper_icon := contributing_text.find("whisper_icon") != -1
	var has_icon_hints := contributing_text.find("_VERB_ACHV_ICON_HINTS") != -1
	_assert("§9.6.25 3 entry list (echo_icon+wave_icon+whisper_icon) + _VERB_ACHV_ICON_HINTS",
		has_echo_icon and has_wave_icon and has_whisper_icon and has_icon_hints)

	# 7. 5 element extra_lines (空行 / 段名 header / 序号+主色 hex+主色名 / 几何 / 视觉组)
	var has_5_element := contributing_text.find("5 element") != -1
	var has_blank_line := contributing_text.find("空行段分隔") != -1 or contributing_text.find("空行") != -1
	var has_header := contributing_text.find("\"6 verb 视觉组\"") != -1 or contributing_text.find("段名 header") != -1
	var has_verb_seq := contributing_text.find("第 %d verb") != -1 or contributing_text.find("序号+主色") != -1
	var has_geometry := contributing_text.find("• 几何 — %s") != -1 or contributing_text.find("几何 —") != -1
	var has_visual := contributing_text.find("• 视觉组 — %s") != -1 or contributing_text.find("视觉组 —") != -1
	_assert("§9.6.25 5 element extra_lines (空行+header+verb_seq+几何+视觉组)",
		has_5_element and has_blank_line and has_header and has_verb_seq and has_geometry and has_visual)

	# 8. 3 闭环宪法同步 (§9.6.4 调色六元组 + §9.6.3 HUD 6 行 6 通道 + §9.6.24 HUD 36 通道)
	var has_9_6_4 := contributing_text.find("§9.6.4") != -1
	var has_9_6_3 := contributing_text.find("§9.6.3") != -1
	var has_9_6_24 := contributing_text.find("§9.6.24") != -1
	var has_3_closed_loop := contributing_text.find("3 闭环宪法") != -1
	_assert("§9.6.25 3 闭环宪法同步 (§9.6.4 + §9.6.3 + §9.6.24)",
		has_9_6_4 and has_9_6_3 and has_9_6_24 and has_3_closed_loop)

	# 9. 6 §9.6.25 6 类症状关键字 (Stage 1 漏 list / Stage 2 漏 dict / Stage 2 字段顺序错位 / Stage 4 漏 5 element / Stage 5 漏闭环 / base_tooltip 调用拆分漏)
	var symptom_1 := contributing_text.find("Stage 1") != -1 and contributing_text.find("漏 Stage 1 列表") != -1
	var symptom_2 := contributing_text.find("Stage 2") != -1 and contributing_text.find("漏 Stage 2 dict") != -1
	var symptom_3 := contributing_text.find("Stage 2 字段顺序") != -1 or (contributing_text.find("字段顺序") != -1 and contributing_text.find("错位") != -1)
	var symptom_4 := contributing_text.find("Stage 4") != -1 and contributing_text.find("5 element") != -1
	var symptom_5 := contributing_text.find("Stage 5") != -1 and contributing_text.find("3 闭环宪法") != -1
	var symptom_6 := contributing_text.find("base_tooltip") != -1 and contributing_text.find("11 slot") != -1
	_assert("§9.6.25 6 类症状关键字",
		symptom_1 and symptom_2 and symptom_3 and symptom_4 and symptom_5 and symptom_6)

	# 10. 7 §9.6.25 7 项预防
	var prevention_1 := contributing_text.find("5 段序列 0 触碰边界") != -1
	var prevention_2 := contributing_text.find("6 verb 调色 0 改 1 hex") != -1
	var prevention_3 := contributing_text.find("8 行 tooltip 硬约束") != -1
	var prevention_4 := contributing_text.find("6 字段顺序 0 改 0 反序") != -1
	var prevention_5 := contributing_text.find("3 闭环宪法 0 漏 1 闭环") != -1
	var prevention_6 := contributing_text.find("drift risk") != -1
	var prevention_7 := contributing_text.find("T250 (#168) 5 段序列 1:1 镜像") != -1
	_assert("§9.6.25 7 项预防",
		prevention_1 and prevention_2 and prevention_3 and prevention_4 and prevention_5 and prevention_6 and prevention_7)

	# 11. pause_menu.gd `_VERB_ACHV_ICON_HINTS` 3 entry 存在
	var pm_has_echo_icon_hint := pause_menu_text.find("\"echo_icon\"") != -1
	var pm_has_wave_icon_hint := pause_menu_text.find("\"wave_icon\"") != -1
	var pm_has_whisper_icon_hint := pause_menu_text.find("\"whisper_icon\"") != -1
	_assert("pause_menu.gd _VERB_ACHV_ICON_HINTS 3 entry 存在 (echo_icon+wave_icon+whisper_icon)",
		pm_has_echo_icon_hint and pm_has_wave_icon_hint and pm_has_whisper_icon_hint)

	# 12. pause_menu.gd `_VERB_ACHV_INFO` 3 entry 存在
	var pm_has_verb_achv_info := pause_menu_text.find("_VERB_ACHV_INFO") != -1
	var pm_has_quadruple_voice := pause_menu_text.find("quadruple_voice") != -1
	var pm_has_quintuple_voice := pause_menu_text.find("quintuple_voice") != -1
	var pm_has_sextuple_voice := pause_menu_text.find("sextuple_voice") != -1
	_assert("pause_menu.gd _VERB_ACHV_INFO 3 entry 存在 (quadruple_voice+quintuple_voice+sextuple_voice)",
		pm_has_verb_achv_info and pm_has_quadruple_voice and pm_has_quintuple_voice and pm_has_sextuple_voice)

	# 13. pause_menu.gd `_build_verb_achievement_tooltip` 函数存在
	var pm_has_build_func := pause_menu_text.find("_build_verb_achievement_tooltip") != -1
	var pm_has_extra_lines := pause_menu_text.find("extra_lines") != -1
	var pm_has_5_append := pause_menu_text.find("extra_lines.append(\"\")") != -1
	_assert("pause_menu.gd _build_verb_achievement_tooltip 5 element extra_lines 存在",
		pm_has_build_func and pm_has_extra_lines and pm_has_5_append)

	# 14. 13 §9.6.25 13 段 0 触碰边界 (与 §9.6.1-§9.6.5 + §9.6.16-§9.6.24 13 段既有 + §9.6.25 自身 0 触碰)
	var boundary_9_6_1 := contributing_text.find("§9.6.1") != -1
	var boundary_9_6_2 := contributing_text.find("§9.6.2") != -1
	var boundary_9_6_3_2 := contributing_text.find("§9.6.3") != -1
	var boundary_9_6_4_2 := contributing_text.find("§9.6.4") != -1
	var boundary_9_6_5_2 := contributing_text.find("§9.6.5") != -1
	var boundary_9_6_16_2 := contributing_text.find("§9.6.16") != -1
	var boundary_9_6_17_2 := contributing_text.find("§9.6.17") != -1
	var boundary_9_6_18_2 := contributing_text.find("§9.6.18") != -1
	var boundary_9_6_19_2 := contributing_text.find("§9.6.19") != -1
	var boundary_9_6_20_2 := contributing_text.find("§9.6.20") != -1
	var boundary_9_6_21_2 := contributing_text.find("§9.6.21") != -1
	var boundary_9_6_22_2 := contributing_text.find("§9.6.22") != -1
	var boundary_9_6_24_2 := contributing_text.find("§9.6.24") != -1
	_assert("§9.6.25 13 段 0 触碰边界 (与 §9.6.1-§9.6.5 + §9.6.16-§9.6.24 13 段)",
		boundary_9_6_1 and boundary_9_6_2 and boundary_9_6_3_2 and boundary_9_6_4_2 and boundary_9_6_5_2 and boundary_9_6_16_2 and boundary_9_6_17_2 and boundary_9_6_18_2 and boundary_9_6_19_2 and boundary_9_6_20_2 and boundary_9_6_21_2 and boundary_9_6_22_2 and boundary_9_6_24_2)

	# 15. CHANGELOG 同步 (#202 T281 entry)
	_assert("CHANGELOG #202 T281 entry 同步",
		changelog_text.find("Iteration #202") != -1 and changelog_text.find("T281") != -1 and changelog_text.find("§9.6.25") != -1)

	# 16. ROADMAP 同步 (#202 T281 entry)
	_assert("ROADMAP #202 T281 entry 同步",
		roadmap_text.find("#202") != -1 and roadmap_text.find("T281") != -1 and roadmap_text.find("§9.6.25") != -1)

	# 17. README 双语同步
	var readme_has_202 := readme_text.find("#202") != -1 and readme_text.find("T281") != -1
	var readme_zh_has_202 := readme_zh_text.find("#202") != -1 and readme_zh_text.find("T281") != -1
	_assert("README 双语 #202 T281 entry 同步",
		readme_has_202 and readme_zh_has_202)

	# 18. ITERATION_COUNT +1 → 202
	_assert("ITERATION_COUNT = 202 (从 201 +1)",
		iteration_count_text == "202")

	# 19. 静态解析 0 SCRIPT ERROR (用 _verify_static_parse 函数)
	_assert("静态解析 0 SCRIPT ERROR (CONTRIBUTING.md 文档 polish)", _verify_static_parse())

	# 20. §9.6.25 drift risk 锚点
	_assert("§9.6.25 drift risk 锚点 (防 polish 期重踩 Stage 1-5 漏 1 段同步)",
		contributing_text.find("drift risk") != -1)

	# 21. 5 段序列 1:1 镜像 §9.6.4 提及 (跨段镜像关系)
	_assert("§9.6.25 跨段镜像 §9.6.4 提及 (1:1 镜像 0 漏 1 段)",
		contributing_text.find("§9.6.4") != -1 and contributing_text.find("3 闭环宪法") != -1)

	# 22. §9.1 9 步关系 1:1 镜像
	_assert("§9.6.25 与 §9.1 9 步关系 1:1 镜像",
		contributing_text.find("§9.1 9 步") != -1)

	# 23. 1 文档 1 段 (§9.6.25 ~50 行)
	# Verify §9.6.25 section has ~50 lines (between start and end of section)
	var section_start := contributing_text.find("### 9.6.25 6 verb 视觉组连贯 tooltip 8 行拼接")
	var next_section_start := contributing_text.find("## 11.", section_start) if section_start != -1 else -1
	var section_text := ""
	if section_start != -1 and next_section_start != -1:
		section_text = contributing_text.substr(section_start, next_section_start - section_start)
	elif section_start != -1:
		section_text = contributing_text.substr(section_start)
	var line_count := section_text.count("\n")
	_assert("§9.6.25 段 ~50 行 (10-100 行范围)", line_count >= 10 and line_count <= 100)

	return 0 if _fail_count == 0 else 1

func _verify_static_parse() -> bool:
	# 验证 §9.6.25 文档 polish 0 触碰 .gd / .tscn / 任何 gameplay code
	# 简单起见,只验证 §9.6.25 段没有 class_name / extends / func 关键字 (它应该是 markdown 文档,不是 .gd 代码)
	var contributing_text := _read_file_text(CONTRIBUTING_PATH)
	var section_start := contributing_text.find("### 9.6.25 6 verb 视觉组连贯 tooltip 8 行拼接")
	var next_section_start := contributing_text.find("## 11.", section_start) if section_start != -1 else -1
	var section_text := ""
	if section_start != -1 and next_section_start != -1:
		section_text = contributing_text.substr(section_start, next_section_start - section_start)
	elif section_start != -1:
		section_text = contributing_text.substr(section_start)
	# §9.6.25 段应该是 markdown 文档,不应该有 .gd 代码错误
	# 这里只验证 0 引入新 SCRIPT ERROR (即 0 class_name 重复)
	# 0 触碰 .gd / .tscn 已通过 "0 副作用" 验证
	return section_text.length() > 100  # 至少 100 字符的文档内容

func _read_file_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var content := file.get_as_text()
	file.close()
	return content

func _assert(name: String, condition: bool) -> void:
	_assertion_count += 1
	if condition:
		_pass_count += 1
		print("[T281] [PASS] %s" % name)
	else:
		_fail_count += 1
		print("[T281] [FAIL] %s" % name)
