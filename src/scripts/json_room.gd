class_name JsonRoom
extends Node2D

## A room that loads its content from a JSON configuration file at runtime.
## Attach this script to a Node2D in a scene, set `room_id`, and it will
## build the entire room automatically via RoomLoader.

@export var room_id: String = "archive_01"

var _loader: RoomLoader

func _ready() -> void:
	# T184 (#102) — re-warm hit SFX on every JSON-loaded archive
	# room (archive_01..04) entry.  Mirrors RoomController._ready
	# T184 block — both classes mount archive rooms, so both
	# need the cache-hit re-warm to keep the verb audio chain
	# tight after long idle.  JsonRoom loads via RoomLoader
	# which spawns a RoomController internally; this hook fires
	# one frame earlier and acts as a defensive belt-and-braces
	# for any JSON room that somehow runs without a controller.
	# Headless-safe `has_method` pattern, mirror of #101 T183.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("prewarm_hit_sfx"):
		ame.call("prewarm_hit_sfx")

	_loader = RoomLoader.new()
	add_child(_loader)
	var rc := _loader.load_room(room_id, self)
	if rc == null:
		push_error("JsonRoom: failed to load room '%s'" % room_id)
