extends SceneTree

## test_t127_run_history_smoke.gd
## T127 — Run 编号 + 历史最佳 端到端冒烟测试
## 验证：
##  1. PlayerStats 默认 run_number = 1
##  2. reset_stats() 后 run_number = 2
##  3. _update_best_stats_from_current_run() 单调更新 _best_stats
##  4. _persist_best_stats() 写盘到 user://run_history.json
##  5. _load_best_stats() 恢复 _best_stats 和 run_number
##  6. get_best_stats() 返回副本（不暴露内部引用）
##  7. get_run_number() 与 run_number 一致
##  8. 单调更新：低值不破纪录

func _initialize() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0

	# 加载 PlayerStats script
	var ps_script := load("res://src/autoload/player_stats.gd")
	if ps_script == null:
		print("  FAIL: cannot load player_stats.gd")
		quit(1)
		return

	# 1. HISTORY_PATH 常量存在
	test_num += 1
	if ps_script.HISTORY_PATH == "user://run_history.json":
		print("  [%d] PASS  HISTORY_PATH = 'user://run_history.json'" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  HISTORY_PATH = '%s'" % [test_num, ps_script.HISTORY_PATH])
		failed += 1

	# 2. 默认 run_number = 1
	test_num += 1
	var ps := ps_script.new()
	ps._ready()
	if ps.get_run_number() == 1:
		print("  [%d] PASS  default run_number == 1" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  default run_number != 1 (got %d)" % [test_num, ps.get_run_number()])
		failed += 1

	# 3. 初始 _best_stats 全 0
	test_num += 1
	var best := ps.get_best_stats()
	var all_zero := true
	for key in best.keys():
		if best[key] != 0 and best[key] != 0.0:
			all_zero = false
			break
	if all_zero:
		print("  [%d] PASS  initial _best_stats all zero" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  initial _best_stats not zero: %s" % [test_num, str(best)])
		failed += 1

	# 4. _update_best_stats_from_current_run() 单调更新
	test_num += 1
	ps.rooms_cleared = 3
	ps.shards_collected = 7
	ps.enemies_purified = 5
	# 模拟 get_run_time_seconds() 返回 ~45s（偏移 _run_start_time）
	ps._run_start_time = Time.get_ticks_msec() / 1000.0 - 45.0
	ps._update_best_stats_from_current_run()
	var best2 := ps.get_best_stats()
	if int(best2.get("most_rooms_cleared", 0)) == 3 and int(best2.get("most_shards_collected", 0)) == 7 and int(best2.get("most_enemies_purified", 0)) == 5 and float(best2.get("longest_run_seconds", 0.0)) >= 44.0:
		print("  [%d] PASS  _update_best_stats_from_current_run picks up new bests" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _update_best_stats_from_current_run failed: %s" % [test_num, str(best2)])
		failed += 1

	# 5. reset_stats() 后 run_number = 2
	test_num += 1
	ps.reset_stats()
	if ps.get_run_number() == 2:
		print("  [%d] PASS  reset_stats() bumps run_number to 2" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  reset_stats() did not bump run_number (got %d)" % [test_num, ps.get_run_number()])
		failed += 1

	# 6. _best_stats 在 reset 后保留（单调更新）
	test_num += 1
	var best3 := ps.get_best_stats()
	if int(best3.get("most_rooms_cleared", 0)) == 3:
		print("  [%d] PASS  _best_stats persisted across reset_stats" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _best_stats lost across reset: %s" % [test_num, str(best3)])
		failed += 1

	# 7. get_best_stats() 返回副本（mutate 不影响内部状态）
	test_num += 1
	var best_copy := ps.get_best_stats()
	best_copy["most_rooms_cleared"] = 9999
	var best_check := ps.get_best_stats()
	if int(best_check.get("most_rooms_cleared", 0)) != 9999:
		print("  [%d] PASS  get_best_stats returns a defensive copy" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  get_best_stats exposes internal dict" % test_num)
		failed += 1

	# 8. _persist_best_stats() 写盘
	test_num += 1
	if FileAccess.file_exists(ps_script.HISTORY_PATH):
		print("  [%d] PASS  _persist_best_stats wrote to %s" % [test_num, ps_script.HISTORY_PATH])
		passed += 1
	else:
		print("  [%d] FAIL  _persist_best_stats did not write to %s" % [test_num, ps_script.HISTORY_PATH])
		failed += 1

	# 9. _load_best_stats() 恢复数据（创建新 instance 模拟新会话）
	test_num += 1
	var ps2 := ps_script.new()
	ps2._ready()
	if ps2.get_run_number() == 2:
		print("  [%d] PASS  _load_best_stats restored run_number = 2" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _load_best_stats did not restore run_number (got %d)" % [test_num, ps2.get_run_number()])
		failed += 1

	# 10. _load_best_stats() 恢复 _best_stats
	test_num += 1
	var best4 := ps2.get_best_stats()
	if int(best4.get("most_rooms_cleared", 0)) == 3 and int(best4.get("most_shards_collected", 0)) == 7:
		print("  [%d] PASS  _load_best_stats restored _best_stats" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _load_best_stats did not restore _best_stats: %s" % [test_num, str(best4)])
		failed += 1

	# 11. _update_best_stats_from_current_run() 不破坏较低记录（单调）
	test_num += 1
	ps2.rooms_cleared = 1  # 比 best 3 小
	ps2.shards_collected = 1
	ps2._run_start_time = Time.get_ticks_msec() / 1000.0 - 1.0  # 比 best 短
	ps2._update_best_stats_from_current_run()
	var best5 := ps2.get_best_stats()
	if int(best5.get("most_rooms_cleared", 0)) == 3 and int(best5.get("most_shards_collected", 0)) == 7 and float(best5.get("longest_run_seconds", 0.0)) >= 44.0:
		print("  [%d] PASS  _update_best_stats_from_current_run is monotonic (no regression)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _update_best_stats_from_current_run overwrote bests: %s" % [test_num, str(best5)])
		failed += 1

	# 12. get_run_number() 与 run_number 字段一致
	test_num += 1
	if ps2.get_run_number() == ps2.run_number:
		print("  [%d] PASS  get_run_number() == run_number field" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  get_run_number() != run_number" % test_num)
		failed += 1

	# 清理（避免污染 user://run_history.json 给后续测试）
	if FileAccess.file_exists(ps_script.HISTORY_PATH):
		DirAccess.remove_absolute(ps_script.HISTORY_PATH)
	ps.free()
	ps2.free()

	print("")
	print("T127 smoke test: %d passed, %d failed" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
