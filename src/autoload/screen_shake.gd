extends Node
## ScreenShake — autoload 屏幕震动服务（T089 polish）。
##
## 提供简单的 [code]shake(intensity, duration)[/code] API。任何节点都可
## 通过全局名 [code]ScreenShake[/code] 直接调用，无需在调用方持有
## 摄像机引用。内部用 Tween + 多帧 micro-shake 实现衰减曲线，比
## 散落在 player.gd / 敌人脚本中的 inline 震动更一致、可调。
##
## 用法：
## [codeblock]
## ScreenShake.shake_preset(ScreenShake.Preset.PULSE)   # 预设
## ScreenShake.shake(2.0, 0.12)                         # 自定义
## ScreenShake.shake_preset(ScreenShake.Preset.BOSS_PHASE2)
## [/codeblock]
##
## 设计：每次 shake 取消上一次（不会出现叠加过载）。结束 offset 一定
## 归零（即使被打断），不会留下偏移。镜头 `process_mode` 跟随场景
## —— 通常不需要 PROCESS_MODE_ALWAYS，因为震动只发生在游戏运行中。

# --- 预设（与旧 inline 数值保持视觉兼容，并新增 BOSS_PHASE2 5 强度） ---
enum Preset {
	LIGHT,        # 1.0 / 0.08s  弱警告、声匣修复小反馈
	PULSE,        # 2.0 / 0.10s  Pulse 声波触发
	BIND,         # 1.0 / 0.08s  Bind 牵引触发
	CUT,          # 1.5 / 0.06s  Cut 斩击（短促锋利）
	DAMAGE,       # 3.5 / 0.15s  玩家受击
	DEATH,        # 4.5 / 0.25s  玩家死亡
	BOSS_PHASE2,  # 5.0 / 0.30s  Boss 阶段 2 切换（新增）
	HEAVY,        # 4.0 / 0.18s  通用重击
	PERK_LEVEL_UP,  # 2.5 / 0.15s  商店升档 ≥2 时小屏抖 (T185 #103 新增)
}

const _PRESETS := {
	Preset.LIGHT:         Vector2(1.0, 0.08),
	Preset.PULSE:         Vector2(2.0, 0.10),
	Preset.BIND:          Vector2(1.0, 0.08),
	Preset.CUT:           Vector2(1.5, 0.06),
	Preset.DAMAGE:        Vector2(3.5, 0.15),
	Preset.DEATH:         Vector2(4.5, 0.25),
	Preset.BOSS_PHASE2:   Vector2(5.0, 0.30),
	Preset.HEAVY:         Vector2(4.0, 0.18),
	Preset.PERK_LEVEL_UP: Vector2(2.5, 0.15),
}

