extends SceneTree

# I043 — T217 (#138) ProfileQuickStats 4 段全 fade 联动 smoke test
# 静态检查 (无 Godot binary 时仍可跑): 验证 pause_menu.gd 中 T217 实现的
# 6 大模块 (4 sub-Label @onready / state 字段 / mouse_filter + signal connect /
# 2 hover handler / apply 函数 / 4 sub-Label text setter) + 5 大回归保护
# (T213 tooltip 0 触碰 / T210 4 段数据源 0 改 / T199 5 verb tooltip 0 触碰 /
# T215 5 行 RecentList hover 0 触碰 / T160 banner 起始态 0 触碰) + 1 大废弃
# 验证 (T214 旧版 1 Label string 替换逻辑完全废弃). 期望: 32 断言全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i043_t217_quick_stats_4seg_hover_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#
# === T217.SUBLABEL — 4 sub-Label @onready 字段声明 ===
# - T217.SUBLABEL.ACHIEVEMENT: _quick_stats_achievement Label
# - T217.SUBLABEL.BEST_TIME: _quick_stats_best_time Label
# - T217.SUBLABEL.LONGEST_ROOM: _quick_stats_longest_room Label
# - T217.SUBLABEL.RUN_NUMBER: _quick_stats_run_number Label
# - T217.SUBLABEL.HBOX: _profile_quick_stats 改为 HBoxContainer 类型
#
# === T217.STATE — 状态字段 + DIM 常量 ===
# - T217.STATE.HOVERED_IDX: _quick_stats_hovered_idx int = -1 字段
# - T217.STATE.DIM: _QUICK_STATS_DIM Color(1.0, 1.0, 1.0, 0.5) 常量
# - T217.STATE.NO_OLD_BOOL: _quick_stats_hovered bool 字段废弃
# - T217.STATE.NO_OLD_TEXT: _quick_stats_default_text String 字段废弃
#
# === T217.WIRING — 4 sub-Label mouse_filter + signal connect ===
# - T217.WIRING.MOUSE_FILTER: 4 sub-Label 各 mouse_filter = Control.MOUSE_FILTER_STOP
# - T217.WIRING.MOUSE_ENTERED: 4 mouse_entered.connect(_on_quick_stats_hover_in.bind(idx))
# - T217.WIRING.MOUSE_EXITED: 4 mouse_exited.connect(_on_quick_stats_hover_out.bind(idx))
# - T217.WIRING.TOOLTIP: tooltip 绑到 HBoxContainer (parent)
# - T217.WIRING.BIND_0_1_2_3: 4 段 bind idx 0-3 各自出现
#
# === T217.HANDLERS — 2 hover handler 函数 ===
# - T217.HANDLERS.HOVER_IN: _on_quick_stats_hover_in(idx: int) 函数声明
# - T217.HANDLERS.HOVER_OUT: _on_quick_stats_hover_out(idx: int) 函数声明
# - T217.HANDLERS.REENTRANT_GUARD: hover_in 同 idx 多次触发 0 副作用
# - T217.HANDLERS.HANDOVER_GUARD: hover_out idx != hovered 不 clear
# - T217.HANDLERS.BOUNDARY: 越界检查 idx < 0 or idx > 3
#
# === T217.APPLY — _apply_quick_stats_hover_state() 函数 ===
# - T217.APPLY.FUNC: _apply_quick_stats_hover_state 函数声明
# - T217.APPLY.LOOP_4: for i in range(4) 循环
# - T217.APPLY.WHITE_IF_MATCH: idx 段 modulate = Color.WHITE
# - T217.APPLY.DIM_IF_NOT: 其他 3 段 modulate = _QUICK_STATS_DIM
# - T217.APPLY.NULL_GUARD: 4 sub-Label null guard
#
# === T217.REFRESH — _refresh_profile() 4 sub-Label text setter ===
# - T217.REFRESH.ACHIEVEMENT: _quick_stats_achievement.text = "成就 %d / %d"
# - T217.REFRESH.BEST_TIME: _quick_stats_best_time.text = "最佳 %s"
# - T217.REFRESH.LONGEST_ROOM: _quick_stats_longest_room.text = "最长单房 %s"
# - T217.REFRESH.RUN_NUMBER: _quick_stats_run_number.text = "Run #%d"
# - T217.REFRESH.APPLY_AFTER: _apply_quick_stats_hover_state() 末尾调用 1 次
# - T217.REFRESH.NO_OLD_BBCODE: 旧版 1 BBCode 字符串 literal "★ [color=#69C7CE]成就" 废弃
# - T217.REFRESH.NO_OLD_DEFAULT_SAVE: 旧版 _quick_stats_default_text = _profile_quick_stats.text 废弃
#
# === T217.REGRESS — 回归 (T213/T210/T199/T215/T160 不动) ===
# - T217.REGRESS.1: T213 _QUICK_STATS_HINT const 4 段仍存在
# - T217.REGRESS.2: T213 _build_quick_stats_tooltip() 函数 0 删
# - T217.REGRESS.3: T213 _profile_quick_stats.tooltip_text 绑定 0 删 (HBoxContainer 仍绑)
# - T217.REGRESS.4: T210 4 段数据源 (unlocked_count / best_time_str / longest_room_str / run_number) 0 改
# - T217.REGRESS.5: T199 _VERB_HINT_DATA + _build_verb_hint_tooltip() 0 删
# - T217.REGRESS.6: T215 5 行 RecentList hover 字段 (_recent_row_hovered / _recent_row_default_color) 0 删
# - T217.REGRESS.7: T160 banner 起始态 (modulate.a = 0.0) 0 改

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
	print("=== I043 — T217 (#138) ProfileQuickStats 4 段全 fade 联动 smoke test ===")
	var f := FileAccess.open(PAUSE_MENU_PATH, FileAccess.READ)
	if f == null:
		_failures.append("cannot open %s" % PAUSE_MENU_PATH)
		_finish()
		return
	var content := f.get_as_text()
	f.close()

	_run_t217_sublabel_assertions(content)
	_run_t217_state_assertions(content)
	_run_t217_wiring_assertions(content)
	_run_t217_handlers_assertions(content)
	_run_t217_apply_assertions(content)
	_run_t217_refresh_assertions(content)
	_run_t217_regress_assertions(content)
	_finish()


