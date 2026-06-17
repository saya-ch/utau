class_name VerbAbilityBase
extends Node

# D002.B (#98) — Common base class for the 5 verb ability scripts
# (PulseAbility / BindAbility / CutAbility / EchoAbility /
# ResonanceWaveAbility).  Extracts the byte-identical cooldown timer
# + windup-state setup + cost consume + _process + _exit_tree
# fade-out + cooldown jingle from #85-#97 4 verb ability files into a
# single parent.  This is the D002 (Godot 4 multi-script inheritance
# family refactor)推全 after T174.B (#94) validated the pattern on the
# 5 windup VFX files.  If this refactor holds through #98, the
# remaining 5 verb audio / VFX / SFX families can follow the same
# pattern in future rounds.
#
# Why a true base class (vs a helper script / autoload):
#   - Same rationale as T174.B (_verb_windup_vfx_base.gd): Node
#     parent lets us own per-instance state (`_cooldown_timer` /
#     `_windup_timer` / `_is_winding_up` / `_pending_origin` /
#     `_pending_direction` / `_windup_vfx`) and lifecycle hooks
#     (`_process` / `_exit_tree`) on self, no autoload lookup
#     overhead per frame.
#   - Verb-specific state (`_is_active` / `_active_timer` for
#     Echo + Wave, `_current_radius` for Wave, `_reflected_this_cast`
#     for Echo, `wave_combo_threshold` for Wave) and verb-specific
#     logic (`can_X()` / `start_X(...)` / `_execute_X()` /
#     `_spawn_windup_vfx()`) remain in the subclasses — this base
#     only owns the *contract* shared by all 5 verb abilities.
#
# Lifecycle contract (subclasses must call `_setup_windup_state()`
# in their `start_X()` after consuming cost, and implement
# `_execute()` to be called by `_process()` when the windup timer
# reaches 0):
#   1. `start_X()` calls `can_X()` guard (subclass-defined)
#   2. `start_X()` calls `_consume_verb_cost(X_cost)` (base)
#   3. `start_X()` calls `_setup_windup_state(origin, direction)`
#      (base, where direction is `Vector2.ZERO` for omnidirectional
#      verbs like Echo + Wave)
#   4. `start_X()` calls `_spawn_windup_vfx()` (subclass-specific,
#      sets the `_windup_vfx` handle and adds the VFX to the scene)
#   5. `_process()` (base) auto-fires `_execute()` when
#      `_windup_timer` reaches 0
#   6. `_execute()` (subclass) frees `_windup_vfx`, emits the
#      verb's fire signal, plays fire SFX, performs the verb's
#      hit check
#   7. `_exit_tree()` (base) calls `_windup_vfx.fade_out_and_free()`
#      on interrupt (player death, scene change during the 0.04s ~
#      0.10s windup window)
#
# Subclass responsibilities (minimum required overrides):
#   - `@export var cooldown: float` (verb-specific default)
#   - `@export var windup_time: float` (verb-specific default)
#   - `func _get_verb_name() -> String: return "pulse"` (used for the
#     T181 #97 cooldown "ready" jingle — must match the verb name
#     string AudioManagerEnhanced.play_verb_cooldown_ready() expects)
#   - `func can_X() -> bool` (verb-specific, gates the cast)
#   - `func start_X(...) -> bool` (verb-specific signature; pulse /
#     bind / cut take `(origin, direction)`, echo / wave take
#     `(origin)` only because they are omnidirectional)
#   - `func _execute() -> void` (verb-specific, called by base
#     `_process` when windup timer hits 0)
#   - `func _spawn_windup_vfx() -> void` (verb-specific, populates
#     `_windup_vfx` member via `_attach_windup_vfx(vfx_script)`
#     helper + triggers the verb-specific VFX)
#
# Pattern source: each verb's `_consume_verb_cost()` /
# `_setup_windup_state()` / `_exit_tree()` / `get_cooldown_ratio()` /
# `is_winding_up()` were byte-identical (verified by F007 #87 review
# across 4 verbs + #92 review across 5 verbs), so the base now
# provides one canonical copy.  The `_process` cooldown timer +
# cooldown jingle (T181 #97) was also byte-identical across all 5
# verbs (5 verb_name strings differ; the timer logic doesn't), so
# the base provides one canonical copy with `_get_verb_name()`
# virtualizing the only difference.

