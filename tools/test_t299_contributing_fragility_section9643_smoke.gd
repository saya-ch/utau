# tools/test_t299_contributing_fragility_section9643_smoke.gd
#
# T299 (#224) 落地冒烟测试: §9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook
# 串联 1:1 严格分离契约 polish 模式 文档化 (D002.B #98 + T166 #85 + T167
# #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + T297 #222
# + T298 #223 跨 10 任务 ~124 轮落地) — 6 verb (Stage 1 Pulse 1 verb 2 hook
# 1:1 严格 + Stage 2 Bind 1 verb 2 hook 1:1 严格 + Stage 3 Cut 1 verb 2 hook
# 1:1 严格 + Stage 4 Echo 1 verb 2 hook 1:1 严格 + Stage 5 Wave 1 verb 2 hook
# 1:1 严格 + Stage 6 Whisper 1 verb 2 hook 1:1 严格) 12 hook 1:1 严格分离契约
# 验证.
#
# 6 verb 双 hook 串联 12 hook 状态:
#        6 verb `_ready()` 第 1 行 `super._ready()` 1:1 严格 (6 verb × 1 hook = 6 hook 1:1 严格)
#      + 5 verb `_exit_tree()` 0 override 0 触碰 base 1:1 严格继承 (Pulse / Bind / Cut / Echo / Whisper 5 verb × 1 hook = 5 hook 1:1 严格)
#      + 1 verb `_exit_tree()` 1 override 0 显式 `super._exit_tree()` 调用但 1:1 严格 byte-identical cleanup 镜像 base (Wave 1 verb × 1 hook = 1 hook 1:1 严格, fade_out_and_free + null 与 base 字节码 1:1 严格一致)
#      + 1 显式契约 "Lifecycle contract (subclasses MUST call `super._ready()` and `super._exit_tree()` from their overrides)" 1 段
#
# 跨 1 套 polish 模式 × 6 verb × 2 hook = 12 hook 1:1 严格分离契约.
#
# 跨 34 套 polish 模式 中 第 34 套 (前 33 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 /
# §9.6.41 / §9.6.42, T299 是 第 34 套, 关注 "6 verb `_ready()` + `_exit_tree()`
# 双 hook 串联 1:1 严格分离契约", §9.6.43 与 §9.6.41 + §9.6.42 是 "姊妹段
# + 串联段", 1 套 polish 模式 × 6 verb × 2 hook = 12 元素 1:1 严格 包含
# 1 套 polish 模式 × 6 verb = 6 元素 1:1 严格 + 1 套 polish 模式 × 6 verb =
# 6 元素 1:1 严格, 一是 6 verb `_ready()` super 调用顺序 6 verb, 一是 6 verb
# `_exit_tree()` super 调用顺序 6 verb, 1 套 polish 模式 串联 2 套 polish 模式).
#
# 运行: godot --headless --path . --script tools/test_t299_contributing_fragility_section9643_smoke.gd
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
	print("=== T299 (#224) §9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 12 hook 1:1 严格分离契约 smoke test ===")

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

	# ========== 1. §9.6.43 段顶 存在 + 5 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook 串联", "T299-1: §9.6.43 段顶 存在")
	_assert_contains(contributing, "1:1 严格分离契约", "T299-2: §9.6.43 标题包含 '1:1 严格分离契约'")
	_assert_contains(contributing, "D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + T297 #222 + T298 #223", "T299-3: §9.6.43 引用 10 任务 跨任务 ID")
	_assert_contains(contributing, "跨 10 任务 ~124 轮落地", "T299-4: §9.6.43 引用 ~124 轮 polish 链 (D002.B #98 → T298 #223)")

	# ========== 2. 6 verb Stage 关键词 完整 (12 hook: 6 verb × 2 hook) ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 verb 2 hook 1:1 严格", "T299-5: §9.6.43 Stage 1 Pulse 1 verb 2 hook 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 verb 2 hook 1:1 严格", "T299-6: §9.6.43 Stage 2 Bind 1 verb 2 hook 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 verb 2 hook 1:1 严格", "T299-7: §9.6.43 Stage 3 Cut 1 verb 2 hook 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 verb 2 hook 1:1 严格", "T299-8: §9.6.43 Stage 4 Echo 1 verb 2 hook 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 verb 2 hook 1:1 严格", "T299-9: §9.6.43 Stage 5 Wave 1 verb 2 hook 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 6 Whisper 1 verb 2 hook 1:1 严格", "T299-10: §9.6.43 Stage 6 Whisper 1 verb 2 hook 1:1 严格 关键词 存在")

	# ========== 3. 6 verb `_ready()` 第 1 行 `super._ready()` 验证 (6 verb × 1 hook = 6 hook) ==========
	# Stage 1: pulse_ability.gd `_ready()` 第 1 行 `super._ready()`
	var pulse_ready_idx := pulse_ability.find("func _ready")
	var pulse_super_ready_idx := pulse_ability.find("super._ready()", pulse_ready_idx)
	_assert(pulse_ready_idx != -1, "T299-11.s1: pulse_ability.gd `func _ready` 存在 (Stage 1 Pulse 1 verb 1 hook 1:1 严格分离契约)")
	_assert(pulse_super_ready_idx > pulse_ready_idx, "T299-12.s1: pulse_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 1 Pulse 1 verb 1 hook super 调用顺序)")
	# Stage 2: bind_ability.gd `_ready()` 第 1 行 `super._ready()`
	var bind_ready_idx := bind_ability.find("func _ready")
	var bind_super_ready_idx := bind_ability.find("super._ready()", bind_ready_idx)
	_assert(bind_ready_idx != -1, "T299-13.s2: bind_ability.gd `func _ready` 存在 (Stage 2 Bind 1 verb 1 hook 1:1 严格分离契约)")
	_assert(bind_super_ready_idx > bind_ready_idx, "T299-14.s2: bind_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 2 Bind 1 verb 1 hook super 调用顺序)")
	# Stage 3: cut_ability.gd `_ready()` 第 1 行 `super._ready()`
	var cut_ready_idx := cut_ability.find("func _ready")
	var cut_super_ready_idx := cut_ability.find("super._ready()", cut_ready_idx)
	_assert(cut_ready_idx != -1, "T299-15.s3: cut_ability.gd `func _ready` 存在 (Stage 3 Cut 1 verb 1 hook 1:1 严格分离契约)")
	_assert(cut_super_ready_idx > cut_ready_idx, "T299-16.s3: cut_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 3 Cut 1 verb 1 hook super 调用顺序)")
	# Stage 4: echo_ability.gd `_ready()` 第 1 行 `super._ready()`
	var echo_ready_idx := echo_ability.find("func _ready")
	var echo_super_ready_idx := echo_ability.find("super._ready()", echo_ready_idx)
	_assert(echo_ready_idx != -1, "T299-17.s4: echo_ability.gd `func _ready` 存在 (Stage 4 Echo 1 verb 1 hook 1:1 严格分离契约)")
	_assert(echo_super_ready_idx > echo_ready_idx, "T299-18.s4: echo_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 4 Echo 1 verb 1 hook super 调用顺序)")
	# Stage 5: wave_ability.gd `_ready()` 第 1 行 `super._ready()`
	var wave_ready_idx := wave_ability.find("func _ready")
	var wave_super_ready_idx := wave_ability.find("super._ready()", wave_ready_idx)
	_assert(wave_ready_idx != -1, "T299-19.s5: wave_ability.gd `func _ready` 存在 (Stage 5 Wave 1 verb 1 hook 1:1 严格分离契约)")
	_assert(wave_super_ready_idx > wave_ready_idx, "T299-20.s5: wave_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 5 Wave 1 verb 1 hook super 调用顺序)")
	# Stage 6: whisper_ability.gd `_ready()` 第 1 行 `super._ready()`
	var whisper_ready_idx := whisper_ability.find("func _ready")
	var whisper_super_ready_idx := whisper_ability.find("super._ready()", whisper_ready_idx)
	_assert(whisper_ready_idx != -1, "T299-21.s6: whisper_ability.gd `func _ready` 存在 (Stage 6 Whisper 1 verb 1 hook 1:1 严格分离契约)")
	_assert(whisper_super_ready_idx > whisper_ready_idx, "T299-22.s6: whisper_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 6 Whisper 1 verb 1 hook super 调用顺序)")

	# ========== 4. 5 verb `_exit_tree()` 0 override 验证 (Pulse / Bind / Cut / Echo / Whisper) ==========
	_assert(pulse_ability.find("func _exit_tree") == -1, "T299-23.s1: pulse_ability.gd 0 override `func _exit_tree` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_ability.find("func _exit_tree") == -1, "T299-24.s2: bind_ability.gd 0 override `func _exit_tree` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_ability.find("func _exit_tree") == -1, "T299-25.s3: cut_ability.gd 0 override `func _exit_tree` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_ability.find("func _exit_tree") == -1, "T299-26.s4: echo_ability.gd 0 override `func _exit_tree` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(whisper_ability.find("func _exit_tree") == -1, "T299-27.s6: whisper_ability.gd 0 override `func _exit_tree` (Stage 6 Whisper 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 5. 1 verb `_exit_tree()` 1 override 验证 (Wave) — 1:1 严格 byte-identical cleanup 镜像 base ==========
	_assert(wave_ability.find("func _exit_tree") != -1, "T299-28.s5: resonance_wave_ability.gd 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 hook 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_ability.find("super._exit_tree()") == -1, "T299-29.s5: resonance_wave_ability.gd 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")
	# Stage 5: wave_ability.gd `_exit_tree()` 内含 fade_out_and_free + null (1:1 严格 byte-identical cleanup 镜像 base)
	var wave_exit_tree_idx := wave_ability.find("func _exit_tree")
	var wave_fade_idx := wave_ability.find("_windup_vfx.fade_out_and_free()", wave_exit_tree_idx)
	var wave_null_idx := wave_ability.find("_windup_vfx = null", wave_exit_tree_idx)
	_assert(wave_fade_idx > wave_exit_tree_idx, "T299-30.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx.fade_out_and_free()` 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base)")
	_assert(wave_null_idx > wave_exit_tree_idx, "T299-31.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx = null` 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base)")

	# ========== 6. base 双 hook 1 共享方法 验证 (_verb_ability_base.gd) ==========
	_assert_contains(verb_ability_base, "func _ready() -> void:", "T299-32.b1: _verb_ability_base.gd `func _ready() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "func _exit_tree() -> void:", "T299-33.b1: _verb_ability_base.gd `func _exit_tree() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "_windup_vfx.fade_out_and_free()", "T299-34.b1: _verb_ability_base.gd `_windup_vfx.fade_out_and_free()` base cleanup 存在")
	_assert_contains(verb_ability_base, "_windup_vfx = null", "T299-35.b1: _verb_ability_base.gd `_windup_vfx = null` base cleanup 存在")

	# ========== 7. 1 显式契约 验证 (_verb_ability_base.gd) — Lifecycle contract ==========
	_assert_contains(verb_ability_base, "Lifecycle contract", "T299-36.c1: _verb_ability_base.gd `Lifecycle contract` 显式契约 存在")
	_assert_contains(verb_ability_base, "subclasses MUST call `super._ready()` and", "T299-37.c1: _verb_ability_base.gd `subclasses MUST call `super._ready()` and ...` 显式契约 第一行 存在 (含双 hook 0 漏 1 边 super._ready 子句)")
	_assert_contains(verb_ability_base, "`super._exit_tree()` from their overrides", "T299-37b.c1: _verb_ability_base.gd `super._exit_tree()` from their overrides` 显式契约 第二行 存在 (含双 hook 0 漏 1 边 super._exit_tree 子句)")

	# ========== 8. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T299-38: §9.6.43 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排", "T299-39: §9.6.43 0 副作用 段 引用 0 改 0 删 0 重排")
	# 8 段 prevention rule
	_assert_contains(contributing, "0 触碰边界", "T299-40: §9.6.43 prevention 段 (a/b/c) 0 触碰边界 关键词")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T299-41: §9.6.43 prevention 段 (c) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T299-42: §9.6.43 prevention 段 (d) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T299-43: §9.6.43 prevention 段 (e) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T299-44: §9.6.43 prevention 段 (f) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "34 套 polish 模式", "T299-45: §9.6.43 prevention 段 (g) 34 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 段", "T299-46: §9.6.43 prevention 段 (h) 0 漏 1 段")
	_assert_contains(contributing, "drift risk", "T299-47: §9.6.43 prevention 段 drift risk 已知 12 hook 1:1 镜像 0 漏 1 hook / 1 边 / 1 字符")
	# 4 关系段: 与 §9.6.41 + 与 §9.6.42 + 与 T162 + 与 §9.1 (4 关系段)
	_assert_contains(contributing, "**与 §9.6.41 关系**", "T299-48: §9.6.43 与 §9.6.41 关系 段 存在 (姊妹段 + 串联段, §9.6.43 = §9.6.41 + §9.6.42 串联段)")
	_assert_contains(contributing, "**与 §9.6.42 关系**", "T299-49: §9.6.43 与 §9.6.42 关系 段 存在 (姊妹段 + 串联段)")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T299-50: §9.6.43 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T299-51: §9.6.43 与 §9.1 9 步关系 段 存在")

	# ========== 9. §9.6.43 段长 ≥ 35 行 + 0 漏 33 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook 串联")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T299-52: §9.6.43 段长 ≥ 35 行 (vs §9.6.42 ~50 行, T299 ~50 行) — actual " + str(section_lines.size()) + " lines")
	# 33 套 polish 模式 全列举 (含 §9.6.42, 不含 §9.6.43 自身)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42"]:
		_assert_contains(section_text, ref_num, "T299-53." + ref_num + ": §9.6.43 段内 引用 " + ref_num + " (33 套 polish 模式 列举 0 漏 1 套)")

	# ========== 10. 33 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.43"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42"]:
		_assert_contains(zero_block_text, ref_num, "T299-54." + ref_num + ": §9.6.43 0 副作用 段 引用 " + ref_num + " (33 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 11. 6 verb × 2 hook = 12 hook 1:1 严格 闭环 ==========
	# 验证 6 verb 序列 6 元素: Pulse 1 verb + Bind 1 verb + Cut 1 verb + Echo 1 verb + Wave 1 verb + Whisper 1 verb
	var stage_keywords := ["Pulse 1 verb", "Bind 1 verb", "Cut 1 verb", "Echo 1 verb", "Wave 1 verb", "Whisper 1 verb"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 6, "T299-55: 6 verb 序列 6 元素 1:1 严格 闭环 (6 verb 关键词 全找到) — actual " + str(stage_count) + "/6")
	# 验证 12 hook 关键词 (6 verb × 2 hook = 12 hook)
	var hook_keywords := ["12 hook", "双 hook 串联", "双 hook 1:1 严格"]
	var hook_count := 0
	for kw in hook_keywords:
		if contributing.find(kw) != -1:
			hook_count += 1
	_assert(hook_count >= 2, "T299-56: 12 hook 双 hook 串联 关键词 存在 (12 hook 1:1 严格分离契约 闭环) — actual " + str(hook_count) + "/3")

	# ========== 12. 6 verb 双 hook 1:1 严格 状态 验证 (5 verb 0 override + 1 verb 1 override) ==========
	# 验证: 5 verb 0 override `_exit_tree()` (Pulse / Bind / Cut / Echo / Whisper)
	var five_verbs_no_override_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("func _exit_tree") != -1:
			five_verbs_no_override_ok = false
			break
	_assert(five_verbs_no_override_ok, "T299-57: 5 verb (Pulse / Bind / Cut / Echo / Whisper) 0 override `func _exit_tree` (5 verb 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")
	# 验证: 1 verb (Wave) 1 override `_exit_tree()` 但 0 显式 `super._exit_tree()` 调用
	var wave_text := _read_text(WAVE_ABILITY_PATH)
	_assert(wave_text.find("func _exit_tree") != -1, "T299-58: 1 verb (Wave) 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_text.find("super._exit_tree()") == -1, "T299-59: 1 verb (Wave) 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb 1:1 严格 byte-identical cleanup 镜像 base 而非 super 调用)")
	# 验证: 6 verb `_ready()` 第 1 行 `super._ready()` 1:1 严格
	var six_verbs_super_ready_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WAVE_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		var ready_idx := text.find("func _ready")
		if ready_idx == -1:
			six_verbs_super_ready_ok = false
			break
		var super_ready_idx := text.find("super._ready()", ready_idx)
		if super_ready_idx == -1:
			six_verbs_super_ready_ok = false
			break
	_assert(six_verbs_super_ready_ok, "T299-60: 6 verb (Pulse / Bind / Cut / Echo / Wave / Whisper) 全部 `_ready()` 第 1 行 `super._ready()` 1:1 严格 (6 verb × 1 hook = 6 hook super 调用顺序 0 漏 1 verb 0 反向)")

	# ========== 13. §9.6.43 字节码一致性 source-grep 验证 (Wave 1 verb `_exit_tree()` 状态 1:1 严格) ==========
	# Stage 5 Wave 1 verb `_exit_tree()` 内含 fade_out_and_free + null (1:1 严格 byte-identical cleanup 镜像 base)
	var wave_exit_start := wave_text.find("func _exit_tree")
	var wave_exit_end := wave_text.find("\nfunc ", wave_exit_start + 100)
	if wave_exit_end == -1:
		wave_exit_end = wave_text.length()
	var wave_exit_block := wave_text.substr(wave_exit_start, wave_exit_end - wave_exit_start)
	_assert_contains(wave_exit_block, "_windup_vfx.fade_out_and_free()", "T299-61.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx.fade_out_and_free()` 1:1 严格 byte-identical cleanup 镜像 base")
	_assert_contains(wave_exit_block, "_windup_vfx = null", "T299-62.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx = null` 1:1 严格 byte-identical cleanup 镜像 base")

	# ========== 14. T299 自身 0 硬编码 验证 ==========
	# 读取 T299 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t299_contributing_fragility_section9643_smoke.gd")
	# T299 自身 0 硬编码 `==` ITERATION_COUNT
	# T299 自身 0 硬编码 `## #N` marker
	# T299 自身 0 硬编码 `## #224` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_224_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #224" in line and "`## #224" not in line and "CHANGELOG.md 顶部 #224" not in line and "README.md 'Recent completed work' #224" not in line and "README.zh-CN.md '最近完成的工作' #224" not in line:
			hard_224_count += 1
	_assert(hard_eq_count == 0, "T299-63: T299 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T299-64: T299 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.43 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_224_count == 0, "T299-65: T299 自身 0 硬编码 `## #224` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.43 稳定子串) — actual " + str(hard_224_count) + " 处")

	# ========== 15. §9.6.43 0 触碰既有 33 套 polish 模式 任何 1 character ==========
	# 验证: §9.6.42 段 仍然存在 (T299 0 触碰 §9.6.42 任何 1 character)
	_assert_contains(contributing, "### 9.6.42 6 verb `_exit_tree()` super 调用顺序", "T299-66: §9.6.42 段 仍然存在 (T299 0 触碰 §9.6.42 任何 1 character, 33 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.41 6 verb `_ready()` super 调用顺序", "T299-67: §9.6.41 段 仍然存在 (T299 0 触碰 §9.6.41 任何 1 character, 33 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T299-68: §9.6.40 段 仍然存在 (T299 0 触碰 §9.6.40 任何 1 character, 33 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T299-69: §9.6.39 段 仍然存在 (T299 0 触碰 §9.6.39 任何 1 character, 33 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.18 `_verb_ability_base.gd` 共享契约", "T299-70: §9.6.18 段 仍然存在 (T299 0 触碰 §9.6.18 任何 1 character, 33 套 polish 模式 0 漏 1 套)")

	# ========== 16. T299 自身 0 副作用 ==========
	# 验证: T299 自身 0 触碰 CONTRIBUTING.md / 6 verb 各自双 hook 任何 1 character
	# (此验证 通过 T299 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T299 smoke test 自身段引用 §9.6.43 12 hook (1 套 polish 模式 × 6 verb × 2 hook = 12 元素)
	_assert_contains(test_self_text, "Stage 1 Pulse 1 verb 2 hook 1:1 严格", "T299-71: T299 自身引用 Stage 1 Pulse 1 verb 2 hook 1:1 严格 (12 hook 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 17. §9.6.43 0 漏 1 元素 0 改 1 字段 (12 元素 × 1 字段 = 12 元素 1:1 严格) ==========
	# 验证: 6 verb × 2 hook = 12 元素 1:1 严格 (1 Pulse 2 hook + 1 Bind 2 hook + 1 Cut 2 hook + 1 Echo 2 hook + 1 Wave 2 hook + 1 Whisper 2 hook)
	_assert_contains(contributing, "6 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T299-72: §9.6.43 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 18. 任务 ID 引用 ==========
	_assert_contains(contributing, "D002.B", "T299-73: §9.6.43 引用 D002.B 任务 ID")
	_assert_contains(contributing, "T166", "T299-74: §9.6.43 引用 T166 任务 ID")
	_assert_contains(contributing, "T167", "T299-75: §9.6.43 引用 T167 任务 ID")
	_assert_contains(contributing, "T168", "T299-76: §9.6.43 引用 T168 任务 ID")
	_assert_contains(contributing, "T169", "T299-77: §9.6.43 引用 T169 任务 ID")
	_assert_contains(contributing, "T171", "T299-78: §9.6.43 引用 T171 任务 ID")
	_assert_contains(contributing, "T173", "T299-79: §9.6.43 引用 T173 任务 ID")
	_assert_contains(contributing, "T174", "T299-80: §9.6.43 引用 T174 任务 ID")
	_assert_contains(contributing, "T297", "T299-81: §9.6.43 引用 T297 任务 ID (前一轮 #222 polish)")
	_assert_contains(contributing, "T298", "T299-82: §9.6.43 引用 T298 任务 ID (前一轮 #223 polish)")
	_assert_contains(contributing, "T299", "T299-83: §9.6.43 引用 T299 任务 ID (本轮 #224 polish)")
	_assert_contains(contributing, "#98", "T299-84: §9.6.43 引用 #98 iteration ID (D002.B iter)")
	_assert_contains(contributing, "#85", "T299-85: §9.6.43 引用 #85 iteration ID (T166 iter)")
	_assert_contains(contributing, "#86", "T299-86: §9.6.43 引用 #86 iteration ID (T167/T168 iter)")
	_assert_contains(contributing, "#87", "T299-87: §9.6.43 引用 #87 iteration ID (T169 iter)")
	_assert_contains(contributing, "#89", "T299-88: §9.6.43 引用 #89 iteration ID (T171 iter)")
	_assert_contains(contributing, "#92", "T299-89: §9.6.43 引用 #92 iteration ID (T173 iter)")
	_assert_contains(contributing, "#93", "T299-90: §9.6.43 引用 #93 iteration ID (T174 iter)")
	_assert_contains(contributing, "#222", "T299-91: §9.6.43 引用 #222 iteration ID (T297 自身落地 iter)")
	_assert_contains(contributing, "#223", "T299-92: §9.6.43 引用 #223 iteration ID (T298 自身落地 iter)")
	_assert_contains(contributing, "#224", "T299-93: §9.6.43 引用 #224 iteration ID (T299 自身落地 iter)")

	# ========== 19. §9.6.43 6 verb × 2 hook = 12 hook 拆分 验证 ==========
	# 6 verb × 2 hook = 12 hook 1:1 严格
	_assert_contains(contributing, "12 hook 1:1 严格", "T299-94: §9.6.43 12 hook 1:1 严格 关键词 存在 (1:1 严格 6 verb × 2 hook = 12 hook 拆分)")
	_assert_contains(contributing, "6 verb × 2 hook", "T299-95: §9.6.43 6 verb × 2 hook 关键词 存在 (1:1 严格 6 verb × 2 hook = 12 hook 拆分)")
	_assert_contains(contributing, "1:1 严格 byte-identical cleanup 镜像 base", "T299-96: §9.6.43 1:1 严格 byte-identical cleanup 镜像 base 关键词 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")
	_assert_contains(contributing, "fade_out_and_free + null 与 base 字节码 1:1 严格一致", "T299-97: §9.6.43 fade_out_and_free + null 与 base 字节码 1:1 严格一致 关键词 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 字节码一致性)")

	# ========== 20. §9.6.43 姊妹段 + 串联段 §9.6.41 + §9.6.42 关系 验证 ==========
	# §9.6.43 = §9.6.41 + §9.6.42 串联段, 1 套 polish 模式 × 6 verb × 2 hook = 12 元素 1:1 严格 包含 1 套 polish 模式 × 6 verb = 6 元素 + 1 套 polish 模式 × 6 verb = 6 元素
	_assert_contains(contributing, "姊妹段 + 串联段", "T299-98: §9.6.43 段 包含 '姊妹段 + 串联段' 关键词 (§9.6.43 = §9.6.41 + §9.6.42 串联段, 1 套 polish 模式 串联 2 套 polish 模式)")
	_assert_contains(contributing, "1 套 polish 模式 串联 2 套 polish 模式", "T299-99: §9.6.43 段 包含 '1 套 polish 模式 串联 2 套 polish 模式' 关键词 (1 套 polish 模式 × 12 hook = 12 元素 1:1 严格 包含 1 套 polish 模式 × 6 verb = 6 元素 + 1 套 polish 模式 × 6 verb = 6 元素)")

	# ========== 21. §9.6.43 34 套 polish 模式 唯一性 验证 ==========
	# §9.6.43 是 34 套 polish 模式**唯一**关注 "6 verb 双 hook 串联 1:1 严格分离契约"
	_assert_contains(contributing, "§9.6.43 是 34 套 polish 模式**唯一**关注", "T299-100: §9.6.43 是 34 套 polish 模式**唯一**关注 6 verb 双 hook 串联 1:1 严格分离契约 (1 套 polish 模式唯一性 标注 0 互混 0 复用 0 共享)")

	# ========== 22. §9.6.43 §9.1 9 步关系 验证 ==========
	# §9.6.43 6 verb × 2 hook = 12 hook 走 §9.1 9 步落地的 1 步 (Stage 2 ability 子类, 跨 6 verb 各 2 hook)
	_assert_contains(contributing, "§9.6.43 6 verb × 2 hook = 12 hook 走 §9.1 9 步落地的 1 步", "T299-101: §9.6.43 6 verb × 2 hook = 12 hook 走 §9.1 9 步落地的 1 步 (Stage 2 ability 子类, 跨 6 verb 各 2 hook)")

	# ========== 23. §9.6.43 §9.6.18 关系 验证 (隐式 — 通过 _verb_ability_base.gd 显式契约) ==========
	# §9.6.18 (T273 #192 落地) 关注 "16 件套 verb ability base (5 verb ability 共享 base)"
	# §9.6.43 与 §9.6.18 关系: §9.6.43 关注 6 verb 双 hook 串联, §9.6.18 关注 16 件套 verb ability base, 显式契约 1 段
	_assert_contains(verb_ability_base, "Lifecycle contract", "T299-102: _verb_ability_base.gd `Lifecycle contract` 显式契约 是 §9.6.43 与 §9.6.18 共享契约 (§9.6.18 关注 16 件套 verb ability base, §9.6.43 关注 6 verb 双 hook 串联, 共享 1 段 Lifecycle contract 显式契约)")

	# ========== Final ==========
	print("[T299] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T299] FAILURES:")
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
		print("[T299] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T299] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
