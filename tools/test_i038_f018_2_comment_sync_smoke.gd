extends SceneTree
## I038 (#132) — F018.2 comment-sync 注释收尾冒烟测试
##
## 验证 #132 I038 收尾: save_system.gd `_get_autoload` helper F018.2 (#131)
## 注释同步落地. F018.2 (#131) 把 helper 抽提到 3 autoload 共享, 但
## save_system.gd (作为本仓库 3 autoload helper 的"模式定义"原始拥有者)
## 当时只更新了 helper 同步到 game_state.gd + player_stats.gd, 自身
## helper 注释未加 F018.2 (#131) 跨引用. I038 (#132) 收尾:
##
##   * save_system.gd `_get_autoload` helper 注释加 F018.2 (#131) 跨引用
##     + 路径选择 rationale (SceneTree.root vs self.get_node_or_null)
##     + null-guard 模式 (test resilience 兜底)
##   * 与 game_state.gd / player_stats.gd helper 注释形成 3 autoload
##     完整 F018.2 注释对称 (3 端都有 F018.2 跨引用)
##   * 3 端实现功能上完全相同 (1 idiom 取代"3 处各自维护 8 行内联")
##
## === I038.HELPER.3  3 autoload (save_system / game_state / player_stats) ===
## === I038.F018_2  3 autoload helper 注释都含 F018.2 跨引用 ===
## === I038.MODE_DEF  save_system.gd 注释声明为"模式定义" (原始拥有者) ===
## === I038.SCENE_TREE  3 autoload helper 注释都提到 SceneTree.root 路径 ===
## === I038.SELF_DANGER  3 autoload helper 注释都警告 self.get_node_or_null ===
## === I038.NULL_GUARD  3 autoload helper 注释都提到 null-guard 模式 ===
## === I038.SAME_BODY  3 autoload helper 函数体行数一致 (实现相同) ===
## === I038.PROD_TRUE  3 autoload helper 注释都提到"真游戏" autoload 永远存在 ===
##
## F018.0 (#130) — preset scope 泄漏 (音频侧)
## F018.1 (#130) — game_state 静态引用 PlayerStats.reset_stats → dynamic
## F018.2 (#131) — 抽出 _get_autoload() 通用 helper, 应用到 game_state.gd + player_stats.gd
## I038 (#132) — F018.2 注释同步收尾: save_system.gd helper 注释加 F018.2 (#131) 跨引用

