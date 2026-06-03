class_name RoomLoader
extends Node

## Loads a room from a JSON configuration file and instantiates all entities.
## This allows rooms to be designed in JSON rather than hand-editing .tscn files.

const ROOMS_DIR := "res://data/rooms/"

# Scene preload cache
var _scene_cache: Dictionary = {}

func _ready() -> void:
	_preload_scenes()

func _preload_scenes() -> void:
	_scene_cache["player"] = preload("res://src/scenes/player.tscn")
	_scene_cache["hud"] = preload("res://src/scenes/hud.tscn")
	_scene_cache["title_screen"] = preload("res://src/scenes/title_screen.tscn")
	_scene_cache["pause_menu"] = preload("res://src/scenes/pause_menu.tscn")
	_scene_cache["game_over_screen"] = preload("res://src/scenes/game_over_screen.tscn")
	_scene_cache["settings_menu"] = preload("res://src/scenes/settings_menu.tscn")
	_scene_cache["room_transition"] = preload("res://src/scenes/room_transition.tscn")
	_scene_cache["room_door"] = preload("res://src/scenes/room_door.tscn")
	_scene_cache["save_lantern"] = preload("res://src/scenes/save_lantern.tscn")
	_scene_cache["ability_gate"] = preload("res://src/scenes/ability_gate.tscn")
	_scene_cache["resonance_shard"] = preload("res://src/scenes/resonance_shard.tscn")
	_scene_cache["achievement_notification"] = preload("res://src/scenes/achievement_notification.tscn")
	_scene_cache["tutorial_hint"] = preload("res://src/scenes/tutorial_hint.tscn")

## Load a room JSON and build the scene tree under `parent`.
func load_room(room_id: String, parent: Node) -> RoomController:
	var json_path := ROOMS_DIR + room_id + ".json"
	var json_str := FileAccess.get_file_as_string(json_path)
	if json_str.is_empty():
		push_error("RoomLoader: could not read %s" % json_path)
		return null

	var json := JSON.new()
	var err := json.parse(json_str)
	if err != OK:
		push_error("RoomLoader: JSON parse error in %s: %s" % [json_path, json.get_error_message()])
		return null

	var data: Dictionary = json.data
	var room_controller := _build_room(data, parent)
	return room_controller

