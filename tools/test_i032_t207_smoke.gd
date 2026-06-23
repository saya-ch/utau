extends SceneTree
## I032 (#124) — T207 SaveLoadMenu modal Esc + click cancel 同时按两键优先级 guard 冒烟测试
##
## 覆盖 #124 主任务 T207. 验证 _on_confirm_cancel 在同一帧被 Esc (T189/T192 _input 路径)
## + click backdrop (T191 gui_input 路径) 同时触发时, "首个事件胜出, 第二个 no-op" 的
## 优先级语义在代码层面显式. 修复 T188 confirm modal 在双调场景下的潜在 race (虽然
## _hide_confirm_modal 本身幂等, 但显式 guard 让"双调 no-op" 可读 + 防御未来扩展时
## 双调引入副作用 e.g. cancel jingle 音效 / modal shake 动画).
##
## 三类断言:
##
## === T207 — _cancel_in_progress guard field ===
## - T207.GD.FIELD: var _cancel_in_progress: bool = false 字段存在
## - T207.GD.FIELD_INIT: 字段默认值 false
## - T207.GD.ANCHOR: 字段 docblock 含 T207 (#124) 注释锚点
## - T207.GD.RATIONALE: 注释解释 guard 用途 (Esc + click 同时按两键优先级)
## - T207.GD.T192_REF: 注释引用 T192 _input 路径
## - T207.GD.T191_REF: 注释引用 T191 gui_input 路径
##
## === T207 — _on_confirm_cancel guard logic ===
## - T207.GD.CANCEL_FN: _on_confirm_cancel 函数存在
## - T207.GD.GUARD_CHECK: 入口检查 _cancel_in_progress (if guard return)
## - T207.GD.GUARD_SET: 设置 _cancel_in_progress = true
## - T207.GD.GUARD_CLEAR: 出口复位 _cancel_in_progress = false
## - T207.GD.HIDE_CALL: _on_confirm_cancel 调 _hide_confirm_modal (T188 兼容)
## - T207.GD.NO_EMIT: cancel 路径不 emit delete_requested (T188 语义对称)
## - T207.GD.ANCHOR_CANCEL: _on_confirm_cancel docblock 含 T207 (#124) 注释锚点
## - T207.GD.ORDER: guard 入口检查在 set true 之前 (短路语义)
## - T207.GD.SET_CLEAR_ORDER: set true 在 hide 之前, clear false 在 hide 之后
##
## === T207 — 兼容 T188/T189/T191/T192 同源链 ===
## - T207.T188_COMPAT: T188 _hide_confirm_modal 仍存在 (T207 是包装层)
## - T207.T189_COMPAT: T189 _is_confirm_modal_visible 仍存在 (T192 Esc 早退守卫)
## - T207.T191_COMPAT: T191 backdrop gui_input 调 _on_confirm_cancel (走 guard)
## - T207.T192_COMPAT: T192 _input Esc 调 _on_confirm_cancel (走 guard)
## - T207.SINGLE_FIRE: guard 让双调中只第一个进入 _hide_confirm_modal

