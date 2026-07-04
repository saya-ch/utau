extends SceneTree
## I059 (#158) — T240 ProfileRecentList 5 行 hover font_color 提亮 0.12s tween fade (T215 1 步升级, 同步 T231 alpha boost 节奏) 冒烟测试
##
## 覆盖 #158 任务 T240 原子化提交:
##
## === T240 — ProfileRecentList 5 行 hover font_color 提亮 0.12s tween fade (T215 snap 升级) ===
## - T240.CONST.DURATION: _RECENT_ROW_FONT_COLOR_FADE_DURATION = 0.12 (与 T231 同节奏)
## - T240.FIELD.TWEEN: _recent_row_font_color_tween: Tween = null (5 行共享 1 个 tween 引用)
## - T240.HOVER_IN.TWEEN: _on_recent_row_hover_in 0.12s tween_property theme_override_colors/font_color → Color.WHITE
## - T240.HOVER_IN.KILL: 旧 _recent_row_font_color_tween.is_valid() 时 kill (防快速 hover 进出叠加)
## - T240.HOVER_IN.QUAD: TRANS_QUAD + EASE_OUT (与 T231 alpha boost 节奏一致)
## - T240.HOVER_OUT.TWEEN: _on_recent_row_hover_out 0.12s tween_property theme_override_colors/font_color → default_color
## - T240.HOVER_OUT.KILL: hover_out 同样 kill 旧 tween (5 行共享引用)
## - T240.SYNC.T231: 同步 T231 alpha boost 0.12s 节奏 (同 _RECENT_ROW_HOVER_FADE_DURATION)
## - T240.REGRESS.T215_1: T215 _recent_row_hovered 字段保留 (re-entrant guard 0 触碰)
## - T240.REGRESS.T215_2: T215 _recent_row_default_color 字段保留 (default restore 0 触碰)
## - T240.REGRESS.T231: T231 _RECENT_ROW_HOVER_FADE_DURATION = 0.12 const 保留 (0 改)
## - T240.REGRESS.T216: T216 tooltip_text 7 字段顺序 literal 保留 (0 改)
## - T240.REGRESS.T219: T219 _RECENT_ROW_ALPHA_MAX/MIN const 保留 (5 行 alpha 渐变 0 改)
## - T240.SYNTAX: 1 次 _on_recent_row_hover_in + 1 次 _on_recent_row_hover_out 声明
## - T240.DOC.ANCHOR: T240 (#158) 注释锚点 ≥ 3 处 (const + hover_in + hover_out)
## - T240.GODOT4_THEME_PATH: tween 必须走 "theme_override_colors/font_color" sub-property (Label
##   font_color 走 theme system, Godot 4 没有 font_color 直接属性, tween_property("font_color")
##   报 "Invalid access to property" 错误, 必须用 theme override 路径与 add_theme_color_override
##   同源)

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I059 (#158) — T240 RecentList 5 行 hover font_color 0.12s tween fade (T215 1 步升级) ===")
	_run_t240_const_assertions()
	_run_t240_field_assertions()
	_run_t240_hover_in_assertions()
	_run_t240_hover_out_assertions()
	_run_t240_sync_assertions()
	_run_t240_regress_assertions()
	_run_t240_syntax_assertions()
	_run_t240_doc_anchor_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I059 (#158) T240 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T240 — ProfileRecentList 5 行 hover font_color 0.12s tween fade =====================

# ---------- T240.CONST.* — 节奏参数 (与 T231 alpha boost 同步) ----------
func _run_t240_const_assertions() -> void:
	print("--- T240.CONST.* — 节奏参数 (与 T231 alpha boost 同步 0.12s) ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12",
		"T240.CONST.DURATION.1: _RECENT_ROW_FONT_COLOR_FADE_DURATION = 0.12 (与 T231 _RECENT_ROW_HOVER_FADE_DURATION 同值, 同步节奏 5 行 hover 视觉组连贯)")


# ---------- T240.FIELD.* — 5 行共享 tween 引用 ----------
func _run_t240_field_assertions() -> void:
	print("--- T240.FIELD.* — 5 行共享 tween 引用 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "var _recent_row_font_color_tween: Tween = null",
		"T240.FIELD.TWEEN.1: _recent_row_font_color_tween: Tween = null (5 行 row 共享 1 个 tween 引用, mouse_exited → mouse_entered 快速切换时 kill 旧 tween 防叠加)")


# ---------- T240.HOVER_IN.* — _on_recent_row_hover_in 0.12s tween 提亮到 WHITE ----------
func _run_t240_hover_in_assertions() -> void:
	print("--- T240.HOVER_IN.* — _on_recent_row_hover_in 0.12s tween font_color → Color.WHITE ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_recent_row_hover_in(idx: int) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T240.HOVER_IN.1: _on_recent_row_hover_in 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 3500)
	# tween 提亮到 Color.WHITE 0.12s (走 theme_override_colors/font_color sub-property)
	_assert_contains(fn_body, "tween_property(row, \"theme_override_colors/font_color\", Color.WHITE, _RECENT_ROW_FONT_COLOR_FADE_DURATION)",
		"T240.HOVER_IN.TWEEN.1: 0.12s tween_property theme_override_colors/font_color → Color.WHITE (T215 旧 add_theme_color_override snap 升级为 0.12s 渐变, Godot 4 Label font_color 走 theme system 必须走 override 路径)")
	# kill 旧 tween
	_assert_contains(fn_body, "_recent_row_font_color_tween.is_valid()",
		"T240.HOVER_IN.KILL.1: kill 旧 tween 守卫 (5 行共享 1 个 tween, mouse_exited → mouse_entered 快速切换时防叠加撕裂)")
	_assert_contains(fn_body, "_recent_row_font_color_tween.kill()",
		"T240.HOVER_IN.KILL.2: 旧 tween 显式 kill (释放 tween 引用, 避免 modulate / font_color 双通道叠加)")
	# TRANS_QUAD + EASE_OUT
	_assert_contains(fn_body, "set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)",
		"T240.HOVER_IN.QUAD.1: TRANS_QUAD + EASE_OUT (与 T231 alpha boost 0.12s 节奏一致, 跨面板 hover 反馈同节奏)")


# ---------- T240.HOVER_OUT.* — _on_recent_row_hover_out 0.12s tween 渐回 default_color ----------
func _run_t240_hover_out_assertions() -> void:
	print("--- T240.HOVER_OUT.* — _on_recent_row_hover_out 0.12s tween font_color → default_color ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_recent_row_hover_out(idx: int) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T240.HOVER_OUT.1: _on_recent_row_hover_out 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 2500)
	# tween 渐回 default_color 0.12s (走 theme_override_colors/font_color sub-property)
	_assert_contains(fn_body, "tween_property(row, \"theme_override_colors/font_color\", default_color, _RECENT_ROW_FONT_COLOR_FADE_DURATION)",
		"T240.HOVER_OUT.TWEEN.1: 0.12s tween_property theme_override_colors/font_color → default_color (T215 旧 add_theme_color_override snap 升级为 0.12s 渐回, 与 hover_in tween 双向对称)")
	# kill 旧 tween (与 hover_in 一致)
	_assert_contains(fn_body, "_recent_row_font_color_tween.is_valid()",
		"T240.HOVER_OUT.KILL.1: kill 旧 tween 守卫 (与 hover_in 共享 1 个 tween 引用, hover_out 前 kill)")
	_assert_contains(fn_body, "_recent_row_font_color_tween.kill()",
		"T240.HOVER_OUT.KILL.2: 旧 tween 显式 kill (双向对称: hover_in 杀 hover_out 旧 tween, hover_out 杀 hover_in 旧 tween)")


# ---------- T240.SYNC.* — 与 T231 alpha boost 0.12s 同步 ----------
func _run_t240_sync_assertions() -> void:
	print("--- T240.SYNC.* — 与 T231 alpha boost 0.12s 同步 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 同步 T231 _RECENT_ROW_HOVER_FADE_DURATION const (T240 节奏 = T231 节奏 = 0.12)
	_assert_contains(src, "const _RECENT_ROW_HOVER_FADE_DURATION := 0.12",
		"T240.SYNC.T231.1: T231 _RECENT_ROW_HOVER_FADE_DURATION = 0.12 const 保留 (T240 与 T231 共享 0.12s 节奏, 5 行 row hover 时 (1) theme_override_colors/font_color tween + (2) modulate:a tween 同起同终)")
	# T240 font_color tween 与 T231 alpha tween 在同 1 行 row 上同时存在
	var in_idx := src.find("func _on_recent_row_hover_in(idx: int) -> void:")
	if in_idx != -1:
		var in_body := src.substr(in_idx, 3500)
		var has_font_tween := in_body.find("tween_property(row, \"theme_override_colors/font_color\"") != -1
		var has_alpha_tween := in_body.find("tween_property(row, \"modulate:a\"") != -1
		if has_font_tween and has_alpha_tween:
			_passes += 1
			print("  OK  T240.SYNC.T231.2: 同 row hover_in 同时存在 theme_override_colors/font_color tween + modulate:a tween (双通道同步起点, 视觉组连贯)")
		else:
			_failures.append("FAIL: T240.SYNC.T231.2: hover_in 双通道 tween 不全 — theme_override_colors/font_color=%s, modulate:a=%s" % [has_font_tween, has_alpha_tween])
	# T240 font_color tween 与 T231 alpha tween 在 hover_out 上同时存在
	var out_idx := src.find("func _on_recent_row_hover_out(idx: int) -> void:")
	if out_idx != -1:
		var out_body := src.substr(out_idx, 2500)
		var has_font_tween := out_body.find("tween_property(row, \"theme_override_colors/font_color\"") != -1
		var has_alpha_tween := out_body.find("tween_property(row, \"modulate:a\"") != -1
		if has_font_tween and has_alpha_tween:
			_passes += 1
			print("  OK  T240.SYNC.T231.3: 同 row hover_out 同时存在 theme_override_colors/font_color tween + modulate:a tween (双通道同步终点, hover 退出 0 视觉差)")
		else:
			_failures.append("FAIL: T240.SYNC.T231.3: hover_out 双通道 tween 不全 — theme_override_colors/font_color=%s, modulate:a=%s" % [has_font_tween, has_alpha_tween])


# ---------- T240.REGRESS.* — T215 + T231 + T216 + T219 0 改 ----------
func _run_t240_regress_assertions() -> void:
	print("--- T240.REGRESS.* — T215 + T231 + T216 + T219 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T215 字段 0 改
	_assert_contains(src, "_recent_row_hovered",
		"T240.REGRESS.T215.1: T215 _recent_row_hovered 字段保留 (5 行 re-entrant guard 0 触碰)")
	_assert_contains(src, "_recent_row_default_color",
		"T240.REGRESS.T215.2: T215 _recent_row_default_color 字段保留 (5 行 restore 默认色逻辑 0 触碰)")
	# T231 const 0 改
	_assert_contains(src, "const _RECENT_ROW_HOVER_FADE_DURATION := 0.12",
		"T240.REGRESS.T231.1: T231 _RECENT_ROW_HOVER_FADE_DURATION = 0.12 const 保留 (T240 不动 T231 alpha 节奏)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T240.REGRESS.T231.2: T231 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST = 0.1 const 保留 (T240 不动 T231 alpha boost 量)")
	# T216 tooltip_text 7 字段顺序 0 改 (T240 1 步升级仅 hover handler, tooltip 0 改)
	var tooltip_idx := src.find("func _build_recent_row_hint")
	if tooltip_idx == -1:
		# 兼容其它命名 — 检 _RECENT_ROW_HINT 常量 / _RECENT_ROW_HINT_FIELDS 7 字段保留
		_assert_contains(src, "_RECENT_ROW_HINT",
			"T240.REGRESS.T216.1: T216 _RECENT_ROW_HINT tooltip 7 字段顺序 0 改 (T240 仅升级 hover handler, tooltip 路径 0 触碰)")
	else:
		var tooltip_body := src.substr(tooltip_idx, 4000)
		_assert_contains(tooltip_body, "_RECENT_ROW_HINT",
			"T240.REGRESS.T216.1: T216 _RECENT_ROW_HINT tooltip 7 字段顺序 0 改 (T240 仅升级 hover handler, tooltip 路径 0 触碰)")
	# T219 5 行 alpha 渐变 const 0 改
	_assert_contains(src, "_RECENT_ROW_ALPHA_MAX",
		"T240.REGRESS.T219.1: T219 _RECENT_ROW_ALPHA_MAX const 保留 (5 行 alpha 渐变基础参数 0 触碰)")
	_assert_contains(src, "_RECENT_ROW_ALPHA_MIN",
		"T240.REGRESS.T219.2: T219 _RECENT_ROW_ALPHA_MIN const 保留 (5 行 alpha 渐变基础参数 0 触碰)")


# ---------- T240.SYNTAX.* — 1 次 _on_recent_row_hover_in + 1 次 _on_recent_row_hover_out 声明 ----------
func _run_t240_syntax_assertions() -> void:
	print("--- T240.SYNTAX.* — 1 次 hover_in + 1 次 hover_out 声明 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1 次声明 _on_recent_row_hover_in
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
		print("  OK  T240.SYNTAX.1: _on_recent_row_hover_in 1 次声明 (T215 + T231 + T240 共用, 无重复)")
	else:
		_failures.append("FAIL: T240.SYNTAX.1: _on_recent_row_hover_in %d 次声明, 应 1" % hover_in_count)
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
		print("  OK  T240.SYNTAX.2: _on_recent_row_hover_out 1 次声明 (T215 + T231 + T240 共用, 无重复)")
	else:
		_failures.append("FAIL: T240.SYNTAX.2: _on_recent_row_hover_out %d 次声明, 应 1" % hover_out_count)


# ---------- T240.DOC.ANCHOR.* — T240 (#158) 注释锚点 ≥ 3 处 ----------
func _run_t240_doc_anchor_assertions() -> void:
	print("--- T240.DOC.ANCHOR.* — T240 (#158) 注释锚点 ≥ 3 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T240 (#158)") != -1:
			anchor_count += 1
	if anchor_count >= 3:
		_passes += 1
		print("  OK  T240.DOC.ANCHOR.1: T240 (#158) 注释锚点 %d 处 (≥ 3, 涵盖 const/hover_in/hover_out 3 段)" % anchor_count)
	else:
		_failures.append("FAIL: T240.DOC.ANCHOR.1: T240 (#158) 注释锚点仅 %d 处, 需 ≥ 3" % anchor_count)


# ===================== helpers =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % label)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [label, needle])


func _print_summary() -> void:
	print("--- I059 (#158) T240 smoke summary ---")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for fail in _failures:
		print(fail)
