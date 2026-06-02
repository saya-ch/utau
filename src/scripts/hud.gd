class_name HUD
extends CanvasLayer

@export var health_bell_size: Vector2 = Vector2(14, 16)
@export var bar_width: float = 80.0
@export var bar_height: float = 6.0

@onready var _health_container: HBoxContainer = $MarginContainer/VBoxContainer/HealthRow/HealthContainer
@onready var _resonance_bar: ProgressBar = $MarginContainer/VBoxContainer/ResonanceRow/ResonanceBar
@onready var _resonance_label: Label = $MarginContainer/VBoxContainer/ResonanceRow/ResonanceLabel
@onready var _pulse_cooldown: ProgressBar = $MarginContainer/VBoxContainer/PulseRow/PulseCooldown
@onready var _repair_hint: Label = $MarginContainer/VBoxContainer/RepairHint
@onready var _shard_count: Label = $MarginContainer/VBoxContainer/ShardRow/ShardCount

var _pulse_ability: PulseAbility = null
var _repair_hint_timer: float = 0.0
var _repair_hint_max_time: float = 2.0

func _ready() -> void:
	add_to_group("hud")
	GameState.health_changed.connect(_on_health_changed)
	GameState.resonance_changed.connect(_on_resonance_changed)
	GameState.shards_changed.connect(_on_shards_changed)

	# Find player pulse ability
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player:
		_pulse_ability = player.get_node_or_null("PulseAbility") as PulseAbility

	# Initialize display
	_on_health_changed(GameState.health, GameState.max_health)
	_on_resonance_changed(GameState.resonance, GameState.max_resonance)
	_on_shards_changed(GameState.shards)

	_repair_hint.visible = false
	_repair_hint.modulate = Color("#F2B66E")

func _process(delta: float) -> void:
	if _pulse_ability:
		var ratio := _pulse_ability.get_cooldown_ratio()
		_pulse_cooldown.value = (1.0 - ratio) * 100.0

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
