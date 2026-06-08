extends SceneTree

## T141 (#75) — Smoke test for the Wave 5-verb hit audio cue.
## Verifies the wave hit audio wiring:
##   1. AudioManagerEnhanced has a play_wave_hit() public method
##   2. The new _wave_hit_stream field is declared (lazy-initialised)
##   3. _generate_wave_hit_sfx() exists + returns a valid AudioStreamWAV
##   4. play_wave_hit() honours the 50ms throttle (consecutive calls
##      within the window are dropped after the first)
##   5. play_wave_hit() plays the SFX (stream.data is non-empty + the
##      50ms time delta updates the last-played timestamp)
##   6. resonance_wave_vfx.gd add_hit_flash() calls play_wave_hit() —
##      verified by source-grep (no autoload at parse time, so a
##      source-grep is the most robust check)
##   7. The 1320Hz fundamental + 2.4x harmonic synthesis is present
##      in _generate_wave_hit_sfx() (so the chime is recognisable
##      and not just a generic sine)

func _initialize() -> void:
	print("=== T141 (#75) — Wave 5-verb hit audio cue smoke test ===")

	var all_ok := true

	# 1-2. AudioManagerEnhanced has the new play_wave_hit() + stream field.
	var ame_script: Script = load("res://src/scripts/audio_manager_enhanced.gd")
	if ame_script == null:
		print("  FAIL: cannot load audio_manager_enhanced.gd")
		all_ok = false
	else:
		var ame_tmp: Node = ame_script.new()
		var has_play := ame_tmp.has_method("play_wave_hit")
		var has_stream_field := false
		for p in ame_tmp.get_property_list():
			if p.name == "_wave_hit_stream":
				has_stream_field = true
		ame_tmp.free()
		if not has_play:
			print("  FAIL: AudioManagerEnhanced.play_wave_hit() method missing")
			all_ok = false
		else:
			print("  PASS: AudioManagerEnhanced.play_wave_hit() present")
		if not has_stream_field:
			print("  FAIL: AudioManagerEnhanced._wave_hit_stream field missing")
			all_ok = false
		else:
			print("  PASS: AudioManagerEnhanced._wave_hit_stream field present")

	# 3. _generate_wave_hit_sfx() synthesises a valid stream.
	# We instantiate AudioManagerEnhanced and call the private method
	# directly (this is a smoke test, not a black-box test).
	# Note: we don't add it to the tree — the synthesis methods are
	# pure functions that only depend on Time/random state, neither
	# of which require being in the scene tree.
	if ame_script != null:
		var ame: Node = ame_script.new()
		if ame.has_method("_generate_wave_hit_sfx"):
			var stream: AudioStream = ame.call("_generate_wave_hit_sfx")
			if stream == null:
				print("  FAIL: _generate_wave_hit_sfx() returned null")
				all_ok = false
			elif not (stream is AudioStreamWAV):
				print("  FAIL: _generate_wave_hit_sfx() returned non-WAV stream")
				all_ok = false
			elif (stream as AudioStreamWAV).data.size() == 0:
				print("  FAIL: _generate_wave_hit_sfx() returned empty data")
				all_ok = false
			else:
				# Expected: 0.20s * 44100Hz * 2 bytes = 17640 bytes
				var expected_size := int(0.20 * 44100) * 2
				var actual_size: int = (stream as AudioStreamWAV).data.size()
				if abs(actual_size - expected_size) <= 4:
					print("  PASS: _generate_wave_hit_sfx() returned %d bytes (0.20s @ 44.1kHz)" % actual_size)
				else:
					print("  FAIL: _generate_wave_hit_sfx() size = %d (expected ~%d)" % [actual_size, expected_size])
					all_ok = false
		else:
			print("  FAIL: _generate_wave_hit_sfx() method missing")
			all_ok = false
		ame.free()

	# 4-5. Throttle + first-play behaviour.
	if ame_script != null:
		var ame2: Node = ame_script.new()
		# Reset state — we don't want the throttle to think it just played.
		ame2.set("_last_wave_hit_time_ms", -1)
		ame2.set("_wave_hit_stream", null)
		var last_before: int = int(ame2.get("_last_wave_hit_time_ms"))
		# First call: should play and update the timestamp.
		ame2.call("play_wave_hit")
		var last_after: int = int(ame2.get("_last_wave_hit_time_ms"))
		if last_after <= last_before:
			print("  FAIL: play_wave_hit() did not update _last_wave_hit_time_ms (before=%d, after=%d)" % [last_before, last_after])
			all_ok = false
		else:
			print("  PASS: play_wave_hit() updates _last_wave_hit_time_ms (%d -> %d)" % [last_before, last_after])
		# Now force a second call within the 50ms window.  We can't
		# reliably wait for real time in a smoke test, so we manually
		# rewind the timestamp by 10ms (less than 50ms) and verify
		# the throttle skips the play (timestamp stays unchanged).
		ame2.set("_last_wave_hit_time_ms", last_after - 10)
		var before_throttled: int = int(ame2.get("_last_wave_hit_time_ms"))
		ame2.call("play_wave_hit")
		var after_throttled: int = int(ame2.get("_last_wave_hit_time_ms"))
		# The throttle should NOT have updated the timestamp because
		# 10ms < 50ms throttle window.  Note: even if it did fire, the
		# timestamp would advance; we check it stayed the same.
		if after_throttled != before_throttled:
			print("  FAIL: play_wave_hit() did not honour 50ms throttle (ts changed: %d -> %d)" % [before_throttled, after_throttled])
			all_ok = false
		else:
			print("  PASS: play_wave_hit() honours 50ms throttle (ts unchanged)")
		# And: pushing the timestamp well past the window (200ms) lets
		# the next call through and updates the timestamp.
		ame2.set("_last_wave_hit_time_ms", int(ame2.get("_last_wave_hit_time_ms")) - 200)
		var before_open: int = int(ame2.get("_last_wave_hit_time_ms"))
		ame2.call("play_wave_hit")
		var after_open: int = int(ame2.get("_last_wave_hit_time_ms"))
		if after_open <= before_open:
			print("  FAIL: play_wave_hit() did not refresh ts after throttle window (before=%d, after=%d)" % [before_open, after_open])
			all_ok = false
		else:
			print("  PASS: play_wave_hit() refreshes ts after throttle window elapses")
		ame2.free()

	# 6. resonance_wave_vfx.gd add_hit_flash() calls play_wave_hit().
	var wv_file := FileAccess.open("res://src/scripts/resonance_wave_vfx.gd", FileAccess.READ)
	if wv_file == null:
		print("  FAIL: cannot open resonance_wave_vfx.gd")
		all_ok = false
	else:
		var wv_text: String = wv_file.get_as_text()
		wv_file.close()
		var has_call := "play_wave_hit()" in wv_text
		var in_add_hit := false
		var h_idx := wv_text.find("func add_hit_flash(")
		if h_idx >= 0:
			# 1500 chars covers the func header + comment + actual call.
			# (The T141 comment block + if-guarded call is ~12 lines.)
			var h_block := wv_text.substr(h_idx, 1500)
			in_add_hit = "play_wave_hit()" in h_block
		if not has_call:
			print("  FAIL: resonance_wave_vfx.gd does not call play_wave_hit()")
			all_ok = false
		elif not in_add_hit:
			print("  FAIL: play_wave_hit() call is not inside add_hit_flash()")
			all_ok = false
		else:
			print("  PASS: resonance_wave_vfx.gd add_hit_flash() calls play_wave_hit()")

	# 7. The 1320Hz fundamental + 2.4x harmonic synthesis is present.
	var ame_file := FileAccess.open("res://src/scripts/audio_manager_enhanced.gd", FileAccess.READ)
	if ame_file == null:
		print("  FAIL: cannot open audio_manager_enhanced.gd")
		all_ok = false
	else:
		var ame_text: String = ame_file.get_as_text()
		ame_file.close()
		var has_1320 := "1320.0" in ame_text
		var has_harmonic := "* 2.4" in ame_text
		if not has_1320:
			print("  FAIL: 1320Hz fundamental not present in _generate_wave_hit_sfx")
			all_ok = false
		else:
			print("  PASS: 1320Hz fundamental in _generate_wave_hit_sfx")
		if not has_harmonic:
			print("  FAIL: 2.4x harmonic not present in _generate_wave_hit_sfx")
			all_ok = false
		else:
			print("  PASS: 2.4x harmonic in _generate_wave_hit_sfx (chime timbre)")

	print("")
	if all_ok:
		print("ALL CHECKS PASSED.")
		quit(0)
	else:
		print("FAILURES DETECTED — see above.")
		quit(1)
