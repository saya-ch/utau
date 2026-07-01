extends SceneTree
## I051 + I052 (#147) — T225 ProfileQuickStats 4 段 hover 提亮 fade-out 持续
## 0.3s + T226 AchievementGrid 14 slot hover +1 灰阶预览 冒烟测试
##
## 覆盖 #147 任务 T225 + T226 原子化提交:
##
## === T225 — ProfileQuickStats 4 段 hover 提亮 fade-out 持续 0.3s ===
## - T225.CONST.FADE: _QUICK_STATS_HOVER_FADE_DURATION = 0.3 (T225 节奏参数)
## - T225.FIELD.TWEEN: _quick_stats_hover_tween: Tween = null (1 个全局 tween)
## - T225.APPLY.KILL: _apply_quick_stats_hover_state kill 旧 tween
## - T225.APPLY.NEW: 创建新 tween set_parallel (4 段同步渐变)
## - T225.APPLY.MODULATE: 4 sub-Label tween_property modulate 字段 (Color)
## - T225.APPLY.QUAD: TRANS_QUAD + EASE_OUT (与 T111/T215 既有节奏一致)
## - T225.APPLY.SAVE: _quick_stats_hover_tween = t (引用保存, 下次 _apply 可 kill)
## - T225.REGRESS.T217: T217 _quick_stats_hovered_idx 字段 + 2 handler 0 改
## - T225.REGRESS.T218: T218 _quick_stats_pulse_tweens + click handler 0 改
## - T225.DOC.ANCHOR: T225 (#147) 注释锚点 ≥ 2 处
## - T225.NO_SNAP: 旧版 _apply_quick_stats_hover_state 立即赋值 0 残留
##
## === T226 — AchievementGrid 14 slot hover +1 灰阶预览 ===
## - T226.CONST.BOOST: _SLOT_HOVER_BRIGHT_ALPHA_BOOST = 0.1 (locked slot 亮一阶)
## - T226.CONST.DURATION: _SLOT_HOVER_FADE_DURATION = 0.12 (T111 旧版 0.12s 同步)
## - T226.FIELD.DICT: _slot_hover_alpha_base: Dictionary = {} (slot → base_alpha)
## - T226.HOVER_IN.READ_BASE: _on_slot_hover_in 读 _slot_hover_alpha_base
## - T226.HOVER_IN.CLAMP: clampf(base + boost, 0.0, 1.0) (unlocked 1.0 不变)
## - T226.HOVER_IN.MODULATE: modulate tween 终点 Color(1.2, 1.1, 0.9, boosted)
## - T226.HOVER_OUT.READ_BASE: _on_slot_hover_out 读 _slot_hover_alpha_base
## - T226.HOVER_OUT.LOCKED_COLOR: locked_color 用 base_alpha (替换 hardcoded 0.5)
## - T226.REFRESH.SAVE: _refresh_achievement_grid 存 _slot_hover_alpha_base
## - T226.REGRESS.T111: T111 1.5x 放大 + 暖色 modulate 0 改
## - T226.REGRESS.T222: T222 _ACHV_LOCKED_ALPHA_START/END/RGB 0 改
## - T226.DOC.ANCHOR: T226 (#147) 注释锚点 ≥ 2 处
## - T226.NO_REGRESS: 旧 hardcoded Color(0.25, 0.25, 0.3, 0.5) 0 残留
## - T226.NO_HARDCODED_BOOST: 旧 +0.1 硬编码 0 残留 (用 const 引用)

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I051 + I052 (#147) — T225 QuickStats 4段 hover 0.3s fade + T226 AchvGrid 14 slot +1 灰阶 ===")
	_run_t225_const_assertions()
	_run_t225_field_assertions()
	_run_t225_apply_assertions()
	_run_t225_regress_assertions()
	_run_t225_doc_anchor_assertions()
	_run_t225_no_snap_assertions()
	_run_t226_const_assertions()
	_run_t226_field_assertions()
	_run_t226_hover_in_assertions()
	_run_t226_hover_out_assertions()
	_run_t226_refresh_assertions()
	_run_t226_regress_assertions()
	_run_t226_doc_anchor_assertions()
	_run_t226_no_regress_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I051 + I052 (#147) T225 + T226 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T225 — QuickStats 4 段 hover 提亮 fade-out 0.3s =====================

# ---------- T225.CONST.* — 节奏参数 ----------
func _run_t225_const_assertions() -> void:
	print("--- T225.CONST.* — 节奏参数 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _QUICK_STATS_HOVER_FADE_DURATION := 0.3",
		"T225.CONST.FADE.1: _QUICK_STATS_HOVER_FADE_DURATION = 0.3 (T225 节奏: 0.3s 提亮 fade-out)")


# ---------- T225.FIELD.* — 全局 tween 引用 ----------
func _run_t225_field_assertions() -> void:
	print("--- T225.FIELD.* — 全局 tween 引用 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "var _quick_stats_hover_tween: Tween = null",
		"T225.FIELD.TWEEN.1: _quick_stats_hover_tween: Tween = null (1 个全局 tween 引用)")


# ---------- T225.APPLY.* — _apply_quick_stats_hover_state 改造 ----------
func _run_t225_apply_assertions() -> void:
	print("--- T225.APPLY.* — _apply_quick_stats_hover_state 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _apply_quick_stats_hover_state() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T225.APPLY.1: _apply_quick_stats_hover_state 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 2500)
	_assert_contains(fn_body, "_quick_stats_hover_tween.is_valid()",
		"T225.APPLY.KILL.1: _apply 调 _quick_stats_hover_tween.is_valid() 守卫 (defensive)")
	_assert_contains(fn_body, "_quick_stats_hover_tween.kill()",
		"T225.APPLY.KILL.2: _apply kill 旧 tween (避免快速 hover 进出 4 段时 tween 叠加)")
	_assert_contains(fn_body, "create_tween()",
		"T225.APPLY.NEW.1: _apply 创建新 tween")
	_assert_contains(fn_body, "t.set_parallel(true)",
		"T225.APPLY.NEW.2: tween set_parallel(true) (4 sub-Label 同步渐变)")
	_assert_contains(fn_body, "var subs: Array = [_quick_stats_achievement, _quick_stats_best_time, _quick_stats_longest_room, _quick_stats_run_number]",
		"T225.APPLY.MODULATE.1: 4 sub-Label 装入 subs 数组")
	_assert_contains(fn_body, "t.tween_property(subs[i], \"modulate\", target_color, _QUICK_STATS_HOVER_FADE_DURATION)",
		"T225.APPLY.MODULATE.2: 4 sub-Label tween_property modulate 字段 (Color 4 通道)")
	_assert_contains(fn_body, "set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)",
		"T225.APPLY.QUAD.1: TRANS_QUAD + EASE_OUT (T111 0.12s 节奏同源, 视觉组连贯)")
	_assert_contains(fn_body, "_quick_stats_hover_tween = t",
		"T225.APPLY.SAVE.1: 新 tween 引用保存到 _quick_stats_hover_tween (下次 _apply 可 kill)")


# ---------- T225.REGRESS.* — T217 + T218 0 改 ----------
func _run_t225_regress_assertions() -> void:
	print("--- T225.REGRESS.* — T217 + T218 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T217 状态字段 + 2 handler 0 改
	_assert_contains(src, "var _quick_stats_hovered_idx: int = -1",
		"T225.REGRESS.T217.1: T217 _quick_stats_hovered_idx 字段 0 删 (#138 锚点保留)")
	_assert_contains(src, "func _on_quick_stats_hover_in(idx: int) -> void:",
		"T225.REGRESS.T217.2: T217 _on_quick_stats_hover_in handler 0 删")
	_assert_contains(src, "func _on_quick_stats_hover_out(idx: int) -> void:",
		"T225.REGRESS.T217.3: T217 _on_quick_stats_hover_out handler 0 删")
	# T218 click 联动 0 改
	_assert_contains(src, "var _quick_stats_pulse_tweens: Dictionary = {}",
		"T225.REGRESS.T218.1: T218 per-target tween Dictionary 0 删 (#139 锚点保留)")
	_assert_contains(src, "func _on_quick_stats_clicked(idx: int, event: InputEvent) -> void:",
		"T225.REGRESS.T218.2: T218 click handler 函数 0 删")
	_assert_contains(src, "_QUICK_STATS_PULSE_DURATION_IN := 0.15",
		"T225.REGRESS.T218.3: T218 pulse 节奏 0 改 (与 T225 0.3s fade 0 冲突: T225 改 modulate 字段, T218 改 modulate.a 字段不同节点)")


# ---------- T225.DOC.ANCHOR.* — T225 注释锚点 ≥ 2 处 ----------
func _run_t225_doc_anchor_assertions() -> void:
	print("--- T225.DOC.ANCHOR.* — T225 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T225 (#147)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T225.DOC.ANCHOR.1: T225 (#147) 注释锚点 %d 处 (≥ 2)" % anchor_count)
	else:
		_failures.append("FAIL: T225.DOC.ANCHOR.1: T225 (#147) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T225.NO_SNAP — 旧版 _apply 立即赋值 0 残留 ----------
func _run_t225_no_snap_assertions() -> void:
	print("--- T225.NO_SNAP — 旧版 _apply 立即赋值 0 残留 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _apply_quick_stats_hover_state() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T225.NO_SNAP.1: _apply_quick_stats_hover_state 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 2500)
	# 旧版 `subs[i].modulate = ...` 立即赋值应该 0 残留, 改为 tween_property
	if fn_body.find("subs[i].modulate = Color.WHITE") != -1:
		_failures.append("FAIL: T225.NO_SNAP.1: 旧版 snap 赋值 `subs[i].modulate = Color.WHITE` 残留 (T225 应 tween)")
	else:
		_passes += 1
		print("  OK  T225.NO_SNAP.1: 旧版 snap 赋值 modulate = Color.WHITE 0 残留 (T225 tween 0.3s fade)")
	if fn_body.find("subs[i].modulate = _QUICK_STATS_DIM") != -1:
		_failures.append("FAIL: T225.NO_SNAP.2: 旧版 snap 赋值 `subs[i].modulate = _QUICK_STATS_DIM` 残留")
	else:
		_passes += 1
		print("  OK  T225.NO_SNAP.2: 旧版 snap 赋值 modulate = _QUICK_STATS_DIM 0 残留 (T225 tween 0.3s fade)")


# ===================== T226 — AchievementGrid 14 slot hover +1 灰阶预览 =====================

# ---------- T226.CONST.* — boost + 节奏参数 ----------
func _run_t226_const_assertions() -> void:
	print("--- T226.CONST.* — boost + 节奏参数 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _SLOT_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T226.CONST.BOOST.1: _SLOT_HOVER_BRIGHT_ALPHA_BOOST = 0.1 (locked slot 亮一阶暗示可点查看)")
	_assert_contains(src, "const _SLOT_HOVER_FADE_DURATION := 0.12",
		"T226.CONST.DURATION.1: _SLOT_HOVER_FADE_DURATION = 0.12 (T111 0.12s 节奏同步, 4 套 tween 内部 4 个 set_parallel 同步推进)")


# ---------- T226.FIELD.* — base alpha 字典 ----------
func _run_t226_field_assertions() -> void:
	print("--- T226.FIELD.* — base alpha 字典 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "var _slot_hover_alpha_base: Dictionary = {}",
		"T226.FIELD.DICT.1: _slot_hover_alpha_base: Dictionary = {} (slot → base_alpha)")


# ---------- T226.HOVER_IN.* — _on_slot_hover_in 改造 ----------
func _run_t226_hover_in_assertions() -> void:
	print("--- T226.HOVER_IN.* — _on_slot_hover_in 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_slot_hover_in(slot: TextureRect) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T226.HOVER_IN.1: _on_slot_hover_in 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 1500)
	_assert_contains(fn_body, "if _slot_hover_alpha_base.has(slot):",
		"T226.HOVER_IN.READ_BASE.1: _on_slot_hover_in 守卫 _slot_hover_alpha_base.has(slot) (defensive)")
	_assert_contains(fn_body, "base_alpha = _slot_hover_alpha_base[slot]",
		"T226.HOVER_IN.READ_BASE.2: _on_slot_hover_in 读 base_alpha = _slot_hover_alpha_base[slot]")
	_assert_contains(fn_body, "clampf(base_alpha + _SLOT_HOVER_BRIGHT_ALPHA_BOOST, 0.0, 1.0)",
		"T226.HOVER_IN.CLAMP.1: clampf(base + boost, 0, 1) (unlocked 1.0+0.1=1.0 不变, locked 0.5/0.2+0.1=0.6/0.3)")
	_assert_contains(fn_body, "Color(1.2, 1.1, 0.9, boosted_alpha)",
		"T226.HOVER_IN.MODULATE.1: modulate tween 终点 Color(RGB 暖色, boosted_alpha) (T111 RGB 暖色 + T226 alpha 提升)")


# ---------- T226.HOVER_OUT.* — _on_slot_hover_out 改造 ----------
func _run_t226_hover_out_assertions() -> void:
	print("--- T226.HOVER_OUT.* — _on_slot_hover_out 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_slot_hover_out(slot: TextureRect) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T226.HOVER_OUT.1: _on_slot_hover_out 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 1500)
	_assert_contains(fn_body, "if _slot_hover_alpha_base.has(slot):",
		"T226.HOVER_OUT.READ_BASE.1: _on_slot_hover_out 守卫 _slot_hover_alpha_base.has(slot)")
	_assert_contains(fn_body, "base_alpha = _slot_hover_alpha_base[slot]",
		"T226.HOVER_OUT.READ_BASE.2: _on_slot_hover_out 读 base_alpha")
	_assert_contains(fn_body, "var locked_color: Color = Color(_ACHV_LOCKED_COLOR_RGB.r, _ACHV_LOCKED_COLOR_RGB.g, _ACHV_LOCKED_COLOR_RGB.b, base_alpha)",
		"T226.HOVER_OUT.LOCKED_COLOR.1: locked_color 用 base_alpha (T226 替换 T111 旧版 hardcoded 0.5 让 locked slot 跟随解锁进度退场)")


# ---------- T226.REFRESH.* — _refresh_achievement_grid 末尾存 base alpha ----------
func _run_t226_refresh_assertions() -> void:
	print("--- T226.REFRESH.* — _refresh_achievement_grid 末尾存 base alpha ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _refresh_achievement_grid() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T226.REFRESH.1: _refresh_achievement_grid 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 1500)
	_assert_contains(fn_body, "_slot_hover_alpha_base[child] = 1.0",
		"T226.REFRESH.SAVE.1: unlocked slot 存 base alpha 1.0 (T226 解锁后 base=1.0)")
	_assert_contains(fn_body, "_slot_hover_alpha_base[child] = locked_alpha",
		"T226.REFRESH.SAVE.2: locked slot 存 base alpha = locked_alpha (T226 跟随解锁进度 0.5→0.2)")


# ---------- T226.REGRESS.* — T111 + T222 0 改 ----------
func _run_t226_regress_assertions() -> void:
	print("--- T226.REGRESS.* — T111 + T222 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T111 1.5x 放大 + 暖色 0 改
	_assert_contains(src, "Vector2(1.5, 1.5)",
		"T226.REGRESS.T111.1: T111 1.5x 放大 tween 0 改 (#58 锚点保留)")
	_assert_contains(src, "Color(1.4, 1.4, 1.4, 1.0)",
		"T226.REGRESS.T111.2: T111 self_modulate 暖白 0 改")
	# T222 颜色常量 0 改
	_assert_contains(src, "const _ACHV_LOCKED_ALPHA_START := 0.5",
		"T226.REGRESS.T222.1: T222 _ACHV_LOCKED_ALPHA_START 0 改 (#144 锚点保留)")
	_assert_contains(src, "const _ACHV_LOCKED_ALPHA_END := 0.2",
		"T226.REGRESS.T222.2: T222 _ACHV_LOCKED_ALPHA_END 0 改")
	_assert_contains(src, "const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)",
		"T226.REGRESS.T222.3: T222 _ACHV_LOCKED_COLOR_RGB 0 改")


# ---------- T226.DOC.ANCHOR.* — T226 注释锚点 ≥ 2 处 ----------
func _run_t226_doc_anchor_assertions() -> void:
	print("--- T226.DOC.ANCHOR.* — T226 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T226 (#147)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T226.DOC.ANCHOR.1: T226 (#147) 注释锚点 %d 处 (≥ 2)" % anchor_count)
	else:
		_failures.append("FAIL: T226.DOC.ANCHOR.1: T226 (#147) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T226.NO_REGRESS — 旧 hardcoded 0.5 / 旧 +0.1 0 残留 ----------
func _run_t226_no_regress_assertions() -> void:
	print("--- T226.NO_REGRESS — 旧 hardcoded 0.5 / 旧 +0.1 0 残留 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 在 _on_slot_hover_out 函数体内的旧 `Color(0.25, 0.25, 0.3, 0.5)` 硬编码应该 0 残留
	var hover_out_idx := src.find("func _on_slot_hover_out(slot: TextureRect) -> void:")
	if hover_out_idx == -1:
		_failures.append("FAIL: T226.NO_REGRESS.1: _on_slot_hover_out 函数未找到")
		return
	var hover_out_body := src.substr(hover_out_idx, 1500)
	if hover_out_body.find("Color(0.25, 0.25, 0.3, 0.5)") != -1:
		_failures.append("FAIL: T226.NO_REGRESS.1: 旧 hardcoded Color(0.25, 0.25, 0.3, 0.5) 残留 (T226 用 locked_color 替代)")
	else:
		_passes += 1
		print("  OK  T226.NO_REGRESS.1: 旧 hardcoded Color(0.25, 0.25, 0.3, 0.5) 0 残留 (T226 全替为 locked_color 跟随解锁进度)")
	# 旧 `+ 0.1` 硬编码 alpha 提升 0 残留 (用 const _SLOT_HOVER_BRIGHT_ALPHA_BOOST)
	var hover_in_idx := src.find("func _on_slot_hover_in(slot: TextureRect) -> void:")
	if hover_in_idx == -1:
		_failures.append("FAIL: T226.NO_REGRESS.2: _on_slot_hover_in 函数未找到")
		return
	var hover_in_body := src.substr(hover_in_idx, 1500)
	# 旧版硬编码 +0.1 模式: `base_alpha + 0.1` (没有 const 引用)
	if hover_in_body.find("base_alpha + 0.1") != -1 and hover_in_body.find("_SLOT_HOVER_BRIGHT_ALPHA_BOOST") == -1:
		_failures.append("FAIL: T226.NO_REGRESS.2: 旧 hardcoded `base_alpha + 0.1` 残留 (T226 应 _SLOT_HOVER_BRIGHT_ALPHA_BOOST 引用)")
	else:
		_passes += 1
		print("  OK  T226.NO_REGRESS.2: 旧 hardcoded `base_alpha + 0.1` 0 残留 (T226 用 _SLOT_HOVER_BRIGHT_ALPHA_BOOST const)")


# ===================== 通用 helper =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % label)
	else:
		_failures.append("FAIL: %s (missing: %s)" % [label, needle])


func _print_summary() -> void:
	print("")
	print("--- Summary ---")
	print("  PASS: %d" % _passes)
	print("  FAIL: %d" % _failures.size())
	for fail_msg in _failures:
		print("  %s" % fail_msg)
