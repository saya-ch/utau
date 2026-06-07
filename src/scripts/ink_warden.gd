class_name InkWarden
extends CharacterBody2D

signal died
signal damaged
signal shield_broken
signal stunned

@export var patrol_speed: float = 25.0
@export var patrol_range: float = 50.0
@export var chase_speed: float = 45.0
@export var chase_range: float = 100.0
@export var lose_interest_range: float = 160.0
@export var health: int = 5
@export var contact_damage: int = 2
@export var knockback_resistance: float = 0.6
@export var shield_health: int = 3
@export var stun_duration: float = 2.5
@export var projectile_cooldown: float = 2.0
@export var projectile_speed: float = 50.0

# T080 — Boss music key override.  Default is the single-boss
# archive_03 theme; archive_04 (with two InkWardens in the same
# room) tags both its bosses with "archive_boss_dual" for a
# more intense track.  Set via the JSON `boss_music_key` field
# in data/rooms/*.json, applied in RoomLoader._build_enemy.
@export var boss_music_key: String = "archive_boss"

var _start_position: Vector2
var _patrol_direction: int = 1
var _is_dead: bool = false
var _is_purified: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _shield_active: bool = true
var _is_stunned: bool = false
var _stun_timer: float = 0.0
var _projectile_timer: float = 0.0

enum State { PATROL, CHASE, STUNNED }
var _state: State = State.PATROL
var _player_ref: Node2D = null

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _shield_vfx: Node2D = $ShieldVFX

# T067 — Boss music override is ref-counted in AudioManagerEnhanced.
# We track whether THIS instance ever requested an override, so the
# _exit_tree cleanup only decrements the counter if we were the ones
# who incremented it.  Without this flag, a boss that died normally
# (calling release_boss_music in _purify) would double-decrement
# on _exit_tree and end up with a negative override count.
var _requested_boss_music: bool = false

# T084 — Tracks whether the phase 2 "tier upgrade" request was
# issued (separately from the _ready request, so we can release
# both slots independently on death / exit).  See _purify and
# _exit_tree for the matching release calls.
var _phase_2_boss_music_requested: bool = false

# T084 — Phase 2 ("enraged") state, entered at half health.
# Tracks the original max health so the half threshold is stable,
# the moment of phase entry so VFX/audio fire exactly once, and
# the per-phase attack state (triple burst, slam).
var _max_health: int = 0
var _phase_2_active: bool = false
var _slam_timer: float = 0.0
const PHASE_2_HEALTH_THRESHOLD: float = 0.5
# Phase 2 tuning (overrides of base @export values when active)
const PHASE_2_PATROL_SPEED_MULT: float = 1.5
const PHASE_2_CHASE_SPEED_MULT: float = 1.6
const PHASE_2_PROJECTILE_COOLDOWN_MULT: float = 0.55
const PHASE_2_PROJECTILES_PER_BURST: int = 3
const PHASE_2_BURST_SPREAD_DEG: float = 18.0
const PHASE_2_SLAM_INTERVAL: float = 4.5
const PHASE_2_SLAM_TELEGRAPH: float = 0.9
const PHASE_2_SLAM_DAMAGE: int = 2
const PHASE_2_SLAM_RADIUS: float = 56.0

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("elite_enemies")
	_start_position = global_position
	_projectile_timer = randf() * projectile_cooldown
	_max_health = health
	_slam_timer = PHASE_2_SLAM_INTERVAL

	if _hurtbox:
		_hurtbox.body_entered.connect(_on_hurtbox_body_entered)

	_update_shield_visuals()

	# T071 — Request boss music when an InkWarden is alive in the
	# scene.  The AudioManagerEnhanced transparently overrides the
	# GFC's standard "archive_exploration" routing until the boss
	# is purified.  Defensive has_method check: AudioManagerEnhanced
	# is an autoload that always exists at runtime, but smoke tests
	# can run without the full autoload chain registered.
	#
	# T080 — Use the per-instance `boss_music_key` (default
	# "archive_boss" for archive_03, "archive_boss_dual" for the
	# InkWardens in archive_04).  AudioManagerEnhanced ref-counts
	# requests so a second boss with the same key is a no-op, and
	# supports tier upgrade if a higher-tier key is requested
	# after a lower one is already active.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("request_boss_music"):
		ame.call("request_boss_music", boss_music_key, 800)
		_requested_boss_music = true

