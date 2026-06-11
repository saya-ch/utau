extends SceneTree
## I008 (#93) + I009 (#94) — T174 5 verb windup VFX ramp-in tween 冒烟测试
##
## 覆盖 #92 T174 任务 + #94 T174.B 任务:
## - 5 verb windup VFX trigger() 新增 modulate.a 0→1 tween（TRANS_QUAD
##   EASE_OUT，duration = _max_lifetime），取代旧 _draw() 中线性
##   `alpha_t = clampf(t / 0.4, 0, 1)` 的 40%-then-hold 曲线
## - 5 verb windup VFX _draw() col.a 改为常量（peak_alpha，不再
##   乘 alpha_t），ramp-in 视觉曲线完全由 modulate.a tween 驱动
## - 与 T173 (#92) ramp-out 0.05s tween 对偶：ramp-in 也用 Tween，
##   VFX "进入家族" 改为与 "退出家族" 同样的 tween 曲线
##
## #94 T174.B 变更:
## - 5 verb windup VFX 的 ramp-in tween 代码（modulate.a=0.0 +
##   create_tween + TRANS_QUAD EASE_OUT + tween_property 1.0/_max_lifetime）
##   抽到 VerbWindupVFXBase._activate_windup_tween()
## - 5 verb trigger() 改为调 _activate_windup_tween() 而非自带 4 行 tween
## - 本测试更新：检查 5 verb 文件 调 _activate_windup_tween()，且 ramp-in
##   tween 代码现在在 base class（modulate.a=0.0 / create_tween /
##   TRANS_QUAD / EASE_OUT / 1.0 终值 / _max_lifetime duration），
##   仍满足"5 verb windup ramp-in 一致"契约
##
## 与 I007 (#92) / I006 (#89) / I005 (#88) 模式一致：源码扫描 +
## 字符串锚定（不实例化 Node2D，避免 headless mock tween 边界）。
## 回归保护：5 verb windup ramp-in 是 #92 的"VFX 进入家族"标准，
## 未来 6th verb 接入 windup VFX 必须使用同 trigger() tween 曲线
## （与 5 verb family 5 元组同等重要）。

const PULSE_WINDUP_VFX_GD := "res://src/scripts/pulse_windup_vfx.gd"
const BIND_WINDUP_VFX_GD := "res://src/scripts/bind_windup_vfx.gd"
const ECHO_WINDUP_VFX_GD := "res://src/scripts/echo_windup_vfx.gd"
const CUT_WINDUP_VFX_GD := "res://src/scripts/cut_windup_vfx.gd"
const WAVE_WINDUP_VFX_GD := "res://src/scripts/wave_windup_vfx.gd"
const VERB_WINDUP_VFX_BASE_GD := "res://src/scripts/_verb_windup_vfx_base.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	_run_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL T174 (#93) + T174.B (#94) ASSERTIONS PASSED ===")
		quit(0)


func _run_assertions() -> void:
	# T174.B — VerbWindupVFXBase 包含 5 verb ramp-in tween 公共代码
	_run_base_class_assertions()

	# T174.B — 5 verb trigger() 调 _activate_windup_tween() 委托给 base
	_run_windup_vfx_activate_assertions("PulseWindupVFX", PULSE_WINDUP_VFX_GD, "T174.B1")
	_run_windup_vfx_activate_assertions("BindWindupVFX", BIND_WINDUP_VFX_GD, "T174.B2")
	_run_windup_vfx_activate_assertions("EchoWindupVFX", ECHO_WINDUP_VFX_GD, "T174.B3")
	_run_windup_vfx_activate_assertions("CutWindupVFX", CUT_WINDUP_VFX_GD, "T174.B4")
	_run_windup_vfx_activate_assertions("WaveWindupVFX", WAVE_WINDUP_VFX_GD, "T174.B5")


