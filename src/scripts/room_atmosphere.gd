class_name RoomAtmosphere
extends Node2D

## Two-stage ambient lighting controller for archive rooms.
##
## Stage 0 (default): cold base modulate matching flooded archive mood.
## Stage 1 (bell repair): 0.8s warm reflow toward an intermediate warm tone,
##                         signaling that the voice bell is whole again.
## Stage 2 (room complete): 2.0s full warm wash toward the final repaired tone,
##                          synced with room_completed signal.
##
## Listens for VoiceBell.repaired and RoomController.room_completed signals.
## Designed for archive_02 (T076). Set `enabled = false` to disable entirely.

@export var enabled: bool = true
@export var base_modulate: Color = Color("#5A6E80")  # Cold ink-teal grey
@export var bell_repaired_modulate: Color = Color("#FFCFA0")  # Warm amber, intermediate
@export var room_completed_modulate: Color = Color("#FFE8CC")  # Full warm parchment
@export var bell_repair_duration: float = 0.8
@export var room_complete_duration: float = 2.0

enum AtmosphereStage { BASE, BELL_REPAIRED, ROOM_COMPLETED }

var _stage: AtmosphereStage = AtmosphereStage.BASE
var _transition_timer: float = 0.0
var _transition_from: Color = Color.WHITE
var _transition_to: Color = Color.WHITE
var _transition_duration: float = 0.0
var _is_transitioning: bool = false
# Cached current modulate; shared between _process, _ready and _draw.
var _current_modulate_cache: Color = Color.WHITE

@onready var _background = null
@onready var _room_controller = null
@onready var _voice_bell = null

func _ready() -> void:
	z_index = -5

	if not enabled:
		return

	# Find background, room controller, and voice bell in the parent node
	var parent := get_parent()
	if parent:
		_background = parent.get_node_or_null("Background")
		_room_controller = parent.get_node_or_null("RoomController")
		_voice_bell = parent.get_node_or_null("VoiceBell")

	# Connect room_completed (full warm wash)
	if _room_controller and _room_controller.has_signal("room_completed"):
		_room_controller.room_completed.connect(_on_room_completed)

	# Connect voice bell repaired (0.8s warm reflow)
	if _voice_bell and _voice_bell.has_signal("repaired"):
		_voice_bell.repaired.connect(_on_voice_bell_repaired)

	_current_modulate_cache = base_modulate
	_apply_to_background()

func _on_voice_bell_repaired() -> void:
	# Stage 1: 0.8s warm reflow toward bell_repaired_modulate
	if _stage == AtmosphereStage.ROOM_COMPLETED:
		return  # already at final stage
	_begin_transition(AtmosphereStage.BELL_REPAIRED, bell_repair_duration)

func _on_room_completed() -> void:
	# Stage 2: 2s full warm wash toward room_completed_modulate
	_begin_transition(AtmosphereStage.ROOM_COMPLETED, room_complete_duration)

func _begin_transition(target_stage: AtmosphereStage, duration: float) -> void:
	_stage = target_stage
	_transition_from = _current_modulate_cache
	_transition_to = _get_target_modulate(target_stage)
	_transition_duration = maxf(duration, 0.01)
	_transition_timer = 0.0
	_is_transitioning = true

func _get_target_modulate(stage: AtmosphereStage) -> Color:
	match stage:
		AtmosphereStage.BELL_REPAIRED:
			return bell_repaired_modulate
		AtmosphereStage.ROOM_COMPLETED:
			return room_completed_modulate
		_:
			return base_modulate

func _process(delta: float) -> void:
	if not enabled or not _is_transitioning:
		return

	_transition_timer += delta
	var t := clampf(_transition_timer / _transition_duration, 0.0, 1.0)
	# Ease-out cubic for warm light reflows
	t = 1.0 - pow(1.0 - t, 3.0)
	_current_modulate_cache = _transition_from.lerp(_transition_to, t)
	_apply_to_background()

	if _transition_timer >= _transition_duration:
		_is_transitioning = false
		_current_modulate_cache = _transition_to
		_apply_to_background()

func _apply_to_background() -> void:
	if _background and _background is CanvasItem:
		(_background as CanvasItem).modulate = _current_modulate_cache

func _draw() -> void:
	if not enabled:
		return
	# Subtle full-screen tint that intensifies as the room is repaired.
	# Stage 0 = nearly transparent cold overlay.
	# Stage 1/2 = faint warm wash to suggest ambient lighting.
	var col := _current_modulate_cache
	match _stage:
		AtmosphereStage.BASE:
			col.a = 0.06
		AtmosphereStage.BELL_REPAIRED:
			col.a = 0.10
		AtmosphereStage.ROOM_COMPLETED:
			col.a = 0.12
	draw_rect(Rect2(-100, -100, 680, 470), col)
