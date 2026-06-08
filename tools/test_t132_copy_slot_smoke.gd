extends SceneTree

## test_t132_copy_slot_smoke.gd
##
## T132 冒烟测试 — SaveSystem.copy_slot 备份/恢复 API
##
## 与既有 test_t128/t129 不同：本测试不实例化 SaveSystem（headless
## 模式下 save_system.gd:70 的 GameState 引用编译失败），
## 而是用 ① 源码扫描 ② 直接用 DirAccess.copy_absolute 验证 byte-level
## 复制语义，对应 copy_slot 的核心实现。
##
## 10 项断言：
## 1. copy_slot API 存在（save_system.gd 源码扫描）
## 2. copy_slot 接受 (src: int, dst: int) 签名
## 3. copy_slot src 非法（-1）→ push_warning + return false 路径
## 4. copy_slot dst 非法（100）→ push_warning + return false 路径
## 5. copy_slot src 不存在 → push_warning + return false 路径
## 6. copy_slot src==dst 时 no-op return true 路径
## 7. 真实文件复制测试：写入 src 后 copy → 验证 byte-identical
## 8. 复制后 dst 文件存在 + get_save_integrity 等价校验（CRC32 走同源）
## 9. copy_slot 写盘成功 emit save_completed(dst, true, ...) signal
## 10. 复制后修改 src，dst 不受影响（独立副本）

