extends SceneTree

# I040 — T214 (#134) ProfileQuickStats Run # 段悬停高亮联动 smoke test
# 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd 中 T214 实现的
# 6 大模块 (state field / mouse_filter / signal connect / hover_in handler /
# hover_out handler / _refresh_profile save) + 4 大回归保护 (T213 tooltip 0 触碰
# / T199 5 verb tooltip 0 触碰 / T210 4 段 literal 0 改 / 既有 _refresh_profile
# 主流程 0 触碰). 期望: 37 断言全 PASS, 0 回归.
#
# #135 review 修正 (4 项 test bug, 全部不改 pause_menu.gd 真实代码, 0 行为变化):
#   1. T214.ANCHOR.1 — 阈值 ≥6 改为 ≥5 (T214 是 polish scope 收窄, 不需要为后续 T214.B/C/D 留 6+ 锚点, 5 处已覆盖所有新增模块)
#   2. T214.REGRESS.6 — "T199 (#95)" 改为 "T199 (#116)" (T199 实际属于 #116, 5 verb row hover tooltip, I025 测试一致)
#   3. T214.REGRESS.7 — color tag 顺序从 "[color=#X]段名" 改为 "段名 [color=#X]" (literal 真实顺序是 color tag 在段名后)
#   4. T214.SYNTAX.2 — 限定到 "_profile_quick_stats.mouse_filter = MOUSE_FILTER_STOP" 完整 attribute path (排除 AchievementGrid slot.mouse_filter 完全无关的 0 触碰)
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i040_t214_quick_stats_hover_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#   python3 tools/test_i040_t214_quick_stats_hover_smoke.py   # 见末尾 fallback

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
	print("=== I040 — T214 (#134) ProfileQuickStats Run # 段悬停高亮联动 smoke test ===")
	var f := FileAccess.open(PAUSE_MENU_PATH, FileAccess.READ)
	if f == null:
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()
	# T214.HOVER — state field (3)
	_assert("var _quick_stats_hovered: bool = false" in content,
		"T214.HOVER.1 — _quick_stats_hovered bool 字段声明存在 (防止 mouse_entered 多次触发的 re-entrant guard)")
	_assert("var _quick_stats_default_text: String = \"\"" in content,
		"T214.HOVER.2 — _quick_stats_default_text String 字段声明存在 (mouse_exited restore 用, 在 _refresh_profile() 中赋值)")
	_assert(content.find("var _quick_stats_hovered: bool = false") < content.find("var _quick_stats_default_text: String = \"\""),
		"T214.HOVER.3 — hover 状态字段声明顺序合理 (在 _is_paused/_profile_open 之后, _ready 之前)")

	# T214.HOVER — mouse_filter + signal connect (3)
	_assert("_profile_quick_stats.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T214.HOVER.4 — mouse_filter = MOUSE_FILTER_STOP 显式设 (Label 默认 IGNORE, 必须改 STOP 才能触发 mouse_entered)")
	_assert("_profile_quick_stats.mouse_entered.connect(_on_quick_stats_hover_in)" in content,
		"T214.HOVER.5 — mouse_entered.connect() 绑定到 _on_quick_stats_hover_in handler (T111 成就 grid TextureRect 同模式)")
	_assert("_profile_quick_stats.mouse_exited.connect(_on_quick_stats_hover_out)" in content,
		"T214.HOVER.6 — mouse_exited.connect() 绑定到 _on_quick_stats_hover_out handler")

	# T214.HANDLERS — hover_in (8)
	_assert("func _on_quick_stats_hover_in() -> void:" in content,
		"T214.HANDLERS.1 — _on_quick_stats_hover_in handler 函数声明存在")
	_assert("if not _profile_quick_stats or _quick_stats_hovered:" in content,
		"T214.HANDLERS.2 — hover_in null guard + re-entrant guard (mouse_entered 多次触发 0 副作用)")
	_assert("_quick_stats_hovered = true" in content,
		"T214.HANDLERS.3 — hover_in 设置 _quick_stats_hovered = true (翻状态字段)")
	_assert("Run #[color=#B7E6DC]" in content and content.count("Run #[color=#B7E6DC]") >= 1,
		"T214.HANDLERS.4 — hover_in 找 Run # 段 marker \"Run #[color=#B7E6DC]\" (从 _profile_quick_stats.text 拆出 4 段第 4 段)")
	_assert("Run #[color=#FFFFFF][b]" in content,
		"T214.HANDLERS.5 — hover_in 用 bright_open = \"Run #[color=#FFFFFF][b]\" 替换原 marker (颜色提亮 + 粗体)")
	_assert("[/b][/color]" in content,
		"T214.HANDLERS.6 — hover_in 用 bright_close = \"[/b][/color]\" 包裹 Run # 数字 (粗体 + 颜色关闭)")
	_assert("original.find(marker)" in content and "rest.find(close_marker)" in content,
		"T214.HANDLERS.7 — hover_in 用 .find() + .substr() 双重 splice (拆出 prefix + number + suffix 三段重组)")
	_assert("_profile_quick_stats.text = \"%s%s%s%s\"" in content,
		"T214.HANDLERS.8 — hover_in 重写 _profile_quick_stats.text (prefix + bright_open + number + bright_close + suffix 4 段拼回)")

	# T214.HANDLERS — hover_out (5)
	_assert("func _on_quick_stats_hover_out() -> void:" in content,
		"T214.HANDLERS.9 — _on_quick_stats_hover_out handler 函数声明存在")
	_assert("if not _quick_stats_hovered:" in content and "return  # 已经在 default 状态" in content,
		"T214.HANDLERS.10 — hover_out 状态 guard: 已经在 default 时 return 0 副作用 (防 mouse_exited 多次触发)")
	_assert("_quick_stats_hovered = false" in content,
		"T214.HANDLERS.11 — hover_out 翻 _quick_stats_hovered = false (re-entrant safety for next mouse_entered)")
	_assert("_quick_stats_default_text.is_empty()" in content and "return" in content,
		"T214.HANDLERS.12 — hover_out 防御: _quick_stats_default_text 为空 (首次 _refresh 前 0 玩家 hover) → return 0 副作用")
	_assert("_profile_quick_stats.text = _quick_stats_default_text" in content,
		"T214.HANDLERS.13 — hover_out restore _profile_quick_stats.text 到 _quick_stats_default_text")

	# T214.SAVE — _refresh_profile save (3)
	_assert("_quick_stats_default_text = _profile_quick_stats.text" in content,
		"T214.SAVE.1 — _refresh_profile() 末尾保存 _quick_stats_default_text (供 hover_out restore)")
	# save 必须在 _profile_quick_stats.text = "..." 之后, 不能在 _ready 中早于 set text 之前
	var set_text_pos := content.find("_profile_quick_stats.text = \"★ [color=#69C7CE]成就")
	var save_pos := content.find("_quick_stats_default_text = _profile_quick_stats.text")
	_assert(set_text_pos > 0 and save_pos > 0 and save_pos > set_text_pos,
		"T214.SAVE.2 — _quick_stats_default_text 保存位置在 set text 之后**立即** (顺序: 写 text → 立刻 save → 才允许 hover 改, 防止误把高亮版当 default 写回)")
	_assert(content.count("_quick_stats_default_text = _profile_quick_stats.text") == 1,
		"T214.SAVE.3 — _quick_stats_default_text 只在 _refresh_profile() 中保存 1 次 (不在 _ready / _on_quick_stats_hover_in 中保存, 避免重写 default 时错位)")

	# T214.ANCHOR — 注释锚点 (4)
	# 期望至少 5 处 T214 (#134) 注释锚点 (state field 1 + _ready 1 + hover_in 1 +
	# hover_out 1 + _refresh_profile save 1 = 5 必需, 不强制 ≥6 因为 T214 是
	# polish scope 收窄的产物, 不需要像 T213 那样为后续 T214.B/C/D 留占位).
	var t214_anchor_count := content.count("T214 (#134)")
	_assert(t214_anchor_count >= 5,
		"T214.ANCHOR.1 — T214 (#134) 注释锚点至少 5 处 (state field 1 + _ready 1 + hover_in 1 + hover_out 1 + _refresh_profile save 1) — 实际 %d 处" % t214_anchor_count)

	# T214.REGRESS — T213 0 触碰 (4)
	_assert("tooltip_text = _build_quick_stats_tooltip()" in content,
		"T214.REGRESS.1 — T213 tooltip_text 绑定**未删** (T214 是 hover 高亮层, T213 tooltip 是含义说明层, 两层互补不互斥)")
	_assert("func _build_quick_stats_tooltip() -> String:" in content,
		"T214.REGRESS.2 — T213 _build_quick_stats_tooltip() 函数**未删**")
	_assert("_QUICK_STATS_HINT" in content and content.count("_QUICK_STATS_HINT") >= 4,
		"T214.REGRESS.3 — T213 _QUICK_STATS_HINT const 数据源**未删** (4 段权威解释 + 颜色 token + 位置, hover_in 复用 Run # 段 literal 与 _QUICK_STATS_HINT 第 4 条 Run # 字段一致)")
	_assert("T213 (#133)" in content,
		"T214.REGRESS.4 — T213 (#133) 注释锚点**未删** (T214 在 T213 之上加层, 旧锚点保留做历史追溯)")

	# T214.REGRESS — T199 5 verb tooltip 0 触碰 (2)
	_assert("_VERB_HINT_DATA" in content and "func _build_verb_hint_tooltip() -> String:" in content,
		"T214.REGRESS.5 — T199 _VERB_HINT_DATA + _build_verb_hint_tooltip()**未删** (5 动词 tooltip 是另一个独立 tooltip, T214 不动)")
	_assert("T199 (#116)" in content,
		"T214.REGRESS.6 — T199 (#116) 注释锚点**未删** (T199 实际属于 #116, 5 verb row hover tooltip)")

	# T214.REGRESS — T210 4 段 literal 0 改 (3)
	# T210 是 4 段 literal 颜色 token (Glass Cyan / Amber Voice / Muted Violet / Pale Resonance)
	# 锚定 _profile_quick_stats.text = "..." literal — T214 必须保留这段 literal.
	# 注意: literal 真实顺序是 "★ [color=#69C7CE]成就 %d / %d[/color]  ·  最佳 [color=#F2B66E]%s[/color]  ·  最长单房 [color=#65506A]%s[/color]  ·  Run #[color=#B7E6DC]%d[/color] ★" —
	# 成就 段 color tag 在**段名前**, 最佳 / 最长单房 / Run # 段 color tag 在**段名后** (BBCode 风格不一, 兼容即可).
	# 验证 4 段都存在 (color token + 段名) — 与 literal 实际顺序无关, 0 触碰断言.
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
		"T214.REGRESS.7 — T210 4 段 literal 颜色 token (Glass Cyan / Amber Voice / Muted Violet / Pale Resonance)**未改** (前 4 段 hover_in 不动; literal 真实顺序: 成就 color-前, 最佳/最长单房/Run# color-后); 缺: %s" % t210_missing)
	_assert("[color=#B7E6DC]%d[/color] ★" in content or "[color=#B7E6DC]%d[/color]" in content,
		"T214.REGRESS.8 — T210 Run # 段 literal \"[color=#B7E6DC]%d[/color] ★\"**未改** (hover_in 用 .find() 找 marker, 不修改 literal source)")
	_assert(content.count("[color=#B7E6DC]") >= 2,
		"T214.REGRESS.9 — T210 Run # 段 [color=#B7E6DC] token**保留在原 literal** + T214 hover_in 的 marker 字符串中各 1 次")

	# T214.REGRESS — _refresh_profile 主流程 0 触碰 (2)
	_assert("_profile_time.text = \"回响时长  %02d:%02d\"" in content,
		"T214.REGRESS.10 — _refresh_profile() 主流程 _profile_time.text = ... 0 触碰 (T214 只在 _quick_stats.text = ... 之后插入 save)")
	_assert("PlayerStats.get_run_time_seconds()" in content and "PlayerStats.get_run_number()" in content,
		"T214.REGRESS.11 — _refresh_profile() 主流程 PlayerStats 调用 0 触碰 (T214 不改 _refresh_profile 主流程)")

	# T214.SYNTAX — GDScript 静态语法 (3)
	# 简单平衡检查: 数字 "func _on_quick_stats_hover_in" + 1 = "func _on_quick_stats_hover_out" (数量一致)
	_assert(content.count("func _on_quick_stats_hover_in") == 1 and content.count("func _on_quick_stats_hover_out") == 1,
		"T214.SYNTAX.1 — _on_quick_stats_hover_in/out 各自声明 1 次 (无重复定义)")
	# MOUSE_FILTER_STOP 显式设 1 次 — 用完整 attribute path 限定到 _profile_quick_stats 自身,
	# 排除 AchievementGrid 段 slot.mouse_filter = MOUSE_FILTER_STOP 那种**完全无关**的 0 触碰断言.
	# 修 #135 review 发现: 之前用 `content.count("MOUSE_FILTER_STOP")` 会被 slot.mouse_filter 误算,
	# 而 T214 落地只引入 1 处 _profile_quick_stats.mouse_filter = MOUSE_FILTER_STOP.
	_assert(content.count("_profile_quick_stats.mouse_filter = Control.MOUSE_FILTER_STOP") == 1,
		"T214.SYNTAX.2 — _profile_quick_stats.mouse_filter = MOUSE_FILTER_STOP 显式设 1 次 (T214 落地仅 1 处; slot.mouse_filter 在 AchievementGrid 段, 与 T214 无关)")
	# 检查没有意外的 4 段颜色被改 (#B7E6DC literal 在 hover_in marker + original literal 共 2 处)
	_assert(content.count("#B7E6DC") >= 2,
		"T214.SYNTAX.3 — #B7E6DC Pale Resonance token 保留在原 literal + hover_in marker 中 (color identity 一致)")
	_finish()

func _finish() -> void:
	print("")
	print("=== I040 — summary ===")
	print("PASS: %d" % _passes)
	print("FAIL: %d" % _failures.size())
	for fail in _failures:
		print("  - %s" % fail)
	if _failures.is_empty():
		print("I040 — T214 ProfileQuickStats Run # 段悬停高亮联动 smoke test: PASSED")
		quit(0)
	else:
		print("I040 — T214 ProfileQuickStats Run # 段悬停高亮联动 smoke test: FAILED")
		quit(1)
