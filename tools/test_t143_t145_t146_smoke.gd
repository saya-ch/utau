extends SceneTree

## T143 + T145 + T146 (#76) — Smoke test bundle.
##
## T143 — Wave-specific HUD prompts.
##   1. hud.gd defines show_wave_charging / show_wave_winding_up /
##      show_wave_active on top of the existing show_wave_blocked
##   2. player.gd _handle_wave routes the 4 failure cases:
##      active / winding_up / cooldown / cost-low (兜底)
##   3. Each route forwards to a verb-specific hud method (no fallback
##      to the old one-size-fits-all "共鸣不足" path)
##
## T145 — is_action_globally_blocked() generalisation + jump integration.
##   1. player.gd defines public `is_action_globally_blocked()` (renamed
##      from _is_wave_globally_blocking)
##   2. The old _is_wave_globally_blocking() name is GONE (no leftover)
##   3. _is_dying is OR'd in alongside the wave windup probe
##   4. All 5 verb handlers + _handle_jump call the new helper
##   5. _handle_jump zeroes its buffer timers on block (no replay
##      after the predicate flips back to false)
##
## T146 — wave_combo screen-shake polish.
##   1. resonance_wave_ability.gd exposes `signal wave_combo`
##   2. `_deactivate_wave` emits wave_combo when the cast hit >=
##      wave_combo_threshold (default 3)
##   3. player.gd has `_on_wave_combo(hit_count)` handler
##   4. player.gd connects the signal via has_signal guard
##   5. _on_wave_combo calls ScreenShake.shake(4.0, 0.4) and
##      flash_color(Electric Violet)

