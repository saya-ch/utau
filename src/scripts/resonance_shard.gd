class_name ResonanceShard
extends Area2D

const _RepairVFXScript := preload("res://src/scripts/repair_vfx.gd")

@export var attract_speed: float = 120.0
@export var attract_range: float = 48.0
@export var collect_range: float = 8.0
@export var lifetime: float = 10.0
@export var fade_start_time: float = 7.0
@export var gravity_force: float = 300.0
@export var bounce_damping: float = 0.5
@export var initial_velocity: Vector2 = Vector2.ZERO
@export var shard_value: int = 1

var _velocity: Vector2 = Vector2.ZERO
var _is_collected: bool = false
var _is_attracting: bool = false
var _life_timer: float = 0.0
var _player_ref: Node2D = null

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("resonance_shards")
	body_entered.connect(_on_body_entered)
	
	_velocity = initial_velocity
	
	# Try to load shard texture
	var tex := load("res://assets/sprites/pulse_icon.png") as Texture2D
	if tex and _sprite:
		_sprite.texture = tex
		_sprite.modulate = Color("#F2B66E")
		_sprite.scale = Vector2(0.4, 0.4)

func _physics_process(delta: float) -> void:
	if _is_collected:
		return
	
	_life_timer += delta
	
	# Lifetime fade out
	if _life_timer >= lifetime:
		_collect()
		return
	elif _life_timer >= fade_start_time:
		if _sprite:
			var fade_t := (_life_timer - fade_start_time) / (lifetime - fade_start_time)
			_sprite.modulate.a = 1.0 - fade_t
	
	# Find player
	_update_player_ref()
	
	if _player_ref and _is_attracting:
		# Move toward player
		var dir := (_player_ref.global_position - global_position).normalized()
		global_position += dir * attract_speed * delta
		
		if global_position.distance_to(_player_ref.global_position) <= collect_range:
			_collect()
			return
	else:
		# Physics simulation
		_velocity.y += gravity_force * delta
		global_position += _velocity * delta
		
		# Check floor collision (simple raycast-like check)
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + Vector2(0, 4),
			0b00001  # World layer
		)
		var result := space_state.intersect_ray(query)
		if result:
			_velocity.y = -_velocity.y * bounce_damping
			_velocity.x *= 0.8
			global_position.y = result["position"].y - 2

func _update_player_ref() -> void:
	if _player_ref == null or not is_instance_valid(_player_ref):
		var tree := get_tree()
		if tree:
			_player_ref = tree.get_first_node_in_group("player") as Node2D
	
	if _player_ref:
		var dist := global_position.distance_to(_player_ref.global_position)
		_is_attracting = dist <= attract_range

func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	if _is_collected:
		return
	_is_collected = true
	
	GameState.add_shards(shard_value)
	
	# HUD feedback
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("+%d◆" % shard_value)
	
	# Collect VFX
	var vfx := _RepairVFXScript.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 12.0)
	
	queue_free()

func launch(velocity: Vector2) -> void:
	_velocity = velocity
