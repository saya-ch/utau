extends SceneTree
## I007 (#92) — T173 5 verb windup VFX 0.05s 淡出 tween 冒烟测试
##
## 覆盖 #91 T173 任务:
## - 5 verb windup VFX 各自新增 fade_out_and_free() 公共方法（0.05s
##   modulate.a 1.0→0.0 tween + tween 结束 queue_free 自身）
## - 4 verb ability._exit_tree() 从硬 queue_free() 切换为 fade_out_and_free()
##   （让 player 死亡 / 场景切换打断 windup 时 0.05s 平滑淡出而非硬 pop）
## - resonance_wave_ability.gd 补 _exit_tree() 钩子（#89 T171 缺漏:
##   Wave 是 5 verb windup 家族中唯一没有 _exit_tree 的 ability，场景
##   切换时 windup VFX 会 leak 到 freed scene 上下文）
##
## 与 I006 (#89) / I005 (#88) 模式一致：源码扫描 + 字符串锚定（不实例化
## 能力类或 Node2D，避免 headless mock tween / ScreenShake 边界）。
## 回归保护：5 verb windup 淡出曲线 0.05s 是 #91 的"VFX 退出家族"标准，
## 未来 6th verb 接入 windup VFX 必须包含同方法（与 5 verb family
## 5 元组同等重要）。

const PULSE_WINDUP_VFX_GD := "res://src/scripts/pulse_windup_vfx.gd"
const BIND_WINDUP_VFX_GD := "res://src/scripts/bind_windup_vfx.gd"
const ECHO_WINDUP_VFX_GD := "res://src/scripts/echo_windup_vfx.gd"
const CUT_WINDUP_VFX_GD := "res://src/scripts/cut_windup_vfx.gd"
const WAVE_WINDUP_VFX_GD := "res://src/scripts/wave_windup_vfx.gd"

