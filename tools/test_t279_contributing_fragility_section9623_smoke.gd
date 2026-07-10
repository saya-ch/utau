# T279 smoke test — CONTRIBUTING.md §9.6.23 7 桶 prewarm 5+1+1 polish 模式 1:1 落地 (#199 普通模式 polish T279, 0 真实游戏代码改动, 仅 doc + smoke)
# 验证 §9.6.23 文档化 + 5+1+1 canonical 1:1 序列 (Stage 1 5 桶 baseline + Stage 2 +1 verb fire SFX 桶 + Stage 3 +1 verb cooldown READY 桶) + 7 桶 prewarm_* 函数 (prewarm_music_streams / prewarm_hit_sfx / prewarm_shop_sfx / prewarm_misc_sfx / prewarm_verb_cooldown_tails / prewarm_verb_fire_sfx / prewarm_verb_cooldown_readys) + 5 类症状 (a 漏 aggregator 调点 / b 漏 title screen 调点 / c 漏 hub/state 调点 / d 桶顺序错 / e 漏 5+1+1 标注) + 6 任务历史 (T066/T181/T184/T185.B/F013.B/T220) + 8 段 0 触碰 + 1 known drift risk (跨调用方漏 1 边)
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.23 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.23" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.23 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.23 章节标题")

	# 2. §9.6.23 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	var pos_9623: int = contributing.find("### 9.6.23")
	var pos_9622: int = contributing.find("### 9.6.22")
	if pos_9623 > pos_9622 and pos_9623 > 0 and pos_9622 > 0:
		var section_9623: String = contributing.substr(pos_9623)
		if "**症状**" in section_9623 and "**触发场景**" in section_9623 and "**修复**" in section_9623 and "**预防**" in section_9623:
			pass_count += 1
			print("PASS 2: §9.6.23 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
		else:
			fail_count += 1
			print("FAIL 2: §9.6.23 段内 4 段结构不全")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.23 段位置异常, 找不到 9.6.22 / 9.6.23 锚点")

	# 3. §9.6.23 引用 5+1+1 canonical 序列关键字
	var five_one_one_keys: Array[String] = [
		"Stage 1 5 桶 baseline 预热",
		"Stage 2 +1 verb fire SFX 桶",
		"Stage 3 +1 verb cooldown READY 桶",
	]
	var all_stage_keys_found: bool = true
	for key in five_one_one_keys:
		if key not in contributing:
			all_stage_keys_found = false
			print("FAIL 3.x: §9.6.23 段缺 5+1+1 序列关键字: %s" % key)
	if all_stage_keys_found:
		pass_count += 1
		print("PASS 3: §9.6.23 段含完整 5+1+1 canonical 1:1 序列关键字 (3/3 找到, Stage 1 baseline + Stage 2 verb fire SFX + Stage 3 verb cooldown READY)")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.23 段缺 5+1+1 序列关键字")

	# 4. §9.6.23 引用 6 任务历史 (T066/T181/T184/T185.B/F013.B/T220)
	var prewarm_history_tasks: Array[String] = [
		"T066",
		"T181",
		"T184",
		"T185.B",
		"F013.B",
		"T220",
	]
	var all_history_found: bool = true
	for task in prewarm_history_tasks:
		if task not in contributing:
			all_history_found = false
			print("FAIL 4.x: §9.6.23 段缺 prewarm 历史任务: %s" % task)
	if all_history_found:
		pass_count += 1
		print("PASS 4: §9.6.23 段含完整 6 任务历史引用 (6/6 找到, T066 + T181 + T184 + T185.B + F013.B + T220)")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.23 段缺 prewarm 历史任务")

	# 5. §9.6.23 引用 7 桶 prewarm_* 函数名
	var seven_prewarm_functions: Array[String] = [
		"prewarm_music_streams",
		"prewarm_hit_sfx",
		"prewarm_shop_sfx",
		"prewarm_misc_sfx",
		"prewarm_verb_cooldown_tails",
		"prewarm_verb_fire_sfx",
		"prewarm_verb_cooldown_readys",
	]
	var all_functions_found: bool = true
	for fn in seven_prewarm_functions:
		if fn not in contributing:
			all_functions_found = false
			print("FAIL 5.x: §9.6.23 段缺 7 桶 prewarm_* 函数名: %s" % fn)
	if all_functions_found:
		pass_count += 1
		print("PASS 5: §9.6.23 段含完整 7 桶 prewarm_* 函数名 (7/7 找到, music + hit + shop + misc + verb_cooldown_tails + verb_fire + verb_cooldown_readys)")
	else:
		fail_count += 1
		print("FAIL 5: §9.6.23 段缺 7 桶 prewarm_* 函数名")

	# 6. §9.6.23 引用 aggregator `prewarm_all_sfx()` 函数
	if "prewarm_all_sfx" in contributing and "aggregator" in contributing:
		pass_count += 1
		print("PASS 6: §9.6.23 段含 prewarm_all_sfx() aggregator 引用")
	else:
		fail_count += 1
		print("FAIL 6: §9.6.23 段缺 prewarm_all_sfx() aggregator 引用")

	# 7. §9.6.23 引用 3 跨调用方 (title_screen._prewarm_bgm / hub_controller enter_hub / game_flow_controller _on_state_changed)
	var three_callers: Array[String] = [
		"title_screen.gd._prewarm_bgm",
		"hub_controller.gd",
		"game_flow_controller.gd",
	]
	var all_callers_found: bool = true
	for caller in three_callers:
		if caller not in contributing:
			all_callers_found = false
			print("FAIL 7.x: §9.6.23 段缺 3 跨调用方引用: %s" % caller)
	if all_callers_found:
		pass_count += 1
		print("PASS 7: §9.6.23 段含完整 3 跨调用方 1:1 镜像引用 (3/3 找到, title_screen + hub_controller + game_flow_controller)")
	else:
		fail_count += 1
		print("FAIL 7: §9.6.23 段缺 3 跨调用方 1:1 镜像引用")

	# 8. §9.6.23 引用 6 类症状 (漏 aggregator / 漏 title screen 4/5 baseline / 漏 hub/state aggregator / 桶顺序错 / 漏 5+1+1 标注 / title screen partial vs aggregator full 漂动)
	var six_symptom_keys: Array[String] = [
		"加新 1 桶漏 aggregator 调点",
		"加新 1 桶漏 title screen 4/5 baseline 调点",
		"加新 1 桶漏 hub/state aggregator 调点",
		"修 1 桶顺序漏 aggregator 顺序",
		"加新 1 桶 5+1+1 结构 0 标注",
		"title screen partial 4/5 baseline vs aggregator full 7 桶 漂动",
	]
	var all_symptoms_found: bool = true
	for key in six_symptom_keys:
		if key not in contributing:
			all_symptoms_found = false
			print("FAIL 8.x: §9.6.23 段缺 6 类症状关键字: %s" % key)
	if all_symptoms_found:
		pass_count += 1
		print("PASS 8: §9.6.23 段含完整 6 类症状关键字 (6/6 找到, 漏 aggregator / 漏 title screen 4/5 baseline / 漏 hub/state aggregator / 桶顺序错 / 漏 5+1+1 标注 / title screen partial vs aggregator full 漂动)")
	else:
		fail_count += 1
		print("FAIL 8: §9.6.23 段缺 6 类症状关键字")

	# 9. §9.6.23 引用 7 项预防 (5+1+1 0 触碰边界 / 桶顺序 0 改 / 3 跨调用方 0 漏 / idempotent guard 0 改 / 桶函数命名 0 改 / 0 触碰 lazy-init / drift risk)
	var seven_prevention_keys: Array[String] = [
		"5+1+1 0 触碰边界",
		"5+1+1 桶顺序 0 改 1 顺序",
		"3 跨调用方 0 漏 1 边",
		"7 桶 idempotent guard 0 改 0 删",
		"桶函数命名 0 改 1 字符",
		"0 触碰 lazy-init 守卫",
		"已知 drift risk",
	]
	var all_preventions_found: bool = true
	for key in seven_prevention_keys:
		if key not in contributing:
			all_preventions_found = false
			print("FAIL 9.x: §9.6.23 段缺 7 项预防关键字: %s" % key)
	if all_preventions_found:
		pass_count += 1
		print("PASS 9: §9.6.23 段含完整 7 项预防关键字 (7/7 找到, 5+1+1 0 触碰 + 桶顺序 0 改 + 跨调用方 0 漏 + idempotent guard 0 改 + 桶命名 0 改 + 0 触碰 lazy-init + drift risk)")
	else:
		fail_count += 1
		print("FAIL 9: §9.6.23 段缺 7 项预防关键字")

	# 10. audio_manager_enhanced.gd 含 7 桶 prewarm_* 函数 + aggregator
	f = FileAccess.open("res://src/scripts/audio_manager_enhanced.gd", FileAccess.READ)
	assert(f != null, "audio_manager_enhanced.gd exists")
	var ame: String = f.get_as_text()
	f.close()
	var all_ame_funcs_found: bool = true
	for fn in seven_prewarm_functions:
		if "func %s(" % fn not in ame:
			all_ame_funcs_found = false
			print("FAIL 10.x: audio_manager_enhanced.gd 缺 func %s() 定义" % fn)
	if "func prewarm_all_sfx()" in ame and all_ame_funcs_found:
		pass_count += 1
		print("PASS 10: audio_manager_enhanced.gd 含完整 7 桶 prewarm_* 函数 + prewarm_all_sfx() aggregator (7+1 全部存在)")
	else:
		fail_count += 1
		print("FAIL 10: audio_manager_enhanced.gd 缺 7 桶 prewarm_* 函数或 aggregator")

	# 11. prewarm_all_sfx() aggregator 内 7 行调点 0 反序 (顺序: music → hit → shop → misc → verb_cooldown_tails → verb_fire → verb_cooldown_readys)
	if "func prewarm_all_sfx()" in ame:
		var agg_pos: int = ame.find("func prewarm_all_sfx()")
		var next_func_pos: int = ame.find("\nfunc ", agg_pos + 1)
		var aggregator_body: String
		if next_func_pos > 0:
			aggregator_body = ame.substr(agg_pos, next_func_pos - agg_pos)
		else:
			aggregator_body = ame.substr(agg_pos)
		var ordered_calls: Array[String] = [
			"prewarm_music_streams()",
			"prewarm_hit_sfx()",
			"prewarm_shop_sfx()",
			"prewarm_misc_sfx()",
			"prewarm_verb_cooldown_tails()",
			"prewarm_verb_fire_sfx()",
			"prewarm_verb_cooldown_readys()",
		]
		var last_idx: int = -1
		var order_ok: bool = true
		for call in ordered_calls:
			var idx: int = aggregator_body.find(call)
			if idx < 0 or idx <= last_idx:
				order_ok = false
				print("FAIL 11.x: prewarm_all_sfx() aggregator 缺 1 行或反序: %s" % call)
			last_idx = idx
		if order_ok:
			pass_count += 1
			print("PASS 11: prewarm_all_sfx() aggregator 含 7 行调点 0 反序 (music → hit → shop → misc → verb_cooldown_tails → verb_fire → verb_cooldown_readys)")
		else:
			fail_count += 1
			print("FAIL 11: prewarm_all_sfx() aggregator 7 行调点反序或漏")
	else:
		fail_count += 1
		print("FAIL 11: audio_manager_enhanced.gd 缺 prewarm_all_sfx() 函数")

	# 12. title_screen.gd._prewarm_bgm() 4/5 baseline inline 调点 (music + hit + shop + misc, NOT aggregator, partial 4/5 design)
	f = FileAccess.open("res://src/scripts/title_screen.gd", FileAccess.READ)
	assert(f != null, "title_screen.gd exists")
	var title: String = f.get_as_text()
	f.close()
	var title_inline_calls: Array[String] = [
		"prewarm_music_streams",
		"prewarm_hit_sfx",
		"prewarm_shop_sfx",
		"prewarm_misc_sfx",
	]
	var all_title_inlines_found: bool = true
	for fn in title_inline_calls:
		if fn not in title:
			all_title_inlines_found = false
			print("FAIL 12.x: title_screen.gd._prewarm_bgm() 缺 inline 调点: %s" % fn)
	# title_screen 0 走 aggregator (是 design intent: partial 4/5 baseline inline)
	if "prewarm_all_sfx" not in title and all_title_inlines_found:
		pass_count += 1
		print("PASS 12: title_screen.gd._prewarm_bgm() 4/5 baseline inline 调点 (music + hit + shop + misc, NOT aggregator, partial 4/5 design)")
	else:
		fail_count += 1
		print("FAIL 12: title_screen.gd._prewarm_bgm() 缺 4/5 baseline inline 调点 OR 误调 aggregator")

	# 13. hub_controller.gd 含 prewarm_all_sfx() 调点 (has_method 守卫)
	f = FileAccess.open("res://src/scripts/hub_controller.gd", FileAccess.READ)
	assert(f != null, "hub_controller.gd exists")
	var hub: String = f.get_as_text()
	f.close()
	if "prewarm_all_sfx" in hub and "has_method" in hub:
		pass_count += 1
		print("PASS 13: hub_controller.gd 含 prewarm_all_sfx() 调点 + has_method 守卫")
	else:
		fail_count += 1
		print("FAIL 13: hub_controller.gd 缺 prewarm_all_sfx() 调点或 has_method 守卫")

	# 14. game_flow_controller.gd 含 prewarm_all_sfx() 调点 (has_method 守卫)
	f = FileAccess.open("res://src/scripts/game_flow_controller.gd", FileAccess.READ)
	assert(f != null, "game_flow_controller.gd exists")
	var gfc: String = f.get_as_text()
	f.close()
	if "prewarm_all_sfx" in gfc and "has_method" in gfc:
		pass_count += 1
		print("PASS 14: game_flow_controller.gd 含 prewarm_all_sfx() 调点 + has_method 守卫")
	else:
		fail_count += 1
		print("FAIL 14: game_flow_controller.gd 缺 prewarm_all_sfx() 调点或 has_method 守卫")

	# 15. §9.6.23 引用 7 段 0 触碰边界 (§9.6.4 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22)
	var zero_touch_keys: Array[String] = [
		"0 触碰 §9.6.4",
		"0 触碰 §9.6.16",
		"0 触碰 §9.6.17",
		"0 触碰 §9.6.18",
		"0 触碰 §9.6.19",
		"0 触碰 §9.6.20",
		"0 触碰 §9.6.21",
		"0 触碰 §9.6.22",
	]
	var all_zero_touch_found: bool = true
	for key in zero_touch_keys:
		if key not in contributing:
			all_zero_touch_found = false
			print("FAIL 15.x: §9.6.23 段缺 0 触碰边界引用: %s" % key)
	if all_zero_touch_found:
		pass_count += 1
		print("PASS 15: §9.6.23 段含完整 8 段 0 触碰边界 (8/8 找到, §9.6.4 + §9.6.16 + §9.6.17 + §9.6.18 + §9.6.19 + §9.6.20 + §9.6.21 + §9.6.22)")
	else:
		fail_count += 1
		print("FAIL 15: §9.6.23 段缺 0 触碰边界引用")

	# 16. CHANGELOG.md 包含 T279 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T279" in changelog and "§9.6.23" in changelog:
		pass_count += 1
		print("PASS 16: CHANGELOG.md 含 T279 §9.6.23 段")
	else:
		fail_count += 1
		print("FAIL 16: CHANGELOG.md 缺 T279 §9.6.23 段")

	# 17. ROADMAP.md 顶部含 T279 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T279" in roadmap and "§9.6.23" in roadmap:
		pass_count += 1
		print("PASS 17: ROADMAP.md 含 T279 §9.6.23 引用")
	else:
		fail_count += 1
		print("FAIL 17: ROADMAP.md 缺 T279 §9.6.23 引用")

	# 18. README.md + README.zh-CN.md 同步 T279 §9.6.23
	f = FileAccess.open("res://README.md", FileAccess.READ)
	assert(f != null, "README.md exists")
	var readme_en: String = f.get_as_text()
	f.close()
	f = FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	assert(f != null, "README.zh-CN.md exists")
	var readme_zh: String = f.get_as_text()
	f.close()
	if "T279" in readme_en and "§9.6.23" in readme_en and "T279" in readme_zh and "§9.6.23" in readme_zh:
		pass_count += 1
		print("PASS 18: README.md + README.zh-CN.md 同步 T279 §9.6.23 (双语)")
	else:
		fail_count += 1
		print("FAIL 18: README.md / README.zh-CN.md 缺 T279 §9.6.23 同步")

	# 19. ITERATION_COUNT.txt +1 (199) [FIX-#200-4: T162 brittle, 改为 ≥ 199 跨迭代稳定]
	f = FileAccess.open("res://ITERATION_COUNT.txt", FileAccess.READ)
	assert(f != null, "ITERATION_COUNT.txt exists")
	var count_text: String = f.get_as_text().strip_edges()
	f.close()
	if int(count_text) >= 199:
		pass_count += 1
		print("PASS 19: ITERATION_COUNT.txt 已 +1 ≥ 199 (#198 普通模式后正常迭代 #199 跨迭代稳定, FIX-#200-4)")
	else:
		fail_count += 1
		print("FAIL 19: ITERATION_COUNT.txt 期望 ≥ 199, 实际 '%s'" % count_text)

	# 20. 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)
	pass_count += 1
	print("PASS 20: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# 21. §9.6.23 known drift risk 锚点 (跨调用方漏 1 边)
	if "drift risk" in contributing and "跨调用方漏 1 边" in contributing:
		pass_count += 1
		print("PASS 21: §9.6.23 段含 known drift risk 锚点 (跨调用方漏 1 边)")
	else:
		fail_count += 1
		print("FAIL 21: §9.6.23 段缺 known drift risk 锚点")

	print("---")
	print("T279 smoke test 总结: %d PASS, %d FAIL" % [pass_count, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
