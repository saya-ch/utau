extends SceneTree
## I055 (#151) — T231 ProfileRecentList 5 局行 hover +0.1 alpha boost + T232 顶级
## 行第 4 块 "近期共鸣 (近因加权)" 5 局时间衰减权重 冒烟测试
##
## 覆盖 #151 任务 T231 + T232 原子化提交:
##
## === T231 — ProfileRecentList 5 局行 hover +0.1 alpha boost (T215 1 步升级) ===
## - T231.CONST.BOOST: _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST = 0.1 (与 T226 同值)
## - T231.CONST.DURATION: _RECENT_ROW_HOVER_FADE_DURATION = 0.12 (T226 同节奏)
## - T231.FIELD.DICT: _recent_row_hover_alpha_base: Dictionary = {} (row → base)
## - T231.HOVER_IN.READ_BASE: _on_recent_row_hover_in 读 _recent_row_hover_alpha_base
## - T231.HOVER_IN.CLAMP: clampf(base + boost, 0, 1) (1.0+0.1=1.0, 0.5+0.1=0.6)
## - T231.HOVER_IN.MODULATE: modulate tween 终点 modulate:a boosted_alpha
## - T231.HOVER_IN.QUAD: TRANS_QUAD + EASE_OUT (与 T226/T111 0.12s 节奏一致)
## - T231.HOVER_OUT.READ_BASE: _on_recent_row_hover_out 读 _recent_row_hover_alpha_base
## - T231.HOVER_OUT.MODULATE: modulate:a tween 0.12s 回 base
## - T231.REFRESH.SAVE: _refresh_recent_runs_list 存 _recent_row_hover_alpha_base[i] = row_alpha
## - T231.REFRESH.CLEAR: _refresh_recent_runs_list 起始 _recent_row_hover_alpha_base.clear()
## - T231.DOC.ANCHOR: T231 (#151) 注释锚点 ≥ 2 处
## - T231.NO_REGRESS: T215 5 行 hover handler + _recent_row_hovered/default_color 0 改 (T215 字体提亮
##   走 T240 0.12s tween_property path, 旧 add_theme_color_override(\"font_color\", Color.WHITE) snap
##   路径被 T240 替代 — T231 REGRESS.T215.1 改检 T240 0.12s tween_property("font_color", Color.WHITE))
## - T231.NO_REGRESS_T215: T215 5 行 hover handler + _recent_row_hovered/default_color 0 改
## - T231.NO_REGRESS_T219: T219 5 行 alpha 渐变 1.0/0.875/0.75/0.625/0.5 0 改
## - T231.SYNTAX: _on_recent_row_hover_in / _out 1 次声明, tween.create_tween() 调 2 次
##
## === T232 — 顶级行第 4 块 "近期共鸣 (近因加权)" 5 局时间衰减权重 ===
## - T232.CONST.DECAY: _RECENT_RESONANCE_DECAY = 0.5 (新→旧指数衰减 0.5^i)
## - T232.CONST.WINDOW: _RECENT_RESONANCE_HISTORY_WINDOW = 5 (5 局最近加权)
## - T232.FIELD.ONREADY: _profile_recent_resonance 节点 @onready 就位
## - T232.TSCN.NODE: tscn ProfileRecentResonance Label 节点存在
## - T232.TSCN.COLOR: tscn 4 顶级行 Glass Cyan #69C7CE 仍就位
## - T232.REFRESH.NFMT: "★ 近期共鸣 (近因加权) — %.1f 碎/房 (n=%d, 衰 %.1f) ★" literal
## - T232.REFRESH.EMPTY: history 空路径 "★ 近期共鸣 (近因加权) —  ★" 占位
## - T232.REFRESH.WEIGHT: 5 局加权公式: w=0.5^i (新→旧), sum(w*shards)/sum(w*rooms)
## - T232.REFRESH.FALLBACK: 5 局全 0 房 → "(无房记录, n=N)" fallback
## - T232.REGRESS.T201: T201 顶级行 "★ 平均共鸣" 0 改
## - T232.REGRESS.T209: T209 顶级行 "★ 最长单房" 0 改
## - T232.DOC.ANCHOR: T232 (#151) 注释锚点 ≥ 3 处
## - T232.SYNTAX: 1 处 @onready _profile_recent_resonance 节点路径

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"
const PAUSE_MENU_TSCN := "res://src/scenes/pause_menu.tscn"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I055 (#151) — T231 RecentList 5 行 hover +0.1 alpha boost + T232 4th top row weighted ===")
	_run_t231_const_assertions()
	_run_t231_field_assertions()
	_run_t231_hover_in_assertions()
	_run_t231_hover_out_assertions()
	_run_t231_refresh_assertions()
	_run_t231_regress_assertions()
	_run_t231_doc_anchor_assertions()
	_run_t231_syntax_assertions()
	_run_t232_const_assertions()
	_run_t232_field_assertions()
	_run_t232_tscn_assertions()
	_run_t232_refresh_assertions()
	_run_t232_regress_assertions()
	_run_t232_doc_anchor_assertions()
	_run_t232_syntax_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I055 (#151) T231 + T232 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T231 — ProfileRecentList 5 行 hover +0.1 alpha boost =====================

# ---------- T231.CONST.* — boost + 节奏参数 ----------
func _run_t231_const_assertions() -> void:
	print("--- T231.CONST.* — boost + 节奏参数 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T231.CONST.BOOST.1: _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST = 0.1 (与 T226 _SLOT_HOVER_BRIGHT_ALPHA_BOOST 同值, 跨面板 hover 反馈一致)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_FADE_DURATION := 0.12",
		"T231.CONST.DURATION.1: _RECENT_ROW_HOVER_FADE_DURATION = 0.12 (T226 0.12s 节奏同步, 5 行各自 0.12s 渐变)")


# ---------- T231.FIELD.* — base alpha 字典 ----------
func _run_t231_field_assertions() -> void:
	print("--- T231.FIELD.* — base alpha 字典 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "var _recent_row_hover_alpha_base: Dictionary = {}",
		"T231.FIELD.DICT.1: _recent_row_hover_alpha_base: Dictionary = {} (row → base_alpha, T226 _slot_hover_alpha_base 同模式)")


# ---------- T231.HOVER_IN.* — _on_recent_row_hover_in 改造 ----------
func _run_t231_hover_in_assertions() -> void:
	print("--- T231.HOVER_IN.* — _on_recent_row_hover_in 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_recent_row_hover_in(idx: int) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T231.HOVER_IN.1: _on_recent_row_hover_in 函数未找到")
		return
	# _on_recent_row_hover_in → _on_recent_row_hover_out 跨 30 行注释, 取 3000 字符保险
	var fn_body := src.substr(fn_idx, 3000)
	_assert_contains(fn_body, "if _recent_row_hover_alpha_base.has(idx):",
		"T231.HOVER_IN.READ_BASE.1: _on_recent_row_hover_in 守卫 _recent_row_hover_alpha_base.has(idx) (defensive, default 1.0 fallback)")
	_assert_contains(fn_body, "base_alpha = float(_recent_row_hover_alpha_base[idx])",
		"T231.HOVER_IN.READ_BASE.2: _on_recent_row_hover_in 读 base_alpha = float(_recent_row_hover_alpha_base[idx])")
	_assert_contains(fn_body, "clampf(base_alpha + _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST, 0.0, 1.0)",
		"T231.HOVER_IN.CLAMP.1: clampf(base + boost, 0, 1) (1.0+0.1=1.0 不变, 0.5+0.1=0.6 '微微亮一阶')")
	# tween 链: 跨行拆分, 检查 modulate:a tween + 0.12s duration 2 个关键 token
	_assert_contains(fn_body, "boosted_alpha, _RECENT_ROW_HOVER_FADE_DURATION",
		"T231.HOVER_IN.MODULATE.1: modulate:a tween 0.12s 终点 boosted_alpha (T215 1 步升级 alpha 反馈层)")
	_assert_contains(fn_body, "set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)",
		"T231.HOVER_IN.QUAD.1: TRANS_QUAD + EASE_OUT (与 T226/T111 0.12s quad-out 节奏一致)")


# ---------- T231.HOVER_OUT.* — _on_recent_row_hover_out 改造 ----------
func _run_t231_hover_out_assertions() -> void:
	print("--- T231.HOVER_OUT.* — _on_recent_row_hover_out 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_recent_row_hover_out(idx: int) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T231.HOVER_OUT.1: _on_recent_row_hover_out 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 2000)
	_assert_contains(fn_body, "if _recent_row_hover_alpha_base.has(idx):",
		"T231.HOVER_OUT.READ_BASE.1: _on_recent_row_hover_out 守卫 _recent_row_hover_alpha_base.has(idx)")
	_assert_contains(fn_body, "base_alpha = float(_recent_row_hover_alpha_base[idx])",
		"T231.HOVER_OUT.READ_BASE.2: _on_recent_row_hover_out 读 base_alpha")
	_assert_contains(fn_body, "base_alpha, _RECENT_ROW_HOVER_FADE_DURATION",
		"T231.HOVER_OUT.MODULATE.1: modulate:a tween 0.12s 回到 base (hover_out 渐回原 alpha 双向对称)")


# ---------- T231.REFRESH.* — _refresh_recent_runs_list 存 base alpha ----------
func _run_t231_refresh_assertions() -> void:
	print("--- T231.REFRESH.* — _refresh_recent_runs_list 存 base alpha ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _refresh_recent_runs_list() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T231.REFRESH.1: _refresh_recent_runs_list 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 8000)
	_assert_contains(fn_body, "_recent_row_hover_alpha_base.clear()",
		"T231.REFRESH.CLEAR.1: _refresh_recent_runs_list 起始 clear dict (每次 _refresh 重建 5 行, 旧 entry 残留 0 触碰)")
	_assert_contains(fn_body, "_recent_row_hover_alpha_base[i] = row_alpha",
		"T231.REFRESH.SAVE.1: 存每行 base_alpha 到 dict (1.0/0.875/0.75/0.625/0.5 T219 alpha 渐变 base 值)")


# ---------- T231.REGRESS.* — T215 + T219 0 改 ----------
func _run_t231_regress_assertions() -> void:
	print("--- T231.REGRESS.* — T215 + T219 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T215 font_color 提亮 #158 T240 升级: 旧 add_theme_color_override(\"font_color\", Color.WHITE)
	# snap 路径替换为 0.12s tween_property (T215 1 步升级到 T240). T231 REGRESS 检 T240 新路径
	# 就位, 5 行 hover font_color 提亮 0.12s 渐变到 Color.WHITE (走 theme_override_colors/font_color
	# sub-property, Godot 4 Label font_color 走 theme system, tween 必须走 override 路径).
	# T215 _recent_row_hovered / _recent_row_default_color 字段 0 改 (re-entrant guard +
	# restore 默认色逻辑保留).
	_assert_contains(src, "tween_property(row, \"theme_override_colors/font_color\", Color.WHITE, _RECENT_ROW_FONT_COLOR_FADE_DURATION)",
		"T231.REGRESS.T215.1: T240 0.12s tween_property theme_override_colors/font_color → Color.WHITE 替代 T215 旧 add_theme_color_override snap (T215 1 步升级到 T240, 同步 T231 alpha boost 节奏)")
	# T215 字段 (5 行 hover state) 0 改
	_assert_contains(src, "_recent_row_hovered",
		"T231.REGRESS.T215.2: T215 _recent_row_hovered 字段保留 (5 行 re-entrant guard 0 触碰)")
	_assert_contains(src, "_recent_row_default_color",
		"T231.REGRESS.T215.3: T215 _recent_row_default_color 字段保留 (5 行 restore 默认色 0 触碰)")
	# T219 5 行 alpha 渐变 1.0/0.875/0.75/0.625/0.5 0 改
	_assert_contains(src, "_RECENT_ROW_ALPHA_MAX",
		"T231.REGRESS.T219.1: T219 _RECENT_ROW_ALPHA_MAX const 保留 (5 行 alpha 渐变基础参数 0 触碰)")
	_assert_contains(src, "_RECENT_ROW_ALPHA_MIN",
		"T231.REGRESS.T219.2: T219 _RECENT_ROW_ALPHA_MIN const 保留 (5 行 alpha 渐变基础参数 0 触碰)")


# ---------- T231.DOC.ANCHOR.* — T231 注释锚点 ≥ 2 处 ----------
func _run_t231_doc_anchor_assertions() -> void:
	print("--- T231.DOC.ANCHOR.* — T231 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T231 (#151)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T231.DOC.ANCHOR.1: T231 (#151) 注释锚点 %d 处 (≥ 2)" % anchor_count)
	else:
		_failures.append("FAIL: T231.DOC.ANCHOR.1: T231 (#151) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T231.SYNTAX.* — 无重复声明 + 正确 tween 调用 ----------
func _run_t231_syntax_assertions() -> void:
	print("--- T231.SYNTAX.* — 无重复声明 + 正确 tween 调用 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1 次声明 _on_recent_row_hover_in (T215 + T231 共用)
	var hover_in_count := 0
	var idx := 0
	while true:
		var found := src.find("func _on_recent_row_hover_in(", idx)
		if found == -1:
			break
		hover_in_count += 1
		idx = found + 1
	if hover_in_count == 1:
		_passes += 1
		print("  OK  T231.SYNTAX.1: _on_recent_row_hover_in 1 次声明 (T215 + T231 共用, 无重复)")
	else:
		_failures.append("FAIL: T231.SYNTAX.1: _on_recent_row_hover_in %d 次声明, 应 1" % hover_in_count)
	# 1 次声明 _on_recent_row_hover_out
	var hover_out_count := 0
	idx = 0
	while true:
		var found := src.find("func _on_recent_row_hover_out(", idx)
		if found == -1:
			break
		hover_out_count += 1
		idx = found + 1
	if hover_out_count == 1:
		_passes += 1
		print("  OK  T231.SYNTAX.2: _on_recent_row_hover_out 1 次声明 (T215 + T231 共用, 无重复)")
	else:
		_failures.append("FAIL: T231.SYNTAX.2: _on_recent_row_hover_out %d 次声明, 应 1" % hover_out_count)
	# create_tween() 调 2 次 (hover_in + hover_out 各 1)
	var tween_count := src.count("create_tween()")
	if tween_count >= 2:
		_passes += 1
		print("  OK  T231.SYNTAX.3: create_tween() 调 %d 次 (hover_in + hover_out 各 1, ≥ 2)" % tween_count)
	else:
		_failures.append("FAIL: T231.SYNTAX.3: create_tween() 调 %d 次, 期望 ≥ 2" % tween_count)


# ===================== T232 — 顶级行第 4 块 "近期共鸣 (近因加权)" =====================

# ---------- T232.CONST.* — 衰减 + 窗口参数 ----------
func _run_t232_const_assertions() -> void:
	print("--- T232.CONST.* — 衰减 + 窗口参数 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _RECENT_RESONANCE_DECAY := 0.5",
		"T232.CONST.DECAY.1: _RECENT_RESONANCE_DECAY = 0.5 (新→旧指数衰减 0.5^i, 早期 run 压制 80%)")
	_assert_contains(src, "const _RECENT_RESONANCE_HISTORY_WINDOW := 5",
		"T232.CONST.WINDOW.1: _RECENT_RESONANCE_HISTORY_WINDOW = 5 (5 局最近加权, 与 T219 5 行 RecentList 同窗口)")


# ---------- T232.FIELD.* — @onready 节点字段 ----------
func _run_t232_field_assertions() -> void:
	print("--- T232.FIELD.* — @onready 节点字段 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "@onready var _profile_recent_resonance: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRecentResonance",
		"T232.FIELD.ONREADY.1: @onready _profile_recent_resonance 节点路径就位 (T232 4 顶级行)")


# ---------- T232.TSCN.* — tscn 节点 + 颜色就位 ----------
func _run_t232_tscn_assertions() -> void:
	print("--- T232.TSCN.* — tscn 节点 + 颜色就位 ---")
	var tscn := _read_file(PAUSE_MENU_TSCN)
	_assert_contains(tscn, "[node name=\"ProfileRecentResonance\" type=\"Label\" parent=\"PlayerProfilePanel/ProfileMargin/ProfileVBox\"]",
		"T232.TSCN.NODE.1: tscn ProfileRecentResonance Label 节点就位 (T232 4 顶级行 4/4)")
	_assert_contains(tscn, "text = \"★ 近期共鸣 (近因加权) —  ★\"",
		"T232.TSCN.NODE.2: tscn ProfileRecentResonance 默认 text 占位 (T232 与 T201/T209 占位符同款)")
	# 4 顶级行 Glass Cyan #69C7CE 仍就位 (T232 新行也用同色, T201/T209 0 改)
	var cyan_count := tscn.count("Color(0.412, 0.78, 0.808, 1)")
	if cyan_count >= 4:
		_passes += 1
		print("  OK  T232.TSCN.COLOR.1: 4 顶级行 Glass Cyan #69C7CE 就位 (AvgResonance + BestStreak + LongestRoom + RecentResonance, count=%d)" % cyan_count)
	else:
		_failures.append("FAIL: T232.TSCN.COLOR.1: 4 顶级行 Glass Cyan 数量异常 (count=%d, 期望 >= 4)" % cyan_count)


# ---------- T232.REFRESH.* — _refresh_top_aggregate_rows 4th 行格式 ----------
func _run_t232_refresh_assertions() -> void:
	print("--- T232.REFRESH.* — _refresh_top_aggregate_rows 4th 行格式 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 完整格式: 含 (近因加权) 标签 + n=N + 衰 0.5 参数
	_assert_contains(src, "\"★ 近期共鸣 (近因加权) — %.1f 碎/房 (n=%d, 衰 %.1f) ★\"",
		"T232.REFRESH.NFMT.1: '★ 近期共鸣 (近因加权) — %.1f 碎/房 (n=%d, 衰 %.1f) ★' literal (T232 4 顶级行 4/4 加权格式)")
	# Empty 占位: 与 T201/T209 占位符同款
	_assert_contains(src, "\"★ 近期共鸣 (近因加权) —  ★\"",
		"T232.REFRESH.EMPTY.1: '★ 近期共鸣 (近因加权) —  ★' empty 占位 (T232 history 空路径)")
	# 加权公式: pow(_RECENT_RESONANCE_DECAY, float(i))
	_assert_contains(src, "pow(_RECENT_RESONANCE_DECAY, float(i))",
		"T232.REFRESH.WEIGHT.1: 5 局加权公式 pow(0.5, i) (新→旧指数衰减)")
	# Fallback: 全 0 房路径
	_assert_contains(src, "\"★ 近期共鸣 (近因加权) — (无房记录, n=%d) ★\"",
		"T232.REFRESH.FALLBACK.1: 5 局全 0 房 → '(无房记录, n=N)' fallback (T232 与 T201 fallback 风格一致)")


# ---------- T232.REGRESS.* — T201 + T209 0 改 ----------
func _run_t232_regress_assertions() -> void:
	print("--- T232.REGRESS.* — T201 + T209 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T201 顶级行 "★ 平均共鸣" 仍存在 (T232 新增第 4 行, T201 0 改)
	_assert_contains(src, "\"★ 平均共鸣 — %.1f 碎/房 (n=%d) ★\"",
		"T232.REGRESS.T201.1: T201 '★ 平均共鸣 — %.1f 碎/房 (n=%d) ★' literal 保留 (T232 不动 T201 跨 run 累计比)")
	# T209 顶级行 "★ 最长单房" 仍存在 (T209 0 改)
	_assert_contains(src, "\"★ 最长单房 %02d:%02d ★\"",
		"T232.REGRESS.T209.1: T209 '★ 最长单房 %02d:%02d ★' literal 保留 (T232 不动 T209 跨 run max)")
	# T201 empty 占位
	_assert_contains(src, "\"★ 平均共鸣 —  ★\"",
		"T232.REGRESS.T201.2: T201 empty 占位 literal 保留 (T232 history 空路径 4 顶级行 4/4 占位)")


# ---------- T232.DOC.ANCHOR.* — T232 注释锚点 ≥ 3 处 ----------
func _run_t232_doc_anchor_assertions() -> void:
	print("--- T232.DOC.ANCHOR.* — T232 注释锚点 ≥ 3 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T232 (#151)") != -1:
			anchor_count += 1
	if anchor_count >= 3:
		_passes += 1
		print("  OK  T232.DOC.ANCHOR.1: T232 (#151) 注释锚点 %d 处 (≥ 3, 涵盖 const/field/refresh 3 段)" % anchor_count)
	else:
		_failures.append("FAIL: T232.DOC.ANCHOR.1: T232 (#151) 注释锚点仅 %d 处, 需 ≥ 3" % anchor_count)


# ---------- T232.SYNTAX.* — 1 处 @onready + 1 处 history 取末尾 5 局 ----------
func _run_t232_syntax_assertions() -> void:
	print("--- T232.SYNTAX.* — 1 处 @onready + 1 处 history 取末尾 5 局 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1 处 @onready _profile_recent_resonance
	var onready_count := src.count("@onready var _profile_recent_resonance: Label")
	if onready_count == 1:
		_passes += 1
		print("  OK  T232.SYNTAX.1: @onready _profile_recent_resonance 1 次声明 (T232 4 顶级行 4/4)")
	else:
		_failures.append("FAIL: T232.SYNTAX.1: @onready _profile_recent_resonance %d 次声明, 应 1" % onready_count)
	# history 末尾 5 局 (新→旧 倒取)
	_assert_contains(src, "var h_idx: int = history.size() - 1 - i",
		"T232.SYNTAX.2: history 末尾 5 局倒取 (history.size() - 1 - i, i=0 最新 run, 与 T201/T209 同步遍历风格)")


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
	print("I055 (#151) T231 + T232 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
