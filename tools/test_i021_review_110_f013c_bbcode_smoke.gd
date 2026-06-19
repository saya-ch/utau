## I021 (#110) — REVIEW_#110 修复冒烟测试 (F013.C whole-tone scale + Label bbcode_enabled)
##
## 验证 #110 审查发现的 2 个回归已修复：
##   (A) I011/I017 smoke test 期望值同步 F013.C #109 whole-tone scale
##       (Bind 72→71, Cut 76→73 READY + Bind 76→75, Cut 80→77, Echo 81→79, Wave 85→81 TAIL)
##   (B) save_load_menu.gd 4 处 `_hint_label.bbcode_enabled = true` 移除
##       (Godot 4.6 Label 不支持 bbcode_enabled 属性；BBCode 标记保留 text 中但不解析)
##
## 这是 #109 末尾"57/57 smoke"报告与 #110 实际"55/56 smoke" 之间的回归修复，
## 是审查模式的核心价值 —— 在独立开发节奏中自动捕获漂移。

extends SceneTree

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const SAVE_LOAD_MENU_GD := "res://src/scripts/save_load_menu.gd"
const SAVE_LOAD_MENU_TSCN := "res://src/scenes/save_load_menu.tscn"

var _passes: int = 0
var _fails: int = 0
var _fail_messages: Array[String] = []


func _initialize() -> void:
	print("=== I021 (#110) REVIEW_#110 fix smoke test ===")
	_run_f013c_whole_scale_assertions()
	_run_bbcode_enabled_fix_assertions()
	print("")
	print("--- I021 (#110) REVIEW_#110 fix smoke summary ---")
	print("passes: %d" % _passes)
	print("failures: %d" % _fails)
	for msg in _fail_messages:
		print("FAIL: %s" % msg)
	if _fails == 0:
		print("=== ALL I021 (#110) REVIEW_#110 ASSERTIONS PASSED ===")
		quit(0)
	else:
		quit(1)


# ---------- (A) F013.C whole-tone scale — 5 verb READY + 5 verb TAIL ----------
func _run_f013c_whole_scale_assertions() -> void:
	print("--- F013.C whole-tone scale — 5 verb READY + TAIL ---")
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	# READY jingle 起点 (whole-tone scale 2-semitone spacing)
	_assert_contains(ame_src, "\"pulse\": return 69",
		"F013C.READY.PULSE: pulse READY start MIDI 69 (A4)")
	_assert_contains(ame_src, "\"bind\":  return 71",
		"F013C.READY.BIND: bind READY start MIDI 71 (B4) — F013.C whole-tone")
	_assert_contains(ame_src, "\"cut\":   return 73",
		"F013C.READY.CUT: cut READY start MIDI 73 (C#5) — F013.C whole-tone")
	_assert_contains(ame_src, "\"echo\":  return 75",
		"F013C.READY.ECHO: echo READY start MIDI 75 (D#5) — F013.C whole-tone")
	_assert_contains(ame_src, "\"wave\":  return 77",
		"F013C.READY.WAVE: wave READY start MIDI 77 (F5) — F013.C whole-tone")
	# TAIL jingle 起点 (whole-tone scale mirror, +4 semitones from READY)
	_assert_contains(ame_src, "\"pulse\": return 73",
		"F013C.TAIL.PULSE: pulse TAIL start MIDI 73 (C#5)")
	_assert_contains(ame_src, "\"bind\":  return 75",
		"F013C.TAIL.BIND: bind TAIL start MIDI 75 (D#5) — F013.C whole-tone")
	_assert_contains(ame_src, "\"cut\":   return 77",
		"F013C.TAIL.CUT: cut TAIL start MIDI 77 (F5) — F013.C whole-tone")
	_assert_contains(ame_src, "\"echo\":  return 79",
		"F013C.TAIL.ECHO: echo TAIL start MIDI 79 (G5) — F013.C whole-tone")
	_assert_contains(ame_src, "\"wave\":  return 81",
		"F013C.TAIL.WAVE: wave TAIL start MIDI 81 (A5) — F013.C whole-tone")
	# 旧值（pre-F013.C）必须不再出现，避免 #109 之前的 72/76/80/85 残留
	# 注：echo=79 / wave=81 在 TAIL jingle 中是新值（whole-tone scale 第 4/5 步），
	#     所以"旧值已清"断言必须限定在 READY 段落（出现在 _verb_cooldown_start_midi 函数中）
	var ready_section := _extract_ready_section(ame_src)
	_assert_not_contains(ready_section, "\"bind\":  return 72",
		"F013C.NEG.BIND: 旧 bind=72 (READY) 已清")
	_assert_not_contains(ready_section, "\"cut\":   return 76",
		"F013C.NEG.CUT: 旧 cut=76 (READY) 已清")
	_assert_not_contains(ready_section, "\"echo\":  return 79",
		"F013C.NEG.ECHO: 旧 echo=79 (READY) 已清")
	_assert_not_contains(ready_section, "\"wave\":  return 81",
		"F013C.NEG.WAVE: 旧 wave=81 (READY) 已清")
	var tail_section := _extract_tail_section(ame_src)
	_assert_not_contains(tail_section, "\"bind\":  return 76",
		"F013C.NEG.BIND: 旧 bind=76 (TAIL) 已清")
	_assert_not_contains(tail_section, "\"cut\":   return 80",
		"F013C.NEG.CUT: 旧 cut=80 (TAIL) 已清")
	_assert_not_contains(tail_section, "\"echo\":  return 81",
		"F013C.NEG.ECHO: 旧 echo=81 (TAIL) 已清")
	_assert_not_contains(tail_section, "\"wave\":  return 85",
		"F013C.NEG.WAVE: 旧 wave=85 (TAIL) 已清")


