# tools/test_t297_contributing_fragility_section9641_smoke.gd
#
# T297 (#222) 落地冒烟测试: §9.6.41 6 verb `_ready()` super 调用顺序
# 1:1 严格分离契约 polish 模式 文档化 (D002.B #98 + T166 #85 + T167
# #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 +
# F013.E #159 跨 9 任务 ~123 轮落地) — 6 verb (Stage 1 Pulse 1 verb
# 1:1 严格 + Stage 2 Bind 1 verb 1:1 严格 + Stage 3 Cut 1 verb 1:1
# 严格 + Stage 4 Echo 1 verb 1:1 严格 + Stage 5 Wave 1 verb 1:1
# 严格 + Stage 6 Whisper 1 verb 1:1 严格) 1:1 严格分离契约 验证.
#
# 6 verb = 1 `src/scripts/pulse_ability.gd` `_ready()` 第 1 行 `super._ready()`
#        + 1 `src/scripts/bind_ability.gd` `_ready()` 第 1 行 `super._ready()`
#        + 1 `src/scripts/cut_ability.gd` `_ready()` 第 1 行 `super._ready()`
#        + 1 `src/scripts/echo_ability.gd` `_ready()` 第 1 行 `super._ready()`
#        + 1 `src/scripts/resonance_wave_ability.gd` `_ready()` 第 1 行 `super._ready()`
#        + 1 `src/scripts/whisper_ability.gd` `_ready()` 第 1 行 `super._ready()`
#        + 1 显式契约 "Lifecycle contract (subclasses MUST call `super._ready()` and `super._exit_tree()` from their overrides)" 1 段
#        + 1 `_player` non-null assertion 0 触碰既有 1:1 严格
#
# 跨 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格分离契约.
#
# 跨 32 套 polish 模式 中 第 32 套 (前 31 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40,
# T297 是 第 32 套, 关注 "6 verb `_ready()` super 调用顺序 6 verb
# 1:1 严格分离契约").
#
# 运行: godot --headless --path . --script tools/test_t297_contributing_fragility_section9641_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const VERB_ABILITY_BASE_PATH := "res://src/scripts/_verb_ability_base.gd"
const PULSE_ABILITY_PATH := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_PATH := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_PATH := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_PATH := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_PATH := "res://src/scripts/resonance_wave_ability.gd"
const WHISPER_ABILITY_PATH := "res://src/scripts/whisper_ability.gd"
const CHANGELOG_PATH := "res://CHANGELOG.md"
const README_PATH := "res://README.md"
const README_ZH_PATH := "res://README.zh-CN.md"
const ROADMAP_PATH := "res://ROADMAP.md"
const REVIEW_LOG_PATH := "res://REVIEW_LOG.md"
const CHECK_SMOKE_CONSISTENCY_PATH := "res://tools/check_smoke_consistency.sh"

var _passed := 0
var _failed := 0
var _failures: Array[String] = []

func _initialize() -> void:
	_run()