func _run_base_class_assertions() -> void:
	var src := _read_file(VERB_WINDUP_VFX_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: T174.B.BASE: cannot read " + VERB_WINDUP_VFX_BASE_GD)
		return
	# T174.B base 集中提供 ramp-in tween 契约
	# (1) modulate.a = 0.0 起点
	_assert_contains(src, "modulate.a = 0.0",
		"T174.B.BASE.1: base._activate_windup_tween() initializes modulate.a = 0.0")
	# (2) create_tween() 入口
	var has_tween := src.contains("create_tween()")
	if not has_tween:
		_failures.append("FAIL: T174.B.BASE.2: base._activate_windup_tween() must use create_tween()")
	else:
		_passes += 1
	# (3) tween 终值 1.0
	_assert_contains(src, "\"modulate:a\", 1.0",
		"T174.B.BASE.3: base._activate_windup_tween() tween end value is \"modulate:a\", 1.0")
	# (4) tween duration 引用 _max_lifetime
	_assert_contains(src, "_max_lifetime",
		"T174.B.BASE.4: base._activate_windup_tween() tween duration references _max_lifetime (not hardcoded)")
	# (5) TRANS_QUAD 平滑曲线
	_assert_contains(src, "Tween.TRANS_QUAD",
		"T174.B.BASE.5: base._activate_windup_tween() uses Tween.TRANS_QUAD")
	# (6) EASE_OUT 缓动
	_assert_contains(src, "Tween.EASE_OUT",
		"T174.B.BASE.6: base._activate_windup_tween() uses Tween.EASE_OUT")
	# (7) base 声明 class_name VerbWindupVFXBase（可被 5 verb 引用）
	_assert_contains(src, "class_name VerbWindupVFXBase",
		"T174.B.BASE.7: base class declares class_name VerbWindupVFXBase")
	# (8) base 声明 _activate_windup_tween 函数（5 verb 调用入口）
	_assert_contains(src, "func _activate_windup_tween(",
		"T174.B.BASE.8: base class declares _activate_windup_tween() function")
	# (9) base 声明 fade_out_and_free（5 verb 继承的 T173 退出契约）
	_assert_contains(src, "func fade_out_and_free(",
		"T174.B.BASE.9: base class declares fade_out_and_free() (T173 contract moved here)")
	# (10) base 持有 5 verb 公共状态 _lifetime / _max_lifetime / _active
	_assert_contains(src, "var _max_lifetime: float",
		"T174.B.BASE.10: base class declares _max_lifetime state")
	_assert_contains(src, "var _lifetime: float",
		"T174.B.BASE.11: base class declares _lifetime state")
	_assert_contains(src, "var _active: bool",
		"T174.B.BASE.12: base class declares _active state")
	# (11) base 持有公共 _process 生命周期跟踪
	_assert_contains(src, "func _process(",
		"T174.B.BASE.13: base class declares _process() lifetime tracker")
	# (12) base z_index = 10（5 verb 公共 _ready）
	_assert_contains(src, "z_index = 10",
		"T174.B.BASE.14: base class _ready() sets z_index = 10 (above world, below HUD)")
	# (13) T174.B (#94) docblock 标记
	_assert_contains(src, "T174.B (#94)",
		"T174.B.BASE.15: T174.B (#94) docblock attribution marker in base class")

	# 旧线性 ramp 已从 base + 5 verb 全部删除（双重严格：在源代码中查找）
	var combined := src
	for p in [PULSE_WINDUP_VFX_GD, BIND_WINDUP_VFX_GD, ECHO_WINDUP_VFX_GD, CUT_WINDUP_VFX_GD, WAVE_WINDUP_VFX_GD]:
		combined += "\n" + _read_file(p)
	var has_old_alpha_ramp := false
	for line in combined.split("\n"):
		var stripped := line.strip_edges()
		if stripped.is_empty() or stripped.begins_with("#"):
			continue
		if line.contains("alpha_t := clampf(t /"):
			has_old_alpha_ramp = true
			break
	if has_old_alpha_ramp:
		_failures.append("FAIL: T174.B.BASE.X: base or 5 verb still has old linear 'alpha_t := clampf(t / ...)' alpha ramp — must be removed (T174 contract)")
	else:
		_passes += 1


func _run_windup_vfx_activate_assertions(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: " + prefix + ": cannot read " + path)
		return
	# (1) 5 verb extends VerbWindupVFXBase
	_assert_contains(src, "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"",
		prefix + ": " + class_name_str + " extends VerbWindupVFXBase (T174.B refactor)")
	# (2) trigger() 体内调 _activate_windup_tween() 委托
	_assert_contains(src, "_activate_windup_tween()",
		prefix + ": " + class_name_str + ".trigger() delegates to _activate_windup_tween() (T174.B contract)")


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


func _print_summary() -> void:
	print("--- I008 (#93) T174 + I009 (#94) T174.B smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
