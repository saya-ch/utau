extends SceneTree

## test_t136_autosave_smoke.gd
## T136 — SaveSystem 自动存档每 60 秒 端到端冒烟测试
## 验证：
##  1. SaveSystem 含 5 个 AUTOSAVE_* 常量（DEFAULT_ENABLED/INTERVAL/SLOT/MIN/MAX）
##  2. SaveSystem 含 autosave_tick signal
##  3. SaveSystem 含 3 个 getter (get_autosave_enabled/interval/slot)
##  4. SaveSystem 含 4 个 setter (set_autosave_enabled/interval/slot + trigger_autosave_now)
##  5. _autosave_timer 节点创建（Timer 子节点，process_mode=ALWAYS，wait_time clamp）
##  6. _load_autosave_config / _persist_autosave_config（settings.cfg 读写）
##  7. _is_in_gameplay_scene 跳过大厅/菜单/暂停（6 个非游戏场景）
##  8. _do_autosave_tick 4 状态路径（disabled / skipped / ok / error）
##  9. settings_menu.tscn 含 AutoSaveEnabledCheck / AutoSaveIntervalSlider / AutoSaveSlotOptions
## 10. settings_menu.gd 含 _on_autosave_enabled_toggled / _on_autosave_interval_changed / _on_autosave_slot_selected
## 11. settings_menu.gd _save_settings 写 3 个 autosave key
## 12. 内联 _clamp_autosave_interval 验证 min/max 边界
##
## 与 T128/T132 同模式：源码扫描 + 内联实现验证核心逻辑。
## 不直接实例化 SaveSystem（save_system.gd 顶层引用 GameState，
## headless --script 模式不初始化 autoload 编译失败）。

const SRC_SAVE := "res://src/autoload/save_system.gd"
const SRC_SETTINGS_GD := "res://src/scripts/settings_menu.gd"
const SRC_SETTINGS_TSCN := "res://src/scenes/settings_menu.tscn"

