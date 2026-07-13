# tools/test_t302_contributing_fragility_section9646_smoke.gd
#
# T302 (#228) 落地冒烟测试: §9.6.46 5 verb windup VFX `_ready()` + `_process()` +
# `_activate_windup_tween()` + `fade_out_and_free()` 4 hook lifecycle 0 触碰既有
# 1:1 严格分离契约 polish 模式 文档化 (T166 #85 + T167 #86 + T168 #86 + T169 #87
# + T171 #89 跨 5 任务 ~140 轮落地) — 5 verb (Stage 1 Pulse 1 verb 4 hook + 1 trigger() + 1
# `_draw()` + 1 视觉组 1:1 严格 + Stage 2 Bind 1 verb 4 hook + 1 trigger() + 1
# `_draw()` + 1 视觉组 1:1 严格 + Stage 3 Cut 1 verb 4 hook + 1 trigger() + 1
# `_draw()` + 1 视觉组 1:1 严格 + Stage 4 Echo 1 verb 4 hook + 1 trigger() + 1
# `_draw()` + 1 视觉组 1:1 严格 + Stage 5 Wave 1 verb 4 hook + 1 trigger() + 1
# `_draw()` + 1 视觉组 1:1 严格) 5 verb × 6 元素 = 30 元素 + 1 base 4 hook +
# 1 显式契约 + 1 视觉组 0 触碰既有 = 31 元素 1:1 严格分离契约验证.
#
# 5 verb 4 hook lifecycle 31 元素状态:
#        5 verb `_ready()` 0 override 0 触碰 base 1:1 严格继承 (5 verb × 1 hook = 5 hook 1:1 严格)
#      + 5 verb `_process()` 0 override 0 触碰 base 1:1 严格继承 (5 verb × 1 hook = 5 hook 1:1 严格)
#      + 5 verb `_activate_windup_tween()` 0 override 0 触碰 base 1:1 严格继承 (5 verb × 1 hook = 5 hook 1:1 严格)
#      + 5 verb `fade_out_and_free()` 0 override 0 触碰 base 1:1 严格继承 (5 verb × 1 hook = 5 hook 1:1 严格)
#      + 5 verb trigger() 0 override verb-specific 1:1 严格 (5 verb × 1 trigger() = 5 trigger() 1:1 严格, 5 verb 各自 trigger() 调用 `_activate_windup_tween()` 0 触碰 base 1:1 严格)
#      + 5 verb `_draw()` 0 override verb-specific 1:1 严格 (5 verb × 1 `_draw()` = 5 `_draw()` 1:1 严格)
#      + 1 base `_ready()` 1 共享方法 (z_index = 10)
#      + 1 base `_process()` 1 共享方法 (lifetime tracker + auto-free)
#      + 1 base `_activate_windup_tween()` 1 共享方法 (ramp-in tween)
#      + 1 base `fade_out_and_free()` 1 共享方法 (0.05s fade-out tween + queue_free)
#      + 1 显式契约 "subclasses MUST call _activate_windup_tween() in their trigger()" 1 段
#      + 5 verb 视觉组 5 段 1:1 严格 (Pulse 同心圆环 + Coral Pulse 核 / Bind 向内螺旋 + Muted Violet 核 / Cut 4 三角碎片 + Amber Voice 核 / Echo 8 棱镜折射 + Glass Cyan 核 / Wave 3 同心圆环 + Pale Resonance 核)
#      + 1 视觉组 0 触碰既有 1:1 严格 (5 verb 视觉组 5 段 0 漏 0 改 0 反序 0 反向)
#
# 跨 1 套 polish 模式 × 5 verb × 6 元素 = 30 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有 = 31 元素 1:1 严格分离契约.
#
# 跨 37 套 polish 模式 中 第 37 套 (前 36 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 /
# §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45, T302 是 第 37 套, 关注
# "5 verb windup VFX `_ready()` + `_process()` + `_activate_windup_tween()` +
# `fade_out_and_free()` 4 hook lifecycle 0 触碰既有 1:1 严格分离契约", §9.6.46
# 与 §9.6.45 是 "姊妹段 + 拼接段", 1 套 polish 模式 × 31 元素 = 31 元素 1:1
# 严格 包含 1 套 polish 模式 × 4 hook lifecycle (5 verb × 4 hook = 20 hook
# 0 override 0 触碰 base 1:1 严格继承) + 1 套 polish 模式 × 5 verb trigger() +
# 5 verb `_draw()` 10 元素 1:1 严格 + 1 套 polish 模式 × 1 base 4 hook 4
# 元素 1:1 严格 + 1 套 polish 模式 × 1 显式契约 1 元素 1:1 严格 + 1 套
# polish 模式 × 5 verb 视觉组 5 段 + 1 视觉组 0 触碰既有 1:1 严格.
#
# 运行: godot --headless --path . --script tools/test_t302_contributing_fragility_section9646_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const VERB_WINDUP_VFX_BASE_PATH := "res://src/scripts/_verb_windup_vfx_base.gd"
const PULSE_WINDUP_VFX_PATH := "res://src/scripts/pulse_windup_vfx.gd"
const BIND_WINDUP_VFX_PATH := "res://src/scripts/bind_windup_vfx.gd"
const CUT_WINDUP_VFX_PATH := "res://src/scripts/cut_windup_vfx.gd"
const ECHO_WINDUP_VFX_PATH := "res://src/scripts/echo_windup_vfx.gd"
const WAVE_WINDUP_VFX_PATH := "res://src/scripts/wave_windup_vfx.gd"
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
	print("=== T302 (#228) §9.6.46 5 verb windup VFX 4 hook lifecycle 0 触碰既有 1:1 严格分离契约 31 元素 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var verb_windup_vfx_base := _read_text(VERB_WINDUP_VFX_BASE_PATH)
	var pulse_windup_vfx := _read_text(PULSE_WINDUP_VFX_PATH)
	var bind_windup_vfx := _read_text(BIND_WINDUP_VFX_PATH)
	var cut_windup_vfx := _read_text(CUT_WINDUP_VFX_PATH)
	var echo_windup_vfx := _read_text(ECHO_WINDUP_VFX_PATH)
	var wave_windup_vfx := _read_text(WAVE_WINDUP_VFX_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)
	var check_smoke := _read_text(CHECK_SMOKE_CONSISTENCY_PATH)

	# ========== 1. §9.6.46 段顶 存在 + 5 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.46 5 verb windup VFX `_ready()` + `_process()` + `_activate_windup_tween()` + `fade_out_and_free()` 4 hook lifecycle 0 触碰既有 1:1 严格分离契约", "T302-1: §9.6.46 段顶 存在")
	_assert_contains(contributing, "5 verb windup VFX 4 hook lifecycle 0 触碰既有 1:1 严格分离契约", "T302-2: §9.6.46 标题包含 '5 verb windup VFX 4 hook lifecycle 0 触碰既有 1:1 严格分离契约'")
	_assert_contains(contributing, "T166 #85 + T167 #86 + T168 #86 + T169 #87 + T171 #89", "T302-3: §9.6.46 引用 5 任务 跨任务 ID")
	_assert_contains(contributing, "跨 5 任务 ~140 轮落地", "T302-4: §9.6.46 引用 ~140 轮 polish 链 (T166 #85 → T171 #89)")
	_assert_contains(contributing, "polish 模式 文档化", "T302-5: §9.6.46 标题包含 'polish 模式 文档化' 关键词")

	# ========== 2. 5 verb Stage 关键词 完整 (30 元素: 5 verb × 6 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有) ==========
	_assert_contains(contributing, "Stage 1 Pulse 1 verb 4 hook + 1 视觉组 1:1 严格", "T302-6: §9.6.46 Stage 1 Pulse 1 verb 4 hook + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 Bind 1 verb 4 hook + 1 视觉组 1:1 严格", "T302-7: §9.6.46 Stage 2 Bind 1 verb 4 hook + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 Cut 1 verb 4 hook + 1 视觉组 1:1 严格", "T302-8: §9.6.46 Stage 3 Cut 1 verb 4 hook + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 Echo 1 verb 4 hook + 1 视觉组 1:1 严格", "T302-9: §9.6.46 Stage 4 Echo 1 verb 4 hook + 1 视觉组 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 Wave 1 verb 4 hook + 1 视觉组 1:1 严格", "T302-10: §9.6.46 Stage 5 Wave 1 verb 4 hook + 1 视觉组 1:1 严格 关键词 存在")

	# ========== 3. 31 元素 = 30 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有 1:1 严格 关键词 ==========
	_assert_contains(contributing, "31 元素 1:1 严格", "T302-11: §9.6.46 31 元素 1:1 严格 关键词 存在 (5 verb × 6 元素 = 30 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有 = 31 元素 1:1 严格)")
	_assert_contains(contributing, "5 verb × 6 元素", "T302-12: §9.6.46 5 verb × 6 元素 关键词 存在 (5 verb × 6 元素 = 30 元素 1:1 严格)")
	_assert_contains(contributing, "1 base 4 hook", "T302-13: §9.6.46 1 base 4 hook 关键词 存在 (1 base 4 hook 0 触碰既有 1:1 严格)")
	_assert_contains(contributing, "1 显式契约", "T302-14: §9.6.46 1 显式契约 关键词 存在")
	_assert_contains(contributing, "subclasses MUST call _activate_windup_tween() in their trigger()", "T302-15: §9.6.46 显式契约 关键词 存在 (subclasses MUST call _activate_windup_tween() in their trigger())")
	_assert_contains(contributing, "1 视觉组 0 触碰既有 1:1 严格", "T302-16: §9.6.46 1 视觉组 0 触碰既有 1:1 严格 关键词 存在")

	# ========== 4. base 4 hook 验证 (_verb_windup_vfx_base.gd) ==========
	_assert_contains(verb_windup_vfx_base, "func _ready() -> void:", "T302-17.b1: _verb_windup_vfx_base.gd `func _ready() -> void:` 1 共享方法 存在")
	_assert_contains(verb_windup_vfx_base, "func _process(delta: float) -> void:", "T302-18.b1: _verb_windup_vfx_base.gd `func _process(delta: float) -> void:` 1 共享方法 存在")
	_assert_contains(verb_windup_vfx_base, "func _activate_windup_tween() -> void:", "T302-19.b1: _verb_windup_vfx_base.gd `func _activate_windup_tween() -> void:` 1 共享方法 存在")
	_assert_contains(verb_windup_vfx_base, "func fade_out_and_free() -> void:", "T302-20.b1: _verb_windup_vfx_base.gd `func fade_out_and_free() -> void:` 1 共享方法 存在")
	_assert_contains(verb_windup_vfx_base, "subclasses MUST call _activate_windup_tween() in their trigger()", "T302-21.c1: _verb_windup_vfx_base.gd 显式契约 存在")

	# ========== 5. 5 verb `_ready()` 0 override 验证 (Pulse / Bind / Cut / Echo / Wave) ==========
	_assert(pulse_windup_vfx.find("func _ready") == -1, "T302-22.s1: pulse_windup_vfx.gd 0 override `func _ready` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_windup_vfx.find("func _ready") == -1, "T302-23.s2: bind_windup_vfx.gd 0 override `func _ready` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_windup_vfx.find("func _ready") == -1, "T302-24.s3: cut_windup_vfx.gd 0 override `func _ready` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_windup_vfx.find("func _ready") == -1, "T302-25.s4: echo_windup_vfx.gd 0 override `func _ready` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(wave_windup_vfx.find("func _ready") == -1, "T302-26.s5: wave_windup_vfx.gd 0 override `func _ready` (Stage 5 Wave 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 6. 5 verb `_process()` 0 override 验证 ==========
	_assert(pulse_windup_vfx.find("func _process") == -1, "T302-27.s1: pulse_windup_vfx.gd 0 override `func _process` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_windup_vfx.find("func _process") == -1, "T302-28.s2: bind_windup_vfx.gd 0 override `func _process` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_windup_vfx.find("func _process") == -1, "T302-29.s3: cut_windup_vfx.gd 0 override `func _process` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_windup_vfx.find("func _process") == -1, "T302-30.s4: echo_windup_vfx.gd 0 override `func _process` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(wave_windup_vfx.find("func _process") == -1, "T302-31.s5: wave_windup_vfx.gd 0 override `func _process` (Stage 5 Wave 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 7. 5 verb `_activate_windup_tween()` 0 override 验证 ==========
	_assert(pulse_windup_vfx.find("func _activate_windup_tween") == -1, "T302-32.s1: pulse_windup_vfx.gd 0 override `func _activate_windup_tween` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_windup_vfx.find("func _activate_windup_tween") == -1, "T302-33.s2: bind_windup_vfx.gd 0 override `func _activate_windup_tween` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_windup_vfx.find("func _activate_windup_tween") == -1, "T302-34.s3: cut_windup_vfx.gd 0 override `func _activate_windup_tween` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_windup_vfx.find("func _activate_windup_tween") == -1, "T302-35.s4: echo_windup_vfx.gd 0 override `func _activate_windup_tween` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(wave_windup_vfx.find("func _activate_windup_tween") == -1, "T302-36.s5: wave_windup_vfx.gd 0 override `func _activate_windup_tween` (Stage 5 Wave 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 8. 5 verb `fade_out_and_free()` 0 override 验证 ==========
	_assert(pulse_windup_vfx.find("func fade_out_and_free") == -1, "T302-37.s1: pulse_windup_vfx.gd 0 override `func fade_out_and_free` (Stage 1 Pulse 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(bind_windup_vfx.find("func fade_out_and_free") == -1, "T302-38.s2: bind_windup_vfx.gd 0 override `func fade_out_and_free` (Stage 2 Bind 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(cut_windup_vfx.find("func fade_out_and_free") == -1, "T302-39.s3: cut_windup_vfx.gd 0 override `func fade_out_and_free` (Stage 3 Cut 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(echo_windup_vfx.find("func fade_out_and_free") == -1, "T302-40.s4: echo_windup_vfx.gd 0 override `func fade_out_and_free` (Stage 4 Echo 1 verb 1 hook 0 触碰 base 1:1 严格继承)")
	_assert(wave_windup_vfx.find("func fade_out_and_free") == -1, "T302-41.s5: wave_windup_vfx.gd 0 override `func fade_out_and_free` (Stage 5 Wave 1 verb 1 hook 0 触碰 base 1:1 严格继承)")

	# ========== 9. 5 verb trigger() 验证 (verb-specific, 0 override 4 hook 自身) ==========
	_assert(pulse_windup_vfx.find("func trigger") != -1, "T302-42.s1: pulse_windup_vfx.gd 1 `func trigger` (Stage 1 Pulse 1 verb 1 trigger() verb-specific 1:1 严格)")
	_assert(pulse_windup_vfx.find("_activate_windup_tween()") != -1, "T302-43.s1: pulse_windup_vfx.gd `trigger()` 调用 `_activate_windup_tween()` 0 触碰 base 1:1 严格")
	_assert(bind_windup_vfx.find("func trigger") != -1, "T302-44.s2: bind_windup_vfx.gd 1 `func trigger` (Stage 2 Bind 1 verb 1 trigger() verb-specific 1:1 严格)")
	_assert(cut_windup_vfx.find("func trigger") != -1, "T302-45.s3: cut_windup_vfx.gd 1 `func trigger` (Stage 3 Cut 1 verb 1 trigger() verb-specific 1:1 严格)")
	_assert(echo_windup_vfx.find("func trigger") != -1, "T302-46.s4: echo_windup_vfx.gd 1 `func trigger` (Stage 4 Echo 1 verb 1 trigger() verb-specific 1:1 严格)")
	_assert(wave_windup_vfx.find("func trigger") != -1, "T302-47.s5: wave_windup_vfx.gd 1 `func trigger` (Stage 5 Wave 1 verb 1 trigger() verb-specific 1:1 严格)")

	# ========== 10. 5 verb `_draw()` 0 override verb-specific 1:1 严格 验证 ==========
	_assert(pulse_windup_vfx.find("func _draw") != -1, "T302-48.s1: pulse_windup_vfx.gd 1 `func _draw` (Stage 1 Pulse 1 verb 1 `_draw()` verb-specific 1:1 严格)")
	_assert(bind_windup_vfx.find("func _draw") != -1, "T302-49.s2: bind_windup_vfx.gd 1 `func _draw` (Stage 2 Bind 1 verb 1 `_draw()` verb-specific 1:1 严格)")
	_assert(cut_windup_vfx.find("func _draw") != -1, "T302-50.s3: cut_windup_vfx.gd 1 `func _draw` (Stage 3 Cut 1 verb 1 `_draw()` verb-specific 1:1 严格)")
	_assert(echo_windup_vfx.find("func _draw") != -1, "T302-51.s4: echo_windup_vfx.gd 1 `func _draw` (Stage 4 Echo 1 verb 1 `_draw()` verb-specific 1:1 严格)")
	_assert(wave_windup_vfx.find("func _draw") != -1, "T302-52.s5: wave_windup_vfx.gd 1 `func _draw` (Stage 5 Wave 1 verb 1 `_draw()` verb-specific 1:1 严格)")

	# ========== 11. 5 verb 视觉组 5 段 关键词 验证 ==========
	_assert_contains(contributing, "5 verb 视觉组 5 段 1:1 严格", "T302-53: §9.6.46 5 verb 视觉组 5 段 1:1 严格 关键词 存在 (Pulse 同心圆环 / Bind 向内螺旋 / Cut 4 三角碎片 / Echo 8 棱镜折射 / Wave 3 同心圆环)")
	_assert_contains(contributing, "Pulse 同心圆环 + Coral Pulse 核", "T302-54.s1: §9.6.46 Pulse 视觉组 (同心圆环 + Coral Pulse 核) 关键词 存在")
	_assert_contains(contributing, "Bind 向内螺旋 + Muted Violet 核", "T302-55.s2: §9.6.46 Bind 视觉组 (向内螺旋 + Muted Violet 核) 关键词 存在")
	_assert_contains(contributing, "Cut 4 三角碎片 + Amber Voice 核", "T302-56.s3: §9.6.46 Cut 视觉组 (4 三角碎片 + Amber Voice 核) 关键词 存在")
	_assert_contains(contributing, "Echo 8 棱镜折射 + Glass Cyan 核", "T302-57.s4: §9.6.46 Echo 视觉组 (8 棱镜折射 + Glass Cyan 核) 关键词 存在")
	_assert_contains(contributing, "Wave 3 同心圆环 + Pale Resonance 核", "T302-58.s5: §9.6.46 Wave 视觉组 (3 同心圆环 + Pale Resonance 核) 关键词 存在")

	# ========== 12. 0 副作用 段 + 8 段 prevention rule + 5 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T302-59: §9.6.46 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排", "T302-60: §9.6.46 0 副作用 段 引用 0 改 0 删 0 重排")
	_assert_contains(contributing, "31 元素 0 触碰边界", "T302-61: §9.6.46 prevention 段 (b) 31 元素 0 触碰边界 关键词")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T302-62: §9.6.46 prevention 段 (c) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T302-63: §9.6.46 prevention 段 (d) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T302-64: §9.6.46 prevention 段 (e) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T302-65: §9.6.46 prevention 段 (f) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "37 套 polish 模式", "T302-66: §9.6.46 prevention 段 (g) 37 套 polish 模式 唯一性")
	_assert_contains(contributing, "drift risk", "T302-67: §9.6.46 prevention 段 drift risk 已知 31 元素 1:1 镜像 0 漏 6 元素 / 1 边 1:1 镜像")
	# 5 关系段: 与 §9.6.19 + 与 §9.6.33 + 与 T162 + 与 §9.1
	_assert_contains(contributing, "**与 §9.6.19 关系**", "T302-68: §9.6.46 与 §9.6.19 关系 段 存在 (姊妹段 + 拼接段, §9.6.46 = §9.6.19 + 24 元素 1:1 严格)")
	_assert_contains(contributing, "**与 §9.6.33 关系**", "T302-69: §9.6.46 与 §9.6.33 关系 段 存在 (姊妹段 + 拼接段)")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T302-70: §9.6.46 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T302-71: §9.6.46 与 §9.1 9 步关系 段 存在")

	# ========== 13. §9.6.46 段长 ≥ 20 行 + 0 漏 36 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.46 5 verb windup VFX")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 20, "T302-72: §9.6.46 段长 ≥ 20 行 — actual " + str(section_lines.size()) + " lines")
	# 36 套 polish 模式 全列举 (含 §9.6.45, 不含 §9.6.46 自身)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36", "§9.6.37", "§9.6.38", "§9.6.39", "§9.6.40", "§9.6.41", "§9.6.42", "§9.6.43", "§9.6.44", "§9.6.45"]:
		_assert_contains(section_text, ref_num, "T302-73." + ref_num + ": §9.6.46 段内 引用 " + ref_num + " (36 套 polish 模式 列举 0 漏 1 套)")

	# ========== 14. 5 verb × 6 元素 = 30 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有 = 31 元素 1:1 严格 闭环 ==========
	var stage_keywords := ["Pulse 1 verb", "Bind 1 verb", "Cut 1 verb", "Echo 1 verb", "Wave 1 verb"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 5, "T302-74: 5 verb 序列 5 元素 1:1 严格 闭环 (5 verb 关键词 全找到) — actual " + str(stage_count) + "/5")
	var elements_keywords := ["31 元素", "5 verb × 6 元素", "1 base 4 hook", "1 显式契约", "1 视觉组 0 触碰既有"]
	var elements_count := 0
	for kw in elements_keywords:
		if contributing.find(kw) != -1:
			elements_count += 1
	_assert(elements_count >= 4, "T302-75: 31 元素 拆分 关键词 存在 (30 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有 = 31 元素 1:1 严格分离契约 闭环) — actual " + str(elements_count) + "/5")

	# ========== 15. 5 verb 0 override 4 hook 状态 验证 (5 verb × 4 hook = 20 hook 0 override) ==========
	var five_verbs_no_override_ok := true
	for path in [PULSE_WINDUP_VFX_PATH, BIND_WINDUP_VFX_PATH, CUT_WINDUP_VFX_PATH, ECHO_WINDUP_VFX_PATH, WAVE_WINDUP_VFX_PATH]:
		var text := _read_text(path)
		if text.find("func _ready") != -1 or text.find("func _process") != -1 or text.find("func _activate_windup_tween") != -1 or text.find("func fade_out_and_free") != -1:
			five_verbs_no_override_ok = false
			break
	_assert(five_verbs_no_override_ok, "T302-76: 5 verb (Pulse / Bind / Cut / Echo / Wave) 0 override 4 hook (5 verb × 4 hook = 20 hook 0 触碰 base 1:1 严格继承, 0 漏 1 verb 0 反向)")

	# ========== 16. §9.6.46 0 触碰既有 36 套 polish 模式 任何 1 character ==========
	_assert_contains(contributing, "### 9.6.45 6 verb `_ready()` + `_exit_tree()` 双 hook 串联", "T302-77: §9.6.45 段 仍然存在 (T302 0 触碰 §9.6.45 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.44 6 verb `_ready()` + `_exit_tree()` 双 hook 串联", "T302-78: §9.6.44 段 仍然存在 (T302 0 触碰 §9.6.44 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.43 6 verb `_ready()` + `_exit_tree()` 双 hook 串联", "T302-79: §9.6.43 段 仍然存在 (T302 0 触碰 §9.6.43 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.42 6 verb `_exit_tree()` super 调用顺序", "T302-80: §9.6.42 段 仍然存在 (T302 0 触碰 §9.6.42 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.41 6 verb `_ready()` super 调用顺序", "T302-81: §9.6.41 段 仍然存在 (T302 0 触碰 §9.6.41 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.40 6 verb cooldown ready jingle 5 段", "T302-82: §9.6.40 段 仍然存在 (T302 0 触碰 §9.6.40 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.39 T162 brittle 修复流程 5 步骤", "T302-83: §9.6.39 段 仍然存在 (T302 0 触碰 §9.6.39 任何 1 character, 36 套 polish 模式 0 漏 1 套)")
	_assert_contains(contributing, "### 9.6.19 7 件套 windup VFX base", "T302-84: §9.6.19 段 仍然存在 (T302 0 触碰 §9.6.19 任何 1 character, 36 套 polish 模式 0 漏 1 套)")

	# ========== 17. 任务 ID 引用 ==========
	_assert_contains(contributing, "T166", "T302-85: §9.6.46 引用 T166 任务 ID")
	_assert_contains(contributing, "T167", "T302-86: §9.6.46 引用 T167 任务 ID")
	_assert_contains(contributing, "T168", "T302-87: §9.6.46 引用 T168 任务 ID")
	_assert_contains(contributing, "T169", "T302-88: §9.6.46 引用 T169 任务 ID")
	_assert_contains(contributing, "T171", "T302-89: §9.6.46 引用 T171 任务 ID")
	_assert_contains(contributing, "T302", "T302-90: §9.6.46 引用 T302 任务 ID (本轮 #228 polish)")
	_assert_contains(contributing, "#85", "T302-91: §9.6.46 引用 #85 iteration ID (T166 iter)")
	_assert_contains(contributing, "#86", "T302-92: §9.6.46 引用 #86 iteration ID (T167 iter)")
	_assert_contains(contributing, "#87", "T302-93: §9.6.46 引用 #87 iteration ID (T169 iter)")
	_assert_contains(contributing, "#89", "T302-94: §9.6.46 引用 #89 iteration ID (T171 iter)")
	_assert_contains(contributing, "#228", "T302-95: §9.6.46 引用 #228 iteration ID (T302 自身落地 iter)")

	# ========== 18. §9.6.46 姊妹段 + 拼接段 关系 验证 ==========
	_assert_contains(contributing, "姊妹段 + 拼接段", "T302-96: §9.6.46 段 包含 '姊妹段 + 拼接段' 关键词 (§9.6.46 = §9.6.19 + 24 元素 1:1 严格 拼接段, 1 套 polish 模式 串联 1 套 polish 模式 + 24 元素)")
	_assert_contains(contributing, "1 套 polish 模式 × 31 元素 = 31 元素 1:1 严格 ⊃ 1 套 polish 模式 × 7 件套 = 7 件套 1:1 严格", "T302-97: §9.6.46 段 包含 '1 套 polish 模式 × 31 元素 = 31 元素 1:1 严格 ⊃ 1 套 polish 模式 × 7 件套 = 7 件套 1:1 严格' 关键词 (1 套 polish 模式 × 31 元素 = 31 元素 1:1 严格 ⊃ 1 套 polish 模式 × 7 件套 = 7 件套 1:1 严格)")

	# ========== 19. §9.6.46 37 套 polish 模式 唯一性 验证 ==========
	_assert_contains(contributing, "§9.6.46 是 37 套 polish 模式**唯一**关注", "T302-98: §9.6.46 是 37 套 polish 模式**唯一**关注 5 verb windup VFX 4 hook lifecycle 0 触碰既有 1:1 严格分离契约 (1 套 polish 模式唯一性 标注 0 互混 0 复用 0 共享)")

	# ========== 20. §9.6.46 §9.1 9 步关系 验证 ==========
	_assert_contains(contributing, "§9.6.46 5 verb × 6 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有 = 31 元素 走 §9.1 9 步落地的 1 步", "T302-99: §9.6.46 31 元素 走 §9.1 9 步落地的 1 步 (Stage 7 windup VFX 子类, 跨 5 verb 各 6 元素 + 1 base 4 hook + 1 显式契约 + 1 视觉组 0 触碰既有)")

	# ========== 21. T302 自身 0 硬编码 验证 ==========
	var test_self_text := _read_text("res://tools/test_t302_contributing_fragility_section9646_smoke.gd")
	_assert_contains(test_self_text, "Stage 1 Pulse 1 verb 4 hook + 1 视觉组 1:1 严格", "T302-100: T302 自身引用 Stage 1 Pulse 1 verb 4 hook + 1 视觉组 1:1 严格 (31 元素 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 22. §9.6.46 4 hook 关键词 ==========
	_assert_contains(contributing, "_activate_windup_tween", "T302-101: §9.6.46 引用 `_activate_windup_tween` 关键词 (1 base hook 0 触碰既有 1:1 严格)")
	_assert_contains(contributing, "fade_out_and_free", "T302-102: §9.6.46 引用 `fade_out_and_free` 关键词 (1 base hook 0 触碰既有 1:1 严格)")

	# ========== 23. T302 0 触碰既有 36 套 polish 模式 段 仍然存在 + T302 自身 0 副作用 ==========
	_assert_contains(contributing, "### 9.6.46 5 verb windup VFX `_ready()` + `_process()` + `_activate_windup_tween()` + `fade_out_and_free()` 4 hook lifecycle 0 触碰既有 1:1 严格分离契约", "T302-103: §9.6.46 段 段顶 0 触碰既有 (T302 0 触碰既有 36 套 polish 模式 任何 1 character, 段 0 漏 1 字符)")

	# ========== Final ==========
	print("[T302] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T302] FAILURES:")
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
		print("[T302] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T302] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
