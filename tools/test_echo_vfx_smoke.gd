extends SceneTree

## Smoke test for EchoVFX — verifies the shield VFX instantiates,
## triggers, ticks through its lifetime, and queue_frees cleanly.
## No actual rendering verification (headless), but the draw
## callbacks should not throw exceptions.

func _initialize() -> void:
	print("=== echo_vfx smoke test ===")

	var vfx_script := load("res://src/scripts/echo_vfx.gd")
	if vfx_script == null:
		print("  FAIL: cannot load script")
		quit(1)
		return
	print("  Script loaded OK")

	# Verify has trigger and add_bounce_flash methods
	var vfx: Node2D = vfx_script.new()
	root.add_child(vfx)
	if not vfx.has_method("trigger"):
		print("  FAIL: missing trigger()")
		quit(1)
		return
	if not vfx.has_method("add_bounce_flash"):
		print("  FAIL: missing add_bounce_flash()")
		quit(1)
		return
	print("  trigger() and add_bounce_flash() present (OK)")

	# Trigger the VFX — should not throw
	vfx.trigger(Vector2(100, 100), 30.0)
	print("  trigger() called without exception (OK)")

	# Add a bounce flash
	vfx.add_bounce_flash(Vector2(110, 100))
	print("  add_bounce_flash() called without exception (OK)")

	# Tick a few frames to drive _process and _draw callbacks
	for i in range(5):
		await process_frame
	print("  Survived 5 frames of _process + _draw (OK)")

	# Wait for the full lifetime to expire
	await create_timer(1.0).timeout
	if is_instance_valid(vfx):
		print("  FAIL: VFX should have queue_free'd itself")
		quit(1)
		return
	print("  VFX queue_free'd after lifetime (OK)")

	print("=== smoke test PASSED ===")
	quit(0)
