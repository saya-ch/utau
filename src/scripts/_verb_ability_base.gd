class_name VerbAbilityBase
extends Node

## VerbAbilityBase — 5 verb ability (Pulse/Bind/Cut/Echo/Wave) 共享父类
## D002.B (#98) — 抽取 _VerbAbilityBase 父类，把 5 verb ability 中
## byte-identical 的 F001 风格代码（已抽 _VerbWindupVFXBase 验证成功）
## 集中到本父类，未来 6th verb 只需 extends 即可获得生命周期 + 共享
## helper。T174.B (#94) 的 5 verb windup VFX 父类是本任务的"前车之鉴"。
##
## 集中在本父类的内容（5 verb 共用）：
##   - 共享状态：_cooldown_timer / _windup_timer / _is_winding_up /
##              _pending_origin / _pending_direction / _windup_vfx / _player
##   - 共享 @export：cooldown / windup_time
##   - _ready() 玩家类型断言 + 调用 _apply_perk_bonuses() 虚钩
##   - _process() cooldown 倒计时 + 跨 >0→<=0 帧守卫触发 cooldown jingle
##               + windup 倒计时 + 触发 _execute_verb() 虚钩
##   - _consume_verb_cost() 5 verb byte-identical helper（F007 #87）
##   - _setup_windup_state() 5 verb byte-identical helper（F007 #87）
##   - get_cooldown_ratio() 5 verb byte-identical helper
##   - is_winding_up() 5 verb byte-identical helper
##   - _exit_tree() _windup_vfx fade_out_and_free（T166-T173 系列）
##   - _has_game_state_autoload() 3 verb 已用，bind/echo 升级
##   - _spawn_windup_vfx() 5 verb windup VFX 注入 helper（标准 4-step：
##                     防御性 free 旧 instance → add_child → trigger →
##                     stashed in _windup_vfx）
##
## 留在各 verb 子类的内容（verb-specific）：
##   - 各自 verb-specific signal（pulse_fired / bind_fired / ...）
##   - 各自 verb-specific @export（pulse_radius / bind_radius / ...）
##   - can_X() / start_X() 公共门（cost + cooldown + windup 守卫）
##   - _execute_verb() 虚钩：fire signal + 调 AudioManagerEnhanced.play_X() +
##                          _perform_X_hit_check()（verb-specific 命中检测）
##   - 各自 verb-specific helper（_apply_X_hit / _perform_X_hit_check / ...）
##   - 各自 verb-specific 内部状态（echo._is_active / wave._current_radius / ...）
##
## 子类需要 override 的最小集合（3 个）：
##   1. _get_verb_name() -> String     # 返回 "pulse" / "bind" / "cut" / "echo" / "wave"
##   2. _apply_perk_bonuses() -> void  # 应用 shop perk bonus（默认 no-op）
##   3. _execute_verb() -> void        # 5 verb fire 主体（默认 no-op，警告）
##
## 子类的"标准开头"示例（参考 _verb_windup_vfx_base.gd 的 5 verb 模式）：
##   class_name PulseAbility
##   extends VerbAbilityBase
##
##   signal pulse_fired(origin: Vector2, radius: float)
##   signal pulse_hit(target: Node, knockback: Vector2)
##   signal pulse_blocked
##
##   @export var pulse_radius: float = 48.0
##   @export var pulse_cost: int = 15
##   @export var damage: int = 1
##
##   func _get_verb_name() -> String: return "pulse"
##   func _apply_perk_bonuses() -> void: ...  # 5 verb 各不相同
##
##   func can_pulse() -> bool: ...             # verb-specific gate
##   func start_pulse(origin, direction) -> bool: ...  # 调 _consume_verb_cost
##   func _execute_verb() -> void: ...         # 调 fire signal + play_pulse()
##
## 命名规则：父类以 `_` 前缀（_verb_ability_base.gd）符合 Godot 资产
## 排序惯例（`_` 排首位，便于人工浏览"基类优先"），并避免与玩家在
## 场景树中可能误用的同名 class_name 冲突。

# ===== 共享 @export =====
# 子类 5 verb 全部 @export cooldown + windup_time（D002.B 整合点）。
# 父类 default 设为 5 verb 中位数（Bind cooldown 1.2s / windup 0.1s），
# 子类通过 @export override 覆盖。GDScript 允许子类重声明 @export
# 来 override 父类同名 export 的 default。
@export var cooldown: float = 1.2
@export var windup_time: float = 0.1

