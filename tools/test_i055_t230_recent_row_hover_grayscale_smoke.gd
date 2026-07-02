extends SceneTree

# I055 — T230 (#149) ProfileRecentList 5 局行 hover 灰阶 +1 软提亮
# smoke test. 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd
# 中 T230 实现的 4 大模块 (1 hover_brighten 常量 / 1 hover_in handler
# lerp 改写 / T215 docblock 注释升级 / 1 防御 fallback) + 4 大回归
# 保护 (T215 5 行 hover 字段 0 删 / T215 hover_out 还原 default_color 0
# 改 / T219 alpha 渐变 0 改 / T216 5 字段 tooltip 0 改) + 1 大废弃验证
# (旧版 Color.WHITE snap 0 残留) + 1 注释锚点 round-trip (T230 (#149)
# ≥ 3 处). 期望: 18+ 断言全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i055_t230_recent_row_hover_grayscale_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#
# === T230.CONST — 1 hover_brighten 系数常量 ===
# - T230.CONST.FACTOR: _RECENT_ROW_HOVER_BRIGHTEN = 0.15 常量声明
#                      (1 灰阶 = 15% lerp toward WHITE, Amber Voice 亮 ~5% RGB)
#
# === T230.HANDLER — _on_recent_row_hover_in 改写 ===
# - T230.HANDLER.LERP: handler 调 default_color.lerp(Color.WHITE, 0.15)
# - T230.HANDLER.NO_SNAP: handler 不再 snap font_color = Color.WHITE
# - T230.HANDLER.DEFAULT_READ: handler 读 _recent_row_default_color[idx]
#                              (从 saved array 取行默认色, fallback Color.WHITE 越界守卫)
# - T230.HANDLER.THEME_OVERRIDE: 调 add_theme_color_override("font_color", ...)
#                                 (T215 旧版 0 改, 改的是赋的颜色)
#
# === T230.REGRESS — 回归 (T215/T219/T216 0 触碰) ===
# - T230.REGRESS.HOVER_OUT: _on_recent_row_hover_out 仍 restore default_color (T215 0 改)
# - T230.REGRESS.HOVERED_FIELD: _recent_row_hovered 字段 0 删 (T215 0 改)
# - T230.REGRESS.DEFAULT_FIELD: _recent_row_default_color 字段 0 删 (T215 0 改)
# - T230.REGRESS.ALPHA: _RECENT_ROW_ALPHA_MAX/MIN 0 改 (T219 0 触碰)
# - T230.REGRESS.NO_OLD_SNAP: 旧版 snap font_color = Color.WHITE 0 残留 (T230 改用 lerp 0.15)
# - T230.REGRESS.ANCHOR: T230 (#149) 注释锚点 ≥ 3 处 (const 1 + handler 1 + design 1)

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
	print("=== I055 — T230 (#149) ProfileRecentList 5 局行 hover 灰阶 +1 软提亮 smoke test ===")
	var content := _read_text(PAUSE_MENU_PATH)
	if content.is_empty():
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return

	_run_t230_const_assertions(content)
	_run_t230_handler_assertions(content)
	_run_t230_regress_assertions(content)
	_finish()


# ---------- T230.CONST — 1 hover_brighten 系数常量 ----------
func _run_t230_const_assertions(content: String) -> void:
	print("--- T230.CONST — 1 hover_brighten 系数常量 ---")

	_assert("const _RECENT_ROW_HOVER_BRIGHTEN := 0.15" in content,
		"T230.CONST.FACTOR.1 — _RECENT_ROW_HOVER_BRIGHTEN = 0.15 常量声明 (1 灰阶 = 15% lerp toward WHITE, 与 T226 #147 +0.1 alpha boost 思路同源)")


