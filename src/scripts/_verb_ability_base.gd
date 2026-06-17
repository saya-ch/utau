class_name VerbAbilityBase
extends Node

# D002.B (#98) — Common base class for the 5 verb ability scripts
# (PulseAbility / BindAbility / CutAbility / EchoAbility /
# ResonanceWaveAbility).  Extracts the byte-identical cooldown +
# windup-state + cost-consume + _exit_tree code that was copied
# across all 5 ability files since F007 #87 + T173 #92 + T181 #97.
# A future 6th-verb addition now inherits the contract via `extends`
# rather than copy-paste, and refactors of the shared contract have
# one canonical place to land.
#
# Why a true base class (vs a helper script):
#   - A helper script would have to be called as a static function or
#     autoload, losing access to `self._cooldown_timer` /
#     `self._windup_vfx` / `self.fade_out_and_free()`.  A `Node`
#     parent lets us own the per-instance shared state and expose
#     it to subclass overrides naturally.
#   - Verb-specific state (verb radius, verb cost, verb damage),
#     verb-specific @exports (cooldown / windup_time / radius), and
#     verb-specific methods (`can_X` / `start_X` / `_execute_X`)
#     remain in the subclasses — this base only owns the *contract*
#     shared by all 5 abilities.
#
# Lifecycle contract (subclasses MUST call `super._ready()` and
# `super._exit_tree()` from their overrides):
#   1. `_ready()`: parent resolves `_player` via @onready
#      (get_parent() as CharacterBody2D) and asserts non-null.
#      Subclasses call `super._ready()` first, then add verb-specific
#      perk application (pulse_radius_bonus / echo_radius_bonus /
#      wave_radius_bonus / damage_bonus).
#   2. `_process(delta)`: parent does NOT auto-call _process; each
#      subclass owns its own _process body.  Subclasses opt into
#      the T181 cooldown jingle by calling
#      `_process_cooldown(delta, verb_name)` from their _process —
#      fires the ascending-major-3rd (or other interval) jingle when
#      the timer crosses from >0 to <=0.
#   3. `_exit_tree()`: parent fades out `_windup_vfx` via
#      `fade_out_and_free()` (T173 #92) and nulls the handle.  This
#      hook was MISSING in the original Wave (#92 T173.C fix added
#      it explicitly); consolidating it in the base means the 6th
#      verb can't forget the cleanup.
#
# Pattern source: each verb's `_consume_verb_cost()` /
# `_setup_windup_state()` / `_exit_tree()` / cooldown + jingle guard
# was byte-identical (verified #87 / #92 / #97 reviews by grep
# across the 5 files), so the base now provides one canonical copy.
# The T181 cooldown jingle was byte-identical except for the verb
# name string, consolidated into `_process_cooldown(delta, verb_name)`.

# ---- Common state (owned by the base, shared by all 5 abilities) ----
# Subclasses must NOT redeclare these (would shadow the base's state
# and break the lifecycle contract).  Verb-specific state (verb
# radius / verb cost / verb damage) lives in each subclass.

var _cooldown_timer: float = 0.0
var _windup_timer: float = 0.0
var _is_winding_up: bool = false
var _pending_origin: Vector2 = Vector2.ZERO
var _pending_direction: Vector2 = Vector2.ZERO
# T166 (#85) + T167 (#86) + T168 (#86) + T169 (#87) + T173.C (#92) —
# Live handle to the pre-verb windup VFX so _execute_*() can free
# it the instant the fire VFX takes over (avoids a 1-frame overlap).
# Null when no windup is active.  Mirrored across all 5 verb
# abilities since #92 T173.C.  The base's _exit_tree() handles
# fade_out_and_free() uniformly.
var _windup_vfx: Node2D = null

# ---- Common @onready ----
# All 5 verb abilities are children of the player node (verified by
# scene structure; see data/player.tscn).  Resolved at scene load
# via get_parent() as CharacterBody2D.  Asserted non-null in
# _ready() so a mis-parented ability surfaces immediately.
@onready var _player: CharacterBody2D = get_parent() as CharacterBody2D

# ---- Common @export defaults ----
# Verb-specific subclasses override these (Pulse @export cooldown = 0.5
# / windup_time = 0.10; Bind = 1.2 / 0.1; Cut = 0.8 / 0.06; Echo = 4.0
# / 0.08; Wave = 6.0 / 0.10).  The base provides safe defaults so the
# get_cooldown_ratio() and _setup_windup_state() methods can reference
# the field names without Godot 4 static analysis flagging "Field not
# declared".  Subclass @exports win for the actual gameplay values.
var cooldown: float = 0.5
var windup_time: float = 0.10

