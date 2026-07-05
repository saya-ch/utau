extends SceneTree
## T246 (#163) — 5 verb 旧成就 PNG 路径补全 (Echo + Wave) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t246_verb_achievement_icons_smoke.gd
##
## T246: 5 verb 旧成就 PNG 路径补全 (Echo + Wave) — quadruple_voice / quintuple_voice
##   通知卡 fallback 颜色 → 真实 PNG 资源 升级
##   - scripts/generate_verb_achievement_icons.py 程序化生成器 (1 文件 ~140 行)
##   - 4 PNG (echo_icon + echo_icon_32x32 + wave_icon + wave_icon_32x32)
##   - 4 .import 文件 (与 T245 whisper_icon 模式 1:1)
##   - 复用 T085 draw_echo_icon + T103 draw_wave_icon 像素级 deterministic

func _initialize() -> void:
	print("=== T246 #163 5 verb 旧成就 PNG 路径补全 (Echo + Wave) smoke test ===")

	var src_generate_script := _read_file("res://scripts/generate_verb_achievement_icons.py")

	var passed := 0
	var total := 0

	# =================================================================
	# T246.1-4 — generate_verb_achievement_icons.py 4 断言
	# =================================================================
	print("--- T246.1-4 — generate_verb_achievement_icons.py 4 断言 ---")

	# ===== T246.1.SCRIPT_EXISTS — generate_verb_achievement_icons.py 存在 =====
	total += 1
	if src_generate_script == "":
		print("  FAIL [T246.1.1]: scripts/generate_verb_achievement_icons.py 缺")
		quit(1); return
	passed += 1
	print("  [T246.1.1] scripts/generate_verb_achievement_icons.py 存在 (OK)")

	# ===== T246.2.REUSE_DRAW_FNS — 复用 draw_echo_icon + draw_wave_icon =====
	total += 1
	if src_generate_script.find("from generate_echo_icon import draw_echo_icon") == -1 or \
	   src_generate_script.find("from generate_wave_icon import draw_wave_icon") == -1:
		print("  FAIL [T246.2.1]: generate_verb_achievement_icons.py 缺 draw_echo_icon / draw_wave_icon 复用")
		quit(1); return
	passed += 1
	print("  [T246.2.1] generate_verb_achievement_icons.py 复用 draw_echo_icon / draw_wave_icon (OK)")

	# ===== T246.3.ECHO_WAVE_TARGETS — 目标含 echo_icon + wave_icon =====
	total += 1
	if src_generate_script.find("echo_icon") == -1 or src_generate_script.find("wave_icon") == -1:
		print("  FAIL [T246.3.1]: generate_verb_achievement_icons.py 缺 echo_icon / wave_icon target")
		quit(1); return
	passed += 1
	print("  [T246.3.1] generate_verb_achievement_icons.py 含 echo_icon + wave_icon target (OK)")

	# ===== T246.4.MAKE_GODOT_IMPORT — make_godot_import 函数定义 =====
	total += 1
	if src_generate_script.find("def make_godot_import") == -1 or src_generate_script.find("compress/mode=0") == -1:
		print("  FAIL [T246.4.1]: generate_verb_achievement_icons.py 缺 make_godot_import 函数 / compress/mode=0")
		quit(1); return
	passed += 1
	print("  [T246.4.1] generate_verb_achievement_icons.py 含 make_godot_import 函数 + compress/mode=0 (OK)")

	# =================================================================
	# T246.5-8 — 4 PNG 文件 4 断言
	# =================================================================
	print("--- T246.5-8 — 4 PNG 文件 4 断言 ---")

	# ===== T246.5.PNG_ECHO_BASE =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/echo_icon/echo_icon.png"):
		print("  FAIL [T246.5.1]: assets/ui/achievements/echo_icon/echo_icon.png 缺")
		quit(1); return
	passed += 1
	print("  [T246.5.1] achievements/echo_icon/echo_icon.png 32x32 存在 (OK)")

	# ===== T246.6.PNG_ECHO_32X32 =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/echo_icon/echo_icon_32x32.png"):
		print("  FAIL [T246.6.1]: assets/ui/achievements/echo_icon/echo_icon_32x32.png 缺")
		quit(1); return
	passed += 1
	print("  [T246.6.1] achievements/echo_icon/echo_icon_32x32.png 32x32 显式 存在 (OK)")

	# ===== T246.7.PNG_WAVE_BASE =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/wave_icon/wave_icon.png"):
		print("  FAIL [T246.7.1]: assets/ui/achievements/wave_icon/wave_icon.png 缺")
		quit(1); return
	passed += 1
	print("  [T246.7.1] achievements/wave_icon/wave_icon.png 32x32 存在 (OK)")

	# ===== T246.8.PNG_WAVE_32X32 =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/wave_icon/wave_icon_32x32.png"):
		print("  FAIL [T246.8.1]: assets/ui/achievements/wave_icon/wave_icon_32x32.png 缺")
		quit(1); return
	passed += 1
	print("  [T246.8.1] achievements/wave_icon/wave_icon_32x32.png 32x32 显式 存在 (OK)")

	# =================================================================
	# T246.9-12 — 4 .import 文件 4 断言
	# =================================================================
	print("--- T246.9-12 — 4 .import 文件 4 断言 ---")

	# ===== T246.9.IMPORT_ECHO_BASE =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/echo_icon/echo_icon.png.import"):
		print("  FAIL [T246.9.1]: assets/ui/achievements/echo_icon/echo_icon.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T246.9.1] achievements/echo_icon/echo_icon.png.import 存在 (OK)")

	# ===== T246.10.IMPORT_ECHO_32X32 =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/echo_icon/echo_icon_32x32.png.import"):
		print("  FAIL [T246.10.1]: assets/ui/achievements/echo_icon/echo_icon_32x32.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T246.10.1] achievements/echo_icon/echo_icon_32x32.png.import 存在 (OK)")

	# ===== T246.11.IMPORT_WAVE_BASE =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/wave_icon/wave_icon.png.import"):
		print("  FAIL [T246.11.1]: assets/ui/achievements/wave_icon/wave_icon.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T246.11.1] achievements/wave_icon/wave_icon.png.import 存在 (OK)")

	# ===== T246.12.IMPORT_WAVE_32X32 =====
	total += 1
	if not FileAccess.file_exists("res://assets/ui/achievements/wave_icon/wave_icon_32x32.png.import"):
		print("  FAIL [T246.12.1]: assets/ui/achievements/wave_icon/wave_icon_32x32.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T246.12.1] achievements/wave_icon/wave_icon_32x32.png.import 存在 (OK)")

	# =================================================================
	# T246.13-16 — 5 verb PNG 资源 跨路径对称性 4 断言
	# =================================================================
	print("--- T246.13-16 — 5 verb PNG 资源 跨路径对称性 4 断言 ---")

	# ===== T246.13.ECHO_PATH_DUAL — echo_icon 2 路径齐全 (verb family + achievements) =====
	total += 1
	var echo_verb_exists := FileAccess.file_exists("res://assets/ui/echo_icon/echo_icon.png")
	var echo_ach_exists := FileAccess.file_exists("res://assets/ui/achievements/echo_icon/echo_icon.png")
	if not (echo_verb_exists and echo_ach_exists):
		print("  FAIL [T246.13.1]: echo_icon 双路径不全 (verb_family=%s, achievements=%s)" % [echo_verb_exists, echo_ach_exists])
		quit(1); return
	passed += 1
	print("  [T246.13.1] echo_icon 双路径齐全 (verb family + achievements) (OK)")

	# ===== T246.14.WAVE_PATH_DUAL — wave_icon 2 路径齐全 =====
	total += 1
	var wave_verb_exists := FileAccess.file_exists("res://assets/ui/wave_icon/wave_icon.png")
	var wave_ach_exists := FileAccess.file_exists("res://assets/ui/achievements/wave_icon/wave_icon.png")
	if not (wave_verb_exists and wave_ach_exists):
		print("  FAIL [T246.14.1]: wave_icon 双路径不全 (verb_family=%s, achievements=%s)" % [wave_verb_exists, wave_ach_exists])
		quit(1); return
	passed += 1
	print("  [T246.14.1] wave_icon 双路径齐全 (verb family + achievements) (OK)")

	# ===== T246.15.WHISPER_REGRESS — whisper_icon 双路径 0 触碰 (T245 #162 既有) =====
	total += 1
	var whisper_verb_exists := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon.png")
	var whisper_ach_exists := FileAccess.file_exists("res://assets/ui/achievements/whisper_icon/whisper_icon.png")
	if not (whisper_verb_exists and whisper_ach_exists):
		print("  FAIL [T246.15.1]: whisper_icon 双路径 regression (T245 #162 0 触碰 应保留)")
		quit(1); return
	passed += 1
	print("  [T246.15.1] whisper_icon 双路径 0 触碰 (T245 #162 既有保留) (OK)")

	# ===== T246.16.ACHIEVEMENT_NOTIF_REGRESS — achievement_notification.gd ICON_PATH_BASE 0 触碰 =====
	total += 1
	var notif_src := _read_file("res://src/scripts/achievement_notification.gd")
	if notif_src.find('const ICON_PATH_BASE := "res://assets/ui/achievements"') == -1:
		print("  FAIL [T246.16.1]: achievement_notification.gd ICON_PATH_BASE 改动 (regression)")
		quit(1); return
	passed += 1
	print("  [T246.16.1] achievement_notification.gd ICON_PATH_BASE 0 触碰 (T245 ICON_PATH_BASE 既有保留) (OK)")

	# =================================================================
	# T246.17-20 — 3 关联成就 icon_hint 引用 4 断言
	# =================================================================
	print("--- T246.17-20 — 3 关联成就 icon_hint 引用 4 断言 ---")

	var ach_data := _read_file("res://data/achievements.json")

	# ===== T246.17.QUADRUPLE_VOICE_ECHO =====
	total += 1
	if ach_data.find('"quadruple_voice"') == -1 or ach_data.find('"icon_hint": "echo_icon"') == -1:
		print("  FAIL [T246.17.1]: data/achievements.json quadruple_voice 缺 echo_icon icon_hint")
		quit(1); return
	passed += 1
	print("  [T246.17.1] quadruple_voice 关联 echo_icon icon_hint (OK)")

	# ===== T246.18.QUINTUPLE_VOICE_WAVE =====
	total += 1
	if ach_data.find('"quintuple_voice"') == -1 or ach_data.find('"icon_hint": "wave_icon"') == -1:
		print("  FAIL [T246.18.1]: data/achievements.json quintuple_voice 缺 wave_icon icon_hint")
		quit(1); return
	passed += 1
	print("  [T246.18.1] quintuple_voice 关联 wave_icon icon_hint (OK)")

	# ===== T246.19.SEXTUPLE_VOICE_WHISPER =====
	total += 1
	if ach_data.find('"sextuple_voice"') == -1 or ach_data.find('"icon_hint": "whisper_icon"') == -1:
		print("  FAIL [T246.19.1]: data/achievements.json sextuple_voice 缺 whisper_icon icon_hint")
		quit(1); return
	passed += 1
	print("  [T246.19.1] sextuple_voice 关联 whisper_icon icon_hint (OK)")

	# ===== T246.20.THREE_VERB_ACHIEVEMENTS =====
	total += 1
	var verb_ach_count := 0
	for hint in ["echo_icon", "wave_icon", "whisper_icon"]:
		if ach_data.find('"icon_hint": "%s"' % hint) != -1:
			verb_ach_count += 1
	if verb_ach_count != 3:
		print("  FAIL [T246.20.1]: 3 verb 关联成就 icon_hint 缺 (count=%d, 期望 3)" % verb_ach_count)
		quit(1); return
	passed += 1
	print("  [T246.20.1] 3 verb 关联成就 icon_hint 全 3 闭环 (OK)")

	# =================================================================
	# T246.21-24 — PNG 32x32 尺寸验证 4 断言
	# =================================================================
	print("--- T246.21-24 — PNG 32x32 尺寸验证 4 断言 ---")

	# ===== T246.21.ECHO_PNG_32 =====
	total += 1
	var echo_size := _get_png_size("res://assets/ui/achievements/echo_icon/echo_icon.png")
	if echo_size != Vector2i(32, 32):
		print("  FAIL [T246.21.1]: echo_icon.png 尺寸=%s, 期望 (32, 32)" % str(echo_size))
		quit(1); return
	passed += 1
	print("  [T246.21.1] echo_icon.png 32x32 尺寸正确 (OK)")

	# ===== T246.22.ECHO_PNG_32_32X32 =====
	total += 1
	var echo_32_size := _get_png_size("res://assets/ui/achievements/echo_icon/echo_icon_32x32.png")
	if echo_32_size != Vector2i(32, 32):
		print("  FAIL [T246.22.1]: echo_icon_32x32.png 尺寸=%s, 期望 (32, 32)" % str(echo_32_size))
		quit(1); return
	passed += 1
	print("  [T246.22.1] echo_icon_32x32.png 32x32 尺寸正确 (OK)")

	# ===== T246.23.WAVE_PNG_32 =====
	total += 1
	var wave_size := _get_png_size("res://assets/ui/achievements/wave_icon/wave_icon.png")
	if wave_size != Vector2i(32, 32):
		print("  FAIL [T246.23.1]: wave_icon.png 尺寸=%s, 期望 (32, 32)" % str(wave_size))
		quit(1); return
	passed += 1
	print("  [T246.23.1] wave_icon.png 32x32 尺寸正确 (OK)")

	# ===== T246.24.WAVE_PNG_32_32X32 =====
	total += 1
	var wave_32_size := _get_png_size("res://assets/ui/achievements/wave_icon/wave_icon_32x32.png")
	if wave_32_size != Vector2i(32, 32):
		print("  FAIL [T246.24.1]: wave_icon_32x32.png 尺寸=%s, 期望 (32, 32)" % str(wave_32_size))
		quit(1); return
	passed += 1
	print("  [T246.24.1] wave_icon_32x32.png 32x32 尺寸正确 (OK)")

	# =================================================================
	# 完成
	# =================================================================
	print("=== T246 #163 5 verb 旧成就 PNG 路径补全 (Echo + Wave) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _get_png_size(path: String) -> Vector2i:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		return Vector2i(-1, -1)
	return img.get_size()
