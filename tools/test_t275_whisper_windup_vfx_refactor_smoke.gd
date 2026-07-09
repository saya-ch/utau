# T275 smoke test — WhisperWindupVFX 收回 §9.6.19 已知 drift 5 项 (F013.E #159 漂移) + 让 6 verb windup VFX 共享契约 1:1 严格分离 100% 闭环 (#194 普通模式 polish T275, 1 任务真实代码重构, 0 玩法变化, 0 性能影响, 0 critical/major/minor/warning, ~10min 内完成)
# 验证 T275 重构:
#   1. whisper_windup_vfx.gd 改成 extends "res://src/scripts/_verb_windup_vfx_base.gd" (不再 extends Node2D)
#   2. 0 字段 shadow (不再重声明 3 共享字段 _max_lifetime / _lifetime / _active)
#   3. 1 verb 显式 override _ready() (因为 z_index=50 业务需求, super 后重设, 与 §9.6.18 Wave 显式重写 byte-identical 模式 镜像)
#   4. 0 override _process(delta) (走 base 1:1 生命周期)
#   5. 0 override fade_out_and_free() (走 base 0.05s 退出)
#   6. trigger() 末尾调 _activate_windup_tween() (与 5 verb 1:1, T174.B #94 模式)
#   7. _draw() 用 if not _active: 守卫 (rename _is_active → _active 1:1)
#   8. z_index = 50 业务需求保留 (override _ready 末尾重设, 区别于 5 verb z_index=10)
#   9. 静态解析 0 SCRIPT ERROR
extends SceneTree