func _ready() -> void:
	# Base initialization — subclasses call super._ready() and add
	# verb-specific perk application after.  The type-check is
	# enforced here so any mis-parented ability surfaces at boot
	# with a clear assertion message (verb-specific subclasses
	# inherit this check for free, with a single shared error msg).
	assert(_player != null, "VerbAbilityBase subclass must be child of CharacterBody2D")

# T181 (#97) — Cooldown decrement + "ready" jingle guard.  Subclasses
# call this from their own _process(delta) before any verb-specific
# processing.  When the timer crosses from >0 to <=0 this frame,
# fires the ascending jingle (Pulse=A4→C5, Bind=C5→E5, Cut=E5→G5,
# Echo=G5→A5, Wave=A5→C6) so the player gets a discrete "verb is
# back!" cue without staring at the HUD.  The cross-from-positive
# guard (previous frame > 0, this frame <= 0) prevents the jingle
# from firing on every frame the cooldown is already 0 (which would
# spam on the first frame after scene load).  AudioManagerEnhanced
# is the 5-verb autoload — `is null` guard not needed in normal
# play but `has_method` keeps headless tests runnable.
func _process_cooldown(delta: float, verb_name: String) -> void:
	if _cooldown_timer <= 0:
		return
	_cooldown_timer -= delta
	if _cooldown_timer <= 0:
		if AudioManagerEnhanced and AudioManagerEnhanced.has_method("play_verb_cooldown_ready"):
			AudioManagerEnhanced.play_verb_cooldown_ready(verb_name)

# F007 (#87) — Shared cost-consumption step.  Returns true if cost
# was paid, false if the GameState autoload is missing or resonance
# is insufficient.  Before D002.B (#98), each verb ability carried
# its own byte-identical copy (GDScript no-cross-script-inheritance
# limitation at the time); after, the base provides the canonical
# copy and subclasses just call `super._consume_verb_cost(cost)`.
# Returns false if GameState autoload is unavailable (headless test
# context) so callers can early-out cleanly.
func _consume_verb_cost(cost: int) -> bool:
	if GameState == null:
		return false
	return GameState.consume_resonance(cost)

# F007 (#87) — Shared windup-state setup step.  Sets the 4 internal
# fields (`_is_winding_up` / `_windup_timer` / `_pending_origin` /
# `_pending_direction`) that `_process()` and `_execute_*()` read
# on the next frame.  Idempotent within a single cast (the verb's
# `can_X()` check at `start_*` entry guarantees we're not already
# winding up).  Reads `windup_time` from the subclass's @export
# (Pulse=0.10, Bind=0.10, Cut=0.06, Echo=0.08, Wave=0.10).
func _setup_windup_state(origin: Vector2, direction: Vector2) -> void:
	_is_winding_up = true
	_windup_timer = windup_time
	_pending_origin = origin
	_pending_direction = direction

# T166 (#85) + T167 (#86) + T168 (#86) + T169 (#87) + T173.C (#92) —
# Clean up the windup VFX if the player / scene is freed mid-windup
# (e.g. on a room transition while the windup tween is still
# ticking).  Without this, the VFX node would stay parented to a
# freed scene and crash on its next _process tick.  Pattern is now
# uniform across the 5 verb abilities — Wave was the last to gain
# the hook in #92 T173.C, and D002.B (#98) consolidates the
# fade_out_and_free() call here so a 6th verb can't forget it.
func _exit_tree() -> void:
	if _windup_vfx and is_instance_valid(_windup_vfx):
		_windup_vfx.fade_out_and_free()
	_windup_vfx = null

# Standard cooldown ratio accessor.  Used by the HUD to draw the
# 4-verb cooldown bars (Coral Pulse / Violet Bind / Amber Cut /
# Cyan Echo) and the Wave cooldown chip.  Reads the subclass's
# `cooldown` @export (overrides the base's default of 0.5).  All
# 5 verb abilities used to carry their own byte-identical copy;
# D002.B (#98) consolidates the formula here.  Returns 0.0 when
# `cooldown <= 0` so an un-configured base default doesn't divide
# by zero.
func get_cooldown_ratio() -> float:
	if cooldown <= 0:
		return 0.0
	return clampf(_cooldown_timer / cooldown, 0.0, 1.0)

# Standard windup-state accessor.  Used by the player input gate
# (PlayerActionGate autoload, D001 #82) to early-out on verb casts
# during Wave's windup (T142 #75 anti-misinput design).  All 5
# verb abilities have this method; the base provides the canonical
# copy since D002.B (#98).
func is_winding_up() -> bool:
	return _is_winding_up
