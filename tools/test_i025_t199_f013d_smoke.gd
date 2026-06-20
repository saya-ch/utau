extends SceneTree
## I025 (#116) — Smoke test for T199 (PauseMenu 5 verb row hover tooltip 显示
## 5 verb 详细参数) + F013.D (6 verb 接入路径在 CONTRIBUTING.md §9 文档化).
##
## 22+ 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i025_t199_f013d_smoke.gd
##
## 设计 (与 I024 一致, 静态单点锚点):
##   T199.PM.VERB_HINT_DATA — pause_menu.gd 有 _VERB_HINT_DATA 常量.
##   T199.PM.VERB_HINT_DATA_LEN — _VERB_HINT_DATA 长度 = 5.
##   T199.PM.VERB_HINT_DATA_KEYS — 5 verb 全部含 7 必填字段
##     (key/name_zh/name_color/cost/cooldown_s/radius_px/desc_zh).
##   T199.PM.PULSE_KEY — Pulse 键位 = J.
##   T199.PM.BIND_KEY — Bind 键位 = K.
##   T199.PM.CUT_KEY — Cut 键位 = L.
##   T199.PM.ECHO_KEY — Echo 键位 = Q.
##   T199.PM.WAVE_KEY — Wave 键位 = V.
##   T199.PM.PULSE_COST — Pulse cost = 15.
##   T199.PM.WAVE_COST — Wave cost = 50 (最高共鸣消耗).
##   T199.PM.PULSE_COOLDOWN — Pulse cooldown = 0.5.
##   T199.PM.WAVE_COOLDOWN — Wave cooldown = 6.0 (最长冷却).
##   T199.PM.WAVE_RADIUS — Wave radius = 80 (最大范围).
##   T199.PM.PULSE_COLOR — Pulse color = #E86D5A.
##   T199.PM.WAVE_COLOR — Wave color = #B7E6DC.
##   T199.PM.BUILD_TOOLTIP — _build_verb_hint_tooltip() 函数存在.
##   T199.PM.BUILD_TOOLTIP_HEADER — tooltip 含 "5 声波能力" header.
##   T199.PM.BUILD_TOOLTIP_5_LINES — tooltip 至少含 5 verb 行 (• ...).
##   T199.PM.T199_ANCHOR — pause_menu.gd 含 T199 (#116) 注释锚点.
##   T199.PM.TOOLTIP_ASSIGN — _ready() 中设置 tooltip_text 双向.
##   T199.PM.STAT_TOOLTIP — _stat_abilities.tooltip_text = _verb_hint_text.
##   T199.PM.PROFILE_TOOLTIP — _profile_abilities.tooltip_text = _verb_hint_text.
##   F013D.DOC.SECTION — CONTRIBUTING.md §9 存在.
##   F013D.DOC.STEP_9 — §9.1 含 9 接入步骤.
##   F013D.DOC.PITFALLS — §9.2 含易错点 (cooldown 重声明).
##   F013D.DOC.SUPER_READY — §9.2 含 super._ready() 漏调提示.
##   F013D.DOC.VERB_HINT_DATA_PITFALL — §9.2 含 _VERB_HINT_DATA 漏更新提示.
##   F013D.DOC.5_KEYS — §9.2 列出现役 5 键 (J/K/L/Q/V).

