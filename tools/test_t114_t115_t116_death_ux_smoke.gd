extends SceneTree
# T114 + T115 + T116 — death-UX polish smoke test (#61).
# 13 assertions covering:
#   1) silence_void preset shape (T114)
#   2) silence_void zero-amplitude synth (T114)
#   3) silence_void GFC route for GAME_OVER_FAILURE (T114)
#   4) GFC no longer calls stop_music for failure (T114)
#   5) AudioManagerEnhanced arp-empty math (T114 no-divide-by-zero)
#   6) Player has 6-element _DEATH_QUOTES array (T115)
#   7) Player has 4 death-quote timing constants (T115)
#   8) Player has _build_death_quote_overlay method (T115)
#   9) Player has _show_death_quote and _hide_death_quote (T115)
#  10) respawn_at calls _hide_death_quote (T115 cleanup)
#  11) InkWarden has request_afterimage method (T116)
#  12) request_afterimage guards _is_dead / _is_purified (T116)
#  13) Player.die() iterates elite_enemies (T116 wire-up)

const SRC_AUDIO := "res://src/scripts/audio_manager_enhanced.gd"
const SRC_GFC := "res://src/scripts/game_flow_controller.gd"
const SRC_PLAYER := "res://src/scripts/player.gd"
const SRC_WARDEN := "res://src/scripts/ink_warden.gd"

var _passed: int = 0
var _failed: int = 0

func _initialize() -> void:
	_run_assert("T114 silence_void preset present", _assert_silence_void_preset)
	_run_assert("T114 silence_void zero-amplitude stream", _assert_silence_void_zero_amplitude)
	_run_assert("T114 GFC GAME_OVER_FAILURE → silence_void", _assert_gfc_failure_routes_silence_void)
	_run_assert("T114 GFC GAME_OVER_FAILURE no longer stop_music", _assert_gfc_failure_no_stop_music)
	_run_assert("T114 AudioManagerEnhanced arp-empty path (no %0)", _assert_audio_arp_empty_safe)
	_run_assert("T115 player has 6 _DEATH_QUOTES", _assert_player_has_6_quotes)
	_run_assert("T115 player has 4 quote timing constants", _assert_player_quote_constants)
	_run_assert("T115 player._build_death_quote_overlay exists", _assert_player_build_overlay)
	_run_assert("T115 player has _show_quote + _hide_quote", _assert_player_quote_methods)
	_run_assert("T115 respawn_at calls _hide_death_quote", _assert_respawn_calls_hide_quote)
	_run_assert("T116 InkWarden has request_afterimage", _assert_warden_has_afterimage)
	_run_assert("T116 request_afterimage guards _is_dead/_is_purified", _assert_warden_afterimage_guards)
	_run_assert("T116 player.die() iterates elite_enemies", _assert_player_iterates_elite)

	print("[test_t114_t115_t116_death_ux_smoke] PASSED %d / FAILED %d" % [_passed, _failed])
	if _failed > 0:
		quit(1)
	else:
		quit(0)

func _run_assert(label: String, fn: Callable) -> void:
	var ok := false
	var err_msg := ""
	# Use callv so we can capture any runtime error without aborting
	# the entire test (each assertion is independent).
	var result = fn.call()
	if typeof(result) == TYPE_BOOL:
		ok = result
	elif typeof(result) == TYPE_ARRAY and result.size() == 2:
		ok = result[0]
		err_msg = String(result[1])
	if ok:
		_passed += 1
		print("  [PASS] %s" % label)
	else:
		_failed += 1
		print("  [FAIL] %s%s" % [label, " — " + err_msg if err_msg != "" else ""])

func _file_get_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)

# --- T114 ---

func _assert_silence_void_preset() -> Variant:
	var src := _file_get_text(SRC_AUDIO)
	if src == "":
		return [false, "audio_manager_enhanced.gd not found"]
	if src.find('"silence_void":') == -1:
		return [false, "silence_void preset missing"]
	# Required field shape
	for field in ["bpm", "duration", "chord_midi", "arp_midi", "arp_volume", "pad_volume", "bass_volume", "shimmer_volume"]:
		if src.find('"silence_void"') == -1:
			continue
		# crude: ensure field is in source near the silence_void block
		var block_start := src.find('"silence_void":')
		var block_end := src.find("}", block_start)
		if block_start == -1 or block_end == -1:
			return [false, "silence_void block parse failed"]
		var block := src.substr(block_start, block_end - block_start)
		if field in ["chord_midi", "arp_midi"]:
			if block.find('"' + field + '": []') == -1:
				return [false, "%s not empty array in silence_void" % field]
		else:
			if block.find('"' + field + '":') == -1:
				return [false, "%s missing in silence_void" % field]
	# Confirm zero volumes
	var block_start := src.find('"silence_void":')
	var block_end := src.find("}", block_start)
	var block := src.substr(block_start, block_end - block_start)
	for vol in ["arp_volume", "pad_volume", "bass_volume", "shimmer_volume"]:
		var vpos := block.find('"' + vol + '":')
		if vpos == -1:
			return [false, "%s missing" % vol]
		var rest := block.substr(vpos + len(vol) + 4, 8)
		if not rest.begins_with("0.0"):
			return [false, "%s not 0.0 — found '%s'" % [vol, rest]]
	return true

