extends SceneTree
## I029 (#121) — Smoke test for T202.B + T202.C (accessibility 总开关
## ReduceAllCheck: 一键控制 3 个 reduce 子项 + 3 子项手动 toggle 时
## 主开关进入 indeterminate 状态 + 持久化 reduce_all key).
##
## 22 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i029_t202b_reduce_all_smoke.gd
##
## 设计 (与 I027 / I028 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T202B.MENU.REDUCE_ALL_REF — @onready var _reduce_all_check.
##   T202B.MENU.SCENE_NODE — settings_menu.tscn 含 ReduceAllCheck 节点.
##   T202B.MENU.SCENE_PARENT — parent = VBoxContainer/Content/VideoPanel.
##   T202B.MENU.SCENE_BEFORE_HEADER — ReduceAllCheck 在 AccessibilityHeader 之前.
##   T202B.MENU.SCENE_AMBER_COLOR — Amber Voice 主题色 (0.949, 0.714, 0.431).
##   T202B.MENU.SCENE_FONT_10 — font_size = 10 (高于子项 9pt).
##   T202B.MENU.SCENE_TOOLTIP — tooltip_text 提示总控 + indeterminate 语义.
##   T202B.GD.STATE_FIELD — _reduce_all 字段 (bool).
##   T202B.GD.GUARD_FIELD — _syncing_from_master 守卫字段.
##   T202B.GD.READY_CONNECT — _ready 中 _reduce_all_check.toggled.connect.
##   T202B.GD.ON_REDUCE_ALL_FN — _on_reduce_all_toggled 函数.
##   T202B.GD.APPLY_CHILDREN — _apply_three_children helper.
##   T202B.GD.SET_DISABLED — _set_three_children_disabled helper.
##   T202B.GD.SYNC_STATE — _sync_reduce_all_state helper.
##   T202B.GD.GUARD_USAGE — 3 子项 _on_reduce_*_toggled 末尾守卫调用.
##   T202B.GD.SAVE_REDUCE_ALL — _save_settings 写 reduce_all key.
##   T202B.GD.LOAD_REDUCE_ALL — _load_settings 读 reduce_all key.
##   T202B.GD.RESTORE_REDUCE_ALL — _on_restore_all_pressed 还原主开关.
##   T202C.GD.INDETERMINATE — indeterminate 状态写入.
##   T202C.GD.MIXED_BRANCH — _sync_reduce_all_state 中 mixed 分支.
##   T202C.GD.SET_BLOCK_SIGNALS — set_block_signals 防递归.
##   T202C.GD.LIVE_PUSH — 主开关推 3 子项 → ScreenShake.autoload live-push.

