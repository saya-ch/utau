extends SceneTree

## T144 + T148 + T154 (#78) — wave_focus higher harmonic + wave_combo chime tail
## + save_lantern reverse-flash smoke test.
##
## T144 (Audio polish — 5min):
##   - `_wave_hit_streams` dict (4 entries: 0..3) instead of single stream
##   - `_generate_wave_hit_sfx(perk_level)` adds 1 high harmonic per
##     wave_focus purchase (0=base, 1=+3.6x, 2=+5.0x, 3=+6.8x)
##   - `play_wave_hit()` reads GameState.get_perk_count("wave_focus")
##     and dispatches to the right stream (O(1) dict lookup)
##
## T148 (Audio polish — 15min):
##   - `_generate_wave_combo_sfx()` — 0.6s E6+G#6 stacked-6th pair
##     with 0.5Hz LFO detune, decoupled from per-hit ping
##   - `play_wave_combo()` public method, lazy-cached
##   - `player.gd._on_wave_combo` calls it after ScreenShake.shake +
##     flash_color so the audio + visual + tactile feedback are
##     temporally aligned
##
## T154 (UX polish — 10min):
##   - `SaveLantern.flash_coral_pulse()` — tints sprite Coral Pulse
##     (#E86D5A) for 0.15s then reverts to white (Tween.TRANS_QUAD)
##   - `SilencedWeb.on_cut_triggered()` iterates the `save_lantern`
##     group and calls the flash on every lantern in the scene
##   - "Reverse" semantic: Coral Pulse is the inverse of Amber Voice
##     (the lantern's normal lit colour), so the player gets a clear
##     "alive" beat when they clear a corruption web

