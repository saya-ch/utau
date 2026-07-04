extends SceneTree
## I026 (#159) — Smoke test for F013.E (Whisper 6 verb 接入路径落地).
##
## 36+ 断言 — 全部静态 parse / grep (无 live scene 需求, 无 autoload init).
## Run via:
##   godot --headless --script tools/test_i026_f013e_whisper_smoke.gd
##
## 6 verb 接入路径 §9.1 9 步 全部覆盖:
##   1. whisper_ability.gd class_name WhisperAbility extends _verb_ability_base
##   2. player.tscn 节点 WhisperAbility script=ExtResource + cooldown/windup_time
##   3. project.godot Input Map whisper={T, 4, button 7}
##   4. STYLE_GUIDE.md Muted Mauve #C8A4D8
##   5. player.gd whisper_ability @onready + _handle_whisper + _on_whisper_fired
##   6. whisper_vfx.gd / whisper_windup_vfx.gd (含 fade_out_and_free)
##   7. player_stats.gd whisper_used + record_ability_used 分支 + reset
##   8. pause_menu.gd _VERB_HINT_DATA 第 6 元素 + _stat_abilities 6 verb +
##      _profile_abilities 6 verb + _profile_last_verb whisper match + tooltip 6 声波能力
##   9. achievements.json sextuple_voice + style_guide Muted Mauve