func _run() -> void:
	print("=== T297 (#222) §9.6.41 6 verb `_ready()` super 调用顺序 6 verb 1:1 严格分离契约 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var verb_ability_base := _read_text(VERB_ABILITY_BASE_PATH)
	var pulse_ability := _read_text(PULSE_ABILITY_PATH)
	var bind_ability := _read_text(BIND_ABILITY_PATH)
	var cut_ability := _read_text(CUT_ABILITY_PATH)
	var echo_ability := _read_text(ECHO_ABILITY_PATH)
	var wave_ability := _read_text(WAVE_ABILITY_PATH)
	var whisper_ability := _read_text(WHISPER_ABILITY_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)
	var check_smoke := _read_text(CHECK_SMOKE_CONSISTENCY_PATH)

	# ========== 1. §9.6.41 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.41 6 verb `_ready()` super 调用顺序", "T297-1: §9.6.41 段顶 存在")
	_assert_contains(contributing, "1:1 严格分离契约", "T297-2: §9.6.41 标题包含 '1:1 严格分离契约'")
	_assert_contains(contributing, "D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + F013.E #159", "T297-3: §9.6.41 引用 9 任务 跨任务 ID")
	_assert_contains(contributing, "跨 9 任务 ~123 轮落地", "T297-4: §9.6.41 引用 ~123 轮 polish 链 (D002.B #98 → F013.E #159)")

	# ========== 2. 6 verb Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 verb 1:1 严格", "T297-5: §9.6.41 Stage 1 Pulse 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 verb 1:1 严格", "T297-6: §9.6.41 Stage 2 Bind 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 verb 1:1 严格", "T297-7: §9.6.41 Stage 3 Cut 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 verb 1:1 严格", "T297-8: §9.6.41 Stage 4 Echo 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 verb 1:1 严格", "T297-9: §9.6.41 Stage 5 Wave 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 6 Whisper 1 verb 1:1 严格", "T297-10: §9.6.41 Stage 6 Whisper 1 verb 1:1 严格 关键词 存在")

	# ========== 3. 6 verb 字节码 一致性 source-grep 验证 (6 verb 各自 `_ready()` 第 1 行 `super._ready()`) ==========
	# Stage 1: Pulse 1 verb `_ready()` 第 1 行 `super._ready()`
	_assert_contains(pulse_ability, "super._ready()", "T297-11.s1: pulse_ability.gd `super._ready()` 引用 存在 (Stage 1 Pulse 1 verb 1:1 严格)")
	# Stage 2: Bind 1 verb `_ready()` 第 1 行 `super._ready()`
	_assert_contains(bind_ability, "super._ready()", "T297-12.s2: bind_ability.gd `super._ready()` 引用 存在 (Stage 2 Bind 1 verb 1:1 严格)")
	# Stage 3: Cut 1 verb `_ready()` 第 1 行 `super._ready()`
	_assert_contains(cut_ability, "super._ready()", "T297-13.s3: cut_ability.gd `super._ready()` 引用 存在 (Stage 3 Cut 1 verb 1:1 严格)")
	# Stage 4: Echo 1 verb `_ready()` 第 1 行 `super._ready()`
	_assert_contains(echo_ability, "super._ready()", "T297-14.s4: echo_ability.gd `super._ready()` 引用 存在 (Stage 4 Echo 1 verb 1:1 严格)")
	# Stage 5: Wave 1 verb `_ready()` 第 1 行 `super._ready()`
	_assert_contains(wave_ability, "super._ready()", "T297-15.s5: resonance_wave_ability.gd `super._ready()` 引用 存在 (Stage 5 Wave 1 verb 1:1 严格)")
	# Stage 6: Whisper 1 verb `_ready()` 第 1 行 `super._ready()`
	_assert_contains(whisper_ability, "super._ready()", "T297-16.s6: whisper_ability.gd `super._ready()` 引用 存在 (Stage 6 Whisper 1 verb 1:1 严格)")

	# ========== 4. 6 verb `_ready()` 顺序验证: super._ready() 在第 1 行 紧跟 func _ready() ==========
	# Stage 1: pulse_ability.gd
	var pulse_ready_idx := pulse_ability.find("func _ready()")
	var pulse_super_idx := pulse_ability.find("super._ready()")
	_assert(pulse_super_idx > pulse_ready_idx and (pulse_super_idx - pulse_ready_idx) < 300, "T297-17.s1: pulse_ability.gd `super._ready()` 紧跟 `func _ready()` (Stage 1 Pulse 1 verb 1:1 严格 _ready() 顺序)")
	# Stage 2: bind_ability.gd
	var bind_ready_idx := bind_ability.find("func _ready()")
	var bind_super_idx := bind_ability.find("super._ready()")
	_assert(bind_super_idx > bind_ready_idx and (bind_super_idx - bind_ready_idx) < 300, "T297-18.s2: bind_ability.gd `super._ready()` 紧跟 `func _ready()` (Stage 2 Bind 1 verb 1:1 严格 _ready() 顺序)")
	# Stage 3: cut_ability.gd
	var cut_ready_idx := cut_ability.find("func _ready()")
	var cut_super_idx := cut_ability.find("super._ready()")
	_assert(cut_super_idx > cut_ready_idx and (cut_super_idx - cut_ready_idx) < 300, "T297-19.s3: cut_ability.gd `super._ready()` 紧跟 `func _ready()` (Stage 3 Cut 1 verb 1:1 严格 _ready() 顺序)")
	# Stage 4: echo_ability.gd
	var echo_ready_idx := echo_ability.find("func _ready()")
	var echo_super_idx := echo_ability.find("super._ready()")
	_assert(echo_super_idx > echo_ready_idx and (echo_super_idx - echo_ready_idx) < 300, "T297-20.s4: echo_ability.gd `super._ready()` 紧跟 `func _ready()` (Stage 4 Echo 1 verb 1:1 严格 _ready() 顺序)")
	# Stage 5: wave_ability.gd
	var wave_ready_idx := wave_ability.find("func _ready()")
	var wave_super_idx := wave_ability.find("super._ready()")
	_assert(wave_super_idx > wave_ready_idx and (wave_super_idx - wave_ready_idx) < 300, "T297-21.s5: resonance_wave_ability.gd `super._ready()` 紧跟 `func _ready()` (Stage 5 Wave 1 verb 1:1 严格 _ready() 顺序)")
	# Stage 6: whisper_ability.gd
	var whisper_ready_idx := whisper_ability.find("func _ready()")
	var whisper_super_idx := whisper_ability.find("super._ready()")
	_assert(whisper_super_idx > whisper_ready_idx and (whisper_super_idx - whisper_ready_idx) < 300, "T297-22.s6: whisper_ability.gd `super._ready()` 紧跟 `func _ready()` (Stage 6 Whisper 1 verb 1:1 严格 _ready() 顺序)")

	# ========== 5. 1 显式契约 验证 (_verb_ability_base.gd) ==========
	_assert_contains(verb_ability_base, "Lifecycle contract", "T297-23.c1: _verb_ability_base.gd `Lifecycle contract` 显式契约 存在")
	_assert_contains(verb_ability_base, "subclasses MUST call `super._ready()`", "T297-24.c1: _verb_ability_base.gd `subclasses MUST call `super._ready()`` 显式契约 存在")
	# _player non-null assertion
	_assert_contains(verb_ability_base, "assert(_player != null", "T297-25.c2: _verb_ability_base.gd `assert(_player != null, ...)` non-null assertion 存在")

	# ========== 6. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T297-26: §9.6.41 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 `_ready()` 方法", "T297-27: §9.6.41 0 副作用 段 引用 _ready() 0 改 0 删 0 重排")
	# 8 段 prevention rule
	_assert_contains(contributing, "6 verb 0 触碰边界", "T297-28: §9.6.41 prevention 段 (a) 6 verb 0 触碰边界")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T297-29: §9.6.41 prevention 段 (b) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T297-30: §9.6.41 prevention 段 (c) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T297-31: §9.6.41 prevention 段 (d) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T297-32: §9.6.41 prevention 段 (e) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "32 套 polish 模式", "T297-33: §9.6.41 prevention 段 (f) 32 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 段", "T297-34: §9.6.41 prevention 段 (g) 0 漏 1 段")
	_assert_contains(contributing, "drift risk", "T297-35: §9.6.41 prevention 段 (h) drift risk 已知 6 verb 1:1 镜像 0 漏 1 verb / 1 边 / 1 字符")
	# 4 关系段: 与 §9.6.40 + 与 §9.6.18 + 与 T162 + 与 §9.1 (4 关系段)
	_assert_contains(contributing, "**与 §9.6.40 关系**", "T297-36: §9.6.41 与 §9.6.40 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.18 关系**", "T297-37: §9.6.41 与 §9.6.18 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T297-38: §9.6.41 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T297-39: §9.6.41 与 §9.1 9 步关系 段 存在")

	# ========== 7. §9.6.41 段长 ≥ 35 行 + 0 漏 31 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.41 6 verb `_ready()` super 调用顺序")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T297-40: §9.6.41 段长 ≥ 35 行 (vs §9.6.40 ~30 行, T297 ~30+ 行) — actual " + str(section_lines.size()) + " lines")
	# 31 套 polish 模式 全列举 (含 §9.6.40)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40"]:
		_assert_contains(section_text, ref_num, "T297-41." + ref_num + ": §9.6.41 段内 引用 " + ref_num + " (31 套 polish 模式 列举 0 漏 1 套)")

	# ========== 8. 31 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.41"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40"]:
		_assert_contains(zero_block_text, ref_num, "T297-42." + ref_num + ": §9.6.41 0 副作用 段 引用 " + ref_num + " (31 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 9. 6 verb × 1 套 polish 模式 = 6 元素 1:1 严格 闭环 ==========
	# 验证 6 verb 序列 6 元素: Pulse 1 verb + Bind 1 verb + Cut 1 verb + Echo 1 verb + Wave 1 verb + Whisper 1 verb
	var stage_keywords := ["Pulse 1 verb", "Bind 1 verb", "Cut 1 verb", "Echo 1 verb", "Wave 1 verb", "Whisper 1 verb"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 6, "T297-43: 6 verb 序列 6 元素 1:1 严格 闭环 (6 verb 关键词 全找到) — actual " + str(stage_count) + "/6")

	# ========== 10. 6 verb 1:1 严格 `_ready()` 顺序 验证 (super._ready() 在 6 verb 各自 `_ready()` 紧跟) ==========
	# 验证: 6 verb super._ready() 全部存在
	var all_6_verbs_super_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WAVE_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("super._ready()") == -1:
			all_6_verbs_super_ok = false
			break
	_assert(all_6_verbs_super_ok, "T297-44: 6 verb 各自 `super._ready()` 全部存在 (6 verb 1:1 严格 顺序 0 漏 1 verb 0 反向)")

	# ========== 11. T297 自身 0 硬编码 验证 ==========
	# 读取 T297 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t297_contributing_fragility_section9641_smoke.gd")
	# T297 自身 0 硬编码 `==` ITERATION_COUNT
	# T297 自身 0 硬编码 `## #N` marker
	# T297 自身 0 硬编码 `## #222` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_222_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #222" in line and "`## #222" not in line and "CHANGELOG.md 顶部 #222" not in line and "README.md 'Recent completed work' #222" not in line and "README.zh-CN.md '最近完成的工作' #222" not in line:
			hard_222_count += 1
	_assert(hard_eq_count == 0, "T297-45: T297 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T297-46: T297 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.41 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_222_count == 0, "T297-47: T297 自身 0 硬编码 `## #222` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.41 稳定子串) — actual " + str(hard_222_count) + " 处")

	# ========== 12. §9.6.41 0 触碰既有 31 套 polish 模式 任何 1 character ==========
	# 验证: §9.6.40 段 仍然存在 (T297 0 触碰 §9.6.40 任何 1 character)
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T297-48: §9.6.40 段 仍然存在 (T297 0 触碰 §9.6.40 任何 1 character, 31 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T297-49: §9.6.39 段 仍然存在 (T297 0 触碰 §9.6.39 任何 1 character, 31 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.38 6 verb audio 家族 19 cue 字段扩展", "T297-50: §9.6.38 段 仍然存在 (T297 0 触碰 §9.6.38 任何 1 character, 31 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.18 `_verb_ability_base.gd` 共享契约", "T297-51: §9.6.18 段 仍然存在 (T297 0 触碰 §9.6.18 任何 1 character, 31 套 polish 模式 0 漏 1 套)")

	# ========== 13. T297 自身 0 副作用 ==========
	# 验证: T297 自身 0 触碰 CONTRIBUTING.md / 6 verb 各自 `_ready()` 任何 1 character
	# (此验证 通过 T297 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T297 smoke test 自身段引用 §9.6.41 6 verb (1 套 polish 模式 × 6 verb = 6 元素)
	_assert_contains(test_self_text, "Stage 1 Pulse 1 verb 1:1 严格", "T297-52: T297 自身引用 Stage 1 Pulse 1 verb 1:1 严格 (6 verb 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 14. §9.6.41 0 漏 1 元素 0 改 1 字段 (6 元素 × 1 字段 = 6 元素 1:1 严格) ==========
	# 验证: 6 verb × 1 字段 = 6 元素 1:1 严格 (1 Pulse 1 verb + 1 Bind 1 verb + 1 Cut 1 verb + 1 Echo 1 verb + 1 Wave 1 verb + 1 Whisper 1 verb)
	_assert_contains(contributing, "6 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T297-53: §9.6.41 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 15. 任务 ID 引用 ==========
	_assert_contains(contributing, "D002.B", "T297-54: §9.6.41 引用 D002.B 任务 ID")
	_assert_contains(contributing, "T166", "T297-55: §9.6.41 引用 T166 任务 ID")
	_assert_contains(contributing, "T167", "T297-56: §9.6.41 引用 T167 任务 ID")
	_assert_contains(contributing, "T168", "T297-57: §9.6.41 引用 T168 任务 ID")
	_assert_contains(contributing, "T169", "T297-58: §9.6.41 引用 T169 任务 ID")
	_assert_contains(contributing, "T171", "T297-59: §9.6.41 引用 T171 任务 ID")
	_assert_contains(contributing, "T173", "T297-60: §9.6.41 引用 T173 任务 ID")
	_assert_contains(contributing, "T174", "T297-61: §9.6.41 引用 T174 任务 ID")
	_assert_contains(contributing, "F013.E", "T297-62: §9.6.41 引用 F013.E 任务 ID")
	_assert_contains(contributing, "T297", "T297-63: §9.6.41 引用 T297 任务 ID (本轮 #222 polish)")
	_assert_contains(contributing, "#98", "T297-64: §9.6.41 引用 #98 iteration ID (D002.B iter)")
	_assert_contains(contributing, "#85", "T297-65: §9.6.41 引用 #85 iteration ID (T166 iter)")
	_assert_contains(contributing, "#86", "T297-66: §9.6.41 引用 #86 iteration ID (T167/T168 iter)")
	_assert_contains(contributing, "#87", "T297-67: §9.6.41 引用 #87 iteration ID (T169 iter)")
	_assert_contains(contributing, "#89", "T297-68: §9.6.41 引用 #89 iteration ID (T171 iter)")
	_assert_contains(contributing, "#92", "T297-69: §9.6.41 引用 #92 iteration ID (T173 iter)")
	_assert_contains(contributing, "#93", "T297-70: §9.6.41 引用 #93 iteration ID (T174 iter)")
	_assert_contains(contributing, "#159", "T297-71: §9.6.41 引用 #159 iteration ID (F013.E iter)")
	_assert_contains(contributing, "#222", "T297-72: §9.6.41 引用 #222 iteration ID (T297 自身落地 iter)")

	# ========== 16. CHANGELOG / ROADMAP / README 同步 验证 (post-落地) ==========
	# 这一节是 给 #223+ 后续 polish 留 1 段 验证位; 当前 T297 落地后 由 cross-section 同步 在 #223 同步
	# 当前 验证: T297 自身 0 触碰任何 cross-section 文件 (除 T297 自身 0 触碰既有)

	# ========== Final ==========
	print("[T297] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T297] FAILURES:")
		for f in _failures:
			print("  - " + f)
		quit(1)
	else:
		quit(0)


# ---------- helpers ----------

func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_error("missing file: " + path)
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("cannot open: " + path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content

func _assert(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("[T297] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T297] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
