extends SceneTree
## I047 (#143) — F014/F015/F016 prewarm lazy-init guard 清理 冒烟测试
##
## 覆盖 #143 任务 T221 I015 原子化提交:
##
## === F014 — prewarm_misc_sfx 中 _unlock_chime_stream null 守卫清理 ===
## - F014.PRE.NO_NULL: prewarm_misc_sfx body 不含 `if _unlock_chime_stream == null:` (T221 #143 清理)
## - F014.PRE.ASSIGN: prewarm_misc_sfx 仍调 _generate_unlock_chime_sfx() (F014 集成保留)
## - F014.PRE.T185B_DOC: T185.B (#103) 锚点保留 (T185.B #103 注释同步)
## - F014.PLAY.LAZY.KEPT: play_unlock_chime 内部 lazy 守卫保留 (公共方法 idempotent)
## - F014.PLAY.ASSIGN.KEPT: play_unlock_chime 仍调 _generate_unlock_chime_sfx()
##
## === F015 — prewarm_misc_sfx 中 _delete_confirm_stream null 守卫清理 ===
## - F015.PRE.NO_NULL: prewarm_misc_sfx body 不含 `if _delete_confirm_stream == null:` (T221 #143 清理)
## - F015.PRE.ASSIGN: prewarm_misc_sfx 仍调 _generate_delete_confirm_sfx() (F015 集成保留)
## - F015.PLAY.LAZY.KEPT: play_delete_confirm 内部 lazy 守卫保留 (公共方法 idempotent)
## - F015.PLAY.ASSIGN.KEPT: play_delete_confirm 仍调 _generate_delete_confirm_sfx()
##
## === F016 — prewarm_misc_sfx 中 _death_lay_down_stream null 守卫清理 ===
## - F016.PRE.NO_NULL: prewarm_misc_sfx body 不含 `if _death_lay_down_stream == null:` (T221 #143 清理)
## - F016.PRE.ASSIGN: prewarm_misc_sfx 仍调 _generate_death_lay_down_sfx() (F016 集成保留)
## - F016.PLAY.LAZY.KEPT: play_death_lay_down 内部 lazy 守卫保留 (公共方法 idempotent)
## - F016.PLAY.ASSIGN.KEPT: play_death_lay_down 仍调 _generate_death_lay_down_sfx()
##
## === T208 — 14 成就 dict.has 守卫未受影响 (回归保护) ===
## - T208.PRE.DICT_HAS: prewarm_misc_sfx 14 成就 dict.has 守卫保留 (T208 必要守卫)

const AUDIO_MANAGER_GD := "res://src/scripts/audio_manager_enhanced.gd"

var _failures: Array[String] = []
var _passes: int = 0


func _init() -> void:
	print("=== I047 (#143) — F014/F015/F016 prewarm lazy-init guard 清理 ===")
	_run_f014_pre_no_null_assertions()
	_run_f014_pre_assign_assertions()
	_run_f014_pre_doc_assertions()
	_run_f014_play_lazy_kept_assertions()
	_run_f015_pre_no_null_assertions()
	_run_f015_pre_assign_assertions()
	_run_f015_play_lazy_kept_assertions()
	_run_f016_pre_no_null_assertions()
	_run_f016_pre_assign_assertions()
	_run_f016_play_lazy_kept_assertions()
	_run_t208_dict_has_kept_assertions()
	_print_summary()
	if not _failures.is_empty():
		quit(1)
	else:
		print("=== ALL I047 (#143) F014/F015/F016 prewarm lazy-init guard 清理 ASSERTIONS PASSED ===")
		quit(0)


# ===================== F014 — prewarm_misc_sfx 中 _unlock_chime_stream null 守卫清理 =====================

