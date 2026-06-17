extends SceneTree
## I007 (#92) + I009 (#94) + I011 (#98) — T173/T174.B/D002.B 5 verb
## windup VFX 0.05s 淡出 tween + VerbAbilityBase 抽取 冒烟测试
##
## 覆盖 #91 T173 任务 + #94 T174.B 任务 + #98 D002.B 任务:
## - 5 verb windup VFX 各自新增 fade_out_and_free() 公共方法（0.05s
##   modulate.a 1.0→0.0 tween + tween 结束 queue_free 自身）
## - 4 verb ability._exit_tree() 从硬 queue_free() 切换为 fade_out_and_free()
##   （让 player 死亡 / 场景切换打断 windup 时 0.05s 平滑淡出而非硬 pop）
## - resonance_wave_ability.gd 补 _exit_tree() 钩子（#89 T171 缺漏:
##   Wave 是 5 verb windup 家族中唯一没有 _exit_tree 的 ability，场景
##   切换时 windup VFX 会 leak 到 freed scene 上下文）
##
## #94 T174.B 变更:
## - 5 verb windup VFX 的 fade_out_and_free() 抽到 VerbWindupVFXBase（5 verb
##   继承，不再各自持有 byte-identical copy）
## - 5 verb 文件不再有 `func fade_out_and_free(` 声明 / 不再有 `create_tween()`
##   / 不再有 `"modulate:a", 0.0` / 不再有 0.05 / 不再有 queue_free() in fade /
##   不再有 T173 (#92) docblock 标记
## - 4 verb ability._exit_tree() 仍调 fade_out_and_free()（base class 方法，
##   通过继承解析）
## - 本测试更新：fade_out_and_free 契约（create_tween / 0.05 / 0.0 终值 /
##   queue_free）从 base class 验证；5 verb 文件验证它们 extends base
##
## #98 D002.B 变更:
## - 5 verb ability._exit_tree() 进一步抽到 VerbAbilityBase（5 verb 继承，
##   不再各自持有 byte-identical copy）
## - 5 verb ability 文件不再有 `func _exit_tree() -> void:` 声明 / 不再有
##   `fade_out_and_free()` 内联调用 / 不再有 _exit_tree 体（T173 之前
##   各自的硬 queue_free + T173 #92 fade_out_and_free 切换都集中在 base）
## - 5 verb ability 文件验证它们 extends VerbAbilityBase + 引用
##   D002.B (#98) docblock 标记
## - 本测试更新：_exit_tree 契约（fade_out_and_free 调用）从 base 验证；
##   5 verb 文件验证它们 extends base + 不再有 _exit_tree

const PULSE_WINDUP_VFX_GD := "res://src/scripts/pulse_windup_vfx.gd"
const BIND_WINDUP_VFX_GD := "res://src/scripts/bind_windup_vfx.gd"
const ECHO_WINDUP_VFX_GD := "res://src/scripts/echo_windup_vfx.gd"
const CUT_WINDUP_VFX_GD := "res://src/scripts/cut_windup_vfx.gd"
const WAVE_WINDUP_VFX_GD := "res://src/scripts/wave_windup_vfx.gd"
const VERB_WINDUP_VFX_BASE_GD := "res://src/scripts/_verb_windup_vfx_base.gd"
const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"

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
		print("=== ALL T173 (#92) + T174.B (#94) + D002.B (#98) ASSERTIONS PASSED ===")
		quit(0)


