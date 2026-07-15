extends SceneTree
# _test_refcounted_runner.gd — Runner for 6 `extends RefCounted` smoke tests
# (T306 #233 + T307 #234 + T308 #236 + T309 #237 + T310 #238 + T311 #239).
# Those test classes use `extends RefCounted` + `class_name` + `run() -> Dictionary`
# and cannot be invoked directly via `godot --headless --script ...` because
# Godot 4 requires the script to inherit from SceneTree or MainLoop.
#
# This wrapper:
#   1. Preloads all 6 RefCounted test classes
#   2. Calls `new().run()` on each
#   3. Aggregates pass/fail counts
#   4. Prints a summary and quits with code 0 (all pass) or 1 (any fail)
#
# 0 真实游戏代码改动 — this file is a tools/ runner, not src/.
# 0 触碰 6 RefCounted test class 任何 1 字符.
# 0 触碰 src/ 任何 .gd / .tscn 任何 1 字符.
#
# Run: godot --headless --script tools/_test_refcounted_runner.gd

const _REFCOUNTED_TESTS = [
	preload("res://tools/test_t306_contributing_fragility_section9650_smoke.gd"),
	preload("res://tools/test_t307_contributing_fragility_section9651_smoke.gd"),
	preload("res://tools/test_t308_contributing_fragility_section9652_smoke.gd"),
	preload("res://tools/test_t309_contributing_fragility_section9653_smoke.gd"),
	preload("res://tools/test_t310_contributing_fragility_section9654_smoke.gd"),
	preload("res://tools/test_t311_contributing_fragility_section9655_smoke.gd"),
]

func _initialize() -> void:
	print("=== RefCounted smoke test runner (T306-T311) ===")
	var total_passed: int = 0
	var total_failed: int = 0
	var total_skipped: int = 0
	var any_failed: bool = false
	for cls in _REFCOUNTED_TESTS:
		var inst = cls.new()
		var result: Dictionary = inst.run()
		var passed: int = result.get("passed", 0)
		var failed: int = result.get("failed", 0)
		var skipped: int = result.get("skipped", 0)
		var issues: Array = result.get("issues", [])
		var name: String = cls.resource_path.get_file()
		print("  [%s] passed=%d failed=%d skipped=%d" % [name, passed, failed, skipped])
		if issues.size() > 0:
			for issue in issues:
				print("    - %s" % issue)
		total_passed += passed
		total_failed += failed
		total_skipped += skipped
		if failed > 0:
			any_failed = true
	print("=== Total: passed=%d failed=%d skipped=%d ===" % [total_passed, total_failed, total_skipped])
	if any_failed:
		print("[REFCOUNTED RUNNER FAILED]")
		quit(1)
	else:
		print("[REFCOUNTED RUNNER PASSED] 6 RefCounted smoke tests all green")
		quit(0)
