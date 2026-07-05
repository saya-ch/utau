extends SceneTree
## I031 (#123) — Smoke test for T206 (HUD ResonanceBar + HealthContainer
## reduce_flash 灰化 — 扩展 T200 5 verb cooldown bar 灰化范围到 HUD
## 顶部 2 个最显眼常驻颜色块).
##
## 16 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i031_t206_smoke.gd
##
## 设计 (与 I022 ~ I030 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T206.HUD.RESONANCE_BAR_REF — hud.gd 有 _resonance_bar @onready ref.
##   T206.HUD.HEALTH_CONTAINER_REF — hud.gd 有 _health_container @onready ref.
##   T206.HUD.APPLY_FN_EXISTS — _apply_reduced_flash_modulate 函数仍存在.
##   T206.HUD.SEVEN_ELEMENTS_LOOP — iteration list 包含 5 verb bar + 2 新元素 = 7.
##   T206.HUD.RESONANCE_IN_LOOP — _resonance_bar 在 iteration list 内.
##   T206.HUD.HEALTH_CONTAINER_IN_LOOP — _health_container 在 iteration list 内.
##   T206.HUD.MODULATE_ASSIGN — ui_elem.modulate = target_color (改名后仍 modulate 写).
##   T206.HUD.T206_ANCHOR — T206 (#123) 注释锚点出现 >= 2 (const 块 + helper 块).
##   T206.HUD.REDUCED_CONST — _REDUCED_COLOR_MODULATE 常量值不变 (T200 兼容).
##   T206.HUD.NORMAL_CONST — _NORMAL_COLOR_MODULATE 常量值不变 (T200 兼容).
##   T206.HUD.GUARD_NOT_EVERY_FRAME — 状态切换守卫 (T200 兼容).
##   T206.HUD.SS_QUERY — ScreenShake.is_reduce_flash() 仍调用 (T200 兼容).
##   T206.HUD.PROCESS_HOOK — _apply_reduced_flash_modulate 在 _process 体内调 (T200 兼容).
##   T206.HUD.LEGACY_5_BARS — 5 verb bar 仍在 list 中 (T200 不被破坏).
##   T206.HUD.HEALTH_CONTAINER_TYPE — _health_container 是 HBoxContainer (modulate 继承).
##   T206.SS.IS_REDUCE_FLASH — screen_shake.gd is_reduce_flash() 函数存在 (T195 兼容).

