class_name HUD
extends CanvasLayer

const PulseAbilityScript = preload("res://src/scripts/pulse_ability.gd")

@export var health_bell_size: Vector2 = Vector2(14, 16)
@export var bar_width: float = 80.0
@export var bar_height: float = 6.0

@onready var _health_container: HBoxContainer = $MarginContainer/VBoxContainer/HealthRow/HealthContainer
@onready var _resonance_bar: ProgressBar = $MarginContainer/VBoxContainer/ResonanceRow/ResonanceBar
@onready var _resonance_label: Label = $MarginContainer/VBoxContainer/ResonanceRow/ResonanceLabel
@onready var _pulse_cooldown: ProgressBar = $MarginContainer/VBoxContainer/PulseRow/PulseCooldown
@onready var _bind_cooldown: ProgressBar = $MarginContainer/VBoxContainer/BindRow/BindCooldown
@onready var _cut_cooldown: ProgressBar = $MarginContainer/VBoxContainer/CutRow/CutCooldown
@onready var _echo_cooldown: ProgressBar = $MarginContainer/VBoxContainer/EchoRow/EchoCooldown
@onready var _wave_cooldown: ProgressBar = $MarginContainer/VBoxContainer/WaveRow/WaveCooldown
# T202 (#118) — 5 verb 冷却中半透明提示标签。cooldown > 0 时显示
# "冷却中" 给玩家即时反馈（progress bar 视觉小，远处难立刻看出）。
# modulate alpha 0.6 + 主题色与 verb fill 风格匹配（Pulse 暖 / Bind 紫
# / Cut 珊瑚 / Echo 青 / Wave 浅青），让"verb 色域分工"在 label 仍
# 保留，与 T200 (#117) reduce_flash 灰化不冲突（label 是文字，色
# 域分工主要靠 progress bar 维持）。
@onready var _pulse_cooldown_label: Label = $MarginContainer/VBoxContainer/PulseRow/PulseCooldownLabel
@onready var _bind_cooldown_label: Label = $MarginContainer/VBoxContainer/BindRow/BindCooldownLabel
@onready var _cut_cooldown_label: Label = $MarginContainer/VBoxContainer/CutRow/CutCooldownLabel
@onready var _echo_cooldown_label: Label = $MarginContainer/VBoxContainer/EchoRow/EchoCooldownLabel
@onready var _wave_cooldown_label: Label = $MarginContainer/VBoxContainer/WaveRow/WaveCooldownLabel
# T204 (#119) — 5 verb 名称标签。位置在 Icon 后、Cooldown 前,
# 玩家一眼看出"这一行是哪个 verb", 不必只靠 icon 形状 + progress
# bar 颜色双通道推断。颜色严格对齐 5 verb 主题色 (Amber Voice /
# Muted Violet / Coral Pulse / Glass Cyan / Pale Resonance), 与
# T202 "冷却中" label 主题色一致 — HUD 5 verb 行色域分工在
# 3 个 UI 通道 (icon + bar + name label) 100% 透明。Always-visible
# 7pt 小字, 不占额外 row 高度, 不影响 HUD 布局。
@onready var _pulse_name_label: Label = $MarginContainer/VBoxContainer/PulseRow/PulseNameLabel
@onready var _bind_name_label: Label = $MarginContainer/VBoxContainer/BindRow/BindNameLabel
@onready var _cut_name_label: Label = $MarginContainer/VBoxContainer/CutRow/CutNameLabel
@onready var _echo_name_label: Label = $MarginContainer/VBoxContainer/EchoRow/EchoNameLabel
@onready var _wave_name_label: Label = $MarginContainer/VBoxContainer/WaveRow/WaveNameLabel
# T204 (#119) — 5 verb name label 设计要点:
# (1) always-visible (无 visible toggle), 与 cooldown label 形成
#     "始终显示 verb 名 + 冷却时叠加 '冷却中' 文字" 双层语义;
# (2) 7pt 小字 + 5 verb 主题色, 与 progress bar fill style 1:1 匹配
#     (Pulse Amber Voice 0.949 / Bind Muted Violet 0.396 / Cut Coral 0.91 /
#      Echo Glass Cyan 0.412 / Wave Pale Resonance 0.718);
# (3) 位置 Icon 后、Cooldown 前 — 比把 name 放 Icon 前更好, 因为
#     HBoxContainer layout_mode 横向流, name 紧贴 progress bar 让
#     "verb 名 + 冷却进度" 形成 1 个视觉组, 玩家眼睛不需要跨过
#     icon 回头找 name。
@onready var _repair_hint: Label = $MarginContainer/VBoxContainer/RepairHint
@onready var _shard_count: Label = $MarginContainer/VBoxContainer/ShardRow/ShardCount

