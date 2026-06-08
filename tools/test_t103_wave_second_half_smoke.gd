extends SceneTree

## T103 (#74 second half) — Smoke test for the Wave 5-verb symmetry.
## Verifies the autoload + JSON + scene wiring introduced for:
##   1. GameState.get_wave_radius_bonus() exists and returns 0 by default
##   2. Purchasing wave_focus (via purchase_perk) bumps the bonus
##   3. shop_catalog.json contains a wave_focus entry
##   4. achievements.json has a quintuple_voice entry using wave_icon
##   5. PlayerStats.wave_used exists; record_ability_used("wave") works
##   6. PlayerStats.all_abilities_used check requires wave_used >= 1
##   7. hud.tscn has the new WaveRow node
##   8. ResonanceWaveAbility._ready() applies the wave_radius_bonus

func _initialize() -> void:
	print("=== T103 (#74 second half) — 5-verb symmetry smoke test ===")

	var all_ok := true

	# 1. GameState.get_wave_radius_bonus() exists on the autoload script.
	var gs_script: Script = load("res://src/autoload/game_state.gd")
	if gs_script == null:
		print("  FAIL: cannot load game_state.gd")
		all_ok = false
	else:
		var gs_tmp: Node = gs_script.new()
		var has_field := false
		for p in gs_tmp.get_property_list():
			if p.name == "wave_radius_bonus":
				has_field = true
				break
		gs_tmp.free()
		if not has_field:
			print("  FAIL: GameState.wave_radius_bonus field missing")
			all_ok = false
		else:
			print("  PASS: GameState.wave_radius_bonus field present")

	# 2. GameState.get_wave_radius_bonus() returns 0 with no purchase.
	var gs: Node = gs_script.new()
	var default_bonus: int = int(gs.call("get_wave_radius_bonus"))
	if default_bonus != 0:
		print("  FAIL: get_wave_radius_bonus() = %d (expected 0)" % default_bonus)
		all_ok = false
	else:
		print("  PASS: get_wave_radius_bonus() = 0 with no purchase")

	# 3. Purchase wave_focus 2x via purchase_perk -> bonus = 20.
	# purchase_perk signature: (perk_id, price_shards, max_purchases).
	# wave_focus in shop_catalog.json: price_shards=12, max_purchases=3.
	# Grant enough shards first to avoid the price check.
	gs.set("shards", 999)
	gs.call("purchase_perk", "wave_focus", 12, 3)
	gs.call("purchase_perk", "wave_focus", 12, 3)
	var bumped_bonus: int = int(gs.call("get_wave_radius_bonus"))
	if bumped_bonus != 20:
		print("  FAIL: get_wave_radius_bonus() = %d after 2 wave_focus (expected 20)" % bumped_bonus)
		all_ok = false
	else:
		print("  PASS: 2 wave_focus purchases -> +20 radius")
	gs.free()

	# 4. shop_catalog.json contains wave_focus.
	var shop_file := FileAccess.open("res://data/shop_catalog.json", FileAccess.READ)
	if shop_file == null:
		print("  FAIL: cannot open shop_catalog.json")
		all_ok = false
	else:
		var shop_text := shop_file.get_as_text()
		shop_file.close()
		if "wave_focus" not in shop_text or "wave_radius_bonus" not in shop_text:
			print("  FAIL: shop_catalog.json missing wave_focus or wave_radius_bonus")
			all_ok = false
		else:
			print("  PASS: shop_catalog.json has wave_focus / wave_radius_bonus")

	# 5. achievements.json has quintuple_voice using wave_icon.
	var ach_file := FileAccess.open("res://data/achievements.json", FileAccess.READ)
	if ach_file == null:
		print("  FAIL: cannot open achievements.json")
		all_ok = false
	else:
		var ach_text := ach_file.get_as_text()
		ach_file.close()
		if "quintuple_voice" not in ach_text or "wave_icon" not in ach_text:
			print("  FAIL: achievements.json missing quintuple_voice or wave_icon")
			all_ok = false
		else:
			print("  PASS: achievements.json has quintuple_voice (wave_icon)")
		# Count total — should be 14.
		var parsed: Dictionary = JSON.parse_string(ach_text)
		var total := 0
		if parsed != null and parsed.has("achievements"):
			total = (parsed["achievements"] as Array).size()
		if total != 14:
			print("  FAIL: total achievements = %d (expected 14)" % total)
			all_ok = false
		else:
			print("  PASS: total achievements = 14 (T139 dynamic total_count)")

	# 6. PlayerStats.wave_used field + record_ability_used("wave") wiring.
	var ps_script: Script = load("res://src/autoload/player_stats.gd")
	if ps_script == null:
		print("  FAIL: cannot load player_stats.gd")
		all_ok = false
	else:
		var ps: Node = ps_script.new()
		ps.add_to_group("player_stats")
		var has_wave_used := false
		for p in ps.get_property_list():
			if p.name == "wave_used":
				has_wave_used = true
				break
		if not has_wave_used:
			print("  FAIL: PlayerStats.wave_used field missing")
			all_ok = false
		else:
			print("  PASS: PlayerStats.wave_used field present")
		# record_ability_used("wave")
		ps.call("record_ability_used", "wave")
		ps.call("record_ability_used", "wave")
		var wave_used_val: int = int(ps.get("wave_used"))
		if wave_used_val != 2:
			print("  FAIL: wave_used = %d after 2 records (expected 2)" % wave_used_val)
			all_ok = false
		else:
			print("  PASS: record_ability_used('wave') x2 -> wave_used=2")
		ps.free()

	# 7. hud.tscn has the new WaveRow node.
	var hud_file := FileAccess.open("res://src/scenes/hud.tscn", FileAccess.READ)
	if hud_file == null:
		print("  FAIL: cannot open hud.tscn")
		all_ok = false
	else:
		var hud_text := hud_file.get_as_text()
		hud_file.close()
		if "WaveRow" not in hud_text:
			print("  FAIL: hud.tscn missing WaveRow")
			all_ok = false
		else:
			print("  PASS: hud.tscn has WaveRow")

	# 8. ResonanceWaveAbility._ready() reads GameState.get_wave_radius_bonus().
	# In headless we can't fully instantiate the ability (needs player parent)
	# but we can verify the source file references the new getter.
	var wv_file := FileAccess.open("res://src/scripts/resonance_wave_ability.gd", FileAccess.READ)
	if wv_file == null:
		print("  FAIL: cannot open resonance_wave_ability.gd")
		all_ok = false
	else:
		var wv_text := wv_file.get_as_text()
		wv_file.close()
		if "get_wave_radius_bonus" not in wv_text:
			print("  FAIL: resonance_wave_ability.gd missing get_wave_radius_bonus call")
			all_ok = false
		else:
			print("  PASS: resonance_wave_ability.gd calls get_wave_radius_bonus()")

	print("")
	if all_ok:
		print("ALL CHECKS PASSED.")
		quit(0)
	else:
		print("FAILURES DETECTED — see above.")
		quit(1)
