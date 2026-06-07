extends SceneTree

## T105 — Smoke test for SaveLoadMenu 4-archive room progress timeline.
## Runs headless. Verifies that the wiring is in place:
##   1. SaveSystem exposes get_save_rooms_completed(slot_id) -> Array
##   2. SaveLoadMenu has ARCHIVE_ROOMS const with 4 archive ids
##   3. SaveLoadMenu has _make_progress_cell / _apply_progress / _format_progress_inline
##   4. _make_card_panel wires ProgressRow + 4 Cell_%d children
##   5. _make_list_row sets bbcode_enabled = true on TitleLbl
##   6. ARCHIVE_ROOMS order matches expected (01/02/03/04)
##   7. Color constants match STYLE_GUIDE Amber Voice / Ink Navy / Glass Cyan
##   8. get_save_rooms_completed gracefully returns [] for empty/invalid slot

func _initialize() -> void:
	print("=== T105 SaveLoadMenu 4-archive progress timeline smoke test ===")

	# 1. SaveSystem.get_save_rooms_completed exists + returns Array
	var ss_script := load("res://src/autoload/save_system.gd")
	if ss_script == null:
		print("  FAIL: cannot load save_system.gd")
		quit(1)
		return
	var ss_tmp: Node = ss_script.new()
	if not ss_tmp.has_method("get_save_rooms_completed"):
		print("  FAIL: SaveSystem missing get_save_rooms_completed method")
		ss_tmp.free()
		quit(1)
		return
	var empty_result: Array = ss_tmp.call("get_save_rooms_completed", 0)
	if typeof(empty_result) != TYPE_ARRAY:
		print("  FAIL: get_save_rooms_completed(0) should return Array, got %d" % typeof(empty_result))
		ss_tmp.free()
		quit(1)
		return
	ss_tmp.free()
	print("  SaveSystem.get_save_rooms_completed exists + returns Array (OK)")

	# 2. SaveLoadMenu.ARCHIVE_ROOMS const = 4 entries
	var slm_script := load("res://src/scripts/save_load_menu.gd")
	if slm_script == null:
		print("  FAIL: cannot load save_load_menu.gd")
		quit(1)
		return
	var archive_rooms: Array = slm_script.get("ARCHIVE_ROOMS")
	if typeof(archive_rooms) != TYPE_ARRAY or archive_rooms.size() != 4:
		print("  FAIL: SaveLoadMenu.ARCHIVE_ROOMS should be 4-entry Array, got %s" % str(archive_rooms))
		quit(1)
		return
	var expected_order := ["archive_01", "archive_02", "archive_03", "archive_04"]
	for i in range(4):
		if String(archive_rooms[i]) != expected_order[i]:
			print("  FAIL: ARCHIVE_ROOMS[%d] = %s, expected %s" % [i, archive_rooms[i], expected_order[i]])
			quit(1)
			return
	print("  SaveLoadMenu.ARCHIVE_ROOMS = [01,02,03,04] in order (OK)")

	# 3. SaveLoadMenu has 3 helper methods
	var slm_text_file := FileAccess.open("res://src/scripts/save_load_menu.gd", FileAccess.READ)
	if slm_text_file == null:
		print("  FAIL: cannot open save_load_menu.gd")
		quit(1)
		return
	var slm_text := slm_text_file.get_as_text()
	slm_text_file.close()
	for token in ["_make_progress_cell", "_apply_progress", "_format_progress_inline", "ProgressRow", "Cell_%d", "ARCHIVE_ROOMS", "_COLOR_PROGRESS_FILLED", "_COLOR_PROGRESS_EMPTY", "_COLOR_PROGRESS_BORDER"]:
		if token not in slm_text:
			print("  FAIL: save_load_menu.gd missing %s" % token)
			quit(1)
			return
	print("  save_load_menu.gd has _make_progress_cell / _apply_progress / _format_progress_inline (OK)")

	# 4. _make_list_row sets bbcode_enabled = true on TitleLbl
	if "left.bbcode_enabled = true" not in slm_text:
		print("  FAIL: _make_list_row does not enable bbcode on TitleLbl")
		quit(1)
		return
	print("  _make_list_row sets bbcode_enabled = true (OK)")

	# 5. _make_card_panel wires ProgressRow + 4 cells
	if 'progress_row.name = "ProgressRow"' not in slm_text:
		print("  FAIL: _make_card_panel does not name the row 'ProgressRow'")
		quit(1)
		return
	if "for i in range(ARCHIVE_ROOMS.size()):" not in slm_text:
		print("  FAIL: _make_card_panel does not iterate ARCHIVE_ROOMS for cells")
		quit(1)
		return
	print("  _make_card_panel wires ProgressRow + 4 cells (OK)")

	# 6. Color constants match STYLE_GUIDE (Amber Voice / Ink Navy / Glass Cyan)
	# Amber Voice = #F2B66E = (0.949, 0.714, 0.431)
	# Ink Navy    = #081426 = (0.031, 0.071, 0.118)
	# Glass Cyan  = #69C7CE = (0.412, 0.78, 0.808)
	var filled: Color = slm_script.get("_COLOR_PROGRESS_FILLED")
	var empty: Color = slm_script.get("_COLOR_PROGRESS_EMPTY")
	var border: Color = slm_script.get("_COLOR_PROGRESS_BORDER")
	if not _color_close(filled, Color(0.949, 0.714, 0.431, 1.0)):
		print("  FAIL: _COLOR_PROGRESS_FILLED = %s, expected Amber Voice" % str(filled))
		quit(1)
		return
	if not _color_close(empty, Color(0.031, 0.071, 0.118, 1.0)):
		print("  FAIL: _COLOR_PROGRESS_EMPTY = %s, expected Ink Navy" % str(empty))
		quit(1)
		return
	if not _color_close(border, Color(0.412, 0.78, 0.808, 0.7)):
		print("  FAIL: _COLOR_PROGRESS_BORDER = %s, expected Glass Cyan 0.7 alpha" % str(border))
		quit(1)
		return
	print("  _COLOR_PROGRESS_FILLED/EMPTY/BORDER match STYLE_GUIDE (OK)")

	# 7. Card panel height bumped to 56 to fit ProgressRow
	if 'Vector2(0, 56)  # T105' not in slm_text:
		print("  FAIL: _make_card_panel height not bumped to 56 (T105)")
		quit(1)
		return
	print("  _make_card_panel height bumped to 56 (OK)")

	# 8. _format_progress_inline produces 4 BBCode squares
	var slm_tmp: Node = slm_script.new()
	if not slm_tmp.has_method("_format_progress_inline"):
		print("  FAIL: SaveLoadMenu instance missing _format_progress_inline")
		slm_tmp.free()
		quit(1)
		return
	var inline_empty: String = slm_tmp.call("_format_progress_inline", [])
	var inline_two: String = slm_tmp.call("_format_progress_inline", ["archive_01", "archive_03"])
	slm_tmp.free()
	# Empty list → 4 archive_blue empty squares
	if inline_empty.count("[color=") != 4:
		print("  FAIL: _format_progress_inline([]) BBCode count = %d, expected 4" % inline_empty.count("[color="))
		quit(1)
		return
	# Two completed → expect 2 amber filled + 2 archive blue empty
	if inline_two.count("#F2B66E") != 2 or inline_two.count("#12334A") != 2:
		print("  FAIL: _format_progress_inline([01,03]) = '%s', expected 2 amber + 2 blue" % inline_two)
		quit(1)
		return
	print("  _format_progress_inline returns correct BBCode counts (OK)")

	print("=== T105 SaveLoadMenu 4-archive progress timeline smoke test PASSED ===")
	quit(0)

func _color_close(a: Color, b: Color) -> bool:
	return abs(a.r - b.r) < 0.01 and abs(a.g - b.g) < 0.01 and abs(a.b - b.b) < 0.01 and abs(a.a - b.a) < 0.05