var _pulse_ability = null
var _bind_ability = null
var _cut_ability = null
var _echo_ability = null
var _wave_ability = null
var _repair_hint_timer: float = 0.0
var _repair_hint_max_time: float = 2.0

# T200 (#117) — accessibility reduce_flash 钩子：5 verb cooldown bar 在
# 玩家勾选「减弱屏幕闪烁」后转为 desaturated grey (0.55 灰度 75% 透
# 明度)。颜色仍存在但饱和度降到 30% 上下，让"5 verb 色域分工"在屏
# 闪偏好下不再刺眼，5 bar 仍可一眼区分（Pulse 暖 / Bind 紫 / Cut 珊瑚
# / Echo 青 / Wave 浅青 → 全部变浅灰但仍有"色相差"），HUD 反馈通道
# 不完全关闭，只是把"高饱和度 = 闪"降到低饱和度。GameState.health
# 铃铛 / ResonanceBar 主色 不变（这些不是 flash，只是常驻状态显示）。
# 用 ProgressBar.modulate 叠加（不替换 style.fill.bg_color，避免影响
# ProgressBar 已有 StyleBoxFlat 子资源，modulate 与 fill style 是
# Godot 4 渲染链中相乘关系，对玩家呈现"颜色被洗过一遍"）。
#
# T206 (#123) — accessibility reduce_flash 范围扩展：除 5 verb
# cooldown bar 之外，HUD 顶部 2 个最显眼的常驻颜色块（ResonanceBar
# 主色 + HealthContainer 4 bell）也参与 reduce_flash 灰化。ResonanceBar
# 是 Glass Cyan #69C7CE 主色（主资源条 80x6 px），HealthContainer
# 是 4 个 Glass Cyan/Muted Violet bell（生命条 14x16 px each）。玩家
# 勾选「减弱屏幕闪烁」时整个 HUD 顶部 color blob 区域（5 verb bar +
# resonance + health）一致降饱和度，视觉刺激源从 7 个降到 0 个。
# T200 时 rationale 是"常驻/瞬时二分 = constant state 不灰化"，T206
# 升级 rationale：accessibility 偏好应当覆盖玩家感知的"全部高饱和
# 度 UI blob"——14x16 满血 bell 每帧 0.5px 玻璃青高光与 5 verb 冷却
# 条同等刺激源，累加效应 = "我刚勾 reduce_flash 但屏幕还是闪"。
# 实现：iteration list 从 5 元素扩到 7 元素（5 verb bar + _resonance_bar
# + _health_container）。_health_container 是 HBoxContainer parent，
# modulate 继承到所有动态子 ColorRect bell（4 满血 + 0-3 空血），
# 1 次 modulate 写 = 全部 bell 灰化，比"逐 bell 写"更省 + 0 重复。
# 5 verb name label（T204）/ 5 verb cooldown "冷却中" label（T202）
# 主题色不变——文字通道保留色域分工 + 已是 alpha 0.6 半透，不需再灰。
const _REDUCED_COLOR_MODULATE := Color(0.55, 0.55, 0.6, 0.75)
const _NORMAL_COLOR_MODULATE := Color(1.0, 1.0, 1.0, 1.0)
var _reduced_flash_applied: bool = false

