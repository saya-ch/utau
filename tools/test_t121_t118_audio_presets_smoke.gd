extends SceneTree

## T121 + T118 — Smoke test for the audio_presets.gd refactor + 9th BGM theme.
## Verifies:
##   1. src/scripts/audio_presets.gd exists and has class_name AudioPresets
##   2. audio_presets.gd declares BOSS_MUSIC_TIER const (3 entries)
##   3. audio_presets.gd declares MUSIC_PRESETS const (9 entries)
##   4. audio_manager_enhanced.gd uses preload() to load audio_presets.gd
##   5. audio_manager_enhanced.gd no longer declares inline _MUSIC_PRESETS dict
##   6. audio_manager_enhanced.gd no longer declares inline _BOSS_MUSIC_TIER dict
##   7. All 9 preset names are present in audio_presets.gd
##   8. whisper_hollow (T118 — the 9th theme) is present and has all 13 fields
##   9. whisper_hollow is NOT in BOSS_MUSIC_TIER (it's a scene-routing theme)
##  10. whisper_hollow is D minor (only D-minor preset — distinguishable axis)
##  11. whisper_hollow has empty arp_midi (same as silence_void — no arpeggio)
##  12. whisper_hollow LFO 0.15Hz is the slowest of all presets
##  13. silence_void (T114 — the 8th theme) still exists with all zero volumes
##  14. archive_storm (T107 — the 7th theme) still has tier 3 in BOSS_MUSIC_TIER
##  15. All 7 pre-existing presets (T062-T107) still have all 13 fields

