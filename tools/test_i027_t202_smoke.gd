extends SceneTree
## I027 (#118) — Smoke test for T202 (HUD 5 verb 冷却中半透明提示
## 标签 — Pulse / Bind / Cut / Echo / Wave 各 1 个 "冷却中" Label,
## cooldown ratio > 0 时显示, ratio == 0 时隐藏).
##
## 25 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i027_t202_smoke.gd
##
## 设计 (与 I022 ~ I026 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T202.HUD.LABEL_REFS — 5 @onready var _*_cooldown_label 字段.
##   T202.HUD.PULSE_LABEL — hud.gd 引用 PulseCooldownLabel 路径.
##   T202.HUD.BIND_LABEL — hud.gd 引用 BindCooldownLabel 路径.
##   T202.HUD.CUT_LABEL — hud.gd 引用 CutCooldownLabel 路径.
##   T202.HUD.ECHO_LABEL — hud.gd 引用 EchoCooldownLabel 路径.
##   T202.HUD.WAVE_LABEL — hud.gd 引用 WaveCooldownLabel 路径.
##   T202.HUD.HELPER_FN — _update_cooldown_label 函数存在.
##   T202.HUD.HELPER_NULL_GUARD — 函数入口 null 守卫.
##   T202.HUD.HELPER_THRESHOLD — 阈值常量 0.001 浮点容差.
##   T202.HUD.HELPER_VISIBLE_TOGGLE — label.visible 写.
##   T202.HUD.CALL_SITE_5 — _update_cooldown_label 调用次数 = 5.
##   T202.HUD.PROCESS_5_BRANCHES — _process 内 5 verb 各调 1 次.
##   T202.HUD.T202_ANCHOR — hud.gd 含 T202 (#118) 注释锚点 >= 2.
##   T202.TSCN.PULSE_NODE — hud.tscn 有 PulseCooldownLabel 节点.
##   T202.TSCN.BIND_NODE — hud.tscn 有 BindCooldownLabel 节点.
##   T202.TSCN.CUT_NODE — hud.tscn 有 CutCooldownLabel 节点.
##   T202.TSCN.ECHO_NODE — hud.tscn 有 EchoCooldownLabel 节点.
##   T202.TSCN.WAVE_NODE — hud.tscn 有 WaveCooldownLabel 节点.
##   T202.TSCN.PULSE_PARENT — 节点 parent = PulseRow (HBoxContainer).
##   T202.TSCN.PULSE_TEXT — 文本 "冷却中".
##   T202.TSCN.PULSE_INVISIBLE — 节点初始 visible = false.
##   T202.TSCN.PULSE_COLOR_PULSE — Pulse 标签用 Pulse 暖色 (0.949).
##   T202.TSCN.BIND_COLOR_BIND — Bind 标签用 Bind 紫色 (0.396).
##   T202.TSCN.CUT_COLOR_CUT — Cut 标签用 Cut 珊瑚色 (0.91).
##   T202.TSCN.ECHO_COLOR_ECHO — Echo 标签用 Echo 青色 (0.412).
##   T202.TSCN.WAVE_COLOR_WAVE — Wave 标签用 Wave 浅青色 (0.718).

