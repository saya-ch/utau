extends SceneTree
## H001 (#99) — D002.B Field Conflict 回归保护冒烟测试
##
## 覆盖 #99 hotfix 任务:
## - H001.1: _verb_ability_base.gd 用 @export 声明 cooldown / windup_time
##            (Pulse 默认值 0.5 / 0.10,作为"feels-good floor" fallback)
## - H001.2: 5 verb ability (pulse / bind / cut / echo / wave) 不再
##            重复声明 @export var cooldown / windup_time (避免
##            "already exists in parent class" Parse Error)
## - H001.3: player.tscn 为 5 verb ability 显式覆盖 cooldown /
##            windup_time,保留各 verb 的 gameplay tuning:
##              Pulse: 0.5  / 0.10
##              Bind:  1.2  / 0.10
##              Cut:   0.8  / 0.06
##              Echo:  4.0  / 0.08
##              Wave:  6.0  / 0.10
## - H001.4: echo_ability.gd 重新拥有 _is_active / _active_timer /
##            _reflected_this_cast (verb-specific shield state)
## - H001.5: resonance_wave_ability.gd 重新拥有 _is_active /
##            _active_timer / _current_radius / _hit_this_cast
##            (verb-specific wave state)
##
## 模式与 I009 (#94) / I011 (#97) / D002.B (#98) 一致: 源码字符串
## 扫描 + 锚定断言,不实例化 Node 避免 headless mock autoload 边界。
## 回归保护:H001 是 D002.B 5 verb code-sharing 宪法级约束的修正,
## 任何后续重构想"优化"cooldown/windup_time 位置、或删除 verb-specific
## state、或剥离 .tscn overrides,都会被这 30+ 项断言抓住。

