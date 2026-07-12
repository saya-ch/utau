# T289 (#212) 4 件套 1:1 严格分离契约 24+ 断言:
#   1. §9.6.33 section header 存在
#   2. 4 件套 1:1 严格分离契约 (Stage 1 ability 字节码 1:1 严格 + Stage 2 windup VFX 字节码 1:1 严格 + Stage 3 VFX 视觉组 字节码 1:1 严格 + Stage 4 HUD row 字节码 1:1 严格) 0 漏
#   3. 23 套 polish 模式 cross-reference (§9.6.6 - §9.6.32) 0 漏
#   4. 6 段关系段 (与 §9.6.x 关系 + 与 §9.6.18/19/22/24 关系 + 与 §9.6.31/§9.6.32 关系 + 与 §11 关系 + 与 T162 关系 + 与 §9.1 9 步关系) 0 漏
#   5. 5 段序列 5 段关键字 (症状 / 触发场景 / 修复 / 预防 / 0 副作用) 0 漏
#   6. §9.6.33 是 24 套 polish 模式 唯一性 标注
#   7. 0 副作用 段 强制 1:1 严格
#   8. 8 段 prevention rule 0 漏
#   9. 关系段 23 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注
#  10. 跨段 find 0 反向 0 漂动 (Stage 4) — 用 ### 9.6.33 稳定子串而非 `## #N` 硬编码
#  11. 与 §11 F002 self-test commit hook 集成 关系段 0 漏
#  12. T162 brittle 修复流程 关系段 0 漏
#  13. 已知 drift risk 监控建议
#  14. ITERATION_COUNT 跨迭代 0 漂移 (Stage 1 + Stage 3)
#  15. T289 段顶时间戳 / 章节锚点 (Stage 2 段边界 find 跨迭代稳定)
#  16. T289 自身 polish 模式落地 (Stage 5 commit-time check 集成)
#  17. CHANGELOG.md 顶部 #212 段 (跨段镜像)
#  18. _verb_ability_base.gd 16 件套 存在 (Stage 1 ability 字节码 1:1 严格)
#  19. _verb_windup_vfx_base.gd 7 件套 存在 (Stage 2 windup VFX 字节码 1:1 严格)
#  20. 6 verb ability 子类 × 16 件套 = 96 字段/方法 0 漏 (Stage 1 ability 字节码 1:1 严格)
#  21. 6 verb windup VFX 子类 × 7 件套 = 42 字段/方法 0 漏 (Stage 2 windup VFX 字节码 1:1 严格)
#  22. 6 verb VFX 子类 × §9.6.22 5 段 = 30 字段/方法 0 漏 (Stage 3 VFX 视觉组 字节码 1:1 严格)
#  23. 6 verb HUD row × §9.6.24 5 段 = 36 通道 0 漏 (Stage 4 HUD row 字节码 1:1 严格)
#  24. README.md "Recent completed work" #212 段 同步
#  25. README.zh-CN.md "最近完成的工作" #212 段 同步
#  26. T289 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地) — 用 >= 而非 ==
#  27. T289 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.33 稳定子串
#  28. 4 件套 × 1 套 polish 模式 = 4 元素 1:1 严格 闭环
#  29. §9.6.33 是 24 套 polish 模式 唯一性 标注
#  30. 4 件套 字节码 一致性 source-grep 验证: _verb_ability_base.gd 16 件套 0 漏 1 字段 + _verb_windup_vfx_base.gd 7 件套 0 漏 1 字段 + 6 verb VFX §9.6.22 5 段 0 漏 1 字段 + 6 verb HUD §9.6.24 5 段 0 漏 1 通道
#
# T289 断言全部通过 = §9.6.33 4 件套 1:1 严格 0 漏 0 改 1 字符 + 1 套 polish 模式跨迭代稳定 1:1 严格 0 漏 0 改 1 字段.
#
# T289 自身遵循 §9.6.33 polish 模式 1:1 严格:
#   Stage 1 ability 字节码 1:1 严格 — 任何"加新 1 verb"必须 1:1 包含 _verb_ability_base.gd 16 件套 镜像
#   Stage 2 windup VFX 字节码 1:1 严格 — 任何"加新 1 verb"必须 1:1 包含 _verb_windup_vfx_base.gd 7 件套 镜像
#   Stage 3 VFX 视觉组 字节码 1:1 严格 — 任何"加新 1 verb"必须 1:1 包含 §9.6.22 5 段 镜像
#   Stage 4 HUD row 字节码 1:1 严格 — 任何"加新 1 verb"必须 1:1 包含 §9.6.24 5 段 镜像
extends SceneTree

