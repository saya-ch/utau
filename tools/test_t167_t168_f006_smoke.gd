extends SceneTree
## T167 + T168 + F006 (#86) — smoke test (补 #86 缺测试)
##
## 任务组合:
##   T167 Polish: BindAbility windup 加 pre-bind 视觉信号 (Muted Violet spiral
##                0.5× 收缩, 与 T166 Pulse 同模式, Bind 专属 motif)
##   T168 Polish: EchoAbility 起手 0.08s 玻璃护盾球 0.5×→1.0× 撑开
##                (Glass Cyan fill + Pale Resonance rim + Amber Voice core,
##                4 verb 第 3 种 motion language — 与 Pulse/Bind 内缩反向)
##   F006 Refactor: player.gd 提取 `_try_verb()` 5 步中央管道 (block check
##                  + just_pressed + origin/dir calc + start_fn + blocked HUD)
##                  + 4 个 `_start_*_at()` wrapper (Pulse/Bind/Cut/Echo 各自)
##
## 测试目标: 静态分析 (不跑 Play mode, 与 #85 #84 其它 smoke test 风格一致).
##   T167  -- bind_windup_vfx.gd 存在 + extends Node2D + Muted Violet + 3 arcs
##            + bind_ability._windup_vfx var + start_bind spawn + _execute_bind
##            free + _exit_tree hook + bind_radius*0.5 调用
##   T168  -- echo_windup_vfx.gd 存在 + extends Node2D + 3 色 (Glass Cyan /
##            Pale Resonance / Amber Voice) + _end_scale=1.0 撑开 (vs Pulse
##            0.92 内缩) + echo_ability._windup_vfx var + start_echo spawn +
##            _execute_echo free + _exit_tree hook + echo_radius*0.5 和
##            echo_radius 调用
##   F006  -- player.gd._try_verb() helper + 4 个 _start_*_at() wrapper
##            + 4 verb handler 1-line body + _pre_verb_block_check() F005
##            回归 + is_action_globally_blocked() 公开函数保留
##   D001 regression — PlayerActionGate 还在 + is_action_globally_blocked
##            是 thin delegate

const T167_BIND_ABILITY_PATH := "res://src/scripts/bind_ability.gd"
const T167_BIND_WINDUP_VFX_PATH := "res://src/scripts/bind_windup_vfx.gd"
const T168_ECHO_ABILITY_PATH := "res://src/scripts/echo_ability.gd"
const T168_ECHO_WINDUP_VFX_PATH := "res://src/scripts/echo_windup_vfx.gd"
const F006_PLAYER_PATH := "res://src/scripts/player.gd"
const T166_PULSE_ABILITY_PATH := "res://src/scripts/pulse_ability.gd"
const T166_PULSE_WINDUP_VFX_PATH := "res://src/scripts/pulse_windup_vfx.gd"
const T165_AUDIO_PATH := "res://src/scripts/audio_manager_enhanced.gd"

