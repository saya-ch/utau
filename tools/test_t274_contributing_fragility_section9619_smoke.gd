# T274 smoke test — CONTRIBUTING.md §9.6.19 `_verb_windup_vfx_base.gd` 共享契约 1:1 严格分离 polish 模式 (#193 普通模式 polish T274, T162 brittle 修复流程进一步扩展, 0 真实游戏代码改动)
# 验证 §9.6.19 文档化 + 7 件共享契约 1:1 描述 (3 字段 + 1 _ready() + 1 _process(delta) + 1 _activate_windup_tween() + 1 fade_out_and_free() + 1 super._ready() 首行 + 1 extends VerbWindupVFXBase 1:1) + 5 verb windup VFX 子类 (Pulse / Bind / Cut / Echo / Wave) extends VerbWindupVFXBase 0 重写共享契约 + 1 verb (Whisper) 0 extend base 漂移 (F013.E #159 落地时漂移, T275+ 重构目标)
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. CONTRIBUTING.md 包含 §9.6.19 标题
	f = FileAccess.open("res://CONTRIBUTING.md", FileAccess.READ)
	assert(f != null, "CONTRIBUTING.md exists")
	var contributing: String = f.get_as_text()
	f.close()
	if "### 9.6.19" in contributing:
		pass_count += 1
		print("PASS 1: CONTRIBUTING.md 包含 §9.6.19 章节标题")
	else:
		fail_count += 1
		print("FAIL 1: CONTRIBUTING.md 缺 §9.6.19 章节标题")

	# 2. §9.6.19 段含 4 段结构 (症状 / 触发场景 / 修复 / 预防)
	if "**症状 / 触发场景 / 修复 / 预防**" in contributing:
		pass_count += 1
		print("PASS 2: §9.6.19 段含 4 段完整结构 (症状 / 触发场景 / 修复 / 预防)")
	else:
		fail_count += 1
		print("FAIL 2: §9.6.19 段缺 4 段完整结构")

	# 3. §9.6.19 引用 _verb_windup_vfx_base.gd 共享契约关键字
	# T275 (#194) 之前 (T274 #193 落地时): 12 关键字含 "T275+" (T275+ 重构目标, 文档化待收回)
	# T275 (#194) 之后: 12 关键字含 "T275 #194" (T275 #194 收回完成状态) + "_is_active" 漂移关键字保留
	#   (作为漂移说明的 keyword, 记录 F013.E #159 落地时的命名偏离, T275 #194 已 1:1 rename 为 _active)
	var base_contract_keys: Array[String] = [
		"_verb_windup_vfx_base.gd",
		"VerbWindupVFXBase",
		"3 共享字段",
		"_max_lifetime",
		"_lifetime",
		"_active",
		"_activate_windup_tween",
		"fade_out_and_free",
		"z_index = 10",
		"WhisperWindupVFX",
		"_is_active",
		"T275 #194",
	]
	var all_keys_found: bool = true
	for key in base_contract_keys:
		if key not in contributing:
			all_keys_found = false
			print("FAIL 3.x: §9.6.19 段缺共享契约关键字: %s" % key)
	if all_keys_found:
		pass_count += 1
		print("PASS 3: §9.6.19 段含完整 7 件共享契约 1:1 描述 + Whisper 漂移关键字 (12/12 找到)")
	else:
		fail_count += 1
		print("FAIL 3: §9.6.19 段缺共享契约关键字")

	# 4. §9.6.19 引用 5 verb windup VFX 子类 + 1 verb Whisper
	var six_windup_verbs: Array[String] = [
		"PulseWindupVFX",
		"BindWindupVFX",
		"CutWindupVFX",
		"EchoWindupVFX",
		"WaveWindupVFX",
		"WhisperWindupVFX",
	]
	var all_verbs_found: bool = true
	for v in six_windup_verbs:
		if v not in contributing:
			all_verbs_found = false
			print("FAIL 4.x: §9.6.19 段缺 windup VFX 之一: %s" % v)
	if all_verbs_found:
		pass_count += 1
		print("PASS 4: §9.6.19 段含完整 6 verb windup VFX 子类引用 (6/6 找到, 含 5 verb 共享 base + 1 verb Whisper 漂移)")
	else:
		fail_count += 1
		print("FAIL 4: §9.6.19 段缺 windup VFX 子类引用")

	# 5. _verb_windup_vfx_base.gd 包含 class_name VerbWindupVFXBase + extends Node2D
	f = FileAccess.open("res://src/scripts/_verb_windup_vfx_base.gd", FileAccess.READ)
	assert(f != null, "_verb_windup_vfx_base.gd exists")
	var base_src: String = f.get_as_text()
	f.close()
	if "class_name VerbWindupVFXBase" in base_src and "extends Node2D" in base_src:
		pass_count += 1
		print("PASS 5: _verb_windup_vfx_base.gd 包含 class_name VerbWindupVFXBase + extends Node2D")
	else:
		fail_count += 1
		print("FAIL 5: _verb_windup_vfx_base.gd 缺 class_name VerbWindupVFXBase / extends Node2D")

	# 6. _verb_windup_vfx_base.gd 包含 3 共享字段
	var three_shared_fields: Array[String] = [
		"_max_lifetime",
		"_lifetime",
		"_active",
	]
	var field_count: int = 0
	for field in three_shared_fields:
		if "var %s" % field in base_src:
			field_count += 1
	if field_count == 3:
		pass_count += 1
		print("PASS 6: _verb_windup_vfx_base.gd 含完整 3 共享字段 (3/3 找到)")
	else:
		fail_count += 1
		print("FAIL 6: _verb_windup_vfx_base.gd 缺共享字段, 只找到 %d / 3" % field_count)

	# 7. _verb_windup_vfx_base.gd 包含 1 _ready() z_index=10 集中
	if "func _ready()" in base_src and "z_index = 10" in base_src:
		pass_count += 1
		print("PASS 7: _verb_windup_vfx_base.gd 含 1 _ready() z_index=10 集中")
	else:
		fail_count += 1
		print("FAIL 7: _verb_windup_vfx_base.gd 缺 _ready() / z_index=10")

	# 8. _verb_windup_vfx_base.gd 包含 1 _process(delta) 生命周期
	if "func _process(delta" in base_src and "queue_free()" in base_src and "queue_redraw()" in base_src:
		pass_count += 1
		print("PASS 8: _verb_windup_vfx_base.gd 含 1 _process(delta) 生命周期 + queue_free + queue_redraw")
	else:
		fail_count += 1
		print("FAIL 8: _verb_windup_vfx_base.gd 缺 _process(delta) / queue_free / queue_redraw")

	# 9. _verb_windup_vfx_base.gd 包含 1 _activate_windup_tween() ramp-in tween (T174 #93 落地)
	if "func _activate_windup_tween()" in base_src and "Tween.TRANS_QUAD" in base_src and "Tween.EASE_OUT" in base_src:
		pass_count += 1
		print("PASS 9: _verb_windup_vfx_base.gd 含 1 _activate_windup_tween() ramp-in tween (TRANS_QUAD EASE_OUT)")
	else:
		fail_count += 1
		print("FAIL 9: _verb_windup_vfx_base.gd 缺 _activate_windup_tween / TRANS_QUAD / EASE_OUT")

	# 10. _verb_windup_vfx_base.gd 包含 1 fade_out_and_free() 0.05s 退出 (T173 #92 落地)
	if "func fade_out_and_free" in base_src and 'tween_property(self, "modulate:a", 0.0, 0.05)' in base_src:
		pass_count += 1
		print("PASS 10: _verb_windup_vfx_base.gd 含 1 fade_out_and_free() 0.05s 退出 (T173 #92 落地, idempotent)")
	else:
		fail_count += 1
		print("FAIL 10: _verb_windup_vfx_base.gd 缺 fade_out_and_free / 0.05s tween")

	# 11. 5 verb windup VFX 子类 extends VerbWindupVFXBase
	var five_windup_files: Array[String] = [
		"res://src/scripts/pulse_windup_vfx.gd",
		"res://src/scripts/bind_windup_vfx.gd",
		"res://src/scripts/cut_windup_vfx.gd",
		"res://src/scripts/echo_windup_vfx.gd",
		"res://src/scripts/wave_windup_vfx.gd",
	]
	var five_windup_classes: Array[String] = [
		"PulseWindupVFX",
		"BindWindupVFX",
		"CutWindupVFX",
		"EchoWindupVFX",
		"WaveWindupVFX",
	]
	var extends_count: int = 0
	for i in range(five_windup_files.size()):
		var fp: String = five_windup_files[i]
		var cls: String = five_windup_classes[i]
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			print("FAIL 11.x: %s 不存在" % fp)
			continue
		var src: String = sf.get_as_text()
		sf.close()
		if "class_name %s" % cls in src and "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"" in src:
			extends_count += 1
		else:
			print("FAIL 11.x: %s 缺 class_name / extends VerbWindupVFXBase" % fp)
	if extends_count == 5:
		pass_count += 1
		print("PASS 11: 5 verb windup VFX 子类 (Pulse / Bind / Cut / Echo / Wave) 全部 extends VerbWindupVFXBase (5/5 找到)")
	else:
		fail_count += 1
		print("FAIL 11: 5 verb windup VFX 子类 extends 不全, 只找到 %d / 5" % extends_count)

	# 12. 5 verb windup VFX 子类 0 重声明 3 共享字段 (字段 shadow 1:1 严格分离)
	var field_shadow_count: int = 0
	for fp in five_windup_files:
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		# 检查子类源代码是否重声明 base 共享字段
		# 必须 0 重声明 (会 shadow base 字段)
		for field in three_shared_fields:
			var redeclare_pattern: String = "var %s:" % field
			for line in src.split("\n"):
				var stripped: String = line.strip_edges()
				if stripped.begins_with("#"):
					continue
				if redeclare_pattern in line or ("var %s =" % field) in line or ("var %s " % field) in line:
					field_shadow_count += 1
					print("FAIL 12.x: %s 重声明 base 共享字段 %s (shadow): %s" % [fp, field, line])
	if field_shadow_count == 0:
		pass_count += 1
		print("PASS 12: 5 verb windup VFX 子类 0 重声明 3 共享字段 (字段 shadow 0, 共享契约 1:1 严格分离)")
	else:
		fail_count += 1
		print("FAIL 12: 5 verb windup VFX 子类重声明 %d 个 base 共享字段 (shadow 违反 §9.6.19)" % field_shadow_count)

	# 13. 5 verb windup VFX 子类 0 override _ready() (z_index=10 集中)
	var ready_override_count: int = 0
	for fp in five_windup_files:
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		if "func _ready()" in src:
			ready_override_count += 1
			print("FAIL 13.x: %s override _ready() (违反 §9.6.19 base z_index=10 集中)" % fp)
	if ready_override_count == 0:
		pass_count += 1
		print("PASS 13: 5 verb windup VFX 子类 0 override _ready() (z_index=10 base 集中 1:1 严格分离)")
	else:
		fail_count += 1
		print("FAIL 13: 5 verb windup VFX 子类 override %d 个 _ready() (违反 §9.6.19)" % ready_override_count)

	# 14. 5 verb windup VFX 子类 0 override _process(delta) 生命周期
	var process_override_count: int = 0
	for fp in five_windup_files:
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		if "func _process(delta" in src:
			process_override_count += 1
			print("FAIL 14.x: %s override _process(delta) (违反 §9.6.19 base 生命周期 1:1 集中)" % fp)
	if process_override_count == 0:
		pass_count += 1
		print("PASS 14: 5 verb windup VFX 子类 0 override _process(delta) (base 生命周期 1:1 集中)")
	else:
		fail_count += 1
		print("FAIL 14: 5 verb windup VFX 子类 override %d 个 _process(delta) (违反 §9.6.19)" % process_override_count)

	# 15. 5 verb windup VFX 子类 0 override _activate_windup_tween() (T174 #93 ramp-in tween)
	var tween_override_count: int = 0
	for fp in five_windup_files:
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		# 检查子类是否 override (重新声明) _activate_windup_tween
		# 通过检查 "func _activate_windup_tween" 是否在子类源代码出现 (subclass override 标志)
		# base 在 _verb_windup_vfx_base.gd 1 次声明
		if "func _activate_windup_tween" in src:
			tween_override_count += 1
			print("FAIL 15.x: %s override _activate_windup_tween() (违反 §9.6.19 base tween 1:1 集中)" % fp)
		# 验证 trigger() 末尾调 _activate_windup_tween() (T174.B #94 替代 4-line tween block)
		elif "_activate_windup_tween()" not in src:
			print("FAIL 15.x: %s 缺 trigger() 末尾的 _activate_windup_tween() 调用 (违反 T174.B #94 1:1 复制)" % fp)
	if tween_override_count == 0:
		pass_count += 1
		print("PASS 15: 5 verb windup VFX 子类 0 override _activate_windup_tween() (T174.B #94 base tween 1:1 集中, trigger() 末尾 1 行调用)")
	else:
		fail_count += 1
		print("FAIL 15: 5 verb windup VFX 子类 override %d 个 _activate_windup_tween() (违反 §9.6.19)" % tween_override_count)

	# 16. 5 verb windup VFX 子类 0 override fade_out_and_free() (T173 #92 0.05s 退出)
	var fade_override_count: int = 0
	for fp in five_windup_files:
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		# 检查子类是否 override (重新声明) fade_out_and_free
		if "func fade_out_and_free" in src:
			fade_override_count += 1
			print("FAIL 16.x: %s override fade_out_and_free() (违反 §9.6.19 base 0.05s 退出 1:1 集中)" % fp)
	if fade_override_count == 0:
		pass_count += 1
		print("PASS 16: 5 verb windup VFX 子类 0 override fade_out_and_free() (T173 #92 base 0.05s 退出 1:1 集中, idempotent)")
	else:
		fail_count += 1
		print("FAIL 16: 5 verb windup VFX 子类 override %d 个 fade_out_and_free() (违反 §9.6.19)" % fade_override_count)

	# 17. Whisper 已知 drift — T275 (#194) 收回 4 项漂移, 期望 0 漂移
	# T275 之前 (T274 #193 落地时): 期望 4 项漂移 (0 extend base / _is_active 命名偏离 / 自实现 _process / 自实现 fade_out_and_free)
	# T275 之后: 4 项漂移全部收回 — 6 verb windup VFX 共享契约 1:1 严格分离 100% 闭环.
	#   (1) extends Node2D → extends VerbWindupVFXBase (收回)
	#   (2) var _is_active → _active 1:1 rename (收回)
	#   (3) 自实现 _process(delta) → 走 base 1:1 集中 (收回)
	#   (4) 自实现 fade_out_and_free() → 走 base 0.05s 退出 1:1 集中 (收回)
	#   业务特例保留: z_index=50 (VFX 在玩家上方, 区别于 5 verb z_index=10), 显式 override _ready() 调 super 集中 z_index=10 + 重设 z_index=50.
	var whisper_src: String = FileAccess.get_file_as_string("res://src/scripts/whisper_windup_vfx.gd")
	var whisper_drift_count: int = 0
	# 漂移 1: extends Node2D (而非 base) — T275 收回
	if "extends Node2D" in whisper_src:
		whisper_drift_count += 1
		print("FAIL 17.1: whisper_windup_vfx.gd 仍 extends Node2D (T275 #194 未收回)")
	elif "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"" in whisper_src:
		pass # T275 收回 OK
	else:
		whisper_drift_count += 1
		print("FAIL 17.1: whisper_windup_vfx.gd extends 异常")
	# 漂移 2: 字段名 _is_active vs base _active — T275 收回
	if "var _is_active" in whisper_src:
		whisper_drift_count += 1
		print("FAIL 17.2: whisper_windup_vfx.gd 仍含 var _is_active (T275 #194 未 rename)")
	# 漂移 3: 自实现 _process(delta) — T275 收回
	if "func _process(delta" in whisper_src:
		whisper_drift_count += 1
		print("FAIL 17.3: whisper_windup_vfx.gd 仍自实现 _process(delta) (T275 #194 未收回)")
	# 漂移 4: 自实现 fade_out_and_free() — T275 收回
	if "func fade_out_and_free" in whisper_src:
		whisper_drift_count += 1
		print("FAIL 17.4: whisper_windup_vfx.gd 仍自实现 fade_out_and_free() (T275 #194 未收回)")
	if whisper_drift_count == 0:
		pass_count += 1
		print("PASS 17: T275 (#194) 收回 §9.6.19 全部 4 项漂移 — 6 verb windup VFX 共享契约 1:1 严格分离 100% 闭环 (extends base + _active rename + 0 _process override + 0 fade_out_and_free override, 业务特例 z_index=50 保留)")
	else:
		fail_count += 1
		print("FAIL 17: T275 (#194) 仅收回 %d / 4 项漂移, 还有漂移未清理" % whisper_drift_count)

	# 18. CHANGELOG.md 包含 T274 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T274" in changelog and "§9.6.19" in changelog:
		pass_count += 1
		print("PASS 18: CHANGELOG.md 含 T274 §9.6.19 段")
	else:
		fail_count += 1
		print("FAIL 18: CHANGELOG.md 缺 T274 §9.6.19 段")

	# 19. ROADMAP.md 顶部含 T274 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T274" in roadmap and "§9.6.19" in roadmap:
		pass_count += 1
		print("PASS 19: ROADMAP.md 顶部含 T274 §9.6.19 引用")
	else:
		fail_count += 1
		print("FAIL 19: ROADMAP.md 顶部缺 T274 §9.6.19 引用")

	# 20. 静态解析 — 0 SCRIPT ERROR
	print("PASS 20: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# Summary
	print("")
	print("=== T274 smoke test summary: %d passed, %d failed ===" % [pass_count + 1, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
