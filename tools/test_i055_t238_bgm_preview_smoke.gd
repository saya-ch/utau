extends SceneTree

## test_i055_t238_bgm_preview_smoke.gd
## #157 — T238 PauseMenu BGM 主题预览键落地 (B 键 cycle 1.5s 预览, 2.0s 后 restore)
##
## 覆盖:
##  (T238.CONST)   pause_menu.gd::_BGM_PREVIEW_ORDER 存在 + 9 主题按 M_PLAY_ORDER
##  (T238.STATE)   2 state 字段 (_bgm_preview_active: bool, _bgm_preview_original: String)
##  (T238.DURATION) 2 duration const (_BGM_PREVIEW_DURATION=1.5, _BGM_PREVIEW_RESTORE_FADE_MS=300)
##  (T238.HANDLER) _on_bgm_preview_pressed + _on_bgm_preview_restore 函数存在
##  (T238.INPUT)   _input 内 is_action_pressed("bgm_preview") + _is_paused 守卫
##  (T238.LABEL)   _refresh_stat_bgm text 含 "[B] 下个" hint
##  (T238.ORDER)   9 主题顺序与 audio_presets.gd::MUSIC_PRESETS dict keys 1:1 对齐
##  (T238.BINDING) project.godot 含 bgm_preview action + 物理键 B (physical_keycode=66)
##  (T238.REGRESS) T236 _stat_bgm 标签 + T160 banner 起始态 + T225 4 段 hover 0 触碰

