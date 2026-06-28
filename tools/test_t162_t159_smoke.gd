extends SceneTree

## T162 + T159 (#83) — Smoke test bundle.
##
## T162 — PlayerProfilePanel "Run 历史行" (last N individual runs).
##   1. pause_menu.tscn defines a "ProfileRecentList" VBoxContainer under
##      PlayerProfilePanel/ProfileMargin/ProfileVBox between ProfileTrend20
##      and the HSep2 separator.
##   2. pause_menu.gd exposes an @onready var for the new list node.
##   3. pause_menu.gd defines _PROFILE_RECENT_RUNS_MAX (5) so the
##      visual density is bounded.
##   4. pause_menu.gd defines _refresh_recent_runs_list() that reads
##      PlayerStats.get_recent_runs(N), reverse-sorts newest-first, and
##      builds N row Labels with: "Run #N  房 X  净 Y  碎 Z  时 mm:ss".
##   5. The "latest" row (i == 0) is colored with the Amber Voice
##      color (0.949, 0.714, 0.431) so the most recent run is
##      visually anchored.
##   6. Empty history shows a "暂无 run 记录" placeholder label.
##   7. _refresh_profile() calls _refresh_recent_runs_list() AFTER the
##      three trend rows (T131) so the panel shows
##      best → trend5 → trend10 → trend20 → recent list → achv
##      in a coherent vertical flow.
##
## T159 — InkWarden phase-2 dissolve tween.
##   1. ink_warden.gd defines PHASE_2_DISSOLVE_OUT_TIME (0.25s) +
##      PHASE_2_DISSOLVE_IN_TIME (0.30s) so the tween durations are
##      tunable constants, not magic numbers.
##   2. _enter_phase_2 wraps the sprite swap in a tween that does:
##      (a) snap scale to ONE + alpha to 1.0
##      (b) tween scale ↑ (→ 1.15) and alpha ↓ (→ 0.0) over OUT_TIME
##      (c) snap scale to 0.85 + alpha to 0.0
##      (d) tween scale ↑ (→ 1.0) and alpha ↑ (→ 1.0) over IN_TIME
##      (e) then the existing red flash + settle (preserved)
##   3. The red tween still happens at the end (sequence preserved).