func _ready() -> void:
	add_to_group("hud")
	GameState.health_changed.connect(_on_health_changed)
	GameState.resonance_changed.connect(_on_resonance_changed)
	GameState.shards_changed.connect(_on_shards_changed)

	# Find player abilities
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player:
		_pulse_ability = player.get_node_or_null("PulseAbility")
		_bind_ability = player.get_node_or_null("BindAbility")
		_cut_ability = player.get_node_or_null("CutAbility")
		_echo_ability = player.get_node_or_null("EchoAbility")
		# T103 — 第五动词 Wave 群体波（cooldown 6s = 5 verb 中最贵）
		_wave_ability = player.get_node_or_null("ResonanceWaveAbility")

	# Initialize display
	_on_health_changed(GameState.health, GameState.max_health)
	_on_resonance_changed(GameState.resonance, GameState.max_resonance)
	_on_shards_changed(GameState.shards)

	_repair_hint.visible = false
	_repair_hint.modulate = Color("#F2B66E")

func _process(delta: float) -> void:
	if _pulse_ability and _pulse_ability.has_method("get_cooldown_ratio"):
		var ratio := _pulse_ability.get_cooldown_ratio() as float
		_pulse_cooldown.value = (1.0 - ratio) * 100.0
		# T202 (#118) — 5 verb 冷却中提示：cooldown ratio > 0 时显示
		# "冷却中" 标签。ratio = 0（verb 可用）时隐藏。cooldown 刚
		# 结束的 1 帧（ratio 由正到 0）也走 _update_cooldown_labels
		# 集中处理，保持 progress bar 数值与 label 可见性同步。
		_update_cooldown_label(_pulse_cooldown_label, ratio)

	if _bind_ability and _bind_ability.has_method("get_cooldown_ratio"):
		var ratio := _bind_ability.get_cooldown_ratio() as float
		_bind_cooldown.value = (1.0 - ratio) * 100.0
		_update_cooldown_label(_bind_cooldown_label, ratio)

	if _cut_ability and _cut_ability.has_method("get_cooldown_ratio"):
		var ratio := _cut_ability.get_cooldown_ratio() as float
		_cut_cooldown.value = (1.0 - ratio) * 100.0
		_update_cooldown_label(_cut_cooldown_label, ratio)

	if _echo_ability and _echo_ability.has_method("get_cooldown_ratio"):
		var ratio := _echo_ability.get_cooldown_ratio() as float
		_echo_cooldown.value = (1.0 - ratio) * 100.0
		_update_cooldown_label(_echo_cooldown_label, ratio)

	# T103 — 第五动词 Wave cooldown 实时刷新。_wave_ability 可能为 null
	# （headless 测试 / 玩家尚未生成），has_method 守卫。
	if _wave_ability and _wave_ability.has_method("get_cooldown_ratio"):
		var ratio := _wave_ability.get_cooldown_ratio() as float
		_wave_cooldown.value = (1.0 - ratio) * 100.0
		_update_cooldown_label(_wave_cooldown_label, ratio)

	# T200 (#117) — accessibility reduce_flash 5 verb bar 灰化。
	# 玩家在 settings 勾选「减弱屏幕闪烁」后，5 verb cooldown bar
	# (Pulse/Bind/Cut/Echo/Wave) 转为 desaturated 0.55 灰度 75% 透明。
	# 用 _reduced_flash_applied 缓存当前态避免每帧重设 modulate
	# (5 bar × 60Hz = 300 次/秒 modulate 写入 浪费)。仅在切换
	# 状态时 (true→false / false→true) 调一次 _apply_reduced_flash_modulate。
	# ScreenShake autoload 可能不存在 (headless test 场景), has_method
	# 守卫; 不存在时按正常态走 (5 bar 全 modulate=white, 与 reduce_flash
	# = false 视觉一致, 不会误伤测试)。
	var reduce_flash_active: bool = false
	if _has_screen_shake():
		reduce_flash_active = bool(ScreenShake.is_reduce_flash())
	if reduce_flash_active != _reduced_flash_applied:
		_reduced_flash_applied = reduce_flash_active
		_apply_reduced_flash_modulate(reduce_flash_active)

	if _repair_hint.visible:
		_repair_hint_timer -= delta
		var alpha := clampf(_repair_hint_timer / 0.5, 0.0, 1.0)
		_repair_hint.modulate.a = alpha
		if _repair_hint_timer <= 0:
			_repair_hint.visible = false

