extends SceneTree
## I035 (#128) — T209 PlayerProfilePanel 顶级行 "最长单房" 冒烟测试
##
## 覆盖 #128 主任务 T209。 验证 LongestRoom 跨层 wiring：
##   (1) game_state.gd 加 3 字段 + 2 API（record_room_enter/exit）
##       + 2 accessor（get_longest_room_seconds/id）
##       + reset_run() 重置 3 字段
##   (2) room_controller.gd._ready() 调 record_room_enter
##       _check_completion() 间接（经 _complete_room）调 record_room_exit
##   (3) player_stats.gd._best_stats 加 longest_room_seconds
##       _capture_run_into_history snapshot 加 longest_room_seconds
##       _update_best_stats_from_current_run 单调更新
##       get_best_stats() 注释含 longest_room_seconds
##   (4) pause_menu.tscn 加 ProfileLongestRoom Label（在 ProfileBestStreak
##       下、HSep1 上，与 AvgResonance/BestStreak 顶级行风格一致）
##   (5) pause_menu.gd 加 _profile_longest_room @onready
##       _refresh_top_aggregate_rows 在 3 个 early-return 路径都 set
##       text = "★ 最长单房 —  ★"，n>0 路径 set "★ 最长单房 mm:ss ★"
##       mm:ss 格式（_profile_best_streak 同款），并用 get_best_stats 拿数据
##
## 三类断言:
##
## === T209.GS — game_state.gd per-room timing API ===
## - T209.GS.3_FIELDS: _room_enter_time / _longest_room_seconds_this_run /
##                     _longest_room_id_this_run 3 字段
## - T209.GS.RESET_RESET: reset_run() 重置 3 字段
## - T209.GS.RECORD_ENTER: record_room_enter(room_id) 写 _room_enter_time
## - T209.GS.RECORD_EXIT: record_room_exit(room_id) 更新 max + id
## - T209.GS.ENTER_GUARD: _room_enter_time < 0 时 record_room_exit 早退
## - T209.GS.GET_SEC: get_longest_room_seconds() 公开 accessor
## - T209.GS.GET_ID: get_longest_room_id() 公开 accessor
## - T209.GS.CURRENT_ROOM: record_room_enter 也写 current_room (invariant)
## - T209.GS.ANCHOR: 注释含 T209 锚点 (可读性)
##
## === T209.RC — room_controller.gd 钩入 record_room_enter/exit ===
## - T209.RC.ENTER_CALL: _ready() 调 record_room_enter(room_id)
## - T209.RC.EXIT_CALL: _complete_room() 调 record_room_exit(room_id)
## - T209.RC.ORDER: mark_room_completed 在 record_room_exit 之前
##                  (语义顺序: 完成 → 计时)
## - T209.RC.ANCHOR: 注释含 T209 锚点
##
## === T209.PS — player_stats.gd longest_room_seconds 持久化 ===
## - T209.PS.DICT_KEY: _best_stats dict 含 "longest_room_seconds"
## - T209.PS.UPDATE: _update_best_stats_from_current_run 调
##                   GameState.get_longest_room_seconds() 并 > 比较
## - T209.PS.SNAPSHOT: _capture_run_into_history snapshot 含
##                     "longest_room_seconds" 字段
## - T209.PS.GET_BEST_COMMENT: get_best_stats() 注释含 longest_room_seconds
## - T209.PS.LOADER_SAFE: _load_best_stats 用 for key in _best_stats.keys()
##                        循环, 老存档 (无 longest_room_seconds) 仍安全
##
## === T209.UI — pause_menu.tscn + pause_menu.gd 顶级行 ===
## - T209.UI.TSCN: pause_menu.tscn 含 [node name="ProfileLongestRoom"
## - T209.UI.POS: ProfileLongestRoom 在 ProfileBestStreak 之后、HSep1 之前
## - T209.UI.GD_VAR: pause_menu.gd 含 _profile_longest_room @onready
## - T209.UI.REFRESH: _refresh_top_aggregate_rows 含 "★ 最长单房"
## - T209.UI.EMPTY: 3 个 early-return 路径都 set "★ 最长单房 —  ★"
## - T209.UI.FORMAT: n>0 路径用 %02d:%02d mm:ss 格式 (mm:ss)
## - T209.UI.DATA_SRC: get_best_stats() 被调, 注释说明 _best_stats 来源
## - T209.UI.ANCHOR: 注释含 T209 (#128) 锚点