# ---------- T217.SUBLABEL — 4 sub-Label @onready 字段声明 ----------
func _run_t217_sublabel_assertions(content: String) -> void:
	print("--- T217.SUBLABEL — 4 sub-Label @onready 字段声明 ---")

	_assert("@onready var _quick_stats_achievement: Label" in content,
		"T217.SUBLABEL.ACHIEVEMENT.1 — _quick_stats_achievement Label @onready 字段声明存在 (Achievement 段 sub-Label)")
	_assert("@onready var _quick_stats_best_time: Label" in content,
		"T217.SUBLABEL.BEST_TIME.1 — _quick_stats_best_time Label @onready 字段声明存在 (最佳回响段 sub-Label)")
	_assert("@onready var _quick_stats_longest_room: Label" in content,
		"T217.SUBLABEL.LONGEST_ROOM.1 — _quick_stats_longest_room Label @onready 字段声明存在 (最长单房段 sub-Label)")
	_assert("@onready var _quick_stats_run_number: Label" in content,
		"T217.SUBLABEL.RUN_NUMBER.1 — _quick_stats_run_number Label @onready 字段声明存在 (Run # 段 sub-Label)")
	_assert("@onready var _profile_quick_stats: HBoxContainer" in content,
		"T217.SUBLABEL.HBOX.1 — _profile_quick_stats 改为 HBoxContainer 类型 (parent 容器, 4 sub-Label + 3 sep + 2 star 居中)")


# ---------- T217.STATE — 状态字段 + DIM 常量 ----------
func _run_t217_state_assertions(content: String) -> void:
	print("--- T217.STATE — 状态字段 + DIM 常量 ---")

	_assert("var _quick_stats_hovered_idx: int = -1" in content,
		"T217.STATE.HOVERED_IDX.1 — _quick_stats_hovered_idx int = -1 字段声明 (idx 0-3 hover, -1 无 hover)")
	_assert("const _QUICK_STATS_DIM := Color(1.0, 1.0, 1.0, 0.5)" in content,
		"T217.STATE.DIM.1 — _QUICK_STATS_DIM Color(1, 1, 1, 0.5) 常量声明 (multiplicative 50% alpha dim, 4 sub-Label 原色保留)")
	_assert(not ("var _quick_stats_hovered: bool = false" in content),
		"T217.STATE.NO_OLD_BOOL.1 — T214 旧版 _quick_stats_hovered bool 字段废弃 (1 bit 只能表达 hover 状态, 不能表达 hover 哪一段)")
	_assert(not ("var _quick_stats_default_text: String" in content),
		"T217.STATE.NO_OLD_TEXT.1 — T214 旧版 _quick_stats_default_text String 字段废弃 (modulate 4 字段独立管理, 不需要 default 字符串缓存)")


