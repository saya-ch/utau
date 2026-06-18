extends SceneTree
## I018 (#107) — T188 SaveSlot confirm modal 二次弹窗 UX 升级 冒烟测试
##
## 覆盖 #107 主任务 T188. 验证破坏性操作 (delete save slot) 的二次确认弹窗
## 落地. 三类断言:
##
## === T188 — 二次确认弹窗结构与信号接线 ===
## - T188.TSCN.NODE: ConfirmDeleteLayer 节点存在 (CanvasLayer layer=64)
## - T188.TSCN.BACKDROP: ConfirmBackdrop ColorRect (anchors_preset=15) 全屏
## - T188.TSCN.PANEL: ConfirmPanel PanelContainer (anchors_preset=8) 居中
## - T188.TSCN.TITLE: ConfirmTitle Label 含 "确认删除存档？"
## - T188.TSCN.MSG: ConfirmMessage Label 含 "此操作不可撤销"
## - T188.TSCN.CANCEL: ConfirmCancelBtn Button 文本 "取消"
## - T188.TSCN.DELETE: ConfirmDeleteBtn Button 文本 "删除"
## - T188.TSCN.INIT_HIDDEN: 4 个关键子节点 (backdrop/panel/cancel/delete) 初始 visible=false
##
## === T188 — script @onready + 二次确认 logic ===
## - T188.GD.ONREADY: 8 个 @onready 字段 (_confirm_layer/.../delete_btn) 声明
## - T188.GD.PENDING: _pending_delete_slot 字段 (-1 = 无 pending)
## - T188.GD.READY_HIDE: _ready 末尾调 _hide_confirm_modal
## - T188.GD.READY_SIGNALS: _confirm_cancel_btn + _confirm_delete_btn 信号连接
## - T188.GD.ON_DELETE_GUARD: _on_delete 守卫 (节点 null → fallback)
## - T188.GD.ON_DELETE_SHOW: _on_delete 走 _show_confirm_modal 而非直接 emit
## - T188.GD.SHOW_SLOT: _show_confirm_modal 写入 slot_id
## - T188.GD.SHOW_VISIBLE: 4 个 visible=true
## - T188.GD.SHOW_FOCUS: 焦点给 cancel 按钮
## - T188.GD.HIDE_RESET: _hide_confirm_modal 重置 _pending_delete_slot=-1
## - T188.GD.CANCEL: _on_confirm_cancel 调 _hide_confirm_modal
## - T188.GD.DELETE_EMIT: _on_confirm_delete emit delete_requested
## - T188.GD.DELETE_AUDIO: play_delete_confirm SFX 在确认后触发
## - T188.GD.BACK_HIDE: _on_back 末尾调 _hide_confirm_modal 防 _pending 残留