# ---------- F014.PRE.NO_NULL — prewarm_misc_sfx body 不含 null 守卫 ----------
func _run_f014_pre_no_null_assertions() -> void:
	print("--- F014.PRE.NO_NULL — prewarm_misc_sfx body 不含 null 守卫 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F014.PRE.NO_NULL.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# T221 #143 清理: prewarm_misc_sfx body 不应再含 `if _unlock_chime_stream == null:` 守卫
	if body.find("if _unlock_chime_stream == null:") == -1:
		_passes += 1
		print("  OK  F014.PRE.NO_NULL.1: prewarm_misc_sfx body 不含 `if _unlock_chime_stream == null:` 守卫 (T221 #143 清理)")
	else:
		_failures.append("FAIL: F014.PRE.NO_NULL.1: prewarm_misc_sfx body 仍含 `if _unlock_chime_stream == null:` 守卫 (T221 #143 应清未清)")


# ---------- F014.PRE.ASSIGN — prewarm_misc_sfx 仍调 _generate_unlock_chime_sfx() ----------
func _run_f014_pre_assign_assertions() -> void:
	print("--- F014.PRE.ASSIGN — prewarm_misc_sfx 仍调 _generate_unlock_chime_sfx() ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F014.PRE.ASSIGN.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# F014 集成保留: prewarm_misc_sfx body 仍调 _generate_unlock_chime_sfx()
	_assert_contains(body, "_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"F014.PRE.ASSIGN.1: prewarm_misc_sfx body 仍调 _generate_unlock_chime_sfx() (F014 集成保留)")


# ---------- F014.PRE.T185B_DOC — T185.B (#103) 锚点保留 ----------
func _run_f014_pre_doc_assertions() -> void:
	print("--- F014.PRE.T185B_DOC — T185.B (#103) 锚点保留 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# T185.B 注释锚点保留 (T185.B #103 历史, T221 #143 不破坏)
	_assert_contains(src, "T185.B (#103)",
		"F014.PRE.T185B_DOC.1: T185.B (#103) 锚点保留 (T185.B 注释同步未破坏)")


# ---------- F014.PLAY.LAZY.KEPT — play_unlock_chime 内部 lazy 守卫保留 ----------
func _run_f014_play_lazy_kept_assertions() -> void:
	print("--- F014.PLAY.LAZY.KEPT — play_unlock_chime 内部 lazy 守卫保留 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# play_unlock_chime 公共方法 lazy 守卫保留 (idempotent, headless 安全)
	_assert_contains(src, "if _unlock_chime_stream == null:",
		"F014.PLAY.LAZY.KEPT.1: play_unlock_chime 内部 `if _unlock_chime_stream == null:` 守卫保留 (T208.FALLBACK #126 兼容)")
	_assert_contains(src, "_unlock_chime_stream = _generate_unlock_chime_sfx()",
		"F014.PLAY.ASSIGN.KEPT.1: play_unlock_chime 仍调 _generate_unlock_chime_sfx()")


# ===================== F015 — prewarm_misc_sfx 中 _delete_confirm_stream null 守卫清理 =====================

# ---------- F015.PRE.NO_NULL — prewarm_misc_sfx body 不含 null 守卫 ----------
func _run_f015_pre_no_null_assertions() -> void:
	print("--- F015.PRE.NO_NULL — prewarm_misc_sfx body 不含 null 守卫 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F015.PRE.NO_NULL.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# T221 #143 清理: prewarm_misc_sfx body 不应再含 `if _delete_confirm_stream == null:` 守卫
	if body.find("if _delete_confirm_stream == null:") == -1:
		_passes += 1
		print("  OK  F015.PRE.NO_NULL.1: prewarm_misc_sfx body 不含 `if _delete_confirm_stream == null:` 守卫 (T221 #143 清理)")
	else:
		_failures.append("FAIL: F015.PRE.NO_NULL.1: prewarm_misc_sfx body 仍含 `if _delete_confirm_stream == null:` 守卫 (T221 #143 应清未清)")


# ---------- F015.PRE.ASSIGN — prewarm_misc_sfx 仍调 _generate_delete_confirm_sfx() ----------
func _run_f015_pre_assign_assertions() -> void:
	print("--- F015.PRE.ASSIGN — prewarm_misc_sfx 仍调 _generate_delete_confirm_sfx() ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F015.PRE.ASSIGN.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# F015 集成保留: prewarm_misc_sfx body 仍调 _generate_delete_confirm_sfx()
	_assert_contains(body, "_delete_confirm_stream = _generate_delete_confirm_sfx()",
		"F015.PRE.ASSIGN.1: prewarm_misc_sfx body 仍调 _generate_delete_confirm_sfx() (F015 集成保留)")


# ---------- F015.PLAY.LAZY.KEPT — play_delete_confirm 内部 lazy 守卫保留 ----------
func _run_f015_play_lazy_kept_assertions() -> void:
	print("--- F015.PLAY.LAZY.KEPT — play_delete_confirm 内部 lazy 守卫保留 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# play_delete_confirm 公共方法 lazy 守卫保留 (idempotent, headless 安全)
	_assert_contains(src, "if _delete_confirm_stream == null:",
		"F015.PLAY.LAZY.KEPT.1: play_delete_confirm 内部 `if _delete_confirm_stream == null:` 守卫保留 (公共方法 idempotent)")
	_assert_contains(src, "_delete_confirm_stream = _generate_delete_confirm_sfx()",
		"F015.PLAY.ASSIGN.KEPT.1: play_delete_confirm 仍调 _generate_delete_confirm_sfx()")


# ===================== F016 — prewarm_misc_sfx 中 _death_lay_down_stream null 守卫清理 =====================

# ---------- F016.PRE.NO_NULL — prewarm_misc_sfx body 不含 null 守卫 ----------
func _run_f016_pre_no_null_assertions() -> void:
	print("--- F016.PRE.NO_NULL — prewarm_misc_sfx body 不含 null 守卫 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F016.PRE.NO_NULL.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# T221 #143 清理: prewarm_misc_sfx body 不应再含 `if _death_lay_down_stream == null:` 守卫
	if body.find("if _death_lay_down_stream == null:") == -1:
		_passes += 1
		print("  OK  F016.PRE.NO_NULL.1: prewarm_misc_sfx body 不含 `if _death_lay_down_stream == null:` 守卫 (T221 #143 清理)")
	else:
		_failures.append("FAIL: F016.PRE.NO_NULL.1: prewarm_misc_sfx body 仍含 `if _death_lay_down_stream == null:` 守卫 (T221 #143 应清未清)")


# ---------- F016.PRE.ASSIGN — prewarm_misc_sfx 仍调 _generate_death_lay_down_sfx() ----------
func _run_f016_pre_assign_assertions() -> void:
	print("--- F016.PRE.ASSIGN — prewarm_misc_sfx 仍调 _generate_death_lay_down_sfx() ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: F016.PRE.ASSIGN.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# F016 集成保留: prewarm_misc_sfx body 仍调 _generate_death_lay_down_sfx()
	_assert_contains(body, "_death_lay_down_stream = _generate_death_lay_down_sfx()",
		"F016.PRE.ASSIGN.1: prewarm_misc_sfx body 仍调 _generate_death_lay_down_sfx() (F016 集成保留)")


# ---------- F016.PLAY.LAZY.KEPT — play_death_lay_down 内部 lazy 守卫保留 ----------
func _run_f016_play_lazy_kept_assertions() -> void:
	print("--- F016.PLAY.LAZY.KEPT — play_death_lay_down 内部 lazy 守卫保留 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	# play_death_lay_down 公共方法 lazy 守卫保留 (idempotent, headless 安全)
	_assert_contains(src, "if _death_lay_down_stream == null:",
		"F016.PLAY.LAZY.KEPT.1: play_death_lay_down 内部 `if _death_lay_down_stream == null:` 守卫保留 (F016 公共方法 idempotent)")
	_assert_contains(src, "_death_lay_down_stream = _generate_death_lay_down_sfx()",
		"F016.PLAY.ASSIGN.KEPT.1: play_death_lay_down 仍调 _generate_death_lay_down_sfx()")


# ===================== T208 — 14 成就 dict.has 守卫未受影响 (回归保护) =====================

# ---------- T208.PRE.DICT_HAS — prewarm_misc_sfx 14 成就 dict.has 守卫保留 ----------
func _run_t208_dict_has_kept_assertions() -> void:
	print("--- T208.PRE.DICT_HAS — prewarm_misc_sfx 14 成就 dict.has 守卫保留 ---")
	var src := _read_file(AUDIO_MANAGER_GD)
	var prewarm_misc_body_start := src.find("func prewarm_misc_sfx() -> void:")
	if prewarm_misc_body_start == -1:
		_failures.append("FAIL: T208.PRE.DICT_HAS.1: prewarm_misc_sfx 函数未找到")
		return
	var next_func_pos := src.find("\nfunc ", prewarm_misc_body_start + 1)
	if next_func_pos == -1:
		next_func_pos = src.length()
	var body := src.substr(prewarm_misc_body_start, next_func_pos - prewarm_misc_body_start)
	# T208 14 成就 dict.has 守卫保留 (T208 #126 多 key 守卫是必要的, 与 3 单 stream 守卫不同)
	_assert_contains(body, "if not _achievement_chime_streams.has(ach_id):",
		"T208.PRE.DICT_HAS.1: prewarm_misc_sfx 14 成就 `if not _achievement_chime_streams.has(ach_id):` 守卫保留 (T208 多 key 守卫必要)")
	_assert_contains(body, "for ach_id in ACHIEVEMENT_CHIME_PRESETS.keys():",
		"T208.PRE.DICT_HAS.2: prewarm_misc_sfx 14 成就循环保留 (T208 集成未破坏)")


# ===================== 通用 helper =====================

func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content


func _assert_contains(haystack: String, needle: String, label: String) -> void:
	if haystack.find(needle) != -1:
		_passes += 1
		print("  OK  %s" % label)
	else:
		_failures.append("FAIL: %s (missing: %s)" % [label, needle])


func _print_summary() -> void:
	print("")
	print("--- Summary ---")
	print("  PASS: %d" % _passes)
	print("  FAIL: %d" % _failures.size())
	for fail_msg in _failures:
		print("  %s" % fail_msg)
	print("")
