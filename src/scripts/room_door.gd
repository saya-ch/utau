class_name RoomDoor
extends Area2D

signal player_entered(target_room_path: String)

@export var target_room_path: String = ""
@export var target_spawn_point: Vector2 = Vector2(60, 180)
@export var door_color: Color = Color("#69C7CE")

var _is_open: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("room_door")
	body_entered.connect(_on_body_entered)
	_close()

func open() -> void:
	_is_open = true
	if _collision:
		_collision.disabled = false
	if _sprite:
		var tween := create_tween()
		_tween_open_visuals(tween)

func _close() -> void:
	_is_open = false
	if _collision:
		_collision.disabled = true
	if _sprite:
		_sprite.modulate = Color("#081426")
		_sprite.modulate.a = 0.3

func _tween_open_visuals(tween: Tween) -> void:
	_sprite.modulate = Color("#69C7CE")
	_sprite.modulate.a = 0.3
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.5)
	tween.tween_property(_sprite, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(_sprite, "scale", Vector2(1.0, 1.0), 0.3)
	# Subtle pulse loop
	tween.set_loops()
	tween.tween_property(_sprite, "modulate:a", 0.6, 0.8)
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.8)

func _on_body_entered(body: Node2D) -> void:
	if not _is_open:
		return
	if body.is_in_group("player"):
		player_entered.emit(target_room_path)