func _initialize() -> void:
	print("=== T144 + T148 + T154 (#78) — wave_focus harmonics + combo chime + lantern flash ===")

	var all_ok := true

	# === T144 — _wave_hit_streams dict + per-level harmonic synthesis ===
	var ame_script: Script = load("res://src/scripts/audio_manager_enhanced.gd")
	if ame_script == null:
		print("  FAIL: cannot load audio_manager_enhanced.gd")
		all_ok = false
	else:
		var ame_tmp: Node = ame_script.new()
		# 1. _wave_hit_streams is a dict (not the old single stream).
		var has_dict_field := false
		for p in ame_tmp.get_property_list():
			if p.name == "_wave_hit_streams":
				has_dict_field = true
		if not has_dict_field:
			print("  FAIL: AudioManagerEnhanced._wave_hit_streams dict field missing")
			all_ok = false
		else:
			print("  PASS: AudioManagerEnhanced._wave_hit_streams dict present (T144)")

		# 2. Old _wave_hit_stream single field is GONE.
		var has_old_field := false
		for p in ame_tmp.get_property_list():
			if p.name == "_wave_hit_stream":
				has_old_field = true
		if has_old_field:
			print("  FAIL: old _wave_hit_stream single field still present (T144 migration incomplete)")
			all_ok = false
		else:
			print("  PASS: old _wave_hit_stream single field removed (T144 migration clean)")

		# 3. _generate_wave_hit_sfx() accepts perk_level param.
		var has_param := false
		for m in ame_tmp.get_method_list():
			if m.name == "_generate_wave_hit_sfx" and m.args.size() == 1 \
					and m.args[0].name == "perk_level":
				has_param = true
		if not has_param:
			print("  FAIL: _generate_wave_hit_sfx() missing perk_level parameter")
			all_ok = false
		else:
			print("  PASS: _generate_wave_hit_sfx(perk_level) signature correct (T144)")

		# 4. All 4 levels synthesise a valid stream of the same size.
		#    Sample size is the same (0.20s * 44100Hz * 2 bytes = 17640 bytes);
		#    harmonic content differs but size is invariant.
		if has_param:
			var sizes_match := true
			var expected_size: int = int(0.20 * 44100) * 2
			for lv in range(4):
				var s: AudioStream = ame_tmp.call("_generate_wave_hit_sfx", lv)
				if s == null or not (s is AudioStreamWAV):
					print("  FAIL: _generate_wave_hit_sfx(%d) returned bad stream" % lv)
					all_ok = false
					sizes_match = false
					break
				var actual_size: int = (s as AudioStreamWAV).data.size()
				if abs(actual_size - expected_size) > 4:
					print("  FAIL: level %d size = %d (expected ~%d)" % [lv, actual_size, expected_size])
					all_ok = false
					sizes_match = false
					break
			if sizes_match:
				print("  PASS: _generate_wave_hit_sfx(0..3) all return 17640-byte streams (T144)")

		# 5. Level 3 (max perk) has MORE harmonic content than level 0
		#    in the source code (3.6x, 5.0x, 6.8x multipliers).
		var ame_file := FileAccess.open("res://src/scripts/audio_manager_enhanced.gd", FileAccess.READ)
		if ame_file == null:
			print("  FAIL: cannot open audio_manager_enhanced.gd")
			all_ok = false
		else:
			var ame_text: String = ame_file.get_as_text()
			ame_file.close()
			var has_36 := "* 3.6" in ame_text
			var has_50 := "* 5.0" in ame_text
			var has_68 := "* 6.8" in ame_text
			var has_match := "match safe_level:" in ame_text
			var has_clamp := "clampi(perk_level, 0, 3)" in ame_text
			if not has_36:
				print("  FAIL: 3.6x harmonic (level 1+) not present in source")
				all_ok = false
			else:
				print("  PASS: 3.6x harmonic present (T144 level 1+)")
			if not has_50:
				print("  FAIL: 5.0x harmonic (level 2+) not present in source")
				all_ok = false
			else:
				print("  PASS: 5.0x harmonic present (T144 level 2+)")
			if not has_68:
				print("  FAIL: 6.8x harmonic (level 3) not present in source")
				all_ok = false
			else:
				print("  PASS: 6.8x harmonic present (T144 level 3 = 'triumph')")
			if not has_match:
				print("  FAIL: 'match safe_level:' per-level dispatch not in source")
				all_ok = false
			else:
				print("  PASS: per-level match dispatch in _generate_wave_hit_sfx")
			if not has_clamp:
				print("  FAIL: perk_level clamping not present (unsafe input)")
				all_ok = false
			else:
				print("  PASS: perk_level clampi(0, 3) guards against bad input")

		# 6. play_wave_hit() reads GameState.get_perk_count("wave_focus")
		#    to determine the perk_level.
		var pw_file := FileAccess.open("res://src/scripts/audio_manager_enhanced.gd", FileAccess.READ)
		if pw_file == null:
			print("  FAIL: cannot re-open audio_manager_enhanced.gd")
			all_ok = false
		else:
			var pw_text: String = pw_file.get_as_text()
			pw_file.close()
			# Look inside play_wave_hit() block.
			var pw_idx: int = pw_text.find("func play_wave_hit(")
			if pw_idx < 0:
				print("  FAIL: play_wave_hit() not found")
				all_ok = false
			else:
				var pw_block := pw_text.substr(pw_idx, 1500)
				var has_wf_lookup := "get_perk_count(\"wave_focus\")" in pw_block
				var has_dict_lookup := "_wave_hit_streams.has(perk_level)" in pw_block
				var has_lazy_init := "_wave_hit_streams[perk_level] = _generate_wave_hit_sfx(perk_level)" in pw_block
				if not has_wf_lookup:
					print("  FAIL: play_wave_hit() does not read get_perk_count('wave_focus')")
					all_ok = false
				else:
					print("  PASS: play_wave_hit() reads wave_focus perk count (T144)")
				if not has_dict_lookup:
					print("  FAIL: play_wave_hit() does not dispatch via _wave_hit_streams dict")
					all_ok = false
				else:
					print("  PASS: play_wave_hit() dispatches via dict lookup (O(1))")
				if not has_lazy_init:
					print("  FAIL: play_wave_hit() does not lazy-init the level stream")
					all_ok = false
				else:
					print("  PASS: play_wave_hit() lazy-inits the level stream on first play")

		ame_tmp.free()

	# === T148 — _wave_combo_stream + play_wave_combo() + player call ===
	# 7. AudioManagerEnhanced has play_wave_combo() public method.
	if ame_script != null:
		var ame2: Node = ame_script.new()
		var has_pw_combo := ame2.has_method("play_wave_combo")
		if not has_pw_combo:
			print("  FAIL: AudioManagerEnhanced.play_wave_combo() missing")
			all_ok = false
		else:
			print("  PASS: AudioManagerEnhanced.play_wave_combo() present (T148)")

		# 8. _wave_combo_stream field declared.
		var has_combo_stream := false
		for p in ame2.get_property_list():
			if p.name == "_wave_combo_stream":
				has_combo_stream = true
		if not has_combo_stream:
			print("  FAIL: _wave_combo_stream field missing")
			all_ok = false
		else:
			print("  PASS: _wave_combo_stream cache field present (T148)")

		# 9. _generate_wave_combo_sfx() returns 0.6s stream (26460 bytes).
		if ame2.has_method("_generate_wave_combo_sfx"):
			var s: AudioStream = ame2.call("_generate_wave_combo_sfx")
			if s == null or not (s is AudioStreamWAV):
				print("  FAIL: _generate_wave_combo_sfx() returned bad stream")
				all_ok = false
			else:
				var actual_size: int = (s as AudioStreamWAV).data.size()
				var expected_size: int = int(0.60 * 44100) * 2
				if abs(actual_size - expected_size) > 4:
					print("  FAIL: _generate_wave_combo_sfx() size = %d (expected ~%d)" % [actual_size, expected_size])
					all_ok = false
				else:
					print("  PASS: _generate_wave_combo_sfx() returns 26460 bytes (0.6s @ 44.1kHz)")
		else:
			print("  FAIL: _generate_wave_combo_sfx() method missing")
			all_ok = false

		# 10. Source-grep: E6 + G#6 in _generate_wave_combo_sfx.
		var ame_file2 := FileAccess.open("res://src/scripts/audio_manager_enhanced.gd", FileAccess.READ)
		if ame_file2 != null:
			var ame_text2: String = ame_file2.get_as_text()
			ame_file2.close()
			var has_e6 := "1318.5" in ame_text2
			var has_gsharp6 := "1661.2" in ame_text2
			if not has_e6:
				print("  FAIL: E6 (1318.5Hz) not in _generate_wave_combo_sfx")
				all_ok = false
			else:
				print("  PASS: E6 (1318.5Hz) fundamental present in combo chime")
			if not has_gsharp6:
				print("  FAIL: G#6 (1661.2Hz) not in _generate_wave_combo_sfx")
				all_ok = false
			else:
				print("  PASS: G#6 (1661.2Hz) harmonic present in combo chime")

		# 11. Source-grep: player.gd._on_wave_combo calls play_wave_combo.
		var pl_file := FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
		if pl_file == null:
			print("  FAIL: cannot open player.gd")
			all_ok = false
		else:
			var pl_text: String = pl_file.get_as_text()
			pl_file.close()
			var oc_idx: int = pl_text.find("func _on_wave_combo(")
			if oc_idx < 0:
				print("  FAIL: _on_wave_combo() not found in player.gd")
				all_ok = false
			else:
				# 1500 chars covers the function + the new T148 call.
				var oc_block := pl_text.substr(oc_idx, 1500)
				var has_combo_call := "AudioManagerEnhanced.play_wave_combo()" in oc_block
				if not has_combo_call:
					print("  FAIL: _on_wave_combo() does not call play_wave_combo()")
					all_ok = false
				else:
					print("  PASS: _on_wave_combo() calls play_wave_combo() (T148)")

		ame2.free()

	# === T154 — SaveLantern.flash_coral_pulse + SilencedWeb iteration ===
	# 12. SaveLantern has flash_coral_pulse() method.
	var sl_script: Script = load("res://src/scripts/save_lantern.gd")
	if sl_script == null:
		print("  FAIL: cannot load save_lantern.gd")
		all_ok = false
	else:
		var sl_tmp: Node = sl_script.new()
		var has_flash := sl_tmp.has_method("flash_coral_pulse")
		if not has_flash:
			print("  FAIL: SaveLantern.flash_coral_pulse() missing")
			all_ok = false
		else:
			print("  PASS: SaveLantern.flash_coral_pulse() present (T154)")
		sl_tmp.free()

	# 13. Source-grep: flash_coral_pulse contains 0.15s tween + Coral color.
	var sl_file := FileAccess.open("res://src/scripts/save_lantern.gd", FileAccess.READ)
	if sl_file == null:
		print("  FAIL: cannot open save_lantern.gd")
		all_ok = false
	else:
		var sl_text: String = sl_file.get_as_text()
		sl_file.close()
		var has_15 := "0.15" in sl_text
		var has_coral := "0.91, 0.427, 0.353" in sl_text
		var has_tween := "tween_property" in sl_text
		var has_e86d5a := "#E86D5A" in sl_text or "E86D5A" in sl_text
		if not has_15:
			print("  FAIL: 0.15s flash duration not in save_lantern.gd")
			all_ok = false
		else:
			print("  PASS: 0.15s flash duration in flash_coral_pulse()")
		if not has_coral:
			print("  FAIL: Coral Pulse RGB (0.91, 0.427, 0.353) not in save_lantern.gd")
			all_ok = false
		else:
			print("  PASS: Coral Pulse color in flash_coral_pulse()")
		if not has_tween:
			print("  FAIL: tween_property not used for the flash revert")
			all_ok = false
		else:
			print("  PASS: tween_property used for 0.15s revert")
		if not has_e86d5a:
			print("  FAIL: #E86D5A (Coral Pulse hex) reference not in save_lantern.gd")
			all_ok = false
		else:
			print("  PASS: #E86D5A hex reference present in flash_coral_pulse()")

	# 14. SilencedWeb.on_cut_triggered() iterates save_lantern group.
	var sw_file := FileAccess.open("res://src/scripts/silenced_web.gd", FileAccess.READ)
	if sw_file == null:
		print("  FAIL: cannot open silenced_web.gd")
		all_ok = false
	else:
		var sw_text: String = sw_file.get_as_text()
		sw_file.close()
		var oc_idx2: int = sw_text.find("func on_cut_triggered(")
		if oc_idx2 < 0:
			print("  FAIL: on_cut_triggered() not found in silenced_web.gd")
			all_ok = false
		else:
			# 1800 chars covers the function + the new T154 iteration.
			var oc_block2: String = sw_text.substr(oc_idx2, 1800)
			var has_group_lookup := "get_nodes_in_group(\"save_lantern\")" in oc_block2
			var has_flash_call := "flash_coral_pulse()" in oc_block2
			var has_has_method := "has_method(\"flash_coral_pulse\")" in oc_block2
			if not has_group_lookup:
				print("  FAIL: on_cut_triggered() does not iterate save_lantern group")
				all_ok = false
			else:
				print("  PASS: on_cut_triggered() iterates save_lantern group (T154)")
			if not has_flash_call:
				print("  FAIL: on_cut_triggered() does not call flash_coral_pulse()")
				all_ok = false
			else:
				print("  PASS: on_cut_triggered() calls flash_coral_pulse() (T154)")
			if not has_has_method:
				print("  FAIL: on_cut_triggered() does not guard with has_method()")
				all_ok = false
			else:
				print("  PASS: on_cut_triggered() guards with has_method()")

	print("")
	if all_ok:
		print("ALL CHECKS PASSED.")
		quit(0)
	else:
		print("FAILURES DETECTED — see above.")
		quit(1)
