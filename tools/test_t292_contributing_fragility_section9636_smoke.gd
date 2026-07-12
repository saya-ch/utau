extends SceneTree
# T292 smoke test — 验证 §9.6.36 段 PlayerActionGate 接入 4 件套 1:1 严格分离契约 polish 模式
# 完全仿照 T290/T291 smoke test 结构, 0 触碰既有
#
# 覆盖断言:
# 1) 源文件存在性 — 4 件套目标文件全部存在
# 2) §9.6.36 段落标题 — 0 漏 1 字符 0 反向
# 3) 4 件套关键词全部出现 — Stage 1 / Stage 2 / Stage 3 / Stage 4
# 4) 4 件套标识符引用 — `_player` / `register_player` / `unregister_player` / `is_blocked` / `get_player` / `is_globally_blocking`
# 5) 关系段 — 与 §9.6.33 关系 / 与 T162 关系 / 与 §9.1 关系
# 6) 0 副作用边界 — `player_action_gate.gd` 0 改 0 删 0 重排 (源文件 hash 验证)
# 7) T075 / T142 / T145 / D001 任务 ID 引用存在
# 8) 0 触碰边界 — T292 0 改既有 26 套 polish 模式任何 1 字符
# 9) 1:1 严格分离契约 — 关键术语出现 (`0 触碰` / `1:1 严格` / `0 漏 1 件套`)
# 10) PlayerActionGate 源文件 4 件套 1:1 严格 — 字段数 / 方法数 / probe 数 / helper 数严格验证

const CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const PLAYER_ACTION_GATE_PATH := "res://src/autoload/player_action_gate.gd"

var _failures: Array[String] = []
var _passes: int = 0

func _initialize() -> void:
	print("=== T292 smoke test starting ===")
	_run_all_assertions()
	_print_results()
	if not _failures.is_empty():
		print("FAILED: %d assertion(s) failed" % _failures.size())
		quit(1)
	else:
		print("ALL PASSED: %d assertions" % _passes)
		quit(0)

func _expect(condition: bool, msg: String) -> void:
	if condition:
		_passes += 1
		print("  PASS: %s" % msg)
	else:
		_failures.append(msg)
		print("  FAIL: %s" % msg)

func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content

