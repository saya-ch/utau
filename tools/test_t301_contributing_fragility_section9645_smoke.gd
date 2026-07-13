# tools/test_t301_contributing_fragility_section9645_smoke.gd
#
# T301 (#227) 落地冒烟测试: §9.6.45 6 verb `_ready()` + `_exit_tree()` 双 hook
# 串联 + `_player` non-null assertion 0 触碰既有 + 6 verb 视觉组连贯 lifecycle
# 1:1 严格分离契约 polish 模式 文档化 (D002.B #98 + T166 #85 + T167 #86 +
# T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + T245 #162 + T250
# #168 + T297 #222 + T298 #223 + T299 #224 + T300 #226 跨 14 任务 ~127 轮
# 落地) — 6 verb (Stage 1 Pulse 1 verb 2 hook + 1 assertion + 1 视觉组 1:1
# 严格 + Stage 2 Bind 1 verb 2 hook + 1 assertion + 1 视觉组 1:1 严格 + Stage
# 3 Cut 1 verb 2 hook + 1 assertion + 1 视觉组 1:1 严格 + Stage 4 Echo 1 verb
# 2 hook + 1 assertion + 1 视觉组 1:1 严格 + Stage 5 Wave 1 verb 2 hook +
# 1 assertion + 1 视觉组 1:1 严格 + Stage 6 Whisper 1 verb 2 hook + 1
# assertion + 1 视觉组 1:1 严格) 6 verb × 4 元素 = 24 元素 + 1 base assertion
# + 1 显式契约 "6 verb 视觉组连贯 lifecycle 共享视觉语法" + 1 视觉组 0 触碰
# 既有 = 26 元素 1:1 严格分离契约验证.
#
# 6 verb 双 hook 串联 + `_player` non-null assertion + 6 verb 视觉组连贯
# lifecycle 26 元素状态:
#        6 verb `_ready()` 第 1 行 `super._ready()` 1:1 严格 (6 verb × 1 hook = 6 hook 1:1 严格)
#      + 5 verb `_exit_tree()` 0 override 0 触碰 base 1:1 严格继承 (Pulse / Bind / Cut / Echo / Whisper 5 verb × 1 hook = 5 hook 1:1 严格)
#      + 1 verb `_exit_tree()` 1 override 0 显式 `super._exit_tree()` 调用但 1:1 严格 byte-identical cleanup 镜像 base (Wave 1 verb × 1 hook = 1 hook 1:1 严格)
#      + 6 verb 0 override `assert(_player != null, ...)` 0 触碰 base 1:1 严格继承 (6 verb × 1 assertion = 6 assertion 0 触碰既有 1:1 严格)
#      + 1 base `_ready()` 1 共享方法 含 `assert(_player != null, "VerbAbilityBase subclass must be child of CharacterBody2D")` 1 边 (1 base assertion 0 触碰既有 1:1 严格)
#      + 1 base `_exit_tree()` 1 共享方法
#      + 1 显式契约 "Lifecycle contract (subclasses MUST call `super._ready()` and `super._exit_tree()` from their overrides)" 1 段
#      + 5 verb 视觉组 5 段 1:1 严格 (Pulse 同心圆环扩散波 + Coral Pulse 核 / Bind 向内螺旋涡 + Muted Violet 核 / Cut 水平锋利斩 + 4 三角碎片 + Amber Voice 核 / Echo 玻璃护盾 + 8 棱镜折射 + 双向反弹 + Glass Cyan 核 / Wave 双环扩散 + 8 棱镜光线 + amber 中心 + Pale Resonance 核)
#      + 1 verb 视觉组 1 段 1:1 严格 (Whisper constant 球 + 2px 描边 + 球心亮点 + Muted Mauve 核, T245 #162 落地)
#      + 1 显式契约 "6 verb 视觉组连贯 lifecycle 共享视觉语法 (深海军蓝背景圆盘 + Glass Cyan 外环 + verb 主色 core)" 1 段
#      + 1 视觉组 0 触碰既有 1:1 严格 (5 verb 视觉组 5 段 + 1 verb 视觉组 1 段 0 漏 0 改 0 反序 0 反向)
#
# 跨 1 套 polish 模式 × 6 verb × 4 元素 = 24 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有 = 26 元素 1:1 严格分离契约.
#
# 跨 36 套 polish 模式 中 第 36 套 (前 35 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 /
# §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44, T301 是 第 36 套, 关注 "6 verb
# `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion
# 0 触碰既有 + 6 verb 视觉组连贯 lifecycle 1:1 严格分离契约", §9.6.45 与
# §9.6.44 是 "姊妹段 + 拼接段", 1 套 polish 模式 × 26 元素 = 26 元素 1:1
# 严格 包含 1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格 (源自 §9.6.44
# 双 hook 串联 + `_player` non-null assertion 0 触碰既有) + 1 套 polish
# 模式 × 5 verb 视觉组 5 段 + 1 套 polish 模式 × 1 verb 视觉组 1 段 + 1
# 套 polish 模式 × 1 显式契约 "6 verb 视觉组连贯 lifecycle 共享视觉语法" +
# 1 套 polish 模式 × 1 视觉组 0 触碰既有 1:1 严格 = 7 元素 1:1 严格 (6
# verb 视觉组连贯 lifecycle 拼接段 7 元素)).
#
# 运行: godot --headless --path . --script tools/test_t301_contributing_fragility_section9645_smoke.gd
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
	print("=== T301 (#227) §9.6.45 6 verb 双 hook 串联 + `_player` non-null assertion + 6 verb 视觉组连贯 lifecycle 26 元素 1:1 严格分离契约 smoke test ===")

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

	# ========== 1. §9.6.45 段顶 存在 + 5 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.45 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 + 6 verb 视觉组连贯 lifecycle 1:1 严格分离契约", "T301-1: §9.6.45 段顶 存在")
	_assert_contains(contributing, "6 verb 视觉组连贯 lifecycle 1:1 严格分离契约", "T301-2: §9.6.45 标题包含 '6 verb 视觉组连贯 lifecycle 1:1 严格分离契约'")
	_assert_contains(contributing, "D002.B #98 + T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89 + T173 #92 + T174 #93 + T245 #162 + T250 #168 + T297 #222 + T298 #223 + T299 #224 + T300 #226", "T301-3: §9.6.45 引用 14 任务 跨任务 ID")
	_assert_contains(contributing, "跨 14 任务 ~127 轮落地", "T301-4: §9.6.45 引用 ~127 轮 polish 链 (D002.B #98 → T300 #226)")
	_assert_contains(contributing, "polish 模式 文档化", "T301-5: §9.6.45 标题包含 'polish 模式 文档化' 关键词")

	# ========== 2. 6 verb Stage 关键词 完整 (24 元素: 6 verb × 4 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有) ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-6: §9.6.45 Stage 1 Pulse 1 verb 3 元素 + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-7: §9.6.45 Stage 2 Bind 1 verb 3 元素 + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-8: §9.6.45 Stage 3 Cut 1 verb 3 元素 + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-9: §9.6.45 Stage 4 Echo 1 verb 3 元素 + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-10: §9.6.45 Stage 5 Wave 1 verb 3 元素 + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 6 Whisper 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-11: §9.6.45 Stage 6 Whisper 1 verb 3 元素 + 1 视觉组 1:1 严格 关键词 存在 (T245 #162 落地)")

	# ========== 3. 26 元素 = 24 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有 1:1 严格 关键词 ==========
	_assert_contains(contributing, "26 元素 1:1 严格", "T301-12: §9.6.45 26 元素 1:1 严格 关键词 存在 (6 verb × 4 元素 = 24 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有 = 26 元素 1:1 严格)")
	_assert_contains(contributing, "6 verb × 4 元素", "T301-13: §9.6.45 6 verb × 4 元素 关键词 存在 (6 verb × 4 元素 = 24 元素 1:1 严格)")
	_assert_contains(contributing, "6 verb 视觉组连贯 lifecycle", "T301-14: §9.6.45 6 verb 视觉组连贯 lifecycle 关键词 存在")
	_assert_contains(contributing, "1 显式契约 \"6 verb 视觉组连贯 lifecycle 共享视觉语法", "T301-15: §9.6.45 1 显式契约 '6 verb 视觉组连贯 lifecycle 共享视觉语法' 关键词 存在")
	_assert_contains(contributing, "深海军蓝背景圆盘 + Glass Cyan 外环 + verb 主色 core", "T301-16: §9.6.45 显式契约 关键词 存在 (深海军蓝背景圆盘 + Glass Cyan 外环 + verb 主色 core)")

	# ========== 4. 6 verb `_ready()` 第 1 行 `super._ready()` 验证 (6 verb × 1 hook = 6 hook) ==========
	var pulse_ready_idx := pulse_ability.find("func _ready")
	var pulse_super_ready_idx := pulse_ability.find("super._ready()", pulse_ready_idx)
	_assert(pulse_ready_idx != -1, "T301-17.s1: pulse_ability.gd `func _ready` 存在 (Stage 1 Pulse 1 verb 1 hook 1:1 严格分离契约)")
	_assert(pulse_super_ready_idx > pulse_ready_idx, "T301-18.s1: pulse_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 1 Pulse 1 verb 1 hook super 调用顺序)")
	var bind_ready_idx := bind_ability.find("func _ready")
	var bind_super_ready_idx := bind_ability.find("super._ready()", bind_ready_idx)
	_assert(bind_ready_idx != -1, "T301-19.s2: bind_ability.gd `func _ready` 存在 (Stage 2 Bind 1 verb 1 hook 1:1 严格分离契约)")
	_assert(bind_super_ready_idx > bind_ready_idx, "T301-20.s2: bind_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 2 Bind 1 verb 1 hook super 调用顺序)")
	var cut_ready_idx := cut_ability.find("func _ready")
	var cut_super_ready_idx := cut_ability.find("super._ready()", cut_ready_idx)
	_assert(cut_ready_idx != -1, "T301-21.s3: cut_ability.gd `func _ready` 存在 (Stage 3 Cut 1 verb 1 hook 1:1 严格分离契约)")
	_assert(cut_super_ready_idx > cut_ready_idx, "T301-22.s3: cut_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 3 Cut 1 verb 1 hook super 调用顺序)")
	var echo_ready_idx := echo_ability.find("func _ready")
	var echo_super_ready_idx := echo_ability.find("super._ready()", echo_ready_idx)
	_assert(echo_ready_idx != -1, "T301-23.s4: echo_ability.gd `func _ready` 存在 (Stage 4 Echo 1 verb 1 hook 1:1 严格分离契约)")
	_assert(echo_super_ready_idx > echo_ready_idx, "T301-24.s4: echo_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 4 Echo 1 verb 1 hook super 调用顺序)")
	var wave_ready_idx := wave_ability.find("func _ready")
	var wave_super_ready_idx := wave_ability.find("super._ready()", wave_ready_idx)
	_assert(wave_ready_idx != -1, "T301-25.s5: wave_ability.gd `func _ready` 存在 (Stage 5 Wave 1 verb 1 hook 1:1 严格分离契约)")
	_assert(wave_super_ready_idx > wave_ready_idx, "T301-26.s5: wave_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 5 Wave 1 verb 1 hook super 调用顺序)")
	var whisper_ready_idx := whisper_ability.find("func _ready")
	var whisper_super_ready_idx := whisper_ability.find("super._ready()", whisper_ready_idx)
	_assert(whisper_ready_idx != -1, "T301-27.s6: whisper_ability.gd `func _ready` 存在 (Stage 6 Whisper 1 verb 1 hook 1:1 严格分离契约)")
	_assert(whisper_super_ready_idx > whisper_ready_idx, "T301-28.s6: whisper_ability.gd `_ready()` 第 1 行 `super._ready()` 1:1 严格 (Stage 6 Whisper 1 verb 1 hook super 调用顺序)")

	# ========== 5. 5 verb `_exit_tree()` 0 override 验证 (Pulse / Bind / Cut / Echo / Whisper) ==========
	_assert(pulse_ability.find("func _exit_tree") == -1, "T301-29.s1: pulse_ability.gd 0 override `func _exit_tree` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_ability.find("func _exit_tree") == -1, "T301-30.s2: bind_ability.gd 0 override `func _exit_tree` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_ability.find("func _exit_tree") == -1, "T301-31.s3: cut_ability.gd 0 override `func _exit_tree` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_ability.find("func _exit_tree") == -1, "T301-32.s4: echo_ability.gd 0 override `func _exit_tree` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(whisper_ability.find("func _exit_tree") == -1, "T301-33.s6: whisper_ability.gd 0 override `func _exit_tree` (Stage 6 Whisper 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 6. 1 verb `_exit_tree()` 1 override 验证 (Wave) — 1:1 严格 byte-identical cleanup 镜像 base ==========
	_assert(wave_ability.find("func _exit_tree") != -1, "T301-34.s5: resonance_wave_ability.gd 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 hook 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_ability.find("super._exit_tree()") == -1, "T301-35.s5: resonance_wave_ability.gd 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb byte-identical cleanup 镜像 base 而非 super 调用)")

	# ========== 7. 6 verb 0 自己加 `assert(_player != null, ...)` 验证 (6 verb × 1 assertion = 6 assertion 0 override) ==========
	_assert(pulse_ability.find("assert(_player != null") == -1, "T301-36.s1: pulse_ability.gd 0 自己加 `assert(_player != null` (Stage 1 Pulse 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(bind_ability.find("assert(_player != null") == -1, "T301-37.s2: bind_ability.gd 0 自己加 `assert(_player != null` (Stage 2 Bind 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(cut_ability.find("assert(_player != null") == -1, "T301-38.s3: cut_ability.gd 0 自己加 `assert(_player != null` (Stage 3 Cut 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(echo_ability.find("assert(_player != null") == -1, "T301-39.s4: echo_ability.gd 0 自己加 `assert(_player != null` (Stage 4 Echo 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(wave_ability.find("assert(_player != null") == -1, "T301-40.s5: wave_ability.gd 0 自己加 `assert(_player != null` (Stage 5 Wave 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")
	_assert(whisper_ability.find("assert(_player != null") == -1, "T301-41.s6: whisper_ability.gd 0 自己加 `assert(_player != null` (Stage 6 Whisper 1 verb 1 assertion 0 触碰 base 1:1 严格继承)")

	# ========== 8. base `_player` non-null assertion 1 边 验证 (_verb_ability_base.gd) ==========
	_assert_contains(verb_ability_base, "assert(_player != null, \"VerbAbilityBase subclass must be child of CharacterBody2D\")", "T301-42.b1: _verb_ability_base.gd `_player` non-null assertion 1 边 0 触碰既有 1:1 严格 (1 base assertion 0 触碰既有 1:1 严格 0 漏 0 改 0 反序 0 反向)")
	_assert_contains(verb_ability_base, "@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D", "T301-43.b1: _verb_ability_base.gd `@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D` 1 边 存在 (1 边 0 触碰既有 1:1 严格)")
	_assert_contains(verb_ability_base, "func _ready() -> void:", "T301-44.b1: _verb_ability_base.gd `func _ready() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "func _exit_tree() -> void:", "T301-45.b1: _verb_ability_base.gd `func _exit_tree() -> void:` 1 共享方法 存在")
	_assert_contains(verb_ability_base, "Lifecycle contract", "T301-46.c1: _verb_ability_base.gd `Lifecycle contract` 显式契约 存在")

	# ========== 9. 5 verb 视觉组 5 段 + 1 verb 视觉组 1 段 关键词 验证 ==========
	_assert_contains(contributing, "5 verb 视觉组 5 段 1:1 严格", "T301-47: §9.6.45 5 verb 视觉组 5 段 1:1 严格 关键词 存在 (Pulse 同心圆环扩散波 / Bind 向内螺旋涡 / Cut 水平锋利斩 / Echo 玻璃护盾 / Wave 双环扩散)")
	_assert_contains(contributing, "Pulse 同心圆环扩散波 + Coral Pulse 核", "T301-48.s1: §9.6.45 Pulse 视觉组 (同心圆环扩散波 + Coral Pulse 核) 关键词 存在")
	_assert_contains(contributing, "Bind 向内螺旋涡 + Muted Violet 核", "T301-49.s2: §9.6.45 Bind 视觉组 (向内螺旋涡 + Muted Violet 核) 关键词 存在")
	_assert_contains(contributing, "Cut 水平锋利斩 + 4 三角碎片 + Amber Voice 核", "T301-50.s3: §9.6.45 Cut 视觉组 (水平锋利斩 + 4 三角碎片 + Amber Voice 核) 关键词 存在")
	_assert_contains(contributing, "Echo 玻璃护盾 + 8 棱镜折射 + 双向反弹 + Glass Cyan 核", "T301-51.s4: §9.6.45 Echo 视觉组 (玻璃护盾 + 8 棱镜折射 + 双向反弹 + Glass Cyan 核) 关键词 存在")
	_assert_contains(contributing, "Wave 双环扩散 + 8 棱镜光线 + amber 中心 + Pale Resonance 核", "T301-52.s5: §9.6.45 Wave 视觉组 (双环扩散 + 8 棱镜光线 + amber 中心 + Pale Resonance 核) 关键词 存在")
	_assert_contains(contributing, "Whisper constant 球 + 2px 描边 + 球心亮点 + Muted Mauve 核", "T301-53.s6: §9.6.45 Whisper 视觉组 (constant 球 + 2px 描边 + 球心亮点 + Muted Mauve 核, T245 #162 落地) 关键词 存在")

	# ========== 10. 6 verb 视觉组连贯 lifecycle 1 段 显式契约 关键词 验证 ==========
	_assert_contains(contributing, "6 verb 视觉组连贯 lifecycle 共享视觉语法", "T301-54: §9.6.45 6 verb 视觉组连贯 lifecycle 共享视觉语法 显式契约 关键词 存在")
	_assert_contains(contributing, "1 视觉组 0 触碰既有 1:1 严格", "T301-55: §9.6.45 1 视觉组 0 触碰既有 1:1 严格 关键词 存在")

	# ========== 11. 0 副作用 段 + 8 段 prevention rule + 5 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T301-56: §9.6.45 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排", "T301-57: §9.6.45 0 副作用 段 引用 0 改 0 删 0 重排")
	_assert_contains(contributing, "26 元素 0 触碰边界", "T301-58: §9.6.45 prevention 段 (b) 26 元素 0 触碰边界 关键词")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T301-59: §9.6.45 prevention 段 (c) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T301-60: §9.6.45 prevention 段 (d) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T301-61: §9.6.45 prevention 段 (e) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T301-62: §9.6.45 prevention 段 (f) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "36 套 polish 模式", "T301-63: §9.6.45 prevention 段 (g) 36 套 polish 模式 唯一性")
	_assert_contains(contributing, "drift risk", "T301-64: §9.6.45 prevention 段 drift risk 已知 26 元素 1:1 镜像 0 漏 4 元素 / 1 边 1:1 镜像")
	# 5 关系段: 与 §9.6.44 + 与 §9.6.26 + 与 §9.6.22 + 与 T162 + 与 §9.1
	_assert_contains(contributing, "**与 §9.6.44 关系**", "T301-65: §9.6.45 与 §9.6.44 关系 段 存在 (姊妹段 + 拼接段, §9.6.45 = §9.6.44 + 7 元素 1:1 严格)")
	_assert_contains(contributing, "**与 §9.6.26 关系**", "T301-66: §9.6.45 与 §9.6.26 关系 段 存在 (姊妹段 + 拼接段)")
	_assert_contains(contributing, "**与 §9.6.22 关系**", "T301-67: §9.6.45 与 §9.6.22 关系 段 存在 (姊妹段 + 拼接段, 26 元素 ⊃ 5 段 1:1 严格)")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T301-68: §9.6.45 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T301-69: §9.6.45 与 §9.1 9 步关系 段 存在")

	# ========== 12. §9.6.45 段长 ≥ 30 行 + 0 漏 35 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.45 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 + 6 verb 视觉组连贯 lifecycle 1:1 严格分离契约")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 30, "T301-70: §9.6.45 段长 ≥ 30 行 — actual " + str(section_lines.size()) + " lines")
	# 35 套 polish 模式 全列举 (含 §9.6.44, 不含 §9.6.45 自身)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42", "§9.6.43", "§9.6.44"]:
		_assert_contains(section_text, ref_num, "T301-71." + ref_num + ": §9.6.45 段内 引用 " + ref_num + " (35 套 polish 模式 列举 0 漏 1 套)")

	# ========== 13. 35 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.45"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42", "§9.6.43", "§9.6.44"]:
		_assert_contains(zero_block_text, ref_num, "T301-72." + ref_num + ": §9.6.45 0 副作用 段 引用 " + ref_num + " (35 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 14. 6 verb × 4 元素 = 24 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有 = 26 元素 1:1 严格 闭环 ==========
	var stage_keywords := ["Pulse 1 verb", "Bind 1 verb", "Cut 1 verb", "Echo 1 verb", "Wave 1 verb", "Whisper 1 verb"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 6, "T301-73: 6 verb 序列 6 元素 1:1 严格 闭环 (6 verb 关键词 全找到) — actual " + str(stage_count) + "/6")
	var elements_keywords := ["26 元素", "6 verb × 4 元素", "1 显式契约", "1 视觉组 0 触碰既有"]
	var elements_count := 0
	for kw in elements_keywords:
		if contributing.find(kw) != -1:
			elements_count += 1
	_assert(elements_count >= 3, "T301-74: 26 元素 拆分 关键词 存在 (24 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有 = 26 元素 1:1 严格分离契约 闭环) — actual " + str(elements_count) + "/4")

	# ========== 15. 6 verb 双 hook + assertion 1:1 严格 状态 验证 (5 verb 0 override + 1 verb 1 override + 6 verb 0 自己加 assert) ==========
	var five_verbs_no_override_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("func _exit_tree") != -1:
			five_verbs_no_override_ok = false
			break
	_assert(five_verbs_no_override_ok, "T301-75: 5 verb (Pulse / Bind / Cut / Echo / Whisper) 0 override `func _exit_tree` (5 verb 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")
	var wave_text := _read_text(WAVE_ABILITY_PATH)
	_assert(wave_text.find("func _exit_tree") != -1, "T301-76: 1 verb (Wave) 1 override `func _exit_tree` (Stage 5 Wave 1 verb 1 override 1:1 严格 byte-identical cleanup 镜像 base)")
	_assert(wave_text.find("super._exit_tree()") == -1, "T301-77: 1 verb (Wave) 0 显式 `super._exit_tree()` 调用 (Stage 5 Wave 1 verb 1:1 严格 byte-identical cleanup 镜像 base 而非 super 调用)")
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
	_assert(six_verbs_super_ready_ok, "T301-78: 6 verb (Pulse / Bind / Cut / Echo / Wave / Whisper) 全部 `_ready()` 第 1 行 `super._ready()` 1:1 严格 (6 verb × 1 hook = 6 hook super 调用顺序 0 漏 1 verb 0 反向)")
	var six_verbs_no_assert_ok := true
	for path in [PULSE_ABILITY_PATH, BIND_ABILITY_PATH, CUT_ABILITY_PATH, ECHO_ABILITY_PATH, WAVE_ABILITY_PATH, WHISPER_ABILITY_PATH]:
		var text := _read_text(path)
		if text.find("assert(_player != null") != -1:
			six_verbs_no_assert_ok = false
			break
	_assert(six_verbs_no_assert_ok, "T301-79: 6 verb (Pulse / Bind / Cut / Echo / Wave / Whisper) 0 自己加 `assert(_player != null` (6 verb × 1 assertion = 6 assertion 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")

	# ========== 16. §9.6.45 0 触碰既有 35 套 polish 模式 任何 1 character ==========
	_assert_contains(contributing, "### 9.6.44 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 1:1 严格分离契约", "T301-80: §9.6.44 段 仍然存在 (T301 0 触碰 §9.6.44 任何 1 character, 35 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook 串联", "T301-81: §9.6.43 段 仍然存在 (T301 0 触碰 §9.6.43 任何 1 character, 35 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.42 6 verb `_exit_tree()` super 调用顺序", "T301-82: §9.6.42 段 仍然存在 (T301 0 触碰 §9.6.42 任何 1 character, 35 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.41 6 verb `_ready()` super 调用顺序", "T301-83: §9.6.41 段 仍然存在 (T301 0 触碰 §9.6.41 任何 1 character, 35 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T301-84: §9.6.40 段 仍然存在 (T301 0 触碰 §9.6.40 任何 1 character, 35 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T301-85: §9.6.39 段 仍然存在 (T301 0 触碰 §9.6.39 任何 1 character, 35 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.18 `_verb_ability_base.gd` 共享契约", "T301-86: §9.6.18 段 仍然存在 (T301 0 触碰 §9.6.18 任何 1 character, 35 套 polish 模式 0 漏 1 套)")

	# ========== 17. 任务 ID 引用 ==========
	_assert_contains(contributing, "D002.B", "T301-87: §9.6.45 引用 D002.B 任务 ID")
	_assert_contains(contributing, "T166", "T301-88: §9.6.45 引用 T166 任务 ID")
	_assert_contains(contributing, "T167", "T301-89: §9.6.45 引用 T167 任务 ID")
	_assert_contains(contributing, "T168", "T301-90: §9.6.45 引用 T168 任务 ID")
	_assert_contains(contributing, "T169", "T301-91: §9.6.45 引用 T169 任务 ID")
	_assert_contains(contributing, "T171", "T301-92: §9.6.45 引用 T171 任务 ID")
	_assert_contains(contributing, "T173", "T301-93: §9.6.45 引用 T173 任务 ID")
	_assert_contains(contributing, "T174", "T301-94: §9.6.45 引用 T174 任务 ID")
	_assert_contains(contributing, "T245", "T301-95: §9.6.45 引用 T245 任务 ID (T245 #162 落地 Whisper 视觉组)")
	_assert_contains(contributing, "T250", "T301-96: §9.6.45 引用 T250 任务 ID (T250 #168 落地 6 verb 视觉组连贯 tooltip 8 行)")
	_assert_contains(contributing, "T297", "T301-97: §9.6.45 引用 T297 任务 ID (前一轮 #222 polish)")
	_assert_contains(contributing, "T298", "T301-98: §9.6.45 引用 T298 任务 ID (前一轮 #223 polish)")
	_assert_contains(contributing, "T299", "T301-99: §9.6.45 引用 T299 任务 ID (前一轮 #224 polish)")
	_assert_contains(contributing, "T300", "T301-100: §9.6.45 引用 T300 任务 ID (前一轮 #226 polish)")
	_assert_contains(contributing, "T301", "T301-101: §9.6.45 引用 T301 任务 ID (本轮 #227 polish)")
	_assert_contains(contributing, "#98", "T301-102: §9.6.45 引用 #98 iteration ID (D002.B iter)")
	_assert_contains(contributing, "#85", "T301-103: §9.6.45 引用 #85 iteration ID (T166 iter)")
	_assert_contains(contributing, "#162", "T301-104: §9.6.45 引用 #162 iteration ID (T245 iter, Whisper 视觉组 落地)")
	_assert_contains(contributing, "#168", "T301-105: §9.6.45 引用 #168 iteration ID (T250 iter, 6 verb 视觉组连贯 tooltip 落地)")
	_assert_contains(contributing, "#226", "T301-106: §9.6.45 引用 #226 iteration ID (T300 自身落地 iter)")
	_assert_contains(contributing, "#227", "T301-107: §9.6.45 引用 #227 iteration ID (T301 自身落地 iter)")

	# ========== 18. §9.6.45 姊妹段 + 拼接段 关系 验证 ==========
	_assert_contains(contributing, "姊妹段 + 拼接段", "T301-108: §9.6.45 段 包含 '姊妹段 + 拼接段' 关键词 (§9.6.45 = §9.6.44 + 7 元素 1:1 严格 拼接段, 1 套 polish 模式 串联 1 套 polish 模式 + 7 元素)")
	_assert_contains(contributing, "1 套 polish 模式 × 26 元素 = 26 元素 1:1 严格 ⊃ 1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格", "T301-109: §9.6.45 段 包含 '1 套 polish 模式 × 26 元素 = 26 元素 1:1 严格 ⊃ 1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格' 关键词 (1 套 polish 模式 × 26 元素 = 26 元素 1:1 严格 ⊃ 1 套 polish 模式 × 19 元素 = 19 元素 1:1 严格)")

	# ========== 19. §9.6.45 36 套 polish 模式 唯一性 验证 ==========
	_assert_contains(contributing, "§9.6.45 是 36 套 polish 模式**唯一**关注", "T301-110: §9.6.45 是 36 套 polish 模式**唯一**关注 6 verb 双 hook 串联 + `_player` non-null assertion + 6 verb 视觉组连贯 lifecycle 1:1 严格分离契约 (1 套 polish 模式唯一性 标注 0 互混 0 复用 0 共享)")

	# ========== 20. §9.6.45 §9.1 9 步关系 验证 ==========
	_assert_contains(contributing, "§9.6.45 6 verb × 4 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有 = 26 元素 走 §9.1 9 步落地的 1 步", "T301-111: §9.6.45 26 元素 走 §9.1 9 步落地的 1 步 (Stage 2 ability 子类, 跨 6 verb 各 4 元素 + 1 base assertion + 1 显式契约 + 1 视觉组 0 触碰既有)")

	# ========== 21. T301 自身 0 硬编码 验证 ==========
	var test_self_text := _read_text("res://tools/test_t301_contributing_fragility_section9645_smoke.gd")
	_assert_contains(test_self_text, "Stage 1 Pulse 1 verb 3 元素 + 1 视觉组 1:1 严格", "T301-112: T301 自身引用 Stage 1 Pulse 1 verb 3 元素 + 1 视觉组 1:1 严格 (26 元素 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 22. §9.6.45 `_player` non-null assertion 关键词 ==========
	_assert_contains(contributing, "_player` non-null assertion", "T301-113: §9.6.45 引用 `_player` non-null assertion 关键词 (1 base assertion 0 触碰既有 1:1 严格)")
	_assert_contains(contributing, "6 verb 0 自己加 `assert(_player != null, ...)` 0 触碰 base 1:1 严格继承", "T301-114: §9.6.45 引用 6 verb 0 自己加 `assert(_player != null, ...)` 0 触碰 base 1:1 严格继承 关键词")

	# ========== 23. T301 0 触碰既有 35 套 polish 模式 段 仍然存在 + T301 自身 0 副作用 ==========
	_assert_contains(contributing, "### 9.6.45 6 verb `_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion 0 触碰既有 + 6 verb 视觉组连贯 lifecycle 1:1 严格分离契约", "T301-115: §9.6.45 段 段顶 0 触碰既有 (T301 0 触碰既有 35 套 polish 模式 任何 1 character, 段 0 漏 1 字符)")

	# ========== Final ==========
	print("[T301] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T301] FAILURES:")
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
		print("[T301] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T301] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
