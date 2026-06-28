extends SceneTree

## T133 + T134 — Smoke test for PauseMenu "Quick Stats" 摘要行
##                and settings_menu dynamic SLOT_COUNT placeholder.
## Verifies:
##   T133 (PauseMenu Quick Stats):
##   1. pause_menu.tscn has a "ProfileQuickStats" Label
##   2. ProfileQuickStats sits between ProfileRun and HSep1 (ordering)
##   3. pause_menu.tscn default text contains 3 data points (成就 / 最佳 / Run #)
##   4. pause_menu.gd has @onready var _profile_quick_stats
##   5. _refresh_profile() populates _profile_quick_stats with BBCode
##   6. BBCode text uses the 3 style-guide colors (Glass Cyan / Amber Voice / 浅青)
##   7. PlayerStats exposes get_unlocked_count() and get_total_count()
##   8. Panel size bumped to fit new line (offset_top/offset_bottom = -120/+120)
##
##   T134 (settings_menu dynamic SLOT_COUNT):
##   9. settings_menu.tscn placeholder text matches SaveSystem.SLOT_COUNT (5)
##  10. settings_menu.gd has _has_save_system_autoload() guard method
##  11. settings_menu.gd _ready() calls _refresh_save_count() dynamically
##  12. _refresh_save_count() formats text using SaveSystem.SLOT_COUNT

