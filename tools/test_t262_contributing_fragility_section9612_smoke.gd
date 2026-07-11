extends SceneTree
## T262 (#183) — §9.6.12 settings_menu 4 tab 状态机 (AUDIO / VIDEO / CONTROLS / SAVES) + Tab 枚举 + 4 panel mutual-exclusive visible + 4 button modulate 1:1 复制 polish 模式 (T037 + T072 + T086 + T134 + T202.B 跨 5 任务 ~20 轮落地) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t262_contributing_fragility_section9612_smoke.gd
##
## T262: CONTRIBUTING.md §9.6.12 已知 fragility 扩展
##   - §9.6.12 4 tab 状态机 (Tab 枚举 + 1 状态字段 + 4 tab Button + 4 panel + 4 signal connect + _switch_tab 7 步骤 + 初始渲染 1 行) 7 件套
##   - settings_menu.gd 1 Tab 枚举 (enum Tab { AUDIO, VIDEO, CONTROLS, SAVES })
##   - settings_menu.gd 1 状态字段 (var _current_tab: Tab = Tab.AUDIO)
##   - settings_menu.gd 4 tab Button @onready 引用 (_tab_audio / _tab_video / _tab_controls / _tab_saves)
##   - settings_menu.gd 4 panel Control @onready 引用 (_audio_panel / _video_panel / _controls_panel / _saves_panel)
##   - settings_menu.gd 4 行 signal connect (4 lambda 立即调 _switch_tab)
##   - settings_menu.gd 1 _switch_tab 函数 (状态 + 4 panel 显隐 + 4 button modulate + 1 side effect)
##   - settings_menu.gd 1 行 _ready 末尾初始渲染 _switch_tab(Tab.AUDIO)
## 验证 9 维:
##   - §9.6.12 章节在 CONTRIBUTING.md 已落地
##   - §9.6.12 4 段结构 (症状/触发/修复/预防) 全部存在
##   - settings_menu.gd 1 Tab 枚举
##   - settings_menu.gd 1 状态字段
##   - settings_menu.gd 4 tab Button @onready (4 + 1 顺序)
##   - settings_menu.gd 4 panel Control @onready (4 + 1 顺序)
##   - settings_menu.gd 4 signal connect (4 + 1 顺序)
##   - settings_menu.gd _switch_tab 函数
##   - settings_menu.gd _ready 末尾初始渲染
##   - CHANGELOG.md 含 #183 段 + ROADMAP.md 顶部时间戳含 #183

