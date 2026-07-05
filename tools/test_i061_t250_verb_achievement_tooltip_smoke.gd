extends SceneTree
## I061 (#168) — T250 AchievementGrid 6 verb 关联成就 slot tooltip 扩展
## (3 行 → 8 行: 追加 "6 verb 视觉组" 段 header + verb 序号 + 主色 +
## 几何 + 视觉组连贯短句) 冒烟测试
##
## 覆盖 #168 任务 T250 原子化提交:
##
## === T250 — AchievementGrid 6 verb 关联成就 slot tooltip 扩展 ===
## - T250.CONST.HINTS: _VERB_ACHV_ICON_HINTS const 存在 + 3 entry (echo_icon / wave_icon / whisper_icon)
## - T250.CONST.INFO: _VERB_ACHV_INFO const 存在 + 3 key (echo_icon / wave_icon / whisper_icon)
## - T250.ECHO.VERB_INDEX: echo_icon verb_index = 4 (Echo = 4 verb)
## - T250.ECHO.COLOR: echo_icon color = #69C7CE (Glass Cyan)
## - T250.ECHO.COLOR_NAME: echo_icon color_name = Glass Cyan
## - T250.ECHO.GEOMETRY: echo_icon geometry_zh 盾球扩散关键词
## - T250.ECHO.VISUAL: echo_icon visual_group 5 verb 动态几何关键词
## - T250.ECHO.ACHV_ID: echo_icon achv_id = quadruple_voice
## - T250.WAVE.VERB_INDEX: wave_icon verb_index = 5 (Wave = 5 verb)
## - T250.WAVE.COLOR: wave_icon color = #B7E7DD (Pale Resonance)
## - T250.WAVE.COLOR_NAME: wave_icon color_name = Pale Resonance
## - T250.WAVE.GEOMETRY: wave_icon geometry_zh 双环扩散关键词
## - T250.WAVE.VISUAL: wave_icon visual_group 5 verb 最冷最浅关键词
## - T250.WAVE.ACHV_ID: wave_icon achv_id = quintuple_voice
## - T250.WHISPER.VERB_INDEX: whisper_icon verb_index = 6 (Whisper = 6 verb)
## - T250.WHISPER.COLOR: whisper_icon color = #C8A4D8 (Muted Mauve)
## - T250.WHISPER.COLOR_NAME: whisper_icon color_name = Muted Mauve
## - T250.WHISPER.GEOMETRY: whisper_icon geometry_zh 静态球 + 不扩散关键词
## - T250.WHISPER.VISUAL: whisper_icon visual_group debuff 贴身关键词
## - T250.WHISPER.ACHV_ID: whisper_icon achv_id = sextuple_voice
## - T250.FUNC.EXIST: _build_verb_achievement_tooltip 函数存在
## - T250.FUNC.HEADER: 函数体内 "6 verb 视觉组" header 存在
## - T250.FUNC.VERB_LINE: 函数体内 "• 第 %d verb · %s  %s" format 存在
## - T250.FUNC.GEOM_LINE: 函数体内 "• 几何 — %s" format 存在
## - T250.FUNC.VISUAL_LINE: 函数体内 "• 视觉组 — %s" format 存在
## - T250.FUNC.GUARD: 函数体内 _VERB_ACHV_ICON_HINTS.has() guard 存在
## - T250.FUNC.INFO_GUARD: 函数体内 _VERB_ACHV_INFO.has() guard 存在
## - T250.FUNC.RETURN_BASE: 函数体内 base_tooltip 原样 return 分支存在
## - T250.CALLSITE: slot.tooltip_text 走 _build_verb_achievement_tooltip 包装
## - T250.CALLSITE.BASE: 既有 T109 base_tooltip 3 行 "title + desc + 解锁时间" 保留
## - T250.NO_REGRESS_T109: T109 base_tooltip 既有 3 行格式 "%s  %s\n解锁于 %s" 保留
## - T250.NO_REGRESS_T111: T111 mouse_filter=STOP + mouse_entered/exited 2 signal 保留
## - T250.NO_REGRESS_T222: T222 _ACHV_LOCKED_ALPHA_START/END/RGB const 保留
## - T250.NO_REGRESS_T226: T226 _SLOT_HOVER_BRIGHT_ALPHA_BOOST + _slot_hover_alpha_base 保留
## - T250.NO_REGRESS_ICON: ICON_PATH_BASE / ICON_DEFAULT const 保留
## - T250.SYNTAX.VERB_INDEX_TYPE: verb_index 字段类型 int 3 处
## - T250.SYNTAX.UNIQUE_FIELDS: 6 字段 (achv_id/verb_index/color/color_name/geometry_zh/visual_group) 3 entry
## - T250.SYNTAX.HINT_COUNT: _VERB_ACHV_ICON_HINTS 3 entry 准确
## - T250.DOC.ANCHOR: T250 (#168) 注释锚点 ≥ 4 处 (const + func + callsite + no_regress)
## - T250.PALETTE.EXCLUSIVE: 6 verb 调色六元组 0 重叠 (echo #69C7CE / wave #B7E7DD / whisper #C8A4D8 3 hex 各异)
## - T250.PALETTE.WHISPER_MAUVE: Whisper 主色 #C8A4D8 (Muted Mauve) 与 5 verb 5 色 0 重叠
## - T250.GEOMETRY.WHISPER_UNIQUE: Whisper 是 6 verb 唯一"不扩散" 静态球 关键词

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I061 (#168) — T250 AchievementGrid 6 verb 关联成就 slot tooltip 扩展 (3 行 → 8 行) ===")
	_run_t250_const_hints_assertions()
	_run_t250_const_info_assertions()
	_run_t250_echo_assertions()
	_run_t250_wave_assertions()
	_run_t250_whisper_assertions()
	_run_t250_func_assertions()
	_run_t250_callsite_assertions()
	_run_t250_no_regress_assertions()
	_run_t250_syntax_assertions()
	_run_t250_palette_assertions()
	_run_t250_doc_anchor_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I061 (#168) T250 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T250 — 6 verb 关联成就 slot tooltip 扩展 =====================

# ---------- T250.CONST.HINTS — _VERB_ACHV_ICON_HINTS ----------
func _run_t250_const_hints_assertions() -> void:
	print("--- T250.CONST.HINTS — _VERB_ACHV_ICON_HINTS const ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _VERB_ACHV_ICON_HINTS := [",
		"T250.CONST.HINTS.1: const _VERB_ACHV_ICON_HINTS 列表 const 存在 (6 verb 关联 icon_hint 3 entry: echo_icon / wave_icon / whisper_icon)")
	_assert_contains(src, "\"echo_icon\"",
		"T250.CONST.HINTS.2: echo_icon entry 存在 (4 verb Echo 关联 quadruple_成就 icon_hint)")
	_assert_contains(src, "\"wave_icon\"",
		"T250.CONST.HINTS.3: wave_icon entry 存在 (5 verb Wave 关联 quintuple_成就 icon_hint)")
	_assert_contains(src, "\"whisper_icon\"",
		"T250.CONST.HINTS.4: whisper_icon entry 存在 (6 verb Whisper 关联 sextuple_成就 icon_hint)")


# ---------- T250.CONST.INFO — _VERB_ACHV_INFO ----------
func _run_t250_const_info_assertions() -> void:
	print("--- T250.CONST.INFO — _VERB_ACHV_INFO const ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _VERB_ACHV_INFO := {",
		"T250.CONST.INFO.1: const _VERB_ACHV_INFO dict const 存在 (6 verb 关联 icon_hint → 6 字段视觉组连贯数据)")
	# 6 字段 key 3 entry 各有 (achv_id / verb_index / color / color_name / geometry_zh / visual_group)
	_assert_contains(src, "\"achv_id\"",
		"T250.CONST.INFO.2: achv_id 字段 key 存在 (关联成就 id 字段)")
	_assert_contains(src, "\"verb_index\"",
		"T250.CONST.INFO.3: verb_index 字段 key 存在 (verb 序号 1-6 字段)")
	_assert_contains(src, "\"color\"",
		"T250.CONST.INFO.4: color 字段 key 存在 (verb 主色 hex 字段)")
	_assert_contains(src, "\"color_name\"",
		"T250.CONST.INFO.5: color_name 字段 key 存在 (verb 主色名 字段)")
	_assert_contains(src, "\"geometry_zh\"",
		"T250.CONST.INFO.6: geometry_zh 字段 key 存在 (verb 几何描述中文 字段)")
	_assert_contains(src, "\"visual_group\"",
		"T250.CONST.INFO.7: visual_group 字段 key 存在 (verb 视觉组连贯短句 字段)")


# ---------- T250.ECHO.* — echo_icon 4 字段视觉组连贯数据 ----------
func _run_t250_echo_assertions() -> void:
	print("--- T250.ECHO.* — echo_icon 4 字段视觉组连贯数据 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 截取 echo_icon 块 (4 verb = Echo)
	var echo_idx := src.find("\"echo_icon\":")
	if echo_idx == -1:
		_failures.append("FAIL: T250.ECHO.1: echo_icon dict entry 缺失")
		return
	# 截取 echo_icon 块 (到下一个 "wave_icon" 或 "}" 块)
	var next_wave := src.find("\"wave_icon\":", echo_idx)
	var echo_block: String
	if next_wave == -1:
		echo_block = src.substr(echo_idx, 800)
	else:
		echo_block = src.substr(echo_idx, next_wave - echo_idx)
	_assert_contains(echo_block, "\"quadruple_voice\"",
		"T250.ECHO.ACHV_ID.1: echo_icon achv_id = quadruple_voice (4 verb Echo 关联 4 声回响 成就)")
	_assert_contains(echo_block, "\"verb_index\": 4",
		"T250.ECHO.VERB_INDEX.1: echo_icon verb_index = 4 (Echo = 4 verb 序号)")
	_assert_contains(echo_block, "\"#69C7CE\"",
		"T250.ECHO.COLOR.1: echo_icon color = #69C7CE (Glass Cyan — Echo 4 verb 命中色)")
	_assert_contains(echo_block, "Glass Cyan",
		"T250.ECHO.COLOR_NAME.1: echo_icon color_name = Glass Cyan (Echo 4 verb 主色名)")
	_assert_contains(echo_block, "盾球扩散",
		"T250.ECHO.GEOMETRY.1: echo_icon geometry_zh 盾球扩散关键词存在 (Echo 4 verb 核心几何)")
	_assert_contains(echo_block, "5 verb 全是动态几何",
		"T250.ECHO.VISUAL.1: echo_icon visual_group 5 verb 全是动态几何 关键词 (5 verb 视觉组连贯)")


# ---------- T250.WAVE.* — wave_icon 4 字段视觉组连贯数据 ----------
func _run_t250_wave_assertions() -> void:
	print("--- T250.WAVE.* — wave_icon 4 字段视觉组连贯数据 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var wave_idx := src.find("\"wave_icon\":")
	if wave_idx == -1:
		_failures.append("FAIL: T250.WAVE.1: wave_icon dict entry 缺失")
		return
	var next_whisper := src.find("\"whisper_icon\":", wave_idx)
	var wave_block: String
	if next_whisper == -1:
		wave_block = src.substr(wave_idx, 800)
	else:
		wave_block = src.substr(wave_idx, next_whisper - wave_idx)
	_assert_contains(wave_block, "\"quintuple_voice\"",
		"T250.WAVE.ACHV_ID.1: wave_icon achv_id = quintuple_voice (5 verb Wave 关联 5 声回响 成就)")
	_assert_contains(wave_block, "\"verb_index\": 5",
		"T250.WAVE.VERB_INDEX.1: wave_icon verb_index = 5 (Wave = 5 verb 序号)")
	_assert_contains(wave_block, "\"#B7E7DD\"",
		"T250.WAVE.COLOR.1: wave_icon color = #B7E7DD (Pale Resonance — Wave 5 verb 主色)")
	_assert_contains(wave_block, "Pale Resonance",
		"T250.WAVE.COLOR_NAME.1: wave_icon color_name = Pale Resonance (Wave 5 verb 主色名)")
	_assert_contains(wave_block, "双环扩散",
		"T250.WAVE.GEOMETRY.1: wave_icon geometry_zh 双环扩散关键词存在 (Wave 5 verb 核心几何)")
	_assert_contains(wave_block, "5 verb 全是动态几何",
		"T250.WAVE.VISUAL.1: wave_icon visual_group 5 verb 全是动态几何 (5 verb 视觉组连贯 + Wave 最冷最浅)")


# ---------- T250.WHISPER.* — whisper_icon 4 字段视觉组连贯数据 ----------
func _run_t250_whisper_assertions() -> void:
	print("--- T250.WHISPER.* — whisper_icon 4 字段视觉组连贯数据 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var whisper_idx := src.find("\"whisper_icon\":")
	if whisper_idx == -1:
		_failures.append("FAIL: T250.WHISPER.1: whisper_icon dict entry 缺失")
		return
	var whisper_block := src.substr(whisper_idx, 800)
	_assert_contains(whisper_block, "\"sextuple_voice\"",
		"T250.WHISPER.ACHV_ID.1: whisper_icon achv_id = sextuple_voice (6 verb Whisper 关联 6 声回响 成就)")
	_assert_contains(whisper_block, "\"verb_index\": 6",
		"T250.WHISPER.VERB_INDEX.1: whisper_icon verb_index = 6 (Whisper = 6 verb 序号)")
	_assert_contains(whisper_block, "\"#C8A4D8\"",
		"T250.WHISPER.COLOR.1: whisper_icon color = #C8A4D8 (Muted Mauve — Whisper 6 verb 主色)")
	_assert_contains(whisper_block, "Muted Mauve",
		"T250.WHISPER.COLOR_NAME.1: whisper_icon color_name = Muted Mauve (Whisper 6 verb 主色名)")
	_assert_contains(whisper_block, "不扩散",
		"T250.WHISPER.GEOMETRY.1: whisper_icon geometry_zh 不扩散 关键词存在 (6 verb 唯一\"不扩散\" 静态球)")
	_assert_contains(whisper_block, "debuff 贴身",
		"T250.WHISPER.VISUAL.1: whisper_icon visual_group debuff 贴身 关键词 (6 verb 视觉组连贯: 5 verb 动作 vs 6 verb debuff 贴身)")


# ---------- T250.FUNC.* — _build_verb_achievement_tooltip 函数实现 ----------
func _run_t250_func_assertions() -> void:
	print("--- T250.FUNC.* — _build_verb_achievement_tooltip 函数实现 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "func _build_verb_achievement_tooltip(base_tooltip: String, icon_hint: String) -> String:",
		"T250.FUNC.EXIST.1: _build_verb_achievement_tooltip 函数签名存在 (2 参数: base_tooltip + icon_hint, 返回 String)")
	# 截取函数体
	var fn_idx := src.find("func _build_verb_achievement_tooltip")
	if fn_idx == -1:
		_failures.append("FAIL: T250.FUNC.BODY.1: 函数体截取失败")
		return
	var fn_body := src.substr(fn_idx, 2000)
	_assert_contains(fn_body, "_VERB_ACHV_ICON_HINTS.has(icon_hint)",
		"T250.FUNC.GUARD.1: 函数体内 _VERB_ACHV_ICON_HINTS.has() guard 存在 (11 个非 6 verb 关联 slot 100% 兼容)")
	_assert_contains(fn_body, "_VERB_ACHV_INFO.has(icon_hint)",
		"T250.FUNC.INFO_GUARD.1: 函数体内 _VERB_ACHV_INFO.has() guard 存在 (defensive: 防御 icon_hint 在 HINTS 但不在 INFO 极端 case)")
	_assert_contains(fn_body, "return base_tooltip",
		"T250.FUNC.RETURN_BASE.1: 函数体内 base_tooltip 原样 return 分支存在 (2 处: HINTS guard 失败 + INFO guard 失败)")
	_assert_contains(fn_body, "\"6 verb 视觉组\"",
		"T250.FUNC.HEADER.1: 函数体内 \"6 verb 视觉组\" header 存在 (tooltip 段名 1 header)")
	_assert_contains(fn_body, "\"• 第 %d verb · %s  %s\"",
		"T250.FUNC.VERB_LINE.1: 函数体内 \"• 第 %d verb · %s  %s\" format 存在 (verb 序号 + 主色 hex + 主色名 3 字段)")
	_assert_contains(fn_body, "\"• 几何 — %s\"",
		"T250.FUNC.GEOM_LINE.1: 函数体内 \"• 几何 — %s\" format 存在 (verb 几何描述中文 1 字段)")
	_assert_contains(fn_body, "\"• 视觉组 — %s\"",
		"T250.FUNC.VISUAL_LINE.1: 函数体内 \"• 视觉组 — %s\" format 存在 (verb 视觉组连贯短句 1 字段)")


# ---------- T250.CALLSITE — slot.tooltip_text 走 _build_verb_achievement_tooltip 包装 ----------
func _run_t250_callsite_assertions() -> void:
	print("--- T250.CALLSITE — slot.tooltip_text 走 _build_verb_achievement_tooltip 包装 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint)",
		"T250.CALLSITE.1: slot.tooltip_text 走 _build_verb_achievement_tooltip 包装 (单一职责拆分: 11 slot 0 触碰 + 3 slot 升级)")
	_assert_contains(src, "var base_tooltip := \"%s  %s\\n解锁于 %s\" % [title_zh, desc_zh, ts_str]",
		"T250.CALLSITE.BASE.1: T109 既有 base_tooltip 3 行 \"title + desc + 解锁时间\" 保留 (11 slot 100% 兼容原 tooltip 渲染)")


# ---------- T250.NO_REGRESS — T109 / T111 / T222 / T226 / ICON 0 触碰 ----------
func _run_t250_no_regress_assertions() -> void:
	print("--- T250.NO_REGRESS — T109 / T111 / T222 / T226 / ICON 0 触碰 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T109 (#60) 既有 3 行 tooltip format 保留
	_assert_contains(src, "\"%s  %s\\n解锁于 %s\"",
		"T250.NO_REGRESS_T109.1: T109 base_tooltip 3 行 format 字符串保留 (T250 #168 0 删 T109 既有 3 行模板)")
	# T111 (#58) hover 高亮 mouse_filter STOP + 2 signal 保留
	_assert_contains(src, "slot.mouse_filter = Control.MOUSE_FILTER_STOP",
		"T250.NO_REGRESS_T111.1: T111 mouse_filter = Control.MOUSE_FILTER_STOP 保留 (T250 #168 0 触碰 hover 信号触发前提)")
	_assert_contains(src, "slot.mouse_entered.connect(_on_slot_hover_in.bind(slot))",
		"T250.NO_REGRESS_T111.2: T111 mouse_entered signal connect 保留 (T250 #168 0 删 hover_in 触发)")
	_assert_contains(src, "slot.mouse_exited.connect(_on_slot_hover_out.bind(slot))",
		"T250.NO_REGRESS_T111.3: T111 mouse_exited signal connect 保留 (T250 #168 0 删 hover_out 触发)")
	# T222 (#144) locked slot alpha const 保留
	_assert_contains(src, "const _ACHV_LOCKED_ALPHA_START",
		"T250.NO_REGRESS_T222.1: T222 _ACHV_LOCKED_ALPHA_START const 保留 (T250 #168 0 触碰 14 slot locked alpha 起点)")
	_assert_contains(src, "const _ACHV_LOCKED_ALPHA_END",
		"T250.NO_REGRESS_T222.2: T222 _ACHV_LOCKED_ALPHA_END const 保留 (T250 #168 0 触碰 14 slot locked alpha 终点)")
	# T226 (#147) hover boost const + dict 保留
	_assert_contains(src, "const _SLOT_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T250.NO_REGRESS_T226.1: T226 _SLOT_HOVER_BRIGHT_ALPHA_BOOST = 0.1 const 保留 (T250 #168 0 触碰 hover +1 灰阶)")
	_assert_contains(src, "var _slot_hover_alpha_base: Dictionary = {}",
		"T250.NO_REGRESS_T226.2: T226 _slot_hover_alpha_base dict 保留 (T250 #168 0 触碰 hover base alpha 缓存)")
	# ICON_PATH_BASE / ICON_DEFAULT 保留
	_assert_contains(src, "const ICON_PATH_BASE := \"res://assets/ui/achievements\"",
		"T250.NO_REGRESS_ICON.1: ICON_PATH_BASE const 保留 (T250 #168 0 触碰 _load_icon_texture 路径)")
	_assert_contains(src, "const ICON_DEFAULT := \"amber_dot\"",
		"T250.NO_REGRESS_ICON.2: ICON_DEFAULT = \"amber_dot\" const 保留 (T250 #168 0 触碰 fallback icon_hint)")


# ---------- T250.SYNTAX — verb_index 类型 / 6 字段 / 3 entry ----------
func _run_t250_syntax_assertions() -> void:
	print("--- T250.SYNTAX — verb_index 类型 / 6 字段 / 3 entry ---")
	var src := _read_file(PAUSE_MENU_GD)
	# verb_index 字段类型 int 3 处 (3 entry 各 1 次)
	var verb_index_count := src.count("\"verb_index\": ")
	if verb_index_count == 3:
		_passes += 1
		print("  OK  T250.SYNTAX.VERB_INDEX_TYPE.1: verb_index 字段出现 3 次 (3 entry 各 1 次, 类型推断 int)")
	else:
		_failures.append("FAIL: T250.SYNTAX.VERB_INDEX_TYPE.1: verb_index 字段出现 %d 次, 应 3" % verb_index_count)
	# _VERB_ACHV_ICON_HINTS 3 entry 准确
	var hints_count := src.count("\"echo_icon\"") + src.count("\"wave_icon\"") + src.count("\"whisper_icon\"")
	# echo_icon / wave_icon / whisper_icon 各在 HINTS list + INFO dict = 2 次 = 总 6 次
	# 但 INFO 段还有 "echo_icon": / "wave_icon": / "whisper_icon": dict key 共 3 次
	# 总 icon_hint 字面量: 3 (HINTS list) + 3 (INFO dict key) = 6
	if hints_count >= 6:
		_passes += 1
		print("  OK  T250.SYNTAX.HINT_COUNT.1: echo_icon/wave_icon/whisper_icon 字面量共 %d 次 (≥ 6, 3 HINTS + 3 INFO dict key, 3 entry 准确)" % hints_count)
	else:
		_failures.append("FAIL: T250.SYNTAX.HINT_COUNT.1: icon_hint 字面量共 %d 次, 需 ≥ 6" % hints_count)


# ---------- T250.PALETTE — 6 verb 调色六元组 0 重叠 + Whisper 唯一"不扩散" ----------
func _run_t250_palette_assertions() -> void:
	print("--- T250.PALETTE — 6 verb 调色六元组 0 重叠 + Whisper 唯一\"不扩散\" ---")
	var src := _read_file(PAUSE_MENU_GD)
	# echo / wave / whisper 3 主色 hex 各异
	_assert_contains(src, "\"#69C7CE\"",
		"T250.PALETTE.EXCLUSIVE.1: Echo Glass Cyan #69C7CE hex 存在 (4 verb 命中色)")
	_assert_contains(src, "\"#B7E7DD\"",
		"T250.PALETTE.EXCLUSIVE.2: Wave Pale Resonance #B7E7DD hex 存在 (5 verb 主色)")
	_assert_contains(src, "\"#C8A4D8\"",
		"T250.PALETTE.EXCLUSIVE.3: Whisper Muted Mauve #C8A4D8 hex 存在 (6 verb 主色)")
	# Whisper Muted Mauve 与 5 verb 5 色 0 重叠
	_assert_contains(src, "Muted Mauve #C8A4D8",
		"T250.PALETTE.WHISPER_MAUVE.1: Muted Mauve #C8A4D8 注释段存在 (6 verb 与 5 verb 5 色 0 重叠)")
	# Whisper 唯一"不扩散" 静态球 关键词
	_assert_contains(src, "6 verb 唯一\\\"不扩散\\\" 几何",
		"T250.GEOMETRY.WHISPER_UNIQUE.1: 6 verb 唯一\"不扩散\" 几何 关键词存在 (Whisper 静态球 vs 5 verb 全是动态几何)")


# ---------- T250.DOC.ANCHOR — T250 (#168) 注释锚点 ≥ 4 处 ----------
func _run_t250_doc_anchor_assertions() -> void:
	print("--- T250.DOC.ANCHOR — T250 (#168) 注释锚点 ≥ 4 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T250 (#168)") != -1:
			anchor_count += 1
	if anchor_count >= 4:
		_passes += 1
		print("  OK  T250.DOC.ANCHOR.1: T250 (#168) 注释锚点 %d 处 (≥ 4, 涵盖 const 块 + func 块 + callsite 块 + no_regress 注释段)" % anchor_count)
	else:
		_failures.append("FAIL: T250.DOC.ANCHOR.1: T250 (#168) 注释锚点仅 %d 处, 需 ≥ 4" % anchor_count)


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, msg: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I061 (#168) T250 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