# T200 (#117) — ScreenShake autoload 存在性检查 helper。get_tree().root
# .get_node_or_null 比 Engine.has_singleton 更稳, 因为 autoload 是
# SceneTree 注册的, 不是 Engine singleton。
func _has_screen_shake() -> bool:
	if get_tree() == null:
		return false
	return get_tree().root.has_node("ScreenShake")

# T200 (#117) — apply/clear 5 verb cooldown bar desaturated modulate。
# 一次性遍历 5 bar 设/清 modulate, 后续无 cost (每帧只在状态切换
# 那一刻调一次)。reduce=true → 0.55/0.55/0.6/0.75 灰阶 (alpha 75%
# 让背景透过一些); reduce=false → 1/1/1/1 还原全色。
#
# T206 (#123) — iteration list 扩展：5 verb bar 之外加 _resonance_bar
# (ProgressBar 80x6 Glass Cyan 主色) + _health_container (HBoxContainer
# parent of 4 dynamic ColorRect bell) 共 7 元素。_health_container.modulate
# 继承到所有动态子 bell (1 写 = 全部 bell 灰化)。reduce=true 时 7
# UI 元素全部 _REDUCED_COLOR_MODULATE (0.55 灰 + 0.75 alpha); 
# reduce=false 时 7 UI 元素全部 _NORMAL_COLOR_MODULATE (1,1,1,1 还原)。
# 状态切换守卫沿用 T200 _reduced_flash_applied, 切换 1 次 = 7
# element 写, 之后无 per-frame cost。7 element 写 = 7 ProgressBar/
# Container .modulate 属性赋值, O(1) 静态开销, 0 allocation。
func _apply_reduced_flash_modulate(reduce: bool) -> void:
	var target_color: Color = _REDUCED_COLOR_MODULATE if reduce else _NORMAL_COLOR_MODULATE
	# T206 (#123) — 5 verb cooldown bar (T200) + _resonance_bar +
	# _health_container 共 7 UI 元素. _health_container.modulate 继承
	# 到所有动态 ColorRect bell (满血 Glass Cyan + 空血 Muted Violet),
	# 1 次写 = 全部 bell 灰化.
	for ui_elem in [_pulse_cooldown, _bind_cooldown, _cut_cooldown, _echo_cooldown, _wave_cooldown, _resonance_bar, _health_container]:
		if ui_elem and is_instance_valid(ui_elem):
			ui_elem.modulate = target_color

# T202 (#118) — 单个 verb 冷却中标签显示切换。ratio > 0 时显示（cooldown
# 中），ratio == 0 时隐藏（verb 可用）。label.visible 写比 modulate.a
# = 0 节省每帧渲染开销，Godot 4 渲染时不可见节点完全跳过 draw call。
# ratio > 0 阈值 0.001 避免浮点误差让 0.0000001 ratio 误显示
# (VerbAbilityBase.get_cooldown_ratio() 走 clampf [0,1], 但安全起
# 见仍加阈值)。null 守卫防御 _onready 时序竞态（headless 测试）。
func _update_cooldown_label(label: Label, ratio: float) -> void:
	if label == null:
		return
	var should_show: bool = ratio > 0.001
	if label.visible != should_show:
		label.visible = should_show

func _on_health_changed(new_health: int, max_health: int) -> void:
	# Clear and rebuild health bells
	for child in _health_container.get_children():
		child.queue_free()

	for i in range(max_health):
		var bell := ColorRect.new()
		bell.custom_minimum_size = health_bell_size
		bell.size = health_bell_size
		if i < new_health:
			bell.color = Color("#69C7CE")
		else:
			bell.color = Color("#65506A")
		_health_container.add_child(bell)

