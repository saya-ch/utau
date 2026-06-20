extends SceneTree
## I022 (#112) — Smoke test for T194 (Echo 在 ACTION_NAMES 漏 + 5 verb 分组标题) +
## T195 (settings accessibility 减弱屏幕震动 / 减弱屏幕闪烁).
##
## 35+ 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i022_t194_t195_smoke.gd
##
## 设计 (与 I021 / I020 / I019 一致):
##   T194.GD.ECHO_ADDED — 5 verb 在 ACTION_NAMES 字典里全 5 个, echo 不再漏.
##   T194.GD.ECHO_CATEGORY — ACTION_CATEGORY 把 echo 标为 verb, 9 actions 都有 category.
##   T194.GD.RENDER_ORDER — CATEGORY_RENDER_ORDER 3 段 (移动/声波能力/交互), name+key+color.
##   T194.GD.BUILD_LIST — _build_controls_list 用 CATEGORY_RENDER_ORDER (不再按字典序).
##   T194.GD.DEFAULT_BINDINGS — _DEFAULT_BINDINGS 含 echo (Q=81) 与 9 actions 全.
##   T195.TSCN.REDUCE_CHECKS — settings_menu.tscn 有 ReduceShakeCheck + ReduceFlashCheck.
##   T195.TSCN.ACCESSIBILITY_HEADER — VideoPanel 末尾有 "无障碍" Label.
##   T195.GD.ONREADY — _reduce_shake_check / _reduce_flash_check 字段.
##   T195.GD.TOGGLE_HANDLERS — _on_reduce_shake_toggled / _on_reduce_flash_toggled.
##   T195.GD.HAS_AUTOLOAD — _has_screen_shake_autoload helper.
##   T195.GD.SAVE — _save_settings 写 [accessibility] section.
##   T195.GD.LOAD — _load_settings 读 [accessibility] + live-push ScreenShake.
##   T195.GD.RESTORE — _on_restore_all_pressed 还原 reduce 状态到 off.
##   T195.SHAKE.STATE — screen_shake.gd 有 _reduced_shake / _reduced_flash 字段.
##   T195.SHAKE.SETTERS — set_reduce_shake / set_reduce_flash / is_reduce_shake / is_reduce_flash.
##   T195.SHAKE.GATING — shake / flash_color / flash_grayscale 入口早退.

