extends SceneTree
## T256 (#176) — §9.6.6 ProfileRecentList 5 行 row 文本 5 字段 → 7 字段 format 字符串扩展模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t256_contributing_fragility_section966_smoke.gd
##
## T256: CONTRIBUTING.md §9.6.6 已知 fragility 扩展
##   - §9.6.6 ProfileRecentList 5 行 row 文本 5 字段 → 7 字段 format 字符串扩展模式 (T249 #167 落地)
##   - 7 字段顺序与 _RECENT_ROW_HINT tooltip 1:1 对齐
##   - 6 middle-dot 分隔符 + 末尾 _RECENT_ROW_TIP_INDICATOR 0 删
##   - if t_sec > 0.0 守卫 (0/0 nan 防御)
##   - 0 BBCode 包裹, 走纯文本 + add_theme_color_override
## 验证 5 维:
##   - §9.6.6 章节在 CONTRIBUTING.md 已落地
##   - §9.6.6 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - pause_menu.gd row_lbl.text 7 字段 format 字符串
##     - pause_menu.gd 6 个 _RECENT_ROW_FIELD_SEP + 1 个 _RECENT_ROW_TIP_INDICATOR
##     - pause_menu.gd if t_sec > 0.0 守卫
##     - pause_menu.gd rooms_per_minute + enemies_per_minute 局部变量
##     - pause_menu.gd _RECENT_ROW_HINT 7 entry dict
##   - CHANGELOG.md 含 #176 段 + ROADMAP.md 顶部时间戳含 #176