# Common state — owned by the base, used by `_process` to drive the
# cooldown + windup lifecycle.  Subclasses must NOT redeclare these
# (would shadow the base's state and break the lifecycle contract).
# Mirrors T174.B's `var _max_lifetime` pattern in _verb_windup_vfx_base.gd.
var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO
# T166-T173 — Live handle to the pre-verb windup VFX so `_execute()`
# can free it the instant the verb's fire VFX takes over (avoids a
# 1-frame overlap where both visuals are visible).  Mirrors the
# `pulse_windup_vfx.gd` / `bind_windup_vfx.gd` / `echo_windup_vfx.gd`
# / `cut_windup_vfx.gd` / `wave_windup_vfx.gd` pattern.  The base
# owns the member and the cleanup hooks; subclasses populate it in
# their `_spawn_windup_vfx()`.
var _windup_vfx: Node2D = null

# Verb-specific @export defaults.  Declared here in the base
# (with default 0.0) so the GDScript 4 parser can resolve the
# references to `cooldown` / `windup_time` in `_process` /
# `get_cooldown_ratio` / `_setup_windup_state`.  Per-verb
# defaults are applied in each subclass's `_ready()` via
# `super._ready()` + `cooldown = <verb_default>` + `windup_time =
# <verb_default>` — this is the Godot 4 idiomatic pattern for
# "subclass overrides base @export default" (subclasses may NOT
# redeclare an @export variable that the base already declared;
# they assign to it in code).
#
# Why this works: at runtime, `self.cooldown` resolves to the
# instance's @export value (the base's 0.0 default gets
# overridden by the subclass's _ready assignment).  The
# inspector shows the base's 0.0 default for *new* node
# instances, but the per-verb defaults get applied as soon as
# _ready runs — same observable behaviour as the pre-D002.B
# per-subclass @export defaults (player.tscn doesn't override
# these, so the .tscn values never entered the picture).
#
# This pattern is the same as T174.B's `var _max_lifetime:
# float = 0.10` (base) + subclass assignments in `trigger()` (5
# verb windup VFX scripts) — just the access point is different
# (subclasses here assign via _ready, not in trigger()).
@export var cooldown: float = 0.0
@export var windup_time: float = 0.0

@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	# All 5 verb abilities are child nodes of the player's CharacterBody2D
	# (see player.tscn's verb child nodes).  Asserting at _ready catches
	# misconfiguration early; the previous per-verb `assert(_player != null)`
	# (pulse #85, bind #86, echo #86, cut #87, wave #89) is now
	# centralised in the base.
	assert(_player != null, "VerbAbilityBase must be child of CharacterBody2D")

func _process(delta: float) -> void:
	# T181 (#97 first half) — Cooldown timer countdown + cross-from-
	# positive guard for the "ready" jingle.  Verbatim from the 5
	# original ability `_process` blocks (verified #97 review by grep
	# across 5 files): when the timer crosses from >0 to <=0 this
	# frame, fire the ascending-major-3rd jingle (verb-specific
	# pitch via AudioManagerEnhanced.play_verb_cooldown_ready) so
	# the player gets a discrete "<verb> is back!" cue without
	# staring at the HUD.  The cross-from-positive guard
	# (previous frame > 0, this frame <= 0) prevents the jingle
	# from firing on every frame the cooldown is already 0 (which
	# would spam on the first frame after scene load).
	# AudioManagerEnhanced is the 5-verb autoload (no `is null`
	# guard needed in normal play) but has_method is checked for
	# headless test contexts.
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0:
			if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_verb_cooldown_ready"):
				AudioManagerEnhanced.play_verb_cooldown_ready(_get_verb_name())

	# Windup timer countdown + auto-execute.  Verbatim from the 5
	# original ability `_process` blocks.
	if _is_winding_up:
		_windup_timer -= delta
		if _windup_timer <= 0:
			_execute()

# Cooldown ratio for HUD (`hud.gd:_verb_cooldown` calls this 5 times
# per frame, once per verb).  Byte-identical to the 5 originals.
# Returning 0.0 when `cooldown <= 0` means HUD treats the verb as
# "ready" by default; subclasses that don't expose a cooldown bar
# (none today) just get a no-op.
func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

# Windup state query for `player.gd` `_handle_*` and `PlayerActionGate.is_globally_blocked()`.
# Byte-identical to the 5 originals.
func is_winding_up() -> bool:
	return _is_winding_up

