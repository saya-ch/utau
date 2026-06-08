extends SceneTree

## test_t131_run_trends_smoke.gd
##
## T131 冒烟测试 — PlayerStats _run_history + 近 N 局平均 API
##
## 11 项断言：
## 1. _run_history 字段默认空数组
## 2. _capture_run_into_history 写入 1 条 snapshot
## 3. 第 1 条 snapshot 含 run_number + run_time_seconds + 4 统计字段
## 4. 第 2 次 capture 后 _run_history 长度 2
## 5. _RUN_HISTORY_MAX = 20：capture 25 次后只保留 20 条
## 6. 截断时丢弃最早元素（FIFO），最后元素 run_number == 25
## 7. get_run_history 返回防御性副本（mutate 不影响原 array）
## 8. get_recent_runs(5) 返回最后 5 条
## 9. get_recent_runs(50) 当只有 20 条时返回 20 条
## 10. get_recent_runs_average(3) 返回 4 字段平均 + sample_count=3
## 11. 零样本时 get_recent_runs_average 返回空 dict

const PlayerStatsScript := preload("res://src/autoload/player_stats.gd")

func _init() -> void:
	var passed := 0
	var failed := 0
	var ps: Node = PlayerStatsScript.new()
	# 绕开 _ready（不挂 scene tree）；_run_history 默认是 []

	# --- 断言 1: _run_history 字段默认空数组 ---
	var initial_hist: Array = ps.get("_run_history")
	if initial_hist.size() == 0:
		print("  [PASS] _run_history starts empty")
		passed += 1
	else:
		print("  [FAIL] _run_history initial size = %d, expected 0" % initial_hist.size())
		failed += 1

	# --- 断言 2: _capture_run_into_history 写入 1 条 snapshot ---
	if not ps.has_method("_capture_run_into_history"):
		print("  [FAIL] _capture_run_into_history method missing")
		failed += 1
		_report(passed, failed)
		ps.free()
		return
	ps.call("_capture_run_into_history")
	var hist1: Array = ps.get("_run_history")
	if hist1.size() == 1:
		print("  [PASS] _capture_run_into_history appends 1 entry")
		passed += 1
	else:
		print("  [FAIL] _capture_run_into_history: hist size = %d, expected 1" % hist1.size())
		failed += 1

	# --- 断言 3: snapshot 含 6 字段 ---
	var entry0: Dictionary = hist1[0]
	var expected_keys := ["run_number", "run_time_seconds", "rooms_cleared", "enemies_purified", "shards_collected", "deaths"]
	var all_keys := true
	for k in expected_keys:
		if not entry0.has(k):
			all_keys = false
			print("    [FAIL] snapshot missing key: %s" % k)
	if all_keys:
		print("  [PASS] snapshot has 6 fields (run_number/time/rooms/enemies/shards/deaths)")
		passed += 1
	else:
		failed += 1

	# --- 断言 4: 第二次 capture 后长度 2 ---
	# 改一下 run_number 让 snapshot 唯一
	ps.set("run_number", 7)
	ps.call("_capture_run_into_history")
	var hist2: Array = ps.get("_run_history")
	if hist2.size() == 2:
		print("  [PASS] 2 captures → hist size 2")
		passed += 1
	else:
		print("  [FAIL] 2 captures → hist size %d" % hist2.size())
		failed += 1

	# --- 断言 5: _RUN_HISTORY_MAX = 20：25 次 capture 后只留 20 ---
	var cap_max: int = int(ps.get("_RUN_HISTORY_MAX"))
	if cap_max != 20:
		print("  [FAIL] _RUN_HISTORY_MAX = %d, expected 20" % cap_max)
		failed += 1
	else:
		print("  [PASS] _RUN_HISTORY_MAX = 20")
		passed += 1
	# 清空再灌 25 次
	ps.set("_run_history", [])
	for i in range(25):
		ps.set("run_number", i + 1)
		# 让 stats 字段稍微变化便于验证 FIFO
		ps.set("rooms_cleared", i + 1)
		ps.call("_capture_run_into_history")
	var hist25: Array = ps.get("_run_history")
	if hist25.size() == 20:
		print("  [PASS] 25 captures → FIFO cap 20")
		passed += 1
	else:
		print("  [FAIL] 25 captures → hist size %d, expected 20" % hist25.size())
		failed += 1

	# --- 断言 6: 截断时丢弃最早元素，最后 run_number == 25 ---
	var first_entry: Dictionary = hist25[0]
	var last_entry: Dictionary = hist25[hist25.size() - 1]
	if int(first_entry.get("run_number", 0)) == 6 and int(last_entry.get("run_number", 0)) == 25:
		print("  [PASS] FIFO trim: first run_number=6, last=25 (dropped 1-5)")
		passed += 1
	else:
		print("  [FAIL] FIFO wrong: first=%s last=%s" % [
			str(first_entry.get("run_number", "?")),
			str(last_entry.get("run_number", "?"))])
		failed += 1

	# --- 断言 7: get_run_history 返回防御性副本 ---
	var hist_a: Array = ps.call("get_run_history")
	hist_a.clear()  # mutate 副本
	var hist_b: Array = ps.get("_run_history")
	if hist_b.size() == 20:
		print("  [PASS] get_run_history returns defensive copy (mutate didn't affect internal)")
		passed += 1
	else:
		print("  [FAIL] defensive copy broken: internal size after mutate = %d" % hist_b.size())
		failed += 1

	# --- 断言 8: get_recent_runs(5) 返回最后 5 条 ---
	var recent5: Array = ps.call("get_recent_runs", 5)
	if recent5.size() == 5 and int((recent5[0] as Dictionary).get("run_number", 0)) == 21:
		print("  [PASS] get_recent_runs(5) returns last 5 (run_number 21-25)")
		passed += 1
	else:
		print("  [FAIL] get_recent_runs(5) wrong: size=%d first_run_number=%s" % [
			recent5.size(),
			str((recent5[0] as Dictionary).get("run_number", "?")) if recent5.size() > 0 else "<empty>"])
		failed += 1

	# --- 断言 9: get_recent_runs(50) 当只 20 条时返回 20 条 ---
	var recent50: Array = ps.call("get_recent_runs", 50)
	if recent50.size() == 20:
		print("  [PASS] get_recent_runs(50) clamped to hist size 20")
		passed += 1
	else:
		print("  [FAIL] get_recent_runs(50) returned %d, expected 20" % recent50.size())
		failed += 1

	# --- 断言 10: get_recent_runs_average(3) 返回平均 + sample_count ---
	# 重置 3 条已知数据让平均可预测
	ps.set("_run_history", [
		{"run_number": 1, "run_time_seconds": 60.0, "rooms_cleared": 2, "enemies_purified": 4, "shards_collected": 6, "deaths": 1},
		{"run_number": 2, "run_time_seconds": 120.0, "rooms_cleared": 4, "enemies_purified": 8, "shards_collected": 12, "deaths": 2},
		{"run_number": 3, "run_time_seconds": 180.0, "rooms_cleared": 6, "enemies_purified": 12, "shards_collected": 18, "deaths": 3}
	])
	var avg3: Dictionary = ps.call("get_recent_runs_average", 3)
	if avg3.is_empty():
		print("  [FAIL] avg3 returned empty dict")
		failed += 1
	else:
		# 平均: rooms=(2+4+6)/3=4, enemies=(4+8+12)/3=8, shards=(6+12+18)/3=12, time=(60+120+180)/3=120, deaths=(1+2+3)/3=2
		var rooms_ok: bool = abs(float(avg3.get("rooms_cleared", 0.0)) - 4.0) < 0.001
		var enemies_ok: bool = abs(float(avg3.get("enemies_purified", 0.0)) - 8.0) < 0.001
		var shards_ok: bool = abs(float(avg3.get("shards_collected", 0.0)) - 12.0) < 0.001
		var time_ok: bool = abs(float(avg3.get("run_time_seconds", 0.0)) - 120.0) < 0.001
		var deaths_ok: bool = abs(float(avg3.get("deaths", 0.0)) - 2.0) < 0.001
		var count_ok: bool = int(avg3.get("sample_count", 0)) == 3
		if rooms_ok and enemies_ok and shards_ok and time_ok and deaths_ok and count_ok:
			print("  [PASS] get_recent_runs_average(3) correct (rooms=4/enemies=8/shards=12/time=120/deaths=2, n=3)")
			passed += 1
		else:
			print("  [FAIL] avg3 wrong: rooms=%s enemies=%s shards=%s time=%s deaths=%s n=%s" % [
				str(avg3.get("rooms_cleared", "?")),
				str(avg3.get("enemies_purified", "?")),
				str(avg3.get("shards_collected", "?")),
				str(avg3.get("run_time_seconds", "?")),
				str(avg3.get("deaths", "?")),
				str(avg3.get("sample_count", "?"))])
			failed += 1

	# --- 断言 11: 零样本时 get_recent_runs_average 返回空 dict ---
	ps.set("_run_history", [])
	var avg_empty: Dictionary = ps.call("get_recent_runs_average", 5)
	if avg_empty.is_empty():
		print("  [PASS] get_recent_runs_average returns empty dict when hist empty")
		passed += 1
	else:
		print("  [FAIL] get_recent_runs_average should be empty when hist empty, got: %s" % str(avg_empty))
		failed += 1

	ps.free()
	_report(passed, failed)

func _report(passed: int, failed: int) -> void:
	print("")
	print("=== T131 run history / trends smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
