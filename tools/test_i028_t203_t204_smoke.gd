extends SceneTree
## I028 (#119) — Smoke test for T203 (pause_menu.tscn `#` 注释 tscn
## 语法违反修复) + T204 (HUD 5 verb 名称标签 Pulse/Bind/Cut/Echo/Wave
## 5 个新 Label 节点, always-visible 7pt 主题色, 位置 Icon 后 Cooldown 前).
##
## 25 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i028_t203_t204_smoke.gd
##
## 设计 (与 I022 ~ I027 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T203.PM.NO_HASH_COMMENT — pause_menu.tscn 0 个 `#` 注释行 (tscn 语法
##     要求 `;` 起头, `#` 会导致后续节点解析失败, 即 #117 T201 引入的
##     ProfileAvgResonance 节点 "Node not found" ERROR 根因).
##   T203.PM.PROFILE_AVG_NODE — ProfileAvgResonance 节点存在.
##   T203.PM.PROFILE_BEST_NODE — ProfileBestStreak 节点存在.
##   T203.PM.AVG_PARENT — parent = ProfileVBox.
##   T203.PM.AVG_TEXT — text 含 "平均共鸣".
##   T203.PM.BEST_TEXT — text 含 "最佳单局".
##   T203.PM.GLASS_CYAN_COLOR — 2 行都用 Glass Cyan (0.412).
##   T203.GD.ONREADY_AVG — pause_menu.gd 引用 ProfileAvgResonance 路径.
##   T203.GD.ONREADY_BEST — pause_menu.gd 引用 ProfileBestStreak 路径.
##   T203.GD.REFRESH_FN — _refresh_top_aggregate_rows 函数存在.
##   T203.GD.T203_ANCHOR — pause_menu.gd 含 T203 (#119) 注释锚点.
##   T204.HUD.NAME_REFS — 5 _*_name_label @onready 字段引用.
##   T204.HUD.PULSE_NAME_PATH — hud.gd 引用 PulseRow/PulseNameLabel.
##   T204.HUD.BIND_NAME_PATH — hud.gd 引用 BindRow/BindNameLabel.
##   T204.HUD.CUT_NAME_PATH — hud.gd 引用 CutRow/CutNameLabel.
##   T204.HUD.ECHO_NAME_PATH — hud.gd 引用 EchoRow/EchoNameLabel.
##   T204.HUD.WAVE_NAME_PATH — hud.gd 引用 WaveRow/WaveNameLabel.
##   T204.HUD.T204_ANCHOR — hud.gd 含 T204 (#119) 注释锚点 >= 2.
##   T204.TSCN.PULSE_NAME_NODE — hud.tscn 含 PulseNameLabel 节点.
##   T204.TSCN.BIND_NAME_NODE — hud.tscn 含 BindNameLabel 节点.
##   T204.TSCN.CUT_NAME_NODE — hud.tscn 含 CutNameLabel 节点.
##   T204.TSCN.ECHO_NAME_NODE — hud.tscn 含 EchoNameLabel 节点.
##   T204.TSCN.WAVE_NAME_NODE — hud.tscn 含 WaveNameLabel 节点.
##   T204.TSCN.PULSE_NAME_TEXT — PulseNameLabel text = "Pulse".
##   T204.TSCN.ECHO_NAME_COLOR — EchoNameLabel 用 Echo 青 (0.412) 主题色.