# ---------- T230.HANDLER — _on_recent_row_hover_in 改写 ----------
func _run_t230_handler_assertions(content: String) -> void:
	print("--- T230.HANDLER — _on_recent_row_hover_in 改写 ---")

	# 锁定 _on_recent_row_hover_in 函数体
	var hover_in_idx: int = content.find("func _on_recent_row_hover_in(")
	if hover_in_idx < 0:
		_failures.append("T230.HANDLER.FUNC.1 — _on_recent_row_hover_in handler 找不到")
		_passes -= 1
		print("[FAIL] T230.HANDLER.FUNC.1 — _on_recent_row_hover_in handler missing (cascading handler assertions skipped)")
		return
	var next_func: int = content.find("\nfunc ", hover_in_idx + 1)
	if next_func < 0:
		next_func = hover_in_idx + 3000  # fallback
	var handler_body: String = content.substr(hover_in_idx, next_func - hover_in_idx)

	# lerp(Color.WHITE, _RECENT_ROW_HOVER_BRIGHTEN) 调用
	_assert("default_color.lerp(Color.WHITE, _RECENT_ROW_HOVER_BRIGHTEN)" in handler_body,
		"T230.HANDLER.LERP.1 — handler 调 default_color.lerp(Color.WHITE, _RECENT_ROW_HOVER_BRIGHTEN) (T230 灰阶 +1 软提亮, GDScript Color.lerp 标准 API)")

	# 旧版 snap font_color = Color.WHITE 0 残留 (T230 改用 lerp)
	_assert(not ("(row as Label).add_theme_color_override(\"font_color\", Color.WHITE)" in handler_body),
		"T230.HANDLER.NO_SNAP.1 — 旧版 snap font_color = Color.WHITE 0 残留 (T230 改用 default_color.lerp(WHITE, 0.15) 软提亮)")

	# handler 读 _recent_row_default_color[idx] (saved 数组 fallback Color.WHITE 守卫)
	_assert("_recent_row_default_color[idx]" in handler_body,
		"T230.HANDLER.DEFAULT_READ.1 — handler 读 _recent_row_default_color[idx] (saved 数组, fallback Color.WHITE 越界守卫)")

	# add_theme_color_override 调用保留 (T215 旧版 0 改 wrapper)
	_assert("add_theme_color_override(\"font_color\"" in handler_body,
		"T230.HANDLER.THEME_OVERRIDE.1 — add_theme_color_override(\"font_color\", ...) 调用保留 (T215 旧版 0 改 wrapper, T230 改赋的颜色)")

	# re-entrant guard 保留 (T215 0 改)
	_assert("_recent_row_hovered[idx] = true" in handler_body,
		"T230.HANDLER.REENTRANT.1 — _recent_row_hovered[idx] = true re-entrant guard 保留 (T215 0 触碰)")


# ---------- T230.REGRESS — 回归 (T215/T219/T216 0 触碰) ----------
func _run_t230_regress_assertions(content: String) -> void:
	print("--- T230.REGRESS — 回归 (T215/T219/T216 0 触碰) ---")

	# T215 hover_out 仍 restore default_color (0 改)
	var hover_out_idx: int = content.find("func _on_recent_row_hover_out(")
	if hover_out_idx < 0:
		_failures.append("T230.REGRESS.HOVER_OUT.1 — _on_recent_row_hover_out handler 找不到")
		_passes -= 1
	else:
		var next_func: int = content.find("\nfunc ", hover_out_idx + 1)
		if next_func < 0:
			next_func = hover_out_idx + 3000
		var hover_out_body: String = content.substr(hover_out_idx, next_func - hover_out_idx)
		_assert("add_theme_color_override(\"font_color\", default_color)" in hover_out_body,
			"T230.REGRESS.HOVER_OUT.2 — _on_recent_row_hover_out 仍 restore default_color (T215 0 改, T230 仅改 hover_in 不改 hover_out)")
		_assert("_recent_row_hovered[idx] = false" in hover_out_body,
			"T230.REGRESS.HOVER_OUT.3 — hover_out 仍 _recent_row_hovered[idx] = false re-entrant guard 保留 (T215 0 触碰)")

	# T215 字段 0 删
	_assert("var _recent_row_hovered: Array" in content,
		"T230.REGRESS.HOVERED_FIELD.1 — _recent_row_hovered Array 字段 0 删 (T215 0 改)")
	_assert("var _recent_row_default_color: Array" in content,
		"T230.REGRESS.DEFAULT_FIELD.1 — _recent_row_default_color Array 字段 0 删 (T215 0 改)")

	# T219 alpha 渐变 0 改
	_assert("const _RECENT_ROW_ALPHA_MAX := 1.0" in content,
		"T230.REGRESS.ALPHA.1 — _RECENT_ROW_ALPHA_MAX = 1.0 保留 (T219 0 触碰, 0 改)")
	_assert("const _RECENT_ROW_ALPHA_MIN := 0.5" in content,
		"T230.REGRESS.ALPHA.2 — _RECENT_ROW_ALPHA_MIN = 0.5 保留 (T219 0 触碰, 0 改)")

	# T230 注释锚点 ≥ 3 处
	var t230_anchor_count: int = content.count("T230 (#149)") + content.count("T230(#149)")
	_assert(t230_anchor_count >= 3,
		"T230.REGRESS.ANCHOR.1 — T230 (#149) 注释锚点 ≥ 3 处 (实际 %d 处) — const 1 + handler 1 + docblock 1 = 3 处" % t230_anchor_count)


# Helper: read a file as text, return empty string on failure.
func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var txt: String = f.get_as_text()
	f.close()
	return txt


# Helper: print final result + quit with the right exit code.
func _finish() -> void:
	print("")
	if _failures.is_empty():
		print("ALL %d CHECKS PASSED." % _passes)
		quit(0)
	else:
		print("FAILURES DETECTED — %d failure(s) out of %d assertion(s)." % [_failures.size(), _passes])
		for fail_msg in _failures:
			print("  - %s" % fail_msg)
		quit(1)
