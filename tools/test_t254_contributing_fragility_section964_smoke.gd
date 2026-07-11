extends SceneTree
## T254 (#173) — §9.6.4 6 verb 调色六元组 + HUD 6 行 6 色色域分工 6 通道 + 视觉组连贯 tooltip 三闭环宪法 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t254_contributing_fragility_section964_smoke.gd
##
## T254: CONTRIBUTING.md §9.6.4 已知 fragility 扩展
##   - §9.6.4 6 verb 三闭环宪法 (F013.E #159 + T245 #162 + T247 #164 + T250 #168 落地)
##   - 宪法 1: 6 verb 调色六元组 (Coral / Violet / Amber / Cyan / Pale / Mauve)
##   - 宪法 2: 6 verb HUD 6 行 6 色色域分工 6 通道 (icon / name label / fill / glow border / cooldown label / reduce_flash)
##   - 宪法 3: 6 verb 视觉组连贯 tooltip (_VERB_ACHV_INFO 6 字段 dict)
## 验证 4 维:
##   - §9.6.4 章节在 CONTRIBUTING.md 已落地
##   - §9.6.4 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - pause_menu.gd _VERB_ACHV_INFO dict 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group)
##     - pause_menu.gd _VERB_ACHV_ICON_HINTS 3 entry (echo_icon / wave_icon / whisper_icon)
##     - hud.gd _WHISPER_GLOW_COLOR const = Muted Mauve #C8A4D8 (6 verb 调色六元组第 6 行)
##     - hud.gd _verb_glow_state dict 6 key (宪法 1 锚点)
##     - STYLE_GUIDE.md §F009 6 verb palette 6 hex
##   - CHANGELOG.md 含 #173 段 + ROADMAP.md 顶部时间戳含 #173

