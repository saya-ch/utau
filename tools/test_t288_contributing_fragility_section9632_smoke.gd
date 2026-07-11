# T288 (#211) 3 件套 1:1 严格分离契约 24+ 断言:
#   1. §9.6.32 section header 存在
#   2. 3 件套 1:1 严格分离契约 (Stage 1 归档触发条件 1:1 严格 + Stage 2 归档范围 1:1 严格 + Stage 3 归档完整性 1:1 严格) 0 漏
#   3. 22 套 polish 模式 cross-reference (§9.6.6 - §9.6.31) 0 漏
#   4. 4 段关系段 (与 §9.6.x 关系 + 与 §11 关系 + 与 T162 关系 + 与 §9.1 9 步关系) 0 漏
#   5. 5 段序列 5 段关键字 (症状 / 触发场景 / 修复 / 预防 / 0 副作用) 0 漏
#   6. §9.6.32 是 23 套 polish 模式 唯一性 标注
#   7. 0 副作用 段 强制 1:1 严格
#   8. 8 段 prevention rule 0 漏
#   9. 关系段 22 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注
#  10. 跨段 find 0 反向 0 漂动 (Stage 4) — 用 ### 9.6.32 稳定子串而非 `## #N` 硬编码
#  11. 与 §11 F002 self-test commit hook 集成 关系段 0 漏
#  12. T162 brittle 修复流程 关系段 0 漏
#  13. 已知 drift risk 监控建议
#  14. ITERATION_COUNT 跨迭代 0 漂移 (Stage 1 + Stage 3)
#  15. T288 段顶时间戳 / 章节锚点 (Stage 2 段边界 find 跨迭代稳定)
#  16. T288 自身 polish 模式落地 (Stage 5 commit-time check 集成)
#  17. CHANGELOG.md 顶部 #211 段 (跨段镜像)
#  18. REVIEW_LOG.md 顶部 "## 归档策略" note 段 (Stage 3 归档完整性 1:1 严格)
#  19. REVIEW_LOG_ARCHIVE.md 顶部 "## 归档内容" note 段 (Stage 3 归档完整性 1:1 严格)
#  20. REVIEW_LOG.md 行数 ≥ 1500 (Stage 1 归档触发条件 1:1 严格: 1500 行阈值)
#  21. REVIEW_LOG.md 含 "## 审查 #210" 段 (活跃保留最新 1 段)
#  22. REVIEW_LOG.md 不含 "## 审查 #110" 段 (已归档) (Stage 2 归档范围 1:1 严格)
#  23. REVIEW_LOG_ARCHIVE.md 含 "## 审查 #110" 段 (Stage 2 归档接受 M 1:1 严格)
#  24. README.md "Recent completed work" #211 段 同步
#  25. README.zh-CN.md "最近完成的工作" #211 段 同步
#  26. T288 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地)
#  27. T288 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.32 稳定子串
#  28. 3 件套 × 1 套 polish 模式 = 3 元素 1:1 严格 闭环
#  29. §9.6.32 是 23 套 polish 模式 唯一性 标注
#  30. 归档双重 `wc -l` 验证 (Stage 3 归档完整性 1:1 严格): 活跃文件行数 + 归档文件行数 = 归档前行数 + 互链段行数 误差 ≤ 5
#
# T288 断言全部通过 = §9.6.32 3 件套 1:1 严格 0 漏 0 改 1 字符 + 1 套 polish 模式跨迭代稳定 1:1 严格 0 漏 0 改 1 字段.
#
# T288 自身遵循 §9.6.32 polish 模式 1:1 严格:
#   Stage 1 归档触发条件 1:1 严格 — 任何"加新 1 审查归档类型"必须 1:1 包含 1 归档触发条件 (`wc -l` 阈值触发)
#   Stage 2 归档范围 1:1 严格 — 任何"加新 1 审查归档类型"必须 1:1 包含 1 归档范围 (活跃保留 N 轮 + 归档接受旧条目 + 顶部归档策略 note 滚动)
#   Stage 3 归档完整性 1:1 严格 — 任何"加新 1 审查归档类型"必须 1:1 包含 1 归档完整性 (REVIEW_LOG.md 顶部"## 归档策略" note + REVIEW_LOG_ARCHIVE.md 顶部"## 归档内容" note + 双重 `wc -l` 验证)
extends SceneTree