func _initialize() -> void:
	print("=== I029 T202.B + T202.C accessibility 总开关 smoke test (#121) ===")

	var menu_src := ""
	var mf := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if mf:
		menu_src = mf.get_as_text()
		mf.close()

	var scene_src := ""
	var scf := FileAccess.open("res://src/scenes/settings_menu.tscn", FileAccess.READ)
	if scf:
		scene_src = scf.get_as_text()
		scf.close()

	var passed := 0
	var total := 0

	# ===== T202B.MENU.REDUCE_ALL_REF =====
	total += 1
	if menu_src.find("@onready var _reduce_all_check") == -1:
		print("  FAIL [T202B.1]: settings_menu.gd 缺 @onready var _reduce_all_check 字段")
		quit(1)
		return
	passed += 1
	print("  [T202B.1] @onready var _reduce_all_check 字段 (OK)")

	# ===== T202B.MENU.SCENE_NODE =====
	total += 1
	if scene_src.find('name="ReduceAllCheck"') == -1:
		print("  FAIL [T202B.2]: settings_menu.tscn 缺 ReduceAllCheck 节点")
		quit(1)
		return
	passed += 1
	print("  [T202B.2] settings_menu.tscn 含 ReduceAllCheck (OK)")

	# ===== T202B.MENU.SCENE_PARENT =====
	total += 1
	if scene_src.find('parent="VBoxContainer/Content/VideoPanel"') == -1:
		print("  FAIL [T202B.3]: ReduceAllCheck parent 路径错")
		quit(1)
		return
	passed += 1
	print("  [T202B.3] ReduceAllCheck parent = VideoPanel (OK)")

	# ===== T202B.MENU.SCENE_BEFORE_HEADER =====
	total += 1
	# ReduceAllCheck 节点定义必须在 AccessibilityHeader 节点之前 (主开关是区段最显眼)
	var reduce_all_idx := scene_src.find('name="ReduceAllCheck"')
	var header_idx := scene_src.find('name="AccessibilityHeader"')
	if reduce_all_idx == -1 or header_idx == -1:
		print("  FAIL [T202B.4]: ReduceAllCheck / AccessibilityHeader 节点缺失 (前置 anchor 应已通过)")
		quit(1)
		return
	if reduce_all_idx > header_idx:
		print("  FAIL [T202B.4]: ReduceAllCheck 必须在 AccessibilityHeader 之前 (主开关是区段最显眼)")
		quit(1)
		return
	passed += 1
	print("  [T202B.4] ReduceAllCheck 位于 AccessibilityHeader 之前 (OK)")

	# ===== T202B.MENU.SCENE_AMBER_COLOR =====
	total += 1
	# Amber Voice 主题色 (0.949, 0.714, 0.431) 突出"总控"语义
	var reduce_all_section := scene_src.substr(reduce_all_idx, 600)
	if reduce_all_section.find("0.949, 0.714, 0.431") == -1:
		print("  FAIL [T202B.5]: ReduceAllCheck 缺 Amber Voice 主题色 (0.949, 0.714, 0.431)")
		quit(1)
		return
	passed += 1
	print("  [T202B.5] ReduceAllCheck Amber Voice 主题色 (OK)")

	# ===== T202B.MENU.SCENE_FONT_10 =====
	total += 1
	# font_size = 10 (高于子项 9pt 突出主开关)
	if reduce_all_section.find("font_size = 10") == -1:
		print("  FAIL [T202B.6]: ReduceAllCheck 缺 font_size = 10 (主开关突出)")
		quit(1)
		return
	passed += 1
	print("  [T202B.6] ReduceAllCheck font_size = 10 (OK)")

	# ===== T202B.MENU.SCENE_TOOLTIP =====
	total += 1
	# tooltip_text 提示总控 + indeterminate 语义
	if reduce_all_section.find("tooltip_text") == -1:
		print("  FAIL [T202B.7]: ReduceAllCheck 缺 tooltip_text (总控 + indeterminate 语义说明)")
		quit(1)
		return
	passed += 1
	print("  [T202B.7] ReduceAllCheck tooltip_text (OK)")

	# ===== T202B.GD.STATE_FIELD =====
	total += 1
	# _reduce_all 字段独立 bool
	if menu_src.find("var _reduce_all: bool = false") == -1:
		print("  FAIL [T202B.8]: settings_menu.gd 缺 _reduce_all 字段")
		quit(1)
		return
	passed += 1
	print("  [T202B.8] _reduce_all bool 字段 (OK)")

	# ===== T202B.GD.GUARD_FIELD =====
	total += 1
	# _syncing_from_master 守卫字段
	if menu_src.find("var _syncing_from_master: bool = false") == -1:
		print("  FAIL [T202B.9]: settings_menu.gd 缺 _syncing_from_master 守卫字段")
		quit(1)
		return
	passed += 1
	print("  [T202B.9] _syncing_from_master 守卫字段 (OK)")

	# ===== T202B.GD.READY_CONNECT =====
	total += 1
	# _ready 中 _reduce_all_check.toggled.connect
	if menu_src.find("_reduce_all_check.toggled.connect(_on_reduce_all_toggled)") == -1:
		print("  FAIL [T202B.10]: _ready 缺 _reduce_all_check.toggled.connect")
		quit(1)
		return
	passed += 1
	print("  [T202B.10] _ready 中 _reduce_all_check.toggled.connect (OK)")

	# ===== T202B.GD.ON_REDUCE_ALL_FN =====
	total += 1
	# _on_reduce_all_toggled 函数
	if menu_src.find("func _on_reduce_all_toggled(enabled: bool) -> void:") == -1:
		print("  FAIL [T202B.11]: 缺 _on_reduce_all_toggled 函数")
		quit(1)
		return
	passed += 1
	print("  [T202B.11] _on_reduce_all_toggled 函数 (OK)")

	# ===== T202B.GD.APPLY_CHILDREN =====
	total += 1
	# _apply_three_children helper
	if menu_src.find("func _apply_three_children(enabled: bool) -> void:") == -1:
		print("  FAIL [T202B.12]: 缺 _apply_three_children helper")
		quit(1)
		return
	passed += 1
	print("  [T202B.12] _apply_three_children helper (OK)")

	# ===== T202B.GD.SET_DISABLED =====
	total += 1
	# _set_three_children_disabled helper
	if menu_src.find("func _set_three_children_disabled(disabled: bool) -> void:") == -1:
		print("  FAIL [T202B.13]: 缺 _set_three_children_disabled helper")
		quit(1)
		return
	passed += 1
	print("  [T202B.13] _set_three_children_disabled helper (OK)")

	# ===== T202B.GD.SYNC_STATE =====
	total += 1
	# _sync_reduce_all_state helper
	if menu_src.find("func _sync_reduce_all_state() -> void:") == -1:
		print("  FAIL [T202B.14]: 缺 _sync_reduce_all_state helper")
		quit(1)
		return
	passed += 1
	print("  [T202B.14] _sync_reduce_all_state helper (OK)")

	# ===== T202B.GD.GUARD_USAGE =====
	total += 1
	# 3 个 _on_reduce_*_toggled 末尾守卫调用 _sync_reduce_all_state
	# 出现次数 = 3 (shake / flash / vibration)
	var guard_call_count := _count_substr(menu_src, "if not _syncing_from_master:\n\t\t_sync_reduce_all_state()")
	if guard_call_count < 3:
		# 兼容不同缩进
		guard_call_count = _count_substr(menu_src, "not _syncing_from_master")
		# 同时还要 _sync_reduce_all_state() 调用
		var sync_call_count := _count_substr(menu_src, "_sync_reduce_all_state()")
		if guard_call_count < 3 or sync_call_count < 3:
			print("  FAIL [T202B.15]: 3 子项守卫调用不足 (guard_count=%d, sync_call_count=%d)" % [guard_call_count, sync_call_count])
			quit(1)
			return
	passed += 1
	print("  [T202B.15] 3 子项 _on_reduce_*_toggled 守卫调用 (OK)")

	# ===== T202B.GD.SAVE_REDUCE_ALL =====
	total += 1
	# _save_settings 写 reduce_all key 到 [accessibility] section
	if menu_src.find('cfg.set_value("accessibility", "reduce_all", _reduce_all)') == -1:
		print("  FAIL [T202B.16]: _save_settings 缺 reduce_all 持久化")
		quit(1)
		return
	passed += 1
	print("  [T202B.16] _save_settings reduce_all 持久化 (OK)")

	# ===== T202B.GD.LOAD_REDUCE_ALL =====
	total += 1
	# _load_settings 读 reduce_all key
	if menu_src.find('cfg.get_value("accessibility", "reduce_all", false)') == -1:
		print("  FAIL [T202B.17]: _load_settings 缺 reduce_all 读回")
		quit(1)
		return
	passed += 1
	print("  [T202B.17] _load_settings reduce_all 读回 (OK)")

	# ===== T202B.GD.RESTORE_REDUCE_ALL =====
	total += 1
	# _on_restore_all_pressed 中还原 reduce_all
	# 简化: 找 _on_restore_all_pressed 函数末尾有 _reduce_all = false + _set_three_children_disabled(false)
	var restore_idx := menu_src.find("func _on_restore_all_pressed")
	if restore_idx == -1:
		print("  FAIL [T202B.18]: 缺 _on_restore_all_pressed 函数")
		quit(1)
		return
	var restore_body := menu_src.substr(restore_idx, 5000)
	if restore_body.find("_reduce_all = false") == -1 or restore_body.find("_set_three_children_disabled(false)") == -1:
		print("  FAIL [T202B.18]: _on_restore_all_pressed 缺 reduce_all 还原")
		quit(1)
		return
	passed += 1
	print("  [T202B.18] _on_restore_all_pressed 还原主开关 (OK)")

	# ===== T202C.GD.INDETERMINATE =====
	total += 1
	# indeterminate 状态写入 (T202.C 三态显示)
	if menu_src.find("_reduce_all_check.indeterminate = true") == -1:
		print("  FAIL [T202C.19]: 缺 indeterminate = true 状态写入")
		quit(1)
		return
	passed += 1
	print("  [T202C.19] indeterminate = true 状态写入 (OK)")

	# ===== T202C.GD.MIXED_BRANCH =====
	total += 1
	# _sync_reduce_all_state 中混合分支 (1-2 个子项 true 时)
	var sync_idx := menu_src.find("func _sync_reduce_all_state()")
	if sync_idx == -1:
		print("  FAIL [T202C.20]: 缺 _sync_reduce_all_state 函数 (前置 anchor 应已通过)")
		quit(1)
		return
	var sync_body := menu_src.substr(sync_idx, 1200)
	if sync_body.find("indeterminate = true") == -1 or sync_body.find("混合状态") == -1:
		print("  FAIL [T202C.20]: _sync_reduce_all_state 缺 mixed 分支 (indeterminate + '混合状态' 注释)")
		quit(1)
		return
	passed += 1
	print("  [T202C.20] _sync_reduce_all_state 混合分支 (OK)")

	# ===== T202C.GD.SET_BLOCK_SIGNALS =====
	total += 1
	# set_block_signals 防递归 (主开关 + 3 子项)
	var block_count := _count_substr(menu_src, "_reduce_all_check.set_block_signals(true)")
	if block_count < 2:
		print("  FAIL [T202C.21]: _reduce_all_check.set_block_signals 出现次数 = %d, 期望 >= 2" % block_count)
		quit(1)
		return
	passed += 1
	print("  [T202C.21] set_block_signals 防递归 (出现 %d 次) (OK)" % block_count)

	# ===== T202C.GD.LIVE_PUSH =====
	total += 1
	# _apply_three_children 推 3 个 ScreenShake autoload live-push
	# 出现次数 = 3 (shake / flash / vibration)
	var live_push_count := _count_substr(menu_src, "ScreenShake.set_reduce_")
	if live_push_count < 6:
		# 3 (live-push 路径) + 3 (_on_reduce_*_toggled 路径) 至少 6
		print("  FAIL [T202C.22]: ScreenShake.set_reduce_* live-push 出现次数 = %d, 期望 >= 6" % live_push_count)
		quit(1)
		return
	passed += 1
	print("  [T202C.22] ScreenShake.set_reduce_* live-push 链 (出现 %d 次) (OK)" % live_push_count)

	print("=== I029 T202.B + T202.C smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 与 I027 / I028 同样的实现.
func _count_substr(haystack: String, needle: String) -> int:
	if needle.is_empty():
		return 0
	var c := 0
	var sp := 0
	while true:
		var idx := haystack.find(needle, sp)
		if idx == -1:
			break
		c += 1
		sp = idx + 1
	return c