func _build_room(data: Dictionary, parent: Node) -> RoomController:
	var room_id: String = data.get("room_id", "unknown")
	var completion_shards: int = data.get("completion_shards", 3)

	# Background
	if data.has("background"):
		var bg := Sprite2D.new()
		bg.name = "Background"
		bg.position = _vec2(data["background"].get("position", [240, 135]))
		bg.texture = load(data["background"]["texture"]) as Texture2D
		bg.z_index = -10
		parent.add_child(bg)

	# Ground
	if data.has("ground"):
		var ground := StaticBody2D.new()
		ground.name = "Ground"
		ground.collision_layer = 1
		var shape := WorldBoundaryShape2D.new()
		var col := CollisionShape2D.new()
		col.position = _vec2(data["ground"].get("position", [240, 250]))
		col.shape = shape
		ground.add_child(col)
		parent.add_child(ground)

	# Platforms
	if data.has("platforms"):
		var platforms_parent := Node2D.new()
		platforms_parent.name = "Platforms"
		parent.add_child(platforms_parent)
		for i in range(data["platforms"].size()):
			var p_data: Dictionary = data["platforms"][i]
			var platform := _build_platform(p_data, i)
			platforms_parent.add_child(platform)

	# Hazards (water)
	if data.has("hazards"):
		for i in range(data["hazards"].size()):
			var h_data: Dictionary = data["hazards"][i]
			var hazard := _build_hazard(h_data, i)
			parent.add_child(hazard)

	# Enemies
	if data.has("enemies"):
		for i in range(data["enemies"].size()):
			var e_data: Dictionary = data["enemies"][i]
			var enemy := _build_enemy(e_data, i)
			if enemy:
				parent.add_child(enemy)

	# Interactables (glass_lock, voice_bell, ability_gate, save_lantern)
	if data.has("interactables"):
		for i in range(data["interactables"].size()):
			var int_data: Dictionary = data["interactables"][i]
			var interactable := _build_interactable(int_data, i)
			if interactable:
				parent.add_child(interactable)

	# Room door
	if data.has("room_door"):
		var door_scene: PackedScene = _scene_cache.get("room_door")
		if door_scene:
			var door: RoomDoor = door_scene.instantiate() as RoomDoor
			door.name = "RoomDoor"
			door.position = _vec2(data["room_door"].get("position", [470, 210]))
			door.target_room_path = data["room_door"].get("target_room_path", "")
			door.target_spawn_point = _vec2(data["room_door"].get("target_spawn_point", [60, 180]))
			door.door_id = data["room_door"].get("door_id", "")
			parent.add_child(door)

	# Player
	var player_scene: PackedScene = _scene_cache.get("player")
	var player: Node = null
	if player_scene:
		player = player_scene.instantiate()
		player.name = "Player"
		player.position = _vec2(data.get("player_spawn", [60, 180]))
		parent.add_child(player)

	# Camera
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	var cam_script := load("res://src/scripts/camera_follow.gd") as Script
	if cam_script:
		camera.set_script(cam_script)
		camera.set("target", NodePath("../Player"))
		camera.set("smoothing", 8.0)
		camera.set("look_ahead", 16.0)
		camera.set("vertical_offset", -8.0)
	camera.add_to_group("camera")
	parent.add_child(camera)

	# UI
	var hud_scene: PackedScene = _scene_cache.get("hud")
	if hud_scene:
		var hud = hud_scene.instantiate()
		hud.name = "HUD"
		parent.add_child(hud)

	var title_scene: PackedScene = _scene_cache.get("title_screen")
	if title_scene:
		var title = title_scene.instantiate()
		title.name = "TitleScreen"
		parent.add_child(title)

	var pause_scene: PackedScene = _scene_cache.get("pause_menu")
	if pause_scene:
		var pause = pause_scene.instantiate()
		pause.name = "PauseMenu"
		parent.add_child(pause)

	var over_scene: PackedScene = _scene_cache.get("game_over_screen")
	if over_scene:
		var over = over_scene.instantiate()
		over.name = "GameOverScreen"
		parent.add_child(over)

	var settings_scene: PackedScene = _scene_cache.get("settings_menu")
	if settings_scene:
		var settings = settings_scene.instantiate()
		settings.name = "SettingsMenu"
		parent.add_child(settings)

	var rt_scene: PackedScene = _scene_cache.get("room_transition")
	if rt_scene:
		var rt = rt_scene.instantiate()
		rt.name = "RoomTransition"
		parent.add_child(rt)

	# Achievement notification (always available so unlocked achievements
	# can be shown regardless of which room the player is in)
	var achv_scene: PackedScene = _scene_cache.get("achievement_notification")
	if achv_scene:
		var achv = achv_scene.instantiate()
		achv.name = "AchievementNotification"
		parent.add_child(achv)

	# Tutorial hints
	var tut_scene: PackedScene = _scene_cache.get("tutorial_hint")
	if tut_scene:
		var tut = tut_scene.instantiate()
		tut.name = "TutorialHint"
		parent.add_child(tut)

	# Room boundary walls
	var boundary := StaticBody2D.new()
	boundary.name = "RoomBoundary"
	boundary.collision_layer = 1
	parent.add_child(boundary)
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(80, 16)
	var left_wall := CollisionShape2D.new()
	left_wall.position = Vector2(-10, 135)
	left_wall.shape = wall_shape
	boundary.add_child(left_wall)
	var right_wall := CollisionShape2D.new()
	right_wall.position = Vector2(490, 135)
	right_wall.shape = wall_shape
	boundary.add_child(right_wall)
	var ceil_shape := RectangleShape2D.new()
	ceil_shape.size = Vector2(120, 24)
	var ceiling := CollisionShape2D.new()
	ceiling.position = Vector2(240, -10)
	ceiling.shape = ceil_shape
	boundary.add_child(ceiling)

	# RoomController
	var rc := RoomController.new()
	rc.name = "RoomController"
	rc.room_id = room_id
	rc.completion_shards = completion_shards
	# Tutorial hints from JSON
	if data.has("tutorial_hints"):
		rc.tutorial_hints = data["tutorial_hints"]
	parent.add_child(rc)

	# GameFlowController
	var gfc := GameFlowController.new()
	gfc.name = "GameFlowController"
	var flow_script := load("res://src/scripts/game_flow_controller.gd") as Script
	if flow_script:
		gfc.set_script(flow_script)
	parent.add_child(gfc)

	return rc

