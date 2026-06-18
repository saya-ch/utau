extends SceneTree
## I019 (#108) — T189 SaveLoadMenu Esc 关闭 confirm modal + F017 14 成就 per-achievement chime 变体 冒烟测试
##
## 覆盖 #108 两个任务. 文本匹配 + 结构断言 模式 (与 I018 T188 一致), 验证
## Esc 二次确认弹窗 + 3 变体 (amber/coral/bright) chime 路由都正确落地.
##
## === T189 — SaveLoadMenu Esc 关闭 confirm modal (与 #107 T188 紧接延伸) ===
## - T189.GD.HANDLER: _unhandled_key_input 函数存在
## - T189.GD.ACTION: is_action_pressed("ui_cancel") 守卫
## - T189.GD.VIS_GUARD: 菜单整体 hidden 时不消费 Esc
## - T189.GD.MODAL_ESC: 弹窗 visible 时调 _on_confirm_cancel (安全默认)
## - T189.GD.MENU_ESC: 弹窗未显示时调 _on_back
## - T189.GD.HANDLED: get_viewport().set_input_as_handled 调用
## - T189.GD.DOC_ANCHOR: 函数体含 T189 注释锚点
## - T189.GD.PRIORITY: _unhandled_key_input 而非 _input (子按钮优先)
##
## === F017 — 14 成就 per-achievement chime 变体 (amber/coral/bright) ===
## - F017.GD.CACHE: _unlock_chime_streams Dictionary 字段
## - F017.GD.API: play_unlock_chime(ach_id) 公开 API (参数化)
## - F017.GD.API_COMPAT: 旧 API ach_id=="" → legacy F014 stream
## - F017.GD.ROUTE: _route_chime_variant 函数 + 3 桶 (coral/bright/amber)
## - F017.GD.ROUTE_CORAL: 4 coral_* 成就 → "coral"
## - F017.GD.ROUTE_BRIGHT: 3 voice_* 集齐 → "bright"
## - F017.GD.ROUTE_AMBER: 其余 7 兜底 → "amber"
## - F017.GD.DISPATCH: _generate_chime_for_variant dispatch 函数
## - F017.GD.SYNTH_AMBER: _generate_amber_unlock_chime_sfx 函数
## - F017.GD.SYNTH_CORAL: _generate_coral_unlock_chime_sfx 函数
## - F017.GD.SYNTH_BRIGHT: _generate_bright_unlock_chime_sfx 函数
## - F017.GD.SYNTH_HZ_AMBER: amber 4 音含 523.25/659.26/783.99/1046.50Hz
## - F017.GD.SYNTH_HZ_CORAL: coral 4 音含 440/523.25/659.26/880Hz
## - F017.GD.SYNTH_HZ_BRIGHT: bright 4 音含 392/493.88/587.33/783.99Hz
## - F017.GD.PREWARM: prewarm_misc_sfx 预热 3 变体 (amber/coral/bright)
##
## === ACHIEVEMENT_NOTIFICATION — F017 调用链 ===
## - F017.AN.HELPER_SIG: _play_unlock_chime(id_val) 接受参数
## - F017.AN.HELPER_CALL: ame.call("play_unlock_chime", id_val) 传参
## - F017.AN.HANDLER_CALL: _on_achievement_unlocked 传 id_val 给 helper

