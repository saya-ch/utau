extends SceneTree
## I008 (#93) — T174 5 verb windup VFX ramp-in tween 冒烟测试
##
## 覆盖 #92 T174 任务:
## - 5 verb windup VFX trigger() 新增 modulate.a 0→1 tween（TRANS_QUAD
##   EASE_OUT，duration = _max_lifetime），取代旧 _draw() 中线性
##   `alpha_t = clampf(t / 0.4, 0, 1)` 的 40%-then-hold 曲线
## - 5 verb windup VFX _draw() col.a 改为常量（peak_alpha，不再
##   乘 alpha_t），ramp-in 视觉曲线完全由 modulate.a tween 驱动
## - 与 T173 (#92) ramp-out 0.05s tween 对偶：ramp-in 也用 Tween，
##   VFX "进入家族" 改为与 "退出家族" 同样的 tween 曲线
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

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	_run_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL T174 (#93) ASSERTIONS PASSED ===")
		quit(0)


func _run_assertions() -> void:
	# T174.A — 5 verb windup VFX trigger() 内新增 ramp-in tween
	_run_windup_vfx_assertions("PulseWindupVFX", PULSE_WINDUP_VFX_GD, "T174.A1")
	_run_windup_vfx_assertions("BindWindupVFX", BIND_WINDUP_VFX_GD, "T174.A2")
	_run_windup_vfx_assertions("EchoWindupVFX", ECHO_WINDUP_VFX_GD, "T174.A3")
	_run_windup_vfx_assertions("CutWindupVFX", CUT_WINDUP_VFX_GD, "T174.A4")
	_run_windup_vfx_assertions("WaveWindupVFX", WAVE_WINDUP_VFX_GD, "T174.A5")


func _run_windup_vfx_assertions(class_name_str: String, path: String, prefix: String) -> void:
	var src := _read_file(path)
	if src.is_empty():
		_failures.append("FAIL: cannot read " + path)
		return

	# 检查 trigger() 体内（不依赖 _extract_*_body 复杂度，只确保文档中存在）
	# (1) trigger() 内 modulate.a = 0.0 显式初始化
	_assert_contains(src,
		"modulate.a = 0.0",
		prefix + ": trigger() initializes modulate.a = 0.0 in " + class_name_str)
	# (2) trigger() 内 create_tween() 调用（ramp-in 入口）
	var has_tween := src.contains("create_tween()")
	if not has_tween:
		_failures.append("FAIL: " + prefix + ": trigger() must use create_tween() for ramp-in tween in " + class_name_str)
	else:
		_passes += 1
	# (3) tween 终值 1.0（"modulate:a", 1.0）
	_assert_contains(src,
		"\"modulate:a\", 1.0",
		prefix + ": tween end value is \"modulate:a\", 1.0 in " + class_name_str)
	# (4) tween duration 引用 _max_lifetime（不是硬编码）
	_assert_contains(src,
		"_max_lifetime",
		prefix + ": tween duration references _max_lifetime (not hardcoded) in " + class_name_str)
	# (5) TRANS_QUAD 平滑曲线
	_assert_contains(src,
		"Tween.TRANS_QUAD",
		prefix + ": ramp-in tween uses Tween.TRANS_QUAD in " + class_name_str)
	# (6) EASE_OUT 缓动
	_assert_contains(src,
		"Tween.EASE_OUT",
		prefix + ": ramp-in tween uses Tween.EASE_OUT in " + class_name_str)
	# (7) docblock 标记 T174 (#93)
	_assert_contains(src,
		"T174 (#93)",
		prefix + ": T174 (#93) docblock attribution marker in " + class_name_str)

	# 旧线性 ramp 已删除断言（_draw() 不再含 `alpha_t := clampf(t / X, ...)` 模式）
	# 注意：Wave 旧代码用 `(t - phase_offset) / 0.4`，也命中此模式
	# 严格匹配 `alpha_t := clampf(t / ` 形式以避免命中 `var t := clampf(_lifetime / ...)`
	# （后者是 _process lifetime 线性进展，是合法的，必须保留）
	# 注释中也可能含此 pattern（在 backticks 内），所以双重严格：
	# 在源代码中（非 backticks 注释行）查找。
	var has_old_alpha_ramp := false
	for line in src.split("\n"):
		# 跳过注释行（以 # 开头或纯空白）
		var stripped := line.strip_edges()
		if stripped.is_empty() or stripped.begins_with("#"):
			continue
		# 在代码行中查找 `alpha_t := clampf(t /`
		if line.contains("alpha_t := clampf(t /"):
			has_old_alpha_ramp = true
			break
	if has_old_alpha_ramp:
		_failures.append("FAIL: " + prefix + ": " + class_name_str + " still has old linear 'alpha_t := clampf(t / ...)' alpha ramp — must be removed (T174 contract)")
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


func _print_summary() -> void:
	print("--- I008 (#93) T174 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