const GAME_STATE_GD := "res://src/autoload/game_state.gd"
const ROOM_CONTROLLER_GD := "res://src/scripts/room_controller.gd"
const PLAYER_STATS_GD := "res://src/autoload/player_stats.gd"
const PAUSE_MENU_TSCN := "res://src/scenes/pause_menu.tscn"
const PAUSE_MENU_GD := "res://src/scripts/pause_menu.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I035 (#128) — T209 PlayerProfilePanel LongestRoom 冒烟测试 ===")
	_run_t209_gs_assertions()
	_run_t209_rc_assertions()
	_run_t209_ps_assertions()
	_run_t209_ui_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I035 (#128) T209 ASSERTIONS PASSED ===")
		quit(0)


# ---------- T209.GS — game_state.gd per-room timing API ----------
func _run_t209_gs_assertions() -> void:
	print("--- T209.GS — game_state.gd per-room timing API ---")
	var src := _read_file(GAME_STATE_GD)

	# 3 字段 — autoload 新加 per-room timing 状态
	_assert_contains(src, "var _room_enter_time: float = -1.0",
		"T209.GS.3_FIELDS.1: _room_enter_time: float = -1.0 (T209 新增)")
	_assert_contains(src, "var _longest_room_seconds_this_run: float = 0.0",
		"T209.GS.3_FIELDS.2: _longest_room_seconds_this_run: float = 0.0")
	_assert_contains(src, "var _longest_room_id_this_run: String = \"\"",
		"T209.GS.3_FIELDS.3: _longest_room_id_this_run: String = \"\"")

	# reset_run() 重置 3 字段 — 新一 run 清零, 不污染历史
	_assert_contains(src, "\t_room_enter_time = -1.0",
		"T209.GS.RESET_RESET.1: reset_run() 重置 _room_enter_time = -1.0")
	_assert_contains(src, "\t_longest_room_seconds_this_run = 0.0",
		"T209.GS.RESET_RESET.2: reset_run() 重置 _longest_room_seconds_this_run = 0.0")
	_assert_contains(src, "\t_longest_room_id_this_run = \"\"",
		"T209.GS.RESET_RESET.3: reset_run() 重置 _longest_room_id_this_run = \"\"")

	# record_room_enter API
	_assert_contains(src, "func record_room_enter(room_id: String) -> void:",
		"T209.GS.RECORD_ENTER.1: record_room_enter(room_id) API 存在")
	_assert_contains(src, "\t_room_enter_time = Time.get_ticks_msec() / 1000.0",
		"T209.GS.RECORD_ENTER.2: record_room_enter 写 _room_enter_time (sec)")
	# current_room 同步 (invariant)
	_assert_contains(src, "\tcurrent_room = room_id",
		"T209.GS.CURRENT_ROOM.1: record_room_enter 同步写 current_room (invariant)")

	# record_room_exit API
	_assert_contains(src, "func record_room_exit(room_id: String) -> void:",
		"T209.GS.RECORD_EXIT.1: record_room_exit(room_id) API 存在")
	_assert_contains(src, "if _room_enter_time < 0.0:",
		"T209.GS.ENTER_GUARD.1: _room_enter_time < 0 早退 (headless 测试防护)")
	_assert_contains(src, "if duration > _longest_room_seconds_this_run:",
		"T209.GS.RECORD_EXIT.2: duration > current max 才更新 (单调)")
	_assert_contains(src, "\t\t_longest_room_seconds_this_run = duration",
		"T209.GS.RECORD_EXIT.3: 更新 _longest_room_seconds_this_run")
	_assert_contains(src, "\t\t_longest_room_id_this_run = room_id",
		"T209.GS.RECORD_EXIT.4: 更新 _longest_room_id_this_run")

	# 2 accessor
	_assert_contains(src, "func get_longest_room_seconds() -> float:",
		"T209.GS.GET_SEC.1: get_longest_room_seconds() 公开 accessor")
	_assert_contains(src, "func get_longest_room_id() -> String:",
		"T209.GS.GET_ID.1: get_longest_room_id() 公开 accessor")
	_assert_contains(src, "\treturn _longest_room_seconds_this_run",
		"T209.GS.GET_SEC.2: get_longest_room_seconds 返回 _longest_room_seconds_this_run")
	_assert_contains(src, "\treturn _longest_room_id_this_run",
		"T209.GS.GET_ID.2: get_longest_room_id 返回 _longest_room_id_this_run")

	# 注释锚点
	_assert_contains(src, "T209",
		"T209.GS.ANCHOR.1: 注释含 T209 锚点 (可读性)")


# ---------- T209.RC — room_controller.gd 钩入 record_room_enter/exit ----------
func _run_t209_rc_assertions() -> void:
	print("--- T209.RC — room_controller.gd 钩入 record_room_enter/exit ---")
	var src := _read_file(ROOM_CONTROLLER_GD)

	# _ready() 调 record_room_enter
	_assert_contains(src, "GameState.record_room_enter(room_id)",
		"T209.RC.ENTER_CALL.1: _ready() 调 record_room_enter(room_id) (T209 新增)")
	_assert_contains(src, "GameState.current_room = room_id\n\t# T209",
		"T209.RC.ENTER_ORDER.1: current_room = room_id 在 record_room_enter 之前 (原行保留)")

	# _complete_room() 调 record_room_exit
	_assert_contains(src, "GameState.record_room_exit(room_id)",
		"T209.RC.EXIT_CALL.1: _complete_room() 调 record_room_exit(room_id)")

	# 顺序: mark_room_completed 在 record_room_exit 之前
	# (标记完成 → 计时 → 加分 → 统计)
	_assert_contains(src, "GameState.mark_room_completed(room_id)\n\t# T209",
		"T209.RC.ORDER.1: mark_room_completed 早于 record_room_exit (语义顺序)")

	# 注释锚点
	_assert_contains(src, "T209",
		"T209.RC.ANCHOR.1: 注释含 T209 锚点")


# ---------- T209.PS — player_stats.gd longest_room_seconds 持久化 ----------
func _run_t209_ps_assertions() -> void:
	print("--- T209.PS — player_stats.gd longest_room_seconds 持久化 ---")
	var src := _read_file(PLAYER_STATS_GD)

	# _best_stats dict 加 key
	_assert_contains(src, "\"longest_room_seconds\": 0.0",
		"T209.PS.DICT_KEY.1: _best_stats dict 含 \"longest_room_seconds\": 0.0")

	# _update_best_stats_from_current_run 调 accessor
	# F018.1 (#130) — 原 needle 静态引用 `GameState.get_longest_room_seconds()` 在
	# SceneTree 模式 (smoke test --script 启动) 抛 parse error. 修复后改用
	# 内部辅助 _read_longest_room_from_gamestate() 动态查 autoload.
	_assert_contains(src, "_read_longest_room_from_gamestate()",
		"T209.PS.UPDATE.1: _update_best_stats_from_current_run 调 get_longest_room_seconds (F018.1 #130 改用动态辅助)")
	_assert_contains(src, "if longest_room > float(_best_stats.get(\"longest_room_seconds\", 0.0)):",
		"T209.PS.UPDATE.2: 单调更新 (longest_room > best)")
	_assert_contains(src, "\t\t_best_stats[\"longest_room_seconds\"] = longest_room",
		"T209.PS.UPDATE.3: 写入 _best_stats[\"longest_room_seconds\"]")

	# _capture_run_into_history snapshot 加 key
	# F018.1 (#130) — 同步改用动态辅助
	_assert_contains(src, "\"longest_room_seconds\": _read_longest_room_from_gamestate()",
		"T209.PS.SNAPSHOT.1: snapshot 含 longest_room_seconds (T209 新增, F018.1 改用动态辅助)")

	# get_best_stats() 注释含字段说明
	_assert_contains(src, "longest_room_seconds",
		"T209.PS.GET_BEST_COMMENT.1: get_best_stats() 注释含 longest_room_seconds 字段说明")

	# _load_best_stats 老存档兼容 (现有循环已安全, 文档化即可)
	_assert_contains(src, "for key in _best_stats.keys():",
		"T209.PS.LOADER_SAFE.1: _load_best_stats 用 for key in _best_stats.keys() 循环 (老存档兼容)")


# ---------- T209.UI — pause_menu.tscn + pause_menu.gd 顶级行 ----------
func _run_t209_ui_assertions() -> void:
	print("--- T209.UI — pause_menu.tscn + pause_menu.gd 顶级行 ---")
	var tscn := _read_file(PAUSE_MENU_TSCN)
	var gd := _read_file(PAUSE_MENU_GD)

	# pause_menu.tscn: ProfileLongestRoom Label
	_assert_contains(tscn, "[node name=\"ProfileLongestRoom\" type=\"Label\"",
		"T209.UI.TSCN.1: pause_menu.tscn 含 [node name=\"ProfileLongestRoom\" type=\"Label\"")

	# ProfileLongestRoom 在 ProfileBestStreak 之后、HSep1 之前
	# 用 substring offset 排序检查
	var idx_best_streak := tscn.find("[node name=\"ProfileBestStreak\"")
	var idx_longest_room := tscn.find("[node name=\"ProfileLongestRoom\"")
	var idx_hsep1 := tscn.find("[node name=\"HSep1\"")
	if idx_best_streak == -1 or idx_longest_room == -1 or idx_hsep1 == -1:
		_failures.append("FAIL: T209.UI.POS.1: 找不到 ProfileBestStreak/ProfileLongestRoom/HSep1 (idx %d/%d/%d)" % [idx_best_streak, idx_longest_room, idx_hsep1])
	elif idx_best_streak < idx_longest_room and idx_longest_room < idx_hsep1:
		_passes += 1
		print("  OK  T209.UI.POS.1: ProfileLongestRoom 在 ProfileBestStreak 后、HSep1 前 (idx %d < %d < %d)" % [idx_best_streak, idx_longest_room, idx_hsep1])
	else:
		_failures.append("FAIL: T209.UI.POS.1: ProfileLongestRoom 位置错 (idx %d < %d < %d 不成立)" % [idx_best_streak, idx_longest_room, idx_hsep1])

	# pause_menu.gd: @onready var _profile_longest_room
	_assert_contains(gd, "@onready var _profile_longest_room: Label = $PlayerProfilePanel/ProfileMargin/ProfileVBox/ProfileLongestRoom",
		"T209.UI.GD_VAR.1: @onready var _profile_longest_room (T209 新增)")

	# _refresh_top_aggregate_rows 写 "★ 最长单房"
	_assert_contains(gd, "★ 最长单房",
		"T209.UI.REFRESH.1: _refresh_top_aggregate_rows 写 '★ 最长单房'")

	# 3 个 early-return 路径都 set "★ 最长单房 —  ★"
	# 计数: "★ 最长单房 —  ★" 至少出现 3 次
	var empty_count := gd.count("★ 最长单房 —  ★")
	if empty_count >= 3:
		_passes += 1
		print("  OK  T209.UI.EMPTY.1: 3 个 early-return 路径都 set '★ 最长单房 —  ★' (count=%d)" % empty_count)
	else:
		_failures.append("FAIL: T209.UI.EMPTY.1: '★ 最长单房 —  ★' count=%d, 期望 >= 3" % empty_count)

	# mm:ss 格式 (%02d:%02d)
	_assert_contains(gd, "\"★ 最长单房 %02d:%02d ★\"",
		"T209.UI.FORMAT.1: n>0 路径用 %02d:%02d mm:ss 格式 (与 BestStreak 同款)")

	# 数据源: get_best_stats
	_assert_contains(gd, "PlayerStats.get_best_stats()",
		"T209.UI.DATA_SRC.1: 数据源 get_best_stats()")
	_assert_contains(gd, "longest_room_seconds",
		"T209.UI.DATA_SRC.2: 读 _best_stats[\"longest_room_seconds\"]")

	# 注释锚点
	_assert_contains(gd, "T209",
		"T209.UI.ANCHOR.1: 注释含 T209 锚点")


# ===================== utilities =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_failures.append("FAIL: cannot open %s" % path)
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(src: String, needle: String, msg: String) -> void:
	if src.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % msg)
	else:
		_failures.append("FAIL: %s (needle=%s)" % [msg, needle])


func _print_summary() -> void:
	print("---")
	print("I035 (#128) T209 smoke summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
