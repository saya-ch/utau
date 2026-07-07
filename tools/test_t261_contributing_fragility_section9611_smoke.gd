extends SceneTree
## T261 (#182) — §9.6.11 settings_menu ReduceAllCheck 三态 (enabled / disabled / indeterminate) 总开关 + 3 子项 reduce_*_check 联动 + 防递归 `_syncing_from_master` 守卫 polish 模式 (T202.B #121 落地) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t261_contributing_fragility_section9611_smoke.gd
##
## T261: CONTRIBUTING.md §9.6.11 已知 fragility 扩展
##   - §9.6.11 ReduceAllCheck 三态 (enabled/disabled/indeterminate) + 3 子项 reduce_*_check 联动
##   - T202.B #121 _syncing_from_master 递归守卫
##   - settings_menu.gd 4 数据字段 (_reduced_shake/flash/vibration + _reduce_all)
##   - settings_menu.gd 1 守卫 (_syncing_from_master)
##   - settings_menu.gd 6 件套: 1 主 CheckBox 引用 + 1 数据 + 1 守卫 + 1 signal + 1 主 handler + 2 helper + 1 sync
## 验证 9 维:
##   - §9.6.11 章节在 CONTRIBUTING.md 已落地
##   - §9.6.11 4 段结构 (症状/触发/修复/预防) 全部存在
##   - settings_menu.gd 4 数据字段 (3 _reduced_* + 1 _reduce_all)
##   - settings_menu.gd 1 递归守卫 (_syncing_from_master)
##   - settings_menu.gd 6 件套 (主 CheckBox / _apply_three_children / _set_three_children_disabled / _sync_reduce_all_state / _on_reduce_all_toggled / 3 子项 if not _syncing_from_master)
##   - settings_menu.gd 3 子项 _on_reduce_*_toggled 末尾 1 行短路守卫
##   - CHANGELOG.md 含 #182 段 + ROADMAP.md 顶部时间戳含 #182

