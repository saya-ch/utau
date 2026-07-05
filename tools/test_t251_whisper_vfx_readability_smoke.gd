extends SceneTree
## T251 (#169) — Whisper VFX 玩家可读性强化 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t251_whisper_vfx_readability_smoke.gd
##
## T251: Whisper VFX 玩家可读性强化 (polish 链 28→29 环)
##   - whisper_vfx.gd 加 1 层 EDGE_HIGHLIGHT (1.04×R 1px 描边) 让 constant 球
##     在深背景边缘可读, 0 半径扩散 (6 verb 唯一不扩散几何保留)
##   - flash_hit(target_pos) 从 pass 占位 → 真正实现: append _hit_flashes,
##     _process 老化, _draw 渲染 Warm Parchment 小圆 0.15s 衰减
##   - player.gd _on_whisper_hit 从 pass → 调 _current_whisper_vfx.flash_hit,
##     仿 _on_wave_hit 模式 (5+1 verb hit 反馈同语义)
##   - 4 个新 const (EDGE_HIGHLIGHT_RADIUS_RATIO, EDGE_HIGHLIGHT_ALPHA,
##     HIT_FLASH_LIFETIME, HIT_FLASH_BASE_RADIUS)
##   - 1 个新 var (_hit_flashes: Array)
##   - 1 个新 draw_arc (EDGE_HIGHLIGHT 层) + 1 个新 draw_circle loop (HIT_FLASH)