func _run_assertions() -> void:
	# T174.B — VerbWindupVFXBase 包含 fade_out_and_free 公共代码（5 verb 继承）
	_run_base_class_fade_out_assertions()

	# T174.B — 5 verb windup 文件 extends base（继承 fade_out_and_free）
	_run_windup_vfx_inherit_assertions("PulseWindupVFX", PULSE_WINDUP_VFX_GD, "T174.B1")
	_run_windup_vfx_inherit_assertions("BindWindupVFX", BIND_WINDUP_VFX_GD, "T174.B2")
	_run_windup_vfx_inherit_assertions("EchoWindupVFX", ECHO_WINDUP_VFX_GD, "T174.B3")
	_run_windup_vfx_inherit_assertions("CutWindupVFX", CUT_WINDUP_VFX_GD, "T174.B4")
	_run_windup_vfx_inherit_assertions("WaveWindupVFX", WAVE_WINDUP_VFX_GD, "T174.B5")

	# D002.B (#98) — VerbAbilityBase 包含 _exit_tree 调 fade_out_and_free
	# （5 verb ability 继承，byte-identical 公共代码集中在 base 一份）
	_run_ability_base_exit_tree_assertions()

	# D002.B (#98) — 5 verb ability extends VerbAbilityBase
	_run_ability_inherit_assertions("PulseAbility", PULSE_ABILITY_GD, "D002.B.EXT1")
	_run_ability_inherit_assertions("BindAbility", BIND_ABILITY_GD, "D002.B.EXT2")
	_run_ability_inherit_assertions("EchoAbility", ECHO_ABILITY_GD, "D002.B.EXT3")
	_run_ability_inherit_assertions("CutAbility", CUT_ABILITY_GD, "D002.B.EXT4")
	_run_ability_inherit_assertions("ResonanceWaveAbility", RESONANCE_WAVE_ABILITY_GD, "D002.B.EXT5")

	# D002.B (#98) — 5 verb ability 不再各自持有 _exit_tree / fade_out_and_free 内联
	_run_ability_no_inline_exit_tree_assertions("PulseAbility", PULSE_ABILITY_GD, "D002.B.NOINLINE1")
	_run_ability_no_inline_exit_tree_assertions("BindAbility", BIND_ABILITY_GD, "D002.B.NOINLINE2")
	_run_ability_no_inline_exit_tree_assertions("EchoAbility", ECHO_ABILITY_GD, "D002.B.NOINLINE3")
	_run_ability_no_inline_exit_tree_assertions("CutAbility", CUT_ABILITY_GD, "D002.B.NOINLINE4")
	_run_ability_no_inline_exit_tree_assertions("ResonanceWaveAbility", RESONANCE_WAVE_ABILITY_GD, "D002.B.NOINLINE5")


