extends Node

# Autoload singleton: central manager for camera shake effects.
#
# T089 — Replaces 5 ad-hoc tween blocks scattered across
# `player.gd` (pulse-fired / bind-fired / cut-fired / take-damage) and
# `ability_gate.gd` (blocked attempt) with a single central manager.
#
# Why a manager:
#   1. Concurrent shakes (e.g. player takes damage while a Pulse
#      expands to the same frame) used to fight — each new tween
#      overwrote the previous camera.offset, killing the perceptual
#      "punch" of the older shake. With a manager the contributions
#      are summed across frames.
#   2. Designer-facing Preset enum: magnitude + duration are tuned
#      in one place instead of by per-call pixel numbers, so future
#      changes (e.g. "PULSE should be a bit heftier") are a one-line
#      edit.
#   3. Decoupled from `Camera2D.global_position` smoothing — the
#      follow script writes global_position every frame, but the
#      shake is applied to `camera.offset` which is summed on top
#      of the smoothed position, so the look-ahead and the shake
#      never trample each other.

signal shook

enum Preset {
	PULSE,	# 1.4 — soft tap on Pulse fired
	BIND,		# 0.8 — subtle pull on Bind fired
	CUT,		# 1.0 — sharp tap on Cut fired
	HIT,		# 2.2 — player damage shake
	DEATH,	# 3.0 — long low-freq shake on player death
	BOSS,		# 2.4 — InkWarden shield break / boss hit
	HEAVY,	# 3.6 — InkWarden purify (room-sized)
}

const _MAGNITUDE: Dictionary = {
	Preset.PULSE: 1.4,
	Preset.BIND: 0.8,
	Preset.CUT: 1.0,
	Preset.HIT: 2.2,
	Preset.DEATH: 3.0,
	Preset.BOSS: 2.4,
	Preset.HEAVY: 3.6,
}

const _DURATION: Dictionary = {
	Preset.PULSE: 0.10,
	Preset.BIND: 0.08,
	Preset.CUT: 0.08,
	Preset.HIT: 0.18,
	Preset.DEATH: 0.40,
	Preset.BOSS: 0.18,
	Preset.HEAVY: 0.45,
}

# Active shake entries: {remaining: float, magnitude: float, duration: float}
var _active_shakes: Array = []
var _current_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Run even while paused so screen-shake feedback is visible during
	# pause / settings menus. Without this, a shake that started right
	# before opening the menu would freeze at the random offset.
	process_mode = Node.PROCESS_MODE_ALWAYS

## Public API — request a shake by intent (preset).
func add(preset: Preset) -> void:
	var mag: float = _MAGNITUDE.get(preset, 1.0)
	var dur: float = _DURATION.get(preset, 0.1)
	add_trauma(mag, dur)

## Public API — request a custom shake (designer-tested escape hatch).
## Magnitude is in pixels; duration in seconds.
func add_trauma(magnitude: float, duration: float) -> void:
	if magnitude <= 0.0 or duration <= 0.0:
		return
	_active_shakes.append({
		"remaining": duration,
		"magnitude": magnitude,
		"duration": duration,
	})
	shook.emit()

## Public API — cancel all active shakes. Useful when the player
## dies and we don't want lingering noise from a prior room.
func reset() -> void:
	_active_shakes.clear()
	_apply_offset(Vector2.ZERO)

func _process(delta: float) -> void:
	if _active_shakes.is_empty():
		if _current_offset != Vector2.ZERO:
			_apply_offset(Vector2.ZERO)
		return

	var total := Vector2.ZERO
	var i := 0
	while i < _active_shakes.size():
		var s: Dictionary = _active_shakes[i]
		s["remaining"] -= delta
		if s["remaining"] <= 0.0:
			_active_shakes.remove_at(i)
		else:
			# Linear decay: shake starts at full magnitude and fades
			# to 0 over the duration. Random direction per axis per
			# frame gives the classic "earthquake" feel.
			var t: float = s["remaining"] / s["duration"]  # 1.0 → 0.0
			var mag: float = s["magnitude"] * t
			total.x += randf_range(-mag, mag)
			total.y += randf_range(-mag, mag)
			i += 1

	_apply_offset(total)

func _apply_offset(offset: Vector2) -> void:
	_current_offset = offset
	var camera := get_tree().get_first_node_in_group("camera") as Camera2D
	if camera:
		camera.offset = offset
