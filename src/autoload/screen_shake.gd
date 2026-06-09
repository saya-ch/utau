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
}

const _PRESETS := {
	Preset.LIGHT:       Vector2(1.0, 0.08),
	Preset.PULSE:       Vector2(2.0, 0.10),
	Preset.BIND:        Vector2(1.0, 0.08),
	Preset.CUT:         Vector2(1.5, 0.06),
	Preset.DAMAGE:      Vector2(3.5, 0.15),
	Preset.DEATH:       Vector2(4.5, 0.25),
	Preset.BOSS_PHASE2: Vector2(5.0, 0.30),
	Preset.HEAVY:       Vector2(4.0, 0.18),
}

# --- 内部状态 ---
var _active_tween: Tween = null
var _shake_timer: Timer = null
var _camera: Camera2D = null
# T093 polish — 当前活动的灰阶洗 CanvasLayer，多次死亡时复用同一引用
var _active_grayscale: CanvasLayer = null
# T097 — 当前活动的彩色闪 CanvasLayer (Pulse 施法、Cut 命中、反弹命中等等)
# 与 _active_grayscale 形态对齐：每次取消上一次，避免叠加峰值失控。
var _active_color_flash: CanvasLayer = null
# T156 — 摄像机单帧旋转 tween (skybox rotate 1f 起拍)
var _active_rotation_tween: Tween = null

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


## T093 polish — 玩家死亡时叠加一层 0.3s 冷灰度洗。
##
## 在屏幕最顶层 (CanvasLayer layer=128) 添加一个 ColorRect，色调取
## 自 STYLE_GUIDE 冷色区间（Ink Navy + 一点 Deep Teal 的去饱和混合），
## 通过 modulate.a 控制在 0.3s 内淡入到峰值强度（默认 0.55）再淡出。
## 视觉效果："听见坠落" 节拍中，世界被短暂褪色 — 比单纯的 red tint
## 多一层「意识消散 / 失重」的失能感，但不会遮住 HUD（淡出在 fade-out
## 结束前完成）。
##
## 多次调用会自动取消上一次并立即开始新的（避免叠加峰值失控）。
func flash_grayscale(duration: float = 0.3, peak_alpha: float = 0.55) -> void:
	if duration <= 0.0 or peak_alpha <= 0.0:
		return
	var tree := get_tree()
	if not tree:
		return
	# 取消上次（避免多次死亡 / 多实例场景叠加到 > 1.0 alpha）
	if _active_grayscale and is_instance_valid(_active_grayscale):
		_active_grayscale.queue_free()
		_active_grayscale = null
	# 顶层 CanvasLayer
	var layer := CanvasLayer.new()
	layer.layer = 128  # 排在 HUD (10) / 暂停菜单 (50) / 通知卡 (90) 之上
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
	_active_grayscale = layer

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
		if _active_grayscale == layer:
			_active_grayscale = null
	)


## T097 — 在屏幕最顶层 (CanvasLayer layer=128) 添加一个 ColorRect，用给定的颜色
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
func flash_color(color: Color = Color(0.412, 0.78, 0.808, 1.0), duration: float = 0.08, peak_alpha: float = 0.2) -> void:
	if duration <= 0.0 or peak_alpha <= 0.0:
		return
	var tree := get_tree()
	if not tree:
		return
	# 取消上次 (避免多次反弹 / 多实例场景叠加到 > 1.0 alpha)
	if _active_color_flash and is_instance_valid(_active_color_flash):
		_active_color_flash.queue_free()
		_active_color_flash = null
	# 顶层 CanvasLayer
	var layer := CanvasLayer.new()
	layer.layer = 128  # 与 flash_grayscale 同一层 (HUD 10 / 暂停菜单 50 / 通知卡 90 之上)
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
	_active_color_flash = layer

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
		if _active_color_flash == layer:
			_active_color_flash = null
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
	# T093 polish — 灰阶洗随 stop 一起清掉
	if _active_grayscale and is_instance_valid(_active_grayscale):
		_active_grayscale.queue_free()
	_active_grayscale = null
	# T097 — 彩色闪也随 stop 一起清掉
	if _active_color_flash and is_instance_valid(_active_color_flash):
		_active_color_flash.queue_free()
	_active_color_flash = null
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
