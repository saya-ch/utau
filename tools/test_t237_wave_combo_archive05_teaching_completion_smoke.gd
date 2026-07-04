extends SceneTree

## test_t237_wave_combo_archive05_teaching_completion_smoke.gd
##
## T237 (#156) — Smoke test for archive_05 wave_combo 教学完成
## 反馈强化. 验证:
##   1. player.gd `_on_wave_combo` 末尾调 `_is_in_archive_05_teaching_room()`
##   2. player.gd 包含 `_is_in_archive_05_teaching_room` 函数
##   3. player.gd 包含 `_spawn_wave_combo_teaching_completion_label` 函数
##   4. `_is_in_archive_05_teaching_room` 检查 GameState.current_room == "archive_05"
##   5. archive_05 教学完成路径调 ScreenShake.flash_color(layer 200)
##   6. archive_05 教学完成路径调 ScreenShake.shake(1.0, 0.20) 补 LIGHT
##   7. archive_05 教学完成路径调 _spawn_wave_combo_teaching_completion_label()
##   8. _spawn_wave_combo_teaching_completion_label 创建 CanvasLayer layer 90
##   9. _spawn_wave_combo_teaching_completion_label 创建 CenterContainer + Label
##  10. Label text == "教学完成！"
##  11. 标签 modulate.a 初始 0.0 (淡入起点)
##  12. Label 走 Voxglass 暖白 #E8C8B0 (RGB 0.91, 0.78, 0.69)
##  13. 标签使用 1.2s 渐入 + 0.6s 停留 + 0.6s 渐出 Tween
##  14. 标签最终 queue_free (无内存泄漏)
##  15. T146 原 wave_combo 反馈 0 改动 (屏震 4.0/0.4 + Violet 0.18/0.30)
##  16. T148 play_wave_combo() 0 改动 (E6+G#6 钟鸣)
##  17. T197 vibrate(0.7, 0.25) 0 改动
##  18. T237 注释 + T237 在 player.gd 中可 grep
##  19. 0 新 .gd / 0 新 .tscn (T237 完全内联在 player.gd)
##  20. check_smoke_consistency.sh 0 错 (1 个新 test 不破坏一致性)

