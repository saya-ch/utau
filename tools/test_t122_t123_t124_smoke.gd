extends SceneTree

## #64 — Smoke test for T122 (IntroCutscene ambient) + T123 (whisper_hollow routing).
## Verifies:
##   1. AudioManagerEnhanced exposes play_intro_ambience() method
##   2. AudioManagerEnhanced exposes _generate_intro_ambience() method
##   3. _generate_intro_ambience() returns a valid AudioStreamWAV
##   4. Generated stream has the right sample count (8s @ 22050Hz = 176400 samples)
##   5. Generated stream mix_rate is 22050 Hz
##   6. Generated stream data is not all-zero (D2 + G2 sine content present)
##   7. intro_cutscene.gd _play_sequence references play_intro_ambience
##   8. intro_cutscene.gd has the AudioManagerEnhanced lookup guard
##   9. GFC _play_music_for_state contains "whisper_hollow" routing
##  10. GFC Hub branch contains "rooms_completed.size() >= 2" threshold
##  11. GFC still routes archive_exploration for RoomController
##  12. GFC still routes title_intro for TITLE state
##  13. GameState has rooms_completed Dictionary (precondition for T123)
##  14. README.md contains "## BGM Palette" section header
##  15. README.zh-CN.md contains "## BGM 9 主题色板" section header

