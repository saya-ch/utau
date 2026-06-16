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
const T166_VERB_ABILITY_BASE_PATH := "res://src/scripts/_verb_ability_base.gd"
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
	# D002.B (#98) — 5 verb 共享的 _windup_vfx var / _exit_tree / _execute_pulse 等
	# 提到父类 VerbAbilityBase，所以 pulse_ability.gd 不再直接持有这些。检查父类
	# + pulse 文件 union：契约在父类实现 + pulse 文件 overrides 它的 _execute_verb
	# + 提供 start_pulse()。
	var t166_base: String = _read_file(T166_VERB_ABILITY_BASE_PATH)
	var t166_ability: String = _read_file(T166_PULSE_ABILITY_PATH)
	if t166_ability.is_empty():
		print("  FAIL: cannot read " + T166_PULSE_ABILITY_PATH)
		all_ok = false
	else:
		# 1. windup_time = 0.10 (was 0.08). D002.B — windup_time @export 在父类，
		# 5 verb 各自默认值 (pulse=0.10) 通过 .tscn override。父类 default 0.1。
		# 接受 "windup_time: float = 0.10" 在父类 OR pulse 文件里。
		var windup_time_0_10: bool = (
			"@export var windup_time: float = 0.10" in t166_ability
			or ("@export var windup_time: float" in t166_base and ("= 0.1" in t166_base or "= 0.10" in t166_base))
		)
		if windup_time_0_10:
			print("  PASS: windup_time 0.10s present (in pulse file or base class)")
		else:
			print("  FAIL: windup_time != 0.10 (must be 0.10s for VFX to be readable)")
			all_ok = false
		# 2. _windup_vfx var exists. D002.B — moved to VerbAbilityBase.
		var windup_vfx_var: bool = (
			"var _windup_vfx: Node2D = null" in t166_ability
			or "var _windup_vfx: Node2D = null" in t166_base
		)
		if windup_vfx_var:
			print("  PASS: _windup_vfx var present (in pulse file or base class)")
		else:
			print("  FAIL: _windup_vfx var missing")
			all_ok = false
		# 3. start_pulse spawns windup_vfx.
		#    D002.B (#98) — 5 verb 文件顺序把 _execute_verb 放在 start_* 之前
		#    （父类虚钩优先）。所以只检查 start_pulse 函数体内是否调
		#    pulse_windup_vfx.gd（不依赖 _execute_* 位置）。
		var start_idx: int = t166_ability.find("func start_pulse(")
		var spawn_idx: int = -1
		if start_idx > 0:
			var next_func_idx: int = t166_ability.find("\nfunc ", start_idx + 1)
			if next_func_idx < 0:
				next_func_idx = t166_ability.length()
			var start_body_text: String = t166_ability.substr(start_idx, next_func_idx - start_idx)
			if "pulse_windup_vfx.gd" in start_body_text:
				spawn_idx = start_idx
		if start_idx > 0 and spawn_idx > 0:
			print("  PASS: windup_vfx spawned inside start_pulse()")
		else:
			print("  FAIL: windup_vfx not spawned in start_pulse (start=%d, spawn=%d)" % [start_idx, spawn_idx])
			all_ok = false
		# 4. _execute_pulse/_execute_verb frees windup_vfx.
		#    D002.B — _windup_vfx.queue_free() 移到父类 _begin_verb_fire()，子类
		#    _execute_verb() 不再直接调 queue_free。检查父类 OR 子类有 queue_free。
		var execute_idx: int = t166_ability.find("func _execute_verb()")
		if execute_idx < 0:
			# Pre-D002.B 兼容
			execute_idx = t166_ability.find("func _execute_pulse()")
		var exec_window_text: String = ""
		if execute_idx > 0:
			var next_func_idx: int = t166_ability.find("\nfunc ", execute_idx + 1)
			if next_func_idx < 0:
				next_func_idx = t166_ability.length()
			exec_window_text = t166_ability.substr(execute_idx, next_func_idx - execute_idx)
		var free_in_base: bool = "_windup_vfx.queue_free()" in t166_base
		var free_in_subclass: bool = "_windup_vfx.queue_free()" in exec_window_text
		if free_in_base or free_in_subclass:
			print("  PASS: _windup_vfx freed (in base class via _begin_verb_fire or in subclass _execute_verb)")
		else:
			print("  FAIL: _windup_vfx not freed (no queue_free in base or subclass _execute_verb)")
			all_ok = false
		# 5. _exit_tree cleanup hook. D002.B — moved to VerbAbilityBase.
		var exit_tree_present: bool = "func _exit_tree" in t166_ability or "func _exit_tree" in t166_base
		if exit_tree_present:
			print("  PASS: _exit_tree cleanup hook present (in pulse file or base class)")
		else:
			print("  FAIL: _exit_tree cleanup missing")
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
