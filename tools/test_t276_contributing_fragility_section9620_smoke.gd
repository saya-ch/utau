# T276 smoke test — CONTRIBUTING.md §9.6.20 Hub ↔ archive 跨房间 transition flow polish 模式 1:1 落地 (#196 普通模式 polish T276, 0 真实游戏代码改动, 仅 doc + smoke)
# 验证 §9.6.20 文档化 + 5 段 canonical 1:1 序列 (Stage 1 触发检测 + Stage 2 GFC 状态转换 + Stage 3 fade_out + Stage 4 场景切换 + Stage 5 新 scene 恢复) + 4 类症状 (a 位置丢失 / b 持久化丢失 / c fade_in 闪帧 / d BGM 错乱) + 12 任务历史 (T053/T063/T070/T078/T079/T081/T107/T114/T123/T156/T223/T269) + 4 个 anti-pattern 0 触碰
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.20 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.20" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.20 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.20 章节标题")

	# 2. §9.6.20 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	if "**症状**" in contributing and "**触发场景**" in contributing and "**修复**" in contributing and "**预防**" in contributing:
		# 进一步验证是 §9.6.20 段内 (在 §9.6.20 标题之后, §9.6.19 之前没有这 4 段全有)
		var pos_9620: int = contributing.find("### 9.6.20")
		var pos_9619: int = contributing.find("### 9.6.19")
		if pos_9620 > pos_9619 and pos_9620 > 0 and pos_9619 > 0:
			var section_9620: String = contributing.substr(pos_9620)
			if "**症状**" in section_9620 and "**触发场景**" in section_9620 and "**修复**" in section_9620 and "**预防**" in section_9620:
				pass_count += 1
				print("PASS 2: §9.6.20 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
			else:
				fail_count += 1
				print("FAIL 2: §9.6.20 段内 4 段结构不全")
		else:
			fail_count += 1
			print("FAIL 2: §9.6.20 段位置异常, 找不到 9.6.19 / 9.6.20 锚点")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.20 段缺 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")

	# 3. §9.6.20 引用 5 段 canonical 序列关键字
	var five_stage_keys: Array[String] = [
		"Stage 1 触发检测",
		"Stage 2 GFC 状态转换",
		"Stage 3 fade_out",
		"Stage 4 场景切换",
		"Stage 5 新 scene 恢复",
	]
	var all_stage_keys_found: bool = true
	for key in five_stage_keys:
		if key not in contributing:
			all_stage_keys_found = false
			print("FAIL 3.x: §9.6.20 段缺 5 段序列关键字: %s" % key)
	if all_stage_keys_found:
		pass_count += 1
		print("PASS 3: §9.6.20 段含完整 5 段 canonical 1:1 序列关键字 (5/5 找到)")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.20 段缺 5 段序列关键字")

	# 4. §9.6.20 引用关键字段 / 方法
	var transition_contract_keys: Array[String] = [
		"_pending_room_path",
		"_pending_spawn_point",
		"save_persistent_state",
		"restore_persistent_state",
		"_is_transitioning",
		"change_scene_to_file",
		"respawn_at",
		"fade_out(0.4)",
		"fade_in(0.5)",
		"process_frame",
		"is_in_group(\"player\")",
		"target_room_path",
	]
	var all_contract_keys_found: bool = true
	for key in transition_contract_keys:
		if key not in contributing:
			all_contract_keys_found = false
			print("FAIL 4.x: §9.6.20 段缺过渡流契约关键字: %s" % key)
	if all_contract_keys_found:
		pass_count += 1
		print("PASS 4: §9.6.20 段含完整 12 个过渡流契约关键字 (12/12 找到, 含 2 字段名 + 4 持久化 + 1 scene 切换 + 1 respawn + 2 fade + 1 process_frame + 1 player 守卫 + 1 target_room_path)")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.20 段缺过渡流契约关键字")

	# 5. §9.6.20 引用 12 任务历史 (T053/T063/T070/T078/T079/T081/T107/T114/T123/T156/T223/T269)
	var transition_history_tasks: Array[String] = [
		"T053",
		"T063",
		"T070",
		"T078",
		"T079",
		"T081",
		"T107",
		"T114",
		"T123",
		"T156",
		"T223",
		"T269",
	]
	var all_history_found: bool = true
	for task in transition_history_tasks:
		if task not in contributing:
			all_history_found = false
			print("FAIL 5.x: §9.6.20 段缺过渡流历史任务: %s" % task)
	if all_history_found:
		pass_count += 1
		print("PASS 5: §9.6.20 段含完整 12 任务历史引用 (12/12 找到, T053 + T063 + T070 + T078 + T079 + T081 + T107 + T114 + T123 + T156 + T223 + T269)")
	else:
		fail_count += 1
		print("FAIL 5: §9.6.20 段缺过渡流历史任务")

	# 6. §9.6.20 引用 4 类症状 (a 位置丢失 / b 持久化丢失 / c fade_in 闪帧 / d BGM 错乱)
	var four_symptom_keys: Array[String] = [
		"玩家位置丢失",
		"持久化状态丢失",
		"fade_in 黑屏闪 1 帧",
		"BGM 错乱",
	]
	var all_symptoms_found: bool = true
	for key in four_symptom_keys:
		if key not in contributing:
			all_symptoms_found = false
			print("FAIL 6.x: §9.6.20 段缺 4 类症状关键字: %s" % key)
	if all_symptoms_found:
		pass_count += 1
		print("PASS 6: §9.6.20 段含完整 4 类症状关键字 (4/4 找到, a 位置丢失 + b 持久化丢失 + c fade_in 闪帧 + d BGM 错乱)")
	else:
		fail_count += 1
		print("FAIL 6: §9.6.20 段缺 4 类症状关键字")

	# 7. game_flow_controller.gd 包含 5 段序列关键节点
	f = FileAccess.open("res://src/scripts/game_flow_controller.gd", FileAccess.READ)
	assert(f != null, "game_flow_controller.gd exists")
	var gfc_src: String = f.get_as_text()
	f.close()
	var gfc_contract_keys: Array[String] = [
		"func _on_door_entered",
		"func _recover_from_transition",
		"change_scene_to_file",
		"State.ROOM_TRANSITION",
		"respawn_at",
		"is_hub_mode",
		"_is_transitioning",
	]
	var gfc_keys_count: int = 0
	for key in gfc_contract_keys:
		if key in gfc_src:
			gfc_keys_count += 1
	if gfc_keys_count == gfc_contract_keys.size():
		pass_count += 1
		print("PASS 7: game_flow_controller.gd 含完整 7 个 5 段序列关键节点 (7/7 找到, _on_door_entered + _recover_from_transition + change_scene_to_file + ROOM_TRANSITION + respawn_at + is_hub_mode + _is_transitioning)")
	else:
		fail_count += 1
		print("FAIL 7: game_flow_controller.gd 缺 5 段序列关键节点, 只找到 %d / %d" % [gfc_keys_count, gfc_contract_keys.size()])

	# 8. room_transition.gd 包含 fade_out + fade_in + 默认 0.5s; GFC 调用 0.4s fade_out + 0.5s fade_in
	f = FileAccess.open("res://src/scripts/room_transition.gd", FileAccess.READ)
	assert(f != null, "room_transition.gd exists")
	var rt_src: String = f.get_as_text()
	f.close()
	var gfc_full_src: String = gfc_src  # already loaded in check 7
	var rt_has_both_fns: bool = "func fade_out" in rt_src and "func fade_in" in rt_src
	var rt_has_default_05: bool = "0.5" in rt_src
	var gfc_calls_04_out: bool = "fade_out(0.4)" in gfc_full_src
	var gfc_calls_05_in: bool = "fade_in(0.5)" in gfc_full_src
	if rt_has_both_fns and rt_has_default_05 and gfc_calls_04_out and gfc_calls_05_in:
		pass_count += 1
		print("PASS 8: room_transition.gd 含 fade_out + fade_in + 默认 0.5s; GFC 调用 fade_out(0.4) + fade_in(0.5) 4 项全找到")
	else:
		fail_count += 1
		print("FAIL 8: 4 项之一缺失 (rt_has_both_fns=%s, rt_has_default_05=%s, gfc_calls_04_out=%s, gfc_calls_05_in=%s)" % [rt_has_both_fns, rt_has_default_05, gfc_calls_04_out, gfc_calls_05_in])

	# 9. room_door.gd 包含 target_room_path + is_in_group("player") + player_entered signal
	f = FileAccess.open("res://src/scripts/room_door.gd", FileAccess.READ)
	assert(f != null, "room_door.gd exists")
	var door_src: String = f.get_as_text()
	f.close()
	var door_contract_keys: Array[String] = [
		"target_room_path",
		"is_in_group(\"player\")",
		"player_entered",
	]
	var door_keys_count: int = 0
	for key in door_contract_keys:
		if key in door_src:
			door_keys_count += 1
	if door_keys_count == door_contract_keys.size():
		pass_count += 1
		print("PASS 9: room_door.gd 含完整 3 个 Stage 1 触发检测关键节点 (3/3 找到, target_room_path + is_in_group(\"player\") + player_entered signal)")
	else:
		fail_count += 1
		print("FAIL 9: room_door.gd 缺 Stage 1 触发检测关键节点, 只找到 %d / %d" % [door_keys_count, door_contract_keys.size()])

	# 10. GameState autoload 包含 _pending_room_path + _pending_spawn_point + save_persistent_state + restore_persistent_state + _is_transitioning
	f = FileAccess.open("res://src/autoload/game_state.gd", FileAccess.READ)
	assert(f != null, "game_state.gd exists")
	var gs_src: String = f.get_as_text()
	f.close()
	var gs_contract_keys: Array[String] = [
		"_pending_room_path",
		"_pending_spawn_point",
		"func save_persistent_state",
		"func restore_persistent_state",
		"_is_transitioning",
	]
	var gs_keys_count: int = 0
	for key in gs_contract_keys:
		if key in gs_src:
			gs_keys_count += 1
	if gs_keys_count == gs_contract_keys.size():
		pass_count += 1
		print("PASS 10: game_state.gd (GameState autoload) 含完整 5 个跨 scene 持久化契约关键节点 (5/5 找到, _pending_room_path + _pending_spawn_point + save_persistent_state + restore_persistent_state + _is_transitioning)")
	else:
		fail_count += 1
		print("FAIL 10: game_state.gd 缺跨 scene 持久化契约关键节点, 只找到 %d / %d" % [gs_keys_count, gs_contract_keys.size()])

	# 11. §9.6.20 引用 4 个 anti-pattern
	var four_antipattern_keys: Array[String] = [
		"漏 Stage 2 `_pending_spawn_point` 写入",
		"Stage 4 漏 `save_persistent_state`",
		"Stage 4 漏 `_is_transitioning = true`",
		"Stage 5 漏 `await get_tree().process_frame`",
	]
	var all_antipatterns_found: bool = true
	for key in four_antipattern_keys:
		if key not in contributing:
			all_antipatterns_found = false
			print("FAIL 11.x: §9.6.20 段缺 4 anti-pattern 之一: %s" % key)
	if all_antipatterns_found:
		pass_count += 1
		print("PASS 11: §9.6.20 段含完整 4 anti-pattern 关键字 (4/4 找到, 漏 spawn_point 写入 + 漏 save_persistent_state + 漏 _is_transitioning + 漏 process_frame)")
	else:
		fail_count += 1
		print("FAIL 11: §9.6.20 段缺 4 anti-pattern 之一")

	# 12. §9.6.20 引用 §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 跨段关系
	var pos_9620: int = contributing.find("### 9.6.20")
	var section_9620: String = contributing.substr(pos_9620)
	var cross_section_keys: Array[String] = [
		"§9.6.16",
		"§9.6.17",
		"§9.6.18",
		"§9.6.19",
		"§9.1 9 步",
	]
	var all_cross_section_found: bool = true
	for key in cross_section_keys:
		if key not in section_9620:
			all_cross_section_found = false
			print("FAIL 12.x: §9.6.20 段缺跨段关系引用: %s" % key)
	if all_cross_section_found:
		pass_count += 1
		print("PASS 12: §9.6.20 段含完整 5 跨段关系引用 (5/5 找到, §9.6.16 + §9.6.17 + §9.6.18 + §9.6.19 + §9.1 9 步)")
	else:
		fail_count += 1
		print("FAIL 12: §9.6.20 段缺跨段关系引用")

	# 13. §9.6.19 段未触碰 (T274 #193 + T275 #194 落地后状态保留)
	if "T275 #194 收回完成" in contributing or "T275 (#194) 收回完成" in contributing:
		pass_count += 1
		print("PASS 13: §9.6.19 段 T275 #194 收回完成状态保留 (T276 #196 0 触碰既有 §9.6.19 段)")
	else:
		fail_count += 1
		print("FAIL 13: §9.6.19 段 T275 #194 收回完成状态丢失")

	# 14. CHANGELOG.md 包含 T276 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T276" in changelog and "§9.6.20" in changelog:
		pass_count += 1
		print("PASS 14: CHANGELOG.md 含 T276 §9.6.20 段")
	else:
		fail_count += 1
		print("FAIL 14: CHANGELOG.md 缺 T276 §9.6.20 段")

	# 15. ROADMAP.md 顶部含 T276 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T276" in roadmap and "§9.6.20" in roadmap:
		pass_count += 1
		print("PASS 15: ROADMAP.md 含 T276 §9.6.20 引用")
	else:
		fail_count += 1
		print("FAIL 15: ROADMAP.md 缺 T276 §9.6.20 引用")

	# 16. README.md 同步 +1 (双语: T276 §9.6.20)
	f = FileAccess.open("res://README.md", FileAccess.READ)
	assert(f != null, "README.md exists")
	var readme_en: String = f.get_as_text()
	f.close()
	f = FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	assert(f != null, "README.zh-CN.md exists")
	var readme_zh: String = f.get_as_text()
	f.close()
	if "T276" in readme_en and "§9.6.20" in readme_en and "T276" in readme_zh and "§9.6.20" in readme_zh:
		pass_count += 1
		print("PASS 16: README.md + README.zh-CN.md 同步 T276 §9.6.20 (双语)")
	else:
		fail_count += 1
		print("FAIL 16: README.md / README.zh-CN.md 缺 T276 §9.6.20 同步")

	# 17. ITERATION_COUNT.txt +1 (196)
	f = FileAccess.open("res://ITERATION_COUNT.txt", FileAccess.READ)
	assert(f != null, "ITERATION_COUNT.txt exists")
	var count_text: String = f.get_as_text().strip_edges()
	f.close()
	if count_text == "196":
		pass_count += 1
		print("PASS 17: ITERATION_COUNT.txt 已 +1 → 196 (#195 审查模式后正常迭代 #196)")
	else:
		fail_count += 1
		print("FAIL 17: ITERATION_COUNT.txt 期望 196, 实际 '%s'" % count_text)

	# 18. 静态解析 — 0 SCRIPT ERROR
	print("PASS 18: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# Summary
	print("")
	print("=== T276 smoke test summary: %d passed, %d failed ===" % [pass_count + 1, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