# T172 (#91) — 4 verb 命中色查表常量. 严格对应 STYLE_GUIDE 限制色板
# (Coral Pulse / Muted Violet / Amber Voice / Glass Cyan).  让 player.gd
# 等调用方不直接写字面 Color(0.91, 0.427, 0.353, 1.0), 改调
# ScreenShake.VERB_HIT_PULSE_COLOR 等常量 —— 4 verb 调色 4 元组分工
# 一目了然 ("看到闪就知道是哪个 verb")，未来调色板刷新只动这里 1 处.
# 与 T170a/b/c/d (#88-#89) 4 verb 命中节奏 "1/16 beat groove" 严格一致.
# 注意: duration / peak_alpha 节奏仍由调用方传字面值, 因为 4 verb 节奏各异
# (Pulse 0.10/0.18 / Bind 0.10/0.18 / Cut 0.09/0.18 / Echo 反射 0.08/0.20 /
# Echo 非反射 0.06/0.12) 强行打包会损失 T170b 6:3 "反 > 挡" 比例语义.
#
# F010 (#96) — 完整 JSDoc 风格说明 + 6th verb 接入流程.  本常量是
# "4 verb 命中色查表" 的唯一权威源, 与 STYLE_GUIDE.md 的 4 Verb 命中
# 色查表段 (F009 #94) 严格 1:1 镜像.  4 verb (Pulse / Bind / Cut /
# Echo) 命中时, 调用方 (player.gd `_on_*_hit` 5 个 handler 之一) 必
# 须经此查表, 禁止直接 `Color("#E86D5A")` 硬编码 (T170 #88 锚定 +
# F009 #94 宪法修订流程).
#
# ┌─────────────┬──────────────────────────┬──────────────┬───────────┬─────────────────────────────────────────────┐
# │ Verb        │ Constant                 │ Hex / RGBA   │ Palette   │ Caller / where it fires                     │
# ├─────────────┼──────────────────────────┼──────────────┼───────────┼─────────────────────────────────────────────┤
# │ Pulse       │ VERB_HIT_PULSE_COLOR     │ #E86D5A      │ Coral     │ player.gd _on_pulse_hit (after AOE knockback)│
# │             │                          │ (0.91,.43,.35)│  Pulse   │                                             │
# │ Bind        │ VERB_HIT_BIND_COLOR      │ #65506A      │ Muted     │ player.gd _on_bind_hit  (after pull         │
# │             │                          │ (.40,.31,.42)│  Violet   │   snap to center)                           │
# │ Cut         │ VERB_HIT_CUT_COLOR       │ #F2B66E      │ Amber     │ player.gd _on_cut_hit   (after arc lands    │
# │             │                          │ (.95,.71,.43)│  Voice    │   on up to 6 targets)                       │
# │ Echo        │ VERB_HIT_ECHO_COLOR      │ #69C7CE      │ Glass     │ player.gd _on_echo_hit  (split path:        │
# │             │                          │ (.41,.78,.81)│  Cyan     │   reflect 0.08/0.20 / non-reflect 0.06/0.12)│
# └─────────────┴──────────────────────────┴──────────────┴───────────┴─────────────────────────────────────────────┘
#
# 调用契约 (4 verb 命中, 任一 _on_*_hit handler):
#   ScreenShake.flash_color(ScreenShake.VERB_HIT_PULSE_COLOR, 0.10, 0.18)
#   ScreenShake.flash_color(ScreenShake.VERB_HIT_BIND_COLOR,  0.10, 0.18)
#   ScreenShake.flash_color(ScreenShake.VERB_HIT_CUT_COLOR,   0.09, 0.18)
#   ScreenShake.flash_color(ScreenShake.VERB_HIT_ECHO_COLOR,  0.08, 0.20)  # 反弹路径
#   ScreenShake.flash_color(ScreenShake.VERB_HIT_ECHO_COLOR,  0.06, 0.12)  # 非反弹路径
# 第二参数 = flash 强度 (color overlay alpha), 第三 = duration (秒).
#
# **Wave 不参与此查表** (与 F009 #94 STYLE_GUIDE 段严格一致): Wave
# (第 5 verb) 是 "我自己蓄力" 语义, 不是 "谁命中我" 语义, 故使用独立
# ring 系统 + Pale Resonance #B7E7DD 调色.  Wave 命中时调
# `resonance_wave_vfx.gd.add_hit_flash()` 0.4s 玻璃白闪, **不**调
# VERB_HIT_*_COLOR.  这是有意的设计分割, 不是疏忽.
#
# **6th verb 接入流程 (宪法修订)**:
#   1. 本文件加一行 `const VERB_HIT_<NAME>_COLOR: Color = Color(...)` 选 STYLE_GUIDE
#      限制色板内尚未被 4 verb 命中色占用的色 (e.g. Warm Parchment #E6D5B8).
#   2. STYLE_GUIDE.md 4 Verb 命中色查表段 (F009) 加一行 (verb / const / hex / 用途).
#   3. player.gd 5 个 _on_*_hit handler 之外新增一个 `_on_<name>_hit` handler.
#   4. smoke test 加一项断言: "screen_shake.gd 5 个 VERB_HIT_*_COLOR 常量实际存在".
# 任何代码直接硬编码 `#E86D5A` 等 4 元组 hex 即视为违反 (CI grep 锚定).
const VERB_HIT_PULSE_COLOR: Color = Color(0.91, 0.427, 0.353, 1.0)    # Coral Pulse #E86D5A
const VERB_HIT_BIND_COLOR: Color  = Color(0.398, 0.314, 0.416, 1.0)   # Muted Violet #65506A
const VERB_HIT_CUT_COLOR: Color   = Color(0.949, 0.714, 0.431, 1.0)   # Amber Voice #F2B66E
const VERB_HIT_ECHO_COLOR: Color  = Color(0.412, 0.78, 0.808, 1.0)    # Glass Cyan #69C7CE

