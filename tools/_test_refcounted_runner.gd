extends SceneTree
# _test_refcounted_runner.gd — Runner for 54 `extends RefCounted` smoke tests
# (T306 #233 + T307 #234 + T308 #236 + T309 #237 + T310 #238 + T311 #239 + T312 #241 + T313 #242 + T315 #244 + T316 #246 + T317 #247 + T318 #248 + T319 #249 + T321 #251 + T322 #252 + T323 #253 + T324 #254 + T325 #256 + T326 #257 + T327 #258 + T328 #259 + T329 #261 + T330 #262 + T331 #263 + T332 #264 + T333 #266 + T334 #267 + T335 #268 + T336 #269 + T337 #271 + T338 #272 + T339 #273 + T340 #274 + T341 #276 + T342 #277 + T343 #278 + T344 #279 + T345 #281 + T346 #282 + T347 #283 + T348 #284 + T349 #286 + T350 #287 + T351 #288 + T352 #289 + T353 #291 + T354 #292 + T355 #293 + T356 #294 + T357 #296 + T358 #297 + T359 #298 + T360 #299 + T361 #301).
# Those test classes use `extends RefCounted` + `class_name` + `run() -> Dictionary`
# and cannot be invoked directly via `godot --headless --script ...` because
# Godot 4 requires the script to inherit from SceneTree or MainLoop.
#
# This wrapper:
#   1. Preloads all 54 RefCounted test classes
#   2. Calls `new().run()` on each
#   3. Aggregates pass/fail counts
#   4. Prints a summary and quits with code 0 (all pass) or 1 (any fail)
#
# 0 真实游戏代码改动 — this file is a tools/ runner, not src/.
# 0 触碰 54 RefCounted test class 任何 1 字符 (T306-T319 + T321 + T322 + T323 + T324 + T325 + T326 + T327 + T328 + T329 + T330 + T331 + T332 + T333 + T334 + T335 + T336 + T337 + T338 + T339 + T340 + T341 + T342 + T343 + T344 + T345 + T346 + T347 + T348 + T349 + T350 + T351 + T352 + T353 + T354 + T355 + T356 + T357 + T358 + T359 + T360 + T361).
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
	preload("res://tools/test_t312_contributing_fragility_section9656_smoke.gd"),
	preload("res://tools/test_t313_contributing_fragility_section9657_smoke.gd"),
	preload("res://tools/test_t315_contributing_fragility_section9658_smoke.gd"),
	preload("res://tools/test_t316_contributing_fragility_section9659_smoke.gd"),
	preload("res://tools/test_t317_contributing_fragility_section9660_smoke.gd"),
	preload("res://tools/test_t318_contributing_fragility_section9661_smoke.gd"),
	preload("res://tools/test_t319_contributing_fragility_section9662_smoke.gd"),
	preload("res://tools/test_t321_contributing_fragility_section9663_smoke.gd"),
	preload("res://tools/test_t322_contributing_fragility_section9664_smoke.gd"),
	preload("res://tools/test_t323_contributing_fragility_section9665_smoke.gd"),
	preload("res://tools/test_t324_contributing_fragility_section9666_smoke.gd"),
	preload("res://tools/test_t325_contributing_fragility_section9667_smoke.gd"),
	preload("res://tools/test_t326_contributing_fragility_section9668_smoke.gd"),
	preload("res://tools/test_t327_contributing_fragility_section9669_smoke.gd"),
	preload("res://tools/test_t328_contributing_fragility_section9670_smoke.gd"),
	preload("res://tools/test_t329_contributing_fragility_section9671_smoke.gd"),
	preload("res://tools/test_t330_contributing_fragility_section9672_smoke.gd"),
	preload("res://tools/test_t331_contributing_fragility_section9673_smoke.gd"),
	preload("res://tools/test_t332_contributing_fragility_section9674_smoke.gd"),
	preload("res://tools/test_t333_contributing_fragility_section9675_smoke.gd"),
	preload("res://tools/test_t334_contributing_fragility_section9676_smoke.gd"),
	preload("res://tools/test_t335_contributing_fragility_section9677_smoke.gd"),
	preload("res://tools/test_t336_contributing_fragility_section9678_smoke.gd"),
	preload("res://tools/test_t337_contributing_fragility_section9679_smoke.gd"),
	preload("res://tools/test_t338_contributing_fragility_section9680_smoke.gd"),
	preload("res://tools/test_t339_contributing_fragility_section9681_smoke.gd"),
	preload("res://tools/test_t340_contributing_fragility_section9682_smoke.gd"),
	preload("res://tools/test_t341_contributing_fragility_section9683_smoke.gd"),
	preload("res://tools/test_t342_contributing_fragility_section9684_smoke.gd"),
	preload("res://tools/test_t343_contributing_fragility_section9685_smoke.gd"),
	preload("res://tools/test_t344_contributing_fragility_section9686_smoke.gd"),
	preload("res://tools/test_t345_contributing_fragility_section9687_smoke.gd"),
	preload("res://tools/test_t346_contributing_fragility_section9688_smoke.gd"),
	preload("res://tools/test_t347_contributing_fragility_section9689_smoke.gd"),
	preload("res://tools/test_t348_contributing_fragility_section9690_smoke.gd"),
	preload("res://tools/test_t349_contributing_fragility_section9691_smoke.gd"),
	preload("res://tools/test_t350_contributing_fragility_section9692_smoke.gd"),
	preload("res://tools/test_t351_contributing_fragility_section9693_smoke.gd"),
	preload("res://tools/test_t352_contributing_fragility_section9694_smoke.gd"),
	preload("res://tools/test_t353_contributing_fragility_section9695_smoke.gd"),
	preload("res://tools/test_t354_contributing_fragility_section9696_smoke.gd"),
	preload("res://tools/test_t355_contributing_fragility_section9697_smoke.gd"),
	preload("res://tools/test_t356_contributing_fragility_section9698_smoke.gd"),
	preload("res://tools/test_t357_contributing_fragility_section9699_smoke.gd"),
	preload("res://tools/test_t358_contributing_fragility_section96100_smoke.gd"),
	preload("res://tools/test_t359_contributing_fragility_section96101_smoke.gd"),
	preload("res://tools/test_t360_contributing_fragility_section96102_smoke.gd"),
	preload("res://tools/test_t361_contributing_fragility_section96103_smoke.gd"),
]

func _initialize() -> void:
	print("=== RefCounted smoke test runner (T306-T319 + T321 + T322 + T323 + T324 + T325 + T326 + T327 + T328 + T329 + T330 + T331 + T332 + T333 + T334 + T335 + T336 + T337 + T338 + T339 + T340 + T341 + T342 + T343 + T344 + T345 + T346 + T347 + T348 + T349 + T350 + T351 + T352 + T353 + T354 + T355 + T356 + T357 + T358 + T359 + T360 + T361) ===")
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
		print("[REFCOUNTED RUNNER PASSED] 54 RefCounted smoke tests all green")
		quit(0)
