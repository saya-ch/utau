class_name SilencedWeb
extends StaticBody2D

## 沉默雾墙 / 腐蚀链 — 第三种障碍
## 设计：垂直悬挂的腐蚀丝网，Pulse 推不动，Bind 不能拉，但 Cut 斩击可一次性切断
## 视觉：深墨蓝丝线 + 暗淡紫色腐蚀 + 极淡青色边缘
## 切断后：暖琥珀色粒子 + 波形扩散，2s 淡出

@export var web_color: Color = Color("#65506A")
@export var broken_color: Color = Color("#F2B66E")
@export var visual_width: float = 32.0
@export var visual_height: float = 80.0

var _is_broken: bool = false
var _lifetime: float = 0.0
var _max_lifetime: float = 2.0
var _original_collision_layer: int = 0
var _cut_progress: float = 0.0  # 0-1 cut animation

func _ready() -> void:
	collision_layer = 1  # World layer
	add_to_group("hazards")  # Treated as hazard for pulse
	# But we also want Cut to be able to trigger it - add a special group
	add_to_group("corruption_chain")
	_original_collision_layer = collision_layer

func _process(delta: float) -> void:
	if _is_broken:
		_lifetime += delta
		_cut_progress = clampf(_lifetime / 0.3, 0.0, 1.0)
		var fade_progress := clampf((_lifetime - 0.3) / (_max_lifetime - 0.3), 0.0, 1.0)
		modulate.a = 1.0 - fade_progress
		if _lifetime >= _max_lifetime:
			queue_free()
		else:
			queue_redraw()

func _draw() -> void:
	var w := visual_width
	var h := visual_height
	var rect := Rect2(-w * 0.5, -h * 0.5, w, h)

	if _is_broken:
		# Draw two halves sliding apart + warm flash
		var sep := _cut_progress * (w * 1.5)
		var fade := 1.0 - clampf((_lifetime - 0.3) / (_max_lifetime - 0.3), 0.0, 1.0)
		var col := broken_color
		col.a = fade * 0.6
		# Left half sliding left
		var left_rect := Rect2(-w * 0.5 - sep, -h * 0.5, w * 0.5, h)
		draw_rect(left_rect, col, true)
		# Right half sliding right
		var right_rect := Rect2(0.0 + sep, -h * 0.5, w * 0.5, h)
		draw_rect(right_rect, col, true)
		# Central flash line
		var flash_col := Color("#E86D5A")
		flash_col.a = fade * 0.9
		draw_line(Vector2(0, -h * 0.5), Vector2(0, h * 0.5), flash_col, 1.5)
	else:
		# Intact: dark web with subtle pattern
		var bg := web_color
		bg.a = 0.7
		draw_rect(rect, bg, true)
		# Crack pattern (vertical/horizontal lines)
		var line_col := Color("#1D6570")
		line_col.a = 0.4
		# Vertical threads
		for i in range(5):
			var x := -w * 0.4 + (w * 0.8 / 4.0) * i
			draw_line(Vector2(x, -h * 0.5), Vector2(x, h * 0.5), line_col, 0.5)
		# Horizontal threads
		for i in range(7):
			var y := -h * 0.4 + (h * 0.8 / 6.0) * i
			draw_line(Vector2(-w * 0.5, y), Vector2(w * 0.5, y), line_col, 0.5)
		# Diagonal corruption streaks
		var corr_col := Color("#081426")
		corr_col.a = 0.5
		draw_line(Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, h * 0.4), corr_col, 1.0)
		draw_line(Vector2(w * 0.5, -h * 0.4), Vector2(-w * 0.5, h * 0.5), corr_col, 1.0)
		# Faint glow outline
		var glow := Color("#69C7CE")
		glow.a = 0.25
		draw_rect(rect, glow, false, 1.0)

func on_cut_triggered() -> void:
	if _is_broken:
		return
	_is_broken = true
	_lifetime = 0.0
	# Stats tracking
	PlayerStats.record_silence_web_cut()
	# Disable collision so player can pass through
	collision_layer = 0
	collision_mask = 0
	# Spawn a RepairVFX at center for clear feedback
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 20.0)