# F007 (#87) — Shared cost-consumption step.  Byte-identical to the
# 5 originals.  Returns true if cost was paid, false if the
# GameState autoload is missing or resonance is insufficient.  The
# `GameState == null` check guards headless test contexts where the
# autoload may not be registered.
func _consume_verb_cost(cost: int) -> bool:
	if GameState == null:
		return false
	return GameState.consume_resonance(cost)

# F007 (#87) — Shared windup-state setup step.  Sets the 4 internal
# fields (plus `_is_winding_up`) that `_process` and the verb's
# `_execute()` read on the next frame.  Idempotent within a single
# cast (the verb's `can_X()` check at `start_X` entry guarantees
# we're not already winding up).
#
# Echo + Wave pass `Vector2.ZERO` for `direction` since they are
# omnidirectional; the field still gets set so the 5 verb classes
# share the same helper signature.
func _setup_windup_state(origin: Vector2, direction: Vector2) -> void:
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction

# T166-T173 (#85-#92) — Clean up the windup VFX if the player / scene
# is freed mid-windup (e.g. on a room transition while the windup
# tween is still ticking).  Without this, the VFX node would stay
# parented to a freed scene and crash on its next `_process` tick.
# T173 (#92) — Switched from hard `queue_free()` to
# `fade_out_and_free()` (0.05s modulate.a 1→0 tween then free).
# Avoids a "hard pop" when the verb is interrupted (player death,
# room transition during the 0.04s ~ 0.10s windup window).  The
# fade_out_and_free() implementation is on each windup VFX (inherited
# from VerbWindupVFXBase per T174.B #94).
func _exit_tree() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.fade_out_and_free()
	_windup_vfx = null

# Helper for subclasses' `_spawn_windup_vfx()` implementations.  The
# "queue_free leaked → create new → add to scene" sequence was
# byte-identical across the 4 directional verbs (pulse / bind /
# echo / cut) per F007 + T166-T169 review; Wave (#89 T171) had a
# different ordering ("create → trigger → add → assign") which is
# actually a latent bug because `create_tween()` is called on a
# node not yet in the scene tree.  The new unified pattern
# ("queue_free old → add new to scene → subclass triggers") avoids
# the Wave latent bug and matches the 4-verb canonical form.  The
# subclass must call `_windup_vfx.trigger(...)` AFTER this helper
# (so the node is in the tree before `_activate_windup_tween` calls
# `create_tween`).
func _attach_windup_vfx(vfx_script: GDScript) -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		# Defensive: free a leaked previous instance (shouldn't
		# happen since start_X rejects if can_X()==false, but
		# cheap insurance against state corruption).
		_windup_vfx.queue_free()
	_windup_vfx = vfx_script.new()
	var scene := get_tree().current_scene
	if scene:
		scene.add_child(_windup_vfx)

# Virtual — subclass MUST override to return the verb name string
# used by AudioManagerEnhanced.play_verb_cooldown_ready() and
# PlayerStats.record_ability_used().  Returning "" is a no-op (the
# cooldown jingle silently skips, the ability stats record with
# an empty key — both are bugs, not crashes).  The 5 expected
# values are "pulse" / "bind" / "cut" / "echo" / "wave".
func _get_verb_name() -> String:
	return ""

# Virtual — subclass MUST implement.  Called by the base's
# `_process` when the windup timer reaches 0.  Subclass is
# responsible for:
#   1. Freeing `_windup_vfx` (queue_free, NOT fade_out_and_free —
#      _exit_tree handles the interrupt path; _execute is the
#      happy path)
#   2. Setting `_cooldown_timer = cooldown` to start the cooldown
#   3. Setting `_is_winding_up = false`
#   4. Emitting the verb's fire signal
#   5. Calling `AudioManagerEnhanced.play_<verb>()` (T181 #97)
#   6. Performing the verb's hit check (`_perform_*_hit_check()`)
func _execute() -> void:
	pass

# Virtual — subclass MUST implement.  Called by `start_X()` after
# `_setup_windup_state()` to spawn the verb's pre-fire windup VFX.
# The canonical pattern is:
#   _attach_windup_vfx(preload("res://src/scripts/<verb>_windup_vfx.gd"))
#   _windup_vfx.trigger(_pending_origin, <verb>_radius * 0.5, windup_time)
# (Echo passes a 4th arg to `trigger`; Cut passes `direction` as
# the 3rd arg; the others are 3-arg `trigger`.)
func _spawn_windup_vfx() -> void:
	pass
