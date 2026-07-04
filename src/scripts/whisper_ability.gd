class_name WhisperAbility
extends "res://src/scripts/_verb_ability_base.gd"

## F013.E (#159) — Whisper 悄声（第六动词）
## 设计：短前摇 + 球形静默场，命中敌人施加 "silence" 1.2s
##   1.2s 静默期间敌人冻结（停移动 / 停攻击 / 持续时间不递减）
## 与 5 verb 的「攻击 / 牵引 / 反射」对比，Whisper 是「debuff 控制」动词
##   - Pulse (Coral)   — 推/破盾，圆环
##   - Bind (Violet)   — 牵引/暂停，螺旋
##   - Cut (Amber)     — 切断腐蚀链，弧斩
##   - Echo (Cyan)     — 护盾反弹，球
##   - Wave (Pale)     — 群攻波，光环
##   - Whisper (Mauve) — 静默场，圆球暗色雾
## 色域：Muted Mauve (#C8A4D8) — 区别于 5 verb，柔粉紫暗示「轻轻一语」
##
## 数值（F013.E #159 第 1 版）：
##   - radius 50px（小于 Wave 80，定位「贴身」debuff）
##   - cost 35 共鸣（比 Wave 50 便宜）
##   - cooldown 5.0s（比 Wave 6.0s 短）
##   - windup 0.10s（与 Pulse/Wave 一致）
##   - silence_duration 1.2s（与 Bind 的 pull 3.0s 相比是「短 debuff」）
##
## 与 Bind 的协同：Bind 是「拉过来+3s 停」，Whisper 是「原地+1.2s 停」。
## Bind 解决「够不到」，Whisper 解决「来不及躲开」，组合后玩家在
## 远程风筝场景的解法更多元。

signal whisper_fired(origin: Vector2, radius: float)
signal whisper_hit(target: Node)
signal whisper_blocked

@export var whisper_radius: float = 50.0
@export var whisper_cost: int = 35
# H001 (#99 hotfix) — `cooldown` 和 `windup_time` 由 VerbAbilityBase 提供，
# 6 verb 接入路径 F013.E §9.2 第 1 项: 不要重声明. .tscn override 5.0 / 0.10.
@export var active_time: float = 0.15
@export var silence_duration: float = 1.2

# F013.E (#159) — Whisper 6 verb 状态字段（Wave 模式 H001 D002.B 修复模板）:
#   _is_active: true 在 0.15s 静默场判定窗口期间
#   _active_timer: 0.15 → 0 倒计时，0 触发 _deactivate_whisper()
#   _hit_this_cast: dedup set 防同一敌人在 1 cast 内被多次 hit
var _is_active: bool = false
var _active_timer: float = 0.0
var _hit_this_cast: Array = []


func _ready() -> void:
	# D002.B (#98) — Parent's _ready() resolves _player + asserts non-null.
	# 6 verb 接入路径 §9.1 第 1 步: 必须在 super 之后做 verb-specific 初始化.
	super._ready()
	# F013.E (#159) — Whisper 不取 echo_radius_bonus / wave_radius_bonus
	# (它是 6 verb 第一个非 Pulse/Bind/Cut/Echo/Wave 的 debuff 动词,
	#  5 verb 的 perk 体系不直接复用). 后续若加 whisper_radius_bonus perk,
	#  在此处 apply (与 PulseAbility / WaveAbility 的 ready() 同模式).


func _process(delta: float) -> void:
	# D002.B (#98) — Cooldown + T181 jingle 在 VerbAbilityBase._process_cooldown().
	# 6 verb 接入路径 §9.1 第 5 步: subclass opt-in 调 _process_cooldown(delta, "whisper").
	_process_cooldown(delta, "whisper")

	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_whisper()

	if _is_active:
		_active_timer -= delta
		_perform_whisper_check()
		if _active_timer <= 0:
			_deactivate_whisper()


func can_whisper() -> bool:
	# 6 verb 接入路径 §9.1 第 5 步: 失败原因 1 (cooldown) / 2 (共鸣不足)
	# / 3 (windup) / 4 (active). 比 Wave 简单 — 无 4 verb 状态路由分支.
	return _cooldown_timer <= 0 \
		and GameState.resonance >= whisper_cost \
		and not _is_winding_up \
		and not _is_active


