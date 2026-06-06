class_name NoteProjectile
extends Area2D

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 60.0
@export var lifetime: float = 4.0
@export var damage: int = 1

# T094 — 反弹标记。被 Echo 护盾反弹时由 bounce_off_echo 写入，
# 反弹后再次撞到敌人时走反弹命中路径（造成 bounce_damage 伤 +
# knockback，不重复净化）。NoteWisp.take_damage 自身负责净化 +
# 计数 + 碎片掉落。
var is_bounced: bool = false
var bounce_damage: int = 1

var _life_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
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

# T094 — Echo 护盾反弹入口。被 echo_ability._perform_shield_block_check
# 调用；新 direction 指向 echo_center（即反弹向玩家位置，符合"折返
# 给发射者"的语义），speed 乘以 boost，is_bounced 标记让后续
# _on_body_entered 走反弹命中路径。
func bounce_off_echo(echo_center: Vector2, boost: float, bounce_dmg: int) -> void:
	var away_from_center := (global_position - echo_center).normalized()
	if away_from_center == Vector2.ZERO:
		away_from_center = -direction  # 退化情况：用原 direction 的反向
	direction = away_from_center
	speed = maxf(speed * boost, 20.0)
	is_bounced = true
	bounce_damage = bounce_dmg
	# 视觉上把 note 切到 Amber Voice 暖色（与原 Coral 冷色区分）
	if _sprite:
		_sprite.self_modulate = Color("#F2B66E")
		# 缩放微微放大，传达"被反弹加速"的感觉
		_sprite.scale = Vector2(1.2, 1.2)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, direction * 50.0)
		queue_free()
		return
	# T094 — 反弹命中敌人。NoteWisp.is_in_group("enemies")；直接走
	# take_damage 走它的净化路径，伤害按 bounce_damage（=1 + perk）。
	if is_bounced and body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			var knockback := direction * 80.0
			body.take_damage(bounce_damage, knockback)
		queue_free()
		return

func _on_area_entered(area: Area2D) -> void:
	# Destroyed by Pulse
	if area.is_in_group("pulse_hitbox"):
		# Spawn small VFX
		var vfx := RepairVFX.new()
		get_tree().current_scene.add_child(vfx)
		vfx.trigger(global_position, 8.0)
		queue_free()
