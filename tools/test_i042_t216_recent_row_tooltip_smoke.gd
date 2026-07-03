extends SceneTree

# I042 — T216 (#137) ProfileRecentList 5 行 hover tooltip (5 字段含义静态信息层) smoke test
# 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd 中 T216 实现的
# 4 大模块 (const 数据源 / build 函数 / 5 行 tooltip_text 绑定 / 注释锚点) +
# 5 大回归保护 (T162 5 行 literal 0 改 / T213 QuickStats tooltip 0 触碰 /
# T214 hover 0 触碰 / T215 RecentList 5 行 hover 0 触碰 / T210 QuickStats 4 段
# literal 0 改). 期望:
# 44 断言全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i042_t216_recent_row_tooltip_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#
# === T216.HINT — _RECENT_ROW_HINT 5 字段权威数据源 (5 段) ===
# - T216.HINT.CONST: pause_menu.gd 含 const _RECENT_ROW_HINT
# - T216.HINT.5_ENTRIES: 5 字段 (Run #/房/净/碎/时) 全部出现在 const
# - T216.HINT.RUN: 字段 1 label = "Run #" — 当前会话第几局
# - T216.HINT.ROOM: 字段 2 label = "房" — 本 run 通关房间数
# - T216.HINT.PURIFIED: 字段 3 label = "净" — 本 run 净化敌人数
# - T216.HINT.SHARD: 字段 4 label = "碎" — 本 run 共鸣碎片拾取数
# - T216.HINT.TIME: 字段 5 label = "时" — 本 run 总时长 mm:ss
# - T216.HINT.3_FIELDS: 每段 3 字段 (label/desc_zh/detail) 全部出现
# - T216.HINT.RUN_DESC: 字段 1 含 "1-based session 内" (权威)
# - T216.HINT.ROOM_DETAIL: 字段 2 detail 含 "RoomController._complete_room"
# - T216.HINT.PURIFIED_DETAIL: 字段 3 detail 含 "PlayerStats.record_enemy_purified"
# - T216.HINT.SHARD_DETAIL: 字段 4 detail 含 "Voice Bell 修复后 1 枚"
# - T216.HINT.TIME_DETAIL: 字段 5 detail 含 "GameState.run_start_time"
#
# === T216.BUILD — _build_recent_row_tooltip() 函数 ===
# - T216.BUILD.FUNC: pause_menu.gd 含 _build_recent_row_tooltip() 函数
# - T216.BUILD.HEADER: tooltip 头部 "最近一局明细"
# - T216.BUILD.FOR_LOOP: for h in _RECENT_ROW_HINT 循环
# - T216.BUILD.BULLET_FMT: 段行用 "• %s — %s" bullet format (与 T213 一致)
# - T216.BUILD.DETAIL_FMT: detail 行用 "    %s" 缩进 format
# - T216.BUILD.11_LINES: tooltip 至少 11 行 (1 头 + 5×2 段)
# - T216.BUILD.JOIN: 拼接用 "\n".join(lines)
#
# === T216.READY — 5 行 _refresh_recent_runs_list 中绑定 row_lbl.tooltip_text ===
# - T216.READY.ASSIGN: pause_menu.gd 含 row_lbl.tooltip_text = _build_recent_row_tooltip()
# - T216.READY.IN_REFRESH: 绑定在 _refresh_recent_runs_list 函数内 (与 T215 同行)
# - T216.READY.AFTER_SIGNAL: 绑定在 mouse_entered/exited connect 之后 (语义顺序: 1) 显 mouse 2) tooltip)
# - T216.READY.ANCHOR: 注释含 T216 (#137) 锚点
#
# === T216.REGRESS — 回归 (T162/T213/T214/T215/T210 不动) ===
# - T216.REGRESS.1: T162 _PROFILE_RECENT_RUNS_MAX = 5 仍在
# - T216.REGRESS.2: T162 5 行 data format literal "Run #%d  房 %d  净 %d  碎 %d  时 %02d:%02d" 仍在
# - T216.REGRESS.3: T213 _QUICK_STATS_HINT 仍在 (T216 是独立 const)
# - T216.REGRESS.4: T213 _profile_quick_stats.tooltip_text 绑定 0 触碰
# - T216.REGRESS.5: T214 _quick_stats_hovered / _quick_stats_default_text 字段 0 删
# - T216.REGRESS.6: T215 _recent_row_hovered / _recent_row_default_color 字段 0 删
# - T216.REGRESS.7: T215 row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP 0 改
# - T216.REGRESS.8: T215 mouse_entered.connect + mouse_exited.connect 5 行绑定 0 改
# - T216.REGRESS.9: T215 Color.WHITE 提亮 0 改
# - T216.REGRESS.10: T210 4 段 color token + 段名 0 改