func _init() -> void:
	print("=== T133 + T134 Quick Stats + Dynamic SLOT_COUNT smoke test ===")
	var fail_count := 0
	var test_num := 0

	# Load source files
	var pm_tscn_path := "res://src/scenes/pause_menu.tscn"
	var pm_gd_path := "res://src/scripts/pause_menu.gd"
	var sm_tscn_path := "res://src/scenes/settings_menu.tscn"
	var sm_gd_path := "res://src/scripts/settings_menu.gd"
	var ps_gd_path := "res://src/autoload/player_stats.gd"

	var pm_tscn := FileAccess.open(pm_tscn_path, FileAccess.READ)
	var pm_gd := FileAccess.open(pm_gd_path, FileAccess.READ)
	var sm_tscn := FileAccess.open(sm_tscn_path, FileAccess.READ)
	var sm_gd := FileAccess.open(sm_gd_path, FileAccess.READ)
	var ps_gd := FileAccess.open(ps_gd_path, FileAccess.READ)
	if pm_tscn == null or pm_gd == null or sm_tscn == null or sm_gd == null or ps_gd == null:
		print("  FAIL: cannot open one of the source files")
		quit(1)
		return
	var pm_tscn_text := pm_tscn.get_as_text()
	var pm_gd_text := pm_gd.get_as_text()
	var sm_tscn_text := sm_tscn.get_as_text()
	var sm_gd_text := sm_gd.get_as_text()
	var ps_gd_text := ps_gd.get_as_text()
	pm_tscn.close()
	pm_gd.close()
	sm_tscn.close()
	sm_gd.close()
	ps_gd.close()

	# === T133 tests ===

	# 1. ProfileQuickStats label exists in pause_menu.tscn
	test_num += 1
	if not 'name="ProfileQuickStats"' in pm_tscn_text:
		print("  FAIL [%d]: ProfileQuickStats node missing in pause_menu.tscn" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: ProfileQuickStats node declared" % test_num)

	# 2. ProfileQuickStats is positioned BETWEEN ProfileRun and HSep1 (parent is ProfileVBox)
	test_num += 1
	var run_idx := pm_tscn_text.find('name="ProfileRun"')
	var quick_idx := pm_tscn_text.find('name="ProfileQuickStats"')
	var hsep1_idx := pm_tscn_text.find('name="HSep1"')
	if run_idx < 0 or quick_idx < 0 or hsep1_idx < 0:
		print("  FAIL [%d]: cannot locate ProfileRun/ProfileQuickStats/HSep1 positions" % test_num)
		fail_count += 1
	elif not (run_idx < quick_idx and quick_idx < hsep1_idx):
		print("  FAIL [%d]: ProfileQuickStats not between ProfileRun and HSep1" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: ProfileQuickStats positioned between ProfileRun and HSep1" % test_num)

	# 3. Default 4 段文字 (成就 / 最佳 / 最长单房 / Run #) 各 1 sub-Label 拥有
	# T217 (#138) — 旧版 1 Label 4 BBCode 段 1 行聚合 → 4 sub-Label 独立段.
	# tscn HBoxContainer ProfileQuickStats 内 4 sub-Label 各持有 1 段
	# 1 段独立, 0 BBCode. 4 sub-Label 默认 placeholder (成就 0 / 13, 最佳 —,
	# 最长单房 —, Run #1) 在 tscn 各自 text 字段, _refresh_profile() 只
	# 改 4 sub-Label text, 0 改 4 sub-Label 颜色 (颜色 tscn theme_override).
	test_num += 1
	var text_block_idx := pm_tscn_text.find('name="ProfileQuickStats"')
	if text_block_idx < 0:
		print("  FAIL [%d]: ProfileQuickStats not in tscn" % test_num)
		fail_count += 1
	else:
		# HBoxContainer 内 4 sub-Label 8 邻 4 字段名 (QuickStatsAchievement / QuickStatsBestTime
		# / QuickStatsLongestRoom / QuickStatsRunNumber) 4 段独立存在, 4 段默认 placeholder
		# 文字 (成就 / 最佳 / 最长单房 / Run #) 4 段独立存在
		var search_window := pm_tscn_text.substr(text_block_idx, 4000)
		var has_achievement := "QuickStatsAchievement" in search_window and "成就 0 / 13" in search_window
		var has_best := "QuickStatsBestTime" in search_window and "最佳 —" in search_window
		var has_longest := "QuickStatsLongestRoom" in search_window and "最长单房 —" in search_window
		var has_run := "QuickStatsRunNumber" in search_window and "Run #1" in search_window
		if not (has_achievement and has_best and has_longest and has_run):
			print("  FAIL [%d]: ProfileQuickStats 4 sub-Label 缺段: ach=%s best=%s longest=%s run=%s" % [
				test_num, has_achievement, has_best, has_longest, has_run
			])
			fail_count += 1
		else:
			print("  PASS [%d]: ProfileQuickStats 4 sub-Label (成就 + 最佳 + 最长单房 + Run #) 全存在" % test_num)

	# 4. @onready var _profile_quick_stats declared in pause_menu.gd
	test_num += 1
	if not "@onready var _profile_quick_stats" in pm_gd_text:
		print("  FAIL [%d]: @onready var _profile_quick_stats missing" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: @onready var _profile_quick_stats declared" % test_num)

	# 5. _refresh_profile() 4 sub-Label text 独立 set (T217 (#138) 拆 4 BBCode 段
	# → 4 sub-Label 1 段独立 set). 旧版 1 Label 4 BBCode 段 _profile_quick_stats.text
	# 聚合写法废弃, 4 sub-Label 1 段独立 text setter 0 字符串拼接. 4 sub-Label
	# (.text = "成就 %d / %d" / "最佳 %s" / "最长单房 %s" / "Run #%d") 4 段各自
	# 出现 1 次. 末尾 _apply_quick_stats_hover_state() 1 次 re-apply hover 状态
	# (4 sub-Label modulate 重算).
	test_num += 1
	var refresh_body := _extract_func_body(pm_gd_text, "func _refresh_profile(")
	if refresh_body == "":
		print("  FAIL [%d]: cannot extract _refresh_profile body" % test_num)
		fail_count += 1
	elif not "_quick_stats_achievement.text = \"成就 %d / %d\"" in refresh_body:
		print("  FAIL [%d]: _refresh_profile missing _quick_stats_achievement.text setter" % test_num)
		fail_count += 1
	elif not "_quick_stats_best_time.text = \"最佳 %s\"" in refresh_body:
		print("  FAIL [%d]: _refresh_profile missing _quick_stats_best_time.text setter" % test_num)
		fail_count += 1
	elif not "_quick_stats_longest_room.text = \"最长单房 %s\"" in refresh_body:
		print("  FAIL [%d]: _refresh_profile missing _quick_stats_longest_room.text setter" % test_num)
		fail_count += 1
	elif not "_quick_stats_run_number.text = \"Run #%d\"" in refresh_body:
		print("  FAIL [%d]: _refresh_profile missing _quick_stats_run_number.text setter" % test_num)
		fail_count += 1
	elif not "_apply_quick_stats_hover_state()" in refresh_body:
		print("  FAIL [%d]: _refresh_profile missing _apply_quick_stats_hover_state() 末尾 re-apply" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _refresh_profile 4 sub-Label text 独立 set + apply 末尾调用" % test_num)

	# 6. STYLE_GUIDE 4 段 4 色 (Glass Cyan / Amber Voice / Muted Violet / Pale Resonance)
	# T217 (#138) — 旧版 BBCode 颜色 token ([color=#69C7CE] / [color=#F2B66E])
	# → tscn theme_override_colors/font_color 4 sub-Label 独立设. 4 段 4 色
	# (Glass Cyan #69C7CE 成就 / Amber Voice #F2B66E 最佳 / Muted Violet #65506A
	# 最长单房 / Pale Resonance #B7E6DC Run #) 0 复用, tscn 4 sub-Label font_color
	# 字段 4 段独立存在.
	test_num += 1
	var has_glass_cyan := "Color(0.412, 0.78, 0.808, 1)" in pm_tscn_text
	var has_amber_voice := "Color(0.949, 0.714, 0.431, 1)" in pm_tscn_text
	var has_muted_violet := "Color(0.4, 0.314, 0.416, 1)" in pm_tscn_text
	var has_pale_resonance := "Color(0.718, 0.906, 0.867, 1)" in pm_tscn_text
	if not (has_glass_cyan and has_amber_voice and has_muted_violet and has_pale_resonance):
		print("  FAIL [%d]: Quick Stats 4 段 4 色缺: cyan=%s amber=%s violet=%s pale=%s" % [
			test_num, has_glass_cyan, has_amber_voice, has_muted_violet, has_pale_resonance
		])
		fail_count += 1
	else:
		print("  PASS [%d]: Quick Stats 4 段 4 色 (Glass Cyan + Amber Voice + Muted Violet + Pale Resonance)" % test_num)

	# 7. PlayerStats exposes get_unlocked_count() and get_total_count()
	test_num += 1
	if not "func get_unlocked_count()" in ps_gd_text:
		print("  FAIL [%d]: PlayerStats.get_unlocked_count() missing" % test_num)
		fail_count += 1
	elif not "func get_total_count()" in ps_gd_text:
		print("  FAIL [%d]: PlayerStats.get_total_count() missing" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: PlayerStats.get_unlocked_count() + get_total_count() present" % test_num)

	# 8. PlayerProfilePanel size bumped to fit new line
	test_num += 1
	# Check offset_top and offset_bottom in the panel decl
	var panel_idx := pm_tscn_text.find('name="PlayerProfilePanel"')
	if panel_idx < 0:
		print("  FAIL [%d]: PlayerProfilePanel missing" % test_num)
		fail_count += 1
	else:
		var panel_window := pm_tscn_text.substr(panel_idx, 600)
		var has_offset_top_120 := "offset_top = -120.0" in panel_window
		var has_offset_bottom_120 := "offset_bottom = 120.0" in panel_window
		if not (has_offset_top_120 and has_offset_bottom_120):
			print("  FAIL [%d]: panel not resized to -120/+120 (top=%s, bottom=%s)" % [
				test_num, has_offset_top_120, has_offset_bottom_120
			])
			fail_count += 1
		else:
			print("  PASS [%d]: PlayerProfilePanel resized to -120/+120 (240px tall)" % test_num)

	# === T134 tests ===

	# 9. settings_menu.tscn placeholder text matches SaveSystem.SLOT_COUNT (5)
	test_num += 1
	if 'text = "当前存档：0 / 3"' in sm_tscn_text:
		print("  FAIL [%d]: settings_menu.tscn still has hard-coded '0 / 3'" % test_num)
		fail_count += 1
	elif not 'text = "当前存档：0 / 5"' in sm_tscn_text:
		print("  FAIL [%d]: settings_menu.tscn placeholder not updated to '0 / 5'" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: settings_menu.tscn placeholder updated to '0 / 5'" % test_num)

	# 10. settings_menu.gd has _has_save_system_autoload() guard method
	test_num += 1
	if not "func _has_save_system_autoload(" in sm_gd_text:
		print("  FAIL [%d]: _has_save_system_autoload() method missing" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _has_save_system_autoload() guard method present" % test_num)

	# 11. settings_menu.gd _ready() calls _refresh_save_count() dynamically
	test_num += 1
	var ready_body := _extract_func_body(sm_gd_text, "func _ready(")
	if ready_body == "":
		print("  FAIL [%d]: cannot extract settings_menu._ready body" % test_num)
		fail_count += 1
	elif not "_refresh_save_count()" in ready_body:
		print("  FAIL [%d]: settings_menu._ready() does not call _refresh_save_count()" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: settings_menu._ready() calls _refresh_save_count() dynamically" % test_num)

	# 12. _refresh_save_count() formats text using SaveSystem.SLOT_COUNT
	test_num += 1
	var refresh_save_body := _extract_func_body(sm_gd_text, "func _refresh_save_count(")
	if refresh_save_body == "":
		print("  FAIL [%d]: cannot extract _refresh_save_count body" % test_num)
		fail_count += 1
	elif not "SaveSystem.SLOT_COUNT" in refresh_save_body:
		print("  FAIL [%d]: _refresh_save_count does not use SaveSystem.SLOT_COUNT" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _refresh_save_count() uses SaveSystem.SLOT_COUNT dynamically" % test_num)

	# Final summary
	print("")
	if fail_count == 0:
		print("=== ALL %d TESTS PASSED ===" % test_num)
		quit(0)
	else:
		print("=== %d / %d TESTS FAILED ===" % [fail_count, test_num])
		quit(1)

func _extract_func_body(source: String, signature: String) -> String:
	# Extract the body of a `func foo(...): ...` block.  Heuristic —
	# find the signature, then capture everything up to the next
	# top-level "func " or "class_name " at the same indent level.
	var idx := source.find(signature)
	if idx < 0:
		return ""
	# Find the colon ending the function signature
	var colon_idx := source.find(":", idx)
	if colon_idx < 0:
		return ""
	# Find the next "\nfunc " or end of file after colon_idx
	var body_start := source.find("\n", colon_idx) + 1
	# Look for the next top-level "func " declaration
	var search_from := body_start
	while true:
		var next_func := source.find("\nfunc ", search_from)
		var next_class := source.find("\nclass_name ", search_from)
		var next_end := -1
		if next_func >= 0 and (next_end < 0 or next_func < next_end):
			next_end = next_func
		if next_class >= 0 and (next_end < 0 or next_class < next_end):
			next_end = next_class
		if next_end < 0:
			return source.substr(body_start)
		# Only break if it's at the same indent (top-level)
		# Find the line containing next_end
		var line_start := source.rfind("\n", next_end - 1) + 1
		var prefix := source.substr(line_start, next_end - line_start)
		# If the prefix is whitespace only, it's a top-level decl
		var stripped := prefix.strip_edges()
		if stripped == "":
			return source.substr(body_start, next_end - body_start)
		# Otherwise it's a nested function (e.g. inside a static func),
		# keep searching
		search_from = next_end + 1
		if search_from >= source.length():
			return source.substr(body_start)
	# Safety fallback — should be unreachable because the loop
	# either returns inside or hits search_from >= source.length().
	return source.substr(body_start)
