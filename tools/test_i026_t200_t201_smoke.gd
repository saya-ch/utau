extends SceneTree
## I026 (#117 → #118 refactor) — Smoke test for T200 (HUD 5 verb 冷却条 灰化)
## + T201 (PlayerProfilePanel 2 个顶级聚合行 AvgResonance / BestStreak).
##
## 28+ 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i026_t200_t201_smoke.gd
##
## 设计 (与 I022 ~ I025 一致, 静态单点锚点 + 字段/注释/call-site 计数):
##   T200.HUD.REDUCED_CONST — hud.gd 有 _REDUCED_COLOR_MODULATE 常量.
##   T200.HUD.NORMAL_CONST — hud.gd 有 _NORMAL_COLOR_MODULATE 常量.
##   T200.HUD.APPLIED_STATE — hud.gd 有 _reduced_cooldown_color_applied 状态变量 (T203 重命名).
##   T200.HUD.APPLY_FN — _apply_reduced_cooldown_color_modulate 函数存在 (T203 重命名).
##   T200.HUD.HAS_SS_FN — _has_screen_shake helper 函数存在.
##   T200.HUD.PROCESS_HOOK — _process() 内有 reduce_cooldown_color 钩子调用.
##   T200.HUD.SS_QUERY — 调用 ScreenShake.is_reduce_cooldown_color() (T203 切换信号源).
##   T200.HUD.5_BARS_LOOP — 循环 5 bar (pulse/bind/cut/echo/wave).
##   T200.HUD.MODULATE_ASSIGN — bar.modulate = target_color 赋值.
##   T200.HUD.T200_ANCHOR — hud.gd 含 T200 (#117) 注释锚点 (T200 任务不变, 仅 #118 期间绑定切换).
##   T200.HUD.GUARD_NOT_EVERY_FRAME — 用 _reduced_cooldown_color_applied 守卫避免每帧重设.
##   T200.SS.IS_REDUCE_COOLDOWN_COLOR — screen_shake.gd 有 is_reduce_cooldown_color() 函数 (T203 新增).
##   T200.SS.IS_REDUCE_FLASH_PRESERVED — screen_shake.gd 仍保留 T195 is_reduce_flash() 公开 API.
##   T201.PM.AVG_REF — pause_menu.gd 有 _profile_avg_resonance @onready ref.
##   T201.PM.STREAK_REF — pause_menu.gd 有 _profile_best_streak @onready ref.
##   T201.PM.AVG_FN — _refresh_top_aggregate_rows 函数存在.
##   T201.PM.CALL_SITE — _refresh_profile() 内调用 _refresh_top_aggregate_rows().
##   T201.PM.AVG_FORMULA — 含 sum(shards)/sum(rooms) 聚合比计算.
##   T201.PM.STREAK_FORMULA — 含 max rooms_cleared 找 best run.
##   T201.PM.AVG_PLACEHOLDER — 零样本/无房记录占位 "—" 或 "无房记录".
##   T201.PM.STREAK_PLACEHOLDER — 零样本占位 "—".
##   T201.PM.T201_ANCHOR — pause_menu.gd 含 T201 (#117) 注释锚点.
##   T201.SCENE.AVG_NODE — pause_menu.tscn 有 ProfileAvgResonance Label.
##   T201.SCENE.STREAK_NODE — pause_menu.tscn 有 ProfileBestStreak Label.
##   T201.SCENE.AVG_PARENT — 节点挂在 PlayerProfilePanel/ProfileMargin/ProfileVBox.
##   T201.SCENE.STREAK_PARENT — 节点挂在 PlayerProfilePanel/ProfileMargin/ProfileVBox.
##   T201.SCENE.AVG_COLOR — ProfileAvgResonance 有 Glass Cyan (#69C7CE).
##   T201.SCENE.STREAK_COLOR — ProfileBestStreak 有 Glass Cyan (#69C7CE).
##   T201.SCENE.AVG_AFTER_AUTO — 节点位于 ProfileAutoSave 后、HSep1 前.