# ---------- T217.WIRING — 4 sub-Label mouse_filter + signal connect ----------
func _run_t217_wiring_assertions(content: String) -> void:
	print("--- T217.WIRING — 4 sub-Label mouse_filter + signal connect ---")

	# 4 sub-Label 各 mouse_filter = Control.MOUSE_FILTER_STOP
	_assert("_quick_stats_achievement.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T217.WIRING.MOUSE_FILTER.1 — _quick_stats_achievement mouse_filter STOP (Label 默认 IGNORE 显式设)")
	_assert("_quick_stats_best_time.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T217.WIRING.MOUSE_FILTER.2 — _quick_stats_best_time mouse_filter STOP")
	_assert("_quick_stats_longest_room.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T217.WIRING.MOUSE_FILTER.3 — _quick_stats_longest_room mouse_filter STOP")
	_assert("_quick_stats_run_number.mouse_filter = Control.MOUSE_FILTER_STOP" in content,
		"T217.WIRING.MOUSE_FILTER.4 — _quick_stats_run_number mouse_filter STOP")

	# 4 sub-Label mouse_entered.connect + mouse_exited.connect
	_assert("_quick_stats_achievement.mouse_entered.connect(_on_quick_stats_hover_in.bind(0))" in content,
		"T217.WIRING.MOUSE_ENTERED.1 — Achievement mouse_entered.bind(0) (idx 0 = 第 1 段)")
	_assert("_quick_stats_best_time.mouse_entered.connect(_on_quick_stats_hover_in.bind(1))" in content,
		"T217.WIRING.MOUSE_ENTERED.2 — BestTime mouse_entered.bind(1) (idx 1 = 第 2 段)")
	_assert("_quick_stats_longest_room.mouse_entered.connect(_on_quick_stats_hover_in.bind(2))" in content,
		"T217.WIRING.MOUSE_ENTERED.3 — LongestRoom mouse_entered.bind(2) (idx 2 = 第 3 段)")
	_assert("_quick_stats_run_number.mouse_entered.connect(_on_quick_stats_hover_in.bind(3))" in content,
		"T217.WIRING.MOUSE_ENTERED.4 — RunNumber mouse_entered.bind(3) (idx 3 = 第 4 段)")
	_assert(content.count("_on_quick_stats_hover_out.bind(") == 4,
		"T217.WIRING.MOUSE_EXITED.1 — 4 mouse_exited.connect(_on_quick_stats_hover_out.bind(idx)) 各自声明 1 次")

	# tooltip 绑到 HBoxContainer
	_assert("_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()" in content,
		"T217.WIRING.TOOLTIP.1 — tooltip 绑到 HBoxContainer (parent), 4 sub-Label 共享同一 tooltip")

	# bind idx 0-3 全部出现
	_assert(content.count(".bind(0)") >= 1 and content.count(".bind(1)") >= 1 and content.count(".bind(2)") >= 1 and content.count(".bind(3)") >= 1,
		"T217.WIRING.BIND_0_1_2_3.1 — 4 段 bind idx 0/1/2/3 全部出现 (4 段独立)")


# ---------- T217.HANDLERS — 2 hover handler 函数 ----------
func _run_t217_handlers_assertions(content: String) -> void:
	print("--- T217.HANDLERS — 2 hover handler 函数 ---")

	_assert("func _on_quick_stats_hover_in(idx: int) -> void:" in content,
		"T217.HANDLERS.HOVER_IN.1 — _on_quick_stats_hover_in(idx: int) -> void 函数声明 (4 段 bind 共享 1 对 handler)")
	_assert("func _on_quick_stats_hover_out(idx: int) -> void:" in content,
		"T217.HANDLERS.HOVER_OUT.1 — _on_quick_stats_hover_out(idx: int) -> void 函数声明")

	# re-entrant guard + handover guard + boundary
	_assert("if _quick_stats_hovered_idx == idx:" in content and "return" in content.split("if _quick_stats_hovered_idx == idx:")[1].substr(0, 100),
		"T217.HANDLERS.REENTRANT_GUARD.1 — hover_in re-entrant guard (同 idx 多次触发 0 副作用)")
	_assert("if _quick_stats_hovered_idx != idx:" in content,
		"T217.HANDLERS.HANDOVER_GUARD.1 — hover_out handover guard (idx != hovered 不 clear, 避免 hover Achievement → BestTime 转移时误清)")
	_assert("if idx < 0 or idx > 3:" in content,
		"T217.HANDLERS.BOUNDARY.1 — 越界检查 idx < 0 or idx > 3 (与 T215 5 行 RecentList hover 越界模式同源)")


