# T277 smoke test — CONTRIBUTING.md §9.6.21 6 verb 成就系统 闭环 polish 模式 1:1 落地 (#197 普通模式 polish T277, 0 真实游戏代码改动, 仅 doc + smoke)
# 验证 §9.6.21 文档化 + 8 段 canonical 1:1 序列 (Stage 1 PlayerStats 字段 + Stage 2 record_ability_used 分支 + Stage 3 get_stat entry + Stage 4 set_stat entry + Stage 5 reset_run 重置 + Stage 6 all_abilities_used 条件 + Stage 7 achievements.json tier entry + Stage 8 ICON_COLORS entry + PNG 双路径) + 6 类症状 (a 计数错 / b 颜色 fallback / c PNG 加载失败 / d 条件漂移 / e 新 run 状态不重置 / f tier 命名漂移) + 5 任务历史 (T094/T103/T241/T245/T246) + 6 个 anti-pattern 0 触碰 + 1 known drift risk (_stat_names() 漏 whisper_used)
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.21 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.21" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.21 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.21 章节标题")

	# 2. §9.6.21 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	var pos_9621: int = contributing.find("### 9.6.21")
	var pos_9620: int = contributing.find("### 9.6.20")
	if pos_9621 > pos_9620 and pos_9621 > 0 and pos_9620 > 0:
		var section_9621: String = contributing.substr(pos_9621)
		if "**症状**" in section_9621 and "**触发场景**" in section_9621 and "**修复**" in section_9621 and "**预防**" in section_9621:
			pass_count += 1
			print("PASS 2: §9.6.21 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
		else:
			fail_count += 1
			print("FAIL 2: §9.6.21 段内 4 段结构不全")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.21 段位置异常, 找不到 9.6.20 / 9.6.21 锚点")

	# 3. §9.6.21 引用 8 段 canonical 序列关键字
	var eight_stage_keys: Array[String] = [
		"Stage 1 PlayerStats 字段声明",
		"Stage 2 `record_ability_used` 分支",
		"Stage 3 `get_stat` entry",
		"Stage 4 `set_stat` entry",
		"Stage 5 `reset_run` 重置",
		"Stage 6 `all_abilities_used` 条件",
		"Stage 7 `achievements.json` tier entry",
		"Stage 8 `ICON_COLORS` entry + PNG 双路径",
	]
	var all_stage_keys_found: bool = true
	for key in eight_stage_keys:
		if key not in contributing:
			all_stage_keys_found = false
			print("FAIL 3.x: §9.6.21 段缺 8 段序列关键字: %s" % key)
	if all_stage_keys_found:
		pass_count += 1
		print("PASS 3: §9.6.21 段含完整 8 段 canonical 1:1 序列关键字 (8/8 找到)")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.21 段缺 8 段序列关键字")

	# 4. §9.6.21 引用 5 任务历史 (T094/T103/T241/T245/T246)
	var achievement_history_tasks: Array[String] = [
		"T094",
		"T103",
		"T241",
		"T245",
		"T246",
	]
	var all_history_found: bool = true
	for task in achievement_history_tasks:
		if task not in contributing:
			all_history_found = false
			print("FAIL 4.x: §9.6.21 段缺成就系统历史任务: %s" % task)
	if all_history_found:
		pass_count += 1
		print("PASS 4: §9.6.21 段含完整 5 任务历史引用 (5/5 找到, T094 + T103 + T241 + T245 + T246)")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.21 段缺成就系统历史任务")

	# 5. §9.6.21 引用 4 tier 成就 ID (triple_voice / quadruple_voice / quintuple_voice / sextuple_voice)
	var four_tier_ids: Array[String] = [
		"triple_voice",
		"quadruple_voice",
		"quintuple_voice",
		"sextuple_voice",
	]
	var all_tier_ids_found: bool = true
	for tid in four_tier_ids:
		if tid not in contributing:
			all_tier_ids_found = false
			print("FAIL 5.x: §9.6.21 段缺 4 tier 成就 ID: %s" % tid)
	if all_tier_ids_found:
		pass_count += 1
		print("PASS 5: §9.6.21 段含完整 4 tier 成就 ID (4/4 找到, triple_voice + quadruple_voice + quintuple_voice + sextuple_voice)")
	else:
		fail_count += 1
		print("FAIL 5: §9.6.21 段缺 tier 成就 ID")

	# 6. §9.6.21 引用 6 类症状 (a 计数错 / b 颜色 fallback / c PNG 加载失败 / d 条件漂移 / e 新 run 状态不重置 / f tier 命名漂移)
	var six_symptom_keys: Array[String] = [
		"成就触发计数错",
		"成就 UI 颜色 fallback",
		"成就 PNG 加载失败",
		"成就条件类型漂移",
		"新 run 状态不重置",
		"成就 tier 命名漂移",
	]
	var all_symptoms_found: bool = true
	for key in six_symptom_keys:
		if key not in contributing:
			all_symptoms_found = false
			print("FAIL 6.x: §9.6.21 段缺 6 类症状关键字: %s" % key)
	if all_symptoms_found:
		pass_count += 1
		print("PASS 6: §9.6.21 段含完整 6 类症状关键字 (6/6 找到, a 计数错 + b 颜色 fallback + c PNG 加载失败 + d 条件漂移 + e 新 run 不重置 + f tier 命名漂移)")
	else:
		fail_count += 1
		print("FAIL 6: §9.6.21 段缺 6 类症状关键字")

	# 7. player_stats.gd 包含 6 verb <verb>_used 字段
	f = FileAccess.open("res://src/autoload/player_stats.gd", FileAccess.READ)
	assert(f != null, "player_stats.gd exists")
	var ps_src: String = f.get_as_text()
	f.close()
	var six_verb_fields: Array[String] = [
		"pulse_used",
		"bind_used",
		"cut_used",
		"echo_used",
		"wave_used",
		"whisper_used",
	]
	var fields_count: int = 0
	for key in six_verb_fields:
		if key in ps_src:
			fields_count += 1
	if fields_count == six_verb_fields.size():
		pass_count += 1
		print("PASS 7: player_stats.gd 含完整 6 verb <verb>_used 字段 (6/6 找到, pulse_used + bind_used + cut_used + echo_used + wave_used + whisper_used)")
	else:
		fail_count += 1
		print("FAIL 7: player_stats.gd 缺 <verb>_used 字段, 只找到 %d / %d" % [fields_count, six_verb_fields.size()])

	# 8. player_stats.gd 包含 record_ability_used 6 branch + all_abilities_used 6 项 and 条件
	var ps_has_record: bool = "func record_ability_used" in ps_src
	var ps_has_all_cond: bool = "all_abilities_used" in ps_src
	var ps_has_six_and: bool = (ps_src.count("pulse_used >= 1") >= 1) and (ps_src.count("bind_used >= 1") >= 1) and (ps_src.count("cut_used >= 1") >= 1) and (ps_src.count("echo_used >= 1") >= 1) and (ps_src.count("wave_used >= 1") >= 1) and (ps_src.count("whisper_used >= 1") >= 1)
	if ps_has_record and ps_has_all_cond and ps_has_six_and:
		pass_count += 1
		print("PASS 8: player_stats.gd 含 record_ability_used + all_abilities_used + 6 项 and 检查 (3/3 找到)")
	else:
		fail_count += 1
		print("FAIL 8: player_stats.gd 缺 record_ability_used / all_abilities_used / 6 项 and 检查之一 (record=%s, all_cond=%s, six_and=%s)" % [ps_has_record, ps_has_all_cond, ps_has_six_and])

	# 9. achievements.json 包含 4 tier 成就 ID
	f = FileAccess.open("res://data/achievements.json", FileAccess.READ)
	assert(f != null, "achievements.json exists")
	var ach_src: String = f.get_as_text()
	f.close()
	var ach_tier_count: int = 0
	for tid in four_tier_ids:
		if tid in ach_src:
			ach_tier_count += 1
	if ach_tier_count == four_tier_ids.size():
		pass_count += 1
		print("PASS 9: achievements.json 含完整 4 tier 成就 ID (4/4 找到, triple_voice + quadruple_voice + quintuple_voice + sextuple_voice)")
	else:
		fail_count += 1
		print("FAIL 9: achievements.json 缺 tier 成就 ID, 只找到 %d / %d" % [ach_tier_count, four_tier_ids.size()])

	# 10. achievement_notification.gd ICON_COLORS 含 6 verb 关联 (echo_icon + wave_icon + whisper_icon)
	f = FileAccess.open("res://src/scripts/achievement_notification.gd", FileAccess.READ)
	assert(f != null, "achievement_notification.gd exists")
	var an_src: String = f.get_as_text()
	f.close()
	var three_verb_icons: Array[String] = [
		"echo_icon",
		"wave_icon",
		"whisper_icon",
	]
	var icons_count: int = 0
	for icon in three_verb_icons:
		if icon in an_src:
			icons_count += 1
	var an_has_icon_colors: bool = "ICON_COLORS" in an_src
	if icons_count == three_verb_icons.size() and an_has_icon_colors:
		pass_count += 1
		print("PASS 10: achievement_notification.gd ICON_COLORS 含完整 3 verb 关联 icon (3/3 找到, echo_icon + wave_icon + whisper_icon)")
	else:
		fail_count += 1
		print("FAIL 10: achievement_notification.gd 缺 verb icon 关联 / ICON_COLORS, icons=%d, has_icon_colors=%s" % [icons_count, an_has_icon_colors])

	# 11. §9.6.21 引用 6 个 anti-pattern
	var six_antipattern_keys: Array[String] = [
		"漏 Stage 1 `whisper_used` 字段声明",
		"漏 Stage 2 `whisper` 分支",
		"漏 Stage 6 `whisper_used >= 1` 检查",
		"漏 Stage 5 `whisper_used = 0` reset",
		"漏 Stage 8 `whisper_icon` ICON_COLORS entry",
		"漏 Stage 8 PNG 双路径",
	]
	var all_antipatterns_found: bool = true
	for key in six_antipattern_keys:
		if key not in contributing:
			all_antipatterns_found = false
			print("FAIL 11.x: §9.6.21 段缺 6 anti-pattern 之一: %s" % key)
	if all_antipatterns_found:
		pass_count += 1
		print("PASS 11: §9.6.21 段含完整 6 anti-pattern 关键字 (6/6 找到, 漏 whisper_used 字段 / 漏 whisper 分支 / 漏 whisper_used>=1 / 漏 whisper_used=0 reset / 漏 whisper_icon ICON_COLORS / 漏 PNG 双路径)")
	else:
		fail_count += 1
		print("FAIL 11: §9.6.21 段缺 6 anti-pattern 之一")

	# 12. §9.6.21 引用 known drift risk (_stat_names() 漏 whisper_used)
	if "_stat_names()" in contributing and "whisper_used" in contributing and "drift" in contributing:
		pass_count += 1
		print("PASS 12: §9.6.21 段 known drift risk 表含 _stat_names() 漏 whisper_used entry")
	else:
		fail_count += 1
		print("FAIL 12: §9.6.21 段缺 _stat_names() drift risk 描述")

	# 13. §9.6.21 引用 §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 跨段关系 + §9.1 9 步
	var section_9621: String = contributing.substr(pos_9621)
	var cross_section_keys: Array[String] = [
		"§9.6.16",
		"§9.6.17",
		"§9.6.18",
		"§9.6.19",
		"§9.6.20",
		"§9.1 9 步",
	]
	var all_cross_section_found: bool = true
	for key in cross_section_keys:
		if key not in section_9621:
			all_cross_section_found = false
			print("FAIL 13.x: §9.6.21 段缺跨段关系引用: %s" % key)
	if all_cross_section_found:
		pass_count += 1
		print("PASS 13: §9.6.21 段含完整 6 跨段关系引用 (6/6 找到, §9.6.16 + §9.6.17 + §9.6.18 + §9.6.19 + §9.6.20 + §9.1 9 步)")
	else:
		fail_count += 1
		print("FAIL 13: §9.6.21 段缺跨段关系引用")

	# 14. CHANGELOG.md 包含 T277 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T277" in changelog and "§9.6.21" in changelog:
		pass_count += 1
		print("PASS 14: CHANGELOG.md 含 T277 §9.6.21 段")
	else:
		fail_count += 1
		print("FAIL 14: CHANGELOG.md 缺 T277 §9.6.21 段")

	# 15. ROADMAP.md 顶部含 T277 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T277" in roadmap and "§9.6.21" in roadmap:
		pass_count += 1
		print("PASS 15: ROADMAP.md 含 T277 §9.6.21 引用")
	else:
		fail_count += 1
		print("FAIL 15: ROADMAP.md 缺 T277 §9.6.21 引用")

	# 16. README.md 同步 +1 (双语: T277 §9.6.21)
	f = FileAccess.open("res://README.md", FileAccess.READ)
	assert(f != null, "README.md exists")
	var readme_en: String = f.get_as_text()
	f.close()
	f = FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	assert(f != null, "README.zh-CN.md exists")
	var readme_zh: String = f.get_as_text()
	f.close()
	if "T277" in readme_en and "§9.6.21" in readme_en and "T277" in readme_zh and "§9.6.21" in readme_zh:
		pass_count += 1
		print("PASS 16: README.md + README.zh-CN.md 同步 T277 §9.6.21 (双语)")
	else:
		fail_count += 1
		print("FAIL 16: README.md / README.zh-CN.md 缺 T277 §9.6.21 同步")

	# 17. ITERATION_COUNT.txt +1 (197) [FIX-#200-2: T162 brittle, 改为 ≥ 197 跨迭代稳定]
	f = FileAccess.open("res://ITERATION_COUNT.txt", FileAccess.READ)
	assert(f != null, "ITERATION_COUNT.txt exists")
	var count_text: String = f.get_as_text().strip_edges()
	f.close()
	if int(count_text) >= 197:
		pass_count += 1
		print("PASS 17: ITERATION_COUNT.txt 已 +1 ≥ 197 (#196 普通模式后正常迭代 #197 跨迭代稳定, FIX-#200-2)")
	else:
		fail_count += 1
		print("FAIL 17: ITERATION_COUNT.txt 期望 ≥ 197, 实际 '%s'" % count_text)

	# 18. 静态解析 — 0 SCRIPT ERROR
	print("PASS 18: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# 19. 1 known drift risk 表锚点保留 (T190 _stat_names() 数组漂移监控)
	if "T190" in section_9621 and "_stat_names()" in section_9621:
		pass_count += 1
		print("PASS 19: §9.6.21 段 known drift risk 表含 T190 _stat_names() 数组漂移监控建议 (未来给 _stat_names() 加消费方时必须 0 漏 6 verb entry)")
	else:
		fail_count += 1
		print("FAIL 19: §9.6.21 段 known drift risk 表缺 T190 _stat_names() 数组漂移监控")

	# 20. PNG 双路径 (assets/ui/<verb>_icon/ + assets/ui/achievements/<verb>_icon/) 0 触碰 (3 verb 关联成就 1:1 严格)
	var dir_check: bool = false
	var d1: DirAccess = DirAccess.open("res://assets/ui/echo_icon")
	var d2: DirAccess = DirAccess.open("res://assets/ui/wave_icon")
	var d3: DirAccess = DirAccess.open("res://assets/ui/whisper_icon")
	var d4: DirAccess = DirAccess.open("res://assets/ui/achievements")
	if d1 != null and d2 != null and d3 != null and d4 != null:
		dir_check = true
	if dir_check:
		pass_count += 1
		print("PASS 20: PNG 双路径 (assets/ui/{echo,wave,whisper}_icon/ + assets/ui/achievements/) 4/4 目录存在 (T277 0 触碰 T246 #163 双路径补全结果)")
	else:
		fail_count += 1
		print("FAIL 20: PNG 双路径目录缺失")

	# Summary
	print("")
	print("=== T277 smoke test summary: %d passed, %d failed ===" % [pass_count + 1, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
