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
@onready var _repair_hint: Label = $MarginContainer/VBoxContainer/RepairHint
@onready var _shard_count: Label = $MarginContainer/VBoxContainer/ShardRow/ShardCount

var _pulse_ability = null
var _bind_ability = null
var _cut_ability = null
var _echo_ability = null
var _wave_ability = null
var _repair_hint_timer: float = 0.0
var _repair_hint_max_time: float = 2.0

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
	
	if _bind_ability and _bind_ability.has_method("get_cooldown_ratio"):
		var ratio := _bind_ability.get_cooldown_ratio() as float
		_bind_cooldown.value = (1.0 - ratio) * 100.0

	if _cut_ability and _cut_ability.has_method("get_cooldown_ratio"):
		var ratio := _cut_ability.get_cooldown_ratio() as float
		_cut_cooldown.value = (1.0 - ratio) * 100.0

	if _echo_ability and _echo_ability.has_method("get_cooldown_ratio"):
		var ratio := _echo_ability.get_cooldown_ratio() as float
		_echo_cooldown.value = (1.0 - ratio) * 100.0

	# T103 — 第五动词 Wave cooldown 实时刷新。_wave_ability 可能为 null
	# （headless 测试 / 玩家尚未生成），has_method 守卫。
	if _wave_ability and _wave_ability.has_method("get_cooldown_ratio"):
		var ratio := _wave_ability.get_cooldown_ratio() as float
		_wave_cooldown.value = (1.0 - ratio) * 100.0

	if _repair_hint.visible:
		_repair_hint_timer -= delta
		var alpha := clampf(_repair_hint_timer / 0.5, 0.0, 1.0)
		_repair_hint.modulate.a = alpha
		if _repair_hint_timer <= 0:
			_repair_hint.visible = false

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
