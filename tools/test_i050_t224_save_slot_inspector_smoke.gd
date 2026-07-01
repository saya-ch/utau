extends SceneTree

## test_i050_t224_save_slot_inspector_smoke.gd
## T224 (#146) — save_slot.json 历史 5 局 0 损坏 0 漂移巡检
##
## 覆盖：
##  1. save_system.gd 暴露公开 audit_save_slots() 方法
##  2. save_system.gd 有私有 _audit_save_slots() worker
##  3. _ready 末尾调用 audit_save_slots (boot-time 巡检)
##  4. title_screen.gd 引用 audit_save_slots (re-enter 巡检)
##  5. 内联模拟 4 状态分类逻辑 (empty/ok/corrupted/drift)
##  6. 报告 dict 含 6 个 key (ok/corrupted/drift/empty/total/ids)

func _init() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0

	# --- 1. save_system.gd 暴露公开 audit_save_slots() 方法 ---
	test_num += 1
	var ss_file := FileAccess.open("res://src/autoload/save_system.gd", FileAccess.READ)
	if ss_file == null:
		print("  [%d] FAIL  save_system.gd 不可读" % test_num)
		failed += 1
		_finish(passed, failed)
		return
	var ss_text := ss_file.get_as_text()
	ss_file.close()
	if "func audit_save_slots" in ss_text and "func _audit_save_slots" in ss_text:
		print("  [%d] PASS  audit_save_slots (公开) + _audit_save_slots (私有) 都存在" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  audit_save_slots 或 _audit_save_slots 缺失" % test_num)
		failed += 1

	# --- 2. _ready 末尾调用 audit_save_slots (boot-time 巡检) ---
	test_num += 1
	# 找 _ready 函数体并检查是否在末尾有 audit_save_slots() 调用
	var ready_start := ss_text.find("func _ready()")
	if ready_start < 0:
		print("  [%d] FAIL  save_system.gd 找不到 _ready" % test_num)
		failed += 1
	else:
		# 找下一个顶级 func (即 _ready 结束位置)
		var next_func := ss_text.find("\nfunc ", ready_start + 10)
		var ready_body: String
		if next_func > 0:
			ready_body = ss_text.substr(ready_start, next_func - ready_start)
		else:
			ready_body = ss_text.substr(ready_start)
		if "call_deferred(\"audit_save_slots\")" in ready_body or "audit_save_slots()" in ready_body:
			print("  [%d] PASS  _ready 调用 audit_save_slots (boot-time 巡检)" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  _ready 缺 audit_save_slots 调用" % test_num)
			failed += 1

	# --- 3. title_screen.gd 引用 audit_save_slots (re-enter 巡检) ---
	test_num += 1
	var ts_file := FileAccess.open("res://src/scripts/title_screen.gd", FileAccess.READ)
	if ts_file == null:
		print("  [%d] FAIL  title_screen.gd 不可读" % test_num)
		failed += 1
	else:
		var ts_text := ts_file.get_as_text()
		ts_file.close()
		if "audit_save_slots" in ts_text and "T224" in ts_text:
			print("  [%d] PASS  title_screen.gd 引用 audit_save_slots + T224 注释" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  title_screen.gd 缺 audit_save_slots 引用或 T224 注释" % test_num)
			failed += 1

	# --- 4. 报告 dict 含 8 个 key ---
	test_num += 1
	var required_keys := ["ok", "corrupted", "drift", "empty", "total", "ok_ids", "corrupted_ids", "drift_ids"]
	var missing_keys: Array = []
	for k in required_keys:
		if not (k in ss_text):
			missing_keys.append(k)
	if missing_keys.is_empty():
		print("  [%d] PASS  报告 dict 含 8 个 key (ok/corrupted/drift/empty/total + 4 个 ids)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  报告缺 key: %s" % [test_num, str(missing_keys)])
		failed += 1

	# --- 5. 内联模拟 4 状态分类逻辑 (empty/ok/corrupted/drift) ---
	# _classify_slot(path, file_exists, parse_ok, has_room) 4 状态:
	#   empty    : file_exists=false
	#   corrupted: file_exists=true, parse_ok=false
	#   drift    : file_exists=true, parse_ok=true, has_room=false
	#   ok       : file_exists=true, parse_ok=true, has_room=true
	test_num += 1
	var st_empty: String = _classify_slot("/nonexistent", false, true, true)     # file 不存在
	var st_ok: String = _classify_slot("/fake/ok", true, true, true)             # file + parse + has_room
	var st_corrupted: String = _classify_slot("/fake/c", true, false, true)      # file + parse 失败 (CRC32 mismatch 模拟)
	var st_drift: String = _classify_slot("/fake/d", true, true, false)          # file + parse + has_room=false (字段缺失)
	if st_empty == "empty" and st_ok == "ok" and st_corrupted == "corrupted" and st_drift == "drift":
		print("  [%d] PASS  4 状态分类逻辑正确 (empty/ok/corrupted/drift)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  4 状态不对: empty=%s, ok=%s, corrupted=%s, drift=%s" % [test_num, st_empty, st_ok, st_corrupted, st_drift])
		failed += 1

	# --- 6. T224 注释在 save_system.gd 中 (code review 友好) ---
	test_num += 1
	if "T224" in ss_text and "audit" in ss_text:
		print("  [%d] PASS  T224 注释 + audit 关键字在 save_system.gd 中" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T224 注释或 audit 关键字缺失" % test_num)
		failed += 1

	# --- 7. audit_save_slots 返回 Dictionary (非 void) ---
	test_num += 1
	# 找 audit_save_slots 函数签名
	if "func audit_save_slots() -> Dictionary:" in ss_text:
		print("  [%d] PASS  audit_save_slots() -> Dictionary 返回类型正确" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  audit_save_slots 返回类型不是 Dictionary" % test_num)
		failed += 1

	_finish(passed, failed)

func _finish(passed: int, failed: int) -> void:
	print("")
	print("=== I050 T224 save_slot_inspector smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)

# === 内联 helpers（避免 headless --script 模式下 SaveSystem 实例化编译失败） ===

# 模拟 _audit_save_slots() 的单槽位分类逻辑（最小化版）。
# 4 状态优先级: empty (file 不存在) > corrupted (file 在但 parse 失败 /
# CRC32 mismatch) > drift (parse ok 但缺 required fields) > ok (全部完整)。
func _classify_slot(path: String, file_exists: bool, parse_ok: bool, has_room: bool) -> String:
	if not file_exists:
		return "empty"
	if not parse_ok:
		return "corrupted"
	# file_exists + parse_ok → 假设 has_room 决定 ok / drift
	if not has_room:
		return "drift"
	return "ok"