func _initialize() -> void:
	print("=== I028 T203 ProfileAvgResonance fix + T204 HUD verb name labels smoke test (#119) ===")

	var hud_src := ""
	var hf := FileAccess.open("res://src/scripts/hud.gd", FileAccess.READ)
	if hf:
		hud_src = hf.get_as_text()
		hf.close()

	var hud_scene_src := ""
	var scf := FileAccess.open("res://src/scenes/hud.tscn", FileAccess.READ)
	if scf:
		hud_scene_src = scf.get_as_text()
		scf.close()

	var pause_src := ""
	var pf := FileAccess.open("res://src/scripts/pause_menu.gd", FileAccess.READ)
	if pf:
		pause_src = pf.get_as_text()
		pf.close()

	var pause_scene_src := ""
	var pcf := FileAccess.open("res://src/scenes/pause_menu.tscn", FileAccess.READ)
	if pcf:
		pause_scene_src = pcf.get_as_text()
		pcf.close()

	var passed := 0
	var total := 0

	# ===== T203.PM.NO_HASH_COMMENT =====
	# pause_menu.tscn 0 个 `#` 注释行. tscn 语法要求 `;` 起头注释,
	# `#` 会导致 Godot 4.6 tscn parser abort at the line, 后续节点
	# 全部解析失败 (即 #117 T201 引入 ProfileAvgResonance 节点
	# "Node not found" ERROR 的根因). 排除节点行内 `#` 注释也不允许
	# (T191 #109 修复 tscn 时显式转 `;`), 严格 0 tolerance.
	total += 1
	# 简化: 用正则找"行起头 # " 模式
	var hash_comment_count := 0
	var line_start := 0
	while true:
		var nl := pause_scene_src.find("\n", line_start)
		var line: String
		if nl == -1:
			line = pause_scene_src.substr(line_start)
		else:
			line = pause_scene_src.substr(line_start, nl - line_start)
		# 跳过 [node ...] 节点行内 `# ` 注释 (虽然 #119 修复后应该 0 个)
		var stripped := line.strip_edges()
		if stripped.begins_with("#"):
			hash_comment_count += 1
		if nl == -1:
			break
		line_start = nl + 1
	if hash_comment_count > 0:
		print("  FAIL [T203.1]: pause_menu.tscn 仍有 %d 个 `#` 注释行 (tscn 要求 `;`)" % hash_comment_count)
		quit(1)
		return
	passed += 1
	print("  [T203.1] pause_menu.tscn 0 个 `#` 注释行 (OK)")

	# ===== T203.PM.PROFILE_AVG_NODE =====
	total += 1
	if pause_scene_src.find('name="ProfileAvgResonance"') == -1:
		print("  FAIL [T203.2]: pause_menu.tscn 缺 ProfileAvgResonance 节点")
		quit(1)
		return
	passed += 1
	print("  [T203.2] pause_menu.tscn 含 ProfileAvgResonance (OK)")

	# ===== T203.PM.PROFILE_BEST_NODE =====
	total += 1
	if pause_scene_src.find('name="ProfileBestStreak"') == -1:
		print("  FAIL [T203.3]: pause_menu.tscn 缺 ProfileBestStreak 节点")
		quit(1)
		return
	passed += 1
	print("  [T203.3] pause_menu.tscn 含 ProfileBestStreak (OK)")

	# ===== T203.PM.AVG_PARENT =====
	total += 1
	var avg_idx := pause_scene_src.find('name="ProfileAvgResonance"')
	if avg_idx == -1:
		print("  FAIL [T203.4]: 无法定位 ProfileAvgResonance")
		quit(1)
		return
	var avg_section := pause_scene_src.substr(avg_idx, 500)
	if avg_section.find('parent="PlayerProfilePanel/ProfileMargin/ProfileVBox"') == -1:
		print("  FAIL [T203.4]: ProfileAvgResonance parent 错")
		quit(1)
		return
	passed += 1
	print("  [T203.4] ProfileAvgResonance parent = ProfileVBox (OK)")

	# ===== T203.PM.AVG_TEXT =====
	total += 1
	if avg_section.find("平均共鸣") == -1:
		print("  FAIL [T203.5]: ProfileAvgResonance 缺 '平均共鸣' 文本")
		quit(1)
		return
	passed += 1
	print("  [T203.5] ProfileAvgResonance 含 '平均共鸣' 文本 (OK)")

	# ===== T203.PM.BEST_TEXT =====
	total += 1
	var best_idx := pause_scene_src.find('name="ProfileBestStreak"')
	if best_idx == -1:
		print("  FAIL [T203.6]: 无法定位 ProfileBestStreak")
		quit(1)
		return
	var best_section := pause_scene_src.substr(best_idx, 500)
	if best_section.find("最佳单局") == -1:
		print("  FAIL [T203.6]: ProfileBestStreak 缺 '最佳单局' 文本")
		quit(1)
		return
	passed += 1
	print("  [T203.6] ProfileBestStreak 含 '最佳单局' 文本 (OK)")

	# ===== T203.PM.GLASS_CYAN_COLOR =====
	total += 1
	# Glass Cyan (0.412, 0.78, 0.808, 1) — 2 行都用同一色
	if avg_section.find("0.412") == -1 or best_section.find("0.412") == -1:
		print("  FAIL [T203.7]: ProfileAvgResonance/ProfileBestStreak 缺 Glass Cyan (0.412)")
		quit(1)
		return
	passed += 1
	print("  [T203.7] 2 行都用 Glass Cyan (0.412) 主题色 (OK)")

	# ===== T203.GD.ONREADY_AVG =====
	total += 1
	if pause_src.find("PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAvgResonance") == -1:
		print("  FAIL [T203.8]: pause_menu.gd 缺 ProfileAvgResonance 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T203.8] pause_menu.gd 引用 ProfileAvgResonance (OK)")

	# ===== T203.GD.ONREADY_BEST =====
	total += 1
	if pause_src.find("PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileBestStreak") == -1:
		print("  FAIL [T203.9]: pause_menu.gd 缺 ProfileBestStreak 路径引用")
		quit(1)
		return
	passed += 1
	print("  [T203.9] pause_menu.gd 引用 ProfileBestStreak (OK)")

	# ===== T203.GD.REFRESH_FN =====
	total += 1
	if pause_src.find("func _refresh_top_aggregate_rows") == -1:
		print("  FAIL [T203.10]: pause_menu.gd 缺 _refresh_top_aggregate_rows 函数")
		quit(1)
		return
	passed += 1
	print("  [T203.10] _refresh_top_aggregate_rows 函数存在 (OK)")

	# ===== T203.GD.T203_ANCHOR =====
	total += 1
	# T203 (#119) 注释锚点 — pause_menu.gd 至少 1 处提到本轮 (docblock or _refresh_top_aggregate_rows)
	var t203_count := _count_substr(pause_src, "T203 (#119)")
	if t203_count < 1:
		print("  FAIL [T203.11]: pause_menu.gd 缺 T203 (#119) 注释锚点")
		quit(1)
		return
	passed += 1
	print("  [T203.11] pause_menu.gd T203 (#119) 注释锚点 = %d (>= 1) (OK)" % t203_count)

	# ===== T204.HUD.NAME_REFS =====
	total += 1
	var name_ref_count := 0
	for label_name in ["_pulse_name_label", "_bind_name_label", "_cut_name_label", "_echo_name_label", "_wave_name_label"]:
		if hud_src.find(label_name) != -1:
			name_ref_count += 1
	if name_ref_count < 5:
		print("  FAIL [T204.1]: 5 _*_name_label @onready 字段引用 = %d, 期望 5" % name_ref_count)
		quit(1)
		return
	passed += 1
	print("  [T204.1] 5 _*_name_label @onready 字段引用 (OK)")

	# ===== T204.HUD.PULSE_NAME_PATH =====
	total += 1
	if hud_src.find("PulseRow/PulseNameLabel") == -1:
		print("  FAIL [T204.2]: hud.gd 缺 PulseRow/PulseNameLabel 路径")
		quit(1)
		return
	passed += 1
	print("  [T204.2] hud.gd 引用 PulseRow/PulseNameLabel (OK)")

	# ===== T204.HUD.BIND_NAME_PATH =====
	total += 1
	if hud_src.find("BindRow/BindNameLabel") == -1:
		print("  FAIL [T204.3]: hud.gd 缺 BindRow/BindNameLabel 路径")
		quit(1)
		return
	passed += 1
	print("  [T204.3] hud.gd 引用 BindRow/BindNameLabel (OK)")

	# ===== T204.HUD.CUT_NAME_PATH =====
	total += 1
	if hud_src.find("CutRow/CutNameLabel") == -1:
		print("  FAIL [T204.4]: hud.gd 缺 CutRow/CutNameLabel 路径")
		quit(1)
		return
	passed += 1
	print("  [T204.4] hud.gd 引用 CutRow/CutNameLabel (OK)")

	# ===== T204.HUD.ECHO_NAME_PATH =====
	total += 1
	if hud_src.find("EchoRow/EchoNameLabel") == -1:
		print("  FAIL [T204.5]: hud.gd 缺 EchoRow/EchoNameLabel 路径")
		quit(1)
		return
	passed += 1
	print("  [T204.5] hud.gd 引用 EchoRow/EchoNameLabel (OK)")

	# ===== T204.HUD.WAVE_NAME_PATH =====
	total += 1
	if hud_src.find("WaveRow/WaveNameLabel") == -1:
		print("  FAIL [T204.6]: hud.gd 缺 WaveRow/WaveNameLabel 路径")
		quit(1)
		return
	passed += 1
	print("  [T204.6] hud.gd 引用 WaveRow/WaveNameLabel (OK)")

	# ===== T204.HUD.T204_ANCHOR =====
	total += 1
	var t204_count := _count_substr(hud_src, "T204 (#119)")
	if t204_count < 2:
		print("  FAIL [T204.7]: T204 (#119) 注释锚点出现次数 = %d, 期望 >= 2" % t204_count)
		quit(1)
		return
	passed += 1
	print("  [T204.7] T204 (#119) 注释锚点出现 = %d 次 (>= 2) (OK)" % t204_count)

	# ===== T204.TSCN.PULSE_NAME_NODE =====
	total += 1
	if hud_scene_src.find('name="PulseNameLabel"') == -1:
		print("  FAIL [T204.8]: hud.tscn 缺 PulseNameLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T204.8] hud.tscn 含 PulseNameLabel (OK)")

	# ===== T204.TSCN.BIND_NAME_NODE =====
	total += 1
	if hud_scene_src.find('name="BindNameLabel"') == -1:
		print("  FAIL [T204.9]: hud.tscn 缺 BindNameLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T204.9] hud.tscn 含 BindNameLabel (OK)")

	# ===== T204.TSCN.CUT_NAME_NODE =====
	total += 1
	if hud_scene_src.find('name="CutNameLabel"') == -1:
		print("  FAIL [T204.10]: hud.tscn 缺 CutNameLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T204.10] hud.tscn 含 CutNameLabel (OK)")

	# ===== T204.TSCN.ECHO_NAME_NODE =====
	total += 1
	if hud_scene_src.find('name="EchoNameLabel"') == -1:
		print("  FAIL [T204.11]: hud.tscn 缺 EchoNameLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T204.11] hud.tscn 含 EchoNameLabel (OK)")

	# ===== T204.TSCN.WAVE_NAME_NODE =====
	total += 1
	if hud_scene_src.find('name="WaveNameLabel"') == -1:
		print("  FAIL [T204.12]: hud.tscn 缺 WaveNameLabel 节点")
		quit(1)
		return
	passed += 1
	print("  [T204.12] hud.tscn 含 WaveNameLabel (OK)")

	# ===== T204.TSCN.PULSE_NAME_TEXT =====
	total += 1
	# 5 verb 名称: Pulse / Bind / Cut / Echo / Wave
	var pulse_name_idx := hud_scene_src.find('name="PulseNameLabel"')
	if pulse_name_idx == -1:
		print("  FAIL [T204.13]: 无法定位 PulseNameLabel")
		quit(1)
		return
	var pulse_name_section := hud_scene_src.substr(pulse_name_idx, 350)
	if pulse_name_section.find('text = "Pulse"') == -1:
		print("  FAIL [T204.13]: PulseNameLabel 缺 text = 'Pulse'")
		quit(1)
		return
	passed += 1
	print("  [T204.13] PulseNameLabel text = 'Pulse' (OK)")

	# ===== T204.TSCN.ECHO_NAME_COLOR =====
	total += 1
	# 抽查 1: Echo 主题色 (0.412, 0.78, 0.808)
	var echo_name_idx := hud_scene_src.find('name="EchoNameLabel"')
	if echo_name_idx == -1:
		print("  FAIL [T204.14]: 无法定位 EchoNameLabel")
		quit(1)
		return
	var echo_name_section := hud_scene_src.substr(echo_name_idx, 350)
	if echo_name_section.find("0.412") == -1:
		print("  FAIL [T204.14]: EchoNameLabel 缺 Echo 青 (0.412) 主题色")
		quit(1)
		return
	passed += 1
	print("  [T204.14] EchoNameLabel Echo 青 (0.412) 主题色 (OK)")

	print("=== I028 T203+T204 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 与 I022 ~ I027 同样的实现.
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
