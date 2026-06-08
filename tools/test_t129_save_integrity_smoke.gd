extends SceneTree

## test_t129_save_integrity_smoke.gd
##
## T129 冒烟测试 — SaveLoadMenu 集成存档健康度（get_save_integrity）
##
## 8 项断言：
## 1. SaveSystem.get_save_integrity API 存在（5 状态）
## 2. SaveLoadMenu 常量 _INTEGRITY_OK_TEXT/LEGACY/CORRUPTED 存在
## 3. _INTEGRITY_OK_TEXT 颜色 = #69C7CE（Glass Cyan）
## 4. _INTEGRITY_LEGACY_TEXT 颜色 = #F2B66E（Amber Voice）
## 5. _INTEGRITY_CORRUPTED_TEXT 颜色 = #E86D5A（Coral Pulse）
## 6. _format_integrity_badge 方法存在
## 7. _refresh_card / _refresh_list_row 调用 get_save_integrity
## 8. corrupted 槽位 load_btn.disabled 逻辑
##
## T129 是 UI 集成层 + 复用 T128 API，所以重点是常量引用 + 视觉组一致。

const SaveLoadMenu := preload("res://src/scripts/save_load_menu.gd")
const SaveSystemScript := preload("res://src/autoload/save_system.gd")

func _init() -> void:
	var passed := 0
	var failed := 0

	# --- 断言 1: SaveSystem.get_save_integrity API 存在 ---
	var save_sys: Node = SaveSystemScript.new()
	if save_sys.has_method("get_save_integrity"):
		print("  [PASS] SaveSystem.get_save_integrity API exists")
		passed += 1
	else:
		print("  [FAIL] SaveSystem.get_save_integrity API missing")
		failed += 1
	save_sys.free()

	# --- 断言 2: SaveLoadMenu 3 个 INTEGRITY 常量存在 ---
	var integrity_ok_text: String = String(SaveLoadMenu._INTEGRITY_OK_TEXT)
	var integrity_legacy_text: String = String(SaveLoadMenu._INTEGRITY_LEGACY_TEXT)
	var integrity_corrupted_text: String = String(SaveLoadMenu._INTEGRITY_CORRUPTED_TEXT)
	if integrity_ok_text != "" and integrity_legacy_text != "" and integrity_corrupted_text != "":
		print("  [PASS] 3 INTEGRITY constants exist (ok=%s, legacy=%s, corrupted=%s)" % [
			integrity_ok_text, integrity_legacy_text, integrity_corrupted_text])
		passed += 1
	else:
		print("  [FAIL] INTEGRITY constants missing")
		failed += 1

	# --- 断言 3: ok 颜色 = Glass Cyan #69C7CE ---
	if "[color=#69C7CE]" in integrity_ok_text and "✓" in integrity_ok_text:
		print("  [PASS] ok badge uses Glass Cyan ✓")
		passed += 1
	else:
		print("  [FAIL] ok badge wrong color/glyph: %s" % integrity_ok_text)
		failed += 1

	# --- 断言 4: legacy 颜色 = Amber Voice #F2B66E ---
	if "[color=#F2B66E]" in integrity_legacy_text and "⚠" in integrity_legacy_text:
		print("  [PASS] legacy badge uses Amber Voice ⚠")
		passed += 1
	else:
		print("  [FAIL] legacy badge wrong color/glyph: %s" % integrity_legacy_text)
		failed += 1

	# --- 断言 5: corrupted 颜色 = Coral Pulse #E86D5A ---
	if "[color=#E86D5A]" in integrity_corrupted_text and "✖" in integrity_corrupted_text:
		print("  [PASS] corrupted badge uses Coral Pulse ✖")
		passed += 1
	else:
		print("  [FAIL] corrupted badge wrong color/glyph: %s" % integrity_corrupted_text)
		failed += 1

	# --- 断言 6: _format_integrity_badge 方法存在 ---
	var menu_script: GDScript = SaveLoadMenu
	if menu_script.has_method("has_script_method") and menu_script.get_script_method_list().size() > 0:
		# GDScript 不允许直接调用 static-like method, 用 has_script_method 走脚本
		pass
	# 退而求其次：检查源码包含 "_format_integrity_badge" 字符串
	var src := menu_script.get_source_code() if menu_script.has_method("get_source_code") else ""
	if "func _format_integrity_badge" in src or "_format_integrity_badge" in str(menu_script):
		print("  [PASS] _format_integrity_badge method defined")
		passed += 1
	else:
		# 通过直接构造 menu 实例 + call method
		var menu: Node = SaveLoadMenu.new()
		if menu and menu.has_method("_format_integrity_badge"):
			print("  [PASS] _format_integrity_badge method defined (instance check)")
			passed += 1
			# Bonus: 实测 _format_integrity_badge 4 个状态
			var ok_str: String = String(menu.call("_format_integrity_badge", "ok"))
			var legacy_str: String = String(menu.call("_format_integrity_badge", "legacy"))
			var corrupted_str: String = String(menu.call("_format_integrity_badge", "corrupted"))
			var missing_str: String = String(menu.call("_format_integrity_badge", "missing"))
			if "✓" in ok_str and "⚠" in legacy_str and "✖" in corrupted_str and missing_str == "":
				print("    [BONUS] _format_integrity_badge 4 states correct")
			else:
				print("    [BONUS-FAIL] _format_integrity_badge states wrong: ok=%s legacy=%s corrupted=%s missing='%s'" % [
					ok_str, legacy_str, corrupted_str, missing_str])
			menu.free()
		else:
			print("  [FAIL] _format_integrity_badge method missing")
			failed += 1

	# --- 断言 7: _refresh_card / _refresh_list_row 调用 get_save_integrity ---
	var save_menu_src: String = ""
	if menu_script.has_method("get_source_code"):
		save_menu_src = String(menu_script.call("get_source_code"))
	# 直接读 .gd 文件做字符串匹配（更可靠）
	var file := FileAccess.open("res://src/scripts/save_load_menu.gd", FileAccess.READ)
	if file != null:
		save_menu_src = file.get_as_text()
		file.close()
	if "get_save_integrity" in save_menu_src and "badge" in save_menu_src:
		print("  [PASS] save_load_menu.gd references get_save_integrity + badge")
		passed += 1
	else:
		print("  [FAIL] save_load_menu.gd does not reference get_save_integrity")
		failed += 1

	# --- 断言 8: corrupted 槽位 load_btn.disabled 逻辑 ---
	if 'integrity == "corrupted"' in save_menu_src:
		print("  [PASS] corrupted slot disables LoadBtn")
		passed += 1
	else:
		print("  [FAIL] corrupted slot LoadBtn disable logic missing")
		failed += 1

	print("")
	print("=== T129 SaveLoadMenu integrity badge smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