func _assert_silence_void_zero_amplitude() -> Variant:
	# Actually synthesize the track and confirm the byte stream is
	# all zeros (or near-zeros, since the synth emits 16-bit
	# integers in [-28000, 28000]; four-zero channels = 0).
	var ame := load(SRC_AUDIO)
	if not ame:
		return [false, "could not load audio_manager_enhanced.gd"]
	var inst = ame.new()
	if not inst.has_method("_generate_music_track"):
		return [false, "_generate_music_track missing"]
	# Call the synth directly.
	var stream = inst.call("_generate_music_track", "silence_void")
	if not stream:
		return [false, "silence_void stream not generated"]
	# AudioStreamWAV.data is a PackedByteArray of 16-bit signed samples.
	# All four channels are zero-amplitude, so every sample is 0.
	var data: PackedByteArray = stream.data
	if data.size() == 0:
		return [false, "data is empty"]
	# Count non-zero bytes.
	var nonzero := 0
	for b in data:
		if b != 0:
			nonzero += 1
	if nonzero > 0:
		return [false, "expected all-zero bytes, got %d non-zero" % nonzero]
	inst.free()
	return true

func _assert_gfc_failure_routes_silence_void() -> Variant:
	var src := _file_get_text(SRC_GFC)
	if src == "":
		return [false, "gfc not found"]
	# Find the LAST occurrence of State.GAME_OVER_FAILURE: — there
	# are two in the file (one in the enum-like state map and one in
	# the actual match arm).  The second one is the one we care about
	# for T114 routing.
	var last_pos := -1
	var search_pos := 0
	while true:
		var p := src.find("State.GAME_OVER_FAILURE:", search_pos)
		if p == -1:
			break
		last_pos = p
		search_pos = p + 1
	if last_pos == -1:
		return [false, "GAME_OVER_FAILURE arm not found"]
	# Read the next ~1500 chars (the match arm body — 12-line comment
	# is large so the actual play_music_track call is far from the
	# arm label).
	var arm := src.substr(last_pos, 1500)
	if arm.find('"silence_void"') == -1:
		return [false, "GAME_OVER_FAILURE arm does not call silence_void"]
	if arm.find("play_music_track") == -1:
		return [false, "GAME_OVER_FAILURE arm does not call play_music_track"]
	return true

func _assert_gfc_failure_no_stop_music() -> Variant:
	var src := _file_get_text(SRC_GFC)
	if src == "":
		return [false, "gfc not found"]
	# Find the LAST occurrence of State.GAME_OVER_FAILURE: (the
	# match arm — see _assert_gfc_failure_routes_silence_void for
	# why).  After our T114 edit, the arm must NOT call stop_music
	# on the EXECUTABLE line (the original docstring mentioning
	# "stops the music" is in a comment and would otherwise trigger
	# a false positive).
	var last_pos := -1
	var search_pos := 0
	while true:
		var p := src.find("State.GAME_OVER_FAILURE:", search_pos)
		if p == -1:
			break
		last_pos = p
		search_pos = p + 1
	if last_pos == -1:
		return [false, "GAME_OVER_FAILURE arm not found"]
	var arm := src.substr(last_pos, 1500)
	for line in arm.split("\n"):
		var stripped := line.strip_edges()
		# Only check executable lines, not comments — the arm's
		# own T114 comment block mentions "stops" in past tense.
		if stripped.begins_with("#"):
			continue
		if stripped.find("stop_music") != -1:
			return [false, "GAME_OVER_FAILURE still calls stop_music: %s" % stripped]
	return true

func _assert_audio_arp_empty_safe() -> Variant:
	# Confirm the synth math guards against arp_len == 0 (the
	# silence_void case).  Look for the `if arp_len > 0:` guard.
	var src := _file_get_text(SRC_AUDIO)
	if src == "":
		return [false, "audio_manager_enhanced.gd not found"]
	if src.find("if arp_len > 0:") == -1:
		return [false, "arp_len > 0 guard missing — would divide by zero on silence_void"]
	# Also confirm the comment block mentioning T114 is present
	if src.find("T114") == -1:
		return [false, "T114 comment not present in synth"]
	return true

# --- T115 ---

