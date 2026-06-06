extends SceneTree

## Smoke test for EchoAbility class — verifies instantiation, method
## signatures, and signal definitions. Uses a real CharacterBody2D
## stand-in but stubs out the GameState autoload by NOT calling
## start_echo() (which would touch resonance). We just verify the
## ability is well-formed.

func _initialize() -> void:
	print("=== echo_ability class smoke test ===")

	# Verify class_name is set (i.e. EchoAbility is recognized)
	var echo_script := load("res://src/scripts/echo_ability.gd")
	if echo_script == null:
		print("  FAIL: cannot load script")
		quit(1)
		return
	print("  Script loaded OK: %s" % echo_script.resource_path)

	# Verify class has all expected exports
	var expected_exports := [
		"echo_radius", "echo_cost", "cooldown",
		"windup_time", "active_time", "reflect_speed_multiplier",
		"reflect_damage", "enemy_knockback", "enemy_stun_duration"
	]
	for prop in expected_exports:
		if not (prop in echo_script.get_script_property_list().map(func(p): return p.name)):
			print("  FAIL: missing export %s" % prop)
			quit(1)
			return
	print("  All %d exports present" % expected_exports.size())

	# Verify class has all expected methods
	# We instantiate a dummy to call get_method_list() (a Script's static
	# has_method() does NOT include its own functions, only autoload/
	# engine methods. We have to instantiate and call get_method_list()).
	var inst: Node = echo_script.new()
	var method_names := []
	for m in inst.get_method_list():
		method_names.append(m.name)
	inst.free()
	var expected_methods := [
		"can_echo", "start_echo", "is_shield_active",
		"get_cooldown_ratio", "is_winding_up"
	]
	for m in expected_methods:
		if not (m in method_names):
			print("  FAIL: missing method %s" % m)
			quit(1)
			return
	print("  All %d methods present" % expected_methods.size())

	# Verify signals are declared
	var expected_signals := [
		"echo_fired", "echo_hit", "echo_blocked", "echo_expired"
	]
	var signals_found := []
	for s in echo_script.get_script_signal_list():
		signals_found.append(s.name)
	for sig in expected_signals:
		if not (sig in signals_found):
			print("  FAIL: missing signal %s" % sig)
			quit(1)
			return
	print("  All %d signals present" % expected_signals.size())

	# Verify can_echo() and is_shield_active() on a fresh instance
	var player := CharacterBody2D.new()
	root.add_child(player)
	var echo = echo_script.new()
	player.add_child(echo)
	await process_frame

	if echo.is_shield_active():
		print("  FAIL: fresh instance should not be active")
		quit(1)
		return
	print("  Fresh instance: not active (OK)")

	if echo.is_winding_up():
		print("  FAIL: fresh instance should not be winding up")
		quit(1)
		return
	print("  Fresh instance: not winding up (OK)")

	# Cooldown ratio on a fresh instance should be 0
	var ratio: float = echo.get_cooldown_ratio()
	if ratio != 0.0:
		print("  FAIL: fresh cooldown ratio should be 0, got %f" % ratio)
		quit(1)
		return
	print("  Fresh cooldown ratio: 0.0 (OK)")

	player.queue_free()
	await process_frame
	print("=== smoke test PASSED ===")
	quit(0)
