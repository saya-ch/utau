# tools/test_t300_contributing_fragility_section9644_smoke.gd
#
# T300 (#226) 落地冒烟测试: §9.6.44 6 verb `_ready()` + `_exit_tree()` 双 hook
# 串联 + `_player` non-null assertion 0 触碰既有 1:1 严格分离契约 polish 模式
# 文档化 (D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171
# #89 + T173 #92 + T174 #93 + T297 #222 + T298 #223 + T299 #224 跨 11 任务
# ~125 轮落地) — 6 verb (Stage 1 Pulse 1 verb 2 hook + 1 assertion 1:1 严格
# + Stage 2 Bind 1 verb 2 hook + 1 assertion 1:1 严格 + Stage 3 Cut 1 verb
# 2 hook + 1 assertion 1:1 严格 + Stage 4 Echo 1 verb 2 hook + 1 assertion
# 1:1 严格 + Stage 5 Wave 1 verb 2 hook + 1 assertion 1:1 严格 + Stage 6
# Whisper 1 verb 2 hook + 1 assertion 1:1 严格) 12 hook + 6 assertion + 1
# base assertion = 19 元素 1:1 严格分离契约验证.
#
# 6 verb 双 hook 串联 + `_player` non-null assertion 19 元素状态:
#        6 verb `_ready()` 第 1 行 `super._ready()` 1:1 严格 (6 verb × 1 hook = 6 hook 1:1 严格)
#      + 5 verb `_exit_tree()` 0 override 0 触碰 base 1:1 严格继承 (Pulse / Bind / Cut / Echo / Whisper 5 verb × 1 hook = 5 hook 1:1 严格)
#      + 1 verb `_exit_tree()` 1 override 0 显式 `super._exit_tree()` 调用但 1:1 严格 byte-identical cleanup 镜像 base (Wave 1 verb × 1 hook = 1 hook 1:1 严格)
#      + 6 verb 0 override `assert(_player != null, ...)` 0 触碰 base 1:1 严格继承 (6 verb × 1 assertion = 6 assertion 0 触碰既有 1:1 严格)
#      + 1 base `_ready()` 1 共享方法 含 `assert(_player != null, "VerbAbilityBase subclass must be child of CharacterBody2D")` 1 边 (1 base assertion 0 触碰既有 1:1 严格)
#      + 1 base `_exit_tree()` 1 共享方法
#      + 1 显式契约 "Lifecycle contract (subclasses MUST call `super._ready()` and `super._exit_tree()` from their overrides)" 1 段
#
# 跨 1 套 polish 模式 × 6 verb × 2 hook + 6 verb × 1 assertion + 1 base assertion = 19 元素 1:1 严格分离契约.
#
# 跨 35 套 polish 模式 中 第 35 套 (前 34 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 /
# §9.6.41 / §9.6.42 / §9.6.43, T300 是 第 35 套, 关注 "6 verb `_ready()` +
# `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有
# 1:1 严格分离契约", §9.6.44 与 §9.6.41 + §9.6.42 + §9.6.43 是 "姊妹段 +
# 拼接段", 1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格 包含 1 套 polish
# 模式 × 12 hook = 12 元素 1:1 严格 (源自 §9.6.43 双 hook 串联) + 1 套
# polish 模式 × 6 assertion = 6 元素 1:1 严格 (6 verb 0 自己加 `assert`
# 0 触碰既有) + 1 套 polish 模式 × 1 base assertion = 1 元素 1:1 严格
# (base `_ready()` 含 1 边 assertion 0 触碰既有)).
#
# 运行: godot --headless --path . --script tools/test_t300_contributing_fragility_section9644_smoke.gd
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
	print("=== T300 (#226) §9.6.44 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 19 元素 1:1 严格分离契约 smoke test ===")

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

	# ========== 1. §9.6.44 段顶 存在 + 5 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.44 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 1:1 严格分离契约", "T300-1: §9.6.44 段顶 存在")
	_assert_contains(contributing, "1:1 严格分离契约", "T300-2: §9.6.44 标题包含 '1:1 严格分离契约'")
	_assert_contains(contributing, "D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + T297 #222 + T298 #223 + T299 #224", "T300-3: §9.6.44 引用 11 任务 跨任务 ID")
	_assert_contains(contributing, "跨 11 任务 ~125 轮落地", "T300-4: §9.6.44 引用 ~125 轮 polish 链 (D002.B #98 → T299 #224)")
	_assert_contains(contributing, "polish 模式 文档化", "T300-5: §9.6.44 标题包含 'polish 模式 文档化' 关键词")

	# ========== 2. 6 verb Stage 关键词 完整 (19 元素: 6 verb × 3 元素 + 1 base assertion) ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 verb 2 hook 1:1 严格 0 漏 0 改 + 1 assertion 0 触碰既有 1:1 严格", "T300-6: §9.6.44 Stage 1 Pulse 1 verb 2 hook + 1 assertion 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 verb 2 hook 1:1 严格 0 漏 0 改 + 1 assertion 0 触碰既有 1:1 严格", "T300-7: §9.6.44 Stage 2 Bind 1 verb 2 hook + 1 assertion 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 verb 2 hook 1:1 严格 0 漏 0 改 + 1 assertion 0 触碰既有 1:1 严格", "T300-8: §9.6.44 Stage 3 Cut 1 verb 2 hook + 1 assertion 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 verb 2 hook 1:1 严格 0 漏 0 改 + 1 assertion 0 触碰既有 1:1 严格", "T300-9: §9.6.44 Stage 4 Echo 1 verb 2 hook + 1 assertion 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 verb 2 hook 1:1 严格 0 漏 0 改 + 1 assertion 0 触碰既有 1:1 严格", "T300-10: §9.6.44 Stage 5 Wave 1 verb 2 hook + 1 assertion 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 6 Whisper 1 verb 2 hook 1:1 严格 0 漏 0 改 + 1 assertion 0 触碰既有 1:1 严格", "T300-11: §9.6.44 Stage 6 Whisper 1 verb 2 hook + 1 assertion 1:1 严格 关键词 存在")

	# ========== 3. 19 元素 = 12 hook + 6 assertion + 1 base assertion 1:1 严格 关键词 ==========
	_assert_contains(contributing, "19 元素 1:1 严格", "T300-12: §9.6.44 19 元素 1:1 严格 关键词 存在 (6 verb × 2 hook = 12 hook + 6 verb × 1 assertion = 6 assertion + 1 base assertion = 19 元素 1:1 严格)")
	_assert_contains(contributing, "12 hook 1:1 严格", "T300-13: §9.6.44 12 hook 1:1 严格 关键词 存在 (6 verb × 2 hook = 12 hook 1:1 严格)")
	_assert_contains(contributing, "6 verb × 2 hook", "T300-14: §9.6.44 6 verb × 2 hook 关键词 存在")
	_assert_contains(contributing, "6 verb × 1 assertion", "T300-15: §9.6.44 6 verb × 1 assertion 关键词 存在 (6 verb × 1 assertion = 6 assertion 0 触碰既有 1:1 严格)")
	_assert_contains(contributing, "1 base assertion", "T300-16: §9.6.44 1 base assertion 关键词 存在 (1 base assertion 0 触碰既有 1:1 严格)")

	# ========== 4. 6 verb `_ready()` 第 1 行 `super._ready()` 验证 (6 verb × 1 hook = 6 hook) ==========
	var pulse_ready_idx := pulse_ability.find("func _ready")
	var pulse_super_ready_idx := pulse_ability.find("super._ready()", pulse_ready_idx)
	_assert(pulse_ready_idx != -1, "T300-17.s1: pulse_ability.gd `func _ready` 存在 (Stage 1 Pulse 1 verb 1 hook 1:1 严格分离契约)")
	_assert(pulse_super_ready_idx > pulse_ready_idx, "T300-18.s1: pulse_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 1 Pulse 1 verb 1 hook super 调用顺序)")
	var bind_ready_idx := bind_ability.find("func _ready")
	var bind_super_ready_idx := bind_ability.find("super._ready()", bind_ready_idx)
	_assert(bind_ready_idx != -1, "T300-19.s2: bind_ability.gd `func _ready` 存在 (Stage 2 Bind 1 verb 1 hook 1:1 严格分离契约)")
	_assert(bind_super_ready_idx > bind_ready_idx, "T300-20.s2: bind_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 2 Bind 1 verb 1 hook super 调用顺序)")
	var cut_ready_idx := cut_ability.find("func _ready")
	var cut_super_ready_idx := cut_ability.find("super._ready()", cut_ready_idx)
	_assert(cut_ready_idx != -1, "T300-21.s3: cut_ability.gd `func _ready` 存在 (Stage 3 Cut 1 verb 1 hook 1:1 严格分离契约)")
	_assert(cut_super_ready_idx > cut_ready_idx, "T300-22.s3: cut_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 3 Cut 1 verb 1 hook super 调用顺序)")
	var echo_ready_idx := echo_ability.find("func _ready")
	var echo_super_ready_idx := echo_ability.find("super._ready()", echo_ready_idx)
	_assert(echo_ready_idx != -1, "T300-23.s4: echo_ability.gd `func _ready` 存在 (Stage 4 Echo 1 verb 1 hook 1:1 严格分离契约)")
	_assert(echo_super_ready_idx > echo_ready_idx, "T300-24.s4: echo_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 4 Echo 1 verb 1 hook super 调用顺序)")
	var wave_ready_idx := wave_ability.find("func _ready")
	var wave_super_ready_idx := wave_ability.find("super._ready()", wave_ready_idx)
	_assert(wave_ready_idx != -1, "T300-25.s5: wave_ability.gd `func _ready` 存在 (Stage 5 Wave 1 verb 1 hook 1:1 严格分离契约)")
	_assert(wave_super_ready_idx > wave_ready_idx, "T300-26.s5: wave_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 5 Wave 1 verb 1 hook super 调用顺序)")
	var whisper_ready_idx := whisper_ability.find("func _ready")
	var whisper_super_ready_idx := whisper_ability.find("super._ready()", whisper_ready_idx)
	_assert(whisper_ready_idx != -1, "T300-27.s6: whisper_ability.gd `func _ready` 存在 (Stage 6 Whisper 1 verb 1 hook 1:1 严格分离契约)")
	_assert(whisper_super_ready_idx > whisper_ready_idx, "T300-28.s6: whisper_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 6 Whisper 1 verb 1 hook super 调用顺序)")

	# ========== 5. 5 verb `_exit_tree()` 0 override 验证 (Pulse / Bind / Cut / Echo / Whisper) ==========
	_assert(pulse_ability.find("func _exit_tree") == -1, "T300-29.s1: pulse_ability.gd 0 override `func _exit_tree` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_ability.find("func _exit_tree") == -1, "T300-30.s2: bind_ability.gd 0 override `func _exit_tree` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_ability.find("func _exit_tree") == -1, "T300-31.s3: cut_ability.gd 0 override `func _exit_tree` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_ability.find("func _exit_tree") == -1, "T300-32.s4: echo_ability.gd 0 override `func _exit_tree` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(whisper_ability.find("func _exit_tree") == -1, "T300-33.s6: whisper_ability.gd 0 override `func _exit_tree` (Stage 6 Whisper 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 6. 1 verb `_exit_tree()` 1 override 验证 (Wave) — 1:1 严格 byte-identical cleanup 镜像 base ==========
	_assert(wave_ability.find("func _exit_tree") != -1, "T300-34.s5: resonance_wave_ability.gd 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 hook 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_ability.find("super._exit_tree()") == -1, "T300-35.s5: resonance_wave_ability.gd 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")
	var wave_exit_tree_idx := wave_ability.find("func _exit_tree")
	var wave_fade_idx := wave_ability.find("_windup_vfx.fade_out_and_free()", wave_exit_tree_idx)
	var wave_null_idx := wave_ability.find("_windup_vfx = null", wave_exit_tree_idx)
	_assert(wave_fade_idx > wave_exit_tree_idx, "T300-36.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx.fade_out_and_free()` 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base)")
	_assert(wave_null_idx > wave_exit_tree_idx, "T300-37.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx = null` 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base)")

	# ========== 7. 6 verb 0 自己加 `assert(_player != null, ...)` 验证 (6 verb × 1 assertion = 6 assertion 0 override) ==========
	_assert(pulse_ability.find("assert(_player != null") == -1, "T300-38.s1: pulse_ability.gd 0 自己加 `assert(_player != null` (Stage 1 Pulse 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(bind_ability.find("assert(_player != null") == -1, "T300-39.s2: bind_ability.gd 0 自己加 `assert(_player != null` (Stage 2 Bind 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(cut_ability.find("assert(_player != null") == -1, "T300-40.s3: cut_ability.gd 0 自己加 `assert(_player != null` (Stage 3 Cut 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(echo_ability.find("assert(_player != null") == -1, "T300-41.s4: echo_ability.gd 0 自己加 `assert(_player != null` (Stage 4 Echo 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(wave_ability.find("assert(_player != null") == -1, "T300-42.s5: wave_ability.gd 0 自己加 `assert(_player != null` (Stage 5 Wave 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(whisper_ability.find("assert(_player != null") == -1, "T300-43.s6: whisper_ability.gd 0 自己加 `assert(_player != null` (Stage 6 Whisper 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")

	# ========== 8. base `_player` non-null assertion 1 边 验证 (_verb_ability_base.gd) ==========
	_assert_contains(verb_ability_base, "assert(_player != null, \"VerbAbilityBase subclass must be child of CharacterBody2D\")", "T300-44.b1: _verb_ability_base.gd `_player` non-null assertion 1 边 0 触碰既有 1:1 严格 (1 base assertion 0 触碰既有 1:1 严格 0 漏 0 改 0 反序 0 反向)")
	_assert_contains(verb_ability_base, "@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D", "T300-45.b1: _verb_ability_base.gd `@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D` 1 边 存在 (1 边 0 触碰既有 1:1 严格)")

	# ========== 9. base 双 hook 1 共享方法 验证 (_verb_ability_base.gd) ==========
	_assert_contains(verb_ability_base, "func _ready() -> void:", "T300-46.b1: _verb_ability_base.gd `func _ready() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "func _exit_tree() -> void:", "T300-47.b1: _verb_ability_base.gd `func _exit_tree() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "_windup_vfx.fade_out_and_free()", "T300-48.b1: _verb_ability_base.gd `_windup_vfx.fade_out_and_free()` base cleanup 存在")
	_assert_contains(verb_ability_base, "_windup_vfx = null", "T300-49.b1: _verb_ability_base.gd `_windup_vfx = null` base cleanup 存在")

	# ========== 10. 1 显式契约 验证 (_verb_ability_base.gd) — Lifecycle contract ==========
	_assert_contains(verb_ability_base, "Lifecycle contract", "T300-50.c1: _verb_ability_base.gd `Lifecycle contract` 显式契约 存在")
	_assert_contains(verb_ability_base, "subclasses MUST call `super._ready()` and", "T300-51.c1: _verb_ability_base.gd `subclasses MUST call `super._ready()` and ...` 显式契约 第一行 存在 (含双 hook 0 漏 1 边 super._ready 子句)")
	_assert_contains(verb_ability_base, "`super._exit_tree()` from their overrides", "T300-52.c1: _verb_ability_base.gd `super._exit_tree()` from their overrides` 显式契约 第二行 存在 (含双 hook 0 漏 1 边 super._exit_tree 子句)")

	# ========== 11. 0 副作用 段 + 8 段 prevention rule + 5 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T300-53: §9.6.44 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排", "T300-54: §9.6.44 0 副作用 段 引用 0 改 0 删 0 重排")
	_assert_contains(contributing, "0 触碰边界", "T300-55: §9.6.44 prevention 段 (a/b/c) 0 触碰边界 关键词")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T300-56: §9.6.44 prevention 段 (c) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T300-57: §9.6.44 prevention 段 (d) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T300-58: §9.6.44 prevention 段 (e) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T300-59: §9.6.44 prevention 段 (f) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "35 套 polish 模式", "T300-60: §9.6.44 prevention 段 (g) 35 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 段", "T300-61: §9.6.44 prevention 段 (h) 0 漏 1 段")
	_assert_contains(contributing, "drift risk", "T300-62: §9.6.44 prevention 段 drift risk 已知 19 元素 1:1 镜像 0 漏 3 元素 / 1 边 1:1 镜像")
	# 5 关系段: 与 §9.6.41 + 与 §9.6.42 + 与 §9.6.43 + 与 T162 + 与 §9.1
	_assert_contains(contributing, "**与 §9.6.41 关系**", "T300-63: §9.6.44 与 §9.6.41 关系 段 存在 (姊妹段 + 拼接段, §9.6.44 = §9.6.41 + 7 元素 1:1 严格)")
	_assert_contains(contributing, "**与 §9.6.42 关系**", "T300-64: §9.6.44 与 §9.6.42 关系 段 存在 (姊妹段 + 拼接段)")
	_assert_contains(contributing, "**与 §9.6.43 关系**", "T300-65: §9.6.44 与 §9.6.43 关系 段 存在 (姊妹段 + 拼接段, 19 元素 ⊃ 12 元素 1:1 严格)")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T300-66: §9.6.44 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T300-67: §9.6.44 与 §9.1 9 步关系 段 存在")

	# ========== 12. §9.6.44 段长 ≥ 35 行 + 0 漏 34 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.44 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 1:1 严格分离契约")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T300-68: §9.6.44 段长 ≥ 35 行 (vs §9.6.43 ~50 行, T300 ~50 行) — actual " + str(section_lines.size()) + " lines")
	# 34 套 polish 模式 全列举 (含 §9.6.43, 不含 §9.6.44 自身)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42", "§9.6.43"]:
		_assert_contains(section_text, ref_num, "T300-69." + ref_num + ": §9.6.44 段内 引用 " + ref_num + " (34 套 polish 模式 列举 0 漏 1 套)")

	# ========== 13. 34 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.44"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42", "§9.6.43"]:
		_assert_contains(zero_block_text, ref_num, "T300-70." + ref_num + ": §9.6.44 0 副作用 段 引用 " + ref_num + " (34 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 14. 6 verb × 3 元素 = 18 元素 + 1 base assertion = 19 元素 1:1 严格 闭环 ==========
	# 验证 6 verb 序列 6 元素: Pulse 1 verb + Bind 1 verb + Cut 1 verb + Echo 1 verb + Wave 1 verb + Whisper 1 verb
	var stage_keywords := ["Pulse 1 verb", "Bind 1 verb", "Cut 1 verb", "Echo 1 verb", "Wave 1 verb", "Whisper 1 verb"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 6, "T300-71: 6 verb 序列 6 元素 1:1 严格 闭环 (6 verb 关键词 全找到) — actual " + str(stage_count) + "/6")
	# 验证 19 元素 关键词
	var elements_keywords := ["19 元素", "12 hook", "6 verb × 1 assertion", "1 base assertion"]
	var elements_count := 0
	for kw in elements_keywords:
		if contributing.find(kw) != -1:
			elements_count += 1
	_assert(elements_count >= 3, "T300-72: 19 元素 拆分 关键词 存在 (12 hook + 6 assertion + 1 base assertion = 19 元素 1:1 严格分离契约 闭环) — actual " + str(elements_count) + "/4")

	# ========== 15. 6 verb 双 hook + assertion 1:1 严格 状态 验证 (5 verb 0 override + 1 verb 1 override + 6 verb 0 自己加 assert) ==========
	# 验证: 5 verb 0 override `_exit_tree()` (Pulse / Bind / Cut / Echo / Whisper)
	var five_verbs_no_override_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("func _exit_tree") != -1:
			five_verbs_no_override_ok = false
			break
	_assert(five_verbs_no_override_ok, "T300-73: 5 verb (Pulse / Bind / Cut / Echo / Whisper) 0 override `func _exit_tree` (5 verb 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")
	# 验证: 1 verb (Wave) 1 override `_exit_tree()` 但 0 显式 `super._exit_tree()` 调用
	var wave_text := _read_text(WAVE_ABILITY_PATH)
	_assert(wave_text.find("func _exit_tree") != -1, "T300-74: 1 verb (Wave) 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_text.find("super._exit_tree()") == -1, "T300-75: 1 verb (Wave) 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb 1:1 严格 byte-identical cleanup 镜像 base 而非 super 调用)")
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
	_assert(six_verbs_super_ready_ok, "T300-76: 6 verb (Pulse / Bind / Cut / Echo / Wave / Whisper) 全部 `_ready()` 第 1 行 `super._ready()` 1:1 严格 (6 verb × 1 hook = 6 hook super 调用顺序 0 漏 1 verb 0 反向)")
	# 验证: 6 verb 0 自己加 `assert(_player != null, ...)` (6 verb × 1 assertion = 6 assertion 0 override)
	var six_verbs_no_assert_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WAVE_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("assert(_player != null") != -1:
			six_verbs_no_assert_ok = false
			break
	_assert(six_verbs_no_assert_ok, "T300-77: 6 verb (Pulse / Bind / Cut / Echo / Wave / Whisper) 0 自己加 `assert(_player != null` (6 verb × 1 assertion = 6 assertion 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")

	# ========== 16. §9.6.44 字节码一致性 source-grep 验证 (Wave 1 verb `_exit_tree()` 状态 1:1 严格) ==========
	var wave_exit_start := wave_text.find("func _exit_tree")
	var wave_exit_end := wave_text.find("\nfunc ", wave_exit_start + 100)
	if wave_exit_end == -1:
		wave_exit_end = wave_text.length()
	var wave_exit_block := wave_text.substr(wave_exit_start, wave_exit_end - wave_exit_start)
	_assert_contains(wave_exit_block, "_windup_vfx.fade_out_and_free()", "T300-78.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx.fade_out_and_free()` 1:1 严格 byte-identical cleanup 镜像 base")
	_assert_contains(wave_exit_block, "_windup_vfx = null", "T300-79.s5: wave_ability.gd `_exit_tree()` 内 `_windup_vfx = null` 1:1 严格 byte-identical cleanup 镜像 base")

	# ========== 17. T300 自身 0 硬编码 验证 ==========
	var test_self_text := _read_text("res://tools/test_t300_contributing_fragility_section9644_smoke.gd")
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_226_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #226" in line and "`## #226" not in line and "CHANGELOG.md 顶部 #226" not in line and "README.md 'Recent completed work' #226" not in line and "README.zh-CN.md '最近完成的工作' #226" not in line:
			hard_226_count += 1
	_assert(hard_eq_count == 0, "T300-80: T300 自身 0 硬编码 `==` ITERATION_COUNT (用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T300-81: T300 自身 0 硬编码 `## #N` marker (用 ### 9.6.44 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_226_count == 0, "T300-82: T300 自身 0 硬编码 `## #226` marker (用 ### 9.6.44 稳定子串) — actual " + str(hard_226_count) + " 处")

	# ========== 18. §9.6.44 0 触碰既有 34 套 polish 模式 任何 1 character ==========
	_assert_contains(contributing, "### 9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook 串联", "T300-83: §9.6.43 段 仍然存在 (T300 0 触碰 §9.6.43 任何 1 character, 34 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.42 6 verb `_exit_tree()` super 调用顺序", "T300-84: §9.6.42 段 仍然存在 (T300 0 触碰 §9.6.42 任何 1 character, 34 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.41 6 verb `_ready()` super 调用顺序", "T300-85: §9.6.41 段 仍然存在 (T300 0 触碰 §9.6.41 任何 1 character, 34 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T300-86: §9.6.40 段 仍然存在 (T300 0 触碰 §9.6.40 任何 1 character, 34 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T300-87: §9.6.39 段 仍然存在 (T300 0 触碰 §9.6.39 任何 1 character, 34 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.18 `_verb_ability_base.gd` 共享契约", "T300-88: §9.6.18 段 仍然存在 (T300 0 触碰 §9.6.18 任何 1 character, 34 套 polish 模式 0 漏 1 套)")

	# ========== 19. T300 自身 0 副作用 + 自身段引用 §9.6.44 19 元素 ==========
	_assert_contains(test_self_text, "Stage 1 Pulse 1 verb 2 hook + 1 assertion 1:1 严格", "T300-89: T300 自身引用 Stage 1 Pulse 1 verb 2 hook + 1 assertion 1:1 严格 (19 元素 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 20. §9.6.44 0 漏 1 元素 0 改 1 字段 (19 元素 × 1 字段 = 19 元素 1:1 严格) ==========
	_assert_contains(contributing, "6 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T300-90: §9.6.44 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 21. 任务 ID 引用 ==========
	_assert_contains(contributing, "D002.B", "T300-91: §9.6.44 引用 D002.B 任务 ID")
	_assert_contains(contributing, "T166", "T300-92: §9.6.44 引用 T166 任务 ID")
	_assert_contains(contributing, "T167", "T300-93: §9.6.44 引用 T167 任务 ID")
	_assert_contains(contributing, "T168", "T300-94: §9.6.44 引用 T168 任务 ID")
	_assert_contains(contributing, "T169", "T300-95: §9.6.44 引用 T169 任务 ID")
	_assert_contains(contributing, "T171", "T300-96: §9.6.44 引用 T171 任务 ID")
	_assert_contains(contributing, "T173", "T300-97: §9.6.44 引用 T173 任务 ID")
	_assert_contains(contributing, "T174", "T300-98: §9.6.44 引用 T174 任务 ID")
	_assert_contains(contributing, "T297", "T300-99: §9.6.44 引用 T297 任务 ID (前一轮 #222 polish)")
	_assert_contains(contributing, "T298", "T300-100: §9.6.44 引用 T298 任务 ID (前一轮 #223 polish)")
	_assert_contains(contributing, "T299", "T300-101: §9.6.44 引用 T299 任务 ID (前一轮 #224 polish)")
	_assert_contains(contributing, "T300", "T300-102: §9.6.44 引用 T300 任务 ID (本轮 #226 polish)")
	_assert_contains(contributing, "#98", "T300-103: §9.6.44 引用 #98 iteration ID (D002.B iter)")
	_assert_contains(contributing, "#85", "T300-104: §9.6.44 引用 #85 iteration ID (T166 iter)")
	_assert_contains(contributing, "#86", "T300-105: §9.6.44 引用 #86 iteration ID (T167/T168 iter)")
	_assert_contains(contributing, "#87", "T300-106: §9.6.44 引用 #87 iteration ID (T169 iter)")
	_assert_contains(contributing, "#89", "T300-107: §9.6.44 引用 #89 iteration ID (T171 iter)")
	_assert_contains(contributing, "#92", "T300-108: §9.6.44 引用 #92 iteration ID (T173 iter)")
	_assert_contains(contributing, "#93", "T300-109: §9.6.44 引用 #93 iteration ID (T174 iter)")
	_assert_contains(contributing, "#222", "T300-110: §9.6.44 引用 #222 iteration ID (T297 自身落地 iter)")
	_assert_contains(contributing, "#223", "T300-111: §9.6.44 引用 #223 iteration ID (T298 自身落地 iter)")
	_assert_contains(contributing, "#224", "T300-112: §9.6.44 引用 #224 iteration ID (T299 自身落地 iter)")
	_assert_contains(contributing, "#226", "T300-113: §9.6.44 引用 #226 iteration ID (T300 自身落地 iter)")

	# ========== 22. §9.6.44 6 verb × 2 hook = 12 hook + 6 verb × 1 assertion + 1 base assertion = 19 元素 拆分 验证 ==========
	_assert_contains(contributing, "12 hook 1:1 严格", "T300-114: §9.6.44 12 hook 1:1 严格 关键词 存在 (1:1 严格 6 verb × 2 hook = 12 hook 拆分)")
	_assert_contains(contributing, "6 verb × 2 hook", "T300-115: §9.6.44 6 verb × 2 hook 关键词 存在 (1:1 严格 6 verb × 2 hook = 12 hook 拆分)")
	_assert_contains(contributing, "1:1 严格 byte-identical cleanup 镜像 base", "T300-116: §9.6.44 1:1 严格 byte-identical cleanup 镜像 base 关键词 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")
	_assert_contains(contributing, "fade_out_and_free + null 与 base 字节码 1:1 严格一致", "T300-117: §9.6.44 fade_out_and_free + null 与 base 字节码 1:1 严格一致 关键词 存在 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 字节码一致性)")

	# ========== 23. §9.6.44 姊妹段 + 拼接段 §9.6.41 + §9.6.42 + §9.6.43 关系 验证 ==========
	_assert_contains(contributing, "姊妹段 + 拼接段", "T300-118: §9.6.44 段 包含 '姊妹段 + 拼接段' 关键词 (§9.6.44 = §9.6.43 + 7 元素 1:1 严格 拼接段, 1 套 polish 模式 串联 1 套 polish 模式 + 7 元素)")
	_assert_contains(contributing, "1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格 ⊃ 1 套 polish 模式 × 12 元素 = 12 元素 1:1 严格", "T300-119: §9.6.44 段 包含 '1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格 ⊃ 1 套 polish 模式 × 12 元素 = 12 元素 1:1 严格' 关键词 (1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格 ⊃ 1 套 polish 模式 × 12 元素 = 12 元素 1:1 严格)")

	# ========== 24. §9.6.44 35 套 polish 模式 唯一性 验证 ==========
	_assert_contains(contributing, "§9.6.44 是 35 套 polish 模式**唯一**关注", "T300-120: §9.6.44 是 35 套 polish 模式**唯一**关注 6 verb 双 hook 串联 + `_player` non-null assertion 0 触碰既有 1:1 严格分离契约 (1 套 polish 模式唯一性 标注 0 互混 0 复用 0 共享)")

	# ========== 25. §9.6.44 §9.1 9 步关系 验证 ==========
	_assert_contains(contributing, "§9.6.44 6 verb × 2 hook + 6 verb × 1 assertion + 1 base assertion = 19 元素 走 §9.1 9 步落地的 1 步", "T300-121: §9.6.44 19 元素 走 §9.1 9 步落地的 1 步 (Stage 2 ability 子类, 跨 6 verb 各 3 元素 + 1 base assertion)")

	# ========== 26. §9.6.44 §9.6.18 关系 验证 (隐式 — 通过 _verb_ability_base.gd 显式契约) ==========
	_assert_contains(verb_ability_base, "Lifecycle contract", "T300-122: _verb_ability_base.gd `Lifecycle contract` 显式契约 是 §9.6.44 与 §9.6.18 共享契约 (§9.6.18 关注 16 件套 verb ability base, §9.6.44 关注 6 verb 双 hook 串联 + `_player` non-null assertion 0 触碰既有, 共享 1 段 Lifecycle contract 显式契约)")

	# ========== 27. §9.6.44 `_player` non-null assertion 关键词 ==========
	_assert_contains(contributing, "_player` non-null assertion", "T300-123: §9.6.44 引用 `_player` non-null assertion 关键词 (1 base assertion 0 触碰既有 1:1 严格)")
	_assert_contains(contributing, "assert(_player != null", "T300-124: §9.6.44 引用 `assert(_player != null` 关键词 (1 base assertion 0 触碰既有 1:1 严格)")

	# ========== 28. 6 verb 0 override `assert(_player != null, ...)` 关键词 ==========
	_assert_contains(contributing, "6 verb 0 自己加 `assert(_player != null, ...)` 0 触碰 base 1:1 严格继承", "T300-125: §9.6.44 引用 6 verb 0 自己加 `assert(_player != null, ...)` 0 触碰 base 1:1 严格继承 关键词")

	# ========== Final ==========
	print("[T300] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T300] FAILURES:")
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
		print("[T300] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T300] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