# --- 内部状态 ---
var _active_tween: Tween = null
var _shake_timer: Timer = null
var _camera: Camera2D = null
# T163 (#84) — Per-layer active flash tracking.  Keyed by CanvasLayer.layer
# index so a flash_color call on layer=256 doesn't accidentally cancel a
# layer=64 flash running in parallel.  Backwards-compatible: the default
# 128 layer index is still the most common, and pre-#84 callers (who
# didn't pass a layer) all land on the same dict slot, preserving the
# "back-to-back call cancels the previous" behavior.
var _active_grayscale: Dictionary = {}   # int layer_idx -> CanvasLayer
var _active_color_flash: Dictionary = {}  # int layer_idx -> CanvasLayer
# T156 — 摄像机单帧旋转 tween (skybox rotate 1f 起拍)
var _active_rotation_tween: Tween = null
# T195 (#112) — accessibility 减弱视觉反馈 状态字段. 玩家在设置
# "减弱屏幕震动" 后 set_reduce_shake(true), 之后 shake() 入口早退
# (no-op, 玩家不晃动但仍能听见 SFX / 看见 VFX). 同理 _reduced_flash
# 拦截 flash_color / flash_grayscale 入口 (T097 / T093), 但 punch_rotation
# 保留 (旋转 1 帧 skybox reaction 是 BOSS_PHASE2 起拍, 不在 reduce 范围).
# 默认 false = 全功能. _active_shake / _active_flash tween 也清空以防
# 玩家勾选后已经有在跑的震动继续 (clear pending, 而非只 no-op future).
var _reduced_shake: bool = false
var _reduced_flash: bool = false

# 频率：每秒多少 micro-shake 帧。频率越高震感越"碎"。
const FREQUENCY_HZ := 30.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 用 Timer 而不是 Tween 一次性偏移，可以更真实地"高频抖动"，
	# 而不是单纯 lerp 一次。下面是 timer：
	_shake_timer = Timer.new()
	_shake_timer.one_shot = false
	_shake_timer.wait_time = 1.0 / FREQUENCY_HZ
	_shake_timer.timeout.connect(_tick_shake)
	add_child(_shake_timer)


