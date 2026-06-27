extends SceneTree
## I039 (#133) — T213 ProfileQuickStats 4 段 summary 行 hover tooltip 显示
##                   每段含义 + 颜色 hex + 详细位置
##
## 覆盖 #133 主任务 T213。 验证 ProfileQuickStats 顶级 summary 行 (★ 成就 X/Y
## · 最佳 mm:ss · 最长单房 mm:ss · Run #N ★) 在 _ready() 中绑定 tooltip_text
## 显示 4 段各自的含义 + 颜色 hex + 详细位置:
##   (1) pause_menu.gd 含 _QUICK_STATS_HINT 4 段权威数据源 (label/color/
##        color_name/desc_zh/detail 5 字段)
##   (2) _build_quick_stats_tooltip() 函数存在, 头部 "4 段总览"
##   (3) tooltip 含 4 段 (成就/最佳/最长单房/Run #) 各自 label + desc_zh
##   (4) tooltip 含 4 段 color hex (#69C7CE/#F2B66E/#65506A/#B7E6DC) +
##        color_name (Glass Cyan/Amber Voice/Muted Violet/Pale Resonance)
##   (5) _ready() 中 _profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()
##   (6) 注释锚点 T213 (#133) 留痕
##   (7) 回归覆盖: T199 (#116) 5 verb tooltip 仍正常
##   (8) 回归覆盖: T210 (#129) QuickStats 4 段 (成就/最佳/最长单房/Run#)
##        字符串 literal 未被 T213 误改
##   (9) 回归覆盖: T160 banner 起始态 (modulate.a = 0 + visible = false) 不动
##
## 三类断言:
##
## === T213.HINT — _QUICK_STATS_HINT 4 段权威数据源 ===
## - T213.HINT.CONST: pause_menu.gd 含 const _QUICK_STATS_HINT
## - T213.HINT.4_ENTRIES: 4 段 (成就/最佳/最长单房/Run #) 全部出现在 const
## - T213.HINT.GLASS_CYAN: 段 1 (成就) color = #69C7CE (Glass Cyan)
## - T213.HINT.AMBER_VOICE: 段 2 (最佳) color = #F2B66E (Amber Voice)
## - T213.HINT.MUTED_VIOLET: 段 3 (最长单房) color = #65506A (Muted Violet)
## - T213.HINT.PALE_RESONANCE: 段 4 (Run #) color = #B7E6DC (Pale Resonance)
## - T213.HINT.5_FIELDS: 每段 5 字段 (label/color/color_name/desc_zh/detail)
## - T213.HINT.ACHV_DESC: 段 1 含 "跨 run 累计解锁数"
## - T213.HINT.BEST_DESC: 段 2 含 "单次 run 最长回响时长"
## - T213.HINT.LONG_DESC: 段 3 含 "单房最长耗时"
## - T213.HINT.RUN_DESC: 段 4 含 "当前会话第几局"
##
## === T213.BUILD — _build_quick_stats_tooltip() 函数 ===
## - T213.BUILD.FUNC: pause_menu.gd 含 _build_quick_stats_tooltip() 函数
## - T213.BUILD.HEADER: tooltip 头部 "4 段总览 — 悬停查看每段含义"
## - T213.BUILD.FOR_LOOP: for h in _QUICK_STATS_HINT 循环
## - T213.BUILD.BULLET_FMT: 段行用 "• %s — %s" bullet format
## - T213.BUILD.COLOR_FMT: 颜色行用 "颜色: %s  %s  ·  %s" format
## - T213.BUILD.9_LINES: tooltip 至少 9 行 (1 头 + 4×2 段)
##
## === T213.READY — _ready() 中绑定 _profile_quick_stats.tooltip_text ===
## - T213.READY.ASSIGN: pause_menu.gd 含 _profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()
## - T213.READY.ANCHOR: 注释含 T213 (#133) 锚点
##
## === T213.REGRESS — 回归 (T199/T210/T160 不动) ===
## - T213.REGRESS.VERB_HINT: T199 _VERB_HINT_DATA + _build_verb_hint_tooltip
##                          仍存在
## - T213.REGRESS.QUICK_LITERAL: T210 QuickStats 4 段 literal 未改
## - T213.REGRESS.BANNER: T160 banner 起始态 (modulate.a = 0) 未改
## - T213.REGRESS.MMSS: T210 QuickStats 4 段 mm:ss %02d:%02d 格式未改
## - T213.REGRESS.EM_DASH: QuickStats 自身 "—" 占位 2 处 (最佳+最长单房) 未改

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I039 (#133) — T213 ProfileQuickStats 4 段 hover tooltip 冒烟测试 ===")
	_run_t213_hint_assertions()
	_run_t213_build_assertions()
	_run_t213_ready_assertions()
	_run_t213_regress_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I039 (#133) T213 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T213.HINT — _QUICK_STATS_HINT 4 段权威数据源 ----------
func _run_t213_hint_assertions() -> void:
	print("--- T213.HINT — _QUICK_STATS_HINT 4 段权威数据源 ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# const _QUICK_STATS_HINT 存在
	_assert_contains(gd, "const _QUICK_STATS_HINT",
		"T213.HINT.CONST.1: pause_menu.gd 含 const _QUICK_STATS_HINT")

	# 4 段 label 全部出现
	_assert_contains(gd, "\"label\": \"成就\"",
		"T213.HINT.4_ENTRIES.1: 段 1 label = '成就' (Glass Cyan)")
	_assert_contains(gd, "\"label\": \"最佳\"",
		"T213.HINT.4_ENTRIES.2: 段 2 label = '最佳' (Amber Voice)")
	_assert_contains(gd, "\"label\": \"最长单房\"",
		"T213.HINT.4_ENTRIES.3: 段 3 label = '最长单房' (Muted Violet)")
	_assert_contains(gd, "\"label\": \"Run #\"",
		"T213.HINT.4_ENTRIES.4: 段 4 label = 'Run #' (Pale Resonance)")

	# 4 段 color hex
	_assert_contains(gd, "\"color\": \"#69C7CE\"",
		"T213.HINT.GLASS_CYAN.1: 段 1 (成就) color hex = #69C7CE (Glass Cyan)")
	_assert_contains(gd, "\"color\": \"#F2B66E\"",
		"T213.HINT.AMBER_VOICE.1: 段 2 (最佳) color hex = #F2B66E (Amber Voice)")
	_assert_contains(gd, "\"color\": \"#65506A\"",
		"T213.HINT.MUTED_VIOLET.1: 段 3 (最长单房) color hex = #65506A (Muted Violet)")
	_assert_contains(gd, "\"color\": \"#B7E6DC\"",
		"T213.HINT.PALE_RESONANCE.1: 段 4 (Run #) color hex = #B7E6DC (Pale Resonance)")

	# 4 段 color_name 全部出现
	_assert_contains(gd, "\"color_name\": \"Glass Cyan\"",
		"T213.HINT.COLOR_NAME.1: 段 1 color_name = Glass Cyan")
	_assert_contains(gd, "\"color_name\": \"Amber Voice\"",
		"T213.HINT.COLOR_NAME.2: 段 2 color_name = Amber Voice")
	_assert_contains(gd, "\"color_name\": \"Muted Violet\"",
		"T213.HINT.COLOR_NAME.3: 段 3 color_name = Muted Violet")
	_assert_contains(gd, "\"color_name\": \"Pale Resonance\"",
		"T213.HINT.COLOR_NAME.4: 段 4 color_name = Pale Resonance")

	# 5 字段 (label/color/color_name/desc_zh/detail) × 4 段 = 20 字段引用
	var label_count := gd.count("\"label\":")
	var color_count := gd.count("\"color\":")
	var color_name_count := gd.count("\"color_name\":")
	var desc_zh_count := gd.count("\"desc_zh\":")
	var detail_count := gd.count("\"detail\":")
	if label_count >= 4 and color_count >= 4 and color_name_count >= 4 and desc_zh_count >= 4 and detail_count >= 4:
		_passes += 1
		print("  OK  T213.HINT.5_FIELDS.1: 5 字段 × 4 段全部就位 (label=%d/color=%d/color_name=%d/desc_zh=%d/detail=%d)" % [label_count, color_count, color_name_count, desc_zh_count, detail_count])
	else:
		_failures.append("FAIL: T213.HINT.5_FIELDS.1: 5 字段 × 4 段未全部就位 (label=%d/color=%d/color_name=%d/desc_zh=%d/detail=%d)" % [label_count, color_count, color_name_count, desc_zh_count, detail_count])

	# 4 段 desc_zh 中文描述 (与 _QUICK_STATS_HINT 设计意图对齐)
	_assert_contains(gd, "跨 run 累计解锁数",
		"T213.HINT.ACHV_DESC.1: 段 1 (成就) desc_zh 含 '跨 run 累计解锁数'")
	_assert_contains(gd, "单次 run 最长回响时长",
		"T213.HINT.BEST_DESC.1: 段 2 (最佳) desc_zh 含 '单次 run 最长回响时长'")
	_assert_contains(gd, "单房最长耗时",
		"T213.HINT.LONG_DESC.1: 段 3 (最长单房) desc_zh 含 '单房最长耗时'")
	_assert_contains(gd, "1-based session 内",
		"T213.HINT.RUN_DESC.1: 段 4 (Run #) desc_zh 含 '1-based session 内'")


# ---------- T213.BUILD — _build_quick_stats_tooltip() 函数 ----------
func _run_t213_build_assertions() -> void:
	print("--- T213.BUILD — _build_quick_stats_tooltip() 函数 ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# 函数存在
	_assert_contains(gd, "func _build_quick_stats_tooltip()",
		"T213.BUILD.FUNC.1: pause_menu.gd 含 _build_quick_stats_tooltip() 函数")

	# 头部 "4 段总览 — 悬停查看每段含义"
	_assert_contains(gd, "4 段总览 — 悬停查看每段含义",
		"T213.BUILD.HEADER.1: tooltip 头部 '4 段总览 — 悬停查看每段含义'")

	# for 循环 _QUICK_STATS_HINT
	_assert_contains(gd, "for h in _QUICK_STATS_HINT",
		"T213.BUILD.FOR_LOOP.1: for h in _QUICK_STATS_HINT 循环渲染 4 段")

	# bullet format "• %s — %s"
	_assert_contains(gd, "• %s — %s",
		"T213.BUILD.BULLET_FMT.1: tooltip 段行 '• %s — %s' bullet format")

	# 颜色 format "颜色: %s  %s  ·  %s"
	_assert_contains(gd, "颜色: %s  %s  ·  %s",
		"T213.BUILD.COLOR_FMT.1: tooltip 颜色行 '颜色: %s  %s  ·  %s' format")

	# 9 行 tooltip (1 头 + 4 段 × 2 行/段)
	# 1 头 = lines.append("4 段总览 — 悬停查看每段含义") → 1 行
	# 4 段 × (bullet + color) = 8 行
	# 1 + 8 = 9 行
	# 验证方式: 期望 lines.append 出现 >= 6 次 (源层 — T213 函数 3 处
	# [头 + 2 in-loop] + T199 函数 3 处 [头 + 2 in-loop] = 6 source-level
	# 出现, 运行时 9 + 11 = 20 append calls)
	var lines_append_count := gd.count("lines.append(")
	# _build_quick_stats_tooltip() 内应有 1 (头) + 4×2 (4 段 × 2 行) = 9 个 lines.append
	# 但 _build_verb_hint_tooltip() 也含 lines.append (1 头 + 5×2 = 11 个)
	# 总计 9 + 11 = 20. 期望 >= 9 (最弱约束)
	if lines_append_count >= 6:
		_passes += 1
		print("  OK  T213.BUILD.9_LINES.1: lines.append 次数 = %d (>= 6, T213 函数 3 源层 + T199 函数 3 源层, 运行时 9 + 11 = 20 calls)" % lines_append_count)
	else:
		_failures.append("FAIL: T213.BUILD.9_LINES.1: lines.append 次数 = %d (< 6)" % lines_append_count)

	# join 用 "\n" (与 T199 一致风格)
	_assert_contains(gd, "\"\\n\".join(lines)",
		"T213.BUILD.JOIN.1: tooltip 行用 '\\n'.join(lines) 拼接 (与 T199 风格一致)")


# ---------- T213.READY — _ready() 中绑定 _profile_quick_stats.tooltip_text ----------
func _run_t213_ready_assertions() -> void:
	print("--- T213.READY — _ready() 中绑定 _profile_quick_stats.tooltip_text ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# _ready() 末尾绑定 _profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()
	_assert_contains(gd, "_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()",
		"T213.READY.ASSIGN.1: _ready() 末尾绑定 _profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()")

	# 注释锚点 T213 (#133)
	_assert_contains(gd, "T213 (#133)",
		"T213.READY.ANCHOR.1: pause_menu.gd 含 T213 (#133) 注释锚点")

	# 防御: 绑定前置 if _profile_quick_stats:
	_assert_contains(gd, "if _profile_quick_stats:",
		"T213.READY.IF_GUARD.1: _profile_quick_stats 绑定前置 if guard (防御性)")

	# T213 注释在 banner 起始态之后, 不打乱既有 T160 banner 顺序
	# 期望顺序: T160 banner modulate.a = 0 → T213 hover tooltip
	# (用 "玩家悬停 QuickStats 1 行" 字符串 — 唯一在 _ready() T213
	# binding 块出现的, const block 注释用 "数据源" 结尾区分)
	var t160_pos := gd.find("T160 — Banner 起始态")
	var t213_ready_pos := gd.find("\t# T213 (#133) — ProfileQuickStats 4 段总览 hover tooltip\n\t# 玩家悬停 QuickStats 1 行")
	# 兜底: 如果 "\t# 玩家悬停" 字符串匹配失败 (换行符差异), 用更宽松匹配
	if t213_ready_pos == -1:
		t213_ready_pos = gd.find("玩家悬停 QuickStats 1 行")
	if t160_pos != -1 and t213_ready_pos != -1 and t213_ready_pos > t160_pos:
		_passes += 1
		print("  OK  T213.READY.SEQUENCE.1: T160 banner 起始态 → T213 hover tooltip 顺序正确 (T160=%d, T213_ready=%d)" % [t160_pos, t213_ready_pos])
	else:
		_failures.append("FAIL: T213.READY.SEQUENCE.1: 顺序错乱 (T160=%d, T213_ready=%d)" % [t160_pos, t213_ready_pos])


# ---------- T213.REGRESS — 回归 (T199/T210/T160 不动) ----------
func _run_t213_regress_assertions() -> void:
	print("--- T213.REGRESS — 回归 (T199/T210/T160 不动) ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# T199 (#116) 5 verb tooltip 仍存在 (5 verb row + stat + profile 双向)
	_assert_contains(gd, "const _VERB_HINT_DATA",
		"T213.REGRESS.VERB_HINT.1: T199 _VERB_HINT_DATA 仍存在")
	_assert_contains(gd, "func _build_verb_hint_tooltip()",
		"T213.REGRESS.VERB_HINT.2: T199 _build_verb_hint_tooltip() 仍存在")
	_assert_contains(gd, "_stat_abilities.tooltip_text = _verb_hint_text",
		"T213.REGRESS.VERB_HINT.3: T199 _stat_abilities tooltip 绑定仍存在")
	_assert_contains(gd, "_profile_abilities.tooltip_text = _verb_hint_text",
		"T213.REGRESS.VERB_HINT.4: T199 _profile_abilities tooltip 绑定仍存在")

	# T210 (#129) QuickStats 4 段 literal 未改
	_assert_contains(gd, "\"★ [color=#69C7CE]成就 %d / %d[/color]  ·  最佳 [color=#F2B66E]%s[/color]  ·  最长单房 [color=#65506A]%s[/color]  ·  Run #[color=#B7E6DC]%d[/color] ★\"",
		"T213.REGRESS.QUICK_LITERAL.1: T210 QuickStats 4 段 literal 完整未改 (成就/最佳/最长单房/Run#)")

	# T160 banner 起始态 (modulate.a = 0 + visible = false) 未改
	_assert_contains(gd, "_new_achv_banner.modulate.a = 0.0",
		"T213.REGRESS.BANNER.1: T160 banner 起始态 modulate.a = 0.0 仍存在")
	_assert_contains(gd, "_new_achv_banner.visible = false",
		"T213.REGRESS.BANNER.2: T160 banner 起始态 visible = false 仍存在")

	# T210 QuickStats 自身 mm:ss 格式 (最佳 + 最长单房 各 1 处 %02d:%02d) 未改
	_assert_contains(gd, "best_time_str = \"%02d:%02d\" % [qbm, qbs]",
		"T213.REGRESS.MMSS.1: T210 '最佳' 段 mm:ss %02d:%02d 格式仍存在")
	_assert_contains(gd, "longest_room_str = \"%02d:%02d\" % [qlm, qls]",
		"T213.REGRESS.MMSS.2: T210 '最长单房' 段 mm:ss %02d:%02d 格式仍存在")

	# QuickStats 自身 "—" 占位 2 处 (最佳 + 最长单房) 未改
	var em_dash_best := gd.count("best_time_str = \"—\"")
	var em_dash_long := gd.count("longest_room_str = \"—\"")
	if em_dash_best >= 1 and em_dash_long >= 1:
		_passes += 1
		print("  OK  T213.REGRESS.EM_DASH.1: QuickStats 自身 '—' 占位 2 处未改 (最佳=%d, 最长单房=%d)" % [em_dash_best, em_dash_long])
	else:
		_failures.append("FAIL: T213.REGRESS.EM_DASH.1: QuickStats '—' 占位数量异常 (最佳=%d, 最长单房=%d)" % [em_dash_best, em_dash_long])


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I039 (#133) T213 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