# ---------- (B) Label bbcode_enabled — Godot 4.6 Label 不支持 ----------
func _run_bbcode_enabled_fix_assertions() -> void:
	print("--- Label bbcode_enabled — Godot 4.6 兼容性 ---")
	var slm_src := _read_file(SAVE_LOAD_MENU_GD)
	# save_load_menu.gd 中所有 `xxx.bbcode_enabled = true` 赋值必须全部移除
	# (Label in Godot 4.6 has no bbcode_enabled property)
	# 用 regex 模式匹配 (var).bbcode_enabled =
	var pattern := RegEx.new()
	pattern.compile("(\\w+)\\.bbcode_enabled\\s*=\\s*(true|false)")
	var matches := pattern.search_all(slm_src)
	if matches.size() == 0:
		_pass("BBCODE.GD: save_load_menu.gd 0 个 bbcode_enabled 赋值 (符合 Godot 4.6)")
	else:
		var names: Array[String] = []
		for m in matches:
			names.append(m.get_string(1))
		_fail("BBCODE.GD: save_load_menu.gd 仍有 %d 个 bbcode_enabled 赋值: %s" % [matches.size(), names])
	# 在 tscn 中检查 ConfirmBackdrop/ConfirmPanel 仍可正常工作（无 bbcode_enabled 残留影响）
	var tscn_src := _read_file(SAVE_LOAD_MENU_TSCN)
	_assert_contains(tscn_src, "ConfirmBackdrop",
		"BBCODE.TSCN: ConfirmBackdrop 节点保留（不受 bbcode_enabled 清理影响）")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


# 提取 READY 段落：从 _verb_cooldown_start_midi 函数开始到下一个 func def 之前
func _extract_ready_section(src: String) -> String:
	var start := src.find("func _verb_cooldown_start_midi")
	if start < 0:
		return ""
	# 找下一个顶级 func 声明（缩进为 0 tab）
	var end := src.find("\nfunc ", start + 50)
	if end < 0:
		end = src.length()
	return src.substr(start, end - start)


# 提取 TAIL 段落：从 _verb_cooldown_tail_start_midi 函数开始到下一个 func def 之前
func _extract_tail_section(src: String) -> String:
	var start := src.find("func _verb_cooldown_tail_start_midi")
	if start < 0:
		return ""
	var end := src.find("\nfunc ", start + 50)
	if end < 0:
		end = src.length()
	return src.substr(start, end - start)


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.contains(needle):
		_pass(label)
	else:
		_fail("%s — needle '%s' not found" % [label, needle])


func _assert_not_contains(haystack: String, needle: String, label: String) -> void:
	if not haystack.contains(needle):
		_pass(label)
	else:
		_fail("%s — needle '%s' still present (regression)" % [label, needle])


func _pass(label: String) -> void:
	_passes += 1
	print("  ✓ %s" % label)


func _fail(label: String) -> void:
	_fails += 1
	_fail_messages.append(label)
	print("  ✗ %s" % label)
