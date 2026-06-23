extends SceneTree
## I030 (#122) — Smoke test for T205 (Settings Menu Audio 4 滑块
## 实时百分比显示). 验证:
##   - 4 @onready var label refs (master/sfx/music/ambience)
##   - 1 _refresh_audio_volume_label helper 函数
##   - 4 _on_*_changed handler 各调 1 次 helper
##   - _load_settings 调 4 次 helper 同步初始音量
##   - _on_restore_all_pressed 调 4 次 helper 还原默认 100%
##   - tscn 4 labels 启用 bbcode_enabled
##
## 18 断言 — 全部静态 parse / grep (无 live scene 需求).
## Run via:
##   godot --headless --script tools/test_i030_t205_audio_volume_label_smoke.gd

func _initialize() -> void:
	print("=== I030 T205 Audio 4 滑块实时百分比显示 smoke test (#122) ===")

	var menu_src := ""
	var mf := FileAccess.open("res://src/scripts/settings_menu.gd", FileAccess.READ)
	if mf:
		menu_src = mf.get_as_text()
		mf.close()

	var scene_src := ""
	var scf := FileAccess.open("res://src/scenes/settings_menu.tscn", FileAccess.READ)
	if scf:
		scene_src = scf.get_as_text()
		scf.close()

	var passed := 0
	var total := 0

	# ===== T205.GD.MASTER_LABEL_REF =====
	total += 1
	if menu_src.find("@onready var _master_label: Label = $VBoxContainer/Content/AudioPanel/MasterLabel") == -1:
		print("  FAIL [T205.1]: settings_menu.gd 缺 _master_label @onready 字段")
		quit(1)
		return
	passed += 1
	print("  [T205.1] @onready var _master_label (OK)")

	# ===== T205.GD.SFX_LABEL_REF =====
	total += 1
	if menu_src.find("@onready var _sfx_label: Label = $VBoxContainer/Content/AudioPanel/SFXLabel") == -1:
		print("  FAIL [T205.2]: settings_menu.gd 缺 _sfx_label @onready 字段")
		quit(1)
		return
	passed += 1
	print("  [T205.2] @onready var _sfx_label (OK)")

	# ===== T205.GD.MUSIC_LABEL_REF =====
	total += 1
	if menu_src.find("@onready var _music_label: Label = $VBoxContainer/Content/AudioPanel/MusicLabel") == -1:
		print("  FAIL [T205.3]: settings_menu.gd 缺 _music_label @onready 字段")
		quit(1)
		return
	passed += 1
	print("  [T205.3] @onready var _music_label (OK)")

	# ===== T205.GD.AMBIENCE_LABEL_REF =====
	total += 1
	if menu_src.find("@onready var _ambience_label: Label = $VBoxContainer/Content/AudioPanel/AmbienceLabel") == -1:
		print("  FAIL [T205.4]: settings_menu.gd 缺 _ambience_label @onready 字段")
		quit(1)
		return
	passed += 1
	print("  [T205.4] @onready var _ambience_label (OK)")

	# ===== T205.GD.HELPER_FN =====
	total += 1
	if menu_src.find("func _refresh_audio_volume_label(label: Label, value: float, base_text: String) -> void:") == -1:
		print("  FAIL [T205.5]: 缺 _refresh_audio_volume_label helper 函数")
		quit(1)
		return
	passed += 1
	print("  [T205.5] _refresh_audio_volume_label helper 函数 (OK)")

	# ===== T205.GD.HELPER_BBCODE =====
	total += 1
	# helper 内部必须用 [color=#F2B66E] 包 %d%% 数字 (Amber Voice 主题色)
	var helper_idx := menu_src.find("func _refresh_audio_volume_label(")
	if helper_idx == -1:
		print("  FAIL [T205.6]: helper 函数找不到 (前置 anchor 应已通过)")
		quit(1)
		return
	var helper_body := menu_src.substr(helper_idx, 600)
	if helper_body.find("[color=#F2B66E]") == -1 or helper_body.find("%d%%") == -1:
		print("  FAIL [T205.6]: helper 缺 BBCode [color=#F2B66E] + %d%% 格式")
		quit(1)
		return
	passed += 1
	print("  [T205.6] helper 含 BBCode [color=#F2B66E] + %d%% (OK)")

	# ===== T205.GD.HELPER_NULL_GUARD =====
	total += 1
	# null 守卫防御 _onready 时序竞态 (headless test 场景)
	if helper_body.find("if label == null:") == -1 or helper_body.find("return") == -1:
		print("  FAIL [T205.7]: helper 缺 null 守卫")
		quit(1)
		return
	passed += 1
	print("  [T205.7] helper null 守卫 (OK)")

	# ===== T205.GD.ON_MASTER_CALL =====
	total += 1
	# _on_master_changed 末尾调 _refresh_audio_volume_label(_master_label, value, "主音量")
	var on_master_idx := menu_src.find("func _on_master_changed")
	if on_master_idx == -1:
		print("  FAIL [T205.8]: 缺 _on_master_changed 函数")
		quit(1)
		return
	var on_master_body := menu_src.substr(on_master_idx, 400)
	if on_master_body.find("_refresh_audio_volume_label(_master_label, value, \"主音量\")") == -1:
		print("  FAIL [T205.8]: _on_master_changed 缺 helper 调用")
		quit(1)
		return
	passed += 1
	print("  [T205.8] _on_master_changed 调 helper (OK)")

	# ===== T205.GD.ON_SFX_CALL =====
	total += 1
	var on_sfx_idx := menu_src.find("func _on_sfx_changed")
	if on_sfx_idx == -1:
		print("  FAIL [T205.9]: 缺 _on_sfx_changed 函数")
		quit(1)
		return
	var on_sfx_body := menu_src.substr(on_sfx_idx, 400)
	if on_sfx_body.find("_refresh_audio_volume_label(_sfx_label, value, \"音效\")") == -1:
		print("  FAIL [T205.9]: _on_sfx_changed 缺 helper 调用")
		quit(1)
		return
	passed += 1
	print("  [T205.9] _on_sfx_changed 调 helper (OK)")

	# ===== T205.GD.ON_MUSIC_CALL =====
	total += 1
	var on_music_idx := menu_src.find("func _on_music_changed")
	if on_music_idx == -1:
		print("  FAIL [T205.10]: 缺 _on_music_changed 函数")
		quit(1)
		return
	var on_music_body := menu_src.substr(on_music_idx, 400)
	if on_music_body.find("_refresh_audio_volume_label(_music_label, value, \"音乐\")") == -1:
		print("  FAIL [T205.10]: _on_music_changed 缺 helper 调用")
		quit(1)
		return
	passed += 1
	print("  [T205.10] _on_music_changed 调 helper (OK)")

	# ===== T205.GD.ON_AMBIENCE_CALL =====
	total += 1
	var on_amb_idx := menu_src.find("func _on_ambience_changed")
	if on_amb_idx == -1:
		print("  FAIL [T205.11]: 缺 _on_ambience_changed 函数")
		quit(1)
		return
	var on_amb_body := menu_src.substr(on_amb_idx, 400)
	if on_amb_body.find("_refresh_audio_volume_label(_ambience_label, value, \"环境音\")") == -1:
		print("  FAIL [T205.11]: _on_ambience_changed 缺 helper 调用")
		quit(1)
		return
	passed += 1
	print("  [T205.11] _on_ambience_changed 调 helper (OK)")

	# ===== T205.GD.LOAD_SETTINGS_4_CALLS =====
	total += 1
	# _load_settings 中调 4 次 helper 同步初始音量
	var load_idx := menu_src.find("func _load_settings()")
	if load_idx == -1:
		print("  FAIL [T205.12]: 缺 _load_settings 函数")
		quit(1)
		return
	var load_body := menu_src.substr(load_idx, 4000)
	var load_call_count := _count_substr(load_body, "_refresh_audio_volume_label")
	if load_call_count < 4:
		print("  FAIL [T205.12]: _load_settings 调 helper 次数 = %d, 期望 >= 4" % load_call_count)
		quit(1)
		return
	passed += 1
	print("  [T205.12] _load_settings 调 4 次 helper (OK, %d 次)" % load_call_count)

	# ===== T205.GD.RESTORE_ALL_4_CALLS =====
	total += 1
	# _on_restore_all_pressed 中调 4 次 helper 还原默认 100%
	var restore_idx := menu_src.find("func _on_restore_all_pressed")
	if restore_idx == -1:
		print("  FAIL [T205.13]: 缺 _on_restore_all_pressed 函数")
		quit(1)
		return
	var restore_body := menu_src.substr(restore_idx, 8000)
	var restore_call_count := _count_substr(restore_body, "_refresh_audio_volume_label")
	if restore_call_count < 4:
		print("  FAIL [T205.13]: _on_restore_all_pressed 调 helper 次数 = %d, 期望 >= 4" % restore_call_count)
		quit(1)
		return
	passed += 1
	print("  [T205.13] _on_restore_all_pressed 调 4 次 helper (OK, %d 次)" % restore_call_count)

	# ===== T205.TSCN.MASTER_BBCODE =====
	total += 1
	# tscn MasterLabel 含 bbcode_enabled = true
	var master_node_idx := scene_src.find('name="MasterLabel"')
	if master_node_idx == -1:
		print("  FAIL [T205.14]: tscn 缺 MasterLabel 节点")
		quit(1)
		return
	var master_node_section := scene_src.substr(master_node_idx, 200)
	if master_node_section.find("bbcode_enabled = true") == -1:
		print("  FAIL [T205.14]: MasterLabel 缺 bbcode_enabled = true (BBCode [color] 不渲染)")
		quit(1)
		return
	passed += 1
	print("  [T205.14] MasterLabel bbcode_enabled = true (OK)")

	# ===== T205.TSCN.SFX_BBCODE =====
	total += 1
	var sfx_node_idx := scene_src.find('name="SFXLabel"')
	if sfx_node_idx == -1:
		print("  FAIL [T205.15]: tscn 缺 SFXLabel 节点")
		quit(1)
		return
	var sfx_node_section := scene_src.substr(sfx_node_idx, 200)
	if sfx_node_section.find("bbcode_enabled = true") == -1:
		print("  FAIL [T205.15]: SFXLabel 缺 bbcode_enabled = true")
		quit(1)
		return
	passed += 1
	print("  [T205.15] SFXLabel bbcode_enabled = true (OK)")

	# ===== T205.TSCN.MUSIC_BBCODE =====
	total += 1
	var music_node_idx := scene_src.find('name="MusicLabel"')
	if music_node_idx == -1:
		print("  FAIL [T205.16]: tscn 缺 MusicLabel 节点")
		quit(1)
		return
	var music_node_section := scene_src.substr(music_node_idx, 200)
	if music_node_section.find("bbcode_enabled = true") == -1:
		print("  FAIL [T205.16]: MusicLabel 缺 bbcode_enabled = true")
		quit(1)
		return
	passed += 1
	print("  [T205.16] MusicLabel bbcode_enabled = true (OK)")

	# ===== T205.TSCN.AMBIENCE_BBCODE =====
	total += 1
	var amb_node_idx := scene_src.find('name="AmbienceLabel"')
	if amb_node_idx == -1:
		print("  FAIL [T205.17]: tscn 缺 AmbienceLabel 节点")
		quit(1)
		return
	var amb_node_section := scene_src.substr(amb_node_idx, 200)
	if amb_node_section.find("bbcode_enabled = true") == -1:
		print("  FAIL [T205.17]: AmbienceLabel 缺 bbcode_enabled = true")
		quit(1)
		return
	passed += 1
	print("  [T205.17] AmbienceLabel bbcode_enabled = true (OK)")

	# ===== T205.GD.ANCHOR_COMMENT =====
	total += 1
	# T205 (#122) 注释锚点 (供未来读代码追溯)
	var anchor_count := _count_substr(menu_src, "T205 (#122)")
	if anchor_count < 3:
		print("  FAIL [T205.18]: T205 (#122) 注释锚点出现 %d 次, 期望 >= 3" % anchor_count)
		quit(1)
		return
	passed += 1
	print("  [T205.18] T205 (#122) 注释锚点 (出现 %d 次) (OK)" % anchor_count)

	print("=== I030 T205 Audio 4 滑块实时百分比显示 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


# Substring counter helper — 与 I027 / I028 / I029 同样的实现.
func _count_substr(haystack: String, needle: String) -> int:
	if needle.is_empty():
		return 0
	var c := 0
	var sp := 0
	while true:
		var idx := haystack.find(needle, sp)
		if idx == -1:
			break
		c += 1
		sp = idx + 1
	return c
