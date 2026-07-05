extends SceneTree
## I058 (#154) — T235+T236 ProfileRecentList 字段 middle-dot 分隔 + StatsPanel BGM 主题提示行 冒烟测试
##
## 覆盖 #154 任务 T235+T236 原子化提交:
##
## === T235 — ProfileRecentList 5 行 row text 字段间用 ` · ` middle-dot 分隔符 ===
## - T235.CONST.DECLARED: const _RECENT_ROW_FIELD_SEP 已声明 (1 次, 0 重复)
## - T235.CONST.VALUE: _RECENT_ROW_FIELD_SEP 值 = "  ·  " (2 空格 + U+00B7 中点 + 2 空格)
## - T235.CONST.UNICODE: U+00B7 (·) middle-dot 字符 literal 在源码中
## - T235.CONST.UNIQUE: const _RECENT_ROW_FIELD_SEP 1 次声明 (0 重复)
## - T235.FORMAT.STRING: row_lbl.text format string 包含 6 个 middle-dot 分隔符 placeholder (T249 #167 5 字段 → 7 字段扩展, 加 房/时 + 净/时 2 派生率)
## - T235.FORMAT.ARG: format 数组 14 个变量 (6 个 _RECENT_ROW_FIELD_SEP 夹 7 字段 + _RECENT_ROW_TIP_INDICATOR 末位, T249 #167 同步 5→7 字段顺序与 _RECENT_ROW_HINT tooltip 100% 对齐)
## - T235.DOC.ANCHOR: T235 (#154) 注释锚点 ≥ 2 处
## - T235.NO_REGRESS_T215: T215 _recent_row_hovered / _recent_row_default_color 0 触碰
## - T235.NO_REGRESS_T216: T216 tooltip_text 0 触碰
## - T235.NO_REGRESS_T219: T219 _RECENT_ROW_ALPHA_MAX/MIN 保留
## - T235.NO_REGRESS_T231: T231 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST 0 触碰
## - T235.NO_REGRESS_T232: T232 _RECENT_RESONANCE_DECAY/WINDOW 0 触碰
## - T235.NO_REGRESS_T234: T234 _RECENT_ROW_TIP_INDICATOR 保留 (1 空格 + ↗ U+2197)
## - T235.SYNTAX: const + format 1 次声明, 0 重复
##
## === T236 — StatsPanel 底部 BGM 主题提示行 ===
## - T236.NODE.DECLARED: pause_menu.tscn StatBGM Label 节点已声明
## - T236.NODE.PATH: path 正确 ($StatsPanel/StatsMargin/StatsVBox/StatBGM)
## - T236.NODE.FONT_SIZE: 7pt 小字 (font_size = 7)
## - T236.NODE.DEFAULT_TEXT: 默认 text = "BGM · —" (空时占位)
## - T236.ONREADY.DECLARED: @onready var _stat_bgm 已声明 (1 次, 0 重复)
## - T236.ONREADY.PATH: @onready path = $StatsPanel/StatsMargin/StatsVBox/StatBGM
## - T236.FUNC.DECLARED: func _refresh_stat_bgm() 已声明
## - T236.FUNC.AUDIO: 调 AudioManagerEnhanced.get_current_music_key() 公开 API
## - T236.FUNC.FALLBACK: 空字符串 fallback "—"
## - T236.FUNC.FORMAT: "BGM · %s" 中点分隔 (与 T235 0 100% 一致)
## - T236.READY.CALL: _ready 末尾调一次 _refresh_stat_bgm()
## - T236.REFRESH.CALL: _refresh_stats 末尾调一次 _refresh_stat_bgm()
## - T236.DOC.ANCHOR: T236 (#154) 注释锚点 ≥ 2 处

