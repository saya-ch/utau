extends SceneTree
## T101 + T163 + F004 (#84) — smoke test
##
## 任务组合:
##   T101 Polish: ResonanceWave 命中粒子层叠 8→12 (4 new visual layers)
##   T163 Code:   ScreenShake.flash_color / flash_grayscale 接受可选 [layer] 参数
##   F004 Fix:    修复 3 套件 pre-existing stale-state 冒烟测试 (T147 / F002.7 / F002.8)
##
## 测试目标: 静态分析 (不跑 Play mode, 与 #84 其它 smoke test 风格一致).
##   T101  -- 12 个 layer 数到位 + 4 个新增常量 + painter 顺序约束
##   T163  -- 3 个函数签名都有 `flash_layer: int = 128` 参数
##   F004  -- 3 套件 stale 修复 (本测试是 *新增*, 主要验证 fix 后 PASS
##            + 3 个新加的 D001 sync 断言. 其它两个套件独立运行.)

const T101_PATH := "res://src/scripts/resonance_wave_vfx.gd"
const T163_PATH := "res://src/autoload/screen_shake.gd"
const T147_TEST_PATH := "res://tools/test_t150_t147_t149_smoke.gd"
const F002_TEST_PATH := "res://tools/test_t158_t156_f002_smoke.gd"

