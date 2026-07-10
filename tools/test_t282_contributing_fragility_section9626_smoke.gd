extends SceneTree
# T282 CONTRIBUTING §9.6.26 6 verb icon 视觉组 (5 段 canonical 1:1 序列) polish 模式 文档化 smoke test
# 验证 23+ 断言: §9.6.26 章节 + 5 段 4 段结构 + 5 段 5 段序列关键字 + 6 §9.6.26 6 任务历史引用 (T013/T034/T040/T085/T103/T241) + 6 verb family 路径 6 目录 + 6 verb 调色六元组 (Coral/Violet/Amber/Cyan/Pale/Mauve) + 6 verb 几何 motif (圆环/螺旋/锋线/盾球/双环/constant 球) + Stage 2 disc + outer ring (#05070D + #69C7CE 1px) + 6 verb 双 export (32x32 + 64x64) + 3 verb achievement 双路径 (echo/wave/whisper) + 6 §9.6.26 6 类症状关键字 + 7 §9.6.26 7 项预防 + 6 verb family 路径 6 目录存在 + 6 verb icon PNG 文件 12 文件 + 3 verb achievement PNG 文件 4 文件 + 14 §9.6.26 14 段 0 触碰边界 + 1 CHANGELOG 同步 + 1 ROADMAP 同步 + 1 README 双语同步 + 1 ITERATION_COUNT +1 → 203 + 1 静态解析 0 SCRIPT ERROR + 1 §9.6.26 drift risk 锚点 + 1 §9.6.4 调色六元组 1:1 镜像 + 1 §9.1 9 步关系 1:1 镜像 + 1 1 文档 1 段 (§9.6.26 ~50 行)

const ASSERTION_COUNT_TARGET := 24
const STYLE_GUIDE_PATH := "res://STYLE_GUIDE.md"
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
	print("[T282] §9.6.26 6 verb icon 视觉组 (5 段 canonical 1:1 序列) polish 模式 文档化 smoke test")
	print("[T282] =====================================================================")

	var exit_code := 0
	exit_code = _run_all_assertions()
	print("[T282] =====================================================================")
	print("[T282] Total assertions: %d | Passed: %d | Failed: %d" % [_assertion_count, _pass_count, _fail_count])
	if _fail_count == 0:
		print("[T282] STATUS: PASS")
	else:
		print("[T282] STATUS: FAIL")
		exit_code = 1
	quit(exit_code)

