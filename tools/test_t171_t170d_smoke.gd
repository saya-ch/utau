extends SceneTree
## I006 (#89) + I009 (#94) — T171 + T170d 5 verb windup 家族闭环 + Cut 命中屏抖冒烟测试
##
## 覆盖 #89 双任务 + #94 T174.B 任务:
## - T171: 新建 wave_windup_vfx.gd（5 verb windup 家族第 5 色 Pale Resonance）+
##         接入 resonance_wave_ability.gd start_wave()，与 4 verb 模式对齐
## - T170d: Cut 命中补 LIGHT 屏抖 (1.0/0.08s)，4 verb 命中反馈最后一格
## - T174.B (#94): WaveWindupVFX 与 4 verb 一同 extends VerbWindupVFXBase
##         （共享 z_index=10 / _process lifetime / queue_free() safety net），
##         5 verb windup VFX ramp-in tween / fade_out_and_free 抽到 base
##
## 与 I005 (#88 T170) 模式一致：源码扫描 + 字符串锚定（不实例化能力类）。
## 后续回归保护：5 verb windup 调色四元组 (Pulse Cyan / Bind Violet /
## Cut Amber / Echo Cyan / Wave Pale) + 4 verb 命中屏抖分工是 Voxglass
## 视觉组的"5 表面层"之一。任一文件被无意识删除或参数漂移都会被这
## 18+ 项断言抓住。

const WAVE_WINDUP_VFX_GD := "res://src/scripts/wave_windup_vfx.gd"
const VERB_WINDUP_VFX_BASE_GD := "res://src/scripts/_verb_windup_vfx_base.gd"
const RESONANCE_WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"
const PLAYER_GD := "res://src/scripts/player.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	_run_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL T171 + T170d (#89) ASSERTIONS PASSED ===")
		quit(0)


func _run_assertions() -> void:
	var wave_vfx_src := _read_file(WAVE_WINDUP_VFX_GD)
	if wave_vfx_src.is_empty():
		_failures.append("FAIL: cannot read " + WAVE_WINDUP_VFX_GD + " (T171 file must exist)")
	else:
		_run_t171_assertions(wave_vfx_src)
	var wave_base_src := _read_file(VERB_WINDUP_VFX_BASE_GD)
	if wave_base_src.is_empty():
		_failures.append("FAIL: cannot read " + VERB_WINDUP_VFX_BASE_GD + " (T174.B base file must exist)")
	else:
		_run_t174b_base_assertions(wave_base_src)
	var wave_ability_src := _read_file(RESONANCE_WAVE_ABILITY_GD)
	if wave_ability_src.is_empty():
		_failures.append("FAIL: cannot read " + RESONANCE_WAVE_ABILITY_GD)
	else:
		_run_t171_integration_assertions(wave_ability_src)
	var player_src := _read_file(PLAYER_GD)
	if player_src.is_empty():
		_failures.append("FAIL: cannot read " + PLAYER_GD)
	else:
		_run_t170d_assertions(player_src)


func _run_t171_assertions(src: String) -> void:
	# (1) class_name WaveWindupVFX 声明
	_assert_contains(src,
		"class_name WaveWindupVFX",
		"T171.1: class_name WaveWindupVFX declared")
	# (2) extends VerbWindupVFXBase (T174.B #94 — base class refactor)
	_assert_contains(src,
		"extends \"res://src/scripts/_verb_windup_vfx_base.gd\"",
		"T171.2: WaveWindupVFX extends VerbWindupVFXBase (T174.B — base class refactor)")
	# (3) trigger(origin, half_radius, duration) 签名 —— 与 4 verb 家族对齐
	_assert_contains(src,
		"func trigger(origin: Vector2, half_radius: float, duration: float) -> void:",
		"T171.3: trigger(origin, half_radius, duration) signature matches 4-verb family")
	# (4) Pale Resonance 默认色 #B7E7DD (RGB 0.717, 0.906, 0.866)
	_assert_contains(src,
		"Color(\"#B7E7DD\")",
		"T171.4: Pale Resonance color #B7E7DD (5 verb 5th color)")
	# (5) ring_count @export 默认 3
	_assert_contains(src,
		"@export var ring_count: int = 3",
		"T171.5: ring_count @export defaults to 3 (3-ring halo motif)")
	# (6) z_index = 10 (T174.B — 在 base class _ready(), 5 verb 共享)
	# 5 verb 文件不再自带 z_index = 10; 验证它在 base class 中存在
	# (此断言在 _run_t174b_base_assertions 里)
	# (7) Safety net auto-free (T174.B — 在 base class _process 中)
	# 同上,在 _run_t174b_base_assertions 里
	# (8) T171 docblock 标记 (在 wave_windup_vfx.gd 自身)
	_assert_contains(src, "T171 (#89)", "T171.8: T171 docblock marker present in wave_windup_vfx.gd")
	# (9) "ripple outward" 注释（说明 3 环是 ripple 主题，由 r_ratio + alpha 空间层次驱动）
	_assert_contains(src,
		"ripple outward",
		"T171.9: docblock mentions 'ripple outward' (sound-wave motif, 3-ring spatial hierarchy)")
	# (10) STAGE_GUIDE 引用（说明色域来源）
	_assert_contains(src,
		"STYLE_GUIDE",
		"T171.10: STYLE_GUIDE citation (color authority)")
	# (11) T174.B (#94) 标记 (T174.B refactor 在 wave_windup_vfx.gd docblock 中)
	_assert_contains(src, "T174.B (#94)", "T171.11: T174.B (#94) docblock marker in wave_windup_vfx.gd")