# ===== 共享 state（5 verb 全部冗余的 6 字段）=====
# D002.B 集中化 — 子类删掉这 6 个 var，直接从父类继承：
#   var _cooldown_timer: float = 0.0
#   var _windup_timer: float = 0.0
#   var _is_winding_up: bool = false
#   var _pending_origin: Vector2 = Vector2.ZERO
#   var _pending_direction: Vector2 = Vector2.ZERO
#   var _windup_vfx: Node2D = null
#   @onready var _player: CharacterBody2D = get_parent() as CharacterBody2D
var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO
# T166-T173 (#85-#92) — Live handle to the pre-verb windup VFX so
# _execute_verb() can free it the instant the fire VFX takes over
# (avoids 1-frame overlap). 5 verb 全部一致，所以放父类。
var _windup_vfx: Node2D = null
@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D


# ===== 虚钩（子类 override）=====

# 子类必须 override：返回 "pulse" / "bind" / "cut" / "echo" / "wave"
# 用于 _process() 中触发 play_verb_cooldown_ready(<name>) jingle（T181 #97）。
# 默认返回 "base" 是哨兵值（AudioManagerEnhanced 查表 -1 静默 no-op，
# 见 audio_manager_enhanced.gd:_verb_cooldown_start_midi），保证子类
# 未 override 时不会 crash。
func _get_verb_name() -> String:
	return "base"

# 子类 override：应用 shop perk bonus 到自身字段。
# pulse: 调 GameState.get_pulse_radius_bonus / get_damage_bonus
# cut:   调 GameState.get_damage_bonus
# echo:  调 GameState.get_echo_radius_bonus
# wave:  调 GameState.get_wave_radius_bonus
# bind:  不调（无 perk bonus）
# 默认 no-op，bind 不 override 直接走这里。
func _apply_perk_bonuses() -> void:
	pass

# 子类必须 override：5 verb fire 主体（fire signal + 调
# AudioManagerEnhanced.play_<verb>() + _perform_X_hit_check()）。
# 父类默认 no-op + push_warning 提醒子类未 override。
func _execute_verb() -> void:
	push_warning("VerbAbilityBase._execute_verb() not overridden by " + _get_verb_name() + " — subclass should override this hook")


# ===== 共享 _ready + _process =====

func _ready() -> void:
	# 5 verb 全部用同一个断言（_player 必须存在）—— pulse / bind / cut /
	# echo / wave 各自 _ready 第一行就是 assert(_player != null, ...)。
	# 父类统一集中，message 加 verb 名便于 debug。
	assert(_player != null, "VerbAbilityBase<" + _get_verb_name() + "> must be child of CharacterBody2D")
	# 虚钩：子类各自实现 perk bonus 注入逻辑
	_apply_perk_bonuses()

func _process(delta: float) -> void:
	# Cooldown 倒计时 + 跨 >0 → <=0 帧守卫触 jingle
	# T181 (#97 first half) 5 verb 共用 — 父类集中后子类不再写。
	# cross-from-positive 守卫：前一帧 > 0 → 这一帧 <= 0 才触发，
	# 避免 cooldown 已经 0 时每帧重复触发。
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0:
			if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_verb_cooldown_ready"):
				AudioManagerEnhanced.play_verb_cooldown_ready(_get_verb_name())

	# Windup 倒计时 + 触 _execute_verb 虚钩
	# 5 verb 全部走同一路径：_windup_timer 倒计时，归零时调 verb-specific
	# _execute_verb()（子类 override 各自实现）。
	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute_verb()


# ===== 5 verb byte-identical helper（F007 #87）=====

# F007 (#87) — Shared cost-consumption step. Byte-identical to the 5
# verb abilities' copies (pulse/bind/cut/echo/wave). 父类集中后子类
# 不再需要 _consume_verb_cost() 本地副本 —— 直接调
# _consume_verb_cost(cost) 即可。
func _consume_verb_cost(cost: int) -> bool:
	if GameState == null:
		return false
	return GameState.consume_resonance(cost)

# F007 (#87) — Shared windup-state setup step. Byte-identical to the
# 5 verb abilities' copies. Echo 仍可传 Vector2.ZERO 当 direction
# (omnidirectional shield 不用方向) — 这点跟原本 4 verb 共享时一致。
func _setup_windup_state(origin: Vector2, direction: Vector2) -> void:
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction


