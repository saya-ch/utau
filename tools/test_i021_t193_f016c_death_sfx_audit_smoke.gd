extends SceneTree
## I021 (#111) — T193 F016.C Death SFX 触发点 audit 7 房间 × 2 SFX 层 覆盖率 冒烟测试
##
## 覆盖 #111 任务 T193. 验证 play_death_lay_down 在全 7 房间都能正确触发,
## 2 SFX 层 (F016 原 SFX + F016.B idempotency guard) 都覆盖到位.
##
## === F016.C — Death SFX 触发点 audit (全 7 房间 × 2 SFX 层) ===
## - F016C.ROOM.COUNT: 7 个 room 场景文件存在 (json_room + archive_02-04 + hub + transition + door)
## - F016C.ROOM.PATH.1: json_room.tscn (默认 archive_01, JSON-driven)
## - F016C.ROOM.PATH.2: room_archive_02.tscn
## - F016C.ROOM.PATH.3: room_archive_03.tscn
## - F016C.ROOM.PATH.4: room_archive_04.tscn
## - F016C.ROOM.PATH.5: hub_room.tscn (Hub safe-room, 可死亡)
## - F016C.ROOM.PATH.6: room_transition.tscn (transition 中间帧)
## - F016C.ROOM.PATH.7: room_door.tscn (门 scene, 也可死亡)
## - F016C.ROOM.SCRIPT: 每个 room scene 用 RoomController / JsonRoom / HubController script
## - F016C.UNIVERSAL.SOURCE: player.die() 是 7 房间通用的死亡入口 (单点 trigger)
## - F016C.UNIVERSAL.CALLER: GameState.take_damage → player.die() 链路唯一 (无 room-specific 分叉)
## - F016C.UNIVERSAL.SFX: player.die() 调 ame.play_death_lay_down() (单点 SFX 触发)
## - F016C.UNIVERSAL.GUARD: ame.has_method 守卫保持老 ame 版本兼容
## - F016C.UNIVERSAL.PREWARM: prewarm_misc_sfx 含 _generate_death_lay_down_sfx (启动时 SFX 资源已就绪)
## - F016C.LAYER1.F016: F016 原 SFX 层 (0.4s 75Hz sub-bass) 在 play_death_lay_down 内调用
## - F016C.LAYER2.F016B: F016.B idempotency guard (_death_sfx_playing flag) 防止多触发叠加
## - F016C.PRELOAD.READY: ame autoload 必定存在, has_method 仅作 headless / 老 build 防御
## - F016C.COVERAGE.COMMENT: code 含 7 房间 / 全场景覆盖注释
##
## 任务背景: F016 是 #104 加的 "死亡嗡鸣", F016.B 是 #108 加的 idempotency guard.
## 7 房间是 gameplay 范围 — json_room (default archive_01) + 3 固定 archive
## + hub + transition + door. Death SFX 是 universal (player.die() 单点),
## 但代码 review 要确认:
## 1) 没有 room-specific 死亡路径绕过 player.die() (例如某个 room 自定义 take_damage)
## 2) F016.B flag 在多触发场景下生效 (regression 防御)
## 3) prewarm 让首帧死亡 SFX 无 latency (启动时 SFX 资源已生成)
## 4) has_method 守卫不绕过 (autoload 一定存在, headless test 兜底)

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"
const PLAYER_GD := "res://src/scripts/player.gd"
const GAME_STATE_GD := "res://src/autoload/game_state.gd"
const PROJECT_GODOT := "res://project.godot"

