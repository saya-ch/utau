extends Node2D

# T090 — Pure-visual environment decoration. Holds a sprite and an
# optional gentle idle motion (e.g. sway for reeds, drift for feathers).
# No physics, no collision, no gameplay interaction. Sits between
# background and gameplay layer (z_index = -2 by default so platforms
# and enemies draw on top).
#
# Decoration kinds live in `assets/sprites/decorations/`. Adding a new
# kind is a 3-line change: extend the dict, drop a 32x32 PNG, optional
# `idle_motion` registration.

@export var decoration_kind: String = "archive_reed"  # archive_reed | glass_shards | voice_feather | archive_vine
@export var sway_amplitude: float = 0.0  # pixels, set non-zero for idle sway
@export var sway_period: float = 2.4     # seconds per cycle
@export var drift_y: float = 0.0         # pixels/sec vertical drift (e.g. floating feather)

const TEXTURE_PATHS := {
	"archive_reed": "res://assets/sprites/decorations/archive_reed.png",
	"glass_shards": "res://assets/sprites/decorations/glass_shards.png",
	"voice_feather": "res://assets/sprites/decorations/voice_feather.png",
	"archive_vine": "res://assets/sprites/decorations/archive_vine.png",
}

var _sprite: Sprite2D
var _base_position: Vector2
var _time: float = 0.0

func _ready() -> void:
	_base_position = position
	_sprite = Sprite2D.new()
	var path: String = TEXTURE_PATHS.get(decoration_kind, "")
	if path != "":
		var tex := load(path) as Texture2D
		if tex:
			_sprite.texture = tex
	z_index = -2
	add_child(_sprite)

func _process(delta: float) -> void:
	_time += delta
	# Idle sway (left/right oscillation around the spawn point)
	if sway_amplitude > 0.0:
		var offset_x := sin(_time * TAU / sway_period) * sway_amplitude
		position.x = _base_position.x + offset_x
	# Vertical drift (e.g. feather falling slowly)
	if drift_y != 0.0:
		_base_position.y += drift_y * delta
		position.y = _base_position.y