func _exit_tree() -> void:
	# T067 — If we left the scene tree without being purified
	# (e.g. the player left the room mid-fight, the JsonRoom was
	# unloaded, or the room is being reset), release the boss
	# music override we requested in _ready.  Only decrements
	# once per InkWarden instance thanks to _requested_boss_music,
	# so a normal purify() flow isn't double-counted.
	if _requested_boss_music and not _is_purified:
		var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
		if ame and ame.has_method("release_boss_music"):
			ame.call("release_boss_music", 400)
		_requested_boss_music = false
	# T084 — If the phase 2 boss-music upgrade was requested but
	# the boss was never purified (player bailed mid-fight or
	# was killed and the room reset), the phase 2 request slot
	# also needs to be released here.  After _purify, this flag
	# is cleared by _purify itself (so the death-path release
	# there is the only one we run).
	if _phase_2_boss_music_requested and not _is_purified:
		var ame2 := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
		if ame2 and ame2.has_method("release_boss_music"):
			ame2.call("release_boss_music", 400)
		_phase_2_boss_music_requested = false

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	# Apply knockback decay
	_knockback_velocity = _knockback_velocity.lerp(Vector2.ZERO, 4.0 * delta)
	
	if _is_purified:
		velocity.y = -30.0
		velocity.x = _knockback_velocity.x
		move_and_slide()
		return
	
	if _is_stunned:
		_stun_timer -= delta
		velocity.x = _knockback_velocity.x
		velocity.y += get_gravity().y * delta
		velocity.y = minf(velocity.y, 200.0)
		move_and_slide()
		if _stun_timer <= 0:
			_end_stun()
		return
	
	# Update player reference and state logic
	_update_player_detection()
	_update_state(delta)

	# T084 — Slam tick runs only in phase 2 (and only while the
	# boss is actively chasing the player — patrol slams would
	# feel arbitrary).  The slam manages its own telegraph /
	# release timing.
	if _phase_2_active and _state == State.CHASE:
		_tick_slam(delta)
		# If a slam is in its release window, skip movement so
		# the boss visibly plants before the AOE.
		if _slam_timer <= 0.0 and _slam_timer > -PHASE_2_SLAM_TELEGRAPH:
			velocity.x = 0.0
			# Apply gravity / move once, then return.
			velocity.y += get_gravity().y * delta
			velocity.y = minf(velocity.y, 200.0)
			move_and_slide()
			return

	# State-specific behavior
	match _state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.STUNNED:
			pass  # handled above

	# Gravity
	velocity.y += get_gravity().y * delta
	velocity.y = minf(velocity.y, 200.0)

	move_and_slide()

	# Turn around if hitting a wall
	if is_on_wall():
		_patrol_direction *= -1

	# Projectile logic (only when shield is broken)
	if not _shield_active and _state == State.CHASE:
		var cd := projectile_cooldown
		# T084 — phase 2 fires faster (and now in bursts).
		if _phase_2_active:
			cd *= PHASE_2_PROJECTILE_COOLDOWN_MULT
		_projectile_timer -= delta
		if _projectile_timer <= 0:
			_fire_projectile()
			_projectile_timer = cd

func _update_player_detection() -> void:
	var tree := get_tree()
	if not tree:
		return
	_player_ref = tree.get_first_node_in_group("player") as Node2D

func _update_state(delta: float) -> void:
	if not _player_ref:
		_state = State.PATROL
		return
	
	var dist_to_player := global_position.distance_to(_player_ref.global_position)
	var player_in_chase_range := dist_to_player <= chase_range
	var player_in_lose_range := dist_to_player <= lose_interest_range
	
	match _state:
		State.PATROL:
			if player_in_chase_range:
				_state = State.CHASE
		State.CHASE:
			if not player_in_lose_range:
				_state = State.PATROL
		State.STUNNED:
			pass

func _process_patrol(delta: float) -> void:
	var target_x := _start_position.x + _patrol_direction * patrol_range
	var move_dir := signf(target_x - global_position.x)

	# T084 — phase 2 patrol speedup.
	var p_speed := patrol_speed
	if _phase_2_active:
		p_speed *= PHASE_2_PATROL_SPEED_MULT
	velocity.x = move_dir * p_speed + _knockback_velocity.x

	if _sprite:
		_sprite.flip_h = move_dir < 0

	if absf(global_position.x - _start_position.x) >= patrol_range:
		_patrol_direction *= -1

