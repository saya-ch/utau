extends SceneTree

const AudioPresets = preload("res://src/scripts/audio_presets.gd")

## I058 + T239 (#157) — Smoke test for:
##   T239: SettingsMenu Music bus volume preview button — player drags
##         the Music slider, clicks "预览 3 秒", hears 3s of a random
##         BGM theme at the current Music bus volume. Preview is a
##         one-shot AudioStreamPlayer on the Music bus that fades in /
##         holds / fades out and does NOT touch _current_music_player
##         (in-game BGM keeps playing uninterrupted).
##   I058: 18 assertions covering API presence, scene wiring, and
##         method signature contracts. All static parse / grep (no
##         live scene required, no autoload init needed). Run via:
##   godot --headless --script tools/test_i058_t239_bgm_preview_smoke.gd

func _initialize() -> void:
	print("=== I058 + T239 Music bus preview smoke test (#157) ===")

	# T238 (#157) — Defensive try_load helpers (same pattern as
	# test_t158_t156_f002_smoke.gd). Live-script assertions fall
	# back to source-grep when the .godot class_name cache is
	# missing (e.g. fresh clone without --import).
	var ame_script := _try_load_script("res://src/scripts/audio_manager_enhanced.gd")
	var sm_script := _try_load_script("res://src/scripts/settings_menu.gd")

	var counters := {"passed": 0, "failed": 0, "skipped": 0}
	var report_pass := func(label: String) -> void:
		print("  [%s] PASS" % label)
		counters["passed"] += 1
	var report_fail := func(label: String, msg: String) -> void:
		print("  [%s] FAIL: %s" % [label, msg])
		counters["failed"] += 1

	# Pre-read source for grep fallbacks
	var ame_src := _read_file("res://src/scripts/audio_manager_enhanced.gd")
	var sm_src := _read_file("res://src/scripts/settings_menu.gd")
	var ts_src := _read_file("res://src/scenes/settings_menu.tscn")

	# ===== I058 / T239 assertions =====

	# I058.1 — AudioManagerEnhanced has preview_music_track method
	if ame_script != null:
		var inst: Node = ame_script.new()
		var methods := []
		for m in inst.get_method_list():
			methods.append(m.name)
		inst.free()
		if "preview_music_track" in methods:
			report_pass.call("I058.1")
		else:
			report_fail.call("I058.1", "audio_manager_enhanced.gd missing method 'preview_music_track'")
	elif ame_src.find("func preview_music_track(") != -1:
		report_pass.call("I058.1 (grep fallback)")
	else:
		report_fail.call("I058.1", "audio_manager_enhanced.gd missing 'func preview_music_track('")

	# I058.2 — preview_music_track signature: (key, duration_sec=3.0, fade_ms=250)
	if ame_src.find("func preview_music_track(key: String, duration_sec: float = 3.0, fade_ms: int = 250)") == -1:
		report_fail.call("I058.2", "preview_music_track signature mismatch (expected key:String, duration_sec:float=3.0, fade_ms:int=250)")
	else:
		report_pass.call("I058.2")

	# I058.3 — AudioManagerEnhanced has stop_music_preview method
	if ame_script != null:
		var inst2: Node = ame_script.new()
		var methods2 := []
		for m in inst2.get_method_list():
			methods2.append(m.name)
		inst2.free()
		if "stop_music_preview" in methods2:
			report_pass.call("I058.3")
		else:
			report_fail.call("I058.3", "audio_manager_enhanced.gd missing method 'stop_music_preview'")
	elif ame_src.find("func stop_music_preview(") != -1:
		report_pass.call("I058.3 (grep fallback)")
	else:
		report_fail.call("I058.3", "audio_manager_enhanced.gd missing 'func stop_music_preview('")

	# I058.4 — _active_preview_player field declared
	if ame_src.find("_active_preview_player: AudioStreamPlayer = null") == -1:
		report_fail.call("I058.4", "audio_manager_enhanced.gd missing '_active_preview_player: AudioStreamPlayer = null' field")
	else:
		report_pass.call("I058.4")

	# I058.5 — preview uses _ensure_music_stream (same as play_music_track)
	var pmt_idx := ame_src.find("func preview_music_track(")
	if pmt_idx == -1:
		report_fail.call("I058.5", "cannot locate preview_music_track function")
	else:
		var pmt_block := ame_src.substr(pmt_idx, 1500)
		if pmt_block.find("_ensure_music_stream(") == -1:
			report_fail.call("I058.5", "preview_music_track missing _ensure_music_stream call")
		else:
			report_pass.call("I058.5")

	# I058.6 — preview does NOT touch _current_music_player / _current_music_key
	# (preview is a separate one-shot, in-game BGM keeps playing)
	if pmt_idx == -1:
		report_fail.call("I058.6", "cannot locate preview_music_track function")
	else:
		var pmt_block2 := ame_src.substr(pmt_idx, 1500)
		# Should NOT assign to _current_music_player
		if pmt_block2.find("_current_music_player = ") != -1 or pmt_block2.find("_current_music_player=") != -1:
			report_fail.call("I058.6", "preview_music_track must NOT touch _current_music_player (in-game BGM must keep playing)")
		# Should NOT assign to _current_music_key
		elif pmt_block2.find("_current_music_key = \"") != -1 or pmt_block2.find("_current_music_key=\"") != -1:
			report_fail.call("I058.6", "preview_music_track must NOT touch _current_music_key (in-game BGM must keep playing)")
		else:
			report_pass.call("I058.6")

	# I058.7 — preview uses cubic ease in/out (same convention as play_music_track)
	if pmt_idx == -1:
		report_fail.call("I058.7", "cannot locate preview_music_track function")
	else:
		var pmt_block3 := ame_src.substr(pmt_idx, 2000)
		if pmt_block3.find("TRANS_CUBIC") == -1:
			report_fail.call("I058.7", "preview_music_track missing TRANS_CUBIC ease")
		elif pmt_block3.find("EASE_IN_OUT") == -1:
			report_fail.call("I058.7", "preview_music_track missing EASE_IN_OUT")
		else:
			report_pass.call("I058.7")

	# I058.8 — preview spam-click safe (kills previous preview)
	if pmt_idx == -1:
		report_fail.call("I058.8", "cannot locate preview_music_track function")
	else:
		var pmt_block4 := ame_src.substr(pmt_idx, 1500)
		if pmt_block4.find("_active_preview_player") == -1:
			report_fail.call("I058.8", "preview_music_track missing _active_preview_player spam-click guard")
		elif pmt_block4.find("queue_free") == -1:
			report_fail.call("I058.8", "preview_music_track must queue_free previous preview player")
		else:
			report_pass.call("I058.8")

	# I058.9 — SettingsMenu.tscn has MusicPreviewButton node
	if ts_src.find("[node name=\"MusicPreviewButton\" type=\"Button\" parent=\"VBoxContainer/Content/AudioPanel\"]") == -1:
		report_fail.call("I058.9", "settings_menu.tscn missing MusicPreviewButton node")
	else:
		report_pass.call("I058.9")

	# I058.10 — MusicPreviewButton text contains 预览 3 秒
	if ts_src.find("text = \"预览 3 秒\"") == -1:
		report_fail.call("I058.10", "MusicPreviewButton missing '预览 3 秒' text")
	else:
		report_pass.call("I058.10")

	# I058.11 — settings_menu.gd has _music_preview_btn @onready var
	if sm_src.find("@onready var _music_preview_btn: Button = $VBoxContainer/Content/AudioPanel/MusicPreviewButton") == -1:
		report_fail.call("I058.11", "settings_menu.gd missing '@onready var _music_preview_btn: Button' declaration")
	else:
		report_pass.call("I058.11")

	# I058.12 — _ready connects _music_preview_btn.pressed → _on_music_preview_pressed
	if sm_src.find("_music_preview_btn.pressed.connect(_on_music_preview_pressed)") == -1:
		report_fail.call("I058.12", "settings_menu.gd _ready missing _music_preview_btn.pressed.connect call")
	else:
		report_pass.call("I058.12")

	# I058.13 — settings_menu.gd has _on_music_preview_pressed handler
	if sm_src.find("func _on_music_preview_pressed() -> void:") == -1:
		report_fail.call("I058.13", "settings_menu.gd missing _on_music_preview_pressed handler")
	else:
		report_pass.call("I058.13")

	# I058.14 — _on_music_preview_pressed uses AudioPresets.MUSIC_PRESETS.keys()
	var h_idx := sm_src.find("func _on_music_preview_pressed()")
	if h_idx == -1:
		report_fail.call("I058.14", "cannot locate _on_music_preview_pressed")
	else:
		var h_block := sm_src.substr(h_idx, 600)
		if h_block.find("AudioPresets.MUSIC_PRESETS.keys()") == -1:
			report_fail.call("I058.14", "_on_music_preview_pressed missing AudioPresets.MUSIC_PRESETS.keys() call")
		elif h_block.find("randi() % keys.size()") == -1:
			report_fail.call("I058.14", "_on_music_preview_pressed missing random pick (randi() % keys.size())")
		elif h_block.find("AudioManagerEnhanced.preview_music_track(") == -1:
			report_fail.call("I058.14", "_on_music_preview_pressed missing AudioManagerEnhanced.preview_music_track call")
		else:
			report_pass.call("I058.14")

	# I058.15 — _on_close calls AudioManagerEnhanced.stop_music_preview (idempotent)
	if sm_src.find("func _on_close()") == -1:
		report_fail.call("I058.15", "settings_menu.gd missing _on_close")
	else:
		var close_idx := sm_src.find("func _on_close()")
		var close_block := sm_src.substr(close_idx, 500)
		if close_block.find("AudioManagerEnhanced.stop_music_preview()") == -1:
			report_fail.call("I058.15", "_on_close missing AudioManagerEnhanced.stop_music_preview() call")
		else:
			report_pass.call("I058.15")

	# I058.16 — T239 anchor comment at preview_music_track
	if ame_src.find("T239 (#157)") == -1:
		report_fail.call("I058.16", "audio_manager_enhanced.gd missing T239 (#157) anchor comment")
	elif ame_src.find("T239 (#157) — SettingsMenu Music bus volume preview button.") == -1:
		report_fail.call("I058.16", "audio_manager_enhanced.gd missing T239 anchor comment for preview_music_track")
	else:
		report_pass.call("I058.16")

	# I058.17 — T239 anchor comment in settings_menu.gd
	if sm_src.find("T239 (#157) — Music bus volume preview button") == -1:
		report_fail.call("I058.17", "settings_menu.gd missing T239 anchor comment for Music bus preview")
	else:
		report_pass.call("I058.17")

	# I058.18 — T239 anchor comment in settings_menu.tscn
	if ts_src.find("T239 (#157) — Music bus volume preview button.") == -1:
		report_fail.call("I058.18", "settings_menu.tscn missing T239 anchor comment for MusicPreviewButton")
	else:
		report_pass.call("I058.18")

	# Summary
	print("=== I058 + T239 smoke test: %d passed, %d failed, %d skipped ===" % [counters["passed"], counters["failed"], counters["skipped"]])
	if counters["failed"] > 0:
		quit(1)
	else:
		quit(0)


# T238 (#157) — Defensive load helper (same pattern as
# test_t158_t156_f002_smoke.gd). Returns null if `load()` fails OR
# the script has parse errors (can_instantiate() == false).
func _try_load_script(path: String) -> Script:
	var s := load(path)
	if s == null:
		return null
	if s is GDScript and not (s as GDScript).can_instantiate():
		return null
	return s


# T238 (#157) — Simple file reader for source-grep fallback paths.
func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content