func _initialize() -> void:
	print("=== #64 T122 (IntroCutscene ambient) + T123 (whisper_hollow routing) smoke test ===")

	var ame_script := load("res://src/scripts/audio_manager_enhanced.gd")
	if ame_script == null:
		print("  FAIL: cannot load audio_manager_enhanced.gd")
		quit(1)
		return
	print("  audio_manager_enhanced.gd loaded OK")

	var ame_inst: Node = ame_script.new()
	root.add_child(ame_inst)
	var ame_methods := []
	for m in ame_inst.get_method_list():
		ame_methods.append(m.name)

	# 1. play_intro_ambience() method
	if not ("play_intro_ambience" in ame_methods):
		print("  FAIL: AudioManagerEnhanced instance missing 'play_intro_ambience' method")
		ame_inst.queue_free()
		quit(1)
		return
	print("  play_intro_ambience() method present (OK)")

	# 2. _generate_intro_ambience() method
	if not ("_generate_intro_ambience" in ame_methods):
		print("  FAIL: AudioManagerEnhanced instance missing '_generate_intro_ambience' method")
		ame_inst.queue_free()
		quit(1)
		return
	print("  _generate_intro_ambience() method present (OK)")

	# 3. _generate_intro_ambience() returns a valid AudioStreamWAV
	var intro_stream: AudioStreamWAV = ame_inst.call("_generate_intro_ambience")
	if intro_stream == null:
		print("  FAIL: _generate_intro_ambience() returned null")
		ame_inst.queue_free()
		quit(1)
		return
	print("  _generate_intro_ambience() returns AudioStreamWAV (OK)")

	# 4. Sample count check: 8s @ 22050Hz * 2 bytes/sample = 352800 bytes
	var data_size: int = intro_stream.data.size()
	var expected_size: int = 22050 * 8 * 2
	if data_size != expected_size:
		print("  FAIL: intro ambience data size = %d, expected %d" % [data_size, expected_size])
		ame_inst.queue_free()
		quit(1)
		return
	print("  data size = %d bytes (8s @ 22050Hz mono 16-bit, OK)" % data_size)

	# 5. mix_rate check
	if intro_stream.mix_rate != 22050:
		print("  FAIL: intro ambience mix_rate = %d, expected 22050" % intro_stream.mix_rate)
		ame_inst.queue_free()
		quit(1)
		return
	print("  mix_rate = 22050 Hz (OK)")

	# 6. Data is not all-zero (D2 + G2 sine + 2nd harmonic content)
	var non_zero_count: int = 0
	for i in range(0, data_size, 2):
		var lo: int = intro_stream.data[i] if i < data_size else 0
		var hi: int = intro_stream.data[i + 1] if i + 1 < data_size else 0
		var s16: int = (hi << 8) | lo
		if s16 != 0:
			non_zero_count += 1
	if non_zero_count < data_size / 4:  # at least 25% of samples should be non-zero
		print("  FAIL: intro ambience too sparse — only %d non-zero samples" % non_zero_count)
		ame_inst.queue_free()
		quit(1)
		return
	print("  non-zero sample count = %d (>= 25%% of %d, sine content present, OK)" % [non_zero_count, data_size / 2])

	# play_intro_ambience() is a one-shot fire-and-forget. In the real game
	# intro_cutscene.gd._play_sequence() invokes it AFTER the node is fully
	# in the scene tree (cutscene is a CanvasLayer added by the title
	# scene). In this SceneTree-based smoke harness the node exists but
	# is not "inside the tree" at _initialize() time, so calling
	# play_intro_ambience() here would log a benign
	# "Playback can only happen when a node is inside the scene tree"
	# warning. Skip the runtime invocation; the method existence +
	# _generate_intro_ambience() correctness checks above already cover
	# the contract — the intro cutscene integration is covered by
	# static source assertions #7 + #8 below.
	print("  play_intro_ambience() method present; runtime invocation skipped in smoke harness (OK)")
	ame_inst.queue_free()

	# 7. intro_cutscene.gd references play_intro_ambience
	var intro_script: GDScript = load("res://src/scripts/intro_cutscene.gd")
	if intro_script == null:
		print("  FAIL: cannot load intro_cutscene.gd")
		quit(1)
		return
	var intro_src: String = intro_script.source_code
	if "play_intro_ambience" not in intro_src:
		print("  FAIL: intro_cutscene.gd source does not reference play_intro_ambience")
		quit(1)
		return
	print("  intro_cutscene.gd references play_intro_ambience (OK)")

	# 8. intro_cutscene.gd has the AudioManagerEnhanced lookup guard
	if "AudioManagerEnhanced" not in intro_src or "get_node_or_null" not in intro_src:
		print("  FAIL: intro_cutscene.gd missing AudioManagerEnhanced lookup guard")
		quit(1)
		return
	print("  intro_cutscene.gd has AudioManagerEnhanced lookup guard (OK)")

	# 9. GFC _play_music_for_state contains whisper_hollow routing
	var gfc_script: GDScript = load("res://src/scripts/game_flow_controller.gd")
	if gfc_script == null:
		print("  FAIL: cannot load game_flow_controller.gd")
		quit(1)
		return
	var gfc_src: String = gfc_script.source_code
	if "whisper_hollow" not in gfc_src:
		print("  FAIL: GFC source does not reference whisper_hollow routing")
		quit(1)
		return
	print("  GFC references whisper_hollow routing (OK)")

	# 10. GFC Hub branch contains rooms_completed.size() >= 2 threshold
	if "rooms_completed.size() >= 2" not in gfc_src:
		print("  FAIL: GFC source missing 'rooms_completed.size() >= 2' threshold")
		quit(1)
		return
	print("  GFC Hub branch has rooms_completed.size() >= 2 threshold (OK)")

	# 11. GFC still routes archive_exploration for RoomController
	if "archive_exploration" not in gfc_src:
		print("  FAIL: GFC source missing archive_exploration routing (regression)")
		quit(1)
		return
	print("  GFC still routes archive_exploration (no regression, OK)")

	# 12. GFC still routes title_intro for TITLE state
	if "title_intro" not in gfc_src:
		print("  FAIL: GFC source missing title_intro routing (regression)")
		quit(1)
		return
	print("  GFC still routes title_intro for TITLE state (no regression, OK)")

	# 13. GameState has rooms_completed Dictionary (precondition)
	var gs_script: GDScript = load("res://src/autoload/game_state.gd")
	if gs_script == null:
		print("  FAIL: cannot load game_state.gd")
		quit(1)
		return
	var gs_src: String = gs_script.source_code
	if "var rooms_completed" not in gs_src:
		print("  FAIL: GameState missing 'var rooms_completed' field (T123 precondition)")
		quit(1)
		return
	print("  GameState has 'var rooms_completed' field (T123 precondition OK)")

	# 14. README.md contains BGM Palette section
	var readme_path := "res://README.md"
	if not FileAccess.file_exists(readme_path):
		print("  FAIL: README.md not found")
		quit(1)
		return
	var readme := FileAccess.open(readme_path, FileAccess.READ).get_as_text()
	if "## BGM Palette" not in readme:
		print("  FAIL: README.md missing '## BGM Palette' section header (T124)")
		quit(1)
		return
	print("  README.md contains '## BGM Palette' section (OK)")

	# 15. README.zh-CN.md contains BGM 9 主题色板 section
	var readme_zh_path := "res://README.zh-CN.md"
	if not FileAccess.file_exists(readme_zh_path):
		print("  FAIL: README.zh-CN.md not found")
		quit(1)
		return
	var readme_zh := FileAccess.open(readme_zh_path, FileAccess.READ).get_as_text()
	if "## BGM 9 主题色板" not in readme_zh:
		print("  FAIL: README.zh-CN.md missing '## BGM 9 主题色板' section header (T124)")
		quit(1)
		return
	print("  README.zh-CN.md contains '## BGM 9 主题色板' section (OK)")

	# Final tally
	print("=== T122+T123+T124 smoke test: ALL 15 ASSERTIONS PASSED ===")
	quit(0)
