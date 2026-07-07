extends SceneTree
## T259 (#179) — §9.6.9 AchievementGrid locked slot 解锁进度 alpha lerp + ProfileRecentList 5 行 alpha 渐变 base + 跨面板 _alpha_base Dictionary 双源 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t259_contributing_fragility_section969_smoke.gd
##
## T259: CONTRIBUTING.md §9.6.9 已知 fragility 扩展
##   - §9.6.9 AchievementGrid locked slot 解锁进度 alpha lerp (T222 #144)
##     + ProfileRecentList 5 行 alpha 渐变 base (T219 #141)
##     + 跨面板 _alpha_base Dictionary 双源 (T226 #145)
##   - T222 3 const: _ACHV_LOCKED_ALPHA_START 0.5 / _ACHV_LOCKED_ALPHA_END 0.2 / _ACHV_LOCKED_COLOR_RGB (0.25, 0.25, 0.3)
##   - T219 2 const: _RECENT_ROW_ALPHA_MAX 1.0 / _RECENT_ROW_ALPHA_MIN 0.5
##   - 2 var 跨面板 base dict: _slot_hover_alpha_base + _recent_row_hover_alpha_base
##   - 5 步等差步长 0.125 (1.0 - 0.5) / 4
##   - defensive fallback 1.0 (T226 _on_slot_hover_in 关键防御)
## 验证 5 维:
##   - §9.6.9 章节在 CONTRIBUTING.md 已落地
##   - §9.6.9 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - pause_menu.gd T222 3 const (alpha_start/alpha_end/color_rgb)
##     - pause_menu.gd T219 2 const (alpha_max/alpha_min)
##     - pause_menu.gd 2 var 跨面板 base dict
##     - pause_menu.gd T222 + T226 _refresh_achievement_grid 末尾 unlocked/locked 2 path
##     - pause_menu.gd T219 + T231 _refresh_recent_runs_list 末尾 5 行 base 存 dict
##   - CHANGELOG.md 含 #179 段 + ROADMAP.md 顶部时间戳含 #179

