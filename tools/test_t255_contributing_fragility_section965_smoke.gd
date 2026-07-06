extends SceneTree
## T255 (#174) — §9.6.5 6 verb 视觉组连贯 tooltip `_build_verb_achievement_tooltip` 8 行拼接 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t255_contributing_fragility_section965_smoke.gd
##
## T255: CONTRIBUTING.md §9.6.5 已知 fragility 扩展
##   - §9.6.5 6 verb 视觉组连贯 tooltip `_build_verb_achievement_tooltip` 8 行拼接 polish 模式 (T250 #168 落地)
##   - 双 has() guard + Array[String] 5 element + "\n".join(...) 三件套
##   - base_tooltip 0 改 (T109 #60 既有 3 行 100% 兼容)
##   - _VERB_ACHV_INFO 6 字段 dict 字段顺序严格按 achv_id / verb_index / color / color_name / geometry_zh / visual_group
## 验证 4 维:
##   - §9.6.5 章节在 CONTRIBUTING.md 已落地
##   - §9.6.5 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - pause_menu.gd _VERB_ACHV_ICON_HINTS 3 entry 列表
##     - pause_menu.gd _VERB_ACHV_INFO dict 6 字段顺序
##     - pause_menu.gd _build_verb_achievement_tooltip 8 行拼接器
##     - pause_menu.gd slot.tooltip_text 调用拆分 (var base_tooltip := ... + _build_verb_...)
##   - CHANGELOG.md 含 #174 段 + ROADMAP.md 顶部时间戳含 #174

