extends SceneTree

# I045 — T219 (#141) ProfileRecentList 5 局行 alpha 渐变 + 7 字段 tooltip smoke test
# 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd 中 T219 实现的
# 4 大模块 (2 alpha 渐变常量 / 7 字段 _RECENT_ROW_HINT 扩展 / alpha 渐变插值
# 代码 / _build_recent_row_tooltip 自动适配 7 字段) + 4 大回归保护
# (T218 click 联动 0 触碰 / T217 4 段 hover 联动 0 触碰 / T215 5 行 hover
# 0 触碰 / T216 5 字段 tooltip 0 触碰) + 1 大废弃验证 (旧版 1 Label 1 alpha
# 全亮 0 残留) + 1 注释锚点 round-trip (T219 (#141) ≥ 5 处). 期望: 35+ 断言
# 全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i045_t219_recent_row_alpha_7field_tooltip_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#
# === T219.CONST — 2 alpha 渐变端点常量 ===
# - T219.CONST.ALPHA_MAX: _RECENT_ROW_ALPHA_MAX = 1.0 (i==0 最新 1 局满亮)
# - T219.CONST.ALPHA_MIN: _RECENT_ROW_ALPHA_MIN = 0.5 (i==4 最旧 1 局半暗)
#
# === T219.HINT — 7 字段 _RECENT_ROW_HINT 扩展 ===
# - T219.HINT.SIZE: 字段数 = 7 (从 5 扩到 7)
# - T219.HINT.LABEL_5: 第 6 字段 label = "房/时" (派生密度, 房间/分钟)
# - T219.HINT.LABEL_6: 第 7 字段 label = "净/时" (派生速率, 敌/分钟)
# - T219.HINT.DESC_5: 第 6 字段 desc_zh 提到 "房间/分钟"
# - T219.HINT.DESC_6: 第 7 字段 desc_zh 提到 "敌/分钟"
# - T219.HINT.ORIG_5: 原 5 字段 (Run #/房/净/碎/时) 全部存在 0 删
# - T219.HINT.DETAIL_5: 第 6 字段 detail 公式 "rooms_cleared / (run_time_seconds / 60)"
# - T219.HINT.DETAIL_6: 第 7 字段 detail 公式 "enemies_purified / (run_time_seconds / 60)"
#
# === T219.ALPHA — 5 行 alpha 渐变插值代码 ===
# - T219.ALPHA.STEP: alpha_step 公式 = (MAX - MIN) / (N - 1)
# - T219.ALPHA.LERP: row_alpha = MAX - i * step 线性插值
# - T219.ALPHA.MODULATE: row_lbl.modulate = Color(1, 1, 1, row_alpha)
#
# === T219.TOOLTIP — _build_recent_row_tooltip 自动适配 7 字段 ===
# - T219.TOOLTIP.LOOP: 函数 for h in _RECENT_ROW_HINT 0 改 (自动渲染 7 字段)
# - T219.TOOLTIP.FMT: "• %s — %s" 格式 0 改 (与 T216 5 字段版完全同模式)
# - T219.TOOLTIP.HEADER: header 文案 0 改 (T216 落地版, 1 header + 7 字段 = 8 行)
#
# === T219.REGRESS — 回归 (T218/T217/T215/T216 0 触碰) ===
# - T219.REGRESS.1: T218 _QUICK_STATS_PULSE_DURATION_IN/OUT/ALPHA_LOW 0 删
# - T219.REGRESS.2: T218 _quick_stats_pulse_tweens Dictionary 字段 0 删
# - T219.REGRESS.3: T218 _on_quick_stats_clicked 函数 0 删
# - T219.REGRESS.4: T217 4 sub-Label mouse_filter STOP 0 删
# - T219.REGRESS.5: T217 _apply_quick_stats_hover_state 函数 0 删
# - T219.REGRESS.6: T215 5 行 RecentList hover 字段 (_recent_row_hovered / _recent_row_default_color) 0 删
# - T219.REGRESS.7: T216 5 字段 hover tooltip _build_recent_row_tooltip 函数 0 删
# - T219.REGRESS.8: T216 _QUICK_STATS_HINT (QuickStats 4 段) 0 触碰 (这是 QuickStats 4 段的 hint, 与 T219 的 7 字段 RecentList hint 是 2 个独立 const)
# - T219.REGRESS.NO_OLD_ALPHA: 旧版 1.0 满 alpha (无 alpha_step 渐变) 0 残留
# - T219.REGRESS.ANCHOR: T219 (#141) 注释锚点 ≥ 5 处

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
	print("=== I045 — T219 (#141) ProfileRecentList 5 局行 alpha 渐变 + 7 字段 tooltip smoke test ===")
	var f := FileAccess.open(PAUSE_MENU_PATH, FileAccess.READ)
	if f == null:
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()

	_run_t219_const_assertions(content)
	_run_t219_hint_assertions(content)
	_run_t219_alpha_assertions(content)
	_run_t219_tooltip_assertions(content)
	_run_t219_regress_assertions(content)
	_finish()