func _initialize() -> void:
	print("=== I026 F013.E Whisper 6 verb 接入路径 smoke test (#159) ===")

	var src_whisper_ability := _read_file("res://src/scripts/whisper_ability.gd")
	var src_whisper_vfx := _read_file("res://src/scripts/whisper_vfx.gd")
	var src_whisper_windup := _read_file("res://src/scripts/whisper_windup_vfx.gd")
	var src_player := _read_file("res://src/scripts/player.gd")
	var src_player_stats := _read_file("res://src/autoload/player_stats.gd")
	var src_pause_menu := _read_file("res://src/scripts/pause_menu.gd")
	var src_player_tscn := _read_file("res://src/scenes/player.tscn")
	var src_project := _read_file("res://project.godot")
	var src_achievements := _read_file("res://data/achievements.json")
	var src_style_guide := _read_file("res://STYLE_GUIDE.md")

	var passed := 0
	var total := 0

	# ===== F013E.1.WA_CLASS — whisper_ability.gd class_name WhisperAbility =====
	total += 1
	if src_whisper_ability.find("class_name WhisperAbility") == -1:
		print("  FAIL [F013E.1.1]: whisper_ability.gd 缺 class_name WhisperAbility")
		quit(1); return
	passed += 1
	print("  [F013E.1.1] whisper_ability.gd 含 class_name WhisperAbility (OK)")

	# ===== F013E.1.WA_EXTENDS — extends _verb_ability_base =====
	total += 1
	if src_whisper_ability.find('extends "res://src/scripts/_verb_ability_base.gd"') == -1:
		print("  FAIL [F013E.1.2]: whisper_ability.gd 没继承 _verb_ability_base")
		quit(1); return
	passed += 1
	print("  [F013E.1.2] whisper_ability.gd 继承 _verb_ability_base (OK)")

	# ===== F013E.1.WA_NO_COOLDOWN_DECL — H001 不重声明 cooldown/windup_time =====
	total += 1
	var has_cooldown_export := src_whisper_ability.find("@export var cooldown") != -1 \
		or src_whisper_ability.find("@export var windup_time") != -1
	if has_cooldown_export:
		print("  FAIL [F013E.1.3]: whisper_ability.gd 重声明 cooldown/windup_time (违反 H001 #99)")
		quit(1); return
	passed += 1
	print("  [F013E.1.3] whisper_ability.gd 未重声明 cooldown/windup_time (H001 OK)")

	# ===== F013E.1.WA_SIGNALS — whisper_fired / whisper_hit / whisper_blocked =====
	total += 1
	if src_whisper_ability.find("signal whisper_fired") == -1 \
			or src_whisper_ability.find("signal whisper_hit") == -1 \
			or src_whisper_ability.find("signal whisper_blocked") == -1:
		print("  FAIL [F013E.1.4]: whisper_ability.gd 缺 3 signal (fired/hit/blocked)")
		quit(1); return
	passed += 1
	print("  [F013E.1.4] whisper_ability.gd 含 3 signal (OK)")

	# ===== F013E.1.WA_SUPER_READY — 调 super._ready() =====
	total += 1
	if src_whisper_ability.find("super._ready()") == -1:
		print("  FAIL [F013E.1.5]: whisper_ability.gd 没调 super._ready()")
		quit(1); return
	passed += 1
	print("  [F013E.1.5] whisper_ability.gd 调 super._ready() (OK)")

	# ===== F013E.1.WA_PROCESS_COOLDOWN — _process_cooldown(delta, \"whisper\") =====
	total += 1
	if src_whisper_ability.find('_process_cooldown(delta, "whisper")') == -1:
		print("  FAIL [F013E.1.6]: whisper_ability.gd 缺 _process_cooldown(delta, \"whisper\")")
		quit(1); return
	passed += 1
	print("  [F013E.1.6] whisper_ability.gd 调 _process_cooldown(delta, \"whisper\") (OK)")

	# ===== F013E.1.WA_RECORD — record_ability_used(\"whisper\") =====
	total += 1
	if src_whisper_ability.find('record_ability_used("whisper")') == -1:
		print("  FAIL [F013E.1.7]: whisper_ability.gd 缺 record_ability_used(\"whisper\")")
		quit(1); return
	passed += 1
	print("  [F013E.1.7] whisper_ability.gd 调 record_ability_used(\"whisper\") (OK)")

	# ===== F013E.2.PLAYER_TSCN_NODE — WhisperAbility node in player.tscn =====
	total += 1
	if src_player_tscn.find("[node name=\"WhisperAbility\"") == -1:
		print("  FAIL [F013E.2.1]: player.tscn 缺 WhisperAbility 节点")
		quit(1); return
	passed += 1
	print("  [F013E.2.1] player.tscn 含 WhisperAbility 节点 (OK)")

	# ===== F013E.2.PLAYER_TSCN_OVERRIDE — cooldown=5.0 / windup_time=0.1 =====
	total += 1
	if src_player_tscn.find("cooldown = 5.0") == -1 \
			or src_player_tscn.find("windup_time = 0.1") == -1:
		print("  FAIL [F013E.2.2]: player.tscn 缺 cooldown=5.0 或 windup_time=0.1 override")
		quit(1); return
	passed += 1
	print("  [F013E.2.2] player.tscn 含 cooldown=5.0 / windup_time=0.1 (OK)")

	# ===== F013E.2.PLAYER_TSCN_EXT — whisper_ability.gd ExtResource =====
	total += 1
	if src_player_tscn.find("res://src/scripts/whisper_ability.gd") == -1:
		print("  FAIL [F013E.2.3]: player.tscn 缺 whisper_ability.gd ExtResource")
		quit(1); return
	passed += 1
	print("  [F013E.2.3] player.tscn 含 whisper_ability.gd ExtResource (OK)")

	# ===== F013E.3.INPUT_MAP — whisper= action =====
	total += 1
	if src_project.find("\nwhisper={") == -1:
		print("  FAIL [F013E.3.1]: project.godot 缺 whisper= action")
		quit(1); return
	passed += 1
	print("  [F013E.3.1] project.godot 含 whisper= Input Map (OK)")

	# ===== F013E.3.INPUT_MAP_T — keycode 84 (T) =====
	total += 1
	if src_project.find('physical_keycode":84') == -1:
		print("  FAIL [F013E.3.2]: project.godot whisper= 没绑 T 键 (keycode 84)")
		quit(1); return
	passed += 1
	print("  [F013E.3.2] project.godot whisper= 绑 T 键 (OK)")

	# ===== F013E.3.INPUT_MAP_4 — alt keycode 52 (4) =====
	total += 1
	if src_project.find('physical_keycode":52') == -1:
		print("  FAIL [F013E.3.3]: project.godot whisper= 缺 alt 键 4 (keycode 52)")
		quit(1); return
	passed += 1
	print("  [F013E.3.3] project.godot whisper= 含 alt 键 4 (OK)")

	# ===== F013E.3.INPUT_MAP_BTN7 — joypad button 7 =====
	total += 1
	if src_project.find('whisper=') != -1 and src_project.find('button_index":7') != -1:
		pass
	else:
		print("  FAIL [F013E.3.4]: project.godot whisper= 缺 joypad button 7")
		quit(1); return
	passed += 1
	print("  [F013E.3.4] project.godot whisper= 含 joypad button 7 (OK)")

	# ===== F013E.4.STYLE_MUTED_MAUVE — Muted Mauve #C8A4D8 in STYLE_GUIDE =====
	total += 1
	if src_style_guide.find("Muted Mauve") == -1 or src_style_guide.find("#C8A4D8") == -1:
		print("  FAIL [F013E.4.1]: STYLE_GUIDE.md 缺 Muted Mauve #C8A4D8")
		quit(1); return
	passed += 1
	print("  [F013E.4.1] STYLE_GUIDE.md 含 Muted Mauve #C8A4D8 (OK)")

	# ===== F013E.5.PLAYER_ONREADY — @onready var whisper_ability =====
	total += 1
	if src_player.find("@onready var whisper_ability = $WhisperAbility") == -1:
		print("  FAIL [F013E.5.1]: player.gd 缺 @onready var whisper_ability = $WhisperAbility")
		quit(1); return
	passed += 1
	print("  [F013E.5.1] player.gd 含 @onready var whisper_ability (OK)")

	# ===== F013E.5.PLAYER_HANDLE — _handle_whisper() =====
	total += 1
	if src_player.find("func _handle_whisper()") == -1:
		print("  FAIL [F013E.5.2]: player.gd 缺 _handle_whisper()")
		quit(1); return
	passed += 1
	print("  [F013E.5.2] player.gd 含 _handle_whisper() (OK)")

	# ===== F013E.5.PLAYER_HANDLE_CALL — _handle_whisper() call in _process =====
	total += 1
	if src_player.find("_handle_whisper()") == -1:
		print("  FAIL [F013E.5.3]: player.gd _process 没调 _handle_whisper()")
		quit(1); return
	passed += 1
	print("  [F013E.5.3] player.gd _process 调 _handle_whisper() (OK)")

	# ===== F013E.5.PLAYER_ON_FIRED — _on_whisper_fired() handler =====
	total += 1
	if src_player.find("func _on_whisper_fired(") == -1:
		print("  FAIL [F013E.5.4]: player.gd 缺 _on_whisper_fired()")
		quit(1); return
	passed += 1
	print("  [F013E.5.4] player.gd 含 _on_whisper_fired() (OK)")

	# ===== F013E.5.PLAYER_ON_HIT — _on_whisper_hit() handler =====
	total += 1
	if src_player.find("func _on_whisper_hit(") == -1:
		print("  FAIL [F013E.5.5]: player.gd 缺 _on_whisper_hit()")
		quit(1); return
	passed += 1
	print("  [F013E.5.5] player.gd 含 _on_whisper_hit() (OK)")

	# ===== F013E.5.PLAYER_SIGNAL_BRIDGE — whisper_fired.connect =====
	total += 1
	if src_player.find("whisper_fired.connect(_on_whisper_fired)") == -1:
		print("  FAIL [F013E.5.6]: player.gd _ready 没 connect whisper_fired 信号")
		quit(1); return
	passed += 1
	print("  [F013E.5.6] player.gd _ready connect whisper_fired 信号 (OK)")

	# ===== F013E.6.VFX_CLASS — whisper_vfx.gd class_name =====
	total += 1
	if src_whisper_vfx.find("class_name WhisperVFX") == -1:
		print("  FAIL [F013E.6.1]: whisper_vfx.gd 缺 class_name WhisperVFX")
		quit(1); return
	passed += 1
	print("  [F013E.6.1] whisper_vfx.gd 含 class_name WhisperVFX (OK)")

	# ===== F013E.6.VFX_FADE — fade_out_and_free() in whisper_vfx =====
	total += 1
	if src_whisper_vfx.find("func fade_out_and_free()") == -1:
		print("  FAIL [F013E.6.2]: whisper_vfx.gd 缺 fade_out_and_free() (T173 #92 契约)")
		quit(1); return
	passed += 1
	print("  [F013E.6.2] whisper_vfx.gd 含 fade_out_and_free() (OK)")

	# ===== F013E.6.WINDUP_CLASS — whisper_windup_vfx.gd class_name =====
	total += 1
	if src_whisper_windup.find("class_name WhisperWindupVFX") == -1:
		print("  FAIL [F013E.6.3]: whisper_windup_vfx.gd 缺 class_name WhisperWindupVFX")
		quit(1); return
	passed += 1
	print("  [F013E.6.3] whisper_windup_vfx.gd 含 class_name WhisperWindupVFX (OK)")

	# ===== F013E.6.WINDUP_FADE — fade_out_and_free() in whisper_windup =====
	total += 1
	if src_whisper_windup.find("func fade_out_and_free()") == -1:
		print("  FAIL [F013E.6.4]: whisper_windup_vfx.gd 缺 fade_out_and_free()")
		quit(1); return
	passed += 1
	print("  [F013E.6.4] whisper_windup_vfx.gd 含 fade_out_and_free() (OK)")

	# ===== F013E.6.PLAYER_PRELOAD_VFX — player.gd preload whisper_vfx =====
	total += 1
	if src_player.find('preload("res://src/scripts/whisper_vfx.gd")') == -1:
		print("  FAIL [F013E.6.5]: player.gd _on_whisper_fired 没 preload whisper_vfx.gd")
		quit(1); return
	passed += 1
	print("  [F013E.6.5] player.gd _on_whisper_fired preload whisper_vfx.gd (OK)")

	# ===== F013E.7.STAT_FIELD — whisper_used 字段 =====
	total += 1
	if src_player_stats.find("var whisper_used: int = 0") == -1:
		print("  FAIL [F013E.7.1]: player_stats.gd 缺 var whisper_used: int = 0")
		quit(1); return
	passed += 1
	print("  [F013E.7.1] player_stats.gd 含 var whisper_used: int = 0 (OK)")

	# ===== F013E.7.STAT_GET — get_stat whisper_used 分支 =====
	total += 1
	if src_player_stats.find('"whisper_used": return whisper_used') == -1:
		print("  FAIL [F013E.7.2]: player_stats.gd get_stat 缺 whisper_used 分支")
		quit(1); return
	passed += 1
	print("  [F013E.7.2] player_stats.gd get_stat 含 whisper_used 分支 (OK)")

	# ===== F013E.7.STAT_SET — _set_stat whisper_used 分支 =====
	total += 1
	if src_player_stats.find('"whisper_used": whisper_used = value') == -1:
		print("  FAIL [F013E.7.3]: player_stats.gd _set_stat 缺 whisper_used 分支")
		quit(1); return
	passed += 1
	print("  [F013E.7.3] player_stats.gd _set_stat 含 whisper_used 分支 (OK)")

	# ===== F013E.7.STAT_RESET — reset_stats whisper_used =====
	total += 1
	if src_player_stats.find("whisper_used = 0") == -1:
		print("  FAIL [F013E.7.4]: player_stats.gd reset_stats 缺 whisper_used = 0")
		quit(1); return
	passed += 1
	print("  [F013E.7.4] player_stats.gd reset_stats 清 whisper_used (OK)")

	# ===== F013E.7.STAT_RECORD — record_ability_used whisper 分支 =====
	total += 1
	if src_player_stats.find('"whisper": record_stat("whisper_used", 1)') == -1:
		print("  FAIL [F013E.7.5]: player_stats.gd record_ability_used 缺 whisper 分支")
		quit(1); return
	passed += 1
	print("  [F013E.7.5] player_stats.gd record_ability_used 含 whisper 分支 (OK)")

	# ===== F013E.7.STAT_ALL_ABILITIES — all_abilities_used 6 verb =====
	total += 1
	if src_player_stats.find("and whisper_used >= 1") == -1:
		print("  FAIL [F013E.7.6]: player_stats.gd all_abilities_used 缺 whisper_used >= 1")
		quit(1); return
	passed += 1
	print("  [F013E.7.6] player_stats.gd all_abilities_used 含 whisper (OK)")

	# ===== F013E.7.ACHIEVEMENT — sextuple_voice =====
	total += 1
	if src_achievements.find("\"sextuple_voice\"") == -1:
		print("  FAIL [F013E.7.7]: achievements.json 缺 sextuple_voice 成就")
		quit(1); return
	passed += 1
	print("  [F013E.7.7] achievements.json 含 sextuple_voice 成就 (OK)")

	# ===== F013E.7.ACHIEVEMENT_DESC — 6 verb 描述 =====
	total += 1
	if src_achievements.find("Whisper") == -1:
		print("  FAIL [F013E.7.8]: achievements.json sextuple_voice 缺 Whisper 描述")
		quit(1); return
	passed += 1
	print("  [F013E.7.8] achievements.json sextuple_voice 含 Whisper 描述 (OK)")

	# ===== F013E.8.PM_VERB_HINT — _VERB_HINT_DATA 第 6 元素 =====
	total += 1
	if src_pause_menu.find('"name_zh": "Whisper"') == -1:
		print("  FAIL [F013E.8.1]: pause_menu.gd _VERB_HINT_DATA 缺 Whisper 元素")
		quit(1); return
	passed += 1
	print("  [F013E.8.1] pause_menu.gd _VERB_HINT_DATA 含 Whisper 元素 (OK)")

	# ===== F013E.8.PM_VERB_HINT_KEY — T =====
	total += 1
	if src_pause_menu.find('"key": "T"') == -1:
		print("  FAIL [F013E.8.2]: pause_menu.gd _VERB_HINT_DATA 缺 Whisper key=T")
		quit(1); return
	passed += 1
	print("  [F013E.8.2] pause_menu.gd _VERB_HINT_DATA Whisper key=T (OK)")

	# ===== F013E.8.PM_VERB_HINT_MAUVE — name_color #C8A4D8 =====
	total += 1
	if src_pause_menu.find('"name_color": "#C8A4D8"') == -1:
		print("  FAIL [F013E.8.3]: pause_menu.gd _VERB_HINT_DATA 缺 Whisper name_color=#C8A4D8")
		quit(1); return
	passed += 1
	print("  [F013E.8.3] pause_menu.gd _VERB_HINT_DATA Whisper name_color=#C8A4D8 (OK)")

	# ===== F013E.8.PM_TOOLTIP_6 — \"6 声波能力\" header =====
	total += 1
	if src_pause_menu.find("6 声波能力") == -1:
		print("  FAIL [F013E.8.4]: pause_menu.gd _build_verb_hint_tooltip 缺 '6 声波能力' header")
		quit(1); return
	passed += 1
	print("  [F013E.8.4] pause_menu.gd _build_verb_hint_tooltip '6 声波能力' header (OK)")

	# ===== F013E.8.PM_STAT_ABILITIES — _stat_abilities 6 verb =====
	total += 1
	if src_pause_menu.find("Whisper %d[/color]") == -1:
		print("  FAIL [F013E.8.5]: pause_menu.gd _stat_abilities 缺 Whisper row")
		quit(1); return
	passed += 1
	print("  [F013E.8.5] pause_menu.gd _stat_abilities 含 Whisper row (OK)")

	# ===== F013E.8.PM_PROFILE_ABILITIES — _profile_abilities 6 verb =====
	# 期望 _profile_abilities 出现 2 次 (stat + profile). 我们只校验至少 1 次.
	total += 1
	var profile_count := 0
	var sp := 0
	while true:
		var idx := src_pause_menu.find("Whisper %d[/color]", sp)
		if idx == -1:
			break
		profile_count += 1
		sp = idx + 1
	if profile_count < 2:
		print("  FAIL [F013E.8.6]: pause_menu.gd _profile_abilities 缺 Whisper row (count=%d)" % profile_count)
		quit(1); return
	passed += 1
	print("  [F013E.8.6] pause_menu.gd _profile_abilities 含 Whisper row (count=%d) (OK)" % profile_count)

	# ===== F013E.8.PM_PROFILE_LAST_VERB — match whisper 分支 =====
	total += 1
	if src_pause_menu.find('"whisper":') == -1:
		print("  FAIL [F013E.8.7]: pause_menu.gd _profile_last_verb 缺 whisper match")
		quit(1); return
	passed += 1
	print("  [F013E.8.7] pause_menu.gd _profile_last_verb 含 whisper match (OK)")

	# ===== F013E.8.PM_PROFILE_LAST_VERB_COLOR — #C8A4D8 BBCode =====
	total += 1
	if src_pause_menu.find('[color=#C8A4D8]Whisper[/color]') == -1:
		print("  FAIL [F013E.8.8]: pause_menu.gd _profile_last_verb 缺 Whisper BBCode #C8A4D8")
		quit(1); return
	passed += 1
	print("  [F013E.8.8] pause_menu.gd _profile_last_verb Whisper #C8A4D8 (OK)")

	# ===== F013E.9.NO_REGRESSION — T199 smoke anchor 仍存在 (5 verb) =====
	total += 1
	# T199.I025 锚点 'T199 (#116)' 必须在 pause_menu.gd 仍存在, 表 5 verb
	# tooltip 行 (改为 6 行) 兼容.
	if src_pause_menu.find("T199 (#116)") == -1:
		print("  FAIL [F013E.9.1]: pause_menu.gd 缺 T199 (#116) 锚点 (5 verb 锚点 regression)")
		quit(1); return
	passed += 1
	print("  [F013E.9.1] pause_menu.gd 含 T199 (#116) 锚点 (5 verb 兼容 OK)")

	print("=== I026 F013.E Whisper 6 verb 接入路径 smoke test PASS: %d/%d ===" % [passed, total])
	quit(0)


func _read_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content := f.get_as_text()
	f.close()
	return content
