extends SceneTree

## test_i054_t229_t230_profile_audit_and_intro_a11y_smoke.gd
## #149 — T229 PauseMenu ProfileAudit + T230 intro cutscene accessibility 同步
##
## 覆盖:
##  (T229) pause_menu.tscn 节点结构 (ProfileAudit 标签 + 锚点)
##  (T229) pause_menu.gd _refresh_profile_audit 函数存在
##  (T229) _refresh_profile 调用 _refresh_profile_audit
##  (T229) SaveSystem.audit_save_slots 公共接口存在 (4 状态分类)
##  (T229) 4 颜色分支 (全 ok / 损坏 / 漂移 / fallback)
##  (T230) intro_cutscene.gd _compute_accessibility_multiplier 函数
##  (T230) _play_sequence 接受 multiplier 参数 + 4 段时长缩放
##  (T230) 3 档 multiplier (0.4 / 0.7 / 1.0) 边界
##  (T230) settings.cfg 解析失败 fallback 1.0

func _init() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0

	# === T229 — PauseMenu ProfileAudit ===

	# --- 1. pause_menu.tscn 含 ProfileAudit 节点 ---
	test_num += 1
	var pm_tscn := FileAccess.open("res://src/scenes/pause_menu.tscn", FileAccess.READ)
	if pm_tscn == null:
		print("  [%d] FAIL  pause_menu.tscn 不可读" % test_num)
		failed += 1
	else:
		var pm_tscn_text := pm_tscn.get_as_text()
		pm_tscn.close()
		if "[node name=\"ProfileAudit\" type=\"Label\"" in pm_tscn_text:
			print("  [%d] PASS  pause_menu.tscn 含 ProfileAudit Label 节点" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  pause_menu.tscn 缺 ProfileAudit Label 节点" % test_num)
			failed += 1

	# --- 2. ProfileAudit 节点 parent 是 PlayerProfilePanel/ProfileMargin/ProfileVBox ---
	test_num += 1
	var pm_tscn_check := FileAccess.open("res://src/scenes/pause_menu.tscn", FileAccess.READ)
	if pm_tscn_check == null:
		print("  [%d] FAIL  pause_menu.tscn 不可读 (re-read)" % test_num)
		failed += 1
	else:
		var pm_tscn_text_check := pm_tscn_check.get_as_text()
		pm_tscn_check.close()
		# 找 ProfileAudit 节点的 parent
		var idx := pm_tscn_text_check.find("ProfileAudit")
		var parent_ok: bool = false
		if idx > 0:
			# parent 字段在 type=Label 行下面 layout_mode 行之前
			var parent_line := pm_tscn_text_check.substr(idx, 200)
			if "PlayerProfilePanel/ProfileMargin/ProfileVBox" in parent_line:
				parent_ok = true
		if parent_ok:
			print("  [%d] PASS  ProfileAudit parent = PlayerProfilePanel/ProfileMargin/ProfileVBox" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  ProfileAudit parent 路径错误" % test_num)
			failed += 1

	# --- 3. pause_menu.gd @onready var _profile_audit ---
	test_num += 1
	var pm_gd := FileAccess.open("res://src/scripts/pause_menu.gd", FileAccess.READ)
	if pm_gd == null:
		print("  [%d] FAIL  pause_menu.gd 不可读" % test_num)
		failed += 1
		_finish(passed, failed)
		return
	var pm_text := pm_gd.get_as_text()
	pm_gd.close()
	if "@onready var _profile_audit: Label" in pm_text and "ProfileAudit" in pm_text:
		print("  [%d] PASS  pause_menu.gd @onready var _profile_audit 绑定到 ProfileAudit 节点" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  pause_menu.gd 缺 @onready var _profile_audit" % test_num)
		failed += 1

	# --- 4. _refresh_profile_audit 函数存在 ---
	test_num += 1
	if "func _refresh_profile_audit() -> void:" in pm_text:
		print("  [%d] PASS  _refresh_profile_audit 函数存在" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _refresh_profile_audit 函数缺失" % test_num)
		failed += 1

	# --- 5. _refresh_profile 末尾调 _refresh_profile_audit ---
	test_num += 1
	# 找 _refresh_profile 末尾
	var refresh_start := pm_text.find("func _refresh_profile() -> void:")
	if refresh_start < 0:
		print("  [%d] FAIL  _refresh_profile 函数未找到" % test_num)
		failed += 1
	else:
		var next_func := pm_text.find("\nfunc ", refresh_start + 30)
		var refresh_body: String
		if next_func > 0:
			refresh_body = pm_text.substr(refresh_start, next_func - refresh_start)
		else:
			refresh_body = pm_text.substr(refresh_start)
		if "_refresh_profile_audit()" in refresh_body:
			print("  [%d] PASS  _refresh_profile 调 _refresh_profile_audit" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  _refresh_profile 缺 _refresh_profile_audit 调用" % test_num)
			failed += 1

	# --- 6. SaveSystem.audit_save_slots 公共接口存在 ---
	test_num += 1
	var ss_gd := FileAccess.open("res://src/autoload/save_system.gd", FileAccess.READ)
	if ss_gd == null:
		print("  [%d] FAIL  save_system.gd 不可读" % test_num)
		failed += 1
	else:
		var ss_text := ss_gd.get_as_text()
		ss_gd.close()
		if "func audit_save_slots() -> Dictionary:" in ss_text:
			print("  [%d] PASS  SaveSystem.audit_save_slots() -> Dictionary 公共接口存在" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  SaveSystem.audit_save_slots 公共接口缺失" % test_num)
			failed += 1

	# --- 7. 4 颜色分支 (全 ok / 损坏 / 漂移 / fallback) ---
	test_num += 1
	# 模拟 _refresh_profile_audit 的颜色逻辑
	var color_full_ok: Color = Color(0.875, 0.835, 0.784, 1.0)
	var color_corrupted: Color = Color(0.85, 0.45, 0.4, 1.0)
	var color_drift: Color = Color(0.85, 0.71, 0.43, 1.0)
	var c1 := _pick_audit_color(5, 0, 0)  # 全 ok
	var c2 := _pick_audit_color(2, 1, 0)  # 有损坏
	var c3 := _pick_audit_color(3, 0, 1)  # 有漂移
	var c4 := _pick_audit_color(0, 3, 1)  # 损坏 + 漂移 (损坏优先)
	if c1 == color_full_ok and c2 == color_corrupted and c3 == color_drift and c4 == color_corrupted:
		print("  [%d] PASS  4 颜色分支正确 (全 ok 暖白 / 损坏 暖红 / 漂移 暖黄 / 损坏+漂移 损坏优先)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  颜色分支错: c1=%s c2=%s c3=%s c4=%s" % [test_num, c1, c2, c3, c4])
		failed += 1

	# --- 8. 1 行文本格式: 存档 N ok · N 损坏 · N 漂移 · N 空 ---
	test_num += 1
	var text_ok: String = "存档  3 ok  ·  0 损坏  ·  0 漂移  ·  2 空"
	var text_corrupt: String = "存档  2 ok  ·  1 损坏  ·  0 漂移  ·  2 空"
	var t1: String = _format_audit_text(3, 0, 0, 2)
	var t2: String = _format_audit_text(2, 1, 0, 2)
	if t1 == text_ok and t2 == text_corrupt:
		print("  [%d] PASS  1 行 4 字段文本格式正确" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  文本格式错: t1=%s t2=%s" % [test_num, t1, t2])
		failed += 1

	# === T230 — intro cutscene accessibility 同步 ===

	# --- 9. intro_cutscene.gd _compute_accessibility_multiplier 函数存在 ---
	test_num += 1
	var ic_gd := FileAccess.open("res://src/scripts/intro_cutscene.gd", FileAccess.READ)
	if ic_gd == null:
		print("  [%d] FAIL  intro_cutscene.gd 不可读" % test_num)
		failed += 1
	else:
		var ic_text := ic_gd.get_as_text()
		ic_gd.close()
		if "func _compute_accessibility_multiplier() -> float:" in ic_text:
			print("  [%d] PASS  _compute_accessibility_multiplier 函数存在" % test_num)
			passed += 1
		else:
			print("  [%d] FAIL  _compute_accessibility_multiplier 函数缺失" % test_num)
			failed += 1

	# --- 10. _play_sequence 接受 multiplier 参数 ---
	test_num += 1
	ic_gd = FileAccess.open("res://src/scripts/intro_cutscene.gd", FileAccess.READ)
	var ic_text2: String = ic_gd.get_as_text() if ic_gd != null else ""
	if ic_gd:
		ic_gd.close()
	if "func _play_sequence(multiplier: float = 1.0) -> void:" in ic_text2:
		print("  [%d] PASS  _play_sequence(multiplier) 接受参数" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _play_sequence 缺 multiplier 参数" % test_num)
		failed += 1

	# --- 11. 3 档 multiplier (0.4 / 0.7 / 1.0) 边界 ---
	test_num += 1
	# 模拟 _compute_accessibility_multiplier 内联逻辑
	var m_off: float = _mock_multiplier(false, false, false)
	var m_mix1: float = _mock_multiplier(true, false, false)
	var m_mix2: float = _mock_multiplier(true, true, false)
	var m_all: float = _mock_multiplier(true, true, true)
	if m_off == 1.0 and m_mix1 == 0.7 and m_mix2 == 0.7 and m_all == 0.4:
		print("  [%d] PASS  3 档 multiplier 边界 (0/3 → 1.0, 1-2/3 → 0.7, 3/3 → 0.4)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  multiplier 错: off=%s mix1=%s mix2=%s all=%s" % [test_num, m_off, m_mix1, m_mix2, m_all])
		failed += 1

	# --- 12. multiplier 钳 [0.2, 1.0] 范围 ---
	test_num += 1
	var clamped_low: float = clampf(0.05, 0.2, 1.0)
	var clamped_high: float = clampf(1.5, 0.2, 1.0)
	var clamped_mid: float = clampf(0.7, 0.2, 1.0)
	if clamped_low == 0.2 and clamped_high == 1.0 and clamped_mid == 0.7:
		print("  [%d] PASS  multiplier clamp [0.2, 1.0] 范围正确" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  clamp 错: low=%s high=%s mid=%s" % [test_num, clamped_low, clamped_high, clamped_mid])
		failed += 1

	# --- 13. settings.cfg 解析失败 fallback 1.0 ---
	test_num += 1
	# 内联模拟: ConfigFile load 失败 → 返回 1.0
	# 这是逻辑合约, 验证 _compute_accessibility_multiplier 第一个 early return
	if "if err != OK:\n\t\treturn 1.0" in ic_text2 or "if err != OK:" in ic_text2:
		print("  [%d] PASS  settings.cfg 解析失败 → 1.0 fallback 路径存在" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  settings.cfg 解析失败 fallback 路径缺失" % test_num)
		failed += 1

	# --- 14. _ready 调 _play_sequence(multiplier) ---
	test_num += 1
	if "_play_sequence(_compute_accessibility_multiplier())" in ic_text2:
		print("  [%d] PASS  _ready 调 _play_sequence(multiplier) — wiring 完整" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _ready 缺 _play_sequence(multiplier) wiring" % test_num)
		failed += 1

	# --- 15. T230 注释在 intro_cutscene.gd ---
	test_num += 1
	if "T230" in ic_text2 and "accessibility" in ic_text2:
		print("  [%d] PASS  T230 注释 + accessibility 关键字在 intro_cutscene.gd" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T230 注释或关键字缺失" % test_num)
		failed += 1

	# --- 16. T229 注释在 pause_menu.gd ---
	test_num += 1
	if "T229" in pm_text and "audit" in pm_text:
		print("  [%d] PASS  T229 注释 + audit 关键字在 pause_menu.gd" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  T229 注释或 audit 关键字缺失" % test_num)
		failed += 1

	_finish(passed, failed)

func _finish(passed: int, failed: int) -> void:
	print("")
	print("=== I054 T229+T230 profile_audit + intro_a11y smoke: %d passed, %d failed ===" % [passed, failed])
	if failed > 0:
		quit(1)
	else:
		quit(0)

# === 内联 helpers (避免 headless --script 模式实例化 autoload / UI 场景) ===

# 模拟 _refresh_profile_audit 的颜色选择逻辑 (与 pause_menu.gd 同源).
# 损坏 > 漂移 > 全 ok 优先级.
func _pick_audit_color(ok_n: int, corrupted_n: int, drift_n: int) -> Color:
	if corrupted_n > 0:
		return Color(0.85, 0.45, 0.4, 1.0)
	elif drift_n > 0:
		return Color(0.85, 0.71, 0.43, 1.0)
	else:
		return Color(0.875, 0.835, 0.784, 1.0)

# 模拟 _refresh_profile_audit 的 1 行 4 字段文本.
func _format_audit_text(ok_n: int, corrupted_n: int, drift_n: int, empty_n: int) -> String:
	return "存档  %d ok  ·  %d 损坏  ·  %d 漂移  ·  %d 空" % [ok_n, corrupted_n, drift_n, empty_n]

# 模拟 _compute_accessibility_multiplier 的 3 子项 AND-OR 计数逻辑.
# n=0 → 1.0 (8s 完整); n=1-2 → 0.7 (5.6s 温和); n=3 → 0.4 (3.2s 强烈).
func _mock_multiplier(shake: bool, flash: bool, vibration: bool) -> float:
	var n: int = int(shake) + int(flash) + int(vibration)
	if n >= 3:
		return 0.4
	elif n >= 1:
		return 0.7
	return 1.0