func _initialize() -> void:
	print("=== T259 #179 §9.6.9 AchievementGrid locked slot 解锁进度 alpha lerp + ProfileRecentList 5 行 alpha 渐变 base + 跨面板 _alpha_base Dictionary 双源 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T259.1 — §9.6.9 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T259.1 — §9.6.9 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T259.1.1 §9.6.9 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.9 AchievementGrid locked slot 解锁进度 alpha lerp + ProfileRecentList 5 行 alpha 渐变 base + 跨面板 `_alpha_base` Dictionary 双源 polish 模式 (T222 #144 + T219 #141 + T226 #145 落地)") == -1:
		print("  FAIL [T259.1.1]: CONTRIBUTING.md 缺 §9.6.9 章节标题")
		quit(1); return
	passed += 1
	print("  [T259.1.1] CONTRIBUTING.md 含 §9.6.9 章节标题 (OK)")

	# ===== T259.1.2 §9.6.9 含 T222 + T219 + T226 三个 anchor =====
	total += 1
	var s969_start := src_contributing.find("### 9.6.9")
	var s10_start := src_contributing.find("## 10.")
	if s969_start == -1 or s10_start == -1:
		print("  FAIL [T259.1.2]: §9.6.9 / ## 10 区间划分失败")
		quit(1); return
	var s969 := src_contributing.substr(s969_start, s10_start - s969_start)
	if "T222" not in s969:
		print("  FAIL [T259.1.2]: §9.6.9 区间缺 T222 anchor (T222 #144 解锁进度 alpha lerp 落地任务)")
		quit(1); return
	if "T219" not in s969:
		print("  FAIL [T259.1.2]: §9.6.9 区间缺 T219 anchor (T219 #141 5 行 row alpha 渐变落地任务)")
		quit(1); return
	if "T226" not in s969:
		print("  FAIL [T259.1.2]: §9.6.9 区间缺 T226 anchor (T226 #145 跨面板 _alpha_base Dictionary 双源落地任务)")
		quit(1); return
	passed += 1
	print("  [T259.1.2] CONTRIBUTING.md §9.6.9 区间含 T222 + T219 + T226 三个 anchor (OK)")

	# ===== T259.1.3 §9.6.9 提到 alpha lerp + 5 行渐变 + 跨面板双源字典核心概念 =====
	total += 1
	if s969.find("alpha lerp") == -1:
		print("  FAIL [T259.1.3]: §9.6.9 缺「alpha lerp」核心概念 (T222 解锁进度 alpha lerp)")
		quit(1); return
	if s969.find("5 行") == -1 and s969.find("5行") == -1:
		print("  FAIL [T259.1.3]: §9.6.9 缺「5 行」核心概念 (T219 5 行 row alpha 渐变)")
		quit(1); return
	if s969.find("_alpha_base") == -1 and s969.find("base dict") == -1 and s969.find("base 字典") == -1:
		print("  FAIL [T259.1.3]: §9.6.9 缺「_alpha_base」核心概念 (T226 跨面板 base 字典双源)")
		quit(1); return
	passed += 1
	print("  [T259.1.3] CONTRIBUTING.md §9.6.9 含 alpha lerp + 5 行渐变 + 跨面板双源字典核心概念 (OK)")

	# =================================================================
	# T259.2 — §9.6.9 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T259.2 — §9.6.9 4 段结构 ---")

	# ===== T259.2.1 §9.6.9 症状 =====
	total += 1
	if s969.find("**症状**") == -1:
		print("  FAIL [T259.2.1]: §9.6.9 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T259.2.1] §9.6.9 含「症状」段 (OK)")

	# ===== T259.2.2 §9.6.9 触发场景 =====
	total += 1
	if s969.find("**触发场景**") == -1:
		print("  FAIL [T259.2.2]: §9.6.9 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T259.2.2] §9.6.9 含「触发场景」段 (OK)")

	# ===== T259.2.3 §9.6.9 修复 =====
	total += 1
	if s969.find("**修复**") == -1:
		print("  FAIL [T259.2.3]: §9.6.9 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T259.2.3] §9.6.9 含「修复」段 (OK)")

	# ===== T259.2.4 §9.6.9 预防 =====
	total += 1
	if s969.find("**预防**") == -1:
		print("  FAIL [T259.2.4]: §9.6.9 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T259.2.4] §9.6.9 含「预防」段 (OK)")

	# =================================================================
	# T259.3 — pause_menu.gd T222 3 const (5 断言)
	# =================================================================
	print("--- T259.3 — pause_menu.gd T222 解锁进度 alpha lerp 3 const ---")

	# ===== T259.3.1 _ACHV_LOCKED_ALPHA_START 0.5 (T222) =====
	total += 1
	if src_pause_menu.find("const _ACHV_LOCKED_ALPHA_START := 0.5") == -1:
		print("  FAIL [T259.3.1]: pause_menu.gd 缺 const _ACHV_LOCKED_ALPHA_START := 0.5 (T222 解锁进度 alpha lerp 起点)")
		quit(1); return
	passed += 1
	print("  [T259.3.1] pause_menu.gd 含 _ACHV_LOCKED_ALPHA_START := 0.5 (T222) (OK)")

	# ===== T259.3.2 _ACHV_LOCKED_ALPHA_END 0.2 (T222 关键设计) =====
	total += 1
	if src_pause_menu.find("const _ACHV_LOCKED_ALPHA_END := 0.2") == -1:
		print("  FAIL [T259.3.2]: pause_menu.gd 缺 const _ACHV_LOCKED_ALPHA_END := 0.2 (T222 0.2 终点避免 fade 到底 0 透明)")
		quit(1); return
	passed += 1
	print("  [T259.3.2] pause_menu.gd 含 _ACHV_LOCKED_ALPHA_END := 0.2 (T222 关键设计) (OK)")

	# ===== T259.3.3 _ACHV_LOCKED_COLOR_RGB Color(0.25, 0.25, 0.3) (T222 暗灰调) =====
	total += 1
	if src_pause_menu.find("const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)") == -1:
		print("  FAIL [T259.3.3]: pause_menu.gd 缺 const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3) (T222 暗灰调 RGB 锁定)")
		quit(1); return
	passed += 1
	print("  [T259.3.3] pause_menu.gd 含 _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3) (T222) (OK)")

	# ===== T259.3.4 _RECENT_ROW_ALPHA_MAX 1.0 (T219) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_ALPHA_MAX := 1.0") == -1:
		print("  FAIL [T259.3.4]: pause_menu.gd 缺 const _RECENT_ROW_ALPHA_MAX := 1.0 (T219 5 行 row alpha 渐变上界)")
		quit(1); return
	passed += 1
	print("  [T259.3.4] pause_menu.gd 含 _RECENT_ROW_ALPHA_MAX := 1.0 (T219) (OK)")

	# ===== T259.3.5 _RECENT_ROW_ALPHA_MIN 0.5 (T219) =====
	total += 1
	if src_pause_menu.find("const _RECENT_ROW_ALPHA_MIN := 0.5") == -1:
		print("  FAIL [T259.3.5]: pause_menu.gd 缺 const _RECENT_ROW_ALPHA_MIN := 0.5 (T219 5 行 row alpha 渐变下界)")
		quit(1); return
	passed += 1
	print("  [T259.3.5] pause_menu.gd 含 _RECENT_ROW_ALPHA_MIN := 0.5 (T219) (OK)")

	# =================================================================
	# T259.4 — pause_menu.gd 2 var 跨面板 base dict (3 断言)
	# =================================================================
	print("--- T259.4 — pause_menu.gd 跨面板 _alpha_base Dictionary 双源 ---")

	# ===== T259.4.1 _slot_hover_alpha_base Dictionary (T226) =====
	total += 1
	if src_pause_menu.find("var _slot_hover_alpha_base: Dictionary = {}") == -1:
		print("  FAIL [T259.4.1]: pause_menu.gd 缺 var _slot_hover_alpha_base: Dictionary = {} (T226 slot 跨面板 base dict 第 1 源)")
		quit(1); return
	passed += 1
	print("  [T259.4.1] pause_menu.gd 含 _slot_hover_alpha_base Dictionary (T226) (OK)")

	# ===== T259.4.2 _recent_row_hover_alpha_base Dictionary (T231) =====
	total += 1
	if src_pause_menu.find("var _recent_row_hover_alpha_base: Dictionary = {}") == -1:
		print("  FAIL [T259.4.2]: pause_menu.gd 缺 var _recent_row_hover_alpha_base: Dictionary = {} (T231 row 跨面板 base dict 第 2 源)")
		quit(1); return
	passed += 1
	print("  [T259.4.2] pause_menu.gd 含 _recent_row_hover_alpha_base Dictionary (T231) (OK)")

	# ===== T259.4.3 _slot_hover_alpha_base 在 _refresh_achievement_grid 末尾存 base (T226) =====
	total += 1
	var s4_count := 0
	# unlocked 路径: _slot_hover_alpha_base[child] = 1.0
	if src_pause_menu.find("_slot_hover_alpha_base[child] = 1.0") != -1:
		s4_count += 1
	# locked 路径: _slot_hover_alpha_base[child] = locked_alpha
	if src_pause_menu.find("_slot_hover_alpha_base[child] = locked_alpha") != -1:
		s4_count += 1
	if s4_count != 2:
		print("  FAIL [T259.4.3]: pause_menu.gd _slot_hover_alpha_base 在 _refresh_achievement_grid 末尾 base 存 dict 路径数 = %d (期望 2: unlocked=1.0 + locked=locked_alpha)" % s4_count)
		quit(1); return
	passed += 1
	print("  [T259.4.3] pause_menu.gd _slot_hover_alpha_base 2 path base 存 dict (unlocked=1.0 + locked=locked_alpha) (OK)")

	# =================================================================
	# T259.5 — pause_menu.gd T219 + T231 5 行 row 渐变公式 (3 断言)
	# =================================================================
	print("--- T259.5 — pause_menu.gd T219 + T231 5 行 row alpha 渐变公式 ---")

	# ===== T259.5.1 alpha_step 5 步等差步长公式 (T219) =====
	total += 1
	if src_pause_menu.find("alpha_step: float = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1)") == -1:
		print("  FAIL [T259.5.1]: pause_menu.gd 缺 alpha_step 5 步等差步长公式 (T219 alpha 渐变公式 0 改)")
		quit(1); return
	passed += 1
	print("  [T259.5.1] pause_menu.gd 含 alpha_step 5 步等差步长公式 (T219) (OK)")

	# ===== T259.5.2 row_alpha linear 公式 (T219) =====
	total += 1
	if src_pause_menu.find("var row_alpha: float = _RECENT_ROW_ALPHA_MAX - float(i) * alpha_step") == -1:
		print("  FAIL [T259.5.2]: pause_menu.gd 缺 row_alpha linear 公式 (T219 5 行 linear 0 改)")
		quit(1); return
	passed += 1
	print("  [T259.5.2] pause_menu.gd 含 row_alpha linear 公式 (T219) (OK)")

	# ===== T259.5.3 _recent_row_hover_alpha_base[i] = row_alpha 存 dict (T231) =====
	total += 1
	if src_pause_menu.find("_recent_row_hover_alpha_base[i] = row_alpha") == -1:
		print("  FAIL [T259.5.3]: pause_menu.gd 缺 _recent_row_hover_alpha_base[i] = row_alpha 5 行存 dict (T231 row 跨面板 base dict 末尾存)")
		quit(1); return
	passed += 1
	print("  [T259.5.3] pause_menu.gd 含 _recent_row_hover_alpha_base[i] = row_alpha (T231) (OK)")

	# =================================================================
	# T259.6 — pause_menu.gd T226 defensive fallback 1.0 + 读 dict 模式 (3 断言)
	# =================================================================
	print("--- T259.6 — pause_menu.gd T226 defensive fallback + 读 dict 模式 ---")

	# ===== T259.6.1 defensive fallback 1.0 (T226 关键防御) =====
	total += 1
	if src_pause_menu.find("var base_alpha: float = 1.0") == -1:
		print("  FAIL [T259.6.1]: pause_menu.gd 缺 var base_alpha: float = 1.0 (T226 defensive fallback _refresh 之前 _on_slot_hover_in 0 越界读 dict)")
		quit(1); return
	passed += 1
	print("  [T259.6.1] pause_menu.gd 含 defensive fallback base_alpha: float = 1.0 (T226 关键防御) (OK)")

	# ===== T259.6.2 _on_slot_hover_in 读 dict has(slot) 守卫 (T226) =====
	total += 1
	if src_pause_menu.find("if _slot_hover_alpha_base.has(slot):") == -1:
		print("  FAIL [T259.6.2]: pause_menu.gd 缺 if _slot_hover_alpha_base.has(slot): 读 dict 守卫 (T226 hover 0 base 报错防御)")
		quit(1); return
	passed += 1
	print("  [T259.6.2] pause_menu.gd 含 _slot_hover_alpha_base.has(slot) 读 dict 守卫 (T226) (OK)")

	# ===== T259.6.3 _on_slot_hover_out 读 dict 读 base_alpha (T226 配套) =====
	total += 1
	# _on_slot_hover_out 同样走 _slot_hover_alpha_base.has(slot) 读 base_alpha, 验证 2 处
	var has_count := 0
	var pos := 0
	while true:
		var idx := src_pause_menu.find("if _slot_hover_alpha_base.has(slot):", pos)
		if idx == -1:
			break
		has_count += 1
		pos = idx + 1
	if has_count < 2:
		print("  FAIL [T259.6.3]: pause_menu.gd _slot_hover_alpha_base.has(slot) 读 dict 守卫数 = %d (期望 ≥ 2, _on_slot_hover_in + _on_slot_hover_out 配套)" % has_count)
		quit(1); return
	passed += 1
	print("  [T259.6.3] pause_menu.gd _slot_hover_alpha_base.has(slot) 读 dict 守卫 ≥ 2 处 (T226 配套) (OK)")

	# =================================================================
	# T259.7 — pause_menu.gd T222 + T226 _refresh_achievement_grid 跨刷新联动 (2 断言)
	# =================================================================
	print("--- T259.7 — pause_menu.gd T222 + T226 _refresh_achievement_grid 联动 ---")

	# ===== T259.7.1 _refresh_achievement_grid unlocked/locked 2 path 联动 (T222) =====
	total += 1
	if src_pause_menu.find("PlayerStats.is_unlocked(id_val)") == -1:
		print("  FAIL [T259.7.1]: pause_menu.gd 缺 PlayerStats.is_unlocked(id_val) (T222 _refresh_achievement_grid unlocked/locked 2 path 分流 0 触碰)")
		quit(1); return
	if src_pause_menu.find("locked_alpha: float = lerp(_ACHV_LOCKED_ALPHA_START, _ACHV_LOCKED_ALPHA_END, progress)") == -1:
		print("  FAIL [T259.7.1]: pause_menu.gd 缺 locked_alpha: float = lerp(...) (T222 lerp 公式 0 改)")
		quit(1); return
	passed += 1
	print("  [T259.7.1] pause_menu.gd _refresh_achievement_grid unlocked/locked 2 path + lerp 公式 (T222) (OK)")

	# ===== T259.7.2 locked_color 用 _ACHV_LOCKED_COLOR_RGB + 改 alpha 0 改 RGB (T222 关键设计) =====
	total += 1
	if src_pause_menu.find("var locked_color: Color = Color(_ACHV_LOCKED_COLOR_RGB.r, _ACHV_LOCKED_COLOR_RGB.g, _ACHV_LOCKED_COLOR_RGB.b, locked_alpha)") == -1:
		print("  FAIL [T259.7.2]: pause_menu.gd 缺 locked_color = Color(RGB.r, RGB.g, RGB.b, locked_alpha) 改 alpha 0 改 RGB (T222 关键设计)")
		quit(1); return
	passed += 1
	print("  [T259.7.2] pause_menu.gd locked_color 改 alpha 0 改 RGB (T222 关键设计) (OK)")

	# =================================================================
	# T259.8 — CONTRIBUTING.md §9.6.9 核心概念 (3 断言)
	# =================================================================
	print("--- T259.8 — CONTRIBUTING.md §9.6.9 核心概念 ---")

	# ===== T259.8.1 §9.6.9 提到 0.2 终点 (T222 关键设计) =====
	total += 1
	if s969.find("0.2") == -1:
		print("  FAIL [T259.8.1]: §9.6.9 缺 T222 0.2 终点描述 (避免 fade 到底 0 透明)")
		quit(1); return
	passed += 1
	print("  [T259.8.1] §9.6.9 含 T222 0.2 终点描述 (OK)")

	# ===== T259.8.2 §9.6.9 提到 5 步等差步长 0.125 (T219 关键设计) =====
	total += 1
	if s969.find("0.125") == -1:
		print("  FAIL [T259.8.2]: §9.6.9 缺 T219 5 步等差步长 0.125 描述 (1.0 - 0.5) / 4 = 0.125")
		quit(1); return
	passed += 1
	print("  [T259.8.2] §9.6.9 含 T219 5 步等差步长 0.125 描述 (OK)")

	# ===== T259.8.3 §9.6.9 提到跨面板 2 base dict 0 互混 (T226 关键设计) =====
	total += 1
	if s969.find("_slot_hover_alpha_base") == -1:
		print("  FAIL [T259.8.3]: §9.6.9 缺 T226 _slot_hover_alpha_base 跨面板 base dict 描述")
		quit(1); return
	if s969.find("_recent_row_hover_alpha_base") == -1:
		print("  FAIL [T259.8.3]: §9.6.9 缺 T231 _recent_row_hover_alpha_base 跨面板 base dict 描述")
		quit(1); return
	passed += 1
	print("  [T259.8.3] §9.6.9 含跨面板 2 base dict 0 互混描述 (T226 关键设计) (OK)")

	# =================================================================
	# T259.9 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T259.9 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T259.9.1 CHANGELOG.md 含 #179 段 =====
	total += 1
	if src_changelog.find("## #179 — T259") == -1:
		print("  FAIL [T259.9.1]: CHANGELOG.md 缺 #179 段")
		quit(1); return
	passed += 1
	print("  [T259.9.1] CHANGELOG.md 含 #179 段 (OK)")

	# ===== T259.9.2 ROADMAP.md 顶部时间戳含 #179 =====
	total += 1
	if src_roadmap.find("#179") == -1:
		print("  FAIL [T259.9.2]: ROADMAP.md 顶部缺 #179 时间戳")
		quit(1); return
	passed += 1
	print("  [T259.9.2] ROADMAP.md 顶部含 #179 时间戳 (OK)")

	print("=== T259 #179 §9.6.9 AchievementGrid locked slot 解锁进度 alpha lerp + ProfileRecentList 5 行 alpha 渐变 base + 跨面板 _alpha_base Dictionary 双源 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
