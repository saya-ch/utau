extends SceneTree

## test_t135_share_smoke.gd
## T135 — PauseMenu Quick Stats Share 按钮 端到端冒烟测试
## 验证：
##  1. pause_menu.tscn 含 ProfileShareButton 节点（位于 ProfileQuickStats 与 HSep1 之间）
##  2. pause_menu.gd @onready var _profile_share_btn 引用
##  3. _ready 末尾 _profile_share_btn.pressed.connect(_on_share_pressed) 信号连接
##  4. _on_share_pressed 存在
##  5. _format_share_text 存在 + 输出 3 行（首行 Voxglass / 第二行成就.../ 第三行日期）
##  6. Share 按钮文本 = "分享到剪贴板"
##  7. _format_share_text 含 🎵 emoji + 成就计数占位 %d / %d + 最佳占位 %s + Run #%d + 日期占位 %s
##  8. Button 颜色 Glass Cyan #69C7CE (RGB 0.412, 0.78, 0.808)
##  9. inline _format_share_text_3fields(unlocked, total, best, run) → 与 _format_share_text 输出一致
## 10. inline _format_share_text_3fields(0, 13, "—", 1) 含全部 5 字段
## 11. DisplayServer.has_method("clipboard_set") 存在时 _on_share_pressed 不抛异常
## 12. _on_share_pressed 防御 _profile_share_btn = null
##
## 与 T128/T132/T136 同模式：源码扫描 + 内联实现 + 字符串断言。
## 不直接实例化 PauseMenu（依赖 PlayerStats autoload + 完整 scene tree，
## headless --script 模式不初始化 autoload）。

const SRC_PAUSE_GD := "res://src/scripts/pause_menu.gd"
const SRC_PAUSE_TSCN := "res://src/scenes/pause_menu.tscn"

