class_name HazardWater
extends Area2D

signal player_entered
signal player_exited

@export var damage_per_second: float = 1.0
@export var slow_factor: float = 0.5
@export var knockback_upward: float = -80.0

var _player_in_water: Node2D = null
var _damage_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if _player_in_water:
		_damage_timer += delta
		if _damage_timer >= 1.0:
			_damage_timer -= 1.0
			if _player_in_water.has_method("take_damage"):
				_player_in_water.take_damage(int(damage_per_second), Vector2(0, knockback_upward))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_water = body
		player_entered.emit()
		
		# Apply immediate knockback upward
		if body.has_method("take_damage"):
			body.take_damage(0, Vector2(0, knockback_upward))
		
		# Slow player movement
		if body.has_method("set_speed_multiplier"):
			body.set_speed_multiplier(slow_factor)

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_water:
		_player_in_water = null
		player_exited.emit()
		
		# Restore player speed
		if body.has_method("set_speed_multiplier"):
			body.set_speed_multiplier(1.0)

func repel(force: Vector2) -> void:
	# Water can be temporarily pushed back by Pulse
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "position:y", _sprite.position.y - 4, 0.2)
		tween.tween_property(_sprite, "position:y", _sprite.position.y, 0.5)