func _process_chase(delta: float) -> void:
	if not _player_ref:
		return

	var chase_dir := signf(_player_ref.global_position.x - global_position.x)

	# T084 — phase 2 chase speedup.
	var c_speed := chase_speed
	if _phase_2_active:
		c_speed *= PHASE_2_CHASE_SPEED_MULT
	velocity.x = chase_dir * c_speed + _knockback_velocity.x

	if _sprite:
		_sprite.flip_h = chase_dir < 0

	# Chase visual: slightly redder
	if _sprite and _sprite.modulate == Color.WHITE:
		_sprite.modulate = Color("#E86D5A").lerp(Color.WHITE, 0.3)

func _fire_projectile() -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return

	# T084 — In phase 2 we fire a 3-spread burst instead of a
	# single projectile.  Center shot aimed at the player; two
	# flank shots at ±BURST_SPREAD_DEG.  Otherwise we keep the
	# single-shot behavior from base.
	if _phase_2_active:
		_fire_burst(player)
		return

	var dir := (player.global_position - global_position).normalized()
	var proj := NoteProjectile.new()
	proj.direction = dir
	proj.speed = projectile_speed
	proj.modulate = Color("#E86D5A")  # coral projectiles
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position + Vector2(0, -16)

# T084 — 3-spread projectile burst (phase 2 exclusive).
# Used to overwhelm Pulse cooldown windows; the spread is wide
# enough that a single dash doesn't trivially dodge all three.
func _fire_burst(player: CharacterBody2D) -> void:
	var aim := (player.global_position - global_position).normalized()
	var base_angle := aim.angle()
	var scene := get_tree().current_scene
	if not scene:
		return
	for i in PHASE_2_PROJECTILES_PER_BURST:
		var offset_idx := i - int(PHASE_2_PROJECTILES_PER_BURST / 2)
		var angle := base_angle + deg_to_rad(PHASE_2_BURST_SPREAD_DEG) * float(offset_idx)
		var dir := Vector2(cos(angle), sin(angle))
		var proj := NoteProjectile.new()
		proj.direction = dir
		proj.speed = projectile_speed * 1.15
		# Slightly darker coral for flank shots to give visual
		# variety vs the center shot.
		if offset_idx == 0:
			proj.modulate = Color("#E86D5A")
		else:
			proj.modulate = Color("#C7503F")
		scene.add_child(proj)
		proj.global_position = global_position + Vector2(0, -16)

func take_damage(amount: int, knockback: Vector2) -> void:
	if _is_dead or _is_purified or _is_stunned:
		return

	if _shield_active:
		shield_health -= amount
		_knockback_velocity = knockback * (1.0 - knockback_resistance)
		_flash_shield()
		# Show shield damage (Glass Cyan, custom "盾" text)
		DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -12), amount, DamageNumber.Kind.SHIELD, "盾")
		if shield_health <= 0:
			_break_shield()
		return

	health -= amount
	_knockback_velocity = knockback * (1.0 - knockback_resistance)

	damaged.emit()

	# Show damage number on hit
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -12), amount, DamageNumber.Kind.DMG)

	if health <= 0:
		_purify()
	else:
		if _sprite:
			_sprite.modulate = Color("#E86D5A")
			await get_tree().create_timer(0.1).timeout
			if _sprite and not _is_dead and not _is_purified and not _is_stunned:
				_sprite.modulate = Color.WHITE

		# T084 — Phase 2 trigger: half health → enraged state.
		# Fired AFTER the damage flash so the player sees the hit
		# land and then the visual escalation.  Guarded so it runs
		# exactly once per InkWarden.
		if not _phase_2_active and float(health) / float(_max_health) <= PHASE_2_HEALTH_THRESHOLD:
			_enter_phase_2()

func _break_shield() -> void:
	_shield_active = false
	shield_broken.emit()

	# Show shield-break notification (Amber Voice, custom "破盾" text)
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -36), 0, DamageNumber.Kind.PURIFY, "破盾")

	# Visual feedback
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_shield_broken.png") as Texture2D
		if tex:
			_sprite.texture = tex
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#E86D5A"), 0.1)
		tween.tween_property(_sprite, "modulate", Color.WHITE, 0.3)
	
	# Shield break VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 40.0)
	
	# Enter stun
	_enter_stun()

