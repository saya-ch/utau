extends SceneTree
## I014 (#102) — F013 shop perk SFX + T184 cross-scene prewarm 冒烟测试
##
## 覆盖 #102 双任务原子化提交:
##
## === F013 — AudioManagerEnhanced 商店 SFX (purchase_confirm + level_up arpeggio) ===
## - F013.FIELD.CONFIRM: _shop_purchase_confirm_stream 字段声明
## - F013.FIELD.LEVELUP: _shop_level_up_streams: Dictionary 字段声明
## - F013.CONST.LEVELS: _SHOP_LEVEL_UP_LEVELS = 4 (perk level 0..3)
## - F013.CONST.BASE: _SHOP_LEVEL_UP_BASE_MIDI = [60, 62, 64, 65] (C4/D4/E4/F4 升序)
## - F013.PLAY.CONFIRM: play_shop_purchase_confirm() 公开方法已声明
## - F013.PLAY.LEVELUP: play_shop_level_up(level) 公开方法已声明
## - F013.PLAY.CONFIRM.LAZY: lazy-init 守卫 (null → 生成)
## - F013.PLAY.LEVELUP.LAZY: lazy-init 守卫 (Dict.has(level) → 生成)
## - F013.PLAY.LEVELUP.CLAMP: clampi(level, 0, _SHOP_LEVEL_UP_LEVELS-1) 防御越界
## - F013.GEN.CONFIRM.SIG: _generate_shop_purchase_confirm_sfx() 私有 synth
## - F013.GEN.CONFIRM.TRIAD: C5 523.25Hz + E5 659.26Hz + G5 783.99Hz 大三和弦
## - F013.GEN.CONFIRM.DUR: 0.4s duration (与 _generate_repair_sfx 0.6s 区分)
## - F013.GEN.LEVELUP.SIG: _generate_shop_level_up_sfx(level) 私有 synth
## - F013.GEN.LEVELUP.ARPEGGIO: 音阶 +4 / +7 半音 (major triad arpeggio 模式)
## - F013.GEN.LEVELUP.DUR: 0.30s duration (3 notes × 0.10s)
## - F013.SHOP.AMECALL: shop_menu._on_buy_pressed 调 ame.play_shop_purchase_confirm()
## - F013.SHOP.LEVELUP: shop_menu._on_buy_pressed 调 ame.play_shop_level_up()
## - F013.SHOP.LEVEL_ARG: 入参 = new_count - 1 (新 level, 0..3)
## - F013.SHOP.HAS_METHOD: ame.has_method 守卫 (headless-safe 模式)
## - F013.SHOP.ORDER: purchase_confirm 在 level_up 之前 (chord 先 + arpeggio 后)
##
## === T184 — Cross-scene prewarm aggregator + hub/gfc hook ===
## - T184.PRE.SHOP: prewarm_shop_sfx() 公开方法已声明
## - T184.PRE.SHOP.CONFIRM: prewarm 1 个 purchase_confirm stream
## - T184.PRE.SHOP.LEVELS: prewarm 4 个 level_up arpeggio (0..3)
## - T184.PRE.ALL: prewarm_all_sfx() aggregator 公开方法已声明
## - T184.PRE.ALL.ORDER: aggregator 顺序 music → hit → shop
## - T184.PRE.ALL.IDEMPOTENT: 文档块说明 idempotent (每次守卫)
## - T184.TITLE.CALL: title_screen._prewarm_bgm 调 prewarm_shop_sfx (F013 闭环)
## - T184.TITLE.HAS_METHOD: title_screen 用 has_method 守卫
## - T184.HUB.CALL: hub_controller._ready 调 prewarm_all_sfx
## - T184.HUB.HAS_METHOD: hub_controller 用 has_method 守卫
## - T184.GFC.CALL: game_flow_controller._enter_state 调 prewarm_all_sfx
## - T184.GFC.HAS_METHOD: game_flow_controller 用 has_method 守卫
## - T184.PRE.ALL.SCOPE: aggregator 文档块说明 ~25 ms 总成本 (4 verb hit + 5 shop + 9 music)
## - T184.PRE.ALL.AFTER_MUSIC: aggregator 内 music 先于 hit (T066 同源 pattern mirror)

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const TITLE_SCREEN_GD := "res://src/scripts/title_screen.gd"
const HUB_CONTROLLER_GD := "res://src/scripts/hub_controller.gd"
const GAME_FLOW_CONTROLLER_GD := "res://src/scripts/game_flow_controller.gd"
const SHOP_MENU_GD := "res://src/scripts/shop_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I014 (#102) — F013 shop SFX + T184 cross-scene prewarm ===")
	_run_f013_field_assertions()
	_run_f013_const_assertions()
	_run_f013_play_api_assertions()
	_run_f013_gen_synth_assertions()
	_run_f013_shop_integration_assertions()
	_run_t184_prewarm_shop_assertions()
	_run_t184_prewarm_all_assertions()
	_run_t184_title_integration_assertions()
	_run_t184_hub_integration_assertions()
	_run_t184_gfc_integration_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I014 (#102) F013 + T184 ASSERTIONS PASSED ===")
		quit(0)


# ===================== F013 — shop SFX (purchase_confirm + level_up) =====================

# ---------- F013.FIELD / CONST — 字段 + 常量声明 ----------
func _run_f013_field_assertions() -> void:
	print("--- F013.FIELD / CONST — 字段 + 常量声明 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "var _shop_purchase_confirm_stream: AudioStreamWAV",
		"F013.FIELD.CONFIRM.1: _shop_purchase_confirm_stream: AudioStreamWAV 字段声明")
	_assert_contains(src, "var _shop_level_up_streams: Dictionary = {}",
		"F013.FIELD.LEVELUP.1: _shop_level_up_streams: Dictionary 字段声明 (per-level 缓存)")

func _run_f013_const_assertions() -> void:
	print("--- F013.CONST — perk level 常量 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "const _SHOP_LEVEL_UP_LEVELS: int = 4",
		"F013.CONST.LEVELS.1: _SHOP_LEVEL_UP_LEVELS: int = 4 (perk level 0..3 4 步)")
	_assert_contains(src, "const _SHOP_LEVEL_UP_BASE_MIDI: Array = [60, 62, 64, 65]",
		"F013.CONST.BASE.1: _SHOP_LEVEL_UP_BASE_MIDI = [60, 62, 64, 65] (C4/D4/E4/F4)")
	# 4 个 MIDI 数值都在源里出现 (双 anchor 防止 0/3 误改)
	for v in [60, 62, 64, 65]:
		_assert_contains(src, str(v),
			"F013.CONST.BASE.VAL.%d: _SHOP_LEVEL_UP_BASE_MIDI 数组含 %d (升序 anchor)" % [v, v])


# ---------- F013.PLAY.* — 公开 API + lazy + clamp ----------
func _run_f013_play_api_assertions() -> void:
	print("--- F013.PLAY.* — 公开 API + lazy + clamp ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func play_shop_purchase_confirm() -> void:",
		"F013.PLAY.CONFIRM.1: play_shop_purchase_confirm() -> void: 公开方法声明")
	_assert_contains(src, "func play_shop_level_up(level: int = 0) -> void:",
		"F013.PLAY.LEVELUP.1: play_shop_level_up(level: int = 0) -> void: 公开方法声明 (默认 level=0)")
	# lazy 守卫
	_assert_contains(src, "if _shop_purchase_confirm_stream == null:",
		"F013.PLAY.CONFIRM.LAZY.1: play_shop_purchase_confirm lazy-init 守卫 (null check)")
	_assert_contains(src, "_shop_purchase_confirm_stream = _generate_shop_purchase_confirm_sfx()",
		"F013.PLAY.CONFIRM.LAZY.2: lazy 路径调 _generate_shop_purchase_confirm_sfx()")
	_assert_contains(src, "if not _shop_level_up_streams.has(clamped_level):",
		"F013.PLAY.LEVELUP.LAZY.1: play_shop_level_up Dict.has(level) lazy-init 守卫")
	_assert_contains(src, "_shop_level_up_streams[clamped_level] = _generate_shop_level_up_sfx(clamped_level)",
		"F013.PLAY.LEVELUP.LAZY.2: lazy 路径调 _generate_shop_level_up_sfx(level)")
	# clamp 防御
	_assert_contains(src, "var clamped_level: int = clampi(level, 0, _SHOP_LEVEL_UP_LEVELS - 1)",
		"F013.PLAY.LEVELUP.CLAMP.1: clampi(level, 0, _SHOP_LEVEL_UP_LEVELS - 1) 防御越界")
	# 调用 play_sfx (走 SFX bus)
	_assert_contains(src, "play_sfx(_shop_purchase_confirm_stream)",
		"F013.PLAY.CONFIRM.BUS.1: play_sfx(_shop_purchase_confirm_stream) 走 SFX bus")
	_assert_contains(src, "play_sfx(stream)",
		"F013.PLAY.LEVELUP.BUS.1: play_sfx(stream) 走 SFX bus")


# ---------- F013.GEN.* — 私有 synth 函数 ----------
func _run_f013_gen_synth_assertions() -> void:
	print("--- F013.GEN.* — 私有 synth 函数 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func _generate_shop_purchase_confirm_sfx() -> AudioStreamWAV:",
		"F013.GEN.CONFIRM.SIG.1: _generate_shop_purchase_confirm_sfx() -> AudioStreamWAV 私有 synth")
	_assert_contains(src, "523.25",  # C5
		"F013.GEN.CONFIRM.TRIAD.1: C5 523.25Hz 大三和弦 anchor")
	_assert_contains(src, "659.26",  # E5
		"F013.GEN.CONFIRM.TRIAD.2: E5 659.26Hz 大三和弦 anchor")
	_assert_contains(src, "783.99",  # G5
		"F013.GEN.CONFIRM.TRIAD.3: G5 783.99Hz 大三和弦 anchor")
	_assert_contains(src, "var duration := 0.4",
		"F013.GEN.CONFIRM.DUR.1: purchase_confirm 0.4s (比 repair 0.6s 短, 奖励感更短促)")
	_assert_contains(src, "exp(-t * 3.5)",
		"F013.GEN.CONFIRM.ENV.1: purchase_confirm 衰减 3.5 (比 repair 4.0 慢 → 'rings')")
	_assert_contains(src, "func _generate_shop_level_up_sfx(level: int) -> AudioStreamWAV:",
		"F013.GEN.LEVELUP.SIG.1: _generate_shop_level_up_sfx(level) -> AudioStreamWAV 私有 synth")
	_assert_contains(src, "_SHOP_LEVEL_UP_BASE_MIDI[level]",
		"F013.GEN.LEVELUP.BASE.1: _generate 用 _SHOP_LEVEL_UP_BASE_MIDI[level] 选 base")
	_assert_contains(src, "[0, 4, 7][step]",
		"F013.GEN.LEVELUP.ARPEGGIO.1: 大调三和弦音阶 +0/+4/+7 半音 (major triad arpeggio)")
	_assert_contains(src, "var duration := 0.30",
		"F013.GEN.LEVELUP.DUR.1: level_up 0.30s duration (3 notes × 0.10s)")


# ---------- F013.SHOP.* — shop_menu 接入 ----------
func _run_f013_shop_integration_assertions() -> void:
	print("--- F013.SHOP.* — shop_menu 接入 ---")
	var src := _read_file(SHOP_MENU_GD)
	_assert_contains(src, "ame.has_method(\"play_shop_purchase_confirm\")",
		"F013.SHOP.HAS_METHOD.1: shop_menu 用 has_method(\"play_shop_purchase_confirm\") 守卫 (headless-safe)")
	_assert_contains(src, "ame.has_method(\"play_shop_level_up\")",
		"F013.SHOP.HAS_METHOD.2: shop_menu 用 has_method(\"play_shop_level_up\") 守卫")
	_assert_contains(src, "ame.play_shop_purchase_confirm()",
		"F013.SHOP.AMECALL.1: shop_menu._on_buy_pressed 调 ame.play_shop_purchase_confirm()")
	_assert_contains(src, "ame.play_shop_level_up(max(0, new_count - 1))",
		"F013.SHOP.LEVELUP.1: shop_menu._on_buy_pressed 调 ame.play_shop_level_up(新 level)")
	_assert_contains(src, "var new_count: int = GameState.get_perk_count(perk_id)",
		"F013.SHOP.LEVELUP.2: new_count = GameState.get_perk_count(perk_id) (新 level 来源)")
	_assert_contains(src, "F013 (#102)",
		"F013.SHOP.DOC.1: shop_menu 注释含 F013 (#102) 锚点")
	# 顺序: purchase_confirm 调用于 level_up 调用于 (chord 先 arpeggio 后)
	var confirm_pos := src.find("ame.play_shop_purchase_confirm()")
	var levelup_pos := src.find("ame.play_shop_level_up(")
	if confirm_pos != -1 and levelup_pos != -1 and confirm_pos < levelup_pos:
		_passes += 1
		print("  OK  F013.SHOP.ORDER.1: purchase_confirm 在 level_up 之前 (chord 先, arpeggio 后)")
	else:
		_failures.append("FAIL: F013.SHOP.ORDER.1: 顺序错 confirm=%d levelup=%d" % [confirm_pos, levelup_pos])


# ===================== T184 — prewarm aggregator + cross-scene hook =====================

# ---------- T184.PRE.SHOP — prewarm_shop_sfx 公开方法 ----------
func _run_t184_prewarm_shop_assertions() -> void:
	print("--- T184.PRE.SHOP — prewarm_shop_sfx 公开方法 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_shop_sfx() -> void:",
		"T184.PRE.SHOP.1: prewarm_shop_sfx() -> void: 公开方法声明")
	_assert_contains(src, "if _shop_purchase_confirm_stream == null:",
		"T184.PRE.SHOP.CONFIRM.1: prewarm_shop_sfx cache 守卫 (purchase_confirm 路径)")
	_assert_contains(src, "_shop_purchase_confirm_stream = _generate_shop_purchase_confirm_sfx()",
		"T184.PRE.SHOP.CONFIRM.2: prewarm_shop_sfx 调 _generate_shop_purchase_confirm_sfx()")
	_assert_contains(src, "for level in range(_SHOP_LEVEL_UP_LEVELS):",
		"T184.PRE.SHOP.LEVELS.1: prewarm_shop_sfx for level in range(4) 4 level 循环")
	_assert_contains(src, "if not _shop_level_up_streams.has(level):",
		"T184.PRE.SHOP.LEVELS.2: prewarm_shop_sfx Dict.has(level) 守卫 (per-level cache)")
	_assert_contains(src, "_shop_level_up_streams[level] = _generate_shop_level_up_sfx(level)",
		"T184.PRE.SHOP.LEVELS.3: prewarm_shop_sfx 调 _generate_shop_level_up_sfx(level)")
	_assert_contains(src, "T184 (#102)",
		"T184.PRE.SHOP.DOC.1: prewarm_shop_sfx 注释含 T184 (#102) 锚点")


# ---------- T184.PRE.ALL — aggregator prewarm_all_sfx ----------
func _run_t184_prewarm_all_assertions() -> void:
	print("--- T184.PRE.ALL — aggregator prewarm_all_sfx ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_all_sfx() -> void:",
		"T184.PRE.ALL.1: prewarm_all_sfx() -> void: 公开 aggregator 声明")
	# 顺序: music → hit → shop (T066 同源 + T183 集成 + T184 shop 增量)
	var music_pos := src.find("prewarm_music_streams()\n\tprewarm_hit_sfx()")
	var hit_pos := src.find("prewarm_hit_sfx()\n\tprewarm_shop_sfx()")
	if music_pos != -1 and hit_pos != -1 and music_pos < hit_pos:
		_passes += 1
		print("  OK  T184.PRE.ALL.ORDER.1: aggregator 顺序 music → hit → shop (T066+T183+T184)")
	else:
		_failures.append("FAIL: T184.PRE.ALL.ORDER.1: aggregator 顺序错 music=%d hit=%d" % [music_pos, hit_pos])
	_assert_contains(src, "Idempotent",
		"T184.PRE.ALL.IDEMPOTENT.1: aggregator 文档块说明 Idempotent (重入安全)")
	_assert_contains(src, "~25 ms",
		"T184.PRE.ALL.SCOPE.1: aggregator 文档块说明 ~25 ms 总成本 (4 verb hit + 5 shop + 9 music)")


# ---------- T184.TITLE — title_screen 接入 prewarm_shop_sfx ----------
func _run_t184_title_integration_assertions() -> void:
	print("--- T184.TITLE — title_screen 接入 prewarm_shop_sfx ---")
	var src := _read_file(TITLE_SCREEN_GD)
	_assert_contains(src, "ame.has_method(\"prewarm_shop_sfx\")",
		"T184.TITLE.HAS_METHOD.1: title_screen 用 has_method(\"prewarm_shop_sfx\") 守卫 (headless-safe)")
	_assert_contains(src, "ame.call(\"prewarm_shop_sfx\")",
		"T184.TITLE.CALL.1: title_screen._prewarm_bgm 调 ame.call(\"prewarm_shop_sfx\")")
	_assert_contains(src, "T184 (#102)",
		"T184.TITLE.DOC.1: title_screen 注释含 T184 (#102) 锚点")
	# 顺序: prewarm_shop_sfx 在 prewarm_music_streams / prewarm_hit_sfx 之后 (T183 之后增量)
	var music_pos := src.find("ame.call(\"prewarm_music_streams\")")
	var hit_pos := src.find("ame.call(\"prewarm_hit_sfx\")")
	var shop_pos := src.find("ame.call(\"prewarm_shop_sfx\")")
	if music_pos != -1 and hit_pos != -1 and shop_pos != -1 and music_pos < hit_pos and hit_pos < shop_pos:
		_passes += 1
		print("  OK  T184.TITLE.ORDER.1: title_screen 顺序 music → hit → shop (T066 + T183 + T184 增量)")
	else:
		_failures.append("FAIL: T184.TITLE.ORDER.1: title_screen 顺序错 music=%d hit=%d shop=%d" % [music_pos, hit_pos, shop_pos])


# ---------- T184.HUB — hub_controller 接入 prewarm_all_sfx ----------
func _run_t184_hub_integration_assertions() -> void:
	print("--- T184.HUB — hub_controller 接入 prewarm_all_sfx ---")
	var src := _read_file(HUB_CONTROLLER_GD)
	_assert_contains(src, "ame.has_method(\"prewarm_all_sfx\")",
		"T184.HUB.HAS_METHOD.1: hub_controller 用 has_method(\"prewarm_all_sfx\") 守卫")
	_assert_contains(src, "ame.call(\"prewarm_all_sfx\")",
		"T184.HUB.CALL.1: hub_controller._ready 调 ame.call(\"prewarm_all_sfx\")")
	_assert_contains(src, "T184 (#102)",
		"T184.HUB.DOC.1: hub_controller 注释含 T184 (#102) 锚点")


# ---------- T184.GFC — game_flow_controller 接入 prewarm_all_sfx ----------
func _run_t184_gfc_integration_assertions() -> void:
	print("--- T184.GFC — game_flow_controller 接入 prewarm_all_sfx ---")
	var src := _read_file(GAME_FLOW_CONTROLLER_GD)
	_assert_contains(src, "ame_prewarm.has_method(\"prewarm_all_sfx\")",
		"T184.GFC.HAS_METHOD.1: game_flow_controller 用 has_method(\"prewarm_all_sfx\") 守卫 (alias 变量)")
	_assert_contains(src, "ame_prewarm.call(\"prewarm_all_sfx\")",
		"T184.GFC.CALL.1: game_flow_controller._enter_state 调 ame_prewarm.call(\"prewarm_all_sfx\")")
	_assert_contains(src, "T184 (#102)",
		"T184.GFC.DOC.1: game_flow_controller 注释含 T184 (#102) 锚点")
	# 顺序: prewarm 在 _play_music_for_state 之后 (BGM 先, SFX 紧接)
	var music_pos := src.find("_play_music_for_state(new_state)")
	var prewarm_pos := src.find("ame_prewarm.call(\"prewarm_all_sfx\")")
	if music_pos != -1 and prewarm_pos != -1 and music_pos < prewarm_pos:
		_passes += 1
		print("  OK  T184.GFC.ORDER.1: gfc 顺序 music_for_state → prewarm_all_sfx (BGM 先, SFX 紧接)")
	else:
		_failures.append("FAIL: T184.GFC.ORDER.1: gfc 顺序错 music=%d prewarm=%d" % [music_pos, prewarm_pos])


# ===================== helpers =====================
func _assert_contains(src: String, needle: String, label: String) -> void:
	if src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (needle: " + needle + ")")


func _assert_not_contains(src: String, needle: String, label: String) -> void:
	if not src.contains(needle):
		_passes += 1
	else:
		_failures.append("FAIL: " + label + " (forbidden needle still present: " + needle + ")")


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _print_summary() -> void:
	print("--- I014 (#102) F013 + T184 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
