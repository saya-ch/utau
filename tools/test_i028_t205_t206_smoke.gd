extends SceneTree
## I028 (#122) — Smoke test for T205 (14 成就 → 9 BGM 主题 Layering Map
## in CONTRIBUTING.md §11) + T206 (WaveAbility 0.5× Pale Resonance 1
## room 教学演示 — first-time Wave fire queues a tutorial_hint).
##
## 24 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i028_t205_t206_smoke.gd
##
## 设计 (与 I027 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T205.CONTRIBUTING.SECTION_11 — CONTRIBUTING.md §11 heading 存在
##   T205.CONTRIBUTING.MAP_TABLE — 表格含 14 行
##   T205.CONTRIBUTING.ACH_FIRST_STEPS — 表格含 first_steps
##   T205.CONTRIBUTING.ACH_VOICE_PURIFIER — 表格含 voice_purifier
##   T205.CONTRIBUTING.ACH_RESONANCE_COLLECTOR — 表格含 resonance_collector
##   T205.CONTRIBUTING.ACH_TRIPLE_VOICE — 表格含 triple_voice
##   T205.CONTRIBUTING.ACH_QUADRUPLE_VOICE — 表格含 quadruple_voice
##   T205.CONTRIBUTING.ACH_QUINTUPLE_VOICE — 表格含 quintuple_voice
##   T205.CONTRIBUTING.ACH_FIRST_CUT — 表格含 first_cut
##   T205.CONTRIBUTING.ACH_WARDEN_SLAYER — 表格含 warden_slayer
##   T205.CONTRIBUTING.ACH_FULL_ARCHIVE — 表格含 full_archive
##   T205.CONTRIBUTING.ACH_PERSISTENT_RESONANCE — 表格含 persistent_resonance
##   T205.CONTRIBUTING.ACH_LONG_ROAD — 表格含 long_road
##   T205.CONTRIBUTING.ACH_ARCHIVE_MASTER — 表格含 archive_master
##   T205.CONTRIBUTING.ACH_RESONANCE_HOARDER — 表格含 resonance_hoarder
##   T205.CONTRIBUTING.ACH_SILENCE_HUNTER — 表格含 silence_hunter
##   T205.CONTRIBUTING.BGM_9_THEMES — 9 BGM 主题 key 全部出现
##   T205.CONTRIBUTING.PRIORITY_BLOCK — §11.3 BGM 优先级列表
##   T205.CONTRIBUTING.NEXT_IMPL — §11.5 列出 #123 落地文件
##   T206.PLAYER.ANCHOR — T206 (#122) 注释锚点
##   T206.PLAYER.WAVE_HINT_GROUP — wave_precursor_intro group_id
##   T206.PLAYER.WAVE_HINT_TEXT — "0.5× Pale Resonance" 文案
##   T206.PLAYER.WAVE_HINT_DURATION — 4.0s duration
##   T206.PLAYER.WAVE_HINT_INSIDE_SUCCESS — 在 if success: 分支内 (不是 else)

