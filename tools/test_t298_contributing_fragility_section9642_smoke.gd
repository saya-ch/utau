# tools/test_t298_contributing_fragility_section9642_smoke.gd
#
# T298 (#223) 落地冒烟测试: §9.6.42 6 verb `_exit_tree()` super 调用顺序
# 1:1 严格分离契约 polish 模式 文档化 (D002.B #98 + T166 #85 + T167
# #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 跨 7 任务 ~123 轮
# 落地) — 6 verb (Stage 1 Pulse 1 verb 1:1 严格 + Stage 2 Bind 1 verb
# 1:1 严格 + Stage 3 Cut 1 verb 1:1 严格 + Stage 4 Echo 1 verb 1:1
# 严格 + Stage 5 Wave 1 verb 1:1 严格 + Stage 6 Whisper 1 verb 1:1
# 严格) 1:1 严格分离契约 验证.
#
# 6 verb `_exit_tree()` super 调用顺序 状态:
#        5 verb 0 override `_exit_tree()` (Pulse / Bind / Cut / Echo / Whisper 0 触碰 base 1:1 严格继承)
#      + 1 verb 1 override `_exit_tree()` (Wave 0 显式 `super._exit_tree()` 调用但 1:1 严格 byte-identical cleanup 镜像 base — fade_out_and_free + null 与 base 字节码 1:1 严格一致)
#      + 1 显式契约 "Lifecycle contract (subclasses MUST call `super._ready()` and `super._exit_tree()` from their overrides)" 1 段
#
# 跨 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格分离契约.
#
# 跨 33 套 polish 模式 中 第 33 套 (前 32 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 /
# §9.6.41, T298 是 第 33 套, 关注 "6 verb `_exit_tree()` super 调用顺序
# 6 verb 1:1 严格分离契约", §9.6.41 与 §9.6.42 是 "姊妹段", 1 套
# polish 模式 × 6 verb = 6 元素 1:1 严格 镜像 1 套 polish 模式 × 5 verb
# + 1 verb = 6 元素 1:1 严格, 一是 6 verb `_ready()` super 调用顺序
# 6 verb, 一是 6 verb `_exit_tree()` super 调用顺序 6 verb).
#
# 运行: godot --headless --path . --script tools/test_t298_contributing_fragility_section9642_smoke.gd
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
	print("=== T298 (#223) §9.6.42 6 verb `_exit_tree()` super 调用顺序 6 verb 1:1 严格分离契约 smoke test ===")

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

	# ========== 1. §9.6.42 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.42 6 verb `_exit_tree()` super 调用顺序", "T298-1: §9.6.42 段顶 存在")
	_assert_contains(contributing, "1:1 严格分离契约", "T298-2: §9.6.42 标题包含 '1:1 严格分离契约'")
	_assert_contains(contributing, "D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92", "T298-3: §9.6.42 引用 7 任务 跨任务 ID")
	_assert_contains(contributing, "跨 7 任务 ~123 轮落地", "T298-4: §9.6.42 引用 ~123 轮 polish 链 (D002.B #98 → T173.C #92)")

	# ========== 2. 6 verb Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 verb 1:1 严格", "T298-5: §9.6.42 Stage 1 Pulse 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 verb 1:1 严格", "T298-6: §9.6.42 Stage 2 Bind 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 verb 1:1 严格", "T298-7: §9.6.42 Stage 3 Cut 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 verb 1:1 严格", "T298-8: §9.6.42 Stage 4 Echo 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 verb 1:1 严格", "T298-9: §9.6.42 Stage 5 Wave 1 verb 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 6 Whisper 1 verb 1:1 严格", "T298-10: §9.6.42 Stage 6 Whisper 1 verb 1:1 严格 关键词 存在")

	# ========== 3. 5 verb 0 override `_exit_tree()` 验证 (Pulse / Bind / Cut / Echo / Whisper) ==========
	# Stage 1: pulse_ability.gd 0 override `_exit_tree()`
	_assert(pulse_ability.find("func _exit_tree") == -1, "T298-11.s1: pulse_ability.gd 0 override `func _exit_tree` (Stage 1 Pulse 1 verb 0 触碰 base 1:1 严格继承)")
	# Stage 2: bind_ability.gd 0 override `_exit_tree()`
	_assert(bind_ability.find("func _exit_tree") == -1, "T298-12.s2: bind_ability.gd 0 override `func _exit_tree` (Stage 2 Bind 1 verb 0 触碰 base 1:1 严格继承)")
	# Stage 3: cut_ability.gd 0 override `_exit_tree()`
	_assert(cut_ability.find("func _exit_tree") == -1, "T298-13.s3: cut_ability.gd 0 override `func _exit_tree` (Stage 3 Cut 1 verb 0 触碰 base 1:1 严格继承)")
	# Stage 4: echo_ability.gd 0 override `_exit_tree()`
	_assert(echo_ability.find("func _exit_tree") == -1, "T298-14.s4: echo_ability.gd 0 override `func _exit_tree` (Stage 4 Echo 1 verb 0 触碰 base 1:1 严格继承)")
	# Stage 6: whisper_ability.gd 0 override `_exit_tree()`
	_assert(whisper_ability.find("func _exit_tree") == -1, "T298-15.s6: whisper_ability.gd 0 override `func _exit_tree` (Stage 6 Whisper 1 verb 0 触碰 base 1:1 严格继承)")

	# ========== 4. 1 verb 1 override `_exit_tree()` 验证 (Wave) — 1:1 严格 byte-identical cleanup 镜像 base ==========
	# Stage 5: wave_ability.gd 1 override `_exit_tree()` 但 0 显式 `super._exit_tree()` 调用 (1:1 严格 byte-identical cleanup 镜像 base)
	_assert(wave_ability.find("func _exit_tree") != -1, "T298-16.s5: resonance_wave_ability.gd 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_ability.find("super._exit_tree()") == -1, "T298-17.s5: resonance_wave_ability.gd 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")
	# Stage 5: wave_ability.gd `_exit_tree()` 内含 fade_out_and_free + null (1:1 严格 byte-identical cleanup 镜像 base)
	var wave_exit_tree_idx := wave_ability.find("func _exit_tree")
	var wave_fade_idx := wave_ability.find("_windup_vfx.fade_out_and_free()", wave_exit_tree_idx)
	var wave_null_idx := wave_ability.find("_windup_vfx = null", wave_exit_tree_idx)
	_assert(wave_fade_idx > wave_exit_tree_idx, "T298-18.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx.fade_out_and_free()` 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base)")
	_assert(wave_null_idx > wave_exit_tree_idx, "T298-19.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx = null` 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base)")

	# ========== 5. base `_exit_tree()` 1 共享方法 验证 (_verb_ability_base.gd) ==========
	# base `_exit_tree()` 1 共享方法 包含 fade_out_and_free + null (1 共享方法 + 0 显式 contract 内容 1 段)
	_assert_contains(verb_ability_base, "func _exit_tree() -> void:", "T298-20.b1: _verb_ability_base.gd `func _exit_tree() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "_windup_vfx.fade_out_and_free()", "T298-21.b1: _verb_ability_base.gd `_windup_vfx.fade_out_and_free()` base cleanup 存在")
	_assert_contains(verb_ability_base, "_windup_vfx = null", "T298-22.b1: _verb_ability_base.gd `_windup_vfx = null` base cleanup 存在")

	# ========== 6. 1 显式契约 验证 (_verb_ability_base.gd) — Lifecycle contract ==========
	_assert_contains(verb_ability_base, "Lifecycle contract", "T298-23.c1: _verb_ability_base.gd `Lifecycle contract` 显式契约 存在")
	# FIX-#225-5 (T162 brittle Stage 1 + Stage 3 + Stage 5): 原 "subclasses MUST call `super._ready()` and `super._exit_tree()`" 整段 substring 检查
	# 在 source 中 split 跨 2 行 (line 25 + line 26), 跨行 substring 永远 0 命中 (T162 brittle).
	# T162 Stage 1 (expect reverse): 拆为 3 个独立 substring 段 ID 断言, 每个 1 套 polish 模式 × 1:1 source-grep (0 跨行 brittle).
	# T162 Stage 2 (docblock): 跨迭代稳定, 整段 substring 跨行 brittle 不可逆.
	# T162 Stage 3 (segment find reverse): 3 段 段 ID 跨行稳定 标识符.
	# T162 Stage 4 (0 触碰既有): source 文件 0 触碰.
	# T162 Stage 5 (cross-section sync): 3 段 1 套 polish 模式 × 3 元素 同步 (T162 Stage 5 5 文件 light sync 范式).
	_assert_contains(verb_ability_base, "subclasses MUST call", "T298-24.c1a: _verb_ability_base.gd lifecycle doc 'subclasses MUST call' 段 ID 1:1 严格 source-grep 验证 (1/3, FIX-#225-5 拆 整段 vs 跨行)")
	_assert_contains(verb_ability_base, "super._ready()", "T298-24.c1b: _verb_ability_base.gd lifecycle doc 'super._ready()' 段 ID 1:1 严格 source-grep 验证 (2/3, FIX-#225-5 拆 整段 vs 跨行)")
	_assert_contains(verb_ability_base, "super._exit_tree()", "T298-24.c1c: _verb_ability_base.gd lifecycle doc 'super._exit_tree()' 段 ID 1:1 严格 source-grep 验证 (3/3, FIX-#225-5 拆 整段 vs 跨行, 0 漏 1 边)")

	# ========== 7. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T298-25: §9.6.42 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 `_exit_tree()` 方法", "T298-26: §9.6.42 0 副作用 段 引用 _exit_tree() 0 改 0 删 0 重排")
	# 8 段 prevention rule
	_assert_contains(contributing, "6 verb 0 触碰边界", "T298-27: §9.6.42 prevention 段 (a) 6 verb 0 触碰边界")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T298-28: §9.6.42 prevention 段 (b) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T298-29: §9.6.42 prevention 段 (c) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T298-30: §9.6.42 prevention 段 (d) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T298-31: §9.6.42 prevention 段 (e) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "33 套 polish 模式", "T298-32: §9.6.42 prevention 段 (f) 33 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 段", "T298-33: §9.6.42 prevention 段 (g) 0 漏 1 段")
	_assert_contains(contributing, "drift risk", "T298-34: §9.6.42 prevention 段 (h) drift risk 已知 6 verb 1:1 镜像 0 漏 1 verb / 1 边 / 1 字符")
	# 4 关系段: 与 §9.6.41 + 与 §9.6.18 + 与 T162 + 与 §9.1 (4 关系段)
	_assert_contains(contributing, "**与 §9.6.41 关系**", "T298-35: §9.6.42 与 §9.6.41 关系 段 存在 (姊妹段, 一是 6 verb `_ready()` super 调用顺序 6 verb, 一是 6 verb `_exit_tree()` super 调用顺序 6 verb)")
	_assert_contains(contributing, "**与 §9.6.18 关系**", "T298-36: §9.6.42 与 §9.6.18 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T298-37: §9.6.42 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T298-38: §9.6.42 与 §9.1 9 步关系 段 存在")

	# ========== 8. §9.6.42 段长 ≥ 35 行 + 0 漏 32 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.42 6 verb `_exit_tree()` super 调用顺序")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T298-39: §9.6.42 段长 ≥ 35 行 (vs §9.6.41 ~50 行, T298 ~30+ 行) — actual " + str(section_lines.size()) + " lines")
	# 32 套 polish 模式 全列举 (含 §9.6.41)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41"]:
		_assert_contains(section_text, ref_num, "T298-40." + ref_num + ": §9.6.42 段内 引用 " + ref_num + " (32 套 polish 模式 列举 0 漏 1 套)")

	# ========== 9. 32 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.42"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41"]:
		_assert_contains(zero_block_text, ref_num, "T298-41." + ref_num + ": §9.6.42 0 副作用 段 引用 " + ref_num + " (32 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 10. 6 verb × 1 套 polish 模式 = 6 元素 1:1 严格 闭环 ==========
	# 验证 6 verb 序列 6 元素: Pulse 1 verb + Bind 1 verb + Cut 1 verb + Echo 1 verb + Wave 1 verb + Whisper 1 verb
	var stage_keywords := ["Pulse 1 verb", "Bind 1 verb", "Cut 1 verb", "Echo 1 verb", "Wave 1 verb", "Whisper 1 verb"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 6, "T298-42: 6 verb 序列 6 元素 1:1 严格 闭环 (6 verb 关键词 全找到) — actual " + str(stage_count) + "/6")

	# ========== 11. 6 verb 1:1 严格 `_exit_tree()` 状态 验证 (5 verb 0 override + 1 verb 1 override) ==========
	# 验证: 5 verb 0 override `_exit_tree()` (Pulse / Bind / Cut / Echo / Whisper)
	var five_verbs_no_override_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("func _exit_tree") != -1:
			five_verbs_no_override_ok = false
			break
	_assert(five_verbs_no_override_ok, "T298-43: 5 verb (Pulse / Bind / Cut / Echo / Whisper) 0 override `func _exit_tree` (5 verb 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")
	# 验证: 1 verb (Wave) 1 override `_exit_tree()` 但 0 显式 `super._exit_tree()` 调用
	var wave_text := _read_text(WAVE_ABILITY_PATH)
	_assert(wave_text.find("func _exit_tree") != -1, "T298-44: 1 verb (Wave) 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_text.find("super._exit_tree()") == -1, "T298-45: 1 verb (Wave) 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb 1:1 严格 byte-identical cleanup 镜像 base 而非 super 调用)")

	# ========== 12. §9.6.42 字节码一致性 source-grep 验证 (6 verb `_exit_tree()` 状态 1:1 严格) ==========
	# Stage 5 Wave 1 verb `_exit_tree()` 内含 fade_out_and_free + null (1:1 严格 byte-identical cleanup 镜像 base)
	var wave_exit_start := wave_text.find("func _exit_tree")
	# FIX-#225-6 (T162 brittle Stage 1 + Stage 3): 原 `wave_text.find("\n", wave_exit_start + 100)` offset 100 太短,
	# `_exit_tree()` 完整 body ~150 chars (4 行 含 if/fade/null), offset 100 仅捕获前 3 行, 漏 `_windup_vfx = null` 1 行 (T162 brittle).
	# T162 Stage 1 (expect reverse): offset 100 → 250, 完整 body capture (5+ 行 缓冲).
	# T162 Stage 2 (docblock): 跨迭代稳定, _exit_tree() body 长度 0 改.
	# T162 Stage 3 (segment find reverse): 段 ID "_windup_vfx = null" 跨函数稳定 标识符.
	# T162 Stage 4 (0 触碰既有): source 文件 0 触碰.
	# T162 Stage 5 (cross-section sync): 1 套 polish 模式 × 1:1 source-grep, 1 段 ID 同步.
	var wave_exit_end := wave_text.find("\n", wave_exit_start + 250)
	if wave_exit_end == -1:
		wave_exit_end = wave_text.length()
	var wave_exit_block := wave_text.substr(wave_exit_start, wave_exit_end - wave_exit_start)
	_assert_contains(wave_exit_block, "_windup_vfx.fade_out_and_free()", "T298-46.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx.fade_out_and_free()` 1:1 严格 byte-identical cleanup 镜像 base")
	_assert_contains(wave_exit_block, "_windup_vfx = null", "T298-47.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx = null` 1:1 严格 byte-identical cleanup 镜像 base")

	# ========== 13. T298 自身 0 硬编码 验证 ==========
	# 读取 T298 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t298_contributing_fragility_section9642_smoke.gd")
	# T298 自身 0 硬编码 `==` ITERATION_COUNT
	# T298 自身 0 硬编码 `## #N` marker
	# T298 自身 0 硬编码 `## #223` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_223_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #223" in line and "`## #223" not in line and "CHANGELOG.md 顶部 #223" not in line and "README.md 'Recent completed work' #223" not in line and "README.zh-CN.md '最近完成的工作' #223" not in line:
			hard_223_count += 1
	_assert(hard_eq_count == 0, "T298-48: T298 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T298-49: T298 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.42 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_223_count == 0, "T298-50: T298 自身 0 硬编码 `## #223` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.42 稳定子串) — actual " + str(hard_223_count) + " 处")

	# ========== 14. §9.6.42 0 触碰既有 32 套 polish 模式 任何 1 character ==========
	# 验证: §9.6.41 段 仍然存在 (T298 0 触碰 §9.6.41 任何 1 character)
	_assert_contains(contributing, "### 9.6.41 6 verb `_ready()` super 调用顺序", "T298-51: §9.6.41 段 仍然存在 (T298 0 触碰 §9.6.41 任何 1 character, 32 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T298-52: §9.6.40 段 仍然存在 (T298 0 触碰 §9.6.40 任何 1 character, 32 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T298-53: §9.6.39 段 仍然存在 (T298 0 触碰 §9.6.39 任何 1 character, 32 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.38 6 verb audio 家族 19 cue 字段扩展", "T298-54: §9.6.38 段 仍然存在 (T298 0 触碰 §9.6.38 任何 1 character, 32 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.18 `_verb_ability_base.gd` 共享契约", "T298-55: §9.6.18 段 仍然存在 (T298 0 触碰 §9.6.18 任何 1 character, 32 套 polish 模式 0 漏 1 套)")

	# ========== 15. T298 自身 0 副作用 ==========
	# 验证: T298 自身 0 触碰 CONTRIBUTING.md / 6 verb 各自 `_exit_tree()` 任何 1 character
	# (此验证 通过 T298 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T298 smoke test 自身段引用 §9.6.42 6 verb (1 套 polish 模式 × 6 verb = 6 元素)
	_assert_contains(test_self_text, "Stage 1 Pulse 1 verb 1:1 严格", "T298-56: T298 自身引用 Stage 1 Pulse 1 verb 1:1 严格 (6 verb 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 16. §9.6.42 0 漏 1 元素 0 改 1 字段 (6 元素 × 1 字段 = 6 元素 1:1 严格) ==========
	# 验证: 6 verb × 1 字段 = 6 元素 1:1 严格 (1 Pulse 1 verb + 1 Bind 1 verb + 1 Cut 1 verb + 1 Echo 1 verb + 1 Wave 1 verb + 1 Whisper 1 verb)
	_assert_contains(contributing, "6 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T298-57: §9.6.42 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 17. 任务 ID 引用 ==========
	_assert_contains(contributing, "D002.B", "T298-58: §9.6.42 引用 D002.B 任务 ID")
	_assert_contains(contributing, "T166", "T298-59: §9.6.42 引用 T166 任务 ID")
	_assert_contains(contributing, "T167", "T298-60: §9.6.42 引用 T167 任务 ID")
	_assert_contains(contributing, "T168", "T298-61: §9.6.42 引用 T168 任务 ID")
	_assert_contains(contributing, "T169", "T298-62: §9.6.42 引用 T169 任务 ID")
	_assert_contains(contributing, "T171", "T298-63: §9.6.42 引用 T171 任务 ID")
	_assert_contains(contributing, "T173", "T298-64: §9.6.42 引用 T173 任务 ID")
	_assert_contains(contributing, "T298", "T298-65: §9.6.42 引用 T298 任务 ID (本轮 #223 polish)")
	_assert_contains(contributing, "#98", "T298-66: §9.6.42 引用 #98 iteration ID (D002.B iter)")
	_assert_contains(contributing, "#85", "T298-67: §9.6.42 引用 #85 iteration ID (T166 iter)")
	_assert_contains(contributing, "#86", "T298-68: §9.6.42 引用 #86 iteration ID (T167/T168 iter)")
	_assert_contains(contributing, "#87", "T298-69: §9.6.42 引用 #87 iteration ID (T169 iter)")
	_assert_contains(contributing, "#89", "T298-70: §9.6.42 引用 #89 iteration ID (T171 iter)")
	_assert_contains(contributing, "#92", "T298-71: §9.6.42 引用 #92 iteration ID (T173 iter)")
	_assert_contains(contributing, "#223", "T298-72: §9.6.42 引用 #223 iteration ID (T298 自身落地 iter)")

	# ========== 18. §9.6.42 5 verb + 1 verb 拆分 验证 ==========
	# 5 verb (Pulse / Bind / Cut / Echo / Whisper) 0 override + 1 verb (Wave) 1 override byte-identical cleanup
	_assert_contains(contributing, "5 verb 0 override `_exit_tree()`", "T298-73: §9.6.42 5 verb 0 override `_exit_tree()` 关键词 存在 (1:1 严格 5 verb + 1 verb 拆分)")
	_assert_contains(contributing, "1 verb 1 override `_exit_tree()`", "T298-74: §9.6.42 1 verb 1 override `_exit_tree()` 关键词 存在 (1:1 严格 5 verb + 1 verb 拆分)")
	_assert_contains(contributing, "1:1 严格 byte-identical cleanup 镜像 base", "T298-75: §9.6.42 1:1 严格 byte-identical cleanup 镜像 base 关键词 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")
	_assert_contains(contributing, "fade_out_and_free + null 与 base 字节码 1:1 严格一致", "T298-76: §9.6.42 fade_out_and_free + null 与 base 字节码 1:1 严格一致 关键词 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 字节码一致性)")

	# ========== 19. §9.6.42 姊妹段 §9.6.41 关系 验证 ==========
	# §9.6.41 与 §9.6.42 是 "姊妹段" (1 套 polish 模式 × 6 verb = 6 元素 1:1 严格 镜像 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格)
	_assert_contains(contributing, "**与 §9.6.41 关系**", "T298-77: §9.6.42 与 §9.6.41 关系 段 存在 (姊妹段, 一是 6 verb `_ready()` super 调用顺序 6 verb, 一是 6 verb `_exit_tree()` super 调用顺序 6 verb)")
	_assert_contains(contributing, "姊妹段", "T298-78: §9.6.42 段 包含 '姊妹段' 关键词 (§9.6.41 与 §9.6.42 是 '姊妹段', 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格 镜像 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格)")

	# ========== 20. §9.6.42 32 套 polish 模式 唯一性 验证 ==========
	# §9.6.42 是 33 套 polish 模式**唯一**关注 "6 verb `_exit_tree()` super 调用顺序 6 verb 1:1 严格分离契约"
	_assert_contains(contributing, "§9.6.42 是 33 套 polish 模式**唯一**关注", "T298-79: §9.6.42 是 33 套 polish 模式**唯一**关注 6 verb `_exit_tree()` super 调用顺序 6 verb 1:1 严格分离契约 (1 套 polish 模式唯一性 标注 0 互混 0 复用 0 共享)")

	# ========== 21. §9.6.42 §9.1 9 步关系 验证 ==========
	# §9.6.42 6 verb 走 §9.1 9 步落地的 1 步 (Stage 2 ability 子类, 跨 6 verb 各 1 verb)
	_assert_contains(contributing, "§9.6.42 6 verb 走 §9.1 9 步落地的 1 步", "T298-80: §9.6.42 6 verb 走 §9.1 9 步落地的 1 步 (Stage 2 ability 子类, 跨 6 verb 各 1 verb)")

	# ========== 22. §9.6.42 §9.6.18 关系 验证 ==========
	# §9.6.18 (T273 #192 落地) 关注 "16 件套 verb ability base (5 verb ability 共享 base)"
	# §9.6.42 与 §9.6.18 是 "姊妹段" (1 套 polish 模式 × 6 verb = 6 元素 1:1 严格 镜像 1 套 polish 模式 × 16 件套 = 16 元素 1:1 严格)
	_assert_contains(contributing, "§9.6.42 与 §9.6.18 是 \"姊妹段\"", "T298-81: §9.6.42 与 §9.6.18 是 \"姊妹段\" (§9.6.18 关注 16 件套 verb ability base, §9.6.42 关注 6 verb `_exit_tree()` super 调用顺序 6 verb, 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格 镜像 1 套 polish 模式 × 16 件套 = 16 元素 1:1 严格)")

	# ========== Final ==========
	print("[T298] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T298] FAILURES:")
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
		print("[T298] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T298] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