func _on_resonance_changed(new_resonance: int, max_resonance: int) -> void:
	if _resonance_bar:
		_resonance_bar.max_value = max_resonance
		_resonance_bar.value = new_resonance
	if _resonance_label:
		_resonance_label.text = "%d/%d" % [new_resonance, max_resonance]

func _on_shards_changed(new_count: int) -> void:
	if _shard_count:
		_shard_count.text = "◆ %d" % new_count

func show_repair_hint(text: String) -> void:
	if _repair_hint:
		_repair_hint.text = text
		_repair_hint.visible = true
		_repair_hint_timer = _repair_hint_max_time
		_repair_hint.modulate.a = 1.0

func show_pulse_blocked() -> void:
	show_repair_hint("共鸣不足")

# T147 (#77) — Jump 阻塞时给玩家提示。与 wave 4 状态路由 (#76 T143) 对称：
# jump 是 5 verb 之外玩家最常用的动作（移动核心），当 is_action_globally_blocked()
# 返回 true（死亡动画期 / Wave windup 期）时按 jump 应该是"被忽略"，
# 但玩家看不到原因会以为键失灵。提示让"按了没反应"立刻有归因。
# 文案与 show_pulse_blocked 共享"动作暂不可用"语义，但走独立方法
# 以保留 verb/jump 分开 i18n hook。
func show_jump_blocked() -> void:
	show_repair_hint("跳跃不可用")

# T143 (#76) — Wave 群体波有 4 种"无法施放"原因，对应 4 个不同提示。
# 之前所有 5 verb 失败都用 "共鸣不足" 一句话（4 verb 时代的简化），
# 但 Wave 是 5 verb 中唯一同时拥有"风蓄期 / 扩散期 / 长 cooldown" 的能力，
# 复用 "共鸣不足" 让玩家分不清"是没钱 / 还在准备 / 已经在扩散"。
# 拆为 3 个 verb 专属方法（charging / winding_up / active）+ 通用 blocked
# 共 4 个，按 wave_ability 状态路由：
#   - 共鸣不足 → show_wave_blocked()  (同 pulse)
#   - 6s cooldown 中 → show_wave_charging()  ("V 还在蓄势")
#   - 0.10s windup 中 → show_wave_winding_up()  ("V 正在准备")
#   - 0.40s 扩散中 → show_wave_active()  ("V 横扫中")
# 按 verb 路由便于将来扩展专属文案 / i18n / 调试。
func show_wave_blocked() -> void:
	# 共鸣不足 — 与 Pulse 共享同一句底层文案（5 verb cost 不同但提示是
	# 同一资源类），但走独立方法以保留 i18n hook。
	show_repair_hint("共鸣不足")

func show_wave_charging() -> void:
	# Cooldown 6s 期间提示 — 区别于共鸣不足（"再等一会"语义）。
	# "V" 是默认键，玩家可在 settings 重映射；提示文本保留动作名
	# "Wave" 避免依赖键名（玩家可能改了键）。
	show_repair_hint("Wave 还在蓄势")

func show_wave_winding_up() -> void:
	# 0.10s windup 期提示 — 玩家按 V 后到 wave 真正扩散前的极短窗口
	# （60Hz 下 = 6 帧）。这个提示实际很少见（人类按 V 后会立即看到
	# 圆环扩散），但保留方法以便 verb 路由对称（5 verb 都有 _blocked 钩子）。
	show_repair_hint("Wave 正在准备")

func show_wave_active() -> void:
	# 0.40s 扩散期提示 — 玩家按 V 触发 windup 结束、圆环开始扩散
	# 之后的窗口。该期间 wave_ability.can_wave() 返回 false（active
	# 期间禁止复按），失败原因不是 cooldown 也不是共鸣不足，而是
	# "波还没散完"。这一状态对玩家最有教育意义（告诉他们"我按了
	# 但没反应"是因为上一次波还在扫）。
	show_repair_hint("Wave 横扫中")