func _initialize() -> void:
	print("=== T143+T145+T146 (#76) — wave UX/Polish/Refactor smoke test ===")

	var all_ok := true

	# Read all three files once at the top so later blocks can re-use
	# the strings without re-opening (avoids GDScript block-scope
	# surprises on `var` declared inside an if-branch).
	var hud_text: String = _read_text("res://src/scripts/hud.gd")
	var player_text: String = _read_text("res://src/scripts/player.gd")
	var wv_text: String = _read_text("res://src/scripts/resonance_wave_ability.gd")
	if hud_text.is_empty() or player_text.is_empty() or wv_text.is_empty():
		print("  FAIL: cannot read one of the source files (hud/player/wave)")
		all_ok = false
		_finish(all_ok)
		return

	# ---------- T143 — Wave-specific HUD prompts ----------
	print("--- T143 ---")

	var t143_methods := [
		"func show_wave_blocked()",
		"func show_wave_charging()",
		"func show_wave_winding_up()",
		"func show_wave_active()",
	]
	for m in t143_methods:
		if m not in hud_text:
			print("  FAIL: hud.gd missing " + m)
			all_ok = false
		else:
			print("  PASS: hud.gd defines " + m)

	# Each new method must call show_repair_hint (no dead method).
	var t143_prompts := [
		["show_wave_charging", "Wave 还在蓄势"],
		["show_wave_winding_up", "Wave 正在准备"],
		["show_wave_active", "Wave 横扫中"],
	]
	for pair in t143_prompts:
		var method_name: String = pair[0]
		var hint: String = pair[1]
		var idx: int = hud_text.find("func " + method_name + "()")
		if idx < 0:
			continue  # already reported above
		var body: String = hud_text.substr(idx, 300)
		if "show_repair_hint" not in body or hint not in body:
			print("  FAIL: hud.gd " + method_name + " missing show_repair_hint(\"" + hint + "\")")
			all_ok = false
		else:
			print("  PASS: hud.gd " + method_name + " emits \"" + hint + "\"")

	# _handle_wave must check all 4 failure modes.
	var handle_wave_idx: int = player_text.find("func _handle_wave()")
	if handle_wave_idx < 0:
		print("  FAIL: player.gd missing _handle_wave handler")
		all_ok = false
	else:
		# 1800 chars covers the whole handler + the long leading comment.
		var handle_wave_block: String = player_text.substr(handle_wave_idx, 1800)
		var t143_probes := [
			["is_wave_active", "show_wave_active"],
			["is_winding_up", "show_wave_winding_up"],
			["get_cooldown_ratio", "show_wave_charging"],
		]
		for pair in t143_probes:
			var probe: String = pair[0]
			var hud_method: String = pair[1]
			if probe not in handle_wave_block:
				print("  FAIL: _handle_wave missing probe " + probe + "()")
				all_ok = false
			elif hud_method not in handle_wave_block:
				print("  FAIL: _handle_wave missing route to " + hud_method + "()")
				all_ok = false
			else:
				print("  PASS: _handle_wave probes " + probe + "() and routes to " + hud_method + "()")
		# 兜底分支：show_wave_blocked 单独检查（无对应的 probe 方法名）。
		if "show_wave_blocked()" in handle_wave_block:
			print("  PASS: _handle_wave has show_wave_blocked() 兜底 route")
		else:
			print("  FAIL: _handle_wave missing show_wave_blocked() 兜底 route")
			all_ok = false

	# ---------- T145 — is_action_globally_blocked + jump ----------
	print("--- T145 ---")

	# 1. New public helper exists.
	if "func is_action_globally_blocked() -> bool:" in player_text:
		print("  PASS: player.gd has is_action_globally_blocked() helper")
	else:
		print("  FAIL: player.gd missing is_action_globally_blocked() helper")
		all_ok = false

	# 2. Old underscore-prefixed name is GONE.
	if "func _is_wave_globally_blocking()" in player_text:
		print("  FAIL: player.gd still has _is_wave_globally_blocking() (should be renamed)")
		all_ok = false
	else:
		print("  PASS: player.gd _is_wave_globally_blocking() is renamed/removed")

	# 3. _is_dying is part of the predicate.
	var helper_idx: int = player_text.find("func is_action_globally_blocked() -> bool:")
	if helper_idx < 0:
		print("  FAIL: cannot locate is_action_globally_blocked() body")
		all_ok = false
	else:
		var helper_body: String = player_text.substr(helper_idx, 600)
		if "_is_dying" in helper_body and "wave_ability" in helper_body:
			print("  PASS: is_action_globally_blocked() OR's _is_dying + wave_ability")
		else:
			print("  FAIL: is_action_globally_blocked() missing _is_dying or wave_ability probe")
			all_ok = false

	# 4. All 5 verb handlers + _handle_jump call the new helper. F005 (#85)
	# introduced a thin wrapper `_pre_verb_block_check()` that the 4 verb
	# handlers use; _handle_jump and the echo multi-reflect handler still
	# call is_action_globally_blocked() directly. Accept either form so
	# the test tracks both the #76 rename and the #85 wrapper refactor.
	var t145_callers := [
		"_handle_pulse",
		"_handle_bind",
		"_handle_cut",
		"_handle_echo",
		"_handle_jump",
	]
	for handler in t145_callers:
		var h_idx: int = player_text.find("func " + handler + "(")
		if h_idx < 0:
			print("  FAIL: player.gd missing " + handler)
			all_ok = false
			continue
		# 2500 chars covers _handle_jump's long leading comment (T145
		# + T147 both add inline rationale paragraphs above the
		# predicate, so 1500 was tight). The 4 verb handlers are
		# much shorter so 2500 is well within their bodies too.
		var h_block: String = player_text.substr(h_idx, 2500)
		var calls_guard := "is_action_globally_blocked()" in h_block \
				or "_pre_verb_block_check()" in h_block
		if not calls_guard:
			print("  FAIL: " + handler + " does not call is_action_globally_blocked() or _pre_verb_block_check()")
			all_ok = false
		else:
			print("  PASS: " + handler + " calls action-block guard")

	# 5. _handle_jump zeros its buffer timers on block.
	var jump_idx: int = player_text.find("func _handle_jump(")
	if jump_idx < 0:
		print("  FAIL: cannot find _handle_jump")
		all_ok = false
	else:
		var jump_block: String = player_text.substr(jump_idx, 2500)
		if "_coyote_timer = 0.0" in jump_block and "_jump_buffer_timer = 0.0" in jump_block:
			print("  PASS: _handle_jump zeros both buffer timers on block")
		else:
			print("  FAIL: _handle_jump missing buffer-timer zeroing")
			all_ok = false

	# ---------- T146 — wave_combo screen-shake ----------
	print("--- T146 ---")

	# 1. wave_combo signal exists.
	if "signal wave_combo(hit_count: int)" in wv_text:
		print("  PASS: resonance_wave_ability.gd has wave_combo signal")
	else:
		print("  FAIL: resonance_wave_ability.gd missing wave_combo signal")
		all_ok = false

	# 2. wave_combo_threshold @export exists.
	if "@export var wave_combo_threshold: int = 3" in wv_text:
		print("  PASS: wave_combo_threshold @export = 3")
	else:
		print("  FAIL: wave_combo_threshold @export missing or wrong default")
		all_ok = false

	# 3. _deactivate_wave emits wave_combo when threshold reached.
	var deact_idx: int = wv_text.find("func _deactivate_wave()")
	if deact_idx < 0:
		print("  FAIL: cannot find _deactivate_wave")
		all_ok = false
	else:
		var deact_body: String = wv_text.substr(deact_idx, 800)
		if "wave_combo.emit" in deact_body and "wave_combo_threshold" in deact_body:
			print("  PASS: _deactivate_wave emits wave_combo when hit_count >= threshold")
		else:
			print("  FAIL: _deactivate_wave missing wave_combo.emit or threshold check")
			all_ok = false

	# 4. player.gd connects wave_combo via has_signal guard.
	if "wave_ability.has_signal(\"wave_combo\")" in player_text \
			and "wave_ability.wave_combo.connect" in player_text:
		print("  PASS: player.gd connects wave_combo with has_signal guard")
	else:
		print("  FAIL: player.gd missing has_signal-guarded wave_combo connect")
		all_ok = false

	# 5. _on_wave_combo handler exists + shakes + flashes.
	var combo_idx: int = player_text.find("func _on_wave_combo(")
	if combo_idx < 0:
		print("  FAIL: player.gd missing _on_wave_combo handler")
		all_ok = false
	else:
		# 3000 chars: _on_wave_combo has a long leading comment block (T146
		# design rationale + T148 chime tail appended in #78) and the
		# flash_color call sits near the end (~line 38 in the function),
		# so 2000 chars was too short post-T148. 3000 gives comfortable
		# headroom for any future tail additions.
		var combo_body: String = player_text.substr(combo_idx, 3000)
		var t146_evidence := [
			["ScreenShake.shake(4.0, 0.4)", "0.4s wave_combo shake"],
			["ScreenShake.flash_color", "Electric Violet flash"],
			["Color(0.549, 0.357, 1.0", "Electric Violet color (#8C5BFF)"],
		]
		for pair in t146_evidence:
			var sig: String = pair[0]
			var label: String = pair[1]
			if sig in combo_body:
				print("  PASS: _on_wave_combo has " + label)
			else:
				print("  FAIL: _on_wave_combo missing " + label)
				all_ok = false

	_finish(all_ok)

# Helper: read a file as text, return empty string on failure.
func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var txt: String = f.get_as_text()
	f.close()
	return txt

# Helper: print final result + quit with the right exit code.
func _finish(ok: bool) -> void:
	print("")
	if ok:
		print("ALL CHECKS PASSED.")
		quit(0)
	else:
		print("FAILURES DETECTED — see above.")
		quit(1)