const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I032 (#124) — T207 modal cancel 同帧双调优先级 guard ===")
	_run_t207_field_assertions()
	_run_t207_cancel_fn_assertions()
	_run_t207_compat_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I032 (#124) T207 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T207 — guard 字段 ----------
func _run_t207_field_assertions() -> void:
	print("--- T207.GD — _cancel_in_progress guard field ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "var _cancel_in_progress: bool = false",
		"T207.GD.FIELD.1: _cancel_in_progress: bool 字段 (默认 false)")
	_assert_contains(src, "T207 (#124)",
		"T207.GD.ANCHOR.1: T207 (#124) docblock 锚点存在")
	_assert_contains(src, "同时按两键优先级",
		"T207.GD.RATIONALE.1: 注释解释 guard 用途 (同帧 Esc + click cancel 优先级)")
	_assert_contains(src, "T192",
		"T207.GD.T192_REF.1: 注释引用 T192 _input 路径 (Esc 早拦截)")
	_assert_contains(src, "T191",
		"T207.GD.T191_REF.1: 注释引用 T191 gui_input 路径 (click backdrop)")
	# 顺序: _cancel_in_progress 字段应该在 _filter_occupied_only 之后
	# (按声明顺序; 防御重排破坏语义)
	var filter_pos := src.find("var _filter_occupied_only: bool = false")
	var guard_pos := src.find("var _cancel_in_progress: bool = false")
	if filter_pos != -1 and guard_pos != -1 and filter_pos < guard_pos:
		_passes += 1
		print("  OK  T207.GD.FIELD_ORDER.1: _cancel_in_progress 紧跟 _filter_occupied_only 字段 (按声明顺序)")
	else:
		_failures.append("FAIL: T207.GD.FIELD_ORDER.1: 字段声明顺序异常 (filter_pos=%d, guard_pos=%d)" % [filter_pos, guard_pos])


# ---------- T207 — _on_confirm_cancel guard 逻辑 ----------
func _run_t207_cancel_fn_assertions() -> void:
	print("--- T207.GD.CANCEL — _on_confirm_cancel guard logic ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "func _on_confirm_cancel() -> void:",
		"T207.GD.CANCEL_FN.1: _on_confirm_cancel 函数声明")

	# 取 _on_confirm_cancel 函数体 (到下一个 func)
	var cancel_start := src.find("func _on_confirm_cancel() -> void:")
	if cancel_start == -1:
		_failures.append("FAIL: T207.GD.CANCEL_FN.1: _on_confirm_cancel 函数未找到")
		return
	var cancel_end := src.find("\nfunc ", cancel_start + 1)
	if cancel_end == -1:
		cancel_end = src.length()
	var body := src.substr(cancel_start, cancel_end - cancel_start)

	_assert_contains(body, "T207",
		"T207.GD.ANCHOR_CANCEL.1: _on_confirm_cancel docblock 含 T207 锚点")
	_assert_contains(body, "if _cancel_in_progress:",
		"T207.GD.GUARD_CHECK.1: 入口守卫检查 _cancel_in_progress")
	_assert_contains(body, "return",
		"T207.GD.GUARD_RETURN.1: guard 命中时 return 早退 (no-op)")
	_assert_contains(body, "_cancel_in_progress = true",
		"T207.GD.GUARD_SET.1: 通过 guard 后设置 _cancel_in_progress = true")
	_assert_contains(body, "_hide_confirm_modal()",
		"T207.GD.HIDE_CALL.1: 调 _hide_confirm_modal (T188 同源链兼容)")
	_assert_contains(body, "_cancel_in_progress = false",
		"T207.GD.GUARD_CLEAR.1: 出口复位 _cancel_in_progress = false")

	# 顺序: guard 入口检查 → set true → hide → clear false
	# (这个顺序保证: 第一个事件进入后立刻 set guard 让第二个事件早退, 然后 hide, 然后 clear 让下一轮正常)
	var pos_check := body.find("if _cancel_in_progress:")
	var pos_set := body.find("_cancel_in_progress = true")
	var pos_hide := body.find("_hide_confirm_modal()")
	var pos_clear := body.find("_cancel_in_progress = false")
	if pos_check != -1 and pos_set != -1 and pos_hide != -1 and pos_clear != -1:
		if pos_check < pos_set and pos_set < pos_hide and pos_hide < pos_clear:
			_passes += 1
			print("  OK  T207.GD.ORDER.1: guard 顺序 check→set→hide→clear (防御 race)")
		else:
			_failures.append("FAIL: T207.GD.ORDER.1: guard 顺序异常 (check=%d, set=%d, hide=%d, clear=%d)" % [pos_check, pos_set, pos_hide, pos_clear])
	else:
		_failures.append("FAIL: T207.GD.ORDER.1: guard 关键语句缺失")

	# T188 兼容: cancel 路径不应 emit delete_requested (T188 语义对称)
	if body.find("delete_requested.emit") != -1:
		_failures.append("FAIL: T207.GD.NO_EMIT.1: cancel 路径不应 emit delete_requested (T188 兼容)")
	else:
		_passes += 1
		print("  OK  T207.GD.NO_EMIT.1: cancel 路径不 emit (T188 语义对称保留)")


# ---------- T207 — 同源链兼容 ----------
func _run_t207_compat_assertions() -> void:
	print("--- T207.COMPAT — T188/T189/T191/T192 同源链 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)

	# T188: _hide_confirm_modal 仍存在 (T207 是包装层, 不改 T188 行为)
	var hide_start := src.find("func _hide_confirm_modal() -> void:")
	if hide_start != -1:
		_passes += 1
		print("  OK  T207.T188_COMPAT.1: _hide_confirm_modal 仍存在 (T207 包装层兼容)")
	else:
		_failures.append("FAIL: T207.T188_COMPAT.1: _hide_confirm_modal 函数缺失 (T188 链断了)")

	# T189: _is_confirm_modal_visible 仍存在
	var vis_start := src.find("func _is_confirm_modal_visible() -> bool:")
	if vis_start != -1:
		_passes += 1
		print("  OK  T207.T189_COMPAT.1: _is_confirm_modal_visible 仍存在 (T189 链保留)")
	else:
		_failures.append("FAIL: T207.T189_COMPAT.1: _is_confirm_modal_visible 缺失 (T189 链断了)")

	# T191: backdrop gui_input 调 _on_confirm_cancel
	var backdrop_handler := src.find("func _on_confirm_backdrop_gui_input")
	if backdrop_handler != -1:
		var backdrop_end := src.find("\nfunc ", backdrop_handler + 1)
		if backdrop_end == -1:
			backdrop_end = src.length()
		var backdrop_body := src.substr(backdrop_handler, backdrop_end - backdrop_handler)
		if backdrop_body.find("_on_confirm_cancel()") != -1:
			_passes += 1
			print("  OK  T207.T191_COMPAT.1: T191 backdrop gui_input 调 _on_confirm_cancel (走 T207 guard)")
		else:
			_failures.append("FAIL: T207.T191_COMPAT.1: T191 backdrop 不调 _on_confirm_cancel")
	else:
		_failures.append("FAIL: T207.T191_COMPAT.1: T191 backdrop handler 缺失")

	# T192: _input Esc 调 _on_confirm_cancel
	var input_handler := src.find("func _input(event: InputEvent) -> void:")
	if input_handler != -1:
		var input_end := src.find("\nfunc ", input_handler + 1)
		if input_end == -1:
			input_end = src.length()
		var input_body := src.substr(input_handler, input_end - input_handler)
		if input_body.find("_on_confirm_cancel()") != -1:
			_passes += 1
			print("  OK  T207.T192_COMPAT.1: T192 _input Esc 调 _on_confirm_cancel (走 T207 guard)")
		else:
			_failures.append("FAIL: T207.T192_COMPAT.1: T192 _input Esc 不调 _on_confirm_cancel")
	else:
		_failures.append("FAIL: T207.T192_COMPAT.1: T192 _input handler 缺失")

	# T188 confirm cancel button 也调 _on_confirm_cancel (3 路同源链第 3 路)
	var ready_start := src.find("func _ready() -> void:")
	if ready_start != -1:
		var ready_end := src.find("\nfunc ", ready_start + 1)
		if ready_end == -1:
			ready_end = src.length()
		var ready_body := src.substr(ready_start, ready_end - ready_start)
		if ready_body.find("_confirm_cancel_btn.pressed.connect(_on_confirm_cancel)") != -1:
			_passes += 1
			print("  OK  T207.T188_BTN_COMPAT.1: T188 confirm cancel button pressed 也调 _on_confirm_cancel (走 T207 guard)")
		else:
			_failures.append("FAIL: T207.T188_BTN_COMPAT.1: confirm cancel button 不调 _on_confirm_cancel (3 路同源链断了)")

	# SINGLE_FIRE: guard 机制保证同帧双调只第一个进入 _hide_confirm_modal
	# 验证方法: 检查 guard 注释明确说"首个事件胜出, 第二个 no-op"
	if src.find("首个事件胜出") != -1 and src.find("no-op") != -1:
		_passes += 1
		print("  OK  T207.SINGLE_FIRE.1: 注释明确 single-fire 语义 (首个事件胜出, 第二个 no-op)")
	else:
		_failures.append("FAIL: T207.SINGLE_FIRE.1: 注释未明确 single-fire 优先级语义")


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
	print("I032 (#124) T207 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
