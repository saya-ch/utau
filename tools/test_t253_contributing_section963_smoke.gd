extends SceneTree
## T253 (#172) — §9.6.3 6 verb HUD 7 UI 通道 polish 模式 smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t253_contributing_section963_smoke.gd
##
## T253: CONTRIBUTING.md §9.6.3 已知 fragility 扩展 (T247 #164 落地的 6 verb HUD 5+1 verb 7 UI 通道模式文档化)
##   - §9.6.3 6 verb HUD 8 通道 1:1 复制模式 (T247 #164 落地)
##   - 与 §9.6.1 跨类 handler + §9.6.2 VFX 5 layer 同步文档化
## 验证 5 维:
##   - §9.6.3 章节在 CONTRIBUTING.md 已落地 (3 断言)
##   - §9.6.3 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
##   - §9.6.3 与 §9.6.1 + §9.6.2 衔接 (2 断言: 8 通道 1:1 复制条目 + Muted Mauve #C8A4D8 第 6 verb 调色)
##   - hud.gd 8 通道 1:1 复制代码 pattern 实际存在 (8 断言)
##   - hud.tscn 6 verb Whisper 节点 4 子节点 (4 断言)
##   - CHANGELOG/ROADMAP 同步 (2 断言)
## 总 23 断言

func _initialize() -> void:
	print("=== T253 #172 §9.6.3 6 verb HUD 7 UI 通道 polish 模式 smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_hud_gd := _read_file("res://src/scripts/hud.gd")
	var src_hud_tscn := _read_file("res://src/scenes/hud.tscn")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T253.1 — §9.6.3 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T253.1 — §9.6.3 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T253.1.1 §9.6.3 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.3 6 verb HUD 7 UI 通道 polish 模式") == -1:
		print("  FAIL [T253.1.1]: CONTRIBUTING.md 缺 §9.6.3 章节标题")
		quit(1); return
	passed += 1
	print("  [T253.1.1] CONTRIBUTING.md 含 §9.6.3 章节标题 (OK)")

	# ===== T253.1.2 T247 #164 锚点 =====
	total += 1
	if src_contributing.find("T247 #164 落地") == -1:
		print("  FAIL [T253.1.2]: CONTRIBUTING.md §9.6.3 缺 T247 #164 锚点")
		quit(1); return
	passed += 1
	print("  [T253.1.2] CONTRIBUTING.md §9.6.3 含 T247 #164 锚点 (OK)")

	# ===== T253.1.3 §9.6.3 位置在 §9.6.2 之后 ## 10. 之前 =====
	total += 1
	var s963_idx := src_contributing.find("### 9.6.3 6 verb HUD 7 UI 通道 polish 模式")
	var s962_idx := src_contributing.find("### 9.6.2 VFX 5 层视觉 (L1–L5) polish 模式")
	var s10_idx := src_contributing.find("## 10. 联系方式 / 决策记录")
	if s962_idx == -1 or s963_idx == -1 or s10_idx == -1:
		print("  FAIL [T253.1.3]: §9.6.2 / §9.6.3 / §10 顺序定位失败")
		quit(1); return
	if not (s962_idx < s963_idx and s963_idx < s10_idx):
		print("  FAIL [T253.1.3]: §9.6.3 位置错 (期望: §9.6.2 < §9.6.3 < §10)")
		quit(1); return
	passed += 1
	print("  [T253.1.3] §9.6.3 位置正确 (§9.6.2 < §9.6.3 < §10) (OK)")

	# =================================================================
	# T253.2 — §9.6.3 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T253.2 — §9.6.3 4 段结构 ---")

	var s963_start := s963_idx
	var s963_end := s10_idx
	var s963 := src_contributing.substr(s963_start, s963_end - s963_start)

	# ===== T253.2.1 §9.6.3 症状 =====
	total += 1
	if s963.find("**症状**") == -1:
		print("  FAIL [T253.2.1]: §9.6.3 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T253.2.1] §9.6.3 含「症状」段 (OK)")

	# ===== T253.2.2 §9.6.3 触发 =====
	total += 1
	if s963.find("**触发场景**") == -1:
		print("  FAIL [T253.2.2]: §9.6.3 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T253.2.2] §9.6.3 含「触发场景」段 (OK)")

	# ===== T253.2.3 §9.6.3 修复 =====
	total += 1
	if s963.find("**修复**") == -1:
		print("  FAIL [T253.2.3]: §9.6.3 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T253.2.3] §9.6.3 含「修复」段 (OK)")

	# ===== T253.2.4 §9.6.3 预防 =====
	total += 1
	if s963.find("**预防**") == -1:
		print("  FAIL [T253.2.4]: §9.6.3 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T253.2.4] §9.6.3 含「预防」段 (OK)")

	# =================================================================
	# T253.3 — §9.6.3 关键内容 (8 通道 1:1 复制 + Muted Mauve 第 6 verb 调色) (2 断言)
	# =================================================================
	print("--- T253.3 — §9.6.3 关键内容 ---")

	# ===== T253.3.1 8 通道 1:1 复制模式描述 =====
	total += 1
	if s963.find("8 通道 1:1 复制") == -1 or s963.find("C0 ability var") == -1 or s963.find("C8 _apply_reduced_flash_modulate") == -1:
		print("  FAIL [T253.3.1]: §9.6.3 缺 8 通道 1:1 复制模式描述 (C0-C8)")
		quit(1); return
	passed += 1
	print("  [T253.3.1] §9.6.3 含 8 通道 1:1 复制模式描述 (C0-C8) (OK)")

	# ===== T253.3.2 Muted Mauve #C8A4D8 第 6 verb 调色 =====
	total += 1
	if s963.find("Muted Mauve") == -1 or s963.find("#C8A4D8") == -1 or s963.find("6 verb 调色六元组") == -1:
		print("  FAIL [T253.3.2]: §9.6.3 缺 Muted Mauve #C8A4D8 第 6 verb 调色锚点")
		quit(1); return
	passed += 1
	print("  [T253.3.2] §9.6.3 含 Muted Mauve #C8A4D8 第 6 verb 调色锚点 (OK)")

	# =================================================================
	# T253.4 — hud.gd 8 通道 1:1 复制代码 pattern 实际存在 (8 断言)
	# =================================================================
	print("--- T253.4 — hud.gd 8 通道 1:1 复制代码 pattern ---")

	# ===== T253.4.1 C0 ability var 引用 =====
	total += 1
	if src_hud_gd.find("var _whisper_ability = null") == -1:
		print("  FAIL [T253.4.1]: hud.gd 缺 var _whisper_ability = null (C0)")
		quit(1); return
	passed += 1
	print("  [T253.4.1] hud.gd 含 C0 ability var 引用 (OK)")

	# ===== T253.4.2 C2 name label 引用 =====
	total += 1
	if src_hud_gd.find("var _whisper_name_label: Label = $MarginContainer/VBoxContainer/WhisperRow/WhisperNameLabel") == -1:
		print("  FAIL [T253.4.2]: hud.gd 缺 _whisper_name_label @onready 引用 (C2)")
		quit(1); return
	passed += 1
	print("  [T253.4.2] hud.gd 含 C2 name label @onready 引用 (OK)")

	# ===== T253.4.3 C3 cooldown bar 引用 =====
	total += 1
	if src_hud_gd.find("var _whisper_cooldown: ProgressBar = $MarginContainer/VBoxContainer/WhisperRow/WhisperCooldown") == -1:
		print("  FAIL [T253.4.3]: hud.gd 缺 _whisper_cooldown @onready 引用 (C3)")
		quit(1); return
	passed += 1
	print("  [T253.4.3] hud.gd 含 C3 cooldown bar @onready 引用 (OK)")

	# ===== T253.4.4 C4 cooldown label 引用 =====
	total += 1
	if src_hud_gd.find("var _whisper_cooldown_label: Label = $MarginContainer/VBoxContainer/WhisperRow/WhisperCooldownLabel") == -1:
		print("  FAIL [T253.4.4]: hud.gd 缺 _whisper_cooldown_label @onready 引用 (C4)")
		quit(1); return
	passed += 1
	print("  [T253.4.4] hud.gd 含 C4 cooldown label @onready 引用 (OK)")

	# ===== T253.4.5 C5 glow color const =====
	total += 1
	if src_hud_gd.find("const _WHISPER_GLOW_COLOR := Color(0.784, 0.643, 0.847, 1.0)") == -1:
		print("  FAIL [T253.4.5]: hud.gd 缺 _WHISPER_GLOW_COLOR const (C5)")
		quit(1); return
	passed += 1
	print("  [T253.4.5] hud.gd 含 C5 _WHISPER_GLOW_COLOR const (OK)")

	# ===== T253.4.6 C6 glow stylebox var =====
	total += 1
	if src_hud_gd.find("var _whisper_glow_bg: StyleBoxFlat") == -1:
		print("  FAIL [T253.4.6]: hud.gd 缺 var _whisper_glow_bg: StyleBoxFlat (C6)")
		quit(1); return
	passed += 1
	print("  [T253.4.6] hud.gd 含 C6 _whisper_glow_bg stylebox var (OK)")

	# ===== T253.4.7 C7 _verb_glow_state dict key =====
	total += 1
	if src_hud_gd.find("\"whisper\": false") == -1:
		print("  FAIL [T253.4.7]: hud.gd 缺 _verb_glow_state[\"whisper\"] dict key (C7)")
		quit(1); return
	passed += 1
	print("  [T253.4.7] hud.gd 含 C7 _verb_glow_state dict key (OK)")

	# ===== T253.4.8 C8 _apply_reduced_flash_modulate iteration list 8 元素含 _whisper_cooldown =====
	total += 1
	var apply_idx := src_hud_gd.find("func _apply_reduced_flash_modulate")
	if apply_idx == -1:
		print("  FAIL [T253.4.8]: hud.gd 缺 _apply_reduced_flash_modulate 函数")
		quit(1); return
	# 取函数体 (取后 800 字符)
	var apply_body := src_hud_gd.substr(apply_idx, 800)
	if apply_body.find("_whisper_cooldown") == -1 or apply_body.find("_resonance_bar") == -1 or apply_body.find("_health_container") == -1:
		print("  FAIL [T253.4.8]: hud.gd _apply_reduced_flash_modulate iteration list 缺 _whisper_cooldown (C8)")
		quit(1); return
	passed += 1
	print("  [T253.4.8] hud.gd 含 C8 _apply_reduced_flash_modulate iteration list 8 元素 (OK)")

	# =================================================================
	# T253.5 — hud.tscn 6 verb Whisper 节点 4 子节点 (4 断言)
	# =================================================================
	print("--- T253.5 — hud.tscn 6 verb Whisper 节点 ---")

	# ===== T253.5.1 WhisperRow HBoxContainer =====
	total += 1
	if src_hud_tscn.find("[node name=\"WhisperRow\" type=\"HBoxContainer\"") == -1:
		print("  FAIL [T253.5.1]: hud.tscn 缺 WhisperRow HBoxContainer 节点")
		quit(1); return
	passed += 1
	print("  [T253.5.1] hud.tscn 含 WhisperRow HBoxContainer 节点 (OK)")

	# ===== T253.5.2 WhisperIcon TextureRect =====
	total += 1
	if src_hud_tscn.find("[node name=\"WhisperIcon\" type=\"TextureRect\" parent=\"MarginContainer/VBoxContainer/WhisperRow\"]") == -1:
		print("  FAIL [T253.5.2]: hud.tscn 缺 WhisperIcon TextureRect 子节点")
		quit(1); return
	passed += 1
	print("  [T253.5.2] hud.tscn 含 WhisperIcon TextureRect 子节点 (OK)")

	# ===== T253.5.3 WhisperNameLabel Label =====
	total += 1
	if src_hud_tscn.find("[node name=\"WhisperNameLabel\" type=\"Label\" parent=\"MarginContainer/VBoxContainer/WhisperRow\"]") == -1:
		print("  FAIL [T253.5.3]: hud.tscn 缺 WhisperNameLabel Label 子节点")
		quit(1); return
	passed += 1
	print("  [T253.5.3] hud.tscn 含 WhisperNameLabel Label 子节点 (OK)")

	# ===== T253.5.4 WhisperCooldownLabel Label =====
	total += 1
	if src_hud_tscn.find("[node name=\"WhisperCooldownLabel\" type=\"Label\" parent=\"MarginContainer/VBoxContainer/WhisperRow\"]") == -1:
		print("  FAIL [T253.5.4]: hud.tscn 缺 WhisperCooldownLabel Label 子节点")
		quit(1); return
	passed += 1
	print("  [T253.5.4] hud.tscn 含 WhisperCooldownLabel Label 子节点 (OK)")

	# =================================================================
	# T253.6 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T253.6 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T253.6.1 CHANGELOG.md 含 #172 段 =====
	total += 1
	if src_changelog.find("## #172 —") == -1:
		print("  FAIL [T253.6.1]: CHANGELOG.md 缺 #172 段")
		quit(1); return
	passed += 1
	print("  [T253.6.1] CHANGELOG.md 含 #172 段 (OK)")

	# ===== T253.6.2 ROADMAP.md 顶部含 #172 锚点 =====
	total += 1
	if src_roadmap.find("#172") == -1:
		print("  FAIL [T253.6.2]: ROADMAP.md 顶部缺 #172 时间戳")
		quit(1); return
	passed += 1
	print("  [T253.6.2] ROADMAP.md 顶部含 #172 锚点 (OK)")

	print("=== T253 #172 §9.6.3 6 verb HUD 7 UI 通道 polish 模式 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
