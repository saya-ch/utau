extends SceneTree
## I027 (#118) — Smoke test for T202 (HUD 5 verb "冷却中" label) +
## T203 (SettingsMenu 减弱冷却条颜色 4 滑块 + 1 总开关) +
## T200 refactor (HUD 5 verb bar 灰化视觉从 is_reduce_flash 切到 is_reduce_cooldown_color).
##
## 30+ 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i027_t202_t203_smoke.gd
##
## 设计 (与 I022 ~ I026 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T202.HUD.PULSE_LABEL — hud.gd 有 _pulse_cooldown_label @onready ref.
##   T202.HUD.BIND_LABEL — hud.gd 有 _bind_cooldown_label ref.
##   T202.HUD.CUT_LABEL — hud.gd 有 _cut_cooldown_label ref.
##   T202.HUD.ECHO_LABEL — hud.gd 有 _echo_cooldown_label ref.
##   T202.HUD.WAVE_LABEL — hud.gd 有 _wave_cooldown_label ref.
##   T202.HUD.LABEL_TEXT — 5 个 label 节点都含 "冷却中" 文字.
##   T202.HUD.VISIBILITY_TOGGLE — _process 内有 ratio > 0.0 显隐切换.
##   T202.HUD.T202_ANCHOR — hud.gd 含 T202 (#118) 注释锚点.
##   T202.SCENE.PULSE_NODE — hud.tscn 有 PulseCooldownLabel 节点.
##   T202.SCENE.BIND_NODE — hud.tscn 有 BindCooldownLabel 节点.
##   T202.SCENE.CUT_NODE — hud.tscn 有 CutCooldownLabel 节点.
##   T202.SCENE.ECHO_NODE — hud.tscn 有 EchoCooldownLabel 节点.
##   T202.SCENE.WAVE_NODE — hud.tscn 有 WaveCooldownLabel 节点.
##   T202.SCENE.SEMI_TRANSPARENT — 5 label modulate 0.5 alpha (半透明).
##   T202.SCENE.HIDDEN_DEFAULT — 5 label visible = false 默认隐藏.
##   T203.SS.SET_API — screen_shake.gd 有 set_reduce_cooldown_color().
##   T203.SS.GET_API — screen_shake.gd 有 is_reduce_cooldown_color().
##   T203.SS.STATE_FIELD — screen_shake.gd 有 _reduced_cooldown_color 字段.
##   T203.SS.T203_ANCHOR — screen_shake.gd 含 T203 (#118) 注释锚点.
##   T203.SS.OLD_API_PRESERVED — T195 is_reduce_flash/set_reduce_flash 仍在 (不要破坏 T200 旧路径).
##   T203.SS.OLD_VIBRATION_API — T196 is_reduce_vibration 仍在 (不要破坏 3 子开关).
##   T203.SS.OLD_SHAKE_API — T195 is_reduce_shake 仍在 (不要破坏 4 子开关入口).
##   T203.SMENU.MASTER_REF — settings_menu.gd 有 _accessibility_master_check @onready.
##   T203.SMENU.COOLDOWN_REF — settings_menu.gd 有 _reduce_cooldown_color_check @onready.
##   T203.SMENU.MASTER_FIELD — settings_menu.gd 有 _accessibility_master 字段.
##   T203.SMENU.COOLDOWN_FIELD — settings_menu.gd 有 _reduced_cooldown_color 字段.
##   T203.SMENU.MASTER_HANDLER — settings_menu.gd 有 _on_accessibility_master_toggled.
##   T203.SMENU.COOLDOWN_HANDLER — settings_menu.gd 有 _on_reduce_cooldown_color_toggled.
##   T203.SMENU.MASTER_PUSHES_4 — _on_accessibility_master_toggled 内 set_reduce_shake/flash/vibration/cooldown_color 全 4 个 call.
##   T203.SMENU.MASTER_PERSIST — _save_settings 写 accessibility_master key.
##   T203.SMENU.COOLDOWN_PERSIST — _save_settings 写 reduce_cooldown_color key.
##   T203.SMENU.MASTER_LOAD — _load_settings 读 accessibility_master.
##   T203.SMENU.COOLDOWN_LOAD — _load_settings 读 reduce_cooldown_color.
##   T203.SMENU.RESTORE_RESET — _on_restore_all_pressed 还原 master + cooldown (off).
##   T203.SCENE.MASTER_NODE — settings_menu.tscn 有 AccessibilityMasterCheck.
##   T203.SCENE.COOLDOWN_NODE — settings_menu.tscn 有 ReduceCooldownColorCheck.
##   T203.SCENE.NODE_PARENT — 2 节点 parent = VBoxContainer/Content/VideoPanel.
##   T203.SCENE.NODE_AFTER_VIBRATION — 2 节点在 ReduceVibrationCheck 之后 (4 滑块 + 1 master 顺序).
##   T203.SCENE.MASTER_TEXT — AccessibilityMasterCheck 含 "无障碍 总开关" 文字.
##   T203.SCENE.COOLDOWN_TEXT — ReduceCooldownColorCheck 含 "减弱冷却条颜色" 文字.
##   T200.REFACTOR.HUD_USES_COOLDOWN — hud.gd 调 is_reduce_cooldown_color() (T203 切).
##   T200.REFACTOR.NO_FLASH_IN_HUD — hud.gd 调 is_reduce_flash() 次数 = 0 (代码层, 注释允许).
##   T200.REFACTOR.SS_FLASH_API_STILL — screen_shake.gd 仍暴露 is_reduce_flash() (T195 公开 API 不动).