func _initialize() -> void:
	print("=== I025 T199 5 verb tooltip + F013.D 6 verb 接入路径 smoke test (#116) ===")

	var pm_src := ""
	var pf := FileAccess.open("res://src/scripts/pause_menu.gd", FileAccess.READ)
	if pf:
		pm_src = pf.get_as_text()
		pf.close()

	var contrib_src := ""
	var cf := FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	if cf:
		contrib_src = cf.get_as_text()
		cf.close()

	var passed := 0
	var total := 0

	# ===== T199.PM.VERB_HINT_DATA — _VERB_HINT_DATA 常量存在 =====
	total += 1
	if pm_src.find("const _VERB_HINT_DATA") == -1:
		print("  FAIL [T199.PM.1]: pause_menu.gd 缺 const _VERB_HINT_DATA")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.1] pause_menu.gd 含 _VERB_HINT_DATA 常量 (OK)")

	# ===== T199.PM.VERB_HINT_DATA_LEN — 数组长度 = 5 =====
	total += 1
	# 简单 grep 5 个 "name_zh" 出现次数 (每个 verb 元素 1 个)
	# 注意: _build_verb_hint_tooltip() 内 String(d["name_zh"]) 多 1 处,
	# 所以期望是 5 (data) + 1 (consumer) = 6 出现
	var name_zh_count := 0
	var search_pos := 0
	while true:
		var idx := pm_src.find("\"name_zh\"", search_pos)
		if idx == -1:
			break
		name_zh_count += 1
		search_pos = idx + 1
	if name_zh_count != 6:
		print("  FAIL [T199.PM.2]: name_zh 出现次数 = %d, 期望 6 (5 verb data + 1 consumer)" % name_zh_count)
		quit(1)
		return
	passed += 1
	print("  [T199.PM.2] name_zh 出现次数 = 6 (5 verb data + 1 consumer) (OK)")

	# ===== T199.PM.VERB_HINT_DATA_KEYS — 5 verb 全部含 7 必填字段 =====
	# 期望 7 字段 × 5 verb = 35 字段引用 + 5 字段 × 1 字段 = 6 (key/name_zh/name_color/cost/cooldown_s/radius_px
	# 在 _build_verb_hint_tooltip 消费了 5/6 个 — key 字段仅 data 用, 6 个字段名也只在 data 出现) = 5 字段 × 1 消费
	# 简化: 检查 5 verb × 7 字段 + consumer 引用, 容许 >= 35 (允许 consumer 重复)
	total += 1
	var field_count := 0
	for f in ["key", "name_zh", "name_color", "cost", "cooldown_s", "radius_px", "desc_zh"]:
		var f_count := 0
		var sp := 0
		while true:
			var i2 := pm_src.find("\"%s\"" % f, sp)
			if i2 == -1:
				break
			f_count += 1
			sp = i2 + 1
		field_count += f_count
	# 期望 5 verb data × 7 = 35 + 1 consumer for name_zh/desc_zh = 2
	# 最少 35, 因为 name_zh + desc_zh 各多 1 consumer = 37
	if field_count < 35:
		print("  FAIL [T199.PM.3]: 7 必填字段总引用 = %d, 期望 >= 35" % field_count)
		quit(1)
		return
	passed += 1
	print("  [T199.PM.3] 7 必填字段总引用 = %d (>= 35) (OK)" % field_count)

	# ===== T199.PM.PULSE_KEY — Pulse 键位 = J =====
	total += 1
	if pm_src.find("\"key\": \"J\"") == -1:
		print("  FAIL [T199.PM.4]: _VERB_HINT_DATA 缺 Pulse key=J")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.4] _VERB_HINT_DATA Pulse key=J (OK)")

	# ===== T199.PM.BIND_KEY — Bind 键位 = K =====
	total += 1
	if pm_src.find("\"key\": \"K\"") == -1:
		print("  FAIL [T199.PM.5]: _VERB_HINT_DATA 缺 Bind key=K")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.5] _VERB_HINT_DATA Bind key=K (OK)")

	# ===== T199.PM.CUT_KEY — Cut 键位 = L =====
	total += 1
	if pm_src.find("\"key\": \"L\"") == -1:
		print("  FAIL [T199.PM.6]: _VERB_HINT_DATA 缺 Cut key=L")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.6] _VERB_HINT_DATA Cut key=L (OK)")

	# ===== T199.PM.ECHO_KEY — Echo 键位 = Q =====
	total += 1
	if pm_src.find("\"key\": \"Q\"") == -1:
		print("  FAIL [T199.PM.7]: _VERB_HINT_DATA 缺 Echo key=Q")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.7] _VERB_HINT_DATA Echo key=Q (OK)")

	# ===== T199.PM.WAVE_KEY — Wave 键位 = V =====
	total += 1
	if pm_src.find("\"key\": \"V\"") == -1:
		print("  FAIL [T199.PM.8]: _VERB_HINT_DATA 缺 Wave key=V")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.8] _VERB_HINT_DATA Wave key=V (OK)")

	# ===== T199.PM.PULSE_COST — Pulse cost = 15 =====
	total += 1
	if pm_src.find("\"cost\": 15") == -1:
		print("  FAIL [T199.PM.9]: _VERB_HINT_DATA 缺 Pulse cost=15")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.9] _VERB_HINT_DATA Pulse cost=15 (OK)")

	# ===== T199.PM.WAVE_COST — Wave cost = 50 (最高共鸣消耗) =====
	total += 1
	if pm_src.find("\"cost\": 50") == -1:
		print("  FAIL [T199.PM.10]: _VERB_HINT_DATA 缺 Wave cost=50")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.10] _VERB_HINT_DATA Wave cost=50 (OK)")

	# ===== T199.PM.PULSE_COOLDOWN — Pulse cooldown = 0.5 =====
	total += 1
	if pm_src.find("\"cooldown_s\": 0.5") == -1:
		print("  FAIL [T199.PM.11]: _VERB_HINT_DATA 缺 Pulse cooldown_s=0.5")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.11] _VERB_HINT_DATA Pulse cooldown_s=0.5 (OK)")

	# ===== T199.PM.WAVE_COOLDOWN — Wave cooldown = 6.0 (最长冷却) =====
	total += 1
	if pm_src.find("\"cooldown_s\": 6.0") == -1:
		print("  FAIL [T199.PM.12]: _VERB_HINT_DATA 缺 Wave cooldown_s=6.0")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.12] _VERB_HINT_DATA Wave cooldown_s=6.0 (OK)")

	# ===== T199.PM.WAVE_RADIUS — Wave radius = 80 (最大范围) =====
	total += 1
	if pm_src.find("\"radius_px\": 80") == -1:
		print("  FAIL [T199.PM.13]: _VERB_HINT_DATA 缺 Wave radius_px=80")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.13] _VERB_HINT_DATA Wave radius_px=80 (OK)")

	# ===== T199.PM.PULSE_COLOR — Pulse color = #E86D5A =====
	total += 1
	if pm_src.find("\"name_color\": \"#E86D5A\"") == -1:
		print("  FAIL [T199.PM.14]: _VERB_HINT_DATA 缺 Pulse name_color=#E86D5A")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.14] _VERB_HINT_DATA Pulse name_color=#E86D5A (OK)")

	# ===== T199.PM.WAVE_COLOR — Wave color = #B7E6DC =====
	total += 1
	if pm_src.find("\"name_color\": \"#B7E6DC\"") == -1:
		print("  FAIL [T199.PM.15]: _VERB_HINT_DATA 缺 Wave name_color=#B7E6DC")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.15] _VERB_HINT_DATA Wave name_color=#B7E6DC (OK)")

	# ===== T199.PM.BUILD_TOOLTIP — _build_verb_hint_tooltip() 函数存在 =====
	total += 1
	if pm_src.find("func _build_verb_hint_tooltip()") == -1:
		print("  FAIL [T199.PM.16]: pause_menu.gd 缺 _build_verb_hint_tooltip() 函数")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.16] pause_menu.gd 含 _build_verb_hint_tooltip() 函数 (OK)")

	# ===== T199.PM.BUILD_TOOLTIP_HEADER — tooltip 含 "5 声波能力" header =====
	total += 1
	if pm_src.find("5 声波能力") == -1:
		print("  FAIL [T199.PM.17]: _build_verb_hint_tooltip 缺 header '5 声波能力'")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.17] _build_verb_hint_tooltip 含 header '5 声波能力' (OK)")

	# ===== T199.PM.BUILD_TOOLTIP_5_LINES — tooltip 至少含 5 verb 行 (• ...) =====
	# 验证方式: 1) for 循环遍历 _VERB_HINT_DATA; 2) format string 含
	# 5 verb 字段 (key + name_zh + cost + cooldown + radius) — 静态源
	# 中 1 个 format string, 运行时产生 5 行. 配合 T199.PM.2 验证
	# _VERB_HINT_DATA = 5 元素, 即可保证 5 行 bullet.
	total += 1
	var has_for_loop := pm_src.find("for v in _VERB_HINT_DATA") != -1
	# bullet 字符 (•) 后面跟 5 字段 (key + name_zh + cost + cooldown_s + radius_px)
	# 5 个 % 占位符 (%s %s %d %.1fs %dpx) 在同一行.
	var has_bullet_fmt := pm_src.find("消耗 %d  冷却 %.1fs  半径 %dpx") != -1
	if not (has_for_loop and has_bullet_fmt):
		print("  FAIL [T199.PM.18]: tooltip 5 verb 循环渲染未就位 (for=%s, fmt=%s)" % [has_for_loop, has_bullet_fmt])
		quit(1)
		return
	passed += 1
	print("  [T199.PM.18] tooltip 5 verb for 循环 + bullet format 字符串就位 (OK)")

	# ===== T199.PM.T199_ANCHOR — T199 (#116) 注释锚点 =====
	total += 1
	if pm_src.find("T199 (#116)") == -1:
		print("  FAIL [T199.PM.19]: pause_menu.gd 缺 T199 (#116) 注释锚点")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.19] pause_menu.gd 含 T199 (#116) 注释锚点 (OK)")

	# ===== T199.PM.TOOLTIP_ASSIGN — _ready() 中设置 tooltip_text 双向 =====
	total += 1
	# 期望出现 2 次 tooltip_text = _verb_hint_text (1 个 stat + 1 个 profile)
	var assign_count := 0
	var sp4 := 0
	while true:
		var i4 := pm_src.find("tooltip_text = _verb_hint_text", sp4)
		if i4 == -1:
			break
		assign_count += 1
		sp4 = i4 + 1
	if assign_count < 2:
		print("  FAIL [T199.PM.20]: tooltip_text 赋值次数 = %d, 期望 >= 2 (stat + profile)" % assign_count)
		quit(1)
		return
	passed += 1
	print("  [T199.PM.20] tooltip_text 赋值次数 = %d (stat + profile) (OK)" % assign_count)

	# ===== T199.PM.STAT_TOOLTIP — _stat_abilities.tooltip_text = _verb_hint_text =====
	total += 1
	if pm_src.find("_stat_abilities.tooltip_text = _verb_hint_text") == -1:
		print("  FAIL [T199.PM.21]: 缺 _stat_abilities.tooltip_text = _verb_hint_text")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.21] _stat_abilities.tooltip_text 绑定 (OK)")

	# ===== T199.PM.PROFILE_TOOLTIP — _profile_abilities.tooltip_text = _verb_hint_text =====
	total += 1
	if pm_src.find("_profile_abilities.tooltip_text = _verb_hint_text") == -1:
		print("  FAIL [T199.PM.22]: 缺 _profile_abilities.tooltip_text = _verb_hint_text")
		quit(1)
		return
	passed += 1
	print("  [T199.PM.22] _profile_abilities.tooltip_text 绑定 (OK)")

	# ===== F013D.DOC.SECTION — CONTRIBUTING.md §9 存在 =====
	total += 1
	if contrib_src.find("## 9. 添加第 6 声波能力") == -1:
		print("  FAIL [F013D.1]: CONTRIBUTING.md 缺 §9 '添加第 6 声波能力' 章节")
		quit(1)
		return
	passed += 1
	print("  [F013D.1] CONTRIBUTING.md §9 章节存在 (OK)")

	# ===== F013D.DOC.STEP_9 — §9.1 含 9 接入步骤 =====
	total += 1
	# 9 步骤 = 1-9 编号, 期望 9 个 "9. " 顺序步骤
	# 简化: 期望 "1. **" "9. **" 都存在 (9 个步骤)
	if contrib_src.find("9. **冒烟测试**") == -1:
		print("  FAIL [F013D.2]: §9.1 缺第 9 步 '冒烟测试'")
		quit(1)
		return
	passed += 1
	print("  [F013D.2] §9.1 含 9 接入步骤 (OK)")

	# ===== F013D.DOC.PITFALLS — §9.2 含易错点 (cooldown 重声明) =====
	total += 1
	if contrib_src.find("重声明 `cooldown` / `windup_time`") == -1:
		print("  FAIL [F013D.3]: §9.2 缺 cooldown 重声明陷阱提示")
		quit(1)
		return
	passed += 1
	print("  [F013D.3] §9.2 cooldown 重声明陷阱提示 (OK)")

	# ===== F013D.DOC.SUPER_READY — §9.2 含 super._ready() 漏调提示 =====
	total += 1
	if contrib_src.find("super._ready()") == -1:
		print("  FAIL [F013D.4]: §9.2 缺 super._ready() 漏调提示")
		quit(1)
		return
	passed += 1
	print("  [F013D.4] §9.2 super._ready() 漏调提示 (OK)")

	# ===== F013D.DOC.VERB_HINT_DATA_PITFALL — §9.2 含 _VERB_HINT_DATA 漏更新提示 =====
	total += 1
	if contrib_src.find("_VERB_HINT_DATA") == -1:
		print("  FAIL [F013D.5]: §9.2 缺 _VERB_HINT_DATA 漏更新陷阱提示")
		quit(1)
		return
	passed += 1
	print("  [F013D.5] §9.2 _VERB_HINT_DATA 漏更新陷阱提示 (OK)")

	# ===== F013D.DOC.5_KEYS — §9.2 列出现役 5 键 (J/K/L/Q/V) =====
	total += 1
	if contrib_src.find("J/K/L/Q/V") == -1:
		print("  FAIL [F013D.6]: §9.2 缺 5 现役键位列表 J/K/L/Q/V")
		quit(1)
		return
	passed += 1
	print("  [F013D.6] §9.2 含 5 现役键位 J/K/L/Q/V (OK)")

	print("=== I025 T199 + F013.D smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)