func _assert_player_has_6_quotes() -> Variant:
	var src := _file_get_text(SRC_PLAYER)
	if src == "":
		return [false, "player.gd not found"]
	var pos := src.find("_DEATH_QUOTES := [")
	if pos == -1:
		return [false, "_DEATH_QUOTES array not found"]
	# Count quote entries by counting top-level string lines (each
	# entry is enclosed in double quotes — naive but works because
	# none of our quotes contain quote chars).
	var body := src.substr(pos, 1500)
	# We expect 6 distinct quoted entries.  Count " quoted at the
	# start of a line: pattern `"\u4e2d\u6587` or `"\u4e0b\u4e00` etc.
	var count := 0
	for line in body.split("\n"):
		var s := line.strip_edges()
		if s.begins_with("\""):
			count += 1
	if count != 6:
		return [false, "expected 6 quote entries, got %d" % count]
	return true

func _assert_player_quote_constants() -> Variant:
	var src := _file_get_text(SRC_PLAYER)
	if src == "":
		return [false, "player.gd not found"]
	for k in ["DEATH_QUOTE_FADE_IN", "DEATH_QUOTE_HOLD", "DEATH_QUOTE_FADE_OUT", "DEATH_QUOTE_PEAK_ALPHA"]:
		if src.find("const " + k) == -1:
			return [false, "const %s missing" % k]
	return true

func _assert_player_build_overlay() -> Variant:
	var src := _file_get_text(SRC_PLAYER)
	if src == "":
		return [false, "player.gd not found"]
	if src.find("func _build_death_quote_overlay()") == -1:
		return [false, "_build_death_quote_overlay() missing"]
	if src.find("_death_quote_layer = CanvasLayer.new()") == -1:
		return [false, "CanvasLayer construction missing"]
	if src.find("_death_quote_label = Label.new()") == -1:
		return [false, "Label construction missing"]
	return true

func _assert_player_quote_methods() -> Variant:
	var src := _file_get_text(SRC_PLAYER)
	if src == "":
		return [false, "player.gd not found"]
	# Methods may be declared as `func _show_death_quote() -> void:`,
	# not just `func _show_death_quote():`, so strip the trailing
	# return type before searching.
	if src.find("func _show_death_quote(") == -1:
		return [false, "_show_death_quote() missing"]
	if src.find("func _hide_death_quote(") == -1:
		return [false, "_hide_death_quote() missing"]
	# confirm _show uses _DEATH_QUOTES and tween_property on modulate:a
	var pos := src.find("func _show_death_quote(")
	if pos == -1:
		return [false, "_show_death_quote def lost"]
	var body := src.substr(pos, 1500)
	if body.find("_DEATH_QUOTES") == -1:
		return [false, "_show_death_quote does not reference _DEATH_QUOTES"]
	if body.find("modulate:a") == -1:
		return [false, "_show_death_quote does not tween modulate:a"]
	return true

func _assert_respawn_calls_hide_quote() -> Variant:
	var src := _file_get_text(SRC_PLAYER)
	if src == "":
		return [false, "player.gd not found"]
	# find respawn_at body
	var pos := src.find("func respawn_at(pos: Vector2)")
	if pos == -1:
		return [false, "respawn_at not found"]
	var body := src.substr(pos, 1500)
	if body.find("_hide_death_quote()") == -1:
		return [false, "respawn_at does not call _hide_death_quote"]
	return true

# --- T116 ---

func _assert_warden_has_afterimage() -> Variant:
	var src := _file_get_text(SRC_WARDEN)
	if src == "":
		return [false, "ink_warden.gd not found"]
	if src.find("func request_afterimage(") == -1:
		return [false, "request_afterimage() missing"]
	return true

func _assert_warden_afterimage_guards() -> Variant:
	var src := _file_get_text(SRC_WARDEN)
	if src == "":
		return [false, "ink_warden.gd not found"]
	# `func request_afterimage() -> void:` not just `func request_afterimage():`
	var pos := src.find("func request_afterimage(")
	if pos == -1:
		return [false, "request_afterimage not found"]
	var body := src.substr(pos, 2000)
	# Must guard against dead / purified boss so the ghost isn't
	# spawned for a boss that's already been killed this run.
	if body.find("_is_dead") == -1 or body.find("_is_purified") == -1:
		return [false, "request_afterimage missing _is_dead / _is_purified guards"]
	# Must add ghost as Sprite2D to scene
	if body.find("Sprite2D.new()") == -1:
		return [false, "request_afterimage does not build Sprite2D"]
	# Must tween alpha down to 0
	if body.find("modulate:a") == -1:
		return [false, "request_afterimage does not tween modulate:a"]
	return true

func _assert_player_iterates_elite() -> Variant:
	var src := _file_get_text(SRC_PLAYER)
	if src == "":
		return [false, "player.gd not found"]
	# Confirm die() iterates the elite_enemies group and calls
	# request_afterimage on each.  Method may have a return type
	# annotation: `func die() -> void:`
	var pos := src.find("func die(")
	if pos == -1:
		return [false, "die() not found"]
	var body := src.substr(pos, 1800)
	if body.find("get_nodes_in_group(\"elite_enemies\")") == -1:
		return [false, "die() does not iterate elite_enemies group"]
	if body.find("request_afterimage()") == -1:
		return [false, "die() does not call request_afterimage()"]
	return true