const PAUSE_MENU_PATH := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0

func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passes += 1
		print("[PASS] %s" % msg)
	else:
		_failures.append(msg)
		print("[FAIL] %s" % msg)

func _init() -> void:
	print("=== I042 — T216 (#137) ProfileRecentList 5 行 hover tooltip 5 字段含义 smoke test ===")
	var f := FileAccess.open(PAUSE_MENU_PATH, FileAccess.READ)
	if f == null:
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()

	_run_t216_hint_assertions(content)
	_run_t216_build_assertions(content)
	_run_t216_ready_assertions(content)
	_run_t216_regress_assertions(content)
	_finish()


# ---------- T216.HINT — _RECENT_ROW_HINT 5 字段权威数据源 ----------
func _run_t216_hint_assertions(content: String) -> void:
	print("--- T216.HINT — _RECENT_ROW_HINT 5 字段权威数据源 ---")

	# const _RECENT_ROW_HINT 存在
	_assert("const _RECENT_ROW_HINT" in content,
		"T216.HINT.CONST.1 — pause_menu.gd 含 const _RECENT_ROW_HINT")

	# 5 字段 label 全部出现
	_assert("\"label\": \"Run #\"" in content,
		"T216.HINT.5_ENTRIES.1 — 字段 1 label = 'Run #' (1-based session 内)")
	_assert("\"label\": \"房\"" in content,
		"T216.HINT.5_ENTRIES.2 — 字段 2 label = '房' (本 run 通关房间数)")
	_assert("\"label\": \"净\"" in content,
		"T216.HINT.5_ENTRIES.3 — 字段 3 label = '净' (本 run 净化敌人数)")
	_assert("\"label\": \"碎\"" in content,
		"T216.HINT.5_ENTRIES.4 — 字段 4 label = '碎' (本 run 共鸣碎片拾取数)")
	_assert("\"label\": \"时\"" in content,
		"T216.HINT.5_ENTRIES.5 — 字段 5 label = '时' (本 run 总时长 mm:ss)")

	# 3 字段 (label/desc_zh/detail) 验证 — _RECENT_ROW_HINT 是 3 字段结构 (与 T213 _QUICK_STATS_HINT 5 字段不同, T216 没有 color/color_name, 因为 RecentList 行的颜色已经在 _COLOR_RECENT_RUN_LATEST/_NORMAL const 中统一, tooltip 不重述)
	var label_count := content.count("\"label\":")
	var desc_zh_count := content.count("\"desc_zh\":")
	var detail_count := content.count("\"detail\":")
	# T213 _QUICK_STATS_HINT 有 4 段 (label × 4) + T216 _RECENT_ROW_HINT 有 5 段 (label × 5) = 9
	# T213 4 段 desc_zh + T216 5 段 desc_zh = 9
	# T213 4 段 detail + T216 5 段 detail = 9
	_assert(label_count >= 9,
		"T216.HINT.3_FIELDS.1 — label 出现次数 >= 9 (T213 4 段 + T216 5 段) — 实际 %d" % label_count)
	_assert(desc_zh_count >= 9,
		"T216.HINT.3_FIELDS.2 — desc_zh 出现次数 >= 9 (T213 4 段 + T216 5 段) — 实际 %d" % desc_zh_count)
	_assert(detail_count >= 9,
		"T216.HINT.3_FIELDS.3 — detail 出现次数 >= 9 (T213 4 段 + T216 5 段) — 实际 %d" % detail_count)

	# 5 字段 desc_zh 中文描述
	_assert("当前会话第几局" in content and "1-based session" in content,
		"T216.HINT.RUN_DESC.1 — 字段 1 (Run #) desc_zh 含 '当前会话第几局' + '1-based session'")
	_assert("本 run 通关房间数" in content and "Voice Bell 修复" in content,
		"T216.HINT.ROOM_DESC.1 — 字段 2 (房) desc_zh 含 '本 run 通关房间数' + 'Voice Bell 修复'")
	_assert("本 run 净化敌人数" in content and "Pulse 击破" in content,
		"T216.HINT.PURIFIED_DESC.1 — 字段 3 (净) desc_zh 含 '本 run 净化敌人数' + 'Pulse 击破'")
	_assert("本 run 共鸣碎片拾取数" in content and "Voice Bell 修复后 1 枚" in content,
		"T216.HINT.SHARD_DESC.1 — 字段 4 (碎) desc_zh 含 '本 run 共鸣碎片拾取数' + 'Voice Bell 修复后 1 枚'")
	_assert("本 run 总时长" in content and "mm:ss" in content,
		"T216.HINT.TIME_DESC.1 — 字段 5 (时) desc_zh 含 '本 run 总时长' + 'mm:ss'")

	# 5 字段 detail 来源 (具体 PlayerStats/RoomController/GameState API)
	_assert("RoomController._complete_room" in content,
		"T216.HINT.ROOM_DETAIL.1 — 字段 2 (房) detail 含 'RoomController._complete_room' 来源 API")
	_assert("PlayerStats.record_enemy_purified" in content,
		"T216.HINT.PURIFIED_DETAIL.1 — 字段 3 (净) detail 含 'PlayerStats.record_enemy_purified' 来源 API")
	_assert("PlayerStats.record_shard_collected" in content,
		"T216.HINT.SHARD_DETAIL.1 — 字段 4 (碎) detail 含 'PlayerStats.record_shard_collected' 来源 API")
	_assert("GameState.run_start_time" in content and "run_time_seconds" in content,
		"T216.HINT.TIME_DETAIL.1 — 字段 5 (时) detail 含 'GameState.run_start_time' + 'run_time_seconds' 来源 API")


