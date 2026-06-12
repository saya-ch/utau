extends SceneTree
## I010 (#96) — F004.B + F010 + L005 三连击冒烟测试
##
## 覆盖 #96 三任务原子化提交:
## - F004.B: AudioManagerEnhanced 增 4 verb fire SFX 公开 API
##           (play_bind / play_cut / play_echo / play_wave_fire) + 4 个
##           私有 _generate_*_sfx() 合成函数 + 4 个 _*_stream 缓存变量。
##           与 #94 F004 play_pulse() 模板完全镜像，是 T181 5 verb 音频
##           家族完整闭环的"函数定义层"前置。
## - F010:   screen_shake.gd 4 verb VERB_HIT_*_COLOR 4 元组注释扩展
##           为完整 JSDoc 风格说明（4 verb × const × hex × palette × caller
##           表格 + 调用契约示例 + Wave 不参与说明 + 6th verb 接入流程）。
## - L005:   README.md + README.zh-CN.md Screenshots 节补 5 verb windup
##           ramp-in / ramp-out 双闭环（#92-#94）段 + 5 verb 音频闭环
##           现状段，让 README 与 4 文档同步 hook (rule 7) 永远不过时。
##
## 与 I009 (#94) / I008 (#93) / I007 (#92) 模式一致：源码扫描 + 字符串
## 锚定（不实例化 Node2D / autoload 避免 headless mock 边界）。回归保护：
## 5 verb 音频家族函数定义层 + 4 verb 命中色宪法 docblock + README 双语
## Screenshots 段 4 文档同步 三个宪法级约束是 Voxglass "5 表面层"之一。
## 任一文件被无意识删除或参数漂移都会被这 30+ 项断言抓住。