func _initialize() -> void:
	print("=== I038 F018.2 comment-sync 注释收尾 smoke test ===")

	var pass_count := 0
	var fail_count := 0

	# 加载 3 autoload 源文件
	var paths := {
		"save_system": "res://src/autoload/save_system.gd",
		"game_state": "res://src/autoload/game_state.gd",
		"player_stats": "res://src/autoload/player_stats.gd",
	}
	var sources: Dictionary = {}
	for key in paths:
		var f := FileAccess.open(paths[key], FileAccess.READ)
		if f == null:
			print("  FAIL: cannot open %s" % paths[key])
			fail_count += 1
			quit(1)
			return
		sources[key] = f.get_as_text()
		f.close()

	# 抽取每个文件 _get_autoload 注释块 (func 之前的连续注释行)
	# 策略: 从 "func _get_autoload(" 向前回溯, 跳过空行, 收集所有以 "#"
	# 开头的连续行 (包括前导空白). 一旦遇到非注释行, 停止.
	var helper_blocks: Dictionary = {}
	for key in sources:
		var src: String = sources[key]
		var marker := "func _get_autoload("
		var idx := src.find(marker)
		if idx == -1:
			print("  FAIL: %s missing _get_autoload func" % paths[key])
			fail_count += 1
			quit(1)
			return
		# 向前回溯找 func 之前的连续注释块. 注释行以 "#" 开头, 可有前导空白.
		# 从 idx-1 向前逐行检查, 直到遇到非空非注释行停止.
		var block_start := idx
		var j := idx - 1
		while j > 0:
			# 找当前行的起始 (上一个 \n 之后)
			var line_end := j
			var line_start := j
			while line_start > 0 and src[line_start - 1] != '\n':
				line_start -= 1
			# 当前行内容 (不含换行)
			var line: String = src.substr(line_start, line_end - line_start + 1)
			# 去除前导空白
			var trimmed: String = line.lstrip(" \t")
			if trimmed.begins_with("#"):
				# 注释行, 继续向前
				block_start = line_start
				j = line_start - 1
			elif trimmed.length() == 0:
				# 空行, 跳过 (可能是注释块之前的空行)
				# 但如果已经在注释块内, 就不跳过 — 我们只收集紧邻 func 的连续注释
				if block_start < idx:
					# 已经在注释块内遇到空行, 停止
					break
				j = line_start - 1
			else:
				# 非注释非空行, 停止
				break
		helper_blocks[key] = src.substr(block_start, idx - block_start)

	# 1. I038.HELPER.3  3 autoload 都声明 _get_autoload
	for key in paths:
		var src: String = sources[key]
		if src.find("func _get_autoload(") != -1:
			print("  %s declares _get_autoload() (OK)" % key)
			pass_count += 1
		else:
			print("  FAIL: %s missing _get_autoload() declaration" % key)
			fail_count += 1

	# 2. I038.F018_2  3 autoload helper 注释都含 F018.2 跨引用
	for key in paths:
		var block: String = helper_blocks[key]
		if block.find("F018.2") != -1:
			print("  %s helper block mentions F018.2 (OK)" % key)
			pass_count += 1
		else:
			print("  FAIL: %s helper block missing F018.2 cross-reference — I038 not applied" % key)
			fail_count += 1

	# 3. I038.MODE_DEF  save_system.gd 注释声明为"模式定义"
	#    (使用 "模式定义" / "原始拥有者" / "F018.2 (#131)" 三者至少 2 个
	#    才算"模式定义"声明, 防止意外 false positive)
	var save_block: String = helper_blocks["save_system"]
	var mode_def_count := 0
	if save_block.find("模式定义") != -1:
		mode_def_count += 1
	if save_block.find("原始拥有者") != -1:
		mode_def_count += 1
	if save_block.find("F018.2") != -1:
		mode_def_count += 1
	if mode_def_count >= 2:
		print("  save_system.gd helper block declares '模式定义' (模式定义 / 原始拥有者 / F018.2 至少 2 项) (OK)")
		pass_count += 1
	else:
		print("  FAIL: save_system.gd helper block missing '模式定义' / '原始拥有者' / F018.2 reference (found %d/3)" % mode_def_count)
		fail_count += 1

	# 4. I038.SCENE_TREE  3 autoload helper 注释都提到 SceneTree.root 路径
	for key in paths:
		var block: String = helper_blocks[key]
		if block.find("SceneTree.root") != -1 or block.find("SceneTree") != -1:
			print("  %s helper block mentions SceneTree.root path (OK)" % key)
			pass_count += 1
		else:
			print("  FAIL: %s helper block missing SceneTree.root mention" % key)
			fail_count += 1

	# 5. I038.SELF_DANGER  3 autoload helper 注释都警告 self.get_node_or_null 风险
	#    (警告: self.get_node_or_null 绝对路径在 self 不在 scene tree 时会抛错)
	for key in paths:
		var block: String = helper_blocks[key]
		if block.find("self.get_node_or_null") != -1 or block.find("绝对路径") != -1:
			print("  %s helper block warns about self.get_node_or_null absolute path risk (OK)" % key)
			pass_count += 1
		else:
			print("  FAIL: %s helper block missing self.get_node_or_null warning" % key)
			fail_count += 1

	# 6. I038.NULL_GUARD  3 autoload helper 注释都提到 null-guard 模式
	for key in paths:
		var block: String = helper_blocks[key]
		if block.find("null-guard") != -1 or block.find("null guard") != -1 or block.find("null") != -1:
			print("  %s helper block mentions null-guard pattern (OK)" % key)
			pass_count += 1
		else:
			print("  FAIL: %s helper block missing null-guard mention" % key)
			fail_count += 1

	# 7. I038.SAME_BODY  3 autoload helper 函数体行数大致一致 (实现相同)
	#    GDScript 函数体是 indent-based (无 { }), 找 func 后的 ":" 后第一个 \n
	#    之后的非空行 (body 起点), 向下数连续 tab/space 缩进入 body 的行,
	#    遇到 dedent 停止. body 行数应大致相同 (允许 ±5 行的内嵌注释
	#    差异 — 不同 helper 注释风格不同, 但代码行 7 行一致).
	var body_lines: Array = []
	for key in paths:
		var src: String = sources[key]
		var idx := src.find("func _get_autoload(")
		if idx == -1:
			body_lines.append(-1)
			continue
		# 找 func 后的 ":" 后第一个 \n (body 起点)
		var colon_idx := src.find(":", idx)
		if colon_idx == -1:
			body_lines.append(-1)
			continue
		var body_start := src.find("\n", colon_idx)
		if body_start == -1:
			body_lines.append(-1)
			continue
		body_start += 1  # 跳过 \n 到 body 第一行
		# 向下数连续缩进入 body 的行
		var line_count := 0
		var k := body_start
		while k < src.length():
			var line_end_k := src.find("\n", k)
			if line_end_k == -1:
				line_end_k = src.length()
			var line: String = src.substr(k, line_end_k - k)
			# 检查缩进: 第一个非空字符是 tab/space 还是其他
			if line.length() == 0 or line.strip_edges().length() == 0:
				# 空行, 跳过
				k = line_end_k + 1
				continue
			if line[0] == ' ' or line[0] == '\t':
				# 缩进行, 计入 body
				line_count += 1
			else:
				# 非缩进行, body 结束
				break
			k = line_end_k + 1
		body_lines.append(line_count)
	# 允许 ±5 行差异 (内嵌注释)
	var max_line: int = maxi(body_lines[0], maxi(body_lines[1], body_lines[2]))
	var min_line: int = mini(body_lines[0], mini(body_lines[1], body_lines[2]))
	if min_line > 0 and (max_line - min_line) <= 5:
		print("  3 autoload helper bodies have similar line count: %d/%d/%d (OK, ±5 tolerance)" % [body_lines[0], body_lines[1], body_lines[2]])
		pass_count += 1
	else:
		print("  FAIL: 3 autoload helper bodies have very different line count: save=%d game_state=%d player_stats=%d (diff=%d, >5)" % [body_lines[0], body_lines[1], body_lines[2], max_line - min_line])
		fail_count += 1

	# 8. I038.PROD_TRUE  3 autoload helper 注释都提到真游戏 autoload 总是存在
	#    (宽松匹配: "真游戏" / "生产" / "production" / "test resilience" / "test 环境" / "test 兜底"
	#    至少 1 项即可 — 不同 helper 措辞不同, 但语义都是"真游戏 autoload 永远在,
	#    null-guard 是 test resilience 兜底")
	for key in paths:
		var block: String = helper_blocks[key]
		var has_prod := false
		for keyword in ["真游戏", "生产", "production", "test resilience", "test 环境", "test 兜底", "test 典型", "test 场景"]:
			if block.find(keyword) != -1:
				has_prod = true
				break
		if has_prod:
			print("  %s helper block mentions production autoload always exists (OK)" % key)
			pass_count += 1
		else:
			print("  FAIL: %s helper block missing '真游戏' / '生产' / 'production' / 'test resilience' mention" % key)
			fail_count += 1

	print("")
	print("=== I038 F018.2 comment-sync smoke test %s (%d/%d assertions) ===" % [
		"FAILED" if fail_count > 0 else "PASSED",
		pass_count, pass_count + fail_count
	])
	if fail_count > 0:
		quit(1)
	else:
		quit(0)