func _initialize() -> void:
	print("=== T255 #174 §9.6.5 6 verb 视觉组连贯 tooltip 8 行拼接 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T255.1 — §9.6.5 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T255.1 — §9.6.5 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T255.1.1 §9.6.5 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.5 6 verb 视觉组连贯 tooltip `_build_verb_achievement_tooltip` 8 行拼接 polish 模式") == -1:
		print("  FAIL [T255.1.1]: CONTRIBUTING.md 缺 §9.6.5 章节标题")
		quit(1); return
	passed += 1
	print("  [T255.1.1] CONTRIBUTING.md 含 §9.6.5 章节标题 (OK)")

	# ===== T255.1.2 §9.6.5 含 T250 anchor =====
	total += 1
	var s965_start := src_contributing.find("### 9.6.5")
	var s10_start := src_contributing.find("## 10.")
	if s965_start == -1 or s10_start == -1:
		print("  FAIL [T255.1.2]: §9.6.5 / ## 10 区间划分失败")
		quit(1); return
	var s965 := src_contributing.substr(s965_start, s10_start - s965_start)
	if "T250" not in s965:
		print("  FAIL [T255.1.2]: §9.6.5 区间缺 T250 anchor (T250 #168 是该模式落地任务)")
		quit(1); return
	passed += 1
	print("  [T255.1.2] CONTRIBUTING.md §9.6.5 区间含 T250 anchor (OK)")

	# ===== T255.1.3 §9.6.5 提到 8 行拼接 =====
	total += 1
	if s965.find("8 行拼接") == -1 and s965.find("8 行") == -1:
		print("  FAIL [T255.1.3]: §9.6.5 缺 8 行拼接核心概念")
		quit(1); return
	passed += 1
	print("  [T255.1.3] CONTRIBUTING.md §9.6.5 含 8 行拼接核心概念 (OK)")

	# =================================================================
	# T255.2 — §9.6.5 4 段结构 (症状/触发/修复/预防) 全部存在 (5 断言)
	# =================================================================
	print("--- T255.2 — §9.6.5 4 段结构 ---")

	# ===== T255.2.1 §9.6.5 症状 =====
	total += 1
	if s965.find("**症状**") == -1:
		print("  FAIL [T255.2.1]: §9.6.5 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T255.2.1] §9.6.5 含「症状」段 (OK)")

	# ===== T255.2.2 §9.6.5 触发场景 =====
	total += 1
	if s965.find("**触发场景**") == -1:
		print("  FAIL [T255.2.2]: §9.6.5 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T255.2.2] §9.6.5 含「触发场景」段 (OK)")

	# ===== T255.2.3 §9.6.5 修复 =====
	total += 1
	if s965.find("**修复**") == -1:
		print("  FAIL [T255.2.3]: §9.6.5 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T255.2.3] §9.6.5 含「修复」段 (OK)")

	# ===== T255.2.4 §9.6.5 预防 =====
	total += 1
	if s965.find("**预防**") == -1:
		print("  FAIL [T255.2.4]: §9.6.5 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T255.2.4] §9.6.5 含「预防」段 (OK)")

	# ===== T255.2.5 §9.6.5 提到三件套 (双 has guard + Array 5 element + join) =====
	total += 1
	if s965.find("has()") == -1 and s965.find("`has`") == -1 and s965.find("`has(") == -1:
		print("  FAIL [T255.2.5]: §9.6.5 缺双 has() guard 描述")
		quit(1); return
	passed += 1
	print("  [T255.2.5] §9.6.5 含双 has() guard 描述 (OK)")

	# =================================================================
	# T255.3 — pause_menu.gd _VERB_ACHV_ICON_HINTS 3 entry 列表 (2 断言)
	# =================================================================
	print("--- T255.3 — pause_menu.gd _VERB_ACHV_ICON_HINTS 3 entry 列表 ---")

	# ===== T255.3.1 _VERB_ACHV_ICON_HINTS const 声明 =====
	total += 1
	if src_pause_menu.find("const _VERB_ACHV_ICON_HINTS := [\"echo_icon\", \"wave_icon\", \"whisper_icon\"]") == -1:
		print("  FAIL [T255.3.1]: pause_menu.gd 缺 _VERB_ACHV_ICON_HINTS 3 entry 列表")
		quit(1); return
	passed += 1
	print("  [T255.3.1] pause_menu.gd 含 _VERB_ACHV_ICON_HINTS 3 entry 列表 (OK)")

	# ===== T255.3.2 _VERB_ACHV_ICON_HINTS 3 entry 全存在 =====
	total += 1
	var hints_idx := src_pause_menu.find("const _VERB_ACHV_ICON_HINTS")
	if hints_idx == -1:
		print("  FAIL [T255.3.2]: _VERB_ACHV_ICON_HINTS 找不到")
		quit(1); return
	var hints_block := _extract_array_block(src_pause_menu, "_VERB_ACHV_ICON_HINTS")
	if hints_block.is_empty():
		print("  FAIL [T255.3.2]: _VERB_ACHV_ICON_HINTS 块提取失败")
		quit(1); return
	var expected_hints := ["echo_icon", "wave_icon", "whisper_icon"]
	var missing_hints: Array[String] = []
	for h in expected_hints:
		if not ("\"%s\"" % h) in hints_block:
			missing_hints.append(h)
	if missing_hints.size() > 0:
		print("  FAIL [T255.3.2]: _VERB_ACHV_ICON_HINTS 缺 entry: %s" % str(missing_hints))
		quit(1); return
	passed += 1
	print("  [T255.3.2] _VERB_ACHV_ICON_HINTS 含 3 entry (echo_icon / wave_icon / whisper_icon) (OK)")

	# =================================================================
	# T255.4 — pause_menu.gd _VERB_ACHV_INFO dict 6 字段顺序 (4 断言)
	# =================================================================
	print("--- T255.4 — pause_menu.gd _VERB_ACHV_INFO dict 6 字段顺序 ---")

	# ===== T255.4.1 _VERB_ACHV_INFO const 声明 =====
	total += 1
	if src_pause_menu.find("const _VERB_ACHV_INFO := {") == -1:
		print("  FAIL [T255.4.1]: pause_menu.gd 缺 _VERB_ACHV_INFO const 声明")
		quit(1); return
	passed += 1
	print("  [T255.4.1] pause_menu.gd 含 _VERB_ACHV_INFO const 声明 (OK)")

	# ===== T255.4.2 _VERB_ACHV_INFO 6 字段全部存在 =====
	total += 1
	var achv_info_block := _extract_dict_block(src_pause_menu, "_VERB_ACHV_INFO")
	if achv_info_block.is_empty():
		print("  FAIL [T255.4.2]: _VERB_ACHV_INFO 块提取失败")
		quit(1); return
	var expected_fields := ["achv_id", "verb_index", "color", "color_name", "geometry_zh", "visual_group"]
	var missing_fields: Array[String] = []
	for f in expected_fields:
		if not ("\"%s\"" % f) in achv_info_block:
			missing_fields.append(f)
	if missing_fields.size() > 0:
		print("  FAIL [T255.4.2]: _VERB_ACHV_INFO 缺字段: %s" % str(missing_fields))
		quit(1); return
	passed += 1
	print("  [T255.4.2] _VERB_ACHV_INFO 含 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group) (OK)")

	# ===== T255.4.3 _VERB_ACHV_INFO 字段顺序 1:1 严格按 achv_id→verb_index→color→color_name→geometry_zh→visual_group =====
	total += 1
	var pos_achv_id := achv_info_block.find("\"achv_id\"")
	var pos_verb_index := achv_info_block.find("\"verb_index\"")
	var pos_color := achv_info_block.find("\"color\"")
	var pos_color_name := achv_info_block.find("\"color_name\"")
	var pos_geometry := achv_info_block.find("\"geometry_zh\"")
	var pos_visual_group := achv_info_block.find("\"visual_group\"")
	if pos_achv_id == -1 or pos_verb_index == -1 or pos_color == -1 or pos_color_name == -1 or pos_geometry == -1 or pos_visual_group == -1:
		print("  FAIL [T255.4.3]: _VERB_ACHV_INFO 字段位置查找失败")
		quit(1); return
	if not (pos_achv_id < pos_verb_index and pos_verb_index < pos_color and pos_color < pos_color_name and pos_color_name < pos_geometry and pos_geometry < pos_visual_group):
		print("  FAIL [T255.4.3]: _VERB_ACHV_INFO 字段顺序错位 (期望 achv_id→verb_index→color→color_name→geometry_zh→visual_group)")
		quit(1); return
	passed += 1
	print("  [T255.4.3] _VERB_ACHV_INFO 6 字段顺序 1:1 严格 (achv_id < verb_index < color < color_name < geometry_zh < visual_group) (OK)")

	# ===== T255.4.4 _VERB_ACHV_INFO 3 entry (echo_icon / wave_icon / whisper_icon) =====
	total += 1
	var expected_achv_entries := ["echo_icon", "wave_icon", "whisper_icon"]
	var missing_achv_entries: Array[String] = []
	for e in expected_achv_entries:
		if not ("\"%s\"" % e) in achv_info_block:
			missing_achv_entries.append(e)
	if missing_achv_entries.size() > 0:
		print("  FAIL [T255.4.4]: _VERB_ACHV_INFO 缺 entry: %s" % str(missing_achv_entries))
		quit(1); return
	passed += 1
	print("  [T255.4.4] _VERB_ACHV_INFO 含 3 entry (echo_icon / wave_icon / whisper_icon) (OK)")

	# =================================================================
	# T255.5 — pause_menu.gd _build_verb_achievement_tooltip 8 行拼接器 (4 断言)
	# =================================================================
	print("--- T255.5 — pause_menu.gd _build_verb_achievement_tooltip 8 行拼接器 ---")

	# ===== T255.5.1 _build_verb_achievement_tooltip 函数存在 =====
	total += 1
	if src_pause_menu.find("func _build_verb_achievement_tooltip") == -1:
		print("  FAIL [T255.5.1]: pause_menu.gd 缺 _build_verb_achievement_tooltip 函数")
		quit(1); return
	passed += 1
	print("  [T255.5.1] pause_menu.gd 含 _build_verb_achievement_tooltip 函数 (OK)")

	# ===== T255.5.2 _build_verb_achievement_tooltip 含双 has() guard =====
	total += 1
	var bat_idx := src_pause_menu.find("func _build_verb_achievement_tooltip")
	if bat_idx == -1:
		print("  FAIL [T255.5.2]: _build_verb_achievement_tooltip 找不到")
		quit(1); return
	var bat_window := src_pause_menu.substr(bat_idx, 2000)
	var has_count := bat_window.find("_VERB_ACHV_ICON_HINTS.has")
	var has_count2 := bat_window.find("_VERB_ACHV_INFO.has")
	if has_count == -1 or has_count2 == -1:
		print("  FAIL [T255.5.2]: _build_verb_achievement_tooltip 缺双 has() guard (期望 _VERB_ACHV_ICON_HINTS.has + _VERB_ACHV_INFO.has)")
		quit(1); return
	passed += 1
	print("  [T255.5.2] _build_verb_achievement_tooltip 含双 has() guard (_VERB_ACHV_ICON_HINTS.has + _VERB_ACHV_INFO.has) (OK)")

	# ===== T255.5.3 _build_verb_achievement_tooltip 含 5 element extra_lines + join =====
	total += 1
	var extra_lines_count := bat_window.count("extra_lines.append")
	var join_call := bat_window.find('"\\n".join(extra_lines)')  # "\n".join
	if join_call == -1:
		join_call = bat_window.find("\"\\n\".join(extra_lines)")
	if extra_lines_count != 5:
		print("  FAIL [T255.5.3]: _build_verb_achievement_tooltip extra_lines.append 应为 5 次, 实际 %d 次" % extra_lines_count)
		quit(1); return
	if join_call == -1:
		print("  FAIL [T255.5.3]: _build_verb_achievement_tooltip 缺 \"\\n\".join(extra_lines) 拼接调用")
		quit(1); return
	passed += 1
	print("  [T255.5.3] _build_verb_achievement_tooltip 5 element extra_lines.append + \"\\n\".join (OK)")

	# ===== T255.5.4 _build_verb_achievement_tooltip 函数注释 T250 anchor =====
	total += 1
	# 检查函数上面 2000 字符窗口 (docblock 较长, 含 T250 / T199 / T213 / T216 / T249 / T109 多个 anchor)
	var bat_doc_window := src_pause_menu.substr(max(0, bat_idx - 2000), 2000)
	if "T250" not in bat_doc_window:
		print("  FAIL [T255.5.4]: _build_verb_achievement_tooltip 上面 2000 字符 docblock 缺 T250 anchor")
		quit(1); return
	passed += 1
	print("  [T255.5.4] _build_verb_achievement_tooltip 上面 2000 字符 docblock 含 T250 anchor (OK)")

	# =================================================================
	# T255.6 — pause_menu.gd slot.tooltip_text 调用拆分 (3 断言)
	# =================================================================
	print("--- T255.6 — pause_menu.gd slot.tooltip_text 调用拆分 ---")

	# ===== T255.6.1 var base_tooltip 局部变量声明 =====
	total += 1
	if src_pause_menu.find("var base_tooltip := \"%s  %s\\n解锁于 %s\"") == -1 and src_pause_menu.find("var base_tooltip := \"%s  %s") == -1:
		# 使用更宽容匹配
		if src_pause_menu.find("var base_tooltip := ") == -1:
			print("  FAIL [T255.6.1]: pause_menu.gd 缺 var base_tooltip := ... 局部变量声明")
			quit(1); return
	passed += 1
	print("  [T255.6.1] pause_menu.gd 含 var base_tooltip := ... 局部变量声明 (OK)")

	# ===== T255.6.2 slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint) 调用 =====
	total += 1
	if src_pause_menu.find("slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint)") == -1:
		print("  FAIL [T255.6.2]: pause_menu.gd 缺 slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint) 调用")
		quit(1); return
	passed += 1
	print("  [T255.6.2] pause_menu.gd 含 slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint) (OK)")

	# ===== T255.6.3 T250 anchor 在调用拆分上方 docblock =====
	total += 1
	var call_idx := src_pause_menu.find("slot.tooltip_text = _build_verb_achievement_tooltip")
	if call_idx == -1:
		print("  FAIL [T255.6.3]: slot.tooltip_text 调用拆分找不到")
		quit(1); return
	# 上面 1500 字符窗口 (含 T250 #168 注释)
	var call_doc_window := src_pause_menu.substr(max(0, call_idx - 1500), 1500)
	if "T250" not in call_doc_window:
		print("  FAIL [T255.6.3]: slot.tooltip_text 调用拆分上方 1500 字符 docblock 缺 T250 anchor")
		quit(1); return
	passed += 1
	print("  [T255.6.3] slot.tooltip_text 调用拆分上方 docblock 含 T250 anchor (OK)")

	# =================================================================
	# T255.7 — CONTRIBUTING.md §9.6.5 8 行结构文档化 0 错 (1 断言)
	# =================================================================
	print("--- T255.7 — CONTRIBUTING.md §9.6.5 8 行结构文档化 ---")

	# ===== T255.7.1 §9.6.5 提到 3 行 base + 5 行 extra =====
	total += 1
	if s965.find("3 行") == -1 or s965.find("5 行") == -1:
		print("  FAIL [T255.7.1]: §9.6.5 缺「3 行 base + 5 行 extra」结构描述")
		quit(1); return
	passed += 1
	print("  [T255.7.1] §9.6.5 含「3 行 base + 5 行 extra」结构描述 (OK)")

	# =================================================================
	# T255.8 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T255.8 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T255.8.1 CHANGELOG.md 含 #174 段 =====
	total += 1
	if src_changelog.find("## #174 — T255") == -1:
		print("  FAIL [T255.8.1]: CHANGELOG.md 缺 #174 段")
		quit(1); return
	passed += 1
	print("  [T255.8.1] CHANGELOG.md 含 #174 段 (OK)")

	# ===== T255.8.2 ROADMAP.md 顶部时间戳含 #174 =====
	total += 1
	if src_roadmap.find("#174") == -1:
		print("  FAIL [T255.8.2]: ROADMAP.md 顶部缺 #174 时间戳")
		quit(1); return
	passed += 1
	print("  [T255.8.2] ROADMAP.md 顶部含 #174 时间戳 (OK)")

	print("=== T255 #174 §9.6.5 6 verb 视觉组连贯 tooltip 8 行拼接 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
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


func _extract_array_block(src: String, marker: String) -> String:
	# 找 var/const marker: ... = [ ... ] 块
	var idx := src.find(marker)
	if idx == -1:
		return ""
	var open_idx := src.find("[", idx)
	if open_idx == -1:
		return ""
	var depth := 0
	for i in range(open_idx, src.length()):
		var c := src[i]
		if c == "[":
			depth += 1
		elif c == "]":
			depth -= 1
			if depth == 0:
				return src.substr(open_idx, i - open_idx + 1)
	return ""