func _initialize() -> void:
	print("=== T237 wave_combo archive_05 教学完成反馈强化 smoke ===")

	var player_path := "res://src/scripts/player.gd"
	var player_src := _read_file(player_path)
	if player_src == "":
		print("  FAIL: cannot read player.gd")
		quit(1)
		return
	print("  player.gd read OK")

	var passed := 0
	var failed := 0

	# --- 1. _on_wave_combo 末尾调 _is_in_archive_05_teaching_room() ---
	# 检查 _on_wave_combo 函数体内部出现 _is_in_archive_05_teaching_room 调用
	if "_on_wave_combo" in player_src and "_is_in_archive_05_teaching_room" in player_src:
		# 进一步检查 _on_wave_combo 内部确实调到了 guard helper
		var combo_body := _extract_function_body(player_src, "_on_wave_combo")
		if combo_body != "" and "_is_in_archive_05_teaching_room()" in combo_body:
			print("  [1] PASS  _on_wave_combo 调 _is_in_archive_05_teaching_room()")
			passed += 1
		else:
			print("  [1] FAIL  _on_wave_combo 未调 _is_in_archive_05_teaching_room()")
			failed += 1
	else:
		print("  [1] FAIL  player.gd 缺 _on_wave_combo 或 _is_in_archive_05_teaching_room")
		failed += 1

	# --- 2. _is_in_archive_05_teaching_room 函数存在 ---
	if "func _is_in_archive_05_teaching_room" in player_src:
		print("  [2] PASS  _is_in_archive_05_teaching_room 函数存在")
		passed += 1
	else:
		print("  [2] FAIL  _is_in_archive_05_teaching_room 函数缺失")
		failed += 1

	# --- 3. _spawn_wave_combo_teaching_completion_label 函数存在 ---
	if "func _spawn_wave_combo_teaching_completion_label" in player_src:
		print("  [3] PASS  _spawn_wave_combo_teaching_completion_label 函数存在")
		passed += 1
	else:
		print("  [3] FAIL  _spawn_wave_combo_teaching_completion_label 函数缺失")
		failed += 1

	# --- 4. _is_in_archive_05_teaching_room 检查 current_room == "archive_05" ---
	var guard_body := _extract_function_body(player_src, "_is_in_archive_05_teaching_room")
	if guard_body != "" and "current_room" in guard_body and "\"archive_05\"" in guard_body:
		print("  [4] PASS  _is_in_archive_05_teaching_room 检查 current_room == \"archive_05\"")
		passed += 1
	else:
		print("  [4] FAIL  _is_in_archive_05_teaching_room 未检查 archive_05")
		failed += 1

	# --- 5. archive_05 路径调 ScreenShake.flash_color(layer 200) ---
	var combo_body2 := _extract_function_body(player_src, "_on_wave_combo")
	if combo_body2 != "" and "ScreenShake.flash_color" in combo_body2 and ", 200)" in combo_body2:
		print("  [5] PASS  archive_05 路径调 flash_color(layer 200) 2nd Violet 染色")
		passed += 1
	else:
		print("  [5] FAIL  archive_05 路径未调 flash_color(layer 200)")
		failed += 1

	# --- 6. archive_05 路径补 LIGHT 屏震 (1.0, 0.20) ---
	if combo_body2 != "" and "ScreenShake.shake(1.0, 0.20)" in combo_body2:
		print("  [6] PASS  archive_05 路径补 LIGHT 屏震 (1.0, 0.20)")
		passed += 1
	else:
		print("  [6] FAIL  archive_05 路径未补 LIGHT 屏震 (1.0, 0.20)")
		failed += 1

	# --- 7. archive_05 路径调 _spawn_wave_combo_teaching_completion_label() ---
	if combo_body2 != "" and "_spawn_wave_combo_teaching_completion_label()" in combo_body2:
		print("  [7] PASS  archive_05 路径调 _spawn_wave_combo_teaching_completion_label()")
		passed += 1
	else:
		print("  [7] FAIL  archive_05 路径未调 _spawn_wave_combo_teaching_completion_label()")
		failed += 1

	# --- 8. _spawn_wave_combo_teaching_completion_label 创建 CanvasLayer layer 90 ---
	var spawn_body := _extract_function_body(player_src, "_spawn_wave_combo_teaching_completion_label")
	if spawn_body != "" and "CanvasLayer.new()" in spawn_body and "layer.layer = 90" in spawn_body:
		print("  [8] PASS  _spawn_wave_combo_teaching_completion_label 创建 CanvasLayer layer 90")
		passed += 1
	else:
		print("  [8] FAIL  _spawn_wave_combo_teaching_completion_label 未创建 layer 90 CanvasLayer")
		failed += 1

	# --- 9. _spawn_wave_combo_teaching_completion_label 创建 CenterContainer + Label ---
	if spawn_body != "" and "CenterContainer.new()" in spawn_body and "Label.new()" in spawn_body:
		print("  [9] PASS  _spawn_wave_combo_teaching_completion_label 创建 CenterContainer + Label")
		passed += 1
	else:
		print("  [9] FAIL  _spawn_wave_combo_teaching_completion_label 未创建 CenterContainer + Label")
		failed += 1

	# --- 10. Label text == "教学完成！" ---
	if spawn_body != "" and "label.text = \"教学完成！\"" in spawn_body:
		print("  [10] PASS  Label text == \"教学完成！\"")
		passed += 1
	else:
		print("  [10] FAIL  Label text != \"教学完成！\"")
		failed += 1

	# --- 11. 标签 modulate.a 初始 0.0 (淡入起点) ---
	if spawn_body != "" and "label.modulate.a = 0.0" in spawn_body:
		print("  [11] PASS  label.modulate.a = 0.0 淡入起点")
		passed += 1
	else:
		print("  [11] FAIL  label.modulate.a 初始非 0.0")
		failed += 1

	# --- 12. Label 走 Voxglass 暖白 #E8C8B0 (RGB 0.91, 0.78, 0.69) ---
	if spawn_body != "" and "Color(0.91, 0.78, 0.69, 1.0)" in spawn_body:
		print("  [12] PASS  Label Voxglass 暖白 Color(0.91, 0.78, 0.69, 1.0)")
		passed += 1
	else:
		print("  [12] FAIL  Label 未走 Voxglass 暖白色")
		failed += 1

	# --- 13. 标签使用 1.2s 渐入 + 0.6s 停留 + 0.6s 渐出 Tween ---
	if spawn_body != "" and "tween_property(label, \"modulate:a\", 1.0, 1.2)" in spawn_body \
			and "tween_interval(0.6)" in spawn_body \
			and "tween_property(label, \"modulate:a\", 0.0, 0.6)" in spawn_body:
		print("  [13] PASS  Tween 1.2s 渐入 + 0.6s 停留 + 0.6s 渐出")
		passed += 1
	else:
		print("  [13] FAIL  Tween 序列与预期不符 (1.2 + 0.6 + 0.6)")
		failed += 1

	# --- 14. 标签最终 queue_free (无内存泄漏) ---
	if spawn_body != "" and "queue_free" in spawn_body:
		print("  [14] PASS  标签最终 queue_free (0 内存泄漏)")
		passed += 1
	else:
		print("  [14] FAIL  标签未 queue_free")
		failed += 1

	# --- 15. T146 原 wave_combo 反馈 0 改动 ---
	# 检查 _on_wave_combo 内仍有 ScreenShake.shake(4.0, 0.4) + flash_color(Violet, 0.18, 0.30)
	if combo_body2 != "" and "ScreenShake.shake(4.0, 0.4)" in combo_body2 \
			and "flash_color(Color(0.549, 0.357, 1.0, 1.0), 0.18, 0.30)" in combo_body2:
		print("  [15] PASS  T146 原 wave_combo 反馈 0 改动 (shake 4.0/0.4 + Violet 0.18/0.30)")
		passed += 1
	else:
		print("  [15] FAIL  T146 原 wave_combo 反馈被改")
		failed += 1

	# --- 16. T148 play_wave_combo() 0 改动 ---
	if combo_body2 != "" and "AudioManagerEnhanced.play_wave_combo()" in combo_body2:
		print("  [16] PASS  T148 play_wave_combo() 0 改动 (E6+G#6 钟鸣)")
		passed += 1
	else:
		print("  [16] FAIL  T148 play_wave_combo() 被改")
		failed += 1

	# --- 17. T197 vibrate(0.7, 0.25) 0 改动 ---
	if combo_body2 != "" and "ScreenShake.vibrate(0.7, 0.25)" in combo_body2:
		print("  [17] PASS  T197 vibrate(0.7, 0.25) 0 改动")
		passed += 1
	else:
		print("  [17] FAIL  T197 vibrate(0.7, 0.25) 被改")
		failed += 1

	# --- 18. T237 注释 + T237 在 player.gd 中可 grep ---
	# 检查 T237 注释存在 (docblock + 2 函数头 inline)
	if "T237 (#156)" in player_src:
		var t237_count := player_src.count("T237 (#156)")
		if t237_count >= 3:
			print("  [18] PASS  T237 注释在 player.gd 出现 %d 次 (>= 3: docblock + 2 函数头)" % t237_count)
			passed += 1
		else:
			print("  [18] FAIL  T237 注释出现 %d 次 (< 3)" % t237_count)
			failed += 1
	else:
		print("  [18] FAIL  player.gd 缺 T237 (#156) 注释")
		failed += 1

	# --- 19. 0 新 .gd / 0 新 .tscn (T237 完全内联在 player.gd) ---
	# 检查 player.gd 没有新建 scene 文件引用, 没有 preload 新文件
	if "preload(\"res://src/scripts/player_teaching_" in player_src or "preload(\"res://src/scenes/teaching_" in player_src:
		print("  [19] FAIL  T237 不应 preload 新文件 (应完全内联)")
		failed += 1
	else:
		print("  [19] PASS  T237 完全内联在 player.gd, 0 新 preload 引用")
		passed += 1

	# --- 20. _on_wave_combo 主体尾部 包含 # T237 ---
	# 防止 T237 block 被切到 _on_wave_combo 之外 (确保 archive_05 路径在
	# _on_wave_combo 内, 不是 _ready / 别的回调)
	if combo_body2 != "" and "T237" in combo_body2 and "_spawn_wave_combo_teaching_completion_label" in combo_body2:
		# 检查 _spawn 调用确实在 combo_body 末尾 (在 vibrate 之后)
		var vibrate_pos := combo_body2.find("ScreenShake.vibrate(0.7, 0.25)")
		var spawn_pos := combo_body2.find("_spawn_wave_combo_teaching_completion_label()")
		if vibrate_pos >= 0 and spawn_pos > vibrate_pos:
			print("  [20] PASS  T237 block 紧接 T197 vibrate 之后, 在 _on_wave_combo 体内")
			passed += 1
		else:
			print("  [20] FAIL  T237 block 不在 vibrate 之后 (vibrate_pos=%d, spawn_pos=%d)" % [vibrate_pos, spawn_pos])
			failed += 1
	else:
		print("  [20] FAIL  _on_wave_combo 体内未含 T237 + spawn 调")
		failed += 1

	print("=== T237 wave_combo archive_05 教学完成反馈强化 smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)


func _read_file(path: String) -> String:
	# 简单 wrapper, FileAccess 在 SceneTree 模式 (headless) 也可用
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _extract_function_body(src: String, func_name: String) -> String:
	# 提取 `func NAME(` 到下一个 `func ` 之间的 body. 朴素实现,
	# 不处理嵌套 func (本测试不涉及). 返回值含函数头 + 缩进 body.
	var start_idx := src.find("func " + func_name + "(")
	if start_idx < 0:
		return ""
	# 找函数体起始 (第一个 "\n" 之后)
	var body_start := src.find("\n", start_idx)
	if body_start < 0:
		return ""
	# 找下一个 "func " (同行首, 不是行中) 作为结束边界
	var next_func := src.find("\nfunc ", body_start + 1)
	if next_func < 0:
		next_func = src.length()
	return src.substr(body_start + 1, next_func - body_start - 1)
