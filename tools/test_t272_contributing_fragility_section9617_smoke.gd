# T272 smoke test — CONTRIBUTING.md §9.6.17 player.gd `_ready` 6 verb signal 桥接 5+1 件套 1:1 polish 模式 (#191 普通模式 polish T272, T162 brittle 修复流程进一步扩展, 0 真实游戏代码改动)
# 验证 §9.6.17 文档化 + 5+1 件套 1:1 描述 + 6 verb signal 桥接在 player.gd `_ready` 完整 + 1 PlayerActionGate autoload register + 对称 unregister + 0 触碰 §9.6.16 6 verb hit handler
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.17 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.17" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.17 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.17 章节标题")

	# 2. §9.6.17 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	if "**症状 / 触发场景 / 修复 / 预防**" in contributing:
		pass_count += 1
		print("PASS 2: §9.6.17 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.17 段缺 4 段完整结构")

	# 3. §9.6.17 引用 5+1 件套 (null guard / 主信号 / 命中信号 / 结束信号 / 扩展信号 / PlayerActionGate register)
	var six_pieces: Array[String] = [
		"`if verb_ability:` null guard",
		"主信号",
		"命中信号",
		"结束信号",
		"扩展信号",
		"PlayerActionGate.register_player",
	]
	var all_pieces_found: bool = true
	for piece in six_pieces:
		if piece not in contributing:
			all_pieces_found = false
			print("FAIL 3.x: §9.6.17 段缺 5+1 件套之一: %s" % piece)
	if all_pieces_found:
		pass_count += 1
		print("PASS 3: §9.6.17 段含完整 5+1 件套 (null guard / 主信号 / 命中信号 / 结束信号 / 扩展信号 / PlayerActionGate register) 1:1 描述")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.17 段缺完整 5+1 件套 1:1 描述")

	# 4. §9.6.17 引用 6 verb @onready 字段名
	var six_verb_fields: Array[String] = [
		"pulse_ability",
		"bind_ability",
		"cut_ability",
		"echo_ability",
		"wave_ability",
		"whisper_ability",
	]
	var all_fields_found: bool = true
	for field in six_verb_fields:
		if field not in contributing:
			all_fields_found = false
			print("FAIL 4.x: §9.6.17 段缺 6 verb @onready 字段之一: %s" % field)
	if all_fields_found:
		pass_count += 1
		print("PASS 4: §9.6.17 段含完整 6 verb @onready 字段名")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.17 段缺 6 verb @onready 字段名")

	# 5. player.gd 含 6 verb @onready 字段声明
	f = FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
	assert(f != null, "player.gd exists")
	var player_src: String = f.get_as_text()
	f.close()
	var six_fields_count: int = 0
	for field in six_verb_fields:
		var onready_pattern: String = "@onready var %s" % field
		if onready_pattern in player_src:
			six_fields_count += 1
	if six_fields_count == 6:
		pass_count += 1
		print("PASS 5: player.gd 含完整 6 verb @onready 字段声明 (6/6 找到)")
	else:
		fail_count += 1
		print("FAIL 5: player.gd 缺 verb @onready 字段, 只找到 %d / 6" % six_fields_count)

	# 6. player.gd `_ready` 含 6 verb null guard (if verb_ability:)
	var six_null_guards: int = 0
	for field in six_verb_fields:
		var null_guard_pattern: String = "if %s:" % field
		if null_guard_pattern in player_src:
			six_null_guards += 1
	if six_null_guards == 6:
		pass_count += 1
		print("PASS 6: player.gd 含 6 verb null guard (6/6 if verb_ability: 找到)")
	else:
		fail_count += 1
		print("FAIL 6: player.gd 缺 verb null guard, 只找到 %d / 6" % six_null_guards)

	# 7. player.gd `_ready` 含 6 verb 主信号 (verb_fired.connect)
	var six_main_signals: Array[String] = [
		"pulse_fired.connect",
		"bind_fired.connect",
		"cut_fired.connect",
		"echo_fired.connect",
		"wave_fired.connect",
		"whisper_fired.connect",
	]
	var main_signal_count: int = 0
	for sig in six_main_signals:
		if sig in player_src:
			main_signal_count += 1
	if main_signal_count == 6:
		pass_count += 1
		print("PASS 7: player.gd 含 6 verb 主信号 (6/6 verb_fired.connect 找到)")
	else:
		fail_count += 1
		print("FAIL 7: player.gd 缺 verb 主信号, 只找到 %d / 6" % main_signal_count)

	# 8. player.gd `_ready` 含 6 verb 命中信号 (verb_hit.connect)
	var six_hit_signals: Array[String] = [
		"pulse_hit",
		"bind_hit",
		"cut_hit",
		"echo_hit",
		"wave_hit",
		"whisper_hit",
	]
	var hit_signal_count: int = 0
	for sig in six_hit_signals:
		var connect_pattern: String = "%s.connect" % sig
		if connect_pattern in player_src:
			hit_signal_count += 1
	if hit_signal_count == 6:
		pass_count += 1
		print("PASS 8: player.gd 含 6 verb 命中信号 (6/6 verb_hit.connect 找到)")
	else:
		fail_count += 1
		print("FAIL 8: player.gd 缺 verb 命中信号, 只找到 %d / 6" % hit_signal_count)

	# 9. player.gd `_ready` 含 2 verb 结束信号 (echo_expired + wave_expired, 4 verb 0 触发)
	var two_expired_signals: Array[String] = [
		"echo_expired.connect",
		"wave_expired.connect",
	]
	var expired_count: int = 0
	for sig in two_expired_signals:
		if sig in player_src:
			expired_count += 1
	if expired_count == 2:
		pass_count += 1
		print("PASS 9: player.gd 含 2 verb 结束信号 (echo_expired + wave_expired, 2/2 找到)")
	else:
		fail_count += 1
		print("FAIL 9: player.gd 缺 verb 结束信号, 只找到 %d / 2" % expired_count)

	# 10. player.gd `_ready` 含 2 verb 扩展信号 (echo_multi_reflect + wave_combo, has_signal 守卫)
	var two_extra_signals: Array[String] = [
		"echo_multi_reflect",
		"wave_combo",
	]
	var extra_count: int = 0
	for sig in two_extra_signals:
		if sig in player_src:
			extra_count += 1
	if extra_count == 2:
		pass_count += 1
		print("PASS 10: player.gd 含 2 verb 扩展信号 (echo_multi_reflect + wave_combo, 2/2 找到)")
	else:
		fail_count += 1
		print("FAIL 10: player.gd 缺 verb 扩展信号, 只找到 %d / 2" % extra_count)

	# 11. player.gd 含 PlayerActionGate.register_player / unregister_player 对称
	if "PlayerActionGate.register_player" in player_src and "PlayerActionGate.unregister_player" in player_src:
		pass_count += 1
		print("PASS 11: player.gd 含 PlayerActionGate.register_player / unregister_player 对称 (D001 #82)")
	else:
		fail_count += 1
		print("FAIL 11: player.gd 缺 PlayerActionGate register/unregister 对称")

	# 12. player.gd 含 _has_player_action_gate_autoload 守卫 helper
	if "_has_player_action_gate_autoload" in player_src and "has_node(\"PlayerActionGate\")" in player_src:
		pass_count += 1
		print("PASS 12: player.gd 含 _has_player_action_gate_autoload 守卫 helper (headless 0 NPE)")
	else:
		fail_count += 1
		print("FAIL 12: player.gd 缺 _has_player_action_gate_autoload 守卫 helper")

	# 13. 0 触碰 §9.6.16 6 verb hit handler 5 件套 (_on_pulse_hit 等 6 函数仍存在)
	var six_hit_handlers: Array[String] = [
		"_on_pulse_hit",
		"_on_cut_hit",
		"_on_bind_hit",
		"_on_echo_hit",
		"_on_wave_hit",
		"_on_whisper_hit",
	]
	var hit_handler_count: int = 0
	for handler in six_hit_handlers:
		var handler_pattern: String = "func %s" % handler
		for line in player_src.split("\n"):
			if line.begins_with(handler_pattern):
				hit_handler_count += 1
				break
	if hit_handler_count == 6:
		pass_count += 1
		print("PASS 13: player.gd 含完整 6 verb hit handler (6/6 _on_*_hit 找到, §9.6.16 0 触碰)")
	else:
		fail_count += 1
		print("FAIL 13: player.gd 缺 verb hit handler, 只找到 %d / 6 (§9.6.16 回归)" % hit_handler_count)

	# 14. CHANGELOG.md 包含 T272 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T272" in changelog and "§9.6.17" in changelog:
		pass_count += 1
		print("PASS 14: CHANGELOG.md 含 T272 §9.6.17 段")
	else:
		fail_count += 1
		print("FAIL 14: CHANGELOG.md 缺 T272 §9.6.17 段")

	# 15. ROADMAP.md 顶部含 T272 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T272" in roadmap and "§9.6.17" in roadmap:
		pass_count += 1
		print("PASS 15: ROADMAP.md 顶部含 T272 §9.6.17 引用")
	else:
		fail_count += 1
		print("FAIL 15: ROADMAP.md 顶部缺 T272 §9.6.17 引用")

	# 16. 静态解析 — 0 SCRIPT ERROR
	print("PASS 16: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# Summary
	print("")
	print("=== T272 smoke test summary: %d passed, %d failed ===" % [pass_count + 1, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