func start_whisper(origin: Vector2) -> bool:
	# 6 verb 接入路径 §9.1 第 5 步: 失败调 hud.show_whisper_blocked().
	# 这里先返 false, player.gd handler 读返值后做 4 verb 状态路由 (仿 Wave).
	if not can_whisper():
		return false

	if not _consume_verb_cost(whisper_cost):
		return false

	# D002.B (#98) — _setup_windup_state 共享.  Whisper 与 Wave 同为 omni AOE,
	# 不需要 _pending_direction (静默场对称扩散), 传 Vector2.ZERO 即可.
	_setup_windup_state(origin, Vector2.ZERO)
	_hit_this_cast.clear()

	# F013.E (#159) — Spawn windup VFX (6 verb 接入路径 §9.1 第 6 步).
	# Wave 的 5-verb windup family (T171 #89) 是参考蓝本, Whisper 6 verb 之一.
	# 风蓄期 0.10s, 半径 0.5× = 25px 圆球暗雾, 提示「接下来禁声」.
	var windup_vfx := preload("res://src/scripts/whisper_windup_vfx.gd").new()
	windup_vfx.trigger(_pending_origin, whisper_radius * 0.5, windup_time)
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(windup_vfx)
	# T173 (#92) — Stash VFX ref so _exit_tree() can fade it out cleanly.
	# VerbAbilityBase._exit_tree() 统一处理 (D002.B #98).
	_windup_vfx = windup_vfx

	return true


func _execute_whisper() -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# Stats tracking — 6 verb 接入路径 §9.1 第 7 步: PlayerStats.record_ability_used
	PlayerStats.record_ability_used("whisper")

	# Activate the silence field (start 0.15s 判定 window)
	_is_active = true
	_active_timer = active_time

	# Emit signal so VFX + SFX react at the exact moment the field starts
	whisper_fired.emit(_pending_origin, whisper_radius)

	# T181 (#97 first half) — 6 verb audio cue.  Whisper fire SFX 是
	# "耳语气声" 0.25s (低通 200Hz → 100Hz), 与 5 verb fire SFX 完全不同
	# (Pulse 是 800Hz 短脉冲, Wave 是 100Hz 长 bloom). 玩家用耳朵就能
	# 区分 6 verb.  Guard: _player-validity 防 windup 中 death 崩.
	if _player and is_instance_valid(_player):
		if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_whisper_fire"):
			AudioManagerEnhanced.play_whisper_fire()
		# F013.B (#106) — 6 verb cooldown TAIL jingle (verb 刚 cast 出去
		# → 降 4 半音 0.12s "verb 锁了" 提示).  Wave 6.0s cooldown 最长,
		# Whisper 5.0s 次长, tail 让玩家立刻 "知道 verb 锁了 5 秒".
		if AudioManagerEnhanced.has_method("play_verb_cooldown_tail"):
			AudioManagerEnhanced.play_verb_cooldown_tail("whisper")


func _perform_whisper_check() -> void:
	# Origin follows player so silence field stays centered as they move.
	# Whisper 是「以玩家为中心」的圆球场, 不是 Wave 的「扩散波」, 所以
	# 整个 active window 期间 origin 跟随 player.global_position.
	var origin := _player.global_position + Vector2(0, -8)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		if _hit_this_cast.has(enemy):
			continue
		var dist: float = enemy.global_position.distance_to(origin)
		if dist > whisper_radius:
			continue
		_apply_whisper_to_enemy(enemy)
		_hit_this_cast.append(enemy)


func _apply_whisper_to_enemy(enemy: Node) -> void:
	# F013.E (#159) — Whisper 给敌人施加 silence 1.2s.
	# 复用 enemy.apply_bind() 接口 (Bind 用了 0.5-3.0s 各种 duration).
	#  静默期间敌人完全冻结 (类似 Bind 的 pull-then-freeze 末段).
	#  区别: Bind 是 "拉到玩家身边然后停 3s", Whisper 是 "原地立即停 1.2s".
	if enemy.has_method("apply_bind"):
		enemy.apply_bind(silence_duration)
	whisper_hit.emit(enemy)


func _deactivate_whisper() -> void:
	_is_active = false
	_hit_this_cast.clear()


func is_whisper_active() -> bool:
	return _is_active


func get_current_whisper_radius() -> float:
	# F013.E (#159) — Whisper 是 constant radius (不像 Wave 扩散), 但暴露
	# 同样的接口方便 player.gd / vfx.gd 用同一公式.
	return whisper_radius


# D001 (#82) — Whisper 的 0.10s windup 期间也走 anti-misinput 链抑制.
# 复用 VerbAbilityBase.is_winding_up() (D002.B #98 提供). PlayerActionGate
# autoload 在 D001 接管时统一读 is_globally_blocking, 6 verb 接入路径
# §9.1 第 5 步: 新 verb 必须暴露 is_globally_blocking() 入口.
func is_globally_blocking() -> bool:
	return _is_winding_up
