extends SceneTree
## I016 (#104) — T186 perk level-up warm flash + F016 death lay-down SFX 冒烟测试
##
## 覆盖 #104 二任务原子化提交:
##
## === T186 — Shop perk 升档 I→II unlock 暖色光晕 (与 T185 屏抖对偶) ===
## - T186.SHOP.FLASH_HAS_METHOD: shop_menu 用 has_method("flash_color") 守卫
## - T186.SHOP.FLASH_CALL: shop_menu._on_buy_pressed 调 ScreenShake.flash_color(...)
## - T186.SHOP.COLOR: Color(0.902, 0.835, 0.722, 1.0) Warm Parchment #E6D5B8
## - T186.SHOP.DUR: duration 0.5s (与 SaveLoadMenu unlock flash T128 对齐)
## - T186.SHOP.PEAK: peak_alpha 0.18
## - T186.SHOP.LAYER: flash_layer 256 (屏抖之上, 不与 hit flash 128 互消)
## - T186.SHOP.DOC: shop_menu 注释含 T186 (#104) 锚点
## - T186.SHOP.THRESHOLD: 阈值 new_count >= 2 (与 T185 同步, level 0=I 不闪)
##
## === F016 — Death lay-down "听见坠落" 0.4s 75Hz sub-bass 嗡鸣 ===
## - F016.FIELD: _death_lay_down_stream: AudioStreamWAV 字段声明
## - F016.PLAY.SIG: play_death_lay_down() 公开方法已声明
## - F016.PLAY.LAZY: lazy-init 守卫 (null → 生成)
## - F016.PLAY.BUS: play_sfx(_death_lay_down_stream) 走 SFX bus
## - F016.GEN.SIG: _generate_death_lay_down_sfx() 私有 synth
## - F016.GEN.FREQ: 75.0Hz sub-bass 基频 (D2)
## - F016.GEN.OVERTONE1: 1.5x = 112.5Hz (D3)
## - F016.GEN.OVERTONE2: 2.5x = 187.5Hz (F3)
## - F016.GEN.DUR: 0.4s duration (与 lay-down 0.5s 完美匹配)
## - F016.GEN.AMP: 0.28 amplitude (比 delete 0.20 强, < verb fire 0.30-0.40)
## - F016.PLAYER.HAS_METHOD: player.gd 用 has_method("play_death_lay_down") 守卫
## - F016.PLAYER.CALL: player.gd.die() 调 ame.play_death_lay_down()
## - F016.PLAYER.DOC: player.gd 注释含 F016 (#104) 锚点
## - F016.PRE.CALL: prewarm_misc_sfx 调 _generate_death_lay_down_sfx() (F016 集成)

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const SHOP_MENU_GD := "res://src/scripts/shop_menu.gd"
const PLAYER_GD := "res://src/scripts/player.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I016 (#104) — T186 perk level-up warm flash + F016 death lay-down SFX ===")
	_run_t186_shop_flash_assertions()
	_run_f016_field_assertions()
	_run_f016_play_api_assertions()
	_run_f016_gen_synth_assertions()
	_run_f016_player_integration_assertions()
	_run_f016_prewarm_integration_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I016 (#104) T186 + F016 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T186 — Shop perk level-up warm flash =====================

# ---------- T186.SHOP.* — shop_menu 暖色光晕 接入 ----------
func _run_t186_shop_flash_assertions() -> void:
	print("--- T186.SHOP.* — shop_menu 暖色光晕 接入 ---")
	var src := _read_file(SHOP_MENU_GD)
	_assert_contains(src, "ScreenShake.has_method(\"flash_color\")",
		"T186.SHOP.FLASH_HAS_METHOD.1: shop_menu 用 has_method(\"flash_color\") 守卫 (headless-safe)")
	_assert_contains(src, "ScreenShake.flash_color(",
		"T186.SHOP.FLASH_CALL.1: shop_menu._on_buy_pressed 调 ScreenShake.flash_color(...)")
	_assert_contains(src, "Color(0.902, 0.835, 0.722, 1.0)",
		"T186.SHOP.COLOR.1: Color(0.902, 0.835, 0.722, 1.0) Warm Parchment #E6D5B8 (STYLE_GUIDE 限制色板)")
	_assert_contains(src, "0.5,   # duration",
		"T186.SHOP.DUR.1: duration 0.5s (与 SaveLoadMenu unlock flash T128 对齐 \"持久奖励\")")
	_assert_contains(src, "0.18,  # peak alpha",
		"T186.SHOP.PEAK.1: peak_alpha 0.18 (subtle 但看得见, 不抢 BGM/SFX)")
	_assert_contains(src, "256    # flash_layer",
		"T186.SHOP.LAYER.1: flash_layer 256 (屏抖之上, 不与 hit flash 128 互消, 玩家可同时看到 2 事件)")
	_assert_contains(src, "T186 (#104)",
		"T186.SHOP.DOC.1: shop_menu 注释含 T186 (#104) 锚点")
	# 阈值: T186 阈值与 T185 同步, new_count >= 2 (level II+ 才闪, level 0=I 不闪)
	# 找 T186 注释中提到 new_count >= 2 的位置
	_assert_contains(src, "阈值同步 ≥2 (即",
		"T186.SHOP.THRESHOLD.1: T186 阈值与 T185 同步, level II+ 才闪 (避免 5 桶购买全 4 层反馈过载)")


# ===================== F016 — Death lay-down SFX =====================

# ---------- F016.FIELD — 字段声明 ----------
func _run_f016_field_assertions() -> void:
	print("--- F016.FIELD — 字段声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _death_lay_down_stream: AudioStreamWAV",
		"F016.FIELD.1: _death_lay_down_stream: AudioStreamWAV 字段声明 (单 stream cache, F016 #104 新增)")


# ---------- F016.PLAY.* — 公开 API + lazy ----------
func _run_f016_play_api_assertions() -> void:
	print("--- F016.PLAY.* — 公开 API + lazy ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_death_lay_down() -> void:",
		"F016.PLAY.SIG.1: play_death_lay_down() -> void: 公开方法声明")
	_assert_contains(src, "if _death_lay_down_stream == null:",
		"F016.PLAY.LAZY.1: play_death_lay_down lazy-init 守卫 (null check)")
	_assert_contains(src, "_death_lay_down_stream = _generate_death_lay_down_sfx()",
		"F016.PLAY.LAZY.2: lazy 路径调 _generate_death_lay_down_sfx()")
	_assert_contains(src, "play_sfx(_death_lay_down_stream)",
		"F016.PLAY.BUS.1: play_sfx(_death_lay_down_stream) 走 SFX bus")


# ---------- F016.GEN.* — 私有 synth 函数 ----------
func _run_f016_gen_synth_assertions() -> void:
	print("--- F016.GEN.* — 私有 synth 函数 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_death_lay_down_sfx() -> AudioStreamWAV:",
		"F016.GEN.SIG.1: _generate_death_lay_down_sfx() -> AudioStreamWAV 私有 synth")
	_assert_contains(src, "75.0",  # sub-bass 基频
		"F016.GEN.FREQ.1: 75.0Hz sub-bass 基频 anchor (D2, 与 delete 150Hz 区分 \"结束\" vs \"破坏\")")
	_assert_contains(src, "112.5",  # 1.5x
		"F016.GEN.OVERTONE1.1: 1.5x = 112.5Hz overtone (D3)")
	_assert_contains(src, "187.5",  # 2.5x
		"F016.GEN.OVERTONE2.1: 2.5x = 187.5Hz overtone (F3)")
	_assert_contains(src, "var duration := 0.4",
		"F016.GEN.DUR.1: death_lay_down 0.4s duration (与 T075 lay-down 0.5s 完美匹配)")
	_assert_contains(src, "env * 0.28",
		"F016.GEN.AMP.1: amplitude 0.28 (比 delete 0.20 强, < verb fire 0.30-0.40, 暗示 event 重要性)")


# ---------- F016.PLAYER.* — player.gd die() 接入 ----------
func _run_f016_player_integration_assertions() -> void:
	print("--- F016.PLAYER.* — player.gd die() 接入 ---")
	var src := _read_file(PLAYER_GD)
	_assert_contains(src, "ame.has_method(\"play_death_lay_down\")",
		"F016.PLAYER.HAS_METHOD.1: player.gd 用 has_method(\"play_death_lay_down\") 守卫 (老版本 ame 兼容)")
	_assert_contains(src, "ame.play_death_lay_down()",
		"F016.PLAYER.CALL.1: player.gd.die() 调 ame.play_death_lay_down() (SFX 与 freeze-frame 视觉同步)")
	_assert_contains(src, "F016 (#104)",
		"F016.PLAYER.DOC.1: player.gd 注释含 F016 (#104) 锚点")


# ---------- F016.PRE.* — prewarm_misc_sfx 集成 ----------
func _run_f016_prewarm_integration_assertions() -> void:
	print("--- F016.PRE.* — prewarm_misc_sfx 集成 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# 找 prewarm_misc_sfx 函数体内的 F016 集成 (用函数体 substring 限定 scope,
	# 避免匹配到 play_death_lay_down 公开方法的 lazy 路径 — 模式相同但语义不同)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F016.PRE.CALL.1: prewarm_misc_sfx 函数未找到")
		return
	var body := src.substr(prewarm_misc_body_start)
	_assert_contains(body, "_death_lay_down_stream = _generate_death_lay_down_sfx()",
		"F016.PRE.CALL.1: prewarm_misc_sfx 调 _generate_death_lay_down_sfx() (F016 集成, 与 F014/F015 模式 byte-identical)")
	# 顺序: prewarm_misc_sfx body 内 unlock → delete → death (按 F014 → F015 → F016 时间线)
	var unlock_pos := body.find("_unlock_chime_stream = _generate_unlock_chime_sfx()")
	var delete_pos := body.find("_delete_confirm_stream = _generate_delete_confirm_sfx()")
	var death_pos := body.find("_death_lay_down_stream = _generate_death_lay_down_sfx()")
	if unlock_pos != -1 and delete_pos != -1 and death_pos != -1 \
			and unlock_pos < delete_pos and delete_pos < death_pos:
		_passes += 1
		print("  OK  F016.PRE.ORDER.1: prewarm_misc_sfx 顺序 unlock → delete → death (F014 → F015 → F016 时间线)")
	else:
		_failures.append(
			"FAIL: F016.PRE.ORDER.1: prewarm_misc_sfx body 顺序错 unlock=%d delete=%d death=%d" \
			% [unlock_pos, delete_pos, death_pos])


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I016 (#104) T186 + F016 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