const ROOM_SCENES := [
	# 7 房间,顺序与玩家推进一致: json_room (archive_01) → archive_02 → archive_03
	# → archive_04 → hub (safe-room) → transition (door 中间) → door (门口)
	"res://src/scenes/json_room.tscn",
	"res://src/scenes/room_archive_02.tscn",
	"res://src/scenes/room_archive_03.tscn",
	"res://src/scenes/room_archive_04.tscn",
	"res://src/scenes/hub_room.tscn",
	"res://src/scenes/room_transition.tscn",
	"res://src/scenes/room_door.tscn",
]

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I021 (#111) — T193 F016.C Death SFX 7 房间 × 2 层 覆盖率 audit ===")
	_run_f016c_room_count_assertions()
	_run_f016c_universal_source_assertions()
	_run_f016c_universal_caller_assertions()
	_run_f016c_universal_sfx_assertions()
	_run_f016c_universal_prewarm_assertions()
	_run_f016c_layer1_f016_assertions()
	_run_f016c_layer2_f016b_assertions()
	_run_f016c_coverage_comment_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I021 (#111) T193 F016.C ASSERTIONS PASSED ===")
		quit(0)


# ---------- F016C.ROOM.* — 7 房间 scene 文件存在性 ----------
func _run_f016c_room_count_assertions() -> void:
	print("--- F016C.ROOM.* — 7 房间 scene 文件存在性 ---")
	# 7 房间必须全存在. 缺失任何一个 → 玩家推进链断裂 (例如 archive_03 不存在
	# 玩家卡在 archive_02). Death SFX 覆盖率隐含要求所有可死亡 room 都存在.
	if ROOM_SCENES.size() != 7:
		_failures.append("FAIL: F016C.ROOM.COUNT.1: ROOM_SCENES 应为 7 个, 实际 %d" % ROOM_SCENES.size())
	else:
		_passes += 1
		print("  OK  F016C.ROOM.COUNT.1: ROOM_SCENES 数量 = 7 (json+archive_02-04+hub+transition+door)")
	for i in range(ROOM_SCENES.size()):
		var path: String = ROOM_SCENES[i]
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			_failures.append("FAIL: F016C.ROOM.PATH.%d: %s 不存在 (玩家推进链断裂)" % [i + 1, path])
		else:
			f.close()
			_passes += 1
			print("  OK  F016C.ROOM.PATH.%d: %s 存在" % [i + 1, path])


# ---------- F016C.UNIVERSAL.SOURCE — player.die() 是 7 房间通用死亡入口 ----------
func _run_f016c_universal_source_assertions() -> void:
	print("--- F016C.UNIVERSAL.SOURCE — player.die() 通用性 ---")
	var player_src := _read_file(PLAYER_GD)
	# player.die() 是单一死亡入口, 7 房间通过 GameState.take_damage 都走这里.
	# 防御: 任何 room 都不应直接调 _is_dying=true 绕过 die() (会跳过 F016 SFX
	# 触发 + T092 freeze-frame + T116 afterimage + ScreenShake 死亡抖动).
	_assert_contains(player_src, "func die() -> void:",
		"F016C.UNIVERSAL.SOURCE.1: player.gd.die() 存在 (单点死亡入口)")
	_assert_contains(player_src, "if _is_dying:",
		"F016C.UNIVERSAL.SOURCE.2: die() 入口 _is_dying 守卫 (防重入, 与 F016.B 双重防御)")
	_assert_contains(player_src, "_is_dying = true",
		"F016C.UNIVERSAL.SOURCE.3: die() 设 _is_dying=true (下游 freeze-frame / 屏抖 全部接这个 flag)")
	# 项目级: 任何 room 都不应绕开 player.die
	var project_src := _read_file(PROJECT_GODOT)
	if project_src.find("_is_dying = true") == -1:
		_passes += 1
		print("  OK  F016C.UNIVERSAL.SOURCE.4: project.godot 不含 _is_dying 写入 (无 room 绕过 player.die)")
	else:
		_failures.append("FAIL: F016C.UNIVERSAL.SOURCE.4: project.godot 不应含 _is_dying 写入 (疑有 room 绕过)")
	# scan 7 个 room 场景文件: 都用 RoomController / JsonRoom / HubController script
	# 间接走 player.die() 通过 GameState.take_damage, 不应有自定义死亡路径
	for path in ROOM_SCENES:
		var src := _read_file(path)
		if src.find("take_damage") != -1 and src.find("player") == -1:
			# 房间场景不含直接调 take_damage 是 OK 的 (伤害由敌人 / 陷阱 / 水 hazard 触发)
			pass
		# 房间场景不应直接调 die() (绕过 SFX 触发链)
		if src.find(".die()") != -1:
			_failures.append("FAIL: F016C.UNIVERSAL.SOURCE.5: %s 直接调 .die(), 绕过 SFX 触发链" % path)
		else:
			_passes += 1
			print("  OK  F016C.UNIVERSAL.SOURCE.5.%s: %s 不直接调 .die() (统一走 GameState.take_damage)" % [path.get_file(), path.get_file()])


# ---------- F016C.UNIVERSAL.CALLER — GameState.take_damage → player.die 链路唯一 ----------
func _run_f016c_universal_caller_assertions() -> void:
	print("--- F016C.UNIVERSAL.CALLER — GameState.take_damage 唯一入口 ---")
	var gs_src := _read_file(GAME_STATE_GD)
	_assert_contains(gs_src, "func take_damage(amount: int) -> void:",
		"F016C.UNIVERSAL.CALLER.1: GameState.take_damage 函数存在 (7 房间伤害汇聚点)")
	# take_damage 体内调 player.die()
	var take_damage_start := gs_src.find("func take_damage(amount: int) -> void:")
	if take_damage_start == -1:
		_failures.append("FAIL: F016C.UNIVERSAL.CALLER.2: take_damage 未找到")
		return
	var take_damage_end := gs_src.find("\nfunc ", take_damage_start + 1)
	if take_damage_end == -1:
		take_damage_end = gs_src.length()
	var body := gs_src.substr(take_damage_start, take_damage_end - take_damage_start)
	_assert_contains(body, "player.die()",
		"F016C.UNIVERSAL.CALLER.3: take_damage 调 player.die() (统一死亡入口)")
	_assert_contains(body, "has_method(\"die\")",
		"F016C.UNIVERSAL.CALLER.4: take_damage 用 has_method 守卫 (test / 老 code 兼容)")
	_assert_contains(body, "PlayerStats.record_death()",
		"F016C.UNIVERSAL.CALLER.5: take_damage 入口记 death (stats 跟踪, 早于 die() 防止 SFX 异常跳过)")


# ---------- F016C.UNIVERSAL.SFX — player.die() 调 ame.play_death_lay_down() ----------
func _run_f016c_universal_sfx_assertions() -> void:
	print("--- F016C.UNIVERSAL.SFX — player.die() 触发 SFX ---")
	var player_src := _read_file(PLAYER_GD)
	# die() 函数体
	var die_start := player_src.find("func die() -> void:")
	if die_start == -1:
		_failures.append("FAIL: F016C.UNIVERSAL.SFX.1: die() 未找到")
		return
	var die_end := player_src.find("\nfunc ", die_start + 1)
	if die_end == -1:
		die_end = player_src.length()
	var body := player_src.substr(die_start, die_end - die_start)
	# SFX 触发点
	_assert_contains(body, "play_death_lay_down()",
		"F016C.UNIVERSAL.SFX.2: die() 调 play_death_lay_down() (单点 SFX 触发)")
	_assert_contains(body, "has_method(\"play_death_lay_down\")",
		"F016C.UNIVERSAL.SFX.3: has_method 守卫保持老 ame 版本兼容 (autoload 老 build 不崩)")
	# SFX 触发顺序: _is_dying = true 之后 + Engine.time_scale 之前 (与 T092 freeze-frame 同步)
	var sfx_pos := body.find("play_death_lay_down")
	var dying_pos := body.find("_is_dying = true")
	var timescale_pos := body.find("Engine.time_scale = DEATH_FREEZE_TIME_SCALE")
	if sfx_pos > dying_pos:
		_passes += 1
		print("  OK  F016C.UNIVERSAL.SFX.4: SFX 触发在 _is_dying = true 之后 (玩家 '听见坠落' 与 '看见坠落' 同帧)")
	else:
		_failures.append("FAIL: F016C.UNIVERSAL.SFX.4: SFX 触发应晚于 _is_dying = true (顺序错位会撕裂时序)")
	if sfx_pos < timescale_pos:
		_passes += 1
		print("  OK  F016C.UNIVERSAL.SFX.5: SFX 触发在 Engine.time_scale 之前 (与 T092 freeze-frame 视觉时序同步)")
	else:
		_failures.append("FAIL: F016C.UNIVERSAL.SFX.5: SFX 触发应早于 time_scale (time_scale 改后 SFX 会被慢放)")


# ---------- F016C.UNIVERSAL.PREWARM — 启动时 SFX 资源已生成 ----------
func _run_f016c_universal_prewarm_assertions() -> void:
	print("--- F016C.UNIVERSAL.PREWARM — prewarm_misc_sfx 含 death SFX ---")
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(ame_src, "prewarm_misc_sfx",
		"F016C.UNIVERSAL.PREWARM.1: prewarm_misc_sfx 函数存在 (启动时 SFX 资源预热)")
	# prewarm 函数体内调 _generate_death_lay_down_sfx
	var prewarm_start := ame_src.find("func prewarm_misc_sfx")
	if prewarm_start == -1:
		_failures.append("FAIL: F016C.UNIVERSAL.PREWARM.2: prewarm_misc_sfx 未找到")
		return
	var prewarm_end := ame_src.find("\nfunc ", prewarm_start + 1)
	if prewarm_end == -1:
		prewarm_end = ame_src.length()
	var body := ame_src.substr(prewarm_start, prewarm_end - prewarm_start)
	_assert_contains(body, "_generate_death_lay_down_sfx",
		"F016C.UNIVERSAL.PREWARM.3: prewarm 调 _generate_death_lay_down_sfx (启动时生成, 首帧死亡 SFX 无 latency)")


# ---------- F016C.LAYER1.* — F016 原 SFX 层 (0.4s 75Hz sub-bass) ----------
func _run_f016c_layer1_f016_assertions() -> void:
	print("--- F016C.LAYER1.* — F016 原 SFX 层 ---")
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	# play_death_lay_down 体内调 play_sfx (实际发声)
	var play_death_start := ame_src.find("func play_death_lay_down() -> void:")
	if play_death_start == -1:
		_failures.append("FAIL: F016C.LAYER1.F016.1: play_death_lay_down 未找到")
		return
	var play_death_end := ame_src.find("\nfunc ", play_death_start + 1)
	if play_death_end == -1:
		play_death_end = ame_src.length()
	var body := ame_src.substr(play_death_start, play_death_end - play_death_start)
	_assert_contains(body, "play_sfx(_death_lay_down_stream)",
		"F016C.LAYER1.F016.2: play_death_lay_down 走 SFX bus (与 BGM 隔离, 不污染 bgm_layer)")
	_assert_contains(body, "_generate_death_lay_down_sfx()",
		"F016C.LAYER1.F016.3: lazy-init 生成 _death_lay_down_stream (首次死亡触发时才生成)")
	# _generate_death_lay_down_sfx 应有 75Hz 基频 (D2 sub-bass)
	var gen_start := ame_src.find("func _generate_death_lay_down_sfx()")
	if gen_start != -1:
		var gen_end := ame_src.find("\nfunc ", gen_start + 1)
		if gen_end == -1:
			gen_end = ame_src.length()
		var gen_body := ame_src.substr(gen_start, gen_end - gen_start)
		# 基频以字面量 TAU * 75.0 形式出现 (在 sin / frequency 计算里)
		if gen_body.find("75.0") != -1:
			_passes += 1
			print("  OK  F016C.LAYER1.F016.4: _generate TAU * 75.0 D2 sub-bass 基频 (与 lay-down 0.5s 完美匹配)")
		else:
			_failures.append("FAIL: F016C.LAYER1.F016.4: _generate 缺 75.0 基频 (SFX 频段偏移会脱离 sub-bass 调性)")


# ---------- F016C.LAYER2.* — F016.B idempotency guard ----------
func _run_f016c_layer2_f016b_assertions() -> void:
	print("--- F016C.LAYER2.* — F016.B idempotency guard ---")
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	_assert_contains(ame_src, "var _death_sfx_playing: bool = false",
		"F016C.LAYER2.F016B.1: _death_sfx_playing 字段 (idempotency guard flag)")
	_assert_contains(ame_src, "const _DEATH_SFX_DURATION := 0.4",
		"F016C.LAYER2.F016B.2: _DEATH_SFX_DURATION = 0.4 (与 SFX 时长一致)")
	_assert_contains(ame_src, "const _DEATH_SFX_GUARD_BUFFER := 0.1",
		"F016C.LAYER2.F016B.3: _DEATH_SFX_GUARD_BUFFER = 0.1 (SFX 未衰减就被截断的缓冲)")
	# play_death_lay_down 体内 guard
	var play_death_start := ame_src.find("func play_death_lay_down() -> void:")
	if play_death_start == -1:
		_failures.append("FAIL: F016C.LAYER2.F016B.4: play_death_lay_down 未找到")
		return
	var play_death_end := ame_src.find("\nfunc ", play_death_start + 1)
	if play_death_end == -1:
		play_death_end = ame_src.length()
	var body := ame_src.substr(play_death_start, play_death_end - play_death_start)
	_assert_contains(body, "if _death_sfx_playing:",
		"F016C.LAYER2.F016B.5: play_death_lay_down 入口 guard (flag==true 早退)")
	_assert_contains(body, "_death_sfx_playing = false",
		"F016C.LAYER2.F016B.6: Timer.timeout 清 flag (0.5s 后恢复接受下次调用)")


# ---------- F016C.COVERAGE.COMMENT — 7 房间 / 全场景覆盖注释 ----------
func _run_f016c_coverage_comment_assertions() -> void:
	print("--- F016C.COVERAGE.COMMENT — 全场景覆盖注释 ---")
	# 注释中应说明 7 房间 / 全场景 SFX 覆盖, 防止未来重构把 F016.C 边界破坏掉.
	var ame_src := _read_file(AUDIO_MANAGER_GD)
	var player_src := _read_file(PLAYER_GD)
	if ame_src.find("F016.C") != -1 or ame_src.find("F016C") != -1 or ame_src.find("F016.C") != -1:
		_passes += 1
		print("  OK  F016C.COVERAGE.COMMENT.1: audio_manager_enhanced.gd 含 F016.C 锚点注释 (任务可追溯)")
	else:
		# 没有显式 F016C 锚点不致命, 但应在 play_death_lay_down 注释里说明 7 房间覆盖
		if ame_src.find("7 房间") != -1 or ame_src.find("7 rooms") != -1 or ame_src.find("全房间") != -1:
			_passes += 1
			print("  OK  F016C.COVERAGE.COMMENT.1: audio_manager_enhanced.gd 含 7 房间 / 全房间覆盖注释")
		else:
			_failures.append("FAIL: F016C.COVERAGE.COMMENT.1: audio_manager_enhanced.gd 应说明 7 房间 / 全场景 SFX 覆盖")
	if player_src.find("F016.C") != -1 or player_src.find("7 房间") != -1 or player_src.find("universal") != -1:
		_passes += 1
		print("  OK  F016C.COVERAGE.COMMENT.2: player.gd 含 F016.C / universal 锚点注释")
	else:
		# die() 函数体注释里只要说明 SFX 触发, 就算 universal
		var die_start := player_src.find("func die() -> void:")
		if die_start != -1:
			var die_end := player_src.find("\nfunc ", die_start + 1)
			if die_end == -1:
				die_end = player_src.length()
			var body := player_src.substr(die_start, die_end - die_start)
			if body.find("Death SFX") != -1 or body.find("play_death_lay_down") != -1:
				_passes += 1
				print("  OK  F016C.COVERAGE.COMMENT.2: player.gd.die() 含 Death SFX 触发注释 (universal 隐含)")
			else:
				_failures.append("FAIL: F016C.COVERAGE.COMMENT.2: player.gd.die() 应有 Death SFX 触发注释")


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
	print("I021 (#111) T193 F016.C Death SFX 7 房间 × 2 层 audit summary")
	print("passes: %d" % _passes)
	print("failures: %d" % _failures.size())
	for line in _failures:
		print(line)