func _initialize() -> void:
	print("=== T101+T163+F004 (#84) — ResonanceWave 12-layer + flash layer param + stale-test fix ===")
	var all_ok: bool = true

	# ---------- T101 polish: ResonanceWave 12-layer ----------
	print("--- T101 (Polish: ResonanceWave 命中粒子层叠 8→12) ---")
	var t101_text: String = _read_file(T101_PATH)
	if t101_text.is_empty():
		print("  FAIL: cannot read " + T101_PATH)
		all_ok = false
	else:
		# 1. All 4 new layer constants present
		var consts: Array[String] = [
			"DEEP_SHADOW_RADIUS_RATIO",
			"DEEP_SHADOW_ALPHA",
			"INNER_HALO_RADIUS_RATIO",
			"INNER_HALO_ALPHA",
			"OUTER_WISP_RADIUS_RATIO",
			"OUTER_WISP_ALPHA",
			"OUTER_WISP_COUNT",
			"SPARKLE_RADIUS_RATIO",
			"SPARKLE_COUNT",
			"SPARKLE_BASE_ALPHA",
			"SPARKLE_BLINK_HZ",
			"DEEP_SHADOW_COLOR",
			"INNER_HALO_COLOR",
			"SPARKLE_COLOR",
		]
		for c in consts:
			if ("const " + c) in t101_text:
				pass  # counted below
			else:
				print("  FAIL: T101 missing const " + c)
				all_ok = false
		# 2. Specific numeric values pinned
		if "const OUTER_WISP_COUNT: int = 12" in t101_text:
			print("  PASS: OUTER_WISP_COUNT = 12 (新增外圈刻度 12 条)")
		else:
			print("  FAIL: OUTER_WISP_COUNT != 12 (must match comment in style guide)")
			all_ok = false
		if "const SPARKLE_COUNT: int = 6" in t101_text:
			print("  PASS: SPARKLE_COUNT = 6 (新增顶层亮星 6 颗)")
		else:
			print("  FAIL: SPARKLE_COUNT != 6")
			all_ok = false
		# 3. Painter's order: deep_shadow first, sparkle late, core last
		var d_idx: int = t101_text.find("DEEP_SHADOW_COLOR")
		var h_idx: int = t101_text.find("INNER_HALO_COLOR")
		var s_idx: int = t101_text.find("SPARKLE_COLOR")
		var draw_idx: int = t101_text.find("func _draw()")
		if d_idx > 0 and h_idx > 0 and s_idx > 0 and draw_idx > 0:
			# Inside _draw(), shadow must come before halo, halo before sparkles.
			# (We use draw_string occurrences since the colors are referenced inside _draw() too.)
			var draw_shadow: int = t101_text.find("DEEP_SHADOW_COLOR", draw_idx)
			var draw_halo: int = t101_text.find("INNER_HALO_COLOR", draw_idx)
			var draw_spark: int = t101_text.find("SPARKLE_COLOR", draw_idx)
			if draw_shadow > 0 and draw_halo > draw_shadow and draw_spark > draw_halo:
				print("  PASS: painter order deep→halo→sparkle in _draw() (back to front)")
			else:
				print("  FAIL: painter order broken (deep_shadow @%d, halo @%d, sparkle @%d after draw @%d)" % [draw_shadow, draw_halo, draw_spark, draw_idx])
				all_ok = false
		# 4. _draw references OUTER_WISP_COUNT + SPARKLE_COUNT (i.e. they are used, not dead code)
		if "range(OUTER_WISP_COUNT)" in t101_text and "range(SPARKLE_COUNT)" in t101_text:
			print("  PASS: OUTER_WISP_COUNT + SPARKLE_COUNT are used in _draw() loops")
		else:
			print("  FAIL: OUTER_WISP_COUNT / SPARKLE_COUNT not used in _draw() loops")
			all_ok = false
		# 5. draw_circle/draw_line/draw_arc calls (counting source-level occurrences
		# + loop multipliers, since draw_line/draw_circle only appear once in the
		# source even though they're called 8 / 12 / 6 times per frame).
		# Source occurrences in T101 (post-#84):
		#   draw_circle: 6 (deep_shadow, halo, ring_fill, sparkle_loop, core, bounce_loop)
		#   draw_arc:    1 (ring_stroke)
		#   draw_line:   2 (prism_rays_loop, outer_wisps_loop)
		# Runtime per-frame (with loop multipliers):
		#   draw_circle: 1 + 1 + 1 + 6 + 1 + 0..N = 10..10+N
		#   draw_arc:    1
		#   draw_line:   8 + 12 = 20
		var circle_count: int = t101_text.count("draw_circle")
		var arc_count: int = t101_text.count("draw_arc")
		var line_count: int = t101_text.count("draw_line")
		# We expect at least 6 source-level draw_circle (1 per layer + bounce),
		# at least 1 draw_arc, and at least 2 source-level draw_line (loops
		# expand at runtime to 8 + 12 = 20 per frame).
		if circle_count >= 6 and arc_count >= 1 and line_count >= 2:
			print("  PASS: T101 element budget source: draw_circle=%d (×loop) draw_arc=%d draw_line=%d (×loop=20/frame)" % [circle_count, arc_count, line_count])
		else:
			print("  FAIL: T101 element budget too low: draw_circle=%d draw_arc=%d draw_line=%d" % [circle_count, arc_count, line_count])
			all_ok = false
		# 6. Color hex matches style guide (Pale Resonance / Muted Violet / Amber Voice)
		if 'Color("#65506A")' in t101_text and 'Color("#B7E7DD")' in t101_text and 'Color("#F2B66E")' in t101_text:
			print("  PASS: T101 hex colors match STYLE_GUIDE (Muted Violet / Pale Resonance / Amber Voice)")
		else:
			print("  FAIL: T101 hex colors don't match STYLE_GUIDE")
			all_ok = false
		# 7. Style-guide comment block exists
		if "T101 (#84)" in t101_text and "8→12" in t101_text:
			print("  PASS: T101 has documenting comment block (T101 #84 8→12)")
		else:
			print("  FAIL: T101 missing documenting comment")
			all_ok = false

	# ---------- T163 code: flash_color / flash_grayscale layer param ----------
	print("--- T163 (Code: ScreenShake.flash_* 接受可选 [layer] 参数) ---")
	var t163_text: String = _read_file(T163_PATH)
	if t163_text.is_empty():
		print("  FAIL: cannot read " + T163_PATH)
		all_ok = false
	else:
		# 1. flash_color signature has `flash_layer: int = 128`
		# Match the full signature including the new param
		if "func flash_color(color: Color" in t163_text and "flash_layer: int = 128" in t163_text:
			# Make sure the flash_layer param is part of the flash_color function, not just
			# the flash_grayscale one.  Look for the line right after `func flash_color(`.
			var fc_idx: int = t163_text.find("func flash_color(")
			var fc_body: String = t163_text.substr(fc_idx, 400)
			if "flash_layer: int = 128" in fc_body:
				print("  PASS: flash_color(...) has flash_layer: int = 128 parameter (optional)")
			else:
				print("  FAIL: flash_color signature has flash_layer but not in its own function body")
				all_ok = false
		else:
			print("  FAIL: flash_color missing flash_layer: int = 128 parameter")
			all_ok = false
		# 2. flash_grayscale signature has `flash_layer: int = 128`
		if "func flash_grayscale(duration: float" in t163_text:
			var fg_idx: int = t163_text.find("func flash_grayscale(")
			var fg_body: String = t163_text.substr(fg_idx, 500)
			if "flash_layer: int = 128" in fg_body:
				print("  PASS: flash_grayscale(...) has flash_layer: int = 128 parameter (optional)")
			else:
				print("  FAIL: flash_grayscale signature has flash_layer but not in its own function body")
				all_ok = false
		else:
			print("  FAIL: flash_grayscale signature not found")
			all_ok = false
		# 3. Per-layer active tracking (dict-keyed)
		if "_active_grayscale: Dictionary" in t163_text and "_active_color_flash: Dictionary" in t163_text:
			print("  PASS: _active_grayscale + _active_color_flash are per-layer dicts (was single CanvasLayer)")
		else:
			print("  FAIL: per-layer dict tracking missing")
			all_ok = false
		# 4. stop() iterates and clears all layers
		if "for layer_idx in _active_grayscale.keys()" in t163_text \
			and "for layer_idx in _active_color_flash.keys()" in t163_text \
			and "_active_grayscale.clear()" in t163_text \
			and "_active_color_flash.clear()" in t163_text:
			print("  PASS: stop() iterates and clears all active flash layers (per-layer cleanup)")
		else:
			print("  FAIL: stop() does not iterate per-layer cleanup")
			all_ok = false
		# 5. flash_color uses the param (layer.layer = flash_layer, not hardcoded 128)
		var fc_idx2: int = t163_text.find("func flash_color(")
		var fc_body2: String = t163_text.substr(fc_idx2, 1500)
		if "layer.layer = flash_layer" in fc_body2:
			print("  PASS: flash_color uses flash_layer for CanvasLayer.layer assignment")
		else:
			print("  FAIL: flash_color still hardcodes layer.layer = 128")
			all_ok = false
		# 6. flash_grayscale uses the param
		var fg_idx2: int = t163_text.find("func flash_grayscale(")
		var fg_body2: String = t163_text.substr(fg_idx2, 1500)
		if "layer.layer = flash_layer" in fg_body2:
			print("  PASS: flash_grayscale uses flash_layer for CanvasLayer.layer assignment")
		else:
			print("  FAIL: flash_grayscale still hardcodes layer.layer = 128")
			all_ok = false
		# 7. T163 comment block exists
		if "T163 (#84)" in t163_text and "Optional" in t163_text:
			print("  PASS: T163 has documenting comment (T163 #84 Optional [param flash_layer])")
		else:
			print("  FAIL: T163 missing documenting comment")
			all_ok = false

	# ---------- F004 fix: 3 stale-state smoke tests ----------
	print("--- F004 (Fix: 3 stale-state smoke tests) ---")
	# Sub-1: test_t150_t147_t149_smoke 1800 → 2500 char window
	var t147_text: String = _read_file(T147_TEST_PATH)
	if t147_text.is_empty():
		print("  FAIL: cannot read " + T147_TEST_PATH)
		all_ok = false
	else:
		# The active window value is the second arg to `substr(jump_idx, N)`.
		# Pre-F004: N=1800. Post-F004: N=2500. We look for the post-F004 pattern.
		# (The "1800" string may still appear in comments explaining the change —
		#  that's fine and expected. We only care about the active call.)
		var window_match: int = t147_text.find("substr(jump_idx, 2500)")
		var stale_match: int = t147_text.find("substr(jump_idx, 1800)")
		if window_match > 0 and stale_match < 0:
			if "F004" in t147_text and "T101+T163+F004" not in t147_text:
				print("  PASS: test_t150_t147_t149 jump window expanded 1800 → 2500 chars (F004 #84)")
			else:
				print("  FAIL: test_t150_t147_t149 missing F004 documenting comment")
				all_ok = false
		else:
			print("  FAIL: test_t150_t147_t149 still uses 1800 char window (window=%d, stale=%d)" % [window_match, stale_match])
			all_ok = false
		# Sub-2: D001 sync assertion (PlayerActionGate delegate) added
		if "PlayerActionGate.is_blocked()" in t147_text and "D001 sync" in t147_text:
			print("  PASS: test_t150_t147_t149 has new D001 sync assertion (PlayerActionGate delegate)")
		else:
			print("  FAIL: test_t150_t147_t149 missing D001 sync assertion")
			all_ok = false
	# Sub-3: test_t158_t156_f002 dynamic ITERATION_COUNT - 1
	var f002_text: String = _read_file(F002_TEST_PATH)
	if f002_text.is_empty():
		print("  FAIL: cannot read " + F002_TEST_PATH)
		all_ok = false
	else:
		if "ITERATION_COUNT.txt" in f002_text and "prev_iter_str" in f002_text and "ic_text" in f002_text:
			print("  PASS: test_t158_t156_f002 dynamically reads ITERATION_COUNT.txt - 1 (was hardcoded #81)")
		else:
			print("  FAIL: test_t158_t156_f002 still hardcodes #81 (stale)")
			all_ok = false
		# Verify fallback comment for broken ITERATION_COUNT
		if "fall back" in f002_text or "fallback" in f002_text:
			print("  PASS: test_t158_t156_f002 has fallback path for missing ITERATION_COUNT.txt")
		else:
			print("  FAIL: test_t158_t156_f002 missing fallback for missing ITERATION_COUNT.txt")
			all_ok = false

	if all_ok:
		print("=== ALL T101+T163+F004 (#84) ASSERTIONS PASSED ===")
		quit(0)
	else:
		print("=== T101+T163+F004 (#84) ASSERTIONS FAILED ===")
		quit(1)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content
