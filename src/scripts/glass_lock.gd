class_name GlassLock
extends StaticBody2D

signal unlocked
signal repair_progress_changed(progress: float)

@export var repair_required: int = 1
@export var repair_sound_pitch: float = 1.0

var _current_repair: int = 0
var _is_unlocked: bool = false

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("interactable")
	_update_visual_state()

func on_pulse_triggered() -> void:
	if _is_unlocked:
		return
	
	_current_repair += 1
	var progress := float(_current_repair) / float(repair_required)
	repair_progress_changed.emit(progress)
	
	# Visual feedback: brief flash
	if _sprite:
		_sprite.modulate = Color("#F2B66E")
		await get_tree().create_timer(0.1).timeout
		if _sprite:
			_sprite.modulate = Color.WHITE
	
	if _current_repair >= repair_required:
		_unlock()

func _unlock() -> void:
	_is_unlocked = true
	unlocked.emit()

	# Disable collision
	if _collision:
		_collision.disabled = true

	# Spawn repair VFX
	var vfx = preload("res://src/scripts/repair_vfx.gd").new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 32.0)

	# T101 — 修复成功的"声音回归"反馈：屏幕短暂染上 Amber Voice
	# 暖色（0.5s，比 Pulse/Cut/Echo 三动词闪 0.08-0.10s 都长），与
	# repair_vfx 暖色波形 + HUD 暖色"门锁已修复"提示三层视觉同步。
	# 色域主题化扩展：Pulse 命中 coral / Cut 命中 amber（短促） /
	# Echo 反弹 cyan / GlassLock 修复 amber（长）—— "Amber Voice = 修复/
	# 胜利"主题贯穿。has_method 防御让 headless 冒烟可跑。
	if ScreenShake and ScreenShake.has_method("flash_color"):
		ScreenShake.flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.5, 0.18)

	# Visual: fade out or change to "repaired" state
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#69C7CE"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.3, 0.5)

	# HUD hint
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_repair_hint"):
		hud.show_repair_hint("门锁已修复")

func _update_visual_state() -> void:
	if _sprite:
		_sprite.modulate = Color.WHITE

func is_unlocked() -> bool:
	return _is_unlocked

func get_repair_progress() -> float:
	if repair_required <= 0:
		return 1.0
	return clampf(float(_current_repair) / float(repair_required), 0.0, 1.0)
