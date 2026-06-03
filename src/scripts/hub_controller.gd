class_name HubController
extends Node2D

## Hub 区域控制器：管理安全区状态、NPC 交互、出口门过渡、首次进入提示。
##
## 重构说明（T048）：
## - _on_exit_door_entered 仿照 GameFlowController._on_door_entered 模板重写：
##   * 走 GameFlowController._enter_state(State.ROOM_TRANSITION) 统一状态机
##   * 通过 transition.transition_finished 信号链触发 _do_room_switch
##   * disconnect 始终在 _do_room_switch 内做收尾
## - 避免双重切换风险（G005）：Hub 不再手动操作 GameState._is_transitioning，
##   由 GFC 通过状态机统一管理。

signal ability_selected(ability_name: String)
signal hub_exited(target_room_path: String)

@export var hub_id: String = "hub_main"
@export var next_room_path: String = "res://src/scenes/main.tscn"
@export var next_spawn_point: Vector2 = Vector2(60, 180)
@export var tutorial_hints: Array = [
	{"group": "hub_intro", "text": "与档案管理员交谈，领取任务。", "delay": 0.8, "duration": 4.0},
	{"group": "hub_door", "text": "准备就绪后从出口门进入档案馆。", "delay": 5.0, "duration": 4.0},
]

var _dialogue_active: bool = false
var _ability_choice_active: bool = false

@onready var _dialogue_box: DialogueBox = get_node_or_null("../DialogueBox") as DialogueBox
@onready var _exit_door: RoomDoor = get_node_or_null("../ExitDoor") as RoomDoor
@onready var _npcs: Node2D = get_node_or_null("../NPCs") as Node2D

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
		_exit_door.enable_trigger()

	# Connect dialogue
	if _dialogue_box:
		_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
		_dialogue_box.option_selected.connect(_on_option_selected)

	# Schedule Hub-specific tutorial hints (T047)
	_schedule_tutorial_hints()

func _schedule_tutorial_hints() -> void:
	# Hub rooms don't use RoomController's tutorial_hints (which is JSON-driven
	# via RoomLoader). Instead, HubController owns its hint schedule directly.
	if tutorial_hints.is_empty():
		return
	var tut := get_tree().get_first_node_in_group("tutorial_hint")
	if tut == null:
		return
	for hint in tutorial_hints:
		var group_id: String = hint.get("group", "")
		var text: String = hint.get("text", "")
		var delay: float = hint.get("delay", 0.5)
		var duration: float = hint.get("duration", 4.0)
		if group_id == "" or text == "":
			continue
		var t := get_tree().create_timer(delay)
		t.timeout.connect(func():
			if not is_instance_valid(tut):
				return
			tut.queue_hint(group_id, text, duration)
		)

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
		if _exit_door and not _exit_door.is_trigger_enabled():
			_exit_door.enable_trigger()

func _on_exit_door_entered(_path: String) -> void:
	hub_exited.emit(next_room_path)

	# Refactored (T048): mirror GameFlowController._on_door_entered pattern.
	# Hand off the transition to GameFlowController so the same state-machine
	# guarantees apply (pause / recover / change_scene_to_file ordering).
	var gfc := get_tree().get_first_node_in_group("game_flow_controller") as Node
	if gfc == null:
		# Fallback: look up the node directly. Avoid silent mis-switches.
		gfc = get_tree().current_scene.get_node_or_null("GameFlowController")

	if gfc and gfc.has_method("_enter_state") and gfc.has_method("_do_room_switch"):
		# GFC._on_door_entered will:
		# 1) write _pending_room_path (from the param) and
		#    _pending_spawn_point (from the first room_door's target_spawn_point)
		# 2) enter ROOM_TRANSITION state (pause + fade_out)
		# 3) call _do_room_switch on transition_finished
		gfc.call("_on_door_entered", next_room_path)
		return

	# Fallback path: no GFC present. Mirror the old local-transition logic
	# so the door still works in degenerate setups (e.g. scene opened directly).
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