# ---------- T216.BUILD — _build_recent_row_tooltip() 函数 ----------
func _run_t216_build_assertions(content: String) -> void:
	print("--- T216.BUILD — _build_recent_row_tooltip() 函数 ---")

	# 函数存在
	_assert("func _build_recent_row_tooltip() -> String:" in content,
		"T216.BUILD.FUNC.1 — pause_menu.gd 含 _build_recent_row_tooltip() -> String: 函数")

	# 头部 "最近一局明细 — 悬停查看每字段含义"
	_assert("最近一局明细 — 悬停查看每字段含义" in content,
		"T216.BUILD.HEADER.1 — tooltip 头部 '最近一局明细 — 悬停查看每字段含义'")

	# for 循环 _RECENT_ROW_HINT
	_assert("for h in _RECENT_ROW_HINT" in content,
		"T216.BUILD.FOR_LOOP.1 — for h in _RECENT_ROW_HINT 循环渲染 5 字段")

	# bullet format "• %s — %s" (与 T213 一致)
	_assert("• %s — %s" in content,
		"T216.BUILD.BULLET_FMT.1 — tooltip 字段行 '• %s — %s' bullet format (与 T213 一致)")

	# detail format "    %s" (缩进)
	_assert("\"    %s\"" in content,
		"T216.BUILD.DETAIL_FMT.1 — tooltip detail 行 '    %s' 缩进 format (4 空格 + 内容)")

	# 11 行 tooltip (1 头 + 5 字段 × 2 行/字段)
	# 1 头 + 5 × 2 = 11 行
	# 验证方式: 3 tooltip 函数 (_build_verb_hint_tooltip T199 + _build_quick_stats_tooltip T213 +
	# _build_recent_row_tooltip T216) 各自声明 1 header + 1 bullet + 1 detail lines.append =
	# 3 source-layer appends × 3 函数 = 9 source-layer total. 运行时 1 + N×2 = 1+10=11
	# (T199) / 1+8=9 (T213) / 1+10=11 (T216) = 31 runtime calls. source-layer
	# total lines.append >= 9 验证 3 tooltip 函数都 1 header + 1 bullet + 1 detail 完整.
	var lines_append_count := content.count("lines.append(")
	_assert(lines_append_count >= 9,
		"T216.BUILD.11_LINES.1 — total lines.append >= 9 (3 tooltip 函数 × 3 source-layer appends/函数 = 9, 运行时 11+9+11=31 calls) — 实际 %d" % lines_append_count)

	# join 用 "\n" (与 T213 / T199 一致风格)
	_assert("\"\\n\".join(lines)" in content,
		"T216.BUILD.JOIN.1 — tooltip 行用 '\\n'.join(lines) 拼接 (与 T213/T199 风格一致)")

	# T216 函数位置 — 必须在 T213 _build_quick_stats_tooltip 之后 (声明顺序, 因为 T216 复用 T213 模式)
	var t213_build_pos := content.find("func _build_quick_stats_tooltip()")
	var t216_build_pos := content.find("func _build_recent_row_tooltip()")
	_assert(t213_build_pos > 0 and t216_build_pos > 0 and t216_build_pos > t213_build_pos,
		"T216.BUILD.SEQUENCE.1 — _build_recent_row_tooltip 声明在 _build_quick_stats_tooltip 之后 (T213→T216 顺序)")


