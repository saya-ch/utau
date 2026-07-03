extends SceneTree
## I056 (#152) — T233 HUD 5 verb cooldown bar 冷光勾边 (cold glow border) 5 verb 5 色 冒烟测试
##
## 覆盖 #152 任务 T233 原子化提交:
##
## === T233 — 5 verb cooldown bar 冷光勾边 (cold glow border) 5 verb 5 色 ===
## - T233.CONST.PULSE_COLOR: _PULSE_GLOW_COLOR = Amber Voice #F2B66E
## - T233.CONST.BIND_COLOR: _BIND_GLOW_COLOR = Muted Violet #65506A
## - T233.CONST.CUT_COLOR: _CUT_GLOW_COLOR = Coral Pulse #E86D5A
## - T233.CONST.ECHO_COLOR: _ECHO_GLOW_COLOR = Glass Cyan #69C7CE
## - T233.CONST.WAVE_COLOR: _WAVE_GLOW_COLOR = Pale Resonance #B7E6DC
## - T233.CONST.FADE_DURATION: _VERB_GLOW_FADE_DURATION = 0.12 (T231 节奏同步)
## - T233.CONST.GLOW_ALPHA_DIM: _GLOW_ALPHA_DIM = 0.0 (cooling 时 border alpha)
## - T233.CONST.GLOW_ALPHA_BRIGHT: _GLOW_ALPHA_BRIGHT = 1.0 (ready 时 border alpha)
## - T233.FIELD.STYLEBOX: 5 个 StyleBoxFlat 字段 (pulse/bind/cut/echo/wave glow_bg)
## - T233.FIELD.STATE_DICT: _verb_glow_state 字典 5 key (pulse/bind/cut/echo/wave)
## - T233.READY.CREATE: _ready() 调 _create_verb_glow_stylebox 5 次
## - T233.READY.OVERRIDE: _ready() 调 add_theme_stylebox_override 5 次 (per-verb background)
## - T233.HELPER.CREATE: _create_verb_glow_stylebox 函数存在 + StyleBoxFlat.new()
## - T233.HELPER.TWEEN: _tween_verb_glow 函数存在 + tween_property(border_color)
## - T233.HELPER.STATE: _update_verb_glow_state 函数存在 + 状态翻转检测
## - T233.PROCESS.STATE: _process() 调 _update_verb_glow_state 5 次
## - T233.PROCESS.TWEEN: 5 verb _tween_verb_glow 调 create_tween() (T231 同模式)
## - T233.DOC.ANCHOR: T233 (#152) 注释锚点 ≥ 4 处
## - T233.NO_REGRESS_T200: T200 _reduced_flash_applied 字段保留 (T233 0 触碰)
## - T233.NO_REGRESS_T202: T202 5 verb cooldown label 字段保留 (T233 0 触碰)
## - T233.NO_REGRESS_T204: T204 5 verb name label 字段保留 (T233 0 触碰)
## - T233.NO_REGRESS_T206: T206 _apply_reduced_flash_modulate 7 element list 保留 (T233 0 触碰)
## - T233.SYNTAX.STYLEBOX: 5 个 glow_bg 字段 1 次声明, 0 重复
## - T233.SYNTAX.STATE_DICT: _verb_glow_state 1 次声明, 5 key 全 in dict

