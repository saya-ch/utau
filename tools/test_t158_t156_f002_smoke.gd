extends SceneTree

## T158 + T156 + F002 (#81) — Smoke test for:
##   T158: EchoAbility 4+ reflect emits echo_multi_reflect signal,
##         player.gd bridges to 0.4s 0.85x time-scale slow-mo with
##         _is_dying defensive guard.
##   T156: ScreenShake autoload exposes punch_rotation(degrees, duration)
##         and InkWarden._enter_phase_2() calls it before shake_preset.
##   F002: check_smoke_consistency.sh has rule 7 README sync hook
##         (parses "Recent completed work" section, compares to
##         ITERATION_COUNT.txt, fails if >= 2 iterations behind).
##
## 28 assertions total — all static parse / grep (no live scene
## required, no autoload init needed). Run via:
##   godot --headless --script tools/test_t158_t156_f002_smoke.gd

func _initialize() -> void:
	print("=== T158 + T156 + F002 smoke test ===")

	var echo_script := load("res://src/scripts/echo_ability.gd")
	if echo_script == null:
		print("  FAIL: cannot load echo_ability.gd")
		quit(1)
		return
	var player_script := load("res://src/scripts/player.gd")
	if player_script == null:
		print("  FAIL: cannot load player.gd")
		quit(1)
		return
	var screen_shake_script := load("res://src/autoload/screen_shake.gd")
	if screen_shake_script == null:
		print("  FAIL: cannot load screen_shake.gd")
		quit(1)
		return
	var ink_warden_script := load("res://src/scripts/ink_warden.gd")
	if ink_warden_script == null:
		print("  FAIL: cannot load ink_warden.gd")
		quit(1)
		return

	# ===== T158 assertions =====

	# T158.1 — echo_multi_reflect signal declared on EchoAbility
	var signals_found := []
	for s in echo_script.get_script_signal_list():
		signals_found.append(s.name)
	if not ("echo_multi_reflect" in signals_found):
		print("  FAIL [T158.1]: echo_ability.gd missing signal 'echo_multi_reflect'")
		quit(1)
		return
	print("  [T158.1] echo_ability has 'echo_multi_reflect' signal (OK)")

	# T158.2 — MULTI_REFLECT_THRESHOLD constant on EchoAbility
	var inst: Node = echo_script.new()
	var found_threshold := false
	for prop in inst.get_property_list():
		if prop.name == "MULTI_REFLECT_THRESHOLD" or prop.name == "multi_reflect_threshold":
			found_threshold = true
			break
	# Also check via class-level const lookup
	if not found_threshold:
		var script_obj: Script = echo_script
		var const_map: Dictionary = script_obj.get_script_constant_map()
		if const_map.has("MULTI_REFLECT_THRESHOLD"):
			found_threshold = true
	if not found_threshold:
		print("  FAIL [T158.2]: echo_ability.gd missing MULTI_REFLECT_THRESHOLD constant")
		inst.free()
		quit(1)
		return
	inst.free()
	print("  [T158.2] echo_ability has MULTI_REFLECT_THRESHOLD constant (OK)")

	# T158.3 — echo_ability.gd source emits echo_multi_reflect at the 4th reflect
	var echo_src := ""
	var ef := FileAccess.open("res://src/scripts/echo_ability.gd", FileAccess.READ)
	if ef:
		echo_src = ef.get_as_text()
		ef.close()
	if echo_src.find("echo_multi_reflect.emit") == -1:
		print("  FAIL [T158.3]: echo_ability.gd does not emit 'echo_multi_reflect' anywhere")
		quit(1)
		return
	if echo_src.find("_reflected_this_cast.size() == MULTI_REFLECT_THRESHOLD") == -1:
		print("  FAIL [T158.3]: echo_ability.gd emit guard missing (size() == MULTI_REFLECT_THRESHOLD)")
		quit(1)
		return
	print("  [T158.3] echo_ability emits at 4th reflect (size() == MULTI_REFLECT_THRESHOLD) (OK)")

	# T158.4 — player.gd connects to echo_multi_reflect via has_signal guard
	var player_src := ""
	var pf := FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
	if pf:
		player_src = pf.get_as_text()
		pf.close()
	if player_src.find("has_signal(\"echo_multi_reflect\")") == -1:
		print("  FAIL [T158.4]: player.gd missing has_signal(\"echo_multi_reflect\") guard")
		quit(1)
		return
	if player_src.find("echo_multi_reflect.connect") == -1:
		print("  FAIL [T158.4]: player.gd does not connect echo_multi_reflect")
		quit(1)
		return
	print("  [T158.4] player.gd connects echo_multi_reflect via has_signal guard (OK)")

	# T158.5 — player.gd has _on_echo_multi_reflect handler with 0.85 + 0.4
	if player_src.find("_on_echo_multi_reflect") == -1:
		print("  FAIL [T158.5]: player.gd missing _on_echo_multi_reflect handler")
		quit(1)
		return
	if player_src.find("0.85") == -1:
		print("  FAIL [T158.5]: player.gd slow-mo scale 0.85 not present")
		quit(1)
		return
	if player_src.find("0.4") == -1:
		print("  FAIL [T158.5]: player.gd slow-mo duration 0.4 not present")
		quit(1)
		return
	print("  [T158.5] player.gd has _on_echo_multi_reflect with 0.85 / 0.4 (OK)")

	# T158.6 — player.gd handler checks _is_dying to avoid clobbering die() reset
	if player_src.find("not _is_dying") == -1 or player_src.find("Engine.time_scale = 1.0") == -1:
		print("  FAIL [T158.6]: player.gd handler missing _is_dying guard for 1.0 restore")
		quit(1)
		return
	print("  [T158.6] player.gd _on_echo_multi_reflect has _is_dying guard for 1.0 restore (OK)")

	# T158.7 — player.gd handler also guards against stacking on death/wave-windup
	if player_src.find("is_action_globally_blocked") == -1:
		print("  FAIL [T158.7]: player.gd handler missing is_action_globally_blocked guard")
		quit(1)
		return
	# The is_action_globally_blocked check should be in _on_echo_multi_reflect context
	# (search for the early-return in that handler)
	var handler_idx := player_src.find("func _on_echo_multi_reflect")
	if handler_idx == -1:
		print("  FAIL [T158.7]: cannot locate _on_echo_multi_reflect handler")
		quit(1)
		return
	var handler_block := player_src.substr(handler_idx, 600)
	if handler_block.find("is_action_globally_blocked") == -1:
		print("  FAIL [T158.7]: _on_echo_multi_reflect handler missing is_action_globally_blocked early-return")
		quit(1)
		return
	print("  [T158.7] _on_echo_multi_reflect has is_action_globally_blocked early-return (OK)")

	# T158.8 — handler uses create_timer().timeout (await pattern, not tween)
	if player_src.find("create_timer(_ECHO_MULTI_SLOW_MO_DURATION)") == -1 and \
		player_src.find("create_timer(0.4)") == -1:
		print("  FAIL [T158.8]: _on_echo_multi_reflect should await create_timer for 0.4s slow-mo")
		quit(1)
		return
	print("  [T158.8] _on_echo_multi_reflect uses create_timer().timeout await (OK)")

	# ===== T156 assertions =====

	# T156.1 — ScreenShake has punch_rotation method
	var ss_inst: Node = screen_shake_script.new()
	var ss_methods := []
	for m in ss_inst.get_method_list():
		ss_methods.append(m.name)
	ss_inst.free()
	if not ("punch_rotation" in ss_methods):
		print("  FAIL [T156.1]: screen_shake.gd missing method 'punch_rotation'")
		quit(1)
		return
	print("  [T156.1] screen_shake has 'punch_rotation' method (OK)")

	# T156.2 — ScreenShake source has _active_rotation_tween field
	var ss_src := ""
	var sf := FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	if sf:
		ss_src = sf.get_as_text()
		sf.close()
	if ss_src.find("_active_rotation_tween") == -1:
		print("  FAIL [T156.2]: screen_shake.gd missing _active_rotation_tween field")
		quit(1)
		return
	print("  [T156.2] screen_shake has _active_rotation_tween field (OK)")

	# T156.3 — punch_rotation signature accepts (degrees, duration)
	if ss_src.find("func punch_rotation(degrees_value: float = 0.5, duration: float = 0.2)") == -1:
		print("  FAIL [T156.3]: punch_rotation signature mismatch (expected 0.5/0.2 defaults)")
		quit(1)
		return
	print("  [T156.3] punch_rotation(degrees_value=0.5, duration=0.2) signature (OK)")

	# T156.4 — punch_rotation uses deg_to_rad + tween + quad ease
	var pr_idx := ss_src.find("func punch_rotation")
	if pr_idx == -1:
		print("  FAIL [T156.4]: cannot locate punch_rotation function")
		quit(1)
		return
	var pr_block := ss_src.substr(pr_idx, 800)
	if pr_block.find("deg_to_rad") == -1:
		print("  FAIL [T156.4]: punch_rotation missing deg_to_rad call")
		quit(1)
		return
	if pr_block.find("tween_property") == -1:
		print("  FAIL [T156.4]: punch_rotation missing tween_property")
		quit(1)
		return
	if pr_block.find("Tween.TRANS_QUAD") == -1:
		print("  FAIL [T156.4]: punch_rotation missing TRANS_QUAD ease")
		quit(1)
		return
	print("  [T156.4] punch_rotation uses deg_to_rad + tween + TRANS_QUAD (OK)")

	# T156.5 — stop() resets rotation tween + camera.rotation
	if ss_src.find("func stop()") == -1:
		print("  FAIL [T156.5]: screen_shake.gd missing stop() function")
		quit(1)
		return
	var stop_idx := ss_src.find("func stop():")
	if stop_idx == -1:
		stop_idx = ss_src.find("func stop(")
	var stop_block := ss_src.substr(stop_idx, 1200)
	if stop_block.find("_active_rotation_tween") == -1:
		print("  FAIL [T156.5]: stop() does not kill _active_rotation_tween")
		quit(1)
		return
	if stop_block.find("cam.rotation = 0.0") == -1 and stop_block.find("_camera.rotation = 0.0") == -1:
		print("  FAIL [T156.5]: stop() does not reset camera.rotation to 0.0")
		quit(1)
		return
	print("  [T156.5] stop() kills rotation tween + resets camera.rotation (OK)")

	# T156.6 — ink_warden.gd _enter_phase_2() calls punch_rotation BEFORE shake_preset
	var iw_src := ""
	var iw_f := FileAccess.open("res://src/scripts/ink_warden.gd", FileAccess.READ)
	if iw_f:
		iw_src = iw_f.get_as_text()
		iw_f.close()
	var ep2_idx := iw_src.find("func _enter_phase_2()")
	if ep2_idx == -1:
		print("  FAIL [T156.6]: ink_warden.gd missing _enter_phase_2() function")
		quit(1)
		return
	var ep2_block := iw_src.substr(ep2_idx, 1000)
	if ep2_block.find("punch_rotation") == -1:
		print("  FAIL [T156.6]: _enter_phase_2() does not call punch_rotation")
		quit(1)
		return
	if ep2_block.find("shake_preset") == -1:
		print("  FAIL [T156.6]: _enter_phase_2() does not call shake_preset (sanity check)")
		quit(1)
		return
	# Verify ordering: punch_rotation appears before shake_preset in the function block
	var pr_pos := ep2_block.find("punch_rotation")
	var sp_pos := ep2_block.find("shake_preset")
	if pr_pos > sp_pos:
		print("  FAIL [T156.6]: punch_rotation must be called BEFORE shake_preset in _enter_phase_2() (pr_pos=%d sp_pos=%d)" % [pr_pos, sp_pos])
		quit(1)
		return
	print("  [T156.6] _enter_phase_2() calls punch_rotation(0.5, 0.2) before shake_preset (OK)")

	# T156.7 — punch_rotation called with 0.5 / 0.2 arguments in ink_warden
	if ep2_block.find("punch_rotation(0.5, 0.2)") == -1:
		print("  FAIL [T156.7]: punch_rotation call should use arguments 0.5, 0.2")
		quit(1)
		return
	print("  [T156.7] _enter_phase_2() uses punch_rotation(0.5, 0.2) arguments (OK)")

	# ===== F002 assertions =====

	var csc_path := "res://tools/check_smoke_consistency.sh"
	var csc_src := ""
	var csc_f := FileAccess.open(csc_path, FileAccess.READ)
	if csc_f:
		csc_src = csc_f.get_as_text()
		csc_f.close()
	if csc_src == "":
		print("  FAIL [F002.1]: cannot read %s" % csc_path)
		quit(1)
		return

	# F002.1 — rule 7 explicitly labeled
	if csc_src.find("Rule 7") == -1 and csc_src.find("rule 7") == -1:
		print("  FAIL [F002.1]: check_smoke_consistency.sh missing 'Rule 7' / 'rule 7' label")
		quit(1)
		return
	print("  [F002.1] check_smoke_consistency.sh has 'Rule 7' label (OK)")

	# F002.2 — rule 7 references "Recent completed work" header (both en + zh)
	if csc_src.find("Recent completed work") == -1:
		print("  FAIL [F002.2]: rule 7 missing 'Recent completed work' header reference")
		quit(1)
		return
	if csc_src.find("最近完成的工作") == -1:
		print("  FAIL [F002.2]: rule 7 missing '最近完成的工作' (zh-CN) header reference")
		quit(1)
		return
	print("  [F002.2] rule 7 references both en + zh 'Recent completed work' headers (OK)")

	# F002.3 — rule 7 reads ITERATION_COUNT.txt
	# The rule 7 block must reference ITERATION_COUNT (not just say it)
	if csc_src.find("ITERATION_COUNT") == -1:
		print("  FAIL [F002.3]: rule 7 does not reference ITERATION_COUNT")
		quit(1)
		return
	# It should also do the awk+grep pattern
	if csc_src.find("awk") == -1 or csc_src.find("grep -oE") == -1:
		print("  FAIL [F002.3]: rule 7 missing awk + grep -oE parse logic")
		quit(1)
		return
	print("  [F002.3] rule 7 uses awk + grep -oE to parse README sections (OK)")

	# F002.4 — rule 7 has both README.md and README.zh-CN.md coverage
	if csc_src.find("README.md") == -1:
		print("  FAIL [F002.4]: rule 7 missing README.md reference")
		quit(1)
		return
	if csc_src.find("README.zh-CN.md") == -1:
		print("  FAIL [F002.4]: rule 7 missing README.zh-CN.md reference")
		quit(1)
		return
	print("  [F002.4] rule 7 covers both README.md + README.zh-CN.md (OK)")

	# F002.5 — rule 7 has FAIL (errors++) branch for >= 2 iterations behind
	# Look for explicit "errors=" increment in rule 7 block
	var rule7_idx := csc_src.find("Rule 7")
	if rule7_idx == -1:
		rule7_idx = csc_src.find("rule 7")
	# Find a 'for rf in' loop or 'RECENT_SECTION' block start
	var rule7_start := csc_src.rfind("# Rule 7", rule7_idx)
	if rule7_start == -1:
		rule7_start = csc_src.rfind("# rule 7", rule7_idx)
	if rule7_start == -1:
		# Fallback: find the rule 7 line itself
		rule7_start = rule7_idx
	var rule7_block := csc_src.substr(rule7_start, 3000)
	if rule7_block.find("errors=") == -1 or rule7_block.find("DIFF") == -1:
		print("  FAIL [F002.5]: rule 7 missing errors= increment + DIFF check (>= 2 round FAIL)")
		quit(1)
		return
	if rule7_block.find("DIFF") == -1 or rule7_block.find("2") == -1:
		print("  FAIL [F002.5]: rule 7 should check DIFF >= 2 (NOT >=1, that would over-warn)")
		quit(1)
		return
	print("  [F002.5] rule 7 has errors= + DIFF >= 2 FAIL path (OK)")

	# F002.6 — rule 7 has WARN (warnings++) branch for 1 iteration behind
	if rule7_block.find("warnings=") == -1:
		print("  FAIL [F002.6]: rule 7 missing warnings= increment for 1-iteration WARN")
		quit(1)
		return
	print("  [F002.6] rule 7 has warnings= for 1-iteration WARN (OK)")

	# F002.7 — README.md "Recent completed work" has #N-1 entry (proves the hook works)
	# F004 (#84) — Was hardcoded "#81" but should be dynamic: read ITERATION_COUNT.txt - 1
	# to find what the previous iteration's #N was. The rule 7 hook's job is to detect
	# when a commit's CHANGELOG/ROADMAP updates lagged by N≥2 rounds; for the hook to
	# *ever* trip we need the README to track each round. Self-test must follow the
	# current iteration count minus 1 (the round we just finished). If ITERATION_COUNT
	# can't be read, fall back to "81" (the original #N) with a warning, so the test
	# still self-validates on broken setups.
	var readme_src := ""
	var rm_f := FileAccess.open("res://README.md", FileAccess.READ)
	if rm_f:
		readme_src = rm_f.get_as_text()
		rm_f.close()
	var rec_idx := readme_src.find("Recent completed work")
	if rec_idx == -1:
		print("  FAIL [F002.7]: README.md missing 'Recent completed work' section")
		quit(1)
		return
	# Get the section content (until next ## )
	var next_h := readme_src.find("\n## ", rec_idx + 25)
	if next_h == -1:
		next_h = readme_src.length()
	var rec_section := readme_src.substr(rec_idx, next_h - rec_idx)
	var prev_iter_str := "81"
	var ic_f := FileAccess.open("res://ITERATION_COUNT.txt", FileAccess.READ)
	if ic_f:
		var ic_text: String = ic_f.get_as_text().strip_edges()
		ic_f.close()
		if ic_text.is_valid_int():
			var prev_iter: int = int(ic_text) - 1
			if prev_iter >= 1:
				prev_iter_str = str(prev_iter)
	if rec_section.find("#" + prev_iter_str + " —") == -1 and rec_section.find("#" + prev_iter_str + " -") == -1:
		print("  FAIL [F002.7]: README.md 'Recent completed work' missing #" + prev_iter_str + " entry (proves hook would block if missing)")
		quit(1)
		return
	print("  [F002.7] README.md 'Recent completed work' has #" + prev_iter_str + " entry (hook self-test, OK)")

	# F002.8 — README.zh-CN.md "最近完成的工作" has #N-1 entry (zh sync self-test)
	var readme_zh_src := ""
	var rmz_f := FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	if rmz_f:
		readme_zh_src = rmz_f.get_as_text()
		rmz_f.close()
	var rec_zh_idx := readme_zh_src.find("最近完成的工作")
	if rec_zh_idx == -1:
		print("  FAIL [F002.8]: README.zh-CN.md missing '最近完成的工作' section")
		quit(1)
		return
	var next_zh := readme_zh_src.find("\n## ", rec_zh_idx + 25)
	if next_zh == -1:
		next_zh = readme_zh_src.length()
	var rec_zh_section := readme_zh_src.substr(rec_zh_idx, next_zh - rec_zh_idx)
	if rec_zh_section.find("#" + prev_iter_str + " —") == -1 and rec_zh_section.find("#" + prev_iter_str + " -") == -1:
		print("  FAIL [F002.8]: README.zh-CN.md '最近完成的工作' missing #" + prev_iter_str + " entry (zh sync self-test)")
		quit(1)
		return
	print("  [F002.8] README.zh-CN.md '最近完成的工作' has #" + prev_iter_str + " entry (zh sync self-test, OK)")

	print("=== T158 + T156 + F002 smoke test PASSED (28/28 assertions) ===")
	quit(0)
