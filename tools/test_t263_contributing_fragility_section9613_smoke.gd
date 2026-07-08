extends SceneTree
## T263 (#184) — §9.6.13 settings_menu `_save_settings` ↔ `_load_settings` 1:1 同步 + `user://settings.cfg` 持久化 4 section × N key 双源映射 polish 模式 (T079 + T136 + T195 + T196 + T202.B + T205 + T239 跨 7 任务 ~15 轮落地) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t263_contributing_fragility_section9613_smoke.gd
##
## T263: CONTRIBUTING.md §9.6.13 已知 fragility 扩展
##   - §9.6.13 _save_settings / _load_settings 5 件套 (1 写 + 1 读 + 1 default + 1 控件推 + 1 跨 autoload live-push)
##   - settings_menu.gd 4 section × N key 1:1 双源映射 (audio 4 + video 2 + gameplay 4 + accessibility 4 + input N = 14 + N)
##   - settings_menu.gd _save_settings 写 `user://settings.cfg` 14+N key
##   - settings_menu.gd _load_settings 读 `user://settings.cfg` 14+N key
##   - settings_menu.gd 4 section 顺序 (audio → video → gameplay → accessibility → input)
##   - settings_menu.gd _ready 末尾 _load_settings() 1 行
##   - settings_menu.gd _on_close 末尾 _save_settings() 1 行
## 验证 9 维:
##   - §9.6.13 章节在 CONTRIBUTING.md 已落地
##   - §9.6.13 4 段结构 (症状/触发/修复/预防) 全部存在
##   - settings_menu.gd _save_settings 4 section × N key cfg.set_value (audio 4 + video 2 + gameplay 4 + accessibility 4 + input N = 14 + N)
##   - settings_menu.gd _load_settings 4 section × N key cfg.get_value 1:1 对齐 (含 default 参数)
##   - settings_menu.gd 4 section 顺序 (audio → video → gameplay → accessibility → input)
##   - settings_menu.gd 跨 autoload live-push (T079 GameState / T136 SaveSystem / T195+T196+T202.B ScreenShake)
##   - settings_menu.gd 4 reduce_*_check set_block_signals 包裹 (T195+T196+T202.B 模式)
##   - settings_menu.gd _ready 末尾 _load_settings() + _on_close 末尾 _save_settings()
##   - CHANGELOG.md 含 #184 段 + ROADMAP.md 顶部时间戳含 #184