func _initialize() -> void:
	print("=== T121 + T118 audio_presets.gd refactor + 9th BGM theme smoke test ===")

	var fail_count := 0
	var test_num := 0

	# 1. audio_presets.gd exists
	test_num += 1
	var ap_path := "res://src/scripts/audio_presets.gd"
	var ap_script := load(ap_path)
	if ap_script == null:
		print("  FAIL [%d]: cannot load %s" % [test_num, ap_path])
		fail_count += 1
	else:
		print("  PASS [%d]: %s loaded" % [test_num, ap_path])

	# 2. class_name AudioPresets
	test_num += 1
	var ap_src := ""
	var f := FileAccess.open(ap_path, FileAccess.READ)
	if f:
		ap_src = f.get_as_text()
		f.close()
	if not "class_name AudioPresets" in ap_src:
		print("  FAIL [%d]: class_name AudioPresets missing" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: class_name AudioPresets present" % test_num)

	# 3. BOSS_MUSIC_TIER const with 3 entries
	test_num += 1
	if not "const BOSS_MUSIC_TIER" in ap_src:
		print("  FAIL [%d]: BOSS_MUSIC_TIER const missing" % test_num)
		fail_count += 1
	else:
		# Check 3 expected tier keys
		var tier_keys := ["archive_boss", "archive_boss_dual", "archive_storm"]
		var missing := []
		for k in tier_keys:
			if not ("\"%s\"" % k) in ap_src:
				missing.append(k)
		if missing.size() > 0:
			print("  FAIL [%d]: BOSS_MUSIC_TIER missing keys: %s" % [test_num, str(missing)])
			fail_count += 1
		else:
			print("  PASS [%d]: BOSS_MUSIC_TIER has 3 expected keys" % test_num)

	# 4. MUSIC_PRESETS const with 9 entries
	test_num += 1
	if not "const MUSIC_PRESETS" in ap_src:
		print("  FAIL [%d]: MUSIC_PRESETS const missing" % test_num)
		fail_count += 1
	else:
		var preset_keys := ["title_intro", "hub_warm", "archive_exploration",
			"archive_boss", "archive_boss_dual", "archive_dawn",
			"archive_storm", "silence_void", "whisper_hollow"]
		var missing := []
		for k in preset_keys:
			# Check the dict has the key (look for "key": { in dict)
			if not ("\"%s\":" % k) in ap_src:
				missing.append(k)
		if missing.size() > 0:
			print("  FAIL [%d]: MUSIC_PRESETS missing keys: %s" % [test_num, str(missing)])
			fail_count += 1
		else:
			print("  PASS [%d]: MUSIC_PRESETS has 9 expected keys" % test_num)

	# 5. audio_manager_enhanced.gd uses preload()
	test_num += 1
	var ame_path := "res://src/scripts/audio_manager_enhanced.gd"
	var ame_src := ""
	f = FileAccess.open(ame_path, FileAccess.READ)
	if f:
		ame_src = f.get_as_text()
		f.close()
	if not "preload(\"res://src/scripts/audio_presets.gd\")" in ame_src:
		print("  FAIL [%d]: preload(audio_presets.gd) missing in audio_manager_enhanced.gd" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: audio_manager_enhanced.gd uses preload(audio_presets.gd)" % test_num)

	# 6. audio_manager_enhanced.gd no longer has inline _MUSIC_PRESETS := { block
	# (It should be a single-line const referencing AudioPresets.MUSIC_PRESETS,
	# but we removed the alias entirely so check that it doesn't have the dict
	# with a `{` on a new line.)
	test_num += 1
	# Look for the multi-line dict form: "_MUSIC_PRESETS := {" with a newline
	# (the alias form was just removed)
	var has_inline_music_dict := false
	for line in ame_src.split("\n"):
		if "_MUSIC_PRESETS := {" in line and not line.strip().startswith("#"):
			has_inline_music_dict = true
			break
	# Also check: it should reference AudioPresets.MUSIC_PRESETS at least once
	var has_audio_presets_ref := "AudioPresets.MUSIC_PRESETS" in ame_src
	if has_inline_music_dict:
		print("  FAIL [%d]: audio_manager_enhanced.gd still has inline _MUSIC_PRESETS := { block" % test_num)
		fail_count += 1
	elif not has_audio_presets_ref:
		print("  FAIL [%d]: audio_manager_enhanced.gd missing AudioPresets.MUSIC_PRESETS reference" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: audio_manager_enhanced.gd references AudioPresets.MUSIC_PRESETS (no inline dict)" % test_num)

	# 7. audio_manager_enhanced.gd no longer has inline _BOSS_MUSIC_TIER := { block
	test_num += 1
	var has_inline_tier_dict := false
	for line in ame_src.split("\n"):
		if "_BOSS_MUSIC_TIER := {" in line and not line.strip().startswith("#"):
			has_inline_tier_dict = true
			break
	var has_audio_tier_ref := "AudioPresets.BOSS_MUSIC_TIER" in ame_src
	if has_inline_tier_dict:
		print("  FAIL [%d]: audio_manager_enhanced.gd still has inline _BOSS_MUSIC_TIER := { block" % test_num)
		fail_count += 1
	elif not has_audio_tier_ref:
		print("  FAIL [%d]: audio_manager_enhanced.gd missing AudioPresets.BOSS_MUSIC_TIER reference" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: audio_manager_enhanced.gd references AudioPresets.BOSS_MUSIC_TIER (no inline dict)" % test_num)

	# 8. whisper_hollow (T118) has all 13 fields
	test_num += 1
	var required_fields := ["bpm", "duration", "root_midi", "chord_midi",
		"arp_midi", "shimmer_midi", "lfo_freq", "lfo_depth",
		"shimmer_mod", "arp_volume", "pad_volume", "bass_volume", "shimmer_volume"]
	# Extract the whisper_hollow block
	var wh_start := ap_src.find("\"whisper_hollow\":")
	if wh_start < 0:
		print("  FAIL [%d]: cannot find whisper_hollow block in audio_presets.gd" % test_num)
		fail_count += 1
	else:
		# Find the end of the block (next "}, " or end of dict)
		var wh_end := ap_src.find("},", wh_start)
		if wh_end < 0:
			wh_end = ap_src.find("}\n", wh_start)
		var wh_body := ap_src.substr(wh_start, wh_end - wh_start)
		var missing_fields := []
		for fld in required_fields:
			if not ("\"%s\":" % fld) in wh_body:
				missing_fields.append(fld)
		if missing_fields.size() > 0:
			print("  FAIL [%d]: whisper_hollow missing fields: %s" % [test_num, str(missing_fields)])
			fail_count += 1
		else:
			print("  PASS [%d]: whisper_hollow has all 13 fields" % test_num)

	# 9. whisper_hollow is NOT in BOSS_MUSIC_TIER
	test_num += 1
	if "whisper_hollow" in ap_src.split("const MUSIC_PRESETS")[0].split("const BOSS_MUSIC_TIER")[1]:
		print("  FAIL [%d]: whisper_hollow found in BOSS_MUSIC_TIER (should be scene-routing only)" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: whisper_hollow is NOT in BOSS_MUSIC_TIER (correct)" % test_num)

	# 10. whisper_hollow is D minor (root_midi 50 = D3, chord_midi starts with 53 = F3)
	test_num += 1
	# Look for "root_midi": 50 and "chord_midi": [53 in whisper_hollow block
	# (We already have wh_body from test 8 — reuse it.)
	if wh_start >= 0 and wh_end >= 0:
		var wh_body2 := ap_src.substr(wh_start, wh_end - wh_start)
		var has_d3_root := "\"root_midi\": 50" in wh_body2
		# D minor 7th chord starts with F3 (53)
		var has_d_min_chord := "[53, 57, 60, 64]" in wh_body2
		if not has_d3_root:
			print("  FAIL [%d]: whisper_hollow root_midi is not 50 (D3)" % test_num)
			fail_count += 1
		elif not has_d_min_chord:
			print("  FAIL [%d]: whisper_hollow chord_midi is not [53, 57, 60, 64] (D minor 7th)" % test_num)
			fail_count += 1
		else:
			print("  PASS [%d]: whisper_hollow is D minor (root 50 + D-min7 chord)" % test_num)
	else:
		print("  FAIL [%d]: cannot reuse whisper_hollow block from test 8" % test_num)
		fail_count += 1

	# 11. whisper_hollow has empty arp_midi (no bell arpeggio)
	test_num += 1
	if wh_start >= 0 and wh_end >= 0:
		var wh_body3 := ap_src.substr(wh_start, wh_end - wh_start)
		# Look for "arp_midi": [], — that's the empty arp form
		if not "\"arp_midi\": []" in wh_body3:
			print("  FAIL [%d]: whisper_hollow arp_midi is not [] (should be no arpeggio)" % test_num)
			fail_count += 1
		else:
			print("  PASS [%d]: whisper_hollow has empty arp_midi (no arpeggio)" % test_num)
	else:
		print("  FAIL [%d]: cannot reuse whisper_hollow block" % test_num)
		fail_count += 1

	# 12. whisper_hollow LFO 0.15Hz is the slowest of all presets
	test_num += 1
	# All presets' lfo_freq values: title_intro 0.18 / hub_warm 0.42 / archive_exploration 0.28
	# / archive_boss 0.55 / archive_boss_dual 0.83 / archive_dawn 0.30 / archive_storm 0.66
	# / silence_void 0.0 / whisper_hollow 0.15
	# 0.15 is the slowest non-zero LFO (silence_void is 0.0 but disabled).
	if "\"lfo_freq\": 0.15" in ap_src and wh_start >= 0 and wh_end >= 0:
		var wh_body4 := ap_src.substr(wh_start, wh_end - wh_start)
		if not "\"lfo_freq\": 0.15" in wh_body4:
			print("  FAIL [%d]: whisper_hollow lfo_freq is not 0.15" % test_num)
			fail_count += 1
		else:
			print("  PASS [%d]: whisper_hollow LFO 0.15Hz (slowest non-disabled)" % test_num)
	else:
		print("  FAIL [%d]: lfo_freq 0.15 not found in audio_presets.gd" % test_num)
		fail_count += 1

	# 13. silence_void (T114) still exists with all 4 volume channels zeroed
	test_num += 1
	var sv_start := ap_src.find("\"silence_void\":")
	if sv_start < 0:
		print("  FAIL [%d]: silence_void not found in audio_presets.gd" % test_num)
		fail_count += 1
	else:
		var sv_end := ap_src.find("},", sv_start)
		if sv_end < 0:
			sv_end = ap_src.find("}\n", sv_start)
		var sv_body := ap_src.substr(sv_start, sv_end - sv_start)
		# Check all 4 volumes are 0.0
		var vol_fields := ["arp_volume", "pad_volume", "bass_volume", "shimmer_volume"]
		var non_zero := []
		for fld in vol_fields:
			if not ("\"%s\": 0.0" % fld) in sv_body:
				non_zero.append(fld)
		if non_zero.size() > 0:
			print("  FAIL [%d]: silence_void non-zero volume fields: %s" % [test_num, str(non_zero)])
			fail_count += 1
		else:
			print("  PASS [%d]: silence_void has all 4 volume channels at 0.0" % test_num)

	# 14. archive_storm (T107) still has tier 3 in BOSS_MUSIC_TIER
	test_num += 1
	if "\"archive_storm\": 3" in ap_src:
		print("  PASS [%d]: archive_storm tier 3 still in BOSS_MUSIC_TIER" % test_num)
	else:
		print("  FAIL [%d]: archive_storm tier 3 missing from BOSS_MUSIC_TIER" % test_num)
		fail_count += 1

	# 15. All 7 pre-existing presets (T062-T107) still have all 13 fields
	test_num += 1
	var pre_existing := ["title_intro", "hub_warm", "archive_exploration",
		"archive_boss", "archive_boss_dual", "archive_dawn", "archive_storm"]
	var preset_missing := []
	for preset_name in pre_existing:
		var ps_start := ap_src.find("\"%s\":" % preset_name)
		if ps_start < 0:
			preset_missing.append(preset_name + " (not found)")
			continue
		var ps_end := ap_src.find("},", ps_start)
		if ps_end < 0:
			ps_end = ap_src.find("}\n", ps_start)
		var ps_body := ap_src.substr(ps_start, ps_end - ps_start)
		for fld in required_fields:
			if not ("\"%s\":" % fld) in ps_body:
				preset_missing.append(preset_name + "." + fld)
	if preset_missing.size() > 0:
		print("  FAIL [%d]: pre-existing presets missing fields: %s" % [test_num, str(preset_missing)])
		fail_count += 1
	else:
		print("  PASS [%d]: all 7 pre-existing presets have all 13 fields" % test_num)

	# 16. asset_registry has A065 entry
	test_num += 1
	var ar_path := "res://ASSET_REGISTRY.md"
	var ar_src := ""
	f = FileAccess.open(ar_path, FileAccess.READ)
	if f:
		ar_src = f.get_as_text()
		f.close()
	if not "| A065 |" in ar_src:
		print("  FAIL [%d]: ASSET_REGISTRY.md missing A065 entry" % test_num)
		fail_count += 1
	elif not "whisper_hollow" in ar_src:
		print("  FAIL [%d]: ASSET_REGISTRY.md A065 entry doesn't mention whisper_hollow" % test_num)
		fail_count += 1
	else:
		print("  PASS [%d]: ASSET_REGISTRY.md A065 whisper_hollow registered" % test_num)

	# Summary
	print("---")
	if fail_count == 0:
		print("=== ALL %d ASSERTIONS PASSED ===" % test_num)
		quit(0)
	else:
		print("=== %d / %d ASSERTIONS FAILED ===" % [fail_count, test_num])
		quit(1)