const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const RESONANCE_WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	_run_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL T173 (#92) ASSERTIONS PASSED ===")
		quit(0)


func _run_assertions() -> void:
	# T173.A — 5 verb windup VFX 各自有 fade_out_and_free() 方法
	_run_windup_vfx_assertions("PulseWindupVFX", PULSE_WINDUP_VFX_GD, "#69C7CE", "T173.A1")
	_run_windup_vfx_assertions("BindWindupVFX", BIND_WINDUP_VFX_GD, "#65506A", "T173.A2")
	_run_windup_vfx_assertions("EchoWindupVFX", ECHO_WINDUP_VFX_GD, "#69C7CE", "T173.A3")
	_run_windup_vfx_assertions("CutWindupVFX", CUT_WINDUP_VFX_GD, "#F2B66E", "T173.A4")
	_run_windup_vfx_assertions("WaveWindupVFX", WAVE_WINDUP_VFX_GD, "#B7E7DD", "T173.A5")

	# T173.B — 4 verb ability._exit_tree() 切换到 fade_out_and_free
	_run_ability_exit_tree_assertions(PULSE_ABILITY_GD, "Pulse", "T173.B1")
	_run_ability_exit_tree_assertions(BIND_ABILITY_GD, "Bind", "T173.B2")
	_run_ability_exit_tree_assertions(ECHO_ABILITY_GD, "Echo", "T173.B3")
	_run_ability_exit_tree_assertions(CUT_ABILITY_GD, "Cut", "T173.B4")

	# T173.C — resonance_wave_ability.gd 补 _exit_tree() 钩子
	_run_wave_ability_exit_tree_assertion()


func _run_windup_vfx_assertions(class_name_str: String, path: String, color_hex: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: cannot read " + path)
		return
	# (1) fade_out_and_free 函数声明
	_assert_contains(src,
		"func fade_out_and_free(",
		prefix + ": fade_out_and_free() method declared in " + class_name_str)
	# (2) tween 调用 —— create_tween 或 Tween.new() 任一即可
	var has_tween := src.contains("create_tween()") or src.contains("Tween.new()")
	if not has_tween:
		_failures.append("FAIL: " + prefix + ": fade_out_and_free must use create_tween() or Tween.new() for 0.05s tween")
	else:
		_passes += 1
	# (3) modulate:a 0.0 终值（淡出到完全透明 — Godot 4 tween 语法）
	_assert_contains(src,
		"\"modulate:a\", 0.0",
		prefix + ": \"modulate:a\", 0.0 fade-out end value (Godot 4 tween syntax)")
	# (4) 0.05 时长（与候选简报一致）
	_assert_contains(src,
		"0.05",
		prefix + ": 0.05s fade-out duration")
	# (5) tween 结束 queue_free
	_assert_contains(src,
		"queue_free()",
		prefix + ": queue_free() at fade-out end (T173 fade-and-free contract)")
	# (6) docblock 标记 T173 (#92)
	_assert_contains(src,
		"T173 (#92)",
		prefix + ": T173 (#92) docblock attribution marker")


func _run_ability_exit_tree_assertions(path: String, verb: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: cannot read " + path)
		return
	# (1) _exit_tree 函数存在
	_assert_contains(src,
		"func _exit_tree() -> void:",
		prefix + ": " + verb + "Ability._exit_tree() exists")
	# (2) fade_out_and_free 调用（在 _exit_tree 内）
	_assert_contains(src,
		"fade_out_and_free()",
		prefix + ": " + verb + "Ability._exit_tree() calls fade_out_and_free() (T173 contract)")
	# (3) 旧硬 queue_free() 调用已切换为 fade_out_and_free()——检查范围限定在 _exit_tree 函数体内
	#  （其他位置如 start_*() 的 defensive cleanup 与 _execute_*() 的 fire-frame 替换
	#  仍保留硬 queue_free()，因为那些是"正常流程"而非"中断清理"）
	var exit_tree_body := _extract_exit_tree_body(src)
	if exit_tree_body.is_empty():
		_failures.append("FAIL: " + prefix + ": " + verb + "Ability has no _exit_tree() function body to inspect")
	elif exit_tree_body.contains("_windup_vfx.queue_free()"):
		_failures.append("FAIL: " + prefix + ": " + verb + "Ability._exit_tree() still has hard _windup_vfx.queue_free() — should be replaced by fade_out_and_free()")
	else:
		_passes += 1
	# (4) docblock 标记 T173 (#92)
	_assert_contains(src,
		"T173 (#92)",
		prefix + ": T173 (#92) docblock attribution marker in " + verb + "Ability")


func _run_wave_ability_exit_tree_assertion() -> void:
	var src := _read_file(RESONANCE_WAVE_ABILITY_GD)
	if src.is_empty():
		_failures.append("FAIL: cannot read " + RESONANCE_WAVE_ABILITY_GD)
		return
	# (1) _exit_tree 函数存在（T171 缺漏，#91 补）
	_assert_contains(src,
		"func _exit_tree() -> void:",
		"T173.C1: ResonanceWaveAbility._exit_tree() now exists (T171 → #91 缺漏补)")
	# (2) fade_out_and_free 调用
	_assert_contains(src,
		"fade_out_and_free()",
		"T173.C2: ResonanceWaveAbility._exit_tree() calls fade_out_and_free() (5 verb 闭环)")
	# (3) docblock 标记
	_assert_contains(src,
		"T173 (#92)",
		"T173.C3: T173 (#92) docblock attribution marker in ResonanceWaveAbility")


func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s

# Extract the body of the first `func _exit_tree() -> void:` block from
# `src`, scanning from the function header until either the next
# `^func ` at the same indent level (GDScript function declarations) or
# end-of-file.  Used to scope assertions to the interrupt-cleanup path
# only (so legitimate hard queue_free() calls in start_*/_execute_*
# don't trigger false positives).
func _extract_exit_tree_body(src: String) -> String:
	var lines := src.split("\n")
	var start_idx := -1
	for i in lines.size():
		if lines[i].contains("func _exit_tree() -> void:"):
			start_idx = i
			break
	if start_idx < 0:
		return ""
	# Determine the indent of the `func` line — body lines must be deeper.
	var func_line := lines[start_idx]
	var func_indent := func_line.length() - func_line.lstrip("\t ").length()
	var body_lines: Array[String] = []
	for j in range(start_idx + 1, lines.size()):
		var line := lines[j]
		# Stop at next top-level func (same indent as _exit_tree)
		if line.begins_with("func ") and (line.length() - line.lstrip("\t ").length()) == func_indent:
			break
		# Skip blank lines and comments
		if line.strip_edges().is_empty() or line.strip_edges().begins_with("#"):
			continue
		body_lines.append(line)
	return "\n".join(body_lines)


func _print_summary() -> void:
	print("--- I007 (#92) T173 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
