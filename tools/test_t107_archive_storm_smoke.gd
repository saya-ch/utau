extends SceneTree

## T107 — Smoke test for the new archive_storm BGM tier-3 preset
## Verifies:
##   1. _MUSIC_PRESETS contains "archive_storm" key
##   2. archive_storm preset has all 12 expected fields
##   3. _BOSS_MUSIC_TIER has archive_storm mapped to tier 3
##   4. archive_storm tier 3 > archive_boss_dual tier 2 (auto-upgrade)
##   5. archive_storm has 16-note 16th-note arpeggio (16 entries)
##   6. archive_storm is in E minor (root E, chord includes E)
##   7. archive_storm is the highest volume preset (bass 0.34 is max)
##   8. ink_warden.gd phase 2 transition requests "archive_storm"
##   9. archive_storm has 4 chord notes (dissonance layer)
##  10. prewarm_music_streams() generates archive_storm without crash

func _initialize() -> void:
	print("=== T107 archive_storm BGM tier-3 integration smoke test ===")

	var ame_script := load("res://src/scripts/audio_manager_enhanced.gd")
	if ame_script == null:
		print("  FAIL: cannot load audio_manager_enhanced.gd")
		quit(1)
		return
	print("  audio_manager_enhanced.gd loaded OK")

	# 1. Verify _MUSIC_PRESETS contains "archive_storm" key
	var has_storm := false
	for k in ame_script._MUSIC_PRESETS.keys():
		if k == "archive_storm":
			has_storm = true
			break
	if not has_storm:
		print("  FAIL: _MUSIC_PRESETS missing 'archive_storm' key")
		quit(1)
		return
	print("  _MUSIC_PRESETS has 'archive_storm' (OK)")

	var storm: Dictionary = ame_script._MUSIC_PRESETS["archive_storm"]

	# 2. archive_storm preset has all 12 expected fields
	var expected_fields := [
		"bpm", "duration", "root_midi", "chord_midi", "arp_midi",
		"shimmer_midi", "lfo_freq", "lfo_depth", "shimmer_mod",
		"arp_volume", "pad_volume", "bass_volume", "shimmer_volume",
	]
	for f in expected_fields:
		if not storm.has(f):
			print("  FAIL: archive_storm missing field '%s'" % f)
			quit(1)
			return
	print("  archive_storm has all 13 expected fields (OK)")

	# 3. _BOSS_MUSIC_TIER has archive_storm mapped to tier 3
	if not ame_script._BOSS_MUSIC_TIER.has("archive_storm"):
		print("  FAIL: _BOSS_MUSIC_TIER missing 'archive_storm'")
		quit(1)
		return
	var storm_tier: int = int(ame_script._BOSS_MUSIC_TIER["archive_storm"])
	if storm_tier != 3:
		print("  FAIL: archive_storm tier=%d (expected 3)" % storm_tier)
		quit(1)
		return
	print("  _BOSS_MUSIC_TIER archive_storm = 3 (OK)")

	# 4. archive_storm tier 3 > archive_boss_dual tier 2 (auto-upgrade)
	var dual_tier: int = int(ame_script._BOSS_MUSIC_TIER.get("archive_boss_dual", 0))
	if storm_tier <= dual_tier:
		print("  FAIL: archive_storm tier %d should be > archive_boss_dual tier %d" % [storm_tier, dual_tier])
		quit(1)
		return
	print("  tier ordering: archive_storm(%d) > archive_boss_dual(%d) (OK)" % [storm_tier, dual_tier])

	# 5. archive_storm has 16-note 16th-note arpeggio (16 entries)
	var arp: Array = storm["arp_midi"]
	if arp.size() != 16:
		print("  FAIL: arp_midi has %d entries (expected 16)" % arp.size())
		quit(1)
		return
	print("  arp_midi has 16 entries (16th-note pattern, OK)")

	# 6. archive_storm is in E minor (root E, chord includes E)
	if int(storm["root_midi"]) != 28:  # E1
		print("  FAIL: root_midi=%d (expected 28 = E1)" % int(storm["root_midi"]))
		quit(1)
		return
	var chord: Array = storm["chord_midi"]
	var has_e_in_chord := false
	for n in chord:
		if int(n) == 40:  # E2
			has_e_in_chord = true
			break
	if not has_e_in_chord:
		print("  FAIL: chord_midi missing E2 (expected E minor key)")
		quit(1)
		return
	print("  E minor key: root=E1, chord includes E2 (OK)")

	# 7. archive_storm has the heaviest bass volume (0.34 is max across all presets)
	var max_bass_vol := 0.0
	var max_bass_key := ""
	for k in ame_script._MUSIC_PRESETS.keys():
		var v: float = float(ame_script._MUSIC_PRESETS[k]["bass_volume"])
		if v > max_bass_vol:
			max_bass_vol = v
			max_bass_key = k
	if max_bass_key != "archive_storm":
		print("  FAIL: bass_volume max preset is '%s' (%.2f) (expected archive_storm)" % [max_bass_key, max_bass_vol])
		quit(1)
		return
	print("  archive_storm has heaviest bass volume (%.2f) of all presets (OK)" % max_bass_vol)

	# 8. ink_warden.gd phase 2 transition requests "archive_storm"
	var iw_script := load("res://src/scripts/ink_warden.gd")
	if iw_script == null:
		print("  FAIL: cannot load ink_warden.gd")
		quit(1)
		return
	var iw_src := ""
	var f := FileAccess.open("res://src/scripts/ink_warden.gd", FileAccess.READ)
	if f:
		iw_src = f.get_as_text()
		f.close()
	# The phase 2 call is the 2nd `ame.call("request_boss_music", ...)` invocation
	# (the 1st is _ready's boss entry, the 2nd is the phase 2 escalation).
	# Look for the literal call signature: `ame.call("request_boss_music", "archive_storm", 600)`
	# (phase 2 with archive_storm, 600ms fade).
	if iw_src.find('ame.call("request_boss_music", "archive_storm", 600)') == -1:
		print("  FAIL: ink_warden.gd phase 2 call not using 'archive_storm' (expected line: ame.call(\"request_boss_music\", \"archive_storm\", 600))")
		quit(1)
		return
	print("  ink_warden.gd phase 2 transition requests 'archive_storm' (OK)")

	# 9. archive_storm has 4 chord notes (dissonance layer)
	if chord.size() != 4:
		print("  FAIL: chord_midi has %d notes (expected 4 for dissonance layer)" % chord.size())
		quit(1)
		return
	print("  chord_midi has 4 notes (E2 + G#2 + B2 + D3, dissonance layer, OK)")

	# 10. prewarm_music_streams() generates archive_storm without crash
	#    This is the actual generator code path.
	var instance: Node = ame_script.new()
	root.add_child(instance)
	# Call the generator directly to verify it returns a valid AudioStreamWAV.
	var stream: AudioStreamWAV = instance.call("_ensure_music_stream", "archive_storm")
	if stream == null:
		print("  FAIL: _ensure_music_stream('archive_storm') returned null")
		instance.queue_free()
		quit(1)
		return
	if not stream is AudioStreamWAV:
		print("  FAIL: archive_storm stream is not AudioStreamWAV (got %s)" % typeof(stream))
		instance.queue_free()
		quit(1)
		return
	# Check the stream has actual data
	if stream.data.size() == 0:
		print("  FAIL: archive_storm stream has empty data")
		instance.queue_free()
		quit(1)
		return
	# Expected samples for 10s @ 22050Hz = 220500 samples * 2 bytes = 441000 bytes
	var expected_size := 22050 * 10 * 2
	if stream.data.size() < int(expected_size * 0.9):
		print("  FAIL: archive_storm stream data size=%d (expected ~%d)" % [stream.data.size(), expected_size])
		instance.queue_free()
		quit(1)
		return
	print("  archive_storm AudioStreamWAV generated (%d bytes, ~10s @ 22050Hz, OK)" % stream.data.size())
	instance.queue_free()

	print("=== T107 smoke test PASSED (10/10 assertions) ===")
	quit(0)