const VERB_ABILITY_BASE_GD := "res://src/scripts/_verb_ability_base.gd"
const PULSE_ABILITY_GD := "res://src/scripts/pulse_ability.gd"
const BIND_ABILITY_GD := "res://src/scripts/bind_ability.gd"
const CUT_ABILITY_GD := "res://src/scripts/cut_ability.gd"
const ECHO_ABILITY_GD := "res://src/scripts/echo_ability.gd"
const WAVE_ABILITY_GD := "res://src/scripts/resonance_wave_ability.gd"
const PLAYER_TSCN := "res://src/scenes/player.tscn"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== H001 (#99) — D002.B Field Conflict 回归保护 ===")
	_run_h001_base_exports_assertions()
	_run_h001_5verb_no_redeclare_assertions()
	_run_h001_tscn_overrides_assertions()
	_run_h001_echo_state_assertions()
	_run_h001_wave_state_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL H001 (#99) D002.B FIELD CONFLICT ASSERTIONS PASSED ===")
		quit(0)


# ---------- H001.1 — VerbAbilityBase @export 字段声明 ----------
func _run_h001_base_exports_assertions() -> void:
	print("--- H001.1 — VerbAbilityBase @export cooldown / windup_time 声明 ---")
	var src := _read_file(VERB_ABILITY_BASE_GD)
	if src.is_empty():
		_failures.append("FAIL: H001.BASE: cannot read " + VERB_ABILITY_BASE_GD)
		return
	# (1) @export var cooldown (base 唯一声明位置)
	_assert_contains(src, "@export var cooldown: float",
		"H001.BASE.1: base declares @export var cooldown (5 verb 继承)")
	# (2) @export var windup_time (base 唯一声明位置)
	_assert_contains(src, "@export var windup_time: float",
		"H001.BASE.2: base declares @export var windup_time (5 verb 继承)")
	# (3) H001 hotfix 标识注释
	_assert_contains(src, "H001 (#99 hotfix)",
		"H001.BASE.3: base 标注 H001 (#99 hotfix) 修复说明")
	# (4) Pulse 安全的 fallback 默认值 (0.5)
	_assert_contains(src, "@export var cooldown: float = 0.5",
		"H001.BASE.4: base 默认 cooldown=0.5 (Pulse 节奏,feels-good floor)")
	# (5) Pulse 安全的 fallback 默认值 (0.10)
	_assert_contains(src, "@export var windup_time: float = 0.10",
		"H001.BASE.5: base 默认 windup_time=0.10 (Pulse 节奏,feels-good floor)")


# ---------- H001.2 — 5 verb ability 不再重复声明 ----------
func _run_h001_5verb_no_redeclare_assertions() -> void:
	print("--- H001.2 — 5 verb ability 不再重复声明 @export cooldown/windup_time ---")
	var pairs: Array = [
		[PULSE_ABILITY_GD, "pulse"],
		[BIND_ABILITY_GD, "bind"],
		[CUT_ABILITY_GD, "cut"],
		[ECHO_ABILITY_GD, "echo"],
		[WAVE_ABILITY_GD, "wave"],
	]
	for pair in pairs:
		var path: String = pair[0]
		var label: String = pair[1]
		var src := _read_file(path)
		if src.is_empty():
			_failures.append("FAIL: H001.5VERB." + label + ": cannot read " + path)
			continue
		# 关键负向断言:子类不能再次声明 @export var cooldown
		# (会触发 "already exists in parent class" Parse Error)
		_assert_not_contains(src, "@export var cooldown: float",
			"H001.5VERB." + label + ".1: " + label + " 不再 @export cooldown (避免父类冲突)")
		_assert_not_contains(src, "@export var windup_time: float",
			"H001.5VERB." + label + ".2: " + label + " 不再 @export windup_time (避免父类冲突)")
		# H001 hotfix 注释应当存在,提示该字段已在基类声明
		_assert_contains(src, "H001 (#99 hotfix)",
			"H001.5VERB." + label + ".3: " + label + " 标注 H001 hotfix 说明")


# ---------- H001.3 — player.tscn 显式覆盖 per-verb cooldown/windup_time ----------
func _run_h001_tscn_overrides_assertions() -> void:
	print("--- H001.3 — player.tscn 显式覆盖 per-verb cooldown/windup_time ---")
	var src := _read_file(PLAYER_TSCN)
	if src.is_empty():
		_failures.append("FAIL: H001.TSCN: cannot read " + PLAYER_TSCN)
		return
	# Pulse: 0.5 / 0.1
	_assert_tscn_override(src, "PulseAbility", "cooldown = 0.5",
		"H001.TSCN.1: PulseAbility 显式覆盖 cooldown=0.5")
	_assert_tscn_override(src, "PulseAbility", "windup_time = 0.1",
		"H001.TSCN.2: PulseAbility 显式覆盖 windup_time=0.1")
	# Bind: 1.2 / 0.1
	_assert_tscn_override(src, "BindAbility", "cooldown = 1.2",
		"H001.TSCN.3: BindAbility 显式覆盖 cooldown=1.2")
	_assert_tscn_override(src, "BindAbility", "windup_time = 0.1",
		"H001.TSCN.4: BindAbility 显式覆盖 windup_time=0.1")
	# Cut: 0.8 / 0.06
	_assert_tscn_override(src, "CutAbility", "cooldown = 0.8",
		"H001.TSCN.5: CutAbility 显式覆盖 cooldown=0.8")
	_assert_tscn_override(src, "CutAbility", "windup_time = 0.06",
		"H001.TSCN.6: CutAbility 显式覆盖 windup_time=0.06")
	# Echo: 4.0 / 0.08
	_assert_tscn_override(src, "EchoAbility", "cooldown = 4.0",
		"H001.TSCN.7: EchoAbility 显式覆盖 cooldown=4.0")
	_assert_tscn_override(src, "EchoAbility", "windup_time = 0.08",
		"H001.TSCN.8: EchoAbility 显式覆盖 windup_time=0.08")
	# Wave: 6.0 / 0.1
	_assert_tscn_override(src, "ResonanceWaveAbility", "cooldown = 6.0",
		"H001.TSCN.9: ResonanceWaveAbility 显式覆盖 cooldown=6.0")
	_assert_tscn_override(src, "ResonanceWaveAbility", "windup_time = 0.1",
		"H001.TSCN.10: ResonanceWaveAbility 显式覆盖 windup_time=0.1")


# ---------- H001.4 — Echo verb-specific shield state ----------
func _run_h001_echo_state_assertions() -> void:
	print("--- H001.4 — Echo verb-specific state (_is_active / _active_timer / _reflected_this_cast) ---")
	var src := _read_file(ECHO_ABILITY_GD)
	if src.is_empty():
		_failures.append("FAIL: H001.ECHO: cannot read " + ECHO_ABILITY_GD)
		return
	_assert_contains(src, "var _is_active: bool = false",
		"H001.ECHO.1: echo 重新声明 _is_active (shield 激活旗)")
	_assert_contains(src, "var _active_timer: float = 0.0",
		"H001.ECHO.2: echo 重新声明 _active_timer (shield 倒计时)")
	_assert_contains(src, "var _reflected_this_cast: Array = []",
		"H001.ECHO.3: echo 重新声明 _reflected_this_cast (反射 dedup 集合)")


# ---------- H001.5 — Wave verb-specific expanding-ring state ----------
func _run_h001_wave_state_assertions() -> void:
	print("--- H001.5 — Wave verb-specific state (_is_active / _active_timer / _current_radius / _hit_this_cast) ---")
	var src := _read_file(WAVE_ABILITY_GD)
	if src.is_empty():
		_failures.append("FAIL: H001.WAVE: cannot read " + WAVE_ABILITY_GD)
		return
	_assert_contains(src, "var _is_active: bool = false",
		"H001.WAVE.1: wave 重新声明 _is_active (wave 扩散激活旗)")
	_assert_contains(src, "var _active_timer: float = 0.0",
		"H001.WAVE.2: wave 重新声明 _active_timer (wave 倒计时)")
	_assert_contains(src, "var _current_radius: float = 0.0",
		"H001.WAVE.3: wave 重新声明 _current_radius (扩散半径)")
	_assert_contains(src, "var _hit_this_cast: Array = []",
		"H001.WAVE.4: wave 重新声明 _hit_this_cast (AOE dedup 集合)")


# ---------- helpers ----------
func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) >= 0:
		_passes += 1
		print("  PASS: " + msg)
	else:
		_failures.append("FAIL: " + msg + " — needle not found: " + needle)


func _assert_not_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) < 0:
		_passes += 1
		print("  PASS: " + msg)
	else:
		_failures.append("FAIL: " + msg + " — forbidden needle found: " + needle)


