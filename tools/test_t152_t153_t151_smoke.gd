extends SceneTree

## T152 + T153 + T151 (#79) — Smoke test bundle.
##
## T152 — QuickStatsPanel / PlayerProfile 0 数灰阶占位
##   1. pause_menu.gd defines _COLOR_ZERO_STAT const
##   2. pause_menu.gd defines _set_zero_aware_stat() helper
##   3. _refresh_stats() uses _set_zero_aware_stat for 5 stats
##   4. _refresh_profile() uses _set_zero_aware_stat for 4 stats
##   5. Echo reflects still gets Glass Cyan color when > 0
##
## T153 — SaveLoadMenu slot jingle 区分
##   1. audio_manager_enhanced.gd defines _SAVE_SLOT_MIDI_NOTES
##   2. audio_manager_enhanced.gd defines _generate_save_slot_jingle
##   3. audio_manager_enhanced.gd defines play_save_slot_jingle
##   4. save_load_menu.gd calls play_save_slot_jingle in _on_overwrite
##   5. save_load_menu.gd calls play_save_slot_jingle in _on_load
##   6. save_load_menu.gd defines _has_audio_manager guard
##
## T151 — SaveLoadMenu "最近" 标识符
##   1. save_load_menu.gd defines _find_most_recent_slot
##   2. save_load_menu.gd defines _format_recent_badge
##   3. _refresh_slots() passes most_recent_slot to refreshers
##   4. _refresh_card() uses recent_badge in title
##   5. _refresh_list_row() uses recent_badge in title
##   6. pale_resonance #B7E6DC color used for recent_badge