func _build_platform(data: Dictionary, index: int) -> StaticBody2D:
	var platform := StaticBody2D.new()
	platform.name = "Platform%d" % (index + 1)
	platform.position = _vec2(data.get("position", [0, 0]))
	platform.collision_layer = 1

	var size := _vec2(data.get("size", [80, 16]))
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	platform.add_child(col)

	var sprite := Sprite2D.new()
	sprite.self_modulate = Color(0.055, 0.2, 0.29, 1)
	sprite.scale = size
	var tex := load("res://assets/environment/archive_tileset_proxy.png") as Texture2D
	sprite.texture = tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 16, 16)
	platform.add_child(sprite)

	return platform

func _build_hazard(data: Dictionary, index: int) -> Area2D:
	var hazard := Area2D.new()
	hazard.name = "HazardWater%d" % (index + 1)
	hazard.position = _vec2(data.get("position", [0, 0]))
	hazard.collision_layer = 8
	hazard.collision_mask = 2
	var script := load("res://src/scripts/hazard_water.gd") as Script
	if script:
		hazard.set_script(script)

	var size := _vec2(data.get("size", [120, 24]))
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	hazard.add_child(col)

	var sprite := Sprite2D.new()
	sprite.self_modulate = Color(0.114, 0.396, 0.439, 0.6)
	sprite.scale = size
	var tex := load("res://assets/environment/archive_tileset_proxy.png") as Texture2D
	sprite.texture = tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(128, 128, 16, 16)
	hazard.add_child(sprite)

	return hazard

func _build_enemy(data: Dictionary, index: int) -> Node:
	var type: String = data.get("type", "silence_mote")
	var enemy: Node = null

	match type:
		"silence_mote":
			enemy = CharacterBody2D.new()
			enemy.name = "SilenceMote%d" % (index + 1)
			enemy.set_script(load("res://src/scripts/silence_mote.gd") as Script)
			_enemy_setup_common(enemy, data, 8.0)
			# SilenceMote specific defaults
			if data.has("patrol_speed"):
				enemy.set("patrol_speed", data["patrol_speed"])
			if data.has("patrol_range"):
				enemy.set("patrol_range", data["patrol_range"])
			if data.has("chase_speed"):
				enemy.set("chase_speed", data["chase_speed"])
			if data.has("chase_range"):
				enemy.set("chase_range", data["chase_range"])
			if data.has("health"):
				enemy.set("health", data["health"])
			# Sprite
			var sprite := Sprite2D.new()
			var tex := load("res://assets/sprites/silence_mote_normal.png") as Texture2D
			if tex:
				sprite.texture = tex
			enemy.add_child(sprite)
			# WarnIndicator
			var warn := Node2D.new()
			warn.name = "WarnIndicator"
			warn.visible = false
			enemy.add_child(warn)
		"note_wisp":
			enemy = CharacterBody2D.new()
			enemy.name = "NoteWisp%d" % (index + 1)
			enemy.set_script(load("res://src/scripts/note_wisp.gd") as Script)
			_enemy_setup_common(enemy, data, 8.0)
			if data.has("move_amplitude"):
				enemy.set("move_amplitude", data["move_amplitude"])
			if data.has("move_frequency"):
				enemy.set("move_frequency", data["move_frequency"])
			if data.has("health"):
				enemy.set("health", data["health"])
			var sprite := Sprite2D.new()
			sprite.self_modulate = Color(0.91, 0.43, 0.35, 1)
			sprite.scale = Vector2(0.8, 0.8)
			var tex := load("res://assets/environment/archive_tileset_proxy.png") as Texture2D
			if tex:
				sprite.texture = tex
				sprite.region_enabled = true
				sprite.region_rect = Rect2(64, 64, 16, 16)
			enemy.add_child(sprite)
		"ink_warden":
			var scene: PackedScene = load("res://src/scenes/ink_warden.tscn") as PackedScene
			if scene:
				enemy = scene.instantiate()
				enemy.name = "InkWarden%d" % (index + 1)
				if data.has("position"):
					enemy.position = _vec2(data["position"])
				if data.has("health"):
					enemy.set("health", data["health"])
				if data.has("shield_health"):
					enemy.set("shield_health", data["shield_health"])
		_:
			push_warning("RoomLoader: unknown enemy type '%s'" % type)
			return null

	return enemy

