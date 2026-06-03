class_name JsonRoom
extends Node2D

## A room that loads its content from a JSON configuration file at runtime.
## Attach this script to a Node2D in a scene, set `room_id`, and it will
## build the entire room automatically via RoomLoader.

@export var room_id: String = "archive_01"

var _loader: RoomLoader

func _ready() -> void:
	_loader = RoomLoader.new()
	add_child(_loader)
	var rc := _loader.load_room(room_id, self)
	if rc == null:
		push_error("JsonRoom: failed to load room '%s'" % room_id)
