extends SceneTree

## F018.2 (#131) — Smoke test for the new `_get_autoload(name) -> Node`
## helper extracted from save_system.gd and now also living on
## game_state.gd + player_stats.gd.
##
## Verifies:
##   1. All 3 autoloads (save_system, game_state, player_stats) declare
##      a `_get_autoload(name: String) -> Node` method
##   2. _get_autoload returns null when the named autoload does NOT exist
##      (test-environment scenario: --script launch without autoloads)
##   3. _get_autoload returns the Node when the autoload IS present
##      (simulate by adding a fake autoload to /root and looking it up)
##   4. game_state.gd:take_damage() does NOT crash on SceneTree-mode
##      parse — the static `PlayerStats.record_death()` reference is gone
##      (replaced by _get_autoload dynamic lookup) so the script parses
##      cleanly under --script launch with no PlayerStats autoload
##   5. player_stats.gd:_read_longest_room_from_gamestate() still
##      returns 0.0 when GameState autoload is missing (no crash, no
##      "Identifier not found" parse error)
##   6. game_state.gd:reset_run() (which calls PlayerStats.reset_stats)
##      is now also F018.2-ified — no inline SceneTree pattern left
##
## F018.0 (#130) — preset scope 泄漏 (音频侧)
## F018.1 (#130) — game_state 静态引用 PlayerStats.reset_stats → dynamic
## F018.2 (#131) — 抽出 _get_autoload() 通用 helper, 应用到
##   * game_state.gd:reset_run() (8 行 SceneTree 块 → 1 行 helper)
##   * game_state.gd:take_damage() (静态 PlayerStats.record_death → dynamic)
##   * player_stats.gd:_read_longest_room_from_gamestate (复用同一 helper)

func _initialize() -> void:
	print("=== F018.2 autoload helper extraction smoke test ===")

	var pass_count := 0
	var fail_count := 0

	# 1. All 3 autoloads declare _get_autoload
	var targets := [
		"res://src/autoload/save_system.gd",
		"res://src/autoload/game_state.gd",
		"res://src/autoload/player_stats.gd",
	]
	for path in targets:
		var src := ""
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			src = f.get_as_text()
			f.close()
		if src.find("func _get_autoload(autoload_name: String)") != -1 \
				or src.find("func _get_autoload(name: String)") != -1:
			print("  %s declares _get_autoload() (OK)" % path)
			pass_count += 1
		else:
			print("  FAIL: %s missing _get_autoload() declaration" % path)
			fail_count += 1

	# 2. _get_autoload returns null when autoload missing
	#    Instantiate game_state as a one-off node (not added to root as
	#    autoload). Call _get_autoload on a name that does not exist.
	var gs_script := load("res://src/autoload/game_state.gd")
	if gs_script == null:
		print("  FAIL: cannot load game_state.gd")
		fail_count += 1
	else:
		var gs: Node = gs_script.new()
		var n: Node = gs.call("_get_autoload", "NonExistentAutoload_xyz_123")
		if n == null:
			print("  _get_autoload('NonExistent') returns null (OK)")
			pass_count += 1
		else:
			print("  FAIL: _get_autoload('NonExistent') should be null, got %s" % n)
			fail_count += 1
		gs.free()

	# 3. _get_autoload returns the Node when present
	#    Add a fake autoload-style node to /root, then look it up.
	var ps_script := load("res://src/autoload/player_stats.gd")
	if ps_script == null:
		print("  FAIL: cannot load player_stats.gd")
		fail_count += 1
	else:
		var ps: Node = ps_script.new()
		var fake: Node = Node.new()
		fake.name = "FakeAutoload_abc_456"
		root.add_child(fake)
		var found: Node = ps.call("_get_autoload", "FakeAutoload_abc_456")
		if found == fake:
			print("  _get_autoload('FakeAutoload') returns the right Node (OK)")
			pass_count += 1
		else:
			print("  FAIL: _get_autoload returned %s (expected the fake Node)" % found)
			fail_count += 1
		root.remove_child(fake)
		fake.free()
		ps.free()

	# 4. game_state.gd:take_damage() — script parses without
	#    "Identifier not found: PlayerStats" parse error.
	#    If the static `PlayerStats.record_death()` reference were still
	#    there, --script launch with no autoloads would fail to parse.
	#    We just re-load the script and check the source no longer
	#    contains the offending static call.
	#    (Check for the call with tab indent, NOT inside a # comment —
	#    the F018.2 marker comment legitimately mentions the old name.)
	var gs_src := ""
	var gsf := FileAccess.open("res://src/autoload/game_state.gd", FileAccess.READ)
	if gsf:
		gs_src = gsf.get_as_text()
		gsf.close()
	# Look for "\tPlayerStats.record_death(" — the real call site, with
	# tab indent. The F018.2 marker comment uses "# F018.2 ... PlayerStats.record_death()"
	# which starts with "# " (hash-space), not "\t" (tab).
	if gs_src.find("\tPlayerStats.record_death(") == -1:
		print("  game_state.gd no longer has static PlayerStats.record_death() call (OK)")
		pass_count += 1
	else:
		print("  FAIL: game_state.gd still has static PlayerStats.record_death() call — F018.2 not applied")
		fail_count += 1

	# 5. player_stats.gd:_read_longest_room_from_gamestate() returns 0.0
	#    when GameState autoload is missing (no crash).
	var ps2: Node = ps_script.new()
	var v: float = float(ps2.call("_read_longest_room_from_gamestate"))
	if v == 0.0:
		print("  _read_longest_room_from_gamestate returns 0.0 with no GameState autoload (OK)")
		pass_count += 1
	else:
		print("  FAIL: _read_longest_room_from_gamestate returned %f (expected 0.0)" % v)
		fail_count += 1
	ps2.free()

	# 6. game_state.gd:reset_run() no longer has the inline SceneTree block
	#    Look for the marker comment + 8-line nested block pattern.
	if gs_src.find("var _ml: MainLoop = Engine.get_main_loop()") == -1:
		print("  game_state.gd:reset_run() no longer has inline SceneTree block (OK)")
		pass_count += 1
	else:
		print("  FAIL: game_state.gd:reset_run() still has the inline SceneTree block — should use _get_autoload()")
		fail_count += 1

	print("")
	print("=== F018.2 smoke test %s (%d/%d assertions) ===" % [
		"FAILED" if fail_count > 0 else "PASSED",
		pass_count, pass_count + fail_count
	])
	if fail_count > 0:
		quit(1)
	else:
		quit(0)
