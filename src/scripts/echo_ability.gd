class_name EchoAbility
extends Node

## Echo 声波能力（第四动词）
## 设计：短前摇 + 球形护盾 + 敌人投射物反弹 / 摧毁
## 功能：生成 0.6s 玻璃护盾，期间拦截范围内 NoteProjectile，反弹其
##       direction + 速度 1.4x；过近的投射物直接摧毁。反弹后的投射
##       物保留反弹标记，再次命中敌人时按 Pulse 的 1 伤击打（击打结
##       果走 NoteWisp.take_damage，净化计数 + 共鸣碎片掉落）。
## 与 Pulse (推/破盾, 圆环) / Bind (牵引/暂停, 螺旋) / Cut (斩/切断
## 腐蚀链, 弧斩) 形成对比 — Echo 是「防御 + 反击」向的第四动词。
##
## 实现要点：
## - 与 PulseAbility 共享 GameState 派生（无 shop perk 直挂，但可读
##   damage_bonus 决定反弹投射物的反弹伤害；当前回退 = 1 伤）。
## - 反弹通过 NoteProjectile.bounce_off_echo(source_pos, boost) API；
##   投射物被加进 "echo_bounced" 临时组，0.8s 后自动退出。
## - 反弹投射物在 NoteWisp.take_damage 路径外有第二条入口：直接
##   调 enemy.take_damage(1, knockback)；本类不重复净化逻辑。
## - HUD 接入走 hud.gd 的 _echo_ability 引用 + _echo_cooldown 进度条。

signal echo_fired(origin: Vector2, radius: float)
signal echo_block_hit(proj: Node, is_destroyed: bool)
signal echo_expired
signal echo_blocked

@export var echo_radius: float = 44.0
@export var echo_cost: int = 20
@export var cooldown: float = 2.5
@export var windup_time: float = 0.10
@export var echo_duration: float = 0.60
## T068 — 反弹命中时投射物对敌人的伤害（来自 shop damage_bonus
## perk silence_breaker；无 perk 时回退 1）。
@export var bounce_damage: int = 1
## 反弹后投射物速度乘数（>1 = 更快回击敌人）。
@export var bounce_speed_mult: float = 1.4
## 反弹投射物在 "echo_bounced" 临时组的存活时长（秒）。
@export var bounce_tag_duration: float = 0.8

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _is_active: bool = false
var _active_timer: float = 0.0
var _pending_origin: Vector2 = Vector2.ZERO

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	assert(_player != null, "EchoAbility must be child of CharacterBody2D")
	# T068 — silence_breaker perk 提升反弹投射物对敌人的伤害。注意：
	# _ready 触发时 GameState 早已是 autoload + perks 已 restore，OK
	# 直接读；与 pulse_ability._ready 同一时机。
	if _has_game_state_autoload():
		bounce_damage += GameState.get_damage_bonus()

func _has_game_state_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("GameState")

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_activate_shield()

	if _is_active:
		_active_timer -= delta
		# 每帧检测一次范围内投射物（护盾物理碰撞）
		_perform_shield_block_check()
		if _active_timer <= 0:
			_deactivate_shield()

func can_echo() -> bool:
	return (_cooldown_timer <= 0
		and GameState.resonance >= echo_cost
		and not _is_winding_up
		and not _is_active)

func start_echo(origin: Vector2, _direction: Vector2) -> bool:
	if not can_echo():
		return false
	if not GameState.consume_resonance(echo_cost):
		return false

	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	return true

func _activate_shield() -> void:
	_is_winding_up = false
	_is_active = true
	_active_timer = echo_duration
	_cooldown_timer = cooldown

	# Stats tracking
	PlayerStats.record_ability_used("echo")

	# Emit signal for VFX + screen-shake
	echo_fired.emit(_pending_origin, echo_radius)

	# 即时做一次 block check（玩家可能在按下 echo 的瞬间就吃到了
	# 一颗投射物；不立即处理会让玩家困惑"我按了怎么没挡？"）
	_perform_shield_block_check()

func _deactivate_shield() -> void:
	_is_active = false
	echo_expired.emit()