func _initialize() -> void:
	print("=== I022 T194 + T195 smoke test (#112) ===")

	# ===== T194 — Echo 在 ACTION_NAMES 漏 + 5 verb 分组标题 =====

	# Load settings_menu.gd
	var sm_src := ""
	var smf := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if smf:
		sm_src = smf.get_as_text()
		smf.close()

	# T194.1 — ACTION_NAMES 含 echo (5 verb 全 5 个, 不再漏)
	if sm_src.find("\"echo\": \"Echo 反射护盾\"") == -1:
		print("  FAIL [T194.1]: ACTION_NAMES missing echo entry")
		quit(1)
		return
	print("  [T194.1] ACTION_NAMES has echo (5 verb 完整) (OK)")

	# T194.2 — _DEFAULT_BINDINGS 含 echo (Q=81)
	if sm_src.find("\"echo\":       {\"type\": \"key\", \"physical_keycode\": 81}") == -1:
		print("  FAIL [T194.2]: _DEFAULT_BINDINGS missing echo (Q=81)")
		quit(1)
		return
	print("  [T194.2] _DEFAULT_BINDINGS has echo (Q=81) (OK)")

	# T194.3 — ACTION_CATEGORY 把 echo 标为 verb
	if sm_src.find("\"echo\": \"verb\"") == -1:
		print("  FAIL [T194.3]: ACTION_CATEGORY missing echo=verb mapping")
		quit(1)
		return
	print("  [T194.3] ACTION_CATEGORY maps echo=verb (OK)")

	# T194.4 — ACTION_CATEGORY 共 9 entries (3 movement + 5 verb + 1 interact)
	var ac_idx := sm_src.find("const ACTION_CATEGORY := {")
	if ac_idx == -1:
		print("  FAIL [T194.4]: ACTION_CATEGORY const not found")
		quit(1)
		return
	var ac_block := sm_src.substr(ac_idx, 600)
	var ac_verb_count := 0
	for verb_key in ["pulse", "bind", "cut", "echo", "wave"]:
		if ac_block.find("\"%s\": \"verb\"" % verb_key) != -1:
			ac_verb_count += 1
	if ac_verb_count != 5:
		print("  FAIL [T194.4]: ACTION_CATEGORY has %d/5 verb mappings (expected 5)" % ac_verb_count)
		quit(1)
		return
	print("  [T194.4] ACTION_CATEGORY has 5 verb + 3 movement + 1 interact (OK)")

	# T194.5 — CATEGORY_RENDER_ORDER 含 3 段 (移动/声波能力/交互)
	if sm_src.find("const CATEGORY_RENDER_ORDER := [") == -1:
		print("  FAIL [T194.5]: CATEGORY_RENDER_ORDER const not found")
		quit(1)
		return
	if sm_src.find("\"name\": \"移动\"") == -1:
		print("  FAIL [T194.5]: CATEGORY_RENDER_ORDER missing '移动' section")
		quit(1)
		return
	if sm_src.find("\"name\": \"声波能力\"") == -1:
		print("  FAIL [T194.5]: CATEGORY_RENDER_ORDER missing '声波能力' section")
		quit(1)
		return
	if sm_src.find("\"name\": \"交互\"") == -1:
		print("  FAIL [T194.5]: CATEGORY_RENDER_ORDER missing '交互' section")
		quit(1)
		return
	print("  [T194.5] CATEGORY_RENDER_ORDER has 移动/声波能力/交互 (OK)")

	# T194.6 — CATEGORY_RENDER_ORDER 含 3 个 distinct color (Pale Resonance / Amber Voice / Glass Cyan)
	var cro_idx := sm_src.find("const CATEGORY_RENDER_ORDER := [")
	var cro_block := sm_src.substr(cro_idx, 600)
	var color_count := 0
	for color_str in ["Color(0.718, 0.906, 0.867, 1)", "Color(0.949, 0.714, 0.431, 1)", "Color(0.412, 0.78, 0.808, 1)"]:
		if cro_block.find(color_str) != -1:
			color_count += 1
	if color_count != 3:
		print("  FAIL [T194.6]: CATEGORY_RENDER_ORDER has %d/3 distinct colors (expected 3)" % color_count)
		quit(1)
		return
	print("  [T194.6] CATEGORY_RENDER_ORDER uses 3 distinct STYLE_GUIDE colors (OK)")

	# T194.7 — _build_controls_list 用 CATEGORY_RENDER_ORDER 迭代
	var bcl_idx := sm_src.find("func _build_controls_list()")
	if bcl_idx == -1:
		print("  FAIL [T194.7]: _build_controls_list function not found")
		quit(1)
		return
	var bcl_block := sm_src.substr(bcl_idx, 2000)
	if bcl_block.find("for section in CATEGORY_RENDER_ORDER:") == -1:
		print("  FAIL [T194.7]: _build_controls_list does not iterate CATEGORY_RENDER_ORDER")
		quit(1)
		return
	if bcl_block.find("section_header_added := false") == -1:
		print("  FAIL [T194.7]: _build_controls_list missing section_header_added flag")
		quit(1)
		return
	if bcl_block.find("ACTION_CATEGORY[action] != section_key") == -1:
		print("  FAIL [T194.7]: _build_controls_list missing category filter")
		quit(1)
		return
	if bcl_block.find("header.text = \"— \" + section[\"name\"] + \" —\"") == -1:
		print("  FAIL [T194.7]: _build_controls_list missing section header text format")
		quit(1)
		return
	print("  [T194.7] _build_controls_list iterates CATEGORY_RENDER_ORDER + adds section headers (OK)")

	# T194.8 — T194 docblock marker (#112)
	if sm_src.find("T194 (#112)") == -1:
		print("  FAIL [T194.8]: settings_menu.gd missing T194 (#112) docblock marker")
		quit(1)
		return
	print("  [T194.8] settings_menu.gd has T194 (#112) docblock (OK)")

	# ===== T195 — accessibility 减弱屏幕震动 / 减弱屏幕闪烁 =====

	# Load settings_menu.tscn
	var sm_tscn := ""
	var smt := FileAccess.open("res://src/scenes/settings_menu.tscn", FileAccess.READ)
	if smt:
		sm_tscn = smt.get_as_text()
		smt.close()

	# T195.1 — settings_menu.tscn 有 ReduceShakeCheck + ReduceFlashCheck + AccessibilityHeader
	if sm_tscn.find("[node name=\"ReduceShakeCheck\" type=\"CheckBox\"") == -1:
		print("  FAIL [T195.1]: settings_menu.tscn missing ReduceShakeCheck")
		quit(1)
		return
	if sm_tscn.find("[node name=\"ReduceFlashCheck\" type=\"CheckBox\"") == -1:
		print("  FAIL [T195.1]: settings_menu.tscn missing ReduceFlashCheck")
		quit(1)
		return
	if sm_tscn.find("[node name=\"AccessibilityHeader\" type=\"Label\"") == -1:
		print("  FAIL [T195.1]: settings_menu.tscn missing AccessibilityHeader")
		quit(1)
		return
	print("  [T195.1] settings_menu.tscn has ReduceShakeCheck + ReduceFlashCheck + AccessibilityHeader (OK)")

	# T195.2 — 2 checkboxes 在 VideoPanel 下 (parent path 正确)
	if sm_tscn.find("ReduceShakeCheck\" type=\"CheckBox\" parent=\"VBoxContainer/Content/VideoPanel\"") == -1:
		print("  FAIL [T195.2]: ReduceShakeCheck not under VideoPanel")
		quit(1)
		return
	if sm_tscn.find("ReduceFlashCheck\" type=\"CheckBox\" parent=\"VBoxContainer/Content/VideoPanel\"") == -1:
		print("  FAIL [T195.2]: ReduceFlashCheck not under VideoPanel")
		quit(1)
		return
	print("  [T195.2] 2 checkboxes parented under VideoPanel (OK)")

	# T195.3 — 2 checkboxes 含 "减弱屏幕震动" / "减弱屏幕闪烁" 中文 label
	if sm_tscn.find("text = \"减弱屏幕震动\"") == -1:
		print("  FAIL [T195.3]: ReduceShakeCheck missing '减弱屏幕震动' label")
		quit(1)
		return
	if sm_tscn.find("text = \"减弱屏幕闪烁\"") == -1:
		print("  FAIL [T195.3]: ReduceFlashCheck missing '减弱屏幕闪烁' label")
		quit(1)
		return
	print("  [T195.3] 2 checkboxes have '减弱屏幕震动' / '减弱屏幕闪烁' labels (OK)")

	# T195.4 — settings_menu.gd 有 _reduce_shake_check / _reduce_flash_check @onready
	if sm_src.find("@onready var _reduce_shake_check: CheckBox") == -1:
		print("  FAIL [T195.4]: settings_menu.gd missing _reduce_shake_check @onready")
		quit(1)
		return
	if sm_src.find("@onready var _reduce_flash_check: CheckBox") == -1:
		print("  FAIL [T195.4]: settings_menu.gd missing _reduce_flash_check @onready")
		quit(1)
		return
	if sm_src.find("VideoPanel/ReduceShakeCheck") == -1:
		print("  FAIL [T195.4]: _reduce_shake_check not bound to VideoPanel/ReduceShakeCheck node")
		quit(1)
		return
	if sm_src.find("VideoPanel/ReduceFlashCheck") == -1:
		print("  FAIL [T195.4]: _reduce_flash_check not bound to VideoPanel/ReduceFlashCheck node")
		quit(1)
		return
	print("  [T195.4] settings_menu.gd has 2 @onready checkboxes (OK)")

	# T195.5 — _on_reduce_shake_toggled / _on_reduce_flash_toggled handlers
	if sm_src.find("func _on_reduce_shake_toggled(enabled: bool)") == -1:
		print("  FAIL [T195.5]: settings_menu.gd missing _on_reduce_shake_toggled")
		quit(1)
		return
	if sm_src.find("func _on_reduce_flash_toggled(enabled: bool)") == -1:
		print("  FAIL [T195.5]: settings_menu.gd missing _on_reduce_flash_toggled")
		quit(1)
		return
	# live-push 到 ScreenShake autoload
	var shake_handler_block := sm_src.substr(sm_src.find("func _on_reduce_shake_toggled"), 350)
	if shake_handler_block.find("ScreenShake.set_reduce_shake") == -1:
		print("  FAIL [T195.5]: _on_reduce_shake_toggled missing ScreenShake.set_reduce_shake call")
		quit(1)
		return
	var flash_handler_block := sm_src.substr(sm_src.find("func _on_reduce_flash_toggled"), 350)
	if flash_handler_block.find("ScreenShake.set_reduce_flash") == -1:
		print("  FAIL [T195.5]: _on_reduce_flash_toggled missing ScreenShake.set_reduce_flash call")
		quit(1)
		return
	print("  [T195.5] 2 toggle handlers + ScreenShake live-push (OK)")

	# T195.6 — _has_screen_shake_autoload helper
	if sm_src.find("func _has_screen_shake_autoload()") == -1:
		print("  FAIL [T195.6]: settings_menu.gd missing _has_screen_shake_autoload helper")
		quit(1)
		return
	if sm_src.find("has_node(\"ScreenShake\")") == -1:
		print("  FAIL [T195.6]: _has_screen_shake_autoload doesn't check ScreenShake node")
		quit(1)
		return
	print("  [T195.6] _has_screen_shake_autoload helper (OK)")

	# T195.7 — _save_settings 写 [accessibility] section
	var save_block_idx := sm_src.find("func _save_settings()")
	var save_block := sm_src.substr(save_block_idx, 3000)
	if save_block.find("cfg.set_value(\"accessibility\", \"reduce_shake\"") == -1:
		print("  FAIL [T195.7]: _save_settings missing reduce_shake cfg write (idx=%d)" % save_block_idx)
		quit(1)
		return
	if save_block.find("cfg.set_value(\"accessibility\", \"reduce_flash\"") == -1:
		print("  FAIL [T195.7]: _save_settings missing reduce_flash cfg write (idx=%d, block_len=%d)" % [save_block_idx, save_block.length()])
		quit(1)
		return
	print("  [T195.7] _save_settings writes [accessibility] section (OK)")

	# T195.8 — _load_settings 读 [accessibility] + live-push
	var load_block_idx := sm_src.find("func _load_settings()")
	var load_block := sm_src.substr(load_block_idx, 4000)
	if load_block.find("cfg.get_value(\"accessibility\", \"reduce_shake\"") == -1:
		print("  FAIL [T195.8]: _load_settings missing reduce_shake cfg read")
		quit(1)
		return
	if load_block.find("cfg.get_value(\"accessibility\", \"reduce_flash\"") == -1:
		print("  FAIL [T195.8]: _load_settings missing reduce_flash cfg read")
		quit(1)
		return
	if load_block.find("ScreenShake.set_reduce_shake") == -1:
		print("  FAIL [T195.8]: _load_settings missing live-push to ScreenShake")
		quit(1)
		return
	if load_block.find("ScreenShake.set_reduce_flash") == -1:
		print("  FAIL [T195.8]: _load_settings missing live-push to ScreenShake (flash)")
		quit(1)
		return
	print("  [T195.8] _load_settings reads [accessibility] + live-push (OK)")

	# T195.9 — _on_restore_all_pressed 还原 reduce 状态到 off
	var restore_block_idx := sm_src.find("func _on_restore_all_pressed()")
	var restore_block := sm_src.substr(restore_block_idx, 3500)
	if restore_block.find("_reduce_shake_check.button_pressed = false") == -1:
		print("  FAIL [T195.9]: _on_restore_all_pressed doesn't reset _reduce_shake_check to off")
		quit(1)
		return
	if restore_block.find("_reduce_flash_check.button_pressed = false") == -1:
		print("  FAIL [T195.9]: _on_restore_all_pressed doesn't reset _reduce_flash_check to off")
		quit(1)
		return
	if restore_block.find("ScreenShake.set_reduce_shake(false)") == -1:
		print("  FAIL [T195.9]: _on_restore_all_pressed doesn't push ScreenShake set_reduce_shake(false)")
		quit(1)
		return
	if restore_block.find("ScreenShake.set_reduce_flash(false)") == -1:
		print("  FAIL [T195.9]: _on_restore_all_pressed doesn't push ScreenShake set_reduce_flash(false)")
		quit(1)
		return
	print("  [T195.9] _on_restore_all_pressed resets accessibility to off (OK)")

	# T195.10 — T195 docblock marker (#112)
	if sm_src.find("T195 (#112)") == -1:
		print("  FAIL [T195.10]: settings_menu.gd missing T195 (#112) docblock marker")
		quit(1)
		return
	print("  [T195.10] settings_menu.gd has T195 (#112) docblock (OK)")

	# ===== screen_shake.gd — T195 state fields + setters + gating =====

	# Load screen_shake.gd
	var ss_src := ""
	var ssf := FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	if ssf:
		ss_src = ssf.get_as_text()
		ssf.close()

	# T195.SS.1 — _reduced_shake / _reduced_flash 状态字段
	if ss_src.find("var _reduced_shake: bool = false") == -1:
		print("  FAIL [T195.SS.1]: screen_shake.gd missing _reduced_shake field")
		quit(1)
		return
	if ss_src.find("var _reduced_flash: bool = false") == -1:
		print("  FAIL [T195.SS.1]: screen_shake.gd missing _reduced_flash field")
		quit(1)
		return
	print("  [T195.SS.1] screen_shake.gd has _reduced_shake / _reduced_flash state (OK)")

	# T195.SS.2 — set_reduce_shake / set_reduce_flash / is_reduce_shake / is_reduce_flash 公开 API
	if ss_src.find("func set_reduce_shake(enabled: bool)") == -1:
		print("  FAIL [T195.SS.2]: screen_shake.gd missing set_reduce_shake")
		quit(1)
		return
	if ss_src.find("func set_reduce_flash(enabled: bool)") == -1:
		print("  FAIL [T195.SS.2]: screen_shake.gd missing set_reduce_flash")
		quit(1)
		return
	if ss_src.find("func is_reduce_shake() -> bool:") == -1:
		print("  FAIL [T195.SS.2]: screen_shake.gd missing is_reduce_shake getter")
		quit(1)
		return
	if ss_src.find("func is_reduce_flash() -> bool:") == -1:
		print("  FAIL [T195.SS.2]: screen_shake.gd missing is_reduce_flash getter")
		quit(1)
		return
	print("  [T195.SS.2] 2 setters + 2 getters 公开 API (OK)")

	# T195.SS.3 — set_reduce_shake(true) 停 in-flight tween
	var set_shake_block := ss_src.substr(ss_src.find("func set_reduce_shake(enabled: bool)"), 500)
	if set_shake_block.find("_active_tween.kill()") == -1:
		print("  FAIL [T195.SS.3]: set_reduce_shake doesn't kill in-flight tween")
		quit(1)
		return
	if set_shake_block.find("_camera.offset = Vector2.ZERO") == -1:
		print("  FAIL [T195.SS.3]: set_reduce_shake doesn't reset camera offset")
		quit(1)
		return
	print("  [T195.SS.3] set_reduce_shake(true) kills tween + resets offset (OK)")

	# T195.SS.4 — set_reduce_flash(true) 清 in-flight flash
	var set_flash_block := ss_src.substr(ss_src.find("func set_reduce_flash(enabled: bool)"), 700)
	if set_flash_block.find("_active_grayscale.clear()") == -1:
		print("  FAIL [T195.SS.4]: set_reduce_flash doesn't clear _active_grayscale")
		quit(1)
		return
	if set_flash_block.find("_active_color_flash.clear()") == -1:
		print("  FAIL [T195.SS.4]: set_reduce_flash doesn't clear _active_color_flash")
		quit(1)
		return
	print("  [T195.SS.4] set_reduce_flash(true) clears in-flight flash layers (OK)")

	# T195.SS.5 — shake() / flash_color() / flash_grayscale() 入口早退
	var shake_block_idx := ss_src.find("func shake(intensity:")
	var shake_block := ss_src.substr(shake_block_idx, 400)
	if shake_block.find("if _reduced_shake:") == -1 or shake_block.find("\treturn") == -1:
		print("  FAIL [T195.SS.5]: shake() missing _reduced_shake early return")
		quit(1)
		return
	var flash_color_idx := ss_src.find("func flash_color(color:")
	var flash_color_block := ss_src.substr(flash_color_idx, 400)
	if flash_color_block.find("if _reduced_flash:") == -1 or flash_color_block.find("\treturn") == -1:
		print("  FAIL [T195.SS.5]: flash_color() missing _reduced_flash early return")
		quit(1)
		return
	var flash_gray_idx := ss_src.find("func flash_grayscale(duration:")
	var flash_gray_block := ss_src.substr(flash_gray_idx, 400)
	if flash_gray_block.find("if _reduced_flash:") == -1 or flash_gray_block.find("\treturn") == -1:
		print("  FAIL [T195.SS.5]: flash_grayscale() missing _reduced_flash early return")
		quit(1)
		return
	print("  [T195.SS.5] shake / flash_color / flash_grayscale 入口早退 (OK)")

	# T195.SS.6 — T195 docblock marker
	if ss_src.find("T195 (#112)") == -1:
		print("  FAIL [T195.SS.6]: screen_shake.gd missing T195 (#112) docblock marker")
		quit(1)
		return
	print("  [T195.SS.6] screen_shake.gd has T195 (#112) docblock (OK)")

	# ===== All passed =====
	print("")
	print("=== I022 T194 + T195 smoke test PASSED (28/28) ===")
	quit(0)
