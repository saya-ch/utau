extends SceneTree

## test_t130_best_achievements_smoke.gd
##
## T130 冒烟测试 — PlayerStats 4 个新成就（基于 _best_stats 历史最佳）
##
## 13 项断言：
## 1. data/achievements.json 包含 14 个成就（10 旧 + 4 新；#74 T103 新增 quintuple_voice 五声回响）
## 2. 4 个新成就 id 存在：long_road / archive_master / resonance_hoarder / silence_hunter
## 3. 4 个新成就 condition.type == "best_stat_threshold"
## 4. 4 个新成就 condition.stat 引用 4 个 _best_stats 字段
## 5. 4 个新成就 icon_hint 复用现有 4 个（amber_lantern / amber_bell / amber_shard / coral_pulse）
## 6. PlayerStats._evaluate_condition 支持 "best_stat_threshold" 类型
## 7. _evaluate_condition("long_road") 在 _best_stats 不到 600s 时不达成
## 8. _evaluate_condition("archive_master") 在 _best_stats < 4 时不达成
## 9. _evaluate_condition("resonance_hoarder") 在 _best_stats < 50 时不达成
## 10. _evaluate_condition("silence_hunter") 在 _best_stats < 20 时不达成
## 11. PlayerStats 内 _best_stats 仍 4 字段（T127 不破坏）
## 12. _check_achievements 触发 best_stat_threshold 解锁（mock）
## 13. 中文 / 英文 description 包含"历史最佳" / "best ever" 关键词

const PlayerStatsScript := preload("res://src/autoload/player_stats.gd")