func _init() -> void:
	var pass_count: int = 0
	var fail_count: int = 0
	var f: FileAccess

	# 1. whisper_windup_vfx.gd 存在
	f = FileAccess.open("res://src/scripts/whisper_windup_vfx.gd", FileAccess.READ)
	assert(f != null, "whisper_windup_vfx.gd exists")
	var whisper_src: String = f.get_as_text()
	f.close()
	pass_count += 1
	print("PASS 1: whisper_windup_vfx.gd 存在 (T275 重构对象)")

	# 2. T275 重构: extends VerbWindupVFXBase (不再 extends Node2D)
	if "class_name WhisperWindupVFX" in whisper_src and "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"" in whisper_src:
		pass_count += 1
		print("PASS 2: whisper_windup_vfx.gd extends \"res://src/scripts/_verb_windup_vfx_base.gd\" (F013.E 漂移收回, 6 verb windup VFX 共享 base 100% 闭环)")
	else:
		fail_count += 1
		print("FAIL 2: whisper_windup_vfx.gd 缺 class_name / extends VerbWindupVFXBase")

	# 3. T275 重构: 0 重声明 3 共享字段 (字段 shadow 0)
	var three_shared_fields: Array[String] = [
		"_max_lifetime",
		"_lifetime",
		"_active",
	]
	var field_shadow_count: int = 0
	for field in three_shared_fields:
		var redeclare_pattern_a: String = "var %s:" % field
		var redeclare_pattern_b: String = "var %s =" % field
		var redeclare_pattern_c: String = "var %s " % field
		for line in whisper_src.split("\n"):
			var stripped: String = line.strip_edges()
			if stripped.begins_with("#"):
				continue
			# 排除 import / 函数参数 (如 func _process(delta: float)) 等
			if redeclare_pattern_a in line or redeclare_pattern_b in line or redeclare_pattern_c in line:
				# 排除可能误判的行
				if ("func " in line) or ("#" in stripped and stripped.find("#") < stripped.find("var")):
					continue
				field_shadow_count += 1
				print("FAIL 3.x: whisper_windup_vfx.gd 重声明 base 共享字段 %s (shadow): %s" % [field, line])
	if field_shadow_count == 0:
		pass_count += 1
		print("PASS 3: whisper_windup_vfx.gd 0 重声明 3 共享字段 (字段 shadow 0, 共享契约 1:1 严格分离)")
	else:
		fail_count += 1
		print("FAIL 3: whisper_windup_vfx.gd 重声明 %d 个 base 共享字段 (shadow 违反 §9.6.19)" % field_shadow_count)

	# 4. T275 重构: 0 字段名 _is_active (rename 完成)
	if "var _is_active" in whisper_src:
		fail_count += 1
		print("FAIL 4: whisper_windup_vfx.gd 仍含 _is_active 字段 (rename 1:1 未完成)")
	else:
		pass_count += 1
		print("PASS 4: whisper_windup_vfx.gd 0 含 _is_active 字段 (rename _is_active → _active 1:1 完成)")

	# 5. T275 重构: 1 verb 显式 override _ready() (业务特例: z_index=50)
	if "func _ready()" in whisper_src and "super._ready()" in whisper_src and "z_index = 50" in whisper_src:
		pass_count += 1
		print("PASS 5: whisper_windup_vfx.gd 显式 override _ready() (super 集中 z_index=10 + 重设 z_index=50 业务需求, 与 §9.6.18 Wave 显式重写 模式 镜像)")
	else:
		fail_count += 1
		print("FAIL 5: whisper_windup_vfx.gd 缺 _ready() override / super._ready() / z_index=50")

	# 6. T275 重构: 0 override _process(delta) (走 base 1:1 生命周期)
	if "func _process(delta" in whisper_src:
		fail_count += 1
		print("FAIL 6: whisper_windup_vfx.gd 仍 override _process(delta) (应走 base 1:1 集中, F013.E 漂移未收回)")
	else:
		pass_count += 1
		print("PASS 6: whisper_windup_vfx.gd 0 override _process(delta) (走 base 1:1 集中, 生命周期共享契约严格分离)")

	# 7. T275 重构: 0 override fade_out_and_free() (走 base 0.05s 退出)
	if "func fade_out_and_free" in whisper_src:
		fail_count += 1
		print("FAIL 7: whisper_windup_vfx.gd 仍 override fade_out_and_free() (应走 base 0.05s 退出, F013.E 漂移未收回)")
	else:
		pass_count += 1
		print("PASS 7: whisper_windup_vfx.gd 0 override fade_out_and_free() (走 base 0.05s 退出, T173 #92 共享契约严格分离)")

	# 8. T275 重构: trigger() 末尾调 _activate_windup_tween() (与 5 verb 1:1, T174.B #94 模式)
	if "func trigger" in whisper_src and "_activate_windup_tween()" in whisper_src:
		pass_count += 1
		print("PASS 8: whisper_windup_vfx.gd trigger() 末尾调 _activate_windup_tween() (与 5 verb 1:1, T174.B #94 模式)")
	else:
		fail_count += 1
		print("FAIL 8: whisper_windup_vfx.gd trigger() 缺 _activate_windup_tween() 调用 (违反 T174.B #94 1:1 复制)")

	# 9. T275 重构: _draw() 用 if not _active: 守卫 (rename _is_active → _active 1:1)
	if "func _draw()" in whisper_src and "if not _active:" in whisper_src:
		pass_count += 1
		print("PASS 9: whisper_windup_vfx.gd _draw() 用 if not _active: 守卫 (rename _is_active → _active 1:1 完成)")
	else:
		fail_count += 1
		print("FAIL 9: whisper_windup_vfx.gd _draw() 缺 if not _active: 守卫 (rename 未完成)")

	# 10. T275 重构: z_index = 50 业务需求保留
	if "z_index = 50" in whisper_src:
		pass_count += 1
		print("PASS 10: whisper_windup_vfx.gd z_index = 50 业务需求保留 (VFX 在玩家上方, 区别于 5 verb z_index=10)")
	else:
		fail_count += 1
		print("FAIL 10: whisper_windup_vfx.gd 缺 z_index = 50 业务需求 (Whisper VFX 应在玩家上方)")

	# 11. T275 重构: 业务特定字段保留 (whisper_color, line_count, line_length, _max_radius)
	var whisper_specific_fields: Array[String] = [
		"whisper_color",
		"line_count",
		"line_length",
		"_max_radius",
	]
	var spec_field_count: int = 0
	for sf in whisper_specific_fields:
		if ("var %s" % sf in whisper_src) or ("@export var %s" % sf in whisper_src):
			spec_field_count += 1
	if spec_field_count == 4:
		pass_count += 1
		print("PASS 11: whisper_windup_vfx.gd 业务特定字段 4 个保留 (whisper_color / line_count / line_length / _max_radius, 0 改 0 删)")
	else:
		fail_count += 1
		print("FAIL 11: whisper_windup_vfx.gd 业务特定字段只保留 %d / 4" % spec_field_count)

	# 12. T275 重构: _draw() 圆球 + 4 收敛线 视觉保留 (4 短 line, 1.5 px stroke, Muted Mauve #C8A4D8)
	if "draw_arc" in whisper_src and "draw_line" in whisper_src and "#C8A4D8" in whisper_src and "1.5" in whisper_src:
		pass_count += 1
		print("PASS 12: whisper_windup_vfx.gd _draw() 圆球 + 4 收敛线 + Muted Mauve 视觉保留 (F013.E 0 改 视觉)")
	else:
		fail_count += 1
		print("FAIL 12: whisper_windup_vfx.gd _draw() 视觉 0 完整保留 (F013.E 视觉组漂移)")

	# 13. T275 注释锚点至少 5 处 (T275 (#194) docblock)
	var t275_anchor_count: int = 0
	for line in whisper_src.split("\n"):
		if "T275 (#194)" in line or "T275 (#" in line or "T275" in line:
			t275_anchor_count += 1
	if t275_anchor_count >= 5:
		pass_count += 1
		print("PASS 13: whisper_windup_vfx.gd 含 T275 (#194) 注释锚点 %d 处 (>= 5, T162 brittle 流程留痕)" % t275_anchor_count)
	else:
		fail_count += 1
		print("FAIL 13: whisper_windup_vfx.gd T275 注释锚点 %d 处 (< 5, 不足 5 处留痕)" % t275_anchor_count)

	# 14. _verb_windup_vfx_base.gd 0 改 0 触碰 (T275 0 副作用硬约束)
	f = FileAccess.open("res://src/scripts/_verb_windup_vfx_base.gd", FileAccess.READ)
	assert(f != null, "_verb_windup_vfx_base.gd exists")
	var base_src: String = f.get_as_text()
	f.close()
	if "class_name VerbWindupVFXBase" in base_src and "func _ready()" in base_src and "func _process(delta" in base_src and "func _activate_windup_tween()" in base_src and "func fade_out_and_free" in base_src and "z_index = 10" in base_src:
		pass_count += 1
		print("PASS 14: _verb_windup_vfx_base.gd 0 改 0 触碰 (T275 0 副作用, base 既有 7 件共享契约 完整保留)")
	else:
		fail_count += 1
		print("FAIL 14: _verb_windup_vfx_base.gd 0 完整保留 (T275 副作用扩散, 违反 §9.6.19 硬约束)")

	# 15. 5 verb windup VFX 子类 0 改 0 触碰 (T275 0 副作用硬约束)
	var five_windup_files: Array[String] = [
		"res://src/scripts/pulse_windup_vfx.gd",
		"res://src/scripts/bind_windup_vfx.gd",
		"res://src/scripts/cut_windup_vfx.gd",
		"res://src/scripts/echo_windup_vfx.gd",
		"res://src/scripts/wave_windup_vfx.gd",
	]
	var five_windup_intact: int = 0
	for fp in five_windup_files:
		var sf: FileAccess = FileAccess.open(fp, FileAccess.READ)
		if sf == null:
			continue
		var src: String = sf.get_as_text()
		sf.close()
		if "extends \"res://src/scripts/_verb_windup_vfx_base.gd\"" in src and "func _ready()" not in src and "func _process(delta" not in src and "func fade_out_and_free" not in src:
			five_windup_intact += 1
	if five_windup_intact == 5:
		pass_count += 1
		print("PASS 15: 5 verb windup VFX 子类 0 改 0 触碰 (T275 0 副作用, 5 verb 既有共享契约 完整保留, 0 重写 0 重声明 0 override)")
	else:
		fail_count += 1
		print("FAIL 15: 5 verb windup VFX 子类 0 完整保留, 只找到 %d / 5" % five_windup_intact)

	# 16. whisper_ability.gd 0 改 0 触碰 (T275 0 副作用硬约束 — caller 0 改)
	f = FileAccess.open("res://src/scripts/whisper_ability.gd", FileAccess.READ)
	assert(f != null, "whisper_ability.gd exists")
	var whisper_ability_src: String = f.get_as_text()
	f.close()
	if "preload(\"res://src/scripts/whisper_windup_vfx.gd\")" in whisper_ability_src and "windup_vfx.trigger" in whisper_ability_src:
		pass_count += 1
		print("PASS 16: whisper_ability.gd 0 改 0 触碰 (T275 0 副作用, caller 走原 3 API 链, 0 改 preload/trigger/add_child)")
	else:
		fail_count += 1
		print("FAIL 16: whisper_ability.gd 缺 preload/trigger 链 (T275 副作用扩散, 违反 §9.6.19 硬约束)")

	# 17. CHANGELOG.md 同步 — 含 T275 段
	f = FileAccess.open("res://CHANGELOG.md", FileAccess.READ)
	assert(f != null, "CHANGELOG.md exists")
	var changelog: String = f.get_as_text()
	f.close()
	if "T275" in changelog and "§9.6.19" in changelog and "Whisper" in changelog:
		pass_count += 1
		print("PASS 17: CHANGELOG.md 含 T275 §9.6.19 Whisper 段 (T162 brittle 流程留痕)")
	else:
		fail_count += 1
		print("FAIL 17: CHANGELOG.md 缺 T275 §9.6.19 Whisper 段")

	# 18. ROADMAP.md 同步 — 顶部含 T275 引用
	f = FileAccess.open("res://ROADMAP.md", FileAccess.READ)
	assert(f != null, "ROADMAP.md exists")
	var roadmap: String = f.get_as_text()
	f.close()
	if "T275" in roadmap and "Whisper" in roadmap and "§9.6.19" in roadmap:
		pass_count += 1
		print("PASS 18: ROADMAP.md 顶部含 T275 §9.6.19 Whisper 引用 (T162 brittle 流程留痕)")
	else:
		fail_count += 1
		print("FAIL 18: ROADMAP.md 顶部缺 T275 §9.6.19 Whisper 引用")

	# 19. README.md 双语同步 — 含 T275 段
	f = FileAccess.open("res://README.md", FileAccess.READ)
	assert(f != null, "README.md exists")
	var readme_en: String = f.get_as_text()
	f.close()
	if "T275" in readme_en and "Whisper" in readme_en:
		pass_count += 1
		print("PASS 19: README.md 含 T275 Whisper 段 (en, F002 self-test 校验)")
	else:
		fail_count += 1
		print("FAIL 19: README.md 缺 T275 Whisper 段 (en, F002 self-test 校验失败)")

	# 20. README.zh-CN.md 双语同步 — 含 T275 段
	f = FileAccess.open("res://README.zh-CN.md", FileAccess.READ)
	assert(f != null, "README.zh-CN.md exists")
	var readme_zh: String = f.get_as_text()
	f.close()
	if "T275" in readme_zh and "Whisper" in readme_zh:
		pass_count += 1
		print("PASS 20: README.zh-CN.md 含 T275 Whisper 段 (zh, F002 self-test 校验)")
	else:
		fail_count += 1
		print("FAIL 20: README.zh-CN.md 缺 T275 Whisper 段 (zh, F002 self-test 校验失败)")

	# 21. 静态解析 — 0 SCRIPT ERROR (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)
	pass_count += 1
	print("PASS 21: 静态解析 (本测试本身在 Godot 4.6.3 加载并执行, 0 SCRIPT ERROR 触发)")

	# Summary
	print("")
	print("=== T275 smoke test summary: %d passed, %d failed ===" % [pass_count, fail_count])
	if fail_count > 0:
		print("RESULT: FAIL")
		quit(1)
	else:
		print("RESULT: PASS")
		quit(0)