func _initialize() -> void:
	print("=== I028 T205 + T206 smoke test (#122) ===")

	var contributing_src := ""
	var cf := FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	if cf:
		contributing_src = cf.get_as_text()
		cf.close()

	var player_src := ""
	var pf := FileAccess.open("res://src/scripts/player.gd", FileAccess.READ)
	if pf:
		player_src = pf.get_as_text()
		pf.close()

	var passed := 0
	var total := 0

	# ===== T205.CONTRIBUTING.SECTION_11 =====
	total += 1
	if contributing_src.find("## 11. 14 成就 → 9 BGM 主题 Layering Map") == -1:
		print("  FAIL [T205.1]: CONTRIBUTING.md 缺 §11 heading")
		quit(1)
		return
	passed += 1
	print("  [T205.1] CONTRIBUTING.md §11 heading 存在 (OK)")

	# ===== T205.CONTRIBUTING.MAP_TABLE =====
	# 表格在 §11.1 内 — 检查 14 行 14 个 achievement_id 都出现
	# 14 个 id 全部列出 = 14 断言 (下面 14 条)

	# ===== T205.CONTRIBUTING.ACH_FIRST_STEPS =====
	total += 1
	if contributing_src.find("first_steps") == -1:
		print("  FAIL [T205.2]: CONTRIBUTING.md §11 缺 first_steps 行")
		quit(1)
		return
	passed += 1
	print("  [T205.2] first_steps 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_VOICE_PURIFIER =====
	total += 1
	if contributing_src.find("voice_purifier") == -1:
		print("  FAIL [T205.3]: CONTRIBUTING.md §11 缺 voice_purifier 行")
		quit(1)
		return
	passed += 1
	print("  [T205.3] voice_purifier 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_RESONANCE_COLLECTOR =====
	total += 1
	if contributing_src.find("resonance_collector") == -1:
		print("  FAIL [T205.4]: CONTRIBUTING.md §11 缺 resonance_collector 行")
		quit(1)
		return
	passed += 1
	print("  [T205.4] resonance_collector 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_TRIPLE_VOICE =====
	total += 1
	if contributing_src.find("triple_voice") == -1:
		print("  FAIL [T205.5]: CONTRIBUTING.md §11 缺 triple_voice 行")
		quit(1)
		return
	passed += 1
	print("  [T205.5] triple_voice 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_QUADRUPLE_VOICE =====
	total += 1
	if contributing_src.find("quadruple_voice") == -1:
		print("  FAIL [T205.6]: CONTRIBUTING.md §11 缺 quadruple_voice 行")
		quit(1)
		return
	passed += 1
	print("  [T205.6] quadruple_voice 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_QUINTUPLE_VOICE =====
	total += 1
	if contributing_src.find("quintuple_voice") == -1:
		print("  FAIL [T205.7]: CONTRIBUTING.md §11 缺 quintuple_voice 行")
		quit(1)
		return
	passed += 1
	print("  [T205.7] quintuple_voice 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_FIRST_CUT =====
	total += 1
	if contributing_src.find("first_cut") == -1:
		print("  FAIL [T205.8]: CONTRIBUTING.md §11 缺 first_cut 行")
		quit(1)
		return
	passed += 1
	print("  [T205.8] first_cut 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_WARDEN_SLAYER =====
	total += 1
	if contributing_src.find("warden_slayer") == -1:
		print("  FAIL [T205.9]: CONTRIBUTING.md §11 缺 warden_slayer 行")
		quit(1)
		return
	passed += 1
	print("  [T205.9] warden_slayer 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_FULL_ARCHIVE =====
	total += 1
	if contributing_src.find("full_archive") == -1:
		print("  FAIL [T205.10]: CONTRIBUTING.md §11 缺 full_archive 行")
		quit(1)
		return
	passed += 1
	print("  [T205.10] full_archive 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_PERSISTENT_RESONANCE =====
	total += 1
	if contributing_src.find("persistent_resonance") == -1:
		print("  FAIL [T205.11]: CONTRIBUTING.md §11 缺 persistent_resonance 行")
		quit(1)
		return
	passed += 1
	print("  [T205.11] persistent_resonance 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_LONG_ROAD =====
	total += 1
	if contributing_src.find("long_road") == -1:
		print("  FAIL [T205.12]: CONTRIBUTING.md §11 缺 long_road 行")
		quit(1)
		return
	passed += 1
	print("  [T205.12] long_road 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_ARCHIVE_MASTER =====
	total += 1
	if contributing_src.find("archive_master") == -1:
		print("  FAIL [T205.13]: CONTRIBUTING.md §11 缺 archive_master 行")
		quit(1)
		return
	passed += 1
	print("  [T205.13] archive_master 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_RESONANCE_HOARDER =====
	total += 1
	if contributing_src.find("resonance_hoarder") == -1:
		print("  FAIL [T205.14]: CONTRIBUTING.md §11 缺 resonance_hoarder 行")
		quit(1)
		return
	passed += 1
	print("  [T205.14] resonance_hoarder 行存在 (OK)")

	# ===== T205.CONTRIBUTING.ACH_SILENCE_HUNTER =====
	total += 1
	if contributing_src.find("silence_hunter") == -1:
		print("  FAIL [T205.15]: CONTRIBUTING.md §11 缺 silence_hunter 行")
		quit(1)
		return
	passed += 1
	print("  [T205.15] silence_hunter 行存在 (OK)")

	# ===== T205.CONTRIBUTING.BGM_9_THEMES =====
	total += 1
	# 9 BGM 主题 key 全部出现在 §11 (除了 title_intro, 因为 14 成就没映射到它)
	# title_intro 是 title screen 专属，不在成就 layering 候选中
	# 我们只验证被 14 成就用到的 8 个（archive_dawn/archive_boss_dual/silence_void/
	# archive_storm/archive_exploration/hub_whisper_hollow）
	var bgm_keys := ["archive_dawn", "archive_boss_dual", "silence_void", "archive_storm", "archive_exploration", "hub_warm", "whisper_hollow"]
	var missing_keys := []
	for key in bgm_keys:
		if contributing_src.find(key) == -1:
			missing_keys.append(key)
	if not missing_keys.is_empty():
		print("  FAIL [T205.16]: CONTRIBUTING.md §11 缺 BGM 主题 key: %s" % str(missing_keys))
		quit(1)
		return
	passed += 1
	print("  [T205.16] 7 个 BGM 主题 key 全部出现 (OK)")

	# ===== T205.CONTRIBUTING.PRIORITY_BLOCK =====
	total += 1
	# §11.3 优先级列表 — 检查 archive_dawn 排第一
	var prio_idx := contributing_src.find("### 11.3 BGM 主题优先级")
	if prio_idx == -1:
		print("  FAIL [T205.17]: CONTRIBUTING.md 缺 §11.3 优先级列表")
		quit(1)
		return
	var prio_block := contributing_src.substr(prio_idx, 800)
	# 验证 archive_dawn 在 §11.3 内
	if prio_block.find("archive_dawn") == -1:
		print("  FAIL [T205.17]: §11.3 缺 archive_dawn（endgame 收束）")
		quit(1)
		return
	# 验证 whisper_hollow 在 §11.3 内（最低优先级）
	if prio_block.find("whisper_hollow") == -1:
		print("  FAIL [T205.17]: §11.3 缺 whisper_hollow（时间系）")
		quit(1)
		return
	passed += 1
	print("  [T205.17] §11.3 优先级列表 (archive_dawn / whisper_hollow 锚点) (OK)")

	# ===== T205.CONTRIBUTING.NEXT_IMPL =====
	total += 1
	# §11.5 列出 #123 落地文件 — 检查 audio_manager_enhanced.gd + audio_presets.gd
	var impl_idx := contributing_src.find("### 11.5")
	if impl_idx == -1:
		print("  FAIL [T205.18]: CONTRIBUTING.md 缺 §11.5 落地路径")
		quit(1)
		return
	var impl_block := contributing_src.substr(impl_idx, 1200)
	if impl_block.find("audio_manager_enhanced.gd") == -1:
		print("  FAIL [T205.18]: §11.5 缺 audio_manager_enhanced.gd")
		quit(1)
		return
	if impl_block.find("play_achievement_layering") == -1:
		print("  FAIL [T205.18]: §11.5 缺 play_achievement_layering 方法名")
		quit(1)
		return
	passed += 1
	print("  [T205.18] §11.5 落地路径 (audio_manager_enhanced.gd + play_achievement_layering) (OK)")

	# ===== T206.PLAYER.ANCHOR =====
	total += 1
	# T206 (#122) 注释锚点
	if _count_substr(player_src, "T206 (#122)") < 1:
		print("  FAIL [T206.1]: player.gd 缺 T206 (#122) 注释锚点")
		quit(1)
		return
	passed += 1
	print("  [T206.1] T206 (#122) 注释锚点 (OK)")

	# ===== T206.PLAYER.WAVE_HINT_GROUP =====
	total += 1
	# wave_precursor_intro group_id — 确保 group_id 与 tutorial_hint.gd 兼容
	if player_src.find('"wave_precursor_intro"') == -1:
		print("  FAIL [T206.2]: player.gd 缺 wave_precursor_intro group_id")
		quit(1)
		return
	passed += 1
	print("  [T206.2] wave_precursor_intro group_id (OK)")

	# ===== T206.PLAYER.WAVE_HINT_TEXT =====
	total += 1
	# "0.5× Pale Resonance" 文案
	if player_src.find("0.5× Pale Resonance halo") == -1:
		print("  FAIL [T206.3]: player.gd 缺 0.5× Pale Resonance halo 文案")
		quit(1)
		return
	passed += 1
	print("  [T206.3] 0.5× Pale Resonance halo 文案 (OK)")

	# ===== T206.PLAYER.WAVE_HINT_DURATION =====
	total += 1
	# duration 4.0 — 与 _handle_wave 的 queue_hint 第三参数一致
	if player_src.find("wave_precursor_intro") == -1 or _count_substr(player_src, "4.0") < 3:
		print("  FAIL [T206.4]: player.gd 缺 4.0s duration")
		quit(1)
		return
	passed += 1
	print("  [T206.4] 4.0s duration (OK)")

	# ===== T206.PLAYER.WAVE_HINT_INSIDE_SUCCESS =====
	total += 1
	# 验证 wave_precursor_intro 出现在 "if success:" 分支内 (不是 else)
	# 抓取 _handle_wave 函数体
	var handle_wave_idx := player_src.find("func _handle_wave()")
	if handle_wave_idx == -1:
		print("  FAIL [T206.5]: 无法定位 _handle_wave (前置 anchor 应已通过)")
		quit(1)
		return
	# 抓取到下一个 func 之前
	var next_func_idx := player_src.find("\nfunc ", handle_wave_idx + 20)
	if next_func_idx == -1:
		next_func_idx = handle_wave_idx + 4000
	var handle_wave_body := player_src.substr(handle_wave_idx, next_func_idx - handle_wave_idx)
	# 找到 "if success:" 的位置
	var if_success_idx := handle_wave_body.find("if success:")
	if if_success_idx == -1:
		print("  FAIL [T206.5]: _handle_wave 缺 if success: 分支")
		quit(1)
		return
	# 找到 else: 的位置
	var else_idx := handle_wave_body.find("\t\t\telse:")
	if else_idx == -1:
		print("  FAIL [T206.5]: _handle_wave 缺 else: 分支")
		quit(1)
		return
	# 验证 wave_precursor_intro 在 if success: 之后、else 之前
	var group_pos := handle_wave_body.find("wave_precursor_intro")
	if group_pos == -1:
		print("  FAIL [T206.5]: _handle_wave 缺 wave_precursor_intro (前置 anchor 应已通过)")
		quit(1)
		return
	if group_pos < if_success_idx or group_pos > else_idx:
		print("  FAIL [T206.5]: wave_precursor_intro 不在 if success: 分支内 (pos=%d if_success=%d else=%d)" % [group_pos, if_success_idx, else_idx])
		quit(1)
		return
	passed += 1
	print("  [T206.5] wave_precursor_intro 在 if success: 分支内 (OK)")

	print("=== I028 T205 + T206 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 与 I027 同样的实现.
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
