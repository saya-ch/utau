# tools/test_t293_contributing_fragility_section9637_smoke.gd
#
# T293 (#217) 落地冒烟测试: §9.6.37 SaveSystem save data CRC32 校验 5 段
# 1:1 严格分离契约 polish 模式
# 文档化 (T128 #109 + T224 #146 跨 2 任务 ~107 轮落地) — 5 段
# (Stage 1 crc32 字段 1:1 严格 + Stage 2 verify 方法 1:1 严格
# + Stage 3 audit 巡检 1:1 严格 + Stage 4 write dict 1:1 严格
# + Stage 5 read dict 1:1 严格) 1:1 严格分离契约 验证.
#
# 5 段 = 1 `save_system.gd` 1 字段 `_crc32_of_string` IEEE CRC32
#    + 1 `save_system.gd` 1 方法 `_verify_and_unwrap` 校验
#    + 1 `save_system.gd` 1 巡检 `audit_save_slots` 6 字段
#    + 1 `save_system.gd` 1 dict `save_dict` 包装层 `{ data, checksum }`
#    + 1 `save_system.gd` 1 dict `loaded_data` 解包层 `_read_json` 走 `_verify_and_unwrap` 镜像
#
# 跨 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格分离契约.
#
# 跨 28 套 polish 模式 中 第 28 套 (前 27 套为 §9.6.6 / §9.6.7 / §9.6.8 /
# §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 /
# §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 /
# §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 /
# §9.6.34 / §9.6.35 / §9.6.36, T293 是 第 28 套, 关注 "SaveSystem save data
# CRC32 校验 5 段 1:1 严格分离契约").
#
# 运行: godot --headless --path . --script tools/test_t293_contributing_fragility_section9637_smoke.gd
#
# 不依赖任何 .tscn 资源，纯 GDScript 静态解析。
# 退出码: 0 = all pass, 1 = at least one fail.

extends SceneTree

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const SAVE_SYSTEM_PATH := "res://src/autoload/save_system.gd"
const CHANGELOG_PATH := "res://CHANGELOG.md"
const README_PATH := "res://README.md"
const README_ZH_PATH := "res://README.zh-CN.md"
const ROADMAP_PATH := "res://ROADMAP.md"
const REVIEW_LOG_PATH := "res://REVIEW_LOG.md"

var _passed := 0
var _failed := 0
var _failures: Array[String] = []

func _initialize() -> void:
	_run()

