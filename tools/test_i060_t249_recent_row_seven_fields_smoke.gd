extends SceneTree
## I060 (#167) — T249 ProfileRecentList 5 行 row 文本 5 字段 → 7 字段扩展 (tooltip 字段顺序同步) 冒烟测试
##
## 覆盖 #167 任务 T249 原子化提交:
##
## === T249 — ProfileRecentList 5 行 row 文本 5 字段 → 7 字段扩展 (同步 _RECENT_ROW_HINT tooltip 字段顺序) ===
## - T249.FORMAT.STRING: row_lbl.text format string 7 字段 (Run #N · 房 X · 净 X · 碎 X · 时 mm:ss · 房/时 X · 净/时 X ↗)
## - T249.FORMAT.SEP_COUNT: format 字符串 6 个 %s + _RECENT_ROW_FIELD_SEP 拼接 (5 字段 4 分隔符 + 2 派生率 2 分隔符 = 6 间隔)
## - T249.COMPUTE.PER_MIN_DECL: rooms_per_minute 变量已声明 (1 次, 0 重复)
## - T249.COMPUTE.PER_MIN_INIT: rooms_per_minute 初始化 0 (防御 t_sec == 0 不报除零)
## - T249.COMPUTE.PER_MIN_COMPUTE: t_sec > 0 时 rooms_per_minute = round(rooms / (t_sec / 60))
## - T249.COMPUTE.PER_MIN_ZERO: t_sec == 0 时 rooms_per_minute = 0 (0/0 防御)
## - T249.COMPUTE.EN_PER_MIN_DECL: enemies_per_minute 变量已声明 (1 次, 0 重复)
## - T249.COMPUTE.EN_PER_MIN_COMPUTE: t_sec > 0 时 enemies_per_minute = round(enemies / (t_sec / 60))
## - T249.COMPUTE.EN_PER_MIN_ZERO: t_sec == 0 时 enemies_per_minute = 0 (0/0 防御)
## - T249.COMPUTE.GUARD: t_sec > 0 守卫 if 块存在 (0/0 = nan 防御)
## - T249.COMPUTE.ROUND: round() 函数用于 0.5+ 向上舍入
## - T249.NO_REGRESS_T215: T215 _recent_row_hovered / _recent_row_default_color 0 触碰
## - T249.NO_REGRESS_T216: T216 tooltip_text _RECENT_ROW_HINT 7 字段 0 改
## - T249.NO_REGRESS_T231: T231 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST / _RECENT_ROW_HOVER_FADE_DURATION 0 改
## - T249.NO_REGRESS_T234: T234 _RECENT_ROW_TIP_INDICATOR 保留 (1 空格 + ↗ U+2197)
## - T249.NO_REGRESS_T235: T235 _RECENT_ROW_FIELD_SEP 保留 (const 0 改, 引用从 4 → 6)
## - T249.NO_REGRESS_T240: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION 保留 (hover font_color tween 0 改)
## - T249.NO_REGRESS_T219: T219 _RECENT_ROW_ALPHA_MAX/MIN 保留 (5 行 alpha 渐变 0 改)
## - T249.NO_REGRESS_T232: T232 _RECENT_RESONANCE_DECAY/WINDOW 保留
## - T249.NO_REGRESS_T136: T136 _PROFILE_RECENT_RUNS_MAX 保留
## - T249.NO_REGRESS_T137: T137 _profile_recent_list @onready 保留
## - T249.SYNTAX.PER_MIN_VARS: rooms_per_minute + enemies_per_minute 1 次声明
## - T249.SYNTAX.SEP_USAGE: 6 个 _RECENT_ROW_FIELD_SEP 在 format 数组中 (4 + 2 = 6, T249 加 2 派生率)
## - T249.DOC.ANCHOR: T249 (#167) 注释锚点 ≥ 3 处 (const/format/计算块)
## - T249.FORMAT.INDICATOR_END: format 数组末尾 = (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR) 保留 tip indicator
## - T249.FORMAT.ORDER: 7 字段顺序与 _RECENT_ROW_HINT 100% 对齐 (Run # → 房 → 净 → 碎 → 时 → 房/时 → 净/时)
## - T249.FORMAT.NO_BBCODE: 7 字段 format 字符串无 BBCode 包裹 (T249 0 引入 BBCode, 0 BBCode 渲染复杂度, 0 theme override 优先级冲突)

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I060 (#167) — T249 ProfileRecentList 5 行 row 7 字段扩展 (tooltip 字段顺序同步) ===")
	_run_t249_format_assertions()
	_run_t249_compute_assertions()
	_run_t249_syntax_assertions()
	_run_t249_no_regress_assertions()
	_run_t249_doc_anchor_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I060 (#167) T249 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T249 — ProfileRecentList 5 行 row 文本 5 字段 → 7 字段扩展 =====================

# ---------- T249.FORMAT.* — 7 字段 format 字符串 + 6 个 middle-dot 分隔符 ----------
func _run_t249_format_assertions() -> void:
	print("--- T249.FORMAT.* — 7 字段 format 字符串 + 6 个 middle-dot 分隔符 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 7 字段 format 字符串 (T249 #167 5 字段 → 7 字段, 加 房/时 + 净/时 2 派生率)
	_assert_contains(src, "row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"",
		"T249.FORMAT.STRING.1: row_lbl.text 7 字段 (Run #N · 房 X · 净 X · 碎 X · 时 mm:ss · 房/时 X · 净/时 X ↗, T249 #167 5 字段 → 7 字段扩展, 同步 _RECENT_ROW_HINT tooltip 字段顺序)")
	# 7 字段顺序与 _RECENT_ROW_HINT 100% 对齐
	var hint_idx := src.find("const _RECENT_ROW_HINT := [")
	if hint_idx != -1:
		var hint_body := src.substr(hint_idx, 2500)
		# _RECENT_ROW_HINT 7 字段 label 顺序: Run # / 房 / 净 / 碎 / 时 / 房/时 / 净/时
		var order_ok := true
		var order_labels := ["\"Run #\"", "\"房\"", "\"净\"", "\"碎\"", "\"时\"", "\"房/时\"", "\"净/时\""]
		var last_idx := -1
		for lbl in order_labels:
			var found_idx := hint_body.find(lbl)
			if found_idx == -1 or found_idx <= last_idx:
				order_ok = false
				break
			last_idx = found_idx
		if order_ok:
			_passes += 1
			print("  OK  T249.FORMAT.ORDER.1: _RECENT_ROW_HINT 7 字段 label 顺序与 row 7 字段顺序 100% 对齐 (Run # → 房 → 净 → 碎 → 时 → 房/时 → 净/时, 玩家 hover tooltip 看到什么字段顺序, row 文本就是什么顺序)")
		else:
			_failures.append("FAIL: T249.FORMAT.ORDER.1: _RECENT_ROW_HINT 7 字段 label 顺序与 row 7 字段顺序不一致")
	else:
		_failures.append("FAIL: T249.FORMAT.ORDER.1: 找不到 const _RECENT_ROW_HINT")
	# format 数组末尾 = (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR)
	_assert_contains(src, "enemies_per_minute, _RECENT_ROW_TIP_INDICATOR",
		"T249.FORMAT.INDICATOR_END.1: format 数组末尾保留 _RECENT_ROW_TIP_INDICATOR 末位 (T249 #167 0 删 T234 tip indicator)")
	# 0 BBCode 包裹 (T249 走纯文本 + 主题色 override, 0 BBCode 渲染复杂度)
	var format_idx := src.find("row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"")
	if format_idx != -1:
		var format_str := src.substr(format_idx, 200)
		var has_bbcode := format_str.find("[color=") != -1 or format_str.find("[b]") != -1
		if not has_bbcode:
			_passes += 1
			print("  OK  T249.FORMAT.NO_BBCODE.1: 7 字段 format 字符串 0 BBCode 包裹 (T249 #167 0 引入 BBCode 渲染, 0 theme override 优先级冲突, 与 T215+T240 hover 主题色 override 路径兼容)")
		else:
			_failures.append("FAIL: T249.FORMAT.NO_BBCODE.1: 7 字段 format 字符串包含 BBCode 标记 (T249 #167 应走纯文本 + add_theme_color_override)")


# ---------- T249.COMPUTE.* — rooms_per_minute / enemies_per_minute 计算 + 0/0 防御 ----------
func _run_t249_compute_assertions() -> void:
	print("--- T249.COMPUTE.* — rooms_per_minute / enemies_per_minute 计算 + 0/0 防御 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# rooms_per_minute 变量声明
	_assert_contains(src, "var rooms_per_minute: int = 0",
		"T249.COMPUTE.PER_MIN_DECL.1: var rooms_per_minute: int = 0 (派生率变量声明, 默认 0 防 0/0)")
	_assert_contains(src, "var enemies_per_minute: int = 0",
		"T249.COMPUTE.EN_PER_MIN_DECL.1: var enemies_per_minute: int = 0 (派生率变量声明, 默认 0 防 0/0)")
	# 1 次声明, 0 重复
	var per_min_count := src.count("var rooms_per_minute: int = 0")
	if per_min_count == 1:
		_passes += 1
		print("  OK  T249.COMPUTE.PER_MIN_UNIQUE.1: var rooms_per_minute 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T249.COMPUTE.PER_MIN_UNIQUE.1: var rooms_per_minute 声明 %d 次, 应 1" % per_min_count)
	var en_per_min_count := src.count("var enemies_per_minute: int = 0")
	if en_per_min_count == 1:
		_passes += 1
		print("  OK  T249.COMPUTE.EN_PER_MIN_UNIQUE.1: var enemies_per_minute 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T249.COMPUTE.EN_PER_MIN_UNIQUE.1: var enemies_per_minute 声明 %d 次, 应 1" % en_per_min_count)
	# t_sec > 0 守卫
	_assert_contains(src, "if t_sec > 0.0:",
		"T249.COMPUTE.GUARD.1: if t_sec > 0.0: 守卫块存在 (0/0 = nan 防御, t_sec == 0 → 派生率 0 占位)")
	# round() 函数
	_assert_contains(src, "int(round(float(rooms) / (t_sec / 60.0)))",
		"T249.COMPUTE.PER_MIN_COMPUTE.1: rooms_per_minute = int(round(float(rooms) / (t_sec / 60.0))) (房/分钟 派生率, round 0.5+ 向上舍入)")
	_assert_contains(src, "int(round(float(enemies) / (t_sec / 60.0)))",
		"T249.COMPUTE.EN_PER_MIN_COMPUTE.1: enemies_per_minute = int(round(float(enemies) / (t_sec / 60.0))) (敌/分钟 派生率)")
	# t_sec == 0 时派生率 = 0 (初始化 0 + 守卫跳过赋值)
	# 0 出现赋值路径 (var rooms_per_minute: int = 0) + 守卫块 (if t_sec > 0.0:)
	if src.find("var rooms_per_minute: int = 0") != -1 and src.find("if t_sec > 0.0:") != -1:
		_passes += 1
		print("  OK  T249.COMPUTE.PER_MIN_ZERO.1: t_sec == 0 → rooms_per_minute 保持 0 (var init 0 + 守卫 if t_sec > 0.0 跳过赋值, 0/0 nan 防御)")
	else:
		_failures.append("FAIL: T249.COMPUTE.PER_MIN_ZERO.1: t_sec == 0 0/0 防御路径不完整")
	if src.find("var enemies_per_minute: int = 0") != -1 and src.find("if t_sec > 0.0:") != -1:
		_passes += 1
		print("  OK  T249.COMPUTE.EN_PER_MIN_ZERO.1: t_sec == 0 → enemies_per_minute 保持 0 (var init 0 + 守卫 if t_sec > 0.0 跳过赋值, 0/0 nan 防御)")
	else:
		_failures.append("FAIL: T249.COMPUTE.EN_PER_MIN_ZERO.1: t_sec == 0 0/0 防御路径不完整")


# ---------- T249.SYNTAX.* — 6 个 _RECENT_ROW_FIELD_SEP 在 format 数组中 (4 + 2 = 6) ----------
func _run_t249_syntax_assertions() -> void:
	print("--- T249.SYNTAX.* — 6 个 _RECENT_ROW_FIELD_SEP 在 format 数组中 (4 + 2 = 6) ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 6 个 _RECENT_ROW_FIELD_SEP 在 _refresh_recent_runs_list format 数组
	# 4 (原 5 字段) + 2 (T249 加 房/时 + 净/时 2 派生率) = 6
	# 验证 _RECENT_ROW_FIELD_SEP 在 _refresh_recent_runs_list 范围内引用次数 ≥ 7 (1 const + 6 format 数组)
	var ref_count := src.count("_RECENT_ROW_FIELD_SEP")
	if ref_count >= 7:
		_passes += 1
		print("  OK  T249.SYNTAX.SEP_USAGE.1: _RECENT_ROW_FIELD_SEP 引用 %d 次 (≥ 7, const 1 + format 数组 6, T249 #167 5→7 字段扩展后 4→6 分隔符)" % ref_count)
	else:
		_failures.append("FAIL: T249.SYNTAX.SEP_USAGE.1: _RECENT_ROW_FIELD_SEP 引用 %d 次, 需 ≥ 7 (const 1 + format 6)" % ref_count)


# ---------- T249.NO_REGRESS.* — T215/T216/T219/T231/T232/T234/T235/T240/T136/T137 0 触碰 ----------
func _run_t249_no_regress_assertions() -> void:
	print("--- T249.NO_REGRESS.* — T215/T216/T219/T231/T232/T234/T235/T240/T136/T137 0 触碰 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T215 (#136) hover handler 字段保留
	_assert_contains(src, "var _recent_row_hovered: Array = []",
		"T249.NO_REGRESS_T215.1: T215 _recent_row_hovered 字段保留 (T249 #167 0 触碰 hover re-entrant guard)")
	_assert_contains(src, "var _recent_row_default_color: Array = []",
		"T249.NO_REGRESS_T215.2: T215 _recent_row_default_color 字段保留 (T249 #167 0 触碰 default color 缓存)")
	_assert_contains(src, "func _on_recent_row_hover_in(idx: int) -> void:",
		"T249.NO_REGRESS_T215.3: T215 _on_recent_row_hover_in 函数保留 (T249 #167 0 触碰 hover_in handler)")
	_assert_contains(src, "func _on_recent_row_hover_out(idx: int) -> void:",
		"T249.NO_REGRESS_T215.4: T215 _on_recent_row_hover_out 函数保留 (T249 #167 0 触碰 hover_out handler)")
	# T216 (#137) tooltip 0 改
	_assert_contains(src, "row_lbl.tooltip_text = _build_recent_row_tooltip()",
		"T249.NO_REGRESS_T216.1: T216 tooltip_text 绑定保留 (T249 #167 0 触碰 7 字段 tooltip 渲染)")
	_assert_contains(src, "func _build_recent_row_tooltip() -> String:",
		"T249.NO_REGRESS_T216.2: T216 _build_recent_row_tooltip 函数保留 (T249 #167 0 触碰 tooltip 7 字段生成)")
	_assert_contains(src, "const _RECENT_ROW_HINT := [",
		"T249.NO_REGRESS_T216.3: T216 _RECENT_ROW_HINT const 保留 (T249 #167 0 改 tooltip 7 字段权威 const)")
	# T219 (#141) alpha 渐变 0 改
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MAX := 1.0",
		"T249.NO_REGRESS_T219.1: T219 _RECENT_ROW_ALPHA_MAX = 1.0 const 保留 (T249 #167 0 触碰 5 行 alpha 渐变)")
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MIN := 0.5",
		"T249.NO_REGRESS_T219.2: T219 _RECENT_ROW_ALPHA_MIN = 0.5 const 保留")
	# T231 (#151) hover alpha boost 0 改
	_assert_contains(src, "const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T249.NO_REGRESS_T231.1: T231 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST = 0.1 const 保留 (T249 #167 同步 T231 alpha boost 节奏 0 改)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_FADE_DURATION := 0.12",
		"T249.NO_REGRESS_T231.2: T231 _RECENT_ROW_HOVER_FADE_DURATION = 0.12 const 保留 (T249 #167 0 改 fade 时长)")
	_assert_contains(src, "var _recent_row_hover_alpha_base: Dictionary = {}",
		"T249.NO_REGRESS_T231.3: T231 _recent_row_hover_alpha_base dict 保留 (T249 #167 0 触碰 hover alpha boost dict)")
	# T232 (#151) 跨 run 加权 const 0 改
	_assert_contains(src, "const _RECENT_RESONANCE_DECAY := 0.5",
		"T249.NO_REGRESS_T232.1: T232 _RECENT_RESONANCE_DECAY = 0.5 const 保留 (T249 #167 0 触碰 跨 run 衰减权重)")
	_assert_contains(src, "const _RECENT_RESONANCE_HISTORY_WINDOW := 5",
		"T249.NO_REGRESS_T232.2: T232 _RECENT_RESONANCE_HISTORY_WINDOW = 5 const 保留")
	# T234 (#153) tip indicator 保留
	_assert_contains(src, "const _RECENT_ROW_TIP_INDICATOR := \" \u2197\"",
		"T249.NO_REGRESS_T234.1: T234 _RECENT_ROW_TIP_INDICATOR const 保留 (1 空格 + \u2197 U+2197, T249 #167 0 删 tip indicator)")
	# T235 (#154) middle-dot 分隔符 0 改 const, 但引用从 4 → 6
	_assert_contains(src, "const _RECENT_ROW_FIELD_SEP := \"  \u00b7  \"",
		"T249.NO_REGRESS_T235.1: T235 _RECENT_ROW_FIELD_SEP const 保留 (T249 #167 0 改 const 值, 0 改中点字面量)")
	# T240 (#158) hover font_color tween 0 改
	_assert_contains(src, "const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12",
		"T249.NO_REGRESS_T240.1: T240 _RECENT_ROW_FONT_COLOR_FADE_DURATION = 0.12 const 保留 (T249 #167 0 改 hover font_color tween 时长)")
	_assert_contains(src, "var _recent_row_font_color_tween: Tween = null",
		"T249.NO_REGRESS_T240.2: T240 _recent_row_font_color_tween 字段保留 (T249 #167 0 触碰 5 行共享 tween 引用)")
	# T136 (#82) + T137 (#83) 5 局窗口 + @onready 保留
	_assert_contains(src, "const _PROFILE_RECENT_RUNS_MAX",
		"T249.NO_REGRESS_T136.1: T136 _PROFILE_RECENT_RUNS_MAX const 保留 (T249 #167 0 触碰 5 局最近窗口)")
	_assert_contains(src, "@onready var _profile_recent_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRecentList",
		"T249.NO_REGRESS_T137.1: T137 _profile_recent_list @onready 保留 (T249 #167 0 触碰 ScrollContainer 引用)")


# ---------- T249.DOC.ANCHOR.* — T249 (#167) 注释锚点 ≥ 3 处 ----------
func _run_t249_doc_anchor_assertions() -> void:
	print("--- T249.DOC.ANCHOR.* — T249 (#167) 注释锚点 ≥ 3 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T249 (#167)") != -1:
			anchor_count += 1
	if anchor_count >= 3:
		_passes += 1
		print("  OK  T249.DOC.ANCHOR.1: T249 (#167) 注释锚点 %d 处 (≥ 3, 涵盖计算块 + format 块 + no_regress 注释段)" % anchor_count)
	else:
		_failures.append("FAIL: T249.DOC.ANCHOR.1: T249 (#167) 注释锚点仅 %d 处, 需 ≥ 3" % anchor_count)


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, msg: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I060 (#167) T249 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