func _initialize() -> void:
	print("=== T262 #183 §9.6.12 4 tab 状态机 (Tab 枚举 + 1 状态字段 + 4 tab Button + 4 panel + 4 signal connect + _switch_tab 7 步骤 + 初始渲染 1 行) 7 件套 polish 模式 (T037 + T072 + T086 + T134 + T202.B 跨 5 任务 ~20 轮落地) smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_settings_menu := _read_file("res://src/scripts/settings_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T262.1 — §9.6.12 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T262.1 — §9.6.12 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T262.1.1 §9.6.12 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.12 settings_menu 4 tab 状态机") == -1:
		print("  FAIL [T262.1.1]: CONTRIBUTING.md 缺 §9.6.12 章节标题")
		quit(1); return
	passed += 1
	print("  [T262.1.1] CONTRIBUTING.md 含 §9.6.12 章节标题 (OK)")

	# ===== T262.1.2 §9.6.12 含 T037 anchor + _switch_tab + Tab 枚举 =====
	total += 1
	var s9612_start := src_contributing.find("### 9.6.12")
	var s10_start := src_contributing.find("## 10.")
	if s9612_start == -1 or s10_start == -1:
		print("  FAIL [T262.1.2]: §9.6.12 / ## 10 区间划分失败")
		quit(1); return
	var s9612 := src_contributing.substr(s9612_start, s10_start - s9612_start)
	if s9612.find("T037") == -1:
		print("  FAIL [T262.1.2]: §9.6.12 区间缺 T037 anchor")
		quit(1); return
	if s9612.find("_switch_tab") == -1:
		print("  FAIL [T262.1.2]: §9.6.12 区间缺 _switch_tab 关键函数")
		quit(1); return
	if s9612.find("Tab 枚举") == -1 and s9612.find("enum Tab") == -1:
		print("  FAIL [T262.1.2]: §9.6.12 区间缺 Tab 枚举 / enum Tab 关键概念")
		quit(1); return
	passed += 1
	print("  [T262.1.2] CONTRIBUTING.md §9.6.12 区间含 T037 + _switch_tab + Tab 枚举 (OK)")

	# ===== T262.1.3 §9.6.12 提到 4 tab + 4 panel + 7 件套 核心概念 =====
	total += 1
	if s9612.find("4 tab") == -1 and s9612.find("4 panel") == -1 and s9612.find("7 件套") == -1:
		print("  FAIL [T262.1.3]: §9.6.12 缺核心概念 (4 tab / 4 panel / 7 件套)")
		quit(1); return
	passed += 1
	print("  [T262.1.3] CONTRIBUTING.md §9.6.12 含 4 tab / 4 panel / 7 件套 核心概念 (OK)")

	# =================================================================
	# T262.2 — §9.6.12 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T262.2 — §9.6.12 4 段结构 ---")

	# ===== T262.2.1 §9.6.12 症状 =====
	total += 1
	if s9612.find("**症状**") == -1:
		print("  FAIL [T262.2.1]: §9.6.12 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T262.2.1] §9.6.12 含「症状」段 (OK)")

	# ===== T262.2.2 §9.6.12 触发场景 =====
	total += 1
	if s9612.find("**触发场景**") == -1:
		print("  FAIL [T262.2.2]: §9.6.12 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T262.2.2] §9.6.12 含「触发场景」段 (OK)")

	# ===== T262.2.3 §9.6.12 修复 =====
	total += 1
	if s9612.find("**修复**") == -1:
		print("  FAIL [T262.2.3]: §9.6.12 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T262.2.3] §9.6.12 含「修复」段 (OK)")

	# ===== T262.2.4 §9.6.12 预防 =====
	total += 1
	if s9612.find("**预防**") == -1:
		print("  FAIL [T262.2.4]: §9.6.12 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T262.2.4] §9.6.12 含「预防」段 (OK)")

	# =================================================================
	# T262.3 — settings_menu.gd 1 Tab 枚举 + 1 状态字段 (3 断言)
	# =================================================================
	print("--- T262.3 — settings_menu.gd 1 Tab 枚举 + 1 状态字段 ---")

	# ===== T262.3.1 enum Tab { AUDIO, VIDEO, CONTROLS, SAVES } 4 entry =====
	total += 1
	if src_settings_menu.find("enum Tab { AUDIO, VIDEO, CONTROLS, SAVES }") == -1:
		print("  FAIL [T262.3.1]: settings_menu.gd 缺 enum Tab { AUDIO, VIDEO, CONTROLS, SAVES } (T037 Tab 枚举 4 entry)")
		quit(1); return
	passed += 1
	print("  [T262.3.1] settings_menu.gd 含 enum Tab { AUDIO, VIDEO, CONTROLS, SAVES } (T037) (OK)")

	# ===== T262.3.2 var _current_tab: Tab = Tab.AUDIO 状态字段 =====
	total += 1
	if src_settings_menu.find("var _current_tab: Tab = Tab.AUDIO") == -1:
		print("  FAIL [T262.3.2]: settings_menu.gd 缺 var _current_tab: Tab = Tab.AUDIO (T072 状态字段)")
		quit(1); return
	passed += 1
	print("  [T262.3.2] settings_menu.gd 含 _current_tab: Tab = Tab.AUDIO 状态字段 (T072) (OK)")

	# ===== T262.3.3 Tab 枚举 + _current_tab 状态字段顺序 (Tab → _current_tab) =====
	total += 1
	var pos_tab_enum := src_settings_menu.find("enum Tab { AUDIO, VIDEO, CONTROLS, SAVES }")
	var pos_current_tab := src_settings_menu.find("var _current_tab: Tab = Tab.AUDIO")
	if pos_tab_enum == -1 or pos_current_tab == -1:
		print("  FAIL [T262.3.3]: settings_menu.gd Tab 枚举 / _current_tab 缺 1")
		quit(1); return
	if not (pos_tab_enum < pos_current_tab):
		print("  FAIL [T262.3.3]: settings_menu.gd Tab 枚举 / _current_tab 顺序错位 (期望 Tab → _current_tab)")
		quit(1); return
	passed += 1
	print("  [T262.3.3] settings_menu.gd Tab 枚举 / _current_tab 顺序正确 (Tab → _current_tab) (OK)")

	# =================================================================
	# T262.4 — settings_menu.gd 4 tab Button @onready (5 断言)
	# =================================================================
	print("--- T262.4 — settings_menu.gd 4 tab Button @onready ---")

	# ===== T262.4.1 _tab_audio Button =====
	total += 1
	if src_settings_menu.find("@onready var _tab_audio: Button = $VBoxContainer/TabRow/AudioTab") == -1:
		print("  FAIL [T262.4.1]: settings_menu.gd 缺 @onready var _tab_audio (T037 4 tab Button 引用 1)")
		quit(1); return
	passed += 1
	print("  [T262.4.1] settings_menu.gd 含 _tab_audio Button 引用 (T037) (OK)")

	# ===== T262.4.2 _tab_video Button =====
	total += 1
	if src_settings_menu.find("@onready var _tab_video: Button = $VBoxContainer/TabRow/VideoTab") == -1:
		print("  FAIL [T262.4.2]: settings_menu.gd 缺 @onready var _tab_video (T037 4 tab Button 引用 2)")
		quit(1); return
	passed += 1
	print("  [T262.4.2] settings_menu.gd 含 _tab_video Button 引用 (T037) (OK)")

	# ===== T262.4.3 _tab_controls Button =====
	total += 1
	if src_settings_menu.find("@onready var _tab_controls: Button = $VBoxContainer/TabRow/ControlsTab") == -1:
		print("  FAIL [T262.4.3]: settings_menu.gd 缺 @onready var _tab_controls (T086 4 tab Button 引用 3)")
		quit(1); return
	passed += 1
	print("  [T262.4.3] settings_menu.gd 含 _tab_controls Button 引用 (T086) (OK)")

	# ===== T262.4.4 _tab_saves Button =====
	total += 1
	if src_settings_menu.find("@onready var _tab_saves: Button = $VBoxContainer/TabRow/SavesTab") == -1:
		print("  FAIL [T262.4.4]: settings_menu.gd 缺 @onready var _tab_saves (T072 4 tab Button 引用 4)")
		quit(1); return
	passed += 1
	print("  [T262.4.4] settings_menu.gd 含 _tab_saves Button 引用 (T072) (OK)")

	# ===== T262.4.5 4 tab Button 顺序 (audio → video → controls → saves) =====
	total += 1
	var pos_audio_btn := src_settings_menu.find("@onready var _tab_audio: Button")
	var pos_video_btn := src_settings_menu.find("@onready var _tab_video: Button")
	var pos_controls_btn := src_settings_menu.find("@onready var _tab_controls: Button")
	var pos_saves_btn := src_settings_menu.find("@onready var _tab_saves: Button")
	if pos_audio_btn == -1 or pos_video_btn == -1 or pos_controls_btn == -1 or pos_saves_btn == -1:
		print("  FAIL [T262.4.5]: settings_menu.gd 4 tab Button 引用缺 1")
		quit(1); return
	if not (pos_audio_btn < pos_video_btn and pos_video_btn < pos_controls_btn and pos_controls_btn < pos_saves_btn):
		print("  FAIL [T262.4.5]: settings_menu.gd 4 tab Button 顺序错位 (期望 audio → video → controls → saves)")
		quit(1); return
	passed += 1
	print("  [T262.4.5] settings_menu.gd 4 tab Button 顺序正确 (audio → video → controls → saves) (OK)")

	# =================================================================
	# T262.5 — settings_menu.gd 4 panel Control @onready (5 断言)
	# =================================================================
	print("--- T262.5 — settings_menu.gd 4 panel Control @onready ---")

	# ===== T262.5.1 _audio_panel Control =====
	total += 1
	if src_settings_menu.find("@onready var _audio_panel: Control = $VBoxContainer/Content/AudioPanel") == -1:
		print("  FAIL [T262.5.1]: settings_menu.gd 缺 @onready var _audio_panel (T037 4 panel 引用 1)")
		quit(1); return
	passed += 1
	print("  [T262.5.1] settings_menu.gd 含 _audio_panel Control 引用 (T037) (OK)")

	# ===== T262.5.2 _video_panel Control =====
	total += 1
	if src_settings_menu.find("@onready var _video_panel: Control = $VBoxContainer/Content/VideoPanel") == -1:
		print("  FAIL [T262.5.2]: settings_menu.gd 缺 @onready var _video_panel (T037 4 panel 引用 2)")
		quit(1); return
	passed += 1
	print("  [T262.5.2] settings_menu.gd 含 _video_panel Control 引用 (T037) (OK)")

	# ===== T262.5.3 _controls_panel Control =====
	total += 1
	if src_settings_menu.find("@onready var _controls_panel: Control = $VBoxContainer/Content/ControlsPanel") == -1:
		print("  FAIL [T262.5.3]: settings_menu.gd 缺 @onready var _controls_panel (T086 4 panel 引用 3)")
		quit(1); return
	passed += 1
	print("  [T262.5.3] settings_menu.gd 含 _controls_panel Control 引用 (T086) (OK)")

	# ===== T262.5.4 _saves_panel Control =====
	total += 1
	if src_settings_menu.find("@onready var _saves_panel: Control = $VBoxContainer/Content/SavesPanel") == -1:
		print("  FAIL [T262.5.4]: settings_menu.gd 缺 @onready var _saves_panel (T072 4 panel 引用 4)")
		quit(1); return
	passed += 1
	print("  [T262.5.4] settings_menu.gd 含 _saves_panel Control 引用 (T072) (OK)")

	# ===== T262.5.5 4 panel 顺序 (audio → video → controls → saves) =====
	total += 1
	var pos_audio_panel := src_settings_menu.find("@onready var _audio_panel: Control")
	var pos_video_panel := src_settings_menu.find("@onready var _video_panel: Control")
	var pos_controls_panel := src_settings_menu.find("@onready var _controls_panel: Control")
	var pos_saves_panel := src_settings_menu.find("@onready var _saves_panel: Control")
	if pos_audio_panel == -1 or pos_video_panel == -1 or pos_controls_panel == -1 or pos_saves_panel == -1:
		print("  FAIL [T262.5.5]: settings_menu.gd 4 panel 引用缺 1")
		quit(1); return
	if not (pos_audio_panel < pos_video_panel and pos_video_panel < pos_controls_panel and pos_controls_panel < pos_saves_panel):
		print("  FAIL [T262.5.5]: settings_menu.gd 4 panel 顺序错位 (期望 audio → video → controls → saves)")
		quit(1); return
	passed += 1
	print("  [T262.5.5] settings_menu.gd 4 panel 顺序正确 (audio → video → controls → saves) (OK)")

	# =================================================================
	# T262.6 — settings_menu.gd 4 signal connect + 1 _switch_tab 函数 (5 断言)
	# =================================================================
	print("--- T262.6 — settings_menu.gd 4 signal connect + 1 _switch_tab 函数 ---")

	# ===== T262.6.1 _tab_audio signal connect lambda =====
	total += 1
	if src_settings_menu.find("_tab_audio.pressed.connect(func() -> void: _switch_tab(Tab.AUDIO))") == -1:
		print("  FAIL [T262.6.1]: settings_menu.gd 缺 _tab_audio signal connect lambda (T037)")
		quit(1); return
	passed += 1
	print("  [T262.6.1] settings_menu.gd 含 _tab_audio signal connect (T037) (OK)")

	# ===== T262.6.2 _tab_video signal connect lambda =====
	total += 1
	if src_settings_menu.find("_tab_video.pressed.connect(func() -> void: _switch_tab(Tab.VIDEO))") == -1:
		print("  FAIL [T262.6.2]: settings_menu.gd 缺 _tab_video signal connect lambda (T037)")
		quit(1); return
	passed += 1
	print("  [T262.6.2] settings_menu.gd 含 _tab_video signal connect (T037) (OK)")

	# ===== T262.6.3 _tab_controls signal connect lambda =====
	total += 1
	if src_settings_menu.find("_tab_controls.pressed.connect(func() -> void: _switch_tab(Tab.CONTROLS))") == -1:
		print("  FAIL [T262.6.3]: settings_menu.gd 缺 _tab_controls signal connect lambda (T086)")
		quit(1); return
	passed += 1
	print("  [T262.6.3] settings_menu.gd 含 _tab_controls signal connect (T086) (OK)")

	# ===== T262.6.4 _tab_saves signal connect lambda =====
	total += 1
	if src_settings_menu.find("_tab_saves.pressed.connect(func() -> void: _switch_tab(Tab.SAVES))") == -1:
		print("  FAIL [T262.6.4]: settings_menu.gd 缺 _tab_saves signal connect lambda (T072)")
		quit(1); return
	passed += 1
	print("  [T262.6.4] settings_menu.gd 含 _tab_saves signal connect (T072) (OK)")

	# ===== T262.6.5 _switch_tab 函数定义 =====
	total += 1
	if src_settings_menu.find("func _switch_tab(tab: Tab) -> void:") == -1:
		print("  FAIL [T262.6.5]: settings_menu.gd 缺 func _switch_tab(tab: Tab) (T037 7 步骤核心函数)")
		quit(1); return
	passed += 1
	print("  [T262.6.5] settings_menu.gd 含 _switch_tab 函数定义 (T037 7 步骤) (OK)")

	# =================================================================
	# T262.7 — settings_menu.gd _switch_tab 7 步骤关键结构 (5 断言)
	# =================================================================
	print("--- T262.7 — settings_menu.gd _switch_tab 7 步骤关键结构 ---")

	# ===== T262.7.1 _switch_tab 内 _current_tab = tab 状态同步 (步骤 1) =====
	total += 1
	var switch_tab_start := src_settings_menu.find("func _switch_tab(tab: Tab) -> void:")
	if switch_tab_start == -1:
		print("  FAIL [T262.7.1]: settings_menu.gd 缺 func _switch_tab 起点")
		quit(1); return
	# 找下一个 func 作为 _switch_tab 函数块边界
	var next_func_idx := src_settings_menu.find("\nfunc ", switch_tab_start + 1)
	if next_func_idx == -1:
		next_func_idx = src_settings_menu.length()
	var switch_tab_block := src_settings_menu.substr(switch_tab_start, next_func_idx - switch_tab_start)
	if switch_tab_block.find("_current_tab = tab") == -1:
		print("  FAIL [T262.7.1]: _switch_tab 函数体缺 _current_tab = tab (步骤 1 状态同步)")
		quit(1); return
	passed += 1
	print("  [T262.7.1] _switch_tab 含 _current_tab = tab 状态同步 (步骤 1) (OK)")

	# ===== T262.7.2 _switch_tab 内 4 panel 显隐 (步骤 2-5) =====
	total += 1
	if switch_tab_block.find("_audio_panel.visible = tab == Tab.AUDIO") == -1:
		print("  FAIL [T262.7.2]: _switch_tab 缺 _audio_panel 显隐 (步骤 2)")
		quit(1); return
	if switch_tab_block.find("_video_panel.visible = tab == Tab.VIDEO") == -1:
		print("  FAIL [T262.7.2]: _switch_tab 缺 _video_panel 显隐 (步骤 3)")
		quit(1); return
	if switch_tab_block.find("_controls_panel.visible = tab == Tab.CONTROLS") == -1:
		print("  FAIL [T262.7.2]: _switch_tab 缺 _controls_panel 显隐 (步骤 4)")
		quit(1); return
	if switch_tab_block.find("_saves_panel.visible = tab == Tab.SAVES") == -1:
		print("  FAIL [T262.7.2]: _switch_tab 缺 _saves_panel 显隐 (步骤 5)")
		quit(1); return
	passed += 1
	print("  [T262.7.2] _switch_tab 含 4 panel 显隐 (步骤 2-5) (OK)")

	# ===== T262.7.3 _switch_tab 内 4 button modulate 切换 (步骤 6) =====
	total += 1
	if switch_tab_block.find("_tab_audio.modulate = Color.WHITE if tab == Tab.AUDIO else Color(0.5, 0.5, 0.5)") == -1:
		print("  FAIL [T262.7.3]: _switch_tab 缺 _tab_audio modulate 切换 (步骤 6.1)")
		quit(1); return
	if switch_tab_block.find("_tab_video.modulate = Color.WHITE if tab == Tab.VIDEO else Color(0.5, 0.5, 0.5)") == -1:
		print("  FAIL [T262.7.3]: _switch_tab 缺 _tab_video modulate 切换 (步骤 6.2)")
		quit(1); return
	if switch_tab_block.find("_tab_controls.modulate = Color.WHITE if tab == Tab.CONTROLS else Color(0.5, 0.5, 0.5)") == -1:
		print("  FAIL [T262.7.3]: _switch_tab 缺 _tab_controls modulate 切换 (步骤 6.3)")
		quit(1); return
	if switch_tab_block.find("_tab_saves.modulate = Color.WHITE if tab == Tab.SAVES else Color(0.5, 0.5, 0.5)") == -1:
		print("  FAIL [T262.7.3]: _switch_tab 缺 _tab_saves modulate 切换 (步骤 6.4)")
		quit(1); return
	passed += 1
	print("  [T262.7.3] _switch_tab 含 4 button modulate 切换 (步骤 6) (OK)")

	# ===== T262.7.4 _switch_tab 内 Saves side effect (步骤 7) =====
	total += 1
	if switch_tab_block.find("if tab == Tab.SAVES:") == -1 or switch_tab_block.find("_refresh_save_count()") == -1:
		print("  FAIL [T262.7.4]: _switch_tab 缺 Saves side effect (步骤 7 刷存档计数)")
		quit(1); return
	passed += 1
	print("  [T262.7.4] _switch_tab 含 Saves side effect (步骤 7 刷存档计数) (OK)")

	# ===== T262.7.5 _switch_tab 7 步骤顺序 (状态 → panel 显隐 → button modulate → side effect) =====
	total += 1
	var pos_state := switch_tab_block.find("_current_tab = tab")
	var pos_panel_audio := switch_tab_block.find("_audio_panel.visible = tab == Tab.AUDIO")
	var pos_btn_audio := switch_tab_block.find("_tab_audio.modulate = Color.WHITE if tab == Tab.AUDIO else Color(0.5, 0.5, 0.5)")
	var pos_side_effect := switch_tab_block.find("if tab == Tab.SAVES:")
	if not (pos_state < pos_panel_audio and pos_panel_audio < pos_btn_audio and pos_btn_audio < pos_side_effect):
		print("  FAIL [T262.7.5]: _switch_tab 7 步骤顺序错位 (期望 状态 → panel → button → side effect)")
		quit(1); return
	passed += 1
	print("  [T262.7.5] _switch_tab 7 步骤顺序正确 (状态 → panel → button → side effect) (OK)")

	# =================================================================
	# T262.8 — settings_menu.gd _ready 末尾初始渲染 _switch_tab(Tab.AUDIO) (2 断言)
	# =================================================================
	print("--- T262.8 — settings_menu.gd _ready 末尾初始渲染 ---")

	# ===== T262.8.1 _ready 末尾含 _switch_tab(Tab.AUDIO) 初始渲染 =====
	total += 1
	var ready_start := src_settings_menu.find("func _ready() -> void:")
	if ready_start == -1:
		print("  FAIL [T262.8.1]: settings_menu.gd 缺 func _ready 起点")
		quit(1); return
	var ready_next_func := src_settings_menu.find("\nfunc ", ready_start + 1)
	if ready_next_func == -1:
		ready_next_func = src_settings_menu.length()
	var ready_block := src_settings_menu.substr(ready_start, ready_next_func - ready_start)
	if ready_block.find("_switch_tab(Tab.AUDIO)") == -1:
		print("  FAIL [T262.8.1]: settings_menu.gd _ready 末尾缺 _switch_tab(Tab.AUDIO) 初始渲染")
		quit(1); return
	passed += 1
	print("  [T262.8.1] _ready 末尾含 _switch_tab(Tab.AUDIO) 初始渲染 (OK)")

	# ===== T262.8.2 _switch_tab(Tab.AUDIO) 在 _ready 末尾 (position 接近 _ready 末尾) =====
	total += 1
	var pos_switch_in_ready := ready_block.rfind("_switch_tab(Tab.AUDIO)")
	if pos_switch_in_ready == -1:
		print("  FAIL [T262.8.2]: _ready 块内 _switch_tab(Tab.AUDIO) 位置 0 找")
		quit(1); return
	# 应该在 _ready 块的后 1/3 区域 (长度 / 2 < pos < 长度)
	if pos_switch_in_ready < ready_block.length() / 2:
		print("  FAIL [T262.8.2]: _switch_tab(Tab.AUDIO) 不在 _ready 末尾区域")
		quit(1); return
	passed += 1
	print("  [T262.8.2] _switch_tab(Tab.AUDIO) 在 _ready 末尾区域 (OK)")

	# =================================================================
	# T262.9 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T262.9 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T262.9.1 CHANGELOG.md 含 #183 段 =====
	total += 1
	if src_changelog.find("## #183 — T262") == -1 and src_changelog_archive.find("## #183 — T262") == -1:
		print("  FAIL [T262.9.1]: CHANGELOG.md 缺 #183 段")
		quit(1); return
	passed += 1
	print("  [T262.9.1] CHANGELOG.md 含 #183 段 (OK)")

	# ===== T262.9.2 ROADMAP.md 顶部时间戳含 #183 =====
	total += 1
	if src_roadmap.find("#183") == -1:
		print("  FAIL [T262.9.2]: ROADMAP.md 顶部缺 #183 时间戳")
		quit(1); return
	passed += 1
	print("  [T262.9.2] ROADMAP.md 顶部含 #183 时间戳 (OK)")

	print("=== T262 #183 §9.6.12 4 tab 状态机 (Tab 枚举 + 1 状态字段 + 4 tab Button + 4 panel + 4 signal connect + _switch_tab 7 步骤 + 初始渲染 1 行) 7 件套 polish 模式 (T037 + T072 + T086 + T134 + T202.B 跨 5 任务 ~20 轮落地) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