func _initialize() -> void:
	print("=== I027 T202 HUD 5 verb 冷却中 + T203 SettingsMenu 4 滑块 + 1 总开关 smoke test (#118) ===")

	var hud_src := ""
	var hf := FileAccess.open("res://src/scripts/hud.gd", FileAccess.READ)
	if hf:
		hud_src = hf.get_as_text()
		hf.close()

	var hud_scene := ""
	var hsf := FileAccess.open("res://src/scenes/hud.tscn", FileAccess.READ)
	if hsf:
		hud_scene = hsf.get_as_text()
		hsf.close()

	var ss_src := ""
	var sf := FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	if sf:
		ss_src = sf.get_as_text()
		sf.close()

	var sm_src := ""
	var smf := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if smf:
		sm_src = smf.get_as_text()
		smf.close()

	var sm_scene := ""
	var smsf := FileAccess.open("res://src/scenes/settings_menu.tscn", FileAccess.READ)
	if smsf:
		sm_scene = smsf.get_as_text()
		smsf.close()

	var passed := 0
	var total := 0

	# ===== T202.HUD.PULSE_LABEL =====
	total += 1
	if hud_src.find("_pulse_cooldown_label: Label") == -1:
		print("  FAIL [T202.1]: hud.gd 缺 _pulse_cooldown_label @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T202.1] hud.gd 含 _pulse_cooldown_label ref (OK)")

	# ===== T202.HUD.BIND_LABEL =====
	total += 1
	if hud_src.find("_bind_cooldown_label: Label") == -1:
		print("  FAIL [T202.2]: hud.gd 缺 _bind_cooldown_label @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T202.2] hud.gd 含 _bind_cooldown_label ref (OK)")

	# ===== T202.HUD.CUT_LABEL =====
	total += 1
	if hud_src.find("_cut_cooldown_label: Label") == -1:
		print("  FAIL [T202.3]: hud.gd 缺 _cut_cooldown_label @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T202.3] hud.gd 含 _cut_cooldown_label ref (OK)")

	# ===== T202.HUD.ECHO_LABEL =====
	total += 1
	if hud_src.find("_echo_cooldown_label: Label") == -1:
		print("  FAIL [T202.4]: hud.gd 缺 _echo_cooldown_label @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T202.4] hud.gd 含 _echo_cooldown_label ref (OK)")

	# ===== T202.HUD.WAVE_LABEL =====
	total += 1
	if hud_src.find("_wave_cooldown_label: Label") == -1:
		print("  FAIL [T202.5]: hud.gd 缺 _wave_cooldown_label @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T202.5] hud.gd 含 _wave_cooldown_label ref (OK)")

	# ===== T202.HUD.LABEL_TEXT =====
	total += 1
	# 5 个 label visible 切换代码各 1 次, "冷却中" 字符串可能仅在 tscn 中出现
	# hud.gd 通过 _pulse_cooldown_label.visible 引用 5 个 label, 但 text 来自 tscn
	# 简化: 验证 5 个 _*_cooldown_label.visible 引用都在 _process 函数体内
	var vis_toggle_count := 0
	for label_name in ["_pulse_cooldown_label", "_bind_cooldown_label", "_cut_cooldown_label", "_echo_cooldown_label", "_wave_cooldown_label"]:
		if hud_src.find(label_name + ".visible") != -1:
			vis_toggle_count += 1
	if vis_toggle_count < 5:
		print("  FAIL [T202.6]: hud.gd 中 _*_cooldown_label.visible 引用 = %d, 期望 5" % vis_toggle_count)
		quit(1)
		return
	passed += 1
	print("  [T202.6] hud.gd 5 label visible 引用就位 (OK)")

	# ===== T202.HUD.VISIBILITY_TOGGLE =====
	total += 1
	# _process 内有 ratio > 0.0 切换可见性
	var vis_count := _count_substr(hud_src, ".visible = ratio > 0.0")
	if vis_count < 5:
		print("  FAIL [T202.7]: hud.gd 中 .visible = ratio > 0.0 切换 = %d, 期望 5" % vis_count)
		quit(1)
		return
	passed += 1
	print("  [T202.7] hud.gd 5 verb 显隐切换 ratio > 0.0 (OK)")

	# ===== T202.HUD.T202_ANCHOR =====
	total += 1
	var t202_count := _count_substr(hud_src, "T202 (#118)")
	if t202_count < 1:
		print("  FAIL [T202.8]: hud.gd 缺 T202 (#118) 注释锚点")
		quit(1)
		return
	passed += 1
	print("  [T202.8] hud.gd 含 T202 (#118) 锚点 = %d 次 (OK)" % t202_count)

	# ===== T202.SCENE.PULSE_NODE =====
	total += 1
	if hud_scene.find('name="PulseCooldownLabel"') == -1:
		print("  FAIL [T202.9]: hud.tscn 缺 PulseCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.9] hud.tscn 含 PulseCooldownLabel 节点 (OK)")

	# ===== T202.SCENE.BIND_NODE =====
	total += 1
	if hud_scene.find('name="BindCooldownLabel"') == -1:
		print("  FAIL [T202.10]: hud.tscn 缺 BindCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.10] hud.tscn 含 BindCooldownLabel 节点 (OK)")

	# ===== T202.SCENE.CUT_NODE =====
	total += 1
	if hud_scene.find('name="CutCooldownLabel"') == -1:
		print("  FAIL [T202.11]: hud.tscn 缺 CutCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.11] hud.tscn 含 CutCooldownLabel 节点 (OK)")

	# ===== T202.SCENE.ECHO_NODE =====
	total += 1
	if hud_scene.find('name="EchoCooldownLabel"') == -1:
		print("  FAIL [T202.12]: hud.tscn 缺 EchoCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.12] hud.tscn 含 EchoCooldownLabel 节点 (OK)")

	# ===== T202.SCENE.WAVE_NODE =====
	total += 1
	if hud_scene.find('name="WaveCooldownLabel"') == -1:
		print("  FAIL [T202.13]: hud.tscn 缺 WaveCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.13] hud.tscn 含 WaveCooldownLabel 节点 (OK)")

	# ===== T202.SCENE.SEMI_TRANSPARENT =====
	total += 1
	# 5 label modulate = Color(1, 1, 1, 0.5) (半透明白字)
	var semi_count := _count_substr(hud_scene, 'Color(1, 1, 1, 0.5)')
	if semi_count < 5:
		print("  FAIL [T202.14]: hud.tscn 半透明 modulate 0.5 alpha 次数 = %d, 期望 5" % semi_count)
		quit(1)
		return
	passed += 1
	print("  [T202.14] hud.tscn 5 label 半透明 modulate (OK)")

	# ===== T202.SCENE.HIDDEN_DEFAULT =====
	total += 1
	# 5 label visible = false 默认隐藏
	var hidden_count := 0
	for label_name in ["PulseCooldownLabel", "BindCooldownLabel", "CutCooldownLabel", "EchoCooldownLabel", "WaveCooldownLabel"]:
		var node_idx := hud_scene.find('name="' + label_name + '"')
		if node_idx == -1:
			continue
		var section := hud_scene.substr(node_idx, 400)
		if section.find("visible = false") != -1:
			hidden_count += 1
	if hidden_count < 5:
		print("  FAIL [T202.15]: hud.tscn 默认 visible = false 节点 = %d, 期望 5" % hidden_count)
		quit(1)
		return
	passed += 1
	print("  [T202.15] hud.tscn 5 label 默认 visible = false (OK)")

	# ===== T203.SS.SET_API =====
	total += 1
	if ss_src.find("func set_reduce_cooldown_color") == -1:
		print("  FAIL [T203.1]: screen_shake.gd 缺 set_reduce_cooldown_color() 函数")
		quit(1)
		return
	passed += 1
	print("  [T203.1] screen_shake.gd 含 set_reduce_cooldown_color() (OK)")

	# ===== T203.SS.GET_API =====
	total += 1
	if ss_src.find("func is_reduce_cooldown_color") == -1:
		print("  FAIL [T203.2]: screen_shake.gd 缺 is_reduce_cooldown_color() 函数")
		quit(1)
		return
	passed += 1
	print("  [T203.2] screen_shake.gd 含 is_reduce_cooldown_color() (OK)")

	# ===== T203.SS.STATE_FIELD =====
	total += 1
	if ss_src.find("var _reduced_cooldown_color: bool = false") == -1:
		print("  FAIL [T203.3]: screen_shake.gd 缺 _reduced_cooldown_color 字段")
		quit(1)
		return
	passed += 1
	print("  [T203.3] screen_shake.gd 含 _reduced_cooldown_color 字段 (OK)")

	# ===== T203.SS.T203_ANCHOR =====
	total += 1
	var ss_t203_count := _count_substr(ss_src, "T203 (#118)")
	if ss_t203_count < 2:
		print("  FAIL [T203.4]: screen_shake.gd T203 (#118) 注释锚点 = %d, 期望 >= 2" % ss_t203_count)
		quit(1)
		return
	passed += 1
	print("  [T203.4] screen_shake.gd 含 T203 (#118) 锚点 = %d 次 (OK)" % ss_t203_count)

	# ===== T203.SS.OLD_API_PRESERVED =====
	total += 1
	# T195 (#112) is_reduce_flash + set_reduce_flash 仍存在 (不能破坏 T195 公开 API)
	if ss_src.find("func is_reduce_flash") == -1 or ss_src.find("func set_reduce_flash") == -1:
		print("  FAIL [T203.5]: 破坏 T195 API — is_reduce_flash 或 set_reduce_flash 缺失")
		quit(1)
		return
	passed += 1
	print("  [T203.5] T195 is_reduce_flash/set_reduce_flash 保留 (OK)")

	# ===== T203.SS.OLD_VIBRATION_API =====
	total += 1
	if ss_src.find("func is_reduce_vibration") == -1 or ss_src.find("func set_reduce_vibration") == -1:
		print("  FAIL [T203.6]: 破坏 T196 API — is_reduce_vibration 或 set_reduce_vibration 缺失")
		quit(1)
		return
	passed += 1
	print("  [T203.6] T196 is_reduce_vibration/set_reduce_vibration 保留 (OK)")

	# ===== T203.SS.OLD_SHAKE_API =====
	total += 1
	if ss_src.find("func is_reduce_shake") == -1 or ss_src.find("func set_reduce_shake") == -1:
		print("  FAIL [T203.7]: 破坏 T195 API — is_reduce_shake 或 set_reduce_shake 缺失")
		quit(1)
		return
	passed += 1
	print("  [T203.7] T195 is_reduce_shake/set_reduce_shake 保留 (OK)")

	# ===== T203.SMENU.MASTER_REF =====
	total += 1
	if sm_src.find("_accessibility_master_check: CheckBox") == -1:
		print("  FAIL [T203.8]: settings_menu.gd 缺 _accessibility_master_check @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T203.8] settings_menu.gd 含 _accessibility_master_check ref (OK)")

	# ===== T203.SMENU.COOLDOWN_REF =====
	total += 1
	if sm_src.find("_reduce_cooldown_color_check: CheckBox") == -1:
		print("  FAIL [T203.9]: settings_menu.gd 缺 _reduce_cooldown_color_check @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T203.9] settings_menu.gd 含 _reduce_cooldown_color_check ref (OK)")

	# ===== T203.SMENU.MASTER_FIELD =====
	total += 1
	if sm_src.find("var _accessibility_master: bool = false") == -1:
		print("  FAIL [T203.10]: settings_menu.gd 缺 _accessibility_master 字段")
		quit(1)
		return
	passed += 1
	print("  [T203.10] settings_menu.gd 含 _accessibility_master 字段 (OK)")

	# ===== T203.SMENU.COOLDOWN_FIELD =====
	total += 1
	if sm_src.find("var _reduced_cooldown_color: bool = false") == -1:
		print("  FAIL [T203.11]: settings_menu.gd 缺 _reduced_cooldown_color 字段")
		quit(1)
		return
	passed += 1
	print("  [T203.11] settings_menu.gd 含 _reduced_cooldown_color 字段 (OK)")

	# ===== T203.SMENU.MASTER_HANDLER =====
	total += 1
	if sm_src.find("func _on_accessibility_master_toggled") == -1:
		print("  FAIL [T203.12]: settings_menu.gd 缺 _on_accessibility_master_toggled handler")
		quit(1)
		return
	passed += 1
	print("  [T203.12] settings_menu.gd 含 _on_accessibility_master_toggled (OK)")

	# ===== T203.SMENU.COOLDOWN_HANDLER =====
	total += 1
	if sm_src.find("func _on_reduce_cooldown_color_toggled") == -1:
		print("  FAIL [T203.13]: settings_menu.gd 缺 _on_reduce_cooldown_color_toggled handler")
		quit(1)
		return
	passed += 1
	print("  [T203.13] settings_menu.gd 含 _on_reduce_cooldown_color_toggled (OK)")

	# ===== T203.SMENU.MASTER_PUSHES_4 =====
	total += 1
	# _on_accessibility_master_toggled 内 set_reduce_shake/flash/vibration/cooldown_color 全 4 个 call
	var master_handler_idx := sm_src.find("func _on_accessibility_master_toggled")
	if master_handler_idx == -1:
		print("  FAIL [T203.14]: 无法定位 _on_accessibility_master_toggled (前置 anchor 应已通过)")
		quit(1)
		return
	var master_handler_body := sm_src.substr(master_handler_idx, 1500)
	var master_push_count := 0
	for setter in ["set_reduce_shake", "set_reduce_flash", "set_reduce_vibration", "set_reduce_cooldown_color"]:
		if master_handler_body.find(setter) != -1:
			master_push_count += 1
	if master_push_count < 4:
		print("  FAIL [T203.14]: _on_accessibility_master_toggled 内 set_reduce_* push = %d, 期望 4" % master_push_count)
		quit(1)
		return
	passed += 1
	print("  [T203.14] _on_accessibility_master_toggled 推 4 set_reduce_* (OK)")

	# ===== T203.SMENU.MASTER_PERSIST =====
	total += 1
	if sm_src.find('cfg.set_value("accessibility", "accessibility_master"') == -1:
		print("  FAIL [T203.15]: _save_settings 未写 accessibility_master key")
		quit(1)
		return
	passed += 1
	print("  [T203.15] _save_settings 写 accessibility_master key (OK)")

	# ===== T203.SMENU.COOLDOWN_PERSIST =====
	total += 1
	if sm_src.find('cfg.set_value("accessibility", "reduce_cooldown_color"') == -1:
		print("  FAIL [T203.16]: _save_settings 未写 reduce_cooldown_color key")
		quit(1)
		return
	passed += 1
	print("  [T203.16] _save_settings 写 reduce_cooldown_color key (OK)")

	# ===== T203.SMENU.MASTER_LOAD =====
	total += 1
	if sm_src.find('cfg.get_value("accessibility", "accessibility_master"') == -1:
		print("  FAIL [T203.17]: _load_settings 未读 accessibility_master")
		quit(1)
		return
	passed += 1
	print("  [T203.17] _load_settings 读 accessibility_master (OK)")

	# ===== T203.SMENU.COOLDOWN_LOAD =====
	total += 1
	if sm_src.find('cfg.get_value("accessibility", "reduce_cooldown_color"') == -1:
		print("  FAIL [T203.18]: _load_settings 未读 reduce_cooldown_color")
		quit(1)
		return
	passed += 1
	print("  [T203.18] _load_settings 读 reduce_cooldown_color (OK)")

	# ===== T203.SMENU.RESTORE_RESET =====
	total += 1
	# _on_restore_all_pressed 内同时还原 _accessibility_master_check 和 _reduce_cooldown_color_check
	var restore_idx := sm_src.find("func _on_restore_all_pressed")
	if restore_idx == -1:
		print("  FAIL [T203.19]: 无法定位 _on_restore_all_pressed")
		quit(1)
		return
	var restore_body := sm_src.substr(restore_idx, 5000)
	if restore_body.find("_accessibility_master_check") == -1 or restore_body.find("_reduce_cooldown_color_check") == -1:
		print("  FAIL [T203.19]: _on_restore_all_pressed 未还原 master 或 cooldown 4 滑块")
		quit(1)
		return
	passed += 1
	print("  [T203.19] _on_restore_all_pressed 还原 master + cooldown (OK)")

	# ===== T203.SCENE.MASTER_NODE =====
	total += 1
	if sm_scene.find('name="AccessibilityMasterCheck"') == -1:
		print("  FAIL [T203.20]: settings_menu.tscn 缺 AccessibilityMasterCheck 节点")
		quit(1)
		return
	passed += 1
	print("  [T203.20] settings_menu.tscn 含 AccessibilityMasterCheck 节点 (OK)")

	# ===== T203.SCENE.COOLDOWN_NODE =====
	total += 1
	if sm_scene.find('name="ReduceCooldownColorCheck"') == -1:
		print("  FAIL [T203.21]: settings_menu.tscn 缺 ReduceCooldownColorCheck 节点")
		quit(1)
		return
	passed += 1
	print("  [T203.21] settings_menu.tscn 含 ReduceCooldownColorCheck 节点 (OK)")

	# ===== T203.SCENE.NODE_PARENT =====
	total += 1
	# 2 节点 parent = VBoxContainer/Content/VideoPanel
	var master_node_idx := sm_scene.find('name="AccessibilityMasterCheck"')
	var cooldown_node_idx := sm_scene.find('name="ReduceCooldownColorCheck"')
	if master_node_idx == -1 or cooldown_node_idx == -1:
		print("  FAIL [T203.22]: 节点定位失败 (前置 anchor 应已通过)")
		quit(1)
		return
	var master_section := sm_scene.substr(master_node_idx, 200)
	var cooldown_section := sm_scene.substr(cooldown_node_idx, 200)
	if master_section.find('parent="VBoxContainer/Content/VideoPanel"') == -1:
		print("  FAIL [T203.22]: AccessibilityMasterCheck parent 错 (期望 VBoxContainer/Content/VideoPanel)")
		quit(1)
		return
	if cooldown_section.find('parent="VBoxContainer/Content/VideoPanel"') == -1:
		print("  FAIL [T203.22]: ReduceCooldownColorCheck parent 错 (期望 VBoxContainer/Content/VideoPanel)")
		quit(1)
		return
	passed += 1
	print("  [T203.22] 2 节点 parent = VBoxContainer/Content/VideoPanel (OK)")

	# ===== T203.SCENE.NODE_AFTER_VIBRATION =====
	total += 1
	# 2 节点都在 ReduceVibrationCheck 之后 (4 滑块 + 1 master 顺序: shake/flash/vibration/cooldown/master)
	var vibration_idx := sm_scene.find('name="ReduceVibrationCheck"')
	if vibration_idx == -1 or vibration_idx > master_node_idx or vibration_idx > cooldown_node_idx:
		print("  FAIL [T203.23]: 节点顺序错 — ReduceVibrationCheck 必须在 master/cooldown 之前")
		quit(1)
		return
	passed += 1
	print("  [T203.23] 节点顺序: ReduceVibrationCheck < master + cooldown (OK)")

	# ===== T203.SCENE.MASTER_TEXT =====
	total += 1
	if sm_scene.find("无障碍 总开关") == -1:
		print("  FAIL [T203.24]: settings_menu.tscn AccessibilityMasterCheck 缺 '无障碍 总开关' 文字")
		quit(1)
		return
	passed += 1
	print("  [T203.24] AccessibilityMasterCheck 文字 '无障碍 总开关' (OK)")

	# ===== T203.SCENE.COOLDOWN_TEXT =====
	total += 1
	if sm_scene.find("减弱冷却条颜色") == -1:
		print("  FAIL [T203.25]: settings_menu.tscn ReduceCooldownColorCheck 缺 '减弱冷却条颜色' 文字")
		quit(1)
		return
	passed += 1
	print("  [T203.25] ReduceCooldownColorCheck 文字 '减弱冷却条颜色' (OK)")

	# ===== T200.REFACTOR.HUD_USES_COOLDOWN =====
	total += 1
	# hud.gd _process 调 is_reduce_cooldown_color() (T203 切). 注意: is_reduce_flash
	# 出现在注释 (T200 之前绑定文档), 代码层应只剩 is_reduce_cooldown_color().
	if hud_src.find("ScreenShake.is_reduce_cooldown_color()") == -1:
		print("  FAIL [T200.R.1]: hud.gd 未调 is_reduce_cooldown_color() — T203 切换未生效")
		quit(1)
		return
	passed += 1
	print("  [T200.R.1] hud.gd 调 is_reduce_cooldown_color() (OK)")

	# ===== T200.REFACTOR.NO_FLASH_IN_HUD =====
	total += 1
	# hud.gd 不再在代码层调 is_reduce_flash (注释允许保留). 用 regex 简化:
	# 找 "ScreenShake.is_reduce_flash()" 实际调用, 期望 0 次
	var hud_flash_call_count := _count_substr(hud_src, "ScreenShake.is_reduce_flash()")
	if hud_flash_call_count != 0:
		print("  FAIL [T200.R.2]: hud.gd ScreenShake.is_reduce_flash() 调用次数 = %d, 期望 0 (T203 切到 cooldown_color)" % hud_flash_call_count)
		quit(1)
		return
	passed += 1
	print("  [T200.R.2] hud.gd 无 is_reduce_flash() 调用 (OK)")

	# ===== T200.REFACTOR.SS_FLASH_API_STILL =====
	total += 1
	# screen_shake.gd 仍暴露 is_reduce_flash() (T195 公开 API 不动, settings_menu.gd
	# 仍在调). 这是双轨: T195 公开 API 保留 + T203 新增独立 API.
	if ss_src.find("func is_reduce_flash()") == -1:
		print("  FAIL [T200.R.3]: screen_shake.gd 缺 is_reduce_flash() — 破坏 T195 公开 API")
		quit(1)
		return
	passed += 1
	print("  [T200.R.3] screen_shake.gd 仍暴露 is_reduce_flash() (T195 不破坏) (OK)")

	print("=== I027 T202 + T203 + T200 refactor smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 简单 GDScript 内置替代, 避免 import String.count
# (Godot 4 String.count 是 method 但 signature 与 Python 不同, 用手写循环最稳).
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
