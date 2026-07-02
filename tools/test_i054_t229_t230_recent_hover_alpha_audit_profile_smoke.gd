extends SceneTree
## I054 + I055 (#149) — T229 ProfileRecentList 5 局行 hover alpha +0.1 提亮 +
## T230 TitleScreen audit log 推送至 PauseMenu Profile Stats 冒烟测试
##
## 覆盖 #149 任务 T229 + T230 原子化提交:
##
## === T229 — ProfileRecentList 5 局行 hover alpha +0.1 提亮 ===
## - T229.CONST.BOOST: _RECENT_ROW_HOVER_ALPHA_BOOST = 0.1 (5 行 hover 亮一阶)
## - T229.CONST.DURATION: _RECENT_ROW_HOVER_FADE_DURATION = 0.12 (T111/T226 节奏同源)
## - T229.FIELD.BASE: _recent_row_base_alpha: Array = [] (5 行 base alpha 数组)
## - T229.FIELD.TWEENS: _recent_row_hover_tweens: Dictionary = {} (5 行独立 tween 引用)
## - T229.REFRESH.RESET: _refresh_recent_runs_list 5a 段重置 _recent_row_base_alpha + _recent_row_hover_tweens
## - T229.REFRESH.SAVE: _refresh_recent_runs_list 5h 段存 row_alpha (T219 渐变)
## - T229.HOVER_IN.BASE: _on_recent_row_hover_in 读 _recent_row_base_alpha[idx]
## - T229.HOVER_IN.CLAMP: clampf(base + boost, 0, 1) (i==0 1.0+0.1=1.0 clamp; i==4 0.5+0.1=0.6)
## - T229.HOVER_IN.KILL: hover_in 杀旧 tween (5 行并发 hover 互不打断)
## - T229.HOVER_IN.RESET: lbl.modulate.a = base_alpha (0.12s fade 从 base 起步)
## - T229.HOVER_IN.TWEEN: create_tween + tween_property modulate:a + TRANS_QUAD + EASE_OUT
## - T229.HOVER_IN.SAVE: _recent_row_hover_tweens[lbl] = t (5 行独立 tween 引用)
## - T229.HOVER_OUT.RESTORE: _on_recent_row_hover_out 读 _recent_row_base_alpha[idx]
## - T229.HOVER_OUT.KILL: hover_out 杀旧 tween
## - T229.HOVER_OUT.TWEEN: fade back to base_alpha
## - T229.REGRESS.T215: T215 _on_recent_row_hover_in/out 函数保留 (T229 内部添加 alpha 块)
## - T229.REGRESS.T219: T219 _RECENT_ROW_ALPHA_MAX/MIN 0 改
## - T229.DOC.ANCHOR: T229 (#149) 注释锚点 ≥ 2 处
##
## === T230 — TitleScreen audit log 推送至 PauseMenu Profile Stats ===
## - T230.SCENE.LABEL: pause_menu.tscn PlayerProfilePanel/ProfileVBox/ProfileSaveHealth Label 存在
## - T230.SCENE.POS: ProfileSaveHealth 在 ProfileAutoSave 下, ProfileAvgResonance 上
## - T230.SCENE.FONT_SIZE: ProfileSaveHealth 7pt (附属信息 1 阶小于 ProfileAutoSave 8pt)
## - T230.SCENE.COLOR: ProfileSaveHealth Pale Resonance (0.718, 0.906, 0.867, 1) (与 ProfileAutoSave 同色, 视觉组连贯)
## - T230.SCENE.HALIGN: ProfileSaveHealth horizontal_alignment = 1 (居中)
## - T230.GD.VAR: @onready var _profile_save_health: Label (引用 tscn 节点)
## - T230.GD.FUNC: _refresh_save_health_row() 函数存在
## - T230.GD.AUDIT: _refresh_save_health_row 调 SaveSystem.audit_save_slots() (T224 #146 既有 API)
## - T230.GD.FORMAT: "%d ok / %d 损坏 / %d 漂移 / %d 空" 4 状态紧凑展示
## - T230.GD.WARN: corrupted > 0 / drift > 0 → ⚠ 字符前缀 (T224 既有 push_warning 视觉组同源)
## - T230.GD.FALLBACK: SaveSystem 不可用 / 无 audit_save_slots 方法 → "存档健康度：—" 占位
## - T230.GD.CALL: _refresh_profile 调 _refresh_save_health_row() (在 ProfileAutoSave 段后)
## - T230.REGRESS.SAVE_SYSTEM: SaveSystem.autoload 0 改, audit_save_slots 0 改 (T224 #146 锚点保留)
## - T230.REGRESS.AUTO_SAVE: _profile_auto_save 字段 + 刷新逻辑 0 改 (T138 锚点保留)
## - T230.DOC.ANCHOR: T230 (#149) 注释锚点 ≥ 2 处
## - T230.NO_TITLE_PUSH: title_screen.gd audit 推送 0 触碰 (UI 拉取模式, 0 push 逻辑)

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"
const PAUSE_MENU_TSCN := "res://src/scenes/pause_menu.tscn"
const SAVE_SYSTEM_GD := "res://src/autoload/save_system.gd"
const TITLE_SCREEN_GD := "res://src/scripts/title_screen.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I054 + I055 (#149) — T229 RecentList hover alpha +0.1 + T230 audit log → Profile Stats ===")
	_run_t229_const_assertions()
	_run_t229_field_assertions()
	_run_t229_refresh_assertions()
	_run_t229_hover_in_assertions()
	_run_t229_hover_out_assertions()
	_run_t229_regress_assertions()
	_run_t229_doc_anchor_assertions()
	_run_t230_scene_assertions()
	_run_t230_gd_var_assertions()
	_run_t230_gd_func_assertions()
	_run_t230_gd_call_assertions()
	_run_t230_regress_assertions()
	_run_t230_doc_anchor_assertions()
	_run_t230_no_title_push_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I054 + I055 (#149) T229 + T230 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T229 — ProfileRecentList 5 局行 hover alpha +0.1 提亮 =====================

# ---------- T229.CONST.* — boost + 节奏参数 ----------
func _run_t229_const_assertions() -> void:
	print("--- T229.CONST.* — boost + 节奏参数 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _RECENT_ROW_HOVER_ALPHA_BOOST := 0.1",
		"T229.CONST.BOOST.1: _RECENT_ROW_HOVER_ALPHA_BOOST = 0.1 (5 行 hover 亮一阶, T226 slot hover 0.1 跨 2 panel 同源)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_FADE_DURATION := 0.12",
		"T229.CONST.DURATION.1: _RECENT_ROW_HOVER_FADE_DURATION = 0.12 (T111/T215/T226 节奏同源, 跨 4 个 hover 区域同步)")


# ---------- T229.FIELD.* — base alpha 数组 + tween 引用表 ----------
func _run_t229_field_assertions() -> void:
	print("--- T229.FIELD.* — base alpha 数组 + tween 引用表 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "var _recent_row_base_alpha: Array = []",
		"T229.FIELD.BASE.1: _recent_row_base_alpha: Array = [] (5 行 base alpha 数组, 跟随 T219 渐变 row_alpha)")
	_assert_contains(src, "var _recent_row_hover_tweens: Dictionary = {}",
		"T229.FIELD.TWEENS.1: _recent_row_hover_tweens: Dictionary = {} (Label → Tween, 5 行并发 hover 各自 track)")


# ---------- T229.REFRESH.* — _refresh_recent_runs_list 5a/5h 段 ----------
func _run_t229_refresh_assertions() -> void:
	print("--- T229.REFRESH.* — _refresh_recent_runs_list 5a/5h 段 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _refresh_recent_runs_list() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T229.REFRESH.1: _refresh_recent_runs_list 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 6000)
	# 5a 段: 重置 base + tweens
	_assert_contains(fn_body, "_recent_row_base_alpha.clear()",
		"T229.REFRESH.RESET.1: 5a 段重置 _recent_row_base_alpha.clear() (每次 _refresh 重建 5 行 → 数组 resize)")
	_assert_contains(fn_body, "_recent_row_hover_tweens.clear()",
		"T229.REFRESH.RESET.2: 5a 段重置 _recent_row_hover_tweens.clear() (5 行 tween 引用表清空)")
	# 5h 段: 保存 row_alpha
	_assert_contains(fn_body, "_recent_row_base_alpha.append(row_alpha)",
		"T229.REFRESH.SAVE.1: 5h 段 _recent_row_base_alpha.append(row_alpha) (T229 跟随 T219 渐变)")


# ---------- T229.HOVER_IN.* — _on_recent_row_hover_in 改造 ----------
func _run_t229_hover_in_assertions() -> void:
	print("--- T229.HOVER_IN.* — _on_recent_row_hover_in 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_recent_row_hover_in(idx: int) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T229.HOVER_IN.1: _on_recent_row_hover_in 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 2500)
	_assert_contains(fn_body, "if idx < _recent_row_base_alpha.size():",
		"T229.HOVER_IN.BASE.1: hover_in 守卫 _recent_row_base_alpha 越界 (defensive fallback base=1.0)")
	_assert_contains(fn_body, "base_alpha = float(_recent_row_base_alpha[idx])",
		"T229.HOVER_IN.BASE.2: hover_in 读 base_alpha = float(_recent_row_base_alpha[idx])")
	_assert_contains(fn_body, "clampf(base_alpha + _RECENT_ROW_HOVER_ALPHA_BOOST, 0.0, 1.0)",
		"T229.HOVER_IN.CLAMP.1: clampf(base + boost, 0, 1) (i==0 1.0+0.1=1.0 clamp; i==4 0.5+0.1=0.6 渐亮)")
	_assert_contains(fn_body, "if _recent_row_hover_tweens.has(lbl):",
		"T229.HOVER_IN.KILL.1: hover_in 守卫 _recent_row_hover_tweens.has(lbl) (旧 tween 存在 → kill)")
	_assert_contains(fn_body, "old_tween.kill()",
		"T229.HOVER_IN.KILL.2: hover_in kill 旧 tween (5 行并发 hover 互不打断, 避免 tween 叠加)")
	_assert_contains(fn_body, "lbl.modulate.a = base_alpha",
		"T229.HOVER_IN.RESET.1: hover_in lbl.modulate.a = base_alpha (0.12s fade 从 base 起步, 避免中间值残留)")
	_assert_contains(fn_body, 't.tween_property(lbl, "modulate:a", boosted_alpha, _RECENT_ROW_HOVER_FADE_DURATION)',
		"T229.HOVER_IN.TWEEN.1: hover_in tween_property modulate:a (5 行独立 tween 各自推进)")
	_assert_contains(fn_body, "set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)",
		"T229.HOVER_IN.TWEEN.2: hover_in TRANS_QUAD + EASE_OUT (T111/T215/T226 节奏同源, 跨 4 个 hover 区域同步)")
	_assert_contains(fn_body, "_recent_row_hover_tweens[lbl] = t",
		"T229.HOVER_IN.SAVE.1: hover_in 保存 tween 引用 (5 行独立 tween 引用表, 下次 hover 可 kill)")


# ---------- T229.HOVER_OUT.* — _on_recent_row_hover_out 改造 ----------
func _run_t229_hover_out_assertions() -> void:
	print("--- T229.HOVER_OUT.* — _on_recent_row_hover_out 改造 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _on_recent_row_hover_out(idx: int) -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T229.HOVER_OUT.1: _on_recent_row_hover_out 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 2500)
	_assert_contains(fn_body, "if idx < _recent_row_base_alpha.size():",
		"T229.HOVER_OUT.RESTORE.1: hover_out 守卫 _recent_row_base_alpha 越界 (defensive fallback base=1.0)")
	_assert_contains(fn_body, "base_alpha = float(_recent_row_base_alpha[idx])",
		"T229.HOVER_OUT.RESTORE.2: hover_out 读 base_alpha")
	_assert_contains(fn_body, "if _recent_row_hover_tweens.has(lbl):",
		"T229.HOVER_OUT.KILL.1: hover_out 守卫 _recent_row_hover_tweens.has(lbl) (旧 tween 存在 → kill)")
	_assert_contains(fn_body, "lbl.modulate.a = base_alpha",
		"T229.HOVER_OUT.RESET.1: hover_out lbl.modulate.a = base_alpha (0.12s fade 从 base 起步)")
	_assert_contains(fn_body, 't.tween_property(lbl, "modulate:a", base_alpha, _RECENT_ROW_HOVER_FADE_DURATION)',
		"T229.HOVER_OUT.TWEEN.1: hover_out tween_property modulate:a 回到 base_alpha (fade-out 恢复 base)")


# ---------- T229.REGRESS.* — T215 + T219 0 改 ----------
func _run_t229_regress_assertions() -> void:
	print("--- T229.REGRESS.* — T215 + T219 0 改 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T215 既有 hover handler 0 改 (T229 内部添加 alpha 块, 函数签名不变)
	_assert_contains(src, "func _on_recent_row_hover_in(idx: int) -> void:",
		"T229.REGRESS.T215.1: T215 _on_recent_row_hover_in 函数签名 0 改 (#136 锚点保留)")
	_assert_contains(src, "func _on_recent_row_hover_out(idx: int) -> void:",
		"T229.REGRESS.T215.2: T215 _on_recent_row_hover_out 函数签名 0 改")
	_assert_contains(src, "var _recent_row_hovered: Array = []",
		"T229.REGRESS.T215.3: T215 _recent_row_hovered re-entrant guard 字段 0 改")
	_assert_contains(src, "var _recent_row_default_color: Array = []",
		"T229.REGRESS.T215.4: T215 _recent_row_default_color 字段 0 改 (T229 内部新加 _recent_row_base_alpha, 0 触碰默认色)")
	# T219 alpha 渐变常量 0 改
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MAX := 1.0",
		"T229.REGRESS.T219.1: T219 _RECENT_ROW_ALPHA_MAX 0 改 (#141 锚点保留, T229 用作 base alpha 上限)")
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MIN := 0.5",
		"T229.REGRESS.T219.2: T219 _RECENT_ROW_ALPHA_MIN 0 改 (T229 用作 base alpha 下限, hover 0.5+0.1=0.6 仍 > 0.5)")


# ---------- T229.DOC.ANCHOR.* — T229 注释锚点 ≥ 2 处 ----------
func _run_t229_doc_anchor_assertions() -> void:
	print("--- T229.DOC.ANCHOR.* — T229 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T229 (#149)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T229.DOC.ANCHOR.1: T229 (#149) 注释锚点 %d 处 (≥ 2)" % anchor_count)
	else:
		_failures.append("FAIL: T229.DOC.ANCHOR.1: T229 (#149) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ===================== T230 — TitleScreen audit log 推送至 PauseMenu Profile Stats =====================

# ---------- T230.SCENE.* — tscn 节点 ----------
func _run_t230_scene_assertions() -> void:
	print("--- T230.SCENE.* — tscn ProfileSaveHealth 节点 ---")
	var tscn := _read_file(PAUSE_MENU_TSCN)
	# 节点存在
	_assert_contains(tscn, '[node name="ProfileSaveHealth" type="Label"',
		"T230.SCENE.LABEL.1: pause_menu.tscn ProfileSaveHealth Label 节点存在 (T230 新增存档健康度 1 行)")
	# 位置: 在 ProfileAutoSave 之后, ProfileAvgResonance 之前
	var autosave_pos := tscn.find('name="ProfileAutoSave"')
	var savehealth_pos := tscn.find('name="ProfileSaveHealth"')
	var avgresonance_pos := tscn.find('name="ProfileAvgResonance"')
	if autosave_pos == -1 or savehealth_pos == -1 or avgresonance_pos == -1:
		_failures.append("FAIL: T230.SCENE.POS.1: ProfileAutoSave / ProfileSaveHealth / ProfileAvgResonance 节点至少 1 个未找到")
	else:
		if autosave_pos < savehealth_pos and savehealth_pos < avgresonance_pos:
			_passes += 1
			print("  OK  T230.SCENE.POS.1: ProfileSaveHealth 在 ProfileAutoSave 下, ProfileAvgResonance 上 (与\"上次自动存档\"同组, 都是存档子系统信息)")
		else:
			_failures.append("FAIL: T230.SCENE.POS.1: ProfileSaveHealth 位置错误: ProfileAutoSave=%d ProfileSaveHealth=%d ProfileAvgResonance=%d" % [autosave_pos, savehealth_pos, avgresonance_pos])
	# 字体大小: 7pt (附属信息 1 阶小于 ProfileAutoSave 8pt)
	if savehealth_pos != -1:
		var node_body := tscn.substr(savehealth_pos, 800)
		_assert_contains(node_body, "theme_override_font_sizes/font_size = 7",
			"T230.SCENE.FONT_SIZE.1: ProfileSaveHealth 7pt (附属信息 1 阶小于 ProfileAutoSave 8pt, 视觉组定位)")
		# 颜色: Pale Resonance
		_assert_contains(node_body, "theme_override_colors/font_color = Color(0.718, 0.906, 0.867, 1)",
			"T230.SCENE.COLOR.1: ProfileSaveHealth Pale Resonance (0.718, 0.906, 0.867, 1) (与 ProfileAutoSave 同色, 视觉组连贯)")
		# 居中
		_assert_contains(node_body, "horizontal_alignment = 1",
			"T230.SCENE.HALIGN.1: ProfileSaveHealth 居中对齐 (与 ProfileAutoSave / ProfileAvgResonance 一致)")


# ---------- T230.GD.VAR.* — @onready 字段 ----------
func _run_t230_gd_var_assertions() -> void:
	print("--- T230.GD.VAR.* — @onready _profile_save_health 字段 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, '@onready var _profile_save_health: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileSaveHealth',
		"T230.GD.VAR.1: @onready var _profile_save_health: Label 引用 tscn 节点 (T230 新增字段, 与 _profile_auto_save 同模式 chain)")


# ---------- T230.GD.FUNC.* — _refresh_save_health_row 函数 ----------
func _run_t230_gd_func_assertions() -> void:
	print("--- T230.GD.FUNC.* — _refresh_save_health_row 函数 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _refresh_save_health_row() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T230.GD.FUNC.1: _refresh_save_health_row 函数未找到")
		return
	var fn_body := src.substr(fn_idx, 1500)
	# SaveSystem 不可用 fallback
	_assert_contains(fn_body, "if not SaveSystem or not SaveSystem.has_method(\"audit_save_slots\"):",
		"T230.GD.FALLBACK.1: _refresh_save_health_row 守卫 SaveSystem + has_method(autoload 不可用 → \"存档健康度：—\" 占位)")
	_assert_contains(fn_body, "_profile_save_health.text = \"存档健康度：—\"",
		"T230.GD.FALLBACK.2: _refresh_save_health_row fallback 文本 \"存档健康度：—\" (SaveSystem 不可用)")
	# 调 audit_save_slots
	_assert_contains(fn_body, "SaveSystem.audit_save_slots()",
		"T230.GD.AUDIT.1: _refresh_save_health_row 调 SaveSystem.audit_save_slots() (T224 #146 既有公开 API, 0 触碰 save_system.gd)")
	# 4 状态字段
	_assert_contains(fn_body, 'int(report.get("ok", 0))',
		"T230.GD.AUDIT.2: _refresh_save_health_row 读 report.ok (T224 audit 4 状态字段之一)")
	_assert_contains(fn_body, 'int(report.get("corrupted", 0))',
		"T230.GD.AUDIT.3: _refresh_save_health_row 读 report.corrupted (T224 audit 4 状态字段之一)")
	_assert_contains(fn_body, 'int(report.get("drift", 0))',
		"T230.GD.AUDIT.4: _refresh_save_health_row 读 report.drift (T224 audit 4 状态字段之一)")
	_assert_contains(fn_body, 'int(report.get("empty", 0))',
		"T230.GD.AUDIT.5: _refresh_save_health_row 读 report.empty (T224 audit 4 状态字段之一)")
	# 4 状态紧凑展示格式
	_assert_contains(fn_body, '"%s存档健康度：%d ok / %d 损坏 / %d 漂移 / %d 空"',
		"T230.GD.FORMAT.1: _refresh_save_health_row 4 状态紧凑展示 \"存档健康度：%d ok / %d 损坏 / %d 漂移 / %d 空\" (1 行 4 计数, 玩家 1 眼看完)")
	# ⚠ 警示
	_assert_contains(fn_body, "if corrupted_n > 0:",
		"T230.GD.WARN.1: _refresh_save_health_row 守卫 corrupted > 0 (有损坏 → ⚠ 字符前缀)")
	_assert_contains(fn_body, "elif drift_n > 0:",
		"T230.GD.WARN.2: _refresh_save_health_row 守卫 drift > 0 (有漂移 → ⚠ 字符前缀)")


# ---------- T230.GD.CALL.* — _refresh_profile 调用 ----------
func _run_t230_gd_call_assertions() -> void:
	print("--- T230.GD.CALL.* — _refresh_profile 调用 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var fn_idx := src.find("func _refresh_profile() -> void:")
	if fn_idx == -1:
		_failures.append("FAIL: T230.GD.CALL.1: _refresh_profile 函数未找到")
		return
	# 在 ProfileAutoSave 段后调 _refresh_save_health_row
	var fn_body := src.substr(fn_idx, 8000)
	var autosave_text_idx := fn_body.find('"上次自动存档  —"')
	var save_health_call_idx := fn_body.find("_refresh_save_health_row()")
	if autosave_text_idx == -1 or save_health_call_idx == -1:
		_failures.append("FAIL: T230.GD.CALL.1: _refresh_profile 内未找到 \"上次自动存档  —\" 或 _refresh_save_health_row() 调")
	else:
		if save_health_call_idx > autosave_text_idx:
			_passes += 1
			print("  OK  T230.GD.CALL.1: _refresh_profile 在 ProfileAutoSave 段后调 _refresh_save_health_row() (T230 调位置正确)")
		else:
			_failures.append("FAIL: T230.GD.CALL.1: _refresh_save_health_row() 调位置错误, 应在 ProfileAutoSave 段后")


# ---------- T230.REGRESS.* — SaveSystem + T138 0 改 ----------
func _run_t230_regress_assertions() -> void:
	print("--- T230.REGRESS.* — SaveSystem + T138 0 改 ---")
	var save_src := _read_file(SAVE_SYSTEM_GD)
	# SaveSystem.autoload 0 改
	_assert_contains(save_src, "func audit_save_slots() -> Dictionary:",
		"T230.REGRESS.SAVE_SYSTEM.1: SaveSystem.audit_save_slots() 公开 API 函数 0 删 (#146 锚点保留, T230 调)")
	_assert_contains(save_src, "_audit_save_slots_internal",
		"T230.REGRESS.SAVE_SYSTEM.2: SaveSystem 内部 _audit_save_slots_internal 实现 0 改 (T230 0 触碰 save_system.gd)")
	var pause_src := _read_file(PAUSE_MENU_GD)
	# _profile_auto_save 字段 + 刷新逻辑 0 改
	_assert_contains(pause_src, '@onready var _profile_auto_save: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileAutoSave',
		"T230.REGRESS.AUTO_SAVE.1: _profile_auto_save 字段 0 改 (T138 锚点保留, T230 0 触碰)")


# ---------- T230.DOC.ANCHOR.* — T230 注释锚点 ≥ 2 处 ----------
func _run_t230_doc_anchor_assertions() -> void:
	print("--- T230.DOC.ANCHOR.* — T230 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T230 (#149)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T230.DOC.ANCHOR.1: T230 (#149) 注释锚点 %d 处 (≥ 2)" % anchor_count)
	else:
		_failures.append("FAIL: T230.DOC.ANCHOR.1: T230 (#149) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T230.NO_TITLE_PUSH — title_screen.gd audit 推送 0 触碰 ----------
func _run_t230_no_title_push_assertions() -> void:
	print("--- T230.NO_TITLE_PUSH — title_screen.gd audit 推送 0 触碰 ---")
	var title_src := _read_file(TITLE_SCREEN_GD)
	# T230 是 UI 拉取模式 (PauseMenu 调 SaveSystem.audit_save_slots), title_screen.gd 0 推送逻辑
	# T224 (#146) 既有 title_screen audit 调用应该 0 改 (T230 0 触碰)
	# 验证: title_screen.gd 不应该新加 SaveSystem audit 推送至 PauseMenu 的逻辑
	if title_src.find("_refresh_save_health_row") != -1:
		_failures.append("FAIL: T230.NO_TITLE_PUSH.1: title_screen.gd 不应 _refresh_save_health_row (T230 拉取模式, 0 push 逻辑)")
	else:
		_passes += 1
		print("  OK  T230.NO_TITLE_PUSH.1: title_screen.gd 0 加 _refresh_save_health_row (T230 拉取模式, 0 push 逻辑, title_screen 0 改)")


# ===================== 通用 helper =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % label)
	else:
		_failures.append("FAIL: %s (missing: %s)" % [label, needle])


func _print_summary() -> void:
	print("")
	print("--- Summary ---")
	print("  PASS: %d" % _passes)
	print("  FAIL: %d" % _failures.size())
	for fail_msg in _failures:
		print("  %s" % fail_msg)