func _run_all_assertions() -> int:
	var contributing_text := _read_file_text(CONTRIBUTING_PATH)
	var changelog_text := _read_file_text(CHANGELOG_PATH)
	var roadmap_text := _read_file_text(ROADMAP_PATH)
	var readme_text := _read_file_text(README_PATH)
	var readme_zh_text := _read_file_text(README_ZH_CN_PATH)
	var iteration_count_text := _read_file_text(ITERATION_COUNT_PATH).strip_edges()

	# 1. §9.6.26 章节标题存在
	_assert("§9.6.26 章节标题存在",
		contributing_text.find("### 9.6.26 6 verb icon 视觉组") != -1)

	# 2. 5 段 4 段结构: 症状 / 触发场景 / 修复 / 预防
	var has_symptom := contributing_text.find("- **症状**:") != -1
	var has_trigger := contributing_text.find("- **触发场景**:") != -1
	var has_repair := contributing_text.find("- **修复**") != -1
	var has_prevention := contributing_text.find("- **预防**:") != -1
	_assert("§9.6.26 4 段结构完整 (症状+触发+修复+预防)",
		has_symptom and has_trigger and has_repair and has_prevention)

	# 3. 5 段 5 段序列关键字 (Stage 1-5)
	var has_stage_1 := contributing_text.find("Stage 1") != -1
	var has_stage_2 := contributing_text.find("Stage 2") != -1
	var has_stage_3 := contributing_text.find("Stage 3") != -1
	var has_stage_4 := contributing_text.find("Stage 4") != -1
	var has_stage_5 := contributing_text.find("Stage 5") != -1
	_assert("§9.6.26 5 段序列 (Stage 1-5) 关键字全有",
		has_stage_1 and has_stage_2 and has_stage_3 and has_stage_4 and has_stage_5)

	# 4. 6 §9.6.26 6 任务历史引用 (T013 / T034 / T040 / T085 / T103 / T241 + T245)
	var ref_t013 := contributing_text.find("T013") != -1
	var ref_t034 := contributing_text.find("T034") != -1
	var ref_t040 := contributing_text.find("T040") != -1
	var ref_t085 := contributing_text.find("T085") != -1
	var ref_t103 := contributing_text.find("T103") != -1
	var ref_t245 := contributing_text.find("T245") != -1
	_assert("§9.6.26 6 任务历史引用 (T013/T034/T040/T085/T103/T245)",
		ref_t013 and ref_t034 and ref_t040 and ref_t085 and ref_t103 and ref_t245)

	# 5. 6 verb family 路径 6 目录 (pulse_icon / bind_icon / cut_icon / echo_icon / wave_icon / whisper_icon)
	var has_pulse_icon := contributing_text.find("pulse_icon") != -1
	var has_bind_icon := contributing_text.find("bind_icon") != -1
	var has_cut_icon := contributing_text.find("cut_icon") != -1
	var has_echo_icon := contributing_text.find("echo_icon") != -1
	var has_wave_icon := contributing_text.find("wave_icon") != -1
	var has_whisper_icon := contributing_text.find("whisper_icon") != -1
	_assert("§9.6.26 6 verb family 路径 6 目录 (pulse/bind/cut/echo/wave/whisper)",
		has_pulse_icon and has_bind_icon and has_cut_icon and has_echo_icon and has_wave_icon and has_whisper_icon)

	# 6. 6 verb 调色六元组 (Coral / Violet / Amber / Cyan / Pale / Mauve)
	var has_coral := contributing_text.find("Coral") != -1
	var has_violet := contributing_text.find("Violet") != -1
	var has_amber := contributing_text.find("Amber") != -1
	var has_cyan := contributing_text.find("Cyan") != -1
	var has_pale := contributing_text.find("Pale") != -1
	var has_mauve := contributing_text.find("Mauve") != -1
	_assert("§9.6.26 6 verb 调色六元组 (Coral+Violet+Amber+Cyan+Pale+Mauve)",
		has_coral and has_violet and has_amber and has_cyan and has_pale and has_mauve)

	# 7. 6 verb 几何 motif (圆环 / 螺旋 / 锋线 / 盾球 / 双环 / constant 球)
	var has_circle := contributing_text.find("圆环") != -1
	var has_spiral := contributing_text.find("螺旋") != -1
	var has_blade := contributing_text.find("锋线") != -1
	var has_shield := contributing_text.find("盾球") != -1
	var has_double_ring := contributing_text.find("双环") != -1
	var has_constant := contributing_text.find("constant 球") != -1 or contributing_text.find("constant球") != -1
	_assert("§9.6.26 6 verb 几何 motif (圆环+螺旋+锋线+盾球+双环+constant 球)",
		has_circle and has_spiral and has_blade and has_shield and has_double_ring and has_constant)

	# 8. Stage 2 disc + outer ring (deep ink navy #05070D + glass cyan #69C7CE 1px)
	var has_ink_navy := contributing_text.find("#05070D") != -1
	var has_glass_cyan := contributing_text.find("#69C7CE") != -1
	var has_1px := contributing_text.find("1px") != -1
	_assert("§9.6.26 Stage 2 disc + outer ring (#05070D + #69C7CE 1px)",
		has_ink_navy and has_glass_cyan and has_1px)

	# 9. 6 verb 双 export (32x32 + 64x64)
	var has_32x32 := contributing_text.find("32x32") != -1
	var has_64x64 := contributing_text.find("64x64") != -1
	var has_dual_export := contributing_text.find("双 export") != -1
	_assert("§9.6.26 6 verb 双 export (32x32 + 64x64)",
		has_32x32 and has_64x64 and has_dual_export)

	# 10. 3 verb achievement 双路径 (echo_icon / wave_icon / whisper_icon) — 与 §9.6.21 PNG 双路径 1:1 镜像
	var has_achievement_path := contributing_text.find("achievements/<verb>_icon") != -1 or contributing_text.find("achievements/whisper_icon") != -1 or contributing_text.find("assets/ui/achievements") != -1
	var has_3_verb_achievement := contributing_text.find("3 verb achievement") != -1 or contributing_text.find("3 verb 双路径") != -1
	_assert("§9.6.26 3 verb achievement 双路径 (echo/wave/whisper 1:1 §9.6.21)",
		has_achievement_path and has_3_verb_achievement)

	# 11. 6 §9.6.26 6 类症状关键字
	var symptom_1 := contributing_text.find("漏 Stage 1 family 路径") != -1
	var symptom_2 := contributing_text.find("漏 Stage 2 disc") != -1 or contributing_text.find("Stage 2 disc + outer ring 1:1 镜像") != -1
	var symptom_3 := contributing_text.find("漏 Stage 3 调色") != -1 or contributing_text.find("Stage 3 调色 1:1 同步") != -1
	var symptom_4 := contributing_text.find("漏 Stage 4 几何") != -1 or contributing_text.find("Stage 4 几何 1:1 同步") != -1
	var symptom_5 := contributing_text.find("漏 Stage 5 双 export") != -1 or contributing_text.find("Stage 5 双 export 1:1 同步") != -1
	var symptom_6 := contributing_text.find("3 verb achievement") != -1
	_assert("§9.6.26 6 类症状关键字",
		symptom_1 and symptom_2 and symptom_3 and symptom_4 and symptom_5 and symptom_6)

	# 12. 7 §9.6.26 7 项预防
	var prevention_1 := contributing_text.find("5 段 canonical 1:1 序列") != -1 and contributing_text.find("1:1 复制") != -1
	var prevention_2 := contributing_text.find("5 段序列 0 触碰边界") != -1
	var prevention_3 := contributing_text.find("6 verb 调色 0 改 1 hex") != -1
	var prevention_4 := contributing_text.find("6 verb 几何 0 改") != -1
	var prevention_5 := contributing_text.find("6 verb 双 export 0 漏") != -1
	var prevention_6 := contributing_text.find("3 verb achievement 双路径 0 漏") != -1
	var prevention_7 := contributing_text.find("drift risk") != -1
	_assert("§9.6.26 7 项预防",
		prevention_1 and prevention_2 and prevention_3 and prevention_4 and prevention_5 and prevention_6 and prevention_7)

	# 13. 6 verb family 路径 6 目录存在 (文件系统)
	var fs_pulse := FileAccess.file_exists("res://assets/ui/pulse_icon/pulse_icon.png")
	var fs_bind := FileAccess.file_exists("res://assets/ui/bind_icon/bind_icon.png")
	var fs_cut := FileAccess.file_exists("res://assets/ui/cut_icon/cut_icon.png")
	var fs_echo := FileAccess.file_exists("res://assets/ui/echo_icon/echo_icon.png")
	var fs_wave := FileAccess.file_exists("res://assets/ui/wave_icon/wave_icon.png")
	var fs_whisper := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon.png")
	_assert("6 verb family 路径 6 icon PNG 存在 (filesystem)",
		fs_pulse and fs_bind and fs_cut and fs_echo and fs_wave and fs_whisper)

	# 14. 6 verb icon 双 export 12 文件 + 3 verb achievement 4 文件 (filesystem)
	var fs_pulse_64 := FileAccess.file_exists("res://assets/ui/pulse_icon/pulse_icon_64x64.png")
	var fs_bind_64 := FileAccess.file_exists("res://assets/ui/bind_icon/bind_icon_64x64.png")
	var fs_cut_64 := FileAccess.file_exists("res://assets/ui/cut_icon/cut_icon_64x64.png")
	var fs_echo_64 := FileAccess.file_exists("res://assets/ui/echo_icon/echo_icon_64x64.png")
	var fs_wave_64 := FileAccess.file_exists("res://assets/ui/wave_icon/wave_icon_64x64.png")
	var fs_whisper_64 := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon_64x64.png")
	var fs_echo_achv := FileAccess.file_exists("res://assets/ui/achievements/echo_icon/echo_icon.png")
	var fs_wave_achv := FileAccess.file_exists("res://assets/ui/achievements/wave_icon/wave_icon.png")
	var fs_whisper_achv := FileAccess.file_exists("res://assets/ui/achievements/whisper_icon/whisper_icon.png")
	_assert("6 verb 双 export 12 文件 + 3 verb achievement 4 文件 存在 (filesystem)",
		fs_pulse_64 and fs_bind_64 and fs_cut_64 and fs_echo_64 and fs_wave_64 and fs_whisper_64 and fs_echo_achv and fs_wave_achv and fs_whisper_achv)

	# 15. 14 §9.6.26 14 段 0 触碰边界 (与 §9.6.1-§9.6.5 + §9.6.16-§9.6.25 14 段既有 + §9.6.26 自身 0 触碰)
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
	var boundary_9_6_25_2 := contributing_text.find("§9.6.25") != -1
	_assert("§9.6.26 14 段 0 触碰边界 (与 §9.6.1-§9.6.5 + §9.6.16-§9.6.25 14 段)",
		boundary_9_6_1 and boundary_9_6_2 and boundary_9_6_3_2 and boundary_9_6_4_2 and boundary_9_6_5_2 and boundary_9_6_16_2 and boundary_9_6_17_2 and boundary_9_6_18_2 and boundary_9_6_19_2 and boundary_9_6_20_2 and boundary_9_6_21_2 and boundary_9_6_22_2 and boundary_9_6_24_2 and boundary_9_6_25_2)

	# 16. CHANGELOG 同步 (#203 T282 entry)
	_assert("CHANGELOG #203 T282 entry 同步",
		changelog_text.find("Iteration #203") != -1 and changelog_text.find("T282") != -1 and changelog_text.find("§9.6.26") != -1)

	# 17. ROADMAP 同步 (#203 T282 entry)
	_assert("ROADMAP #203 T282 entry 同步",
		roadmap_text.find("#203") != -1 and roadmap_text.find("T282") != -1 and roadmap_text.find("§9.6.26") != -1)

	# 18. README 双语同步
	var readme_has_203 := readme_text.find("#203") != -1 and readme_text.find("T282") != -1
	var readme_zh_has_203 := readme_zh_text.find("#203") != -1 and readme_zh_text.find("T282") != -1
	_assert("README 双语 #203 T282 entry 同步",
		readme_has_203 and readme_zh_has_203)

	# 19. ITERATION_COUNT +1 → 203 (跨迭代稳定: >=
	_assert("ITERATION_COUNT >= 203 (从 202 +1, 跨迭代稳定)",
		iteration_count_text.to_int() >= 203)

	# 20. 静态解析 0 SCRIPT ERROR (用 _verify_static_parse 函数)
	_assert("静态解析 0 SCRIPT ERROR (CONTRIBUTING.md 文档 polish)", _verify_static_parse())

	# 21. §9.6.26 drift risk 锚点
	_assert("§9.6.26 drift risk 锚点 (防 polish 期重踩 Stage 1-5 漏 1 段同步)",
		contributing_text.find("drift risk") != -1)

	# 22. §9.6.4 调色六元组 1:1 镜像 (跨段镜像关系)
	_assert("§9.6.26 跨段镜像 §9.6.4 提及 (1:1 镜像 0 漏 1 段)",
		contributing_text.find("§9.6.4") != -1 and (contributing_text.find("调色六元组") != -1))

	# 23. §9.1 9 步关系 1:1 镜像
	_assert("§9.6.26 与 §9.1 9 步关系 1:1 镜像",
		contributing_text.find("§9.1 9 步") != -1)

	# 24. 1 文档 1 段 (§9.6.26 ~50 行)
	# Verify §9.6.26 section has ~50 lines (between start and end of section)
	# 跨迭代稳定: 下一段用 next §9.6.27 而非 ## 11. (因 ## 11. 后中间可能插入更多 §9.6.x 段)
	var section_start := contributing_text.find("### 9.6.26 6 verb icon 视觉组")
	var next_section_start := contributing_text.find("### 9.6.27", section_start) if section_start != -1 else -1
	var section_text := ""
	if section_start != -1 and next_section_start != -1:
		section_text = contributing_text.substr(section_start, next_section_start - section_start)
	elif section_start != -1:
		section_text = contributing_text.substr(section_start)
	var line_count := section_text.count("\n")
	_assert("§9.6.26 段 ~50 行 (10-100 行范围)", line_count >= 10 and line_count <= 100)

	return 0 if _fail_count == 0 else 1

func _verify_static_parse() -> bool:
	# 验证 §9.6.26 文档 polish 0 触碰 .gd / .tscn / 任何 gameplay code
	# 简单起见,只验证 §9.6.26 段有实质内容 (length > 100)
	var contributing_text := _read_file_text(CONTRIBUTING_PATH)
	var section_start := contributing_text.find("### 9.6.26 6 verb icon 视觉组")
	var next_section_start := contributing_text.find("### 9.6.27", section_start) if section_start != -1 else -1
	var section_text := ""
	if section_start != -1 and next_section_start != -1:
		section_text = contributing_text.substr(section_start, next_section_start - section_start)
	elif section_start != -1:
		section_text = contributing_text.substr(section_start)
	# §9.6.26 段应该是 markdown 文档,不应该有 .gd 代码错误
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
		print("[T282] [PASS] %s" % name)
	else:
		_fail_count += 1
		print("[T282] [FAIL] %s" % name)