func _initialize() -> void:
	print("=== T251 #169 Whisper VFX 玩家可读性强化 smoke test ===")

	var src_whisper_vfx := _read_file("res://src/scripts/whisper_vfx.gd")
	var src_player := _read_file("res://src/scripts/player.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T251.1-4 — whisper_vfx.gd 新 const 4 断言
	# =================================================================
	print("--- T251.1-4 — whisper_vfx.gd 新 const 4 断言 ---")

	# ===== T251.1.EDGE_HIGHLIGHT_RADIUS_RATIO — 1.04 =====
	total += 1
	if src_whisper_vfx.find("EDGE_HIGHLIGHT_RADIUS_RATIO") == -1 or src_whisper_vfx.find("1.04") == -1:
		print("  FAIL [T251.1.1]: whisper_vfx.gd 缺 EDGE_HIGHLIGHT_RADIUS_RATIO=1.04 const")
		quit(1); return
	passed += 1
	print("  [T251.1.1] whisper_vfx.gd 含 EDGE_HIGHLIGHT_RADIUS_RATIO=1.04 const (OK)")

	# ===== T251.2.EDGE_HIGHLIGHT_ALPHA — 0.40 =====
	total += 1
	if src_whisper_vfx.find("EDGE_HIGHLIGHT_ALPHA") == -1 or src_whisper_vfx.find("0.40") == -1:
		print("  FAIL [T251.2.1]: whisper_vfx.gd 缺 EDGE_HIGHLIGHT_ALPHA=0.40 const")
		quit(1); return
	passed += 1
	print("  [T251.2.1] whisper_vfx.gd 含 EDGE_HIGHLIGHT_ALPHA=0.40 const (OK)")

	# ===== T251.3.HIT_FLASH_LIFETIME — 0.15 =====
	total += 1
	if src_whisper_vfx.find("HIT_FLASH_LIFETIME") == -1 or src_whisper_vfx.find("0.15") == -1:
		print("  FAIL [T251.3.1]: whisper_vfx.gd 缺 HIT_FLASH_LIFETIME=0.15 const")
		quit(1); return
	passed += 1
	print("  [T251.3.1] whisper_vfx.gd 含 HIT_FLASH_LIFETIME=0.15 const (OK)")

	# ===== T251.4.HIT_FLASH_BASE_RADIUS — 2.0 =====
	total += 1
	if src_whisper_vfx.find("HIT_FLASH_BASE_RADIUS") == -1 or src_whisper_vfx.find("2.0") == -1:
		print("  FAIL [T251.4.1]: whisper_vfx.gd 缺 HIT_FLASH_BASE_RADIUS=2.0 const")
		quit(1); return
	passed += 1
	print("  [T251.4.1] whisper_vfx.gd 含 HIT_FLASH_BASE_RADIUS=2.0 const (OK)")

	# =================================================================
	# T251.5-8 — whisper_vfx.gd 新 var + 新 _draw 层 4 断言
	# =================================================================
	print("--- T251.5-8 — whisper_vfx.gd 新 var + 新 _draw 层 4 断言 ---")

	# ===== T251.5._HIT_FLASHES_VAR — _hit_flashes: Array =====
	total += 1
	if src_whisper_vfx.find("_hit_flashes") == -1 or src_whisper_vfx.find("Array") == -1:
		print("  FAIL [T251.5.1]: whisper_vfx.gd 缺 _hit_flashes: Array var")
		quit(1); return
	passed += 1
	print("  [T251.5.1] whisper_vfx.gd 含 _hit_flashes: Array var (OK)")

	# ===== T251.6.EDGE_HIGHLIGHT_DRAW_ARC — 1.04×R draw_arc =====
	total += 1
	if src_whisper_vfx.find("EDGE_HIGHLIGHT_RADIUS_RATIO") == -1 or src_whisper_vfx.find("draw_arc") == -1:
		print("  FAIL [T251.6.1]: whisper_vfx.gd _draw 缺 EDGE_HIGHLIGHT draw_arc 层")
		quit(1); return
	passed += 1
	print("  [T251.6.1] whisper_vfx.gd _draw 含 EDGE_HIGHLIGHT draw_arc 层 (OK)")

	# ===== T251.7.HIT_FLASH_DRAW_LOOP — _hit_flashes 遍历 draw_circle =====
	total += 1
	if src_whisper_vfx.find("for h in _hit_flashes:") == -1 or src_whisper_vfx.find("to_local") == -1:
		print("  FAIL [T251.7.1]: whisper_vfx.gd _draw 缺 HIT_FLASH draw_circle loop (for h in _hit_flashes + to_local)")
		quit(1); return
	passed += 1
	print("  [T251.7.1] whisper_vfx.gd _draw 含 HIT_FLASH draw_circle loop (for h in _hit_flashes + to_local) (OK)")

	# ===== T251.8.FLASH_HIT_IMPL — flash_hit 不再是 pass =====
	total += 1
	# 找 flash_hit(target_pos) 函数的开始位置, 然后检查函数体内 50 行内
	# 是否有 _hit_flashes.append 调用, 而不是单纯的 pass
	var flash_hit_idx := src_whisper_vfx.find("func flash_hit(target_pos: Vector2) -> void:")
	if flash_hit_idx == -1:
		print("  FAIL [T251.8.1]: whisper_vfx.gd 缺 flash_hit(target_pos) 函数定义")
		quit(1); return
	var flash_hit_body := src_whisper_vfx.substr(flash_hit_idx, 800)
	if flash_hit_body.find("_hit_flashes.append") == -1 or flash_hit_body.find("HIT_FLASH_LIFETIME") == -1:
		print("  FAIL [T251.8.2]: whisper_vfx.gd flash_hit 仍是 pass 占位 (缺 _hit_flashes.append)")
		quit(1); return
	passed += 1
	print("  [T251.8.1] whisper_vfx.gd flash_hit(target_pos) 已实现 (_hit_flashes.append + HIT_FLASH_LIFETIME) (OK)")

	# =================================================================
	# T251.9-12 — player.gd _on_whisper_hit 实现 4 断言
	# =================================================================
	print("--- T251.9-12 — player.gd _on_whisper_hit 实现 4 断言 ---")

	# ===== T251.9.ON_WHISPER_HIT_NOT_PASS — _on_whisper_hit 不再是 pass =====
	total += 1
	var on_whisper_hit_idx := src_player.find("func _on_whisper_hit(target: Node) -> void:")
	if on_whisper_hit_idx == -1:
		print("  FAIL [T251.9.1]: player.gd 缺 _on_whisper_hit(target) 函数定义")
		quit(1); return
	var on_whisper_hit_body := src_player.substr(on_whisper_hit_idx, 800)
	if on_whisper_hit_body.find("_current_whisper_vfx.flash_hit") == -1:
		print("  FAIL [T251.9.2]: player.gd _on_whisper_hit 仍是 pass 占位 (缺 _current_whisper_vfx.flash_hit 调用)")
		quit(1); return
	passed += 1
	print("  [T251.9.1] player.gd _on_whisper_hit(target) 已实现 (调 _current_whisper_vfx.flash_hit) (OK)")

	# ===== T251.10.IS_INSTANCE_VALID_GUARD — flash_hit 调用前 is_instance_valid 守卫 =====
	total += 1
	if on_whisper_hit_body.find("is_instance_valid") == -1:
		print("  FAIL [T251.10.1]: player.gd _on_whisper_hit 缺 is_instance_valid 守卫 (VFX 可能 0.15s 后 queue_free)")
		quit(1); return
	passed += 1
	print("  [T251.10.1] player.gd _on_whisper_hit 含 is_instance_valid 守卫 (OK)")

	# ===== T251.11.TARGET_GLOBAL_POSITION — flash_hit 传 target.global_position =====
	total += 1
	if on_whisper_hit_body.find("target.global_position") == -1:
		print("  FAIL [T251.11.1]: player.gd _on_whisper_hit 缺 target.global_position 转换")
		quit(1); return
	passed += 1
	print("  [T251.11.1] player.gd _on_whisper_hit 传 target.global_position (世界坐标 → VFX to_local) (OK)")

	# ===== T251.12.T251_ANCHOR_COMMENT — _on_whisper_hit 含 T251 注释 =====
	total += 1
	if on_whisper_hit_body.find("T251") == -1 or on_whisper_hit_body.find("#169") == -1:
		print("  FAIL [T251.12.1]: player.gd _on_whisper_hit 缺 T251 #169 任务锚点注释")
		quit(1); return
	passed += 1
	print("  [T251.12.1] player.gd _on_whisper_hit 含 T251 #169 任务锚点注释 (OK)")

	# =================================================================
	# T251.13-16 — 文档 4 断言
	# =================================================================
	print("--- T251.13-16 — 文档 4 断言 ---")

	# ===== T251.13.CHANGELOG_T251 — CHANGELOG T251 入口 =====
	total += 1
	if src_changelog.find("T251") == -1 or src_changelog.find("Whisper VFX") == -1:
		print("  FAIL [T251.13.1]: CHANGELOG.md 缺 T251 / Whisper VFX 入口")
		quit(1); return
	passed += 1
	print("  [T251.13.1] CHANGELOG.md 含 T251 / Whisper VFX 入口 (OK)")

	# ===== T251.14.ROADMAP_169 — ROADMAP #169 入口 =====
	total += 1
	if src_roadmap.find("#169") == -1 or src_roadmap.find("T251") == -1:
		print("  FAIL [T251.14.1]: ROADMAP.md 缺 #169 / T251 入口")
		quit(1); return
	passed += 1
	print("  [T251.14.1] ROADMAP.md 含 #169 / T251 入口 (OK)")

	# ===== T251.15.CHANGELOG_EDGE_HIGHLIGHT — CHANGELOG 含 EDGE_HIGHLIGHT =====
	total += 1
	if src_changelog.find("EDGE_HIGHLIGHT") == -1:
		print("  FAIL [T251.15.1]: CHANGELOG.md 缺 EDGE_HIGHLIGHT 描述")
		quit(1); return
	passed += 1
	print("  [T251.15.1] CHANGELOG.md 含 EDGE_HIGHLIGHT 描述 (OK)")

	# ===== T251.16.CHANGELOG_FLASH_HIT — CHANGELOG 含 flash_hit 实现 =====
	total += 1
	if src_changelog.find("flash_hit") == -1 or src_changelog.find("Warm Parchment") == -1:
		print("  FAIL [T251.16.1]: CHANGELOG.md 缺 flash_hit / Warm Parchment 描述")
		quit(1); return
	passed += 1
	print("  [T251.16.1] CHANGELOG.md 含 flash_hit / Warm Parchment 描述 (OK)")

	# =================================================================
	# 完成
	# =================================================================
	print("=== T251 #169 Whisper VFX 玩家可读性强化 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content
