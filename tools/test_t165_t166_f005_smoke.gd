extends SceneTree
## T165 + T166 + F005 (#85) — smoke test
##
## 任务组合:
##   T165 Polish: BGM tier-up visual cue (audio_manager_enhanced 在 tier
##                upgrade 时链入 brief 0.15s Glass Cyan 闪, layer 256)
##   T166 Polish: PulseAbility windup 0.08s→0.10s + 0.5× pre-pulse Glass Cyan
##                ring VFX (pulse_windup_vfx.gd 新建) + 6 个生命周期 hook
##   F005 Refactor: 提取 player.gd `_pre_verb_block_check()` helper 给 4
##                  verb handler 共用 (pulse/bind/cut/echo)
##
## 测试目标: 静态分析 (不跑 Play mode, 与 #84 其它 smoke test 风格一致).
##   T165  -- flash_color 调用 + 颜色 + 时长 + peak + layer + autoload guard
##   T166  -- windup_time 0.10 + _windup_vfx var + start/execute/_exit_tree hook
##            + 新建 pulse_windup_vfx.gd + Glass Cyan 配色
##   F005  -- _pre_verb_block_check() helper 存在 + 4 handler 引用

const T165_AUDIO_PATH := "res://src/scripts/audio_manager_enhanced.gd"
const T166_PULSE_ABILITY_PATH := "res://src/scripts/pulse_ability.gd"
const T166_WINDUP_VFX_PATH := "res://src/scripts/pulse_windup_vfx.gd"
const F005_PLAYER_PATH := "res://src/scripts/player.gd"