const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"
const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const ACHIEVEMENT_NOTIFICATION_GD := "res://src/scripts/achievement_notification.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I019 (#108) — T189 Save Esc + F017 14 成就 chime 变体 ===")
	_run_t189_save_esc_assertions()
	_run_f017_chime_cache_assertions()
	_run_f017_chime_api_assertions()
	_run_f017_chime_route_assertions()
	_run_f017_chime_dispatch_assertions()
	_run_f017_chime_synth_assertions()
	_run_f017_chime_prewarm_assertions()
	_run_f017_achievement_notification_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I019 (#108) T189 + F017 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T189.GD — SaveLoadMenu Esc 关闭弹窗 ----------
func _run_t189_save_esc_assertions() -> void:
	print("--- T189.GD — SaveLoadMenu Esc 关闭弹窗 ---")
	var src := _read_file(SAVE_LOAD_MENU_GD)
	_assert_contains(src, "func _unhandled_key_input(event: InputEvent) -> void:",
		"T189.GD.HANDLER.1: _unhandled_key_input handler 存在 (T189 入口)")
	# scope 到 _unhandled_key_input 函数体, 避免误判 _on_back 内的 ui_cancel 注释
	var handler_start := src.find("func _unhandled_key_input(event: InputEvent) -> void:")
	if handler_start == -1:
		_failures.append("FAIL: T189.GD.HANDLER.2: _unhandled_key_input 函数未找到")
		return
	var handler_end := src.find("\nfunc ", handler_start + 1)
	if handler_end == -1:
		handler_end = src.length()
	var body := src.substr(handler_start, handler_end - handler_start)
	_assert_contains(body, "is_action_pressed(\"ui_cancel\")",
		"T189.GD.ACTION.1: is_action_pressed(\"ui_cancel\") 守卫 (Esc/Backspace/gamepad B)")
	_assert_contains(body, "if not visible:",
		"T189.GD.VIS_GUARD.1: 菜单整体 hidden 时不消费 Esc (避免 transient state 误触发)")
	_assert_contains(body, "_confirm_layer and _confirm_layer.visible",
		"T189.GD.MODAL_GUARD.1: 弹窗 visible 状态守卫")
	_assert_contains(body, "_on_confirm_cancel()",
		"T189.GD.MODAL_ESC.1: 弹窗 visible 时调 _on_confirm_cancel (安全默认 = 不删)")
	_assert_contains(body, "_on_back()",
		"T189.GD.MENU_ESC.1: 弹窗未显示时调 _on_back (与点 Back 按钮同语义)")
	_assert_contains(body, "get_viewport().set_input_as_handled()",
		"T189.GD.HANDLED.1: set_input_as_handled 防止事件下传 (避免双触发 _on_back)")
	# T189 注释锚点应在 handler 之前的 docblock (注释块) 中 — 函数体本身只放
	# 实现逻辑, 锚点用 # T189 (#108) 形式放在 func 上一段 docstring.  所以
	# 向前搜 1200 chars 找到 docblock.
	var doc_scan_start: int = max(0, handler_start - 1200)
	var doc_block: String = src.substr(doc_scan_start, handler_start - doc_scan_start)
	_assert_contains(doc_block, "T189",
		"T189.GD.DOC_ANCHOR.1: handler 之前 docblock 含 T189 注释锚点 (#108)")
	# 顺序: modal-esc 分支在前, menu-esc 分支在后, 两条都 set_input_as_handled
	var modal_esc_pos := body.find("_on_confirm_cancel()")
	var menu_esc_pos := body.find("_on_back()")
	if modal_esc_pos != -1 and menu_esc_pos != -1 and modal_esc_pos < menu_esc_pos:
		_passes += 1
		print("  OK  T189.GD.MODAL_FIRST.1: modal-esc 分支早于 menu-esc 分支 (弹窗优先级最高)")
	else:
		_failures.append("FAIL: T189.GD.MODAL_FIRST.1: 顺序异常 (modal_pos=%d, menu_pos=%d)" % [modal_esc_pos, menu_esc_pos])
	# 防御: T189 handler 不应是 _input (子按钮需要优先接收事件)
	if src.find("\nfunc _input(event: InputEvent)") != -1:
		_failures.append("FAIL: T189.GD.PRIORITY.1: 误用 _input 而非 _unhandled_key_input (会吞掉子按钮事件)")
	else:
		_passes += 1
		print("  OK  T189.GD.PRIORITY.1: 使用 _unhandled_key_input 让子按钮优先接收 Enter/Space")


# ---------- F017.GD.CACHE — chime cache 字段 ----------
func _run_f017_chime_cache_assertions() -> void:
	print("--- F017.GD.CACHE — chime cache 字段 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _unlock_chime_streams: Dictionary = {}",
		"F017.GD.CACHE.1: _unlock_chime_streams Dictionary 字段 (3 变体 cache)")
	# 注释应说明 3 桶
	_assert_contains(src, "\"amber\"",
		"F017.GD.CACHE.2: amber 桶常量 (注释中)")
	_assert_contains(src, "\"coral\"",
		"F017.GD.CACHE.3: coral 桶常量 (注释中)")
	_assert_contains(src, "\"bright\"",
		"F017.GD.CACHE.4: bright 桶常量 (注释中)")


# ---------- F017.GD.API — chime 公开 API + 旧 API 兼容 ----------
func _run_f017_chime_api_assertions() -> void:
	print("--- F017.GD.API — chime 公开 API + 旧 API 兼容 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_unlock_chime(ach_id: String = \"\") -> void:",
		"F017.GD.API.1: play_unlock_chime(ach_id) 公开 API 接受 id 参数")
	# 旧 API 兼容: ach_id == "" → 走 legacy _unlock_chime_stream
	var api_start := src.find("func play_unlock_chime(ach_id: String = \"\") -> void:")
	if api_start == -1:
		_failures.append("FAIL: F017.GD.API.2: play_unlock_chime 函数未找到")
		return
	var api_end := src.find("\nfunc ", api_start + 1)
	if api_end == -1:
		api_end = src.length()
	var body := src.substr(api_start, api_end - api_start)
	_assert_contains(body, "ach_id.is_empty()",
		"F017.GD.API_COMPAT.1: ach_id 空串走 legacy 路径 (向后兼容)")
	_assert_contains(body, "_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"F017.GD.API_COMPAT.2: legacy 路径复用 F014 合成函数 (不破坏 #103 旧 API)")
	_assert_contains(body, "_route_chime_variant(ach_id)",
		"F017.GD.API.3: 非空 ach_id 走 _route_chime_variant 路由")


# ---------- F017.GD.ROUTE — chime 路由 ----------
func _run_f017_chime_route_assertions() -> void:
	print("--- F017.GD.ROUTE — chime 路由 (coral/bright/amber) ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _route_chime_variant(ach_id: String) -> String:",
		"F017.GD.ROUTE.1: _route_chime_variant 函数存在")
	# 4 coral_* 成就路由
	var coral_block := _extract_block(src, "func _route_chime_variant(ach_id: String) -> String:",
		"func _generate_chime_for_variant")
	if coral_block.is_empty():
		_failures.append("FAIL: F017.GD.ROUTE.2: _route_chime_variant 函数体未找到")
		return
	_assert_contains(coral_block, "\"voice_purifier\"",
		"F017.GD.ROUTE_CORAL.1: voice_purifier 路由到 coral")
	_assert_contains(coral_block, "\"silence_hunter\"",
		"F017.GD.ROUTE_CORAL.2: silence_hunter 路由到 coral")
	_assert_contains(coral_block, "\"first_cut\"",
		"F017.GD.ROUTE_CORAL.3: first_cut 路由到 coral")
	_assert_contains(coral_block, "\"warden_slayer\"",
		"F017.GD.ROUTE_CORAL.4: warden_slayer 路由到 coral")
	_assert_contains(coral_block, "return \"coral\"",
		"F017.GD.ROUTE_CORAL.5: coral 桶返回 \"coral\" 字符串")
	_assert_contains(coral_block, "\"triple_voice\"",
		"F017.GD.ROUTE_BRIGHT.1: triple_voice 路由到 bright")
	_assert_contains(coral_block, "\"quadruple_voice\"",
		"F017.GD.ROUTE_BRIGHT.2: quadruple_voice 路由到 bright")
	_assert_contains(coral_block, "\"quintuple_voice\"",
		"F017.GD.ROUTE_BRIGHT.3: quintuple_voice 路由到 bright")
	_assert_contains(coral_block, "return \"bright\"",
		"F017.GD.ROUTE_BRIGHT.4: bright 桶返回 \"bright\" 字符串")
	_assert_contains(coral_block, "return \"amber\"",
		"F017.GD.ROUTE_AMBER.1: 兜底返回 \"amber\" (未知 id 安全默认)")


# ---------- F017.GD.DISPATCH — variant dispatch ----------
func _run_f017_chime_dispatch_assertions() -> void:
	print("--- F017.GD.DISPATCH — variant dispatch ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_chime_for_variant(variant: String) -> AudioStreamWAV:",
		"F017.GD.DISPATCH.1: _generate_chime_for_variant dispatch 函数")
	var dispatch_block := _extract_block(src, "func _generate_chime_for_variant(variant: String) -> AudioStreamWAV:",
		"\nfunc ")
	if dispatch_block.is_empty():
		_failures.append("FAIL: F017.GD.DISPATCH.2: dispatch 函数体未找到")
		return
	_assert_contains(dispatch_block, "match variant:",
		"F017.GD.DISPATCH.3: match variant 分支 (避免 if-elif 链)")
	_assert_contains(dispatch_block, "\"amber\":",
		"F017.GD.DISPATCH.4: amber 分支")
	_assert_contains(dispatch_block, "\"coral\":",
		"F017.GD.DISPATCH.5: coral 分支")
	_assert_contains(dispatch_block, "\"bright\":",
		"F017.GD.DISPATCH.6: bright 分支")
	_assert_contains(dispatch_block, "_generate_amber_unlock_chime_sfx()",
		"F017.GD.DISPATCH.7: amber 桶调 amber synth")
	_assert_contains(dispatch_block, "_generate_coral_unlock_chime_sfx()",
		"F017.GD.DISPATCH.8: coral 桶调 coral synth")
	_assert_contains(dispatch_block, "_generate_bright_unlock_chime_sfx()",
		"F017.GD.DISPATCH.9: bright 桶调 bright synth")


# ---------- F017.GD.SYNTH — 3 变体 synth 函数 + Hz 锚点 ----------
func _run_f017_chime_synth_assertions() -> void:
	print("--- F017.GD.SYNTH — 3 变体 synth 函数 + Hz 锚点 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_amber_unlock_chime_sfx() -> AudioStreamWAV:",
		"F017.GD.SYNTH_AMBER.1: _generate_amber_unlock_chime_sfx 函数")
	_assert_contains(src, "func _generate_coral_unlock_chime_sfx() -> AudioStreamWAV:",
		"F017.GD.SYNTH_CORAL.1: _generate_coral_unlock_chime_sfx 函数")
	_assert_contains(src, "func _generate_bright_unlock_chime_sfx() -> AudioStreamWAV:",
		"F017.GD.SYNTH_BRIGHT.1: _generate_bright_unlock_chime_sfx 函数")
	# Hz 锚点: amber 4 音 523.25/659.26/783.99/1046.50 (C5/E5/G5/C6)
	var amber_block := _extract_block(src, "func _generate_amber_unlock_chime_sfx() -> AudioStreamWAV:",
		"\nfunc ")
	if not amber_block.is_empty():
		_assert_contains(amber_block, "TAU * 523.25",
			"F017.GD.SYNTH_HZ_AMBER.1: C5 523.25Hz 基频")
		_assert_contains(amber_block, "TAU * 659.26",
			"F017.GD.SYNTH_HZ_AMBER.2: E5 659.26Hz 谐波")
		_assert_contains(amber_block, "TAU * 783.99",
			"F017.GD.SYNTH_HZ_AMBER.3: G5 783.99Hz 谐波")
		_assert_contains(amber_block, "TAU * 1046.50",
			"F017.GD.SYNTH_HZ_AMBER.4: C6 1046.50Hz 圆满 octave")
		_assert_contains(amber_block, "exp(-t * 6.5)",
			"F017.GD.SYNTH_DECAY_AMBER.1: 衰减常数 6.5 (介于 F014 6.0 与 F013 6.0 之间)")
	else:
		_failures.append("FAIL: F017.GD.SYNTH_AMBER.2: amber 函数体未找到")
	# Hz 锚点: coral 4 音 440/523.25/659.26/880 (A4/C5/E5/A5)
	var coral_block := _extract_block(src, "func _generate_coral_unlock_chime_sfx() -> AudioStreamWAV:",
		"\nfunc ")
	if not coral_block.is_empty():
		_assert_contains(coral_block, "TAU * 440.00",
			"F017.GD.SYNTH_HZ_CORAL.1: A4 440Hz 基频 (coral 主调 A 小调)")
		_assert_contains(coral_block, "TAU * 523.25",
			"F017.GD.SYNTH_HZ_CORAL.2: C5 523.25Hz 谐波")
		_assert_contains(coral_block, "TAU * 659.26",
			"F017.GD.SYNTH_HZ_CORAL.3: E5 659.26Hz 谐波")
		_assert_contains(coral_block, "TAU * 880.00",
			"F017.GD.SYNTH_HZ_CORAL.4: A5 880Hz 圆满 octave")
		_assert_contains(coral_block, "exp(-t * 7.0)",
			"F017.GD.SYNTH_DECAY_CORAL.1: 衰减常数 7.0 (比 amber 6.5 快, 紧迫感)")
	else:
		_failures.append("FAIL: F017.GD.SYNTH_CORAL.2: coral 函数体未找到")
	# Hz 锚点: bright 4 音 392/493.88/587.33/783.99 (G4/B4/D5/G5)
	var bright_block := _extract_block(src, "func _generate_bright_unlock_chime_sfx() -> AudioStreamWAV:",
		"\nfunc ")
	if not bright_block.is_empty():
		_assert_contains(bright_block, "TAU * 392.00",
			"F017.GD.SYNTH_HZ_BRIGHT.1: G4 392Hz 基频 (bright 主调 G 大调)")
		_assert_contains(bright_block, "TAU * 493.88",
			"F017.GD.SYNTH_HZ_BRIGHT.2: B4 493.88Hz 谐波")
		_assert_contains(bright_block, "TAU * 587.33",
			"F017.GD.SYNTH_HZ_BRIGHT.3: D5 587.33Hz 谐波")
		_assert_contains(bright_block, "TAU * 783.99",
			"F017.GD.SYNTH_HZ_BRIGHT.4: G5 783.99Hz 圆满 octave")
		_assert_contains(bright_block, "exp(-t * 5.5)",
			"F017.GD.SYNTH_DECAY_BRIGHT.1: 衰减常数 5.5 (比 amber 6.5 慢, 仪式感最强)")
	else:
		_failures.append("FAIL: F017.GD.SYNTH_BRIGHT.2: bright 函数体未找到")


# ---------- F017.GD.PREWARM — prewarm 3 变体 ----------
func _run_f017_chime_prewarm_assertions() -> void:
	print("--- F017.GD.PREWARM — prewarm 3 变体 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_start == -1:
		_failures.append("FAIL: F017.GD.PREWARM.1: prewarm_misc_sfx 函数未找到")
		return
	var prewarm_end := src.find("\nfunc ", prewarm_start + 1)
	if prewarm_end == -1:
		prewarm_end = src.length()
	var body := src.substr(prewarm_start, prewarm_end - prewarm_start)
	_assert_contains(body, "F017",
		"F017.GD.PREWARM.2: 注释锚点 F017 (#108) 在 prewarm_misc_sfx")
	_assert_contains(body, "for variant in [\"amber\", \"coral\", \"bright\"]:",
		"F017.GD.PREWARM.3: 循环 3 变体 (amber/coral/bright)")
	_assert_contains(body, "_unlock_chime_streams[variant] = _generate_chime_for_variant(variant)",
		"F017.GD.PREWARM.4: 调 dispatch 预热每桶")
	# 顺序: legacy F014 预热 (既有) 在前, F017 3 变体在后 (符合 music→hit→shop→misc 顺序稳定性)
	var legacy_pos := body.find("_unlock_chime_stream = _generate_unlock_chime_sfx()")
	var variants_pos := body.find("for variant in [\"amber\", \"coral\", \"bright\"]:")
	if legacy_pos != -1 and variants_pos != -1 and legacy_pos < variants_pos:
		_passes += 1
		print("  OK  F017.GD.PREWARM.5: legacy F014 预热早于 F017 3 变体 (既有顺序稳定)")
	else:
		_failures.append("FAIL: F017.GD.PREWARM.5: 顺序异常 (legacy_pos=%d, variants_pos=%d)" % [legacy_pos, variants_pos])


# ---------- F017.AN — AchievementNotification 调用链 ----------
func _run_f017_achievement_notification_assertions() -> void:
	print("--- F017.AN — AchievementNotification 调用链 ---")
	var src := _read_file(ACHIEVEMENT_NOTIFICATION_GD)
	_assert_contains(src, "func _play_unlock_chime(id_val: String) -> void:",
		"F017.AN.HELPER_SIG.1: _play_unlock_chime(id_val) 接受参数 (从无参改为有参)")
	_assert_contains(src, "ame.call(\"play_unlock_chime\", id_val)",
		"F017.AN.HELPER_CALL.1: ame.call 传参 id_val 给 chime")
	# _on_achievement_unlocked 调用 helper 时必须传 id_val
	var handler_start := src.find("func _on_achievement_unlocked(id_val: String")
	if handler_start == -1:
		_failures.append("FAIL: F017.AN.HANDLER_CALL.1: _on_achievement_unlocked 函数未找到")
		return
	var handler_end := src.find("\nfunc ", handler_start + 1)
	if handler_end == -1:
		handler_end = src.length()
	var body := src.substr(handler_start, handler_end - handler_start)
	_assert_contains(body, "_play_unlock_chime(id_val)",
		"F017.AN.HANDLER_CALL.2: handler 调 _play_unlock_chime(id_val) 传参")


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _extract_block(src: String, start_marker: String, end_marker: String) -> String:
	var start_pos := src.find(start_marker)
	if start_pos == -1:
		return ""
	var end_pos := src.find(end_marker, start_pos + start_marker.length())
	if end_pos == -1:
		end_pos = src.length()
	return src.substr(start_pos, end_pos - start_pos)


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I019 (#108) T189 + F017 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