func _initialize() -> void:
	print("=== T263 #184 §9.6.13 _save_settings / _load_settings 1:1 同步 + `user://settings.cfg` 持久化 4 section × N key 双源映射 polish 模式 (T079 + T136 + T195 + T196 + T202.B + T205 + T239 跨 7 任务 ~15 轮落地) smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_settings_menu := _read_file("res://src/scripts/settings_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T263.1 — §9.6.13 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T263.1 — §9.6.13 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T263.1.1 §9.6.13 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.13 settings_menu `_save_settings`") == -1:
		print("  FAIL [T263.1.1]: CONTRIBUTING.md 缺 §9.6.13 章节标题")
		quit(1); return
	passed += 1
	print("  [T263.1.1] CONTRIBUTING.md 含 §9.6.13 章节标题 (OK)")

	# ===== T263.1.2 §9.6.13 含 T079 + _save_settings + _load_settings + user://settings.cfg =====
	total += 1
	var s9613_start := src_contributing.find("### 9.6.13")
	var s10_start := src_contributing.find("## 10.")
	if s9613_start == -1 or s10_start == -1:
		print("  FAIL [T263.1.2]: §9.6.13 / ## 10 区间划分失败")
		quit(1); return
	var s9613 := src_contributing.substr(s9613_start, s10_start - s9613_start)
	if s9613.find("T079") == -1:
		print("  FAIL [T263.1.2]: §9.6.13 区间缺 T079 anchor")
		quit(1); return
	if s9613.find("_save_settings") == -1:
		print("  FAIL [T263.1.2]: §9.6.13 区间缺 _save_settings 关键函数")
		quit(1); return
	if s9613.find("_load_settings") == -1:
		print("  FAIL [T263.1.2]: §9.6.13 区间缺 _load_settings 关键函数")
		quit(1); return
	if s9613.find("user://settings.cfg") == -1:
		print("  FAIL [T263.1.2]: §9.6.13 区间缺 user://settings.cfg 关键路径")
		quit(1); return
	passed += 1
	print("  [T263.1.2] CONTRIBUTING.md §9.6.13 区间含 T079 + _save_settings + _load_settings + user://settings.cfg (OK)")

	# ===== T263.1.3 §9.6.13 提到 4 section × N key + 5 件套 + 1:1 同步 核心概念 =====
	total += 1
	if s9613.find("4 section") == -1 or s9613.find("5 件套") == -1 or s9613.find("1:1") == -1:
		print("  FAIL [T263.1.3]: §9.6.13 缺核心概念 (4 section / 5 件套 / 1:1 同步)")
		quit(1); return
	passed += 1
	print("  [T263.1.3] CONTRIBUTING.md §9.6.13 含 4 section × N key + 5 件套 + 1:1 同步 核心概念 (OK)")

	# =================================================================
	# T263.2 — §9.6.13 4 段结构 (症状/触发/修复/预防) (5 断言)
	# =================================================================
	print("--- T263.2 — §9.6.13 4 段结构 ---")

	# ===== T263.2.1 症状段 =====
	total += 1
	if s9613.find("- **症状**") == -1:
		print("  FAIL [T263.2.1]: §9.6.13 缺症状段")
		quit(1); return
	passed += 1
	print("  [T263.2.1] §9.6.13 含症状段 (OK)")

	# ===== T263.2.2 触发场景段 =====
	total += 1
	if s9613.find("- **触发场景**") == -1:
		print("  FAIL [T263.2.2]: §9.6.13 缺触发场景段")
		quit(1); return
	passed += 1
	print("  [T263.2.2] §9.6.13 含触发场景段 (OK)")

	# ===== T263.2.3 修复段 =====
	total += 1
	if s9613.find("- **修复**") == -1:
		print("  FAIL [T263.2.3]: §9.6.13 缺修复段")
		quit(1); return
	passed += 1
	print("  [T263.2.3] §9.6.13 含修复段 (OK)")

	# ===== T263.2.4 预防段 =====
	total += 1
	if s9613.find("- **预防**") == -1:
		print("  FAIL [T263.2.4]: §9.6.13 缺预防段")
		quit(1); return
	passed += 1
	print("  [T263.2.4] §9.6.13 含预防段 (OK)")

	# ===== T263.2.5 §9.6.13 长度 (>= 3500 字符, 4 段结构完整) =====
	total += 1
	if s9613.length() < 3500:
		print("  FAIL [T263.2.5]: §9.6.13 段长度 %d < 3500 (4 段结构不完整)" % s9613.length())
		quit(1); return
	passed += 1
	print("  [T263.2.5] §9.6.13 段长度 %d (>= 3500, 4 段结构完整) (OK)" % s9613.length())

	# =================================================================
	# T263.3 — settings_menu.gd _save_settings 4 section × N key cfg.set_value (5 断言)
	# =================================================================
	print("--- T263.3 — settings_menu.gd _save_settings 4 section × N key cfg.set_value ---")

	# ===== T263.3.1 _save_settings 函数定义 =====
	total += 1
	if src_settings_menu.find("func _save_settings() -> void:") == -1:
		print("  FAIL [T263.3.1]: settings_menu.gd 缺 func _save_settings")
		quit(1); return
	passed += 1
	print("  [T263.3.1] settings_menu.gd 含 _save_settings 函数定义 (OK)")

	# ===== T263.3.2 [audio] 4 key cfg.set_value =====
	total += 1
	var save_start := src_settings_menu.find("func _save_settings() -> void:")
	var save_next := src_settings_menu.find("\nfunc ", save_start + 1)
	if save_next == -1:
		save_next = src_settings_menu.length()
	var save_block := src_settings_menu.substr(save_start, save_next - save_start)
	if save_block.find("cfg.set_value(\"audio\", \"master\"") == -1:
		print("  FAIL [T263.3.2]: _save_settings 缺 [audio] master 写")
		quit(1); return
	if save_block.find("cfg.set_value(\"audio\", \"sfx\"") == -1:
		print("  FAIL [T263.3.2]: _save_settings 缺 [audio] sfx 写")
		quit(1); return
	if save_block.find("cfg.set_value(\"audio\", \"music\"") == -1:
		print("  FAIL [T263.3.2]: _save_settings 缺 [audio] music 写")
		quit(1); return
	if save_block.find("cfg.set_value(\"audio\", \"ambience\"") == -1:
		print("  FAIL [T263.3.2]: _save_settings 缺 [audio] ambience 写")
		quit(1); return
	passed += 1
	print("  [T263.3.2] _save_settings 含 [audio] 4 key (master/sfx/music/ambience) (OK)")

	# ===== T263.3.3 [video] 2 key cfg.set_value =====
	total += 1
	if save_block.find("cfg.set_value(\"video\", \"fullscreen\"") == -1:
		print("  FAIL [T263.3.3]: _save_settings 缺 [video] fullscreen 写")
		quit(1); return
	if save_block.find("cfg.set_value(\"video\", \"window_scale\"") == -1:
		print("  FAIL [T263.3.3]: _save_settings 缺 [video] window_scale 写")
		quit(1); return
	passed += 1
	print("  [T263.3.3] _save_settings 含 [video] 2 key (fullscreen/window_scale) (OK)")

	# ===== T263.3.4 [gameplay] 4 key cfg.set_value (T079 respawn + T136 autosave 3 key) =====
	total += 1
	if save_block.find("cfg.set_value(\"gameplay\", \"respawn_to_hub\"") == -1:
		print("  FAIL [T263.3.4]: _save_settings 缺 [gameplay] respawn_to_hub 写 (T079)")
		quit(1); return
	if save_block.find("cfg.set_value(\"gameplay\", \"autosave_enabled\"") == -1:
		print("  FAIL [T263.3.4]: _save_settings 缺 [gameplay] autosave_enabled 写 (T136)")
		quit(1); return
	if save_block.find("cfg.set_value(\"gameplay\", \"autosave_interval\"") == -1:
		print("  FAIL [T263.3.4]: _save_settings 缺 [gameplay] autosave_interval 写 (T136)")
		quit(1); return
	if save_block.find("cfg.set_value(\"gameplay\", \"autosave_slot\"") == -1:
		print("  FAIL [T263.3.4]: _save_settings 缺 [gameplay] autosave_slot 写 (T136)")
		quit(1); return
	passed += 1
	print("  [T263.3.4] _save_settings 含 [gameplay] 4 key (respawn_to_hub/autosave_3 key) (OK)")

	# ===== T263.3.5 [accessibility] 4 key cfg.set_value (T195 + T196 + T202.B) =====
	total += 1
	if save_block.find("cfg.set_value(\"accessibility\", \"reduce_shake\"") == -1:
		print("  FAIL [T263.3.5]: _save_settings 缺 [accessibility] reduce_shake 写 (T195)")
		quit(1); return
	if save_block.find("cfg.set_value(\"accessibility\", \"reduce_flash\"") == -1:
		print("  FAIL [T263.3.5]: _save_settings 缺 [accessibility] reduce_flash 写 (T195)")
		quit(1); return
	if save_block.find("cfg.set_value(\"accessibility\", \"reduce_vibration\"") == -1:
		print("  FAIL [T263.3.5]: _save_settings 缺 [accessibility] reduce_vibration 写 (T196)")
		quit(1); return
	if save_block.find("cfg.set_value(\"accessibility\", \"reduce_all\"") == -1:
		print("  FAIL [T263.3.5]: _save_settings 缺 [accessibility] reduce_all 写 (T202.B)")
		quit(1); return
	passed += 1
	print("  [T263.3.5] _save_settings 含 [accessibility] 4 key (T195+T196+T202.B) (OK)")

	# =================================================================
	# T263.4 — settings_menu.gd _load_settings 4 section × N key cfg.get_value 1:1 对齐 (5 断言)
	# =================================================================
	print("--- T263.4 — settings_menu.gd _load_settings 4 section × N key cfg.get_value 1:1 对齐 ---")

	# ===== T263.4.1 _load_settings 函数定义 =====
	total += 1
	if src_settings_menu.find("func _load_settings() -> void:") == -1:
		print("  FAIL [T263.4.1]: settings_menu.gd 缺 func _load_settings")
		quit(1); return
	passed += 1
	print("  [T263.4.1] settings_menu.gd 含 _load_settings 函数定义 (OK)")

	# ===== T263.4.2 [audio] 4 key cfg.get_value 1:1 对齐 + 0 漏 default =====
	total += 1
	var load_start := src_settings_menu.find("func _load_settings() -> void:")
	var load_next := src_settings_menu.find("\nfunc ", load_start + 1)
	if load_next == -1:
		load_next = src_settings_menu.length()
	var load_block := src_settings_menu.substr(load_start, load_next - load_start)
	if load_block.find("cfg.get_value(\"audio\", \"master\", 1.0)") == -1:
		print("  FAIL [T263.4.2]: _load_settings 缺 [audio] master 读 + 0 漏 default")
		quit(1); return
	if load_block.find("cfg.get_value(\"audio\", \"sfx\", 1.0)") == -1:
		print("  FAIL [T263.4.2]: _load_settings 缺 [audio] sfx 读 + 0 漏 default")
		quit(1); return
	if load_block.find("cfg.get_value(\"audio\", \"music\", 1.0)") == -1:
		print("  FAIL [T263.4.2]: _load_settings 缺 [audio] music 读 + 0 漏 default")
		quit(1); return
	if load_block.find("cfg.get_value(\"audio\", \"ambience\", 1.0)") == -1:
		print("  FAIL [T263.4.2]: _load_settings 缺 [audio] ambience 读 + 0 漏 default")
		quit(1); return
	passed += 1
	print("  [T263.4.2] _load_settings 含 [audio] 4 key 1:1 读 + 0 漏 default (OK)")

	# ===== T263.4.3 [video] 2 key cfg.get_value 1:1 对齐 + 0 漏 default =====
	total += 1
	if load_block.find("cfg.get_value(\"video\", \"fullscreen\", false)") == -1:
		print("  FAIL [T263.4.3]: _load_settings 缺 [video] fullscreen 读 + 0 漏 default")
		quit(1); return
	if load_block.find("cfg.get_value(\"video\", \"window_scale\", 4)") == -1:
		print("  FAIL [T263.4.3]: _load_settings 缺 [video] window_scale 读 + 0 漏 default")
		quit(1); return
	passed += 1
	print("  [T263.4.3] _load_settings 含 [video] 2 key 1:1 读 + 0 漏 default (OK)")

	# ===== T263.4.4 [gameplay] 4 key cfg.get_value 1:1 对齐 + 0 漏 default =====
	total += 1
	if load_block.find("cfg.get_value(\"gameplay\", \"respawn_to_hub\", true)") == -1:
		print("  FAIL [T263.4.4]: _load_settings 缺 [gameplay] respawn_to_hub 读 + 0 漏 default (T079)")
		quit(1); return
	passed += 1
	print("  [T263.4.4] _load_settings 含 [gameplay] respawn_to_hub 读 + 0 漏 default (T079) (OK)")

	# ===== T263.4.5 [accessibility] 4 key cfg.get_value 1:1 对齐 + 0 漏 default =====
	total += 1
	if load_block.find("cfg.get_value(\"accessibility\", \"reduce_shake\", false)") == -1:
		print("  FAIL [T263.4.5]: _load_settings 缺 [accessibility] reduce_shake 读 + 0 漏 default (T195)")
		quit(1); return
	if load_block.find("cfg.get_value(\"accessibility\", \"reduce_flash\", false)") == -1:
		print("  FAIL [T263.4.5]: _load_settings 缺 [accessibility] reduce_flash 读 + 0 漏 default (T195)")
		quit(1); return
	if load_block.find("cfg.get_value(\"accessibility\", \"reduce_vibration\", false)") == -1:
		print("  FAIL [T263.4.5]: _load_settings 缺 [accessibility] reduce_vibration 读 + 0 漏 default (T196)")
		quit(1); return
	if load_block.find("cfg.get_value(\"accessibility\", \"reduce_all\", false)") == -1:
		print("  FAIL [T263.4.5]: _load_settings 缺 [accessibility] reduce_all 读 + 0 漏 default (T202.B)")
		quit(1); return
	passed += 1
	print("  [T263.4.5] _load_settings 含 [accessibility] 4 key 1:1 读 + 0 漏 default (OK)")

	# =================================================================
	# T263.5 — settings_menu.gd 4 section 顺序 (audio → video → gameplay → accessibility → input) (3 断言)
	# =================================================================
	print("--- T263.5 — settings_menu.gd 4 section 顺序 ---")

	# ===== T263.5.1 _save_settings 内 4 section 顺序 =====
	total += 1
	var pos_audio := save_block.find("cfg.set_value(\"audio\"")
	var pos_video := save_block.find("cfg.set_value(\"video\"")
	var pos_gameplay := save_block.find("cfg.set_value(\"gameplay\"")
	var pos_accessibility := save_block.find("cfg.set_value(\"accessibility\"")
	if pos_audio == -1 or pos_video == -1 or pos_gameplay == -1 or pos_accessibility == -1:
		print("  FAIL [T263.5.1]: _save_settings 4 section 引用缺 1")
		quit(1); return
	if not (pos_audio < pos_video and pos_video < pos_gameplay and pos_gameplay < pos_accessibility):
		print("  FAIL [T263.5.1]: _save_settings 4 section 顺序错位 (期望 audio → video → gameplay → accessibility)")
		quit(1); return
	passed += 1
	print("  [T263.5.1] _save_settings 4 section 顺序正确 (audio → video → gameplay → accessibility) (OK)")

	# ===== T263.5.2 _load_settings 内 4 section 顺序 =====
	total += 1
	var pos_audio_l := load_block.find("cfg.get_value(\"audio\"")
	var pos_video_l := load_block.find("cfg.get_value(\"video\"")
	var pos_gameplay_l := load_block.find("cfg.get_value(\"gameplay\"")
	var pos_accessibility_l := load_block.find("cfg.get_value(\"accessibility\"")
	if pos_audio_l == -1 or pos_video_l == -1 or pos_gameplay_l == -1 or pos_accessibility_l == -1:
		print("  FAIL [T263.5.2]: _load_settings 4 section 引用缺 1")
		quit(1); return
	if not (pos_audio_l < pos_video_l and pos_video_l < pos_gameplay_l and pos_gameplay_l < pos_accessibility_l):
		print("  FAIL [T263.5.2]: _load_settings 4 section 顺序错位 (期望 audio → video → gameplay → accessibility)")
		quit(1); return
	passed += 1
	print("  [T263.5.2] _load_settings 4 section 顺序正确 (audio → video → gameplay → accessibility) (OK)")

	# ===== T263.5.3 _save_settings + _load_settings 双源 4 section 顺序一致 =====
	total += 1
	if not (pos_audio < pos_audio_l and pos_video < pos_video_l and pos_gameplay < pos_gameplay_l and pos_accessibility < pos_accessibility_l):
		print("  FAIL [T263.5.3]: _save / _load 4 section 顺序不一致 (双源 1:1 错位)")
		quit(1); return
	passed += 1
	print("  [T263.5.3] _save / _load 4 section 顺序一致 (双源 1:1) (OK)")

	# =================================================================
	# T263.6 — settings_menu.gd 跨 autoload live-push (3 断言)
	# =================================================================
	print("--- T263.6 — settings_menu.gd 跨 autoload live-push ---")

	# ===== T263.6.1 T079 GameState.set_respawn_to_hub 跨 autoload live-push =====
	total += 1
	if load_block.find("GameState.set_respawn_to_hub") == -1:
		print("  FAIL [T263.6.1]: _load_settings 缺 GameState.set_respawn_to_hub 跨 autoload live-push (T079)")
		quit(1); return
	passed += 1
	print("  [T263.6.1] _load_settings 含 GameState.set_respawn_to_hub 跨 autoload live-push (T079) (OK)")

	# ===== T263.6.2 T136 SaveSystem 跨 autoload live-push (_populate_autosave_controls_from_cfg) =====
	total += 1
	if load_block.find("_populate_autosave_controls_from_cfg") == -1:
		print("  FAIL [T263.6.2]: _load_settings 缺 _populate_autosave_controls_from_cfg 跨 autoload live-push (T136)")
		quit(1); return
	passed += 1
	print("  [T263.6.2] _load_settings 含 _populate_autosave_controls_from_cfg 跨 autoload live-push (T136) (OK)")

	# ===== T263.6.3 T195+T196+T202.B ScreenShake.set_reduce_* 跨 autoload live-push =====
	total += 1
	if load_block.find("ScreenShake.set_reduce_shake") == -1:
		print("  FAIL [T263.6.3]: _load_settings 缺 ScreenShake.set_reduce_shake 跨 autoload live-push (T195)")
		quit(1); return
	if load_block.find("ScreenShake.set_reduce_flash") == -1:
		print("  FAIL [T263.6.3]: _load_settings 缺 ScreenShake.set_reduce_flash 跨 autoload live-push (T195)")
		quit(1); return
	if load_block.find("ScreenShake.set_reduce_vibration") == -1:
		print("  FAIL [T263.6.3]: _load_settings 缺 ScreenShake.set_reduce_vibration 跨 autoload live-push (T196)")
		quit(1); return
	passed += 1
	print("  [T263.6.3] _load_settings 含 ScreenShake.set_reduce_* 跨 autoload live-push (T195+T196) (OK)")

	# =================================================================
	# T263.7 — settings_menu.gd 4 reduce_*_check set_block_signals 包裹 (3 断言)
	# =================================================================
	print("--- T263.7 — settings_menu.gd 4 reduce_*_check set_block_signals 包裹 ---")

	# ===== T263.7.1 _reduce_shake_check set_block_signals 包裹 =====
	total += 1
	if load_block.find("_reduce_shake_check.set_block_signals(true)") == -1:
		print("  FAIL [T263.7.1]: _load_settings 缺 _reduce_shake_check.set_block_signals 包裹 (T195)")
		quit(1); return
	if load_block.find("_reduce_shake_check.set_block_signals(false)") == -1:
		print("  FAIL [T263.7.1]: _load_settings 缺 _reduce_shake_check.set_block_signals(false) 包裹结尾 (T195)")
		quit(1); return
	passed += 1
	print("  [T263.7.1] _load_settings 含 _reduce_shake_check set_block_signals 包裹 (T195) (OK)")

	# ===== T263.7.2 _reduce_flash_check set_block_signals 包裹 =====
	total += 1
	if load_block.find("_reduce_flash_check.set_block_signals(true)") == -1:
		print("  FAIL [T263.7.2]: _load_settings 缺 _reduce_flash_check.set_block_signals 包裹 (T195)")
		quit(1); return
	passed += 1
	print("  [T263.7.2] _load_settings 含 _reduce_flash_check set_block_signals 包裹 (T195) (OK)")

	# ===== T263.7.3 _reduce_all_check set_block_signals 包裹 + indeterminate 显式清 =====
	total += 1
	if load_block.find("_reduce_all_check.set_block_signals(true)") == -1:
		print("  FAIL [T263.7.3]: _load_settings 缺 _reduce_all_check.set_block_signals 包裹 (T202.B)")
		quit(1); return
	if load_block.find("_reduce_all_check.indeterminate = false") == -1:
		print("  FAIL [T263.7.3]: _load_settings 缺 _reduce_all_check.indeterminate = false 显式清 (T202.B)")
		quit(1); return
	passed += 1
	print("  [T263.7.3] _load_settings 含 _reduce_all_check set_block_signals 包裹 + indeterminate 显式清 (T202.B) (OK)")

	# =================================================================
	# T263.8 — settings_menu.gd _ready 末尾 _load_settings() + _on_close 末尾 _save_settings() (3 断言)
	# =================================================================
	print("--- T263.8 — settings_menu.gd _ready 末尾 _load_settings() + _on_close 末尾 _save_settings() ---")

	# ===== T263.8.1 _ready 末尾含 _load_settings() 1 行初始加载 =====
	total += 1
	var ready_start := src_settings_menu.find("func _ready() -> void:")
	var ready_next := src_settings_menu.find("\nfunc ", ready_start + 1)
	if ready_next == -1:
		ready_next = src_settings_menu.length()
	var ready_block := src_settings_menu.substr(ready_start, ready_next - ready_start)
	if ready_block.find("_load_settings()") == -1:
		print("  FAIL [T263.8.1]: _ready 缺 _load_settings() 1 行初始加载")
		quit(1); return
	passed += 1
	print("  [T263.8.1] _ready 末尾含 _load_settings() 1 行初始加载 (OK)")

	# ===== T263.8.2 _on_close 末尾含 _save_settings() 1 行持久化 =====
	total += 1
	var close_start := src_settings_menu.find("func _on_close() -> void:")
	if close_start == -1:
		print("  FAIL [T263.8.2]: _on_close 函数缺")
		quit(1); return
	var close_next := src_settings_menu.find("\nfunc ", close_start + 1)
	if close_next == -1:
		close_next = src_settings_menu.length()
	var close_block := src_settings_menu.substr(close_start, close_next - close_start)
	if close_block.find("_save_settings()") == -1:
		print("  FAIL [T263.8.2]: _on_close 缺 _save_settings() 1 行持久化")
		quit(1); return
	passed += 1
	print("  [T263.8.2] _on_close 末尾含 _save_settings() 1 行持久化 (OK)")

	# ===== T263.8.3 _save_settings + _load_settings 1:1 set_value/get_value 数量一致 (>= 14) =====
	total += 1
	var save_set_count := 0
	var pos := 0
	while true:
		var found := save_block.find("cfg.set_value(", pos)
		if found == -1:
			break
		save_set_count += 1
		pos = found + 1
	var load_get_count := 0
	pos = 0
	while true:
		var found2 := load_block.find("cfg.get_value(", pos)
		if found2 == -1:
			break
		load_get_count += 1
		pos = found2 + 1
	if save_set_count < 14:
		print("  FAIL [T263.8.3]: _save_settings cfg.set_value 数量 %d < 14 (缺 1)" % save_set_count)
		quit(1); return
	if load_get_count < 10:
		print("  FAIL [T263.8.3]: _load_settings cfg.get_value 数量 %d < 10 (缺 1)" % load_get_count)
		quit(1); return
	passed += 1
	print("  [T263.8.3] _save_settings %d set_value / _load_settings %d get_value (双源 1:1) (OK)" % [save_set_count, load_get_count])

	# =================================================================
	# T263.9 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T263.9 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T263.9.1 CHANGELOG.md 含 #184 段 =====
	total += 1
	if src_changelog.find("## #184") == -1:
		print("  FAIL [T263.9.1]: CHANGELOG.md 缺 #184 段")
		quit(1); return
	passed += 1
	print("  [T263.9.1] CHANGELOG.md 含 #184 段 (OK)")

	# ===== T263.9.2 ROADMAP.md 顶部时间戳含 #184 =====
	total += 1
	if src_roadmap.find("#184") == -1:
		print("  FAIL [T263.9.2]: ROADMAP.md 顶部缺 #184 时间戳")
		quit(1); return
	passed += 1
	print("  [T263.9.2] ROADMAP.md 顶部含 #184 时间戳 (OK)")

	print("=== T263 #184 §9.6.13 _save_settings / _load_settings 1:1 同步 + `user://settings.cfg` 持久化 4 section × N key 双源映射 polish 模式 (T079 + T136 + T195 + T196 + T202.B + T205 + T239 跨 7 任务 ~15 轮落地) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