# ---------- T217.APPLY — _apply_quick_stats_hover_state() 函数 ----------
func _run_t217_apply_assertions(content: String) -> void:
	print("--- T217.APPLY — _apply_quick_stats_hover_state() 函数 ---")

	_assert("func _apply_quick_stats_hover_state() -> void:" in content,
		"T217.APPLY.FUNC.1 — _apply_quick_stats_hover_state() 函数声明 (4 sub-Label modulate 重算)")

	# 找到 apply 函数体, 验证内部逻辑
	var apply_start := content.find("func _apply_quick_stats_hover_state() -> void:")
	if apply_start < 0:
		_failures.append("T217.APPLY.FUNC.1 — apply function declaration not found")
		_passes -= 1
		print("[FAIL] T217.APPLY.FUNC.1 — apply function declaration not found (cascading apply assertions skipped)")
		return
	# 截取函数体 (下一个 func 之前 2000 字符)
	var next_func_idx := content.find("\nfunc ", apply_start + 50)
	var apply_body: String
	if next_func_idx > 0:
		apply_body = content.substr(apply_start, next_func_idx - apply_start)
	else:
		apply_body = content.substr(apply_start, 2000)

	_assert("for i in range(4):" in apply_body,
		"T217.APPLY.LOOP_4.1 — for i in range(4) 循环 4 sub-Label (1 循环 4 赋值, 0 字符串处理)")
	_assert("if i == _quick_stats_hovered_idx:" in apply_body and "Color.WHITE" in apply_body,
		"T217.APPLY.WHITE_IF_MATCH.1 — idx 段 modulate = Color.WHITE (亮)")
	_assert("_QUICK_STATS_DIM" in apply_body,
		"T217.APPLY.DIM_IF_NOT.1 — 其他 3 段 modulate = _QUICK_STATS_DIM (50% alpha 暗)")
	_assert("if not _quick_stats_achievement or not _quick_stats_best_time" in apply_body,
		"T217.APPLY.NULL_GUARD.1 — 4 sub-Label null guard (defensive, _ready 之前 _apply 0 副作用)")


# ---------- T217.REFRESH — _refresh_profile() 4 sub-Label text setter ----------
func _run_t217_refresh_assertions(content: String) -> void:
	print("--- T217.REFRESH — _refresh_profile() 4 sub-Label text setter ---")

	_assert("_quick_stats_achievement.text = \"成就 %d / %d\"" in content,
		"T217.REFRESH.ACHIEVEMENT.1 — _quick_stats_achievement.text = \"成就 %d / %d\" (1 段独立, T210 颜色 Glass Cyan tscn theme override)")
	_assert("_quick_stats_best_time.text = \"最佳 %s\"" in content,
		"T217.REFRESH.BEST_TIME.1 — _quick_stats_best_time.text = \"最佳 %s\" (best_time_str 数据源 0 改)")
	_assert("_quick_stats_longest_room.text = \"最长单房 %s\"" in content,
		"T217.REFRESH.LONGEST_ROOM.1 — _quick_stats_longest_room.text = \"最长单房 %s\" (longest_room_str 数据源 0 改)")
	_assert("_quick_stats_run_number.text = \"Run #%d\"" in content,
		"T217.REFRESH.RUN_NUMBER.1 — _quick_stats_run_number.text = \"Run #%d\" (PlayerStats.get_run_number() 数据源 0 改)")

	# _apply_quick_stats_hover_state() 末尾调用 1 次
	_assert(content.count("_apply_quick_stats_hover_state()") >= 2,
		"T217.REFRESH.APPLY_AFTER.1 — _apply_quick_stats_hover_state() 至少调用 2 次 (1 函数定义 1 _refresh 末尾调用, 实际 ≥ 2)")

	# 旧版废弃
	_assert(not ("\"★ [color=#69C7CE]成就\" in content" in content) and not ("★ [color=#69C7CE]成就" in content and "%d / %d[/color]  ·  最佳 [color=#F2B66E]%s[/color]  ·  最长单房 [color=#65506A]%s[/color]  ·  Run #[color=#B7E6DC]%d[/color] ★" in content),
		"T217.REFRESH.NO_OLD_BBCODE.1 — 旧版 1 BBCode 字符串 literal (★ + 4 段 color + sep + 4 段 + ★) 废弃 (1 Label 4 BBCode 段已拆 4 sub-Label)")
	_assert(not ("_quick_stats_default_text = _profile_quick_stats.text" in content),
		"T217.REFRESH.NO_OLD_DEFAULT_SAVE.1 — 旧版 _quick_stats_default_text = _profile_quick_stats.text 字符串缓存废弃 (modulate 4 字段独立管理)")


