class_name RoomDoor
extends Area2D

## A door trigger that, when enabled, lets the player walk through it to enter
## the next room. The "open" name is intentionally avoided because the door
## keeps its visual "closed" sprite — only the trigger collision is enabled or
## disabled. Use `enable_trigger()` to allow the player to enter and
## `disable_trigger()` to block passage.

signal player_entered(target_room_path: String)

@export var target_room_path: String = ""
@export var target_spawn_point: Vector2 = Vector2(60, 180)
@export var door_color: Color = Color("#69C7CE")

# True when the trigger collision is active (i.e. the player can enter).
var _is_trigger_enabled: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("room_door")
	body_entered.connect(_on_body_entered)
	disable_trigger()

## Returns true when the player-enter trigger is currently active
## (i.e. `enable_trigger()` was called and not yet `disable_trigger()`'d).
func is_trigger_enabled() -> bool:
	return _is_trigger_enabled

## Activate the player-enter trigger collision and start the open visual
## animation. Does NOT change the door's visual "closed/open" state in a
## physical sense — the sprite remains in place; we only allow the player
## to pass through.
func enable_trigger() -> void:
	_is_trigger_enabled = true
	if _collision:
		_collision.disabled = false
	if _sprite:
		var tween := create_tween()
		_tween_open_visuals(tween)

## Deactivate the player-enter trigger collision and reset the door sprite
## to its dim "closed" appearance.
func disable_trigger() -> void:
	_is_trigger_enabled = false
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
	if not _is_trigger_enabled:
		return
	if body.is_in_group("player"):
		player_entered.emit(target_room_path)