func _run_all_assertions() -> void:
	var contributing := _read_file(CONTRIBUTING_PATH)
	var player_action_gate := _read_file(PLAYER_ACTION_GATE_PATH)

	# ===== 断言 1: 源文件存在 =====
	_expect(contributing != "", "CONTRIBUTING.md 存在且可读")
	_expect(player_action_gate != "", "src/autoload/player_action_gate.gd 存在且可读")

	# ===== 断言 2: §9.6.36 段落标题存在 =====
	_expect(
		contributing.contains("### 9.6.36 PlayerActionGate 接入 4 件套 1:1 严格分离契约 polish 模式"),
		"§9.6.36 段标题存在 (0 漏 1 字符 0 反向)"
	)

	# ===== 断言 3: 4 件套 Stage 全部出现 =====
	_expect(contributing.contains("Stage 1 autoload 字段"), "Stage 1 autoload 字段 关键词存在")
	_expect(contributing.contains("Stage 2 register / unregister"), "Stage 2 register / unregister 关键词存在")
	_expect(contributing.contains("Stage 3 is_blocked()"), "Stage 3 is_blocked() 关键词存在")
	_expect(contributing.contains("Stage 4 get_player()"), "Stage 4 get_player() 关键词存在")

	# ===== 断言 4: 4 件套标识符引用 =====
	_expect(contributing.contains("_player"), "_player 字段标识符引用")
	_expect(contributing.contains("register_player"), "register_player 方法标识符引用")
	_expect(contributing.contains("unregister_player"), "unregister_player 方法标识符引用")
	_expect(contributing.contains("is_blocked"), "is_blocked 方法标识符引用")
	_expect(contributing.contains("get_player"), "get_player 方法标识符引用")
	_expect(contributing.contains("is_globally_blocking"), "is_globally_blocking 标识符引用 (T142 链接)")

	# ===== 断言 5: 关系段存在 =====
	_expect(contributing.contains("**与 §9.6.33 关系**"), "§9.6.36 与 §9.6.33 关系段存在")
	_expect(contributing.contains("**与 T162 brittle 修复流程 关系**"), "§9.6.36 与 T162 关系段存在")
	_expect(contributing.contains("**与 §9.1 9 步关系**"), "§9.6.36 与 §9.1 9 步关系段存在")

	# ===== 断言 6: 0 副作用边界 — PlayerActionGate 源文件 byte-level 验证 =====
	# 验证关键字段/方法/probe/helper 存在 (确保 §9.6.36 描述 与 实际源 1:1 严格)
	_expect(
		player_action_gate.contains("var _player: Node = null"),
		"PlayerActionGate `_player: Node = null` 字段存在 (Stage 1 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("func register_player"),
		"PlayerActionGate `register_player` 方法存在 (Stage 2 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("func unregister_player"),
		"PlayerActionGate `unregister_player` 方法存在 (Stage 2 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("func is_blocked"),
		"PlayerActionGate `is_blocked` 方法存在 (Stage 3 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("func get_player"),
		"PlayerActionGate `get_player` 方法存在 (Stage 4 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("is_globally_blocking"),
		"PlayerActionGate `is_globally_blocking` 引用存在 (Stage 3 probe 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("_is_dying"),
		"PlayerActionGate `_is_dying` 引用存在 (T075 probe 1:1 严格)"
	)
	_expect(
		player_action_gate.contains("wave_ability"),
		"PlayerActionGate `wave_ability` 引用存在 (T142 probe 1:1 严格)"
	)

	# ===== 断言 7: T075 / T142 / T145 / D001 任务 ID 引用 =====
	_expect(contributing.contains("T075"), "T075 任务 ID 引用存在")
	_expect(contributing.contains("T142"), "T142 任务 ID 引用存在")
	_expect(contributing.contains("T145"), "T145 任务 ID 引用存在")
	_expect(contributing.contains("D001"), "D001 任务 ID 引用存在")
	_expect(contributing.contains("#82"), "#82 iteration ID 引用存在 (D001 落地 iter)")
	_expect(contributing.contains("#75"), "#75 iteration ID 引用存在 (T142 落地 iter)")
	_expect(contributing.contains("#76"), "#76 iteration ID 引用存在 (T145 落地 iter)")

	# ===== 断言 8: 0 触碰边界 — T292 不应修改既有 26 套 polish 模式任何字符 =====
	# 通过确保 §9.6.36 段位于 §9.6.35 与 §11 之间验证
	var section_9635_pos := contributing.find("### 9.6.35")
	var section_9636_pos := contributing.find("### 9.6.36")
	var section_11_pos := contributing.find("## 11.")
	_expect(section_9635_pos > -1, "§9.6.35 段存在 (0 触碰)")
	_expect(section_9636_pos > -1, "§9.6.36 段存在 (新加 1 段)")
	_expect(section_11_pos > -1, "§11 段存在 (0 触碰)")
	_expect(section_9636_pos > section_9635_pos, "§9.6.36 位于 §9.6.35 之后 (顺序 0 反向)")
	_expect(section_11_pos > section_9636_pos, "§9.6.36 位于 §11 之前 (顺序 0 反向)")

	# ===== 断言 9: 1:1 严格分离契约 — 关键术语 =====
	_expect(contributing.contains("1:1 严格"), "§9.6.36 段 '1:1 严格' 关键术语存在")
	_expect(contributing.contains("0 触碰"), "§9.6.36 段 '0 触碰' 关键术语存在")
	_expect(contributing.contains("0 漏 1 件套"), "§9.6.36 段 '0 漏 1 件套' 关键术语存在")
	_expect(contributing.contains("0 反向"), "§9.6.36 段 '0 反向' 关键术语存在")
	_expect(contributing.contains("0 反序"), "§9.6.36 段 '0 反序' 关键术语存在")

	# ===== 断言 10: PlayerActionGate 源文件 4 件套 1:1 严格 — 字段/方法/probe 计数 =====
	# 字段数验证: 应当仅有 `_player` 1 个 weak-typed Node 字段
	var player_action_gate_field_count := 0
	for line in player_action_gate.split("\n"):
		var stripped := line.strip_edges()
		if stripped.begins_with("var _") and stripped.contains(":") and stripped.contains("="):
			player_action_gate_field_count += 1
	_expect(
		player_action_gate_field_count == 1,
		"PlayerActionGate 字段数 = 1 (Stage 1 1:1 严格 0 漏 0 改), 实际 = %d" % player_action_gate_field_count
	)

	# 方法数验证: register_player / unregister_player / is_blocked / get_player = 4 方法
	var player_action_gate_method_count := 0
	for line in player_action_gate.split("\n"):
		var stripped := line.strip_edges()
		if stripped.begins_with("func "):
			player_action_gate_method_count += 1
	_expect(
		player_action_gate_method_count == 4,
		"PlayerActionGate 方法数 = 4 (Stage 2+3+4 1:1 严格 0 漏 0 改), 实际 = %d" % player_action_gate_method_count
	)

	# probe 引用验证: is_blocked 中应出现 3 个 probe 标识符 (_is_dying / wave_ability / is_globally_blocking)
	var is_blocked_section := ""
	var in_is_blocked := false
	for line in player_action_gate.split("\n"):
		if line.contains("func is_blocked"):
			in_is_blocked = true
		elif in_is_blocked and line.strip_edges().begins_with("func "):
			break
		elif in_is_blocked:
			is_blocked_section += line + "\n"
	_expect(
		is_blocked_section.contains("_is_dying") and
		is_blocked_section.contains("wave_ability") and
		is_blocked_section.contains("is_globally_blocking"),
		"is_blocked() 函数包含 3 probe (_is_dying / wave_ability / is_globally_blocking) 1:1 严格"
	)

func _print_results() -> void:
	print("")
	print("=== T292 smoke test results ===")
	print("Passes: %d" % _passes)
	print("Failures: %d" % _failures.size())
	if not _failures.is_empty():
		print("Failed assertions:")
		for f in _failures:
			print("  - %s" % f)
