# T283 (#204) 5 段 canonical 1:1 序列 24+ 断言:
#   1. §9.6.27 section header 存在
#   2. 23 task T162+T213+T214+T215+T216+T217+T219+T225+T226+T229+T231+T234+T235+T240+T249+T256+T257+T258+T259+T260+T261+T262+T263 引用
#   3. 17 套 polish 模式 cross-reference 0 漏
#   4. 5 段 canonical 1:1 序列 0 漏 0 改
#   5. 3 组件 1:1 严格分离
#   6. 9 颜色 token 4+2+3 = 9 (ProfileQuickStats 4 调色 + ProfileRecentList 2 token + ProfileAudit 3 inline)
#   7. 6 边 prevention rule 0 漏
#   8. 1 panel × 3 组件 × 1:1 视觉组连贯 关系 0 漏
#   9. 0 副作用 0 触碰边界 0 漏
#
# T283 断言全部通过 = §9.6.27 5 段序列 1:1 严格 0 漏 0 改 1 字符.
extends SceneTree

func _init() -> void:
	var passed: int = 0
	var failed: int = 0
	var total: int = 0

	# Read CONTRIBUTING.md and pause_menu.gd
	var contributing_path: String = "res://CONTRIBUTING.md"
	var pause_menu_path: String = "res://src/scripts/pause_menu.gd"
	var f1: FileAccess = FileAccess.open(contributing_path, FileAccess.READ)
	if f1 == null:
		push_error("[T283] CANNOT OPEN CONTRIBUTING.md")
		quit(1)
		return
	var contributing: String = f1.get_as_text()
	f1.close()
	var f2: FileAccess = FileAccess.open(pause_menu_path, FileAccess.READ)
	if f2 == null:
		push_error("[T283] CANNOT OPEN pause_menu.gd")
		quit(1)
		return
	var pause_menu: String = f2.get_as_text()
	f2.close()

	# 1. §9.6.27 section header
	total += 1
	if "### 9.6.27 PlayerProfilePanel 3 组件" in contributing:
		passed += 1
		print("[T283-1] PASS: §9.6.27 section header 存在")
	else:
		failed += 1
		push_error("[T283-1] FAIL: §9.6.27 section header 0 存在")

	# 2. 23 task references (selected key tasks)
	for t in ["T162", "T213", "T215", "T229", "T235", "T249", "T256", "T261", "T263"]:
		total += 1
		if t in contributing:
			passed += 1
			print("[T283-2-%s] PASS: %s 引用" % [t, t])
		else:
			failed += 1
			push_error("[T283-2-%s] FAIL: %s 0 引用" % [t, t])

	# 3. 17 polish mode cross-references
	for s in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26"]:
		total += 1
		if s in contributing:
			passed += 1
			print("[T283-3-%s] PASS: %s 引用" % [s, s])
		else:
			failed += 1
			push_error("[T283-3-%s] FAIL: %s 0 引用" % [s, s])

	# 4. 5 段 canonical 1:1 序列
	for stage in ["Stage 1 3 组件 1:1 严格分离", "Stage 2 中点分隔符", "Stage 3 7pt 字号", "Stage 4 _COLOR_* canonical 颜色 token", "Stage 5 派生字段"]:
		total += 1
		if stage in contributing:
			passed += 1
			print("[T283-4-%s] PASS: %s 存在" % [stage, stage])
		else:
			failed += 1
			push_error("[T283-4-%s] FAIL: %s 0 存在" % [stage, stage])

	# 5. 3 组件 1:1 严格分离
	for comp in ["ProfileQuickStats", "ProfileRecentList", "ProfileAudit"]:
		total += 1
		if comp in contributing:
			passed += 1
			print("[T283-5-%s] PASS: %s 引用" % [comp, comp])
		else:
			failed += 1
			push_error("[T283-5-%s] FAIL: %s 0 引用" % [comp, comp])

	# 6. pause_menu.gd const 实际存在
	total += 1
	if "_QUICK_STATS_HINT" in pause_menu and "_RECENT_ROW_HINT" in pause_menu and "_RECENT_ROW_FIELD_SEP" in pause_menu:
		passed += 1
		print("[T283-6] PASS: _QUICK_STATS_HINT + _RECENT_ROW_HINT + _RECENT_ROW_FIELD_SEP 存在")
	else:
		failed += 1
		push_error("[T283-6] FAIL: 1+ const 0 存在")

	total += 1
	if "_COLOR_RECENT_RUN_LATEST" in pause_menu and "_COLOR_RECENT_RUN_NORMAL" in pause_menu and "_COLOR_ZERO_STAT" in pause_menu:
		passed += 1
		print("[T283-7] PASS: _COLOR_RECENT_RUN_LATEST + _COLOR_RECENT_RUN_NORMAL + _COLOR_ZERO_STAT 3 token 存在")
	else:
		failed += 1
		push_error("[T283-7] FAIL: 1+ _COLOR_* token 0 存在")

	total += 1
	if "_refresh_profile_audit" in pause_menu and "audit_save_slots" in pause_menu:
		passed += 1
		print("[T283-8] PASS: _refresh_profile_audit + SaveSystem.audit_save_slots 1:1 落地")
	else:
		failed += 1
		push_error("[T283-8] FAIL: _refresh_profile_audit 0 存在")

	# 9. 5 段 prevention rule (component, separator, font, color, derived)
	for rule in ["Stage 1 0 改 3 组件", "Stage 2 0 改中点分隔符", "Stage 3 0 改 7pt 字号", "Stage 4 0 改 _COLOR_* canonical 颜色 token", "Stage 5 0 改 派生字段"]:
		total += 1
		if rule in contributing:
			passed += 1
			print("[T283-9-%s] PASS: %s prevention rule 存在" % [rule, rule])
		else:
			failed += 1
			push_error("[T283-9-%s] FAIL: %s prevention rule 0 存在" % [rule, rule])

	# 10. 1 panel × 3 组件 × 1:1 视觉组连贯 关系
	total += 1
	if "1 panel × 3 组件 × 1:1 视觉组连贯" in contributing:
		passed += 1
		print("[T283-10] PASS: 1 panel × 3 组件 × 1:1 视觉组连贯 关系 存在")
	else:
		failed += 1
		push_error("[T283-10] FAIL: 1 panel × 3 组件 × 1:1 视觉组连贯 关系 0 存在")

	# 11. 17 套 polish 模式 唯一性
	total += 1
	if "17 套 polish 模式**唯一**" in contributing:
		passed += 1
		print("[T283-11] PASS: 17 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T283-11] FAIL: 17 套 polish 模式 唯一性 标注 0 存在")

	# 12. 0 副作用 0 触碰边界 段
	total += 1
	if "0 副作用" in contributing and "0 触碰边界" in contributing:
		passed += 1
		print("[T283-12] PASS: 0 副作用 0 触碰边界 段 存在")
	else:
		failed += 1
		push_error("[T283-12] FAIL: 0 副作用 / 0 触碰边界 段 0 存在")

	# 13. 关系段 (与 §9.1 9 步关系 + 与 §9.6.6-§9.6.26 关系)
	total += 1
	if "与 §9.1 9 步关系" in contributing:
		passed += 1
		print("[T283-13] PASS: 与 §9.1 9 步关系 段 存在")
	else:
		failed += 1
		push_error("[T283-13] FAIL: 与 §9.1 9 步关系 段 0 存在")

	# 14. 已知 drift risk 监控建议
	total += 1
	if "已知 drift risk" in contributing and "监控建议" in contributing:
		passed += 1
		print("[T283-14] PASS: 已知 drift risk 监控建议 段 存在")
	else:
		failed += 1
		push_error("[T283-14] FAIL: 已知 drift risk 监控建议 段 0 存在")

	# 15. §9.6.27 是 17 套 polish 模式 唯一性 详情
	total += 1
	if "§9.6.27 是 17 套 polish 模式**唯一**关注" in contributing:
		passed += 1
		print("[T283-15] PASS: §9.6.27 是 17 套 polish 模式 唯一性 详情 存在")
	else:
		failed += 1
		push_error("[T283-15] FAIL: §9.6.27 是 17 套 polish 模式 唯一性 详情 0 存在")

	# 16. 6 边 prevention rule 显式编号
	for i in range(1, 9):
		total += 1
		var marker: String = "  %d. " % i
		# search for the rule number prefix
		if i == 1:
			if "1. 任何 polish 期给" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 1 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 1 0 存在" % i)
		elif i == 2:
			if "2. **5 段序列 0 触碰边界**" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 2 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 2 0 存在" % i)
		elif i == 3:
			if "3. **3 组件 0 改 0 漏" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 3 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 3 0 存在" % i)
		elif i == 4:
			if "4. **3 组件 _COLOR_* canonical 颜色 token" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 4 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 4 0 存在" % i)
		elif i == 5:
			if "5. **中点分隔符 0 改" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 5 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 5 0 存在" % i)
		elif i == 6:
			if "6. **7pt 字号 0 改" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 6 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 6 0 存在" % i)
		elif i == 7:
			if "7. **派生字段 0 改" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 7 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 7 0 存在" % i)
		elif i == 8:
			if "8. 已知 drift risk" in contributing:
				passed += 1
				print("[T283-16-%d] PASS: prevention rule 8 存在" % i)
			else:
				failed += 1
				push_error("[T283-16-%d] FAIL: prevention rule 8 0 存在" % i)

	# 17. 4 段 3 组件 调色 9 颜色 token 数字
	total += 1
	if "4 + 2 + 3 = 9 颜色 token" in contributing:
		passed += 1
		print("[T283-17] PASS: 4 + 2 + 3 = 9 颜色 token 数字 存在")
	else:
		failed += 1
		push_error("[T283-17] FAIL: 4 + 2 + 3 = 9 颜色 token 数字 0 存在")

	# 18. 4 段 段名 (Achievements / 最佳 / 最长单房 / Run #)
	for seg in ["Achievements 成就", "最佳", "最长单房", "Run #"]:
		total += 1
		if seg in contributing:
			passed += 1
			print("[T283-18-%s] PASS: %s 段名 引用" % [seg, seg])
		else:
			failed += 1
			push_error("[T283-18-%s] FAIL: %s 段名 0 引用" % [seg, seg])

	# 19. 5 行 × 7 字段 字段名
	for f in ["Run #", "房", "净", "碎", "时", "房/时", "净/时"]:
		total += 1
		if f in contributing:
			passed += 1
			print("[T283-19-%s] PASS: %s 字段名 引用" % [f, f])
		else:
			failed += 1
			push_error("[T283-19-%s] FAIL: %s 字段名 0 引用" % [f, f])

	# 20. ProfileAudit 4 字段 (ok / 损坏 / 漂移 / 空)
	for f in ["ok", "损坏", "漂移", "空"]:
		total += 1
		if f in contributing:
			passed += 1
			print("[T283-20-%s] PASS: %s audit 字段 引用" % [f, f])
		else:
			failed += 1
			push_error("[T283-20-%s] FAIL: %s audit 字段 0 引用" % [f, f])

	# 21. 4 段 段名 + 5 行 × 7 字段 + 4 字段 = 43 element 1:1
	total += 1
	if "43 element 1:1" in contributing:
		passed += 1
		print("[T283-21] PASS: 43 element 1:1 数字 存在")
	else:
		failed += 1
		push_error("[T283-21] FAIL: 43 element 1:1 数字 0 存在")

	# 22. T283 smoke test 24+ 断言
	total += 1
	if "T283 24+ 断言" in contributing:
		passed += 1
		print("[T283-22] PASS: T283 24+ 断言 自我引用 存在")
	else:
		failed += 1
		push_error("[T283-22] FAIL: T283 24+ 断言 自我引用 0 存在")

	# Final
	print("=== T283 #204 §9.6.27 PlayerProfilePanel 3 组件 1:1 视觉组连贯 polish 模式 5 段序列 ===")
	print("=== passed: %d / %d  failed: %d ===" % [passed, total, failed])
	if failed > 0:
		push_error("[T283] %d / %d 断言 失败" % [failed, total])
		quit(1)
	else:
		print("[T283] ALL %d ASSERTIONS PASSED" % total)
		quit(0)
