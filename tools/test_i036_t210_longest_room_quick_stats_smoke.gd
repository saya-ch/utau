extends SceneTree
## I036 (#129) — T210 ProfileQuickStats 顶级 summary 行加 "最长单房" 缩略
##
## 覆盖 #129 主任务 T210。 验证 QuickStats 行从 3 段扩到 4 段聚合 (T209
## #128 顶级行 LongestRoom 落地后, QuickStats 顶级 summary 行 0 同步):
##   (1) pause_menu.gd._refresh_quick_stats 写 "★ 成就 N/N  ·  最佳 mm:ss
##        ·  最长单房 mm:ss  ·  Run #N ★" 4 段
##   (2) QuickStats 行的 "最长单房" 段颜色 #65506A (Muted Violet), 与 3 段
##        (成就/最佳/Run#) 区分, 4 段 4 色 palette 全开
##   (3) QuickStats 行的 mm:ss 用 %02d:%02d 格式, 与 _profile_longest_room
##        顶级行 (T209) / _profile_best_streak 顶级行 (T201) 完全同款
##   (4) n=0 (无 longest room 历史) 路径用 "—" 占位, 与 QuickStats 自身
##        best_time / 顶级行 LongestRoom 风格完全一致
##   (5) 数据源: PlayerStats.get_best_stats()["longest_room_seconds"],
##        T210 加注释说明与 T209 顶级行共用 1 个数据源
##   (6) 注释锚点 T210 (#129) 留痕
##   (7) 回归覆盖: T201 (BestStreak) / T209 (LongestRoom top row) 顶级行
##        未被 T210 误改
##   (8) 回归覆盖: T201 (AvgResonance) 顶级行未被 T210 误改
##
## 三类断言:
##
## === T210.QUICK — pause_menu.gd ProfileQuickStats 顶级 summary 行 ===
## - T210.QUICK.4_FIELDS: 行含 "★" 起始 + "★" 结束 + 4 段 ("成就"/"最佳"
##                       /"最长单房"/"Run #") + 3 个 "·" 分隔
## - T210.QUICK.LONGEST_LABEL: 行含 "最长单房" (中文字面量)
## - T210.QUICK.MUTED_VIOLET: "最长单房" 段颜色 #65506A (Muted Violet)
##                            与 3 段 (#69C7CE/#F2B66E/#B7E6DC) 区分
## - T210.QUICK.MMSS_FORMAT: "最长单房" 段用 %02d:%02d mm:ss 格式
## - T210.QUICK.EM_DASH_FALLBACK: n=0 路径 set "—" 占位
## - T210.QUICK.DATA_SRC: 读 PlayerStats.get_best_stats()
##                        ["longest_room_seconds"] 数据源
## - T210.QUICK.ANCHOR: 注释含 T210 锚点
##
## === T210.REGRESS_TOP — 顶级 3 行 (T201 + T209) 回归 ===
## - T210.REGRESS_TOP.AVG_LABEL:  顶级行 "★ 平均共鸣" 仍存在
## - T210.REGRESS_TOP.BEST_LABEL: 顶级行 "★ 最佳单局" 仍存在
## - T210.REGRESS_TOP.LONG_LABEL: 顶级行 "★ 最长单房" (T209) 仍存在
## - T210.REGRESS_TOP.CYAN_COLOR: 3 顶级行 Glass Cyan #69C7CE 仍 OK
##                                (T210 QuickStats 改了 Muted Violet 不影响)
##
## === T210.QUICK_FORMAT — mm:ss 格式与 QuickStats 自身 best_time 一致 ===
## - T210.QUICK_FORMAT.BEST_FORMAT: QuickStats 自身 "最佳" 段仍用 %02d:%02d
## - T210.QUICK_FORMAT.LONG_FORMAT: QuickStats 自身 "最长单房" 段用 %02d:%02d
##                                  (与 "最佳" 段格式一致 — 4 段时间统一)

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I036 (#129) — T210 ProfileQuickStats LongestRoom QuickStats 冒烟测试 ===")
	_run_t210_quick_assertions()
	_run_t210_regress_top_assertions()
	_run_t210_quick_format_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I036 (#129) T210 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T210.QUICK — pause_menu.gd ProfileQuickStats 顶级 summary 行 ----------
func _run_t210_quick_assertions() -> void:
	print("--- T210.QUICK — pause_menu.gd ProfileQuickStats 顶级 summary 行 ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# 4 段聚合: T217 (#138) 旧版 1 Label 4 BBCode 段 1 行 → 4 sub-Label 各 1 段
	# (HBoxContainer 内 4 sub-Label + 3 sep 静态 Label + 2 star 静态 Label 居中).
	# 4 sub-Label 1 段独立 text setter (成就 %d / %d / 最佳 %s / 最长单房 %s /
	# Run #%d) + 4 段 4 色 theme_override (Glass Cyan / Amber Voice / Muted
	# Violet / Pale Resonance). 旧版 1 行 string literal "★ 成就 ...  ·  最佳 ...
	# ·  最长单房 ... ·  Run # ... ★" 完全废弃 (1 Label BBCode 路径 0 保留).
	_assert_contains(gd, "_quick_stats_achievement.text = \"成就 %d / %d\"",
		"T210.QUICK.4_FIELDS.1: QuickStats Achievement sub-Label 1 段独立 setter (1/4)")
	_assert_contains(gd, "_quick_stats_best_time.text = \"最佳 %s\"",
		"T210.QUICK.4_FIELDS.2: QuickStats BestTime sub-Label 1 段独立 setter (2/4)")
	_assert_contains(gd, "_quick_stats_longest_room.text = \"最长单房 %s\"",
		"T210.QUICK.4_FIELDS.3: QuickStats LongestRoom sub-Label 1 段独立 setter (3/4)")

	# 4 段聚合完整 setter — T217 后 4 sub-Label text setter 4 段全部就位
	_assert_contains(gd, "_quick_stats_run_number.text = \"Run #%d\"",
		"T210.QUICK.4_FIELDS.4: QuickStats RunNumber sub-Label 1 段独立 setter (4/4)")

	# T217 (#138) 旧版 BBCode 4 段 1 行 string literal 废弃验证 (1 Label
	# "★ [color=#69C7CE]成就 ... ★" 完整 literal 0 出现在 pause_menu.gd)
	var old_literal_count := gd.count("★ [color=#69C7CE]成就 %d / %d[/color]  ·  最佳 [color=#F2B66E]%s[/color]  ·  最长单房 [color=#65506A]%s[/color]  ·  Run #[color=#B7E6DC]%d[/color] ★")
	if old_literal_count == 0:
		_passes += 1
		print("  OK  T210.QUICK.LITERAL.1: T217 旧版 1 BBCode literal 废弃 (旧 4 段 1 行 string 0 保留, 4 sub-Label 拆完 0 残留)")
	else:
		_failures.append("FAIL: T210.QUICK.LITERAL.1: T217 旧版 1 BBCode literal 仍残留 %d 次 (应 0)" % old_literal_count)

	# 中文字面量 "最长单房" 至少出现 1 次 (QuickStats 行)
	var longest_label_count := gd.count("最长单房")
	if longest_label_count >= 1:
		_passes += 1
		print("  OK  T210.QUICK.LONGEST_LABEL.1: '最长单房' 出现 %d 次 (QuickStats + 顶级行)" % longest_label_count)
	else:
		_failures.append("FAIL: T210.QUICK.LONGEST_LABEL.1: '最长单房' 出现 0 次")

	# Muted Violet #65506A 颜色: T217 (#138) 1 Label BBCode 颜色 token 废弃,
	# 4 段 4 色 0 全部走 tscn theme_override_colors/font_color 4 sub-Label 独立
	# 设. 验证 tscn 4 段 4 色 (Glass Cyan / Amber Voice / Muted Violet / Pale
	# Resonance) 4 段独立存在, _longest_room 段 (QuickStatsLongestRoom
	# sub-Label) 颜色 = Color(0.4, 0.314, 0.416, 1) = Muted Violet #65506A
	# (T210 #129 新增的 4 段 4 色 palette 第 3 段 0 触碰).
	var tscn := _read_file("res://src/scenes/pause_menu.tscn")
	_assert_contains(tscn, "Color(0.4, 0.314, 0.416, 1)",
		"T210.QUICK.MUTED_VIOLET.1: QuickStats '最长单房' sub-Label tscn theme_override Muted Violet #65506A (T210 4 段 4 色 palette 第 3 段, T217 0 触碰)")
	# 顺带验证 4 段 4 色 tscn 全齐 (Glass Cyan / Amber Voice / Muted Violet / Pale Resonance)
	_assert_contains(tscn, "Color(0.412, 0.78, 0.808, 1)",
		"T210.QUICK.MUTED_VIOLET.2: tscn 4 段 4 色 第 1 段 Glass Cyan #69C7CE QuickStatsAchievement sub-Label 颜色就位")
	_assert_contains(tscn, "Color(0.949, 0.714, 0.431, 1)",
		"T210.QUICK.MUTED_VIOLET.3: tscn 4 段 4 色 第 2 段 Amber Voice #F2B66E QuickStatsBestTime sub-Label 颜色就位")
	_assert_contains(tscn, "Color(0.718, 0.906, 0.867, 1)",
		"T210.QUICK.MUTED_VIOLET.4: tscn 4 段 4 色 第 4 段 Pale Resonance #B7E6DC QuickStatsRunNumber sub-Label 颜色就位")

	# mm:ss 格式 (QuickStats 自身 longest room 段)
	# T210 写: longest_room_str = "%02d:%02d" % [qlm, qls]
	_assert_contains(gd, "longest_room_str = \"%02d:%02d\" % [qlm, qls]",
		"T210.QUICK.MMSS_FORMAT.1: QuickStats '最长单房' 段用 %02d:%02d mm:ss 格式")

	# "—" 占位 (n=0 fallback path)
	_assert_contains(gd, "\t\tlongest_room_str = \"—\"",
		"T210.QUICK.EM_DASH_FALLBACK.1: QuickStats '最长单房' 段 n=0 路径 '—' 占位")

	# 数据源: PlayerStats.get_best_stats() + longest_room_seconds
	_assert_contains(gd, "PlayerStats.get_best_stats()",
		"T210.QUICK.DATA_SRC.1: QuickStats 读 PlayerStats.get_best_stats()")
	_assert_contains(gd, "quick_best.get(\"longest_room_seconds\", 0.0)",
		"T210.QUICK.DATA_SRC.2: QuickStats 读 _best_stats[\"longest_room_seconds\"]")

	# 注释锚点
	_assert_contains(gd, "T210",
		"T210.QUICK.ANCHOR.1: pause_menu.gd 注释含 T210 锚点 (可读性)")


# ---------- T210.REGRESS_TOP — 顶级 3 行 (T201 + T209) 回归 ----------
func _run_t210_regress_top_assertions() -> void:
	print("--- T210.REGRESS_TOP — 顶级 3 行 (T201 + T209) 回归 ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# 顶级行 "平均共鸣" (T201) 仍存在
	_assert_contains(gd, "★ 平均共鸣",
		"T210.REGRESS_TOP.AVG_LABEL.1: 顶级行 '★ 平均共鸣' (T201) 仍存在 (T210 未误改)")
	# 顶级行 "最佳单局" (T201) 仍存在
	_assert_contains(gd, "★ 最佳单局",
		"T210.REGRESS_TOP.BEST_LABEL.1: 顶级行 '★ 最佳单局' (T201) 仍存在 (T210 未误改)")
	# 顶级行 "最长单房" (T209) 仍存在
	_assert_contains(gd, "★ 最长单房",
		"T210.REGRESS_TOP.LONG_LABEL.1: 顶级行 '★ 最长单房' (T209) 仍存在 (T210 未误改)")

	# 顶级 3 行的 — 占位仍然 3 处 (T201 AvgResonance + T201 BestStreak +
	# T209 LongestRoom, 仍各 1 处 — 占位)
	# T201 AvgResonance empty 占位: "★ 平均共鸣 —  ★"
	_assert_contains(gd, "\"★ 平均共鸣 —  ★\"",
		"T210.REGRESS_TOP.AVG_EMPTY.1: 顶级 AvgResonance '★ 平均共鸣 —  ★' 仍存在")
	# T201 BestStreak empty 占位: "★ 最佳单局 —  ★"
	_assert_contains(gd, "\"★ 最佳单局 —  ★\"",
		"T210.REGRESS_TOP.BEST_EMPTY.1: 顶级 BestStreak '★ 最佳单局 —  ★' 仍存在")
	# T209 LongestRoom empty 占位: "—  ★"
	# (注: QuickStats 自身的 n=0 也是 "—", 但 T209 顶级行的 empty 字符串
	# literal 是 "★ 最长单房 —  ★"  多了 2 个空格)
	var top_longest_empty_count := gd.count("\"★ 最长单房 —  ★\"")
	if top_longest_empty_count >= 1:
		_passes += 1
		print("  OK  T210.REGRESS_TOP.LONG_EMPTY.1: 顶级 LongestRoom empty 占位 literal 仍存在 (count=%d)" % top_longest_empty_count)
	else:
		_failures.append("FAIL: T210.REGRESS_TOP.LONG_EMPTY.1: 顶级 LongestRoom empty 占位 literal 不存在")

	# Cyan color #69C7CE (Glass Cyan) 在 3 顶级行仍是主色
	# (T210 QuickStats 改 Muted Violet 不影响顶级行)
	# 顶级 AvgResonance 注释 (n>0 路径)
	# 实际格式: "★ 平均共鸣 — %.1f 碎/房 (n=%d) ★"  (1 位小数, 非 "X.XX")
	_assert_contains(gd, "\"★ 平均共鸣 — %.1f 碎/房 (n=%d) ★\"",
		"T210.REGRESS_TOP.AVG_NFMT.1: 顶级 AvgResonance '★ 平均共鸣 — %.1f 碎/房 (n=%d) ★' literal 仍存在")

	# 顶级 BestStreak 完整 literal (n>0)
	# 实际格式: "★ 最佳单局 #%d — %d 房 %d 净 %d 碎 %02d:%02d ★"
	# (注: "%02d:%02d" 是 mm:ss, 不是 "%d:%02d:%02d" 的 h:mm:ss — 平均房局
	#  单局时长通常 < 60min, 玩家不需要 3 段. BestStreak 与 LongestRoom
	#  顶级行 mm:ss 段格式同款)
	_assert_contains(gd, "\"★ 最佳单局 #%d — %d 房 %d 净 %d 碎 %02d:%02d ★\"",
		"T210.REGRESS_TOP.BEST_NFMT.1: 顶级 BestStreak 完整 literal 仍存在 (mm:ss 2 段)")

	# 顶级 LongestRoom 完整 literal (n>0) — 沿用 T209 格式
	_assert_contains(gd, "\"★ 最长单房 %02d:%02d ★\"",
		"T210.REGRESS_TOP.LONG_NFMT.1: 顶级 LongestRoom 'mm:ss' literal 仍存在 (T209 格式)")

	# 顶级 2 行 mm:ss 格式仍 ≥ 2 处 (BestStreak + LongestRoom 顶级行)
	# BestStreak: "★ 最佳单局 #%d — %d 房 %d 净 %d 碎 %02d:%02d ★"
	# LongestRoom: "★ 最长单房 %02d:%02d ★"
	# 共 2 处 mm:ss literal
	var top_best_mmss_count := gd.count("\"★ 最佳单局 #%d — %d 房 %d 净 %d 碎 %02d:%02d ★\"")
	var top_long_mmss_count := gd.count("\"★ 最长单房 %02d:%02d ★\"")
	var top_mmss_count := top_best_mmss_count + top_long_mmss_count
	if top_mmss_count >= 2:
		_passes += 1
		print("  OK  T210.REGRESS_TOP.MMSS.1: 顶级 2 mm:ss 格式 (BestStreak + LongestRoom) 仍存在 (count=%d)" % top_mmss_count)
	else:
		_failures.append("FAIL: T210.REGRESS_TOP.MMSS.1: 顶级 2 mm:ss 格式数量异常 (count=%d, 期望 >= 2)" % top_mmss_count)


# ---------- T210.QUICK_FORMAT — QuickStats 自身 mm:ss 格式一致 ----------
func _run_t210_quick_format_assertions() -> void:
	print("--- T210.QUICK_FORMAT — QuickStats 自身 mm:ss 格式一致 ---")
	var gd := _read_file(PAUSE_MENU_GD)

	# QuickStats 自身 "最佳" 段 mm:ss 格式 (T133 落地, 此次不动)
	_assert_contains(gd, "best_time_str = \"%02d:%02d\" % [qbm, qbs]",
		"T210.QUICK_FORMAT.BEST_FORMAT.1: QuickStats '最佳' 段 mm:ss %02d:%02d 格式仍存在 (T133 落地)")

	# QuickStats 自身 "最长单房" 段 mm:ss 格式 (T210 新增)
	_assert_contains(gd, "longest_room_str = \"%02d:%02d\" % [qlm, qls]",
		"T210.QUICK_FORMAT.LONG_FORMAT.1: QuickStats '最长单房' 段 mm:ss %02d:%02d 格式 (T210 新增, 与 '最佳' 段一致)")

	# QuickStats 自身 "—" 占位 2 处 (最佳 + 最长单房 各 1 处)
	var em_dash_count := gd.count("best_time_str = \"—\"") + gd.count("longest_room_str = \"—\"")
	if em_dash_count >= 2:
		_passes += 1
		print("  OK  T210.QUICK_FORMAT.EM_DASH.1: QuickStats 自身 '—' 占位 2 处 (最佳 + 最长单房 各 1 处, count=%d)" % em_dash_count)
	else:
		_failures.append("FAIL: T210.QUICK_FORMAT.EM_DASH.1: QuickStats 自身 '—' 占位数量异常 (count=%d, 期望 >= 2)" % em_dash_count)


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
	print("I036 (#129) T210 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