func _enter_stun() -> void:
	_is_stunned = true
	_state = State.STUNNED
	_stun_timer = stun_duration
	stunned.emit()
	
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_stunned.png") as Texture2D
		if tex:
			_sprite.texture = tex
		_sprite.modulate = Color.WHITE
	
	# Stun VFX: stars/spiral
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position + Vector2(0, -32), 16.0)

func _end_stun() -> void:
	_is_stunned = false
	_state = State.CHASE
	
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_shield_broken.png") as Texture2D
		if tex:
			_sprite.texture = tex
		_sprite.modulate = Color.WHITE

func _flash_shield() -> void:
	if _shield_vfx:
		_shield_vfx.visible = true
		var tween := create_tween()
		tween.tween_property(_shield_vfx, "modulate:a", 1.0, 0.05)
		tween.tween_property(_shield_vfx, "modulate:a", 0.0, 0.2)
		await tween.finished
		_shield_vfx.visible = false

func _update_shield_visuals() -> void:
	if _shield_vfx:
		_shield_vfx.visible = _shield_active
		# Faint visible shield when active; fully invisible when broken
		_shield_vfx.modulate.a = 0.6 if _shield_active else 0.0

func _purify() -> void:
	_is_purified = true

	# Stats tracking
	PlayerStats.record_enemy_purified("ink_warden")

	# T071 — Release boss music override when the InkWarden is
	# defeated.  The next GFC state change (e.g. ROOM_TRANSITION
	# → hub) will pick the appropriate track for the new scene.
	# If the room is finished in-place and GFC enters GAME_OVER,
	# stop_music(1200) is the right call.
	#
	# T084 — If phase 2 had bumped the boss music to the higher
	# tier, we issued a SECOND request, so we need a matching
	# second release here.  Otherwise the override count would
	# leak by 1 and the BGM would stay on the boss track.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("release_boss_music"):
		ame.call("release_boss_music", 1200)
		if _phase_2_boss_music_requested:
			ame.call("release_boss_music", 600)
			_phase_2_boss_music_requested = false

	# Show purification number (Amber Voice, custom "净化" text — larger Ink Warden defeat)
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -24), 0, DamageNumber.Kind.PURIFY, "净化")

	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, 32.0)
	
	# Drop multiple shards
	for i in range(3):
		_drop_shard(Vector2(randf_range(-60, 60), randf_range(-140, -100)))
	
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "modulate", Color("#F2B66E"), 0.3)
		tween.tween_property(_sprite, "modulate:a", 0.0, 1.2)
		tween.tween_callback(_finish_death)
	
	if _hurtbox:
		_hurtbox.monitoring = false
	if _collision:
		_collision.disabled = true

func _drop_shard(launch_vel: Vector2) -> void:
	var shard_scene := load("res://src/scenes/resonance_shard.tscn") as PackedScene
	if shard_scene:
		var shard := shard_scene.instantiate() as ResonanceShard
		get_tree().current_scene.add_child(shard)
		shard.global_position = global_position
		shard.launch(launch_vel)
	else:
		GameState.add_shards(1)
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_repair_hint"):
			hud.show_repair_hint("+1◆")