func _perform_shield_block_check() -> void:
	# 球形范围检测敌人投射物。注意：直接迭代 get_tree() group 而
	# 不是 physics shape query，因为 NoteProjectile 是 Area2D（不在
	# 物理 collision layer 上），物理 shape query 会 miss。
	var projectiles := get_tree().get_nodes_in_group("enemy_projectiles")
	for proj in projectiles:
		if proj == null or not is_instance_valid(proj):
			continue
		if proj.is_in_group("echo_bounced"):
			# 已被本次护盾反弹过 — 同一护盾不再二次反弹，避免单
			# 颗投射物在 0.6s 内被无限加速。
			continue
		var dist: float = proj.global_position.distance_to(_pending_origin)
		if dist > echo_radius:
			continue

		# 过近 → 直接摧毁（避免"贴着盾刷过去"留下反弹钉子）
		if dist < echo_radius * 0.5:
			_destroy_projectile(proj)
			continue

		# 标准路径：反弹 — direction 指向玩家中心 + 加速
		# 显式 Vector2 标注：proj 静态类型是 Node，proj.global_position
		# 在 GDScript 4.6 严格类型推断下需要显式 cast。
		var dir_to_player: Vector2 = (_pending_origin - Vector2(proj.global_position)).normalized()
		# 把反弹方向调成"远离玩家 + 一丝丝背离护盾内沿" → 投影回敌
		# 人方向比指向玩家更稳定；这里取指向玩家，因为 Echo 的
		# "反射"语义就是"折返给发射者"。
		if proj.has_method("bounce_off_echo"):
			proj.bounce_off_echo(_pending_origin, bounce_speed_mult, bounce_tag_duration)
		else:
			# Fallback：直接反转 direction + 加速（不依赖新增 API）
			if "direction" in proj:
				proj.set("direction", dir_to_player)
			if "speed" in proj:
				proj.set("speed", float(proj.get("speed")) * bounce_speed_mult)

		# 加反弹标记（同一护盾周期内不二次反弹）
		proj.add_to_group("echo_bounced")
		_schedule_remove_from_group(proj, "echo_bounced", bounce_tag_duration)

		# 反弹命中 VFX（cooldown-safe，ScreenShake 短促）— 调 VFX
		# 类的反弹 API；VFX 由 player.gd._on_echo_fired 创建的
		# EchoVFX 节点持有并通过反弹回调触发（VFX 内部"rebound"）
		var vfx := _get_active_echo_vfx()
		if vfx and vfx.has_method("trigger_rebound"):
			vfx.trigger_rebound(proj.global_position)

		echo_block_hit.emit(proj, false)

		# 屏幕震动（小，BIND 级别）
		ScreenShake.shake_preset(ScreenShake.Preset.BIND)

func _destroy_projectile(proj: Node) -> void:
	# 触发 VFX 破碎动画
	var vfx := _get_active_echo_vfx()
	if vfx and vfx.has_method("trigger_destroyed"):
		vfx.trigger_destroyed(proj.global_position)

	# 与 Pulse 路径一致：spawn 一次 RepairVFX 小亮点
	var repair_vfx := RepairVFX.new()
	get_tree().current_scene.add_child(repair_vfx)
	repair_vfx.trigger(proj.global_position, 8.0)

	proj.queue_free()
	echo_block_hit.emit(proj, true)

func _schedule_remove_from_group(node: Node, group: StringName, after: float) -> void:
	# 用一次性 Timer 延迟移除组标记。如果期间投射物被摧毁 / 离场，
	# 后续 is_instance_valid 守卫会避免误用。
	var tree := get_tree()
	if not tree:
		return
	var timer := tree.create_timer(after)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(node):
			node.remove_from_group(group)
	)

func _get_active_echo_vfx() -> Node:
	# 找到当前 active 的 EchoVFX 节点。玩家 spawn 的 EchoVFX
	# 总是以 add_child 到 current_scene；用 meta "echo_vfx_active"
	# 标记（player._on_echo_fired 设置）。
	var tree := get_tree()
	if not tree:
		return null
	for n in tree.get_nodes_in_group("echo_vfx"):
		if is_instance_valid(n) and n.has_meta("echo_vfx_active") and bool(n.get_meta("echo_vfx_active")):
			return n
	return null

func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

func is_winding_up() -> bool:
	return _is_winding_up

func is_shield_active() -> bool:
	return _is_active
