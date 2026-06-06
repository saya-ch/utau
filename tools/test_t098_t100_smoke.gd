extends SceneTree
## T098/T100 集成冒烟测试 — 验证 Pulse/Cut 命中信号 → flash_color 调
## 用 + pause_menu Echo 反弹行 theme_color_override 逻辑。

func _init() -> void:
	var errors: Array[String] = []
	var checks: Array[String] = []

	# 1. player.gd._on_pulse_hit / _on_cut_hit 存在
	var player_src := FileAccess.get_file_as_string("res://src/scripts/player.gd")
	if "_on_pulse_hit" in player_src:
		checks.append("player._on_pulse_hit defined ✓")
	else:
		errors.append("player._on_pulse_hit missing")
	if "_on_cut_hit" in player_src:
		checks.append("player._on_cut_hit defined ✓")
	else:
		errors.append("player._on_cut_hit missing")
	if "pulse_hit.connect(_on_pulse_hit)" in player_src:
		checks.append("pulse_hit signal connected ✓")
	else:
		errors.append("pulse_hit signal NOT connected")
	if "cut_hit.connect(_on_cut_hit)" in player_src:
		checks.append("cut_hit signal connected ✓")
	else:
		errors.append("cut_hit signal NOT connected")

	# 2. ScreenShake.flash_color API 存在
	var shake_src := FileAccess.get_file_as_string("res://src/autoload/screen_shake.gd")
	if "func flash_color(" in shake_src:
		checks.append("ScreenShake.flash_color API present ✓")
	else:
		errors.append("ScreenShake.flash_color missing")

	# 3. T098 — Pulse 用 Coral Pulse (0.91, 0.427, 0.353)；Cut 用 Amber Voice (0.949, 0.714, 0.431)
	if "Color(0.91, 0.427, 0.353" in player_src:
		checks.append("Pulse Coral Pulse color applied ✓")
	else:
		errors.append("Pulse Coral Pulse color missing")
	if "Color(0.949, 0.714, 0.431" in player_src:
		checks.append("Cut Amber Voice color applied ✓")
	else:
		errors.append("Cut Amber Voice color missing")

	# 4. T100 — pause_menu.gd._refresh_stats 末尾 add_theme_color_override
	var pause_src := FileAccess.get_file_as_string("res://src/scripts/pause_menu.gd")
	if "_stat_reflects.add_theme_color_override" in pause_src and "0.412, 0.78, 0.808" in pause_src:
		checks.append("pause_menu._stat_reflects cyan override ✓")
	else:
		errors.append("pause_menu._stat_reflects cyan override missing")

	# 5. T100 — pause_menu.tscn StatReflects font_color cyan
	var tscn_src := FileAccess.get_file_as_string("res://src/scenes/pause_menu.tscn")
	if "StatReflects" in tscn_src:
		# Search for StatReflects block, then the next font_color line should be cyan
		var idx := tscn_src.find("StatReflects")
		var block := tscn_src.substr(idx, 200)
		if "Color(0.412, 0.78, 0.808, 1)" in block:
			checks.append("pause_menu.tscn StatReflects cyan ✓")
		else:
			errors.append("pause_menu.tscn StatReflects NOT cyan")

	# 6. pulse_ability.gd has pulse_hit signal
	var pulse_src := FileAccess.get_file_as_string("res://src/scripts/pulse_ability.gd")
	if "signal pulse_hit" in pulse_src:
		checks.append("pulse_ability.pulse_hit signal declared ✓")
	else:
		errors.append("pulse_ability.pulse_hit signal missing")

	# 7. cut_ability.gd has cut_hit signal
	var cut_src := FileAccess.get_file_as_string("res://src/scripts/cut_ability.gd")
	if "signal cut_hit" in cut_src:
		checks.append("cut_ability.cut_hit signal declared ✓")
	else:
		errors.append("cut_ability.cut_hit signal missing")

	# Print
	print("=== T098+T100 smoke ===")
	for c in checks:
		print("  ", c)
	if errors.size() > 0:
		print("FAILED:")
		for e in errors:
			print("  - ", e)
		print("=== T098+T100 FAILED: %d errors ===" % errors.size())
		quit(1)
	else:
		print("=== T098+T100 PASS: %d checks ===" % checks.size())
		quit(0)
