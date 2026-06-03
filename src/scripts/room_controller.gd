class_name RoomController
extends Node2D

signal room_completed
signal room_failed

@export var room_id: String = "archive_01"
@export var completion_shards: int = 3
@export var show_completion_ui: bool = true
@export var tutorial_hints: Array = []  # [{group: String, text: String, delay: float, duration: float}]

var _is_completed: bool = false
var _is_failed: bool = false

@onready var _glass_lock = null
@onready var _voice_bell = null
@onready var _silence_mote = null

func _ready() -> void:
	add_to_group("room_controller")
	_find_room_objects()
	_connect_signals()
	GameState.current_room = room_id
	_schedule_tutorial_hints()

func _find_room_objects() -> void:
	var parent := get_parent()
	_glass_lock = parent.get_node_or_null("GlassLock")
	_voice_bell = parent.get_node_or_null("VoiceBell")
	_silence_mote = parent.get_node_or_null("SilenceMote")

func _connect_signals() -> void:
	if _glass_lock and _glass_lock.has_signal("unlocked"):
		_glass_lock.unlocked.connect(_on_lock_unlocked)
	if _voice_bell and _voice_bell.has_signal("shard_collected"):
		_voice_bell.shard_collected.connect(_on_shard_collected)
	GameState.health_changed.connect(_on_health_changed)

func _schedule_tutorial_hints() -> void:
	# Schedule tutorial hints from the room's hint list
	if tutorial_hints.is_empty():
		return
	var tut = get_tree().get_first_node_in_group("tutorial_hint")
	if tut == null:
		return
	# Each hint is shown after `delay` seconds; lasting `duration` seconds
	for hint in tutorial_hints:
		var group_id: String = hint.get("group", "")
		var text: String = hint.get("text", "")
		var delay: float = hint.get("delay", 0.5)
		var duration: float = hint.get("duration", 4.0)
		if group_id == "" or text == "":
			continue
		# Use call_deferred + timer to schedule
		var t := get_tree().create_timer(delay)
		t.timeout.connect(func():
			if not is_instance_valid(tut):
				return
			tut.queue_hint(group_id, text, duration)
		)

func _on_lock_unlocked() -> void:
	if _is_completed or _is_failed:
		return
	_check_completion()

func _on_shard_collected() -> void:
	if _is_completed or _is_failed:
		return
	_check_completion()

func _on_health_changed(new_health: int, _max_health: int) -> void:
	if new_health <= 0 and not _is_failed:
		_is_failed = true
		room_failed.emit()
		_show_failure_feedback()

func _check_completion() -> void:
	var lock_unlocked: bool = true
	if _glass_lock and _glass_lock.has_method("is_unlocked"):
		lock_unlocked = _glass_lock.is_unlocked()
	var shard_collected: bool = true
	if _voice_bell and _voice_bell.has_method("is_shard_collected"):
		shard_collected = _voice_bell.is_shard_collected()

	if lock_unlocked and shard_collected:
		_complete_room()

func _complete_room() -> void:
	if _is_completed:
		return
	_is_completed = true

	GameState.mark_room_completed(room_id)
	GameState.add_shards(completion_shards)
	# Stats tracking
	PlayerStats.record_room_cleared()

	room_completed.emit()
	_show_completion_feedback()

func _show_completion_feedback() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("房间已修复 +%d◆" % completion_shards)
	
	# Spawn completion VFX at room center
	var vfx = preload("res://src/scripts/repair_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(Vector2(240, 135), 64.0)

func _show_failure_feedback() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("共鸣消散...")

func is_completed() -> bool:
	return _is_completed

func is_failed() -> bool:
	return _is_failed

func reset_room() -> void:
	_is_completed = false
	_is_failed = false