func _assert_tscn_override(src: String, node_name: String, prop_line: String, msg: String) -> void:
	# .tscn 节点块格式: [node name="Xxx" parent="."]
	#                 script = ExtResource("...")
	#                 cooldown = 0.5      ← 我们要确认这一行存在
	#                 windup_time = 0.1
	# 简化策略:在 [node name="Xxx" ...] 段内找 prop_line
	var start_marker := "[node name=\"" + node_name + "\""
	var start_idx := src.find(start_marker)
	if start_idx < 0:
		_failures.append("FAIL: " + msg + " — node block not found: " + start_marker)
		return
	# 段结束 = 下一个 [node 或 [sub_resource
	var next_node := src.find("\n[node ", start_idx + 1)
	var next_sub := src.find("\n[sub_resource", start_idx + 1)
	var end_idx := src.length()
	if next_node >= 0:
		end_idx = min(end_idx, next_node)
	if next_sub >= 0:
		end_idx = min(end_idx, next_sub)
	var block := src.substr(start_idx, end_idx - start_idx)
	if block.find(prop_line) >= 0:
		_passes += 1
		print("  PASS: " + msg)
	else:
		_failures.append("FAIL: " + msg + " — property line not in node block: " + prop_line)


func _print_summary() -> void:
	print("")
	print("=== H001 (#99) smoke test summary: %d passed, %d failed ===" % [_passes, _failures.size()])
	for fail in _failures:
		print("  " + fail)
