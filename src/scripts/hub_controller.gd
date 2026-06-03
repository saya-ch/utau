class_name HubController
extends Node2D

signal ability_selected(ability_name: String)
signal hub_exited(target_room_path: String)

@export var hub_id: String = "hub_main"
@export var next_room_path: String = "res://src/scenes/main.tscn"
@export var next_spawn_point: Vector2 = Vector2(60, 180)

var _dialogue_active: bool = false
var _ability_choice_active: bool = false

@onready var _dialogue_box: DialogueBox = $DialogueBox
@onready var _exit_door: RoomDoor = $ExitDoor
@onready var _npcs: Node2D = $NPCs

func _ready() -> void:
	GameState.current_room = hub_id
	
	# Connect NPC interactions
	if _npcs:
		for child in _npcs.get_children():
			if child is NPC:
				child.interacted.connect(_on_npc_interacted)
	
	# Connect exit door
	if _exit_door:
		_exit_door.player_entered.connect(_on_exit_door_entered)
		_exit_door.open()
	
	# Connect dialogue
	if _dialogue_box:
		_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
		_dialogue_box.option_selected.connect(_on_option_selected)

func _on_npc_interacted(npc_id: String) -> void:
	if _dialogue_active:
		return
	
	var lines := _get_dialogue_for_npc(npc_id)
	if lines.size() > 0:
		_dialogue_active = true
		get_tree().paused = true
		_dialogue_box.show_dialogue(lines)

func _get_dialogue_for_npc(npc_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	match npc_id:
		"archivist":
			result = [
				{"name": "档案管理员", "text": "你来了，Saya。档案馆深处的寂静比昨日更浓了。", "portrait": null},
				{"name": "档案管理员", "text": "要进入下一个房间吗？那里的声匣需要你的共鸣。", "portrait": null},
				{"name": "档案管理员", "text": "记住：Pulse 可以推开敌人，Bind 可以牵引它们。", "portrait": null},
				{"name": "档案管理员", "text": "而 Cut 斩击能斩断腐蚀的丝网与沉默的雾墙。", "portrait": null},
				{"name": "档案管理员", "text": "你准备好出发了吗？", "portrait": null, "options": ["是的，出发", "我还想再准备一下"]},
			]
		"tuner":
			result = [
				{"name": "调音自动机", "text": "咔嗒……咔嗒……检测到声波频率不稳定。", "portrait": null},
				{"name": "调音自动机", "text": "建议：在进入危险区域前，确保共鸣能量充足。", "portrait": null},
				{"name": "调音自动机", "text": "当前共鸣能量上限：100。碎片可提升上限。", "portrait": null},
			]
		_:
			result = [
				{"name": "???", "text": "……（无声的凝视）", "portrait": null},
			]
	return result

func _on_dialogue_finished() -> void:
	_dialogue_active = false
	get_tree().paused = false

func _on_option_selected(option_index: int) -> void:
	if option_index == 0:
		# "Yes, let's go" - open exit door if not already
		if _exit_door and not _exit_door._is_open:
			_exit_door.open()

func _on_exit_door_entered(_path: String) -> void:
	hub_exited.emit(next_room_path)
	
	# Transition to next room
	GameState._pending_room_path = next_room_path
	GameState._pending_spawn_point = next_spawn_point
	GameState._is_transitioning = true
	
	var transition := get_tree().current_scene.get_node_or_null("RoomTransition") as RoomTransition
	if transition and transition.has_method("fade_out"):
		if not transition.transition_finished.is_connected(_do_room_switch):
			transition.transition_finished.connect(_do_room_switch)
		transition.fade_out(0.4)
	else:
		_do_room_switch()

func _do_room_switch() -> void:
	var transition := get_tree().current_scene.get_node_or_null("RoomTransition") as RoomTransition
	if transition:
		transition.transition_finished.disconnect(_do_room_switch)
	GameState.save_persistent_state()
	get_tree().change_scene_to_file(GameState._pending_room_path)
