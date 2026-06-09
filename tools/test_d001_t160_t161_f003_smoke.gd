extends SceneTree

## D001 + T160 + T161 + F003 (#82) — Smoke test for:
##   D001: PlayerActionGate autoload refactor — extracts the composite
##         "is action blocked" check (_is_dying + wave windup) from
##         player.gd into src/autoload/player_action_gate.gd.
##   T160: PauseMenu top "新成就！" banner shown when achievement
##         unlocked while menu is open (or within 5s of opening).
##   T161: Settings menu "还原所有推荐设置" button — one-click restore
##         default keybindings + audio + autosave.
##   F003: godot/README.md + README.md + README.zh-CN.md + CONTRIBUTING.md
##         updated to prefer `unzip -FF` over Python zipfile on
##         Python 3.14+ (where stdlib zipfile fails on multi-volume).
##
## 30+ assertions — all static parse / grep (no live scene required,
## no autoload init needed). Run via:
##   godot --headless --script tools/test_d001_t160_t161_f003_smoke.gd

func _initialize() -> void:
	print("=== D001 + T160 + T161 + F003 smoke test (#82) ===")

	# ===== D001 assertions =====

	# D001.1 — PlayerActionGate autoload file exists
	var gate_path := "res://src/autoload/player_action_gate.gd"
	var gate_script := load(gate_path)
	if gate_script == null:
		print("  FAIL [D001.1]: cannot load %s" % gate_path)
		quit(1)
		return
	print("  [D001.1] %s loads (OK)" % gate_path)

	# D001.2 — PlayerActionGate has register_player / unregister_player / is_blocked
	var gate_inst: Node = gate_script.new()
	var gate_methods := []
	for m in gate_inst.get_method_list():
		gate_methods.append(m.name)
	gate_inst.free()
	for required in ["register_player", "unregister_player", "is_blocked", "get_player"]:
		if not (required in gate_methods):
			print("  FAIL [D001.2]: player_action_gate.gd missing method '%s'" % required)
			quit(1)
			return
	print("  [D001.2] PlayerActionGate has register_player/unregister_player/is_blocked/get_player (OK)")

	# D001.3 — project.godot registers PlayerActionGate as autoload
	var pg_src := ""
	var pf := FileAccess.open("res://project.godot", FileAccess.READ)
	if pf:
		pg_src = pf.get_as_text()
		pf.close()
	if pg_src.find("PlayerActionGate=\"*res://src/autoload/player_action_gate.gd\"") == -1:
		print("  FAIL [D001.3]: project.godot missing PlayerActionGate autoload registration")
		quit(1)
		return
	print("  [D001.3] project.godot registers PlayerActionGate as autoload (OK)")

	# D001.4 — player.gd registers with PlayerActionGate in _ready
	var player_src := ""
	var plf := FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
	if plf:
		player_src = plf.get_as_text()
		plf.close()
	if player_src.find("PlayerActionGate.register_player(self)") == -1:
		print("  FAIL [D001.4]: player.gd _ready missing PlayerActionGate.register_player(self)")
		quit(1)
		return
	print("  [D001.4] player.gd calls PlayerActionGate.register_player in _ready (OK)")

	# D001.5 — player.gd unregisters in _exit_tree
	if player_src.find("PlayerActionGate.unregister_player(self)") == -1:
		print("  FAIL [D001.5]: player.gd _exit_tree missing PlayerActionGate.unregister_player(self)")
		quit(1)
		return
	print("  [D001.5] player.gd calls PlayerActionGate.unregister_player in _exit_tree (OK)")

	# D001.6 — player.gd is_action_globally_blocked delegates to gate
	var iagb_idx := player_src.find("func is_action_globally_blocked()")
	if iagb_idx == -1:
		print("  FAIL [D001.6]: player.gd missing is_action_globally_blocked function")
		quit(1)
		return
	var iagb_block := player_src.substr(iagb_idx, 700)
	if iagb_block.find("PlayerActionGate.is_blocked()") == -1:
		print("  FAIL [D001.6]: is_action_globally_blocked does not delegate to PlayerActionGate.is_blocked()")
		quit(1)
		return
	print("  [D001.6] is_action_globally_blocked delegates to PlayerActionGate.is_blocked() (OK)")

	# D001.7 — PlayerActionGate source has D001 header comment
	var gate_src := ""
	var gf := FileAccess.open(gate_path, FileAccess.READ)
	if gf:
		gate_src = gf.get_as_text()
		gf.close()
	if gate_src.find("D001") == -1 or gate_src.find("#82") == -1:
		print("  FAIL [D001.7]: player_action_gate.gd missing D001 / #82 header comment")
		quit(1)
		return
	print("  [D001.7] player_action_gate.gd has D001/#82 header (OK)")

	# D001.8 — is_blocked() probes _is_dying AND delegates to wave_ability.is_globally_blocking
	var ib_idx := gate_src.find("func is_blocked()")
	if ib_idx == -1:
		print("  FAIL [D001.8]: player_action_gate.gd missing is_blocked function")
		quit(1)
		return
	var ib_block := gate_src.substr(ib_idx, 1500)
	if ib_block.find("_is_dying") == -1:
		print("  FAIL [D001.8]: is_blocked() does not probe _is_dying")
		quit(1)
		return
	if ib_block.find("is_globally_blocking") == -1:
		print("  FAIL [D001.8]: is_blocked() does not delegate to wave_ability.is_globally_blocking")
		quit(1)
		return
	print("  [D001.8] is_blocked() composes _is_dying + wave_ability.is_globally_blocking (OK)")

	# D001.9 — resonance_wave_ability.gd is_globally_blocking still has canonical _is_winding_up return
	var rwa_src := ""
	var rf := FileAccess.open("res://src/scripts/resonance_wave_ability.gd", FileAccess.READ)
	if rf:
		rwa_src = rf.get_as_text()
		rf.close()
	var igb_idx := rwa_src.find("func is_globally_blocking()")
	if igb_idx == -1:
		print("  FAIL [D001.9]: resonance_wave_ability.gd missing is_globally_blocking function")
		quit(1)
		return
	# Look at a 500-char window STARTING from 300 chars BEFORE the function
	# to capture the comment block above (D001 refactor note).  Then the
	# function body is appended (next 300 chars) for the `return _is_winding_up`.
	var pre_ctx := rwa_src.substr(max(0, igb_idx - 500), 500)
	var igb_block := pre_ctx + rwa_src.substr(igb_idx, 300)
	if igb_block.find("return _is_winding_up") == -1:
		print("  FAIL [D001.9]: is_globally_blocking does not return _is_winding_up")
		quit(1)
		return
	if igb_block.find("D001") == -1:
		print("  FAIL [D001.9]: is_globally_blocking missing D001 refactor comment")
		quit(1)
		return
	print("  [D001.9] resonance_wave_ability.is_globally_blocking returns _is_winding_up (canonical, OK)")

	# ===== T160 assertions =====

	# T160.1 — NewAchvBanner node added to pause_menu.tscn
	var pm_tscn_src := ""
	var pmt := FileAccess.open("res://src/scenes/pause_menu.tscn", FileAccess.READ)
	if pmt:
		pm_tscn_src = pmt.get_as_text()
		pmt.close()
	if pm_tscn_src.find("[node name=\"NewAchvBanner\"") == -1:
		print("  FAIL [T160.1]: pause_menu.tscn missing NewAchvBanner node")
		quit(1)
		return
	print("  [T160.1] pause_menu.tscn has NewAchvBanner node (OK)")

	# T160.2 — pause_menu.gd subscribes to PlayerStats.achievement_unlocked
	var pm_src := ""
	var pms := FileAccess.open("res://src/scripts/pause_menu.gd", FileAccess.READ)
	if pms:
		pm_src = pms.get_as_text()
		pms.close()
	if pm_src.find("PlayerStats.achievement_unlocked.connect") == -1:
		print("  FAIL [T160.2]: pause_menu.gd does not subscribe to PlayerStats.achievement_unlocked")
		quit(1)
		return
	print("  [T160.2] pause_menu.gd subscribes to PlayerStats.achievement_unlocked (OK)")

	# T160.3 — pause_menu.gd has _show_new_achv_banner with tween + modulate.a
	if pm_src.find("func _show_new_achv_banner()") == -1:
		print("  FAIL [T160.3]: pause_menu.gd missing _show_new_achv_banner function")
		quit(1)
		return
	var sab_idx := pm_src.find("func _show_new_achv_banner()")
	var sab_block := pm_src.substr(sab_idx, 1200)
	if sab_block.find("modulate:a") == -1:
		print("  FAIL [T160.3]: _show_new_achv_banner does not animate modulate:a")
		quit(1)
		return
	if sab_block.find("tween_property") == -1:
		print("  FAIL [T160.3]: _show_new_achv_banner missing tween_property")
		quit(1)
		return
	print("  [T160.3] _show_new_achv_banner uses tween_property + modulate:a fade (OK)")

	# T160.4 — Banner fades in 0.4s + fades out 0.4s (net 0.8s visible)
	if pm_src.find("_BANNER_FADE := 0.4") == -1:
		print("  FAIL [T160.4]: _BANNER_FADE constant should be 0.4")
		quit(1)
		return
	if pm_src.find("_BANNER_DURATION := 0.8") == -1:
		print("  FAIL [T160.4]: _BANNER_DURATION constant should be 0.8")
		quit(1)
		return
	print("  [T160.4] Banner uses 0.4s fade + 0.8s net visible (OK)")

	# T160.5 — _check_banner_for_recent_unlock has 5s window for re-show on menu open
	if pm_src.find("_BANNER_RECENT_UNLOCK_WINDOW := 5.0") == -1:
		print("  FAIL [T160.5]: _BANNER_RECENT_UNLOCK_WINDOW constant should be 5.0s")
		quit(1)
		return
	print("  [T160.5] Recent-unlock window = 5s for menu re-open replay (OK)")

	# ===== T161 assertions =====

	# T161.1 — RestoreAllButton added to settings_menu.tscn
	var sm_tscn_src := ""
	var smt := FileAccess.open("res://src/scenes/settings_menu.tscn", FileAccess.READ)
	if smt:
		sm_tscn_src = smt.get_as_text()
		smt.close()
	if sm_tscn_src.find("[node name=\"RestoreAllButton\"") == -1:
		print("  FAIL [T161.1]: settings_menu.tscn missing RestoreAllButton node")
		quit(1)
		return
	print("  [T161.1] settings_menu.tscn has RestoreAllButton node (OK)")

	# T161.2 — Button text is "还原所有推荐设置"
	if sm_tscn_src.find("text = \"还原所有推荐设置\"") == -1:
		print("  FAIL [T161.2]: RestoreAllButton text should be '还原所有推荐设置'")
		quit(1)
		return
	print("  [T161.2] RestoreAllButton text is '还原所有推荐设置' (OK)")

	# T161.3 — settings_menu.gd has _on_restore_all_pressed handler
	var sm_src := ""
	var sms := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if sms:
		sm_src = sms.get_as_text()
		sms.close()
	if sm_src.find("func _on_restore_all_pressed()") == -1:
		print("  FAIL [T161.3]: settings_menu.gd missing _on_restore_all_pressed function")
		quit(1)
		return
	print("  [T161.3] settings_menu.gd has _on_restore_all_pressed handler (OK)")

	# T161.4 — _on_restore_all_pressed resets all 3 subsystems (keys, audio, autosave)
	var orap_idx := sm_src.find("func _on_restore_all_pressed()")
	var orap_block := sm_src.substr(orap_idx, 3500)
	for key in ["_DEFAULT_BINDINGS", "linear_to_db", "SaveSystem.set_autosave_enabled"]:
		if orap_block.find(key) == -1:
			print("  FAIL [T161.4]: _on_restore_all_pressed missing reference to '%s'" % key)
			quit(1)
			return
	print("  [T161.4] _on_restore_all_pressed resets keys + audio + autosave (OK)")

	# T161.5 — _restore_all_btn pressed signal is connected
	if sm_src.find("_restore_all_btn.pressed.connect(_on_restore_all_pressed)") == -1:
		print("  FAIL [T161.5]: _restore_all_btn.pressed not connected to _on_restore_all_pressed")
		quit(1)
		return
	print("  [T161.5] _restore_all_btn.pressed wired to _on_restore_all_pressed (OK)")

	# ===== F003 assertions =====

	# F003.1 — godot/README.md has Python 3.14+ warning
	var gdm_src := ""
	var gdf := FileAccess.open("res://godot/README.md", FileAccess.READ)
	if gdf:
		gdm_src = gdf.get_as_text()
		gdf.close()
	if gdm_src.find("Python 3.14+") == -1:
		print("  FAIL [F003.1]: godot/README.md missing 'Python 3.14+' warning")
		quit(1)
		return
	print("  [F003.1] godot/README.md has 'Python 3.14+' warning (OK)")

	# F003.2 — godot/README.md has unzip -FF as preferred fallback (B-1)
	if gdm_src.find("unzip -FF") == -1:
		print("  FAIL [F003.2]: godot/README.md missing 'unzip -FF' fallback")
		quit(1)
		return
	print("  [F003.2] godot/README.md recommends 'unzip -FF' as B-1 fallback (OK)")

	# F003.3 — README.md (en) has Python 3.14+ note
	var rm_src := ""
	var rmf := FileAccess.open("res://README.md", FileAccess.READ)
	if rmf:
		rm_src = rmf.get_as_text()
		rmf.close()
	if rm_src.find("Python 3.14+") == -1:
		print("  FAIL [F003.3]: README.md (en) missing 'Python 3.14+' note")
		quit(1)
		return
	print("  [F003.3] README.md (en) has 'Python 3.14+' note (OK)")

	# F003.4 — README.zh-CN.md (zh) has Python 3.14+ note
	var rmz_src := ""
	var rmzf := FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	if rmzf:
		rmz_src = rmzf.get_as_text()
		rmzf.close()
	if rmz_src.find("Python 3.14+") == -1:
		print("  FAIL [F003.4]: README.zh-CN.md (zh) missing 'Python 3.14+' note")
		quit(1)
		return
	print("  [F003.4] README.zh-CN.md (zh) has 'Python 3.14+' note (OK)")

	# F003.5 — CONTRIBUTING.md has Python 3.14+ note
	var ct_src := ""
	var ctf := FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	if ctf:
		ct_src = ctf.get_as_text()
		ctf.close()
	if ct_src.find("Python 3.14+") == -1:
		print("  FAIL [F003.5]: CONTRIBUTING.md missing 'Python 3.14+' note")
		quit(1)
		return
	print("  [F003.5] CONTRIBUTING.md has 'Python 3.14+' note (OK)")

	print("=== D001 + T160 + T161 + F003 smoke test PASSED (all assertions) ===")
	quit(0)