func _initialize() -> void:
	print("=== T162+T159 (#83) — Profile Recent Runs + InkWarden dissolve tween smoke test ===")

	var all_ok := true

	# Read all source files once.
	var pm_text: String = _read_text("res://src/scripts/pause_menu.gd")
	var tscn_text: String = _read_text("res://src/scenes/pause_menu.tscn")
	var iw_text: String = _read_text("res://src/scripts/ink_warden.gd")
	if pm_text.is_empty() or tscn_text.is_empty() or iw_text.is_empty():
		print("  FAIL: cannot read one of the source files (pm/tscn/iw)")
		all_ok = false
		_finish(all_ok)
		return

	# ---------- T162 — PlayerProfilePanel Run 历史行 ----------
	print("--- T162 — Profile Recent Runs ---")

	# 1. pause_menu.tscn defines ProfileRecentList under the same parent.
	#    The .tscn format splits `name="..."` and `parent="..."` across
	#    one header line, so we look for the name+parent together using
	#    regex-like windowing instead of a single substring match.
	if "ProfileRecentList" in tscn_text:
		# Find the ProfileRecentList header line and check its parent.
		var prl_idx: int = tscn_text.find('name="ProfileRecentList"')
		if prl_idx > 0:
			# Window: 200 chars starting at prl_idx covers the full header
			# line, including the closing `]` after parent="...".
			var prl_window: String = tscn_text.substr(prl_idx, 200)
			if "PlayerProfilePanel/ProfileMargin/ProfileVBox" in prl_window:
				print("  PASS: tscn has ProfileRecentList under ProfileVBox")
			else:
				print("  FAIL: tscn has ProfileRecentList but NOT under ProfileVBox")
				all_ok = false
		else:
			print("  FAIL: tscn has ProfileRecentList substring but no proper node header")
			all_ok = false
	else:
		print("  FAIL: tscn missing ProfileRecentList node entirely")
		all_ok = false

	# 2. pause_menu.gd exposes @onready var for the new list node.
	if "_profile_recent_list" in pm_text \
			and "@onready var _profile_recent_list" in pm_text:
		print("  PASS: pause_menu.gd declares @onready _profile_recent_list")
	else:
		print("  FAIL: pause_menu.gd missing @onready _profile_recent_list")
		all_ok = false

	# 3. _PROFILE_RECENT_RUNS_MAX constant exists and is 5.
	if "_PROFILE_RECENT_RUNS_MAX := 5" in pm_text:
		print("  PASS: _PROFILE_RECENT_RUNS_MAX := 5 (visual density cap)")
	else:
		print("  FAIL: pause_menu.gd missing _PROFILE_RECENT_RUNS_MAX := 5")
		all_ok = false

	# 4. _refresh_recent_runs_list() body shows newest-first with the
	#    expected row template.  This catches the most likely regression:
	#    forgetting to reverse or to emit the row template.
	var refresh_idx: int = pm_text.find("func _refresh_recent_runs_list()")
	if refresh_idx < 0:
		print("  FAIL: pause_menu.gd missing _refresh_recent_runs_list()")
		all_ok = false
	else:
		var refresh_body: String = pm_text.substr(refresh_idx, 5000)
		var t162_body_evidence := [
			["PlayerStats.get_recent_runs(_PROFILE_RECENT_RUNS_MAX)", "pulls recent N via get_recent_runs(N)"],
			["reversed_runs.reverse()", "reverses so newest is at top"],
			["暂无 run 记录", "empty history placeholder"],
			["Run #%d  房 %d  净 %d  碎 %d  时 %02d:%02d", "row template Run #/房/净/碎/时"],
			["_COLOR_RECENT_RUN_LATEST", "uses latest-run amber color"],
			["_COLOR_RECENT_RUN_NORMAL", "uses normal pale color for older runs"],
		]
		for pair in t162_body_evidence:
			var sig: String = pair[0]
			var label: String = pair[1]
			if sig in refresh_body:
				print("  PASS: _refresh_recent_runs_list has " + label)
			else:
				print("  FAIL: _refresh_recent_runs_list missing " + label)
				all_ok = false

	# 5. Latest run is highlighted by checking the i==0 branch is in body.
	#    The `_COLOR_RECENT_RUN_LATEST` identifier appears at LEAST twice
	#    in pause_menu.gd: once in the const section (declaration) and
	#    once inside _refresh_recent_runs_list (use).  We must check
	#    the SECOND occurrence (the use) — that's where the i==0 gating
	#    actually happens.
	if "if i == 0" in pm_text and "_COLOR_RECENT_RUN_LATEST" in pm_text:
		# Find the last occurrence (the use, not the const).
		var amber_idx: int = pm_text.rfind("_COLOR_RECENT_RUN_LATEST")
		if amber_idx > 0:
			# Walk back to the start of the line containing the if-i-0 branch
			var window: String = pm_text.substr(max(0, amber_idx - 600), 1200)
			if "if i == 0" in window and "_COLOR_RECENT_RUN_LATEST" in window:
				print("  PASS: latest (i==0) row uses Amber Voice color")
			else:
				print("  FAIL: Amber Voice color not gated to i==0 branch")
				all_ok = false
	else:
		if "if i == 0" not in pm_text:
			print("  FAIL: pause_menu.gd has no 'if i == 0' branch for latest row")
			all_ok = false
		if "_COLOR_RECENT_RUN_LATEST" not in pm_text:
			print("  FAIL: pause_menu.gd has no _COLOR_RECENT_RUN_LATEST color")
			all_ok = false

	# 6. _refresh_profile() invokes _refresh_recent_runs_list() AFTER the
	#    three _refresh_trend_row() calls so the panel order is
	#    best → trend5/10/20 → recent → achv.
	#    _refresh_profile() is large (best + 4 trend/best + recent +
	#    achievement list = 110+ lines), so we use 4000-char window.
	var profile_idx: int = pm_text.find("func _refresh_profile(")
	if profile_idx < 0:
		print("  FAIL: pause_menu.gd missing _refresh_profile()")
		all_ok = false
	else:
		# Find the END of _refresh_profile() so we don't accidentally
		# pick up _refresh_recent_runs_list() which is its own func.
		# _refresh_profile() ends at the next top-level `func ` line.
		var next_func_idx: int = pm_text.find("\nfunc _refresh_trend_row(", profile_idx)
		if next_func_idx < 0:
			next_func_idx = pm_text.find("\nfunc ", profile_idx + 50)
		var profile_end: int = next_func_idx if next_func_idx > 0 else (profile_idx + 5000)
		var profile_body: String = pm_text.substr(profile_idx, profile_end - profile_idx)
		if "_refresh_recent_runs_list()" in profile_body:
			# Order check: the three trend rows must come BEFORE
			# _refresh_recent_runs_list() (so the panel reads in
			# trend → recent order, not the other way around).
			var last_trend_pos: int = profile_body.rfind("_refresh_trend_row(_profile_trend20")
			var recent_pos: int = profile_body.find("_refresh_recent_runs_list()")
			if last_trend_pos >= 0 and recent_pos > last_trend_pos:
				print("  PASS: _refresh_recent_runs_list called AFTER trend row 20")
			else:
				print("  FAIL: _refresh_recent_runs_list not called AFTER trend row 20")
				all_ok = false
		else:
			print("  FAIL: _refresh_profile() does not call _refresh_recent_runs_list()")
			all_ok = false

	# ---------- T159 — InkWarden phase-2 dissolve tween ----------
	print("--- T159 — InkWarden phase-2 dissolve tween ---")

	# 1. Constants for OUT / IN durations defined.
	var t159_consts := [
		"PHASE_2_DISSOLVE_OUT_TIME: float = 0.25",
		"PHASE_2_DISSOLVE_IN_TIME: float = 0.30",
	]
	for c in t159_consts:
		if c in iw_text:
			print("  PASS: ink_warden.gd has " + c)
		else:
			print("  FAIL: ink_warden.gd missing " + c)
			all_ok = false

	# 2. _enter_phase_2() body wraps sprite swap in a tween that does
	#    the dissolve-out, snap, dissolve-in, then existing red flash.
	var ep2_idx: int = iw_text.find("func _enter_phase_2(")
	if ep2_idx < 0:
		print("  FAIL: ink_warden.gd missing _enter_phase_2()")
		all_ok = false
	else:
		# 3500 chars: covers the new dissolve block + the existing
		# red flash + the RepairVFX rings below it.
		var ep2_body: String = iw_text.substr(ep2_idx, 3500)
		var t159_evidence := [
			["PHASE_2_DISSOLVE_OUT_TIME", "uses OUT_TIME constant in dissolve-out tween"],
			["PHASE_2_DISSOLVE_IN_TIME", "uses IN_TIME constant in dissolve-in tween"],
			["Vector2.ONE * PHASE_2_DISSOLVE_OUT_SCALE", "scales up to 1.15 during dissolve out"],
			["Vector2.ONE * PHASE_2_DISSOLVE_IN_START_SCALE", "snaps to 0.85 start for dissolve in"],
			["tween_property(_sprite, \"modulate:a\", 0.0, PHASE_2_DISSOLVE_OUT_TIME)", "alpha to 0 over OUT_TIME"],
			["tween_property(_sprite, \"modulate:a\", 1.0, PHASE_2_DISSOLVE_IN_TIME)", "alpha back to 1 over IN_TIME"],
		]
		for pair in t159_evidence:
			var sig: String = pair[0]
			var label: String = pair[1]
			if sig in ep2_body:
				print("  PASS: _enter_phase_2 has " + label)
			else:
				print("  FAIL: _enter_phase_2 missing " + label)
				all_ok = false

	# 3. The existing red flash is preserved (it must come AFTER the
	#    dissolve-in tween, not be removed by the refactor).
	var red_flash_pos: int = iw_text.find("tween_property(_sprite, \"modulate\", Color(\"#E86D5A\"), 0.08)")
	if red_flash_pos > 0:
		# Red flash must be inside _enter_phase_2 (after the dissolve
		# block), not somewhere else.
		if red_flash_pos > ep2_idx and red_flash_pos < ep2_idx + 3500:
			print("  PASS: existing red flash preserved after dissolve-in tween")
		else:
			print("  FAIL: red flash is not inside _enter_phase_2 body after dissolve")
			all_ok = false
	else:
		print("  FAIL: red flash Color(\"#E86D5A\") tween missing entirely")
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
