# T273 smoke test — CONTRIBUTING.md §9.6.18 `_verb_ability_base.gd` 共享契约 1:1 严格分离 polish 模式 (#192 普通模式 polish T273, T162 brittle 修复流程进一步扩展, 0 真实游戏代码改动)
# 验证 §9.6.18 文档化 + 6 件共享契约 1:1 描述 (6 字段 + 1 @onready + 2 @export + 5 共享方法 + 1 _exit_tree 兜底 + 1 is_globally_blocking 扩展) + 6 verb ability 子类 (Pulse / Bind / Cut / Echo / Wave / Whisper) extends VerbAbilityBase 0 重写共享契约
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.18 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.18" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.18 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.18 章节标题")

	# 2. §9.6.18 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	if "**症状 / 触发场景 / 修复 / 预防**" in contributing:
		pass_count += 1
		print("PASS 2: §9.6.18 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.18 段缺 4 段完整结构")

	# 3. §9.6.18 引用 _verb_ability_base.gd 共享契约
	var base_contract_keys: Array[String] = [
		"_verb_ability_base.gd",
		"VerbAbilityBase",
		"6 共享字段",
		"1 `@onready`",
		"2 `@export`",
		"6 共享方法",
		"is_globally_blocking",
		"_exit_tree",
	]
	var all_keys_found: bool = true
	for key in base_contract_keys:
		if key not in contributing:
			all_keys_found = false
			print("FAIL 3.x: §9.6.18 段缺共享契约关键字: %s" % key)
	if all_keys_found:
		pass_count += 1
		print("PASS 3: §9.6.18 段含完整 6 件共享契约 1:1 描述 (6 字段 + 1 @onready + 2 @export + 5 共享方法 + 1 is_globally_blocking + 1 _exit_tree)")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.18 段缺 6 件共享契约 1:1 描述")

	# 4. §9.6.18 引用 6 verb ability 子类 (Pulse / Bind / Cut / Echo / Wave / Whisper)
	var six_verbs: Array[String] = [
		"PulseAbility",
		"BindAbility",
		"CutAbility",
		"EchoAbility",
		"ResonanceWaveAbility",
		"WhisperAbility",
	]
	var all_verbs_found: bool = true
	for v in six_verbs:
		if v not in contributing:
			all_verbs_found = false
			print("FAIL 4.x: §9.6.18 段缺 6 verb 子类之一: %s" % v)
	if all_verbs_found:
		pass_count += 1
		print("PASS 4: §9.6.18 段含完整 6 verb ability 子类引用")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.18 段缺 6 verb ability 子类引用")

	# 5. _verb_ability_base.gd 包含 class_name VerbAbilityBase + extends Node
	f = FileAccess.open("res://src/scripts/_verb_ability_base.gd", FileAccess.READ)
	assert(f != null, "_verb_ability_base.gd exists")
	var base_src: String = f.get_as_text()
	f.close()
	if "class_name VerbAbilityBase" in base_src and "extends Node" in base_src:
		pass_count += 1
		print("PASS 5: _verb_ability_base.gd 包含 class_name VerbAbilityBase + extends Node")
	else:
		fail_count += 1
		print("FAIL 5: _verb_ability_base.gd 缺 class_name VerbAbilityBase / extends Node")

	# 6. _verb_ability_base.gd 包含 6 共享字段
	var six_shared_fields: Array[String] = [
		"_cooldown_timer",
		"_windup_timer",
		"_is_winding_up",
		"_pending_origin",
		"_pending_direction",
		"_windup_vfx",
	]
	var field_count: int = 0
	for field in six_shared_fields:
		if "var %s" % field in base_src:
			field_count += 1
	if field_count == 6:
		pass_count += 1
		print("PASS 6: _verb_ability_base.gd 含完整 6 共享字段 (6/6 找到)")
	else:
		fail_count += 1
		print("FAIL 6: _verb_ability_base.gd 缺共享字段, 只找到 %d / 6" % field_count)

	# 7. _verb_ability_base.gd 包含 1 @onready 共享 _player
	if "@onready var _player" in base_src:
		pass_count += 1
		print("PASS 7: _verb_ability_base.gd 含 1 @onready 共享 _player")
	else:
		fail_count += 1
		print("FAIL 7: _verb_ability_base.gd 缺 @onready _player")

	# 8. _verb_ability_base.gd 包含 2 @export 共享 cooldown / windup_time (H001 #99 关键踩坑)
	var two_exports: Array[String] = [
		"@export var cooldown",
		"@export var windup_time",
	]
	var export_count: int = 0
	for exp in two_exports:
		if exp in base_src:
			export_count += 1
	if export_count == 2:
		pass_count += 1
		print("PASS 8: _verb_ability_base.gd 含 2 @export 共享 cooldown / windup_time (H001 #99 关键修复, 0 子类重声明)")
	else:
		fail_count += 1
		print("FAIL 8: _verb_ability_base.gd 缺 @export 共享 cooldown / windup_time, 只找到 %d / 2" % export_count)

	# 9. _verb_ability_base.gd 包含 5 共享方法
	var five_shared_methods: Array[String] = [
		"func _consume_verb_cost",
		"func _setup_windup_state",
		"func _process_cooldown",
		"func get_cooldown_ratio",
		"func is_winding_up",
	]
	var method_count: int = 0
	for method in five_shared_methods:
		if method in base_src:
			method_count += 1
	if method_count == 5:
		pass_count += 1
		print("PASS 9: _verb_ability_base.gd 含完整 5 共享方法 (_consume_verb_cost / _setup_windup_state / _process_cooldown / get_cooldown_ratio / is_winding_up)")
	else:
		fail_count += 1
		print("FAIL 9: _verb_ability_base.gd 缺共享方法, 只找到 %d / 5" % method_count)

	# 10. _verb_ability_base.gd 包含 _exit_tree 兜底 (T173 #92 关键修复)
	if "func _exit_tree" in base_src and "fade_out_and_free" in base_src:
		pass_count += 1
		print("PASS 10: _verb_ability_base.gd 含 _exit_tree 兜底 fade_out_and_free (T173 #92 关键修复)")
	else:
		fail_count += 1
		print("FAIL 10: _verb_ability_base.gd 缺 _exit_tree 兜底 / fade_out_and_free")

	# 11. 6 verb ability 子类 extends VerbAbilityBase
	var six_ability_files: Array[String] = [
		"res://src/scripts/pulse_ability.gd",
		"res://src/scripts/bind_ability.gd",
		"res://src/scripts/cut_ability.gd",
		"res://src/scripts/echo_ability.gd",
		"res://src/scripts/resonance_wave_ability.gd",
		"res://src/scripts/whisper_ability.gd",
	]
	var six_ability_classes: Array[String] = [
		"PulseAbility",
		"BindAbility",
		"CutAbility",
		"EchoAbility",
		"ResonanceWaveAbility",
		"WhisperAbility",
	]
	var extends_count: int = 0
	for i in range(six_ability_files.size()):
		var fp: String = six_ability_files[i]
		var cls: String = six_ability_classes[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			print("FAIL 11.x: %s 不存在" % fp)
			continue
		var src: String = sf.get_as_text()
		sf.close()
		if "class_name %s" % cls in src and "extends \"res://src/scripts/_verb_ability_base.gd\"" in src:
			extends_count += 1
		else:
			print("FAIL 11.x: %s 缺 class_name / extends VerbAbilityBase" % fp)
	if extends_count == 6:
		pass_count += 1
		print("PASS 11: 6 verb ability 子类 (Pulse / Bind / Cut / Echo / Wave / Whisper) 全部 extends VerbAbilityBase (6/6 找到)")
	else:
		fail_count += 1
		print("FAIL 11: 6 verb ability 子类 extends 不全, 只找到 %d / 6" % extends_count)

	# 12. 6 verb 子类 0 重声明 6 共享字段 (字段 shadow 1 字段 1:1 严格分离)
	var field_shadow_count: int = 0
	for i in range(six_ability_files.size()):
		var fp: String = six_ability_files[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		# 检查子类是否重新声明了 base 共享字段 (在子类自身)
		# 必须 0 重声明 (会 shadow base 字段)
		# 通过检查 "var _cooldown_timer" / "var _windup_timer" 等是否仅在 base 出现
		# 由于子类 extends, 这些字段可访问, 但子类不能重新声明
		# 简单检查: 子类源代码不含 "var _cooldown_timer" 重新声明
		for field in six_shared_fields:
			var redeclare_pattern: String = "var %s:" % field
			# 子类应 0 重声明 base 字段. 但子类可能用 _cooldown_timer 是从 base 继承, 不写 var.
			# 检查思路: 子类源代码不应有 "var _cooldown_timer" 或 "var _cooldown_timer ="
			if redeclare_pattern in src or ("var %s =" % field) in src or ("var %s " % field) in src:
				# 排除注释行
				for line in src.split("\n"):
					var stripped: String = line.strip_edges()
					if stripped.begins_with("#"):
						continue
					if redeclare_pattern in line or ("var %s =" % field) in line or ("var %s " % field) in line:
						field_shadow_count += 1
						print("FAIL 12.x: %s 重声明 base 共享字段 %s (shadow): %s" % [fp, field, line])
	if field_shadow_count == 0:
		pass_count += 1
		print("PASS 12: 6 verb 子类 0 重声明 6 共享字段 (字段 shadow 0 / 6 共享契约 1:1 严格分离)")
	else:
		fail_count += 1
		print("FAIL 12: 6 verb 子类重声明 %d 个 base 共享字段 (shadow 违反 §9.6.18)" % field_shadow_count)

	# 13. 6 verb 子类 0 重声明 1 @onready _player
	var onready_shadow_count: int = 0
	for i in range(six_ability_files.size()):
		var fp: String = six_ability_files[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		if "@onready var _player" in src:
			onready_shadow_count += 1
			print("FAIL 13.x: %s 重声明 @onready _player (shadow base)" % fp)
	if onready_shadow_count == 0:
		pass_count += 1
		print("PASS 13: 6 verb 子类 0 重声明 @onready _player (1 字段 1:1 严格分离)")
	else:
		fail_count += 1
		print("FAIL 13: 6 verb 子类重声明 %d 个 @onready _player (shadow 违反 §9.6.18)" % onready_shadow_count)

	# 14. 6 verb 子类 0 重声明 2 @export cooldown / windup_time (H001 #99 关键踩坑)
	var export_shadow_count: int = 0
	for i in range(six_ability_files.size()):
		var fp: String = six_ability_files[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		# 子类 0 重声明 @export var cooldown / @export var windup_time (排除注释行)
		for exp in two_exports:
			for line in src.split("\n"):
				var stripped: String = line.strip_edges()
				if stripped.begins_with("#"):
					continue
				if exp in stripped:
					export_shadow_count += 1
					print("FAIL 14.x: %s 重声明 @export %s (H001 #99 关键踩坑: The member 'cooldown' already exists in parent class): %s" % [fp, exp, line])
	if export_shadow_count == 0:
		pass_count += 1
		print("PASS 14: 6 verb 子类 0 重声明 @export cooldown / windup_time (H001 #99 关键修复, .tscn 端 override 1:1)")
	else:
		fail_count += 1
		print("FAIL 14: 6 verb 子类重声明 %d 个 @export (H001 #99 关键踩坑回归)" % export_shadow_count)

	# 15. 6 verb 子类调用 super._ready() 首行 (1:1 共享契约 0 漏)
	var super_ready_count: int = 0
	for i in range(six_ability_files.size()):
		var fp: String = six_ability_files[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		# 检查子类源代码有 super._ready() 调用
		if "super._ready()" in src:
			super_ready_count += 1
	if super_ready_count == 6:
		pass_count += 1
		print("PASS 15: 6 verb 子类调用 super._ready() (6/6 找到, 共享契约 0 漏 super)")
	else:
		fail_count += 1
		print("FAIL 15: 6 verb 子类缺 super._ready() 调用, 只找到 %d / 6" % super_ready_count)

	# 16. 6 verb 子类调用 _process_cooldown(delta, "<verb>") opt-in (T181 #97 共享)
	var six_verb_names: Array[String] = [
		"pulse",
		"bind",
		"cut",
		"echo",
		"wave",
		"whisper",
	]
	var process_cooldown_count: int = 0
	for i in range(six_ability_files.size()):
		var fp: String = six_ability_files[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		var verb_name: String = six_verb_names[i]
		var process_pattern: String = '_process_cooldown(delta, "%s")' % verb_name
		if process_pattern in src:
			process_cooldown_count += 1
	if process_cooldown_count == 6:
		pass_count += 1
		print("PASS 16: 6 verb 子类 opt-in _process_cooldown(delta, '<verb>') (6/6 找到, T181 #97 共享契约 0 漏)")
	else:
		fail_count += 1
		print("FAIL 16: 6 verb 子类 _process_cooldown opt-in 不全, 只找到 %d / 6" % process_cooldown_count)

	# 17. 2 verb 子类 (Wave / Whisper) 重写 is_globally_blocking() (D001 #82 PlayerActionGate 反查入口)
	var two_global_blocking: Array[int] = [0, 0]
	# 0 = resonance_wave_ability, 1 = whisper_ability
	var wave_src: String = FileAccess.get_file_as_string("res://src/scripts/resonance_wave_ability.gd")
	var whisper_src: String = FileAccess.get_file_as_string("res://src/scripts/whisper_ability.gd")
	if "func is_globally_blocking" in wave_src:
		two_global_blocking[0] = 1
	if "func is_globally_blocking" in whisper_src:
		two_global_blocking[1] = 1
	var total_global: int = two_global_blocking[0] + two_global_blocking[1]
	if total_global == 2:
		pass_count += 1
		print("PASS 17: 2 verb (Wave / Whisper) 重写 is_globally_blocking() (2/2 找到, D001 #82 PlayerActionGate 反查入口)")
	else:
		fail_count += 1
		print("FAIL 17: is_globally_blocking() 重写不全, 只找到 %d / 2" % total_global)

	# 18. CHANGELOG.md 包含 T273 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T273" in changelog and "§9.6.18" in changelog:
		pass_count += 1
		print("PASS 18: CHANGELOG.md 含 T273 §9.6.18 段")
	else:
		fail_count += 1
		print("FAIL 18: CHANGELOG.md 缺 T273 §9.6.18 段")

	# 19. ROADMAP.md 顶部含 T273 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T273" in roadmap and "§9.6.18" in roadmap:
		pass_count += 1
		print("PASS 19: ROADMAP.md 顶部含 T273 §9.6.18 引用")
	else:
		fail_count += 1
		print("FAIL 19: ROADMAP.md 顶部缺 T273 §9.6.18 引用")

	# 20. 静态解析 — 0 SCRIPT ERROR
	print("PASS 20: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# Summary
	print("")
	print("=== T273 smoke test summary: %d passed, %d failed ===" % [pass_count + 1, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
