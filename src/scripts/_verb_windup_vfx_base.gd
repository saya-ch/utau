class_name VerbWindupVFXBase
extends Node2D

# T174.B (#94) — Common base class for the 5 verb windup VFX scripts
# (PulseWindupVFX / BindWindupVFX / CutWindupVFX / EchoWindupVFX /
# WaveWindupVFX).  Extracts the byte-identical lifetime tracking +
# ramp-in tween + fade-out tween code from #85 T166 + #86 T167 T168 +
# #87 T169 + #89 T171 + #92 T173 + #93 T174 into a single parent so
# future 6th-verb additions inherit the contract by `extends` rather
# than copy-paste.
#
# Why a true base class (vs a helper script):
#   - Helper script would have to be called as a static function or
#     autoload, losing access to `self.modulate` / `create_tween()` /
#     `queue_free()`.  A `Node2D` parent lets us own the per-instance
#     state (`_lifetime` / `_max_lifetime` / `_active`) and the
#     tween/fade lifecycle on `self`.
#   - Verb-specific state (`_radius`, `_direction`, `_start_scale`,
#     `_end_scale`, etc.) and verb-specific `_draw()` rendering
#     remain in the subclasses — this base only owns the *contract*
#     shared by all 5 windups.
#
# Lifecycle contract (subclasses must call `_activate_windup_tween()`
# in their `trigger()` after setting verb-specific state):
#   1. trigger() sets verb-specific state (radius / direction / etc.)
#   2. trigger() calls `_activate_windup_tween()` to:
#      - reset _lifetime / _active
#      - start the ramp-in modulate:a tween (T174 #93)
#      - call queue_redraw() so the first frame renders
#   3. _process() auto-frees after _max_lifetime (safety net)
#   4. fade_out_and_free() (T173 #92) is called by parent ability's
#      _exit_tree() on interrupts (scene change / death); performs
#      0.05s modulate:a 1.0→0.0 tween then queue_free().
#
# Pattern source: each verb's `fade_out_and_free()` was byte-identical
# (verified #92 review by grep across 5 files), so the base now
# provides one canonical copy.  The ramp-in tween code (T174 #93) is
# also byte-identical (modulate.a=0.0 + create_tween + TRANS_QUAD
# EASE_OUT + tween_property 1.0 over _max_lifetime), consolidated
# into `_activate_windup_tween()`.

# Common state — owned by the base, used by `_process` to drive the
# auto-free safety net.  Subclasses must NOT redeclare these (would
# shadow the base's state and break the lifetime contract).
var _max_lifetime: float = 0.10
var _lifetime: float = 0.0
var _active: bool = false

func _ready() -> void:
	# All 5 verb windups render above the world (player/sprites) but
	# below the HUD (z_index ≥ 10+).  Centralised here so adding a
	# 6th verb only needs to extend this base, not remember the rule.
	z_index = 10

func _process(delta: float) -> void:
	# Lifetime tracking + auto-free safety net.  Verbatim from the
	# 5 original windup VFX scripts (PulseWindupVFX._process etc.):
	# when the parent ability's _execute_*() runs (firing the verb),
	# the windup VFX is freed there; if something interrupts before
	# that (e.g. scene change mid-windup, player death) the parent's
	# _exit_tree() calls fade_out_and_free(); this _process path is
	# the *third* safety net for the rare case where neither fires
	# (paused frame, etc.).
	if not _active:
		return
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_active = false
		queue_free()
		return
	queue_redraw()

# Common ramp-in activation.  Subclasses call this in their
# `trigger()` after setting verb-specific state (radius / direction
# / etc.) and updating `_max_lifetime` (the tween duration reads
# `_max_lifetime` so any windup_time tuning flows through
# automatically).  This is the T174 (#93) contract consolidated.
func _activate_windup_tween() -> void:
	_lifetime = 0.0
	_active = true
	# Initial alpha 0 so the tween has a deterministic start point;
	# the tween below ramps it back to 1.0 over _max_lifetime.
	modulate.a = 0.0
	# T174 (#93) — TRANS_QUAD EASE_OUT front-loads the visibility so
	# the windup reads as "ring fades in quickly then settles" even
	# on the 0.04s Cut windup (the shortest of the 5 verbs).
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, _max_lifetime)
	queue_redraw()

# T173 (#92) — 0.05s fade-out tween then queue_free().  Byte-identical
# to the 5 original `fade_out_and_free()` implementations (verified
# by the #92 review).  Called by the parent ability's `_exit_tree()`
# when the player / scene is freed mid-windup.  The 0.05s duration
# is short enough to vanish before the next room loads (room
# transitions are ≥0.4s) but long enough to mask the abrupt
# _exit_tree with a smooth alpha decay.
#
# Idempotent: if fade_out_and_free is called twice, the second call
# short-circuits via `_active` (the queue_free at end of _process is
# the safety net for the still-active case; the tween path is the
# primary exit during interrupts).
func fade_out_and_free() -> void:
	if not _active:
		# Already fading or never triggered — nothing to do, just free.
		queue_free()
		return
	_active = false  # stop _process from racing the tween
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	tween.tween_callback(queue_free)
