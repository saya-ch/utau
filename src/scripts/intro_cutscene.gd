class_name IntroCutscene
extends CanvasLayer

# T073 — Opening cutscene. Plays on game start, before the TitleScreen
# is revealed. Sequence (~8 s total):
#   0.0 - 1.0s : pure black
#   1.0 - 3.0s : text "声音被寂静吞噬" fades in (2 s)
#   3.0 - 5.0s : hold (2 s)
#   5.0 - 7.0s : black + text fade out together (2 s)
#   7.0 - 8.0s : hold invisible (1 s) before signaling done
# Pressing any key/clicking skips the cutscene to its end.

signal cutscene_finished

const TOTAL_DURATION := 8.0

var _skipped: bool = false
var _finished_emitted: bool = false

@onready var _black_rect: ColorRect = $BlackRect
@onready var _text_label: Label = $CenterContainer/TextLabel

func _ready() -> void:
	# Ensure the cutscene is on top of everything and grabs input
	# so the player can't interact with the title screen underneath.
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Start invisible / blank — text already at modulate alpha 0 in scene.
	_text_label.modulate = Color(1, 1, 1, 0)
	_black_rect.modulate = Color(1, 1, 1, 1)
	# Skip the cutscene entirely when this scene is being entered as part of
	# a "Continue from save" recovery (GFC._recover_from_transition) — the
	# player has already seen the cutscene on their original run and reading
	# a save should drop them straight into the saved scene.
	# GameState._is_transitioning is set to true by _on_continue_game and
	# cleared by _recover_from_transition after fade-in completes.
	if GameState._is_transitioning:
		visible = false
		layer = -1
		# Emit the finished signal immediately so listeners (if any) get
		# notified; this is a fast-path skip, not a normal completion.
		_emit_finished_once()
		return
	# T230 (#149) — accessibility 减弱视觉反馈 reduce_flash 引导 cutscene
	# 同步. 玩家在 Settings → Video 勾 reduce_flash / reduce_shake /
	# reduce_vibration 任意子项时, cutscene 总时长按比例缩短 (8s → 3.2s
	# 全部 on; 8s → 5.6s 混合 1-2 个 on; 8s 保持 默认). 缩放通过
	# 单一 multiplier 系数作用在 4 段 (BLACK_HOLD / TEXT_FADE_IN /
	# HOLD / FADE_OUT) 时长上, 视觉节奏感保留. indeterminate (混合)
	# 检测读 settings.cfg 3 子项 bool 计数, 不依赖 SettingsMenu UI
	# 节点 (cutscene 启动时 SettingsMenu scene tree 可能未实例化).
	_play_sequence(_compute_accessibility_multiplier())

func _play_sequence(multiplier: float = 1.0) -> void:
	# T122 (#64) — start an 8-second ambient drone on the Ambience bus
	# before the visual sequence kicks in. has_node() + has_method()
	# guard so headless / mock-runs (smoke tests) don't crash if the
	# autoload isn't wired up.
	var ame := get_node_or_null("/root/AudioManagerEnhanced")
	if ame and ame.has_method("play_intro_ambience"):
		ame.call("play_intro_ambience")
	# T230 (#149) — accessibility 缩放应用. 4 段时长 (black_hold /
	# text_fade_in / hold / fade_out + final invisible hold) 全部
	# 乘 multiplier, 视觉节奏感 (慢起 / 中段停 / 慢收) 保留, 仅
	# 总时长缩短. multiplier 钳到 [0.2, 1.0] 范围避免误传
	# 0.0 (立即结束) 或 1.5 (比 8s 还长, 玩家困惑). 0.2 最小
	# 让黑屏闪 0.2s + 文本 0.4s 渐入 + 0.6s 停留 + 0.4s 渐出 ≈ 1.6s,
	# 玩家还能看到 "声音被寂静吞噬" 5 个字 (不能更短, 1.6s 已 < 阅读
	# 时长), 再短文字闪过读不出. 1.0 最大是 8s 完整版 (默认).
	multiplier = clampf(multiplier, 0.2, 1.0)
	var black_hold := 1.0 * multiplier
	var fade_in := 2.0 * multiplier
	var hold := 2.0 * multiplier
	var fade_out := 2.0 * multiplier
	var invisible_hold := 1.0 * multiplier
	var tween := create_tween()
	# 0.0 - black_hold : pure black hold
	tween.tween_interval(black_hold)
	# black_hold - +fade_in : text fades in
	tween.tween_property(_text_label, "modulate:a", 1.0, fade_in)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# hold : hold at full opacity
	tween.tween_interval(hold)
	# fade_out : fade out black + text together
	tween.parallel().tween_property(_black_rect, "modulate:a", 0.0, fade_out)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_text_label, "modulate:a", 0.0, fade_out)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# invisible_hold : hold invisible
	tween.tween_interval(invisible_hold)
	# Finish
	tween.tween_callback(_emit_finished_once)