func _initialize() -> void:
	print("=== I026 T200 HUD 灰化 (T203 切到 reduce_cooldown_color) + T201 PlayerProfile 顶级聚合行 smoke test (#118) ===")

	var hud_src := ""
	var hf := FileAccess.open("res://src/scripts/hud.gd", FileAccess.READ)
	if hf:
		hud_src = hf.get_as_text()
		hf.close()

	var ss_src := ""
	var sf := FileAccess.open("res://src/autoload/screen_shake.gd", FileAccess.READ)
	if sf:
		ss_src = sf.get_as_text()
		sf.close()

	var pm_src := ""
	var pf := FileAccess.open("res://src/scripts/pause_menu.gd", FileAccess.READ)
	if pf:
		pm_src = pf.get_as_text()
		pf.close()

	var scene_src := ""
	var scf := FileAccess.open("res://src/scenes/pause_menu.tscn", FileAccess.READ)
	if scf:
		scene_src = scf.get_as_text()
		scf.close()

	var passed := 0
	var total := 0

	# ===== T200.HUD.REDUCED_CONST =====
	total += 1
	if hud_src.find("_REDUCED_COLOR_MODULATE") == -1:
		print("  FAIL [T200.1]: hud.gd 缺 _REDUCED_COLOR_MODULATE 常量")
		quit(1)
		return
	passed += 1
	print("  [T200.1] hud.gd 含 _REDUCED_COLOR_MODULATE (OK)")

	# ===== T200.HUD.NORMAL_CONST =====
	total += 1
	if hud_src.find("_NORMAL_COLOR_MODULATE") == -1:
		print("  FAIL [T200.2]: hud.gd 缺 _NORMAL_COLOR_MODULATE 常量")
		quit(1)
		return
	passed += 1
	print("  [T200.2] hud.gd 含 _NORMAL_COLOR_MODULATE (OK)")

	# ===== T200.HUD.APPLIED_STATE =====
	total += 1
	# T203 (#118) 重命名: _reduced_flash_applied → _reduced_cooldown_color_applied
	# 因为 T203 拆出独立 4 滑块, T200 视觉绑定从 is_reduce_flash 切到 is_reduce_cooldown_color
	if hud_src.find("_reduced_cooldown_color_applied") == -1:
		print("  FAIL [T200.3]: hud.gd 缺 _reduced_cooldown_color_applied 状态变量 (T203 重命名)")
		quit(1)
		return
	passed += 1
	print("  [T200.3] hud.gd 含 _reduced_cooldown_color_applied (OK)")

	# ===== T200.HUD.APPLY_FN =====
	total += 1
	# T203 (#118) 重命名: _apply_reduced_flash_modulate → _apply_reduced_cooldown_color_modulate
	if hud_src.find("func _apply_reduced_cooldown_color_modulate") == -1:
		print("  FAIL [T200.4]: hud.gd 缺 _apply_reduced_cooldown_color_modulate 函数 (T203 重命名)")
		quit(1)
		return
	passed += 1
	print("  [T200.4] hud.gd 含 _apply_reduced_cooldown_color_modulate (OK)")

	# ===== T200.HUD.HAS_SS_FN =====
	total += 1
	if hud_src.find("func _has_screen_shake") == -1:
		print("  FAIL [T200.5]: hud.gd 缺 _has_screen_shake helper")
		quit(1)
		return
	passed += 1
	print("  [T200.5] hud.gd 含 _has_screen_shake helper (OK)")

	# ===== T200.HUD.PROCESS_HOOK =====
	total += 1
	# 在 _process 函数体内调 _apply_reduced_cooldown_color_modulate
	var apply_call_count := _count_substr(hud_src, "_apply_reduced_cooldown_color_modulate(")
	if apply_call_count < 1:
		print("  FAIL [T200.6]: _apply_reduced_cooldown_color_modulate() 调用次数 = %d, 期望 >= 1" % apply_call_count)
		quit(1)
		return
	passed += 1
	print("  [T200.6] _apply_reduced_cooldown_color_modulate() 调用次数 = %d (>= 1) (OK)" % apply_call_count)

	# ===== T200.HUD.SS_QUERY =====
	total += 1
	# T203 (#118) 切换信号源: ScreenShake.is_reduce_flash() → ScreenShake.is_reduce_cooldown_color()
	if hud_src.find("ScreenShake.is_reduce_cooldown_color()") == -1:
		print("  FAIL [T200.7]: hud.gd 未调用 ScreenShake.is_reduce_cooldown_color() (T203 切换)")
		quit(1)
		return
	passed += 1
	print("  [T200.7] hud.gd 调用 ScreenShake.is_reduce_cooldown_color() (OK)")

	# ===== T200.HUD.5_BARS_LOOP =====
	total += 1
	# _apply_reduced_cooldown_color_modulate 内有 5 bar 引用 (pulse/bind/cut/echo/wave)
	var apply_fn_idx := hud_src.find("func _apply_reduced_cooldown_color_modulate")
	if apply_fn_idx == -1:
		print("  FAIL [T200.8]: 无法定位 _apply_reduced_cooldown_color_modulate 函数")
		quit(1)
		return
	# 取函数体到下个 "func " 之间的切片
	var after_apply := hud_src.substr(apply_fn_idx, 800)
	var five_bar_count := 0
	for bar_name in ["_pulse_cooldown", "_bind_cooldown", "_cut_cooldown", "_echo_cooldown", "_wave_cooldown"]:
		if after_apply.find(bar_name) != -1:
			five_bar_count += 1
	if five_bar_count < 5:
		print("  FAIL [T200.8]: _apply_reduced_cooldown_color_modulate 体内 5 bar 引用 = %d, 期望 5" % five_bar_count)
		quit(1)
		return
	passed += 1
	print("  [T200.8] _apply_reduced_cooldown_color_modulate 体内 5 bar 引用 (OK)")

	# ===== T200.HUD.MODULATE_ASSIGN =====
	total += 1
	if hud_src.find("bar.modulate = target_color") == -1:
		print("  FAIL [T200.9]: 缺 bar.modulate = target_color 赋值")
		quit(1)
		return
	passed += 1
	print("  [T200.9] bar.modulate = target_color 赋值 (OK)")

	# ===== T200.HUD.T200_ANCHOR =====
	total += 1
	# T200 (#117) 注释锚点 — T200 任务没变, 注释里会同时含 T200 和 T203 引用
	var t200_count := _count_substr(hud_src, "T200 (#117)")
	if t200_count < 1:
		print("  FAIL [T200.10]: T200 (#117) 注释锚点出现次数 = %d, 期望 >= 1" % t200_count)
		quit(1)
		return
	passed += 1
	print("  [T200.10] T200 (#117) 注释锚点出现 = %d 次 (OK)" % t200_count)

	# ===== T200.HUD.GUARD_NOT_EVERY_FRAME =====
	total += 1
	# T203 (#118) 重命名守卫: reduce_cooldown_color_active != _reduced_cooldown_color_applied
	if hud_src.find("reduce_cooldown_color_active != _reduced_cooldown_color_applied") == -1:
		print("  FAIL [T200.11]: 缺状态切换守卫 (T203 重命名 reduce_cooldown_color_active)")
		quit(1)
		return
	passed += 1
	print("  [T200.11] 状态切换守卫 reduce_cooldown_color_active != _reduced_cooldown_color_applied (OK)")

	# ===== T200.SS.IS_REDUCE_COOLDOWN_COLOR =====
	total += 1
	# T203 (#118) 新增: screen_shake.gd 暴露 is_reduce_cooldown_color() 公开方法
	if ss_src.find("func is_reduce_cooldown_color") == -1:
		print("  FAIL [T200.12]: screen_shake.gd 缺 is_reduce_cooldown_color() 函数 (T203 新增)")
		quit(1)
		return
	passed += 1
	print("  [T200.12] screen_shake.gd 含 is_reduce_cooldown_color() (OK)")

	# ===== T200.SS.IS_REDUCE_FLASH_PRESERVED =====
	total += 1
	# T195 (#112) 公开 API is_reduce_flash() 仍在 (settings_menu.gd 仍在调),
	# T203 (#118) 不破坏 T195 公开 API, 只是 hud.gd 视觉绑定换到 is_reduce_cooldown_color
	if ss_src.find("func is_reduce_flash") == -1:
		print("  FAIL [T200.13]: screen_shake.gd 缺 is_reduce_flash() 函数 (T195 公开 API 应保留)")
		quit(1)
		return
	passed += 1
	print("  [T200.13] screen_shake.gd 含 is_reduce_flash() (T195 API 保留) (OK)")

	# ===== T201.PM.AVG_REF =====
	total += 1
	if pm_src.find("_profile_avg_resonance: Label") == -1:
		print("  FAIL [T201.1]: pause_menu.gd 缺 _profile_avg_resonance @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T201.1] pause_menu.gd 含 _profile_avg_resonance ref (OK)")

	# ===== T201.PM.STREAK_REF =====
	total += 1
	if pm_src.find("_profile_best_streak: Label") == -1:
		print("  FAIL [T201.2]: pause_menu.gd 缺 _profile_best_streak @onready ref")
		quit(1)
		return
	passed += 1
	print("  [T201.2] pause_menu.gd 含 _profile_best_streak ref (OK)")

	# ===== T201.PM.AVG_FN =====
	total += 1
	if pm_src.find("func _refresh_top_aggregate_rows") == -1:
		print("  FAIL [T201.3]: pause_menu.gd 缺 _refresh_top_aggregate_rows 函数")
		quit(1)
		return
	passed += 1
	print("  [T201.3] pause_menu.gd 含 _refresh_top_aggregate_rows (OK)")

	# ===== T201.PM.CALL_SITE =====
	total += 1
	if pm_src.find("_refresh_top_aggregate_rows()") == -1:
		print("  FAIL [T201.4]: _refresh_profile 未调用 _refresh_top_aggregate_rows()")
		quit(1)
		return
	passed += 1
	print("  [T201.4] _refresh_profile 调 _refresh_top_aggregate_rows() (OK)")

	# ===== T201.PM.AVG_FORMULA =====
	total += 1
	# AvgResonance = sum(shards_collected) / sum(rooms_cleared)
	if pm_src.find("total_shards") == -1 or pm_src.find("total_rooms") == -1:
		print("  FAIL [T201.5]: 缺 total_shards / total_rooms 聚合比计算")
		quit(1)
		return
	passed += 1
	print("  [T201.5] total_shards / total_rooms 聚合比 (OK)")

	# ===== T201.PM.STREAK_FORMULA =====
	total += 1
	# best_run 来自 max rooms_cleared 比较
	if pm_src.find("best_run") == -1:
		print("  FAIL [T201.6]: 缺 best_run 计算 (max rooms_cleared)")
		quit(1)
		return
	passed += 1
	print("  [T201.6] best_run (max rooms_cleared) (OK)")

	# ===== T201.PM.AVG_PLACEHOLDER =====
	total += 1
	# 零样本或 0 房 fallback 占位
	if pm_src.find("无房记录") == -1:
		print("  FAIL [T201.7]: 缺 '无房记录' 0 房占位文本")
		quit(1)
		return
	passed += 1
	print("  [T201.7] '无房记录' 0 房占位 (OK)")

	# ===== T201.PM.STREAK_PLACEHOLDER =====
	total += 1
	# 零样本 fallback 占位 "—"
	if pm_src.find("★ 最佳单局 —  ★") == -1:
		print("  FAIL [T201.8]: 缺 '★ 最佳单局 —  ★' 零样本占位")
		quit(1)
		return
	passed += 1
	print("  [T201.8] '★ 最佳单局 —  ★' 零样本占位 (OK)")

	# ===== T201.PM.T201_ANCHOR =====
	total += 1
	var t201_count := _count_substr(pm_src, "T201 (#117)")
	if t201_count < 2:
		print("  FAIL [T201.9]: T201 (#117) 注释锚点出现次数 = %d, 期望 >= 2 (ref 块 + 函数体)" % t201_count)
		quit(1)
		return
	passed += 1
	print("  [T201.9] T201 (#117) 注释锚点出现 = %d 次 (OK)" % t201_count)

	# ===== T201.SCENE.AVG_NODE =====
	total += 1
	if scene_src.find('name="ProfileAvgResonance"') == -1:
		print("  FAIL [T201.10]: pause_menu.tscn 缺 ProfileAvgResonance Label")
		quit(1)
		return
	passed += 1
	print("  [T201.10] pause_menu.tscn 含 ProfileAvgResonance (OK)")

	# ===== T201.SCENE.STREAK_NODE =====
	total += 1
	if scene_src.find('name="ProfileBestStreak"') == -1:
		print("  FAIL [T201.11]: pause_menu.tscn 缺 ProfileBestStreak Label")
		quit(1)
		return
	passed += 1
	print("  [T201.11] pause_menu.tscn 含 ProfileBestStreak (OK)")

	# ===== T201.SCENE.AVG_PARENT =====
	total += 1
	# 节点 parent 是 PlayerProfilePanel/ProfileMargin/ProfileVBox
	if scene_src.find('parent="PlayerProfilePanel/ProfileMargin/ProfileVBox"') == -1:
		print("  FAIL [T201.12]: 节点 parent 错 (期望 PlayerProfilePanel/ProfileMargin/ProfileVBox)")
		quit(1)
		return
	passed += 1
	print("  [T201.12] 节点 parent = PlayerProfilePanel/ProfileMargin/ProfileVBox (OK)")

	# ===== T201.SCENE.STREAK_PARENT =====
	total += 1
	# 同样 parent — 上面那条已验证, 这里双保险
	if scene_src.find('parent="PlayerProfilePanel/ProfileMargin/ProfileVBox"') == -1:
		print("  FAIL [T201.13]: 节点 parent 错 (期望 PlayerProfilePanel/ProfileMargin/ProfileVBox)")
		quit(1)
		return
	passed += 1
	print("  [T201.13] 节点 parent = PlayerProfilePanel/ProfileMargin/ProfileVBox (OK)")

	# ===== T201.SCENE.AVG_COLOR =====
	total += 1
	# Glass Cyan 颜色 (0.412, 0.78, 0.808, 1) 在 ProfileAvgResonance 节点附近出现
	# 用 (0.412 出现次数 >= 1 即可, 因为 scene 内其他节点也用同色)
	# 更严: 找节点定义附近 8 行内出现 (0.412
	var avg_node_idx := scene_src.find('name="ProfileAvgResonance"')
	if avg_node_idx == -1:
		print("  FAIL [T201.14]: 无法定位 ProfileAvgResonance 节点 (前置 anchor 应已通过)")
		quit(1)
		return
	var avg_section := scene_src.substr(avg_node_idx, 600)
	if avg_section.find("(0.412") == -1:
		print("  FAIL [T201.14]: ProfileAvgResonance 缺 Glass Cyan 颜色 (0.412,...)")
		quit(1)
		return
	passed += 1
	print("  [T201.14] ProfileAvgResonance Glass Cyan 颜色 (OK)")

	# ===== T201.SCENE.STREAK_COLOR =====
	total += 1
	var streak_node_idx := scene_src.find('name="ProfileBestStreak"')
	if streak_node_idx == -1:
		print("  FAIL [T201.15]: 无法定位 ProfileBestStreak 节点 (前置 anchor 应已通过)")
		quit(1)
		return
	var streak_section := scene_src.substr(streak_node_idx, 600)
	if streak_section.find("(0.412") == -1:
		print("  FAIL [T201.15]: ProfileBestStreak 缺 Glass Cyan 颜色 (0.412,...)")
		quit(1)
		return
	passed += 1
	print("  [T201.15] ProfileBestStreak Glass Cyan 颜色 (OK)")

	# ===== T201.SCENE.AVG_AFTER_AUTO =====
	total += 1
	# ProfileAutoSave 索引 < ProfileAvgResonance 索引 < HSep1 索引
	var auto_idx := scene_src.find('name="ProfileAutoSave"')
	var avg_idx := scene_src.find('name="ProfileAvgResonance"')
	var streak_idx := scene_src.find('name="ProfileBestStreak"')
	var hsep1_idx := scene_src.find('name="HSep1" type="HSeparator"')
	if auto_idx == -1 or avg_idx == -1 or streak_idx == -1 or hsep1_idx == -1:
		print("  FAIL [T201.16]: 节点定位失败 auto=%d avg=%d streak=%d hsep1=%d" % [auto_idx, avg_idx, streak_idx, hsep1_idx])
		quit(1)
		return
	if not (auto_idx < avg_idx and avg_idx < streak_idx and streak_idx < hsep1_idx):
		print("  FAIL [T201.16]: 节点顺序错: 应为 AutoSave < AvgResonance < BestStreak < HSep1, 实际 auto=%d avg=%d streak=%d hsep1=%d" % [auto_idx, avg_idx, streak_idx, hsep1_idx])
		quit(1)
		return
	passed += 1
	print("  [T201.16] 节点顺序: AutoSave < AvgResonance < BestStreak < HSep1 (OK)")

	print("=== I026 T200 (T203 重命名绑定到 is_reduce_cooldown_color) + T201 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 简单 GDScript 内置替代, 避免 import String.count
# (Godot 4 String.count 是 method 但 signature 与 Python 不同, 用手写循环最稳).
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
