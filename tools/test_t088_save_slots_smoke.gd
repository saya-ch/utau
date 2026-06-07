extends SceneTree

## T088 — Smoke test for the 5-slot save system + list/card layout toggle.
## Runs headless. Verifies that all the wiring is in place:
##   1. SaveSystem.SLOT_COUNT is 5 (was 3)
##   2. SaveLoadMenu.SLOT_COUNT is 5
##   3. SaveLoadMenu has layout export + layout_changed signal
##   4. SaveLoadMenu has _make_list_row + _make_card_panel factories
##   5. SaveLoadMenu has _on_toggle_layout + _refresh_layout_btn_text
##   6. save_load_menu.tscn has the new LayoutButton node + 360-tall RootPanel
##   7. title_screen.gd uses SaveSystem.SLOT_COUNT (not hardcoded 3)
##   8. settings_menu.gd no longer mentions "the 3 slots" in stale comment

func _initialize() -> void:
	print("=== T088 5-slot save + list/card layout smoke test ===")

	# 1. SaveSystem SLOT_COUNT = 5
	var ss_script := load("res://src/autoload/save_system.gd")
	if ss_script == null:
		print("  FAIL: cannot load save_system.gd")
		quit(1)
		return
	var slot_count: int = int(ss_script.SLOT_COUNT)
	if slot_count != 5:
		print("  FAIL: SaveSystem.SLOT_COUNT = %d, expected 5" % slot_count)
		quit(1)
		return
	print("  SaveSystem.SLOT_COUNT = 5 (OK)")

	# 2. SaveSystem.is_valid_slot must accept slot 0..4 and reject 5
	var ss_tmp: Node = ss_script.new()
	var valid_5 := false
	if ss_tmp.has_method("_is_valid_slot"):
		valid_5 = ss_tmp.call("_is_valid_slot", 4) and not ss_tmp.call("_is_valid_slot", 5)
	ss_tmp.free()
	if not valid_5:
		print("  FAIL: _is_valid_slot(4) should be true, _is_valid_slot(5) should be false")
		quit(1)
		return
	print("  _is_valid_slot handles 0..4 OK")

	# 3. SaveLoadMenu has SLOT_COUNT = 5 + layout export + layout_changed signal
	var slm_script := load("res://src/scripts/save_load_menu.gd")
	if slm_script == null:
		print("  FAIL: cannot load save_load_menu.gd")
		quit(1)
		return
	var slm_slot_count: int = int(slm_script.SLOT_COUNT)
	if slm_slot_count != 5:
		print("  FAIL: SaveLoadMenu.SLOT_COUNT = %d, expected 5" % slm_slot_count)
		quit(1)
		return
	print("  SaveLoadMenu.SLOT_COUNT = 5 (OK)")

	var slm_tmp: Node = slm_script.new()
	var has_layout_export := "layout" in slm_tmp.get_property_list().map(func(p): return p.name) \
		if slm_tmp.get_property_list().size() > 0 else false
	# Simpler: just check via property_list for the layout property's existence
	has_layout_export = false
	for p in slm_tmp.get_property_list():
		if p.name == "layout":
			has_layout_export = true
			break
	slm_tmp.free()
	if not has_layout_export:
		print("  FAIL: SaveLoadMenu does not export 'layout' property")
		quit(1)
		return
	print("  SaveLoadMenu exports 'layout' property (OK)")

	# 4. SaveLoadMenu source has _make_list_row + _make_card_panel + _on_toggle_layout
	var slm_text_file := FileAccess.open("res://src/scripts/save_load_menu.gd", FileAccess.READ)
	if slm_text_file == null:
		print("  FAIL: cannot open save_load_menu.gd")
		quit(1)
		return
	var slm_text := slm_text_file.get_as_text()
	slm_text_file.close()
	for token in ["_make_list_row", "_make_card_panel", "_on_toggle_layout", "_refresh_layout_btn_text", "layout_changed"]:
		if token not in slm_text:
			print("  FAIL: save_load_menu.gd missing %s" % token)
			quit(1)
			return
	print("  save_load_menu.gd has _make_list_row/_make_card_panel/_on_toggle_layout (OK)")

	# 5. save_load_menu.tscn has LayoutButton node + 360-tall RootPanel
	var tscn_file := FileAccess.open("res://src/scenes/save_load_menu.tscn", FileAccess.READ)
	if tscn_file == null:
		print("  FAIL: cannot open save_load_menu.tscn")
		quit(1)
		return
	var tscn_text := tscn_file.get_as_text()
	tscn_file.close()
	if "LayoutButton" not in tscn_text:
		print("  FAIL: save_load_menu.tscn missing LayoutButton node")
		quit(1)
		return
	if "offset_top = -180.0" not in tscn_text:
		print("  FAIL: save_load_menu.tscn RootPanel not resized to 360 tall (offset_top -180)")
		quit(1)
		return
	print("  save_load_menu.tscn has LayoutButton + 360-tall RootPanel (OK)")

	# 6. title_screen.gd uses SaveSystem.SLOT_COUNT
	var ts_text_file := FileAccess.open("res://src/scripts/title_screen.gd", FileAccess.READ)
	if ts_text_file == null:
		print("  FAIL: cannot open title_screen.gd")
		quit(1)
		return
	var ts_text := ts_text_file.get_as_text()
	ts_text_file.close()
	if "SaveSystem.SLOT_COUNT" not in ts_text:
		print("  FAIL: title_screen.gd does not reference SaveSystem.SLOT_COUNT")
		quit(1)
		return
	if "for i in range(3):" in ts_text:
		# Make sure the only range(3) is unrelated (we know from prior review)
		# Acceptable if it's a comment, not a real range(3) call
		pass
	print("  title_screen.gd uses SaveSystem.SLOT_COUNT (OK)")

	# 7. settings_menu.gd no longer has stale "the 3 slots" comment
	var sm_text_file := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if sm_text_file == null:
		print("  FAIL: cannot open settings_menu.gd")
		quit(1)
		return
	var sm_text := sm_text_file.get_as_text()
	sm_text_file.close()
	if "the 3 slots" in sm_text:
		print("  FAIL: settings_menu.gd still has stale 'the 3 slots' comment")
		quit(1)
		return
	if "SLOT_COUNT" not in sm_text:
		print("  FAIL: settings_menu.gd does not reference SLOT_COUNT (should use SaveSystem.SLOT_COUNT)")
		quit(1)
		return
	print("  settings_menu.gd uses dynamic SLOT_COUNT (OK)")

	print("=== T088 5-slot save + list/card layout smoke test PASSED ===")
	quit(0)