# T230 (#149) — accessibility multiplier 计算. 读 settings.cfg 3 子项
# (reduce_shake / reduce_flash / reduce_vibration) 计数, 映射到 3 档:
#   0 / 3 子项 on (默认)   → 1.0  (8s 完整版)
#   1-2 / 3 子项 on (混合) → 0.7  (8s × 0.7 = 5.6s, 温和缩短, 不完全跳过)
#   3 / 3 子项 on (全开)   → 0.4  (8s × 0.4 = 3.2s, 强烈缩短)
# 为什么用 3 子项 AND-OR 计数, 而不是直接读 _reduce_all 主开关字段:
# _reduce_all 是 "主开关数据" (bool, 玩家最近一次手动 toggle), 不等
# 于"3 子项 AND 计算" — T202.B 设计让 indeterminate = "曾经全开
# 之后被打破", 3 子项 AND 是 "此刻全开". cutscene 关心"此刻 3 子项
# 真实状态", 不关心"主开关历史", 所以直接读 3 子项更准. 退化路径:
# settings.cfg 不存在 / 解析失败 → 默认 0 子项 on → 1.0 (8s).
func _compute_accessibility_multiplier() -> float:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://settings.cfg")
	if err != OK:
		return 1.0
	var shake_on: bool = bool(cfg.get_value("accessibility", "reduce_shake", false))
	var flash_on: bool = bool(cfg.get_value("accessibility", "reduce_flash", false))
	var vib_on: bool = bool(cfg.get_value("accessibility", "reduce_vibration", false))
	var n: int = int(shake_on) + int(flash_on) + int(vib_on)
	if n >= 3:
		return 0.4
	elif n >= 1:
		return 0.7
	return 1.0

func _emit_finished_once() -> void:
	if _finished_emitted:
		return
	_finished_emitted = true
	cutscene_finished.emit()
	# After a short beat, fully hide so the underlying title screen
	# can be interacted with (the cutscene CanvasLayer is no longer needed).
	var t := get_tree().create_timer(0.2)
	t.timeout.connect(func() -> void:
		if is_instance_valid(self):
			visible = false
			# Re-enable input by dropping the layer below UI. The title
			# screen at layer 0 will now receive clicks.
			layer = -1
	)

func _unhandled_input(event: InputEvent) -> void:
	if _finished_emitted:
		return
	# Only skip on press (not release), and only on key/click/touch.
	if not event.is_pressed():
		return
	var is_key := event is InputEventKey
	var is_mouse := event is InputEventMouseButton
	var is_touch := event is InputEventScreenTouch
	var is_joypad := event is InputEventJoypadButton
	if is_key or is_mouse or is_touch or is_joypad:
		# Consume the event so it doesn't fall through to the title
		# screen beneath us (we want clicks to skip, not to also fire
		# "Start New Game" / "Continue").
		get_viewport().set_input_as_handled()
		_skip()

func _skip() -> void:
	if _skipped or _finished_emitted:
		return
	_skipped = true
	# Fast-forward: tween is not directly killable on a specific time, so
	# just snap to the end state and emit.
	if is_instance_valid(_text_label):
		_text_label.modulate = Color(1, 1, 1, 0)
	if is_instance_valid(_black_rect):
		_black_rect.modulate = Color(1, 1, 1, 0)
	_emit_finished_once()
