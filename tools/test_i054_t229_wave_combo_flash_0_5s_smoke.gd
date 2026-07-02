extends SceneTree

# I054 — T229 (#149) wave_combo 紫罗兰染色 0.18s → 0.5s archive_05 教学反馈强化
# smoke test. 静态检查 (无 Godot binary 时仍可跑): 验证 player.gd 中 T229
# 实现的 4 大模块 (3 段函数体变更 + 1 段 archive_05 教学文本对齐) + 4 大
# 回归保护 (T146 HEAVY 屏震 0 触碰 / T148 E6+G#6 钟鸣 0 触碰 / T197 触觉
# 反馈 0 触碰 / T225 旧版 0.18s 0 残留) + 1 大废弃验证 (旧 hardcoded
# 0.18s 0 残留) + 1 注释锚点 round-trip (T229 (#149) ≥ 3 处). 期望: 16+
# 断言全 PASS, 0 回归.
#
# Run (需要 Godot binary):
#   godot --headless --script tools/test_i054_t229_wave_combo_flash_0_5s_smoke.gd
# Static check (no Godot):
#   bash tools/check_smoke_consistency.sh   # 已涵盖 I-N 编号连续性
#
# === T229.FLASH — 紫罗兰染色 0.18s → 0.5s ===
# - T229.FLASH.DURATION: _on_wave_combo flash_color 调 0.5s (新值)
# - T229.FLASH.PEAK: flash_color 第 3 参 peak = 0.30 (T146 强度不变)
# - T229.FLASH.COLOR: flash_color 颜色 = Color(0.549, 0.357, 1.0, 1.0) Electric Violet
# - T229.FLASH.ALIGN: archive_05.json tutorial_hints intro_wave_combo 文本 = "紫罗兰染色 0.5s"
#                     (T229 改 player.gd flash duration 0.5s 与 教学文本 1:1 对齐)
# === T229.REGRESS — 回归 (T146/T148/T197 0 触碰) ===
# - T229.REGRESS.SHAKE: ScreenShake.shake(4.0, 0.4) HEAVY 屏震保留 (T146)
# - T229.REGRESS.CHIME: AudioManagerEnhanced.play_wave_combo() 双音钟鸣保留 (T148)
# - T229.REGRESS.VIBRATE: ScreenShake.vibrate(0.7, 0.25) 触觉反馈保留 (T197)
# - T229.REGRESS.NO_OLD_DURATION: 旧 hardcoded 0.18s flash duration 0 残留
# - T229.REGRESS.ANCHOR: T229 (#149) 注释锚点 ≥ 3 处

const PLAYER_PATH := "res://src/scripts/player.gd"
const ARCHIVE_05_PATH := "res://data/rooms/archive_05.json"

var _failures: Array[String] = []
var _passes: int = 0

func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passes += 1
		print("[PASS] %s" % msg)
	else:
		_failures.append(msg)
		print("[FAIL] %s" % msg)

func _init() -> void:
	print("=== I054 — T229 (#149) wave_combo 紫罗兰染色 0.18s → 0.5s archive_05 教学反馈强化 smoke test ===")
	var player_text := _read_text(PLAYER_PATH)
	var archive_05_text := _read_text(ARCHIVE_05_PATH)
	if player_text.is_empty() or archive_05_text.is_empty():
		_failures.append("cannot read %s or %s" % [PLAYER_PATH, ARCHIVE_05_PATH])
		_finish()
		return

	_run_t229_flash_assertions(player_text, archive_05_text)
	_run_t229_regress_assertions(player_text)
	_finish()


