extends SceneTree
## T170 (#88) — 4 verb 命中反馈 VFX polish 冒烟测试
##
## 覆盖 #88 三任务 T170a + T170b + T170c:
## - T170a: Bind 命中反馈 (Muted Violet flash + LIGHT shake)
## - T170b: Echo 命中非反弹反馈 (Glass Cyan dim flash)
## - T170c: Pulse 命中屏抖 (LIGHT shake 补 fire 之上)
##
## 与 #87 I005 模式一致：源码扫描 + 字符串锚定（不实例化能力类）。
## 后续回归保护：4 verb 命中反馈色域分工 (Pulse Coral / Bind Violet /
## Cut Amber / Echo Cyan) 是 Voxglass 视觉组的"5 表面层"之一。
## 任一反馈被无意识删除都会被这 18+ 项断言抓住。

const PLAYER_GD := "res://src/scripts/player.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	_run_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL T170 (#88) ASSERTIONS PASSED ===")
		quit(0)


func _run_assertions() -> void:
	var src := _read_file(PLAYER_GD)
	if src.is_empty():
		_failures.append("FAIL: cannot read " + PLAYER_GD)
		return

	# === T170a: Bind 命中反馈 ===
	# (1) _ready 中连接 bind_hit 信号
	_assert_contains(src,
		"bind_ability.bind_hit.connect(_on_bind_hit)",
		"T170a.1: bind_ability.bind_hit.connect(_on_bind_hit) in _ready")
	# (2) has_signal 守卫
	_assert_contains(src,
		"if bind_ability.has_signal(\"bind_hit\"):",
		"T170a.2: has_signal('bind_hit') guard in _ready")
	# (3) 新 _on_bind_hit handler 定义
	_assert_contains(src,
		"func _on_bind_hit(target: Node) -> void:",
		"T170a.3: _on_bind_hit(target: Node) handler defined")
	# (4) target == null 守卫
	_assert_contains_in_func(src, "_on_bind_hit",
		"if target == null:",
		"T170a.4: _on_bind_hit has null guard")
	# (5) Muted Violet flash (T172 #91 — 改为 ScreenShake.VERB_HIT_BIND_COLOR 常量引用)
	_assert_contains_in_func(src, "_on_bind_hit",
		"ScreenShake.VERB_HIT_BIND_COLOR",
		"T170a.5: _on_bind_hit uses Muted Violet (VERB_HIT_BIND_COLOR constant)")
	# (6) flash_color 调用
	_assert_contains_in_func(src, "_on_bind_hit",
		"ScreenShake.flash_color(ScreenShake.VERB_HIT_BIND_COLOR, 0.10, 0.18)",
		"T170a.6: _on_bind_hit flash_color 0.10s / 0.18 peak")
	# (7) shake_preset(LIGHT) 调用
	_assert_contains_in_func(src, "_on_bind_hit",
		"ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)",
		"T170a.7: _on_bind_hit shake_preset(LIGHT) for 钉住 tactile")
	# (8) T170a docblock 标记
	_assert_contains(src, "T170a (#88)", "T170a.8: T170a docblock marker present")

	# === T170b: Echo 命中非反弹反馈 ===
	# (9) is_reflect=false 早退移除 (新逻辑有反馈)
	# 原代码: `if not is_reflect: return`  → 现在改为先 flash 再 return
	# 验证: 在 _on_echo_hit 体内, "if not is_reflect:" 后应该跟着 flash_color 而非 "return"
	_assert_contains_in_func(src, "_on_echo_hit",
		"if not is_reflect:",
		"T170b.1: _on_echo_hit still has is_reflect=false branch")
	# (10) 非反弹分支调 flash_color
	# 在 _on_echo_hit 中, "if not is_reflect:" 之后必须是 flash_color 调用
	_assert_echo_non_reflect_flash(src)
	# (11) Glass Cyan 颜色 (T172 #91 — VERB_HIT_ECHO_COLOR 常量引用)
	_assert_contains_in_func(src, "_on_echo_hit",
		"ScreenShake.VERB_HIT_ECHO_COLOR",
		"T170b.3: _on_echo_hit non-reflect uses Glass Cyan (VERB_HIT_ECHO_COLOR constant)")
	# (12) 非反弹参数: 0.06s / 0.12 peak (更短更暗 than reflect 0.08s / 0.20 peak)
	_assert_contains_in_func(src, "_on_echo_hit",
		"flash_color(ScreenShake.VERB_HIT_ECHO_COLOR, 0.06, 0.12)",
		"T170b.4: non-reflect flash 0.06s / 0.12 peak (shorter+dimmer than reflect)")
	# (13) 反弹路径 (0.08s / 0.20 peak) 保留无回归
	_assert_contains_in_func(src, "_on_echo_hit",
		"flash_color(ScreenShake.VERB_HIT_ECHO_COLOR, 0.08, 0.2)",
		"T170b.5: reflect flash 0.08s / 0.20 peak unchanged (no regression)")
	# (14) T170b docblock 标记
	_assert_contains(src, "T170b (#88)", "T170b.6: T170b docblock marker present")

	# === T170c: Pulse 命中屏抖 ===
	# (15) _on_pulse_hit 新增 shake_preset(LIGHT) 调用
	_assert_contains_in_func(src, "_on_pulse_hit",
		"ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)",
		"T170c.1: _on_pulse_hit shake_preset(LIGHT) for hit tactile")
	# (16) T170c docblock 标记
	_assert_contains(src, "T170c (#88)", "T170c.2: T170c docblock marker present")
	# (17) Coral flash 保留无回归 (T172 #91 — VERB_HIT_PULSE_COLOR 常量引用)
	_assert_contains_in_func(src, "_on_pulse_hit",
		"flash_color(ScreenShake.VERB_HIT_PULSE_COLOR, 0.10, 0.18)",
		"T170c.3: _on_pulse_hit Coral flash unchanged (VERB_HIT_PULSE_COLOR constant)")

	# === 跨任务回归: 4 verb 命中色域分工严格保持 (T172 #91 — 全部走常量) ===
	# Pulse Coral (#E86D5A) / Bind Violet (#65506A) / Cut Amber (#F2B66E) / Echo Cyan (#69C7CE)
	_assert_contains_in_func(src, "_on_pulse_hit",
		"VERB_HIT_PULSE_COLOR",
		"X.1: Pulse 命中 Coral 色保留 (常量引用)")
	_assert_contains_in_func(src, "_on_bind_hit",
		"VERB_HIT_BIND_COLOR",
		"X.2: Bind 命中 Violet 色保留 (常量引用)")
	_assert_contains_in_func(src, "_on_cut_hit",
		"VERB_HIT_CUT_COLOR",
		"X.3: Cut 命中 Amber 色保留 (常量引用, no regression)")
	_assert_contains_in_func(src, "_on_echo_hit",
		"VERB_HIT_ECHO_COLOR",
		"X.4: Echo 命中 Cyan 色保留 (常量引用, no regression)")