func _enemy_setup_common(enemy: Node, data: Dictionary, radius: float) -> void:
	enemy.collision_layer = 4
	enemy.collision_mask = 3
	if data.has("position"):
		enemy.position = _vec2(data["position"])

	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	enemy.add_child(col)

	var hurtbox := Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 4
	hurtbox.collision_mask = 2
	var hurt_shape := RectangleShape2D.new()
	hurt_shape.size = Vector2(20, 20)
	var hurt_col := CollisionShape2D.new()
	hurt_col.shape = hurt_shape
	hurtbox.add_child(hurt_col)
	enemy.add_child(hurtbox)

func _build_interactable(data: Dictionary, index: int) -> Node:
	var type: String = data.get("type", "glass_lock")
	var node: Node = null

	match type:
		"glass_lock":
			node = StaticBody2D.new()
			node.name = "GlassLock"
			node.set_script(load("res://src/scripts/glass_lock.gd") as Script)
			node.collision_layer = 16
			node.collision_mask = 0
			if data.has("position"):
				node.position = _vec2(data["position"])
			if data.has("repair_required"):
				node.set("repair_required", data["repair_required"])
			var shape := RectangleShape2D.new()
			shape.size = Vector2(16, 48)
			var col := CollisionShape2D.new()
			col.shape = shape
			node.add_child(col)
			var sprite := Sprite2D.new()
			sprite.self_modulate = Color(0.412, 0.78, 0.808, 1)
			sprite.scale = Vector2(1, 2)
			var tex := load("res://assets/environment/archive_tileset_proxy.png") as Texture2D
			sprite.texture = tex
			sprite.region_enabled = true
			sprite.region_rect = Rect2(32, 32, 16, 16)
			node.add_child(sprite)
		"voice_bell":
			node = Area2D.new()
			node.name = "VoiceBell"
			node.set_script(load("res://src/scripts/voice_bell.gd") as Script)
			node.collision_layer = 16
			node.collision_mask = 2
			if data.has("position"):
				node.position = _vec2(data["position"])
			if data.has("shard_value"):
				node.set("shard_value", data["shard_value"])
			var shape := RectangleShape2D.new()
			shape.size = Vector2(16, 24)
			var col := CollisionShape2D.new()
			col.shape = shape
			node.add_child(col)
			var sprite := Sprite2D.new()
			var tex := load("res://assets/sprites/voice_bell_broken.png") as Texture2D
			if tex:
				sprite.texture = tex
			node.add_child(sprite)
			var shard_area := Area2D.new()
			shard_area.name = "ShardArea"
			shard_area.monitoring = false
			var shard_col := CollisionShape2D.new()
			shard_col.shape = shape
			shard_area.add_child(shard_col)
			node.add_child(shard_area)
		"ability_gate":
			var scene: PackedScene = _scene_cache.get("ability_gate")
			if scene:
				node = scene.instantiate()
				node.name = "AbilityGate"
				if data.has("position"):
					node.position = _vec2(data["position"])
				if data.has("required_ability"):
					node.set("required_ability", data["required_ability"])
				if data.has("block_hint"):
					node.set("block_hint", data["block_hint"])
		"save_lantern":
			var scene: PackedScene = _scene_cache.get("save_lantern")
			if scene:
				node = scene.instantiate()
				node.name = "SaveLantern"
				if data.has("position"):
					node.position = _vec2(data["position"])
		"silenced_web":
			var scene: PackedScene = load("res://src/scenes/silenced_web.tscn") as PackedScene
			if scene:
				node = scene.instantiate()
				node.name = "SilencedWeb"
				if data.has("position"):
					node.position = _vec2(data["position"])
		_:
			push_warning("RoomLoader: unknown interactable type '%s'" % type)
			return null

	return node

func _vec2(arr: Array) -> Vector2:
	if arr.size() >= 2:
		return Vector2(float(arr[0]), float(arr[1]))
	return Vector2.ZERO
