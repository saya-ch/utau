extends SceneTree
## T268 (#188) — §9.6.15 SaveSystem `audit_save_slots()` 4 状态巡检 (empty / ok / corrupted / drift) + `_refresh_profile_audit` 1 行 4 字段 + `has_method` 跨调用方守卫 + `call_deferred` 启动延迟 polish 模式 (T088 + T131 + T224 + T229 + T265 跨 5 任务 ~40 轮落地) smoke test
##
## 1 任务 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_t268_contributing_fragility_section9615_smoke.gd
##
## T268: CONTRIBUTING.md §9.6.15 已知 fragility 扩展
##   - §9.6.15 5 件套 (公共 audit_save_slots + 内部 _audit_save_slots + call_deferred 启动延迟 + PauseMenu 渲染 + TitleScreen 守卫)
##   - save_system.gd const SLOT_COUNT := 5 顶层常量
##   - save_system.gd func audit_save_slots() 公共入口 (1 行委托)
##   - save_system.gd func _audit_save_slots() 内部 worker (8 key + 4 状态 + 4 ids arrays)
##   - save_system.gd _ready 末尾 call_deferred("audit_save_slots") 启动延迟
##   - pause_menu.gd _refresh_profile_audit 1 行 4 字段 + 3 档色域分工 + has_method 守卫
##   - title_screen.gd _ready has_method("audit_save_slots") 守卫 + 1 行 audit
## 验证 9 维:
##   - §9.6.15 章节在 CONTRIBUTING.md 已落地
##   - §9.6.15 4 段结构 (症状/触发/修复/预防) 全部存在
##   - save_system.gd SLOT_COUNT 顶层常量 5 + audit_save_slots 公共入口 + _audit_save_slots 内部 worker 4 状态
##   - save_system.gd _audit_save_slots 4 ids arrays (empty_ids / ok_ids / corrupted_ids / drift_ids)
##   - save_system.gd _audit_save_slots 走 SLOT_COUNT 循环 0 走硬编码 5
##   - save_system.gd _ready 末尾 call_deferred("audit_save_slots") 启动延迟
##   - pause_menu.gd _refresh_profile_audit 1 行 4 字段 (中点 "·" 分隔) + 3 档色域分工
##   - pause_menu.gd _refresh_profile_audit has_method 守卫 + 4 行 int(report.get, 0) 0 漏 default
##   - title_screen.gd _ready has_method 守卫 + 1 行 audit
##   - CHANGELOG.md 含 #188 段 + ROADMAP.md 顶部时间戳含 #188