func _initialize() -> void:
	print("=== T152+T153+T151 (#79) — QuickStats zero grey + slot jingle + recent badge ===")

	var all_ok := true

	var pause_text: String = _read_text("res://src/scripts/pause_menu.gd")
	var audio_text: String = _read_text("res://src/scripts/audio_manager_enhanced.gd")
	var save_text: String = _read_text("res://src/scripts/save_load_menu.gd")
	if pause_text.is_empty() or audio_text.is_empty() or save_text.is_empty():
		print("  FAIL: cannot read one of the source files")
		all_ok = false
		_finish(all_ok)
		return

	# ---------- T152 — QuickStatsPanel 0 数灰阶占位 ----------
	print("--- T152 ---")

	# 1. _COLOR_ZERO_STAT constant defined.
	if "const _COLOR_ZERO_STAT := Color(0.5, 0.5, 0.55, 1.0)" in pause_text:
		print("  PASS: pause_menu.gd defines _COLOR_ZERO_STAT")
	else:
		print("  FAIL: pause_menu.gd missing _COLOR_ZERO_STAT const")
		all_ok = false

	# 2. _set_zero_aware_stat helper defined.
	if "func _set_zero_aware_stat(lbl: Label, value: int, format_str: String) -> void:" in pause_text:
		print("  PASS: pause_menu.gd defines _set_zero_aware_stat() helper")
	else:
		print("  FAIL: pause_menu.gd missing _set_zero_aware_stat() helper")
		all_ok = false

	# 3. _refresh_stats uses _set_zero_aware_stat for 7 stat lines.
	var refresh_stats_idx: int = pause_text.find("func _refresh_stats() -> void:")
	if refresh_stats_idx < 0:
		print("  FAIL: cannot find _refresh_stats()")
		all_ok = false
	else:
		var body: String = pause_text.substr(refresh_stats_idx, 5000)
		# Count how many _set_zero_aware_stat calls appear in _refresh_stats body.
		# Should cover: stat_rooms, stat_enemies, stat_shards, stat_deaths,
		# stat_cuts, stat_lanterns (6 calls) — echo_reflects is special-cased.
		var call_count: int = 0
		var search_from: int = 0
		while true:
			var idx: int = body.find("_set_zero_aware_stat(", search_from)
			if idx < 0:
				break
			call_count += 1
			search_from = idx + 1
		if call_count >= 6:
			print("  PASS: _refresh_stats() calls _set_zero_aware_stat %d times (>= 6)" % call_count)
		else:
			print("  FAIL: _refresh_stats() only has %d _set_zero_aware_stat calls (need >= 6)" % call_count)
			all_ok = false

	# 4. _refresh_profile uses _set_zero_aware_stat for 4 stat lines.
	var refresh_profile_idx: int = pause_text.find("func _refresh_profile() -> void:")
	if refresh_profile_idx < 0:
		print("  FAIL: cannot find _refresh_profile()")
		all_ok = false
	else:
		var body: String = pause_text.substr(refresh_profile_idx, 8000)
		var call_count: int = 0
		var search_from: int = 0
		while true:
			var idx: int = body.find("_set_zero_aware_stat(", search_from)
			if idx < 0:
				break
			call_count += 1
			search_from = idx + 1
		# Should cover: profile_deaths, profile_rooms, profile_shards, profile_reflects (4 calls)
		if call_count >= 4:
			print("  PASS: _refresh_profile() calls _set_zero_aware_stat %d times (>= 4)" % call_count)
		else:
			print("  FAIL: _refresh_profile() only has %d _set_zero_aware_stat calls (need >= 4)" % call_count)
			all_ok = false

	# 5. Echo reflects special-case: >0 → Glass Cyan color, 0 → grey.
	if "if PlayerStats.echo_reflects > 0:" in pause_text and "Color(0.412, 0.78, 0.808, 1.0)" in pause_text:
		print("  PASS: Echo reflects keeps Glass Cyan when >0")
	else:
		print("  FAIL: Echo reflects Glass Cyan path broken")
		all_ok = false

	# ---------- T153 — save_slot jingle 区分 ----------
	print("--- T153 ---")

	# 1. _SAVE_SLOT_MIDI_NOTES constant defined.
	if "const _SAVE_SLOT_MIDI_NOTES := [72, 76, 79, 84, 88]" in audio_text:
		print("  PASS: audio_manager_enhanced.gd defines _SAVE_SLOT_MIDI_NOTES = [72,76,79,84,88]")
	else:
		print("  FAIL: audio_manager_enhanced.gd missing _SAVE_SLOT_MIDI_NOTES const")
		all_ok = false

	# 2. _save_slot_streams dict cache defined.
	if "var _save_slot_streams: Dictionary = {}" in audio_text:
		print("  PASS: audio_manager_enhanced.gd defines _save_slot_streams cache")
	else:
		print("  FAIL: audio_manager_enhanced.gd missing _save_slot_streams cache")
		all_ok = false

	# 3. _generate_save_slot_jingle() defined.
	if "func _generate_save_slot_jingle(slot_id: int) -> AudioStreamWAV:" in audio_text:
		print("  PASS: audio_manager_enhanced.gd defines _generate_save_slot_jingle()")
	else:
		print("  FAIL: audio_manager_enhanced.gd missing _generate_save_slot_jingle()")
		all_ok = false

	# 4. play_save_slot_jingle() public method defined.
	if "func play_save_slot_jingle(slot_id: int) -> void:" in audio_text:
		print("  PASS: audio_manager_enhanced.gd defines play_save_slot_jingle()")
	else:
		print("  FAIL: audio_manager_enhanced.gd missing play_save_slot_jingle()")
		all_ok = false

	# 5. save_load_menu.gd calls play_save_slot_jingle in _on_overwrite.
	var on_overwrite_idx: int = save_text.find("func _on_overwrite(slot_id: int) -> void:")
	if on_overwrite_idx < 0:
		print("  FAIL: cannot find _on_overwrite() in save_load_menu.gd")
		all_ok = false
	else:
		var body: String = save_text.substr(on_overwrite_idx, 600)
		if "play_save_slot_jingle" in body and "AudioManagerEnhanced" in body:
			print("  PASS: _on_overwrite() calls play_save_slot_jingle")
		else:
			print("  FAIL: _on_overwrite() missing play_save_slot_jingle call")
			all_ok = false

	# 6. save_load_menu.gd calls play_save_slot_jingle in _on_load.
	var on_load_idx: int = save_text.find("func _on_load(slot_id: int) -> void:")
	if on_load_idx < 0:
		print("  FAIL: cannot find _on_load() in save_load_menu.gd")
		all_ok = false
	else:
		var body: String = save_text.substr(on_load_idx, 600)
		if "play_save_slot_jingle" in body and "AudioManagerEnhanced" in body:
			print("  PASS: _on_load() calls play_save_slot_jingle")
		else:
			print("  FAIL: _on_load() missing play_save_slot_jingle call")
			all_ok = false

	# 7. _has_audio_manager guard defined.
	if "func _has_audio_manager() -> bool:" in save_text:
		print("  PASS: save_load_menu.gd defines _has_audio_manager() guard")
	else:
		print("  FAIL: save_load_menu.gd missing _has_audio_manager() guard")
		all_ok = false

	# ---------- T151 — SaveLoadMenu "最近" 标识符 ----------
	print("--- T151 ---")

	# 1. _find_most_recent_slot() defined.
	if "func _find_most_recent_slot() -> int:" in save_text:
		print("  PASS: save_load_menu.gd defines _find_most_recent_slot()")
	else:
		print("  FAIL: save_load_menu.gd missing _find_most_recent_slot()")
		all_ok = false

	# 2. _format_recent_badge() defined.
	if "func _format_recent_badge(slot_id: int, most_recent_slot: int) -> String:" in save_text:
		print("  PASS: save_load_menu.gd defines _format_recent_badge()")
	else:
		print("  FAIL: save_load_menu.gd missing _format_recent_badge()")
		all_ok = false

	# 3. _refresh_slots computes most_recent_slot and passes it down.
	var refresh_slots_idx: int = save_text.find("func _refresh_slots() -> void:")
	if refresh_slots_idx < 0:
		print("  FAIL: cannot find _refresh_slots() in save_load_menu.gd")
		all_ok = false
	else:
		var body: String = save_text.substr(refresh_slots_idx, 700)
		if "_find_most_recent_slot" in body and "most_recent_slot" in body:
			print("  PASS: _refresh_slots() computes and passes most_recent_slot")
		else:
			print("  FAIL: _refresh_slots() missing most_recent_slot plumbing")
			all_ok = false

	# 4. _refresh_card signature includes most_recent_slot.
	if "_refresh_card(panel: PanelContainer, i: int, most_recent_slot: int = -1) -> void:" in save_text:
		print("  PASS: _refresh_card() takes most_recent_slot parameter")
	else:
		print("  FAIL: _refresh_card() missing most_recent_slot parameter")
		all_ok = false

	# 5. _refresh_list_row signature includes most_recent_slot.
	if "_refresh_list_row(panel: PanelContainer, i: int, most_recent_slot: int = -1) -> void:" in save_text:
		print("  PASS: _refresh_list_row() takes most_recent_slot parameter")
	else:
		print("  FAIL: _refresh_list_row() missing most_recent_slot parameter")
		all_ok = false

	# 6. recent_badge uses Pale Resonance #B7E6DC color.
	if "[color=#B7E6DC]★ 最近[/color]" in save_text:
		print("  PASS: recent_badge uses Pale Resonance #B7E6DC")
	else:
		print("  FAIL: recent_badge missing Pale Resonance #B7E6DC")
		all_ok = false

	# 7. _format_recent_badge returns empty for non-matching slot (no badge spam).
	var fmt_recent_idx: int = save_text.find("func _format_recent_badge(slot_id: int, most_recent_slot: int) -> String:")
	if fmt_recent_idx < 0:
		all_ok = false
	else:
		var body: String = save_text.substr(fmt_recent_idx, 400)
		if 'return ""' in body:
			print("  PASS: _format_recent_badge returns empty string for non-matching slot")
		else:
			print("  FAIL: _format_recent_badge missing empty-string fallback")
			all_ok = false

	_finish(all_ok)

func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content

func _finish(ok: bool) -> void:
	if ok:
		print("\n=== ALL T152+T153+T151 (#79) ASSERTIONS PASSED ===")
		quit(0)
	else:
		print("\n=== T152+T153+T151 (#79) HAS FAILURES ===")
		quit(1)