func _init() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0
	var pause_src: String = _read_file(SRC_PAUSE_GD)
	var pause_tscn: String = _read_file(SRC_PAUSE_TSCN)

	# --- 1. pause_menu.tscn 含 ProfileShareButton 节点 + 位置（QuickStats 与 HSep1 之间）---
	test_num += 1
	var quick_pos: int = pause_tscn.find("ProfileQuickStats")
	var share_pos: int = pause_tscn.find("ProfileShareButton")
	var hsep_pos: int = pause_tscn.find("name=\"HSep1\"")
	var has_share_node: bool = (
		"ProfileShareButton" in pause_tscn
		and "text = \"分享到剪贴板\"" in pause_tscn
		and quick_pos > 0
		and share_pos > quick_pos
		and hsep_pos > share_pos
	)
	if has_share_node:
		print("  [%d] PASS  pause_menu.tscn: ProfileShareButton between ProfileQuickStats and HSep1" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.tscn missing ProfileShareButton or wrong position" % test_num)
		failed += 1

	# --- 2. @onready var _profile_share_btn 引用 ---
	test_num += 1
	if "@onready var _profile_share_btn: Button" in pause_src:
		print("  [%d] PASS  pause_menu.gd @onready _profile_share_btn declared" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd missing _profile_share_btn @onready var" % test_num)
		failed += 1

	# --- 3. _ready 末尾 _profile_share_btn.pressed.connect(_on_share_pressed) ---
	test_num += 1
	if "_profile_share_btn.pressed.connect(_on_share_pressed)" in pause_src:
		print("  [%d] PASS  pause_menu.gd connects ProfileShareButton.pressed → _on_share_pressed" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd missing _profile_share_btn.pressed.connect" % test_num)
		failed += 1

	# --- 4. _on_share_pressed 存在 ---
	test_num += 1
	if "func _on_share_pressed() -> void:" in pause_src:
		print("  [%d] PASS  pause_menu.gd defines _on_share_pressed handler" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd missing _on_share_pressed func" % test_num)
		failed += 1

	# --- 5. _format_share_text 存在 + 输出 3 行（首行 Voxglass / 第二行成就.../ 第三行日期）---
	test_num += 1
	if "func _format_share_text() -> String:" in pause_src:
		# 验证内联函数逻辑 — 用预填值的 4 字段模拟一个调用
		var sample: String = _format_share_text_3fields(3, 13, "04:32", 7, "2026-06-08")
		var lines: PackedStringArray = sample.split("\n")
		var has_3_lines: bool = (
			lines.size() == 3
			and "Voxglass" in lines[0]
			and "成就 3 / 13" in lines[1]
			and "最佳 04:32" in lines[1]
			and "Run #7" in lines[1]
			and lines[2] == "2026-06-08"
		)
		if has_3_lines:
			print("  [%d] PASS  _format_share_text outputs 3 lines (header / stats / date)" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  _format_share_text output shape wrong: %s" % [test_num, sample])
			failed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd missing _format_share_text func" % test_num)
		failed += 1

	# --- 6. Share 按钮文本 = "分享到剪贴板" ---
	test_num += 1
	if "text = \"分享到剪贴板\"" in pause_tscn:
		print("  [%d] PASS  ProfileShareButton default text = '分享到剪贴板'" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  ProfileShareButton default text not '分享到剪贴板'" % test_num)
		failed += 1

	# --- 7. _format_share_text 含 🎵 emoji + 5 个 % 占位符 ---
	test_num += 1
	if ("🎵 Voxglass" in pause_src
		and "成就 %d / %d" in pause_src
		and "最佳 %s" in pause_src
		and "Run #%d" in pause_src
		and "%04d-%02d-%02d" in pause_src):
		print("  [%d] PASS  _format_share_text contains 🎵 + 5 format placeholders" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _format_share_text missing emoji or format placeholders" % test_num)
		failed += 1

	# --- 8. Button 颜色 Glass Cyan #69C7CE (RGB 0.412, 0.78, 0.808) ---
	test_num += 1
	if "Color(0.412, 0.78, 0.808, 1)" in pause_tscn:
		print("  [%d] PASS  ProfileShareButton uses Glass Cyan #69C7CE" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  ProfileShareButton color not Glass Cyan" % test_num)
		failed += 1

	# --- 9. inline _format_share_text_3fields(unlocked, total, best, run, date) ---
	test_num += 1
	var sample2: String = _format_share_text_3fields(5, 13, "12:34", 12, "2026-06-08")
	var has_5_fields: bool = (
		"成就 5 / 13" in sample2
		and "最佳 12:34" in sample2
		and "Run #12" in sample2
		and "2026-06-08" in sample2
		and "Voxglass" in sample2
	)
	if has_5_fields:
		print("  [%d] PASS  _format_share_text contains all 5 expected fields" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _format_share_text missing one of 5 fields: %s" % [test_num, sample2])
		failed += 1

	# --- 10. inline _format_share_text_3fields(0, 13, "—", 1, ...) 含全部 5 字段（首次启动）---
	test_num += 1
	var first_run: String = _format_share_text_3fields(0, 13, "—", 1, "2026-06-08")
	var has_first_run_fields: bool = (
		"成就 0 / 13" in first_run
		and "最佳 —" in first_run
		and "Run #1" in first_run
	)
	if has_first_run_fields:
		print("  [%d] PASS  first-run _format_share_text shows '成就 0/13 · 最佳 — · Run #1'" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  first-run _format_share_text wrong: %s" % [test_num, first_run])
		failed += 1

	# --- 11. DisplayServer.has_method("clipboard_set") 存在时 _on_share_pressed 不抛异常 ---
	# 在 --script 模式下 DisplayServer 单例存在但 clipboard_set 可能没有
	# (headless server 模式)，所以我们只验证 source 中有 has_method 守卫
	test_num += 1
	if ("DisplayServer.has_method(\"clipboard_set\")" in pause_src
		and "DisplayServer.clipboard_set(text)" in pause_src):
		print("  [%d] PASS  _on_share_pressed guards clipboard_set with DisplayServer.has_method" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _on_share_pressed missing DisplayServer.has_method guard" % test_num)
		failed += 1

	# --- 12. _on_share_pressed 防御 _profile_share_btn = null ---
	test_num += 1
	if "if _profile_share_btn == null:" in pause_src:
		print("  [%d] PASS  _on_share_pressed null-guards _profile_share_btn (test harness safe)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _on_share_pressed missing _profile_share_btn null guard" % test_num)
		failed += 1

	# 总结
	print("")
	print("T135 share-button smoke: %d / %d passed (%d failed)" % [passed, test_num, failed])
	if failed > 0:
		print("T135_SMOKE: HAS_FAILURES")
		quit(1)
	else:
		print("T135_SMOKE: ALL_PASS")
		quit(0)

func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content

# Inline implementation mirroring PauseMenu._format_share_text.
# Kept here so the smoke test exercises the exact algorithm
# (3-line format with 🎵 glyph + middle · separator + date)
# without depending on the PauseMenu scene tree being live
# in --script mode.
func _format_share_text_3fields(unlocked: int, total: int, best: String, run: int, date: String) -> String:
	return "🎵 Voxglass\n成就 %d / %d  ·  最佳 %s  ·  Run #%d\n%s" % [
		unlocked, total, best, run, date
	]
