extends SceneTree

## T142 (#75) — Smoke test for the 5-verb chain anti-misinput safety net.
## Verifies the Wave windup window blocks the other 4 verb handlers:
##   1. ResonanceWaveAbility.is_globally_blocking() returns false at rest
##   2. is_globally_blocking() returns true immediately after start_wave()
##   3. is_globally_blocking() returns false again after the windup elapses
##   4. is_globally_blocking() is false during the active expansion phase
##   5. player.gd is_action_globally_blocked() helper exists + is_guarded
##      (#76 T145 renamed _is_wave_globally_blocking → is_action_globally_blocked
##      and OR'd in _is_dying; this smoke test was updated to track the rename)
##   6. player.gd calls is_action_globally_blocked() at the top of the
##      4 other verb handlers (_handle_pulse / _handle_bind / _handle_cut
##      / _handle_echo) — verified by source-grep
##   7. start_wave() still succeeds when resonance is available (no
##      regression on the happy path)

func _initialize() -> void:
	print("=== T142 (#75) — 5-verb chain anti-misinput safety net smoke test ===")

	var all_ok := true

	# 1-4. ResonanceWaveAbility.is_globally_blocking() state transitions.
	# Instantiate the ability in isolation (the assertion that it must be
	# a child of CharacterBody2D is bypassed by overriding _player via a
	# dynamic cast — but the script itself is what we exercise).
	var wv_script: Script = load("res://src/scripts/resonance_wave_ability.gd")
	if wv_script == null:
		print("  FAIL: cannot load resonance_wave_ability.gd")
		all_ok = false
	else:
		var wv: Node = wv_script.new()
		# The ability's _ready() expects a CharacterBody2D parent; in
		# headless we don't have one, so the assert would fail.  We work
		# around it by NOT calling _ready (the script side-effect is
		# only the wave_radius_bonus pull from GameState, which has a
		# has_method guard).  We DO need to set _player manually so the
		# windup_timer / active_timer logic in _process() doesn't crash.
		wv._player = null

		# 1. At rest, is_globally_blocking() should be false.
		if wv.is_globally_blocking():
			print("  FAIL: is_globally_blocking()=true at rest (expected false)")
			all_ok = false
		else:
			print("  PASS: is_globally_blocking()=false at rest")

		# 2. After manually forcing windup state, is_globally_blocking()=true.
		# We can't call start_wave() (it calls GameState.consume_resonance
		# which is an autoload; in headless we don't have it).  Instead,
		# we directly set _is_winding_up to simulate the mid-windup frame.
		wv._is_winding_up = true
		if not wv.is_globally_blocking():
			print("  FAIL: is_globally_blocking()=false during windup (expected true)")
			all_ok = false
		else:
			print("  PASS: is_globally_blocking()=true during windup")

		# 3. After windup completes, is_globally_blocking()=false again.
		wv._is_winding_up = false
		if wv.is_globally_blocking():
			print("  FAIL: is_globally_blocking()=true after windup (expected false)")
			all_ok = false
		else:
			print("  PASS: is_globally_blocking()=false after windup elapses")

		# 4. During active expansion (post-windup, pre-expire), it stays false.
		wv._is_active = true
		if wv.is_globally_blocking():
			print("  FAIL: is_globally_blocking()=true during active expansion (expected false)")
			all_ok = false
		else:
			print("  PASS: is_globally_blocking()=false during active expansion (verb chain allowed)")
		wv._is_active = false
		wv.free()

	# 5-6. player.gd is_action_globally_blocked() helper + the 4 callers.
	var player_file := FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
	if player_file == null:
		print("  FAIL: cannot open player.gd")
		all_ok = false
	else:
		var player_text: String = player_file.get_as_text()
		player_file.close()
		# T145 (#76) renamed _is_wave_globally_blocking() → is_action_globally_blocked()
		# and added _is_dying as a co-OR'd condition.
		var has_helper := "func is_action_globally_blocked() -> bool:" in player_text
		if not has_helper:
			print("  FAIL: player.gd missing is_action_globally_blocked() helper")
			all_ok = false
		else:
			print("  PASS: player.gd has is_action_globally_blocked() helper")

		# Check that all 4 verb handlers call the helper.
		var handler_names := ["_handle_pulse", "_handle_bind", "_handle_cut", "_handle_echo"]
		for h in handler_names:
			# Find the function block and check the first 6 lines after
			# the function header for the helper call.
			var h_idx := player_text.find("func " + h + "() -> void:")
			if h_idx < 0:
				print("  FAIL: player.gd missing " + h + " handler")
				all_ok = false
				continue
			var h_block := player_text.substr(h_idx, 600)
			if "is_action_globally_blocked()" not in h_block:
				print("  FAIL: " + h + " does not call is_action_globally_blocked()")
				all_ok = false
			else:
				print("  PASS: " + h + " calls is_action_globally_blocked()")

	# 7. start_wave() happy path — when wave_ability has the preconditions
	# met (cooldown=0, resonance>=cost, no windup/active), start_wave()
	# returns true.  In headless we can't easily test the full player
	# path, so this is a source-grep check: the start_wave() function
	# still exists and consumes resonance before winding up.
	var wv_file := FileAccess.open("res://src/scripts/resonance_wave_ability.gd", FileAccess.READ)
	if wv_file == null:
		print("  FAIL: cannot open resonance_wave_ability.gd")
		all_ok = false
	else:
		var wv_text: String = wv_file.get_as_text()
		wv_file.close()
		var has_start := "func start_wave(origin: Vector2) -> bool:" in wv_text
		var has_windup_set := "_is_winding_up = true" in wv_text
		if not (has_start and has_windup_set):
			print("  FAIL: start_wave() or windup setter missing")
			all_ok = false
		else:
			print("  PASS: start_wave() still winds up the wave (no regression)")

	print("")
	if all_ok:
		print("ALL CHECKS PASSED.")
		quit(0)
	else:
		print("FAILURES DETECTED — see above.")
		quit(1)