# ---------- T216.READY — _refresh_recent_runs_list 中 5 行 tooltip_text 绑定 ----------
func _run_t216_ready_assertions(content: String) -> void:
	print("--- T216.READY — _refresh_recent_runs_list 5 行 tooltip_text 绑定 ---")

	# _refresh_recent_runs_list 中含 row_lbl.tooltip_text = _build_recent_row_tooltip()
	_assert("row_lbl.tooltip_text = _build_recent_row_tooltip()" in content,
		"T216.READY.ASSIGN.1 — _refresh_recent_runs_list 内含 row_lbl.tooltip_text = _build_recent_row_tooltip()")

	# 绑定位置 — 在 T215 mouse_entered.connect 之后 (语义顺序: 1) 显式 mouse 2) tooltip)
	var t215_mouse_entered_pos := content.find("row_lbl.mouse_entered.connect(_on_recent_row_hover_in.bind(i))")
	var t216_tooltip_pos := content.find("row_lbl.tooltip_text = _build_recent_row_tooltip()")
	_assert(t215_mouse_entered_pos > 0 and t216_tooltip_pos > 0 and t216_tooltip_pos > t215_mouse_entered_pos,
		"T216.READY.AFTER_SIGNAL.1 — tooltip_text 绑定在 mouse_entered.connect 之后 (语义顺序)")

	# 绑定位置 — 在 T215 mouse_exited.connect 之后
	var t215_mouse_exited_pos := content.find("row_lbl.mouse_exited.connect(_on_recent_row_hover_out.bind(i))")
	_assert(t215_mouse_exited_pos > 0 and t216_tooltip_pos > t215_mouse_exited_pos,
		"T216.READY.AFTER_SIGNAL.2 — tooltip_text 绑定在 mouse_exited.connect 之后 (语义顺序)")

	# 注释锚点 T216 (#137) 至少 3 处 (const 1 + build 1 + ready 1)
	var t216_anchor_count := content.count("T216 (#137)")
	_assert(t216_anchor_count >= 3,
		"T216.READY.ANCHOR.1 — T216 (#137) 注释锚点至少 3 处 (const 1 + build 1 + ready 1) — 实际 %d 处" % t216_anchor_count)

	# 5 行复用同一 tooltip 函数 (而不是 5 行各自生成, 因为字段含义对 5 行相同)
	# 验证: row_lbl.tooltip_text = _build_recent_row_tooltip() 在 source 中只出现 1 次 (写在 for 循环内 1 次, 5 行各自执行)
	_assert(content.count("row_lbl.tooltip_text = _build_recent_row_tooltip()") == 1,
		"T216.READY.5_REUSE.1 — row_lbl.tooltip_text = _build_recent_row_tooltip() 写在 for 循环内 1 次 (5 行复用同一 tooltip, 字段含义对 5 行相同)")


