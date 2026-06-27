extends SceneTree

## T150 + T147 + T149 (#77) — Smoke test bundle.
##
## T150 — PlayerProfilePanel "上次使用：Wave" 行 (5-verb symmetry completion)
##   1. PlayerStats has last_used_verb field (default "")
##   2. record_ability_used() updates last_used_verb
##   3. reset_stats() clears last_used_verb
##   4. pause_menu.tscn has ProfileLastVerb node
##   5. pause_menu.gd has @onready _profile_last_verb + 5 verb BBCode branches
##
## T147 — _handle_jump 阻塞时 hud.show_jump_blocked 提示
##   1. hud.gd defines show_jump_blocked()
##   2. _handle_jump shows hint when is_action_just_pressed("jump") AND blocked
##   3. The hint goes via get_first_node_in_group("hud").has_method guard
##
## T149 — EchoAbility 反弹 parallax 双层 VFX
##   1. echo_vfx.gd has PARALLAX_ROTATION_RATIO/RADIUS_RATIO/ALPHA_RATIO consts
##   2. _draw() has Layer 5b (secondary ray ring) with smaller base_angle
##   3. _draw() calls queue_free after 0.85s lifetime (no regression)

func _initialize() -> void:
	print("=== T150+T147+T149 (#77) — 5-verb profile completion + jump block UX + Echo parallax ===")

	var all_ok := true

	var stats_text: String = _read_text("res://src/autoload/player_stats.gd")
	var tscn_text: String = _read_text("res://src/scenes/pause_menu.tscn")
	var pause_text: String = _read_text("res://src/scripts/pause_menu.gd")
	var hud_text: String = _read_text("res://src/scripts/hud.gd")
	var player_text: String = _read_text("res://src/scripts/player.gd")
	var echo_text: String = _read_text("res://src/scripts/echo_vfx.gd")
	if stats_text.is_empty() or tscn_text.is_empty() or pause_text.is_empty() \
			or hud_text.is_empty() or player_text.is_empty() or echo_text.is_empty():
		print("  FAIL: cannot read one of the source files")
		all_ok = false
		_finish(all_ok)
		return

	# ---------- T150 — last_used_verb + ProfileLastVerb ----------
	print("--- T150 ---")

	# 1. last_used_verb field on PlayerStats.
	if "var last_used_verb: String = \"\"" in stats_text:
		print("  PASS: PlayerStats has last_used_verb field")
	else:
		print("  FAIL: PlayerStats missing last_used_verb field")
		all_ok = false

	# 2. get_last_used_verb() getter exists.
	if "func get_last_used_verb() -> String:" in stats_text:
		print("  PASS: PlayerStats has get_last_used_verb() getter")
	else:
		print("  FAIL: PlayerStats missing get_last_used_verb() getter")
		all_ok = false

	# 3. record_ability_used writes last_used_verb.
	var rau_idx: int = stats_text.find("func record_ability_used(ability_name: String) -> void:")
	if rau_idx < 0:
		print("  FAIL: cannot find record_ability_used()")
		all_ok = false
	else:
		var rau_body: String = stats_text.substr(rau_idx, 600)
		if "last_used_verb = ability_name" in rau_body:
			print("  PASS: record_ability_used() updates last_used_verb")
		else:
			print("  FAIL: record_ability_used() does not write last_used_verb")
			all_ok = false

	# 4. reset_stats clears last_used_verb.
	var reset_idx: int = stats_text.find("func reset_stats() -> void:")
	if reset_idx < 0:
		print("  FAIL: cannot find reset_stats()")
		all_ok = false
	else:
		var reset_body: String = stats_text.substr(reset_idx, 1500)
		if 'last_used_verb = ""' in reset_body:
			print("  PASS: reset_stats() clears last_used_verb to empty")
		else:
			print("  FAIL: reset_stats() does not clear last_used_verb")
			all_ok = false

	# 5. pause_menu.tscn has ProfileLastVerb node.
	if "ProfileLastVerb" in tscn_text and "上次使用：" in tscn_text:
		print("  PASS: pause_menu.tscn defines ProfileLastVerb node with '上次使用' text")
	else:
		print("  FAIL: pause_menu.tscn missing ProfileLastVerb node or '上次使用' placeholder")
		all_ok = false

	# 6. pause_menu.gd has @onready _profile_last_verb.
	if "_profile_last_verb" in pause_text:
		print("  PASS: pause_menu.gd references _profile_last_verb")
	else:
		print("  FAIL: pause_menu.gd missing _profile_last_verb reference")
		all_ok = false

	# 7. _refresh_profile emits all 5 verb BBCode forms (5-verb symmetry).
	var refresh_idx: int = pause_text.find("func _refresh_profile() -> void:")
	if refresh_idx < 0:
		print("  FAIL: cannot find _refresh_profile()")
		all_ok = false
	else:
		# #135 review 修 — 之前用 substr(refresh_idx, 5000) 硬截 5000 chars,
		# #134 T214 在 _refresh_profile 末尾加 _quick_stats_default_text save
		# (+10 行注释 + 1 行 save) 之后, 5000 chars 窗口只能覆盖到 "pulse":
		# case 头 (offset 4949), bind/cut/echo/wave 4 case 全部在窗口外, 假阳 fail.
		# 改用动态 end-of-function 定位: 从 refresh_idx 之后找下一个顶层
		# "func " 声明 或 EOF, 取完整函数体覆盖 5 case branch.
		var next_func_idx := pause_text.find("\nfunc ", refresh_idx + 1)
		var refresh_end: int = next_func_idx if next_func_idx > 0 else refresh_idx + 12000
		var refresh_body: String = pause_text.substr(refresh_idx, refresh_end - refresh_idx)
		var t150_verbs := [
			["pulse", "#E86D5A"],
			["bind", "#65506A"],
			["cut", "#F2B66E"],
			["echo", "#69C7CE"],
			["wave", "#B7E6DC"],
		]
		for pair in t150_verbs:
			var verb: String = pair[0]
			var hex_code: String = pair[1]
			# Look for the case branch: '"verb":' and the hex in the same _refresh_profile block
			if ('"' + verb + '":') in refresh_body and hex_code in refresh_body:
				print("  PASS: _refresh_profile emits verb '%s' with hex %s" % [verb, hex_code])
			else:
				print("  FAIL: _refresh_profile missing verb '%s' branch or hex %s" % [verb, hex_code])
				all_ok = false

	# ---------- T147 — show_jump_blocked ----------
	print("--- T147 ---")

	# 1. show_jump_blocked() exists in hud.gd.
	if "func show_jump_blocked() -> void:" in hud_text:
		print("  PASS: hud.gd defines show_jump_blocked()")
	else:
		print("  FAIL: hud.gd missing show_jump_blocked()")
		all_ok = false

	# 2. show_jump_blocked() forwards to show_repair_hint with a non-empty text.
	var sjb_idx: int = hud_text.find("func show_jump_blocked() -> void:")
	if sjb_idx < 0:
		all_ok = false
	else:
		var sjb_body: String = hud_text.substr(sjb_idx, 250)
		if "show_repair_hint" in sjb_body:
			print("  PASS: show_jump_blocked() calls show_repair_hint(...)")
		else:
			print("  FAIL: show_jump_blocked() missing show_repair_hint call")
			all_ok = false

	# 3. _handle_jump calls show_jump_blocked when blocked.
	var jump_idx: int = player_text.find("func _handle_jump(")
	var jump_body: String = ""
	if jump_idx < 0:
		print("  FAIL: cannot find _handle_jump()")
		all_ok = false
	else:
		# F004 (#84) — Window expanded from 1800 → 2500 chars.
		# Reason: T145 (#76) added a 17-line T145 docblock + 4-line T147 docblock
		# above the `if is_action_globally_blocked():` body, plus D001 (#82) added
		# the PlayerActionGate autoload refactor line. The relevant code (show_jump_blocked
		# / has_method / _coyote_timer = 0.0 / _jump_buffer_timer = 0.0) now sits
		# at char positions 1827..1900 within the function — past the old 1800
		# window. 2500 chars covers the full body of _handle_jump even with future
		# inline comment growth. (Original test value was a guess that didn't
		# anticipate T145's heavy inline comments — F004 fixes the stale window.)
		jump_body = player_text.substr(jump_idx, 2500)
		# Need: show_jump_blocked called inside the if is_action_globally_blocked() block
		if "show_jump_blocked" in jump_body and "is_action_just_pressed(\"jump\")" in jump_body \
				and "is_action_globally_blocked()" in jump_body:
			print("  PASS: _handle_jump shows jump_blocked hint on is_action_just_pressed + blocked")
		else:
			print("  FAIL: _handle_jump missing show_jump_blocked routing or is_action_just_pressed guard")
			all_ok = false

	# 4. _handle_jump still calls is_action_globally_blocked() + zeros buffers (no regression from T145).
	if jump_idx >= 0 and "_coyote_timer = 0.0" in jump_body and "_jump_buffer_timer = 0.0" in jump_body:
		print("  PASS: _handle_jump zeros buffer timers on block (T145 preserved)")
	else:
		print("  FAIL: _handle_jump buffer zeroing lost")
		all_ok = false

	# 5. _handle_jump uses get_first_node_in_group("hud") + has_method (defensive).
	if jump_idx >= 0 and 'get_first_node_in_group("hud")' in jump_body and "has_method" in jump_body:
		print("  PASS: _handle_jump uses has_method guard for show_jump_blocked")
	else:
		print("  FAIL: _handle_jump missing has_method or group lookup guard")
		all_ok = false

	# 6. F004 (#84) — T147 guard synced with #76 refactor + D001 (#82) PlayerActionGate.
	# The post-#76 name is is_action_globally_blocked() (T145 rename from
	# _is_wave_globally_blocking), and post-D001 that function is a thin delegate to
	# the PlayerActionGate autoload. We assert both the post-#76 name appears in
	# _handle_jump AND the post-D001 delegate pattern (PlayerActionGate.is_blocked()
	# inside the function body) is present — this catches accidental renames and
	# accidental removal of the D001 refactor in a single assertion.
	if jump_idx >= 0 and "is_action_globally_blocked()" in jump_body:
		# Find the is_action_globally_blocked function definition (not the call sites).
		# Look 500 chars after the function header for the PlayerActionGate.is_blocked() delegate.
		var gate_idx: int = player_text.find("func is_action_globally_blocked() -> bool:")
		if gate_idx >= 0:
			var gate_body: String = player_text.substr(gate_idx, 400)
			if "PlayerActionGate.is_blocked()" in gate_body:
				print("  PASS: is_action_globally_blocked() is a thin delegate to PlayerActionGate (D001 sync, OK)")
			else:
				print("  FAIL: is_action_globally_blocked() missing PlayerActionGate.is_blocked() delegate (D001 reverted?)")
				all_ok = false
		else:
			print("  FAIL: cannot find is_action_globally_blocked() definition for D001 sync check")
			all_ok = false
	else:
		print("  FAIL: T147 守卫 in _handle_jump not synced with #76 refactor (using pre-#76 name?)")
		all_ok = false

	# ---------- T149 — Echo parallax double layer ----------
	print("--- T149 ---")

	# 1. Three PARALLAX_* constants present.
	var t149_consts := [
		"PARALLAX_ROTATION_RATIO",
		"PARALLAX_RADIUS_RATIO",
		"PARALLAX_ALPHA_RATIO",
	]
	for c in t149_consts:
		if ("const " + c) in echo_text:
			print("  PASS: echo_vfx.gd defines " + c)
		else:
			print("  FAIL: echo_vfx.gd missing const " + c)
			all_ok = false

	# 2. _draw() has the secondary layer (look for PI / 8.0 offset + 1.08 radius usage).
	if "PI / 8.0" in echo_text and "PARALLAX_RADIUS_RATIO" in echo_text \
			and "_radius * 0.7" in echo_text:
		print("  PASS: echo_vfx.gd _draw() has secondary layer with PI/8 offset and 1.08× radius")
	else:
		print("  FAIL: echo_vfx.gd _draw() missing secondary layer signature")
		all_ok = false

	# 3. queue_free() after 0.85s still present (no regression on lifetime).
	if "_lifetime >= _max_lifetime" in echo_text and "queue_free()" in echo_text \
			and "_max_lifetime: float = 0.85" in echo_text:
		print("  PASS: echo_vfx.gd lifetime / queue_free() preserved")
	else:
		print("  FAIL: echo_vfx.gd lifetime/queue_free broken")
		all_ok = false

	# 4. add_bounce_flash still works (no regression).
	if "func add_bounce_flash(pos: Vector2) -> void:" in echo_text \
			and "_bounces.append" in echo_text:
		print("  PASS: echo_vfx.gd add_bounce_flash() preserved")
	else:
		print("  FAIL: echo_vfx.gd add_bounce_flash() broken")
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
		print("\n=== ALL T150+T147+T149 (#77) ASSERTIONS PASSED ===")
		quit(0)
	else:
		print("\n=== T150+T147+T149 (#77) HAS FAILURES ===")
		quit(1)