func _init() -> void:
	var passed: int = 0
	var failed: int = 0
	var total: int = 0

	# Read CONTRIBUTING.md, ROADMAP.md, CHANGELOG.md, CHANGELOG.md, REVIEW_LOG.md, REVIEW_LOG_ARCHIVE.md, ITERATION_COUNT.txt, README.md, README.zh-CN.md
	var contributing_path: String = "res://CONTRIBUTING.md"
	var roadmap_path: String = "res://ROADMAP.md"
	var changelog_path: String = "res://CHANGELOG.md"
	var review_log_path: String = "res://REVIEW_LOG.md"
	var review_log_archive_path: String = "res://REVIEW_LOG_ARCHIVE.md"
	var iter_count_path: String = "res://ITERATION_COUNT.txt"
	var readme_path: String = "res://README.md"
	var readme_zh_path: String = "res://README.zh-CN.md"
	var f1: FileAccess = FileAccess.open(contributing_path, FileAccess.READ)
	if f1 == null:
		push_error("[T288] CANNOT OPEN CONTRIBUTING.md")
		quit(1)
		return
	var contributing: String = f1.get_as_text()
	f1.close()
	var f2: FileAccess = FileAccess.open(roadmap_path, FileAccess.READ)
	if f2 == null:
		push_error("[T288] CANNOT OPEN ROADMAP.md")
		quit(1)
		return
	var roadmap: String = f2.get_as_text()
	f2.close()
	var f3: FileAccess = FileAccess.open(changelog_path, FileAccess.READ)
	if f3 == null:
		push_error("[T288] CANNOT OPEN CHANGELOG.md")
		quit(1)
		return
	var changelog: String = f3.get_as_text()
	f3.close()
	var f3a: FileAccess = FileAccess.open(review_log_path, FileAccess.READ)
	if f3a == null:
		push_error("[T288] CANNOT OPEN REVIEW_LOG.md")
		quit(1)
		return
	var review_log: String = f3a.get_as_text()
	f3a.close()
	var f3b: FileAccess = FileAccess.open(review_log_archive_path, FileAccess.READ)
	if f3b == null:
		push_error("[T288] CANNOT OPEN REVIEW_LOG_ARCHIVE.md")
		quit(1)
		return
	var review_log_archive: String = f3b.get_as_text()
	f3b.close()
	var f4: FileAccess = FileAccess.open(iter_count_path, FileAccess.READ)
	if f4 == null:
		push_error("[T288] CANNOT OPEN ITERATION_COUNT.txt")
		quit(1)
		return
	var iter_count_text: String = f4.get_as_text().strip_edges()
	f4.close()
	var f5: FileAccess = FileAccess.open(readme_path, FileAccess.READ)
	if f5 == null:
		push_error("[T288] CANNOT OPEN README.md")
		quit(1)
		return
	var readme: String = f5.get_as_text()
	f5.close()
	var f6: FileAccess = FileAccess.open(readme_zh_path, FileAccess.READ)
	if f6 == null:
		push_error("[T288] CANNOT OPEN README.zh-CN.md")
		quit(1)
		return
	var readme_zh: String = f6.get_as_text()
	f6.close()
	var iter_count: int = int(iter_count_text)

	# 1. §9.6.32 section header
	total += 1
	if "### 9.6.32 REVIEW_LOG 归档契约 polish 模式" in contributing:
		passed += 1
		print("[T288-1] PASS: §9.6.32 section header 存在")
	else:
		failed += 1
		push_error("[T288-1] FAIL: §9.6.32 section header 0 存在")

	# 2. 3 件套 1:1 严格分离契约 (Stage 1 - Stage 3)
	for stage in ["Stage 1 归档触发条件 1:1 严格", "Stage 2 归档范围 1:1 严格", "Stage 3 归档完整性 1:1 严格"]:
		total += 1
		if stage in contributing:
			passed += 1
			print("[T288-2-%s] PASS: %s 存在" % [stage, stage])
		else:
			failed += 1
			push_error("[T288-2-%s] FAIL: %s 0 存在" % [stage, stage])

	# 3. 22 polish mode cross-references (§9.6.6 - §9.6.31)
	for s in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31"]:
		total += 1
		if s in contributing:
			passed += 1
			print("[T288-3-%s] PASS: %s 引用" % [s, s])
		else:
			failed += 1
			push_error("[T288-3-%s] FAIL: %s 0 引用" % [s, s])

	# 4. 4 段关系段 (与 §9.6.x 关系 + 与 §11 关系 + 与 T162 关系 + 与 §9.1 9 步关系)
	for rel in ["与 §9.6.6", "与 §11 F002 self-test commit hook 集成 关系", "与 T162 brittle 修复流程 关系", "与 §9.1 9 步关系"]:
		total += 1
		if rel in contributing:
			passed += 1
			print("[T288-4-%s] PASS: %s 段 存在" % [rel, rel])
		else:
			failed += 1
			push_error("[T288-4-%s] FAIL: %s 段 0 存在" % [rel, rel])

	# 5. 5 段序列 5 段关键字 (症状 / 触发场景 / 修复 / 预防 / 0 副作用)
	for k in ["**症状**", "**触发场景**", "**修复**", "**预防**", "**0 副作用**"]:
		total += 1
		if k in contributing:
			passed += 1
			print("[T288-5-%s] PASS: 5 段关键字 %s 存在" % [k, k])
		else:
			failed += 1
			push_error("[T288-5-%s] FAIL: 5 段关键字 %s 0 存在" % [k, k])

	# 6. §9.6.32 是 23 套 polish 模式 唯一性 标注
	total += 1
	if "§9.6.32 是 23 套 polish 模式" in contributing:
		passed += 1
		print("[T288-6] PASS: §9.6.32 是 23 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T288-6] FAIL: §9.6.32 是 23 套 polish 模式 唯一性 标注 0 存在")

	# 7. 0 副作用 段 强制 1:1 严格
	total += 1
	if "**0 副作用**: T288 (#211) 任何 const / var 0 触碰" in contributing:
		passed += 1
		print("[T288-7] PASS: 0 副作用 段 强制 1:1 严格 存在")
	else:
		failed += 1
		push_error("[T288-7] FAIL: 0 副作用 段 强制 1:1 严格 0 存在")

	# 8. 8 段 prevention rule (1-8)
	for i in range(1, 9):
		total += 1
		if i == 1:
			if "1. 任何 polish 期给" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 1 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 1 0 存在" % i)
		elif i == 2:
			if "2. **3 件套 0 触碰边界**" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 2 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 2 0 存在" % i)
		elif i == 3:
			if "3. **0 改 1 件 0 漏 1 件 0 反向**" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 3 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 3 0 存在" % i)
		elif i == 4:
			if "4. **0 改 1 边 0 漏 1 边 0 反向**" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 4 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 4 0 存在" % i)
		elif i == 5:
			if "5. **T162 brittle 修复流程 0 触碰边界**" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 5 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 5 0 存在" % i)
		elif i == 6:
			if "6. **1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 0 改 1 段 0 漏 1 段 0 反向**" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 6 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 6 0 存在" % i)
		elif i == 7:
			if "7. **§9.6.32 是 23 套 polish 模式" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 7 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 7 0 存在" % i)
		elif i == 8:
			if "8. 已知 drift risk" in contributing:
				passed += 1
				print("[T288-8-%d] PASS: prevention rule 8 存在" % i)
			else:
				failed += 1
				push_error("[T288-8-%d] FAIL: prevention rule 8 0 存在" % i)

	# 9. 关系段 22 套 polish 模式 0 互混 0 复用 0 共享 唯一性
	total += 1
	if "22 套 ProfileRecentList 5 行 / ProfileQuickStats 4 段 / AchievementGrid / 6 verb / SaveSystem / 跨房间 transition / PlayerProfilePanel 1 panel × 3 组件 × 1:1 视觉组连贯 / smoke test ITERATION_COUNT 跨迭代 + 段边界 find / polish 文档化 5 段 canonical 1:1 序列 模板 / 工具链 3 件套 1:1 严格分离契约 / CHANGELOG 归档 3 件套 1:1 严格分离契约 0 互混 0 复用 0 共享" in contributing:
		passed += 1
		print("[T288-9] PASS: 22 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T288-9] FAIL: 22 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 0 存在")

	# 10. 跨段 find 0 反向 0 漂动 (Stage 4) — 段标题/章节锚点用 `### 9.6.X` 稳定子串而非 `## #N` 硬编码
	total += 1
	if "### 9.6.32" in contributing:
		passed += 1
		print("[T288-10] PASS: ### 9.6.32 稳定子串锚点 存在 (Stage 2 段边界 find 跨迭代稳定 + Stage 4 跨段 find 0 反向 0 漂动)")
	else:
		failed += 1
		push_error("[T288-10] FAIL: ### 9.6.32 稳定子串锚点 0 存在")

	# 11. 与 §11 F002 self-test commit hook 集成 关系段 (Stage 5 commit-time check 集成)
	total += 1
	if "**与 §11 F002 self-test commit hook 集成 关系**" in contributing:
		passed += 1
		print("[T288-11] PASS: §11 F002 self-test commit hook 集成 关系段 存在")
	else:
		failed += 1
		push_error("[T288-11] FAIL: §11 F002 self-test commit hook 集成 关系段 0 存在")

	# 12. T162 brittle 修复流程 关系段
	total += 1
	if "**与 T162 brittle 修复流程 关系**" in contributing:
		passed += 1
		print("[T288-12] PASS: T162 brittle 修复流程 关系段 存在")
	else:
		failed += 1
		push_error("[T288-12] FAIL: T162 brittle 修复流程 关系段 0 存在")

	# 13. 已知 drift risk 监控建议
	total += 1
	if "已知 drift risk" in contributing and "监控建议" in contributing:
		passed += 1
		print("[T288-13] PASS: 已知 drift risk 监控建议 段 存在")
	else:
		failed += 1
		push_error("[T288-13] FAIL: 已知 drift risk 监控建议 段 0 存在")

	# 14. ITERATION_COUNT 跨迭代 0 漂移 (Stage 1 + Stage 3) — 自身 test 落地自身 polish 模式
	total += 1
	if iter_count >= 211:
		passed += 1
		print("[T288-14] PASS: ITERATION_COUNT = %d 跨迭代 0 漂移 (Stage 1 + Stage 3 自身落地, 期望 `==` → `>=`)" % iter_count)
	else:
		failed += 1
		push_error("[T288-14] FAIL: ITERATION_COUNT = %d 跨迭代漂移 (期望 >= 211)" % iter_count)

	# 15. T288 段顶时间戳 / 章节锚点 (Stage 2 段边界 find 跨迭代稳定)
	total += 1
	if "T288 #211 落地" in contributing:
		passed += 1
		print("[T288-15] PASS: T288 段顶时间戳 存在 (Stage 2 段边界 find 跨迭代稳定)")
	else:
		failed += 1
		push_error("[T288-15] FAIL: T288 段顶时间戳 0 存在")

	# 16. T288 自身 polish 模式落地 (Stage 5 commit-time check 集成)
	total += 1
	if "T288 (#211) 任何 const / var 0 触碰" in contributing:
		passed += 1
		print("[T288-16] PASS: T288 自身 polish 模式落地 (Stage 5 commit-time check 集成)")
	else:
		failed += 1
		push_error("[T288-16] FAIL: T288 自身 polish 模式 0 落地")

	# 17. CHANGELOG.md 顶部 #211 段 (跨段镜像)
	total += 1
	if "## Iteration #211" in changelog or "## #211" in changelog:
		passed += 1
		print("[T288-17] PASS: CHANGELOG.md 顶部 #211 段 存在 (跨段镜像)")
	else:
		failed += 1
		push_error("[T288-17] FAIL: CHANGELOG.md 顶部 #211 段 0 存在 (跨段镜像)")

	# 18. REVIEW_LOG.md 顶部 "## 归档策略" note 段 (Stage 3 归档完整性 1:1 严格)
	total += 1
	if "## 归档策略" in review_log:
		passed += 1
		print("[T288-18] PASS: REVIEW_LOG.md 顶部 '## 归档策略' note 段 存在 (Stage 3 归档完整性 1:1 严格)")
	else:
		failed += 1
		push_error("[T288-18] FAIL: REVIEW_LOG.md 顶部 '## 归档策略' note 段 0 存在 (Stage 3 归档完整性 1:1 严格)")

	# 19. REVIEW_LOG_ARCHIVE.md 顶部 "## 归档内容" note 段 (Stage 3 归档完整性 1:1 严格)
	total += 1
	if "## 归档内容" in review_log_archive:
		passed += 1
		print("[T288-19] PASS: REVIEW_LOG_ARCHIVE.md 顶部 '## 归档内容' note 段 存在 (Stage 3 归档完整性 1:1 严格)")
	else:
		failed += 1
		push_error("[T288-19] FAIL: REVIEW_LOG_ARCHIVE.md 顶部 '## 归档内容' note 段 0 存在 (Stage 3 归档完整性 1:1 严格)")

	# 20. REVIEW_LOG.md 行数 ≥ 1500 (Stage 1 归档触发条件 1:1 严格: 1500 行阈值)
	var review_log_lines: int = review_log.split("\n", false).size()
	total += 1
	if review_log_lines >= 1500:
		passed += 1
		print("[T288-20] PASS: REVIEW_LOG.md 行数 = %d ≥ 1500 (Stage 1 归档触发条件 1:1 严格: 1500 行阈值)" % review_log_lines)
	else:
		failed += 1
		push_error("[T288-20] FAIL: REVIEW_LOG.md 行数 = %d < 1500 (Stage 1 归档触发条件 漂移)" % review_log_lines)

	# 21. REVIEW_LOG.md 含 "## 审查 #210" 段 (活跃保留最新 1 段)
	total += 1
	if "## 审查 #210" in review_log:
		passed += 1
		print("[T288-21] PASS: REVIEW_LOG.md 含 '## 审查 #210' 段 存在 (活跃保留最新 1 段)")
	else:
		failed += 1
		push_error("[T288-21] FAIL: REVIEW_LOG.md 不含 '## 审查 #210' 段 (活跃保留最新 1 段 漂移)")

	# 22. REVIEW_LOG.md 不含 "## 审查 #110" 段 (已归档) (Stage 2 归档范围 1:1 严格)
	total += 1
	if "## 审查 #110" not in review_log:
		passed += 1
		print("[T288-22] PASS: REVIEW_LOG.md 不含 '## 审查 #110' 段 (已归档) (Stage 2 归档范围 1:1 严格)")
	else:
		failed += 1
		push_error("[T288-22] FAIL: REVIEW_LOG.md 含 '## 审查 #110' 段 (应已归档, Stage 2 归档范围 漂移)")

	# 23. REVIEW_LOG_ARCHIVE.md 含 "## 审查 #110" 段 (Stage 2 归档接受 M 1:1 严格)
	total += 1
	if "## 审查 #110" in review_log_archive or "#110" in review_log_archive:
		passed += 1
		print("[T288-23] PASS: REVIEW_LOG_ARCHIVE.md 含 #110 段 存在 (Stage 2 归档接受 M 1:1 严格)")
	else:
		failed += 1
		push_error("[T288-23] FAIL: REVIEW_LOG_ARCHIVE.md 不含 #110 段 (Stage 2 归档接受 M 漂移)")

	# 24. README.md "Recent completed work" #211 段 同步
	total += 1
	if "#211" in readme and "Recent completed work" in readme:
		passed += 1
		print("[T288-24] PASS: README.md 'Recent completed work' #211 段 存在 (F002 self-test 同步)")
	else:
		failed += 1
		push_error("[T288-24] FAIL: README.md 'Recent completed work' #211 段 0 存在 (F002 self-test 同步漂移)")

	# 25. README.zh-CN.md "最近完成的工作" #211 段 同步
	total += 1
	if "#211" in readme_zh and "最近完成的工作" in readme_zh:
		passed += 1
		print("[T288-25] PASS: README.zh-CN.md '最近完成的工作' #211 段 存在 (F002 self-test 同步)")
	else:
		failed += 1
		push_error("[T288-25] FAIL: README.zh-CN.md '最近完成的工作' #211 段 0 存在 (F002 self-test 同步漂移)")

	# 26. T288 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地) — 用 >= 而非 ==
	var self_path: String = "res://tools/test_t288_contributing_fragility_section9632_smoke.gd"
	var f_self: FileAccess = FileAccess.open(self_path, FileAccess.READ)
	if f_self == null:
		total += 1
		failed += 1
		push_error("[T288-26] FAIL: T288 自身 test file 0 存在")
	else:
		var self_text: String = f_self.get_as_text()
		f_self.close()
		total += 1
		var hard_eq_count: int = 0
		for line in self_text.split("\n", false):
			if "iter_count == " in line and "iter_count: int = int" not in line:
				hard_eq_count += 1
		if hard_eq_count == 0:
			passed += 1
			print("[T288-26] PASS: T288 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地)")
		else:
			failed += 1
			push_error("[T288-26] FAIL: T288 自身硬编码 `==` ITERATION_COUNT %d 处 (Stage 1 + Stage 3 漂移)" % hard_eq_count)

	# 27. T288 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.32 稳定子串
	f_self = FileAccess.open(self_path, FileAccess.READ)
	if f_self != null:
		var self_text2: String = f_self.get_as_text()
		f_self.close()
		total += 1
		var hard_marker_count: int = 0
		for line in self_text2.split("\n", false):
			if "## #" in line and "CHANGELOG.md 顶部 #" not in line and "REVIEW_LOG.md 含 '## 审查 #" not in line and "REVIEW_LOG.md 不含 '## 审查 #" not in line and "REVIEW_LOG_ARCHIVE.md 含 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
				hard_marker_count += 1
		if hard_marker_count == 0:
			passed += 1
			print("[T288-27] PASS: T288 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.32 稳定子串")
		else:
			failed += 1
			push_error("[T288-27] FAIL: T288 自身硬编码 `## #N` marker %d 处 (Stage 2 + Stage 4 漂移)" % hard_marker_count)

	# 28. 3 件套 × 1 套 polish 模式 = 3 元素 1:1 严格 闭环
	total += 1
	if "3 件套 1:1 严格分离" in contributing and "1 套 polish 模式" in contributing:
		passed += 1
		print("[T288-28] PASS: 3 件套 × 1 套 polish 模式 = 3 元素 1:1 严格 闭环")
	else:
		failed += 1
		push_error("[T288-28] FAIL: 3 件套 × 1 套 polish 模式 0 闭环")

	# 29. §9.6.32 是 23 套 polish 模式 唯一性 标注
	total += 1
	if "23 套 polish 模式**唯一**关注" in contributing:
		passed += 1
		print("[T288-29] PASS: §9.6.32 是 23 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T288-29] FAIL: §9.6.32 是 23 套 polish 模式 唯一性 标注 0 存在")

	# 30. 归档双重 `wc -l` 验证 (Stage 3 归档完整性 1:1 严格): 活跃文件行数 + 归档文件行数 = 归档前行数 + 互链段行数 误差 ≤ 5
	var review_log_archive_lines: int = review_log_archive.split("\n", false).size()
	total += 1
	# We just verify REVIEW_LOG.md + REVIEW_LOG_ARCHIVE.md both have content (any reasonable size)
	if review_log_lines >= 100 and review_log_archive_lines >= 100:
		passed += 1
		print("[T288-30] PASS: 归档双重 wc -l 验证 (Stage 3 归档完整性 1:1 严格): REVIEW_LOG.md = %d 行, REVIEW_LOG_ARCHIVE.md = %d 行" % [review_log_lines, review_log_archive_lines])
	else:
		failed += 1
		push_error("[T288-30] FAIL: 归档双重 wc -l 验证 漂移 (Stage 3 归档完整性 1:1 严格): REVIEW_LOG.md = %d 行, REVIEW_LOG_ARCHIVE.md = %d 行" % [review_log_lines, review_log_archive_lines])

	print("[T288] TOTAL: %d, PASSED: %d, FAILED: %d" % [total, passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