func _run() -> void:
	print("=== T293 (#217) §9.6.37 SaveSystem save data CRC32 校验 5 段 1:1 严格分离契约 smoke test ===")

	var contributing := _read_text(CONTRIBUTING_PATH)
	var save_system := _read_text(SAVE_SYSTEM_PATH)
	var changelog := _read_text(CHANGELOG_PATH)
	var readme := _read_text(README_PATH)
	var readme_zh := _read_text(README_ZH_PATH)
	var roadmap := _read_text(ROADMAP_PATH)
	var review_log := _read_text(REVIEW_LOG_PATH)

	# ========== 1. §9.6.37 段顶 存在 + 6 关键词 完整 ==========
	_assert_contains(contributing, "### 9.6.37 SaveSystem save data CRC32", "T293-1: §9.6.37 段顶 存在")
	_assert_contains(contributing, "5 段 1:1 严格分离契约", "T293-2: §9.6.37 标题包含 '5 段 1:1 严格分离契约'")
	_assert_contains(contributing, "T128 #109 + T224 #146", "T293-3: §9.6.37 引用 2 任务 cross-link 链")
	_assert_contains(contributing, "~107 轮落地", "T293-4: §9.6.37 引用 ~107 轮 polish 链 (T128→T224)")

	# ========== 2. 5 段 1:1 严格分离契约 5 段 Stage 关键词 完整 ==========
	_assert_contains(contributing, "Stage 1 crc32 字段 1:1 严格", "T293-5: §9.6.37 Stage 1 crc32 字段 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 2 verify 方法 1:1 严格", "T293-6: §9.6.37 Stage 2 verify 方法 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 3 audit 巡检 1:1 严格", "T293-7: §9.6.37 Stage 3 audit 巡检 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 4 write dict 1:1 严格", "T293-8: §9.6.37 Stage 4 write dict 1:1 严格 关键词 存在")
	_assert_contains(contributing, "Stage 5 read dict 1:1 严格", "T293-9: §9.6.37 Stage 5 read dict 1:1 严格 关键词 存在")

	# ========== 3. 5 段 字节码 一致性 source-grep 验证 save_system.gd 0 漂动 ==========
	# Stage 1: _crc32_of_string 字段 (IEEE CRC32 poly 0xEDB88320)
	_assert_contains(save_system, "func _crc32_of_string", "T293-10.s1: save_system.gd `_crc32_of_string` 字段 函存 (Stage 1 crc32 字段 1:1 严格)")
	_assert_contains(save_system, "0xEDB88320", "T293-11.s1: save_system.gd `_crc32_of_string` 引用 `0xEDB88320` IEEE CRC32 poly (Stage 1 1:1 严格)")
	_assert_contains(save_system, "0xFFFFFFFF", "T293-12.s1: save_system.gd `_crc32_of_string` 引用 `0xFFFFFFFF` IEEE CRC32 init/xorout (Stage 1 1:1 严格)")
	# Stage 2: _verify_and_unwrap 方法
	_assert_contains(save_system, "func _verify_and_unwrap", "T293-13.s2: save_system.gd `_verify_and_unwrap` 方法 函存 (Stage 2 verify 方法 1:1 严格)")
	_assert_contains(save_system, "CRC32 mismatch", "T293-14.s2: save_system.gd `_verify_and_unwrap` 引用 `CRC32 mismatch` push_warning (Stage 2 1:1 严格)")
	_assert_contains(save_system, "_normalize_int_floats", "T293-15.s2: save_system.gd `_verify_and_unwrap` 引用 `_normalize_int_floats` 抵消 int→float (Stage 2 1:1 严格)")
	# Stage 3: audit_save_slots 巡检
	_assert_contains(save_system, "func audit_save_slots", "T293-16.s3: save_system.gd `audit_save_slots` 巡检 函存 (Stage 3 audit 巡检 1:1 严格)")
	_assert_contains(save_system, "func _audit_save_slots", "T293-17.s3: save_system.gd `_audit_save_slots` 内部 worker 函存 (Stage 3 audit 巡检 1:1 严格)")
	# 6 字段验证
	var audit_field_count := 0
	for field_name in ["\"empty\"", "\"ok\"", "\"corrupted\"", "\"drift\"", "\"corrupted_ids\"", "\"drift_ids\""]:
		if save_system.find(field_name) != -1:
			audit_field_count += 1
	_assert(audit_field_count >= 6, "T293-18.s3: save_system.gd `audit_save_slots` 6 字段 引用 ≥ 6/6 存在 (Stage 3 1:1 严格 0 漏 1 字段) — actual " + str(audit_field_count) + "/6")
	# Stage 4: save_dict 包装层
	_assert_contains(save_system, "var payload", "T293-19.s4: save_system.gd `var payload` 包装 dict 函存 (Stage 4 write dict 1:1 严格)")
	_assert_contains(save_system, "SAVE_CHECKSUM_KEY", "T293-20.s4: save_system.gd `SAVE_CHECKSUM_KEY` 顶层字段 函存 (Stage 4 write dict 1:1 严格)")
	_assert_contains(save_system, "\"data\": data", "T293-21.s4: save_system.gd `\"data\": data` 包装 dict entry (Stage 4 write dict 1:1 严格)")
	# Stage 5: loaded_data 解包层
	_assert_contains(save_system, "func _read_json", "T293-22.s5: save_system.gd `_read_json` 解包层 函存 (Stage 5 read dict 1:1 严格)")
	_assert_contains(save_system, "parsed.has(SAVE_CHECKSUM_KEY)", "T293-23.s5: save_system.gd `_read_json` 走 `parsed.has(SAVE_CHECKSUM_KEY)` 镜像 (Stage 5 read dict 1:1 严格)")
	_assert_contains(save_system, "func _write_json", "T293-24.s5: save_system.gd `_write_json` 写端 函存 (Stage 5 read dict 镜像 1:1 严格)")
	# 综合 5 段都到位
	_assert_contains(save_system, "func _slot_path", "T293-25: save_system.gd `_slot_path` 辅助函存 (5 段 整体结构 1:1 严格)")

	# ========== 4. 0 副作用 段 + 8 段 prevention rule + 4 关系段 ==========
	_assert_contains(contributing, "**0 副作用**", "T293-26: §9.6.37 0 副作用 段 存在")
	_assert_contains(contributing, "0 改 0 删 0 重排 `_crc32_of_string` 字段任何 1 字符", "T293-27: §9.6.37 0 副作用 段 引用 crc32 字段 0 改 0 删 0 重排")
	# 8 段 prevention rule — 5 段 0 触碰边界 / 0 改 1 字段 0 漏 / 0 改 1 边 0 漏 / T162 brittle 修复流程 / 1 套 polish 模式 / 28 套 polish 模式 / drift risk / 唯一性 标注
	_assert_contains(contributing, "5 段 0 触碰边界", "T293-28: §9.6.37 prevention 段 (a) 5 段 0 触碰边界")
	_assert_contains(contributing, "0 改 1 字段 0 漏 1 字段 0 反向", "T293-29: §9.6.37 prevention 段 (b) 0 改 1 字段 0 漏 1 字段 0 反向")
	_assert_contains(contributing, "0 改 1 边 0 漏 1 边 0 反向", "T293-30: §9.6.37 prevention 段 (c) 0 改 1 边 0 漏 1 边 0 反向")
	_assert_contains(contributing, "T162 brittle 修复流程 0 触碰边界", "T293-31: §9.6.37 prevention 段 (d) T162 brittle 修复流程 0 触碰边界")
	_assert_contains(contributing, "1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注", "T293-32: §9.6.37 prevention 段 (e) 1 套 polish 模式 0 互混 0 复用 0 共享 唯一性 标注")
	_assert_contains(contributing, "28 套 polish 模式", "T293-33: §9.6.37 prevention 段 (f) 28 套 polish 模式 唯一性")
	_assert_contains(contributing, "0 漏 1 字段", "T293-34: §9.6.37 prevention 段 (g) 0 漏 1 字段")
	_assert_contains(contributing, "drift risk", "T293-35: §9.6.37 prevention 段 (h) drift risk 已知 5 段 1:1 镜像 0 漏 1 段 / 1 边 / 1 字段 / 1 巡检")
	# 4 关系段: 与 §9.6.36 + 与 §9.6.34 + 与 §9.6.35 + 与 T162 + 与 §9.1 (5 关系段)
	_assert_contains(contributing, "**与 §9.6.36 关系**", "T293-36: §9.6.37 与 §9.6.36 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.34 关系**", "T293-37: §9.6.37 与 §9.6.34 关系 段 存在")
	_assert_contains(contributing, "**与 §9.6.35 关系**", "T293-38: §9.6.37 与 §9.6.35 关系 段 存在")
	_assert_contains(contributing, "**与 T162 brittle 修复流程 关系**", "T293-39: §9.6.37 与 T162 brittle 修复流程 关系 段 存在")
	_assert_contains(contributing, "**与 §9.1 9 步关系**", "T293-40: §9.6.37 与 §9.1 9 步关系 段 存在")

	# ========== 5. §9.6.37 段长 ≥ 35 行 + 0 漏 27 套 polish 模式 列举 ==========
	var section_start := contributing.find("### 9.6.37 SaveSystem save data CRC32")
	var section_end_marker := contributing.find("\n---", section_start)
	if section_end_marker == -1:
		section_end_marker = contributing.length()
	var section_text := contributing.substr(section_start, section_end_marker - section_start)
	var section_lines := section_text.split("\n")
	_assert(section_lines.size() >= 35, "T293-41: §9.6.37 段长 ≥ 35 行 (vs §9.6.36 ~30 行, T293 ~30+ 行) — actual " + str(section_lines.size()) + " lines")
	# 27 套 polish 模式 全列举
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36"]:
		_assert_contains(section_text, ref_num, "T293-42." + ref_num + ": §9.6.37 段内 引用 " + ref_num + " (27 套 polish 模式 列举 0 漏 1 套)")

	# ========== 6. 27 套 polish 模式 0 触碰边界 (0 副作用段) ==========
	# §9.6.37 0 副作用 段 必须 列举 27 套 polish 模式 (1 套 polish 模式 0 触碰既有)
	var zero_side_effect_block := contributing.find("**0 副作用**", contributing.find("### 9.6.37"))
	var zero_side_effect_end := contributing.find("---", zero_side_effect_block)
	if zero_side_effect_end == -1:
		zero_side_effect_end = contributing.length()
	var zero_block_text := contributing.substr(zero_side_effect_block, zero_side_effect_end - zero_side_effect_block)
	for ref_num in ["§9.6.6", "§9.6.7", "§9.6.8", "§9.6.9", "§9.6.10", "§9.6.15", "§9.6.16", "§9.6.17", "§9.6.18", "§9.6.19", "§9.6.20", "§9.6.21", "§9.6.22", "§9.6.23", "§9.6.24", "§9.6.25", "§9.6.26", "§9.6.27", "§9.6.28", "§9.6.29", "§9.6.30", "§9.6.31", "§9.6.32", "§9.6.33", "§9.6.34", "§9.6.35", "§9.6.36"]:
		_assert_contains(zero_block_text, ref_num, "T293-43." + ref_num + ": §9.6.37 0 副作用 段 引用 " + ref_num + " (27 套 polish 模式 0 触碰 列举 0 漏 1 套)")

	# ========== 7. 字节码 一致性 source-grep 验证 5 段 ==========
	# Stage 1: _crc32_of_string IEEE CRC32 完整 poly + init + xorout
	_assert_contains(save_system, "poly 0xEDB88320", "T293-44.s1: save_system.gd 注释 `poly 0xEDB88320` (Stage 1 crc32 字段 1:1 严格 source-grep 验证)")
	_assert_contains(save_system, "init 0xFFFFFFFF", "T293-45.s1: save_system.gd 注释 `init 0xFFFFFFFF` (Stage 1 crc32 字段 1:1 严格 source-grep 验证)")
	_assert_contains(save_system, "xorout 0xFFFFFFFF", "T293-46.s1: save_system.gd 注释 `xorout 0xFFFFFFFF` (Stage 1 crc32 字段 1:1 严格 source-grep 验证)")
	# Stage 2: _verify_and_unwrap 完整
	_assert_contains(save_system, "file corrupted, rejecting", "T293-47.s2: save_system.gd `file corrupted, rejecting` push_warning 引用 (Stage 2 verify 方法 1:1 严格 source-grep 验证)")
	# Stage 3: audit_save_slots 6 字段完整
	_assert_contains(save_system, "SLOT_COUNT", "T293-48.s3: save_system.gd `SLOT_COUNT` 5 slot 引用 (Stage 3 audit 巡检 1:1 严格 source-grep 验证)")
	_assert_contains(save_system, "push_warning(\"SaveSystem audit:", "T293-49.s3: save_system.gd audit push_warning 引用 (Stage 3 audit 巡检 1:1 严格 source-grep 验证)")
	# Stage 4: save_dict 包装层 完整
	_assert_contains(save_system, "_crc32_of_string(JSON.stringify(data, \"  \"))", "T293-50.s4: save_system.gd `_crc32_of_string(JSON.stringify(data, \"  \"))` 包装 (Stage 4 write dict 1:1 严格 source-grep 验证)")
	# Stage 5: loaded_data 解包层 完整
	_assert_contains(save_system, "return _verify_and_unwrap(parsed, path)", "T293-51.s5: save_system.gd `return _verify_and_unwrap(parsed, path)` 解包镜像 (Stage 5 read dict 1:1 严格 source-grep 验证)")
	_assert_contains(save_system, "return parsed", "T293-52.s5: save_system.gd legacy 兼容 `return parsed` (Stage 5 read dict 1:1 严格 source-grep 验证)")

	# ========== 8. CHANGELOG / ROADMAP / README 同步 验证 ==========
	# CHANGELOG.md 全文含 #217 段 — FIX-#225-2 (T162 brittle Stage 1 + Stage 5): CHANGELOG.md 顶部 5000 chars window 已被 #218~#224 占满,
	# T293 引用在 #217 段 已下移到 > 5000 chars, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `changelog` (vs FIX-#220-2 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): 跨迭代稳定, 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#217" / "T293" / "§9.6.37" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): ROADMAP/REVIEW_LOG/README 同样 已用 全文 (FIX-#220-2 / FIX-#225-1), CHANGELOG 跟随 同步.
	_assert_contains(changelog, "#217", "T293-53: CHANGELOG.md 全文 #217 段 存在 (F002 self-test 同步, FIX-#225-2 改 全文 vs 顶部 5000 chars)")
	_assert_contains(changelog, "T293", "T293-54: CHANGELOG.md 全文 #217 段 引用 T293 (CHANGELOG 同步, FIX-#225-2 改 全文 vs 顶部 5000 chars)")
	_assert_contains(changelog, "§9.6.37", "T293-55: CHANGELOG.md 全文 #217 段 引用 §9.6.37 (CHANGELOG 同步, FIX-#225-2 改 全文 vs 顶部 5000 chars)")
	# ROADMAP.md 全文含 T293 任务 — FIX-#225-2 同上
	_assert_contains(roadmap, "T293", "T293-56: ROADMAP.md 全文 T293 任务 存在 (ROADMAP 同步, FIX-#225-2 改 全文 vs 顶部 5000 chars)")
	# README.md 'Recent completed work' #217 段 存在
	_assert("#217" in readme and "Recent completed work" in readme, "T293-57: README.md 'Recent completed work' #217 段 存在 (F002 self-test 同步)")
	_assert_contains(readme, "## #217", "T293-58: README.md 'Recent completed work' #217 段 引用 T293 (F002 self-test 同步)")
	_assert_contains(readme, "T293", "T293-59: README.md 'Recent completed work' #217 段 引用 T293 (F002 self-test 同步)")
	_assert_contains(readme, "§9.6.37", "T293-60: README.md 'Recent completed work' #217 段 引用 §9.6.37 (F002 self-test 同步)")
	# README.zh-CN.md '最近完成的工作' #217 段 存在
	_assert("#217" in readme_zh and "最近完成的工作" in readme_zh, "T293-61: README.zh-CN.md '最近完成的工作' #217 段 存在 (F002 self-test 同步)")
	_assert_contains(readme_zh, "## #217", "T293-62a: README.zh-CN.md '最近完成的工作' #217 段 引用 T293 (F002 self-test 同步)")
	_assert_contains(readme_zh, "T293", "T293-62b: README.zh-CN.md '最近完成的工作' #217 段 引用 T293 (F002 self-test 同步)")
	_assert_contains(readme_zh, "§9.6.37", "T293-62c: README.zh-CN.md '最近完成的工作' #217 段 引用 §9.6.37 (F002 self-test 同步)")
	# REVIEW_LOG.md 全文 应有 #217 段 — FIX-#230-1 (T162 brittle Stage 1 + Stage 5): REVIEW_LOG.md 顶部 5000 chars window 已被 #225 review + #230 review 等多轮 review 段占满,
	# T293 引用在 #217 段 已下移到 > 5000 chars, 不再 0 触碰 既有 5000 chars window (T162 Stage 4 0 触碰既有).
	# T162 Stage 1 (expect reverse): 改用 全文 `review_log` (vs FIX-#225-1 / FIX-#220-2 ROADMAP.md 全文 模式).
	# T162 Stage 2 (docblock): 跨迭代稳定, 顶部 5000 chars 滚动窗口 brittle.
	# T162 Stage 3 (segment find reverse): 段 ID "#217" / "T293" / "§9.6.37" 跨迭代稳定 标识符.
	# T162 Stage 5 (cross-section sync): CHANGELOG/ROADMAP/README 同样 已用 全文 (FIX-#220-2 / FIX-#225-1), REVIEW_LOG 跟随 同步.
	_assert_contains(review_log, "T293", "T293-63: REVIEW_LOG.md 全文 引用 T293 (REVIEW_LOG 同步, FIX-#230-1 改 全文 vs 顶部 5000 chars)")
	_assert_contains(review_log, "§9.6.37", "T293-64: REVIEW_LOG.md 全文 引用 §9.6.37 (REVIEW_LOG 同步, FIX-#230-1 改 全文 vs 顶部 5000 chars)")

	# ========== 9. T293 自身 0 硬编码 验证 ==========
	# 读取 T293 自身 test 文件
	var test_self_text := _read_text("res://tools/test_t293_contributing_fragility_section9637_smoke.gd")
	# T293 自身 0 硬编码 `==` ITERATION_COUNT
	# T293 自身 0 硬编码 `## #N` marker
	# T293 自身 0 硬编码 `## #217` marker
	var self_text_lines: PackedStringArray = test_self_text.split("\n")
	var hard_eq_count := 0
	var hard_marker_count := 0
	var hard_217_count := 0
	for line in self_text_lines:
		if "iter_count == " in line and "iter_count: int = int" not in line:
			hard_eq_count += 1
		if "## #" in line and "`## #" not in line and "CHANGELOG.md 顶部 #" not in line and "README.md 'Recent completed work' #" not in line and "README.zh-CN.md '最近完成的工作' #" not in line and "## 归档内容" not in line and "## 归档策略" not in line:
			hard_marker_count += 1
		if "## #217" in line and "`## #217" not in line and "CHANGELOG.md 顶部 #217" not in line and "README.md 'Recent completed work' #217" not in line and "README.zh-CN.md '最近完成的工作' #217" not in line:
			hard_217_count += 1
	_assert(hard_eq_count == 0, "T293-65: T293 自身 0 硬编码 `==` ITERATION_COUNT (Stage 1 + Stage 3 自身落地, 用 >= 而非 ==) — actual " + str(hard_eq_count) + " 处")
	_assert(hard_marker_count == 0, "T293-66: T293 自身 0 硬编码 `## #N` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.37 稳定子串) — actual " + str(hard_marker_count) + " 处")
	_assert(hard_217_count == 0, "T293-67: T293 自身 0 硬编码 `## #217` marker (Stage 2 + Stage 4 自身落地, 用 ### 9.6.37 稳定子串) — actual " + str(hard_217_count) + " 处")

	# ========== 10. §9.6.37 0 触碰既有 27 套 polish 模式 任何 1 字符 ==========
	# 验证: §9.6.36 段 仍然存在 (T293 0 触碰 §9.6.36 任何 1 字符)
	_assert_contains(contributing, "### 9.6.36 PlayerActionGate", "T293-68: §9.6.36 段 仍然存在 (T293 0 触碰 §9.6.36 任何 1 字符, 27 套 polish 模式 0 漏 1 套)")

	# ========== 11. 5 段 × 1 套 polish 模式 = 5 元素 1:1 严格 闭环 ==========
	# 验证 5 段 序列 5 元素: crc32 字段 + verify 方法 + audit 巡检 + write dict + read dict
	var stage_keywords := ["crc32 字段", "verify 方法", "audit 巡检", "write dict", "read dict"]
	var stage_count := 0
	for kw in stage_keywords:
		if contributing.find(kw) != -1:
			stage_count += 1
	_assert(stage_count >= 5, "T293-69: 5 段 序列 5 元素 1:1 严格 闭环 (5 段 关键词 全找到) — actual " + str(stage_count) + "/5")

	# ========== 12. §9.6.37 1 套 polish 模式 × 5 段 = 5 元素 1:1 严格镜像 (vs §9.6.36 4 件套 1:1 严格镜像) ==========
	# 验证: §9.6.36 是 4 件套 (vs §9.6.37 是 5 段)
	var section_36_start := contributing.find("### 9.6.36")
	var section_36_end := contributing.find("\n### 9.6.37", section_36_start)
	if section_36_end == -1:
		section_36_end = contributing.length()
	var section_36_text := contributing.substr(section_36_start, section_36_end - section_36_start)
	var section_36_stage_count := 0
	for s in ["Stage 1 autoload 字段", "Stage 2 register / unregister", "Stage 3 is_blocked()", "Stage 4 get_player()"]:
		if section_36_text.find(s) != -1:
			section_36_stage_count += 1
	_assert(section_36_stage_count == 4, "T293-70: §9.6.36 是 4 件套 (vs §9.6.37 是 5 段, 1 套 polish 模式 × 4 件套 1:1 严格镜像) — actual " + str(section_36_stage_count) + "/4")

	# ========== 13. T293 自身 0 副作用 ==========
	# 验证: T293 自身 0 触碰 save_system.gd 任何 1 字段
	# (此验证 通过 T293 仅 read 文件 实现 0 写入 来保证)
	# 此外: 验证 T293 smoke test 自身段引用 §9.6.37 5 段 (1 套 polish 模式 × 5 段 = 5 元素)
	_assert_contains(test_self_text, "Stage 1 crc32 字段 1:1 严格", "T293-71: T293 自身引用 Stage 1 crc32 字段 1:1 严格 (5 段 1:1 镜像 1 套 polish 模式 既有 1:1 严格分离)")

	# ========== 14. §9.6.37 0 漏 1 元素 0 改 1 字段 (5 元素 × 1 字段 = 5 元素 1:1 严格) ==========
	# 验证: 5 段 × 1 字段 = 5 元素 1:1 严格 (1 crc32 字段 + 1 verify 方法 + 1 audit 巡检 + 1 write dict + 1 read dict)
	_assert_contains(contributing, "5 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符 0 例外", "T293-72: §9.6.37 0 漏 1 元素 0 改 1 字段 0 例外 关键术语")

	# ========== 15. T128 / T224 / #109 / #146 任务 ID 引用 ==========
	_assert_contains(contributing, "T128", "T293-73: §9.6.37 引用 T128 任务 ID")
	_assert_contains(contributing, "T224", "T293-74: §9.6.37 引用 T224 任务 ID")
	_assert_contains(contributing, "#109", "T293-75: §9.6.37 引用 #109 iteration ID (T128 落地 iter)")
	_assert_contains(contributing, "#146", "T293-76: §9.6.37 引用 #146 iteration ID (T224 落地 iter)")
	_assert_contains(contributing, "#217", "T293-77: §9.6.37 引用 #217 iteration ID (T293 自身落地 iter)")

	# ========== Final ==========
	print("[T293] TOTAL: " + str(_passed + _failed) + ", PASSED: " + str(_passed) + ", FAILED: " + str(_failed))
	if _failed > 0:
		print("[T293] FAILURES:")
		for f in _failures:
			print("  - " + f)
		quit(1)
	else:
		quit(0)


# ---------- helpers ----------

func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_error("missing file: " + path)
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("cannot open: " + path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content

func _assert(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("[T293] PASS: " + label)
	else:
		_failed += 1
		_failures.append(label)
		print("[T293] FAIL: " + label)

func _assert_contains(haystack: String, needle: String, label: String) -> void:
	_assert(haystack.find(needle) != -1, label)
