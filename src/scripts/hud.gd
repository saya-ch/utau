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
@onready var _repair_hint: Label = $MarginContainer/VBoxContainer/RepairHint
@onready var _shard_count: Label = $MarginContainer/VBoxContainer/ShardRow/ShardCount

var _pulse_ability = null
var _bind_ability = null
var _cut_ability = null
var _echo_ability = null
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
		# T094 — Echo 第四动词 HUD 接入
		_echo_ability = player.get_node_or_null("EchoAbility")

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

	# T094 — Echo 第四动词 HUD 冷却条；4 个 cooldown 一起渲染保持
	# 视觉对齐（Cyan / Violet / Coral / Echo 双色 stripes）。
	if _echo_ability and _echo_ability.has_method("get_cooldown_ratio"):
		var ratio_e := _echo_ability.get_cooldown_ratio() as float
		_echo_cooldown.value = (1.0 - ratio_e) * 100.0
		# 护盾 ACTIVE 期间给一个"激活"色覆盖（更亮的 Glass Cyan），
		# 视觉上与 CD 中（暗 Glass Cyan）区分
		if _echo_ability.has_method("is_shield_active") and _echo_ability.is_shield_active():
			_echo_cooldown.modulate = Color(1.4, 1.4, 1.4, 1.0)
		elif _echo_ability.has_method("is_winding_up") and _echo_ability.is_winding_up():
			_echo_cooldown.modulate = Color(1.2, 1.0, 0.85, 1.0)  # 暖色 wind-up
		else:
			_echo_cooldown.modulate = Color.WHITE

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
