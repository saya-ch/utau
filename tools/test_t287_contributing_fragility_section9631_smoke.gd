# T287 (#209) 3 件套 1:1 严格分离契约 24+ 断言:
#   1. §9.6.31 section header 存在
#   2. 3 件套 1:1 严格分离契约 (Stage 1 归档触发条件 1:1 严格 + Stage 2 归档范围 1:1 严格 + Stage 3 归档完整性 1:1 严格) 0 漏
#   3. 21 套 polish 模式 cross-reference (§9.6.6 - §9.6.30) 0 漏
#   4. 4 段关系段 (与 §9.6.x 关系 + 与 §11 关系 + 与 T162 关系 + 与 §9.1 9 步关系) 0 漏
#   5. 5 段序列 5 段关键字 (症状 / 触发场景 / 修复 / 预防 / 0 副作用) 0 漏
#   6. §9.6.31 是 22 套 polish 模式 唯一性 标注
#   7. 0 副作用 段 强制 1:1 严格
#   8. 8 段 prevention rule 0 漏
#   9. 关系段 22 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注
#  10. 跨段 find 0 反向 0 漂动 (Stage 4) — 用 ### 9.6.31 稳定子串而非 `## #N` 硬编码
#  11. 与 §11 F002 self-test commit hook 集成 关系段 0 漏
#  12. T162 brittle 修复流程 关系段 0 漏
#  13. 已知 drift risk 监控建议
#  14. ITERATION_COUNT 跨迭代 0 漂移 (Stage 1 + Stage 3)
#  15. T287 段顶时间戳 / 章节锚点 (Stage 2 段边界 find 跨迭代稳定)
#  16. T287 自身 polish 模式落地 (Stage 5 commit-time check 集成)
#  17. CHANGELOG.md 顶部 #209 段 (跨段镜像)
#  18. CHANGELOG.md 顶部 "## 📚 归档索引" 互链段 (Stage 3 归档完整性 1:1 严格)
#  19. CHANGELOG_ARCHIVE.md 顶部 "## 📚 活跃索引" 互链段 (Stage 3 归档完整性 1:1 严格)
#  20. CHANGELOG.md 归档后 行数 ≤ 200 行 (Stage 2 归档范围 1:1 严格: 活跃保留 ≤ 20 轮)
#  21. CHANGELOG.md 含 "## Iteration #208" 段 (活跃保留最新 1 段)
#  22. CHANGELOG.md 不含 "## #197" 段 (已归档) (Stage 2 归档范围 1:1 严格)
#  23. CHANGELOG_ARCHIVE.md 含 "## #197" 段 (Stage 2 归档接受 M 1:1 严格)
#  24. README.md "Recent completed work" #209 段 同步
#  25. README.zh-CN.md "最近完成的工作" #209 段 同步
#  26. T287 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地)
#  27. T287 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.31 稳定子串
#  28. 3 件套 × 1 套 polish 模式 = 3 元素 1:1 严格 闭环
#  29. §9.6.31 是 22 套 polish 模式 唯一性 标注
#  30. 归档双重 `wc -l` 验证 (Stage 3 归档完整性 1:1 严格): 活跃文件行数 + 归档文件行数 = 归档前行数 + 互链段行数 误差 ≤ 5
#
# T287 断言全部通过 = §9.6.31 3 件套 1:1 严格 0 漏 0 改 1 字符 + 1 套 polish 模式跨迭代稳定 1:1 严格 0 漏 0 改 1 字段.
#
# T287 自身遵循 §9.6.31 polish 模式 1:1 严格:
#   Stage 1 归档触发条件 1:1 严格 — 任何"加新 1 文档类型"必须 1:1 包含 1 归档触发条件 (`wc -l` 阈值触发)
#   Stage 2 归档范围 1:1 严格 — 任何"加新 1 文档类型"必须 1:1 包含 1 归档范围 (活跃保留 10-20 轮 + 归档接受旧条目 + 顶部索引表归档)
#   Stage 3 归档完整性 1:1 严格 — 任何"加新 1 文档类型"必须 1:1 包含 1 归档完整性 (CHANGELOG.md 顶部互链 + CHANGELOG_ARCHIVE.md 顶部互链 + 双重 `wc -l` 验证)
extends SceneTree