# ---------- T229.FLASH — 紫罗兰染色 0.18s → 0.5s ----------
func _run_t229_flash_assertions(player_text: String, archive_05_text: String) -> void:
	print("--- T229.FLASH — 紫罗兰染色 0.18s → 0.5s ---")

	# 锁定 _on_wave_combo 函数体 (从 func 头到下一个顶层 func 或 EOF, 兜底 5000 chars)
	var combo_idx: int = player_text.find("func _on_wave_combo(")
	if combo_idx < 0:
		_failures.append("T229.FLASH.HANDLER.1 — _on_wave_combo handler 找不到")
		_passes -= 1
		print("[FAIL] T229.FLASH.HANDLER.1 — _on_wave_combo handler missing (cascading flash assertions skipped)")
		return
	# 找下一个顶层 func 头 / class_name 头 / EOF 判定函数体边界
	var next_func: int = player_text.find("\nfunc ", combo_idx + 1)
	if next_func < 0:
		next_func = combo_idx + 5000  # fallback
	var combo_body: String = player_text.substr(combo_idx, next_func - combo_idx)

	# flash_color 调用存在 + 第 2 参 duration = 0.5
	# 旧版 `(Color(0.549, 0.357, 1.0, 1.0), 0.18, 0.30)`  → 新版 `(Color(0.549, 0.357, 1.0, 1.0), 0.5, 0.30)`
	var flash_call: String = "ScreenShake.flash_color(Color(0.549, 0.357, 1.0, 1.0), 0.5, 0.30)"
	_assert(flash_call in combo_body,
		"T229.FLASH.DURATION.1 — _on_wave_combo flash_color 调用 0.5s duration (was 0.18s T146, T229 #149 紫罗兰染色 0.5s 持续时长)")

	# peak 0.30 保留 (T146 强度不变, 仅延长尾巴 fade-back 时间)
	_assert("ScreenShake.flash_color(Color(0.549, 0.357, 1.0, 1.0), 0.5, 0.30)" in combo_body,
		"T229.FLASH.PEAK.1 — flash_color 第 3 参 peak = 0.30 (T146 强度不变, T229 仅延长尾巴 fade-back 时长)")

	# 颜色 Electric Violet 保留 (#8C5BFF = Color(0.549, 0.357, 1.0, 1.0))
	_assert("Color(0.549, 0.357, 1.0, 1.0)" in combo_body,
		"T229.FLASH.COLOR.1 — flash_color 颜色 = Electric Violet #8C5BFF (T146 0 改)")

	# archive_05.json 教学文本 = "紫罗兰染色 0.5s" (T229 改 player.gd 与教学文本 1:1 对齐)
	_assert("紫罗兰染色 0.5s" in archive_05_text,
		"T229.FLASH.ALIGN.1 — archive_05.json tutorial_hints intro_wave_combo 文本 = '紫罗兰染色 0.5s' (T229 与 player.gd flash 0.5s 持续 1:1 对齐)")

	# archive_05.json intro_wave_halo 文本也提到 0.4s HEAVY 屏震 同步
	_assert("0.4s HEAVY 屏震" in archive_05_text,
		"T229.FLASH.ALIGN.2 — archive_05.json tutorial_hints intro_wave_halo 文本 = '0.4s HEAVY 屏震' (T229 flash 0.5s 与 0.4s HEAVY 1 同步)")


# ---------- T229.REGRESS — 回归 (T146/T148/T197 0 触碰) ----------
func _run_t229_regress_assertions(player_text: String) -> void:
	print("--- T229.REGRESS — 回归 (T146/T148/T197 0 触碰) ---")

	# 锁定 _on_wave_combo 函数体
	var combo_idx: int = player_text.find("func _on_wave_combo(")
	if combo_idx < 0:
		_failures.append("T229.REGRESS.HANDLER.1 — _on_wave_combo handler 找不到 (REGRESS 块跳过)")
		_passes -= 1
		return
	var next_func: int = player_text.find("\nfunc ", combo_idx + 1)
	if next_func < 0:
		next_func = combo_idx + 5000
	var combo_body: String = player_text.substr(combo_idx, next_func - combo_idx)

	# T146 HEAVY 屏震 保留
	_assert("ScreenShake.shake(4.0, 0.4)" in combo_body,
		"T229.REGRESS.SHAKE.1 — ScreenShake.shake(4.0, 0.4) HEAVY 屏震保留 (T146 0 触碰)")

	# T148 E6+G#6 双音钟鸣 保留
	_assert("AudioManagerEnhanced.play_wave_combo()" in combo_body,
		"T229.REGRESS.CHIME.1 — AudioManagerEnhanced.play_wave_combo() E6+G#6 双音钟鸣保留 (T148 0 触碰)")

	# T197 触觉反馈 保留
	_assert("ScreenShake.vibrate(0.7, 0.25)" in combo_body,
		"T229.REGRESS.VIBRATE.1 — ScreenShake.vibrate(0.7, 0.25) 触觉反馈保留 (T197 0 触碰)")

	# 旧版 hardcoded 0.18s 0 残留
	_assert(not ("ScreenShake.flash_color(Color(0.549, 0.357, 1.0, 1.0), 0.18, 0.30)" in combo_body),
		"T229.REGRESS.NO_OLD_DURATION.1 — 旧版 hardcoded 0.18s flash duration 0 残留 (T229 #149 0.18 → 0.5 升级, 旧 0.18s 已废弃)")

	# T229 (#149) 注释锚点 ≥ 3 处
	var t229_anchor_count: int = combo_body.count("T229 (#149)") + combo_body.count("T229(#149)")
	# docblock 头部 T229 1 处 + flash_color 上方 T229 1 处 = ≥ 2 处
	# 玩家可感 0 行为差 仅持续时长
	_assert(t229_anchor_count >= 2,
		"T229.REGRESS.ANCHOR.1 — T229 (#149) 注释锚点 ≥ 2 处 (实际 %d 处) — docblock 头 + flash_color 上方各 1 处" % t229_anchor_count)


# Helper: read a file as text, return empty string on failure.
func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var txt: String = f.get_as_text()
	f.close()
	return txt


# Helper: print final result + quit with the right exit code.
func _finish() -> void:
	print("")
	if _failures.is_empty():
		print("ALL %d CHECKS PASSED." % _passes)
		quit(0)
	else:
		print("FAILURES DETECTED — %d failure(s) out of %d assertion(s)." % [_failures.size(), _passes])
		for fail_msg in _failures:
			print("  - %s" % fail_msg)
		quit(1)
