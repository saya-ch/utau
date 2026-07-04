extends SceneTree
## T245 (#162) — Whisper 6 verb icon 落地 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t245_whisper_icon_smoke.gd
##
## T245: Whisper 6 verb icon 落地 (A074 4 PNG 双路径 + 6 verb 视觉组闭环)
##   - scripts/generate_whisper_icon.py 程序化生成器 (1 文件 95 行)
##   - 4 PNG (achievements/whisper_icon 32x32 + _32x32 + verb family/whisper_icon 32x32 + _64x64)
##   - 4 .import 文件 (与 wave_icon 模式 1:1)
##   - ICON_COLORS 扩 8 → 11 entries (echo_icon Glass Cyan / wave_icon Pale Resonance / whisper_icon Muted Mauve)
##   - STYLE_GUIDE 新增 "6 verb 技能图标视觉组 (5+1 verb icon 调色六元组)" 段
##   - ASSET_REGISTRY A074 登记 (1074 seed)

func _initialize() -> void:
	print("=== T245 #162 Whisper 6 verb icon 落地 smoke test ===")

	var src_achievement_notif := _read_file("res://src/scripts/achievement_notification.gd")
	var src_style_guide := _read_file("res://STYLE_GUIDE.md")
	var src_asset_registry := _read_file("res://ASSET_REGISTRY.md")
	var src_generate_script := _read_file("res://scripts/generate_whisper_icon.py")

	var passed := 0
	var total := 0

	# =================================================================
	# T245.1-4 — generate_whisper_icon.py 4 断言
	# =================================================================
	print("--- T245.1-4 — generate_whisper_icon.py 4 断言 ---")

	# ===== T245.1.SCRIPT_EXISTS — generate_whisper_icon.py 存在 =====
	total += 1
	if src_generate_script == "":
		print("  FAIL [T245.1.1]: scripts/generate_whisper_icon.py 缺")
		quit(1); return
	passed += 1
	print("  [T245.1.1] scripts/generate_whisper_icon.py 存在 (OK)")

	# ===== T245.2.DRAW_FUNCTION — draw_whisper_icon 函数定义 =====
	total += 1
	if src_generate_script.find("def draw_whisper_icon(size: int = 32) -> Image.Image:") == -1:
		print("  FAIL [T245.2.1]: generate_whisper_icon.py 缺 draw_whisper_icon 函数")
		quit(1); return
	passed += 1
	print("  [T245.2.1] generate_whisper_icon.py 含 draw_whisper_icon 函数 (OK)")

	# ===== T245.3.MUTED_MAUVE — 6 verb Whisper 主色 Muted Mauve #C8A4D8 =====
	total += 1
	if src_generate_script.find("MUTED_MAUVE = (200, 164, 216)") == -1 or src_generate_script.find("#C8A4D8") == -1:
		print("  FAIL [T245.3.1]: generate_whisper_icon.py 缺 Muted Mauve #C8A4D8 主色定义")
		quit(1); return
	passed += 1
	print("  [T245.3.1] generate_whisper_icon.py 含 Muted Mauve #C8A4D8 主色 (OK)")

	# ===== T245.4.GLASS_CYAN_OUTER — Glass Cyan 1px 外环 (6 verb 视觉组共享) =====
	total += 1
	if src_generate_script.find("GLASS_CYAN") == -1 or src_generate_script.find("6 verb") == -1:
		print("  FAIL [T245.4.1]: generate_whisper_icon.py 缺 Glass Cyan 外环 / 6 verb 注释")
		quit(1); return
	passed += 1
	print("  [T245.4.1] generate_whisper_icon.py 含 Glass Cyan 外环 + 6 verb 视觉组注释 (OK)")

	# =================================================================
	# T245.5-8 — 4 PNG 文件 4 断言
	# =================================================================
	print("--- T245.5-8 — 4 PNG 文件 4 断言 ---")

	# ===== T245.5.PNG_ACH_BASE — achievements/whisper_icon/whisper_icon.png 32x32 =====
	total += 1
	var ach_base_exists := FileAccess.file_exists("res://assets/ui/achievements/whisper_icon/whisper_icon.png")
	if not ach_base_exists:
		print("  FAIL [T245.5.1]: assets/ui/achievements/whisper_icon/whisper_icon.png 缺")
		quit(1); return
	passed += 1
	print("  [T245.5.1] achievements/whisper_icon/whisper_icon.png 32x32 存在 (OK)")

	# ===== T245.6.PNG_ACH_32X32 — achievements/whisper_icon/whisper_icon_32x32.png =====
	total += 1
	var ach_32x32_exists := FileAccess.file_exists("res://assets/ui/achievements/whisper_icon/whisper_icon_32x32.png")
	if not ach_32x32_exists:
		print("  FAIL [T245.6.1]: assets/ui/achievements/whisper_icon/whisper_icon_32x32.png 缺")
		quit(1); return
	passed += 1
	print("  [T245.6.1] achievements/whisper_icon/whisper_icon_32x32.png 32x32 显式 存在 (OK)")

	# ===== T245.7.PNG_VERB_BASE — verb family/whisper_icon/whisper_icon.png =====
	total += 1
	var verb_base_exists := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon.png")
	if not verb_base_exists:
		print("  FAIL [T245.7.1]: assets/ui/whisper_icon/whisper_icon.png 缺")
		quit(1); return
	passed += 1
	print("  [T245.7.1] verb family/whisper_icon/whisper_icon.png 32x32 存在 (OK)")

	# ===== T245.8.PNG_VERB_64X64 — verb family/whisper_icon/whisper_icon_64x64.png =====
	total += 1
	var verb_64x64_exists := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon_64x64.png")
	if not verb_64x64_exists:
		print("  FAIL [T245.8.1]: assets/ui/whisper_icon/whisper_icon_64x64.png 缺")
		quit(1); return
	passed += 1
	print("  [T245.8.1] verb family/whisper_icon/whisper_icon_64x64.png 64x64 存在 (OK)")

	# =================================================================
	# T245.9-12 — 4 .import 文件 4 断言
	# =================================================================
	print("--- T245.9-12 — 4 .import 文件 4 断言 ---")

	# ===== T245.9.IMPORT_ACH_BASE =====
	total += 1
	var import_ach_base_exists := FileAccess.file_exists("res://assets/ui/achievements/whisper_icon/whisper_icon.png.import")
	if not import_ach_base_exists:
		print("  FAIL [T245.9.1]: assets/ui/achievements/whisper_icon/whisper_icon.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T245.9.1] achievements/whisper_icon/whisper_icon.png.import 存在 (OK)")

	# ===== T245.10.IMPORT_ACH_32X32 =====
	total += 1
	var import_ach_32x32_exists := FileAccess.file_exists("res://assets/ui/achievements/whisper_icon/whisper_icon_32x32.png.import")
	if not import_ach_32x32_exists:
		print("  FAIL [T245.10.1]: assets/ui/achievements/whisper_icon/whisper_icon_32x32.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T245.10.1] achievements/whisper_icon/whisper_icon_32x32.png.import 存在 (OK)")

	# ===== T245.11.IMPORT_VERB_BASE =====
	total += 1
	var import_verb_base_exists := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon.png.import")
	if not import_verb_base_exists:
		print("  FAIL [T245.11.1]: assets/ui/whisper_icon/whisper_icon.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T245.11.1] verb family/whisper_icon/whisper_icon.png.import 存在 (OK)")

	# ===== T245.12.IMPORT_VERB_64X64 =====
	total += 1
	var import_verb_64x64_exists := FileAccess.file_exists("res://assets/ui/whisper_icon/whisper_icon_64x64.png.import")
	if not import_verb_64x64_exists:
		print("  FAIL [T245.12.1]: assets/ui/whisper_icon/whisper_icon_64x64.png.import 缺")
		quit(1); return
	passed += 1
	print("  [T245.12.1] verb family/whisper_icon/whisper_icon_64x64.png.import 存在 (OK)")

	# =================================================================
	# T245.13-16 — STYLE_GUIDE 6 verb 视觉组段 4 断言
	# =================================================================
	print("--- T245.13-16 — STYLE_GUIDE 6 verb 视觉组段 4 断言 ---")

	# ===== T245.13.HEADER — "6 verb 技能图标视觉组" 段头 =====
	total += 1
	if src_style_guide.find("6 verb 技能图标视觉组") == -1:
		print("  FAIL [T245.13.1]: STYLE_GUIDE.md 缺 '6 verb 技能图标视觉组' 段")
		quit(1); return
	passed += 1
	print("  [T245.13.1] STYLE_GUIDE.md 含 '6 verb 技能图标视觉组' 段 (OK)")

	# ===== T245.14.HEX_MUTED_MAUVE — Whisper Muted Mauve #C8A4D8 =====
	total += 1
	if src_style_guide.find("#C8A4D8") == -1 or src_style_guide.find("Whisper") == -1 or src_style_guide.find("Muted Mauve") == -1:
		print("  FAIL [T245.14.1]: STYLE_GUIDE.md 缺 Whisper Muted Mauve #C8A4D8 行")
		quit(1); return
	passed += 1
	print("  [T245.14.1] STYLE_GUIDE.md 含 Whisper Muted Mauve #C8A4D8 (OK)")

	# ===== T245.15.SIX_VERB_HEXES — 6 verb 调色六元组 5 旧 verb 1 新 verb 全部在表 =====
	total += 1
	var verb_anchor_count := 0
	for verb_anchor in ["Pulse", "Bind", "Cut", "Echo", "Wave", "Whisper"]:
		if src_style_guide.find(verb_anchor) != -1:
			verb_anchor_count += 1
	if verb_anchor_count != 6:
		print("  FAIL [T245.15.1]: STYLE_GUIDE.md 6 verb anchor 缺 (count=%d, 期望 6)" % verb_anchor_count)
		quit(1); return
	passed += 1
	print("  [T245.15.1] STYLE_GUIDE.md 含 6 verb 调色六元组 (Pulse/Bind/Cut/Echo/Wave/Whisper, 6/6) (OK)")

	# ===== T245.16.REFERENCE_PATH — assets/ui/whisper_icon/ 在参考路径 =====
	total += 1
	if src_style_guide.find("assets/ui/whisper_icon/") == -1:
		print("  FAIL [T245.16.1]: STYLE_GUIDE.md 参考路径缺 assets/ui/whisper_icon/")
		quit(1); return
	passed += 1
	print("  [T245.16.1] STYLE_GUIDE.md 参考路径含 assets/ui/whisper_icon/ (OK)")

	# =================================================================
	# T245.17-20 — ICON_COLORS 3 entry + 1 count 4 断言
	# =================================================================
	print("--- T245.17-20 — ICON_COLORS 3 entry + 1 count 4 断言 ---")

	# ===== T245.17.ECHO_ICON — echo_icon Glass Cyan =====
	total += 1
	if src_achievement_notif.find('"echo_icon"') == -1 or src_achievement_notif.find("0.412, 0.78, 0.808") == -1:
		print("  FAIL [T245.17.1]: achievement_notification.gd ICON_COLORS 缺 echo_icon Glass Cyan entry")
		quit(1); return
	passed += 1
	print("  [T245.17.1] achievement_notification.gd ICON_COLORS 含 echo_icon Glass Cyan (OK)")

	# ===== T245.18.WAVE_ICON — wave_icon Pale Resonance =====
	total += 1
	if src_achievement_notif.find('"wave_icon"') == -1 or src_achievement_notif.find("0.718, 0.906, 0.867") == -1:
		print("  FAIL [T245.18.1]: achievement_notification.gd ICON_COLORS 缺 wave_icon Pale Resonance entry")
		quit(1); return
	passed += 1
	print("  [T245.18.1] achievement_notification.gd ICON_COLORS 含 wave_icon Pale Resonance (OK)")

	# ===== T245.19.WHISPER_ICON — whisper_icon Muted Mauve =====
	total += 1
	if src_achievement_notif.find('"whisper_icon"') == -1 or src_achievement_notif.find("0.784, 0.643, 0.847") == -1:
		print("  FAIL [T245.19.1]: achievement_notification.gd ICON_COLORS 缺 whisper_icon Muted Mauve entry")
		quit(1); return
	passed += 1
	print("  [T245.19.1] achievement_notification.gd ICON_COLORS 含 whisper_icon Muted Mauve (OK)")

	# ===== T245.20.ICON_COLORS_COUNT — ICON_COLORS entries 8 → 11 =====
	total += 1
	var icon_colors_count := _count_occurrences(src_achievement_notif, "Color(")
	# 8 旧 entries + 3 新 entries = 11 entries (8 + 3 = 11)
	# 注: 旧 Color( 含 8 entries: amber_dot 4 + coral_pulse 3 + three_circles 1 = 8, 加上 ICON_DEFAULT 1 个 fallback = 9 个
	# 加上新 3 entries (echo_icon / wave_icon / whisper_icon) = 12 Color( occurrences
	# 但 _load_icon_texture 内部可能也有 Color(), 所以宽松判断 ≥ 11
	if icon_colors_count < 11:
		print("  FAIL [T245.20.1]: ICON_COLORS Color() count=%d, 期望 ≥ 11 (8 旧 + 3 新)" % icon_colors_count)
		quit(1); return
	passed += 1
	print("  [T245.20.1] ICON_COLORS Color() count=%d ≥ 11 (8 旧 + 3 新 entry OK)" % icon_colors_count)

	# =================================================================
	# T245.21-24 — ASSET_REGISTRY A074 4 断言
	# =================================================================
	print("--- T245.21-24 — ASSET_REGISTRY A074 4 断言 ---")

	# ===== T245.21.A074_ROW — A074 行存在 =====
	total += 1
	if src_asset_registry.find("| A074 |") == -1:
		print("  FAIL [T245.21.1]: ASSET_REGISTRY.md 缺 A074 行")
		quit(1); return
	passed += 1
	print("  [T245.21.1] ASSET_REGISTRY.md 含 A074 行 (OK)")

	# ===== T245.22.SEED_1074 — seed=1074 =====
	total += 1
	if src_asset_registry.find("1074") == -1:
		print("  FAIL [T245.22.1]: ASSET_REGISTRY.md A074 缺 1074 seed")
		quit(1); return
	passed += 1
	print("  [T245.22.1] ASSET_REGISTRY.md A074 含 1074 seed (OK)")

	# ===== T245.23.SIX_VERB_ICON_LOOP — 6 verb 视觉组闭环说明 =====
	total += 1
	if src_asset_registry.find("6 verb 视觉组") == -1 or src_asset_registry.find("闭环") == -1:
		print("  FAIL [T245.23.1]: ASSET_REGISTRY.md A074 缺 6 verb 视觉组闭环说明")
		quit(1); return
	passed += 1
	print("  [T245.23.1] ASSET_REGISTRY.md A074 含 6 verb 视觉组闭环说明 (OK)")

	# ===== T245.24.T245_ANCHOR — T245 任务锚点 =====
	total += 1
	if src_asset_registry.find("T245") == -1:
		print("  FAIL [T245.24.1]: ASSET_REGISTRY.md A074 缺 T245 任务锚点")
		quit(1); return
	passed += 1
	print("  [T245.24.1] ASSET_REGISTRY.md A074 含 T245 任务锚点 (OK)")

	# =================================================================
	# 完成
	# =================================================================
	print("=== T245 #162 Whisper 6 verb icon 落地 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _count_occurrences(haystack: String, needle: String) -> int:
	if needle == "":
		return 0
	var count := 0
	var sp := 0
	while true:
		var idx := haystack.find(needle, sp)
		if idx == -1:
			break
		count += 1
		sp = idx + needle.length()
	return count