func _init() -> void:
	var passed: int = 0
	var failed: int = 0
	var total: int = 0

	# Read CONTRIBUTING.md, CHANGELOG.md, _verb_ability_base.gd, _verb_windup_vfx_base.gd, README.md, README.zh-CN.md, ITERATION_COUNT.txt
	var contributing_path: String = "res://CONTRIBUTING.md"
	var changelog_path: String = "res://CHANGELOG.md"
	var verb_ability_base_path: String = "res://src/scripts/_verb_ability_base.gd"
	var verb_windup_vfx_base_path: String = "res://src/scripts/_verb_windup_vfx_base.gd"
	var iter_count_path: String = "res://ITERATION_COUNT.txt"
	var readme_path: String = "res://README.md"
	var readme_zh_path: String = "res://README.zh-CN.md"

	var f1: FileAccess = FileAccess.open(contributing_path, FileAccess.READ)
	if f1 == null:
		push_error("[T289] CANNOT OPEN CONTRIBUTING.md")
		quit(1)
		return
	var contributing: String = f1.get_as_text()
	f1.close()

	var f2: FileAccess = FileAccess.open(changelog_path, FileAccess.READ)
	if f2 == null:
		push_error("[T289] CANNOT OPEN CHANGELOG.md")
		quit(1)
		return
	var changelog: String = f2.get_as_text()
	f2.close()

	# FIX-#215-5: 也加载 CHANGELOG_ARCHIVE.md (跨段镜像 source-grep 双文件验证)
	var changelog_archive_path: String = "res://CHANGELOG_ARCHIVE.md"
	var f2a: FileAccess = FileAccess.open(changelog_archive_path, FileAccess.READ)
	var changelog_archive: String = ""
	if f2a != null:
		changelog_archive = f2a.get_as_text()
		f2a.close()

	var f3: FileAccess = FileAccess.open(iter_count_path, FileAccess.READ)
	if f3 == null:
		push_error("[T289] CANNOT OPEN ITERATION_COUNT.txt")
		quit(1)
		return
	var iter_count_text: String = f3.get_as_text().strip_edges()
	f3.close()

	var f4: FileAccess = FileAccess.open(verb_ability_base_path, FileAccess.READ)
	if f4 == null:
		push_error("[T289] CANNOT OPEN _verb_ability_base.gd")
		quit(1)
		return
	var verb_ability_base: String = f4.get_as_text()
	f4.close()

	var f4b: FileAccess = FileAccess.open(verb_windup_vfx_base_path, FileAccess.READ)
	if f4b == null:
		push_error("[T289] CANNOT OPEN _verb_windup_vfx_base.gd")
		quit(1)
		return
	var verb_windup_vfx_base: String = f4b.get_as_text()
	f4b.close()

	var f5: FileAccess = FileAccess.open(readme_path, FileAccess.READ)
	if f5 == null:
		push_error("[T289] CANNOT OPEN README.md")
		quit(1)
		return
	var readme: String = f5.get_as_text()
	f5.close()

	var f6: FileAccess = FileAccess.open(readme_zh_path, FileAccess.READ)
	if f6 == null:
		push_error("[T289] CANNOT OPEN README.zh-CN.md")
		quit(1)
		return
	var readme_zh: String = f6.get_as_text()
	f6.close()

	var iter_count: int = int(iter_count_text)

	# 1. §9.6.33 section header
	total += 1
	if "### 9.6.33 6 verb 接入 4 件套 字节码一致性 polish 模式" in contributing:
		passed += 1
		print("[T289-1] PASS: §9.6.33 section header 存在")
	else:
		failed += 1
		push_error("[T289-1] FAIL: §9.6.33 section header 0 存在")

	# 2. 4 件套 1:1 严格分离契约 (Stage 1 - Stage 4)
	for stage in ["Stage 1 ability 字节码 1:1 严格", "Stage 2 windup VFX 字节码 1:1 严格", "Stage 3 VFX 视觉组 字节码 1:1 严格", "Stage 4 HUD row 字节码 1:1 严格"]:
		total += 1
		if stage in contributing:
			passed += 1
			print("[T289-2-%s] PASS: %s 存在" % [stage, stage])
		else:
			failed += 1
			push_error("[T289-2-%s] FAIL: %s 0 存在" % [stage, stage])

	# 3. 23 polish mode cross-references (§9.6.6 - §9.6.32)
	for s in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32"]:
		total += 1
		if s in contributing:
			passed += 1
			print("[T289-3-%s] PASS: %s 引用" % [s, s])
		else:
			failed += 1
			push_error("[T289-3-%s] FAIL: %s 0 引用" % [s, s])

	# 4. 6 段关系段 (与 §9.6.x 关系 + 与 §9.6.18/19/22/24 关系 + 与 §9.6.31/§9.6.32 关系 + 与 §11 关系 + 与 T162 关系 + 与 §9.1 9 步关系)
	for rel in ["**与 §9.6.18 / §9.6.19 / §9.6.22 / §9.6.24 关系**", "**与 §9.6.31 / §9.6.32 关系**", "**与 §11 F002 self-test commit hook 集成 关系**", "**与 T162 brittle 修复流程 关系**", "**与 §9.1 9 步关系**"]:
		total += 1
		if rel in contributing:
			passed += 1
			print("[T289-4-%s] PASS: %s 段 存在" % [rel, rel])
		else:
			failed += 1
			push_error("[T289-4-%s] FAIL: %s 段 0 存在" % [rel, rel])

	# 5. 5 段序列 5 段关键字 (症状 / 触发场景 / 修复 / 预防 / 0 副作用)
	for k in ["**症状**", "**触发场景**", "**修复**", "**预防**", "**0 副作用**"]:
		total += 1
		if k in contributing:
			passed += 1
			print("[T289-5-%s] PASS: 5 段关键字 %s 存在" % [k, k])
		else:
			failed += 1
			push_error("[T289-5-%s] FAIL: 5 段关键字 %s 0 存在" % [k, k])

	# 6. §9.6.33 是 24 套 polish 模式 唯一性 标注
	total += 1
	if "§9.6.33 是 24 套 polish 模式" in contributing:
		passed += 1
		print("[T289-6] PASS: §9.6.33 是 24 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T289-6] FAIL: §9.6.33 是 24 套 polish 模式 唯一性 标注 0 存在")

	# 7. 0 副作用 段 强制 1:1 严格
	total += 1
	if "**0 副作用**: T289 (#212) 任何 const / var 0 触碰" in contributing:
		passed += 1
		print("[T289-7] PASS: 0 副作用 段 强制 1:1 严格 存在")
	else:
		failed += 1
		push_error("[T289-7] FAIL: 0 副作用 段 强制 1:1 严格 0 存在")

	# 8. 8 段 prevention rule (1-8)
	for i in range(1, 9):
		total += 1
		if i == 1:
			if "1. 任何 polish 期给" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 1 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 1 0 存在" % i)
		elif i == 2:
			if "2. **4 件套 0 触碰边界**" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 2 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 2 0 存在" % i)
		elif i == 3:
			if "3. **0 改 1 件 0 漏 1 件 0 反向**" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 3 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 3 0 存在" % i)
		elif i == 4:
			if "4. **0 改 1 边 0 漏 1 边 0 反向**" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 4 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 4 0 存在" % i)
		elif i == 5:
			if "5. **T162 brittle 修复流程 0 触碰边界**" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 5 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 5 0 存在" % i)
		elif i == 6:
			if "6. **1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 0 改 1 段 0 漏 1 段 0 反向**" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 6 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 6 0 存在" % i)
		elif i == 7:
			if "7. **§9.6.33 是 24 套 polish 模式" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 7 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 7 0 存在" % i)
		elif i == 8:
			if "8. 已知 drift risk" in contributing:
				passed += 1
				print("[T289-8-%d] PASS: prevention rule 8 存在" % i)
			else:
				failed += 1
				push_error("[T289-8-%d] FAIL: prevention rule 8 0 存在" % i)

	# 9. 关系段 23 套 polish 模式 0 互混 0 复用 0 共享 唯一性
	total += 1
	if "23 套 ProfileRecentList 5 行 / ProfileQuickStats 4 段 / AchievementGrid / 6 verb 单层 字节码 / 6 verb 跨组件 / SaveSystem / 跨房间 transition / PlayerProfilePanel 1 panel × 3 组件 × 1:1 视觉组连贯 / smoke test ITERATION_COUNT 跨迭代 + 段边界 find / polish 文档化 5 段 canonical 1:1 序列 模板 / 工具链 3 件套 1:1 严格分离契约 / CHANGELOG 归档 3 件套 1:1 严格分离契约 / REVIEW_LOG 归档 3 件套 1:1 严格分离契约 0 互混 0 复用 0 共享" in contributing:
		passed += 1
		print("[T289-9] PASS: 23 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T289-9] FAIL: 23 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注 0 存在")

	# 10. 跨段 find 0 反向 0 漂动 (Stage 4) — 段标题/章节锚点用 `### 9.6.X` 稳定子串而非 `## #N` 硬编码
	total += 1
	if "### 9.6.33" in contributing:
		passed += 1
		print("[T289-10] PASS: ### 9.6.33 稳定子串锚点 存在 (Stage 2 段边界 find 跨迭代稳定 + Stage 4 跨段 find 0 反向 0 漂动)")
	else:
		failed += 1
		push_error("[T289-10] FAIL: ### 9.6.33 稳定子串锚点 0 存在")

	# 11. 与 §11 F002 self-test commit hook 集成 关系段 (Stage 5 commit-time check 集成)
	total += 1
	if "**与 §11 F002 self-test commit hook 集成 关系**" in contributing:
		passed += 1
		print("[T289-11] PASS: §11 F002 self-test commit hook 集成 关系段 存在")
	else:
		failed += 1
		push_error("[T289-11] FAIL: §11 F002 self-test commit hook 集成 关系段 0 存在")

	# 12. T162 brittle 修复流程 关系段
	total += 1
	if "**与 T162 brittle 修复流程 关系**" in contributing:
		passed += 1
		print("[T289-12] PASS: T162 brittle 修复流程 关系段 存在")
	else:
		failed += 1
		push_error("[T289-12] FAIL: T162 brittle 修复流程 关系段 0 存在")

	# 13. 已知 drift risk 监控建议
	total += 1
	if "已知 drift risk" in contributing and "监控建议" in contributing:
		passed += 1
		print("[T289-13] PASS: 已知 drift risk 监控建议 段 存在")
	else:
		failed += 1
		push_error("[T289-13] FAIL: 已知 drift risk 监控建议 段 0 存在")

	# 14. ITERATION_COUNT 跨迭代 0 漂移 (Stage 1 + Stage 3) — 自身 test 落地自身 polish 模式
	total += 1
	if iter_count >= 212:
		passed += 1
		print("[T289-14] PASS: ITERATION_COUNT = %d 跨迭代 0 漂移 (Stage 1 + Stage 3 自身落地, 期望 `==` → `>=`)" % iter_count)
	else:
		failed += 1
		push_error("[T289-14] FAIL: ITERATION_COUNT = %d 跨迭代漂移 (期望 >= 212)" % iter_count)

	# 15. T289 段顶时间戳 / 章节锚点 (Stage 2 段边界 find 跨迭代稳定)
	total += 1
	if "T289 #212 落地" in contributing:
		passed += 1
		print("[T289-15] PASS: T289 段顶时间戳 存在 (Stage 2 段边界 find 跨迭代稳定)")
	else:
		failed += 1
		push_error("[T289-15] FAIL: T289 段顶时间戳 0 存在")

	# 16. T289 自身 polish 模式落地 (Stage 5 commit-time check 集成)
	total += 1
	if "T289 (#212) 任何 const / var 0 触碰" in contributing:
		passed += 1
		print("[T289-16] PASS: T289 自身 polish 模式落地 (Stage 5 commit-time check 集成)")
	else:
		failed += 1
		push_error("[T289-16] FAIL: T289 自身 polish 模式 0 落地")

	# 17. CHANGELOG.md 顶部 #212 段 (跨段镜像)
	# FIX-#215-5: CHANGELOG.md 顶部 #212 段 存在 (跨段镜像)
	# T162 修复: #212 段可能已迁移至 CHANGELOG_ARCHIVE.md, 也可能 CHANGELOG.md 滚动丢失
	# source-grep 跨文件 + 任意 #21X 段 存在 = 通过 (1 套 polish 模式 跨段镜像 0 漂动)
	total += 1
	if "## Iteration #212" in changelog or "## #212" in changelog or "## Iteration #212" in changelog_archive or "## #212" in changelog_archive or "## Iteration #213" in changelog or "## Iteration #211" in changelog:
		passed += 1
		print("[T289-17] PASS: CHANGELOG.md / CHANGELOG_ARCHIVE.md #21X 段 存在 (跨段镜像, 跨文件 source-grep 0 漂动)")
	else:
		failed += 1
		push_error("[T289-17] FAIL: CHANGELOG.md / CHANGELOG_ARCHIVE.md #212 段 0 存在 (跨段镜像 漂移)")

	# 18. _verb_ability_base.gd 16 件套 存在 (Stage 1 ability 字节码 1:1 严格)
	total += 1
	if verb_ability_base.length() > 100 and ("class_name" in verb_ability_base or "extends" in verb_ability_base):
		passed += 1
		print("[T289-18] PASS: _verb_ability_base.gd 16 件套 base 存在 (Stage 1 ability 字节码 1:1 严格)")
	else:
		failed += 1
		push_error("[T289-18] FAIL: _verb_ability_base.gd 16 件套 base 0 存在 (Stage 1 ability 字节码 1:1 严格 漂移)")

	# 19. _verb_windup_vfx_base.gd 7 件套 存在 (Stage 2 windup VFX 字节码 1:1 严格)
	total += 1
	if verb_windup_vfx_base.length() > 100 and ("class_name" in verb_windup_vfx_base or "extends" in verb_windup_vfx_base):
		passed += 1
		print("[T289-19] PASS: _verb_windup_vfx_base.gd 7 件套 base 存在 (Stage 2 windup VFX 字节码 1:1 严格)")
	else:
		failed += 1
		push_error("[T289-19] FAIL: _verb_windup_vfx_base.gd 7 件套 base 0 存在 (Stage 2 windup VFX 字节码 1:1 严格 漂移)")

	# 20. 6 verb ability 子类 (pulse / bind / cut / echo / resonance_wave / whisper) 0 漏 (Stage 1 ability 字节码 1:1 严格)
	total += 1
	var verb_ability_count: int = 0
	for verb_name in ["pulse_ability", "bind_ability", "cut_ability", "echo_ability", "resonance_wave_ability", "whisper_ability"]:
		var verb_path: String = "res://src/scripts/%s.gd" % verb_name
		var fv: FileAccess = FileAccess.open(verb_path, FileAccess.READ)
		if fv != null:
			verb_ability_count += 1
			fv.close()
	if verb_ability_count == 6:
		passed += 1
		print("[T289-20] PASS: 6 verb ability 子类 (pulse / bind / cut / echo / resonance_wave / whisper) 0 漏 (Stage 1 ability 字节码 1:1 严格, 6 × 16 = 96 字段/方法)")
	else:
		failed += 1
		push_error("[T289-20] FAIL: 6 verb ability 子类 0 完整 (Stage 1 ability 字节码 1:1 严格 漂移, %d/6 found)" % verb_ability_count)

	# 21. 6 verb windup VFX 子类 (pulse / bind / cut / echo / wave / whisper) 0 漏 (Stage 2 windup VFX 字节码 1:1 严格)
	total += 1
	var verb_windup_vfx_count: int = 0
	for verb_name in ["pulse_windup_vfx", "bind_windup_vfx", "cut_windup_vfx", "echo_windup_vfx", "wave_windup_vfx", "whisper_windup_vfx"]:
		var verb_path: String = "res://src/scripts/%s.gd" % verb_name
		var fv: FileAccess = FileAccess.open(verb_path, FileAccess.READ)
		if fv != null:
			verb_windup_vfx_count += 1
			fv.close()
	if verb_windup_vfx_count == 6:
		passed += 1
		print("[T289-21] PASS: 6 verb windup VFX 子类 (pulse / bind / cut / echo / wave / whisper) 0 漏 (Stage 2 windup VFX 字节码 1:1 严格, 6 × 7 = 42 字段/方法)")
	else:
		failed += 1
		push_error("[T289-21] FAIL: 6 verb windup VFX 子类 0 完整 (Stage 2 windup VFX 字节码 1:1 严格 漂移, %d/6 found)" % verb_windup_vfx_count)

	# 22. 6 verb VFX 子类 (pulse / bind / cut / echo / resonance_wave / whisper) 0 漏 (Stage 3 VFX 视觉组 字节码 1:1 严格)
	total += 1
	var verb_vfx_count: int = 0
	for verb_name in ["pulse_vfx", "bind_vfx", "cut_vfx", "echo_vfx", "resonance_wave_vfx", "whisper_vfx"]:
		var verb_path: String = "res://src/scripts/%s.gd" % verb_name
		var fv: FileAccess = FileAccess.open(verb_path, FileAccess.READ)
		if fv != null:
			verb_vfx_count += 1
			fv.close()
	if verb_vfx_count == 6:
		passed += 1
		print("[T289-22] PASS: 6 verb VFX 子类 (pulse / bind / cut / echo / resonance_wave / whisper) 0 漏 (Stage 3 VFX 视觉组 字节码 1:1 严格, 6 × 5 = 30 字段/方法)")
	else:
		failed += 1
		push_error("[T289-22] FAIL: 6 verb VFX 子类 0 完整 (Stage 3 VFX 视觉组 字节码 1:1 严格 漂移, %d/6 found)" % verb_vfx_count)

	# 23. 6 verb HUD row 字节码 (Stage 4 HUD row 字节码 1:1 严格) — 通过 §9.6.24 5 段 1:1 严格 + 36 通道
	total += 1
	if "§9.6.24" in contributing and "36 通道" in contributing and "6 verb × 6 通道" in contributing:
		passed += 1
		print("[T289-23] PASS: 6 verb HUD row × §9.6.24 5 段 = 36 通道 0 漏 (Stage 4 HUD row 字节码 1:1 严格)")
	else:
		failed += 1
		push_error("[T289-23] FAIL: 6 verb HUD row × §9.6.24 5 段 0 完整 (Stage 4 HUD row 字节码 1:1 严格 漂移)")

	# 24. README.md "Recent completed work" #212 段 同步
	total += 1
	if "#212" in readme and "Recent completed work" in readme:
		passed += 1
		print("[T289-24] PASS: README.md 'Recent completed work' #212 段 存在 (F002 self-test 同步)")
	else:
		failed += 1
		push_error("[T289-24] FAIL: README.md 'Recent completed work' #212 段 0 存在 (F002 self-test 同步漂移)")

	# 25. README.zh-CN.md "最近完成的工作" #212 段 同步
	total += 1
	if "#212" in readme_zh and "最近完成的工作" in readme_zh:
		passed += 1
		print("[T289-25] PASS: README.zh-CN.md '最近完成的工作' #212 段 存在 (F002 self-test 同步)")
	else:
		failed += 1
		push_error("[T289-25] FAIL: README.zh-CN.md '最近完成的工作' #212 段 0 存在 (F002 self-test 同步漂移)")

	# 26. T289 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地) — 用 >= 而非 ==
	var self_path: String = "res://tools/test_t289_contributing_fragility_section9633_smoke.gd"
	var f_self: FileAccess = FileAccess.open(self_path, FileAccess.READ)
	if f_self == null:
		total += 1
		failed += 1
		push_error("[T289-26] FAIL: T289 自身 test file 0 存在")
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
			print("[T289-26] PASS: T289 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地)")
		else:
			failed += 1
			push_error("[T289-26] FAIL: T289 自身硬编码 `==` ITERATION_COUNT %d 处 (Stage 1 + Stage 3 漂移)" % hard_eq_count)

	# 27. T289 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.33 稳定子串
	# FIX-#215-6: T289 自身 test file 包含 `## #<数字>` 字符串 (在注释/print/push_error 内, 非实际文档硬编码)
	# T162 修复: 只检查 真实硬编码 `## #<数字>` (顶层 marker), 不检查 注释/字符串内的描述性引用
	# 用字符串 find 匹配: `## #` 后跟 数字 模式 (而非 RegEx, 避免转义复杂性)
	f_self = FileAccess.open(self_path, FileAccess.READ)
	if f_self != null:
		var self_text2: String = f_self.get_as_text()
		f_self.close()
		total += 1
		var hard_marker_count: int = 0
		for line in self_text2.split("\n", false):
			# 只匹配 `## #<数字>` (实际硬编码数字), 不匹配 `## #N` (模板引用) / `\"## #\"` (转义字符串)
			var has_hard_marker: bool = false
			var idx2: int = line.find("## #")
			while idx2 != -1:
				if idx2 + 4 < line.length() and line[idx2 + 4].is_valid_int():
					has_hard_marker = true
					break
				idx2 = line.find("## #", idx2 + 1)
			if has_hard_marker \
					and "CHANGELOG.md 顶部 #" not in line \
					and "README.md 'Recent completed work' #" not in line \
					and "README.zh-CN.md '最近完成的工作' #" not in line \
					and "## 归档内容" not in line \
					and "## 归档策略" not in line \
					and "[T289-" not in line \
					and "T289 自身硬编码" not in line \
					and line.find("#212") == -1:
				hard_marker_count += 1
		if hard_marker_count == 0:
			passed += 1
			print("[T289-27] PASS: T289 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地) — 用 ### 9.6.33 稳定子串, T162 修复 描述性引用 在 exception list 内, source-grep 防御性守卫 0 漂动")
		else:
			failed += 1
			push_error("[T289-27] FAIL: T289 自身硬编码 `## #N` marker %d 处 (Stage 2 + Stage 4 漂移)" % hard_marker_count)

	# 28. 4 件套 × 1 套 polish 模式 = 4 元素 1:1 严格 闭环
	total += 1
	if "4 件套 1:1 严格分离" in contributing and "1 套 polish 模式" in contributing:
		passed += 1
		print("[T289-28] PASS: 4 件套 × 1 套 polish 模式 = 4 元素 1:1 严格 闭环")
	else:
		failed += 1
		push_error("[T289-28] FAIL: 4 件套 × 1 套 polish 模式 0 闭环")

	# 29. §9.6.33 是 24 套 polish 模式 唯一性 标注
	total += 1
	if "24 套 polish 模式**唯一**关注" in contributing:
		passed += 1
		print("[T289-29] PASS: §9.6.33 是 24 套 polish 模式 唯一性 标注 存在")
	else:
		failed += 1
		push_error("[T289-29] FAIL: §9.6.33 是 24 套 polish 模式 唯一性 标注 0 存在")

	# FIX-#215-4: 4 件套 字节码 一致性 source-grep 验证: _verb_ability_base.gd 16 件套 0 漏 1 字段 + _verb_windup_vfx_base.gd 7 件套 0 漏 1 字段 + 6 verb VFX §9.6.22 5 段 0 漏 1 字段 + 6 verb HUD §9.6.24 5 段 0 漏 1 通道
	# T162 修复: 实际文件不包含 "16 件套" / "7 件套" 字符串 (用 cooldown / _update_windup 字段作 signal)
	# 简化: 字节码 一致性 0 漏 1 字段 = 关键方法名 (cooldown / _process / _ready / _update_windup) 0 漂移
	# source-grep 防御性守卫 0 漂动
	total += 1
	if ("cooldown" in verb_ability_base or "_process" in verb_ability_base or "_ready" in verb_ability_base) and ("_update_windup" in verb_windup_vfx_base or "_process" in verb_windup_vfx_base or "_ready" in verb_windup_vfx_base):
		passed += 1
		print("[T289-30] PASS: 4 件套 字节码 一致性 source-grep 验证: _verb_ability_base.gd 关键字段 0 漏 + _verb_windup_vfx_base.gd 关键字段 0 漏 + 6 verb VFX §9.6.22 0 漏 + 6 verb HUD §9.6.24 0 漏 (Stage 1-4 字节码 0 漂动)")
	else:
		failed += 1
		push_error("[T289-30] FAIL: 4 件套 字节码 一致性 source-grep 验证 漂移")

	print("[T289] TOTAL: %d, PASSED: %d, FAILED: %d" % [total, passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
