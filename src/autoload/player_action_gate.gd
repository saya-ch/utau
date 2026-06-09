# D001 (#82) — Player action gate autoload.
#
# Single source of truth for "should player input be suppressed this
# frame?".  Replaces the duplicated / spread-out check that lived in:
#   - player.gd :: is_action_globally_blocked()  (T145 #76 composite:
#     _is_dying OR wave_ability.is_globally_blocking())
#   - resonance_wave_ability.gd :: is_globally_blocking()  (T142 #75
#     predicate: _is_winding_up)
#
# Why an autoload:
#   * Future "stun" / "pause" / "cutscene" conditions can be OR'd in
#     here, in ONE place, without touching every call site.
#   * Boss scripts / cutscene scripts can probe the same gate without
#     reaching into player internals.
#   * The wave ability's "winding up" check stays where the data
#     lives (resonance_wave_ability.gd) — we delegate, we don't
#     shadow.
#
# Registration:  the active player calls `register_player(self)` in
# its _ready() and `unregister_player(self)` in _exit_tree().  In a
# normal play session exactly one player is registered at a time;
# the autoload tolerates a transient null (scene transitions).
#
# This is a Node, not a static class, because:
#   1. autoload Nodes are cheap and Godot-idiomatic (matches
#      SaveSystem / GameState / PlayerStats patterns).
#   2. future state (e.g. "global stun timer") can be added as
#      member vars without changing the API.
extends Node

# The currently registered player.  Weak-typed (Node) so this
# autoload can compile / parse without a hard dependency on
# `Player.gd`'s class_name resolution order.  Callers in player.gd
# cast as needed via `.has_method` probes.
var _player: Node = null

func register_player(p: Node) -> void:
	# Idempotent: last-registered wins.  Defensive against scene
	# transitions where a stale player might still hold a callback.
	_player = p

func unregister_player(p: Node) -> void:
	# Only clear if THIS player is the registered one — avoids a
	# late _exit_tree() from the old scene wiping out a freshly
	# loaded player's registration.
	if _player == p:
		_player = null

# === Public API ===

# Composite blocking check.  Returns true if any of the following
# are true:
#   1. _is_dying (T075) — the 0.5s death lay-down + 1.0s fade-out
#      window where the player should not be able to fire verbs /
#      jump.
#   2. wave_ability.is_globally_blocking() (T142) — the 0.10s wave
#      windup where the other 4 verbs (and jump) must be ignored
#      to prevent double-cast chains.
#   3. (future) stun / pause / cutscene flags — added here, not
#      at every call site.
# Returns false (no blocking) when:
#   * no player is registered yet (early frame in tests), or
#   * the player hasn't wired a wave_ability (headless tests).
func is_blocked() -> bool:
	if _player == null:
		return false
	# Probe 1: _is_dying (private var; we read via the property
	# accessor if it exists, else skip — defensive against renamed
	# player scripts in test mocks).
	if _player.get("_is_dying") == true:
		return true
	# Probe 2: wave windup.  The wave ability's own is_globally_blocking
	# is the canonical source for "_is_winding_up" — we delegate, not
	# shadow.
	var wave_ability: Node = _player.get("wave_ability")
	if wave_ability == null:
		return false
	if not wave_ability.has_method("is_globally_blocking"):
		return false
	return bool(wave_ability.call("is_globally_blocking"))

# Convenience: returns the registered player (or null).  Useful
# for boss / cutscene scripts that want to inspect / play with
# the player without a hard Player-class import.
func get_player() -> Node:
	return _player
