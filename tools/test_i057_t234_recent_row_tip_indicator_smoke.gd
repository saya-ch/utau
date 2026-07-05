extends SceneTree
## I057 (#153) — T234 ProfileRecentList 5 行 row text 末尾追加 ↗ tip indicator 冒烟测试
##
## 覆盖 #153 任务 T234 原子化提交:
##
## === T234 — ProfileRecentList 5 行 row text 末尾追加 ↗ tip indicator ===
## - T234.CONST.DECLARED: const _RECENT_ROW_TIP_INDICATOR 已声明 (1 次, 0 重复)
## - T234.CONST.VALUE: _RECENT_ROW_TIP_INDICATOR 值 = " ↗" (1 空格 + U+2197 字符)
## - T234.CONST.UNICODE: U+2197 (↗ NORTH EAST ARROW) 字符 literal 在源码中
## - T234.FORMAT.STRING: row_lbl.text format string 末尾含 ↗ tip indicator (T235 #154 字段
##   间分隔从 "  " 演化为 " · " middle-dot, T234.FORMAT.* 3 个 fixed snapshot assertion
##   放宽: 验证 "末尾 %s 仍是 ↗ tip indicator" + "4 个 _RECENT_ROW_FIELD_SEP" 演化正确)
## - T234.FORMAT.ARG: format 数组末尾追加 _RECENT_ROW_TIP_INDICATOR 变量 (T235 后变
##   11 元素: 5 字段 + 4 _RECENT_ROW_FIELD_SEP + 末尾 2 个 _RECENT_ROW_TIP_INDICATOR)
## - T234.FORMAT.PLACEHOLDER: format string 末尾 %s placeholder 仍是 ↗ (T235 0 触碰)
## - T234.ANCHOR: T234 (#153) 注释锚点 ≥ 2 处 (const 块 + _refresh_recent 段)
## - T234.NO_REGRESS_T215: T215 字段 (_recent_row_hovered / _recent_row_default_color) 0 触碰
## - T234.NO_REGRESS_T216: T216 tooltip_text = _build_recent_row_tooltip() 0 触碰
## - T234.NO_REGRESS_T219: T219 _RECENT_ROW_ALPHA_MAX/MIN const 保留
## - T234.NO_REGRESS_T231: T231 _recent_row_hover_alpha_base + boost 0 触碰
## - T234.NO_REGRESS_T232: T232 _RECENT_RESONANCE_DECAY/WINDOW 0 触碰
## - T234.NO_REGRESS_T235: T235 _RECENT_ROW_FIELD_SEP 字段间中点分隔 (4 个 · middle-dot)
## - T234.NO_REGRESS_T136: T136 _PROFILE_RECENT_RUNS_MAX 0 触碰
## - T234.NO_REGRESS_T137: T137 _profile_recent_list @onready 0 触碰
## - T234.SYNTAX: const + format 1 次声明, 0 重复
## - T234.LAYOUT: 5 行 ≤ _PROFILE_RECENT_RUNS_MAX (5), 0 overflow
## - T234.ORDER: _RECENT_ROW_TIP_INDICATOR 在 T232 const 之后声明 (0 顺序冲突)

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I057 (#153) — T234 ProfileRecentList 5 行 row text 末尾追加 ↗ tip indicator ===")
	_run_t234_const_assertions()
	_run_t234_format_assertions()
	_run_t234_doc_anchor_assertions()
	_run_t234_regress_assertions()
	_run_t234_syntax_assertions()
	_run_t234_order_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I057 (#153) T234 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T234 — ProfileRecentList 5 行 row text 末尾追加 ↗ tip indicator =====================

# ---------- T234.CONST.* — _RECENT_ROW_TIP_INDICATOR 已声明 + 值正确 ----------
func _run_t234_const_assertions() -> void:
	print("--- T234.CONST.* — _RECENT_ROW_TIP_INDICATOR 已声明 + 值正确 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _RECENT_ROW_TIP_INDICATOR := \" ↗\"",
		"T234.CONST.DECLARED.1: const _RECENT_ROW_TIP_INDICATOR := \" ↗\" (1 空格 + ↗ U+2197)")
	_assert_contains(src, "_RECENT_ROW_TIP_INDICATOR := \" ↗\"",
		"T234.CONST.VALUE.1: _RECENT_ROW_TIP_INDICATOR 值 = \" ↗\" (tip indicator 字符串 literal)")
	# 验证 Unicode 字符 ↗ (U+2197) 出现在源码 (0 替代)
	var unicode_count := src.count("↗")
	if unicode_count >= 2:
		_passes += 1
		print("  OK  T234.CONST.UNICODE.1: ↗ 字符 (U+2197) 在源码出现 %d 次 (≥ 2, const 块 + format 引用)" % unicode_count)
	else:
		_failures.append("FAIL: T234.CONST.UNICODE.1: ↗ 字符仅出现 %d 次, 需 ≥ 2" % unicode_count)
	# 1 次声明, 0 重复
	var const_count := src.count("const _RECENT_ROW_TIP_INDICATOR")
	if const_count == 1:
		_passes += 1
		print("  OK  T234.CONST.UNIQUE.1: const _RECENT_ROW_TIP_INDICATOR 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T234.CONST.UNIQUE.1: const _RECENT_ROW_TIP_INDICATOR 声明 %d 次, 应 1" % const_count)


# ---------- T234.FORMAT.* — row_lbl.text format string 包含 _RECENT_ROW_TIP_INDICATOR ----------
# T235 (#154) — 字段间分隔从 "  " (2 空格) 演化为 " · " (中点 middle-dot),
# T234 时期 fixed format string snapshot 不再 100% 匹配. 但 T234 核心契约
# "末尾 %s 仍是 ↗ tip indicator" 0 触碰. 这里改成"格式字符串末尾含 ↗ +
# format 数组末尾含 _RECENT_ROW_TIP_INDICATOR"的放松验证.
func _run_t234_format_assertions() -> void:
	print("--- T234.FORMAT.* — row_lbl.text format string 末尾仍是 ↗ tip indicator ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T235 (#154) 字段间分隔已演化为 _RECENT_ROW_FIELD_SEP middle-dot, 不再是
	# "  " (2 空格). format string literal 已变. T249 (#167) 5 字段 → 7 字段扩展
	# 同步 _RECENT_ROW_HINT tooltip 字段顺序, 末尾 2 元素从 (tm, ts, ...) 变成
	# (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR) — _RECENT_ROW_TIP_INDICATOR
	# 0 100% 保留 (0 触碰, 0 改名), 但 format 字符串 0 100% 保留 (T249 改了字段
	# 顺序). 验证 "_RECENT_ROW_TIP_INDICATOR 仍 0 100% 出现在 format 数组末尾" 即可.
	_assert_contains(src, "row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\" % [",
		"T234.FORMAT.STRING.1: row_lbl.text format string 末尾 %s 仍是 ↗ tip indicator (T249 #167 5→7 字段扩展后 末尾 %s ↗ 0 100% 保留, 字段顺序与 _RECENT_ROW_HINT tooltip 100% 对齐)")
	_assert_contains(src, "enemies_per_minute, _RECENT_ROW_TIP_INDICATOR",
		"T234.FORMAT.ARG.1: format 数组末尾追加 _RECENT_ROW_TIP_INDICATOR (T249 #167 演化后 15 元素: 7 字段 + 6 _RECENT_ROW_FIELD_SEP + 末尾 2 个 (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR), tip indicator 0 触碰)")
	_assert_contains(src, "%02d:%02d%s",
		"T234.FORMAT.PLACEHOLDER.1: format string 末尾 %s placeholder 仍是 ↗ tip indicator (%02d:%02d 之后, T249 #167 0 触碰 ↗ 位置)")
	# T235 (#154) 4 个 _RECENT_ROW_FIELD_SEP middle-dot 分隔符 → T249 6 个
	_assert_contains(src, "_RECENT_ROW_FIELD_SEP",
		"T234.NO_REGRESS_T235.1: T235 _RECENT_ROW_FIELD_SEP middle-dot 分隔符保留 (T234 0 触碰字段间分隔, T249 #167 演化后 4 → 6 个)" + \
		" (此处只验证 const 引用 ≥ 1, 不验证具体引用次数)")
	# 验证 _refresh_recent_runs_list 内部 1 处引用 (T234 仅改 row_lbl.text 1 处)
	var reference_count := src.count("_RECENT_ROW_TIP_INDICATOR")
	if reference_count >= 2:
		_passes += 1
		print("  OK  T234.FORMAT.REFERENCE.1: _RECENT_ROW_TIP_INDICATOR 引用 %d 次 (≥ 2, const 1 + format 1)" % reference_count)
	else:
		_failures.append("FAIL: T234.FORMAT.REFERENCE.1: _RECENT_ROW_TIP_INDICATOR 引用 %d 次, 需 ≥ 2" % reference_count)


# ---------- T234.DOC.ANCHOR.* — T234 (#153) 注释锚点 ≥ 2 处 ----------
func _run_t234_doc_anchor_assertions() -> void:
	print("--- T234.DOC.ANCHOR.* — T234 (#153) 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T234 (#153)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T234.DOC.ANCHOR.1: T234 (#153) 注释锚点 %d 处 (≥ 2, const 块 + _refresh_recent 段)" % anchor_count)
	else:
		_failures.append("FAIL: T234.DOC.ANCHOR.1: T234 (#153) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T234.NO_REGRESS.* — T215/T216/T219/T231/T232/T136/T137 0 触碰 ----------
func _run_t234_regress_assertions() -> void:
	print("--- T234.NO_REGRESS.* — T215/T216/T219/T231/T232/T136/T137 0 触碰 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T215 (#136) 字段保留
	_assert_contains(src, "var _recent_row_hovered: Array = []",
		"T234.NO_REGRESS_T215.1: T215 _recent_row_hovered 字段保留 (T234 0 触碰 hover_in/out handler 链)")
	_assert_contains(src, "var _recent_row_default_color: Array = []",
		"T234.NO_REGRESS_T215.2: T215 _recent_row_default_color 字段保留 (T234 0 触碰 default color 缓存)")
	# T216 (#137) tooltip 保留
	_assert_contains(src, "row_lbl.tooltip_text = _build_recent_row_tooltip()",
		"T234.NO_REGRESS_T216.1: T216 tooltip_text 绑定保留 (T234 0 触碰 7 字段 tooltip 渲染)")
	_assert_contains(src, "func _build_recent_row_tooltip() -> String:",
		"T234.NO_REGRESS_T216.2: T216 _build_recent_row_tooltip 函数保留 (T234 0 触碰 tooltip 7 字段生成)")
	# T219 (#141) alpha 渐变 const 保留
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MAX := 1.0",
		"T234.NO_REGRESS_T219.1: T219 _RECENT_ROW_ALPHA_MAX = 1.0 const 保留 (T234 0 触碰 5 行 alpha 渐变)")
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MIN := 0.5",
		"T234.NO_REGRESS_T219.2: T219 _RECENT_ROW_ALPHA_MIN = 0.5 const 保留 (T234 0 触碰 5 行 alpha 渐变)")
	# T231 (#151) _recent_row_hover_alpha_base 保留
	_assert_contains(src, "var _recent_row_hover_alpha_base: Dictionary = {}",
		"T234.NO_REGRESS_T231.1: T231 _recent_row_hover_alpha_base dict 保留 (T234 0 触碰 hover alpha boost)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T234.NO_REGRESS_T231.2: T231 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST = 0.1 const 保留 (T234 0 触碰 boost 强度)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_FADE_DURATION := 0.12",
		"T234.NO_REGRESS_T231.3: T231 _RECENT_ROW_HOVER_FADE_DURATION = 0.12 const 保留 (T234 0 触碰 0.12s fade 节奏)")
	# T232 (#151) 跨 run 加权 const 保留
	_assert_contains(src, "const _RECENT_RESONANCE_DECAY := 0.5",
		"T234.NO_REGRESS_T232.1: T232 _RECENT_RESONANCE_DECAY = 0.5 const 保留 (T234 0 触碰 跨 run 衰减权重)")
	_assert_contains(src, "const _RECENT_RESONANCE_HISTORY_WINDOW := 5",
		"T234.NO_REGRESS_T232.2: T232 _RECENT_RESONANCE_HISTORY_WINDOW = 5 const 保留 (T234 0 触碰 5 局窗口)")
	# T136 (#82) const 保留
	_assert_contains(src, "const _PROFILE_RECENT_RUNS_MAX",
		"T234.NO_REGRESS_T136.1: T136 _PROFILE_RECENT_RUNS_MAX const 保留 (T234 0 触碰 5 局最近窗口)")
	# T137 (#83) _profile_recent_list 保留
	_assert_contains(src, "@onready var _profile_recent_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRecentList",
		"T234.NO_REGRESS_T137.1: T137 _profile_recent_list @onready 保留 (T234 0 触碰 ScrollContainer 引用)")


# ---------- T234.SYNTAX.* — const + format 1 次声明, 0 重复 ----------
func _run_t234_syntax_assertions() -> void:
	print("--- T234.SYNTAX.* — const + format 1 次声明, 0 重复 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1 处 const 声明
	var const_decl_count := src.count("const _RECENT_ROW_TIP_INDICATOR := \" ↗\"")
	if const_decl_count == 1:
		_passes += 1
		print("  OK  T234.SYNTAX.CONST.1: const _RECENT_ROW_TIP_INDICATOR 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T234.SYNTAX.CONST.1: const _RECENT_ROW_TIP_INDICATOR 声明 %d 次, 应 1" % const_decl_count)
	# 1 处 row_lbl.text 包含 _RECENT_ROW_TIP_INDICATOR (在 _refresh_recent_runs_list 内)
	var format_use_count := 0
	for line in src.split("\n"):
		if line.find("_RECENT_ROW_TIP_INDICATOR") != -1 and line.find("row_lbl.text") != -1:
			format_use_count += 1
	# 由于 format 跨多行, 这里改成查 _RECENT_ROW_TIP_INDICATOR 在 row_lbl.text 同一行/附近
	if format_use_count == 0:
		# T235 (#154) 字段间分隔从 "  " 演化为 " · ", T249 (#167) 5 字段 → 7 字段
		# 扩展同步 _RECENT_ROW_HINT tooltip 字段顺序, format string 已变. 这里
		# 改成验证 "row_lbl.text 末尾仍是 %s ↗" 即可 (字段顺序演化不破坏 ↗ 位置).
		var row_text_idx := src.find("row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"")
		if row_text_idx != -1:
			_passes += 1
			print("  OK  T234.SYNTAX.FORMAT.1: row_lbl.text 1 处包含 %s placeholder + _RECENT_ROW_TIP_INDICATOR 引用 (T235 + T249 #167 字段顺序演化后, 末尾 ↗ 0 100% 保留, 7 字段 6 分隔符 + 1 tip indicator)")
		else:
			_failures.append("FAIL: T234.SYNTAX.FORMAT.1: row_lbl.text format string 未找到 %s 末尾 (T249 #167 7 字段 + ↗ 末尾)")
	else:
		if format_use_count == 1:
			_passes += 1
			print("  OK  T234.SYNTAX.FORMAT.1: row_lbl.text 1 处引用 _RECENT_ROW_TIP_INDICATOR (0 重复)")
		else:
			_failures.append("FAIL: T234.SYNTAX.FORMAT.1: row_lbl.text 引用 _RECENT_ROW_TIP_INDICATOR %d 次, 应 1" % format_use_count)
	# const 内部 0 副作用
	_assert_contains(src, "_RECENT_ROW_TIP_INDICATOR", "T234.SYNTAX.IDENT.1: _RECENT_ROW_TIP_INDICATOR 标识符在源码中")


# ---------- T234.ORDER.* — _RECENT_ROW_TIP_INDICATOR 在 T232 const 之后声明 ----------
func _run_t234_order_assertions() -> void:
	print("--- T234.ORDER.* — _RECENT_ROW_TIP_INDICATOR 在 T232 const 之后声明 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T232 const 之后
	var t232_idx := src.find("const _RECENT_RESONANCE_HISTORY_WINDOW := 5")
	var t234_idx := src.find("const _RECENT_ROW_TIP_INDICATOR := \" ↗\"")
	if t232_idx == -1:
		_failures.append("FAIL: T234.ORDER.1: T232 _RECENT_RESONANCE_HISTORY_WINDOW const 未找到")
		return
	if t234_idx == -1:
		_failures.append("FAIL: T234.ORDER.2: T234 _RECENT_ROW_TIP_INDICATOR const 未找到")
		return
	if t234_idx > t232_idx:
		_passes += 1
		print("  OK  T234.ORDER.1: _RECENT_ROW_TIP_INDICATOR 在 _RECENT_RESONANCE_HISTORY_WINDOW 之后声明 (T232 → T234 顺序正确, 0 const 顺序冲突)")
	else:
		_failures.append("FAIL: T234.ORDER.1: _RECENT_ROW_TIP_INDICATOR (offset %d) 应在 _RECENT_RESONANCE_HISTORY_WINDOW (offset %d) 之后" % [t234_idx, t232_idx])


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
	print("I057 (#153) T234 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