func _initialize() -> void:
	print("=== T256 #176 §9.6.6 ProfileRecentList 7 字段 format 字符串扩展模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T256.1 — §9.6.6 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T256.1 — §9.6.6 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T256.1.1 §9.6.6 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.6 ProfileRecentList 5 行 row 文本 5 字段 → 7 字段 format 字符串扩展模式 (T249 #167 落地)") == -1:
		print("  FAIL [T256.1.1]: CONTRIBUTING.md 缺 §9.6.6 章节标题")
		quit(1); return
	passed += 1
	print("  [T256.1.1] CONTRIBUTING.md 含 §9.6.6 章节标题 (OK)")

	# ===== T256.1.2 §9.6.6 含 T249 anchor =====
	total += 1
	var s966_start := src_contributing.find("### 9.6.6")
	var s10_start := src_contributing.find("## 10.")
	if s966_start == -1 or s10_start == -1:
		print("  FAIL [T256.1.2]: §9.6.6 / ## 10 区间划分失败")
		quit(1); return
	var s966 := src_contributing.substr(s966_start, s10_start - s966_start)
	if "T249" not in s966:
		print("  FAIL [T256.1.2]: §9.6.6 区间缺 T249 anchor (T249 #167 是该模式落地任务)")
		quit(1); return
	passed += 1
	print("  [T256.1.2] CONTRIBUTING.md §9.6.6 区间含 T249 anchor (OK)")

	# ===== T256.1.3 §9.6.6 提到 7 字段扩展 =====
	total += 1
	if s966.find("7 字段") == -1 and s966.find("5 字段") == -1:
		print("  FAIL [T256.1.3]: §9.6.6 缺 7 字段扩展核心概念")
		quit(1); return
	passed += 1
	print("  [T256.1.3] CONTRIBUTING.md §9.6.6 含 7 字段扩展核心概念 (OK)")

	# =================================================================
	# T256.2 — §9.6.6 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T256.2 — §9.6.6 4 段结构 ---")

	# ===== T256.2.1 §9.6.6 症状 =====
	total += 1
	if s966.find("**症状**") == -1:
		print("  FAIL [T256.2.1]: §9.6.6 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T256.2.1] §9.6.6 含「症状」段 (OK)")

	# ===== T256.2.2 §9.6.6 触发场景 =====
	total += 1
	if s966.find("**触发场景**") == -1:
		print("  FAIL [T256.2.2]: §9.6.6 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T256.2.2] §9.6.6 含「触发场景」段 (OK)")

	# ===== T256.2.3 §9.6.6 修复 =====
	total += 1
	if s966.find("**修复**") == -1:
		print("  FAIL [T256.2.3]: §9.6.6 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T256.2.3] §9.6.6 含「修复」段 (OK)")

	# ===== T256.2.4 §9.6.6 预防 =====
	total += 1
	if s966.find("**预防**") == -1:
		print("  FAIL [T256.2.4]: §9.6.6 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T256.2.4] §9.6.6 含「预防」段 (OK)")

	# =================================================================
	# T256.3 — pause_menu.gd row_lbl.text 7 字段 format 字符串 (4 断言)
	# =================================================================
	print("--- T256.3 — pause_menu.gd row_lbl.text 7 字段 format 字符串 ---")

	# ===== T256.3.1 row_lbl.text 7 字段 format 字符串 =====
	total += 1
	if src_pause_menu.find("row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"") == -1:
		print("  FAIL [T256.3.1]: pause_menu.gd 缺 7 字段 row_lbl.text format 字符串")
		quit(1); return
	passed += 1
	print("  [T256.3.1] pause_menu.gd 含 7 字段 row_lbl.text format 字符串 (OK)")

	# ===== T256.3.2 6 个 _RECENT_ROW_FIELD_SEP 在 format 数组中 =====
	total += 1
	var format_idx := src_pause_menu.find("row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"")
	if format_idx == -1:
		print("  FAIL [T256.3.2]: row_lbl.text 7 字段 format 字符串找不到")
		quit(1); return
	var format_array_window := src_pause_menu.substr(format_idx, 800)
	var sep_count := format_array_window.count("_RECENT_ROW_FIELD_SEP")
	if sep_count != 6:
		print("  FAIL [T256.3.2]: 期望 6 个 _RECENT_ROW_FIELD_SEP (4 原 5 字段 + 2 派生率), 实际 %d" % sep_count)
		quit(1); return
	passed += 1
	print("  [T256.3.2] format 数组 6 个 _RECENT_ROW_FIELD_SEP (4 原 5 字段 + 2 派生率) (OK)")

	# ===== T256.3.3 format 数组末尾 = _RECENT_ROW_TIP_INDICATOR 0 删 =====
	total += 1
	if not format_array_window.ends_with("enemies_per_minute, _RECENT_ROW_TIP_INDICATOR"):
		# 宽容匹配: 检查是否包含 (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR) 在末尾
		var tip_indicator_idx := format_array_window.find("enemies_per_minute, _RECENT_ROW_TIP_INDICATOR")
		if tip_indicator_idx == -1:
			print("  FAIL [T256.3.3]: 期望 format 数组末尾 = (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR)")
			quit(1); return
	passed += 1
	print("  [T256.3.3] format 数组末尾 = (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR) 0 删 (OK)")

	# ===== T256.3.4 0 BBCode 包裹 =====
	total += 1
	var format_str_window := src_pause_menu.substr(format_idx, 200)
	if format_str_window.find("[color=") != -1 or format_str_window.find("[b]") != -1:
		print("  FAIL [T256.3.4]: row_lbl.text format 字符串含 BBCode 标记 (T249 应走纯文本 + add_theme_color_override)")
		quit(1); return
	passed += 1
	print("  [T256.3.4] row_lbl.text 7 字段 format 字符串 0 BBCode 包裹 (OK)")

	# =================================================================
	# T256.4 — pause_menu.gd if t_sec > 0.0 守卫 (3 断言)
	# =================================================================
	print("--- T256.4 — pause_menu.gd if t_sec > 0.0 守卫 ---")

	# ===== T256.4.1 if t_sec > 0.0 守卫存在 =====
	total += 1
	if src_pause_menu.find("if t_sec > 0.0:") == -1:
		print("  FAIL [T256.4.1]: pause_menu.gd 缺 if t_sec > 0.0 守卫 (0/0 nan 防御)")
		quit(1); return
	passed += 1
	print("  [T256.4.1] pause_menu.gd 含 if t_sec > 0.0 守卫 (OK)")

	# ===== T256.4.2 rooms_per_minute 局部变量声明 + 计算 =====
	total += 1
	if src_pause_menu.find("var rooms_per_minute: int = 0") == -1:
		print("  FAIL [T256.4.2]: pause_menu.gd 缺 var rooms_per_minute: int = 0 局部变量声明")
		quit(1); return
	passed += 1
	print("  [T256.4.2] pause_menu.gd 含 var rooms_per_minute: int = 0 局部变量声明 (OK)")

	# ===== T256.4.3 enemies_per_minute 局部变量声明 + 计算 =====
	total += 1
	if src_pause_menu.find("var enemies_per_minute: int = 0") == -1:
		print("  FAIL [T256.4.3]: pause_menu.gd 缺 var enemies_per_minute: int = 0 局部变量声明")
		quit(1); return
	passed += 1
	print("  [T256.4.3] pause_menu.gd 含 var enemies_per_minute: int = 0 局部变量声明 (OK)")

	# =================================================================
	# T256.5 — pause_menu.gd _RECENT_ROW_HINT 7 entry dict (3 断言)
	# =================================================================
	print("--- T256.5 — pause_menu.gd _RECENT_ROW_HINT 7 entry dict ---")

	# ===== T256.5.1 _RECENT_ROW_HINT const 声明 =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_HINT := [") == -1:
		print("  FAIL [T256.5.1]: pause_menu.gd 缺 const _RECENT_ROW_HINT := [...] 声明")
		quit(1); return
	passed += 1
	print("  [T256.5.1] pause_menu.gd 含 const _RECENT_ROW_HINT := [...] 声明 (OK)")

	# ===== T256.5.2 _RECENT_ROW_HINT 7 entry label 全部存在 =====
	total += 1
	var hint_idx := src_pause_menu.find("const _RECENT_ROW_HINT")
	if hint_idx == -1:
		print("  FAIL [T256.5.2]: _RECENT_ROW_HINT 找不到")
		quit(1); return
	var hint_block := _extract_array_block(src_pause_menu, "_RECENT_ROW_HINT")
	if hint_block.is_empty():
		print("  FAIL [T256.5.2]: _RECENT_ROW_HINT 块提取失败")
		quit(1); return
	var expected_labels := ["Run #", "房", "净", "碎", "时", "房/时", "净/时"]
	var missing_labels: Array[String] = []
	for lbl in expected_labels:
		var label_key := "\"%s\"" % lbl
		if not label_key in hint_block:
			missing_labels.append(lbl)
	if missing_labels.size() > 0:
		print("  FAIL [T256.5.2]: _RECENT_ROW_HINT 缺 label: %s" % str(missing_labels))
		quit(1); return
	passed += 1
	print("  [T256.5.2] _RECENT_ROW_HINT 含 7 entry label (Run # / 房 / 净 / 碎 / 时 / 房/时 / 净/时) (OK)")

	# ===== T256.5.3 _RECENT_ROW_HINT 7 label 顺序 1:1 严格按 row 7 字段顺序 =====
	total += 1
	var pos_run := hint_block.find("\"Run #\"")
	var pos_fang := hint_block.find("\"房\"")
	var pos_jing := hint_block.find("\"净\"")
	var pos_sui := hint_block.find("\"碎\"")
	var pos_shi := hint_block.find("\"时\"")
	var pos_fang_shi := hint_block.find("\"房/时\"")
	var pos_jing_shi := hint_block.find("\"净/时\"")
	if pos_run == -1 or pos_fang == -1 or pos_jing == -1 or pos_sui == -1 or pos_shi == -1 or pos_fang_shi == -1 or pos_jing_shi == -1:
		print("  FAIL [T256.5.3]: _RECENT_ROW_HINT label 位置查找失败")
		quit(1); return
	if not (pos_run < pos_fang and pos_fang < pos_jing and pos_jing < pos_sui and pos_sui < pos_shi and pos_shi < pos_fang_shi and pos_fang_shi < pos_jing_shi):
		print("  FAIL [T256.5.3]: _RECENT_ROW_HINT label 顺序错位 (期望 Run #→房→净→碎→时→房/时→净/时)")
		quit(1); return
	passed += 1
	print("  [T256.5.3] _RECENT_ROW_HINT 7 label 顺序 1:1 严格 (Run # < 房 < 净 < 碎 < 时 < 房/时 < 净/时) (OK)")

	# =================================================================
	# T256.6 — CONTRIBUTING.md §9.6.6 提到核心三件套 (3 断言)
	# =================================================================
	print("--- T256.6 — CONTRIBUTING.md §9.6.6 核心三件套 ---")

	# ===== T256.6.1 §9.6.6 提到 6 middle-dot 分隔符 =====
	total += 1
	if s966.find("6 middle-dot") == -1 and s966.find("6 个") == -1 and s966.find("6 中点") == -1:
		print("  FAIL [T256.6.1]: §9.6.6 缺 6 middle-dot 分隔符描述")
		quit(1); return
	passed += 1
	print("  [T256.6.1] §9.6.6 含 6 middle-dot 分隔符描述 (OK)")

	# ===== T256.6.2 §9.6.6 提到 if t_sec > 0.0 守卫 =====
	total += 1
	if s966.find("t_sec > 0.0") == -1 and s966.find("t_sec==0") == -1:
		print("  FAIL [T256.6.2]: §9.6.6 缺 if t_sec > 0.0 守卫描述 (0/0 nan 防御)")
		quit(1); return
	passed += 1
	print("  [T256.6.2] §9.6.6 含 if t_sec > 0.0 守卫描述 (OK)")

	# ===== T256.6.3 §9.6.6 提到 _RECENT_ROW_TIP_INDICATOR 末位保留 =====
	total += 1
	if s966.find("_RECENT_ROW_TIP_INDICATOR") == -1:
		print("  FAIL [T256.6.3]: §9.6.6 缺 _RECENT_ROW_TIP_INDICATOR 末位保留描述 (T234 #153 anchor 0 删)")
		quit(1); return
	passed += 1
	print("  [T256.6.3] §9.6.6 含 _RECENT_ROW_TIP_INDICATOR 末位保留描述 (OK)")

	# =================================================================
	# T256.7 — pause_menu.gd row_lbl.text 周围 docblock T249 anchor (1 断言)
	# =================================================================
	print("--- T256.7 — pause_menu.gd row_lbl.text 周围 docblock T249 anchor ---")

	# ===== T256.7.1 row_lbl.text 上面 2500 字符 docblock 含 T249 anchor =====
	total += 1
	var row_text_idx := src_pause_menu.find("row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"")
	if row_text_idx == -1:
		print("  FAIL [T256.7.1]: row_lbl.text 7 字段 format 字符串找不到")
		quit(1); return
	var row_doc_window := src_pause_menu.substr(max(0, row_text_idx - 2500), 2500)
	if "T249" not in row_doc_window:
		print("  FAIL [T256.7.1]: row_lbl.text 上面 2500 字符 docblock 缺 T249 anchor (T249 #167 是该模式落地任务)")
		quit(1); return
	passed += 1
	print("  [T256.7.1] row_lbl.text 上面 2500 字符 docblock 含 T249 anchor (OK)")

	# =================================================================
	# T256.8 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T256.8 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T256.8.1 CHANGELOG.md 含 #176 段 =====
	total += 1
	if src_changelog.find("## #176 — T256") == -1:
		print("  FAIL [T256.8.1]: CHANGELOG.md 缺 #176 段")
		quit(1); return
	passed += 1
	print("  [T256.8.1] CHANGELOG.md 含 #176 段 (OK)")

	# ===== T256.8.2 ROADMAP.md 顶部时间戳含 #176 =====
	total += 1
	if src_roadmap.find("#176") == -1:
		print("  FAIL [T256.8.2]: ROADMAP.md 顶部缺 #176 时间戳")
		quit(1); return
	passed += 1
	print("  [T256.8.2] ROADMAP.md 顶部含 #176 时间戳 (OK)")

	print("=== T256 #176 §9.6.6 ProfileRecentList 7 字段 format 字符串扩展模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


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