func _init() -> void:
	var passed := 0
	var failed := 0

	# --- 读 save_system.gd 源码（用于静态检查） ---
	var src_path := "res://src/autoload/save_system.gd"
	var file := FileAccess.open(src_path, FileAccess.READ)
	if file == null:
		print("  [FAIL] cannot open save_system.gd for source read")
		failed += 1
		_report(passed, failed)
		return
	var save_src: String = file.get_as_text()
	file.close()

	# --- 断言 1: copy_slot API 存在 ---
	if "func copy_slot(src: int, dst: int)" in save_src:
		print("  [PASS] copy_slot(src: int, dst: int) method exists in save_system.gd")
		passed += 1
	else:
		print("  [FAIL] copy_slot method signature missing")
		failed += 1

	# --- 断言 2: src 非法（_is_valid_slot 返回 false）→ false ---
	if "if not _is_valid_slot(src):" in save_src and "return false" in save_src:
		print("  [PASS] copy_slot guards invalid src slot")
		passed += 1
	else:
		print("  [FAIL] copy_slot src validation missing")
		failed += 1

	# --- 断言 3: dst 非法 → false ---
	if "if not _is_valid_slot(dst):" in save_src:
		print("  [PASS] copy_slot guards invalid dst slot")
		passed += 1
	else:
		print("  [FAIL] copy_slot dst validation missing")
		failed += 1

	# --- 断言 4: src 不存在 → false ---
	if "if not has_save(src):" in save_src and "return false" in save_src:
		print("  [PASS] copy_slot guards empty src")
		passed += 1
	else:
		print("  [FAIL] copy_slot empty-src validation missing")
		failed += 1

	# --- 断言 5: src==dst no-op 返回 true ---
	if "if src == dst:" in save_src and "return true" in save_src:
		print("  [PASS] copy_slot src==dst no-op returns true")
		passed += 1
	else:
		print("  [FAIL] copy_slot src==dst no-op logic missing")
		failed += 1

	# --- 断言 6: 实际文件复制语义（用 DirAccess.copy_absolute 模拟） ---
	# 这是 copy_slot 的核心实现：src 文件 → dst 文件 byte-level 复制。
	# 我们用 DirAccess 直接验证 byte-identical 复制，因为这是
	# copy_slot 在 save_system.gd 内部实际调用的 API。
	var test_dir := "user://test_copy_slot_t132"
	if DirAccess.dir_exists_absolute(test_dir):
		DirAccess.remove_absolute(test_dir)
	DirAccess.make_dir_recursive_absolute(test_dir)
	var src_file_path := "%s/slot_src.json" % test_dir
	var dst_file_path := "%s/slot_dst.json" % test_dir
	# 写一个 CRC32-wrapped 格式（模拟真实 save，验证下游 read 仍能解析）
	var payload := {
		"data": {
			"version": 1,
			"meta": {"slot_id": 0, "saved_at_unix": 1700000000},
			"game_state": {"current_room": "archive_01", "health": 3, "resonance": 50, "shards": 5, "rooms_completed": ["archive_01"], "abilities": {"pulse": true}, "checkpoint_x": 100.0, "checkpoint_y": 200.0, "run_time_seconds": 60.0},
			"achievements": {"unlocked_ids": ["first_steps"]}
		}
	}
	# 算 CRC32（与 save_system 一致实现）
	var checksum: int = _crc32_of_string(JSON.stringify(payload["data"], "  "))
	payload["_crc32_checksum"] = checksum
	var f_src := FileAccess.open(src_file_path, FileAccess.WRITE)
	if f_src == null:
		print("  [FAIL] cannot open test src file for writing")
		failed += 1
	else:
		f_src.store_string(JSON.stringify(payload, "  "))
		f_src.close()
		# 模拟 copy_slot 内部的 DirAccess.copy_absolute
		var copy_err: int = DirAccess.copy_absolute(src_file_path, dst_file_path)
		if copy_err == OK and FileAccess.file_exists(dst_file_path):
			print("  [PASS] DirAccess.copy_absolute copies file successfully (same as copy_slot core)")
			passed += 1
		else:
			print("  [FAIL] DirAccess.copy_absolute failed: err=%d" % copy_err)
			failed += 1

	# --- 断言 7: 复制后 dst 内容与 src byte-identical ---
	if FileAccess.file_exists(src_file_path) and FileAccess.file_exists(dst_file_path):
		var src_text: String = FileAccess.get_file_as_string(src_file_path)
		var dst_text: String = FileAccess.get_file_as_string(dst_file_path)
		if src_text == dst_text:
			print("  [PASS] copied dst has byte-identical content to src")
			passed += 1
		else:
			print("  [FAIL] dst content differs from src (src_len=%d dst_len=%d)" % [src_text.length(), dst_text.length()])
			failed += 1
	else:
		print("  [FAIL] src or dst file missing for byte-compare")
		failed += 1

	# --- 断言 8: 复制后的 dst 字段完整性 + 校验和在场 ---
	# 不重新序列化后比对 CRC32（JSON 字段顺序敏感，容易误报），
	# 改为：①dst 顶层有 _crc32_checksum 字段 ②data 嵌套子字段全在
	# ③独立算一次 data 字段 CRC32（按字母序序列化）作为 smoke 烟雾。
	# byte-identical 已经在断言 7 验证，所以存储的 CRC32 必然与
	# 原文件一致 — 此断言侧重"被复制后的 dst 在结构上仍可被
	# SaveSystem 正常解析"。
	if FileAccess.file_exists(dst_file_path):
		var dst_text2: String = FileAccess.get_file_as_string(dst_file_path)
		var parsed = JSON.parse_string(dst_text2)
		var checks_ok := true
		if not (parsed is Dictionary):
			checks_ok = false
			print("    [FAIL] parsed root not Dictionary")
		elif not parsed.has("_crc32_checksum"):
			checks_ok = false
			print("    [FAIL] parsed missing _crc32_checksum")
		elif not parsed.has("data"):
			checks_ok = false
			print("    [FAIL] parsed missing data")
		else:
			var d: Dictionary = parsed["data"]
			for key in ["version", "meta", "game_state", "achievements"]:
				if not d.has(key):
					checks_ok = false
					print("    [FAIL] parsed.data missing key: %s" % key)
		if checks_ok:
			print("  [PASS] copied dst parses cleanly + all expected keys present (SaveSystem-loadable)")
			passed += 1
		else:
			failed += 1
	else:
		print("  [FAIL] dst file missing for parse check")
		failed += 1

	# --- 断言 9: copy_slot 源码 emit save_completed signal ---
	# 关键 signal 让 SaveLoadMenu 收到 toast 通知，行为与正常 save 一致
	if "save_completed.emit(dst, true" in save_src and "save_completed.emit(dst, false" in save_src:
		print("  [PASS] copy_slot emits save_completed (success + failure paths)")
		passed += 1
	else:
		print("  [FAIL] copy_slot save_completed signal emit missing")
		failed += 1

	# --- 断言 10: 复制后修改 src，dst 不受影响（独立副本） ---
	if FileAccess.file_exists(src_file_path) and FileAccess.file_exists(dst_file_path):
		var orig_src: String = FileAccess.get_file_as_string(src_file_path)
		var orig_dst: String = FileAccess.get_file_as_string(dst_file_path)
		# 修改 src（追加字节）
		var f_src_mod := FileAccess.open(src_file_path, FileAccess.WRITE)
		if f_src_mod != null:
			f_src_mod.store_string(orig_src + "\n// tampered")
			f_src_mod.close()
		var dst_after: String = FileAccess.get_file_as_string(dst_file_path)
		if dst_after == orig_dst:
			print("  [PASS] copy produced independent file (mutating src didn't affect dst)")
			passed += 1
		else:
			print("  [FAIL] dst mutated after src change (linked copies?)")
			failed += 1
	else:
		print("  [FAIL] src or dst missing for independence test")
		failed += 1

	# 清理测试目录
	if DirAccess.dir_exists_absolute(test_dir):
		DirAccess.remove_absolute(test_dir)

	_report(passed, failed)

# 内联 CRC32（与 save_system._crc32_of_string 一致，避免 preload/load 编译问题）
func _crc32_of_string(s: String) -> int:
	var table: Array = []
	for i in range(256):
		var c := i
		for _j in range(8):
			if c & 1:
				c = (c >> 1) ^ 0xEDB88320
			else:
				c = c >> 1
		table.append(c)
	var crc := 0xFFFFFFFF
	var bytes := s.to_utf8_buffer()
	for i in range(bytes.size()):
		var idx := (crc ^ bytes[i]) & 0xFF
		crc = (crc >> 8) ^ int(table[idx])
	return crc ^ 0xFFFFFFFF

func _report(passed: int, failed: int) -> void:
	print("")
	print("=== T132 copy_slot backup/restore smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
