extends SceneTree

## test_i049_t223_archive_05_smoke.gd
## T223 (#146) — WaveAbility 0.5× Pale Resonance 1 个 room 教学演示
##
## 覆盖：
##  1. data/rooms/archive_05.json 存在且 JSON 解析成功
##  2. room_id = "archive_05"
##  3. 至少 3 个 silence_mote 敌人 (Wave 命中 3+ 触发 wave_combo 演示)
##  4. tutorial_hints 包含 intro_wave_halo 教学 (0.5× Pale Resonance 文字)
##  5. tutorial_hints 包含 intro_wave_combo 反馈 (3+ 命中 → 屏震 + 钟鸣)
##  6. decorations 包含 wave_totem (语义提示)
##  7. src/scenes/room_archive_05.tscn 存在 + room_id = "archive_05"
##  8. save_system.gd ROOM_ID_TO_SCENE 包含 archive_05 映射
##  9. ROOM_ID_TO_SCENE 指向正确的 .tscn 路径
## 10. 教学提示包含 "0.5×" 关键词 (Pale Resonance 教学核心)

func _init() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0

	# --- 0. 预读 save_system.gd (tests 8/9 共用,避免重复 IO + 作用域问题) ---
	var ss_text: String = ""
	var ss_file := FileAccess.open("res://src/autoload/save_system.gd", FileAccess.READ)
	if ss_file != null:
		ss_text = ss_file.get_as_text()
		ss_file.close()

	# --- 1. data/rooms/archive_05.json 存在且 JSON 解析成功 ---
	test_num += 1
	var data_path := "res://data/rooms/archive_05.json"
	var data_file := FileAccess.open(data_path, FileAccess.READ)
	if data_file == null:
		print("  [%d] FAIL  %s 不可打开" % [test_num, data_path])
		failed += 1
		_finish(passed, failed)
		return
	var data_text := data_file.get_as_text()
	data_file.close()
	var parsed: Variant = JSON.parse_string(data_text)
	if parsed == null or not parsed is Dictionary:
		print("  [%d] FAIL  %s 不是合法 JSON dict" % [test_num, data_path])
		failed += 1
		_finish(passed, failed)
		return
	print("  [%d] PASS  archive_05.json 存在且合法" % test_num)
	passed += 1
	var data: Dictionary = parsed

	# --- 2. room_id = "archive_05" ---
	test_num += 1
	if String(data.get("room_id", "")) == "archive_05":
		print("  [%d] PASS  room_id = archive_05" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  room_id = %s (expected archive_05)" % [test_num, data.get("room_id", "")])
		failed += 1

	# --- 3. 至少 3 个 silence_mote 敌人 (wave_combo 触发条件) ---
	test_num += 1
	var enemies: Array = data.get("enemies", [])
	var silence_mote_count := 0
	for enemy in enemies:
		if enemy is Dictionary and String(enemy.get("type", "")) == "silence_mote":
			silence_mote_count += 1
	if silence_mote_count >= 3:
		print("  [%d] PASS  %d 个 silence_mote (>=3 触发 wave_combo)" % [test_num, silence_mote_count])
		passed += 1
	else:
		print("  [%d] FAIL  只有 %d 个 silence_mote (需要 >=3 演示 wave_combo)" % [test_num, silence_mote_count])
		failed += 1

	# --- 4. tutorial_hints 包含 intro_wave_halo + 0.5× 关键词 ---
	test_num += 1
	var hints: Array = data.get("tutorial_hints", [])
	var has_wave_halo := false
	var has_pale_resonance := false
	for hint in hints:
		if hint is Dictionary:
			var hint_group := String(hint.get("group", ""))
			var hint_text := String(hint.get("text", ""))
			if hint_group == "intro_wave_halo":
				has_wave_halo = true
			if "0.5" in hint_text and ("Pale" in hint_text or "pale" in hint_text or "光环" in hint_text):
				has_pale_resonance = true
	if has_wave_halo and has_pale_resonance:
		print("  [%d] PASS  tutorial_hints 含 intro_wave_halo + 0.5× Pale Resonance 关键词" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  intro_wave_halo=%s, 0.5×Pale=%s" % [has_wave_halo, has_pale_resonance])
		failed += 1

	# --- 5. tutorial_hints 包含 intro_wave_combo 反馈 ---
	test_num += 1
	var has_wave_combo := false
	for hint in hints:
		if hint is Dictionary and String(hint.get("group", "")) == "intro_wave_combo":
			has_wave_combo = true
			break
	if has_wave_combo:
		print("  [%d] PASS  tutorial_hints 含 intro_wave_combo 反馈" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  tutorial_hints 缺 intro_wave_combo 反馈" % test_num)
		failed += 1

	# --- 6. decorations 包含 wave_totem ---
	test_num += 1
	var decorations: Array = data.get("decorations", [])
	var wave_totem_count := 0
	for deco in decorations:
		if deco is Dictionary and String(deco.get("type", "")) == "wave_totem":
			wave_totem_count += 1
	if wave_totem_count >= 1:
		print("  [%d] PASS  decorations 含 %d 个 wave_totem" % [test_num, wave_totem_count])
		passed += 1
	else:
		print("  [%d] FAIL  decorations 缺 wave_totem (语义提示)" % test_num)
		failed += 1

	# --- 7. src/scenes/room_archive_05.tscn 存在 + room_id = "archive_05" ---
	test_num += 1
	var tscn_path := "res://src/scenes/room_archive_05.tscn"
	var tscn_file := FileAccess.open(tscn_path, FileAccess.READ)
	if tscn_file == null:
		print("  [%d] FAIL  %s 不存在" % [test_num, tscn_path])
		failed += 1
	else:
		var tscn_text := tscn_file.get_as_text()
		tscn_file.close()
		if "room_id = \"archive_05\"" in tscn_text and "json_room.gd" in tscn_text:
			print("  [%d] PASS  room_archive_05.tscn 存在 + room_id=archive_05 + 引用 json_room.gd" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  room_archive_05.tscn 内容不对 (room_id 或 json_room 引用缺失)" % test_num)
			failed += 1

	# --- 8. save_system.gd ROOM_ID_TO_SCENE 包含 archive_05 映射 ---
	test_num += 1
	if '"archive_05": "res://src/scenes/room_archive_05.tscn"' in ss_text:
		print("  [%d] PASS  ROOM_ID_TO_SCENE 包含 archive_05 → room_archive_05.tscn" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  ROOM_ID_TO_SCENE 缺 archive_05 → room_archive_05.tscn 映射" % test_num)
		failed += 1

	# --- 9. T223 注释在 save_system.gd 中标记 (code review 友好) ---
	test_num += 1
	if "T223" in ss_text and "archive_05" in ss_text:
		print("  [%d] PASS  T223 注释 + archive_05 引用在 save_system.gd 中" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T223 注释或 archive_05 引用缺失" % test_num)
		failed += 1

	# --- 10. 教学提示包含 "0.5×" 关键文字 (教学文本本身) ---
	test_num += 1
	var has_half_text := false
	for hint in hints:
		if hint is Dictionary:
			var txt := String(hint.get("text", ""))
			if "0.5×" in txt or "0.5x" in txt:
				has_half_text = true
				break
	if has_half_text:
		print("  [%d] PASS  教学提示包含 '0.5×' 关键文字" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  教学提示缺 '0.5×' 关键文字" % test_num)
		failed += 1

	_finish(passed, failed)

func _finish(passed: int, failed: int) -> void:
	print("")
	print("=== I049 T223 archive_05 教学演示 smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
