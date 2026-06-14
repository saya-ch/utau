extends SceneTree

## T181 + D002.B (#97) — 5 verb 音频 caller 闭环 + 5 verb ability
## base class 继承 smoke test.  Verifies the 5-verb family is wired
## end-to-end:
##   1. AudioManagerEnhanced has all 5 verb play_X() methods (Pulse
##      / Bind / Cut / Echo / Wave)
##   2. Each play_X() is a callable (no parse error when called)
##   3. Each verb ability is a valid script (no parse error after
##      the D002.B refactor)
##   4. Each verb ability extends VerbAbilityBase (D002.B
##      inheritance wiring)
##   5. Each verb ability's _execute_X() calls the matching
##      play_X() method (T181 caller landing)
##   6. _verb_ability_base.gd is parse-clean (no
##      "Identifier windup_time not declared" regression)

func _initialize() -> void:
	print("=== T181 + D002.B (#97) — 5 verb audio caller + base class smoke test ===")

	var all_ok := true

	# 1-2. AudioManagerEnhanced has all 5 verb play_X() methods.
	var ame_script: Script = load("res://src/scripts/audio_manager_enhanced.gd")
	if ame_script == null:
		print("  FAIL: cannot load audio_manager_enhanced.gd")
		all_ok = false
	else:
		var ame_tmp: Node = ame_script.new()
		var play_methods := ["play_pulse", "play_bind", "play_cut", "play_echo", "play_wave_fire"]
		for method in play_methods:
			if not ame_tmp.has_method(method):
				print("  FAIL: AudioManagerEnhanced.%s() method missing" % method)
				all_ok = false
			else:
				print("  PASS: AudioManagerEnhanced.%s() present" % method)
		ame_tmp.free()

	# 3-4. Each verb ability is a valid script + extends VerbAbilityBase.
	var verb_specs := [
		{"path": "res://src/scripts/pulse_ability.gd", "class": "PulseAbility", "play": "play_pulse"},
		{"path": "res://src/scripts/bind_ability.gd", "class": "BindAbility", "play": "play_bind"},
		{"path": "res://src/scripts/cut_ability.gd", "class": "CutAbility", "play": "play_cut"},
		{"path": "res://src/scripts/echo_ability.gd", "class": "EchoAbility", "play": "play_echo"},
		{"path": "res://src/scripts/resonance_wave_ability.gd", "class": "ResonanceWaveAbility", "play": "play_wave_fire"},
	]
	for spec in verb_specs:
		var script: Script = load(spec["path"])
		if script == null:
			print("  FAIL: cannot load %s" % spec["path"])
			all_ok = false
			continue
		# base check: D002.B — each verb extends VerbAbilityBase
		var base_script = script.get_base_script()
		var base_name = ""
		if base_script:
			base_name = base_script.resource_path if base_script.resource_path else base_script.get_global_name()
		# Walk the inheritance chain to find VerbAbilityBase
		var current = script
		var found_base = false
		while current:
			if current.resource_path and current.resource_path.ends_with("_verb_ability_base.gd"):
				found_base = true
				break
			current = current.get_base_script()
		if not found_base:
			print("  FAIL: %s does not extend _verb_ability_base.gd (D002.B)" % spec["class"])
			all_ok = false
		else:
			print("  PASS: %s extends VerbAbilityBase (D002.B)" % spec["class"])

	# 5. T181 — each verb's _execute_X() source contains the matching play_X() caller.
	# We use source-grep because at parse-time there's no autoload so we can't
	# actually trigger _execute_X() in headless mode.
	for spec in verb_specs:
		var f := FileAccess.open(spec["path"], FileAccess.READ)
		if f == null:
			print("  FAIL: cannot read %s" % spec["path"])
			all_ok = false
			continue
		var source := f.get_as_text()
		f.close()
		var needle := "%s()" % spec["play"]
		var found := source.find(needle) >= 0
		if not found:
			print("  FAIL: %s does not call %s (T181 caller missing)" % [spec["class"], needle])
			all_ok = false
		else:
			print("  PASS: %s calls %s (T181 caller landed)" % [spec["class"], needle])

	# 6. _verb_ability_base.gd is parse-clean (no Identifier windup_time regression).
	var base_script: Script = load("res://src/scripts/_verb_ability_base.gd")
	if base_script == null:
		print("  FAIL: cannot load _verb_ability_base.gd")
		all_ok = false
	else:
		# Try to instantiate (will trigger parse if the script is broken).
		# VerbAbilityBase extends Node, so we can .new() and free() it.
		var base_tmp: Node = base_script.new()
		if base_tmp == null:
			print("  FAIL: _verb_ability_base.gd could not be instantiated")
			all_ok = false
		else:
			base_tmp.free()
			print("  PASS: _verb_ability_base.gd parses + instantiates cleanly")

	if all_ok:
		print("=== T181 + D002.B (#97) — ALL OK ===")
		quit(0)
	else:
		print("=== T181 + D002.B (#97) — FAILURES ===")
		quit(1)
