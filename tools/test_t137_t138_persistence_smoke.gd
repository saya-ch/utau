extends SceneTree
## T137+T138 冒烟测试 — 验证 SaveSystem._last_autosave_unix +
## get_last_autosave_unix() + SaveLoadMenu.QuickLoadButton + PauseMenu
## ProfileAutoSave 显示逻辑。

func _init() -> void:
	var errors: Array[String] = []
	var checks: Array[String] = []

	# 1. SaveSystem — _last_autosave_unix 字段 + get_last_autosave_unix getter
	var save_src := FileAccess.get_file_as_string("res://src/autoload/save_system.gd")
	if "_last_autosave_unix: int = 0" in save_src:
		checks.append("SaveSystem._last_autosave_unix field declared ✓")
	else:
		errors.append("SaveSystem._last_autosave_unix field missing")
	if "func get_last_autosave_unix() -> int:" in save_src:
		checks.append("SaveSystem.get_last_autosave_unix() API ✓")
	else:
		errors.append("SaveSystem.get_last_autosave_unix() API missing")
	# T137+T138 — _do_autosave_tick 末尾当 ok=true 时写 _last_autosave_unix
	if "_last_autosave_unix = int(Time.get_unix_time_from_system())" in save_src:
		checks.append("_last_autosave_unix set in _do_autosave_tick ✓")
	else:
		errors.append("_last_autosave_unix NOT set in _do_autosave_tick")

	# 2. SaveLoadMenu — QuickLoadButton 节点
	var slm_tscn := FileAccess.get_file_as_string("res://src/scenes/save_load_menu.tscn")
	if "QuickLoadButton" in slm_tscn:
		checks.append("SaveLoadMenu.tscn has QuickLoadButton ✓")
	else:
		errors.append("SaveLoadMenu.tscn QuickLoadButton missing")
	# 视觉 — 按钮文本默认含"快速加载最近自动存档"
	if "⚡ 快速加载最近自动存档" in slm_tscn:
		checks.append("SaveLoadMenu.tscn button text ✓")
	else:
		errors.append("SaveLoadMenu.tscn button text missing")
	# 默认 hidden（_ready 时按 _last_autosave_unix 决定）
	var idx := slm_tscn.find("[node name=\"QuickLoadButton\"")
	if idx > 0:
		var block := slm_tscn.substr(idx, 600)
		if "visible = false" in block:
			checks.append("SaveLoadMenu.tscn QuickLoadButton default hidden ✓")
		else:
			errors.append("SaveLoadMenu.tscn QuickLoadButton NOT default hidden (no visible=false in 600 chars after node decl)")
	else:
		errors.append("SaveLoadMenu.tscn QuickLoadButton node decl not found")

	# 3. SaveLoadMenu — _quick_load_btn @onready + _on_quick_load handler
	var slm_src := FileAccess.get_file_as_string("res://src/scripts/save_load_menu.gd")
	if "@onready var _quick_load_btn" in slm_src:
		checks.append("SaveLoadMenu._quick_load_btn @onready ✓")
	else:
		errors.append("SaveLoadMenu._quick_load_btn @onready missing")
	if "func _on_quick_load" in slm_src:
		checks.append("SaveLoadMenu._on_quick_load handler ✓")
	else:
		errors.append("SaveLoadMenu._on_quick_load handler missing")
	if "func _refresh_quick_load_btn" in slm_src:
		checks.append("SaveLoadMenu._refresh_quick_load_btn ✓")
	else:
		errors.append("SaveLoadMenu._refresh_quick_load_btn missing")
	# _on_quick_load 走 SaveSystem.get_last_autosave_unix + get_autosave_slot
	if "SaveSystem.get_last_autosave_unix()" in slm_src and "SaveSystem.get_autosave_slot()" in slm_src:
		checks.append("SaveLoadMenu quick load uses SaveSystem APIs ✓")
	else:
		errors.append("SaveLoadMenu quick load missing SaveSystem API calls")
	# Signal connect
	if "_quick_load_btn.pressed.connect(_on_quick_load)" in slm_src:
		checks.append("SaveLoadMenu quick load signal connected ✓")
	else:
		errors.append("SaveLoadMenu quick load signal NOT connected")

	# 4. PauseMenu — ProfileAutoSave 节点
	var pm_tscn := FileAccess.get_file_as_string("res://src/scenes/pause_menu.tscn")
	if "ProfileAutoSave" in pm_tscn:
		checks.append("PauseMenu.tscn has ProfileAutoSave ✓")
	else:
		errors.append("PauseMenu.tscn ProfileAutoSave missing")
	# 默认文本是 "上次自动存档  —" 占位
	if "上次自动存档  —" in pm_tscn:
		checks.append("PauseMenu.tscn default placeholder ✓")
	else:
		errors.append("PauseMenu.tscn default placeholder missing")
	# 位置在 ProfileShareButton 之后，HSep1 之前
	var idx_share := pm_tscn.find("ProfileShareButton")
	var idx_autosave := pm_tscn.find("ProfileAutoSave")
	var idx_hsep1 := pm_tscn.find("HSep1")
	if idx_share > 0 and idx_autosave > idx_share and idx_autosave < idx_hsep1:
		checks.append("PauseMenu.tscn ProfileAutoSave between Share+HSep1 ✓")
	else:
		errors.append("PauseMenu.tscn ProfileAutoSave position wrong (share=%d autosave=%d hsep1=%d)" % [idx_share, idx_autosave, idx_hsep1])

	# 5. PauseMenu — _profile_auto_save @onready + _refresh_profile 中填充
	var pm_src := FileAccess.get_file_as_string("res://src/scripts/pause_menu.gd")
	if "@onready var _profile_auto_save" in pm_src:
		checks.append("PauseMenu._profile_auto_save @onready ✓")
	else:
		errors.append("PauseMenu._profile_auto_save @onready missing")
	if '上次自动存档  %02d:%02d:%02d' in pm_src:
		checks.append("PauseMenu._profile_auto_save HH:MM:SS format ✓")
	else:
		errors.append("PauseMenu._profile_auto_save HH:MM:SS format missing")
	# _refresh_profile 中调 SaveSystem.get_last_autosave_unix
	if "SaveSystem.get_last_autosave_unix()" in pm_src:
		checks.append("PauseMenu reads SaveSystem.get_last_autosave_unix ✓")
	else:
		errors.append("PauseMenu does NOT read SaveSystem.get_last_autosave_unix")

	# Print
	print("=== T137+T138 persistence smoke ===")
	for c in checks:
		print("  ", c)
	if errors.size() > 0:
		print("FAILED:")
		for e in errors:
			print("  - ", e)
		print("=== T137+T138 FAILED: %d errors ===" % errors.size())
		quit(1)
	else:
		print("=== T137+T138 PASS: %d checks ===" % checks.size())
		quit(0)