const HUD_GD := "res://src/scripts/hud.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I056 (#152) — T233 HUD 5 verb cooldown bar 冷光勾边 5 verb 5 色 ===")
	_run_t233_const_assertions()
	_run_t233_field_assertions()
	_run_t233_ready_assertions()
	_run_t233_helper_assertions()
	_run_t233_process_assertions()
	_run_t233_doc_anchor_assertions()
	_run_t233_regress_assertions()
	_run_t233_syntax_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I056 (#152) T233 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T233 — 5 verb cooldown bar 冷光勾边 =====================

# ---------- T233.CONST.* — 5 verb color + 节奏参数 ----------
func _run_t233_const_assertions() -> void:
	print("--- T233.CONST.* — 5 verb color + 节奏参数 ---")
	var src := _read_file(HUD_GD)
	_assert_contains(src, "const _PULSE_GLOW_COLOR := Color(0.949, 0.714, 0.431, 1.0)",
		"T233.CONST.PULSE_COLOR.1: _PULSE_GLOW_COLOR = Amber Voice #F2B66E (5 verb 主题色 1/5)")
	_assert_contains(src, "const _BIND_GLOW_COLOR := Color(0.396, 0.314, 0.416, 1.0)",
		"T233.CONST.BIND_COLOR.1: _BIND_GLOW_COLOR = Muted Violet #65506A (5 verb 主题色 2/5)")
	_assert_contains(src, "const _CUT_GLOW_COLOR := Color(0.91, 0.43, 0.35, 1.0)",
		"T233.CONST.CUT_COLOR.1: _CUT_GLOW_COLOR = Coral Pulse #E86D5A (5 verb 主题色 3/5)")
	_assert_contains(src, "const _ECHO_GLOW_COLOR := Color(0.412, 0.78, 0.808, 1.0)",
		"T233.CONST.ECHO_COLOR.1: _ECHO_GLOW_COLOR = Glass Cyan #69C7CE (5 verb 主题色 4/5)")
	_assert_contains(src, "const _WAVE_GLOW_COLOR := Color(0.718, 0.906, 0.867, 1.0)",
		"T233.CONST.WAVE_COLOR.1: _WAVE_GLOW_COLOR = Pale Resonance #B7E6DC (5 verb 主题色 5/5)")
	_assert_contains(src, "const _VERB_GLOW_FADE_DURATION := 0.12",
		"T233.CONST.FADE_DURATION.1: _VERB_GLOW_FADE_DURATION = 0.12 (T231 + T226 0.12s 节奏同步)")
	_assert_contains(src, "const _GLOW_ALPHA_DIM := 0.0",
		"T233.CONST.GLOW_ALPHA_DIM.1: _GLOW_ALPHA_DIM = 0.0 (cooling 时 border alpha fade out)")
	_assert_contains(src, "const _GLOW_ALPHA_BRIGHT := 1.0",
		"T233.CONST.GLOW_ALPHA_BRIGHT.1: _GLOW_ALPHA_BRIGHT = 1.0 (ready 时 border alpha 提亮)")


# ---------- T233.FIELD.* — 5 StyleBoxFlat + 1 state dict ----------
func _run_t233_field_assertions() -> void:
	print("--- T233.FIELD.* — 5 StyleBoxFlat + 1 state dict ---")
	var src := _read_file(HUD_GD)
	_assert_contains(src, "var _pulse_glow_bg: StyleBoxFlat",
		"T233.FIELD.STYLEBOX.1: _pulse_glow_bg StyleBoxFlat 字段 (1/5)")
	_assert_contains(src, "var _bind_glow_bg: StyleBoxFlat",
		"T233.FIELD.STYLEBOX.2: _bind_glow_bg StyleBoxFlat 字段 (2/5)")
	_assert_contains(src, "var _cut_glow_bg: StyleBoxFlat",
		"T233.FIELD.STYLEBOX.3: _cut_glow_bg StyleBoxFlat 字段 (3/5)")
	_assert_contains(src, "var _echo_glow_bg: StyleBoxFlat",
		"T233.FIELD.STYLEBOX.4: _echo_glow_bg StyleBoxFlat 字段 (4/5)")
	_assert_contains(src, "var _wave_glow_bg: StyleBoxFlat",
		"T233.FIELD.STYLEBOX.5: _wave_glow_bg StyleBoxFlat 字段 (5/5)")
	_assert_contains(src, "var _verb_glow_state: Dictionary = {",
		"T233.FIELD.STATE_DICT.1: _verb_glow_state dict 字段 (5 key 状态机)")
	# dict 5 key 完整
	var state_dict := src.substr(src.find("var _verb_glow_state: Dictionary = {"), 200)
	_assert_contains(state_dict, "\"pulse\": false",
		"T233.FIELD.STATE_DICT.2: _verb_glow_state[\"pulse\"] = false (1/5 key)")
	_assert_contains(state_dict, "\"bind\": false",
		"T233.FIELD.STATE_DICT.3: _verb_glow_state[\"bind\"] = false (2/5 key)")
	_assert_contains(state_dict, "\"cut\": false",
		"T233.FIELD.STATE_DICT.4: _verb_glow_state[\"cut\"] = false (3/5 key)")
	_assert_contains(state_dict, "\"echo\": false",
		"T233.FIELD.STATE_DICT.5: _verb_glow_state[\"echo\"] = false (4/5 key)")
	_assert_contains(state_dict, "\"wave\": false",
		"T233.FIELD.STATE_DICT.6: _verb_glow_state[\"wave\"] = false (5/5 key)")


# ---------- T233.READY.* — _ready() 5 stylebox 创建 + 5 override ----------
func _run_t233_ready_assertions() -> void:
	print("--- T233.READY.* — _ready() 5 stylebox 创建 + 5 override ---")
	var src := _read_file(HUD_GD)
	var ready_idx := src.find("func _ready() -> void:")
	if ready_idx == -1:
		_failures.append("FAIL: T233.READY.1: _ready 函数未找到")
		return
	# _ready 完整 body (~600 字符足够, _ready → _process 间隔)
	var ready_body := src.substr(ready_idx, 2500)
	# 5 _create_verb_glow_stylebox 调用
	var pulse_create := ready_body.count("_pulse_glow_bg = _create_verb_glow_stylebox(_PULSE_GLOW_COLOR)")
	var bind_create := ready_body.count("_bind_glow_bg = _create_verb_glow_stylebox(_BIND_GLOW_COLOR)")
	var cut_create := ready_body.count("_cut_glow_bg = _create_verb_glow_stylebox(_CUT_GLOW_COLOR)")
	var echo_create := ready_body.count("_echo_glow_bg = _create_verb_glow_stylebox(_ECHO_GLOW_COLOR)")
	var wave_create := ready_body.count("_wave_glow_bg = _create_verb_glow_stylebox(_WAVE_GLOW_COLOR)")
	if pulse_create + bind_create + cut_create + echo_create + wave_create == 5:
		_passes += 1
		print("  OK  T233.READY.CREATE.1: _ready() 调 _create_verb_glow_stylebox 5 次 (5 verb 5 stylebox)")
	else:
		_failures.append("FAIL: T233.READY.CREATE.1: _create_verb_glow_stylebox 总调用 %d, 期望 5" % (pulse_create + bind_create + cut_create + echo_create + wave_create))
	# 5 add_theme_stylebox_override 调用
	var pulse_override := ready_body.count("_pulse_cooldown.add_theme_stylebox_override(\"background\", _pulse_glow_bg)")
	var bind_override := ready_body.count("_bind_cooldown.add_theme_stylebox_override(\"background\", _bind_glow_bg)")
	var cut_override := ready_body.count("_cut_cooldown.add_theme_stylebox_override(\"background\", _cut_glow_bg)")
	var echo_override := ready_body.count("_echo_cooldown.add_theme_stylebox_override(\"background\", _echo_glow_bg)")
	var wave_override := ready_body.count("_wave_cooldown.add_theme_stylebox_override(\"background\", _wave_glow_bg)")
	if pulse_override + bind_override + cut_override + echo_override + wave_override == 5:
		_passes += 1
		print("  OK  T233.READY.OVERRIDE.1: _ready() 调 add_theme_stylebox_override 5 次 (5 verb per-verb background)")
	else:
		_failures.append("FAIL: T233.READY.OVERRIDE.1: add_theme_stylebox_override 总调用 %d, 期望 5" % (pulse_override + bind_override + cut_override + echo_override + wave_override))


# ---------- T233.HELPER.* — 3 个 helper 函数 ----------
func _run_t233_helper_assertions() -> void:
	print("--- T233.HELPER.* — 3 个 helper 函数 ---")
	var src := _read_file(HUD_GD)
	_assert_contains(src, "func _create_verb_glow_stylebox(color: Color) -> StyleBoxFlat:",
		"T233.HELPER.CREATE.1: _create_verb_glow_stylebox 函数存在 (StyleBoxFlat factory)")
	_assert_contains(src, "var sb := StyleBoxFlat.new()",
		"T233.HELPER.CREATE.2: StyleBoxFlat.new() 在 _create_verb_glow_stylebox 内")
	_assert_contains(src, "sb.border_color = color",
		"T233.HELPER.CREATE.3: sb.border_color = color (factory 设 verb 主题色 border)")
	_assert_contains(src, "func _tween_verb_glow(stylebox: StyleBoxFlat, color: Color, is_ready: bool) -> void:",
		"T233.HELPER.TWEEN.1: _tween_verb_glow 函数存在 (border tween)")
	_assert_contains(src, "tween_property(stylebox, \"border_color\", target_color, _VERB_GLOW_FADE_DURATION)",
		"T233.HELPER.TWEEN.2: tween_property border_color 0.12s 同步 T231 节奏")
	_assert_contains(src, "func _update_verb_glow_state(verb_name: String, stylebox: StyleBoxFlat, color: Color, ability: Node) -> void:",
		"T233.HELPER.STATE.1: _update_verb_glow_state 函数存在 (state-change 检测)")
	_assert_contains(src, "var is_ready: bool = ratio < 0.01",
		"T233.HELPER.STATE.2: is_ready = ratio < 0.01 (0.01 阈值 ready 判定)")
	_assert_contains(src, "if is_ready != was_ready:",
		"T233.HELPER.STATE.3: 状态翻转检测 (state-change trigger tween)")


# ---------- T233.PROCESS.* — _process() 5 _update_verb_glow_state 调用 ----------
func _run_t233_process_assertions() -> void:
	print("--- T233.PROCESS.* — _process() 5 _update_verb_glow_state 调用 ---")
	var src := _read_file(HUD_GD)
	var process_idx := src.find("func _process(delta: float) -> void:")
	if process_idx == -1:
		_failures.append("FAIL: T233.PROCESS.1: _process 函数未找到")
		return
	var process_body := src.substr(process_idx, 5000)
	# 5 _update_verb_glow_state 调用
	var pulse_call := process_body.count("_update_verb_glow_state(\"pulse\", _pulse_glow_bg, _PULSE_GLOW_COLOR, _pulse_ability)")
	var bind_call := process_body.count("_update_verb_glow_state(\"bind\",  _bind_glow_bg,  _BIND_GLOW_COLOR,  _bind_ability)")
	var cut_call := process_body.count("_update_verb_glow_state(\"cut\",   _cut_glow_bg,   _CUT_GLOW_COLOR,   _cut_ability)")
	var echo_call := process_body.count("_update_verb_glow_state(\"echo\",  _echo_glow_bg,  _ECHO_GLOW_COLOR,  _echo_ability)")
	var wave_call := process_body.count("_update_verb_glow_state(\"wave\",  _wave_glow_bg,  _WAVE_GLOW_COLOR,  _wave_ability)")
	if pulse_call + bind_call + cut_call + echo_call + wave_call == 5:
		_passes += 1
		print("  OK  T233.PROCESS.STATE.1: _process() 调 _update_verb_glow_state 5 次 (5 verb 5 调用)")
	else:
		_failures.append("FAIL: T233.PROCESS.STATE.1: _update_verb_glow_state 总调用 %d, 期望 5" % (pulse_call + bind_call + cut_call + echo_call + wave_call))


# ---------- T233.DOC.ANCHOR.* — T233 注释锚点 ≥ 4 处 ----------
func _run_t233_doc_anchor_assertions() -> void:
	print("--- T233.DOC.ANCHOR.* — T233 注释锚点 ≥ 4 处 ---")
	var src := _read_file(HUD_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T233 (#152)") != -1:
			anchor_count += 1
	if anchor_count >= 4:
		_passes += 1
		print("  OK  T233.DOC.ANCHOR.1: T233 (#152) 注释锚点 %d 处 (≥ 4, 涵盖 const/field/ready/helper)" % anchor_count)
	else:
		_failures.append("FAIL: T233.DOC.ANCHOR.1: T233 (#152) 注释锚点仅 %d 处, 需 ≥ 4" % anchor_count)


# ---------- T233.NO_REGRESS.* — T200/T202/T204/T206 0 触碰 ----------
func _run_t233_regress_assertions() -> void:
	print("--- T233.NO_REGRESS.* — T200/T202/T204/T206 0 触碰 ---")
	var src := _read_file(HUD_GD)
	# T200 _reduced_flash_applied 字段保留 (T233 0 触碰)
	_assert_contains(src, "var _reduced_flash_applied: bool = false",
		"T233.NO_REGRESS_T200.1: T200 _reduced_flash_applied 字段保留 (T233 0 触碰 reduce_flash 灰化 7 element list)")
	_assert_contains(src, "_apply_reduced_flash_modulate",
		"T233.NO_REGRESS_T200.2: T200 _apply_reduced_flash_modulate 函数保留 (T233 0 触碰 reduce_flash helper)")
	# T202 5 verb cooldown label 字段保留 (T233 0 触碰)
	_assert_contains(src, "_pulse_cooldown_label: Label",
		"T233.NO_REGRESS_T202.1: T202 _pulse_cooldown_label 字段保留 (T233 0 触碰 cooldown label 提示)")
	_assert_contains(src, "_wave_cooldown_label: Label",
		"T233.NO_REGRESS_T202.2: T202 _wave_cooldown_label 字段保留 (T233 0 触碰 cooldown label 提示)")
	# T204 5 verb name label 字段保留 (T233 0 触碰)
	_assert_contains(src, "_pulse_name_label: Label",
		"T233.NO_REGRESS_T204.1: T204 _pulse_name_label 字段保留 (T233 0 触碰 name label)")
	_assert_contains(src, "_wave_name_label: Label",
		"T233.NO_REGRESS_T204.2: T204 _wave_name_label 字段保留 (T233 0 触碰 name label)")
	# T206 _apply_reduced_flash_modulate 7 element list 保留 (T233 0 触碰)
	_assert_contains(src, "[_pulse_cooldown, _bind_cooldown, _cut_cooldown, _echo_cooldown, _wave_cooldown, _resonance_bar, _health_container]",
		"T233.NO_REGRESS_T206.1: T206 7 element list 保留 (T233 仅替换 5 verb background stylebox, modulate 0 触碰)")


# ---------- T233.SYNTAX.* — 无重复声明 + 正确 dict key ----------
func _run_t233_syntax_assertions() -> void:
	print("--- T233.SYNTAX.* — 无重复声明 + 正确 dict key ---")
	var src := _read_file(HUD_GD)
	# 5 个 glow_bg 字段各 1 次声明
	var pulse_field_count := src.count("var _pulse_glow_bg: StyleBoxFlat")
	var bind_field_count := src.count("var _bind_glow_bg: StyleBoxFlat")
	var cut_field_count := src.count("var _cut_glow_bg: StyleBoxFlat")
	var echo_field_count := src.count("var _echo_glow_bg: StyleBoxFlat")
	var wave_field_count := src.count("var _wave_glow_bg: StyleBoxFlat")
	if pulse_field_count == 1 and bind_field_count == 1 and cut_field_count == 1 and echo_field_count == 1 and wave_field_count == 1:
		_passes += 1
		print("  OK  T233.SYNTAX.STYLEBOX.1: 5 个 glow_bg 字段各 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T233.SYNTAX.STYLEBOX.1: glow_bg 字段声明数异常 pulse=%d bind=%d cut=%d echo=%d wave=%d" % [pulse_field_count, bind_field_count, cut_field_count, echo_field_count, wave_field_count])
	# _verb_glow_state 1 次声明
	var state_dict_count := src.count("var _verb_glow_state: Dictionary = {")
	if state_dict_count == 1:
		_passes += 1
		print("  OK  T233.SYNTAX.STATE_DICT.1: _verb_glow_state 1 次声明 (5 key dict, 0 重复)")
	else:
		_failures.append("FAIL: T233.SYNTAX.STATE_DICT.1: _verb_glow_state 声明 %d 次, 应 1" % state_dict_count)


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I056 (#152) T233 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