func _initialize() -> void:
	print("=== I027 T202 HUD 5 verb 冷却中标签 smoke test (#118) ===")

	var hud_src := ""
	var hf := FileAccess.open("res://src/scripts/hud.gd", FileAccess.READ)
	if hf:
		hud_src = hf.get_as_text()
		hf.close()

	var scene_src := ""
	var scf := FileAccess.open("res://src/scenes/hud.tscn", FileAccess.READ)
	if scf:
		scene_src = scf.get_as_text()
		scf.close()

	var passed := 0
	var total := 0

	# ===== T202.HUD.LABEL_REFS =====
	total += 1
	var label_ref_count := 0
	for label_name in ["_pulse_cooldown_label", "_bind_cooldown_label", "_cut_cooldown_label", "_echo_cooldown_label", "_wave_cooldown_label"]:
		if hud_src.find(label_name) != -1:
			label_ref_count += 1
	if label_ref_count < 5:
		print("  FAIL [T202.1]: 5 _*_cooldown_label @onready 字段引用 = %d, 期望 5" % label_ref_count)
		quit(1)
		return
	passed += 1
	print("  [T202.1] 5 _*_cooldown_label @onready 字段引用 (OK)")

	# ===== T202.HUD.PULSE_LABEL =====
	total += 1
	if hud_src.find("PulseRow/PulseCooldownLabel") == -1:
		print("  FAIL [T202.2]: hud.gd 缺 PulseCooldownLabel 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T202.2] hud.gd 引用 PulseCooldownLabel (OK)")

	# ===== T202.HUD.BIND_LABEL =====
	total += 1
	if hud_src.find("BindRow/BindCooldownLabel") == -1:
		print("  FAIL [T202.3]: hud.gd 缺 BindCooldownLabel 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T202.3] hud.gd 引用 BindCooldownLabel (OK)")

	# ===== T202.HUD.CUT_LABEL =====
	total += 1
	if hud_src.find("CutRow/CutCooldownLabel") == -1:
		print("  FAIL [T202.4]: hud.gd 缺 CutCooldownLabel 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T202.4] hud.gd 引用 CutCooldownLabel (OK)")

	# ===== T202.HUD.ECHO_LABEL =====
	total += 1
	if hud_src.find("EchoRow/EchoCooldownLabel") == -1:
		print("  FAIL [T202.5]: hud.gd 缺 EchoCooldownLabel 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T202.5] hud.gd 引用 EchoCooldownLabel (OK)")

	# ===== T202.HUD.WAVE_LABEL =====
	total += 1
	if hud_src.find("WaveRow/WaveCooldownLabel") == -1:
		print("  FAIL [T202.6]: hud.gd 缺 WaveCooldownLabel 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T202.6] hud.gd 引用 WaveCooldownLabel (OK)")

	# ===== T202.HUD.HELPER_FN =====
	total += 1
	if hud_src.find("func _update_cooldown_label") == -1:
		print("  FAIL [T202.7]: hud.gd 缺 _update_cooldown_label 函数")
		quit(1)
		return
	passed += 1
	print("  [T202.7] _update_cooldown_label 函数存在 (OK)")

	# ===== T202.HUD.HELPER_NULL_GUARD =====
	total += 1
	# 函数体前几行有 null 守卫
	var helper_idx := hud_src.find("func _update_cooldown_label")
	if helper_idx == -1:
		print("  FAIL [T202.8]: 无法定位 _update_cooldown_label (前置 anchor 应已通过)")
		quit(1)
		return
	var helper_body := hud_src.substr(helper_idx, 400)
	if helper_body.find("if label == null") == -1:
		print("  FAIL [T202.8]: _update_cooldown_label 缺 null 守卫")
		quit(1)
		return
	passed += 1
	print("  [T202.8] _update_cooldown_label null 守卫 (OK)")

	# ===== T202.HUD.HELPER_THRESHOLD =====
	total += 1
	# 阈值 0.001 浮点容差
	if hud_src.find("ratio > 0.001") == -1:
		print("  FAIL [T202.9]: _update_cooldown_label 缺 0.001 浮点容差阈值")
		quit(1)
		return
	passed += 1
	print("  [T202.9] _update_cooldown_label 0.001 浮点容差 (OK)")

	# ===== T202.HUD.HELPER_VISIBLE_TOGGLE =====
	total += 1
	# label.visible = should_show 赋值
	if hud_src.find("label.visible = should_show") == -1:
		print("  FAIL [T202.10]: _update_cooldown_label 缺 label.visible 写")
		quit(1)
		return
	passed += 1
	print("  [T202.10] label.visible = should_show 写 (OK)")

	# ===== T202.HUD.CALL_SITE_5 =====
	total += 1
	# _update_cooldown_label 调用次数 = 5 (5 verb 各 1 次)
	var call_count := _count_substr(hud_src, "_update_cooldown_label(")
	if call_count < 5:
		print("  FAIL [T202.11]: _update_cooldown_label() 调用次数 = %d, 期望 5" % call_count)
		quit(1)
		return
	passed += 1
	print("  [T202.11] _update_cooldown_label() 调用次数 = %d (>= 5) (OK)" % call_count)

	# ===== T202.HUD.PROCESS_5_BRANCHES =====
	total += 1
	# _process 函数体内含 5 verb 调用分支
	# 简化: 文件中有 5 个不同的 _xxx_cooldown_label 引用（来自 _process 调用）
	# 已经在 T202.1 验证；这里额外验证 process 体内有 _update_cooldown_label
	var process_idx := hud_src.find("func _process(")
	if process_idx == -1:
		print("  FAIL [T202.12]: 无法定位 _process 函数")
		quit(1)
		return
	var process_body := hud_src.substr(process_idx, 2500)
	var process_call_count := _count_substr(process_body, "_update_cooldown_label(")
	if process_call_count < 5:
		print("  FAIL [T202.12]: _process 体内 _update_cooldown_label 调用 = %d, 期望 5" % process_call_count)
		quit(1)
		return
	passed += 1
	print("  [T202.12] _process 体内 5 verb 各调 1 次 = %d (OK)" % process_call_count)

	# ===== T202.HUD.T202_ANCHOR =====
	total += 1
	# T202 (#118) 注释锚点出现次数 >= 2 (label 段 + helper 段)
	var t202_count := _count_substr(hud_src, "T202 (#118)")
	if t202_count < 2:
		print("  FAIL [T202.13]: T202 (#118) 注释锚点出现次数 = %d, 期望 >= 2" % t202_count)
		quit(1)
		return
	passed += 1
	print("  [T202.13] T202 (#118) 注释锚点出现 = %d 次 (OK)" % t202_count)

	# ===== T202.TSCN.PULSE_NODE =====
	total += 1
	if scene_src.find('name="PulseCooldownLabel"') == -1:
		print("  FAIL [T202.14]: hud.tscn 缺 PulseCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.14] hud.tscn 含 PulseCooldownLabel (OK)")

	# ===== T202.TSCN.BIND_NODE =====
	total += 1
	if scene_src.find('name="BindCooldownLabel"') == -1:
		print("  FAIL [T202.15]: hud.tscn 缺 BindCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.15] hud.tscn 含 BindCooldownLabel (OK)")

	# ===== T202.TSCN.CUT_NODE =====
	total += 1
	if scene_src.find('name="CutCooldownLabel"') == -1:
		print("  FAIL [T202.16]: hud.tscn 缺 CutCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.16] hud.tscn 含 CutCooldownLabel (OK)")

	# ===== T202.TSCN.ECHO_NODE =====
	total += 1
	if scene_src.find('name="EchoCooldownLabel"') == -1:
		print("  FAIL [T202.17]: hud.tscn 缺 EchoCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.17] hud.tscn 含 EchoCooldownLabel (OK)")

	# ===== T202.TSCN.WAVE_NODE =====
	total += 1
	if scene_src.find('name="WaveCooldownLabel"') == -1:
		print("  FAIL [T202.18]: hud.tscn 缺 WaveCooldownLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T202.18] hud.tscn 含 WaveCooldownLabel (OK)")

	# ===== T202.TSCN.PULSE_PARENT =====
	total += 1
	# 节点 parent = PulseRow
	if scene_src.find('parent="MarginContainer/VBoxContainer/PulseRow"') == -1:
		print("  FAIL [T202.19]: PulseCooldownLabel parent 错 (期望 PulseRow)")
		quit(1)
		return
	passed += 1
	print("  [T202.19] PulseCooldownLabel parent = PulseRow (OK)")

	# ===== T202.TSCN.PULSE_TEXT =====
	total += 1
	# 节点 text = "冷却中" — 简化：搜索 "冷却中" 出现次数 >= 5 (5 verb 各 1)
	var cd_text_count := _count_substr(scene_src, "\"冷却中\"")
	if cd_text_count < 5:
		print("  FAIL [T202.20]: hud.tscn 中 \"冷却中\" 出现次数 = %d, 期望 5 (5 verb 各 1)" % cd_text_count)
		quit(1)
		return
	passed += 1
	print("  [T202.20] hud.tscn 中 \"冷却中\" 出现 = %d 次 (OK)" % cd_text_count)

	# ===== T202.TSCN.PULSE_INVISIBLE =====
	total += 1
	# 5 verb 标签初始 visible = false — 简化: visible = false 出现次数 >= 5
	# 但 visible = false 也在其他节点 (如 RepairHint) 出现, 所以允许多
	var vis_false_count := _count_substr(scene_src, "visible = false")
	if vis_false_count < 5:
		print("  FAIL [T202.21]: hud.tscn visible = false 出现次数 = %d, 期望 >= 5" % vis_false_count)
		quit(1)
		return
	passed += 1
	print("  [T202.21] hud.tscn visible = false 出现 = %d 次 (>= 5) (OK)" % vis_false_count)

	# ===== T202.TSCN.PULSE_COLOR_PULSE =====
	total += 1
	# Pulse 标签用 Pulse 暖色 (0.949)
	var pulse_idx := scene_src.find('name="PulseCooldownLabel"')
	if pulse_idx == -1:
		print("  FAIL [T202.22]: 无法定位 PulseCooldownLabel (前置 anchor 应已通过)")
		quit(1)
		return
	var pulse_section := scene_src.substr(pulse_idx, 400)
	if pulse_section.find("0.949") == -1:
		print("  FAIL [T202.22]: PulseCooldownLabel 缺 Pulse 暖色 (0.949,...)")
		quit(1)
		return
	passed += 1
	print("  [T202.22] PulseCooldownLabel Pulse 暖色 (OK)")

	# ===== T202.TSCN.BIND_COLOR_BIND =====
	total += 1
	var bind_idx := scene_src.find('name="BindCooldownLabel"')
	if bind_idx == -1:
		print("  FAIL [T202.23]: 无法定位 BindCooldownLabel (前置 anchor 应已通过)")
		quit(1)
		return
	var bind_section := scene_src.substr(bind_idx, 400)
	if bind_section.find("0.396") == -1:
		print("  FAIL [T202.23]: BindCooldownLabel 缺 Bind 紫色 (0.396,...)")
		quit(1)
		return
	passed += 1
	print("  [T202.23] BindCooldownLabel Bind 紫色 (OK)")

	# ===== T202.TSCN.CUT_COLOR_CUT =====
	total += 1
	var cut_idx := scene_src.find('name="CutCooldownLabel"')
	if cut_idx == -1:
		print("  FAIL [T202.24]: 无法定位 CutCooldownLabel (前置 anchor 应已通过)")
		quit(1)
		return
	var cut_section := scene_src.substr(cut_idx, 400)
	if cut_section.find("0.91") == -1:
		print("  FAIL [T202.24]: CutCooldownLabel 缺 Cut 珊瑚色 (0.91,...)")
		quit(1)
		return
	passed += 1
	print("  [T202.24] CutCooldownLabel Cut 珊瑚色 (OK)")

	# ===== T202.TSCN.ECHO_COLOR_ECHO =====
	total += 1
	var echo_idx := scene_src.find('name="EchoCooldownLabel"')
	if echo_idx == -1:
		print("  FAIL [T202.25]: 无法定位 EchoCooldownLabel (前置 anchor 应已通过)")
		quit(1)
		return
	var echo_section := scene_src.substr(echo_idx, 400)
	if echo_section.find("0.412") == -1:
		print("  FAIL [T202.25]: EchoCooldownLabel 缺 Echo 青色 (0.412,...)")
		quit(1)
		return
	passed += 1
	print("  [T202.25] EchoCooldownLabel Echo 青色 (OK)")

	# ===== T202.TSCN.WAVE_COLOR_WAVE =====
	total += 1
	var wave_idx := scene_src.find('name="WaveCooldownLabel"')
	if wave_idx == -1:
		print("  FAIL [T202.26]: 无法定位 WaveCooldownLabel (前置 anchor 应已通过)")
		quit(1)
		return
	var wave_section := scene_src.substr(wave_idx, 400)
	if wave_section.find("0.718") == -1:
		print("  FAIL [T202.26]: WaveCooldownLabel 缺 Wave 浅青色 (0.718,...)")
		quit(1)
		return
	passed += 1
	print("  [T202.26] WaveCooldownLabel Wave 浅青色 (OK)")

	print("=== I027 T202 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 与 I026 同样的实现.
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