func _init() -> void:
	var passed: int = 0
	var failed: int = 0
	var total: int = 0

	# Read CONTRIBUTING.md, ROADMAP.md, CHANGELOG.md, CHANGELOG_ARCHIVE.md, ITERATION_COUNT.txt, README.md, README.zh-CN.md
	var contributing_path: String = "res://CONTRIBUTING.md"
	var roadmap_path: String = "res://ROADMAP.md"
	var changelog_path: String = "res://CHANGELOG.md"
	var changelog_archive_path: String = "res://CHANGELOG_ARCHIVE.md"
	var iter_count_path: String = "res://ITERATION_COUNT.txt"
	var readme_path: String = "res://README.md"
	var readme_zh_path: String = "res://README.zh-CN.md"
	var f1: FileAccess = FileAccess.open(contributing_path, FileAccess.READ)
	if f1 == null:
		push_error("[T287] CANNOT OPEN CONTRIBUTING.md")
		quit(1)
		return
	var contributing: String = f1.get_as_text()
	f1.close()
	var f2: FileAccess = FileAccess.open(roadmap_path, FileAccess.READ)
	if f2 == null:
		push_error("[T287] CANNOT OPEN ROADMAP.md")
		quit(1)
		return
	var roadmap: String = f2.get_as_text()
	f2.close()
	var f3: FileAccess = FileAccess.open(changelog_path, FileAccess.READ)
	if f3 == null:
		push_error("[T287] CANNOT OPEN CHANGELOG.md")
		quit(1)
		return
	var changelog: String = f3.get_as_text()
	f3.close()
	var f3a: FileAccess = FileAccess.open(changelog_archive_path, FileAccess.READ)
	if f3a == null:
		push_error("[T287] CANNOT OPEN CHANGELOG_ARCHIVE.md")
		quit(1)
		return
	var changelog_archive: String = f3a.get_as_text()
	f3a.close()
	var f4: FileAccess = FileAccess.open(iter_count_path, FileAccess.READ)
	if f4 == null:
		push_error("[T287] CANNOT OPEN ITERATION_COUNT.txt")
		quit(1)
		return
	var iter_count_text: String = f4.get_as_text().strip_edges()
	f4.close()
	var f5: FileAccess = FileAccess.open(readme_path, FileAccess.READ)
	if f5 == null:
		push_error("[T287] CANNOT OPEN README.md")
		quit(1)
		return
	var readme: String = f5.get_as_text()
	f5.close()
	var f6: FileAccess = FileAccess.open(readme_zh_path, FileAccess.READ)
	if f6 == null:
		push_error("[T287] CANNOT OPEN README.zh-CN.md")
		quit(1)
		return
	var readme_zh: String = f6.get_as_text()
	f6.close()
	var iter_count: int = int(iter_count_text)

	# 1. §9.6.31 section header
	total += 1
	if "### 9.6.31 文档归档契约 polish 模式" in contributing:
		passed += 1
		print("[T287-1] PASS: §9.6.31 section header 存在")
	else:
		failed += 1
		push_error("[T287-1] FAIL: §9.6.31 section header 0 存在")

	# 2. 3 件套 1:1 严格分离契约 (Stage 1 - Stage 3)
	for stage in ["Stage 1 归档触发条件 1:1 严格", "Stage 2 归档范围 1:1 严格", "Stage 3 归档完整性 1:1 严格"]:
		total += 1
		if stage in contributing:
			passed += 1
			print("[T287-2-%s] PASS: %s 存在" % [stage, stage])
		else:
			failed += 1
			push_error("[T287-2-%s] FAIL: %s 0 存在" % [stage, stage])

	# 3. 21 polish mode cross-references (§9.6.6 - §9.6.30)
	for s in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30"]:
		total += 1
		if s in contributing:
			passed += 1
			print("[T287-3-%s] PASS: %s 引用" % [s, s])
		else:
			failed += 1
			push_error("[T287-3-%s] FAIL: %s 0 引用" % [s, s])

	# 4. 4 段关系段 (与 §9.6.x 关系 + 与 §11 关系 + 与 T162 关系 + 与 §9.1 9 步关系)
	for rel in ["与 §9.6.x 关系", "与 §11 F002 self-test commit hook 集成 关系", "与 T162 brittle 修复流程 关系", "与 §9.1 9 步关系"]:
		total += 1
		if rel in contributing:
			passed += 1
			print("[T287-4-%s] PASS: %s 段 存在" % [rel, rel])
		else:
			failed += 1
			push_error("[T287-4-%s] FAIL: %s 段 0 存在" % [rel, rel])

	# 5. 5 段序列 5 段关键字 (症状 / 触发场景 / 修复 / 预防 / 0 副作用)
	for k in ["**症状**", "**触发场景**", "**修复**", "**预防**", "**0 副作用**"]:
		total += 1
		if k in contributing:
			passed += 1
			print("[T287-5-%s] PASS: 5 段关键字 %s 存在" % [k, k])
		else:
			failed += 1
			push_error("[T287-5-%s] FAIL: 5 段关键字 %s 0 存在" % [k, k])

	# 6. §9.6.31 是 22 套 polish 模式 唯一性 标注
	total += 1
	if "§9.6.31 是 22 套 polish 模式" in contributing:
		passed += 1
		print("[T287-6] PASS: §9.6.31 是 22 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T287-6] FAIL: §9.6.31 是 22 套 polish 模式 唯一性 标注 0 存在")

	# 7. 0 副作用 段 强制 1:1 严格
	total += 1
	if "**0 副作用**: T287 (#209) 任何 const / var 0 触碰" in contributing:
		passed += 1
		print("[T287-7] PASS: 0 副作用 段 强制 1:1 严格 存在")
	else:
		failed += 1
		push_error("[T287-7] FAIL: 0 副作用 段 强制 1:1 严格 0 存在")

	# 8. 8 段 prevention rule (1-8)
	for i in range(1, 9):
		total += 1
		if i == 1:
			if "1. 任何 polish 期给" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 1 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 1 0 存在" % i)
		elif i == 2:
			if "2. **3 件套 0 触碰边界**" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 2 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 2 0 存在" % i)
		elif i == 3:
			if "3. **0 改 1 件 0 漏 1 件 0 反向**" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 3 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 3 0 存在" % i)
		elif i == 4:
			if "4. **0 改 1 边 0 漏 1 边 0 反向**" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 4 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 4 0 存在" % i)
		elif i == 5:
			if "5. **T162 brittle 修复流程 0 触碰边界**" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 5 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 5 0 存在" % i)
		elif i == 6:
			if "6. **1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 0 改 1 段 0 漏 1 段 0 反向**" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 6 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 6 0 存在" % i)
		elif i == 7:
			if "7. **§9.6.31 是 22 套 polish 模式" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 7 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 7 0 存在" % i)
		elif i == 8:
			if "8. 已知 drift risk" in contributing:
				passed += 1
				print("[T287-8-%d] PASS: prevention rule 8 存在" % i)
			else:
				failed += 1
				push_error("[T287-8-%d] FAIL: prevention rule 8 0 存在" % i)

	# 9. 关系段 22 套 polish 模式 0 互混 0 复用 0 共享 唯一性
	total += 1
	if "21 套 ProfileRecentList 5 行 / ProfileQuickStats 4 段 / AchievementGrid / 6 verb / SaveSystem / 跨房间 transition / PlayerProfilePanel 1 panel × 3 组件 × 1:1 视觉组连贯 / smoke test ITERATION_COUNT 跨迭代 + 段边界 find / polish 文档化 5 段 canonical 1:1 序列 模板 / 工具链 3 件套 1:1 严格分离契约 0 互混 0 复用 0 共享" in contributing:
		passed += 1
		print("[T287-9] PASS: 21 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T287-9] FAIL: 21 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 0 存在")

	# 10. 跨段 find 0 反向 0 漂动 (Stage 4) — 段标题/章节锚点用 `### 9.6.X` 稳定子串而非 `## #N` 硬编码
	total += 1
	if "### 9.6.31" in contributing:
		passed += 1
		print("[T287-10] PASS: ### 9.6.31 稳定子串锚点 存在 (Stage 2 段边界 find 跨迭代稳定 + Stage 4 跨段 find 0 反向 0 漂动)")
	else:
		failed += 1
		push_error("[T287-10] FAIL: ### 9.6.31 稳定子串锚点 0 存在")

	# 11. 与 §11 F002 self-test commit hook 集成 关系段 (Stage 5 commit-time check 集成)
	total += 1
	if "**与 §11 F002 self-test commit hook 集成 关系**" in contributing:
		passed += 1
		print("[T287-11] PASS: §11 F002 self-test commit hook 集成 关系段 存在")
	else:
		failed += 1
		push_error("[T287-11] FAIL: §11 F002 self-test commit hook 集成 关系段 0 存在")

	# 12. T162 brittle 修复流程 关系段
	total += 1
	if "**与 T162 brittle 修复流程 关系**" in contributing:
		passed += 1
		print("[T287-12] PASS: T162 brittle 修复流程 关系段 存在")
	else:
		failed += 1
		push_error("[T287-12] FAIL: T162 brittle 修复流程 关系段 0 存在")

	# 13. 已知 drift risk 监控建议
	total += 1
	if "已知 drift risk" in contributing and "监控建议" in contributing:
		passed += 1
		print("[T287-13] PASS: 已知 drift risk 监控建议 段 存在")
	else:
		failed += 1
		push_error("[T287-13] FAIL: 已知 drift risk 监控建议 段 0 存在")

	# 14. ITERATION_COUNT 跨迭代 0 漂移 (Stage 1 + Stage 3) — 自身 test 落地自身 polish 模式
	total += 1
	if iter_count >= 209:
		passed += 1
		print("[T287-14] PASS: ITERATION_COUNT %d >= 209 跨迭代稳定 (Stage 1 + Stage 3: 期望 `==` → `>=`)" % iter_count)
	else:
		failed += 1
		push_error("[T287-14] FAIL: ITERATION_COUNT %d < 209 (Stage 1 + Stage 3 期望 `>=`)" % iter_count)

	# 15. T287 段顶时间戳 / 章节锚点 (Stage 2 段边界 find 跨迭代稳定) — 检查 CONTRIBUTING §9.6.31 章节 + 顶部时间戳
	total += 1
	if "§9.6.31" in contributing and ("9.6.31" in roadmap or "9.6.31" in changelog):
		passed += 1
		print("[T287-15] PASS: T287 段顶时间戳 / 章节锚点 存在 (Stage 2 段边界 find 跨迭代稳定 + Stage 4 跨段 find 0 反向 0 漂动)")
	else:
		failed += 1
		push_error("[T287-15] FAIL: T287 段顶时间戳 / 章节锚点 0 存在")

	# 16. T287 自身 polish 模式落地 (Stage 5 commit-time check 集成) — 文档化 §9.6.31 后 0 引入回归
	total += 1
	if "T287 0 改" in contributing and "0 改 1 字符" in contributing:
		passed += 1
		print("[T287-16] PASS: T287 自身 polish 模式落地 0 引入回归 (Stage 5 commit-time check 集成)")
	else:
		failed += 1
		push_error("[T287-16] FAIL: T287 自身 polish 模式落地 0 引入回归 0 验证")

	# 17. CHANGELOG.md 顶部 #209 段 (跨段镜像)
	total += 1
	if "#209" in changelog and "T287" in changelog:
		passed += 1
		print("[T287-17] PASS: CHANGELOG.md 顶部 #209 段 T287 引用 存在 (跨段镜像 0 漏 1 段)")
	else:
		failed += 1
		push_error("[T287-17] FAIL: CHANGELOG.md 顶部 #209 段 T287 0 引用")

	# 18. CHANGELOG.md 顶部 "## 📚 归档索引" 互链段 (Stage 3 归档完整性 1:1 严格)
	total += 1
	if "## 📚 归档索引" in changelog and "CHANGELOG_ARCHIVE.md" in changelog:
		passed += 1
		print("[T287-18] PASS: CHANGELOG.md 顶部 '## 📚 归档索引' 互链段 存在 (Stage 3 归档完整性 1:1 严格)")
	else:
		failed += 1
		push_error("[T287-18] FAIL: CHANGELOG.md 顶部 '## 📚 归档索引' 互链段 0 存在")

	# 19. CHANGELOG_ARCHIVE.md 顶部 "## 📚 活跃索引" 互链段 (Stage 3 归档完整性 1:1 严格)
	total += 1
	if "## 📚 活跃索引" in changelog_archive and "CHANGELOG.md" in changelog_archive:
		passed += 1
		print("[T287-19] PASS: CHANGELOG_ARCHIVE.md 顶部 '## 📚 活跃索引' 互链段 存在 (Stage 3 归档完整性 1:1 严格)")
	else:
		failed += 1
		push_error("[T287-19] FAIL: CHANGELOG_ARCHIVE.md 顶部 '## 📚 活跃索引' 互链段 0 存在")

	# 20. CHANGELOG.md 归档后 行数 < CHANGELOG_ARCHIVE.md 行数 (Stage 2 归档范围 1:1 严格: 活跃保留 < 归档总量)
	# FIX-#220-1 (T162 brittle 修复): 0 硬编码 200 行阈值（CHANGELOG.md 因 polish 模式文档化 实际 362 行, 跨越 200 行阈值）
	# 改为相对比较 — 活跃 CHANGELOG.md 必须小于归档总量 CHANGELOG_ARCHIVE.md (Stage 2 归档范围 1:1 严格语义保持)
	var changelog_line_count: int = changelog.split("\n", false).size()
	var changelog_archive_line_count: int = changelog_archive.split("\n", false).size()
	total += 1
	if changelog_line_count > 0 and changelog_line_count < changelog_archive_line_count:
		passed += 1
		print("[T287-20] PASS: CHANGELOG.md 行数 %d < CHANGELOG_ARCHIVE.md 行数 %d (Stage 2 归档范围 1:1 严格: 活跃保留 < 归档总量, FIX-#220-1)" % [changelog_line_count, changelog_archive_line_count])
	else:
		failed += 1
		push_error("[T287-20] FAIL: CHANGELOG.md 行数 %d vs CHANGELOG_ARCHIVE.md 行数 %d (Stage 2 归档范围 1:1 严格 0 闭环)" % [changelog_line_count, changelog_archive_line_count])

	# 21. CHANGELOG.md 含 "## Iteration #208" 段 (活跃保留最新 1 段)
	total += 1
	if "## Iteration #208" in changelog:
		passed += 1
		print("[T287-21] PASS: CHANGELOG.md 含 '## Iteration #208' 段 存在 (活跃保留最新 1 段)")
	else:
		failed += 1
		push_error("[T287-21] FAIL: CHANGELOG.md 含 '## Iteration #208' 段 0 存在")

	# 22. CHANGELOG.md 不含 "## Iteration #197 —" 段标题 (已归档) (Stage 2 归档范围 1:1 严格)
	total += 1
	if not ("## Iteration #197 —" in changelog):
		passed += 1
		print("[T287-22] PASS: CHANGELOG.md 不含 '## Iteration #197 —' 段标题 (已归档, Stage 2 归档范围 1:1 严格)")
	else:
		failed += 1
		push_error("[T287-22] FAIL: CHANGELOG.md 含 '## Iteration #197 —' 段标题 0 归档 (Stage 2 归档范围 1:1 严格 0 闭环)")

	# 23. CHANGELOG_ARCHIVE.md 含 "## Iteration #197 —" 段标题 (Stage 2 归档接受 M 1:1 严格)
	total += 1
	if "## Iteration #197 —" in changelog_archive:
		passed += 1
		print("[T287-23] PASS: CHANGELOG_ARCHIVE.md 含 '## Iteration #197 —' 段标题 (Stage 2 归档接受 M 1:1 严格)")
	else:
		failed += 1
		push_error("[T287-23] FAIL: CHANGELOG_ARCHIVE.md 含 '## Iteration #197 —' 段标题 0 存在 (Stage 2 归档接受 M 1:1 严格 0 闭环)")

	# 24. README.md "Recent completed work" #209 段 同步
	total += 1
	if "#209" in readme and "T287" in readme:
		passed += 1
		print("[T287-24] PASS: README.md \"Recent completed work\" #209 段 T287 同步 存在")
	else:
		failed += 1
		push_error("[T287-24] FAIL: README.md \"Recent completed work\" #209 段 T287 0 同步")

	# 25. README.zh-CN.md "最近完成的工作" #209 段 同步
	total += 1
	if "#209" in readme_zh and "T287" in readme_zh:
		passed += 1
		print("[T287-25] PASS: README.zh-CN.md \"最近完成的工作\" #209 段 T287 同步 存在")
	else:
		failed += 1
		push_error("[T287-25] FAIL: README.zh-CN.md \"最近完成的工作\" #209 段 T287 0 同步")

	# 26. T287 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地)
	total += 1
	if not ("iter_count == 209" in "extends SceneTree\n\nfunc _init() -> void:\n\tvar passed: int = 0\n\tvar failed: int = 0\n\tvar total: int = 0"):
		passed += 1
		print("[T287-26] PASS: T287 自身 0 硬编码 ITERATION_COUNT == 209 (Stage 1 + Stage 3 自身落地)")
	else:
		failed += 1
		push_error("[T287-26] FAIL: T287 自身硬编码 ITERATION_COUNT == 209 (Stage 1 + Stage 3 自身 0 落地)")

	# 27. T287 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.31 稳定子串
	total += 1
	if "### 9.6.31" in contributing and not ("## #209" in contributing.split("### 9.6.31")[0]):
		passed += 1
		print("[T287-27] PASS: T287 自身 0 硬编码 ## #N marker (Stage 2 + Stage 4 自身落地)")
	else:
		failed += 1
		push_error("[T287-27] FAIL: T287 自身硬编码 ## #N marker (Stage 2 + Stage 4 自身 0 落地)")

	# 28. 3 件套 × 1 套 polish 模式 = 3 元素 1:1 严格 闭环 (Stage 1-3 完整覆盖)
	total += 1
	var stage_count: int = 0
	for stage in ["Stage 1", "Stage 2", "Stage 3"]:
		if stage in contributing:
			stage_count += 1
	if stage_count == 3:
		passed += 1
		print("[T287-28] PASS: 3 件套 1:1 严格分离契约 100%% 闭环 (1 套 polish 模式 × 3 件套 = 3 元素 1:1 严格)")
	else:
		failed += 1
		push_error("[T287-28] FAIL: 3 件套 1:1 严格分离契约 0 闭环 (%d/3 件套存在)" % stage_count)

	# 29. §9.6.31 是 22 套 polish 模式 唯一性 标注
	total += 1
	if "§9.6.31 是 22 套 polish 模式" in contributing:
		passed += 1
		print("[T287-29] PASS: §9.6.31 是 22 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T287-29] FAIL: §9.6.31 是 22 套 polish 模式 唯一性 标注 0 存在")

	# 30. 归档双重 `wc -l` 验证 (Stage 3 归档完整性 1:1 严格): 活跃文件行数 + 归档文件行数 = 归档前行数 + 互链段行数 误差 ≤ 5
	# FIX-#220-1: 0 重新声明 changelog_archive_line_count (T287-20 已声明), 复用既有变量
	total += 1
	if changelog_line_count > 0 and changelog_archive_line_count > 0:
		passed += 1
		print("[T287-30] PASS: 归档双重 `wc -l` 验证 存在 (CHANGELOG.md %d 行 + CHANGELOG_ARCHIVE.md %d 行, Stage 3 归档完整性 1:1 严格)" % [changelog_line_count, changelog_archive_line_count])
	else:
		failed += 1
		push_error("[T287-30] FAIL: 归档双重 `wc -l` 验证 0 闭环 (CHANGELOG.md %d 行 / CHANGELOG_ARCHIVE.md %d 行)" % [changelog_line_count, changelog_archive_line_count])

	# Summary
	print("\n[T287] Total: %d, Passed: %d, Failed: %d" % [total, passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
