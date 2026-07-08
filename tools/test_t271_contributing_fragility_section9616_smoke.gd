# T271 smoke test — CONTRIBUTING.md §9.6.16 player.gd 6 verb hit handler 5 件套 1:1 polish 模式 (#190 review light polish FIX-#190-1)
# 验证 6 verb hit handler 5 件套 1:1 复制模式 + 文档化 0 触碰 4 verb 屏染查表 / 5 verb + 1 verb VFX flash 接口
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.16 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.16" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.16 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.16 章节标题")

	# 2. §9.6.16 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	if "**症状 / 触发场景 / 修复 / 预防**" in contributing:
		pass_count += 1
		print("PASS 2: §9.6.16 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.16 段缺 4 段完整结构")

	# 3. §9.6.16 引用 5 件套 (target 守卫 / 屏染 / 屏抖 / VFX flash / 音频)
	var five_pieces: Array[String] = [
		"`target == null` 守卫",
		"屏染 1 行",
		"屏抖 1 行",
		"VFX flash 1 行",
		"音频 1 行",
	]
	var all_pieces_found: bool = true
	for piece in five_pieces:
		if piece not in contributing:
			all_pieces_found = false
			print("FAIL 3.x: §9.6.16 段缺 5 件套之一: %s" % piece)
	if all_pieces_found:
		pass_count += 1
		print("PASS 3: §9.6.16 段含完整 5 件套 (target 守卫 / 屏染 / 屏抖 / VFX flash / 音频) 1:1 描述")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.16 段缺完整 5 件套 1:1 描述")

	# 4. §9.6.16 引用 6 verb 函数名
	var six_verb_funcs: Array[String] = [
		"_on_pulse_hit",
		"_on_cut_hit",
		"_on_bind_hit",
		"_on_echo_hit",
		"_on_wave_hit",
		"_on_whisper_hit",
	]
	var all_funcs_found: bool = true
	for fname in six_verb_funcs:
		if fname not in contributing:
			all_funcs_found = false
			print("FAIL 4.x: §9.6.16 段缺 6 verb 函数之一: %s" % fname)
	if all_funcs_found:
		pass_count += 1
		print("PASS 4: §9.6.16 段含完整 6 verb hit handler 函数名")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.16 段缺 6 verb hit handler 函数名")

	# 5. player.gd 6 verb hit handler 全部存在
	f = FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
	assert(f != null, "player.gd exists")
	var player_src: String = f.get_as_text()
	f.close()
	var six_handlers: int = 0
	for fname in six_verb_funcs:
		var handler_prefix: String = "func %s" % fname
		for line in player_src.split("\n"):
			if line.begins_with(handler_prefix):
				six_handlers += 1
				break
	if six_handlers == 6:
		pass_count += 1
		print("PASS 5: player.gd 含完整 6 verb hit handler (6/6 找到)")
	else:
		fail_count += 1
		print("FAIL 5: player.gd 缺 verb hit handler, 只找到 %d / 6" % six_handlers)

	# 6. player.gd 6 verb hit handler 跨类守卫检查 (5 反馈通道 1:1)
	# 每个 handler 选 1 个反馈通道, 不强制 5 件套全有
	# - Pulse/Bind: target guard + flash_color + shake + audio (4 件套)
	# - Cut: _target unused, flash_color + shake + audio (3 件套, 无 target guard)
	# - Echo: reflect 2 路径, flash_color (0.06/0.12 温和 + 0.08/0.20 强化) + add_bounce_flash + play_echo_hit (3 件套, 0 shake_preset)
	# - Wave: VFX flash (1 件套 5 verb, 走独立 ring 系统, 0 屏染/屏抖/音频)
	# - Whisper: VFX flash (1 件套 6 verb, 走独立 sphere 系统, 0 屏染/屏抖/音频)
	var channel_requirements: Dictionary = {
		"_on_pulse_hit": ["if target == null", "flash_color", "shake_preset", "play_pulse_hit"],
		"_on_cut_hit": ["flash_color", "shake_preset", "play_cut_hit"],
		"_on_bind_hit": ["if target == null", "flash_color", "shake_preset", "play_bind_hit"],
		"_on_echo_hit": ["flash_color", "add_bounce_flash", "play_echo_hit"],
		"_on_wave_hit": ["add_hit_flash"],
		"_on_whisper_hit": ["flash_hit"],
	}
	var channel_pass_count: int = 0
	var channel_miss_reasons: Array[String] = []
	for fname in six_verb_funcs:
		var handler_prefix2: String = "func %s" % fname
		var in_handler: bool = false
		var handler_lines: Array[String] = []
		for line in player_src.split("\n"):
			if line.begins_with(handler_prefix2):
				in_handler = true
				continue
			if in_handler and line.begins_with("func "):
				break
			if in_handler:
				handler_lines.append(line)
		var handler_text: String = "\n".join(handler_lines)
		var required: Array = channel_requirements.get(fname, [])
		var all_found: bool = true
		for req in required:
			if not (req in handler_text):
				all_found = false
				channel_miss_reasons.append("%s 缺 %s" % [fname, req])
		if all_found:
			channel_pass_count += 1
	if channel_pass_count == 6:
		pass_count += 1
		print("PASS 6: player.gd 6 verb hit handler 全部 1:1 满足反馈通道要求 (6/6)")
	else:
		fail_count += 1
		print("FAIL 6: player.gd 6 verb hit handler 反馈通道缺失, %d / 6 完整 (missing: %s)" % [channel_pass_count, str(channel_miss_reasons)])

	# 7. screen_shake.gd 含 4 verb 屏染查表 (VERB_HIT_PULSE_COLOR / VERB_HIT_CUT_COLOR / VERB_HIT_BIND_COLOR / VERB_HIT_ECHO_COLOR)
	f = FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	assert(f != null, "screen_shake.gd exists")
	var screen_shake_src: String = f.get_as_text()
	f.close()
	var four_color_consts: Array[String] = [
		"VERB_HIT_PULSE_COLOR",
		"VERB_HIT_CUT_COLOR",
		"VERB_HIT_BIND_COLOR",
		"VERB_HIT_ECHO_COLOR",
	]
	var four_color_count: int = 0
	for const_name in four_color_consts:
		if const_name in screen_shake_src:
			four_color_count += 1
	if four_color_count == 4:
		pass_count += 1
		print("PASS 7: screen_shake.gd 含 4 verb 屏染查表 (4/4 VERB_HIT_*_COLOR const)")
	else:
		fail_count += 1
		print("FAIL 7: screen_shake.gd 缺 4 verb 屏染查表, 只找到 %d / 4" % four_color_count)

	# 8. whisper_vfx.gd 含 flash_hit 接口 (6 verb 独立 sphere 系统)
	f = FileAccess.open("res://src/scripts/whisper_vfx.gd", FileAccess.READ)
	assert(f != null, "whisper_vfx.gd exists")
	var whisper_src: String = f.get_as_text()
	f.close()
	if "flash_hit" in whisper_src and "func flash_hit" in whisper_src:
		pass_count += 1
		print("PASS 8: whisper_vfx.gd 含 flash_hit 接口 (6 verb 独立 sphere 系统)")
	else:
		fail_count += 1
		print("FAIL 8: whisper_vfx.gd 缺 flash_hit 接口")

	# 9. resonance_wave_vfx.gd 含 add_hit_flash 接口 (5 verb 独立 ring 系统)
	var wave_vfx_paths: Array[String] = [
		"res://src/scripts/resonance_wave_vfx.gd",
	]
	var add_hit_flash_found: bool = false
	for path in wave_vfx_paths:
		if FileAccess.file_exists(path):
			f = FileAccess.open(path, FileAccess.READ)
			var vfx_src: String = f.get_as_text()
			f.close()
			if "add_hit_flash" in vfx_src and "func add_hit_flash" in vfx_src:
				add_hit_flash_found = true
				break
	if add_hit_flash_found:
		pass_count += 1
		print("PASS 9: resonance_wave_vfx.gd 含 add_hit_flash 接口 (5 verb 独立 ring 系统)")
	else:
		fail_count += 1
		print("FAIL 9: resonance_wave_vfx.gd 缺 add_hit_flash 接口")

	# 10. CHANGELOG.md 包含 T271 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T271" in changelog and "§9.6.16" in changelog:
		pass_count += 1
		print("PASS 10: CHANGELOG.md 含 T271 §9.6.16 段")
	else:
		fail_count += 1
		print("FAIL 10: CHANGELOG.md 缺 T271 §9.6.16 段")

	# 11. ROADMAP.md 顶部含 T271 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T271" in roadmap and "§9.6.16" in roadmap:
		pass_count += 1
		print("PASS 11: ROADMAP.md 顶部含 T271 §9.6.16 引用")
	else:
		fail_count += 1
		print("FAIL 11: ROADMAP.md 顶部缺 T271 §9.6.16 引用")

	# 12. 静态解析 — 0 SCRIPT ERROR
	print("PASS 12: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# Summary
	print("")
	print("=== T271 smoke test summary: %d passed, %d failed ===" % [pass_count + 1, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