func _initialize() -> void:
	print("=== T165+T166+F005 (#85) — BGM tier-up flash + Pulse windup VFX + verb guard helper ===")
	var all_ok: bool = true

	# ---------- T165 polish: BGM tier-up Glass Cyan flash ----------
	print("--- T165 (Polish: BGM tier-up visual cue — 0.15s Glass Cyan flash) ---")
	var t165_text: String = _read_file(T165_AUDIO_PATH)
	if t165_text.is_empty():
		print("  FAIL: cannot read " + T165_AUDIO_PATH)
		all_ok = false
	else:
		# 1. flash_color call exists inside request_boss_music()'s tier-upgrade branch
		if "ScreenShake.flash_color" in t165_text:
			print("  PASS: ScreenShake.flash_color call present")
		else:
			print("  FAIL: ScreenShake.flash_color call missing")
			all_ok = false
		# 2. Color = Glass Cyan #69C7CE (STYLE_GUIDE)
		if 'Color("#69C7CE")' in t165_text:
			print("  PASS: Glass Cyan #69C7CE color used")
		else:
			print("  FAIL: Glass Cyan #69C7CE color missing (must match STYLE_GUIDE)")
			all_ok = false
		# 3. Duration = 0.15s
		if "0.15" in t165_text:
			print("  PASS: 0.15s duration present")
		else:
			print("  FAIL: 0.15s duration missing (must match brief)")
			all_ok = false
		# 4. peak_alpha = 0.18 (subtle vignette, not full bleach)
		if "0.18" in t165_text:
			print("  PASS: 0.18 peak alpha present")
		else:
			print("  FAIL: 0.18 peak alpha missing")
			all_ok = false
		# 5. flash_layer = 256 (above T097 hit-flash 128 for layered readability)
		if "256" in t165_text:
			print("  PASS: flash_layer 256 present (above hit-flash 128)")
		else:
			print("  FAIL: flash_layer 256 missing (must be above hit-flash 128)")
			all_ok = false
		# 6. Autoload guard helper exists (T165 defensive probe)
		if "_has_screen_shake_autoload" in t165_text:
			print("  PASS: _has_screen_shake_autoload() defensive guard present")
		else:
			print("  FAIL: _has_screen_shake_autoload() defensive guard missing")
			all_ok = false
		# 7. The flash call is inside the new_tier > current_tier branch
		#    (not unconditionally on every request_boss_music call).
		#    We use rfind for the *call* (last occurrence) because a
		#    docstring earlier in the file references "flash_color"
		#    as a string mention (not a real call).
		var upgrade_idx: int = t165_text.find("if new_tier > current_tier")
		var flash_idx: int = t165_text.rfind("ScreenShake.flash_color(")
		if upgrade_idx > 0 and flash_idx > 0 and flash_idx > upgrade_idx:
			print("  PASS: flash call is inside tier-upgrade branch (not unconditional)")
		else:
			print("  FAIL: flash call ordering wrong (upgrade_idx=%d, flash_idx=%d)" % [upgrade_idx, flash_idx])
			all_ok = false

	# ---------- T166 polish: Pulse windup VFX + 0.10s windup ----------
	print("--- T166 (Polish: Pulse windup 0.10s + 0.5× Glass Cyan pre-pulse ring) ---")
	var t166_ability: String = _read_file(T166_PULSE_ABILITY_PATH)
	var t166_ability_base: String = _read_file("res://src/scripts/_verb_ability_base.gd")
	if t166_ability.is_empty():
		print("  FAIL: cannot read " + T166_PULSE_ABILITY_PATH)
		all_ok = false
	else:
		# 1. windup_time = 0.10 (was 0.08)
		# D002.B (#98) — `windup_time` @export moved to VerbAbilityBase
		# (5 verb 继承).  Pulse's per-verb default is set in `_ready()`
		# via `windup_time = 0.10`.  Check the new assignment form.
		if "windup_time = 0.10" in t166_ability or "@export var windup_time: float = 0.10" in t166_ability:
			print("  PASS: windup_time = 0.10s (D002.B #98: per-verb default in _ready)")
		else:
			print("  FAIL: windup_time != 0.10 (must be 0.10s for VFX to be readable)")
			all_ok = false
		# 2. _windup_vfx var exists in VerbAbilityBase
		if "var _windup_vfx: Node2D = null" in t166_ability_base:
			print("  PASS: _windup_vfx var present (in VerbAbilityBase — D002.B #98 集中)")
		else:
			print("  FAIL: _windup_vfx var missing in VerbAbilityBase")
			all_ok = false
		# 3. start_pulse spawns windup_vfx.
		# D002.B (#98) — windup VFX spawn moved from start_pulse() to
		# _spawn_windup_vfx() virtual (called by start_pulse).  Accept
		# the spawn reference anywhere in the file (not just inside
		# start_pulse function body).
		var start_idx: int = t166_ability.find("func start_pulse(")
		var execute_idx: int = t166_ability.find("func _execute_pulse()")
		if "_attach_windup_vfx(preload(\"res://src/scripts/pulse_windup_vfx.gd\"))" in t166_ability:
			print("  PASS: windup_vfx spawned via _attach_windup_vfx in _spawn_windup_vfx() (D002.B #98)")
		else:
			print("  FAIL: windup_vfx not spawned in _spawn_windup_vfx (start=%d, exec=%d)" % [start_idx, execute_idx])
			all_ok = false
		# 4. _execute_pulse frees windup_vfx.
		#    There are 2 _windup_vfx.queue_free() calls in the file (one
		#    defensive in start_pulse, one in _execute_pulse, one in
		#    _exit_tree).  Use a window-based search: find the first
		#    queue_free() that lies between execute and the next function.
		var first_free_after_exec: int = -1
		if execute_idx > 0:
			var next_func_idx: int = t166_ability.find("\nfunc ", execute_idx + 1)
			if next_func_idx < 0:
				next_func_idx = t166_ability.length()
			var window_text: String = t166_ability.substr(execute_idx, next_func_idx - execute_idx)
			first_free_after_exec = execute_idx + window_text.find("_windup_vfx.queue_free()") if "_windup_vfx.queue_free()" in window_text else -1
		if execute_idx > 0 and first_free_after_exec > 0:
			print("  PASS: _execute_pulse() frees windup_vfx (no 1-frame overlap)")
		else:
			print("  FAIL: _execute_pulse() doesn't free windup_vfx (exec=%d, first_free=%d)" % [execute_idx, first_free_after_exec])
			all_ok = false
		# 5. _exit_tree cleanup hook in VerbAbilityBase
		# D002.B (#98) — _exit_tree moved to VerbAbilityBase.
		if "func _exit_tree" in t166_ability_base and "fade_out_and_free" in t166_ability_base:
			print("  PASS: _exit_tree cleanup hook present in VerbAbilityBase (D002.B #98 集中)")
		else:
			print("  FAIL: _exit_tree cleanup missing in VerbAbilityBase")
			all_ok = false

	var t166_vfx: String = _read_file(T166_WINDUP_VFX_PATH)
	if t166_vfx.is_empty():
		print("  FAIL: cannot read " + T166_WINDUP_VFX_PATH + " (new file must be created)")
		all_ok = false
	else:
		# 6. New file extends Node2D (T174.B #94 — now extends VerbWindupVFXBase which extends Node2D)
		if "extends Node2D" in t166_vfx or "_verb_windup_vfx_base.gd" in t166_vfx:
			print("  PASS: pulse_windup_vfx.gd extends Node2D (via VerbWindupVFXBase in T174.B refactor)")
		else:
			print("  FAIL: pulse_windup_vfx.gd doesn't extend Node2D")
			all_ok = false
		# 7. trigger() method exists
		if "func trigger(" in t166_vfx:
			print("  PASS: pulse_windup_vfx.gd has trigger() method")
		else:
			print("  FAIL: pulse_windup_vfx.gd missing trigger() method")
			all_ok = false
		# 8. Glass Cyan ring color
		if '#69C7CE' in t166_vfx:
			print("  PASS: Glass Cyan #69C7CE ring color used (matches pulse fire ring_color)")
		else:
			print("  FAIL: Glass Cyan color missing in windup VFX")
			all_ok = false
		# 9. 0.5× radius passed from caller (check the trigger call in pulse_ability)
		if "pulse_radius * 0.5" in t166_ability:
			print("  PASS: 0.5× radius (pulse_radius * 0.5) passed to windup trigger")
		else:
			print("  FAIL: 0.5× radius not passed to windup trigger")
			all_ok = false

	# ---------- F005 refactor: _pre_verb_block_check() helper ----------
	print("--- F005 (Refactor: _pre_verb_block_check() helper for 4 verb handlers) ---")
	var f005_text: String = _read_file(F005_PLAYER_PATH)
	if f005_text.is_empty():
		print("  FAIL: cannot read " + F005_PLAYER_PATH)
		all_ok = false
	else:
		# 1. _pre_verb_block_check() function defined
		if "func _pre_verb_block_check()" in f005_text:
			print("  PASS: _pre_verb_block_check() helper defined")
		else:
			print("  FAIL: _pre_verb_block_check() helper missing")
			all_ok = false
		# 2. Helper returns is_action_globally_blocked()
		var helper_idx: int = f005_text.find("func _pre_verb_block_check()")
		var helper_body_idx: int = f005_text.find("return is_action_globally_blocked()", helper_idx) if helper_idx > 0 else -1
		if helper_idx > 0 and helper_body_idx > 0 and helper_body_idx - helper_idx < 500:
			print("  PASS: helper returns is_action_globally_blocked() (thin wrapper)")
		else:
			print("  FAIL: helper doesn't return is_action_globally_blocked() (helper_idx=%d, body_idx=%d)" % [helper_idx, helper_body_idx])
			all_ok = false
		# 3-6. All 4 verb handlers use the helper
		var handlers: Array[String] = [
			"func _handle_pulse",
			"func _handle_bind",
			"func _handle_cut",
			"func _handle_echo",
		]
		for h in handlers:
			var h_idx: int = f005_text.find(h)
			if h_idx < 0:
				print("  FAIL: " + h + " not found")
				all_ok = false
				continue
			# Look for _pre_verb_block_check() within the next ~400 chars (the guard line)
			var window_end: int = min(h_idx + 400, f005_text.length())
			var window: String = f005_text.substr(h_idx, window_end - h_idx)
			if "_pre_verb_block_check()" in window:
				print("  PASS: " + h + " uses _pre_verb_block_check() guard")
			else:
				print("  FAIL: " + h + " doesn't use _pre_verb_block_check()")
				all_ok = false
		# 7. The legacy is_action_globally_blocked() public function is still present
		#    (other call sites like _handle_jump / _on_echo_multi_reflect still use it)
		if "func is_action_globally_blocked() -> bool:" in f005_text:
			print("  PASS: is_action_globally_blocked() public function preserved")
		else:
			print("  FAIL: is_action_globally_blocked() public function removed (other callers will break)")
			all_ok = false

	if all_ok:
		print("=== ALL T165+T166+F005 (#85) ASSERTIONS PASSED ===")
		quit(0)
	else:
		print("=== T165+T166+F005 (#85) ASSERTIONS FAILED ===")
		quit(1)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content