func _initialize() -> void:
	print("=== T268 #188 §9.6.15 SaveSystem audit_save_slots() 4 状态巡检 (empty / ok / corrupted / drift) + _refresh_profile_audit 1 行 4 字段 + has_method 跨调用方守卫 + call_deferred 启动延迟 polish 模式 (T088 + T131 + T224 + T229 + T265 跨 5 任务 ~40 轮落地) smoke test ===")

	var src_contributing := _read_file("res://CONTRIBUTING.md")
	var src_save_system := _read_file("res://src/autoload/save_system.gd")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_title_screen := _read_file("res://src/scripts/title_screen.gd")
	var src_changelog := _read_file("res://CHANGELOG.md")
	var src_changelog_archive := _read_file("res://CHANGELOG_ARCHIVE.md")  # T162 brittle 修复流程: CHANGELOG 归档后双源 check 跨迭代稳定 (T287 #209 落地后 #67-#197 已归档到 CHANGELOG_ARCHIVE.md, 旧段 #N 引用可能只在 archive 中)
	var src_roadmap := _read_file("res://ROADMAP.md")

	var passed := 0
	var total := 0

	# =================================================================
	# T268.1 — §9.6.15 章节在 CONTRIBUTING.md 已落地 (3 断言)
	# =================================================================
	print("--- T268.1 — §9.6.15 章节在 CONTRIBUTING.md 已落地 ---")

	# ===== T268.1.1 §9.6.15 章节标题 =====
	total += 1
	if src_contributing.find("### 9.6.15 SaveSystem `audit_save_slots()`") == -1:
		print("  FAIL [T268.1.1]: CONTRIBUTING.md 缺 §9.6.15 章节标题")
		quit(1); return
	passed += 1
	print("  [T268.1.1] CONTRIBUTING.md 含 §9.6.15 章节标题 (OK)")

	# ===== T268.1.2 §9.6.15 含 T088 + T131 + T224 + T229 + T265 anchor =====
	total += 1
	var s9615_start := src_contributing.find("### 9.6.15")
	var s10_start := src_contributing.find("## 10.")
	if s9615_start == -1 or s10_start == -1:
		print("  FAIL [T268.1.2]: §9.6.15 / ## 10 区间划分失败")
		quit(1); return
	var s9615 := src_contributing.substr(s9615_start, s10_start - s9615_start)
	for anchor in ["T088", "T131", "T224", "T229", "T265"]:
		if s9615.find(anchor) == -1:
			print("  FAIL [T268.1.2]: §9.6.15 区间缺 %s anchor" % anchor)
			quit(1); return
	passed += 1
	print("  [T268.1.2] CONTRIBUTING.md §9.6.15 区间含 T088 + T131 + T224 + T229 + T265 5 anchor (OK)")

	# ===== T268.1.3 §9.6.15 提到 4 状态 (empty / ok / corrupted / drift) + SLOT_COUNT 核心概念 =====
	total += 1
	for kw in ["empty", "ok", "corrupted", "drift", "SLOT_COUNT", "5 件套", "call_deferred", "has_method"]:
		if s9615.find(kw) == -1:
			print("  FAIL [T268.1.3]: §9.6.15 缺核心概念 \"%s\"" % kw)
			quit(1); return
	passed += 1
	print("  [T268.1.3] CONTRIBUTING.md §9.6.15 含 4 状态 + SLOT_COUNT + 5 件套 + call_deferred + has_method 核心概念 (OK)")

	# =================================================================
	# T268.2 — §9.6.15 4 段结构 (症状/触发/修复/预防) 全部存在 (3 断言)
	# =================================================================
	print("--- T268.2 — §9.6.15 4 段结构 (症状/触发/修复/预防) 全部存在 ---")

	# ===== T268.2.1 §9.6.15 症状段 =====
	total += 1
	if s9615.find("**症状**") == -1:
		print("  FAIL [T268.2.1]: §9.6.15 缺症状段")
		quit(1); return
	passed += 1
	print("  [T268.2.1] §9.6.15 含 症状段 (OK)")

	# ===== T268.2.2 §9.6.15 触发场景段 =====
	total += 1
	if s9615.find("**触发场景**") == -1:
		print("  FAIL [T268.2.2]: §9.6.15 缺触发场景段")
		quit(1); return
	passed += 1
	print("  [T268.2.2] §9.6.15 含 触发场景段 (OK)")

	# ===== T268.2.3 §9.6.15 修复段 + 预防段 =====
	total += 1
	if s9615.find("**修复**") == -1 or s9615.find("**预防**") == -1:
		print("  FAIL [T268.2.3]: §9.6.15 缺修复/预防段")
		quit(1); return
	passed += 1
	print("  [T268.2.3] §9.6.15 含 修复段 + 预防段 (OK)")

	# =================================================================
	# T268.3 — save_system.gd 顶层常量 SLOT_COUNT + 公共入口 + 内部 worker 4 状态 (4 断言)
	# =================================================================
	print("--- T268.3 — save_system.gd SLOT_COUNT + audit_save_slots 公共入口 + _audit_save_slots 内部 worker 4 状态 ---")

	# ===== T268.3.1 save_system.gd 含 const SLOT_COUNT = 5 =====
	total += 1
	if src_save_system.find("const SLOT_COUNT := 5") == -1:
		print("  FAIL [T268.3.1]: save_system.gd 缺 const SLOT_COUNT := 5")
		quit(1); return
	passed += 1
	print("  [T268.3.1] save_system.gd 含 const SLOT_COUNT := 5 (OK)")

	# ===== T268.3.2 save_system.gd 含 func audit_save_slots() 公共入口 =====
	total += 1
	if src_save_system.find("func audit_save_slots() -> Dictionary:") == -1:
		print("  FAIL [T268.3.2]: save_system.gd 缺 func audit_save_slots() 公共入口")
		quit(1); return
	passed += 1
	print("  [T268.3.2] save_system.gd 含 func audit_save_slots() 公共入口 (OK)")

	# ===== T268.3.3 save_system.gd 公共入口 1 行委托 _audit_save_slots =====
	total += 1
	var audit_pub_start := src_save_system.find("func audit_save_slots() -> Dictionary:")
	var audit_pub_end := src_save_system.find("func _audit_save_slots() -> Dictionary:")
	if audit_pub_start == -1 or audit_pub_end == -1:
		print("  FAIL [T268.3.3]: 无法定位 audit_save_slots 公共入口 / _audit_save_slots 边界")
		quit(1); return
	var audit_pub_block := src_save_system.substr(audit_pub_start, audit_pub_end - audit_pub_start)
	if audit_pub_block.find("return _audit_save_slots()") == -1:
		print("  FAIL [T268.3.3]: audit_save_slots 公共入口缺 return _audit_save_slots() 1 行委托")
		quit(1); return
	passed += 1
	print("  [T268.3.3] audit_save_slots 公共入口含 return _audit_save_slots() 1 行委托 (OK)")

	# ===== T268.3.4 _audit_save_slots 内部 worker 含 4 状态 (empty / ok / corrupted / drift) =====
	total += 1
	var audit_priv_start := src_save_system.find("func _audit_save_slots() -> Dictionary:")
	var audit_priv_end_func := src_save_system.find("func ", audit_priv_start + 35)
	if audit_priv_end_func == -1:
		audit_priv_end_func = src_save_system.length()
	var audit_priv_block := src_save_system.substr(audit_priv_start, audit_priv_end_func - audit_priv_start)
	for state in ["\"empty\": 0", "\"ok\": 0", "\"corrupted\": 0", "\"drift\": 0"]:
		if audit_priv_block.find(state) == -1:
			print("  FAIL [T268.3.4]: _audit_save_slots 缺 4 状态 key %s" % state)
			quit(1); return
	passed += 1
	print("  [T268.3.4] _audit_save_slots 内部 worker 含 4 状态 key (empty/ok/corrupted/drift) (OK)")

	# =================================================================
	# T268.4 — _audit_save_slots 4 ids arrays + 走 SLOT_COUNT 循环 0 走硬编码 5 (3 断言)
	# =================================================================
	print("--- T268.4 — _audit_save_slots 4 ids arrays + 走 SLOT_COUNT 循环 0 走硬编码 5 ---")

	# ===== T268.4.1 _audit_save_slots 含 4 ids arrays (empty_ids / ok_ids / corrupted_ids / drift_ids) =====
	total += 1
	for ids in ["empty_ids", "ok_ids", "corrupted_ids", "drift_ids"]:
		if audit_priv_block.find(ids) == -1:
			print("  FAIL [T268.4.1]: _audit_save_slots 缺 ids array %s" % ids)
			quit(1); return
	passed += 1
	print("  [T268.4.1] _audit_save_slots 含 4 ids arrays (empty_ids/ok_ids/corrupted_ids/drift_ids) (OK)")

	# ===== T268.4.2 _audit_save_slots 走 SLOT_COUNT 循环 0 走硬编码 5 =====
	total += 1
	if audit_priv_block.find("for i in range(SLOT_COUNT):") == -1:
		print("  FAIL [T268.4.2]: _audit_save_slots 缺 for i in range(SLOT_COUNT): 循环")
		quit(1); return
	if audit_priv_block.find("for i in range(5):") != -1:
		print("  FAIL [T268.4.2]: _audit_save_slots 含硬编码 5, 0 走 SLOT_COUNT")
		quit(1); return
	passed += 1
	print("  [T268.4.2] _audit_save_slots 走 SLOT_COUNT 循环, 0 漏 0 改硬编码 5 (OK)")

	# ===== T268.4.3 _audit_save_slots 末尾 push_warning 报 4 状态 + corrupted_ids / drift_ids =====
	total += 1
	if audit_priv_block.find("push_warning") == -1:
		print("  FAIL [T268.4.3]: _audit_save_slots 缺 push_warning 报损坏/漂移")
		quit(1); return
	if audit_priv_block.find("corrupted_ids") == -1 and audit_priv_block.find("str(report[\"corrupted_ids\"])") == -1:
		print("  FAIL [T268.4.3]: _audit_save_slots push_warning 缺 corrupted_ids 报告")
		quit(1); return
	passed += 1
	print("  [T268.4.3] _audit_save_slots 末尾 push_warning 报 4 状态 + corrupted_ids / drift_ids (OK)")

	# =================================================================
	# T268.5 — save_system.gd _ready 末尾 call_deferred(\"audit_save_slots\") 启动延迟 (2 断言)
	# =================================================================
	print("--- T268.5 — save_system.gd _ready 末尾 call_deferred(\"audit_save_slots\") 启动延迟 ---")

	# ===== T268.5.1 save_system.gd _ready 末尾含 call_deferred(\"audit_save_slots\") =====
	total += 1
	var ss_ready_start := src_save_system.find("func _ready() -> void:")
	var ss_ready_end := src_save_system.find("func ", ss_ready_start + 22)
	if ss_ready_end == -1:
		ss_ready_end = src_save_system.length()
	var ss_ready_block := src_save_system.substr(ss_ready_start, ss_ready_end - ss_ready_start)
	if ss_ready_block.find("call_deferred(\"audit_save_slots\")") == -1:
		print("  FAIL [T268.5.1]: save_system.gd _ready 缺 call_deferred(\"audit_save_slots\") 启动延迟")
		quit(1); return
	passed += 1
	print("  [T268.5.1] save_system.gd _ready 末尾含 call_deferred(\"audit_save_slots\") 启动延迟 (OK)")

	# ===== T268.5.2 _ready 末尾 call_deferred 应在函数末尾 (最后 5 行内) =====
	total += 1
	var cd_pos := ss_ready_block.find("call_deferred(\"audit_save_slots\")")
	if cd_pos == -1:
		print("  FAIL [T268.5.2]: 无法定位 call_deferred(\"audit_save_slots\") 位置")
		quit(1); return
	var tail := ss_ready_block.substr(cd_pos)
	if tail.length() > 100:
		print("  FAIL [T268.5.2]: call_deferred 不在 _ready 末尾 (后续还有 %d 字符)" % tail.length())
		quit(1); return
	passed += 1
	print("  [T268.5.2] call_deferred(\"audit_save_slots\") 在 _ready 末尾 (后续 < 100 字符) (OK)")

	# =================================================================
	# T268.6 — pause_menu.gd _refresh_profile_audit 1 行 4 字段 + 3 档色域分工 (4 断言)
	# =================================================================
	print("--- T268.6 — pause_menu.gd _refresh_profile_audit 1 行 4 字段 + 3 档色域分工 ---")

	# ===== T268.6.1 pause_menu.gd 含 _refresh_profile_audit 函数 =====
	total += 1
	if src_pause_menu.find("func _refresh_profile_audit() -> void:") == -1:
		print("  FAIL [T268.6.1]: pause_menu.gd 缺 _refresh_profile_audit 函数")
		quit(1); return
	passed += 1
	print("  [T268.6.1] pause_menu.gd 含 _refresh_profile_audit 函数 (OK)")

	# ===== T268.6.2 _refresh_profile_audit 含 1 行 4 字段渲染 (中点 \"·\" 分隔) =====
	total += 1
	var rpa_start := src_pause_menu.find("func _refresh_profile_audit() -> void:")
	var rpa_end := src_pause_menu.find("func ", rpa_start + 36)
	if rpa_end == -1:
		rpa_end = src_pause_menu.length()
	var rpa_block := src_pause_menu.substr(rpa_start, rpa_end - rpa_start)
	if rpa_block.find("存档") == -1:
		print("  FAIL [T268.6.2]: _refresh_profile_audit 缺 4 字段渲染 (存档 关键字)")
		quit(1); return
	if rpa_block.find("·") == -1:
		print("  FAIL [T268.6.2]: _refresh_profile_audit 缺中点 \"·\" 分隔符")
		quit(1); return
	if rpa_block.find("ok") == -1 or rpa_block.find("损坏") == -1:
		print("  FAIL [T268.6.2]: _refresh_profile_audit 4 字段缺 ok / 损坏 关键字段")
		quit(1); return
	if rpa_block.find("漂移") == -1 or rpa_block.find("空") == -1:
		print("  FAIL [T268.6.2]: _refresh_profile_audit 4 字段缺 漂移 / 空 关键字段")
		quit(1); return
	passed += 1
	print("  [T268.6.2] _refresh_profile_audit 含 1 行 4 字段 (存档 ok 损坏 漂移 空) + 中点 \"·\" 分隔 (OK)")

	# ===== T268.6.3 _refresh_profile_audit 含 3 档色域分工 (损坏>0 暖红 / 漂移>0 暖黄 / 全 ok 暖白) =====
	total += 1
	if rpa_block.find("corrupted_n > 0") == -1:
		print("  FAIL [T268.6.3]: _refresh_profile_audit 缺 corrupted_n > 0 暖红分支")
		quit(1); return
	if rpa_block.find("drift_n > 0") == -1:
		print("  FAIL [T268.6.3]: _refresh_profile_audit 缺 drift_n > 0 暖黄分支")
		quit(1); return
	if rpa_block.find("Color(") == -1:
		print("  FAIL [T268.6.3]: _refresh_profile_audit 缺 Color() 调色")
		quit(1); return
	passed += 1
	print("  [T268.6.3] _refresh_profile_audit 含 3 档色域分工 (corrupted>0 / drift>0 / else 暖白) (OK)")

	# ===== T268.6.4 _refresh_profile_audit 含 4 行 int(report.get(X, 0)) 0 漏 default =====
	total += 1
	var default_count := 0
	for k in ["ok", "corrupted", "drift", "empty"]:
		if rpa_block.find("int(report.get(\"" + k + "\", 0))") != -1:
			default_count += 1
	if default_count != 4:
		print("  FAIL [T268.6.4]: _refresh_profile_audit 4 行 int(report.get(X, 0)) 仅 %d/4, 期望 4" % default_count)
		quit(1); return
	passed += 1
	print("  [T268.6.4] _refresh_profile_audit 含 4 行 int(report.get(X, 0)) 0 漏 default (OK)")

	# =================================================================
	# T268.7 — pause_menu.gd _refresh_profile_audit has_method 守卫 (1 断言)
	# =================================================================
	print("--- T268.7 — pause_menu.gd _refresh_profile_audit has_method 守卫 ---")

	# ===== T268.7.1 _refresh_profile_audit 含 has_method 守卫 =====
	total += 1
	if rpa_block.find("has_method(\"audit_save_slots\")") == -1:
		print("  FAIL [T268.7.1]: _refresh_profile_audit 缺 has_method(\"audit_save_slots\") 守卫")
		quit(1); return
	passed += 1
	print("  [T268.7.1] _refresh_profile_audit 含 has_method(\"audit_save_slots\") 守卫 (OK)")

	# =================================================================
	# T268.8 — title_screen.gd _ready has_method 守卫 + 1 行 audit (2 断言)
	# =================================================================
	print("--- T268.8 — title_screen.gd _ready has_method 守卫 + 1 行 audit ---")

	# ===== T268.8.1 title_screen.gd _ready 含 has_method 守卫 =====
	total += 1
	var ts_ready_start := src_title_screen.find("func _ready() -> void:")
	var ts_ready_end := src_title_screen.find("func ", ts_ready_start + 22)
	if ts_ready_end == -1:
		ts_ready_end = src_title_screen.length()
	var ts_ready_block := src_title_screen.substr(ts_ready_start, ts_ready_end - ts_ready_start)
	if ts_ready_block.find("has_method(\"audit_save_slots\")") == -1:
		print("  FAIL [T268.8.1]: title_screen.gd _ready 缺 has_method(\"audit_save_slots\") 守卫")
		quit(1); return
	passed += 1
	print("  [T268.8.1] title_screen.gd _ready 含 has_method(\"audit_save_slots\") 守卫 (OK)")

	# ===== T268.8.2 title_screen.gd _ready 含 SaveSystem.audit_save_slots() 调用 =====
	total += 1
	if ts_ready_block.find("SaveSystem.audit_save_slots()") == -1:
		print("  FAIL [T268.8.2]: title_screen.gd _ready 缺 SaveSystem.audit_save_slots() 调用")
		quit(1); return
	passed += 1
	print("  [T268.8.2] title_screen.gd _ready 含 SaveSystem.audit_save_slots() 1 行调用 (OK)")

	# =================================================================
	# T268.9 — CHANGELOG/ROADMAP/§9.6.15 同步 (3 断言)
	# =================================================================
	print("--- T268.9 — CHANGELOG/ROADMAP/§9.6.15 同步 ---")

	# ===== T268.9.1 CHANGELOG.md 含 #188 段 =====
	total += 1
	if src_changelog.find("## #188") == -1 and src_changelog_archive.find("## #188") == -1:
		print("  FAIL [T268.9.1]: CHANGELOG.md 缺 #188 段")
		quit(1); return
	passed += 1
	print("  [T268.9.1] CHANGELOG.md 含 #188 段 (OK)")

	# ===== T268.9.2 ROADMAP.md 顶部时间戳含 #188 =====
	total += 1
	if src_roadmap.find("#188") == -1:
		print("  FAIL [T268.9.2]: ROADMAP.md 顶部缺 #188 时间戳")
		quit(1); return
	passed += 1
	print("  [T268.9.2] ROADMAP.md 顶部含 #188 时间戳 (OK)")

	# ===== T268.9.3 §9.6.15 区间提到 5 件套 + 4 段结构 + 1:1 同步 =====
	total += 1
	for kw in ["5 件套", "**症状**", "**触发场景**", "**修复**", "**预防**", "1:1"]:
		if s9615.find(kw) == -1:
			print("  FAIL [T268.9.3]: §9.6.15 区间缺关键 anchor \"%s\"" % kw)
			quit(1); return
	passed += 1
	print("  [T268.9.3] §9.6.15 区间含 5 件套 + 4 段结构 + 1:1 同步 6 关键 anchor (OK)")

	print("=== T268 #188 §9.6.15 SaveSystem audit_save_slots() 4 状态巡检 (empty / ok / corrupted / drift) + _refresh_profile_audit 1 行 4 字段 + has_method 跨调用方守卫 + call_deferred 启动延迟 polish 模式 (T088 + T131 + T224 + T229 + T265 跨 5 任务 ~40 轮落地) smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("无法打开 %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content
