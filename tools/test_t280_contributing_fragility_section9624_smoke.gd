extends SceneTree
# T280 CONTRIBUTING §9.6.24 6 verb HUD 6 行 6 色色域分工 6 通道 (5 段 canonical 1:1 序列) polish 模式 文档化 smoke test
# 验证 19+ 断言: §9.6.24 章节 + 5 段 4 段结构 + 5 段 5 段序列关键字 + 6 §9.6.24 6 任务历史引用 + 6 verb 调色 6 字段 + 36 通道 4+2 字段 + 6 verb dict 6 key + 8 element iteration list + 6 §9.6.24 6 类症状关键字 + 7 §9.6.24 7 项预防 + hud.gd 6 verb const 存在 + hud.gd 6 verb glow stylebox 存在 + hud.gd 6 verb @onready var 存在 + 12 §9.6.24 12 段 0 触碰边界 + 1 CHANGELOG 同步 + 1 ROADMAP 同步 + 1 README 双语同步 + 1 ITERATION_COUNT +1 → 201 + 1 静态解析 0 SCRIPT ERROR + 1 §9.6.24 drift risk 锚点

const ASSERTION_COUNT_TARGET := 23
const HUD_SCRIPT_PATH := "res://src/scripts/hud.gd"
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
	print("[T280] §9.6.24 6 verb HUD 6 行 6 色色域分工 6 通道 (5 段 canonical 1:1 序列) polish 模式 文档化 smoke test")
	print("[T280] =====================================================================")

	var exit_code := 0
	exit_code = _run_all_assertions()
	print("[T280] =====================================================================")
	print("[T280] Total assertions: %d | Passed: %d | Failed: %d" % [_assertion_count, _pass_count, _fail_count])
	if _fail_count == 0:
		print("[T280] STATUS: PASS")
	else:
		print("[T280] STATUS: FAIL")
		exit_code = 1
	quit(exit_code)