func _run_base_class_fade_out_assertions() -> void:
	var src := _read_file(VERB_WINDUP_VFX_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: T174.B.BASE: cannot read " + VERB_WINDUP_VFX_BASE_GD)
		return
	# (1) fade_out_and_free 函数声明（5 verb 继承的入口）
	_assert_contains(src, "func fade_out_and_free(",
		"T174.B.BASE.1: base class declares fade_out_and_free() (T173 contract consolidated)")
	# (2) tween 调用 —— create_tween
	var has_tween := src.contains("create_tween()") or src.contains("Tween.new()")
	if not has_tween:
		_failures.append("FAIL: T174.B.BASE.2: base.fade_out_and_free must use create_tween() for 0.05s tween")
	else:
		_passes += 1
	# (3) modulate:a 0.0 终值（淡出到完全透明 — Godot 4 tween 语法）
	_assert_contains(src, "\"modulate:a\", 0.0",
		"T174.B.BASE.3: base.fade_out_and_free end value is \"modulate:a\", 0.0 (Godot 4 tween syntax)")
	# (4) 0.05 时长（与候选简报一致）
	_assert_contains(src, "0.05",
		"T174.B.BASE.4: base.fade_out_and_free uses 0.05s fade-out duration")
	# (5) tween 结束 queue_free
	_assert_contains(src, "queue_free()",
		"T174.B.BASE.5: base.fade_out_and_free calls queue_free() at fade-out end (T173 fade-and-free contract)")
	# (6) _active 早退守卫（避免 _active=false 状态下重入 tween）
	_assert_contains(src, "if not _active",
		"T174.B.BASE.6: base.fade_out_and_free early-return guard `if not _active` (idempotency)")
	# (7) docblock 标记 T173 (#92)（T173 任务首次引入 fade_out_and_free）
	_assert_contains(src, "T173 (#92)",
		"T174.B.BASE.7: T173 (#92) docblock attribution marker in base class (T173 origin preserved)")


func _run_windup_vfx_inherit_assertions(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	# (1) 5 verb extends VerbWindupVFXBase
	_assert_contains(src, "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"",
		prefix + ": " + class_name_str + " extends VerbWindupVFXBase (T174.B refactor — fade_out_and_free inherited)")
	# (2) 5 verb 文件不再自带 `func fade_out_and_free(` 声明（避免与 base 冲突）
	if src.contains("func fade_out_and_free("):
		_failures.append("FAIL: " + prefix + ": " + class_name_str + " has its own func fade_out_and_free() — should inherit from base (T174.B refactor)")
	else:
		_passes += 1
	# (3) 5 verb 文件调 _activate_windup_tween（与 T174 ramp-in 契约对偶）
	_assert_contains(src, "_activate_windup_tween()",
		prefix + ": " + class_name_str + ".trigger() delegates to _activate_windup_tween() (T174.B)")


# D002.B (#98) — VerbAbilityBase._exit_tree() 集中 fade_out_and_free 契约
# （5 verb ability 继承，byte-identical 公共代码集中在 base 一份）
func _run_ability_base_exit_tree_assertions() -> void:
	var src := _read_file(VERB_ABILITY_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: D002.B.BASE: cannot read " + VERB_ABILITY_BASE_GD)
		return
	# (1) _exit_tree 函数存在
	_assert_contains(src, "func _exit_tree() -> void:",
		"D002.B.BASE.1: VerbAbilityBase._exit_tree() exists (5 verb 继承 interrupt cleanup)")
	# (2) fade_out_and_free 调用（在 _exit_tree 内）
	_assert_contains(src, "fade_out_and_free()",
		"D002.B.BASE.2: VerbAbilityBase._exit_tree() calls fade_out_and_free() (T173 + T174.B 契约 D002.B 集中)")
	# (3) 不再有 _exit_tree 内的硬 _windup_vfx.queue_free()（D002.B #98 集中
	#     base._exit_tree 用 fade_out_and_free；_attach_windup_vfx helper
	#     仍可保留 hard queue_free 作为"leak 防护"清理，这是合法用途）
	var exit_tree_only := _extract_exit_tree_body(src)
	if exit_tree_only.is_empty():
		_failures.append("FAIL: D002.B.BASE.3: VerbAbilityBase has no _exit_tree() function body to inspect")
	elif exit_tree_only.contains("_windup_vfx.queue_free()"):
		_failures.append("FAIL: D002.B.BASE.3: VerbAbilityBase._exit_tree() still has hard _windup_vfx.queue_free() — should be fade_out_and_free()")
	else:
		_passes += 1
	# (4) docblock 标记 T173 (#92) 或 D002.B (#98) 任一可
	var has_doc_marker := src.contains("T173 (#92)") or src.contains("D002.B (#98)")
	if has_doc_marker:
		_passes += 1
	else:
		_failures.append("FAIL: D002.B.BASE.4: VerbAbilityBase has neither T173 (#92) nor D002.B (#98) docblock marker")


# D002.B (#98) — 5 verb ability extends VerbAbilityBase
func _run_ability_inherit_assertions(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	# (1) 5 verb ability extends VerbAbilityBase
	_assert_contains(src, "extends \"res://src/scripts/_verb_ability_base.gd\"",
		prefix + ": " + class_name_str + " extends VerbAbilityBase (D002.B refactor — _exit_tree + _consume_verb_cost + _setup_windup_state inherited)")
	# (2) 5 verb ability 文件引用 D002.B (#98) docblock 标记
	var has_doc_marker := src.contains("D002.B (#98)")
	if has_doc_marker:
		_passes += 1
	else:
		_failures.append("FAIL: " + prefix + ": " + class_name_str + " has no D002.B (#98) docblock marker")


# D002.B (#98) — 5 verb ability 不再各自持有 _exit_tree 函数体（已抽到 base）
func _run_ability_no_inline_exit_tree_assertions(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	# (1) 5 verb ability 文件不再有 `func _exit_tree() -> void:` 声明
	if src.contains("func _exit_tree() -> void:"):
		_failures.append("FAIL: " + prefix + ": " + class_name_str + " has its own func _exit_tree() — should inherit from VerbAbilityBase (D002.B refactor)")
	else:
		_passes += 1
	# (2) 5 verb ability 文件不再有 fade_out_and_free 内联调用（base 接管）
	if src.contains("fade_out_and_free()"):
		_failures.append("FAIL: " + prefix + ": " + class_name_str + " has inline fade_out_and_free() call — should inherit from VerbAbilityBase._exit_tree (D002.B refactor)")
	else:
		_passes += 1


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
# top-level `func` at the same indent (GDScript function declarations)
# or end-of-file.  Used to scope assertions to the interrupt-cleanup
# path only (so the legitimate hard `queue_free()` call in
# `_attach_windup_vfx` helper doesn't trigger false positives).
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
	print("--- I007 (#92) T173 + I009 (#94) T174.B + I011 (#98) D002.B smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
