class_name RoomAtmosphere
extends Node2D

@export var base_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var repaired_modulate: Color = Color("#FFE8CC")
@export var transition_duration: float = 2.0

var _is_repaired: bool = false
var _transition_timer: float = 0.0
var _current_modulate: Color = Color.WHITE

@onready var _background: Sprite2D
@onready var _room_controller: RoomController

func _ready() -> void:
	z_index = -5
	
	# Find background and room controller
	var parent := get_parent()
	if parent:
		_background = parent.get_node_or_null("Background") as Sprite2D
		_room_controller = parent.get_node_or_null("RoomController") as RoomController
	
	if _room_controller:
		_room_controller.room_completed.connect(_on_room_completed)
	
	_current_modulate = base_modulate

func _on_room_completed() -> void:
	_is_repaired = true
	_transition_timer = 0.0

func _process(delta: float) -> void:
	if _is_repaired and _transition_timer < transition_duration:
		_transition_timer += delta
		var t := clampf(_transition_timer / transition_duration, 0.0, 1.0)
		# Ease out cubic
		t = 1.0 - pow(1.0 - t, 3.0)
		_current_modulate = base_modulate.lerp(repaired_modulate, t)
		queue_redraw()
		
		# Also modulate background
		if _background:
			_background.modulate = _current_modulate

func _draw() -> void:
	# Draw a full-screen color overlay that shifts with repair state
	var col := _current_modulate
	col.a = 0.15 * (1.0 - clampf(_transition_timer / transition_duration, 0.0, 1.0))
	if _is_repaired:
		col.a = 0.08
		draw_rect(Rect2(-100, -100, 680, 470), col)