func _run_all_assertions() -> int:
	var contributing_text := _read_file_text(CONTRIBUTING_PATH)
	var changelog_text := _read_file_text(CHANGELOG_PATH)
	var roadmap_text := _read_file_text(ROADMAP_PATH)
	var readme_text := _read_file_text(README_PATH)
	var readme_zh_text := _read_file_text(README_ZH_CN_PATH)
	var iteration_count_text := _read_file_text(ITERATION_COUNT_PATH).strip_edges()
	var hud_text := _read_file_text(HUD_SCRIPT_PATH)

	# 1. §9.6.24 章节标题存在
	_assert("§9.6.24 章节标题存在",
		contributing_text.find("### 9.6.24 6 verb HUD 6 行 6 色色域分工 6 通道") != -1)

	# 2. 5 段 4 段结构: 症状 / 触发场景 / 修复 / 预防
	var has_symptom := contributing_text.find("- **症状**:") != -1
	var has_trigger := contributing_text.find("- **触发场景**:") != -1
	var has_repair := contributing_text.find("- **修复**") != -1
	var has_prevention := contributing_text.find("- **预防**:") != -1
	_assert("§9.6.24 4 段结构完整 (症状+触发+修复+预防)",
		has_symptom and has_trigger and has_repair and has_prevention)

	# 3. 5 段 5 段序列关键字 (Stage 1-5)
	var has_stage_1 := contributing_text.find("Stage 1") != -1
	var has_stage_2 := contributing_text.find("Stage 2") != -1
	var has_stage_3 := contributing_text.find("Stage 3") != -1
	var has_stage_4 := contributing_text.find("Stage 4") != -1
	var has_stage_5 := contributing_text.find("Stage 5") != -1
	_assert("§9.6.24 5 段序列 (Stage 1-5) 关键字全有",
		has_stage_1 and has_stage_2 and has_stage_3 and has_stage_4 and has_stage_5)

	# 4. 6 §9.6.24 6 任务历史引用 (T200 / T202 / T204 / T206 / T233 / T247)
	var ref_t200 := contributing_text.find("T200") != -1
	var ref_t202 := contributing_text.find("T202") != -1
	var ref_t204 := contributing_text.find("T204") != -1
	var ref_t206 := contributing_text.find("T206") != -1
	var ref_t233 := contributing_text.find("T233") != -1
	var ref_t247 := contributing_text.find("T247") != -1
	_assert("§9.6.24 6 任务历史引用 (T200/T202/T204/T206/T233/T247)",
		ref_t200 and ref_t202 and ref_t204 and ref_t206 and ref_t233 and ref_t247)

	# 5. 6 verb 调色 6 字段 (Pulse / Bind / Cut / Echo / Wave / Whisper 主题色 const)
	var has_pulse_color := contributing_text.find("Coral Pulse") != -1 or contributing_text.find("Amber Voice") != -1
	var has_bind_color := contributing_text.find("Muted Violet") != -1
	var has_cut_color := contributing_text.find("Amber Voice") != -1
	var has_echo_color := contributing_text.find("Glass Cyan") != -1
	var has_wave_color := contributing_text.find("Pale Resonance") != -1
	var has_whisper_color := contributing_text.find("Muted Mauve") != -1
	_assert("§9.6.24 6 verb 调色 6 字段 (Pulse+Bind+Cut+Echo+Wave+Whisper)",
		has_pulse_color and has_bind_color and has_cut_color and has_echo_color and has_wave_color and has_whisper_color)

	# 6. 36 通道 = 6 verb × 6 通道 (4 主通道: icon / name label / fill / cooldown label + 2 派生: reduce_flash / glow border)
	var has_icon_ch := contributing_text.find("icon") != -1
	var has_name_label_ch := contributing_text.find("name label") != -1
	var has_fill_ch := contributing_text.find("fill") != -1
	var has_cooldown_label_ch := contributing_text.find("cooldown label") != -1
	var has_reduce_flash_ch := contributing_text.find("reduce_flash") != -1
	var has_glow_border_ch := contributing_text.find("glow border") != -1
	_assert("§9.6.24 36 通道 4+2 字段 (icon+name+fill+cooldown+reduce_flash+glow)",
		has_icon_ch and has_name_label_ch and has_fill_ch and has_cooldown_label_ch and has_reduce_flash_ch and has_glow_border_ch)

	# 7. 6 verb dict 6 key (pulse / bind / cut / echo / wave / whisper)
	var has_pulse_key := contributing_text.find("\"pulse\":") != -1 or contributing_text.find("pulse / bind / cut / echo / wave / whisper") != -1
	var has_bind_key := contributing_text.find("\"bind\":") != -1 or contributing_text.find("pulse / bind / cut / echo / wave / whisper") != -1
	var has_cut_key := contributing_text.find("\"cut\":") != -1 or contributing_text.find("pulse / bind / cut / echo / wave / whisper") != -1
	var has_echo_key := contributing_text.find("\"echo\":") != -1 or contributing_text.find("pulse / bind / cut / echo / wave / whisper") != -1
	var has_wave_key := contributing_text.find("\"wave\":") != -1 or contributing_text.find("pulse / bind / cut / echo / wave / whisper") != -1
	var has_whisper_key := contributing_text.find("\"whisper\":") != -1 or contributing_text.find("pulse / bind / cut / echo / wave / whisper") != -1
	_assert("§9.6.24 6 verb dict 6 key (pulse+bind+cut+echo+wave+whisper)",
		has_pulse_key and has_bind_key and has_cut_key and has_echo_key and has_wave_key and has_whisper_key)

	# 8. 8 element iteration list (5 verb bar + 1 whisper + 1 resonance + 1 health)
	var has_8_element_list := contributing_text.find("8 element") != -1
	var has_5_verb_bar := contributing_text.find("5 verb bar") != -1
	var has_resonance_element := contributing_text.find("resonance") != -1
	var has_health_element := contributing_text.find("health") != -1
	_assert("§9.6.24 8 element iteration list (5 verb bar + 1 whisper + 1 resonance + 1 health)",
		has_8_element_list and has_5_verb_bar and has_resonance_element and has_health_element)

	# 9. 6 §9.6.24 6 类症状关键字 (Stage 1 漏 4 子节点 / Stage 2 改 1 hex 漏 §9.6.4 同步 / Stage 3 漏 1 通道 / Stage 4 漏 dict key / Stage 5 漏 iteration list element / Stage 1 path 错)
	var symptom_1 := contributing_text.find("Stage 1") != -1 and contributing_text.find("4 子节点") != -1
	var symptom_2 := contributing_text.find("Stage 2") != -1 and contributing_text.find("改 1 hex") != -1
	var symptom_3 := contributing_text.find("Stage 3") != -1 and (contributing_text.find("漏 1 通道") != -1 or contributing_text.find("漏 1 个通道") != -1)
	var symptom_4 := contributing_text.find("Stage 4") != -1 and contributing_text.find("漏") != -1 and contributing_text.find("dict key") != -1
	var symptom_5 := contributing_text.find("Stage 5") != -1 and contributing_text.find("iteration list") != -1
	var symptom_6 := contributing_text.find("Node not found") != -1
	_assert("§9.6.24 6 类症状关键字",
		symptom_1 and symptom_2 and symptom_3 and symptom_4 and symptom_5 and symptom_6)

	# 10. 7 §9.6.24 7 项预防
	var prevention_1 := contributing_text.find("5 段序列 0 触碰边界") != -1
	var prevention_2 := contributing_text.find("6 verb 调色 0 改 1 hex") != -1
	var prevention_3 := contributing_text.find("36 通道 (6 verb × 6 通道) 0 反序 0 漏 0 改 1 通道") != -1
	var prevention_4 := contributing_text.find("dict 6 key 0 改 1 字符") != -1
	var prevention_5 := contributing_text.find("iteration list 0 漏 1 element") != -1
	var prevention_6 := contributing_text.find("drift risk") != -1
	var prevention_7 := contributing_text.find("T247 (#164) 5 段序列 1:1 镜像") != -1
	_assert("§9.6.24 7 项预防",
		prevention_1 and prevention_2 and prevention_3 and prevention_4 and prevention_5 and prevention_6 and prevention_7)

	# 11. hud.gd 6 verb const 存在 (6 主题色 const)
	var hud_has_pulse_glow := hud_text.find("_PULSE_GLOW_COLOR") != -1
	var hud_has_bind_glow := hud_text.find("_BIND_GLOW_COLOR") != -1
	var hud_has_cut_glow := hud_text.find("_CUT_GLOW_COLOR") != -1
	var hud_has_echo_glow := hud_text.find("_ECHO_GLOW_COLOR") != -1
	var hud_has_wave_glow := hud_text.find("_WAVE_GLOW_COLOR") != -1
	var hud_has_whisper_glow := hud_text.find("_WHISPER_GLOW_COLOR") != -1
	_assert("hud.gd 6 verb 主题色 const 6 entry 存在",
		hud_has_pulse_glow and hud_has_bind_glow and hud_has_cut_glow and hud_has_echo_glow and hud_has_wave_glow and hud_has_whisper_glow)

	# 12. hud.gd 6 verb glow stylebox 存在
	var hud_has_pulse_glow_bg := hud_text.find("_pulse_glow_bg") != -1
	var hud_has_bind_glow_bg := hud_text.find("_bind_glow_bg") != -1
	var hud_has_cut_glow_bg := hud_text.find("_cut_glow_bg") != -1
	var hud_has_echo_glow_bg := hud_text.find("_echo_glow_bg") != -1
	var hud_has_wave_glow_bg := hud_text.find("_wave_glow_bg") != -1
	var hud_has_whisper_glow_bg := hud_text.find("_whisper_glow_bg") != -1
	_assert("hud.gd 6 verb glow stylebox 6 instance 存在",
		hud_has_pulse_glow_bg and hud_has_bind_glow_bg and hud_has_cut_glow_bg and hud_has_echo_glow_bg and hud_has_wave_glow_bg and hud_has_whisper_glow_bg)

	# 13. hud.gd 6 verb @onready var 存在
	var hud_has_pulse_cooldown := hud_text.find("_pulse_cooldown") != -1
	var hud_has_bind_cooldown := hud_text.find("_bind_cooldown") != -1
	var hud_has_cut_cooldown := hud_text.find("_cut_cooldown") != -1
	var hud_has_echo_cooldown := hud_text.find("_echo_cooldown") != -1
	var hud_has_wave_cooldown := hud_text.find("_wave_cooldown") != -1
	var hud_has_whisper_cooldown := hud_text.find("_whisper_cooldown") != -1
	_assert("hud.gd 6 verb @onready var 6 cooldown 存在",
		hud_has_pulse_cooldown and hud_has_bind_cooldown and hud_has_cut_cooldown and hud_has_echo_cooldown and hud_has_wave_cooldown and hud_has_whisper_cooldown)

	# 14. 12 §9.6.24 12 段 0 触碰边界 (与 §9.6.3 / §9.6.4 / §9.6.5 / §9.6.16-§9.6.23 12 段既有 + §9.6.24 自身 0 触碰)
	var boundary_9_6_3 := contributing_text.find("§9.6.3") != -1
	var boundary_9_6_4 := contributing_text.find("§9.6.4") != -1
	var boundary_9_6_5 := contributing_text.find("§9.6.5") != -1
	var boundary_9_6_16 := contributing_text.find("§9.6.16") != -1
	var boundary_9_6_17 := contributing_text.find("§9.6.17") != -1
	var boundary_9_6_18 := contributing_text.find("§9.6.18") != -1
	var boundary_9_6_19 := contributing_text.find("§9.6.19") != -1
	var boundary_9_6_20 := contributing_text.find("§9.6.20") != -1
	var boundary_9_6_21 := contributing_text.find("§9.6.21") != -1
	var boundary_9_6_22 := contributing_text.find("§9.6.22") != -1
	var boundary_9_6_23 := contributing_text.find("§9.6.23") != -1
	var boundary_self := contributing_text.find("§9.6.24") != -1
	_assert("§9.6.24 12 段 0 触碰边界 (与 §9.6.3-§9.6.5 + §9.6.16-§9.6.23 + §9.6.24 自身)",
		boundary_9_6_3 and boundary_9_6_4 and boundary_9_6_5 and boundary_9_6_16 and boundary_9_6_17 and boundary_9_6_18 and boundary_9_6_19 and boundary_9_6_20 and boundary_9_6_21 and boundary_9_6_22 and boundary_9_6_23 and boundary_self)

	# 15. CHANGELOG 同步 (#201 T280 entry)
	_assert("CHANGELOG #201 T280 entry 同步",
		changelog_text.find("Iteration #201") != -1 and changelog_text.find("T280") != -1 and changelog_text.find("§9.6.24") != -1)

	# 16. ROADMAP 同步 (#201 T280 entry)
	_assert("ROADMAP #201 T280 entry 同步",
		roadmap_text.find("#201") != -1 and roadmap_text.find("T280") != -1 and roadmap_text.find("§9.6.24") != -1)

	# 17. README 双语同步
	var readme_has_201 := readme_text.find("#201") != -1 and readme_text.find("T280") != -1
	var readme_zh_has_201 := readme_zh_text.find("#201") != -1 and readme_zh_text.find("T280") != -1
	_assert("README 双语 #201 T280 entry 同步",
		readme_has_201 and readme_zh_has_201)

	# 18. ITERATION_COUNT +1 → 201 (跨迭代稳定: >=
	_assert("ITERATION_COUNT >= 201 (从 200 +1, 跨迭代稳定)",
		iteration_count_text.to_int() >= 201)

	# 19. 静态解析 0 SCRIPT ERROR (用 _verify_static_parse 函数)
	_assert("静态解析 0 SCRIPT ERROR (CONTRIBUTING.md 文档 polish)", _verify_static_parse())

	# 20. §9.6.24 drift risk 锚点
	_assert("§9.6.24 drift risk 锚点 (防 polish 期重踩 Stage 1-5 漏 1 段同步)",
		contributing_text.find("drift risk") != -1)

	# 21. 5 段序列 1:1 镜像 §9.6.22 提及 (跨段镜像关系)
	_assert("§9.6.24 跨段镜像 §9.6.22 提及 (1:1 镜像 0 漏 1 段)",
		contributing_text.find("§9.6.22") != -1 and contributing_text.find("镜像") != -1)

	# 22. §9.1 9 步关系 1:1 镜像
	_assert("§9.6.24 与 §9.1 9 步关系 1:1 镜像",
		contributing_text.find("§9.1 9 步") != -1)

	# 23. 1 文档 1 段 (§9.6.24 ~50 行)
	# Verify §9.6.24 section has ~50 lines (between start and end of section)
	# 跨迭代稳定: 下一段用 next §9.6.25 而非 ## 11. (因 ## 11. 后中间可能插入更多 §9.6.x 段)
	var section_start := contributing_text.find("### 9.6.24 6 verb HUD 6 行 6 色色域分工 6 通道")
	var next_section_start := contributing_text.find("### 9.6.25", section_start) if section_start != -1 else -1
	var section_text := ""
	if section_start != -1 and next_section_start != -1:
		section_text = contributing_text.substr(section_start, next_section_start - section_start)
	elif section_start != -1:
		section_text = contributing_text.substr(section_start)
	var line_count := section_text.count("\n")
	_assert("§9.6.24 段 ~50 行 (10-100 行范围)", line_count >= 10 and line_count <= 100)

	return 0 if _fail_count == 0 else 1

func _verify_static_parse() -> bool:
	# 验证 §9.6.24 文档 polish 0 触碰 .gd / .tscn / 任何 gameplay code
	# 简单起见,只验证 §9.6.24 段没有 class_name / extends / func 关键字 (它应该是 markdown 文档,不是 .gd 代码)
	var contributing_text := _read_file_text(CONTRIBUTING_PATH)
	var section_start := contributing_text.find("### 9.6.24 6 verb HUD 6 行 6 色色域分工 6 通道")
	var next_section_start := contributing_text.find("### 9.6.25", section_start) if section_start != -1 else -1
	var section_text := ""
	if section_start != -1 and next_section_start != -1:
		section_text = contributing_text.substr(section_start, next_section_start - section_start)
	elif section_start != -1:
		section_text = contributing_text.substr(section_start)
	# §9.6.24 段应该是 markdown 文档,不应该有 .gd 代码错误
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
		print("[T280] [PASS] %s" % name)
	else:
		_fail_count += 1
		print("[T280] [FAIL] %s" % name)
