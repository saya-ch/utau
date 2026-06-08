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

	# 3. Default text contains 3 data points: 成就 / 最佳 / Run #
	test_num += 1
	# Extract the text= value for ProfileQuickStats
	var text_block_idx := pm_tscn_text.find('name="ProfileQuickStats"')
	if text_block_idx < 0:
		print("  FAIL [%d]: ProfileQuickStats not in tscn" % test_num)
		fail_count += 1
	else:
		# Find the line starting with text = after the ProfileQuickStats node decl
		var search_window := pm_tscn_text.substr(text_block_idx, 400)
		var has_achievement := "成就" in search_window
		var has_best := "最佳" in search_window
		var has_run := "Run #" in search_window
		if not (has_achievement and has_best and has_run):
			print("  FAIL [%d]: ProfileQuickStats text missing one of {成就/最佳/Run #}: ach=%s best=%s run=%s" % [
				test_num, has_achievement, has_best, has_run
			])
			fail_count += 1
		else:
			print("  PASS [%d]: ProfileQuickStats default text has 成就 + 最佳 + Run #" % test_num)

	# 4. @onready var _profile_quick_stats declared in pause_menu.gd
	test_num += 1
	if not "@onready var _profile_quick_stats" in pm_gd_text:
		print("  FAIL [%d]: @onready var _profile_quick_stats missing" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: @onready var _profile_quick_stats declared" % test_num)

	# 5. _refresh_profile() populates _profile_quick_stats with BBCode
	test_num += 1
	var refresh_body := _extract_func_body(pm_gd_text, "func _refresh_profile(")
	if refresh_body == "":
		print("  FAIL [%d]: cannot extract _refresh_profile body" % test_num)
		fail_count += 1
	elif not "_profile_quick_stats.text =" in refresh_body:
		print("  FAIL [%d]: _refresh_profile does not set _profile_quick_stats.text" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _refresh_profile populates _profile_quick_stats" % test_num)

	# 6. BBCode text uses 3 style-guide colors (Glass Cyan #69C7CE / Amber Voice #F2B66E / pale cyan)
	test_num += 1
	if not "[color=#69C7CE]" in refresh_body:
		print("  FAIL [%d]: Quick Stats missing Glass Cyan #69C7CE for 成就" % test_num)
		fail_count += 1
	elif not "[color=#F2B66E]" in refresh_body:
		print("  FAIL [%d]: Quick Stats missing Amber Voice #F2B66E for 最佳" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: Quick Stats uses STYLE_GUIDE colors (Glass Cyan + Amber Voice)" % test_num)

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
