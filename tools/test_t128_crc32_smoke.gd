extends SceneTree

## test_t128_crc32_smoke.gd
## T128 — SaveSystem CRC32 校验和防损坏 端到端冒烟测试
## 验证：
##  1. _crc32_of_string() 已知向量（标准 IEEE CRC32）
##  2. _write_json() 写入带 checksum 字段
##  3. _read_json() 正常读回 data
##  4. 篡改 save 文件后 get_save_integrity() 返回 "corrupted"
##  5. 旧格式 save（无 checksum 字段）走 legacy 兼容
##  6. 缺失 slot → "missing"
##  7. delete_slot() 清理 corrupted 文件
##  8. get_save_integrity() 公开方法

func _initialize() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0

	# 加载 SaveSystem script
	var ss_script := load("res://src/autoload/save_system.gd")
	if ss_script == null:
		print("  FAIL: cannot load save_system.gd")
		quit(1)
		return
	var ss_node: Node = ss_script.new()
	ss_node._ready()  # _ensure_save_dir 需要

	# 1. CRC32 已知向量（IEEE 802.3 / zlib / PNG 标准）
	# "123456789" 的标准 CRC32 = 0xCBF43926 = 3421780262
	test_num += 1
	var expected_crc := 3421780262
	var actual_crc := ss_node._crc32_of_string("123456789")
	if actual_crc == expected_crc:
		print("  [%d] PASS  _crc32_of_string('123456789') = 0xCBF43926" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _crc32_of_string('123456789') = %d (expected %d)" % [test_num, actual_crc, expected_crc])
		failed += 1

	# 2. CRC32 空字符串 = 0
	test_num += 1
	var empty_crc := ss_node._crc32_of_string("")
	if empty_crc == 0:
		print("  [%d] PASS  _crc32_of_string('') = 0" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _crc32_of_string('') = %d (expected 0)" % [test_num, empty_crc])
		failed += 1

	# 3. 写入 + 读回 (round-trip)
	test_num += 1
	var test_data := {
		"version": 1,
		"meta": {"slot_id": 0, "saved_at_unix": 1234567890},
		"game_state": {"health": 3, "resonance": 100, "rooms_completed": ["archive_01"]},
		"achievements": {"unlocked_ids": ["first_step"]}
	}
	var write_err := ss_node._write_json("/tmp/t128_test_save.json", test_data)
	var read_back := ss_node._read_json("/tmp/t128_test_save.json")
	if write_err == OK and read_back.get("version", -1) == 1 and int(read_back.get("game_state", {}).get("health", -1)) == 3:
		print("  [%d] PASS  round-trip write/read preserved data" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  round-trip failed (write_err=%d, read=%s)" % [test_num, write_err, str(read_back)])
		failed += 1

	# 4. 写入文件应包含 checksum 字段
	test_num += 1
	var file := FileAccess.open("/tmp/t128_test_save.json", FileAccess.READ)
	if file != null:
		var content := file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed is Dictionary and parsed.has(ss_script.SAVE_CHECKSUM_KEY):
			print("  [%d] PASS  written file contains checksum field" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  written file missing checksum field" % test_num)
			failed += 1
	else:
		print("  [%d] FAIL  cannot open written file" % test_num)
		failed += 1

	# 5. 篡改 save 文件后 _read_json 返回空（CRC32 mismatch）
	test_num += 1
	var slot_path := ss_script._slot_path(2)
	# Write a valid save first
	ss_node._write_json(slot_path, test_data)
	# Read content, mutate, write back
	var file2 := FileAccess.open(slot_path, FileAccess.READ)
	var content2 := file2.get_as_text()
	file2.close()
	var mutated := content2.replace("\"version\"", "\"XversionX\"")
	var file3 := FileAccess.open(slot_path, FileAccess.WRITE)
	file3.store_string(mutated)
	file3.close()
	# Now _read_json should return {} (CRC32 mismatch)
	var corrupted_readback := ss_node._read_json(slot_path)
	if corrupted_readback.is_empty():
		print("  [%d] PASS  _read_json returns {} on tampered save (CRC32 mismatch)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _read_json returned non-empty dict for tampered save: %s" % [test_num, str(corrupted_readback)])
		failed += 1

	# 6. 旧格式 save (无 checksum 字段) 走 legacy 兼容
	test_num += 1
	var legacy := {"version": 1, "meta": {"slot_id": 3}, "game_state": {"health": 2}, "achievements": {"unlocked_ids": []}}
	var legacy_path := ss_script._slot_path(3)
	var legacy_file := FileAccess.open(legacy_path, FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify(legacy, "  "))
	legacy_file.close()
	var legacy_readback := ss_node._read_json(legacy_path)
	if int(legacy_readback.get("game_state", {}).get("health", -1)) == 2:
		print("  [%d] PASS  legacy save (no checksum) loads data correctly" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  legacy save readback failed: %s" % [test_num, str(legacy_readback)])
		failed += 1

	# 7. get_save_integrity 公开方法存在
	test_num += 1
	var has_integrity_method := false
	for m in ss_node.get_method_list():
		if m.name == "get_save_integrity":
			has_integrity_method = true
			break
	if has_integrity_method:
		print("  [%d] PASS  get_save_integrity() exposed as public method" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  get_save_integrity() not exposed" % test_num)
		failed += 1

	# 8. get_save_integrity 状态值（missing / legacy / ok / corrupted）
	test_num += 1
	# Slot 4 should be missing
	var integ_4: String = ss_node.get_save_integrity(4)
	# Slot 2 was tampered above — should be corrupted
	var integ_2: String = ss_node.get_save_integrity(2)
	# Slot 3 was legacy (no checksum) — should be legacy
	var integ_3: String = ss_node.get_save_integrity(3)
	if integ_4 == "missing" and integ_3 == "legacy" and integ_2 == "corrupted":
		print("  [%d] PASS  get_save_integrity: missing='%s', legacy='%s', corrupted='%s'" % [test_num, integ_4, integ_3, integ_2])
		passed += 1
	else:
		print("  [%d] FAIL  get_save_integrity wrong values: missing='%s', legacy='%s', corrupted='%s'" % [test_num, integ_4, integ_3, integ_2])
		failed += 1

	# 9. 删除 corrupted 槽位
	test_num += 1
	ss_node.delete_slot(2)
	if not ss_node.has_save(2):
		print("  [%d] PASS  delete_slot(2) cleared corrupted save" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  delete_slot(2) failed" % test_num)
		failed += 1

	# 10. 删除 legacy 槽位
	test_num += 1
	ss_node.delete_slot(3)
	if not ss_node.has_save(3):
		print("  [%d] PASS  delete_slot(3) cleared legacy save" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  delete_slot(3) failed" % test_num)
		failed += 1

	# 清理
	if FileAccess.file_exists("/tmp/t128_test_save.json"):
		DirAccess.remove_absolute("/tmp/t128_test_save.json")
	ss_node.free()

	print("")
	print("T128 smoke test: %d passed, %d failed" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