const AUDIO_MANAGER_ENHANCED_GD := "res://src/scripts/audio_manager_enhanced.gd"
const SCREEN_SHAKE_GD := "res://src/autoload/screen_shake.gd"
const README_MD := "res://README.md"
const README_ZH_CN_MD := "res://README.zh-CN.md"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I010 (#96) — F004.B + F010 + L005 三连击 ===")
	_run_f004b_audio_stream_vars_assertions()
	_run_f004b_generate_sfx_assertions()
	_run_f004b_public_play_api_assertions()
	_run_f010_screen_shake_docblock_assertions()
	_run_l005_readme_screenshots_section_assertions()
	_run_l005_readme_zh_cn_screenshots_section_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I010 (#96) F004.B + F010 + L005 ASSERTIONS PASSED ===")
		quit(0)


# ---------- F004.B — audio_manager_enhanced.gd 4 verb stream 缓存变量 ----------
func _run_f004b_audio_stream_vars_assertions() -> void:
	print("--- F004.B — 4 verb stream 缓存变量 ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	if src.is_empty():
		_failures.append("FAIL: F004.B: cannot read " + AUDIO_MANAGER_ENHANCED_GD)
		return
	_assert_contains(src, "var _bind_stream: AudioStreamWAV",
		"F004.B.1: _bind_stream 缓存变量在 audio_manager_enhanced.gd (5 verb 音频家族 Bind 缓存)")
	_assert_contains(src, "var _cut_stream: AudioStreamWAV",
		"F004.B.2: _cut_stream 缓存变量在 audio_manager_enhanced.gd (Cut)")
	_assert_contains(src, "var _echo_stream: AudioStreamWAV",
		"F004.B.3: _echo_stream 缓存变量在 audio_manager_enhanced.gd (Echo)")
	_assert_contains(src, "var _wave_fire_stream: AudioStreamWAV",
		"F004.B.4: _wave_fire_stream 缓存变量在 audio_manager_enhanced.gd (Wave fire)")


# ---------- F004.B — 4 verb _generate_*_sfx 私有合成函数 ----------
func _run_f004b_generate_sfx_assertions() -> void:
	print("--- F004.B — 4 verb _generate_*_sfx 合成函数 ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	if src.is_empty():
		_failures.append("FAIL: F004.B: cannot read " + AUDIO_MANAGER_ENHANCED_GD)
		return
	# (1) _generate_bind_sfx 存在 + 220Hz 拉低特征
	_assert_contains(src, "func _generate_bind_sfx()",
		"F004.B.5: _generate_bind_sfx() 私有函数在 audio_manager_enhanced.gd")
	_assert_contains(src, "220.0",
		"F004.B.6: Bind SFX 220Hz 基频 (与 Bind 牵入 motif 匹配)")
	# (2) _generate_cut_sfx 存在 + 1500Hz 锐利特征
	_assert_contains(src, "func _generate_cut_sfx()",
		"F004.B.7: _generate_cut_sfx() 私有函数")
	_assert_contains(src, "1500.0",
		"F004.B.8: Cut SFX 1500Hz 锐利 transient (与 Cut 斩 motif 匹配)")
	# (3) _generate_echo_sfx 存在 + 1320Hz 玻璃特征
	_assert_contains(src, "func _generate_echo_sfx()",
		"F004.B.9: _generate_echo_sfx() 私有函数")
	_assert_contains(src, "1320.0",
		"F004.B.10: Echo SFX 1320Hz 玻璃 ping (与 Echo 反弹 motif 匹配)")
	# (4) _generate_wave_fire_sfx 存在 + 100Hz 宽辐射特征
	_assert_contains(src, "func _generate_wave_fire_sfx()",
		"F004.B.11: _generate_wave_fire_sfx() 私有函数")
	_assert_contains(src, "100.0",
		"F004.B.12: Wave SFX 100Hz 宽辐射 (与 Wave 涟漪 motif 匹配)")
	# (5) F004.B (#96) docblock 标记在 _generate_placeholder_sfx
	_assert_contains(src, "F004.B (#96)",
		"F004.B.13: F004.B (#96) docblock attribution marker")


# ---------- F004.B — 4 verb 公开 play_*() API ----------
func _run_f004b_public_play_api_assertions() -> void:
	print("--- F004.B — 4 verb 公开 play_*() API ---")
	var src := _read_file(AUDIO_MANAGER_ENHANCED_GD)
	if src.is_empty():
		_failures.append("FAIL: F004.B: cannot read " + AUDIO_MANAGER_ENHANCED_GD)
		return
	# (1) 4 verb play_*() 公开 API 全部存在
	_assert_contains(src, "func play_bind()",
		"F004.B.14: play_bind() 公开 API (Bind 音频闭环)")
	_assert_contains(src, "func play_cut()",
		"F004.B.15: play_cut() 公开 API (Cut 音频闭环)")
	_assert_contains(src, "func play_echo()",
		"F004.B.16: play_echo() 公开 API (Echo 音频闭环)")
	_assert_contains(src, "func play_wave_fire()",
		"F004.B.17: play_wave_fire() 公开 API (Wave 音频闭环)")
	# (2) 4 verb play_*() 内部 lazy-init 模式（_stream == null → _generate_*_sfx()）
	_assert_contains(src, "if _bind_stream == null:",
		"F004.B.18: play_bind() lazy-init (避免 _ready 阻塞)")
	_assert_contains(src, "if _cut_stream == null:",
		"F004.B.19: play_cut() lazy-init")
	_assert_contains(src, "if _echo_stream == null:",
		"F004.B.20: play_echo() lazy-init")
	_assert_contains(src, "if _wave_fire_stream == null:",
		"F004.B.21: play_wave_fire() lazy-init")
	# (3) 4 verb play_*() 内部调对应 _generate_*_sfx() 工厂
	_assert_contains(src, "_bind_stream = _generate_bind_sfx()",
		"F004.B.22: play_bind() 调 _generate_bind_sfx() 工厂")
	_assert_contains(src, "_cut_stream = _generate_cut_sfx()",
		"F004.B.23: play_cut() 调 _generate_cut_sfx()")
	_assert_contains(src, "_echo_stream = _generate_echo_sfx()",
		"F004.B.24: play_echo() 调 _generate_echo_sfx()")
	_assert_contains(src, "_wave_fire_stream = _generate_wave_fire_sfx()",
		"F004.B.25: play_wave_fire() 调 _generate_wave_fire_sfx()")
	# (4) 与 #94 play_pulse() 模板同构（play_pulse() 函数存在 + 同 lazy 风格）
	_assert_contains(src, "func play_pulse()",
		"F004.B.26: play_pulse() 仍存在 (#94 F004 模板，5 verb 闭环已闭合)")


# ---------- F010 — screen_shake.gd 4 verb VERB_HIT_*_COLOR 注释扩展 ----------
func _run_f010_screen_shake_docblock_assertions() -> void:
	print("--- F010 — screen_shake.gd 4 verb VERB_HIT_*_COLOR 注释扩展 ---")
	var src := _read_file(SCREEN_SHAKE_GD)
	if src.is_empty():
		_failures.append("FAIL: F010: cannot read " + SCREEN_SHAKE_GD)
		return
	# (1) F010 (#96) docblock 标记
	_assert_contains(src, "F010 (#96)",
		"F010.1: F010 (#96) docblock attribution marker in screen_shake.gd")
	# (2) JSDoc 风格表格 4 verb × Constant × Hex × Palette × Caller
	_assert_contains(src, "Constant",
		"F010.2: JSDoc 风格表格 (Constant 列) 在 screen_shake.gd 4 verb 注释扩展中")
	_assert_contains(src, "Hex / RGBA",
		"F010.3: JSDoc 风格表格 (Hex / RGBA 列)")
	_assert_contains(src, "Palette",
		"F010.4: JSDoc 风格表格 (Palette 列)")
	_assert_contains(src, "Caller / where it fires",
		"F010.5: JSDoc 风格表格 (Caller 列)")
	# (3) 4 verb 命中色 hex 在表格中
	_assert_contains(src, "#E86D5A",
		"F010.6: Pulse Coral Pulse hex #E86D5A 在 F010 表格中")
	_assert_contains(src, "#65506A",
		"F010.7: Bind Muted Violet hex #65506A 在 F010 表格中")
	_assert_contains(src, "#F2B66E",
		"F010.8: Cut Amber Voice hex #F2B66E 在 F010 表格中")
	_assert_contains(src, "#69C7CE",
		"F010.9: Echo Glass Cyan hex #69C7CE 在 F010 表格中")
	# (4) 调用契约示例（5 verb hit flash_color 完整）
	_assert_contains(src, "ScreenShake.flash_color(ScreenShake.VERB_HIT_PULSE_COLOR, 0.10, 0.18)",
		"F010.10: Pulse 调用契约示例 (flash_color Pulse 0.10/0.18)")
	_assert_contains(src, "ScreenShake.flash_color(ScreenShake.VERB_HIT_BIND_COLOR,  0.10, 0.18)",
		"F010.11: Bind 调用契约示例")
	_assert_contains(src, "ScreenShake.flash_color(ScreenShake.VERB_HIT_CUT_COLOR,   0.09, 0.18)",
		"F010.12: Cut 调用契约示例 (0.09/0.18)")
	# (5) Wave 不参与此查表的明确说明
	_assert_contains(src, "Wave 不参与此查表",
		"F010.13: Wave 不参与此查表明确说明 (F009 严格镜像)")
	# (6) 6th verb 接入流程
	_assert_contains(src, "6th verb 接入流程",
		"F010.14: 6th verb 接入流程说明 (宪法修订)")
	# (7) 4 verb VERB_HIT_*_COLOR 常量仍存在（合约源头）
	_assert_contains(src, "VERB_HIT_PULSE_COLOR",
		"F010.15: VERB_HIT_PULSE_COLOR 常量存在 (F010 注释扩展但 const 保留)")
	_assert_contains(src, "VERB_HIT_BIND_COLOR",
		"F010.16: VERB_HIT_BIND_COLOR 常量存在")
	_assert_contains(src, "VERB_HIT_CUT_COLOR",
		"F010.17: VERB_HIT_CUT_COLOR 常量存在")
	_assert_contains(src, "VERB_HIT_ECHO_COLOR",
		"F010.18: VERB_HIT_ECHO_COLOR 常量存在")


# ---------- L005 — README.md Screenshots 节 ramp-in/ramp-out 段 ----------
func _run_l005_readme_screenshots_section_assertions() -> void:
	print("--- L005 — README.md Screenshots 节 ramp-in/ramp-out 段 ---")
	var src := _read_file(README_MD)
	if src.is_empty():
		_failures.append("FAIL: L005: cannot read " + README_MD)
		return
	# (1) 新增 5 Verb windup ramp-in / ramp-out 双闭环子节
	_assert_contains(src, "### 5 Verb windup ramp-in / ramp-out",
		"L005.1: README.md 'Screenshots' 节补 '5 Verb windup ramp-in / ramp-out 双闭环' 子节")
	# (2) ramp-in 描述（T174 #93 + T174.B #94）
	_assert_contains(src, "Tween.TRANS_QUAD",
		"L005.2: ramp-in 描述含 TRANS_QUAD (T174 #93 ramp-in tween 曲线)")
	_assert_contains(src, "EASE_OUT",
		"L005.3: ramp-in 描述含 EASE_OUT (缓出)")
	_assert_contains(src, "VerbWindupVFXBase",
		"L005.4: ramp-in 描述含 VerbWindupVFXBase 父类引用 (T174.B #94)")
	# (3) ramp-out 描述（T173 #92）
	_assert_contains(src, "fade_out_and_free",
		"L005.5: ramp-out 描述含 fade_out_and_free (T173 #92 0.05s 淡出)")
	# (4) 5 verb 音频闭环现状段（F004 + F004.B）
	_assert_contains(src, "5 verb 音频闭环",
		"L005.6: 5 verb 音频闭环现状段 (F004 + F004.B 联合现状)")
	# (5) T181 候选指向（剩余 hit + cooldown 闭环）
	_assert_contains(src, "T181",
		"L005.7: T181 候选指向 (剩余 5 verb hit + cooldown 闭环)")


# ---------- L005 — README.zh-CN.md Screenshots 节 ramp-in/ramp-out 段 ----------
func _run_l005_readme_zh_cn_screenshots_section_assertions() -> void:
	print("--- L005 — README.zh-CN.md Screenshots 节 ramp-in/ramp-out 段 ---")
	var src := _read_file(README_ZH_CN_MD)
	if src.is_empty():
		_failures.append("FAIL: L005: cannot read " + README_ZH_CN_MD)
		return
	# (1) 中文版同步新增 ramp-in / ramp-out 段
	_assert_contains(src, "### 5 verb windup ramp-in / ramp-out",
		"L005.8: README.zh-CN.md 同步 '5 verb windup ramp-in / ramp-out 双闭环' 子节 (双语同步)")
	# (2) 与英文版共享关键 token
	_assert_contains(src, "VerbWindupVFXBase",
		"L005.9: 中文版 VerbWindupVFXBase 父类引用 (与英文版 1:1 镜像)")
	_assert_contains(src, "fade_out_and_free",
		"L005.10: 中文版 fade_out_and_free 引用")
	# (3) 5 verb 音频闭环段
	_assert_contains(src, "5 verb 音频闭环",
		"L005.11: 中文版 5 verb 音频闭环段")
	# (4) T181 候选指向
	_assert_contains(src, "T181",
		"L005.12: 中文版 T181 候选指向")


# ---------- helpers ----------
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
	print("")
	print("=== I010 (#96) summary: " + str(_passes) + " passed, " + str(_failures.size()) + " failed ===")
	if not _failures.is_empty():
		print("FAILURES:")
		for f in _failures:
			print("  " + f)