func _run_t174b_base_assertions(src: String) -> void:
	# T174.B #94 — base class 提供 5 verb 共享的 z_index / _process / queue_free
	# (1) base 声明 class_name VerbWindupVFXBase
	_assert_contains(src, "class_name VerbWindupVFXBase",
		"T174.B.BASE.1: VerbWindupVFXBase class_name declared")
	# (2) base._ready() 内 z_index = 10 (5 verb windup VFX 公共设置)
	_assert_contains(src, "z_index = 10",
		"T174.B.BASE.2: base._ready() sets z_index = 10 (5 verb 共享，above world, below HUD)")
	# (3) base._process() 内 queue_free() safety net
	_assert_contains(src, "queue_free()",
		"T174.B.BASE.3: base._process() calls queue_free() safety net after _max_lifetime")
	# (4) base 提供 fade_out_and_free (T173 退出契约)
	_assert_contains(src, "func fade_out_and_free(",
		"T174.B.BASE.4: base declares fade_out_and_free() (T173 5 verb 共享退出契约)")
	# (5) base 提供 _activate_windup_tween (T174 ramp-in 入口)
	_assert_contains(src, "func _activate_windup_tween(",
		"T174.B.BASE.5: base declares _activate_windup_tween() (T174 5 verb 共享 ramp-in 入口)")


func _run_t171_integration_assertions(src: String) -> void:
	# (11) start_wave() 内 preload wave_windup_vfx.gd
	_assert_contains_in_func(src, "start_wave",
		"preload(\"res://src/scripts/wave_windup_vfx.gd\").new()",
		"T171.11: start_wave() preloads wave_windup_vfx.gd (matches 4-verb preload pattern)")
	# (12) start_wave() 内调用 trigger 并传 (origin, half_radius, duration)
	_assert_contains_in_func(src, "start_wave",
		"windup_vfx.trigger(_pending_origin, wave_radius * 0.5, windup_time)",
		"T171.12: start_wave() calls trigger with 0.5× radius (precursor, not fire)")
	# (13) start_wave() 内 add_child 到 current_scene
	_assert_contains_in_func(src, "start_wave",
		"scene.add_child(windup_vfx)",
		"T171.13: start_wave() adds windup_vfx to current_scene")
	# (14) T171 docblock 标记 在 resonance_wave_ability.gd
	_assert_contains(src, "T171 (#89)", "T171.14: T171 docblock in resonance_wave_ability.gd")


func _run_t170d_assertions(src: String) -> void:
	# (15) _on_cut_hit 内 shake_preset(LIGHT) 调用
	_assert_contains_in_func(src, "_on_cut_hit",
		"ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)",
		"T170d.1: _on_cut_hit shake_preset(LIGHT) for hit tactile")
	# (16) T170d docblock 标记
	_assert_contains(src, "T170d (#89)", "T170d.2: T170d docblock marker present")
	# (17) Amber flash 保留无回归 (X.3 cross-task regression, T172 #91 — VERB_HIT_CUT_COLOR 常量)
	_assert_contains_in_func(src, "_on_cut_hit",
		"flash_color(ScreenShake.VERB_HIT_CUT_COLOR, 0.09, 0.18)",
		"T170d.3: Cut Amber flash unchanged (VERB_HIT_CUT_COLOR constant)")
	# (18) has_method 守卫保留
	_assert_contains_in_func(src, "_on_cut_hit",
		"if ScreenShake and ScreenShake.has_method(\"shake_preset\"):",
		"T170d.4: shake_preset guarded by has_method (autoload-safe)")


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
	print("--- T171 + T170d (#89) smoke test summary ---")
	print("PASS: " + str(_passes))
	print("FAIL: " + str(_failures.size()))
	for f in _failures:
		print("  " + f)
