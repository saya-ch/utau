extends SceneTree
## I013 (#101) — T183 hit SFX pre-warm + F012 shop perk-level 数显 冒烟测试
##
## 覆盖 #101 双任务原子化提交:
##
## === T183 — Audio hit SFX pre-warm on Title screen _ready ===
## - T183.PRE.HEADER: prewarm_hit_sfx() 公开方法已声明
## - T183.PRE.HEADER.DOCBLOCK: T183 (#101) 文档块标注 + 13 stream / ~10 ms 成本说明
## - T183.PRE.BIND: Bind hit SFX 单 stream prewarm (无 perk, 与 T181.B 一致)
## - T183.PRE.PULSE: Pulse hit 4 level (perk_level 0..3) prewarm
## - T183.PRE.CUT: Cut hit 4 level prewarm (future-proof, 无当前 perk)
## - T183.PRE.ECHO: Echo hit 4 level prewarm
## - T183.PRE.TITLE_INTEG: title_screen.gd _prewarm_bgm() 调 prewarm_hit_sfx()
## - T183.PRE.TITLE_HAS_METHOD: title_screen.gd 用 has_method 守卫 (headless-safe)
## - T183.PRE.ORDER: prewarm_hit_sfx() 紧接 prewarm_music_streams() (T066 pattern mirror)
## - T183.PRE.DOC: 注释说明 zero synthesis latency 目标 + 13 AudioStreamWAV
##
## === F012 — Hub shop perk card perk-level 数显 (0 → — → I → II → III) ===
## - F012.ROMAN.CONST: _PERK_LEVEL_ROMAN 常量声明 (6 步表)
## - F012.ROMAN.VALS: ["—", "I", "II", "III", "IV", "V"] 全部元素
## - F012.HELPER: _format_perk_level_label(count) helper 函数
## - F012.LABEL.0: 0 → "Lv —" (空状态)
## - F012.LABEL.1: 1 → "Lv I" (perk 升级 1)
## - F012.LABEL.2: 2 → "Lv II"
## - F012.LABEL.3: 3 → "Lv III" (满级 6 个 perk 中 5 个 max=3)
## - F012.LABEL.NEG: -1 → "Lv —" (count < 0 clamp)
## - F012.LABEL.FALLBACK: 5 → "Lv 5" (超出 6 步 fallback 防 broken future perk)
## - F012.REFRESH.USE: _refresh_item() 调 _format_perk_level_label()
## - F012.REPLACE.OLD: 不再有 "已购 %d/%d" 旧文本
## - F012.MODULATE.0: count=0 灰 (低饱和)
## - F012.MODULATE.MAX: at_max 琥珀 (高饱和)
## - F012.MODULATE.MID: between 青色 (中)
## - F012.MATCH.AUDIO: 与 audio_manager_enhanced.gd T181.B perk-level 命名一致

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const TITLE_SCREEN_GD := "res://src/scripts/title_screen.gd"
const SHOP_MENU_GD := "res://src/scripts/shop_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I013 (#101) — T183 hit SFX pre-warm + F012 shop perk-level readout ===")
	_run_t183_prewarm_header_assertions()
	_run_t183_prewarm_body_assertions()
	_run_t183_title_integration_assertions()
	_run_f012_roman_const_assertions()
	_run_f012_helper_assertions()
	_run_f012_refresh_wiring_assertions()
	_run_f012_modulate_assertions()
	_run_f012_audio_naming_match_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I013 (#101) T183 + F012 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T183 — hit SFX pre-warm =====================

# ---------- T183.PRE.HEADER — prewarm_hit_sfx() 公开方法 + 文档块 ----------
func _run_t183_prewarm_header_assertions() -> void:
	print("--- T183.PRE.HEADER — prewarm_hit_sfx 公开方法 + 文档块 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(src, "func prewarm_hit_sfx() -> void:",
		"T183.PRE.HEADER.1: prewarm_hit_sfx() -> void: 公开方法已声明")
	_assert_contains(src, "T183 (#101)",
		"T183.PRE.HEADER.2: T183 (#101) 文档块标注存在")
	_assert_contains(src, "13 AudioStreamWAV",
		"T183.PRE.HEADER.3: 文档块说明 13 AudioStreamWAV 总数 (1+4+4+4)")
	_assert_contains(src, "zero synthesis latency",
		"T183.PRE.HEADER.4: 文档块说明 zero synthesis latency 目标 (Title ready cost → gameplay frame offload)")
	_assert_contains(src, "Mirror pattern of T066",
		"T183.PRE.HEADER.5: 文档块引用 T066 prewarm_music_streams() 同源 pattern")


# ---------- T183.PRE.{BIND,PULSE,CUT,ECHO} — 4 verb prewarm body ----------
func _run_t183_prewarm_body_assertions() -> void:
	print("--- T183.PRE.{BIND,PULSE,CUT,ECHO} — 4 verb prewarm body ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# Bind: 单 stream (与 T181.B.BIND.UNCHANGED 一致)
	_assert_contains(src, "if _bind_hit_stream == null:",
		"T183.PRE.BIND.1: prewarm_hit_sfx 调 _bind_hit_stream 守卫 (单 stream)")
	_assert_contains(src, "_bind_hit_stream = _generate_bind_hit_sfx()",
		"T183.PRE.BIND.2: prewarm_hit_sfx 调 _generate_bind_hit_sfx()")
	# Pulse: 4 level (0..3)
	_assert_contains(src, "if not _pulse_hit_streams.has(level):",
		"T183.PRE.PULSE.1: prewarm_hit_sfx Pulse 4 level Dict.has(level) 守卫")
	_assert_contains(src, "_pulse_hit_streams[level] = _generate_pulse_hit_sfx(level)",
		"T183.PRE.PULSE.2: prewarm_hit_sfx Pulse 调 _generate_pulse_hit_sfx(level)")
	# Cut: 4 level (future-proof, T181.B future-proof 设计)
	_assert_contains(src, "if not _cut_hit_streams.has(level):",
		"T183.PRE.CUT.1: prewarm_hit_sfx Cut 4 level Dict.has(level) 守卫 (future-proof)")
	_assert_contains(src, "_cut_hit_streams[level] = _generate_cut_hit_sfx(level)",
		"T183.PRE.CUT.2: prewarm_hit_sfx Cut 调 _generate_cut_hit_sfx(level)")
	# Echo: 4 level
	_assert_contains(src, "if not _echo_hit_streams.has(level):",
		"T183.PRE.ECHO.1: prewarm_hit_sfx Echo 4 level Dict.has(level) 守卫")
	_assert_contains(src, "_echo_hit_streams[level] = _generate_echo_hit_sfx(level)",
		"T183.PRE.ECHO.2: prewarm_hit_sfx Echo 调 _generate_echo_hit_sfx(level)")
	# 4 level 表 (0..3)
	_assert_contains(src, "for level in [0, 1, 2, 3]:",
		"T183.PRE.LOOP.1: prewarm_hit_sfx 单一 for level in [0,1,2,3] 循环覆盖 3 verb × 4 level")


# ---------- T183.PRE.TITLE_INTEG — title_screen 接入 ----------
func _run_t183_title_integration_assertions() -> void:
	print("--- T183.PRE.TITLE_INTEG — title_screen 接入 ---")
	var src := _read_file(TITLE_SCREEN_GD)
	_assert_contains(src, "ame.call(\"prewarm_hit_sfx\")",
		"T183.PRE.TITLE_INTEG.1: title_screen._prewarm_bgm 调 ame.call(\"prewarm_hit_sfx\")")
	_assert_contains(src, "ame.has_method(\"prewarm_hit_sfx\")",
		"T183.PRE.TITLE_INTEG.2: title_screen 用 has_method(\"prewarm_hit_sfx\") 守卫 (headless-safe)")
	_assert_contains(src, "T183 (#101)",
		"T183.PRE.TITLE_INTEG.3: title_screen 注释含 T183 (#101) 锚点")
	# 顺序: prewarm_hit_sfx 在 prewarm_music_streams 之后 (统一 mirror pattern)
	var music_pos := src.find("ame.call(\"prewarm_music_streams\")")
	var hit_pos := src.find("ame.call(\"prewarm_hit_sfx\")")
	if music_pos != -1 and hit_pos != -1 and hit_pos > music_pos:
		_passes += 1
		print("  OK  T183.PRE.ORDER.1: prewarm_hit_sfx() 紧接 prewarm_music_streams() (T066 pattern mirror)")
	else:
		_failures.append("FAIL: T183.PRE.ORDER.1: prewarm_hit_sfx 必须在 prewarm_music_streams 之后, music=%d hit=%d" % [music_pos, hit_pos])


# ===================== F012 — shop perk-level readout =====================

# ---------- F012.ROMAN — _PERK_LEVEL_ROMAN 常量 + helper ----------
func _run_f012_roman_const_assertions() -> void:
	print("--- F012.ROMAN — _PERK_LEVEL_ROMAN 常量 + helper ---")
	var src := _read_file(SHOP_MENU_GD)
	_assert_contains(src, "const _PERK_LEVEL_ROMAN := [\"—\", \"I\", \"II\", \"III\", \"IV\", \"V\"]",
		"F012.ROMAN.CONST.1: _PERK_LEVEL_ROMAN 常量声明 (—/I/II/III/IV/V 6 步)")
	_assert_contains(src, "func _format_perk_level_label(count: int) -> String:",
		"F012.HELPER.1: _format_perk_level_label(count: int) -> String helper 声明")
	_assert_contains(src, "F012 (#101)",
		"F012.DOC.1: helper 注释含 F012 (#101) 锚点")
	_assert_contains(src, "T181",
		"F012.DOC.2: helper 注释引用 T181 perk-level 命名 (audio 跨系统一致性)")


# ---------- F012.LABEL — count 0..3 + neg + fallback 格式化 ----------
func _run_f012_helper_assertions() -> void:
	print("--- F012.LABEL — count 0..3 + neg + fallback ---")
	var src := _read_file(SHOP_MENU_GD)
	# 6 步表全部元素
	var local_roman: Array[String] = ["—", "I", "II", "III", "IV", "V"]
	for idx in range(6):
		var roman: String = local_roman[idx]
		if src.contains("\"%s\"" % roman):
			_passes += 1
			print("  OK  F012.ROMAN.VALS.%d: 常量表含 \"%s\"" % [idx + 1, roman])
		else:
			_failures.append("FAIL: F012.ROMAN.VALS.%d: 常量表缺 \"%s\"" % [idx + 1, roman])
	# 返回模板 "Lv %s"
	_assert_contains(src, "\"Lv %s\" % _PERK_LEVEL_ROMAN[count]",
		"F012.LABEL.TEMPLATE.1: helper 走 \"Lv %s\" 模板")
	_assert_contains(src, "if count < 0:",
		"F012.LABEL.NEG.1: helper 守卫 count < 0 (clamp 0)")
	_assert_contains(src, "count = 0",
		"F012.LABEL.NEG.2: count < 0 → count = 0")
	_assert_contains(src, "if count < _PERK_LEVEL_ROMAN.size():",
		"F012.LABEL.RANGE.1: helper 守卫 count < 6 (表内)")
	_assert_contains(src, "return \"Lv %d\" % count",
		"F012.LABEL.FALLBACK.1: fallback \"Lv %d\" 路径保护超 6 步 future perk")
	# count == 0 路径覆盖
	_assert_contains(src, "if count < 0:",
		"F012.LABEL.ZERO.1: count=0 通过 _PERK_LEVEL_ROMAN[0] = \"—\" 输出 \"Lv —\"")


# ---------- F012.REFRESH — _refresh_item 接入 helper + 旧文本已替换 ----------
func _run_f012_refresh_wiring_assertions() -> void:
	print("--- F012.REFRESH — _refresh_item 接入 helper + 旧文本替换 ---")
	var src := _read_file(SHOP_MENU_GD)
	_assert_contains(src, "count_label.text = _format_perk_level_label(count)",
		"F012.REFRESH.USE.1: _refresh_item 用 helper 设 count_label.text")
	_assert_not_contains(src, "count_label.text = \"已购 %d/%d\"",
		"F012.REPLACE.OLD.1: 旧 count_label.text = \"已购 %d/%d\" 赋值已移除 (helper 替代)")
	_assert_contains(src, "count_label.modulate",
		"F012.MODULATE.WIRE.1: _refresh_item 改 count_label.modulate (per-level 颜色)")


# ---------- F012.MODULATE — 0 灰 / 中 青 / 满 琥珀 ----------
func _run_f012_modulate_assertions() -> void:
	print("--- F012.MODULATE — 0 灰 / 中 青 / 满 琥珀 ---")
	var src := _read_file(SHOP_MENU_GD)
	_assert_contains(src, "if count == 0:",
		"F012.MODULATE.0.A: count==0 分支存在")
	_assert_contains(src, "Color(0.65, 0.65, 0.7, 0.9)",
		"F012.MODULATE.0.B: count=0 灰 (低饱和, a=0.9)")
	_assert_contains(src, "elif at_max:",
		"F012.MODULATE.MAX.A: at_max 分支存在 (满级琥珀)")
	_assert_contains(src, "Color(1.0, 0.78, 0.55, 1.0)",
		"F012.MODULATE.MAX.B: at_max 琥珀 (语音色 #FFC78C-ish)")
	_assert_contains(src, "Color(0.62, 0.85, 0.95, 1.0)",
		"F012.MODULATE.MID.B: 中间 level 青色 (玻璃 #9ED9F2-ish)")
	# 3 个 Color 出现次数
	var color_count := src.count("Color(0.65, 0.65, 0.7, 0.9)") + src.count("Color(1.0, 0.78, 0.55, 1.0)") + src.count("Color(0.62, 0.85, 0.95, 1.0)")
	if color_count == 3:
		_passes += 1
		print("  OK  F012.MODULATE.COUNT.1: 3 个 per-level modulate Color 全在 (灰/青/琥珀)")
	else:
		_failures.append("FAIL: F012.MODULATE.COUNT.1: 期望 3 个 Color, 实际 %d" % color_count)


# ---------- F012.MATCH.AUDIO — 与 audio_manager perk-level 命名一致 ----------
func _run_f012_audio_naming_match_assertions() -> void:
	print("--- F012.MATCH.AUDIO — 与 audio_manager perk-level 命名一致 ---")
	var audio_src := _read_file(AUDIO_MANAGER_GD)
	var shop_src := _read_file(SHOP_MENU_GD)
	# 4 verb (Pulse/Cut/Echo/Wave) perk-level 注释必须出现 0..3
	for v in ["Pulse", "Cut", "Echo"]:
		if audio_src.contains("%s hit SFX" % v) and audio_src.contains("perk_level 0..3"):
			_passes += 1
			print("  OK  F012.MATCH.AUDIO.%-6s: audio_manager 同时含 \"%s hit SFX\" + \"perk_level 0..3\" 锚点" % [v, v])
		else:
			_failures.append("FAIL: F012.MATCH.AUDIO.%s: audio_manager 缺 \"%s hit SFX\" + perk_level 0..3 锚点" % [v, v])
	# shop 4 个 level 罗马数字匹配 audio 注释
	for needle in ["\"—\"", "\"I\"", "\"II\"", "\"III\""]:
		if shop_src.contains(needle):
			_passes += 1
			print("  OK  F012.MATCH.SHOP.%-4s: shop_menu 常量表含 %s (与 audio perk-level 对齐)" % [needle, needle])
		else:
			_failures.append("FAIL: F012.MATCH.SHOP.%s: shop_menu 常量表缺 %s" % [needle, needle])


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


const _PERK_LEVEL_ROMAN := ["—", "I", "II", "III", "IV", "V"]


func _print_summary() -> void:
	print("--- I013 (#101) T183 + F012 smoke summary ---")
	print("passes: ", _passes)
	print("failures: ", _failures.size())
	for line in _failures:
		print(line)