# ---------- T219.CONST — 2 alpha 渐变端点常量 ----------
func _run_t219_const_assertions(content: String) -> void:
	print("--- T219.CONST — 2 alpha 渐变端点常量 ---")

	_assert("const _RECENT_ROW_ALPHA_MAX := 1.0" in content,
		"T219.CONST.ALPHA_MAX.1 — _RECENT_ROW_ALPHA_MAX = 1.0 常量声明 (i==0 最新 1 局满亮, 玩家最关注 '上一局')")
	_assert("const _RECENT_ROW_ALPHA_MIN := 0.5" in content,
		"T219.CONST.ALPHA_MIN.1 — _RECENT_ROW_ALPHA_MIN = 0.5 常量声明 (i==4 最旧 1 局半暗, 0.0 太暗 0.7 太平)")


# ---------- T219.HINT — 7 字段 _RECENT_ROW_HINT 扩展 ----------
func _run_t219_hint_assertions(content: String) -> void:
	print("--- T219.HINT — 7 字段 _RECENT_ROW_HINT 扩展 ---")

	# _RECENT_ROW_HINT 字段块查找 (从 const 声明到下一个 const 或 func)
	var hint_start := content.find("const _RECENT_ROW_HINT := [")
	if hint_start < 0:
		_failures.append("T219.HINT.START.1 — _RECENT_ROW_HINT 找不到")
		_passes -= 1
		print("[FAIL] T219.HINT.START.1 — _RECENT_ROW_HINT not found (cascading hint assertions skipped)")
		return
	# 找下一段 "# T216" 或 "# T216" 注释块或下一行 "func " 判定 hint 块边界
	# 由于 7 字段块在文件里是 # T216 (#137) 注释 + const 7 字段,
	# 下一段是 "# T216" 后续 comment, 找下一个 "func _build" 即可
	var hint_end := content.find("func _build_recent_row_tooltip", hint_start)
	if hint_end < 0:
		hint_end = hint_start + 5000  # fallback
	var hint_body: String = content.substr(hint_start, hint_end - hint_start)

	# 字段计数: 找 "label" key 出现次数
	var label_count: int = hint_body.count("\"label\":")
	_assert(label_count == 7,
		"T219.HINT.SIZE.1 — _RECENT_ROW_HINT 字段数 = 7 (从 5 扩到 7, 原 5 字段 + 房/时 + 净/时), 实际 %d" % label_count)

	# 第 6 字段 label = 房/时
	_assert("\"label\": \"房/时\"" in hint_body,
		"T219.HINT.LABEL_5.1 — 第 6 字段 label = '房/时' (派生密度, 房间/分钟 rounded)")

	# 第 7 字段 label = 净/时
	_assert("\"label\": \"净/时\"" in hint_body,
		"T219.HINT.LABEL_6.1 — 第 7 字段 label = '净/时' (派生速率, 敌/分钟 rounded)")

	# 第 6 字段 desc_zh 提到 房间/分钟
	_assert("房间/分钟" in hint_body,
		"T219.HINT.DESC_5.1 — 第 6 字段 desc_zh 提到 '房间/分钟' (派生指标解释)")

	# 第 7 字段 desc_zh 提到 敌/分钟
	_assert("敌/分钟" in hint_body,
		"T219.HINT.DESC_6.1 — 第 7 字段 desc_zh 提到 '敌/分钟' (派生指标解释)")

	# 原 5 字段 label 全部存在 0 删
	_assert("\"label\": \"Run #\"" in hint_body,
		"T219.HINT.ORIG_5.1 — 原 'Run #' 字段 0 删")
	_assert("\"label\": \"房\"" in hint_body,
		"T219.HINT.ORIG_5.2 — 原 '房' 字段 0 删")
	_assert("\"label\": \"净\"" in hint_body,
		"T219.HINT.ORIG_5.3 — 原 '净' 字段 0 删")
	_assert("\"label\": \"碎\"" in hint_body,
		"T219.HINT.ORIG_5.4 — 原 '碎' 字段 0 删")
	_assert("\"label\": \"时\"" in hint_body,
		"T219.HINT.ORIG_5.5 — 原 '时' 字段 0 删")

	# 第 6 字段 detail 公式
	_assert("rooms_cleared / (run_time_seconds / 60)" in hint_body,
		"T219.HINT.DETAIL_5.1 — 第 6 字段 detail 公式 = 'rooms_cleared / (run_time_seconds / 60)' (派生计算透明)")

	# 第 7 字段 detail 公式
	_assert("enemies_purified / (run_time_seconds / 60)" in hint_body,
		"T219.HINT.DETAIL_6.1 — 第 7 字段 detail 公式 = 'enemies_purified / (run_time_seconds / 60)' (派生计算透明)")