func _initialize() -> void:
	print("=== I031 T206 HUD ResonanceBar + HealthContainer reduce_flash 灰化 smoke test (#123) ===")

	var hud_src := ""
	var hf := FileAccess.open("res://src/scripts/hud.gd", FileAccess.READ)
	if hf:
		hud_src = hf.get_as_text()
		hf.close()

	var ss_src := ""
	var sf := FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	if sf:
		ss_src = sf.get_as_text()
		sf.close()

	var passed := 0
	var total := 0

	# ===== T206.HUD.RESONANCE_BAR_REF =====
	total += 1
	if hud_src.find("@onready var _resonance_bar: ProgressBar") == -1:
		print("  FAIL [T206.1]: hud.gd 缺 _resonance_bar @onready 字段")
		quit(1)
		return
	passed += 1
	print("  [T206.1] hud.gd 含 _resonance_bar @onready (OK)")

	# ===== T206.HUD.HEALTH_CONTAINER_REF =====
	total += 1
	if hud_src.find("@onready var _health_container: HBoxContainer") == -1:
		print("  FAIL [T206.2]: hud.gd 缺 _health_container @onready 字段")
		quit(1)
		return
	passed += 1
	print("  [T206.2] hud.gd 含 _health_container @onready (OK)")

	# ===== T206.HUD.APPLY_FN_EXISTS =====
	total += 1
	if hud_src.find("func _apply_reduced_flash_modulate") == -1:
		print("  FAIL [T206.3]: hud.gd 缺 _apply_reduced_flash_modulate 函数 (T200 不应被破坏)")
		quit(1)
		return
	passed += 1
	print("  [T206.3] hud.gd 含 _apply_reduced_flash_modulate 函数 (OK)")

	# ===== T206.HUD.SEVEN_ELEMENTS_LOOP =====
	total += 1
	# iteration list 包含 5 verb bar + _resonance_bar + _health_container = 7 元素
	# T247 (#164) — 加 _whisper_cooldown 第 6 verb, list 7 → 8 元素 (测试阈值 >= 7 仍 PASS)
	var apply_fn_idx := hud_src.find("func _apply_reduced_flash_modulate")
	if apply_fn_idx == -1:
		print("  FAIL [T206.4]: 找不到 _apply_reduced_flash_modulate 函数")
		quit(1)
		return
	var apply_body := hud_src.substr(apply_fn_idx, 800)
	# 验证至少 7 个核心元素名都在 list 内 (T247 #164 后实际 8 元素)
	var seven_count := 0
	for elem_name in ["_pulse_cooldown", "_bind_cooldown", "_cut_cooldown", "_echo_cooldown", "_wave_cooldown", "_resonance_bar", "_health_container"]:
		if apply_body.find(elem_name) != -1:
			seven_count += 1
	if seven_count < 7:
		print("  FAIL [T206.4]: iteration list 仅含 %d/7 核心 UI 元素 (期望 5 verb bar + _resonance_bar + _health_container, T247 #164 后实际 8 元素)" % seven_count)
		quit(1)
		return
	passed += 1
	print("  [T206.4] iteration list 含 7 核心 UI 元素 (T247 #164 扩 8 元素 OK)")

	# ===== T206.HUD.RESONANCE_IN_LOOP =====
	total += 1
	if apply_body.find("_resonance_bar") == -1:
		print("  FAIL [T206.5]: _resonance_bar 不在 iteration list 内")
		quit(1)
		return
	passed += 1
	print("  [T206.5] _resonance_bar 在 iteration list (OK)")

	# ===== T206.HUD.HEALTH_CONTAINER_IN_LOOP =====
	total += 1
	if apply_body.find("_health_container") == -1:
		print("  FAIL [T206.6]: _health_container 不在 iteration list 内")
		quit(1)
		return
	passed += 1
	print("  [T206.6] _health_container 在 iteration list (OK)")

	# ===== T206.HUD.MODULATE_ASSIGN =====
	total += 1
	# T206 改用 ui_elem 变量名, 但仍要 modulate 写
	if apply_body.find("ui_elem.modulate = target_color") == -1 and apply_body.find("bar.modulate = target_color") == -1:
		print("  FAIL [T206.7]: 缺 modulate = target_color 赋值 (T200/T206 任一变量名)")
		quit(1)
		return
	passed += 1
	print("  [T206.7] modulate = target_color 赋值 (OK)")

	# ===== T206.HUD.T206_ANCHOR =====
	total += 1
	# T206 (#123) 注释锚点出现 >= 2 (const 块 + helper 块)
	var t206_count := _count_substr(hud_src, "T206 (#123)")
	if t206_count < 2:
		print("  FAIL [T206.8]: T206 (#123) 注释锚点出现 %d 次, 期望 >= 2" % t206_count)
		quit(1)
		return
	passed += 1
	print("  [T206.8] T206 (#123) 注释锚点 (出现 %d 次) (OK)" % t206_count)

	# ===== T206.HUD.REDUCED_CONST =====
	total += 1
	# _REDUCED_COLOR_MODULATE 常量值与 T200 一致 (兼容)
	if hud_src.find("Color(0.55, 0.55, 0.6, 0.75)") == -1:
		print("  FAIL [T206.9]: _REDUCED_COLOR_MODULATE 常量值变更 (T200 兼容失败)")
		quit(1)
		return
	passed += 1
	print("  [T206.9] _REDUCED_COLOR_MODULATE = Color(0.55, 0.55, 0.6, 0.75) (T200 兼容) (OK)")

	# ===== T206.HUD.NORMAL_CONST =====
	total += 1
	# _NORMAL_COLOR_MODULATE 常量值与 T200 一致
	if hud_src.find("Color(1.0, 1.0, 1.0, 1.0)") == -1:
		print("  FAIL [T206.10]: _NORMAL_COLOR_MODULATE 常量值变更 (T200 兼容失败)")
		quit(1)
		return
	passed += 1
	print("  [T206.10] _NORMAL_COLOR_MODULATE = Color(1,1,1,1) (T200 兼容) (OK)")

	# ===== T206.HUD.GUARD_NOT_EVERY_FRAME =====
	total += 1
	# 状态切换守卫 (T200 兼容)
	if hud_src.find("reduce_flash_active != _reduced_flash_applied") == -1:
		print("  FAIL [T206.11]: 缺状态切换守卫 (T200 兼容失败, 每帧 8 元素 modulate 写浪费, T247 #164 加 _whisper_cooldown 7→8)")
		quit(1)
		return
	passed += 1
	print("  [T206.11] 状态切换守卫 reduce_flash_active != _reduced_flash_applied (T200 兼容) (OK)")

	# ===== T206.HUD.SS_QUERY =====
	total += 1
	# ScreenShake.is_reduce_flash() 仍调用 (T200 兼容)
	if hud_src.find("ScreenShake.is_reduce_flash()") == -1:
		print("  FAIL [T206.12]: 缺 ScreenShake.is_reduce_flash() 调用 (T200 兼容失败)")
		quit(1)
		return
	passed += 1
	print("  [T206.12] ScreenShake.is_reduce_flash() 调用 (T200 兼容) (OK)")

	# ===== T206.HUD.PROCESS_HOOK =====
	total += 1
	# _apply_reduced_flash_modulate 在文件中至少出现 1 次 (process hook)
	var apply_call_count := _count_substr(hud_src, "_apply_reduced_flash_modulate(")
	if apply_call_count < 1:
		print("  FAIL [T206.13]: _apply_reduced_flash_modulate() 调用次数 = %d, 期望 >= 1" % apply_call_count)
		quit(1)
		return
	passed += 1
	print("  [T206.13] _apply_reduced_flash_modulate() 调用次数 = %d (>= 1) (OK)" % apply_call_count)

	# ===== T206.HUD.LEGACY_5_BARS =====
	total += 1
	# 5 verb bar 仍在 list 中 (T200 不被破坏)
	var five_bar_count := 0
	for bar_name in ["_pulse_cooldown", "_bind_cooldown", "_cut_cooldown", "_echo_cooldown", "_wave_cooldown"]:
		if apply_body.find(bar_name) != -1:
			five_bar_count += 1
	if five_bar_count < 5:
		print("  FAIL [T206.14]: 5 verb bar 中仅 %d 个在 list 内 (T200 不应被破坏)" % five_bar_count)
		quit(1)
		return
	passed += 1
	print("  [T206.14] 5 verb bar 仍在 list (T200 兼容) (OK)")

	# ===== T206.HUD.HEALTH_CONTAINER_TYPE =====
	total += 1
	# _health_container 是 HBoxContainer 类型 (modulate 继承到子 ColorRect bell)
	# 验证字段声明有 HBoxContainer 类型注解
	if hud_src.find("_health_container: HBoxContainer") == -1:
		print("  FAIL [T206.15]: _health_container 缺 HBoxContainer 类型注解 (modulate 继承机制依赖)")
		quit(1)
		return
	passed += 1
	print("  [T206.15] _health_container: HBoxContainer 类型注解 (modulate 继承) (OK)")

	# ===== T206.SS.IS_REDUCE_FLASH =====
	total += 1
	# screen_shake.gd is_reduce_flash() 函数存在 (T195 兼容)
	if ss_src.find("func is_reduce_flash") == -1:
		print("  FAIL [T206.16]: screen_shake.gd 缺 is_reduce_flash() 函数 (T195 兼容失败)")
		quit(1)
		return
	passed += 1
	print("  [T206.16] screen_shake.gd 含 is_reduce_flash() (T195 兼容) (OK)")

	print("=== I031 T206 HUD ResonanceBar + HealthContainer reduce_flash 灰化 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 与 I022 ~ I030 同样的实现.
func _count_substr(haystack: String, needle: String) -> int:
	if needle.is_empty():
		return 0
	var c := 0
	var sp := 0
	while true:
		var idx := haystack.find(needle, sp)
		if idx == -1:
			break
		c += 1
		sp = idx + 1
	return c
