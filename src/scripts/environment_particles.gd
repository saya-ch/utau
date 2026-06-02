class_name EnvironmentParticles
extends Node2D

@export var particle_type: ParticleType = ParticleType.DUST
@export var particle_count: int = 20
@export var spawn_area: Rect2 = Rect2(0, 0, 480, 270)
@export var active: bool = true

enum ParticleType { DUST, WATER_GLINT, AMBIENT_GLOW }

var _particles: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_spawn_particles()
	z_index = -1

func _spawn_particles() -> void:
	for i in range(particle_count):
		var p := _create_particle()
		_particles.append(p)

func _create_particle() -> Dictionary:
	var pos := Vector2(
		_rng.randf_range(spawn_area.position.x, spawn_area.end.x),
		_rng.randf_range(spawn_area.position.y, spawn_area.end.y)
	)
	
	match particle_type:
		ParticleType.DUST:
			return {
				"pos": pos,
				"vel": Vector2(_rng.randf_range(-2.0, 2.0), _rng.randf_range(-0.5, -2.0)),
				"life": _rng.randf_range(2.0, 5.0),
				"max_life": 0.0,
				"size": _rng.randf_range(0.5, 1.5),
				"alpha": _rng.randf_range(0.15, 0.35),
			}
		ParticleType.WATER_GLINT:
			return {
				"pos": pos,
				"vel": Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-0.2, 0.2)),
				"life": _rng.randf_range(1.5, 3.5),
				"max_life": 0.0,
				"size": _rng.randf_range(1.0, 2.5),
				"alpha": 0.0,
				"flash_speed": _rng.randf_range(2.0, 4.0),
				"flash_offset": _rng.randf_range(0.0, TAU),
			}
		ParticleType.AMBIENT_GLOW:
			return {
				"pos": pos,
				"vel": Vector2.ZERO,
				"life": _rng.randf_range(3.0, 6.0),
				"max_life": 0.0,
				"size": _rng.randf_range(2.0, 5.0),
				"alpha": _rng.randf_range(0.05, 0.15),
				"pulse_speed": _rng.randf_range(1.0, 2.5),
				"pulse_offset": _rng.randf_range(0.0, TAU),
			}
		_:
			return {}

func _process(delta: float) -> void:
	if not active:
		return
	
	for p in _particles:
		p["life"] -= delta
		p["pos"] += p["vel"] * delta
		
		if p["life"] <= 0:
			_reset_particle(p)
			continue
		
		# Wrap position within spawn area
		if p["pos"].x < spawn_area.position.x:
			p["pos"].x = spawn_area.end.x
		elif p["pos"].x > spawn_area.end.x:
			p["pos"].x = spawn_area.position.x
		if p["pos"].y < spawn_area.position.y:
			p["pos"].y = spawn_area.end.y
		elif p["pos"].y > spawn_area.end.y:
			p["pos"].y = spawn_area.position.y
	
	queue_redraw()

func _reset_particle(p: Dictionary) -> void:
	p["pos"] = Vector2(
		_rng.randf_range(spawn_area.position.x, spawn_area.end.x),
		_rng.randf_range(spawn_area.position.y, spawn_area.end.y)
	)
	p["life"] = _rng.randf_range(2.0, 5.0)
	
	match particle_type:
		ParticleType.DUST:
			p["vel"] = Vector2(_rng.randf_range(-2.0, 2.0), _rng.randf_range(-0.5, -2.0))
			p["alpha"] = _rng.randf_range(0.15, 0.35)
		ParticleType.WATER_GLINT:
			p["vel"] = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-0.2, 0.2))
			p["flash_offset"] = _rng.randf_range(0.0, TAU)
		ParticleType.AMBIENT_GLOW:
			p["pulse_offset"] = _rng.randf_range(0.0, TAU)

func _draw() -> void:
	if not active:
		return
	
	for p in _particles:
		var t := 1.0 - clampf(p["life"] / 5.0, 0.0, 1.0)
		var fade := 1.0 - t * t
		
		match particle_type:
			ParticleType.DUST:
				var col := Color("#B7E7DD")
				col.a = p["alpha"] * fade
				draw_circle(p["pos"], p["size"], col)
			
			ParticleType.WATER_GLINT:
				var time_sec := Time.get_time_dict_from_system()["second"]
				var flash := sin(float(time_sec) * p["flash_speed"] + p["flash_offset"])
				var intensity := (flash + 1.0) * 0.5
				var col := Color("#69C7CE")
				col.a = intensity * 0.4 * fade
				if intensity > 0.7:
					col = Color("#B7E7DD")
					col.a = intensity * 0.5 * fade
				draw_circle(p["pos"], p["size"] * (0.5 + intensity * 0.5), col)
			
			ParticleType.AMBIENT_GLOW:
				var time_sec := Time.get_time_dict_from_system()["second"]
				var pulse := sin(float(time_sec) * p["pulse_speed"] + p["pulse_offset"])
				var intensity := (pulse + 1.0) * 0.5
				var col := Color("#F2B66E")
				col.a = p["alpha"] * intensity * fade
				draw_circle(p["pos"], p["size"] * (0.8 + intensity * 0.4), col)