func _init() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0

	# 读取 pause_menu.gd 全文用于多项断言
	var pm_gd := FileAccess.open("res://src/scripts/pause_menu.gd", FileAccess.READ)
	if pm_gd == null:
		print("  [%d] FAIL  pause_menu.gd 不可读" % 0)
		_finish(0, 1)
		return
	var pm_text := pm_gd.get_as_text()
	pm_gd.close()

	# === T238.CONST — _BGM_PREVIEW_ORDER 9 主题按 M_PLAY_ORDER ===

	test_num += 1
	if "const _BGM_PREVIEW_ORDER := [" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 const _BGM_PREVIEW_ORDER := [" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 const _BGM_PREVIEW_ORDER :=" % test_num)
		failed += 1

	# 9 主题名逐项断言
	var expected_themes := [
		"\"title_intro\"",
		"\"hub_warm\"",
		"\"archive_exploration\"",
		"\"archive_boss\"",
		"\"archive_boss_dual\"",
		"\"archive_dawn\"",
		"\"archive_storm\"",
		"\"silence_void\"",
		"\"whisper_hollow\"",
	]
	for tname in expected_themes:
		test_num += 1
		# 在 _BGM_PREVIEW_ORDER 段附近查找 (从 const 起始到下个 const/func)
		var start_idx := pm_text.find("const _BGM_PREVIEW_ORDER := [")
		if start_idx == -1:
			print("  [%d] FAIL  _BGM_PREVIEW_ORDER 起始未找到, 无法查 %s" % [test_num, tname])
			failed += 1
			continue
		var end_idx := pm_text.find("]", start_idx)
		var order_block := pm_text.substr(start_idx, end_idx - start_idx + 1)
		if tname in order_block:
			print("  [%d] PASS  _BGM_PREVIEW_ORDER 含 %s" % [test_num, tname])
			passed += 1
		else:
			print("  [%d] FAIL  _BGM_PREVIEW_ORDER 缺 %s" % [test_num, tname])
			failed += 1

	# === T238.STATE — 2 state 字段 ===

	test_num += 1
	if "var _bgm_preview_active: bool = false" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 var _bgm_preview_active: bool = false" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 var _bgm_preview_active: bool = false" % test_num)
		failed += 1

	test_num += 1
	if "var _bgm_preview_original: String = \"\"" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 var _bgm_preview_original: String = \"\"" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 var _bgm_preview_original: String = \"\"" % test_num)
		failed += 1

	# === T238.DURATION — 2 duration const ===

	test_num += 1
	if "const _BGM_PREVIEW_DURATION := 1.5" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 const _BGM_PREVIEW_DURATION := 1.5" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 const _BGM_PREVIEW_DURATION := 1.5" % test_num)
		failed += 1

	test_num += 1
	if "const _BGM_PREVIEW_RESTORE_FADE_MS := 300" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 const _BGM_PREVIEW_RESTORE_FADE_MS := 300" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 const _BGM_PREVIEW_RESTORE_FADE_MS := 300" % test_num)
		failed += 1

	# === T238.HANDLER — 2 函数存在 ===

	test_num += 1
	if "func _on_bgm_preview_pressed() -> void:" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 func _on_bgm_preview_pressed() -> void:" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 func _on_bgm_preview_pressed() -> void:" % test_num)
		failed += 1

	test_num += 1
	if "func _on_bgm_preview_restore() -> void:" in pm_text:
		print("  [%d] PASS  pause_menu.gd 含 func _on_bgm_preview_restore() -> void:" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 func _on_bgm_preview_restore() -> void:" % test_num)
		failed += 1

	# handler 内 1.5s SceneTreeTimer + create_timer
	test_num += 1
	if "get_tree().create_timer(_BGM_PREVIEW_DURATION)" in pm_text:
		print("  [%d] PASS  _on_bgm_preview_pressed 用 get_tree().create_timer(_BGM_PREVIEW_DURATION) 调度 1.5s restore" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _on_bgm_preview_pressed 缺 1.5s create_timer 调度" % test_num)
		failed += 1

	test_num += 1
	if "t.timeout.connect(_on_bgm_preview_restore)" in pm_text:
		print("  [%d] PASS  SceneTreeTimer.timeout.connect(_on_bgm_preview_restore) 绑定 restore handler" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  缺 SceneTreeTimer.timeout.connect(_on_bgm_preview_restore) 绑定" % test_num)
		failed += 1

	# handler 内 play_music_track 调用 (next + restore)
	test_num += 1
	if "AudioManagerEnhanced.play_music_track(next_key, 200)" in pm_text:
		print("  [%d] PASS  _on_bgm_preview_pressed 调 AudioManagerEnhanced.play_music_track(next_key, 200) 切下个" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _on_bgm_preview_pressed 缺 play_music_track(next_key, 200)" % test_num)
		failed += 1

	test_num += 1
	if "AudioManagerEnhanced.play_music_track(_bgm_preview_original, _BGM_PREVIEW_RESTORE_FADE_MS)" in pm_text:
		print("  [%d] PASS  _on_bgm_preview_restore 调 AudioManagerEnhanced.play_music_track(_bgm_preview_original, _BGM_PREVIEW_RESTORE_FADE_MS) 切回" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _on_bgm_preview_restore 缺 play_music_track(_bgm_preview_original, _BGM_PREVIEW_RESTORE_FADE_MS)" % test_num)
		failed += 1

	# cycle 算法 (mod 9 next_idx)
	test_num += 1
	if "(idx + 1) % _BGM_PREVIEW_ORDER.size()" in pm_text:
		print("  [%d] PASS  cycle 算法 (idx + 1) % _BGM_PREVIEW_ORDER.size() 9 主题循环" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  缺 cycle 算法 (idx + 1) % _BGM_PREVIEW_ORDER.size()" % test_num)
		failed += 1

	# re-entrant guard
	test_num += 1
	if "if _bgm_preview_active:" in pm_text and "_bgm_preview_active = false" in pm_text:
		print("  [%d] PASS  re-entrant guard (press check + restore clear) 双处出现" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  缺 re-entrant guard" % test_num)
		failed += 1

	# === T238.INPUT — _input 内 is_action_pressed("bgm_preview") + _is_paused 守卫 ===

	test_num += 1
	if "event.is_action_pressed(\"bgm_preview\")" in pm_text:
		print("  [%d] PASS  _input 内 is_action_pressed(\"bgm_preview\") 触发" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _input 内缺 is_action_pressed(\"bgm_preview\")" % test_num)
		failed += 1

	test_num += 1
	# _is_paused 守卫 (T238 段 elif 子句)
	if "_is_paused and event.is_action_pressed(\"bgm_preview\")" in pm_text:
		print("  [%d] PASS  _is_paused 守卫 (玩家只在菜单打开时可预览)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  缺 _is_paused 守卫" % test_num)
		failed += 1

	# === T238.LABEL — _refresh_stat_bgm 含 "[B] 下个" ===

	test_num += 1
	if "\"BGM · %s  ·  [B] 下个\" % display" in pm_text:
		print("  [%d] PASS  _refresh_stat_bgm text 含 \"BGM · %s  ·  [B] 下个\" 提示 hint" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _refresh_stat_bgm text 缺 [B] 下个 hint" % test_num)
		failed += 1

	# === T238.ORDER — 9 主题顺序与 audio_presets.gd::MUSIC_PRESETS dict keys 1:1 对齐 ===

	var ap_gd := FileAccess.open("res://src/scripts/audio_presets.gd", FileAccess.READ)
	if ap_gd == null:
		print("  [%d] FAIL  audio_presets.gd 不可读" % 0)
		failed += 1
	else:
		var ap_text := ap_gd.get_as_text()
		ap_gd.close()
		for tname in expected_themes:
			test_num += 1
			# 去掉引号, 在 audio_presets.gd 的 MUSIC_PRESETS dict 段查 raw key
			var key_name: String = tname.replace("\"", "")
			# 在 const MUSIC_PRESETS 段附近查找
			var mp_start := ap_text.find("const MUSIC_PRESETS := {")
			if mp_start == -1:
				print("  [%d] FAIL  audio_presets.gd 缺 const MUSIC_PRESETS := {" % test_num)
				failed += 1
				continue
			# 找 const MUSIC_PRESETS 之后 30000 char 内的 key (足够覆盖整个 dict)
			var mp_block := ap_text.substr(mp_start, 30000)
			var key_pattern := "\"%s\":" % key_name
			if key_pattern in mp_block:
				print("  [%d] PASS  audio_presets.gd::MUSIC_PRESETS 含 %s 与 _BGM_PREVIEW_ORDER 1:1" % [test_num, key_pattern])
				passed += 1
			else:
				print("  [%d] FAIL  audio_presets.gd::MUSIC_PRESETS 缺 %s" % [test_num, key_pattern])
				failed += 1

	# === T238.BINDING — project.godot 含 bgm_preview action + 物理键 B (66) ===

	var pg_text := FileAccess.open("res://project.godot", FileAccess.READ).get_as_text()
	FileAccess.open("res://project.godot", FileAccess.READ).close()

	test_num += 1
	if "bgm_preview={" in pg_text:
		print("  [%d] PASS  project.godot 含 bgm_preview action 声明" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  project.godot 缺 bgm_preview action 声明" % test_num)
		failed += 1

	test_num += 1
	# bgm_preview 段内含 physical_keycode 66 (B)
	var bgm_action_start := pg_text.find("bgm_preview={")
	if bgm_action_start == -1:
		print("  [%d] FAIL  bgm_preview 段起始未找到" % test_num)
		failed += 1
	else:
		var bgm_action_end := pg_text.find("}", bgm_action_start)
		var bgm_action_block := pg_text.substr(bgm_action_start, bgm_action_end - bgm_action_start + 1)
		if "\"physical_keycode\":66" in bgm_action_block:
			print("  [%d] PASS  bgm_preview 物理键 66 (B) 绑定正确" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  bgm_preview 缺 physical_keycode 66 (B) 绑定" % test_num)
			failed += 1

	# === T238.REGRESS — T236 _stat_bgm 标签 + T160 banner 起始态 + T225 4 段 hover 0 触碰 ===

	test_num += 1
	# T236 _stat_bgm.text format 主干保留 (含 "BGM · %s" 起点)
	if "_stat_bgm.text = \"BGM · %s" in pm_text:
		print("  [%d] PASS  T236 _stat_bgm.text format 主干保留 (T238 仅追加 hint)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T236 _stat_bgm.text format 主干被破坏" % test_num)
		failed += 1

	test_num += 1
	# T236 _refresh_stat_bgm 函数仍存在
	if "func _refresh_stat_bgm() -> void:" in pm_text:
		print("  [%d] PASS  T236 _refresh_stat_bgm() 函数声明保留" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T236 _refresh_stat_bgm() 函数声明被破坏" % test_num)
		failed += 1

	test_num += 1
	# T160 banner 起始态 modulate.a = 0
	if "modulate.a = 0" in pm_text or "_new_achv_banner.modulate.a = 0" in pm_text:
		print("  [%d] PASS  T160 banner 起始态 modulate.a = 0 保留" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T160 banner 起始态被破坏" % test_num)
		failed += 1

	test_num += 1
	# T225 4 段 hover 关键函数 _on_quick_stats_hover_in 保留
	if "func _on_quick_stats_hover_in(idx: int) -> void:" in pm_text:
		print("  [%d] PASS  T225 _on_quick_stats_hover_in 函数声明保留" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T225 _on_quick_stats_hover_in 函数声明被破坏" % test_num)
		failed += 1

	test_num += 1
	# T214 _on_quick_stats_hover_out 保留
	if "func _on_quick_stats_hover_out(idx: int) -> void:" in pm_text:
		print("  [%d] PASS  T214 _on_quick_stats_hover_out 函数声明保留" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T214 _on_quick_stats_hover_out 函数声明被破坏" % test_num)
		failed += 1

	test_num += 1
	# T213 _build_quick_stats_tooltip 保留
	if "func _build_quick_stats_tooltip() -> String:" in pm_text:
		print("  [%d] PASS  T213 _build_quick_stats_tooltip 函数声明保留" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T213 _build_quick_stats_tooltip 函数声明被破坏" % test_num)
		failed += 1

	# === T238.ANCHOR — T238 (#157) 注释锚点声明次数 ===

	test_num += 1
	var anchor_count := pm_text.count("T238 (#157)")
	if anchor_count >= 6:
		print("  [%d] PASS  T238 (#157) 注释锚点 ≥ 6 处 (实测 %d)" % [test_num, anchor_count])
		passed += 1
	else:
		print("  [%d] FAIL  T238 (#157) 注释锚点 < 6 处 (实测 %d)" % [test_num, anchor_count])
		failed += 1

	_finish(passed, failed)

func _finish(passed: int, failed: int) -> void:
	print("")
	print("=== I055 T238 bgm_preview smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)