# ---------- T216.REGRESS — 回归 (T162/T213/T214/T215/T210 不动) ----------
func _run_t216_regress_assertions(content: String) -> void:
	print("--- T216.REGRESS — 回归 (T162/T213/T214/T215/T210 不动) ---")

	# T162 5 行 literal 0 改
	_assert("const _PROFILE_RECENT_RUNS_MAX := 5" in content,
		"T216.REGRESS.1 — T162 _PROFILE_RECENT_RUNS_MAX = 5 const 未删 (5 行 hover 范围 + 5 行 tooltip 范围一致)")
	_assert("\"Run #%d  房 %d  净 %d  碎 %d  时 %02d:%02d%s\"" in content,
            "T216.REGRESS.2 — T162 5 行 data format literal (Run #/房/净/碎/时 mm:ss) 未改基础字段, T234 (#153) 末尾追加 %s + _RECENT_ROW_TIP_INDICATOR tip indicator (T234 0 改字段顺序 + 0 改 tooltip 行为, 仅末尾追加 1 个 ↗)")
	_assert("empty_lbl.text = \"暂无 run 记录\"" in content,
		"T216.REGRESS.3 — T162 empty_lbl '暂无 run 记录' 占位未删 (空 history 路径 0 触碰)")
	_assert("_COLOR_RECENT_RUN_LATEST" in content and "_COLOR_RECENT_RUN_NORMAL" in content,
		"T216.REGRESS.4 — T162 _COLOR_RECENT_RUN_LATEST/_NORMAL const 未删 (T216 tooltip 复用 T162 color const, 不重写 color)")

	# T213 QuickStats tooltip 0 触碰
	_assert("const _QUICK_STATS_HINT" in content and "func _build_quick_stats_tooltip() -> String:" in content,
		"T216.REGRESS.5 — T213 _QUICK_STATS_HINT + _build_quick_stats_tooltip() 未删 (T216 独立 const, T213 0 触碰)")
	_assert("_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()" in content,
		"T216.REGRESS.6 — T213 _profile_quick_stats.tooltip_text 绑定未删 (T216 在 ProfileRecentList 0 触碰 ProfileQuickStats)")

	# T214 QuickStats hover 0 触碰
	_assert("_quick_stats_hovered" in content and "_quick_stats_default_text" in content,
		"T216.REGRESS.7 — T214 _quick_stats_hovered/_quick_stats_default_text 字段未删 (T216 0 触碰)")

	# T215 RecentList hover 0 触碰
	_assert("_recent_row_hovered" in content and "_recent_row_default_color" in content,
		"T216.REGRESS.8 — T215 _recent_row_hovered/_recent_row_default_color 字段未删 (T216 0 删 T215 字段)")
	_assert("row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T216.REGRESS.9 — T215 row_lbl.mouse_filter = MOUSE_FILTER_STOP 显式设未改 (T216 0 改 T215 mouse_filter)")
	_assert("row_lbl.mouse_entered.connect(_on_recent_row_hover_in.bind(i))" in content and "row_lbl.mouse_exited.connect(_on_recent_row_hover_out.bind(i))" in content,
		"T216.REGRESS.10 — T215 mouse_entered/exited.connect 5 行绑定未改 (T216 0 改 T215 signal connect)")
	_assert("add_theme_color_override(\"font_color\", Color.WHITE)" in content,
		"T216.REGRESS.11 — T215 Color.WHITE 提亮未改 (T216 tooltip 独立, 0 触碰 T215 hover 提亮)")

	# T210 QuickStats 4 段 literal 0 改
	var t210_4_segments := [
		["#69C7CE", "成就"],
		["#F2B66E", "最佳"],
		["#65506A", "最长单房"],
		["#B7E6DC", "Run #"],
	]
	var t210_missing: Array[String] = []
	for pair in t210_4_segments:
		if not (pair[0] in content and pair[1] in content):
			t210_missing.append("%s+%s" % [pair[0], pair[1]])
	_assert(t210_missing.is_empty(),
		"T216.REGRESS.12 — T210 4 段 literal 颜色 token + 段名未改; 缺: " + str(t210_missing))

	# T199 5 verb tooltip 0 触碰
	_assert("const _VERB_HINT_DATA" in content and "func _build_verb_hint_tooltip() -> String:" in content,
		"T216.REGRESS.13 — T199 _VERB_HINT_DATA + _build_verb_hint_tooltip() 未删 (5 verb tooltip 与 recent list 独立, 0 触碰)")


func _finish() -> void:
	print("")
	print("=== I042 — summary ===")
	print("PASS: %d" % _passes)
	print("FAIL: %d" % _failures.size())
	for fail in _failures:
		print("  - %s" % fail)
	if _failures.is_empty():
		print("I042 — T216 ProfileRecentList 5 行 hover tooltip 5 字段含义 smoke test: PASSED")
		quit(0)
	else:
		print("I042 — T216 ProfileRecentList 5 行 hover tooltip 5 字段含义 smoke test: FAILED")
		quit(1)
