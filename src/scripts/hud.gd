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
# T202 (#118) — 5 verb 半透明 "冷却中" 提示 label. 每个 verb 一个,
# 在 verb 处于冷却 (ratio > 0) 时可见, 准备就绪 (ratio == 0) 时隐藏.
# 共享同一 modulate 0.5 alpha (半透明白字), accessibility / readability
# 提升: 玩家一眼看出 "哪个 verb 还在冷却 / 哪个已就绪" 而无需盯
# bar 读比例. 与 _REDUCED_COLOR_MODULATE (T200/T203 bar 灰化) 独立:
# bar 颜色降低饱和度后 "冷却中" label 仍清晰可读 (label 是 modulate
# white 0.5 alpha, 不受 ProgressBar modulate 影响 — label 是 sibling
# not child of bar).
@onready var _pulse_cooldown_label: Label = $MarginContainer/VBoxContainer/PulseRow/PulseCooldownLabel
@onready var _bind_cooldown_label: Label = $MarginContainer/VBoxContainer/BindRow/BindCooldownLabel
@onready var _cut_cooldown_label: Label = $MarginContainer/VBoxContainer/CutRow/CutCooldownLabel
@onready var _echo_cooldown_label: Label = $MarginContainer/VBoxContainer/EchoRow/EchoCooldownLabel
@onready var _wave_cooldown_label: Label = $MarginContainer/VBoxContainer/WaveRow/WaveCooldownLabel
@onready var _repair_hint: Label = $MarginContainer/VBoxContainer/RepairHint
@onready var _shard_count: Label = $MarginContainer/VBoxContainer/ShardRow/ShardCount

var _pulse_ability = null
var _bind_ability = null
var _cut_ability = null
var _echo_ability = null
var _wave_ability = null
var _repair_hint_timer: float = 0.0
var _repair_hint_max_time: float = 2.0

# T200 (#117) + T203 (#118) — accessibility 5 verb cooldown bar 灰化.
# T200 原本把此视觉绑定到 is_reduce_flash() (T195 屏幕闪烁偏好),
# T203 (#118) 拆出独立 4 滑块 — 玩家在 settings 勾选「减弱冷却条
# 颜色」后, hud.gd _process() 查 is_reduce_cooldown_color() 为 true,
# 5 verb cooldown bar (Pulse / Bind / Cut / Echo / Wave) 转为
# desaturated 0.55 灰阶 75% 透明. 颜色仍存在但饱和度降到 30% 上下,
# "5 verb 色域分工" (Pulse 暖 / Bind 紫 / Cut 珊瑚 / Echo 青 / Wave
# 浅青) 在 HUD 反馈偏好下不再刺眼, 5 bar 仍可一眼区分 (色相差保留).
# HUD 反馈通道 不完全关闭, 只是把"高饱和度 = 闪"降到低饱和度.
# GameState.health 铃铛 / ResonanceBar 主色 不变 (这些不是 cooldown,
# 是常驻状态显示, 不属于 T203 范围). 用 ProgressBar.modulate 叠加
# (不替换 style.fill.bg_color, 避免影响 ProgressBar 已有 StyleBoxFlat
# 子资源; modulate 与 fill style 是 Godot 4 渲染链中相乘关系, 对玩
# 家呈现"颜色被洗过一遍"). 与 T200 区别: T203 让 reduce_flash 与
# reduce_cooldown_color 独立 (玩家可只想要 1 个: 比如 verb 命中闪还
# 要但常驻 HUD bar 灰化, 或反之).
const _REDUCED_COLOR_MODULATE := Color(0.55, 0.55, 0.6, 0.75)
const _NORMAL_COLOR_MODULATE := Color(1.0, 1.0, 1.0, 1.0)
var _reduced_cooldown_color_applied: bool = false

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
		# T202 (#118) — 半透明 "冷却中" 提示. 比例 > 0 显 label, = 0 隐.
		_pulse_cooldown_label.visible = ratio > 0.0

	if _bind_ability and _bind_ability.has_method("get_cooldown_ratio"):
		var ratio := _bind_ability.get_cooldown_ratio() as float
		_bind_cooldown.value = (1.0 - ratio) * 100.0
		_bind_cooldown_label.visible = ratio > 0.0

	if _cut_ability and _cut_ability.has_method("get_cooldown_ratio"):
		var ratio := _cut_ability.get_cooldown_ratio() as float
		_cut_cooldown.value = (1.0 - ratio) * 100.0
		_cut_cooldown_label.visible = ratio > 0.0

	if _echo_ability and _echo_ability.has_method("get_cooldown_ratio"):
		var ratio := _echo_ability.get_cooldown_ratio() as float
		_echo_cooldown.value = (1.0 - ratio) * 100.0
		_echo_cooldown_label.visible = ratio > 0.0

	# T103 — 第五动词 Wave cooldown 实时刷新。_wave_ability 可能为 null
	# （headless 测试 / 玩家尚未生成），has_method 守卫。
	if _wave_ability and _wave_ability.has_method("get_cooldown_ratio"):
		var ratio := _wave_ability.get_cooldown_ratio() as float
		_wave_cooldown.value = (1.0 - ratio) * 100.0
		_wave_cooldown_label.visible = ratio > 0.0

	# T200 (#117) + T203 (#118) — accessibility reduce_cooldown_color 5
	# verb bar 灰化. 玩家在 settings 勾选「减弱冷却条颜色」后, 5 verb
	# cooldown bar (Pulse/Bind/Cut/Echo/Wave) 转为 desaturated 0.55 灰
	# 阶 75% 透明. 用 _reduced_cooldown_color_applied 缓存当前态避免
	# 每帧重设 modulate (5 bar × 60Hz = 300 次/秒 modulate 写入浪费).
	# 仅在切换状态时 (true→false / false→true) 调一次
	# _apply_reduced_cooldown_color_modulate. ScreenShake autoload 可能
	# 不存在 (headless test 场景), has_method 守卫; 不存在时按正常态
	# 走 (5 bar 全 modulate=white, 与 reduce_cooldown_color = false 视
	# 觉一致, 不会误伤测试). T203 (#118) 与 T200 (#117) 区别: 本轮把
	# 视觉绑定从 is_reduce_flash() 切到 is_reduce_cooldown_color(), 玩
	# 家可分别控制 "屏幕闪" 和 "HUD 冷却条色饱和度".
	var reduce_cooldown_color_active: bool = false
	if _has_screen_shake():
		reduce_cooldown_color_active = bool(ScreenShake.is_reduce_cooldown_color())
	if reduce_cooldown_color_active != _reduced_cooldown_color_applied:
		_reduced_cooldown_color_applied = reduce_cooldown_color_active
		_apply_reduced_cooldown_color_modulate(reduce_cooldown_color_active)

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

# T200 (#117) + T203 (#118) — apply/clear 5 verb cooldown bar desaturated modulate.
# 一次性遍历 5 bar 设/清 modulate, 后续无 cost (每帧只在状态切换
# 那一刻调一次). reduce=true → 0.55/0.55/0.6/0.75 灰阶 (alpha 75%
# 让背景透过一些); reduce=false → 1/1/1/1 还原全色.
func _apply_reduced_cooldown_color_modulate(reduce: bool) -> void:
	var target_color: Color = _REDUCED_COLOR_MODULATE if reduce else _NORMAL_COLOR_MODULATE
	for bar in [_pulse_cooldown, _bind_cooldown, _cut_cooldown, _echo_cooldown, _wave_cooldown]:
		if bar and is_instance_valid(bar):
			bar.modulate = target_color

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