# ===== 5 verb byte-identical query helper =====

# 5 verb 全部 byte-identical（return clampf(_cooldown_timer / cooldown, 0, 1)）。
# 父类集中后子类删掉 get_cooldown_ratio() 本地副本。
func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

# 5 verb 全部 byte-identical（return _is_winding_up）。
# 父类集中后子类删掉 is_winding_up() 本地副本。player.gd 用它
# 做 5 verb chain anti-misinput（T142 #75）。
func is_winding_up() -> bool:
	return _is_winding_up


# ===== 5 verb 共享 _exit_tree（T166-T173 系列）=====

# T166 (#85) Pulse / T167 (#86) Bind / T168 (#86) Echo /
# T169 (#87) Cut / T171 (#89) Wave / T173 (#92) 全部统一为同一
# 5 行实现：fade_out_and_free on _windup_vfx + null 重置。
# 父类集中后子类删掉 _exit_tree() 本地副本。
# _windup_vfx 是 VerbWindupVFXBase 子类（T174.B #94），提供
# fade_out_and_free() 0.05s modulate:a 1→0 tween + queue_free。
func _exit_tree() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.fade_out_and_free()
	_windup_vfx = null


# ===== 3 verb 已用 helper（bind / echo 升级）=====

# 3 verb (pulse / cut / wave) 已在 _ready() 用 _has_game_state_autoload()
# 来 guard GameState autoload 在 headless 测试上下文不存在的情况。
# bind / echo 之前用 `if GameState and GameState.has_method(...)` 直接判断，
# 现统一为同一 helper（语义一致：headless 静默 no-op）。
# 父类集中后子类删掉 _has_game_state_autoload() 本地副本，直接调
# _has_game_state_autoload() 即可。
func _has_game_state_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("GameState")


# ===== 子类 windup VFX 注入 helper（4-step 标准流程）=====

# 标准 4-step 流程（D002.B 整合 5 verb start_X() 内联 windup VFX spawn）：
#   1. 防御性 free 旧 _windup_vfx（避免上次 cast 残留）
#   2. add_child 到 current_scene（不是 player，世界坐标稳定）
#   3. trigger(origin, display_radius, windup_time) 启动 ramp-in
#   4. _windup_vfx = vfx_instance（stash 给 _exit_tree 用）
# 子类 start_X() 调：_spawn_windup_vfx(origin, preload("..._windup_vfx.gd").new(), radius * 0.5)
func _spawn_windup_vfx(origin: Vector2, vfx_instance: Node2D, display_radius: float) -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance.
		_windup_vfx.queue_free()
	_windup_vfx = vfx_instance
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)
		if vfx_instance.has_method("trigger"):
			vfx_instance.trigger(origin, display_radius, windup_time)


# ===== 5 verb _execute_verb 共用"前置"模式（fire signal + play SFX）=====

# T181 (#97) + F004 (#94) — 5 verb _execute_X() 前两行是：
#   1. _is_winding_up = false  +  _cooldown_timer = cooldown
#   2. free _windup_vfx before fire（避免 1 帧 overlap）
#   3. PlayerStats.record_ability_used("<verb>")
#   4. <verb>_fired.emit(...)   # verb-specific signal
#   5. AudioManagerEnhanced.play_<verb>()  # fire SFX
# 第 1-3 步 5 verb byte-identical，父类集中；第 4-5 步 verb-specific，
# 由子类 _execute_verb() 实现。子类 _execute_verb() 应首先调
# _begin_verb_fire() 集中处理 1-3 步。
func _begin_verb_fire(verb_name: String) -> void:
	_is_winding_up = false
	_cooldown_timer = cooldown

	# Free the windup VFX *before* emitting the fire signal so the fire
	# VFX (spawned in player._on_<verb>_fired) replaces the windup VFX
	# in the same frame — no 1-frame overlap. Mirrors the 5 verb pattern
	# (T166-T171 + T173 fade_out_and_free).
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.queue_free()
	_windup_vfx = null

	# Stats tracking — 5 verb 全部走 PlayerStats.record_ability_used(<verb>)
	# (pulse/bind/cut/echo/wave 在 _execute_X() 内). 父类集中
	# 后子类不再需要这条 PlayerStats 调用。
	PlayerStats.record_ability_used(verb_name)