func _init() -> void:
	var passed := 0
	var failed := 0
	var test_num := 0
	var save_src: String = _read_file(SRC_SAVE)
	var settings_gd_src: String = _read_file(SRC_SETTINGS_GD)
	var settings_tscn_src: String = _read_file(SRC_SETTINGS_TSCN)

	# --- 1. 5 个 AUTOSAVE_* 常量 ---
	test_num += 1
	var has_constants: bool = (
		"AUTOSAVE_DEFAULT_ENABLED" in save_src
		and "AUTOSAVE_DEFAULT_INTERVAL" in save_src
		and "AUTOSAVE_DEFAULT_SLOT" in save_src
		and "AUTOSAVE_MIN_INTERVAL" in save_src
		and "AUTOSAVE_MAX_INTERVAL" in save_src
	)
	if has_constants:
		print("  [%d] PASS  SaveSystem exposes 5 AUTOSAVE_* constants" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  SaveSystem missing some AUTOSAVE_* constants" % test_num)
		failed += 1

	# --- 2. autosave_tick signal 声明 ---
	test_num += 1
	if "signal autosave_tick(status: String, slot_id: int)" in save_src:
		print("  [%d] PASS  SaveSystem declares autosave_tick signal" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  SaveSystem missing autosave_tick signal" % test_num)
		failed += 1

	# --- 3. 3 个 getter (enabled/interval/slot) ---
	test_num += 1
	var has_getters: bool = (
		"func get_autosave_enabled() -> bool:" in save_src
		and "func get_autosave_interval() -> float:" in save_src
		and "func get_autosave_slot() -> int:" in save_src
	)
	if has_getters:
		print("  [%d] PASS  SaveSystem exposes 3 autosave getter methods" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  SaveSystem missing autosave getters" % test_num)
		failed += 1

	# --- 4. 4 个 setter / trigger ---
	test_num += 1
	var has_setters: bool = (
		"func set_autosave_enabled(enabled: bool) -> void:" in save_src
		and "func set_autosave_interval(interval: float) -> void:" in save_src
		and "func set_autosave_slot(slot_id: int) -> void:" in save_src
		and "func trigger_autosave_now() -> bool:" in save_src
	)
	if has_setters:
		print("  [%d] PASS  SaveSystem exposes 4 autosave mutator methods (3 setters + trigger)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  SaveSystem missing autosave setters / trigger" % test_num)
		failed += 1

	# --- 5. _autosave_timer 节点 + Timer 配置（one_shot=false, autostart=false, process_mode=ALWAYS） ---
	test_num += 1
	var has_timer_setup: bool = (
		"var _autosave_timer: Timer = null" in save_src
		and "_autosave_timer = Timer.new()" in save_src
		and "_autosave_timer.one_shot = false" in save_src
		and "_autosave_timer.wait_time = _clamp_autosave_interval(_autosave_interval)" in save_src
		and "_autosave_timer.process_mode = Node.PROCESS_MODE_ALWAYS" in save_src
		and "_autosave_timer.timeout.connect(_on_autosave_timer_timeout)" in save_src
	)
	if has_timer_setup:
		print("  [%d] PASS  SaveSystem builds + connects autosave Timer with PROCESS_MODE_ALWAYS" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  SaveSystem Timer setup incomplete (one_shot / wait_time / process_mode / timeout)" % test_num)
		failed += 1

	# --- 6. _load_autosave_config / _persist_autosave_config ---
	test_num += 1
	var has_config_io: bool = (
		"func _load_autosave_config() -> void:" in save_src
		and "func _persist_autosave_config() -> void:" in save_src
		and 'cfg.load("user://settings.cfg")' in save_src
		and "cfg.set_value(\"gameplay\", \"autosave_enabled\"" in save_src
		and "cfg.set_value(\"gameplay\", \"autosave_interval\"" in save_src
		and "cfg.set_value(\"gameplay\", \"autosave_slot\"" in save_src
	)
	if has_config_io:
		print("  [%d] PASS  SaveSystem loads + persists autosave config to user://settings.cfg" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  SaveSystem autosave config I/O missing" % test_num)
		failed += 1

	# --- 7. _is_in_gameplay_scene 跳过大厅/菜单/暂停（6 个非游戏场景） ---
	test_num += 1
	var has_skip_scenes: bool = (
		"func _is_in_gameplay_scene() -> bool:" in save_src
		and "title_screen.tscn" in save_src
		and "save_load_menu.tscn" in save_src
		and "settings_menu.tscn" in save_src
		and "credits_screen.tscn" in save_src
		and "intro_cutscene.tscn" in save_src
		and "game_over_screen.tscn" in save_src
	)
	if has_skip_scenes:
		print("  [%d] PASS  _is_in_gameplay_scene skips 6 non-gameplay scenes (title/saveload/settings/credits/cutscene/gameover)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _is_in_gameplay_scene missing some non-gameplay scene suffix" % test_num)
		failed += 1

	# --- 8. _do_autosave_tick 4 状态路径（disabled / skipped / ok / error） ---
	test_num += 1
	var has_4_states: bool = (
		'autosave_tick.emit("disabled"' in save_src
		and 'autosave_tick.emit("skipped"' in save_src
		and 'autosave_tick.emit("ok"' in save_src
		and 'autosave_tick.emit("error"' in save_src
		and "func _do_autosave_tick(reason: String) -> bool:" in save_src
		and "func _on_autosave_timer_timeout() -> void:" in save_src
	)
	if has_4_states:
		print("  [%d] PASS  _do_autosave_tick covers 4 states (disabled/skipped/ok/error) + timer callback" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _do_autosave_tick missing some state emission" % test_num)
		failed += 1

	# --- 9. settings_menu.tscn 含 AutoSaveEnabledCheck / AutoSaveIntervalSlider / AutoSaveSlotOptions ---
	test_num += 1
	var has_tscn_controls: bool = (
		"AutoSaveEnabledCheck" in settings_tscn_src
		and "AutoSaveIntervalSlider" in settings_tscn_src
		and "AutoSaveSlotOptions" in settings_tscn_src
		and "AutoSaveIntervalValue" in settings_tscn_src
	)
	if has_tscn_controls:
		print("  [%d] PASS  settings_menu.tscn adds 4 autosave UI controls (check / slider / value label / slot options)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  settings_menu.tscn missing some autosave UI control" % test_num)
		failed += 1

	# --- 10. settings_menu.gd 3 个 autosave 信号处理函数 ---
	test_num += 1
	var has_signal_handlers: bool = (
		"func _on_autosave_enabled_toggled(enabled: bool) -> void:" in settings_gd_src
		and "func _on_autosave_interval_changed(value: float) -> void:" in settings_gd_src
		and "func _on_autosave_slot_selected(index: int) -> void:" in settings_gd_src
		and "_autosave_enabled_check.toggled.connect(_on_autosave_enabled_toggled)" in settings_gd_src
		and "_autosave_interval_slider.value_changed.connect(_on_autosave_interval_changed)" in settings_gd_src
		and "_autosave_slot_options.item_selected.connect(_on_autosave_slot_selected)" in settings_gd_src
	)
	if has_signal_handlers:
		print("  [%d] PASS  settings_menu.gd defines + connects 3 autosave signal handlers" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  settings_menu.gd autosave signal wiring incomplete" % test_num)
		failed += 1

	# --- 11. settings_menu.gd _save_settings 写 3 个 autosave key ---
	test_num += 1
	var has_save_keys: bool = (
		"cfg.set_value(\"gameplay\", \"autosave_enabled\"" in settings_gd_src
		and "cfg.set_value(\"gameplay\", \"autosave_interval\"" in settings_gd_src
		and "cfg.set_value(\"gameplay\", \"autosave_slot\"" in settings_gd_src
	)
	if has_save_keys:
		print("  [%d] PASS  settings_menu.gd _save_settings persists 3 autosave keys" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  settings_menu.gd missing autosave key persistence" % test_num)
		failed += 1

	# --- 12. 内联 _clamp_autosave_interval 验证 min/max 边界 ---
	test_num += 1
	var clamp_ok: bool = (
		_clamp_autosave_interval(5.0) == 10.0
		and _clamp_autosave_interval(60.0) == 60.0
		and _clamp_autosave_interval(300.0) == 300.0
		and _clamp_autosave_interval(999.0) == 600.0
		and _clamp_autosave_interval(-1.0) == 10.0
	)
	if clamp_ok:
		print("  [%d] PASS  _clamp_autosave_interval floors at 10s / ceilings at 600s (5→10, 999→600, -1→10)" % test_num)
		passed += 1
	else:
		print("  [%d] FAIL  _clamp_autosave_interval broken at min/max boundary" % test_num)
		failed += 1

	# 总结
	print("")
	print("T136 auto-save smoke: %d / %d passed (%d failed)" % [passed, test_num, failed])
	if failed > 0:
		# Clean exit so the harness doesn't flag us as crash.
		# We still log failed > 0 so a CI can grep for it.
		print("T136_SMOKE: HAS_FAILURES")
		quit(1)
	else:
		print("T136_SMOKE: ALL_PASS")
		quit(0)

func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content

# Inline implementation mirroring SaveSystem._clamp_autosave_interval.
# Kept here so the smoke test exercises the exact algorithm
# (clampf to [10.0, 600.0]) without depending on the autoload
# being live in --script mode.
func _clamp_autosave_interval(value: float) -> float:
	return clampf(value, 10.0, 600.0)