func _assert_echo_non_reflect_flash(src: String) -> void:
	# 在 _on_echo_hit 体内, "if not is_reflect:" 之后必须是 flash_color 调用
	# 用 600-char 窗口扫描 _on_echo_hit 函数体的 is_reflect false 分支
	var func_start := src.find("func _on_echo_hit(")
	if func_start < 0:
		_failures.append("T170b.2: cannot find _on_echo_hit function")
		return
	# 找函数体开始
	var body_start := src.find("\n", func_start)
	# 找下一个 "func " 标记 (函数结束) — 或者文件末尾
	var next_func := src.find("\nfunc ", body_start + 1)
	if next_func < 0:
		next_func = src.length()
	var body := src.substr(body_start, next_func - body_start)
	# 在 body 内找 "if not is_reflect:" 之后第一个非空行
	var branch_idx := body.find("if not is_reflect:")
	if branch_idx < 0:
		_failures.append("T170b.2: 'if not is_reflect:' not found in _on_echo_hit")
		return
	# 截取 500-char 窗口看是不是调 flash_color
	var window := body.substr(branch_idx, 500)
	if window.find("flash_color") < 0:
		_failures.append("T170b.2: 'flash_color' not in 500-char window after 'if not is_reflect:' (must be non-reflect feedback)")
	else:
		_passes += 1
		print("[OK] T170b.2: non-reflect path calls flash_color (per T170b feedback)")


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) >= 0:
		_passes += 1
		print("[OK] " + label)
	else:
		_failures.append("FAIL: " + label + " | needle=" + needle)


func _assert_contains_in_func(haystack: String, func_name: String, needle: String, label: String) -> void:
	var func_start := haystack.find("func " + func_name + "(")
	if func_start < 0:
		_failures.append("FAIL: " + label + " | cannot find func " + func_name)
		return
	# 找下一个 "func " 标记 (函数结束)
	var next_func := haystack.find("\nfunc ", func_start + 1)
	if next_func < 0:
		next_func = haystack.length()
	var body := haystack.substr(func_start, next_func - func_start)
	if body.find(needle) >= 0:
		_passes += 1
		print("[OK] " + label)
	else:
		_failures.append("FAIL: " + label + " | needle not in " + func_name + " body")


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _print_summary() -> void:
	print("")
	print("--- T170 (#88) smoke test summary ---")
	print("PASS: " + str(_passes))
	print("FAIL: " + str(_failures.size()))
	for f in _failures:
		print("  " + f)
