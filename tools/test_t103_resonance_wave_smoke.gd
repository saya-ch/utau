extends SceneTree
## T103 冒烟测试 — 验证第五个声波能力 ResonanceWaveAbility 的核心结构：
## class_name / @export / 3 signal / 4 动词色域分工 / 集成到 player.gd +
## player.tscn + project.godot + 桥接方法。

func _init() -> void:
	var errors: Array[String] = []
	var checks: Array[String] = []

	# 1. ResonanceWaveAbility 类文件存在
	var wave_src := FileAccess.get_file_as_string("res://src/scripts/resonance_wave_ability.gd")
	if wave_src.length() > 100:
		checks.append("resonance_wave_ability.gd exists ✓")
	else:
		errors.append("resonance_wave_ability.gd missing or too short")

	# 2. class_name + 3 signal
	if "class_name ResonanceWaveAbility" in wave_src:
		checks.append("class_name ResonanceWaveAbility declared ✓")
	else:
		errors.append("class_name ResonanceWaveAbility missing")
	for sig in ["signal wave_fired", "signal wave_hit", "signal wave_expired"]:
		if sig in wave_src:
			checks.append("%s declared ✓" % sig)
		else:
			errors.append("%s missing" % sig)

	# 3. 关键 @export 字段（至少 5 个 verb-specific + 3 个在 base）
	# D002.B (#99) — cooldown / windup_time / active_time live in
	# VerbAbilityBase as @export vars (subclass overrides via _ready()
	# direct assignment since GDScript 4 forbids child re-declaration).
	# wave_radius / wave_cost / wave_damage / enemy_knockback /
	# enemy_slow_duration are verb-specific @export and stay in the
	# subclass.  Test accepts the @export var declaration in either
	# the subclass or the base class.
	var base_src := FileAccess.get_file_as_string("res://src/scripts/_verb_ability_base.gd")
	var export_fields_subclass := ["wave_radius", "wave_cost", "wave_damage",
		"enemy_knockback", "enemy_slow_duration"]
	for field in export_fields_subclass:
		if "@export var %s" % field in wave_src:
			checks.append("@export %s ✓" % field)
		else:
			errors.append("@export %s missing" % field)
	# 3 base fields — accept either @export in subclass (pre-#99)
	# or @export in base (post-#99).  Subclass _ready() override is
	# sufficient proof the verb-specific value is set.
	var base_only_fields := ["cooldown", "windup_time", "active_time"]
	for field in base_only_fields:
		var in_subclass := "@export var %s" % field in wave_src
		var in_base := "@export var %s" % field in base_src
		if in_subclass or in_base:
			checks.append("@export %s ✓ (D002.B base or subclass)" % field)
		else:
			errors.append("@export %s missing (must be in subclass or VerbAbilityBase)" % field)

	# 4. 5 动词色域分工 — Wave 用 Pale Resonance (#B7E7DD)，不与前 4 个冲突
	#    Pulse = Coral (0.91, 0.427, 0.353)
	#    Bind  = Violet (0.4, 0.31, 0.42) (Hex #65506A)
	#    Cut   = Amber (0.949, 0.714, 0.431)
	#    Echo  = Cyan  (0.412, 0.78, 0.808)
	#    Wave  = Pale Resonance (0.718, 0.906, 0.867) — 冷色最浅（区别于 Echo 的 cyan）
	var player_src := FileAccess.get_file_as_string("res://src/scripts/player.gd")
	if "Color(0.718, 0.906, 0.867" in player_src:
		checks.append("Wave Pale Resonance color applied in player.gd ✓")
	else:
		errors.append("Wave Pale Resonance color missing in player.gd")
	# 反向验证：5 个色必须都不同（粗略检查：不存在一行 0.91, 0.427, 0.353 在 _on_wave_fired 中）
	var wave_block_start := player_src.find("_on_wave_fired")
	if wave_block_start > 0:
		var wave_block := player_src.substr(wave_block_start, 800)
		if "0.91, 0.427, 0.353" in wave_block:
			errors.append("Wave uses Pulse Coral color — 色域冲突!")
		else:
			checks.append("Wave color domain exclusive from Pulse ✓")

	# 5. player.gd 桥接 — _handle_wave + _on_wave_fired + 信号连接
	if "_handle_wave" in player_src and "_on_wave_fired" in player_src:
		checks.append("player.gd has _handle_wave + _on_wave_fired ✓")
	else:
		errors.append("player.gd wave bridge methods missing")
	if "wave_ability.wave_fired.connect(_on_wave_fired)" in player_src:
		checks.append("wave_fired signal connected ✓")
	else:
		errors.append("wave_fired signal NOT connected")
	if "wave_ability.wave_hit.connect(_on_wave_hit)" in player_src:
		checks.append("wave_hit signal connected ✓")
	else:
		errors.append("wave_hit signal NOT connected")
	if "wave_ability.wave_expired.connect(_on_wave_expired)" in player_src:
		checks.append("wave_expired signal connected ✓")
	else:
		errors.append("wave_expired signal NOT connected")

	# 6. player.tscn — ResonanceWaveAbility 节点 + 6_wave ext_resource
	var tscn_src := FileAccess.get_file_as_string("res://src/scenes/player.tscn")
	if "ResonanceWaveAbility" in tscn_src:
		checks.append("player.tscn has ResonanceWaveAbility node ✓")
	else:
		errors.append("player.tscn missing ResonanceWaveAbility node")
	if "resonance_wave_ability.gd" in tscn_src:
		checks.append("player.tscn references resonance_wave_ability.gd ✓")
	else:
		errors.append("player.tscn ext_resource missing")

	# 7. project.godot — wave 输入映射 (V + 手柄 button 6)
	var proj_src := FileAccess.get_file_as_string("res://project.godot")
	if "wave=" in proj_src and '"physical_keycode":86' in proj_src:
		checks.append("project.godot wave input mapping ✓")
	else:
		errors.append("project.godot wave input mapping missing")
	# Echo 已经有 Q+R+手柄5；Wave 用 V+Enter+手柄6 不冲突
	if '"button_index":6' in proj_src:
		checks.append("project.godot wave gamepad button 6 ✓")
	else:
		errors.append("project.godot wave gamepad button 6 missing")

	# 8. ResonanceWaveVFX 类
	var vfx_src := FileAccess.get_file_as_string("res://src/scripts/resonance_wave_vfx.gd")
	if "class_name ResonanceWaveVFX" in vfx_src:
		checks.append("ResonanceWaveVFX class_name declared ✓")
	else:
		errors.append("ResonanceWaveVFX class_name missing")
	if "func trigger(origin: Vector2, max_radius: float)" in vfx_src:
		checks.append("ResonanceWaveVFX.trigger signature ✓")
	else:
		errors.append("ResonanceWaveVFX.trigger signature missing")
	if "func add_hit_flash(target_pos: Vector2)" in vfx_src:
		checks.append("ResonanceWaveVFX.add_hit_flash ✓")
	else:
		errors.append("ResonanceWaveVFX.add_hit_flash missing")
	# VFX 用 Pale Resonance 主色
	if "Color(\"#B7E7DD\")" in vfx_src:
		checks.append("ResonanceWaveVFX Pale Resonance wave_color ✓")
	else:
		errors.append("ResonanceWaveVFX Pale Resonance color missing")
	if "Color(\"#69C7CE\")" in vfx_src:
		checks.append("ResonanceWaveVFX Glass Cyan outer_ring_color ✓")
	else:
		errors.append("ResonanceWaveVFX outer ring color missing")

	# Print
	print("=== T103 Resonance Wave smoke ===")
	for c in checks:
		print("  ", c)
	if errors.size() > 0:
		print("FAILED:")
		for e in errors:
			print("  - ", e)
		print("=== T103 FAILED: %d errors ===" % errors.size())
		quit(1)
	else:
		print("=== T103 PASS: %d checks ===" % checks.size())
		quit(0)
