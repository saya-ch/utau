class_name AbilityGate
extends StaticBody2D

signal opened
signal blocked_attempt

@export var required_ability: String = "bind"
@export var gate_color: Color = Color("#65506A")
@export var open_color: Color = Color("#69C7CE")
@export var block_hint: String = "需要 Bind 能力"

var _is_open: bool = false

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _hint_area: Area2D = $HintArea

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("ability_gate")
	_update_visual_state()
	
	if _hint_area:
		_hint_area.body_entered.connect(_on_hint_body_entered)

func on_pulse_triggered() -> void:
	_try_open()

func on_bind_triggered() -> void:
	_try_open()

func _try_open() -> void:
	if _is_open:
		return
	
	if GameState.has_ability(required_ability):
		_open()
	else:
		_blocked_attempt()

func _open() -> void:
	_is_open = true
	opened.emit()
	
	# Disable collision
	if _collision:
		_collision.disabled = true
	
	# Visual: fade to open color and shrink
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", open_color, 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.3, 0.5)
		tween.tween_property(_sprite, "scale", Vector2(0.2, 0.2), 0.5)
	
	# Spawn open VFX
	var vfx = preload("res://src/scripts/repair_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 24.0)
	
	# HUD hint
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("通道已开启")
	
	# Audio
	if AudioManagerEnhanced.has_method("play_repair_success"):
		AudioManagerEnhanced.play_repair_success()

func _blocked_attempt() -> void:
	blocked_attempt.emit()

	# Visual: brief shake
	if _sprite:
		var original_pos := _sprite.position
		var tween := create_tween()
		tween.tween_property(_sprite, "position", original_pos + Vector2(2, 0), 0.05)
		tween.tween_property(_sprite, "position", original_pos + Vector2(-2, 0), 0.05)
		tween.tween_property(_sprite, "position", original_pos, 0.05)

		# Flash coral warning
		tween.tween_property(_sprite, "modulate", Color("#E86D5A"), 0.1)
		tween.tween_property(_sprite, "modulate", gate_color, 0.2)

	# T089 — central screen shake so the player feels the gate's rejection
	ScreenShake.add(ScreenShake.BIND)
	
	# HUD hint
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint(block_hint)
	
	# Audio
	if AudioManagerEnhanced.has_method("play_damage"):
		AudioManagerEnhanced.play_damage()

func _update_visual_state() -> void:
	if _sprite:
		_sprite.modulate = gate_color

func _on_hint_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _is_open:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_repair_hint"):
			hud.show_repair_hint(block_hint)

func is_open() -> bool:
	return _is_open
