class_name NoteProjectile
extends Area2D

const _RepairVFXScript := preload("res://src/scripts/repair_vfx.gd")

## T096 — Registered into the `enemy_projectiles` group on _ready (line 16).
## EchoAbility._perform_shield_check walks this group every frame to find
## projectiles inside the shield radius and reflect them 180° back at the
## shooter.  Any new enemy projectile (e.g. a future InkWarden tri-burst
## sub-projectile, a hub mini-game, etc.) MUST call add_to_group("enemy_projectiles")
## here or in its own _ready — otherwise Echo won't know it exists and the
## reflection will silently skip it.  See CHANGELOG #51 I002 for the
## original triage note and CHANGELOG #52 for the verification.

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 60.0
@export var lifetime: float = 4.0
@export var damage: int = 1

var _life_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Group registration is the contract that EchoAbility relies on.  See
	# the class docstring above for the gameplay reason; do not remove.
	add_to_group("enemy_projectiles")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
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

func _on_area_entered(area: Area2D) -> void:
	# Destroyed by Pulse
	if area.is_in_group("pulse_hitbox"):
		# Spawn small VFX
		var vfx := _RepairVFXScript.new()
		get_tree().current_scene.add_child(vfx)
		vfx.trigger(global_position, 8.0)
		queue_free()