func _initialize() -> void:
	print("=== T261 #182 §9.6.11 ReduceAllCheck 三态 + 3 子项 reduce_*_check 联动 + 防递归 _syncing_from_master 守卫 polish 模式 (T202.B #121 落地) smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_settings_menu := _read_file("res://src/scripts/settings_menu.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T261.1 — §9.6.11 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T261.1 — §9.6.11 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T261.1.1 §9.6.11 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.11 settings_menu ReduceAllCheck 三态") == -1:
		print("  FAIL [T261.1.1]: CONTRIBUTING.md 缺 §9.6.11 章节标题")
		quit(1); return
	passed += 1
	print("  [T261.1.1] CONTRIBUTING.md 含 §9.6.11 章节标题 (OK)")

	# ===== T261.1.2 §9.6.11 含 T202.B anchor + _syncing_from_master =====
	total += 1
	var s9611_start := src_contributing.find("### 9.6.11")
	var s10_start := src_contributing.find("## 10.")
	if s9611_start == -1 or s10_start == -1:
		print("  FAIL [T261.1.2]: §9.6.11 / ## 10 区间划分失败")
		quit(1); return
	var s9611 := src_contributing.substr(s9611_start, s10_start - s9611_start)
	if s9611.find("T202.B") == -1:
		print("  FAIL [T261.1.2]: §9.6.11 区间缺 T202.B anchor")
		quit(1); return
	if s9611.find("_syncing_from_master") == -1:
		print("  FAIL [T261.1.2]: §9.6.11 区间缺 _syncing_from_master 关键字段")
		quit(1); return
	passed += 1
	print("  [T261.1.2] CONTRIBUTING.md §9.6.11 区间含 T202.B + _syncing_from_master (OK)")

	# ===== T261.1.3 §9.6.11 提到 3 子项 + 三态 + 防递归 核心概念 =====
	total += 1
	if s9611.find("3 子项") == -1 and s9611.find("三态") == -1 and s9611.find("防递归") == -1:
		print("  FAIL [T261.1.3]: §9.6.11 缺核心概念 (3 子项 / 三态 / 防递归)")
		quit(1); return
	passed += 1
	print("  [T261.1.3] CONTRIBUTING.md §9.6.11 含 3 子项 / 三态 / 防递归 核心概念 (OK)")

	# =================================================================
	# T261.2 — §9.6.11 4 段结构 (症状/触发/修复/预防) 全部存在 (4 断言)
	# =================================================================
	print("--- T261.2 — §9.6.11 4 段结构 ---")

	# ===== T261.2.1 §9.6.11 症状 =====
	total += 1
	if s9611.find("**症状**") == -1:
		print("  FAIL [T261.2.1]: §9.6.11 缺「症状」段")
		quit(1); return
	passed += 1
	print("  [T261.2.1] §9.6.11 含「症状」段 (OK)")

	# ===== T261.2.2 §9.6.11 触发场景 =====
	total += 1
	if s9611.find("**触发场景**") == -1:
		print("  FAIL [T261.2.2]: §9.6.11 缺「触发场景」段")
		quit(1); return
	passed += 1
	print("  [T261.2.2] §9.6.11 含「触发场景」段 (OK)")

	# ===== T261.2.3 §9.6.11 修复 =====
	total += 1
	if s9611.find("**修复**") == -1:
		print("  FAIL [T261.2.3]: §9.6.11 缺「修复」段")
		quit(1); return
	passed += 1
	print("  [T261.2.3] §9.6.11 含「修复」段 (OK)")

	# ===== T261.2.4 §9.6.11 预防 =====
	total += 1
	if s9611.find("**预防**") == -1:
		print("  FAIL [T261.2.4]: §9.6.11 缺「预防」段")
		quit(1); return
	passed += 1
	print("  [T261.2.4] §9.6.11 含「预防」段 (OK)")

	# =================================================================
	# T261.3 — settings_menu.gd 4 数据字段 (3 _reduced_* + 1 _reduce_all) (4 断言)
	# =================================================================
	print("--- T261.3 — settings_menu.gd 4 数据字段 ---")

	# ===== T261.3.1 _reduced_shake bool = false (T195) =====
	total += 1
	if src_settings_menu.find("var _reduced_shake: bool = false") == -1:
		print("  FAIL [T261.3.1]: settings_menu.gd 缺 var _reduced_shake: bool = false (T195 reduce_shake 数据字段)")
		quit(1); return
	passed += 1
	print("  [T261.3.1] settings_menu.gd 含 _reduced_shake bool (T195) (OK)")

	# ===== T261.3.2 _reduced_flash bool = false (T195) =====
	total += 1
	if src_settings_menu.find("var _reduced_flash: bool = false") == -1:
		print("  FAIL [T261.3.2]: settings_menu.gd 缺 var _reduced_flash: bool = false (T195 reduce_flash 数据字段)")
		quit(1); return
	passed += 1
	print("  [T261.3.2] settings_menu.gd 含 _reduced_flash bool (T195) (OK)")

	# ===== T261.3.3 _reduced_vibration bool = false (T196) =====
	total += 1
	if src_settings_menu.find("var _reduced_vibration: bool = false") == -1:
		print("  FAIL [T261.3.3]: settings_menu.gd 缺 var _reduced_vibration: bool = false (T196 reduce_vibration 数据字段)")
		quit(1); return
	passed += 1
	print("  [T261.3.3] settings_menu.gd 含 _reduced_vibration bool (T196) (OK)")

	# ===== T261.3.4 _reduce_all bool = false 独立主项 (T202.B 不从 3 子项 AND 算出) =====
	total += 1
	if src_settings_menu.find("var _reduce_all: bool = false") == -1:
		print("  FAIL [T261.3.4]: settings_menu.gd 缺 var _reduce_all: bool = false (T202.B 主开关独立数据字段)")
		quit(1); return
	passed += 1
	print("  [T261.3.4] settings_menu.gd 含 _reduce_all bool (T202.B 独立主项) (OK)")

	# =================================================================
	# T261.4 — settings_menu.gd 1 递归守卫 _syncing_from_master (2 断言)
	# =================================================================
	print("--- T261.4 — settings_menu.gd 1 递归守卫 ---")

	# ===== T261.4.1 _syncing_from_master bool = false 递归守卫 (T202.B) =====
	total += 1
	if src_settings_menu.find("var _syncing_from_master: bool = false") == -1:
		print("  FAIL [T261.4.1]: settings_menu.gd 缺 var _syncing_from_master: bool = false (T202.B 递归守卫)")
		quit(1); return
	passed += 1
	print("  [T261.4.1] settings_menu.gd 含 _syncing_from_master bool (T202.B 递归守卫) (OK)")

	# ===== T261.4.2 4 数据字段 + 1 守卫 顺序 (3 _reduced_* → 1 _reduce_all → 1 _syncing_from_master) =====
	total += 1
	var pos_shake := src_settings_menu.find("var _reduced_shake: bool = false")
	var pos_flash := src_settings_menu.find("var _reduced_flash: bool = false")
	var pos_vib := src_settings_menu.find("var _reduced_vibration: bool = false")
	var pos_all := src_settings_menu.find("var _reduce_all: bool = false")
	var pos_sync := src_settings_menu.find("var _syncing_from_master: bool = false")
	if pos_shake == -1 or pos_flash == -1 or pos_vib == -1 or pos_all == -1 or pos_sync == -1:
		print("  FAIL [T261.4.2]: settings_menu.gd 5 var 缺 1")
		quit(1); return
	# 顺序约束: shake < flash < vib < all < sync
	if not (pos_shake < pos_flash and pos_flash < pos_vib and pos_vib < pos_all and pos_all < pos_sync):
		print("  FAIL [T261.4.2]: settings_menu.gd 5 var 顺序错位 (期望 shake → flash → vib → all → sync)")
		quit(1); return
	passed += 1
	print("  [T261.4.2] settings_menu.gd 5 var 顺序正确 (shake → flash → vib → all → sync) (OK)")

	# =================================================================
	# T261.5 — settings_menu.gd 6 件套 (主 CheckBox / helper / sync / handler / signal / 3 子项 if) (6 断言)
	# =================================================================
	print("--- T261.5 — settings_menu.gd 6 件套 ---")

	# ===== T261.5.1 _reduce_all_check CheckBox 主项引用 =====
	total += 1
	if src_settings_menu.find("@onready var _reduce_all_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceAllCheck") == -1:
		print("  FAIL [T261.5.1]: settings_menu.gd 缺 @onready var _reduce_all_check (T202.B 主 CheckBox 引用)")
		quit(1); return
	passed += 1
	print("  [T261.5.1] settings_menu.gd 含 _reduce_all_check CheckBox 引用 (T202.B 主项) (OK)")

	# ===== T261.5.2 _on_reduce_all_toggled 主 handler 6 步骤 =====
	total += 1
	if src_settings_menu.find("func _on_reduce_all_toggled(enabled: bool) -> void:") == -1:
		print("  FAIL [T261.5.2]: settings_menu.gd 缺 func _on_reduce_all_toggled (T202.B 主 handler 6 步骤)")
		quit(1); return
	passed += 1
	print("  [T261.5.2] settings_menu.gd 含 _on_reduce_all_toggled 主 handler (T202.B) (OK)")

	# ===== T261.5.3 _apply_three_children helper 推 3 子项 =====
	total += 1
	if src_settings_menu.find("func _apply_three_children(enabled: bool) -> void:") == -1:
		print("  FAIL [T261.5.3]: settings_menu.gd 缺 func _apply_three_children (T202.B 推 3 子项 helper)")
		quit(1); return
	passed += 1
	print("  [T261.5.3] settings_menu.gd 含 _apply_three_children helper (T202.B) (OK)")

	# ===== T261.5.4 _set_three_children_disabled helper 灰化 3 子项 =====
	total += 1
	if src_settings_menu.find("func _set_three_children_disabled(disabled: bool) -> void:") == -1:
		print("  FAIL [T261.5.4]: settings_menu.gd 缺 func _set_three_children_disabled (T202.B 灰化 3 子项 helper)")
		quit(1); return
	passed += 1
	print("  [T261.5.4] settings_menu.gd 含 _set_three_children_disabled helper (T202.B) (OK)")

	# ===== T261.5.5 _sync_reduce_all_state 3 态判定 =====
	total += 1
	if src_settings_menu.find("func _sync_reduce_all_state() -> void:") == -1:
		print("  FAIL [T261.5.5]: settings_menu.gd 缺 func _sync_reduce_all_state (T202.B 3 态判定)")
		quit(1); return
	passed += 1
	print("  [T261.5.5] settings_menu.gd 含 _sync_reduce_all_state 3 态判定 (T202.B) (OK)")

	# ===== T261.5.6 _reduce_all_check.toggled.connect 1 行 signal =====
	total += 1
	if src_settings_menu.find("_reduce_all_check.toggled.connect(_on_reduce_all_toggled)") == -1:
		print("  FAIL [T261.5.6]: settings_menu.gd 缺 _reduce_all_check.toggled.connect (T202.B 主开关 signal 连接)")
		quit(1); return
	passed += 1
	print("  [T261.5.6] settings_menu.gd 含 _reduce_all_check.toggled.connect (T202.B signal) (OK)")

	# =================================================================
	# T261.6 — settings_menu.gd 3 子项 _on_reduce_*_toggled 末尾 1 行短路守卫 (3 断言)
	# =================================================================
	print("--- T261.6 — settings_menu.gd 3 子项 handler 末尾 if not _syncing_from_master ---")

	# ===== T261.6.1 _on_reduce_shake_toggled 末尾 if not _syncing_from_master =====
	total += 1
	var shake_handler_start := src_settings_menu.find("func _on_reduce_shake_toggled(enabled: bool) -> void:")
	var flash_handler_start := src_settings_menu.find("func _on_reduce_flash_toggled(enabled: bool) -> void:", shake_handler_start)
	if shake_handler_start == -1 or flash_handler_start == -1:
		print("  FAIL [T261.6.1]: settings_menu.gd 缺 _on_reduce_shake_toggled / _on_reduce_flash_toggled 边界")
		quit(1); return
	var shake_block := src_settings_menu.substr(shake_handler_start, flash_handler_start - shake_handler_start)
	if shake_block.find("if not _syncing_from_master:") == -1:
		print("  FAIL [T261.6.1]: settings_menu.gd _on_reduce_shake_toggled 末尾缺 if not _syncing_from_master (T202.B 短路守卫)")
		quit(1); return
	passed += 1
	print("  [T261.6.1] settings_menu.gd _on_reduce_shake_toggled 末尾含 if not _syncing_from_master (T202.B) (OK)")

	# ===== T261.6.2 _on_reduce_flash_toggled 末尾 if not _syncing_from_master =====
	total += 1
	var vib_handler_start := src_settings_menu.find("func _on_reduce_vibration_toggled(enabled: bool) -> void:", flash_handler_start)
	if vib_handler_start == -1:
		print("  FAIL [T261.6.2]: settings_menu.gd 缺 _on_reduce_vibration_toggled 边界")
		quit(1); return
	var flash_block := src_settings_menu.substr(flash_handler_start, vib_handler_start - flash_handler_start)
	if flash_block.find("if not _syncing_from_master:") == -1:
		print("  FAIL [T261.6.2]: settings_menu.gd _on_reduce_flash_toggled 末尾缺 if not _syncing_from_master (T202.B 短路守卫)")
		quit(1); return
	passed += 1
	print("  [T261.6.2] settings_menu.gd _on_reduce_flash_toggled 末尾含 if not _syncing_from_master (T202.B) (OK)")

	# ===== T261.6.3 _on_reduce_vibration_toggled 末尾 if not _syncing_from_master =====
	total += 1
	var main_handler_start := src_settings_menu.find("func _on_reduce_all_toggled(enabled: bool) -> void:", vib_handler_start)
	if main_handler_start == -1:
		print("  FAIL [T261.6.3]: settings_menu.gd 缺 _on_reduce_all_toggled 边界")
		quit(1); return
	var vib_block := src_settings_menu.substr(vib_handler_start, main_handler_start - vib_handler_start)
	if vib_block.find("if not _syncing_from_master:") == -1:
		print("  FAIL [T261.6.3]: settings_menu.gd _on_reduce_vibration_toggled 末尾缺 if not _syncing_from_master (T202.B 短路守卫)")
		quit(1); return
	passed += 1
	print("  [T261.6.3] settings_menu.gd _on_reduce_vibration_toggled 末尾含 if not _syncing_from_master (T202.B) (OK)")

	# =================================================================
	# T261.7 — settings_menu.gd 3 子项 CheckBox 引用 + 3 子项 CheckBox 0 触碰 (1 断言)
	# =================================================================
	print("--- T261.7 — settings_menu.gd 3 子项 CheckBox 引用 ---")

	# ===== T261.7.1 3 子项 _reduce_*_check CheckBox 引用 (shake + flash + vibration) 全部存在 =====
	total += 1
	var children_check_count := 0
	for child_check in [
		"@onready var _reduce_shake_check: CheckBox",
		"@onready var _reduce_flash_check: CheckBox",
		"@onready var _reduce_vibration_check: CheckBox",
	]:
		if src_settings_menu.find(child_check) != -1:
			children_check_count += 1
	if children_check_count != 3:
		print("  FAIL [T261.7.1]: settings_menu.gd 3 子项 _reduce_*_check CheckBox 引用 = %d (期望 3, T195 + T196)" % children_check_count)
		quit(1); return
	passed += 1
	print("  [T261.7.1] settings_menu.gd 3 子项 _reduce_*_check CheckBox 引用 (T195 + T196) (OK)")

	# =================================================================
	# T261.8 — CONTRIBUTING.md §9.6.11 核心概念 (3 断言)
	# =================================================================
	print("--- T261.8 — CONTRIBUTING.md §9.6.11 核心概念 ---")

	# ===== T261.8.1 §9.6.11 提到 6 件套 1:1 复制模式 =====
	total += 1
	if s9611.find("6 件套") == -1:
		print("  FAIL [T261.8.1]: §9.6.11 缺 6 件套 1:1 复制模式描述")
		quit(1); return
	passed += 1
	print("  [T261.8.1] §9.6.11 含 6 件套 1:1 复制模式 (OK)")

	# ===== T261.8.2 §9.6.11 提到 _reduce_all 数据独立于 3 子项 AND =====
	total += 1
	if s9611.find("_reduce_all") == -1:
		print("  FAIL [T261.8.2]: §9.6.11 缺 _reduce_all 数据独立字段描述")
		quit(1); return
	if s9611.find("AND") == -1:
		print("  FAIL [T261.8.2]: §9.6.11 缺「不根据 3 子项 AND 算出」关键设计描述")
		quit(1); return
	passed += 1
	print("  [T261.8.2] §9.6.11 含 _reduce_all 数据独立 + AND 关键设计 (OK)")

	# ===== T261.8.3 §9.6.11 提到 _apply_three_children + _set_three_children_disabled + _sync_reduce_all_state =====
	total += 1
	if s9611.find("_apply_three_children") == -1 or s9611.find("_set_three_children_disabled") == -1 or s9611.find("_sync_reduce_all_state") == -1:
		print("  FAIL [T261.8.3]: §9.6.11 缺 3 helper 函数名 (_apply_three_children / _set_three_children_disabled / _sync_reduce_all_state)")
		quit(1); return
	passed += 1
	print("  [T261.8.3] §9.6.11 含 3 helper 函数名 (OK)")

	# =================================================================
	# T261.9 — CHANGELOG/ROADMAP 同步 (2 断言)
	# =================================================================
	print("--- T261.9 — CHANGELOG/ROADMAP 同步 ---")

	# ===== T261.9.1 CHANGELOG.md 含 #182 段 =====
	total += 1
	if src_changelog.find("## #182 — T261") == -1:
		print("  FAIL [T261.9.1]: CHANGELOG.md 缺 #182 段")
		quit(1); return
	passed += 1
	print("  [T261.9.1] CHANGELOG.md 含 #182 段 (OK)")

	# ===== T261.9.2 ROADMAP.md 顶部时间戳含 #182 =====
	total += 1
	if src_roadmap.find("#182") == -1:
		print("  FAIL [T261.9.2]: ROADMAP.md 顶部缺 #182 时间戳")
		quit(1); return
	passed += 1
	print("  [T261.9.2] ROADMAP.md 顶部含 #182 时间戳 (OK)")

	print("=== T261 #182 §9.6.11 ReduceAllCheck 三态 + 3 子项 reduce_*_check 联动 + 防递归 _syncing_from_master 守卫 polish 模式 (T202.B #121 落地) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