func _initialize() -> void:
	print("=== T167+T168+F006 (#86) — Bind windup spiral + Echo windup sphere + _try_verb helper ===")
	var all_ok: bool = true

	# ---------- T167 polish: Bind windup spiral ----------
	print("--- T167 (Polish: BindAbility windup spiral — Muted Violet 3-arc) ---")
	var t167_vfx: String = _read_file(T167_BIND_WINDUP_VFX_PATH)
	if t167_vfx.is_empty():
		print("  FAIL: cannot read " + T167_BIND_WINDUP_VFX_PATH + " (new file must exist)")
		all_ok = false
	else:
		# 1. extends Node2D (T174.B #94 — now extends VerbWindupVFXBase which extends Node2D)
		if "extends Node2D" in t167_vfx or "_verb_windup_vfx_base.gd" in t167_vfx:
			print("  PASS: bind_windup_vfx.gd extends Node2D (via VerbWindupVFXBase in T174.B refactor)")
		else:
			print("  FAIL: bind_windup_vfx.gd doesn't extend Node2D (directly or via base)")
			all_ok = false
		# 2. trigger() method
		if "func trigger(" in t167_vfx:
			print("  PASS: bind_windup_vfx.gd has trigger() method")
		else:
			print("  FAIL: bind_windup_vfx.gd missing trigger() method")
			all_ok = false
		# 3. Muted Violet #65506A (STYLE_GUIDE Bind 主色)
		if '#65506A' in t167_vfx:
			print("  PASS: Muted Violet #65506A color used (Bind 主色)")
		else:
			print("  FAIL: Muted Violet color missing in windup VFX")
			all_ok = false
		# 4. arc_count = 3 (3 spiral arcs echo Bind icon A033 spiral motif)
		if "arc_count: int = 3" in t167_vfx:
			print("  PASS: arc_count = 3 (3 spiral arcs echo Bind icon motif)")
		else:
			print("  FAIL: arc_count != 3 (must be 3 for spiral motif)")
			all_ok = false
		# 5. _end_scale = 0.85 (more aggressive inward pull than Pulse 0.92)
		if "_end_scale: float = 0.85" in t167_vfx:
			print("  PASS: _end_scale = 0.85 (Bind 比 Pulse 0.92 内拉更激进)")
		else:
			print("  FAIL: _end_scale != 0.85 (Bind 内拉必须比 Pulse 激进)")
			all_ok = false
		# 6. Lifecycle: _process + _max_lifetime auto-free safety net
		# T174.B (#94) — _process / _max_lifetime / queue_free now in
		# VerbWindupVFXBase, not in each verb's own file.  Check the verb
		# file for direct lifecycle hooks OR verify the verb file extends
		# the base (which provides them by inheritance).
		var t167_vfx_lifecycle_ok: bool = (
			("func _process(" in t167_vfx and "_max_lifetime" in t167_vfx and "queue_free()" in t167_vfx)
			or "_verb_windup_vfx_base.gd" in t167_vfx
		)
		if t167_vfx_lifecycle_ok:
			print("  PASS: _process + _max_lifetime + queue_free lifecycle (in base class via T174.B refactor)")
		else:
			print("  FAIL: lifecycle hooks missing (process / max_lifetime / queue_free)")
			all_ok = false

	var t167_ability: String = _read_file(T167_BIND_ABILITY_PATH)
	if t167_ability.is_empty():
		print("  FAIL: cannot read " + T167_BIND_ABILITY_PATH)
		all_ok = false
	else:
		# 7. _windup_vfx var exists
		if "var _windup_vfx: Node2D = null" in t167_ability:
			print("  PASS: bind_ability._windup_vfx var present")
		else:
			print("  FAIL: bind_ability._windup_vfx var missing")
			all_ok = false
		# 8. start_bind spawns bind_windup_vfx
	var start_idx: int = t167_ability.find("func start_bind(")
	var execute_idx: int = t167_ability.find("func _execute_bind()")
	var spawn_idx: int = -1
	if start_idx > 0 and execute_idx > 0 and execute_idx > start_idx:
		spawn_idx = t167_ability.find("bind_windup_vfx.gd", start_idx)
		while spawn_idx > 0 and spawn_idx >= execute_idx:
			spawn_idx = t167_ability.find("bind_windup_vfx.gd", spawn_idx + 1)
	if start_idx > 0 and spawn_idx > 0 and spawn_idx > start_idx and (execute_idx < 0 or spawn_idx < execute_idx):
		print("  PASS: bind_windup_vfx spawned inside start_bind()")
	else:
		print("  FAIL: bind_windup_vfx not spawned in start_bind (start=%d, spawn=%d, exec=%d)" % [start_idx, spawn_idx, execute_idx])
		all_ok = false
		# 9. _execute_bind frees windup_vfx
		var first_free_after_exec: int = -1
		if execute_idx > 0:
			var next_func_idx: int = t167_ability.find("\nfunc ", execute_idx + 1)
			if next_func_idx < 0:
				next_func_idx = t167_ability.length()
			var window_text: String = t167_ability.substr(execute_idx, next_func_idx - execute_idx)
			first_free_after_exec = execute_idx + window_text.find("_windup_vfx.queue_free()") if "_windup_vfx.queue_free()" in window_text else -1
		if execute_idx > 0 and first_free_after_exec > 0:
			print("  PASS: _execute_bind() frees windup_vfx (no 1-frame overlap)")
		else:
			print("  FAIL: _execute_bind() doesn't free windup_vfx")
			all_ok = false
		# 10. _exit_tree cleanup hook
		#     D002.B (#98) refactored: 5 verb ability._exit_tree() is
		#     now inherited from VerbAbilityBase, so the literal
		#     string "func _exit_tree" no longer appears in the
		#     subclass file.  Verify the subclass extends
		#     VerbAbilityBase (which owns the fade_out_and_free()
		#     call) instead of checking for the function body.
		if "extends \"res://src/scripts/_verb_ability_base.gd\"" in t167_ability:
			print("  PASS: _exit_tree cleanup hook inherited via VerbAbilityBase (D002.B refactor)")
		else:
			print("  FAIL: bind_ability.gd doesn't extend VerbAbilityBase — _exit_tree cleanup hook missing")
			all_ok = false
		# 11. 0.5× radius passed from caller
		if "bind_radius * 0.5" in t167_ability:
			print("  PASS: 0.5× radius (bind_radius * 0.5) passed to windup trigger")
		else:
			print("  FAIL: 0.5× radius not passed to windup trigger")
			all_ok = false

	# ---------- T168 polish: Echo windup sphere ----------
	print("--- T168 (Polish: EchoAbility windup sphere — 0.5×→1.0× 撑开, 3 色) ---")
	var t168_vfx: String = _read_file(T168_ECHO_WINDUP_VFX_PATH)
	if t168_vfx.is_empty():
		print("  FAIL: cannot read " + T168_ECHO_WINDUP_VFX_PATH + " (new file must exist)")
		all_ok = false
	else:
		# 1. extends Node2D (T174.B #94 — now extends VerbWindupVFXBase which extends Node2D)
		if "extends Node2D" in t168_vfx or "_verb_windup_vfx_base.gd" in t168_vfx:
			print("  PASS: echo_windup_vfx.gd extends Node2D (via VerbWindupVFXBase in T174.B refactor)")
		else:
			print("  FAIL: echo_windup_vfx.gd doesn't extend Node2D (directly or via base)")
			all_ok = false
		# 2. trigger() with 4 params (origin, half, full, duration)
		if "func trigger(origin: Vector2, half_radius: float, full_radius: float, duration: float)" in t168_vfx:
			print("  PASS: echo_windup_vfx.gd trigger() has 4-param signature (half+full)")
		else:
			print("  FAIL: echo_windup_vfx.gd trigger() signature wrong (need 4 params)")
			all_ok = false
		# 3. Three colors (Glass Cyan fill + Pale Resonance rim + Amber Voice core)
		if '#69C7CE' in t168_vfx and '#B7E7DD' in t168_vfx and '#F2B66E' in t168_vfx:
			print("  PASS: 3 colors (Glass Cyan #69C7CE + Pale Resonance #B7E7DD + Amber Voice #F2B66E)")
		else:
			print("  FAIL: 3 colors missing (must match STYLE_GUIDE Echo palette)")
			all_ok = false
		# 4. _end_scale = 1.0 (Echo EXPANDS out, opposite of Pulse 0.92 + Bind 0.85)
		if "_end_scale: float = 1.0" in t168_vfx:
			print("  PASS: _end_scale = 1.0 (Echo 撑开 vs Pulse 0.92/Bind 0.85 内缩)")
		else:
			print("  FAIL: _end_scale != 1.0 (Echo 必须撑开到 1.0)")
			all_ok = false
		# 5. _start_scale = 0.5
		if "_start_scale: float = 0.5" in t168_vfx:
			print("  PASS: _start_scale = 0.5 (从 0.5× 撑到 1.0×)")
		else:
			print("  FAIL: _start_scale != 0.5")
			all_ok = false
		# 6. Lifecycle (T174.B #94 — in base class via extends)
		var t168_vfx_lifecycle_ok: bool = (
			("func _process(" in t168_vfx and "_max_lifetime" in t168_vfx and "queue_free()" in t168_vfx)
			or "_verb_windup_vfx_base.gd" in t168_vfx
		)
		if t168_vfx_lifecycle_ok:
			print("  PASS: _process + _max_lifetime + queue_free lifecycle (in base class via T174.B refactor)")
		else:
			print("  FAIL: lifecycle hooks missing")
			all_ok = false

	var t168_ability: String = _read_file(T168_ECHO_ABILITY_PATH)
	if t168_ability.is_empty():
		print("  FAIL: cannot read " + T168_ECHO_ABILITY_PATH)
		all_ok = false
	else:
		# 7. _windup_vfx var exists
		if "var _windup_vfx: Node2D = null" in t168_ability:
			print("  PASS: echo_ability._windup_vfx var present")
		else:
			print("  FAIL: echo_ability._windup_vfx var missing")
			all_ok = false
		# 8. start_echo spawns echo_windup_vfx
		var start_echo_idx: int = t168_ability.find("func start_echo(")
		var execute_echo_idx: int = t168_ability.find("func _execute_echo()")
		var spawn_echo_idx: int = -1
		if start_echo_idx > 0 and execute_echo_idx > 0 and execute_echo_idx > start_echo_idx:
			spawn_echo_idx = t168_ability.find("echo_windup_vfx.gd", start_echo_idx)
			while spawn_echo_idx > 0 and spawn_echo_idx >= execute_echo_idx:
				spawn_echo_idx = t168_ability.find("echo_windup_vfx.gd", spawn_echo_idx + 1)
		if start_echo_idx > 0 and spawn_echo_idx > 0 and spawn_echo_idx > start_echo_idx and (execute_echo_idx < 0 or spawn_echo_idx < execute_echo_idx):
			print("  PASS: echo_windup_vfx spawned inside start_echo()")
		else:
			print("  FAIL: echo_windup_vfx not spawned in start_echo (start=%d, spawn=%d, exec=%d)" % [start_echo_idx, spawn_echo_idx, execute_echo_idx])
			all_ok = false
		# 9. _execute_echo frees windup_vfx
		var first_free_after_echo: int = -1
		if execute_echo_idx > 0:
			var next_func_echo_idx: int = t168_ability.find("\nfunc ", execute_echo_idx + 1)
			if next_func_echo_idx < 0:
				next_func_echo_idx = t168_ability.length()
			var window_echo_text: String = t168_ability.substr(execute_echo_idx, next_func_echo_idx - execute_echo_idx)
			first_free_after_echo = execute_echo_idx + window_echo_text.find("_windup_vfx.queue_free()") if "_windup_vfx.queue_free()" in window_echo_text else -1
		if execute_echo_idx > 0 and first_free_after_echo > 0:
			print("  PASS: _execute_echo() frees windup_vfx (no 1-frame overlap)")
		else:
			print("  FAIL: _execute_echo() doesn't free windup_vfx")
			all_ok = false
		# 10. _exit_tree cleanup hook
		#     D002.B (#98) refactored: 5 verb ability._exit_tree() is
		#     now inherited from VerbAbilityBase, so the literal
		#     string "func _exit_tree" no longer appears in the
		#     subclass file.  Verify the subclass extends
		#     VerbAbilityBase (which owns the fade_out_and_free()
		#     call) instead of checking for the function body.
		if "extends \"res://src/scripts/_verb_ability_base.gd\"" in t168_ability:
			print("  PASS: _exit_tree cleanup hook inherited via VerbAbilityBase (D002.B refactor)")
		else:
			print("  FAIL: echo_ability.gd doesn't extend VerbAbilityBase — _exit_tree cleanup hook missing")
			all_ok = false
		# 11. echo_radius*0.5 and echo_radius passed (4-arg trigger call)
		if "echo_radius * 0.5" in t168_ability and "echo_radius" in t168_ability:
			print("  PASS: echo_radius*0.5 + echo_radius 4-arg trigger call present")
		else:
			print("  FAIL: 4-arg trigger call missing")
			all_ok = false

	# ---------- F006 refactor: _try_verb() + 4 wrapper ----------
	print("--- F006 (Refactor: _try_verb() helper + 4 _start_*_at() wrappers) ---")
	var f006_text: String = _read_file(F006_PLAYER_PATH)
	if f006_text.is_empty():
		print("  FAIL: cannot read " + F006_PLAYER_PATH)
		all_ok = false
	else:
		# 1. _try_verb() function defined
		if "func _try_verb(action_name: String, start_fn: Callable) -> void:" in f006_text:
			print("  PASS: _try_verb() helper defined with 2-param signature")
		else:
			print("  FAIL: _try_verb() helper missing or signature wrong")
			all_ok = false
		# 2. 4 _start_*_at() wrappers exist
		var wrappers: Array[String] = [
			"func _start_pulse_at(origin: Vector2, dir: Vector2) -> bool:",
			"func _start_bind_at(origin: Vector2, dir: Vector2) -> bool:",
			"func _start_cut_at(origin: Vector2, dir: Vector2) -> bool:",
			"func _start_echo_at(origin: Vector2, _dir: Vector2) -> bool:",
		]
		for w in wrappers:
			if w in f006_text:
				print("  PASS: " + w.split("(")[0] + " wrapper present")
			else:
				print("  FAIL: " + w.split("(")[0] + " wrapper missing")
				all_ok = false
		# 3. 4 verb handlers shrink to 1-line _try_verb() delegate
		#    (T142 / T145 / F005 docblock + body line within ~600 chars)
		var handlers: Array[String] = [
			"func _handle_pulse",
			"func _handle_bind",
			"func _handle_cut",
			"func _handle_echo",
		]
		for h in handlers:
			var h_idx: int = f006_text.find(h)
			if h_idx < 0:
				print("  FAIL: " + h + " not found")
				all_ok = false
				continue
			var window_end: int = min(h_idx + 600, f006_text.length())
			var window: String = f006_text.substr(h_idx, window_end - h_idx)
			if "_try_verb(" in window:
				print("  PASS: " + h + " delegates to _try_verb()")
			else:
				print("  FAIL: " + h + " doesn't delegate to _try_verb() (F006 didn't shrink)")
				all_ok = false
		# 4. _try_verb body uses _pre_verb_block_check (F005 regression)
		var try_verb_idx: int = f006_text.find("func _try_verb(action_name: String, start_fn: Callable) -> void:")
		if try_verb_idx > 0:
			var try_verb_body: String = f006_text.substr(try_verb_idx, 800)
			if "_pre_verb_block_check()" in try_verb_body and "is_action_just_pressed" in try_verb_body and "show_pulse_blocked" in try_verb_body:
				print("  PASS: _try_verb() body has block-check + just_pressed + HUD feedback")
			else:
				print("  FAIL: _try_verb() body missing 3 critical steps (block/just_pressed/HUD)")
				all_ok = false
		# 5. Wave excluded (not refactored to _try_verb)
		var wave_handler_idx: int = f006_text.find("func _handle_wave(")
		if wave_handler_idx > 0 and "is_wave_active" in f006_text.substr(wave_handler_idx, 1500):
			print("  PASS: _handle_wave() preserved (4-branch verb-state routing kept)")
		else:
			print("  FAIL: _handle_wave() should be preserved (Wave has 4-state routing)")
			all_ok = false
		# 6. F005 regression: _pre_verb_block_check() still exists
		if "func _pre_verb_block_check()" in f006_text:
			print("  PASS: F005 _pre_verb_block_check() helper preserved")
		else:
			print("  FAIL: F005 helper missing (regression)")
			all_ok = false
		# 7. is_action_globally_blocked() public function still present
		if "func is_action_globally_blocked() -> bool:" in f006_text:
			print("  PASS: is_action_globally_blocked() public function preserved (D001 + jump caller compat)")
		else:
			print("  FAIL: is_action_globally_blocked() public function removed (callers will break)")
			all_ok = false
		# 8. D001 regression: PlayerActionGate autoload still referenced
		if "PlayerActionGate" in f006_text:
			print("  PASS: D001 PlayerActionGate autoload still referenced")
		else:
			print("  FAIL: D001 PlayerActionGate ref removed (regression)")
			all_ok = false

	# ---------- Cross-check: 4 verb windup VFX pattern consistent ----------
	print("--- Cross-check: 4 verb windup VFX pattern consistent (Pulse+Bind+Echo) ---")
	# T165+BGM tier-up regression (D001/T165 should still work)
	var t165_text: String = _read_file(T165_AUDIO_PATH)
	if "request_boss_music" in t165_text and "ScreenShake.flash_color" in t165_text:
		print("  PASS: T165 BGM tier-up flash still in place (no regression)")
	else:
		print("  FAIL: T165 regression — BGM tier-up missing")
		all_ok = false
	# T166 regression: pulse_ability windup_time = 0.10 + pulse_windup_vfx exists
	var t166_ability: String = _read_file(T166_PULSE_ABILITY_PATH)
	if "@export var windup_time: float = 0.10" in t166_ability and "pulse_windup_vfx.gd" in t166_ability:
		print("  PASS: T166 Pulse windup_time = 0.10 + windup VFX still in place (no regression)")
	else:
		print("  FAIL: T166 regression — Pulse windup setup missing")
		all_ok = false
	var t166_vfx: String = _read_file(T166_PULSE_WINDUP_VFX_PATH)
	# T174.B (#94) — pulse_windup_vfx.gd no longer `extends Node2D` directly;
	# it `extends VerbWindupVFXBase` (which itself extends Node2D).  Accept
	# either the old `extends Node2D` or the new `extends VerbWindupVFXBase`
	# (via the path-based extends used in the 5 verb windup files).
	var t166_extends_ok: bool = ("extends Node2D" in t166_vfx) or ("_verb_windup_vfx_base.gd" in t166_vfx)
	if t166_extends_ok and '_end_scale: float = 0.92' in t166_vfx:
		print("  PASS: T166 pulse_windup_vfx.gd 0.92 inward scale preserved (T174.B refactor compatible)")
	else:
		print("  FAIL: T166 pulse_windup_vfx.gd 0.92 scale regression (T174.B refactor must keep _end_scale=0.92)")
		all_ok = false

	if all_ok:
		print("=== ALL T167+T168+F006 (#86) ASSERTIONS PASSED ===")
		quit(0)
	else:
		print("=== T167+T168+F006 (#86) ASSERTIONS FAILED ===")
		quit(1)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content
