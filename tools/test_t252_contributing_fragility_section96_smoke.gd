extends SceneTree
## T252 (#171) — §9.6 跨类 handler 接通模式 + VFX 5 层 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t252_contributing_fragility_section96_smoke.gd
##
## T252: CONTRIBUTING.md §9.6 已知 fragility 扩展
##   - §9.6.1 跨类 handler `is_instance_valid + has_method` 双守卫 (T251 #169 落地)
##   - §9.6.2 VFX 5 层视觉 (L1-L5) polish 模式 (T251 #169 落地)
## 验证 4 维:
##   - §9.6 章节在 CONTRIBUTING.md 已落地
##   - §9.6.1 4 段结构 (症状/触发/修复/预防) 全部存在
##   - §9.6.2 4 段结构 (症状/触发/修复/预防) 全部存在
##   - 实际代码 pattern 与文档描述 1:1 对齐 (source-grep 验证)
##     - player.gd:849-851 6 verb Whisper 双守卫存在
##     - whisper_vfx.gd flash_hit 实现 append _hit_flashes 模式存在
##     - whisper_vfx.gd _draw L1-L5 5 个 draw_* 调用全部存在

func _initialize() -> void:
	print("=== T252 #171 §9.6 已知 fragility 扩展 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_whisper_vfx := _read_file("res://src/scripts/whisper_vfx.gd")
	var src_player := _read_file("res://src/scripts/player.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T252.1 — §9.6 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T252.1 — §9.6 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T252.1.1 §9.6 章节标题 =====
	total += 1
	if src_contributing.find("## 9.6 跨类 handler 接通模式") == -1:
		print("  FAIL [T252.1.1]: CONTRIBUTING.md 缺 §9.6 章节标题")
		quit(1); return
	passed += 1
	print("  [T252.1.1] CONTRIBUTING.md 含 §9.6 章节标题 (OK)")

	# ===== T252.1.2 §9.6.1 子章节 =====
	total += 1
	if src_contributing.find("### 9.6.1 跨类 handler `is_instance_valid + has_method` 双守卫") == -1:
		print("  FAIL [T252.1.2]: CONTRIBUTING.md 缺 §9.6.1 子章节")
		quit(1); return
	passed += 1
	print("  [T252.1.2] CONTRIBUTING.md 含 §9.6.1 子章节 (OK)")

	# ===== T252.1.3 §9.6.2 子章节 =====
	total += 1
	if src_contributing.find("### 9.6.2 VFX 5 层视觉 (L1–L5) polish 模式") == -1:
		print("  FAIL [T252.1.3]: CONTRIBUTING.md 缺 §9.6.2 子章节")
		quit(1); return
	passed += 1
	print("  [T252.1.3] CONTRIBUTING.md 含 §9.6.2 子章节 (OK)")

	# =================================================================
	# T252.2 — §9.6.1 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T252.2 — §9.6.1 4 段结构 ---")

	# ===== T252.2.1 §9.6.1 症状 =====
	total += 1
	# 找到 §9.6.1 起止区间
	var s961_start := src_contributing.find("### 9.6.1 跨类 handler")
	var s961_end := src_contributing.find("### 9.6.2")
	if s961_start == -1 or s961_end == -1:
		print("  FAIL [T252.2.1]: CONTRIBUTING.md §9.6.1 / §9.6.2 区间划分失败")
		quit(1); return
	var s961 := src_contributing.substr(s961_start, s961_end - s961_start)
	if s961.find("**症状**") == -1:
		print("  FAIL [T252.2.1]: §9.6.1 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T252.2.1] §9.6.1 含「症状」段 (OK)")

	# ===== T252.2.2 §9.6.1 触发 =====
	total += 1
	if s961.find("**触发场景**") == -1:
		print("  FAIL [T252.2.2]: §9.6.1 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T252.2.2] §9.6.1 含「触发场景」段 (OK)")

	# ===== T252.2.3 §9.6.1 修复 =====
	total += 1
	if s961.find("**修复**") == -1:
		print("  FAIL [T252.2.3]: §9.6.1 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T252.2.3] §9.6.1 含「修复」段 (OK)")

	# ===== T252.2.4 §9.6.1 预防 =====
	total += 1
	if s961.find("**预防**") == -1:
		print("  FAIL [T252.2.4]: §9.6.1 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T252.2.4] §9.6.1 含「预防」段 (OK)")

	# =================================================================
	# T252.3 — §9.6.2 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T252.3 — §9.6.2 4 段结构 ---")

	var s962_start := s961_end
	var s962_end := src_contributing.find("## 10.")
	if s962_end == -1:
		s962_end = src_contributing.length()
	var s962 := src_contributing.substr(s962_start, s962_end - s962_start)

	# ===== T252.3.1 §9.6.2 症状 =====
	total += 1
	if s962.find("**症状**") == -1:
		print("  FAIL [T252.3.1]: §9.6.2 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T252.3.1] §9.6.2 含「症状」段 (OK)")

	# ===== T252.3.2 §9.6.2 触发 =====
	total += 1
	if s962.find("**触发场景**") == -1:
		print("  FAIL [T252.3.2]: §9.6.2 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T252.3.2] §9.6.2 含「触发场景」段 (OK)")

	# ===== T252.3.3 §9.6.2 修复 =====
	total += 1
	if s962.find("**修复**") == -1:
		print("  FAIL [T252.3.3]: §9.6.2 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T252.3.3] §9.6.2 含「修复」段 (OK)")

	# ===== T252.3.4 §9.6.2 预防 =====
	total += 1
	if s962.find("**预防**") == -1:
		print("  FAIL [T252.3.4]: §9.6.2 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T252.3.4] §9.6.2 含「预防」段 (OK)")

	# =================================================================
	# T252.4 — player.gd 6 verb Whisper 双守卫代码 pattern 实际存在 (4 断言)
	# =================================================================
	print("--- T252.4 — player.gd 6 verb Whisper 双守卫代码 pattern ---")

	# ===== T252.4.1 _current_whisper_vfx truthy 守卫 =====
	total += 1
	if src_player.find("if _current_whisper_vfx and is_instance_valid(_current_whisper_vfx)") == -1:
		print("  FAIL [T252.4.1]: player.gd 缺 _current_whisper_vfx truthy 守卫")
		quit(1); return
	passed += 1
	print("  [T252.4.1] player.gd 含 _current_whisper_vfx truthy 守卫 (OK)")

	# ===== T252.4.2 has_method 守卫 =====
	total += 1
	if src_player.find("_current_whisper_vfx.has_method(\"flash_hit\")") == -1:
		print("  FAIL [T252.4.2]: player.gd 缺 has_method(\"flash_hit\") 守卫")
		quit(1); return
	passed += 1
	print("  [T252.4.2] player.gd 含 has_method(\"flash_hit\") 守卫 (OK)")

	# ===== T252.4.3 _on_whisper_hit 注释锚点 =====
	total += 1
	if src_player.find("_on_whisper_hit") == -1:
		print("  FAIL [T252.4.3]: player.gd 缺 _on_whisper_hit handler")
		quit(1); return
	passed += 1
	print("  [T252.4.3] player.gd 含 _on_whisper_hit handler (OK)")

	# ===== T252.4.4 flash_hit 调用 =====
	total += 1
	if src_player.find("_current_whisper_vfx.flash_hit(target.global_position)") == -1:
		print("  FAIL [T252.4.4]: player.gd 缺 flash_hit 调用")
		quit(1); return
	passed += 1
	print("  [T252.4.4] player.gd 含 flash_hit 调用 (OK)")

	# =================================================================
	# T252.5 — whisper_vfx.gd flash_hit 实现 _hit_flashes 模式 (4 断言)
	# =================================================================
	print("--- T252.5 — whisper_vfx.gd flash_hit 实现 _hit_flashes 模式 ---")

	# ===== T252.5.1 _hit_flashes 数组声明 =====
	total += 1
	if src_whisper_vfx.find("var _hit_flashes: Array") == -1:
		print("  FAIL [T252.5.1]: whisper_vfx.gd 缺 _hit_flashes: Array 声明")
		quit(1); return
	passed += 1
	print("  [T252.5.1] whisper_vfx.gd 含 _hit_flashes: Array 声明 (OK)")

	# ===== T252.5.2 flash_hit append 模式 =====
	total += 1
	if src_whisper_vfx.find("func flash_hit(target_pos: Vector2)") == -1:
		print("  FAIL [T252.5.2]: whisper_vfx.gd 缺 flash_hit(target_pos) 函数")
		quit(1); return
	passed += 1
	print("  [T252.5.2] whisper_vfx.gd 含 flash_hit(target_pos) 函数 (OK)")

	# ===== T252.5.3 _hit_flashes.append 模式 =====
	total += 1
	if src_whisper_vfx.find("_hit_flashes.append({") == -1:
		print("  FAIL [T252.5.3]: whisper_vfx.gd 缺 _hit_flashes.append({...}) 模式")
		quit(1); return
	passed += 1
	print("  [T252.5.3] whisper_vfx.gd 含 _hit_flashes.append({...}) 模式 (OK)")

	# ===== T252.5.4 _process reversed 循环防 remove_at 索引错位 =====
	total += 1
	if src_whisper_vfx.find("for i in range(_hit_flashes.size() - 1, -1, -1):") == -1:
		print("  FAIL [T252.5.4]: whisper_vfx.gd _process 缺 reversed 循环")
		quit(1); return
	passed += 1
	print("  [T252.5.4] whisper_vfx.gd _process 含 reversed 循环 (OK)")

	# =================================================================
	# T252.6 — whisper_vfx.gd _draw L1-L5 5 个 draw_* 调用 (5 断言)
	# =================================================================
	print("--- T252.6 — whisper_vfx.gd _draw L1-L5 ---")

	# ===== T252.6.1 L1 OUTER_FILL draw_circle =====
	total += 1
	# 找 _draw 函数体
	var draw_start := src_whisper_vfx.find("func _draw()")
	if draw_start == -1:
		print("  FAIL [T252.6.0]: whisper_vfx.gd 缺 _draw 函数")
		quit(1); return
	var draw_body := src_whisper_vfx.substr(draw_start)
	if draw_body.find("L1 OUTER_FILL") == -1 or draw_body.find("draw_circle(Vector2.ZERO, _max_radius, fill_color)") == -1:
		print("  FAIL [T252.6.1]: whisper_vfx.gd _draw 缺 L1 OUTER_FILL draw_circle")
		quit(1); return
	passed += 1
	print("  [T252.6.1] whisper_vfx.gd _draw 含 L1 OUTER_FILL draw_circle (OK)")

	# ===== T252.6.2 L2 SPHERE_RING draw_arc =====
	total += 1
	if draw_body.find("L2 SPHERE_RING") == -1 or draw_body.find("draw_arc(Vector2.ZERO, _max_radius, 0.0, TAU, 32, ring_color, RING_THICKNESS)") == -1:
		print("  FAIL [T252.6.2]: whisper_vfx.gd _draw 缺 L2 SPHERE_RING draw_arc")
		quit(1); return
	passed += 1
	print("  [T252.6.2] whisper_vfx.gd _draw 含 L2 SPHERE_RING draw_arc (OK)")

	# ===== T252.6.3 L3 EDGE_HIGHLIGHT draw_arc (T251 新增) =====
	total += 1
	if draw_body.find("L3 EDGE_HIGHLIGHT") == -1 or draw_body.find("EDGE_HIGHLIGHT_RADIUS_RATIO") == -1:
		print("  FAIL [T252.6.3]: whisper_vfx.gd _draw 缺 L3 EDGE_HIGHLIGHT")
		quit(1); return
	passed += 1
	print("  [T252.6.3] whisper_vfx.gd _draw 含 L3 EDGE_HIGHLIGHT (OK)")

	# ===== T252.6.4 L4 CORE_DOT =====
	total += 1
	if draw_body.find("L4 CORE_DOT") == -1:
		print("  FAIL [T252.6.4]: whisper_vfx.gd _draw 缺 L4 CORE_DOT")
		quit(1); return
	passed += 1
	print("  [T252.6.4] whisper_vfx.gd _draw 含 L4 CORE_DOT (OK)")

	# ===== T252.6.5 L5 HIT_FLASH =====
	total += 1
	if draw_body.find("L5 HIT_FLASH") == -1 or draw_body.find("HIT_FLASH_BASE_RADIUS") == -1:
		print("  FAIL [T252.6.5]: whisper_vfx.gd _draw 缺 L5 HIT_FLASH")
		quit(1); return
	passed += 1
	print("  [T252.6.5] whisper_vfx.gd _draw 含 L5 HIT_FLASH (OK)")

	# =================================================================
	# T252.7 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T252.7 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T252.7.1 CHANGELOG.md 含 #171 段 =====
	total += 1
	if src_changelog.find("## #171 — T252") == -1 and src_changelog_archive.find("## #171 — T252") == -1:
		print("  FAIL [T252.7.1]: CHANGELOG.md 缺 #171 段")
		quit(1); return
	passed += 1
	print("  [T252.7.1] CHANGELOG.md 含 #171 段 (OK)")

	# ===== T252.7.2 ROADMAP.md 顶部时间戳 =====
	total += 1
	if src_roadmap.find("#171") == -1:
		print("  FAIL [T252.7.2]: ROADMAP.md 顶部缺 #171 时间戳")
		quit(1); return
	passed += 1
	print("  [T252.7.2] ROADMAP.md 顶部含 #171 时间戳 (OK)")

	print("=== T252 #171 §9.6 已知 fragility 扩展 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
