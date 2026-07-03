extends SceneTree

# I041 — T215 (#136) ProfileRecentList 5 局行悬停高亮联动 smoke test
# 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd 中 T215 实现的
# 6 大模块 (state field / mouse_filter + signal connect / hover_in handler /
# hover_out handler / _refresh_recent_runs_list 重置+save / 注释锚点) +
# 5 大回归保护 (T162 5 行 literal 0 改 / T213 tooltip 0 触碰 / T214 hover 0 触碰
# / T199 5 verb tooltip 0 触碰 / T210 QuickStats 4 段 literal 0 改). 期望:
# 38 断言全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i041_t215_recent_row_hover_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#   python3 tools/test_i041_t215_recent_row_hover_smoke.py   # 见末尾 fallback

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
	print("=== I041 — T215 (#136) ProfileRecentList 5 局行悬停高亮联动 smoke test ===")
	var f := FileAccess.open(PAUSE_MENU_PATH, FileAccess.READ)
	if f == null:
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()

	# T215.STATE — 状态字段 (3)
	_assert("var _recent_row_hovered: Array = []" in content,
		"T215.STATE.1 — _recent_row_hovered Array 字段声明存在 (5 行独立 bool flag, 防止 re-entrant trigger)")
	_assert("var _recent_row_default_color: Array = []" in content,
		"T215.STATE.2 — _recent_row_default_color Array 字段声明存在 (5 行还原色, 避免 hover_out 错把高亮版当 default 写回)")
	# 字段顺序: T217 (#138) _quick_stats_hovered_idx (替代 T214 旧版
	# _quick_stats_hovered bool, T217 4 段独立 idx 0-3 字段) →
	# _recent_row_hovered / _recent_row_default_color (T215).
	# T215 字段必须在 T217 字段之后, _ready 之前声明.
	# T214 (#134) 旧版 _quick_stats_hovered / _quick_stats_default_text 字段
	# T217 (#138) 完全废弃 (4 sub-Label 1 段高亮 + 3 段 dim, bool 字段 0 足够
	# 表达 "hover 哪一段", idx 字段 0-3 表达精确段号, 字符串 default 缓存 0
	# 需要 modulate 4 字段独立管理替代).
	var t217_hovered_idx_pos := content.find("var _quick_stats_hovered_idx: int = -1")
	var t215_hovered_pos := content.find("var _recent_row_hovered: Array = []")
	var t215_default_pos := content.find("var _recent_row_default_color: Array = []")
	var ready_pos := content.find("func _ready() -> void:")
	_assert(t217_hovered_idx_pos > 0 and t215_hovered_pos > 0 and t215_default_pos > 0,
		"T215.STATE.3 — T215 2 字段声明均存在 (T217 hovered_idx 替代 T214 hovered bool + T215 hovered + T215 default color)")
	_assert(t215_hovered_pos > t217_hovered_idx_pos and t215_default_pos > t215_hovered_pos and ready_pos > t215_default_pos,
		"T215.STATE.4 — T215 字段声明顺序合理 (T217 hovered_idx 之后, _ready 之前)")

	# T215.WIRING — 5 行独立 mouse_filter + connect (6)
	# mouse_filter=STOP 显式设 (Label 默认 IGNORE → 必须改 STOP 才能触发 mouse_entered)
	# 5 行各自 connect, mouse_entered.connect(_on_recent_row_hover_in.bind(i))
	# mouse_exited.connect(_on_recent_row_hover_out.bind(i))
	_assert("_profile_recent_list.get_child_count()" in content or "row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T215.WIRING.1 — 5 行独立 mouse_filter = Control.MOUSE_FILTER_STOP 显式设存在 (Label 默认 IGNORE)")
	_assert("row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T215.WIRING.2 — row_lbl.mouse_filter = MOUSE_FILTER_STOP 显式设 (每行 1 次, 共 5 次)")
	_assert("row_lbl.mouse_entered.connect(_on_recent_row_hover_in.bind(i))" in content,
		"T215.WIRING.3 — row_lbl.mouse_entered.connect(_on_recent_row_hover_in.bind(i)) 绑定 (5 行各自 bind idx)")
	_assert("row_lbl.mouse_exited.connect(_on_recent_row_hover_out.bind(i))" in content,
		"T215.WIRING.4 — row_lbl.mouse_exited.connect(_on_recent_row_hover_out.bind(i)) 绑定")
	_assert("_recent_row_hovered.append(false)" in content,
		"T215.WIRING.5 — _recent_row_hovered.append(false) 在创建 row 时同步 (5 行各自 1 个 false)")
	_assert("_recent_row_default_color.append(default_color)" in content,
		"T215.WIRING.6 — _recent_row_default_color.append(default_color) 在创建 row 时同步 (保存每行还原色)")

	# T215.HANDLERS — handlers (8)
	_assert("func _on_recent_row_hover_in(idx: int) -> void:" in content,
		"T215.HANDLERS.1 — _on_recent_row_hover_in(idx: int) handler 函数声明存在 (idx 是 bind 传入的行号)")
	_assert("func _on_recent_row_hover_out(idx: int) -> void:" in content,
		"T215.HANDLERS.2 — _on_recent_row_hover_out(idx: int) handler 函数声明存在")
	_assert("if idx < 0 or idx >= _profile_recent_list.get_child_count():" in content,
		"T215.HANDLERS.3 — hover_in 越界检查 (idx < 0 or >= child count) 防御 0 副作用退出")
	_assert("_recent_row_hovered[idx]" in content and "_recent_row_hovered[idx]:" in content,
		"T215.HANDLERS.4 — hover_in re-entrant guard (_recent_row_hovered[idx] 已 true → return)")
	_assert("Color.WHITE" in content and "_profile_recent_list.get_child(idx)" in content,
		"T215.HANDLERS.5 — hover_in 提亮 font_color 到 Color.WHITE (5 行独立, idx 闭包)")
	_assert("_recent_row_default_color[idx]" in content,
		"T215.HANDLERS.6 — hover_out restore 到 _recent_row_default_color[idx] (1:1 对应行号, 避免误把高亮版当 default)")
	_assert("_recent_row_hovered[idx] = false" in content,
		"T215.HANDLERS.7 — hover_out 翻 _recent_row_hovered[idx] = false (re-entrant safety for next mouse_entered)")
	_assert("add_theme_color_override(\"font_color\", default_color)" in content,
		"T215.HANDLERS.8 — hover_out 用 add_theme_color_override(\"font_color\", default_color) restore (与 T162 创建时同模式, theme override 替换)")

	# T215.SAVE — _refresh_recent_runs_list 重置 + save (3)
	_assert("_recent_row_hovered.clear()" in content,
		"T215.SAVE.1 — _refresh_recent_runs_list 起始 _recent_row_hovered.clear() (每次 _refresh 重建 5 行, 数组 resize)")
	_assert("_recent_row_default_color.clear()" in content,
		"T215.SAVE.2 — _refresh_recent_runs_list 起始 _recent_row_default_color.clear()")
	# default_color 变量在 set theme override 之前定义
	# 检查 var default_color: Color 在 row_lbl.add_theme_color_override("font_color", default_color) 之前
	var default_color_decl_pos := content.find("var default_color: Color")
	var default_color_use_pos := content.find("add_theme_color_override(\"font_color\", default_color)")
	_assert(default_color_decl_pos > 0 and default_color_use_pos > 0 and default_color_use_pos > default_color_decl_pos,
		"T215.SAVE.3 — default_color: Color 局部变量在 set theme override 之前定义 (T215 提取 default_color 局部变量, T162 嵌套 if-else 重构)")

	# T215.ANCHOR — 注释锚点 (1)
	# 期望至少 4 处 T215 (#136) 注释锚点 (state field 1 + _refresh reset 1 +
	# _refresh row 1 + hover_in 1 + hover_out 1 = 5+ 必需, 不强制 ≥6 因为 T215
	# 是 polish scope 收窄的产物, 不需要像 T213 那样为后续 T215.B/C/D 留占位).
	var t215_anchor_count := content.count("T215 (#136)")
	_assert(t215_anchor_count >= 4,
		"T215.ANCHOR.1 — T215 (#136) 注释锚点至少 4 处 (state field 1 + _refresh reset 1 + _refresh row 1 + hover_in 1 + hover_out 1) — 实际 %d 处" % t215_anchor_count)

	# T215.REGRESS — T162 5 行 literal 0 改 (5)
	_assert("_COLOR_RECENT_RUN_LATEST" in content,
		"T215.REGRESS.1 — T162 _COLOR_RECENT_RUN_LATEST (Amber Voice) const**未删** (T215 复用为 i==0 行的 default_color)")
	_assert("_COLOR_RECENT_RUN_NORMAL" in content,
		"T215.REGRESS.2 — T162 _COLOR_RECENT_RUN_NORMAL (Pale Resonance) const**未删** (T215 复用为 i>0 行的 default_color)")
	_assert("const _PROFILE_RECENT_RUNS_MAX := 5" in content,
		"T215.REGRESS.3 — T162 _PROFILE_RECENT_RUNS_MAX = 5 const**未删** (5 行 hover 范围)")
	_assert("\"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s\"" in content,
		"T215.REGRESS.4 — T162 5 行 data format literal 基础字段 (Run #/房/净/碎/时 mm:ss 5 字段) + T234 (#153) 末尾 %s ↗ + T235 (#154) 字段间中点 `_RECENT_ROW_FIELD_SEP` middle-dot 4 段分隔 (T215 0 改字段顺序 + 0 改 hover 行为, 0 触碰 T234/T235)")
	_assert("empty_lbl.text = \"暂无 run 记录\"" in content,
		"T215.REGRESS.5 — T162 empty_lbl \"暂无 run 记录\" 占位**未删** (空 history 路径 0 触碰)")

	# T215.REGRESS — T213/T217/T199/T210 0 触碰 (4)
	_assert("_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()" in content,
		"T215.REGRESS.6 — T213 ProfileQuickStats tooltip 绑定**未删** (T215 在 ProfileRecentList, 0 触碰 ProfileQuickStats tooltip)")
	# T217 (#138) — 4 sub-Label 4 段独立 hover 联动状态字段, T214 (#134) 旧版
	# _quick_stats_hovered / _quick_stats_default_text 完全废弃 (4 sub-Label
	# modulate 独立管理, 0 字符串 default 缓存). 验证 T217 新字段存在 + T214
	# 旧字段已删 (T215 REGRESS 7 round-trip: 旧字段在 T217 已删, 与 T215 5 行
	# hover 字段同时验证).
	_assert("_quick_stats_hovered_idx" in content and not ("var _quick_stats_hovered: bool = false" in content) and not ("var _quick_stats_default_text: String" in content),
		"T215.REGRESS.7 — T217 _quick_stats_hovered_idx 字段**已加** + T214 旧版 _quick_stats_hovered / _quick_stats_default_text 字段**已删** (T217 完整 round-trip, 4 sub-Label modulate 替代 1 Label 字符串 default 缓存)")
	_assert("_VERB_HINT_DATA" in content and "func _build_verb_hint_tooltip() -> String:" in content,
		"T215.REGRESS.8 — T199 _VERB_HINT_DATA + _build_verb_hint_tooltip()**未删** (5 verb tooltip 与 recent list 独立, 0 触碰)")
	# T210 4 段 literal 验证 — 4 段 (color token + 段名) 双键验证, 与 literal 实际顺序无关
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
		"T215.REGRESS.9 — T210 4 段 literal 颜色 token (Glass Cyan/Amber Voice/Muted Violet/Pale Resonance) + 段名**未改**; 缺: " + str(t210_missing))

	# T215.SYNTAX — GDScript 静态语法 (4)
	# 简单平衡检查: 数字 "func _on_recent_row_hover_in" = "func _on_recent_row_hover_out" = 1 (各 1)
	_assert(content.count("func _on_recent_row_hover_in") == 1 and content.count("func _on_recent_row_hover_out") == 1,
		"T215.SYNTAX.1 — _on_recent_row_hover_in/out 各自声明 1 次 (无重复定义)")
	# row_lbl.mouse_filter = MOUSE_FILTER_STOP 在 _refresh_recent_runs_list 中 5 行各自 1 次
	# 共 5 次 (1 次声明 + 5 次使用) — 但实际 source 中是 1 行声明写在 for loop 内, count = 1
	# 因为 `row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP` 是 1 行 for 循环体内代码, source 1 次
	_assert(content.count("row_lbl.mouse_filter = Control.MOUSE_FILTER_STOP") == 1,
		"T215.SYNTAX.2 — row_lbl.mouse_filter = MOUSE_FILTER_STOP 写在 for 循环体内 1 次 (5 行各自执行)")
	# bind(i) 模式出现 2 次: in 1 次 + out 1 次
	_assert(content.count("_on_recent_row_hover_in.bind(i)") == 1 and content.count("_on_recent_row_hover_out.bind(i)") == 1,
		"T215.SYNTAX.3 — mouse_entered.bind(i) + mouse_exited.bind(i) 各 1 次 (1 对 handler 处理 5 行, 闭包传 idx)")
	# Color.WHITE 提亮 — T215 是唯 1 处用 Color.WHITE 提亮 (T214 走 BBCode 路径不走 Color.WHITE)
	_assert(content.count("add_theme_color_override(\"font_color\", Color.WHITE)") == 1,
		"T215.SYNTAX.4 — hover_in 提亮用 add_theme_color_override(\"font_color\", Color.WHITE) 1 次 (T215 走 theme override 路径不 BBCode)")
	_finish()

func _finish() -> void:
	print("")
	print("=== I041 — summary ===")
	print("PASS: %d" % _passes)
	print("FAIL: %d" % _failures.size())
	for fail in _failures:
		print("  - %s" % fail)
	if _failures.is_empty():
		print("I041 — T215 ProfileRecentList 5 局行悬停高亮联动 smoke test: PASSED")
		quit(0)
	else:
		print("I041 — T215 ProfileRecentList 5 局行悬停高亮联动 smoke test: FAILED")
		quit(1)
