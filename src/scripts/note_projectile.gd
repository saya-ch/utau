class_name NoteProjectile
extends Area2D

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 60.0
@export var lifetime: float = 4.0
@export var damage: int = 1

var _life_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemy_projectiles")
	body_entered.connect(_on_body_entered)
	
	# Visual: small note shape
	if _sprite:
		_sprite.self_modulate = Color("#E86D5A")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_life_timer += delta
	
	if _life_timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, direction * 50.0)
		queue_free()

func destroy_by_pulse() -> void:
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 8.0)
	queue_free()
