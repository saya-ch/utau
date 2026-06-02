class_name NPC
extends Area2D

signal interacted(npc_id: String)

@export var npc_id: String = "archivist"
@export var npc_name: String = "档案管理员"
@export var portrait_texture: Texture2D = null
@export var interaction_radius: float = 24.0

var _can_interact: bool = false
var _player_in_range: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hint: Label = $InteractionHint

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if _collision:
		var shape := CircleShape2D.new()
		shape.radius = interaction_radius
		_collision.shape = shape
	
	if _hint:
		_hint.visible = false
		_hint.text = "按 E 交谈"
		_hint.modulate = Color("#B7E7DD")

func _input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("interact"):
		interacted.emit(npc_id)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		if _hint:
			_hint.visible = true
			var tween := create_tween()
			tween.tween_property(_hint, "modulate:a", 1.0, 0.2)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if _hint:
			var tween := create_tween()
			tween.tween_property(_hint, "modulate:a", 0.0, 0.2)
			tween.tween_callback(func() -> void: _hint.visible = false)