func _init() -> void:
	var passed := 0
	var failed := 0

	# --- 断言 1: achievements.json 含 13 个成就 ---
	var file := FileAccess.open("res://data/achievements.json", FileAccess.READ)
	if file == null:
		print("  [FAIL] cannot open achievements.json")
		failed += 1
		_report(passed, failed)
		return
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	var achvs: Array = parsed.get("achievements", [])
	if achvs.size() == 14:
		print("  [PASS] achievements.json has 14 entries (10 旧 + 4 新)")
		passed += 1
	else:
		print("  [FAIL] achievements.json has %d entries, expected 14" % achvs.size())
		failed += 1

	# --- 断言 2: 4 个新成就 id 存在 ---
	var ids: Array = []
	for a in achvs:
		ids.append(a.get("id", ""))
	var new_ids := ["long_road", "archive_master", "resonance_hoarder", "silence_hunter"]
	var all_present := true
	for nid in new_ids:
		if nid not in ids:
			all_present = false
			print("    [FAIL] missing id: %s" % nid)
	if all_present:
		print("  [PASS] 4 new achievement ids present")
		passed += 1
	else:
		print("  [FAIL] some new ids missing")
		failed += 1

	# --- 断言 3: 4 个新成就 condition.type == "best_stat_threshold" ---
	var all_best_threshold := true
	for a in achvs:
		if a.get("id", "") in new_ids:
			if a.get("condition", {}).get("type", "") != "best_stat_threshold":
				all_best_threshold = false
				print("    [FAIL] %s condition type wrong: %s" % [
					a.get("id", ""), a.get("condition", {}).get("type", "")])
	if all_best_threshold:
		print("  [PASS] 4 new conditions type == best_stat_threshold")
		passed += 1
	else:
		failed += 1

	# --- 断言 4: 4 个新成就 stat 引用 4 个 _best_stats 字段 ---
	var expected_stats := {
		"long_road": "longest_run_seconds",
		"archive_master": "most_rooms_cleared",
		"resonance_hoarder": "most_shards_collected",
		"silence_hunter": "most_enemies_purified"
	}
	var stats_ok := true
	for a in achvs:
		var id_val: String = a.get("id", "")
		if id_val in expected_stats:
			var stat: String = a.get("condition", {}).get("stat", "")
			if stat != expected_stats[id_val]:
				stats_ok = false
				print("    [FAIL] %s stat=%s, expected %s" % [id_val, stat, expected_stats[id_val]])
	if stats_ok:
		print("  [PASS] 4 new conditions stat fields correct")
		passed += 1
	else:
		failed += 1

	# --- 断言 5: 4 个新成就 icon_hint 复用现有 4 个 ---
	var expected_icons := {
		"long_road": "amber_lantern",
		"archive_master": "amber_bell",
		"resonance_hoarder": "amber_shard",
		"silence_hunter": "coral_pulse"
	}
	var icons_ok := true
	for a in achvs:
		var id_val: String = a.get("id", "")
		if id_val in expected_icons:
			var icon: String = a.get("icon_hint", "")
			if icon != expected_icons[id_val]:
				icons_ok = false
				print("    [FAIL] %s icon_hint=%s, expected %s" % [id_val, icon, expected_icons[id_val]])
	# 验证 icon_hint 目录存在
	for icon_name in expected_icons.values():
		var dir_path := "res://assets/ui/achievements/%s/" % icon_name
		if not DirAccess.dir_exists_absolute(dir_path):
			icons_ok = false
			print("    [FAIL] icon dir missing: %s" % dir_path)
	if icons_ok:
		print("  [PASS] 4 new icon_hints reuse existing assets (dirs exist)")
		passed += 1
	else:
		failed += 1

	# --- 断言 6: PlayerStats._evaluate_condition 支持 "best_stat_threshold" ---
	var ps: Node = PlayerStatsScript.new()
	if ps.has_method("_evaluate_condition"):
		var cond := {"type": "best_stat_threshold", "stat": "longest_run_seconds", "min": 600}
		var result: bool = bool(ps.call("_evaluate_condition", cond))
		# 默认 _best_stats.longest_run_seconds == 0.0, 应返回 false
		if result == false:
			print("  [PASS] _evaluate_condition supports best_stat_threshold (default returns false)")
			passed += 1
		else:
			print("  [FAIL] _evaluate_condition(best_stat_threshold) returned true with default 0")
			failed += 1
	else:
		print("  [FAIL] PlayerStats._evaluate_condition method missing")
		failed += 1

	# --- 断言 7-10: 各新条件不达成（默认 0 < min） ---
	var test_cases := [
		["long_road", "longest_run_seconds", 600, 0.0, false],
		["archive_master", "most_rooms_cleared", 4, 0, false],
		["resonance_hoarder", "most_shards_collected", 50, 0, false],
		["silence_hunter", "most_enemies_purified", 20, 0, false]
	]
	var gate_evaluate_ok := true
	for tc in test_cases:
		var id_val: String = tc[0]
		var stat: String = tc[1]
		var min_v = tc[2]
		var best_v = tc[3]
		var expected: bool = tc[4]
		# 通过修改 _best_stats 测试（只读 mock）
		ps.set("_best_stats", {stat: best_v})
		var cond := {"type": "best_stat_threshold", "stat": stat, "min": min_v}
		var got: bool = bool(ps.call("_evaluate_condition", cond))
		if got != expected:
			gate_evaluate_ok = false
			print("    [FAIL] %s: best=%s min=%s got=%s expected=%s" % [id_val, str(best_v), str(min_v), str(got), str(expected)])
	# bonus: 达成测试
	ps.set("_best_stats", {
		"longest_run_seconds": 700.0,
		"most_rooms_cleared": 5,
		"most_shards_collected": 60,
		"most_enemies_purified": 25
	})
	var reach_ok := true
	for tc in test_cases:
		var stat: String = tc[1]
		var min_v = tc[2]
		var cond := {"type": "best_stat_threshold", "stat": stat, "min": min_v}
		var got: bool = bool(ps.call("_evaluate_condition", cond))
		if got != true:
			reach_ok = false
			print("    [FAIL] %s reachable case got=false" % tc[0])
	if gate_evaluate_ok and reach_ok:
		print("  [PASS] 4 new conditions evaluate correctly (4 unreached + 4 reached)")
		passed += 1
	else:
		failed += 1

	# --- 断言 11: _best_stats 仍 4 字段（T127 不破坏） ---
	var best_stats: Dictionary = ps.get("_best_stats")
	var expected_keys := ["longest_run_seconds", "most_rooms_cleared", "most_shards_collected", "most_enemies_purified"]
	var all_keys := true
	for k in expected_keys:
		if not best_stats.has(k):
			all_keys = false
	if all_keys:
		print("  [PASS] _best_stats retains 4 T127 fields")
		passed += 1
	else:
		print("  [FAIL] _best_stats missing T127 fields")
		failed += 1

	# --- 断言 12: _check_achievements 触发 best_stat_threshold 解锁（mock） ---
	# 通过把 _best_stats 抬到满足条件，调用 _check_achievements
	ps.set("_best_stats", {
		"longest_run_seconds": 700.0,
		"most_rooms_cleared": 5,
		"most_shards_collected": 60,
		"most_enemies_purified": 25
	})
	# 加载成就定义（手动注入，绕开 _ready）
	var definitions_by_id: Dictionary = {}
	for a in achvs:
		var id_val: String = a.get("id", "")
		if id_val != "":
			definitions_by_id[id_val] = a
	ps.set("_definitions_by_id", definitions_by_id)
	ps.set("_achievements", achvs)
	ps.set("_unlocked_ids", {})
	# 模拟 autoload 缺失时 has_method 守卫
	if not ps.has_method("_check_achievements"):
		print("  [FAIL] _check_achievements method missing")
		failed += 1
	else:
		# 调用 _check_achievements 应当解锁 4 个新成就
		ps.call("_check_achievements")
		var unlocked: Dictionary = ps.get("_unlocked_ids")
		var newly_unlocked := 0
		for nid in new_ids:
			if unlocked.get(nid, false):
				newly_unlocked += 1
		if newly_unlocked == 4:
			print("  [PASS] _check_achievements unlocked all 4 new best_stat achievements")
			passed += 1
		else:
			print("  [FAIL] _check_achievements only unlocked %d/4 new achievements" % newly_unlocked)
			failed += 1

	# --- 断言 13: 中文 / 英文 description 包含"历史最佳" / "best ever" ---
	var desc_ok := true
	for a in achvs:
		var id_val: String = a.get("id", "")
		if id_val in new_ids:
			var d_zh: String = a.get("description_zh", "")
			var d_en: String = a.get("description_en", "")
			if "历史最佳" not in d_zh or "best ever" not in d_en:
				desc_ok = false
				print("    [FAIL] %s description missing '历史最佳' or 'best ever'" % id_val)
	if desc_ok:
		print("  [PASS] 4 new descriptions contain '历史最佳' / 'best ever'")
		passed += 1
	else:
		failed += 1

	ps.free()
	_report(passed, failed)

func _report(passed: int, failed: int) -> void:
	print("")
	print("=== T130 best_stat_threshold achievements smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