# T084 — Phase 2 entry.  Called once when health drops to half.
# Switches the boss into "enraged" mode: different sprite, brighter
# modulate, faster patrol/chase/projectile cadence, slam attack on
# a timer, and a music tier-up so the BGM escalates alongside the
# visual escalation.  See _physics_process for the slam tick.
func _enter_phase_2() -> void:
	_phase_2_active = true

	# T089 — Phase 2 entry: heaviest screen shake so the player
	# physically feels the escalation.  Decoupled from VFX/audio
	# (which still fire below) so the shake can run independently
	# if those paths fail or in headless mode.
	ScreenShake.shake_preset(ScreenShake.Preset.BOSS_PHASE2)

	# Visual: swap to the phase 2 sprite and tint.
	if _sprite:
		var tex := load("res://assets/enemies/ink_warden/ink_warden_phase2.png") as Texture2D
		if tex:
			_sprite.texture = tex
		var tween := create_tween()
		# Punch red first, settle to a slight red wash.
		tween.tween_property(_sprite, "modulate", Color("#E86D5A"), 0.08)
		tween.tween_property(_sprite, "modulate", Color("#FF6E5A").lerp(Color.WHITE, 0.35), 0.4)

	# Phase transition VFX: a larger repair-style flash with extra
	# coral rings so the escalation reads even on the first frame.
	for i in range(3):
		var vfx := RepairVFX.new()
		get_tree().current_scene.add_child(vfx)
		# Stagger radius so the rings don't perfectly overlap.
		vfx.trigger(global_position, 28.0 + float(i) * 10.0)

	# Audio: BGM tier upgrade via the same AudioManagerEnhanced
	# override API used by the per-instance boss_music_key, but
	# targeting the higher tier.  T107 — request tier-3
	# "archive_storm" (chaos + oppression) instead of
	# "archive_boss_dual" (intensity).  AudioManagerEnhanced will
	# tier-upgrade: if the boss is single (default "archive_boss"
	# key, tier 1), it swaps to tier 3; if already on
	# archive_boss_dual (tier 2), it upgrades to tier 3; if
	# already on archive_storm (tier 3), it is a no-op.  Defensive
	# has_method check to keep headless / unit tests runnable
	# without autoloads.
	#
	# Ref-count note: this is a second request on top of the
	# one issued in _ready.  Both _purify and _exit_tree are
	# responsible for releasing exactly one boss-music slot
	# (covered by the _phase_2_boss_music_requested flag), so
	# the boss_music override count balances back to 0 when
	# this InkWarden is fully gone.
	var ame := get_tree().root.get_node_or_null("AudioManagerEnhanced") as Node
	if ame and ame.has_method("request_boss_music"):
		ame.call("request_boss_music", "archive_storm", 600)
		# Track the extra request separately from the _ready
		# request, so death/exit cleanup can release both.
		_phase_2_boss_music_requested = true

	# Damage notification so the player gets a clear "phase shift"
	# cue separate from the regular damage number.
	DamageNumber.spawn(get_tree().current_scene, global_position + Vector2(0, -48), 0, DamageNumber.Kind.PURIFY, "怒")

# T084 — Slam attack tick.  Only runs in phase 2.  Every
# PHASE_2_SLAM_INTERVAL the boss briefly stops, telegraphs a
# ground slam (coral flash on the sprite), and on release damages
# all players in a SLAM_RADIUS circle around the boss.  The
# telegraph window is 0.9s so the player can dash out before the
# damage frame.  Returns the player to chase once the slam ends.
func _tick_slam(delta: float) -> void:
	_slam_timer -= delta
	if _slam_timer > 0.0:
		return
	if _slam_timer > -PHASE_2_SLAM_TELEGRAPH:
		# Telegraph: blink the boss, no movement override yet.
		if _sprite and fmod(_slam_timer * 8.0, 1.0) < 0.0:
			_sprite.modulate = Color("#E86D5A")
		elif _sprite:
			_sprite.modulate = Color.WHITE
		# Don't actually fire on the first frame of telegraph
		# (so the first slam is a full PHASE_2_SLAM_INTERVAL
		# after phase entry, not immediate).
		return
	# Slam release frame.
	_apply_slam_damage()
	# Burst VFX
	var vfx := RepairVFX.new()
	get_tree().current_scene.add_child(vfx)
	vfx.trigger(global_position, PHASE_2_SLAM_RADIUS)
	# Reset timer for next slam.
	_slam_timer = PHASE_2_SLAM_INTERVAL
	if _sprite:
		_sprite.modulate = Color.WHITE

func _apply_slam_damage() -> void:
	var tree := get_tree()
	if not tree:
		return
	var player := tree.get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	var dist := global_position.distance_to(player.global_position)
	if dist > PHASE_2_SLAM_RADIUS:
		return
	if not player.has_method("take_damage"):
		return
	var kb := (player.global_position - global_position).normalized() * 140.0
	player.take_damage(PHASE_2_SLAM_DAMAGE, kb)

func _finish_death() -> void:
	_is_dead = true
	died.emit()
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if _is_dead or _is_purified or _is_stunned:
		return
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var knockback_dir := (body.global_position - global_position).normalized()
			body.take_damage(contact_damage, knockback_dir * 120.0)

func repel(force: Vector2) -> void:
	_knockback_velocity += force