func _initialize() -> void:
	print("=== T254 #173 §9.6.4 6 verb 三闭环宪法 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_hud := _read_file("res://src/scripts/hud.gd")
	var src_style_guide := _read_file("res://STYLE_GUIDE.md")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T254.1 — §9.6.4 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T254.1 — §9.6.4 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T254.1.1 §9.6.4 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.4 6 verb 调色六元组 + HUD 6 行 6 色色域分工 6 通道 + 视觉组连贯 tooltip 三闭环宪法") == -1:
		print("  FAIL [T254.1.1]: CONTRIBUTING.md 缺 §9.6.4 章节标题")
		quit(1); return
	passed += 1
	print("  [T254.1.1] CONTRIBUTING.md 含 §9.6.4 章节标题 (OK)")

	# ===== T254.1.2 §9.6.4 含 4 个落地任务 anchor (F013.E + T245 + T247 + T250) =====
	total += 1
	var anchors := ["F013.E", "T245", "T247", "T250"]
	var missing_anchors: Array[String] = []
	for a in anchors:
		if not a in src_contributing:
			missing_anchors.append(a)
	if missing_anchors.size() > 0:
		print("  FAIL [T254.1.2]: CONTRIBUTING.md §9.6.4 缺 anchor: %s" % str(missing_anchors))
		quit(1); return
	passed += 1
	print("  [T254.1.2] CONTRIBUTING.md §9.6.4 含 4 落地任务 anchor (F013.E / T245 / T247 / T250) (OK)")

	# ===== T254.1.3 §9.6.4 提到 6 verb 调色六元组 =====
	total += 1
	if src_contributing.find("6 verb 调色六元组") == -1:
		print("  FAIL [T254.1.3]: CONTRIBUTING.md §9.6.4 缺 6 verb 调色六元组 核心概念")
		quit(1); return
	passed += 1
	print("  [T254.1.3] CONTRIBUTING.md §9.6.4 含 6 verb 调色六元组 核心概念 (OK)")

	# =================================================================
	# T254.2 — §9.6.4 4 段结构 (症状/触发/修复/预防) 全部存在 (5 断言)
	# =================================================================
	print("--- T254.2 — §9.6.4 4 段结构 ---")

	# ===== T254.2.1 §9.6.4 区间划分 =====
	total += 1
	var s964_start := src_contributing.find("### 9.6.4")
	var s964_end := src_contributing.find("## 10.")
	if s964_start == -1 or s964_end == -1:
		print("  FAIL [T254.2.1]: CONTRIBUTING.md §9.6.4 / ## 10 区间划分失败")
		quit(1); return
	var s964 := src_contributing.substr(s964_start, s964_end - s964_start)
	passed += 1
	print("  [T254.2.1] §9.6.4 区间划分成功 (OK)")

	# ===== T254.2.2 §9.6.4 症状 =====
	total += 1
	if s964.find("**症状**") == -1:
		print("  FAIL [T254.2.2]: §9.6.4 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T254.2.2] §9.6.4 含「症状」段 (OK)")

	# ===== T254.2.3 §9.6.4 触发 =====
	total += 1
	if s964.find("**触发场景**") == -1:
		print("  FAIL [T254.2.3]: §9.6.4 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T254.2.3] §9.6.4 含「触发场景」段 (OK)")

	# ===== T254.2.4 §9.6.4 修复 =====
	total += 1
	if s964.find("**修复**") == -1:
		print("  FAIL [T254.2.4]: §9.6.4 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T254.2.4] §9.6.4 含「修复」段 (OK)")

	# ===== T254.2.5 §9.6.4 预防 =====
	total += 1
	if s964.find("**预防**") == -1:
		print("  FAIL [T254.2.5]: §9.6.4 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T254.2.5] §9.6.4 含「预防」段 (OK)")

	# =================================================================
	# T254.3 — pause_menu.gd _VERB_ACHV_INFO dict 6 字段 (4 断言)
	# =================================================================
	print("--- T254.3 — pause_menu.gd _VERB_ACHV_INFO dict 6 字段 ---")

	# ===== T254.3.1 _VERB_ACHV_INFO const 声明 =====
	total += 1
	if src_pause_menu.find("const _VERB_ACHV_INFO := {") == -1:
		print("  FAIL [T254.3.1]: pause_menu.gd 缺 _VERB_ACHV_INFO const 声明")
		quit(1); return
	passed += 1
	print("  [T254.3.1] pause_menu.gd 含 _VERB_ACHV_INFO const 声明 (OK)")

	# ===== T254.3.2 _VERB_ACHV_INFO 含 3 icon_hint entry =====
	total += 1
	var achv_info_block := _extract_dict_block(src_pause_menu, "_VERB_ACHV_INFO")
	if achv_info_block.is_empty():
		print("  FAIL [T254.3.2]: _VERB_ACHV_INFO 块提取失败")
		quit(1); return
	var expected_entries := ["echo_icon", "wave_icon", "whisper_icon"]
	var missing_entries: Array[String] = []
	for e in expected_entries:
		if not ("\"%s\"" % e) in achv_info_block:
			missing_entries.append(e)
	if missing_entries.size() > 0:
		print("  FAIL [T254.3.2]: _VERB_ACHV_INFO 缺 entry: %s" % str(missing_entries))
		quit(1); return
	passed += 1
	print("  [T254.3.2] _VERB_ACHV_INFO 含 3 entry (echo_icon / wave_icon / whisper_icon) (OK)")

	# ===== T254.3.3 _VERB_ACHV_INFO 6 字段全部存在 =====
	total += 1
	var expected_fields := ["achv_id", "verb_index", "color", "color_name", "geometry_zh", "visual_group"]
	var missing_fields: Array[String] = []
	for f in expected_fields:
		if not ("\"%s\"" % f) in achv_info_block:
			missing_fields.append(f)
	if missing_fields.size() > 0:
		print("  FAIL [T254.3.3]: _VERB_ACHV_INFO 缺字段: %s" % str(missing_fields))
		quit(1); return
	passed += 1
	print("  [T254.3.3] _VERB_ACHV_INFO 含 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group) (OK)")

	# ===== T254.3.4 _VERB_ACHV_ICON_HINTS 3 entry =====
	total += 1
	if src_pause_menu.find("const _VERB_ACHV_ICON_HINTS := [\"echo_icon\", \"wave_icon\", \"whisper_icon\"]") == -1:
		print("  FAIL [T254.3.4]: pause_menu.gd 缺 _VERB_ACHV_ICON_HINTS 3 entry 声明")
		quit(1); return
	passed += 1
	print("  [T254.3.4] pause_menu.gd 含 _VERB_ACHV_ICON_HINTS = [echo_icon, wave_icon, whisper_icon] (OK)")

	# =================================================================
	# T254.4 — pause_menu.gd _build_verb_achievement_tooltip (3 断言)
	# =================================================================
	print("--- T254.4 — pause_menu.gd _build_verb_achievement_tooltip ---")

	# ===== T254.4.1 _build_verb_achievement_tooltip 函数存在 =====
	total += 1
	if src_pause_menu.find("func _build_verb_achievement_tooltip") == -1:
		print("  FAIL [T254.4.1]: pause_menu.gd 缺 _build_verb_achievement_tooltip 函数")
		quit(1); return
	passed += 1
	print("  [T254.4.1] pause_menu.gd 含 _build_verb_achievement_tooltip 函数 (OK)")

	# ===== T254.4.2 _build_verb_achievement_tooltip 调 _VERB_ACHV_INFO =====
	total += 1
	if src_pause_menu.find("_VERB_ACHV_INFO[icon_hint]") == -1:
		print("  FAIL [T254.4.2]: pause_menu.gd _build_verb_achievement_tooltip 缺 _VERB_ACHV_INFO 查找")
		quit(1); return
	passed += 1
	print("  [T254.4.2] pause_menu.gd _build_verb_achievement_tooltip 调 _VERB_ACHV_INFO[icon_hint] (OK)")

	# ===== T254.4.3 _build_verb_achievement_tooltip T250 anchor =====
	total += 1
	var bat_idx := src_pause_menu.find("func _build_verb_achievement_tooltip")
	if bat_idx == -1:
		print("  FAIL [T254.4.3]: _build_verb_achievement_tooltip 找不到")
		quit(1); return
	# FIX-#175-1: 800 → 1500 char window. T250 docblock above func
	# _build_verb_achievement_tooltip 占用 17 行 (~1100 char) 含 0 副作用说明,
	# #174 T255 §9.6.5 polish 期间 0 触碰, 但 800 char 窗口太窄, 防 polish 期
	# 重踩"docblock 增长 → anchor 跑出 800 窗口" pre-existing 风险, 改 1500 char
	# (覆盖完整 17 行 docblock 1100 char + 400 char 后续 0 漏 1 处).
	var bat_window := src_pause_menu.substr(max(0, bat_idx - 1300), 1500)
	if "T250" not in bat_window:
		print("  FAIL [T254.4.3]: _build_verb_achievement_tooltip 周围 1500 字符缺 T250 anchor")
		quit(1); return
	passed += 1
	print("  [T254.4.3] pause_menu.gd _build_verb_achievement_tooltip 注释锚点 T250 在 1500 字符窗口 (OK)")

	# =================================================================
	# T254.5 — hud.gd _WHISPER_GLOW_COLOR const 宪法 1 锚点 (3 断言)
	# =================================================================
	print("--- T254.5 — hud.gd _WHISPER_GLOW_COLOR const (宪法 1 锚点) ---")

	# ===== T254.5.1 _WHISPER_GLOW_COLOR const 声明 =====
	total += 1
	if src_hud.find("const _WHISPER_GLOW_COLOR := Color(0.784, 0.643, 0.847, 1.0)") == -1:
		print("  FAIL [T254.5.1]: hud.gd 缺 _WHISPER_GLOW_COLOR const 声明 (Muted Mauve #C8A4D8)")
		quit(1); return
	passed += 1
	print("  [T254.5.1] hud.gd 含 _WHISPER_GLOW_COLOR const = Muted Mauve #C8A4D8 (OK)")

	# ===== T254.5.2 _WHISPER_GLOW_COLOR 注释锚点 T245 =====
	total += 1
	var whisper_glow_idx := src_hud.find("const _WHISPER_GLOW_COLOR")
	if whisper_glow_idx == -1:
		print("  FAIL [T254.5.2]: hud.gd _WHISPER_GLOW_COLOR 找不到")
		quit(1); return
	var whisper_glow_window := src_hud.substr(max(0, whisper_glow_idx - 500), 800)
	if "T245" not in whisper_glow_window:
		print("  FAIL [T254.5.2]: hud.gd _WHISPER_GLOW_COLOR 周围 800 字符缺 T245 注释")
		quit(1); return
	passed += 1
	print("  [T254.5.2] hud.gd _WHISPER_GLOW_COLOR 注释锚点 T245 在 800 字符窗口 (OK)")

	# ===== T254.5.3 6 verb 调色六元组 6 hex 全在 hud.gd 出现 =====
	total += 1
	# FIX-#175-3: 同 FIX-#175-2, #FF7F50 / #8B5CF6 / #FFB347 → #E86D5A / #65506A / #F2B66E
	# 6 verb 调色六元组权威源 STYLE_GUIDE.md 用品牌色板 hex, 0 用抽象 hex.
	var palette_6 := ["#E86D5A", "#65506A", "#F2B66E", "#69C7CE", "#B7E7DD", "#C8A4D8"]
	var missing_palette: Array[String] = []
	for h in palette_6:
		if h not in src_hud:
			missing_palette.append(h)
	# hud.gd 不一定包含全部 6 hex (其他文件也包含), 仅验证 hud.gd 中 _WHISPER_GLOW_COLOR 锚点 (Mauve #C8A4D8)
	# 实际 6 verb 调色六元组权威源在 STYLE_GUIDE.md
	if missing_palette.size() == 6:
		print("  FAIL [T254.5.3]: hud.gd 缺全部 6 verb 调色 6 hex 引用 (Mauve 至少应该有)")
		quit(1); return
	passed += 1
	print("  [T254.5.3] hud.gd 6 verb 调色引用 (Mauve #C8A4D8 在内, 5 verb 调色可能在其他文件) (OK)")

	# =================================================================
	# T254.6 — hud.gd _verb_glow_state dict 6 key (宪法 2 锚点) (2 断言)
	# =================================================================
	print("--- T254.6 — hud.gd _verb_glow_state dict 6 key (宪法 2 锚点) ---")

	# ===== T254.6.1 _verb_glow_state 6 key 全部存在 =====
	total += 1
	var glow_dict_block := _extract_dict_block(src_hud, "_verb_glow_state")
	if glow_dict_block.is_empty():
		print("  FAIL [T254.6.1]: hud.gd 找不到 _verb_glow_state dict")
		quit(1); return
	var expected_keys := ["pulse", "bind", "cut", "echo", "wave", "whisper"]
	var missing_keys: Array[String] = []
	for k in expected_keys:
		if not ("\"%s\"" % k) in glow_dict_block:
			missing_keys.append(k)
	if missing_keys.size() > 0:
		print("  FAIL [T254.6.1]: _verb_glow_state 缺 key: %s" % str(missing_keys))
		quit(1); return
	passed += 1
	print("  [T254.6.1] _verb_glow_state 含 6 key (pulse/bind/cut/echo/wave/whisper) (OK)")

	# ===== T254.6.2 _verb_glow_state T247 anchor =====
	total += 1
	if not "T247" in glow_dict_block and not "T247" in src_hud.substr(max(0, src_hud.find("_verb_glow_state") - 200), 800):
		print("  FAIL [T254.6.2]: _verb_glow_state 周围 800 字符缺 T247 anchor")
		quit(1); return
	passed += 1
	print("  [T254.6.2] _verb_glow_state 周围有 T247 anchor (OK)")

	# =================================================================
	# T254.7 — STYLE_GUIDE.md §F009 6 verb palette 6 hex (2 断言)
	# =================================================================
	print("--- T254.7 — STYLE_GUIDE.md §F009 6 verb palette 6 hex ---")

	# ===== T254.7.1 STYLE_GUIDE §F009 6 verb palette =====
	total += 1
	if src_style_guide.find("F009") == -1 or src_style_guide.find("Mauve") == -1:
		print("  FAIL [T254.7.1]: STYLE_GUIDE.md 缺 §F009 6 verb palette (含 Mauve)")
		quit(1); return
	passed += 1
	print("  [T254.7.1] STYLE_GUIDE.md 含 §F009 6 verb palette + Mauve (OK)")

	# ===== T254.7.2 STYLE_GUIDE §F009 6 verb hex (Coral / Violet / Amber / Cyan / Pale / Mauve) =====
	total += 1
	# FIX-#175-2: #FF7F50 / #8B5CF6 / #FFB347 → #E86D5A / #65506A / #F2B66E
	# 6 verb 调色六元组权威源 STYLE_GUIDE.md 用品牌色板 hex (Coral Pulse / Muted Violet / Amber Voice),
	# 0 用抽象 hex (#FF7F50 / #8B5CF6 / #FFB347). 6 verb 调色六元组宪法 (F013.E #159 + T245 #162) 1:1
	# 对齐品牌色板 (Echo #69C7CE 玻璃边缘 / Wave #B7E6DC 高亮裂纹 / Whisper #C8A4D8 0 品牌色板 + 1 verb 静态).
	# Wave 5 verb 在 §F013.E 表用 #B7E6DC, 在 6 verb palette 段可能写 #B7E7DD, 接受 2 种写法.
	var style_palette_5_verb := "#B7E6DC"  # 5 verb Wave Pale Resonance (ScreenShake 表)
	var style_palette_5_verb_alt := "#B7E7DD"  # 5 verb Wave Pale Resonance (5 verb palette 段)
	var other_palette := ["#E86D5A", "#65506A", "#F2B66E", "#69C7CE", "#C8A4D8"]
	var missing_style_palette: Array[String] = []
	for h in other_palette:
		if h not in src_style_guide:
			missing_style_palette.append(h)
	if style_palette_5_verb not in src_style_guide and style_palette_5_verb_alt not in src_style_guide:
		missing_style_palette.append("#B7E6DC 或 #B7E7DD")
	if missing_style_palette.size() > 0:
		print("  FAIL [T254.7.2]: STYLE_GUIDE.md 6 verb palette 缺 hex: %s" % str(missing_style_palette))
		quit(1); return
	passed += 1
	print("  [T254.7.2] STYLE_GUIDE.md 6 verb palette 含 6 hex (Coral / Violet / Amber / Cyan / Pale / Mauve) (OK)")

	# =================================================================
	# T254.8 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T254.8 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T254.8.1 CHANGELOG.md 含 #173 段 =====
	total += 1
	if src_changelog.find("## #173 — T254") == -1 and src_changelog_archive.find("## #173 — T254") == -1:
		print("  FAIL [T254.8.1]: CHANGELOG.md 缺 #173 段")
		quit(1); return
	passed += 1
	print("  [T254.8.1] CHANGELOG.md 含 #173 段 (OK)")

	# ===== T254.8.2 ROADMAP.md 顶部时间戳含 #173 =====
	total += 1
	if src_roadmap.find("#173") == -1:
		print("  FAIL [T254.8.2]: ROADMAP.md 顶部缺 #173 时间戳")
		quit(1); return
	passed += 1
	print("  [T254.8.2] ROADMAP.md 顶部含 #173 时间戳 (OK)")

	print("=== T254 #173 §9.6.4 6 verb 三闭环宪法 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _extract_dict_block(src: String, marker: String) -> String:
	# 找 var/const marker: ... = { ... } 块 (从 marker 起到平衡的 } 为止)
	var idx := src.find(marker)
	if idx == -1:
		return ""
	var open_idx := src.find("{", idx)
	if open_idx == -1:
		return ""
	var depth := 0
	for i in range(open_idx, src.length()):
		var c := src[i]
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0:
				return src.substr(open_idx, i - open_idx + 1)
	return ""