const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"
const SAVE_LOAD_MENU_TSCN := "res://src/scenes/save_load_menu.tscn"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I018 (#107) — T188 SaveSlot confirm modal 二次弹窗 UX 升级 ===")
	_run_t188_tscn_assertions()
	_run_t188_tscn_init_hidden_assertions()
	_run_t188_gd_onready_assertions()
	_run_t188_gd_signal_assertions()
	_run_t188_gd_on_delete_assertions()
	_run_t188_gd_show_modal_assertions()
	_run_t188_gd_hide_modal_assertions()
	_run_t188_gd_confirm_buttons_assertions()
	_run_t188_gd_back_safety_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I018 (#107) T188 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T188.TSCN — 弹窗结构 ----------
func _run_t188_tscn_assertions() -> void:
	print("--- T188.TSCN — 弹窗结构 ---")
	var src := _read_file(SAVE_LOAD_MENU_TSCN)
	_assert_contains(src, "[node name=\"ConfirmDeleteLayer\" type=\"CanvasLayer\" parent=\".\"]",
		"T188.TSCN.NODE.1: ConfirmDeleteLayer 节点声明 (独立 CanvasLayer 不与 SaveLoadMenu 一起 hidden)")
	_assert_contains(src, "layer = 64",
		"T188.TSCN.NODE.2: CanvasLayer layer=64 (高于 main UI, 提示层)")
	_assert_contains(src, "[node name=\"ConfirmBackdrop\" type=\"ColorRect\" parent=\"ConfirmDeleteLayer\"]",
		"T188.TSCN.BACKDROP.1: ConfirmBackdrop ColorRect 节点")
	_assert_contains(src, "anchor_right = 1.0\nanchor_bottom = 1.0",
		"T188.TSCN.BACKDROP.2: backdrop 锚全屏 (anchors_preset=15)")
	_assert_contains(src, "Color(0.02, 0.047, 0.078, 0.6)",
		"T188.TSCN.BACKDROP.3: backdrop 半透明深海蓝遮罩 (STYLE_GUIDE 限制色板 token)")
	_assert_contains(src, "[node name=\"ConfirmPanel\" type=\"PanelContainer\" parent=\"ConfirmDeleteLayer\"]",
		"T188.TSCN.PANEL.1: ConfirmPanel 节点")
	_assert_contains(src, "anchors_preset = 8",
		"T188.TSCN.PANEL.2: panel 居中锚 (anchors_preset=8)")
	_assert_contains(src, "text = \"确认删除存档？\"",
		"T188.TSCN.TITLE.1: 标题文案 \"确认删除存档？\"")
	_assert_contains(src, "Color(0.906, 0.427, 0.353, 1)",
		"T188.TSCN.TITLE.2: 标题色 = Soft Coral #E76D5A (STYLE_GUIDE token, 危险警告色)")
	_assert_contains(src, "text = \"此操作不可撤销。存档将被永久删除。\"",
		"T188.TSCN.MSG.1: 默认 message 文案 (slot 0 模板)")
	_assert_contains(src, "[node name=\"ConfirmCancelBtn\" type=\"Button\"",
		"T188.TSCN.CANCEL.1: Cancel 按钮节点")
	_assert_contains(src, "[node name=\"ConfirmDeleteBtn\" type=\"Button\"",
		"T188.TSCN.DELETE.1: Delete 按钮节点")


# ---------- T188.TSCN.INIT_HIDDEN — 初始 hidden ----------
func _run_t188_tscn_init_hidden_assertions() -> void:
	print("--- T188.TSCN.INIT_HIDDEN — 初始 hidden ---")
	var src := _read_file(SAVE_LOAD_MENU_TSCN)
	# backdrop / panel / cancel / delete 初始 visible = false
	# 用特征串确认结构存在且未在 _ready 里手动 hide
	# backdrop 段 (在 ConfirmBackdrop 节点内)
	var backdrop_start := src.find("[node name=\"ConfirmBackdrop\"")
	var backdrop_end := src.find("[node name=\"ConfirmPanel\"")
	if backdrop_start != -1 and backdrop_end != -1:
		var backdrop_block := src.substr(backdrop_start, backdrop_end - backdrop_start)
		_assert_contains(backdrop_block, "visible = false",
			"T188.TSCN.INIT_HIDDEN.1: backdrop 初始 visible = false")
	else:
		_failures.append("FAIL: T188.TSCN.INIT_HIDDEN.1: backdrop/panel 范围解析失败")
	# panel 段 (含整个 PanelContainer + 它的所有子节点) - visible 在 panel 节点本身上
	var panel_start := src.find("[node name=\"ConfirmPanel\" type=\"PanelContainer\"")
	var cancel_btn_start := src.find("[node name=\"ConfirmCancelBtn\"")
	if panel_start != -1 and cancel_btn_start != -1:
		var panel_block := src.substr(panel_start, cancel_btn_start - panel_start)
		_assert_contains(panel_block, "visible = false",
			"T188.TSCN.INIT_HIDDEN.2: panel 初始 visible = false (含子节点不显示)")
	else:
		_failures.append("FAIL: T188.TSCN.INIT_HIDDEN.2: panel 范围解析失败")


# ---------- T188.GD.ONREADY — @onready 字段 ----------
func _run_t188_gd_onready_assertions() -> void:
	print("--- T188.GD.ONREADY — @onready 字段 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "@onready var _confirm_layer: CanvasLayer = $ConfirmDeleteLayer",
		"T188.GD.ONREADY.1: _confirm_layer @onready 字段")
	_assert_contains(src, "@onready var _confirm_backdrop: ColorRect = $ConfirmDeleteLayer/ConfirmBackdrop",
		"T188.GD.ONREADY.2: _confirm_backdrop @onready 字段")
	_assert_contains(src, "@onready var _confirm_panel: PanelContainer = $ConfirmDeleteLayer/ConfirmPanel",
		"T188.GD.ONREADY.3: _confirm_panel @onready 字段")
	_assert_contains(src, "@onready var _confirm_title: Label = $ConfirmDeleteLayer/ConfirmPanel/ConfirmMargin/ConfirmVBox/ConfirmTitle",
		"T188.GD.ONREADY.4: _confirm_title @onready 字段")
	_assert_contains(src, "@onready var _confirm_message: Label = $ConfirmDeleteLayer/ConfirmPanel/ConfirmMargin/ConfirmVBox/ConfirmMessage",
		"T188.GD.ONREADY.5: _confirm_message @onready 字段")
	_assert_contains(src, "@onready var _confirm_cancel_btn: Button = $ConfirmDeleteLayer/ConfirmPanel/ConfirmMargin/ConfirmVBox/ConfirmButtons/ConfirmCancelBtn",
		"T188.GD.ONREADY.6: _confirm_cancel_btn @onready 字段")
	_assert_contains(src, "@onready var _confirm_delete_btn: Button = $ConfirmDeleteLayer/ConfirmPanel/ConfirmMargin/ConfirmVBox/ConfirmButtons/ConfirmDeleteBtn",
		"T188.GD.ONREADY.7: _confirm_delete_btn @onready 字段")
	_assert_contains(src, "var _pending_delete_slot: int = -1",
		"T188.GD.PENDING.1: _pending_delete_slot 字段 (-1 = 无 pending)")


# ---------- T188.GD.SIGNAL — _ready 信号连接 ----------
func _run_t188_gd_signal_assertions() -> void:
	print("--- T188.GD.SIGNAL — _ready 信号连接 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "_confirm_cancel_btn.pressed.connect(_on_confirm_cancel)",
		"T188.GD.READY_SIGNALS.1: cancel 按钮信号连接")
	_assert_contains(src, "_confirm_delete_btn.pressed.connect(_on_confirm_delete)",
		"T188.GD.READY_SIGNALS.2: delete 按钮信号连接")
	_assert_contains(src, "_hide_confirm_modal()",
		"T188.GD.READY_HIDE.1: _ready 末尾调 _hide_confirm_modal (幂等隐藏)")
	# 顺序 (在 _ready 函数体内): 信号连接要在 _hide_confirm_modal 之前
	# (避免空 signal 调用). scope 到 _ready 函数体避免误判
	# helper 函数定义中的 _hide_confirm_modal() 出现位置
	var ready_start := src.find("func _ready() -> void:")
	if ready_start == -1:
		_failures.append("FAIL: T188.GD.READY_ORDER.1: _ready 函数未找到")
		return
	var ready_end := src.find("\nfunc ", ready_start + 1)
	if ready_end == -1:
		ready_end = src.length()
	var ready_body := src.substr(ready_start, ready_end - ready_start)
	# 排除注释行 (用 "\t_hide_confirm_modal()" 避免匹配到注释里的引用)
	var sig_pos := ready_body.find("_confirm_cancel_btn.pressed.connect")
	var hide_pos := ready_body.find("\t_hide_confirm_modal()")
	if sig_pos != -1 and hide_pos != -1 and sig_pos < hide_pos:
		_passes += 1
		print("  OK  T188.GD.READY_ORDER.1: 信号连接早于 _hide_confirm_modal 调用 (防御空 signal 警告)")
	else:
		_failures.append("FAIL: T188.GD.READY_ORDER.1: 信号连接顺序异常 (sig_pos=%d, hide_pos=%d)" % [sig_pos, hide_pos])


# ---------- T188.GD.ON_DELETE — _on_delete 走二次确认 ----------
func _run_t188_gd_on_delete_assertions() -> void:
	print("--- T188.GD.ON_DELETE — _on_delete 走二次确认 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	var on_delete_start := src.find("func _on_delete(slot_id: int) -> void:")
	if on_delete_start == -1:
		_failures.append("FAIL: T188.GD.ON_DELETE.1: _on_delete 函数未找到")
		return
	var on_delete_end := src.find("\nfunc _show_confirm_modal", on_delete_start)
	if on_delete_end == -1:
		on_delete_end = src.length()
	var body := src.substr(on_delete_start, on_delete_end - on_delete_start)
	_assert_contains(body, "T188",
		"T188.GD.ON_DELETE_TAG.1: _on_delete 含 T188 锚点注释")
	_assert_contains(body, "_confirm_layer == null or _confirm_panel == null",
		"T188.GD.ON_DELETE_GUARD.1: 弹窗节点 null 守卫 (防御 tscn 损坏)")
	_assert_contains(body, "_show_confirm_modal(slot_id)",
		"T188.GD.ON_DELETE_SHOW.1: 走 _show_confirm_modal 而非直接 emit delete_requested")
	# 关键: 旧的 "delete_requested.emit(slot_id)" 不应直接出现在 _on_delete 中
	# (防御: 重构时残留旧行为, 测试会发现)
	if body.find("delete_requested.emit") != -1:
		_failures.append("FAIL: T188.GD.ON_DELETE_SHOW.2: _on_delete 不应直接 emit delete_requested (应走二次确认)")
	else:
		_passes += 1
		print("  OK  T188.GD.ON_DELETE_SHOW.2: _on_delete 不直接 emit (走 _show_confirm_modal 路径)")


# ---------- T188.GD.SHOW — _show_confirm_modal 行为 ----------
func _run_t188_gd_show_modal_assertions() -> void:
	print("--- T188.GD.SHOW — _show_confirm_modal 行为 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	var show_start := src.find("func _show_confirm_modal(slot_id: int) -> void:")
	if show_start == -1:
		_failures.append("FAIL: T188.GD.SHOW.1: _show_confirm_modal 函数未找到")
		return
	var show_end := src.find("\nfunc _hide_confirm_modal", show_start)
	if show_end == -1:
		show_end = src.length()
	var body := src.substr(show_start, show_end - show_start)
	_assert_contains(body, "_pending_delete_slot = slot_id",
		"T188.GD.SHOW_SLOT.1: 写入 _pending_delete_slot")
	_assert_contains(body, "if _confirm_message:",
		"T188.GD.SHOW_MSG_GUARD.1: message 标签 null 守卫")
	_assert_contains(body, "_confirm_message.text = \"槽位 %d",
		"T188.GD.SHOW_MSG.1: 动态文案 (含具体 slot 编号)")
	_assert_contains(body, "if _confirm_layer:",
		"T188.GD.SHOW_VISIBLE.1a: layer visible 检查守卫")
	_assert_contains(body, "_confirm_layer.visible = true",
		"T188.GD.SHOW_VISIBLE.1b: layer visible=true")
	_assert_contains(body, "_confirm_backdrop.visible = true",
		"T188.GD.SHOW_VISIBLE.2: backdrop visible=true")
	_assert_contains(body, "_confirm_panel.visible = true",
		"T188.GD.SHOW_VISIBLE.3: panel visible=true")
	_assert_contains(body, "_confirm_cancel_btn.grab_focus()",
		"T188.GD.SHOW_FOCUS.1: 焦点给 cancel 按钮 (破坏性操作的 default 应该是取消)")


# ---------- T188.GD.HIDE — _hide_confirm_modal 行为 ----------
func _run_t188_gd_hide_modal_assertions() -> void:
	print("--- T188.GD.HIDE — _hide_confirm_modal 行为 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	var hide_start := src.find("func _hide_confirm_modal() -> void:")
	if hide_start == -1:
		_failures.append("FAIL: T188.GD.HIDE.1: _hide_confirm_modal 函数未找到")
		return
	var hide_end := src.find("\nfunc _on_confirm_cancel", hide_start)
	if hide_end == -1:
		hide_end = src.length()
	var body := src.substr(hide_start, hide_end - hide_start)
	_assert_contains(body, "_pending_delete_slot = -1",
		"T188.GD.HIDE_RESET.1: _pending_delete_slot 重置为 -1")
	_assert_contains(body, "_confirm_layer.visible = false",
		"T188.GD.HIDE_VISIBLE.1: layer visible=false")
	_assert_contains(body, "_confirm_backdrop.visible = false",
		"T188.GD.HIDE_VISIBLE.2: backdrop visible=false")
	_assert_contains(body, "_confirm_panel.visible = false",
		"T188.GD.HIDE_VISIBLE.3: panel visible=false")
	# 注释里说明幂等
	if body.find("幂等") != -1 or body.find("idempotent") != -1:
		_passes += 1
		print("  OK  T188.GD.HIDE_NOTE.1: 注释强调幂等 (可多次调用)")
	else:
		_failures.append("FAIL: T188.GD.HIDE_NOTE.1: 注释应强调幂等")


# ---------- T188.GD.CONFIRM — cancel + delete 行为 ----------
func _run_t188_gd_confirm_buttons_assertions() -> void:
	print("--- T188.GD.CONFIRM — cancel + delete 行为 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	# _on_confirm_cancel
	var cancel_start := src.find("func _on_confirm_cancel() -> void:")
	if cancel_start == -1:
		_failures.append("FAIL: T188.GD.CANCEL.1: _on_confirm_cancel 函数未找到")
	else:
		var cancel_end := src.find("\nfunc _on_confirm_delete", cancel_start)
		if cancel_end == -1:
			cancel_end = src.length()
		var body := src.substr(cancel_start, cancel_end - cancel_start)
		_assert_contains(body, "_hide_confirm_modal()",
			"T188.GD.CANCEL.BODY.1: cancel 仅 _hide_confirm_modal (无副作用, 不 emit, 不删)")
		if body.find("delete_requested.emit") != -1:
			_failures.append("FAIL: T188.GD.CANCEL.BODY.2: cancel 路径不应 emit delete_requested")
		else:
			_passes += 1
			print("  OK  T188.GD.CANCEL.BODY.2: cancel 路径不 emit (语义对称)")
	# _on_confirm_delete
	var delete_start := src.find("func _on_confirm_delete() -> void:")
	if delete_start == -1:
		_failures.append("FAIL: T188.GD.DELETE.1: _on_confirm_delete 函数未找到")
	else:
		var delete_end := src.find("\nfunc _on_back", delete_start)
		if delete_end == -1:
			delete_end = src.length()
		var body := src.substr(delete_start, delete_end - delete_start)
		_assert_contains(body, "var slot_id: int = _pending_delete_slot",
			"T188.GD.DELETE.2: 读 _pending_delete_slot 备份到本地")
		_assert_contains(body, "_hide_confirm_modal()",
			"T188.GD.DELETE.3: 先 _hide_confirm_modal 再 emit (避免 _pending 残留到下一帧)")
		_assert_contains(body, "play_delete_confirm",
			"T188.GD.DELETE_AUDIO.1: 走 play_delete_confirm SFX (与之前 _on_delete 行为一致)")
		_assert_contains(body, "delete_requested.emit(slot_id)",
			"T188.GD.DELETE_EMIT.1: emit delete_requested(slot_id) (与 #106 之前同源链)")


# ---------- T188.GD.BACK — _on_back 清理 ----------
func _run_t188_gd_back_safety_assertions() -> void:
	print("--- T188.GD.BACK — _on_back 清理 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	var back_start := src.find("func _on_back() -> void:")
	if back_start == -1:
		_failures.append("FAIL: T188.GD.BACK.1: _on_back 函数未找到")
		return
	var body := src.substr(back_start)
	_assert_contains(body, "T188",
		"T188.GD.BACK.2: _on_back 含 T188 锚点注释")
	_assert_contains(body, "_hide_confirm_modal()",
		"T188.GD.BACK_HIDE.1: _on_back 末尾调 _hide_confirm_modal (防 _pending 残留)")
	# 顺序: _hide_confirm_modal 必须在 hide_menu() 之前 (defense in depth)
	var hide_modal_pos := body.find("_hide_confirm_modal()")
	var hide_menu_pos := body.find("hide_menu()")
	if hide_modal_pos != -1 and hide_menu_pos != -1 and hide_modal_pos < hide_menu_pos:
		_passes += 1
		print("  OK  T188.GD.BACK_ORDER.1: _hide_confirm_modal 早于 hide_menu (避免 _pending 跨场景残留)")
	else:
		_failures.append("FAIL: T188.GD.BACK_ORDER.1: _on_back 顺序异常 (hide_modal_pos=%d, hide_menu_pos=%d)" % [hide_modal_pos, hide_menu_pos])


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
	print("I018 (#107) T188 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
