extends SceneTree
## T243+T242+T244 (#161) — Combined smoke test for #161 iteration polish batch.
##
## 3 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t243_t242_t244_smoke.gd
##
## T243: ink_warden.gd 4 处标识符引用 source-only 整理为 preload (LIGHT-#160-1 闭环)
## T242: Sextuple Voice 6/6 成就 解锁提示音 chord 接入 (15 成就 milestone 闭环)
## T244: PauseMenu 6 verb hover 行 状态文字 (同步 T231+T240 节奏)

func _initialize() -> void:
	print("=== T243+T242+T244 #161 polish batch smoke test ===")

	var src_ink_warden := _read_file("res://src/scripts/ink_warden.gd")
	var src_repair_vfx := _read_file("res://src/scripts/repair_vfx.gd")
	var src_damage_number := _read_file("res://src/scripts/damage_number.gd")
	var src_audio_manager := _read_file("res://src/scripts/audio_manager_enhanced.gd")
	var src_achievements := _read_file("res://data/achievements.json")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")

	var passed := 0
	var total := 0

	# =================================================================
	# T243 — ink_warden.gd preload 重构 (LIGHT-#160-1 闭环)
	# =================================================================
	print("--- T243 — ink_warden.gd preload 重构 ---")

	# ===== T243.1.PRELOAD_RVFX — const RepairVFX = preload =====
	total += 1
	if src_ink_warden.find('const RepairVFX = preload("res://src/scripts/repair_vfx.gd")') == -1:
		print("  FAIL [T243.1.1]: ink_warden.gd 缺 const RepairVFX = preload")
		quit(1); return
	passed += 1
	print("  [T243.1.1] ink_warden.gd 含 const RepairVFX = preload (OK)")

	# ===== T243.2.PRELOAD_DNUM — const DamageNumber = preload =====
	total += 1
	if src_ink_warden.find('const DamageNumber = preload("res://src/scripts/damage_number.gd")') == -1:
		print("  FAIL [T243.2.1]: ink_warden.gd 缺 const DamageNumber = preload")
		quit(1); return
	passed += 1
	print("  [T243.2.1] ink_warden.gd 含 const DamageNumber = preload (OK)")

	# ===== T243.3.CALL_RVFX_NEW — RepairVFX.new() 调用仍 4+ 处 =====
	total += 1
	var rvfx_new_count := _count_occurrences(src_ink_warden, "RepairVFX.new()")
	if rvfx_new_count < 4:
		print("  FAIL [T243.3.1]: ink_warden.gd RepairVFX.new() 调用 < 4 处 (count=%d)" % rvfx_new_count)
		quit(1); return
	passed += 1
	print("  [T243.3.1] ink_warden.gd RepairVFX.new() 调用 = %d 处 (OK, 0 行为变化)" % rvfx_new_count)

	# ===== T243.4.CALL_DNUM_SPAWN — DamageNumber.spawn 调用仍存在 =====
	total += 1
	var dnum_spawn_count := _count_occurrences(src_ink_warden, "DamageNumber.spawn")
	if dnum_spawn_count < 3:
		print("  FAIL [T243.4.1]: ink_warden.gd DamageNumber.spawn 调用 < 3 处 (count=%d)" % dnum_spawn_count)
		quit(1); return
	passed += 1
	print("  [T243.4.1] ink_warden.gd DamageNumber.spawn 调用 = %d 处 (OK, 0 行为变化)" % dnum_spawn_count)

	# ===== T243.5.CALL_DNUM_KIND — DamageNumber.Kind 引用仍存在 =====
	total += 1
	if src_ink_warden.find("DamageNumber.Kind") == -1:
		print("  FAIL [T243.5.1]: ink_warden.gd 缺 DamageNumber.Kind 引用")
		quit(1); return
	passed += 1
	print("  [T243.5.1] ink_warden.gd 含 DamageNumber.Kind 引用 (OK)")

	# ===== T243.6.REPAIR_VFX_CLASS — class_name RepairVFX 仍存在 =====
	total += 1
	if src_repair_vfx.find("class_name RepairVFX") == -1:
		print("  FAIL [T243.6.1]: repair_vfx.gd 缺 class_name RepairVFX")
		quit(1); return
	passed += 1
	print("  [T243.6.1] repair_vfx.gd 含 class_name RepairVFX (OK, source 完整)")

	# ===== T243.7.DAMAGE_NUMBER_CLASS — class_name DamageNumber 仍存在 =====
	total += 1
	if src_damage_number.find("class_name DamageNumber") == -1:
		print("  FAIL [T243.7.1]: damage_number.gd 缺 class_name DamageNumber")
		quit(1); return
	passed += 1
	print("  [T243.7.1] damage_number.gd 含 class_name DamageNumber (OK, source 完整)")

	# ===== T243.8.ANCHOR — T243 锚点注释 =====
	total += 1
	if src_ink_warden.find("T243 (#161)") == -1:
		print("  FAIL [T243.8.1]: ink_warden.gd 缺 T243 (#161) 锚点注释")
		quit(1); return
	passed += 1
	print("  [T243.8.1] ink_warden.gd 含 T243 (#161) 锚点注释 (OK)")

	# =================================================================
	# T242 — Sextuple Voice 6/6 成就 解锁提示音 chord 接入
	# =================================================================
	print("--- T242 — Sextuple Voice 6/6 成就 解锁提示音 chord 接入 ---")

	# ===== T242.1.CHIME_PRESET — sextuple_voice chord_midi 配方 =====
	total += 1
	if src_audio_manager.find('"sextuple_voice": {"chord_midi": [60, 62, 64, 67, 69, 72]') == -1:
		print("  FAIL [T242.1.1]: audio_manager_enhanced.gd 缺 sextuple_voice chord_midi 配方")
		quit(1); return
	passed += 1
	print("  [T242.1.1] audio_manager_enhanced.gd 含 sextuple_voice chord_midi (OK)")

	# ===== T242.2.CHIME_DURATION — duration 0.65 =====
	total += 1
	if src_audio_manager.find('"sextuple_voice": {"chord_midi": [60, 62, 64, 67, 69, 72], "duration": 0.65') == -1:
		print("  FAIL [T242.2.1]: sextuple_voice duration 缺 0.65s")
		quit(1); return
	passed += 1
	print("  [T242.2.1] sextuple_voice duration = 0.65s (OK)")

	# ===== T242.3.BGM_HINT — ACHIEVEMENT_BGM_HINT sextuple_voice =====
	total += 1
	if src_audio_manager.find('"sextuple_voice": "archive_dawn"') == -1:
		print("  FAIL [T242.3.1]: ACHIEVEMENT_BGM_HINT 缺 sextuple_voice: archive_dawn")
		quit(1); return
	passed += 1
	print("  [T242.3.1] ACHIEVEMENT_BGM_HINT 含 sextuple_voice: archive_dawn (OK)")

	# ===== T242.4.ACHIEVEMENT — achievements.json sextuple_voice =====
	total += 1
	if src_achievements.find('"id": "sextuple_voice"') == -1:
		print("  FAIL [T242.4.1]: achievements.json 缺 sextuple_voice 成就")
		quit(1); return
	passed += 1
	print("  [T242.4.1] achievements.json 含 sextuple_voice 成就 (OK)")

	# ===== T242.5.PRE_WARM — pre-warm 15 注释 =====
	total += 1
	if src_audio_manager.find("Pre-warm 15 per-achievement unique chimes") == -1:
		print("  FAIL [T242.5.1]: audio_manager_enhanced.gd pre-warm 注释 缺 15")
		quit(1); return
	passed += 1
	print("  [T242.5.1] audio_manager_enhanced.gd pre-warm 注释 15 (OK)")

	# ===== T242.6.ANCHOR — T242 锚点注释 =====
	total += 1
	if src_audio_manager.find("T242 (#161)") == -1:
		print("  FAIL [T242.6.1]: audio_manager_enhanced.gd 缺 T242 (#161) 锚点注释")
		quit(1); return
	passed += 1
	print("  [T242.6.1] audio_manager_enhanced.gd 含 T242 (#161) 锚点注释 (OK)")

	# =================================================================
	# T244 — PauseMenu 6 verb hover 行 状态文字
	# =================================================================
	print("--- T244 — PauseMenu 6 verb hover 行 状态文字 ---")

	# ===== T244.1.CONST — _VERB_ROW_HOVER_FADE_DURATION = 0.12 =====
	total += 1
	if src_pause_menu.find("const _VERB_ROW_HOVER_FADE_DURATION := 0.12") == -1:
		print("  FAIL [T244.1.1]: pause_menu.gd 缺 _VERB_ROW_HOVER_FADE_DURATION 0.12")
		quit(1); return
	passed += 1
	print("  [T244.1.1] pause_menu.gd 含 _VERB_ROW_HOVER_FADE_DURATION 0.12 (OK)")

	# ===== T244.2.CONST_FONT_COLOR — _VERB_ROW_HOVER_FONT_COLOR =====
	total += 1
	if src_pause_menu.find("const _VERB_ROW_HOVER_FONT_COLOR := Color(1.0, 0.96, 0.88, 1.0)") == -1:
		print("  FAIL [T244.2.1]: pause_menu.gd 缺 _VERB_ROW_HOVER_FONT_COLOR")
		quit(1); return
	passed += 1
	print("  [T244.2.1] pause_menu.gd 含 _VERB_ROW_HOVER_FONT_COLOR (OK)")

	# ===== T244.3.CONST_MODULATE — _VERB_ROW_HOVER_MODULATE =====
	total += 1
	if src_pause_menu.find("const _VERB_ROW_HOVER_MODULATE := Color(1.15, 1.15, 1.15, 1.0)") == -1:
		print("  FAIL [T244.3.1]: pause_menu.gd 缺 _VERB_ROW_HOVER_MODULATE")
		quit(1); return
	passed += 1
	print("  [T244.3.1] pause_menu.gd 含 _VERB_ROW_HOVER_MODULATE (OK)")

	# ===== T244.4.HANDLER_IN — _on_verb_row_hover_in 函数 =====
	total += 1
	if src_pause_menu.find("func _on_verb_row_hover_in() -> void:") == -1:
		print("  FAIL [T244.4.1]: pause_menu.gd 缺 _on_verb_row_hover_in 函数")
		quit(1); return
	passed += 1
	print("  [T244.4.1] pause_menu.gd 含 _on_verb_row_hover_in 函数 (OK)")

	# ===== T244.5.HANDLER_OUT — _on_verb_row_hover_out 函数 =====
	total += 1
	if src_pause_menu.find("func _on_verb_row_hover_out() -> void:") == -1:
		print("  FAIL [T244.5.1]: pause_menu.gd 缺 _on_verb_row_hover_out 函数")
		quit(1); return
	passed += 1
	print("  [T244.5.1] pause_menu.gd 含 _on_verb_row_hover_out 函数 (OK)")

	# ===== T244.6.CONNECT_STAT — _stat_abilities mouse_entered.connect =====
	total += 1
	if src_pause_menu.find("_stat_abilities.mouse_entered.connect(_on_verb_row_hover_in)") == -1:
		print("  FAIL [T244.6.1]: pause_menu.gd 缺 _stat_abilities mouse_entered connect")
		quit(1); return
	passed += 1
	print("  [T244.6.1] pause_menu.gd 含 _stat_abilities mouse_entered connect (OK)")

	# ===== T244.7.CONNECT_PROFILE — _profile_abilities mouse_entered.connect =====
	total += 1
	if src_pause_menu.find("_profile_abilities.mouse_entered.connect(_on_verb_row_hover_in)") == -1:
		print("  FAIL [T244.7.1]: pause_menu.gd 缺 _profile_abilities mouse_entered connect")
		quit(1); return
	passed += 1
	print("  [T244.7.1] pause_menu.gd 含 _profile_abilities mouse_entered connect (OK)")

	# ===== T244.8.TWEEN_FONT_COLOR — font_color tween theme_override path =====
	total += 1
	if src_pause_menu.find('tween_property(target, "theme_override_colors/font_color", _VERB_ROW_HOVER_FONT_COLOR') == -1:
		print("  FAIL [T244.8.1]: pause_menu.gd 缺 theme_override_colors/font_color tween")
		quit(1); return
	passed += 1
	print("  [T244.8.1] pause_menu.gd 含 theme_override_colors/font_color tween (OK)")

	# ===== T244.9.TWEEN_MODULATE — modulate RGB additive brighten tween =====
	total += 1
	if src_pause_menu.find('tween_property(target, "modulate", _VERB_ROW_HOVER_MODULATE') == -1:
		print("  FAIL [T244.9.1]: pause_menu.gd 缺 modulate additive brighten tween")
		quit(1); return
	passed += 1
	print("  [T244.9.1] pause_menu.gd 含 modulate additive brighten tween (OK)")

	# ===== T244.10.ANCHOR — T244 锚点注释 =====
	total += 1
	if src_pause_menu.find("T244 (#161)") == -1:
		print("  FAIL [T244.10.1]: pause_menu.gd 缺 T244 (#161) 锚点注释")
		quit(1); return
	passed += 1
	print("  [T244.10.1] pause_menu.gd 含 T244 (#161) 锚点注释 (OK)")

	# ===== T244.11.NO_REGRESSION — T199 (#116) 锚点仍存在 (5 verb 兼容) =====
	total += 1
	if src_pause_menu.find("T199 (#116)") == -1:
		print("  FAIL [T244.11.1]: pause_menu.gd 缺 T199 (#116) 锚点 (5 verb 兼容 regression)")
		quit(1); return
	passed += 1
	print("  [T244.11.1] pause_menu.gd 含 T199 (#116) 锚点 (5 verb 兼容 OK)")

	# ===== T244.12.NO_REGRESSION_F013E — F013.E (#159) 锚点仍存在 (6 verb 兼容) =====
	total += 1
	if src_pause_menu.find("F013.E (#159)") == -1:
		print("  FAIL [T244.12.1]: pause_menu.gd 缺 F013.E (#159) 锚点 (6 verb 兼容 regression)")
		quit(1); return
	passed += 1
	print("  [T244.12.1] pause_menu.gd 含 F013.E (#159) 锚点 (6 verb 兼容 OK)")

	# =================================================================
	# 完成
	# =================================================================
	print("=== T243+T242+T244 #161 polish batch smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _count_occurrences(haystack: String, needle: String) -> int:
	if needle == "":
		return 0
	var count := 0
	var sp := 0
	while true:
		var idx := haystack.find(needle, sp)
		if idx == -1:
			break
		count += 1
		sp = idx + needle.length()
	return count