# ---------- T217.REGRESS — 回归 (T213/T210/T199/T215/T160 不动) ----------
func _run_t217_regress_assertions(content: String) -> void:
	print("--- T217.REGRESS — 回归 (T213/T210/T199/T215/T160 不动) ---")

	# T213 tooltip 数据源 + build 函数 + 绑定 0 删
	_assert("const _QUICK_STATS_HINT" in content,
		"T217.REGRESS.1 — T213 _QUICK_STATS_HINT const 4 段权威数据源 0 删 (label/color/color_name/desc_zh/detail 5 字段 4 段)")
	_assert("func _build_quick_stats_tooltip() -> String:" in content,
		"T217.REGRESS.2 — T213 _build_quick_stats_tooltip() 函数 0 删 (9 行 tooltip 渲染, 4 段 × 2 行/段 + header)")
	_assert("_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()" in content,
		"T217.REGRESS.3 — T213 _profile_quick_stats.tooltip_text 绑定 0 删 (T217 仍绑到 HBoxContainer, 4 sub-Label 共享同一 tooltip)")

	# T210 4 段数据源 0 改
	_assert("unlocked_count" in content and "total_count" in content and "best_time_str" in content and "longest_room_str" in content and "PlayerStats.get_run_number()" in content,
		"T217.REGRESS.4 — T210 4 段数据源 (unlocked_count / total_count / best_time_str / longest_room_str / PlayerStats.get_run_number()) 0 改, 4 sub-Label 复用同一组数据")

	# T199 5 verb tooltip
	_assert("_VERB_HINT_DATA" in content and "_build_verb_hint_tooltip" in content,
		"T217.REGRESS.5 — T199 _VERB_HINT_DATA + _build_verb_hint_tooltip() 0 删 (5 verb row tooltip 独立)")

	# T215 5 行 RecentList hover 字段
	_assert("_recent_row_hovered" in content and "_recent_row_default_color" in content,
		"T217.REGRESS.6 — T215 5 行 RecentList hover 字段 (_recent_row_hovered / _recent_row_default_color) 0 删 (5 行独立 + T217 4 sub-Label 独立, 0 触碰)")

	# T160 banner 起始态
	_assert("_new_achv_banner.modulate.a = 0.0" in content,
		"T217.REGRESS.7 — T160 banner 起始态 (modulate.a = 0.0) 0 改 (T217 refactor 0 触碰 banner)")

	# T217 注释锚点 (作为完整 round-trip)
	var t217_anchors: int = content.count("T217 (#138)")
	if t217_anchors == 0:
		# 兼容无空格变体
		t217_anchors = content.count("T217(#138)")
	_assert(t217_anchors >= 5,
		"T217.REGRESS.ANCHOR.1 — T217 (#138) 注释锚点 ≥ 5 处 (@onready 段 + 2 handler + apply + _refresh 末尾 + state 字段 docblock 全部覆盖), 实际 %d 处" % t217_anchors)


func _finish() -> void:
	print("=== I043 — summary ===")
	print("PASS: %d" % _passes)
	print("FAIL: %d" % _failures.size())
	if _failures.is_empty():
		print("I043 — T217 ProfileQuickStats 4 段全 fade 联动 smoke test: PASSED")
		quit(0)
	else:
		for fail_msg in _failures:
			print("  - %s" % fail_msg)
		print("I043 — T217 ProfileQuickStats 4 段全 fade 联动 smoke test: FAILED")
		quit(1)