# ---------- T219.ALPHA — 5 行 alpha 渐变插值代码 ----------
func _run_t219_alpha_assertions(content: String) -> void:
	print("--- T219.ALPHA — 5 行 alpha 渐变插值代码 ---")

	# alpha_step 公式 (MAX - MIN) / (N - 1)
	_assert("(_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1)" in content,
		"T219.ALPHA.STEP.1 — alpha_step 公式 = (MAX - MIN) / (N - 1) (5 步等差, 步长 0.125)")

	# row_alpha = MAX - i * step 线性插值
	_assert("_RECENT_ROW_ALPHA_MAX - float(i) * alpha_step" in content,
		"T219.ALPHA.LERP.1 — row_alpha = MAX - i * step 线性插值 (i==0 → 1.0, i==4 → 0.5)")

	# row_lbl.modulate = Color(1, 1, 1, row_alpha)
	_assert("row_lbl.modulate = Color(1.0, 1.0, 1.0, row_alpha)" in content,
		"T219.ALPHA.MODULATE.1 — row_lbl.modulate = Color(1.0, 1.0, 1.0, row_alpha) (5 行整体透明度梯度)")


# ---------- T219.TOOLTIP — _build_recent_row_tooltip 自动适配 7 字段 ----------
func _run_t219_tooltip_assertions(content: String) -> void:
	print("--- T219.TOOLTIP — _build_recent_row_tooltip 自动适配 7 字段 ---")

	# 函数 for h in _RECENT_ROW_HINT 0 改 (自动渲染 7 字段)
	var tooltip_start := content.find("func _build_recent_row_tooltip() -> String:")
	if tooltip_start < 0:
		_failures.append("T219.TOOLTIP.START.1 — _build_recent_row_tooltip 找不到")
		_passes -= 1
		print("[FAIL] T219.TOOLTIP.START.1 — _build_recent_row_tooltip not found (cascading tooltip assertions skipped)")
		return
	var tooltip_next := content.find("\nfunc ", tooltip_start + 50)
	var tooltip_body: String
	if tooltip_next > 0:
		tooltip_body = content.substr(tooltip_start, tooltip_next - tooltip_start)
	else:
		tooltip_body = content.substr(tooltip_start, 1500)

	_assert("for h in _RECENT_ROW_HINT:" in tooltip_body,
		"T219.TOOLTIP.LOOP.1 — 函数 for h in _RECENT_ROW_HINT (7 字段自动遍历, T216 5 字段版完全同模式)")

	_assert("\"• %s — %s\"" in tooltip_body,
		"T219.TOOLTIP.FMT.1 — '• %s — %s' 格式 0 改 (与 T216 5 字段版完全同模式)")

	_assert("lines.append(\"最近一局明细 — 悬停查看每字段含义\")" in tooltip_body,
		"T219.TOOLTIP.HEADER.1 — header 文案 0 改 (T216 落地版, 1 header + 7 字段 = 8 行)")