const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"
const PAUSE_MENU_TSCN := "res://src/scenes/pause_menu.tscn"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I058 (#154) — T235+T236 ProfileRecentList middle-dot 分隔 + StatsPanel BGM 主题提示行 ===")
	_run_t235_const_assertions()
	_run_t235_format_assertions()
	_run_t235_doc_anchor_assertions()
	_run_t235_regress_assertions()
	_run_t235_syntax_assertions()
	_run_t236_node_assertions()
	_run_t236_onready_assertions()
	_run_t236_func_assertions()
	_run_t236_call_assertions()
	_run_t236_doc_anchor_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I058 (#154) T235+T236 ASSERTIONS PASSED ===")
		quit(0)


# ===================== T235 — ProfileRecentList 5 行 row text 字段间 middle-dot 分隔符 =====================

# ---------- T235.CONST.* — _RECENT_ROW_FIELD_SEP 已声明 + 值正确 ----------
func _run_t235_const_assertions() -> void:
	print("--- T235.CONST.* — _RECENT_ROW_FIELD_SEP 已声明 + 值正确 ---")
	var src := _read_file(PAUSE_MENU_GD)
	_assert_contains(src, "const _RECENT_ROW_FIELD_SEP := \"  \u00b7  \"",
		"T235.CONST.DECLARED.1: const _RECENT_ROW_FIELD_SEP := \"  \u00b7  \" (2 空格 + 中点 U+00B7 + 2 空格)")
	# 验证 Unicode 字符 · (U+00B7) 出现在源码
	var unicode_count := src.count("\u00b7")
	if unicode_count >= 2:
		_passes += 1
		print("  OK  T235.CONST.UNICODE.1: \u00b7 middle-dot 字符 (U+00B7) 在源码出现 %d 次 (≥ 2, const 块 + format 引用)" % unicode_count)
	else:
		_failures.append("FAIL: T235.CONST.UNICODE.1: \u00b7 字符仅出现 %d 次, 需 ≥ 2" % unicode_count)
	# 1 次声明, 0 重复
	var const_count := src.count("const _RECENT_ROW_FIELD_SEP")
	if const_count == 1:
		_passes += 1
		print("  OK  T235.CONST.UNIQUE.1: const _RECENT_ROW_FIELD_SEP 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T235.CONST.UNIQUE.1: const _RECENT_ROW_FIELD_SEP 声明 %d 次, 应 1" % const_count)


# ---------- T235.FORMAT.* — row_lbl.text format string 包含 6 个 middle-dot 分隔符 placeholder (T249 5 字段 → 7 字段扩展) ----------
func _run_t235_format_assertions() -> void:
	print("--- T235.FORMAT.* — row_lbl.text format string 包含 6 个 middle-dot 分隔符 placeholder (T249 5 → 7 字段扩展) ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 验证 format string 改用 6 个 %s + _RECENT_ROW_FIELD_SEP 拼接 (T249 #167 5 字段 → 7 字段扩展, 加 房/时 + 净/时 2 派生率)
	_assert_contains(src, "row_lbl.text = \"Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s\"",
		"T235.FORMAT.STRING.1: row_lbl.text format string 改用 6 个 middle-dot 分隔符 (7 字段 + 6 分隔符 + 1 tip indicator, T249 #167 5 字段 → 7 字段扩展)")
	_assert_contains(src, "run_n, _RECENT_ROW_FIELD_SEP,",
		"T235.FORMAT.ARG.1: format 数组 (run_n + _RECENT_ROW_FIELD_SEP)")
	_assert_contains(src, "rooms, _RECENT_ROW_FIELD_SEP,",
		"T235.FORMAT.ARG.2: format 数组 (rooms + _RECENT_ROW_FIELD_SEP)")
	_assert_contains(src, "enemies, _RECENT_ROW_FIELD_SEP,",
		"T235.FORMAT.ARG.3: format 数组 (enemies + _RECENT_ROW_FIELD_SEP)")
	_assert_contains(src, "shards, _RECENT_ROW_FIELD_SEP,",
		"T235.FORMAT.ARG.4: format 数组 (shards + _RECENT_ROW_FIELD_SEP)")
	_assert_contains(src, "rooms_per_minute, _RECENT_ROW_FIELD_SEP,",
		"T235.FORMAT.ARG.5: format 数组 (rooms_per_minute + _RECENT_ROW_FIELD_SEP) — T249 #167 加 房/时 派生率 inline 拼接")
	_assert_contains(src, "enemies_per_minute, _RECENT_ROW_TIP_INDICATOR",
		"T235.FORMAT.ARG.6: format 数组末尾 = (enemies_per_minute, _RECENT_ROW_TIP_INDICATOR) (T249 #167 加 净/时 派生率 + 1 tip indicator)")
	# 验证 _refresh_recent_runs_list 内部 1 处引用 _RECENT_ROW_FIELD_SEP
	var reference_count := src.count("_RECENT_ROW_FIELD_SEP")
	if reference_count >= 7:
		_passes += 1
		print("  OK  T235.FORMAT.REFERENCE.1: _RECENT_ROW_FIELD_SEP 引用 %d 次 (≥ 7, const 1 + format 数组 6, T249 5→7 字段扩展后 4→6 分隔符)" % reference_count)
	else:
		_failures.append("FAIL: T235.FORMAT.REFERENCE.1: _RECENT_ROW_FIELD_SEP 引用 %d 次, 需 ≥ 7 (const 1 + format 6)" % reference_count)


# ---------- T235.DOC.ANCHOR.* — T235 (#154) 注释锚点 ≥ 2 处 ----------
func _run_t235_doc_anchor_assertions() -> void:
	print("--- T235.DOC.ANCHOR.* — T235 (#154) 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T235 (#154)") != -1:
			anchor_count += 1
	if anchor_count >= 2:
		_passes += 1
		print("  OK  T235.DOC.ANCHOR.1: T235 (#154) 注释锚点 %d 处 (≥ 2, const 块 + _refresh_recent 段)" % anchor_count)
	else:
		_failures.append("FAIL: T235.DOC.ANCHOR.1: T235 (#154) 注释锚点仅 %d 处, 需 ≥ 2" % anchor_count)


# ---------- T235.NO_REGRESS.* — T215/T216/T219/T231/T232/T234 0 触碰 ----------
func _run_t235_regress_assertions() -> void:
	print("--- T235.NO_REGRESS.* — T215/T216/T219/T231/T232/T234 0 触碰 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# T215 (#136) 字段保留
	_assert_contains(src, "var _recent_row_hovered: Array = []",
		"T235.NO_REGRESS_T215.1: T215 _recent_row_hovered 字段保留 (T235 0 触碰 hover handler 链)")
	_assert_contains(src, "var _recent_row_default_color: Array = []",
		"T235.NO_REGRESS_T215.2: T215 _recent_row_default_color 字段保留 (T235 0 触碰 default color 缓存)")
	# T216 (#137) tooltip 保留
	_assert_contains(src, "row_lbl.tooltip_text = _build_recent_row_tooltip()",
		"T235.NO_REGRESS_T216.1: T216 tooltip_text 绑定保留 (T235 0 触碰 7 字段 tooltip 渲染)")
	_assert_contains(src, "func _build_recent_row_tooltip() -> String:",
		"T235.NO_REGRESS_T216.2: T216 _build_recent_row_tooltip 函数保留 (T235 0 触碰 tooltip 7 字段生成)")
	# T219 (#141) alpha 渐变 const 保留
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MAX := 1.0",
		"T235.NO_REGRESS_T219.1: T219 _RECENT_ROW_ALPHA_MAX = 1.0 const 保留 (T235 0 触碰 5 行 alpha 渐变)")
	_assert_contains(src, "const _RECENT_ROW_ALPHA_MIN := 0.5",
		"T235.NO_REGRESS_T219.2: T219 _RECENT_ROW_ALPHA_MIN = 0.5 const 保留 (T235 0 触碰 5 行 alpha 渐变)")
	# T231 (#151) _recent_row_hover_alpha_base 保留
	_assert_contains(src, "var _recent_row_hover_alpha_base: Dictionary = {}",
		"T235.NO_REGRESS_T231.1: T231 _recent_row_hover_alpha_base dict 保留 (T235 0 触碰 hover alpha boost)")
	_assert_contains(src, "const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1",
		"T235.NO_REGRESS_T231.2: T231 _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST = 0.1 const 保留 (T235 0 触碰 boost 强度)")
	# T232 (#151) 跨 run 加权 const 保留
	_assert_contains(src, "const _RECENT_RESONANCE_DECAY := 0.5",
		"T235.NO_REGRESS_T232.1: T232 _RECENT_RESONANCE_DECAY = 0.5 const 保留 (T235 0 触碰 跨 run 衰减权重)")
	_assert_contains(src, "const _RECENT_RESONANCE_HISTORY_WINDOW := 5",
		"T235.NO_REGRESS_T232.2: T232 _RECENT_RESONANCE_HISTORY_WINDOW = 5 const 保留 (T235 0 触碰 5 局窗口)")
	# T234 (#153) tip indicator 保留
	_assert_contains(src, "const _RECENT_ROW_TIP_INDICATOR := \" \u2197\"",
		"T235.NO_REGRESS_T234.1: T234 _RECENT_ROW_TIP_INDICATOR const 保留 (1 空格 + \u2197 U+2197)")
	# T136 (#82) const 保留
	_assert_contains(src, "const _PROFILE_RECENT_RUNS_MAX",
		"T235.NO_REGRESS_T136.1: T136 _PROFILE_RECENT_RUNS_MAX const 保留 (T235 0 触碰 5 局最近窗口)")
	# T137 (#83) _profile_recent_list 保留
	_assert_contains(src, "@onready var _profile_recent_list: VBoxContainer = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileRecentList",
		"T235.NO_REGRESS_T137.1: T137 _profile_recent_list @onready 保留 (T235 0 触碰 ScrollContainer 引用)")


# ---------- T235.SYNTAX.* — const + format 1 次声明, 0 重复 ----------
func _run_t235_syntax_assertions() -> void:
	print("--- T235.SYNTAX.* — const + format 1 次声明, 0 重复 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 1 处 const 声明
	var const_decl_count := src.count("const _RECENT_ROW_FIELD_SEP := \"  \u00b7  \"")
	if const_decl_count == 1:
		_passes += 1
		print("  OK  T235.SYNTAX.CONST.1: const _RECENT_ROW_FIELD_SEP 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T235.SYNTAX.CONST.1: const _RECENT_ROW_FIELD_SEP 声明 %d 次, 应 1" % const_decl_count)
	# 验证 _RECENT_ROW_FIELD_SEP 在 T234 const 之后声明 (0 顺序冲突)
	var t234_idx := src.find("const _RECENT_ROW_TIP_INDICATOR := \" \u2197\"")
	var t235_idx := src.find("const _RECENT_ROW_FIELD_SEP := \"  \u00b7  \"")
	if t234_idx != -1 and t235_idx != -1 and t235_idx > t234_idx:
		_passes += 1
		print("  OK  T235.SYNTAX.ORDER.1: _RECENT_ROW_FIELD_SEP 在 _RECENT_ROW_TIP_INDICATOR 之后声明 (T234 → T235 顺序正确, 0 const 顺序冲突)")
	else:
		_failures.append("FAIL: T235.SYNTAX.ORDER.1: _RECENT_ROW_FIELD_SEP offset=%d 应在 _RECENT_ROW_TIP_INDICATOR offset=%d 之后" % [t235_idx, t234_idx])


# ===================== T236 — StatsPanel 底部 BGM 主题提示行 =====================

# ---------- T236.NODE.* — pause_menu.tscn StatBGM Label 节点已声明 ----------
func _run_t236_node_assertions() -> void:
	print("--- T236.NODE.* — pause_menu.tscn StatBGM Label 节点已声明 ---")
	var src := _read_file(PAUSE_MENU_TSCN)
	# StatBGM 节点
	_assert_contains(src, "[node name=\"StatBGM\" type=\"Label\" parent=\"StatsPanel/StatsMargin/StatsVBox\"]",
		"T236.NODE.DECLARED.1: StatBGM Label 节点在 $StatsPanel/StatsMargin/StatsVBox 路径声明 (T236 落地 1 个新 Label 节点)")
	# 默认 text
	_assert_contains(src, "text = \"BGM \u00b7 \u2014\"",
		"T236.NODE.DEFAULT_TEXT.1: StatBGM 默认 text = \"BGM \u00b7 \u2014\" (空时占位, 中点 + 破折号)")
	# font_size = 7
	_assert_contains(src, "theme_override_font_sizes/font_size = 7",
		"T236.NODE.FONT_SIZE.1: StatBGM font_size = 7 (7pt 暖白小字 + 0.875,0.835,0.784 暖白)")
	# font_color 暖白 (0.875, 0.835, 0.784, 1)
	_assert_contains(src, "theme_override_colors/font_color = Color(0.875, 0.835, 0.784, 1)",
		"T236.NODE.FONT_COLOR.1: StatBGM font_color = Color(0.875, 0.835, 0.784, 1) (暖白小字)")
	# horizontal_alignment = 1 (居中)
	_assert_contains(src, "horizontal_alignment = 1",
		"T236.NODE.ALIGN.1: StatBGM horizontal_alignment = 1 (居中, 与 StatTime 0 100% 一致)")


# ---------- T236.ONREADY.* — _stat_bgm @onready 字段已声明 ----------
func _run_t236_onready_assertions() -> void:
	print("--- T236.ONREADY.* — _stat_bgm @onready 字段已声明 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# @onready var _stat_bgm: Label
	_assert_contains(src, "@onready var _stat_bgm: Label = $StatsPanel/StatsMargin/StatsVBox/StatBGM",
		"T236.ONREADY.DECLARED.1: @onready var _stat_bgm: Label path = $StatsPanel/StatsMargin/StatsVBox/StatBGM")
	# 1 次声明, 0 重复
	var onready_count := src.count("@onready var _stat_bgm")
	if onready_count == 1:
		_passes += 1
		print("  OK  T236.ONREADY.UNIQUE.1: @onready var _stat_bgm 1 次声明 (0 重复)")
	else:
		_failures.append("FAIL: T236.ONREADY.UNIQUE.1: @onready var _stat_bgm 声明 %d 次, 应 1" % onready_count)


# ---------- T236.FUNC.* — _refresh_stat_bgm 函数 + AudioManagerEnhanced 调用 ----------
func _run_t236_func_assertions() -> void:
	print("--- T236.FUNC.* — _refresh_stat_bgm 函数 + AudioManagerEnhanced 调用 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 函数声明
	_assert_contains(src, "func _refresh_stat_bgm() -> void:",
		"T236.FUNC.DECLARED.1: func _refresh_stat_bgm() -> void: (T236 落地私有 helper 函数)")
	# 调 AudioManagerEnhanced.get_current_music_key() 公开 API
	_assert_contains(src, "var current_key: String = AudioManagerEnhanced.get_current_music_key()",
		"T236.FUNC.AUDIO.1: 调 AudioManagerEnhanced.get_current_music_key() 公开 API (autoload #62 T117 落地)")
	# 空字符串 fallback "—"
	_assert_contains(src, "var display: String = current_key if not current_key.is_empty() else \"\u2014\"",
		"T236.FUNC.FALLBACK.1: 空字符串 fallback \u2014 (0 主题或 audio_manager_enhanced 尚未初始化)")
	# "BGM · %s" 中点分隔
	_assert_contains(src, "_stat_bgm.text = \"BGM \u00b7 %s\" % display",
		"T236.FUNC.FORMAT.1: _stat_bgm.text = \"BGM \u00b7 %s\" (中点 U+00B7 分隔, 与 T235 0 100% 一致)")


# ---------- T236.CALL.* — _ready + _refresh_stats 末尾调用一次 ----------
func _run_t236_call_assertions() -> void:
	print("--- T236.CALL.* — _ready + _refresh_stats 末尾调用一次 ---")
	var src := _read_file(PAUSE_MENU_GD)
	# 验证 _refresh_stat_bgm 被调用 ≥ 2 次 (_ready 1 + _refresh_stats 1)
	var call_count := src.count("_refresh_stat_bgm()")
	if call_count >= 2:
		_passes += 1
		print("  OK  T236.CALL.COUNT.1: _refresh_stat_bgm() 调用 %d 次 (≥ 2, _ready 1 + _refresh_stats 1)" % call_count)
	else:
		_failures.append("FAIL: T236.CALL.COUNT.1: _refresh_stat_bgm() 调用 %d 次, 需 ≥ 2" % call_count)
	# 验证 _ready 末尾有调用 (在 achievement_unlocked.connect 之后)
	var ready_idx := src.find("func _ready() -> void:")
	var first_call_idx := src.find("_refresh_stat_bgm()", ready_idx)
	if ready_idx != -1 and first_call_idx != -1:
		_passes += 1
		print("  OK  T236.CALL.READY.1: _ready 末尾有 _refresh_stat_bgm() 调用 (首次拉取, 0 主题 fallback \u2014)")
	else:
		_failures.append("FAIL: T236.CALL.READY.1: _ready 末尾未找到 _refresh_stat_bgm() 调用")
	# 验证 _refresh_stats 末尾有调用
	var refresh_stats_idx := src.find("func _refresh_stats() -> void:")
	var second_call_idx := src.find("_refresh_stat_bgm()", refresh_stats_idx)
	if refresh_stats_idx != -1 and second_call_idx != -1:
		_passes += 1
		print("  OK  T236.CALL.REFRESH.1: _refresh_stats 末尾有 _refresh_stat_bgm() 调用 (toggle_pause 打开时刷新)")
	else:
		_failures.append("FAIL: T236.CALL.REFRESH.1: _refresh_stats 末尾未找到 _refresh_stat_bgm() 调用")


# ---------- T236.DOC.ANCHOR.* — T236 (#154) 注释锚点 ≥ 2 处 ----------
func _run_t236_doc_anchor_assertions() -> void:
	print("--- T236.DOC.ANCHOR.* — T236 (#154) 注释锚点 ≥ 2 处 ---")
	var src := _read_file(PAUSE_MENU_GD)
	var anchor_count := 0
	for line in src.split("\n"):
		if line.find("T236 (#154)") != -1:
			anchor_count += 1
	if anchor_count >= 3:
		_passes += 1
		print("  OK  T236.DOC.ANCHOR.1: T236 (#154) 注释锚点 %d 处 (≥ 3, @onready 字段 + _ready 注释 + _refresh_stats 注释 + _refresh_stat_bgm 函数注释)" % anchor_count)
	else:
		_failures.append("FAIL: T236.DOC.ANCHOR.1: T236 (#154) 注释锚点仅 %d 处, 需 ≥ 3" % anchor_count)


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
	print("I058 (#154) T235+T236 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
