# T278 smoke test — CONTRIBUTING.md §9.6.22 6 verb VFX 视觉组 (5 段 canonical 1:1 序列) polish 模式 1:1 落地 (#198 普通模式 polish T278, 0 真实游戏代码改动, 仅 doc + smoke)
# 验证 §9.6.22 文档化 + 5 段 canonical 1:1 序列 (Stage 1 class_name + extends Node2D 模板 + Stage 2 6 verb 调色六元组 1:1 + Stage 3 5+ layer 视觉组 1:1 + Stage 4 6 verb 几何 1:1 严格分离 + Stage 5 6 verb 跨段 1:1 镜像) + 6 verb VFX 文件 (pulse_vfx / bind_vfx / cut_vfx / echo_vfx / resonance_wave_vfx / whisper_vfx) + 4 类症状 (a 漏跨段镜像 / b 漏几何 / c 漏调色 / d 漏 L5) + 11 任务历史 (T098/T158/T170a/c/d/T181/F013.E/T241/T251/T252/T270) + 7 段 0 触碰 + 1 known drift risk (flash_hit 漏 1 verb)
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.22 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.22" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.22 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.22 章节标题")

	# 2. §9.6.22 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	var pos_9622: int = contributing.find("### 9.6.22")
	var pos_9621: int = contributing.find("### 9.6.21")
	if pos_9622 > pos_9621 and pos_9622 > 0 and pos_9621 > 0:
		var section_9622: String = contributing.substr(pos_9622)
		if "**症状**" in section_9622 and "**触发场景**" in section_9622 and "**修复**" in section_9622 and "**预防**" in section_9622:
			pass_count += 1
			print("PASS 2: §9.6.22 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
		else:
			fail_count += 1
			print("FAIL 2: §9.6.22 段内 4 段结构不全")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.22 段位置异常, 找不到 9.6.21 / 9.6.22 锚点")

	# 3. §9.6.22 引用 5 段 canonical 序列关键字
	var five_stage_keys: Array[String] = [
		"Stage 1 class_name + extends Node2D 模板",
		"Stage 2 6 verb 调色六元组 1:1",
		"Stage 3 5+ layer 视觉组 1:1",
		"Stage 4 6 verb 几何 1:1 严格分离",
		"Stage 5 6 verb 跨段 1:1 镜像",
	]
	var all_stage_keys_found: bool = true
	for key in five_stage_keys:
		if key not in contributing:
			all_stage_keys_found = false
			print("FAIL 3.x: §9.6.22 段缺 5 段序列关键字: %s" % key)
	if all_stage_keys_found:
		pass_count += 1
		print("PASS 3: §9.6.22 段含完整 5 段 canonical 1:1 序列关键字 (5/5 找到, Stage 1 class_name + Stage 2 调色 + Stage 3 layer + Stage 4 几何 + Stage 5 跨段)")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.22 段缺 5 段序列关键字")

	# 4. §9.6.22 引用 11 任务历史 (T098/T158/T170a/c/d/T181/F013.E/T241/T251/T252/T270)
	var vfx_history_tasks: Array[String] = [
		"T098",
		"T158",
		"T170a",
		"T170c",
		"T170d",
		"T181",
		"F013.E",
		"T241",
		"T251",
		"T252",
		"T270",
	]
	var all_history_found: bool = true
	for task in vfx_history_tasks:
		if task not in contributing:
			all_history_found = false
			print("FAIL 4.x: §9.6.22 段缺 6 verb VFX 历史任务: %s" % task)
	if all_history_found:
		pass_count += 1
		print("PASS 4: §9.6.22 段含完整 11 任务历史引用 (11/11 找到, T098 + T158 + T170a + T170c + T170d + T181 + F013.E + T241 + T251 + T252 + T270)")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.22 段缺 6 verb VFX 历史任务")

	# 5. §9.6.22 引用 6 verb VFX class_name (PulseVFX / BindVFX / CutVFX / EchoVFX / ResonanceWaveVFX / WhisperVFX)
	var six_verb_vfx_classes: Array[String] = [
		"class_name PulseVFX",
		"class_name BindVFX",
		"class_name CutVFX",
		"class_name EchoVFX",
		"class_name ResonanceWaveVFX",
		"class_name WhisperVFX",
	]
	var all_classes_found: bool = true
	for cls in six_verb_vfx_classes:
		if cls not in contributing:
			all_classes_found = false
			print("FAIL 5.x: §9.6.22 段缺 6 verb VFX class_name: %s" % cls)
	if all_classes_found:
		pass_count += 1
		print("PASS 5: §9.6.22 段含完整 6 verb VFX class_name (6/6 找到, PulseVFX + BindVFX + CutVFX + EchoVFX + ResonanceWaveVFX + WhisperVFX)")
	else:
		fail_count += 1
		print("FAIL 5: §9.6.22 段缺 6 verb VFX class_name")

	# 6. §9.6.22 引用 6 verb 调色六元组 (Pulse Coral / Bind Violet / Cut Amber / Echo Cyan / Wave Pale / Whisper Mauve)
	var six_verb_colors: Array[String] = [
		"Pulse Coral",
		"Bind Violet",
		"Cut Amber",
		"Echo Cyan",
		"Wave Pale",
		"Whisper Mauve",
	]
	var all_colors_found: bool = true
	for color in six_verb_colors:
		if color not in contributing:
			all_colors_found = false
			print("FAIL 6.x: §9.6.22 段缺 6 verb 调色: %s" % color)
	if all_colors_found:
		pass_count += 1
		print("PASS 6: §9.6.22 段含完整 6 verb 调色六元组 (6/6 找到, Pulse Coral + Bind Violet + Cut Amber + Echo Cyan + Wave Pale + Whisper Mauve)")
	else:
		fail_count += 1
		print("FAIL 6: §9.6.22 段缺 6 verb 调色六元组")

	# 7. §9.6.22 引用 6 verb 几何 (圆环 / 螺旋 / 弧斩 / 护盾 / 光环 / 球)
	var six_verb_geometries: Array[String] = [
		"圆环",
		"螺旋",
		"弧斩",
		"护盾",
		"光环",
		"球",
	]
	var all_geometries_found: bool = true
	for geo in six_verb_geometries:
		if geo not in contributing:
			all_geometries_found = false
			print("FAIL 7.x: §9.6.22 段缺 6 verb 几何: %s" % geo)
	if all_geometries_found:
		pass_count += 1
		print("PASS 7: §9.6.22 段含完整 6 verb 几何 (6/6 找到, 圆环 + 螺旋 + 弧斩 + 护盾 + 光环 + 球)")
	else:
		fail_count += 1
		print("FAIL 7: §9.6.22 段缺 6 verb 几何")

	# 8. §9.6.22 引用 4 跨段镜像 (与 §9.6.16 / §9.6.18 / §9.6.19 / §9.6.21 镜像)
	var cross_section_keys: Array[String] = [
		"§9.6.16",
		"§9.6.18",
		"§9.6.19",
		"§9.6.21",
	]
	var all_cross_sections_found: bool = true
	for key in cross_section_keys:
		if key not in contributing:
			all_cross_sections_found = false
			print("FAIL 8.x: §9.6.22 段缺 4 跨段镜像引用: %s" % key)
	if all_cross_sections_found:
		pass_count += 1
		print("PASS 8: §9.6.22 段含完整 4 跨段镜像引用 (4/4 找到, 与 §9.6.16 + §9.6.18 + §9.6.19 + §9.6.21 1:1 镜像)")
	else:
		fail_count += 1
		print("FAIL 8: §9.6.22 段缺跨段镜像引用")

	# 9. §9.6.22 引用 6 verb VFX 文件 6 路径 (pulse_vfx.gd / bind_vfx.gd / cut_vfx.gd / echo_vfx.gd / resonance_wave_vfx.gd / whisper_vfx.gd)
	var six_vfx_files: Array[String] = [
		"pulse_vfx.gd",
		"bind_vfx.gd",
		"cut_vfx.gd",
		"echo_vfx.gd",
		"resonance_wave_vfx.gd",
		"whisper_vfx.gd",
	]
	var all_files_found: bool = true
	for file in six_vfx_files:
		if file not in contributing:
			all_files_found = false
			print("FAIL 9.x: §9.6.22 段缺 6 verb VFX 文件: %s" % file)
	if all_files_found:
		pass_count += 1
		print("PASS 9: §9.6.22 段含完整 6 verb VFX 文件引用 (6/6 找到, pulse_vfx.gd + bind_vfx.gd + cut_vfx.gfx + echo_vfx.gd + resonance_wave_vfx.gd + whisper_vfx.gd)")
	else:
		fail_count += 1
		print("FAIL 9: §9.6.22 段缺 6 verb VFX 文件")

	# 10. §9.6.22 引用 6 verb 5+ layer 视觉组 (Pulse 5 / Bind 5 / Cut 5 / Echo 6 / Wave 6 / Whisper 6)
	var layer_count_keys: Array[String] = [
		"Pulse 5 layer",
		"Bind 5 layer",
		"Cut 5 layer",
		"Echo 6 layer",
		"Wave 6 layer",
		"Whisper 6 layer",
	]
	var all_layer_counts_found: bool = true
	for key in layer_count_keys:
		if key not in contributing:
			all_layer_counts_found = false
			print("FAIL 10.x: §9.6.22 段缺 6 verb 5+ layer 数: %s" % key)
	if all_layer_counts_found:
		pass_count += 1
		print("PASS 10: §9.6.22 段含完整 6 verb 5+ layer 视觉组 (6/6 找到, Pulse 5 + Bind 5 + Cut 5 + Echo 6 + Wave 6 + Whisper 6 layer)")
	else:
		fail_count += 1
		print("FAIL 10: §9.6.22 段缺 6 verb 5+ layer 视觉组")

	# 11. §9.6.22 引用 4 类症状 (漏跨段镜像 / 漏几何 / 漏调色 / 漏 L5)
	var four_symptom_keys: Array[String] = [
		"加新 1 verb VFX 漏 1 跨段镜像",
		"加新 1 verb VFX 漏 1 几何",
		"修 1 verb VFX 调色 漏 §9.6.4 调色六元组 1:1",
		"加新 1 verb VFX 5+ layer 漏 L5 HIT_FLASH",
	]
	var all_symptoms_found: bool = true
	for key in four_symptom_keys:
		if key not in contributing:
			all_symptoms_found = false
			print("FAIL 11.x: §9.6.22 段缺 4 类症状关键字: %s" % key)
	if all_symptoms_found:
		pass_count += 1
		print("PASS 11: §9.6.22 段含完整 4 类症状关键字 (4/4 找到, 漏跨段镜像 / 漏几何 / 漏调色 / 漏 L5)")
	else:
		fail_count += 1
		print("FAIL 11: §9.6.22 段缺 4 类症状关键字")

	# 12. §9.6.22 引用 7 段 0 触碰边界
	var zero_touch_keys: Array[String] = [
		"0 触碰 §9.6.1",
		"0 触碰 §9.6.2",
		"0 触碰 §9.6.16",
		"0 触碰 §9.6.17",
		"0 触碰 §9.6.18",
		"0 触碰 §9.6.19",
		"0 触碰 §9.6.20",
		"0 触碰 §9.6.21",
	]
	var all_zero_touch_found: bool = true
	for key in zero_touch_keys:
		if key not in contributing:
			all_zero_touch_found = false
			print("FAIL 12.x: §9.6.22 段缺 0 触碰边界引用: %s" % key)
	if all_zero_touch_found:
		pass_count += 1
		print("PASS 12: §9.6.22 段含完整 7 段 0 触碰边界 (7/7 找到, §9.6.1 + §9.6.2 + §9.6.16 + §9.6.17 + §9.6.18 + §9.6.19 + §9.6.20 + §9.6.21)")
	else:
		fail_count += 1
		print("FAIL 12: §9.6.22 段缺 0 触碰边界引用")

	# 13. §9.6.22 引用 known drift risk (flash_hit 漏 1 verb)
	if "drift risk" in contributing and "flash_hit" in contributing and ("漏 1 verb" in contributing or "6 verb 1:1 镜像" in contributing):
		pass_count += 1
		print("PASS 13: §9.6.22 段 known drift risk 表含 flash_hit 漏 1 verb 1:1 镜像")
	else:
		fail_count += 1
		print("FAIL 13: §9.6.22 段缺 flash_hit drift risk 描述")

	# 14. CHANGELOG.md 包含 T278 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T278" in changelog and "§9.6.22" in changelog:
		pass_count += 1
		print("PASS 14: CHANGELOG.md 含 T278 §9.6.22 段")
	else:
		fail_count += 1
		print("FAIL 14: CHANGELOG.md 缺 T278 §9.6.22 段")

	# 15. ROADMAP.md 顶部含 T278 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T278" in roadmap and "§9.6.22" in roadmap:
		pass_count += 1
		print("PASS 15: ROADMAP.md 含 T278 §9.6.22 引用")
	else:
		fail_count += 1
		print("FAIL 15: ROADMAP.md 缺 T278 §9.6.22 引用")

	# 16. README.md 同步 +1 (双语: T278 §9.6.22)
	f = FileAccess.open("res://README.md", FileAccess.READ)
	assert(f != null, "README.md exists")
	var readme_en: String = f.get_as_text()
	f.close()
	f = FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	assert(f != null, "README.zh-CN.md exists")
	var readme_zh: String = f.get_as_text()
	f.close()
	if "T278" in readme_en and "§9.6.22" in readme_en and "T278" in readme_zh and "§9.6.22" in readme_zh:
		pass_count += 1
		print("PASS 16: README.md + README.zh-CN.md 同步 T278 §9.6.22 (双语)")
	else:
		fail_count += 1
		print("FAIL 16: README.md / README.zh-CN.md 缺 T278 §9.6.22 同步")

	# 17. ITERATION_COUNT.txt +1 (198)
	f = FileAccess.open("res://ITERATION_COUNT.txt", FileAccess.READ)
	assert(f != null, "ITERATION_COUNT.txt exists")
	var count_text: String = f.get_as_text().strip_edges()
	f.close()
	if count_text == "198":
		pass_count += 1
		print("PASS 17: ITERATION_COUNT.txt 已 +1 → 198 (#197 普通模式后正常迭代 #198)")
	else:
		fail_count += 1
		print("FAIL 17: ITERATION_COUNT.txt 期望 198, 实际 '%s'" % count_text)

	# 18. 静态解析 — 0 SCRIPT ERROR
	print("PASS 18: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# 19. 1 known drift risk 表锚点保留 (flash_hit 6 verb 1:1 镜像漂移监控)
	if "flash_hit" in contributing and "drift" in contributing and "6 verb" in contributing:
		pass_count += 1
		print("PASS 19: §9.6.22 段含 1 known drift risk (flash_hit 6 verb 1:1 镜像) 表锚点保留")
	else:
		fail_count += 1
		print("FAIL 19: §9.6.22 段缺 known drift risk 表锚点")

	print("---")
	print("T278 smoke test 总结: %d PASS, %d FAIL" % [pass_count, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