# ---------- T219.REGRESS — 回归 (T218/T217/T215/T216 0 触碰) ----------
func _run_t219_regress_assertions(content: String) -> void:
	print("--- T219.REGRESS — 回归 (T218/T217/T215/T216 0 触碰) ---")

	# T218 pulse 常量 0 删
	_assert("const _QUICK_STATS_PULSE_DURATION_IN" in content and "const _QUICK_STATS_PULSE_DURATION_OUT" in content and "const _QUICK_STATS_PULSE_ALPHA_LOW" in content,
		"T219.REGRESS.1 — T218 3 pulse 常量 0 删 (T219 ProfileRecentList 5 行 0 触碰 QuickStats 4 段 pulse)")

	# T218 _quick_stats_pulse_tweens Dictionary 字段 0 删
	_assert("var _quick_stats_pulse_tweens: Dictionary = {}" in content,
		"T219.REGRESS.2 — T218 _quick_stats_pulse_tweens Dictionary 字段 0 删 (per-target pulse 0 触碰)")

	# T218 _on_quick_stats_clicked 函数 0 删
	_assert("func _on_quick_stats_clicked(idx: int, event: InputEvent) -> void:" in content,
		"T219.REGRESS.3 — T218 _on_quick_stats_clicked 函数 0 删 (4 段 click handler 0 触碰)")

	# T217 4 sub-Label mouse_filter STOP 0 删
	_assert("_quick_stats_achievement.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T219.REGRESS.4 — T217 Achievement mouse_filter STOP 0 删 (4 段 hover 联动核心 0 触碰)")

	# T217 _apply_quick_stats_hover_state 函数 0 删
	_assert("func _apply_quick_stats_hover_state() -> void:" in content,
		"T219.REGRESS.5 — T217 _apply_quick_stats_hover_state 函数 0 删 (4 段 hover 联动 apply 0 触碰)")

	# T215 5 行 RecentList hover 字段 0 删
	_assert("_recent_row_hovered" in content and "_recent_row_default_color" in content,
		"T219.REGRESS.6 — T215 5 行 RecentList hover 字段 (_recent_row_hovered / _recent_row_default_color) 0 删")

	# T216 _build_recent_row_tooltip 函数 0 删 (自动从 5 字段扩到 7 字段)
	_assert("func _build_recent_row_tooltip() -> String:" in content,
		"T219.REGRESS.7 — T216 _build_recent_row_tooltip 函数 0 删 (5 字段 → 7 字段通过 const 扩展自动适配, 函数本体 0 改)")

	# T216 _QUICK_STATS_HINT (QuickStats 4 段) 0 触碰 (这是 QuickStats 4 段 hint, 与 T219 的 7 字段 RecentList hint 是 2 个独立 const)
	_assert("const _QUICK_STATS_HINT" in content,
		"T219.REGRESS.8 — T213 _QUICK_STATS_HINT (QuickStats 4 段) 0 删 (2 个独立 const: _QUICK_STATS_HINT 4 段 + _RECENT_ROW_HINT 7 字段)")

	# 旧版 alpha 1.0 满亮 (无 alpha_step 渐变) 0 残留
	# 旧版会用 row_lbl.modulate = Color(1, 1, 1, 1.0) 或类似 1.0 硬编码
	_assert(not ("row_lbl.modulate = Color(1, 1, 1, 1.0)" in content),
		"T219.REGRESS.NO_OLD_ALPHA.1 — 旧版 1.0 满 alpha (硬编码) 0 残留 (T219 改用 alpha_step 线性渐变 1.0 → 0.5)")

	# T219 注释锚点 (作为完整 round-trip)
	var t219_anchors: int = content.count("T219 (#141)")
	if t219_anchors == 0:
		# 兼容无空格变体
		t219_anchors = content.count("T219(#141)")
	_assert(t219_anchors >= 5,
		"T219.REGRESS.ANCHOR.1 — T219 (#141) 注释锚点 ≥ 5 处 (constants docblock + hint docblock + alpha code docblock + tooltip code), 实际 %d 处" % t219_anchors)


func _finish() -> void:
	print("=== I045 — summary ===")
	print("PASS: %d" % _passes)
	print("FAIL: %d" % _failures.size())
	if _failures.is_empty():
		print("I045 — T219 ProfileRecentList 5 局行 alpha 渐变 + 7 字段 tooltip smoke test: PASSED")
		quit(0)
	else:
		for fail_msg in _failures:
			print("  - %s" % fail_msg)
		print("I045 — T219 ProfileRecentList 5 局行 alpha 渐变 + 7 字段 tooltip smoke test: FAILED")
		quit(1)