## 触发一次震动（自定义强度 / 持续时间）。
## [param intensity] 最大像素偏移（X/Y 等量）。
## [param duration] 持续秒数，到期自动归零。
func shake(intensity: float, duration: float = 0.1) -> void:
	# T195 (#112) — accessibility 减弱屏幕震动. 玩家勾选 reduce_shake 后
	# shake() 入口早退, 不创建 tween / 不动 camera offset. SFX + VFX 仍
	# 正常播放, 玩家能听见命中但屏幕不晃.
	if _reduced_shake:
		return
	if intensity <= 0.0 or duration <= 0.0:
		return
	# 取消上一次（避免叠加/过载）
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_camera = _resolve_camera()
	if not _camera:
		return

	# 记录状态，timer 在 duration 期间持续抖动
	_current_intensity = intensity
	_current_duration = duration
	_shake_timer.start()  # 触发高频抖动
	# 启动衰减：Tween 让 intensity 线性/曲线下降到 0
	# 用 step_progress 的方式更稳——但 Tween 直接控制 intensity 变量即可
	_active_tween = create_tween()
	_active_tween.tween_method(_set_intensity_factor, 1.0, 0.0, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_callback(_on_shake_finished)


## 触发预设震动。
func shake_preset(preset: int) -> void:
	if not _PRESETS.has(preset):
		push_warning("ScreenShake: unknown preset %d" % preset)
		return
	var p: Vector2 = _PRESETS[preset]
	shake(p.x, p.y)


# === T195 (#112) — accessibility 减弱视觉反馈 公开 setter ===
# settings_menu.gd `_on_reduce_shake_toggled` / `_on_reduce_flash_toggled`
# 调这 2 个 setter, 玩家勾选立即生效 (live-push). set_reduce_shake(true)
# 同时停掉已经 in-flight 的 tween (stop 现有 + 拒绝新), 玩家勾选 0.5s
# 后残余的震动立刻消失 (例如死亡震动还在 0.2s 末期). set_reduce_flash(true)
# 清空 _active_grayscale / _active_color_flash dict, 已经 in-flight 的 flash
# layer queue_free (避免 "我刚勾选了" 但屏幕还闪 0.3s 残余).
func set_reduce_shake(enabled: bool) -> void:
	_reduced_shake = enabled
	if enabled:
		# 停掉 in-flight shake (玩家刚勾选时 0.2-0.3s 残余震动)
		if _active_tween and _active_tween.is_valid():
			_active_tween.kill()
		_active_tween = null
		if _shake_timer:
			_shake_timer.stop()
		if _camera and is_instance_valid(_camera):
			_camera.offset = Vector2.ZERO

func set_reduce_flash(enabled: bool) -> void:
	_reduced_flash = enabled
	if enabled:
		# 清空 in-flight flash (多层)
		for layer_idx in _active_grayscale.keys():
			var g_layer: CanvasLayer = _active_grayscale[layer_idx] as CanvasLayer
			if is_instance_valid(g_layer):
				g_layer.queue_free()
		_active_grayscale.clear()
		for layer_idx in _active_color_flash.keys():
			var c_layer: CanvasLayer = _active_color_flash[layer_idx] as CanvasLayer
			if is_instance_valid(c_layer):
				c_layer.queue_free()
		_active_color_flash.clear()

func is_reduce_shake() -> bool:
	return _reduced_shake

func is_reduce_flash() -> bool:
	return _reduced_flash


## T093 polish — 玩家死亡时叠加一层 0.3s 冷灰度洗。
##
## 在屏幕顶层 (CanvasLayer layer=128) 添加一个 ColorRect，色调取
## 自 STYLE_GUIDE 冷色区间（Ink Navy + 一点 Deep Teal 的去饱和混合），
## 通过 modulate.a 控制在 0.3s 内淡入到峰值强度（默认 0.55）再淡出。
## 视觉效果："听见坠落" 节拍中，世界被短暂褪色 — 比单纯的 red tint
## 多一层「意识消散 / 失重」的失能感，但不会遮住 HUD（淡出在 fade-out
## 结束前完成）。
##
## 多次调用会自动取消上一次并立即开始新的（避免叠加峰值失控）。
##
## T163 (#84) — Optional [param flash_layer] integer picks the canvas layer
## (default 128 — historic mid-stack).  Pass 256 to flash above the HUD
## (e.g. boss-Phase-2 slow-mo effect), 64 to flash under the HUD (e.g.
## world-tinted alerts that shouldn't bleed into the inventory overlay).
## Back-to-back calls on the *same* layer cancel each other (existing
## behavior); calls on *different* layers run in parallel.
func flash_grayscale(duration: float = 0.3, peak_alpha: float = 0.55, flash_layer: int = 128) -> void:
	# T195 (#112) — accessibility 减弱屏幕闪烁. flash_grayscale 入口早退
	# 与 flash_color 一致; 但保留 _reduced_shake 的 punch_rotation (旋转
	# 1 帧 skybox reaction 是 BOSS_PHASE2 起拍, 不在 reduce 范围).
	if _reduced_flash:
		return
	if duration <= 0.0 or peak_alpha <= 0.0:
		return
	var tree := get_tree()
	if not tree:
		return
	# 取消上次 (避免多次死亡 / 多实例场景叠加到 > 1.0 alpha) — 只取消
	# 同一 layer 上的旧实例, 跨 layer 的并行 flash 不互相打断.
	if _active_grayscale.has(flash_layer) and is_instance_valid(_active_grayscale[flash_layer]):
		(_active_grayscale[flash_layer] as CanvasLayer).queue_free()
	_active_grayscale.erase(flash_layer)
	# 顶层 CanvasLayer
	var layer := CanvasLayer.new()
	layer.layer = flash_layer  # 排在 HUD (10) / 暂停菜单 (50) / 通知卡 (90) 之上 (默认 128)
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child(layer)
	# 冷灰：Ink Navy + Muted Violet 各半 + 一点 Deep Teal，去饱和
	# 0.6 倍亮度，与 Voxglass 沉郁调性一致
	var gray := Color(0.32, 0.34, 0.40, 0.0)
	var rect := ColorRect.new()
	rect.color = gray
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	_active_grayscale[flash_layer] = layer

	# Tween：淡入 + 淡出
	var tween := layer.create_tween()
	var half := maxf(duration * 0.5, 0.05)
	tween.tween_property(rect, "color:a", peak_alpha, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(rect, "color:a", 0.0, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		if is_instance_valid(layer):
			layer.queue_free()
		# T163 — 清掉 dict slot (如果它还是这个 layer 的话; 防止 stop()
		# 之后又被回调覆盖).  Uses has + layer 身份比较, 不用 is_equal
		# 避免 Object 引用比较陷阱.
		if _active_grayscale.has(flash_layer) and _active_grayscale[flash_layer] == layer:
			_active_grayscale.erase(flash_layer)
	)


## T097 — 在屏幕顶层 (CanvasLayer layer=128) 添加一个 ColorRect，用给定的颜色
## 与 alpha 进行淡入淡出。视觉上是"在主画布上盖一层带颜色的滤镜"，比
## flash_grayscale 更通用：可用于 Echo 反弹命中 (Glass Cyan) / Cut 命中
## (Coral Pulse) / 修复成功 (Amber Voice) 等需要"短暂染色但保留场景"的场景。
##
## [param color] 染色 (默认 Glass Cyan #69C7CE)。
## [param duration] 淡入 + 淡出总时长（秒），半周期最短 0.05s 防撕裂。
## [param peak_alpha] 峰值 alpha，0.0~1.0。建议 ≤ 0.3 避免遮挡场景。
##
## 多次调用自动取消上一次，避免叠加峰值失控。process_mode=ALWAYS，
## 即使游戏暂停也会渲染（与 flash_grayscale 一致）。
##
## T163 (#84) — Optional [param flash_layer] integer (default 128).  See
## flash_grayscale for the full rationale.  When two flash_color calls
## land on *different* layers (e.g. one for hit feedback on 128, one for
## the boss intro vignette on 256) they run independently — the dict-
## keyed active tracking makes this safe.
func flash_color(color: Color = Color(0.412, 0.78, 0.808, 1.0), duration: float = 0.08, peak_alpha: float = 0.2, flash_layer: int = 128) -> void:
	# T195 (#112) — accessibility 减弱屏幕闪烁. flash_color 入口早退,
	# 玩家能听见 SFX 与看见 hit 数字但不闪屏. 注意: flash_color 是
	# T097 / T163 主力 verb 命中色闪 (Pulse Coral / Bind Violet / Cut Amber
	# / Echo Cyan), reduce 开启后这些 flash 全 no-op.
	if _reduced_flash:
		return
	if duration <= 0.0 or peak_alpha <= 0.0:
		return
	var tree := get_tree()
	if not tree:
		return
	# 取消上次 (避免多次反弹 / 多实例场景叠加到 > 1.0 alpha) — 同 layer
	# 旧实例才取消, 跨 layer 的并行 flash 不互相打断.
	if _active_color_flash.has(flash_layer) and is_instance_valid(_active_color_flash[flash_layer]):
		(_active_color_flash[flash_layer] as CanvasLayer).queue_free()
	_active_color_flash.erase(flash_layer)
	# 顶层 CanvasLayer
	var layer := CanvasLayer.new()
	layer.layer = flash_layer  # 默认 128 与 flash_grayscale 同一层 (HUD 10 / 暂停菜单 50 / 通知卡 90 之上)
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child(layer)
	var c := color
	c.a = 0.0
	var rect := ColorRect.new()
	rect.color = c
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	_active_color_flash[flash_layer] = layer

	# Tween: 淡入 + 淡出 (双向 sine)
	var tween := layer.create_tween()
	var half := maxf(duration * 0.5, 0.05)
	tween.tween_property(rect, "color:a", peak_alpha, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(rect, "color:a", 0.0, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		if is_instance_valid(layer):
			layer.queue_free()
		# T163 — 清掉 dict slot (如果它还是这个 layer 的话)
		if _active_color_flash.has(flash_layer) and _active_color_flash[flash_layer] == layer:
			_active_color_flash.erase(flash_layer)
	)


## 立即停止震动并归零。
func stop() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	if _shake_timer:
		_shake_timer.stop()
	if _camera:
		_camera.offset = Vector2.ZERO
	_current_intensity = 0.0
	_current_intensity_factor = 0.0
	# T163 (#84) — 清掉 *所有* layer 上的 active flash (T093 灰阶 + T097 彩色)
	# dict 现在按 layer_idx 分桶, 旧版本单 CanvasLayer 引用. 迭代清理避免
	# 并行 flash 漏清 (例如同时运行的层 64 受伤闪 + 层 256 boss 慢动作闪).
	for layer_idx in _active_grayscale.keys():
		var g_layer: CanvasLayer = _active_grayscale[layer_idx] as CanvasLayer
		if is_instance_valid(g_layer):
			g_layer.queue_free()
	_active_grayscale.clear()
	for layer_idx in _active_color_flash.keys():
		var c_layer: CanvasLayer = _active_color_flash[layer_idx] as CanvasLayer
		if is_instance_valid(c_layer):
			c_layer.queue_free()
	_active_color_flash.clear()
	# T156 — 旋转 tween 兜底归零 (避免 stop 时摄像机卡在旋转角度)
	if _active_rotation_tween and _active_rotation_tween.is_valid():
		_active_rotation_tween.kill()
	_active_rotation_tween = null
	if _camera:
		_camera.rotation = 0.0


## T156 (#81) — 摄像机单帧旋转 + 收回 ("skybox rotate 1f 起拍")。
##
## 立即把摄像机绕 Z 轴旋转 [param degrees_value] 度（默认 0.5° = 极轻量），
## 然后在 [param duration] 秒内 ease 收回 0°。视觉是 "1 帧天空反应" —
## InkWarden 进入阶段 2 那一帧，世界先"歪一下"再被震回去，作为
## ScreenShake.shake_preset(BOSS_PHASE2) 5.0/0.30s 之前的"起拍"：
## 玩家先看到世界的极轻倾斜（暗示"它在看着我"），然后是大震（"它变
## 强了"），两层视觉先后触发形成 5 段视听序列。
##
## [param degrees_value] 旋转角度（度），0.3~0.7 是 "feels-good" 范围
## [param duration] 收回时长（秒），默认 0.2s 与 HEAVY shake 振幅感知对齐
##
## 多次调用自动取消上一次，与 shake / flash_color / flash_grayscale 行为
## 一致 — 同一刻只一个旋转 tween 生效。
func punch_rotation(degrees_value: float = 0.5, duration: float = 0.2) -> void:
	if absf(degrees_value) <= 0.0 or duration <= 0.0:
		return
	var cam := _resolve_camera()
	if not cam:
		return
	# 取消上一次 (避免多次 enter_phase_2 / 多 InkWarden 叠加到 > 1°)
	if _active_rotation_tween and _active_rotation_tween.is_valid():
		_active_rotation_tween.kill()
	cam.rotation = deg_to_rad(degrees_value)
	_active_rotation_tween = create_tween()
	_active_rotation_tween.tween_property(cam, "rotation", 0.0, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# --- 内部 ---

var _current_intensity: float = 0.0
var _current_intensity_factor: float = 0.0
var _current_duration: float = 0.0


func _set_intensity_factor(f: float) -> void:
	_current_intensity_factor = f


func _tick_shake() -> void:
	if not _camera:
		return
	var k := _current_intensity * _current_intensity_factor
	if k <= 0.01:
		_camera.offset = Vector2.ZERO
		return
	# X/Y 各偏 ±k
	var ox := randf_range(-k, k)
	var oy := randf_range(-k, k)
	_camera.offset = Vector2(ox, oy)


func _on_shake_finished() -> void:
	if _shake_timer:
		_shake_timer.stop()
	if _camera:
		_camera.offset = Vector2.ZERO
	_current_intensity = 0.0
	_current_intensity_factor = 0.0


func _resolve_camera() -> Camera2D:
	# 优先用 "camera" group 中的节点（与 player.gd / RoomLoader 一致）。
	# 缓存到 _camera 避免每帧 get_first_node_in_group。
	if _camera and is_instance_valid(_camera):
		return _camera
	var tree := get_tree()
	if not tree:
		return null
	var node := tree.get_first_node_in_group("camera")
	if node is Camera2D:
		_camera = node as Camera2D
		return _camera
	return null
