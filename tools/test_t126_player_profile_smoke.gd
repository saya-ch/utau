extends SceneTree

## T126 — Smoke test for the new "Player Profile" page in PauseMenu.
## Verifies:
##   1. pause_menu.tscn has a "PlayerProfilePanel" PanelContainer
##   2. pause_menu.tscn has a "ProfileButton" Button in the VBoxContainer
##   3. pause_menu.tscn has the 8 expected profile labels (Time / Deaths /
##      Rooms / Abilities / Shards / Reflects / AchvTitle / CloseBtn)
##   4. The ProfilePanel stylebox (StyleBoxFlat_profile_bg) is registered
##   5. pause_menu.gd has @onready var _profile_panel / _profile_btn / etc.
##   6. pause_menu.gd has _on_profile / _on_profile_close /
##      _refresh_profile / _build_profile_achievement_list /
##      _add_profile_achv_row / _refresh_profile_achievement_list methods
##   7. The ProfileButton is connected to _on_profile
##   8. The ProfileCloseButton is connected to _on_profile_close
##   9. _on_profile refreshes stats and shows the panel
##  10. PlayerStats exposes the 7 fields used by the profile page

func _initialize() -> void:
	print("=== T126 Player Profile page smoke test ===")
	var fail_count := 0
	var test_num := 0

	# Load both files
	var tscn_path := "res://src/scenes/pause_menu.tscn"
	var gd_path := "res://src/scripts/pause_menu.gd"
	var tscn := FileAccess.open(tscn_path, FileAccess.READ)
	var gd := FileAccess.open(gd_path, FileAccess.READ)
	if tscn == null:
		print("  FAIL: cannot open %s" % tscn_path)
		quit(1); return
	if gd == null:
		print("  FAIL: cannot open %s" % gd_path)
		quit(1); return
	var tscn_text := tscn.get_as_text()
	var gd_text := gd.get_as_text()
	tscn.close()
	gd.close()

	# 1. PlayerProfilePanel exists in the tscn
	test_num += 1
	if not 'name="PlayerProfilePanel"' in tscn_text:
		print("  FAIL [%d]: PlayerProfilePanel missing in pause_menu.tscn" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: PlayerProfilePanel node declared" % test_num)

	# 2. ProfileButton exists in the tscn
	test_num += 1
	if not 'name="ProfileButton"' in tscn_text:
		print("  FAIL [%d]: ProfileButton missing in pause_menu.tscn" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: ProfileButton node declared" % test_num)

	# 3. 8 expected profile labels
	test_num += 1
	var expected_labels := [
		"ProfileTime", "ProfileDeaths", "ProfileRooms",
		"ProfileAbilities", "ProfileShards", "ProfileReflects",
		"ProfileAchvTitle", "ProfileCloseButton"
	]
	var missing_labels: Array = []
	for lbl in expected_labels:
		if not ('name="%s"' % lbl) in tscn_text:
			missing_labels.append(lbl)
	if missing_labels.size() > 0:
		print("  FAIL [%d]: missing profile labels: %s" % [test_num, str(missing_labels)])
		fail_count += 1
	else:
		print("  PASS [%d]: all 8 expected profile labels present" % test_num)

	# 4. The stylebox is registered as a sub_resource
	test_num += 1
	if not 'StyleBoxFlat_profile_bg' in tscn_text:
		print("  FAIL [%d]: StyleBoxFlat_profile_bg sub_resource missing" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: StyleBoxFlat_profile_bg sub_resource present" % test_num)

	# 5. pause_menu.gd has the @onready var declarations
	test_num += 1
	var expected_vars := [
		"_profile_btn", "_profile_panel", "_profile_time",
		"_profile_deaths", "_profile_rooms", "_profile_abilities",
		"_profile_shards", "_profile_reflects", "_profile_achv_list",
		"_profile_close_btn"
	]
	var missing_vars: Array = []
	for v in expected_vars:
		if not ("@onready var %s" % v) in gd_text:
			missing_vars.append(v)
	if missing_vars.size() > 0:
		print("  FAIL [%d]: missing @onready vars: %s" % [test_num, str(missing_vars)])
		fail_count += 1
	else:
		print("  PASS [%d]: all 10 @onready profile vars declared" % test_num)

	# 6. pause_menu.gd has the 6 expected methods
	test_num += 1
	var expected_methods := [
		"func _on_profile(", "func _on_profile_close(",
		"func _refresh_profile(", "func _build_profile_achievement_list(",
		"func _add_profile_achv_row(", "func _refresh_profile_achievement_list("
	]
	var missing_methods: Array = []
	for m in expected_methods:
		if not m in gd_text:
			missing_methods.append(m)
	if missing_methods.size() > 0:
		print("  FAIL [%d]: missing methods: %s" % [test_num, str(missing_methods)])
		fail_count += 1
	else:
		print("  PASS [%d]: all 6 expected profile methods declared" % test_num)

	# 7. ProfileButton is connected to _on_profile
	test_num += 1
	if not '_profile_btn.pressed.connect(_on_profile)' in gd_text:
		print("  FAIL [%d]: _profile_btn not connected to _on_profile" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _profile_btn → _on_profile signal connected" % test_num)

	# 8. ProfileCloseButton is connected to _on_profile_close
	test_num += 1
	if not '_profile_close_btn.pressed.connect(_on_profile_close)' in gd_text:
		print("  FAIL [%d]: _profile_close_btn not connected to _on_profile_close" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _profile_close_btn → _on_profile_close signal connected" % test_num)

	# 9. _on_profile refreshes + shows
	test_num += 1
	# The _on_profile function should call _refresh_profile() and set visible = true
	var on_profile_body := _extract_func_body(gd_text, "func _on_profile(")
	if on_profile_body == "":
		print("  FAIL [%d]: cannot extract _on_profile body" % test_num)
		fail_count += 1
	elif not "_refresh_profile()" in on_profile_body:
		print("  FAIL [%d]: _on_profile does not call _refresh_profile()" % test_num)
		fail_count += 1
	elif not "_profile_panel.visible = true" in on_profile_body:
		print("  FAIL [%d]: _on_profile does not set _profile_panel.visible = true" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: _on_profile refreshes stats and shows panel" % test_num)

	# 10. PlayerStats exposes 7 expected fields
	test_num += 1
	var ps_path := "res://src/autoload/player_stats.gd"
	var ps := FileAccess.open(ps_path, FileAccess.READ)
	if ps == null:
		print("  FAIL [%d]: cannot open player_stats.gd" % test_num)
		fail_count += 1
	else:
		var ps_text := ps.get_as_text()
		ps.close()
		var expected_fields := [
			"rooms_cleared", "deaths", "pulse_used", "bind_used",
			"cut_used", "echo_used", "echo_reflects", "shards_collected"
		]
		var missing_fields: Array = []
		for f in expected_fields:
			if not ("var %s:" % f) in ps_text:
				missing_fields.append(f)
		if missing_fields.size() > 0:
			print("  FAIL [%d]: missing PlayerStats fields: %s" % [test_num, str(missing_fields)])
			fail_count += 1
		else:
			print("  PASS [%d]: all 8 expected PlayerStats fields present" % test_num)

	# summary
	if fail_count == 0:
		print("=== T126 Player Profile page smoke test PASSED (%d/%d) ===" % [test_num, test_num])
		quit(0)
	else:
		print("=== T126 Player Profile page smoke test FAILED (%d/%d) ===" % [fail_count, test_num])
		quit(1)

func _extract_func_body(source: String, func_header: String) -> String:
	var idx := source.find(func_header)
	if idx == -1:
		return ""
	# Walk forward to find the next "func " or EOF, return everything between
	# the header's colon and the next top-level "func ".
	var colon := source.find(":", idx)
	if colon == -1:
		return ""
	# naive: scan from colon+1 to next "func " at column 0
	var rest := source.substr(colon + 1)
	# find next "func " at start of line
	var lines := rest.split("\n")
	var body_lines: Array = []
	var started := false
	for line in lines:
		if started and line.begins_with("func "):
			break
		if started:
			body_lines.append(line)
		# detect end of header line (first line)
		if not started and line.begins_with("\t") or (started and line.length() > 0 and not line.begins_with("func ")):
			started = true
			body_lines.append(line)
	return "\n".join(body_lines)
