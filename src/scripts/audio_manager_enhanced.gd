extends Node

# Enhanced Audio Manager for Voxglass
# Provides placeholder SFX using procedural audio generation
# Plus procedural BGM themes (T062) — melancholic ambient pads with bell arpeggios.
#
# T121 #63 — BGM preset data (9 entries) and boss tier table
# (3 entries) extracted to `src/scripts/audio_presets.gd` (pure
# data, no methods) so this file stays focused on synthesis +
# state management.  Loaded below as a `const` (compile-time
# preload), then read as `AudioPresets.MUSIC_PRESETS` and
# `AudioPresets.BOSS_MUSIC_TIER` throughout this file.

const AudioPresets = preload("res://src/scripts/audio_presets.gd")

var _sfx_bus: int = 0
var _music_bus: int = 0
var _ambience_bus: int = 0

# Cached procedural streams
var _pulse_stream: AudioStreamWAV
var _footstep_stream: AudioStreamWAV
var _glass_break_stream: AudioStreamWAV
var _enemy_hum_stream: AudioStreamWAV
var _repair_stream: AudioStreamWAV
# F013 (#102) — Shop perk card SFX caches.  _shop_purchase_confirm is a
# single bright bell triad, _shop_level_up_streams is a per-level
# ascending arpeggio (keyed by current perk level 0..3 so the same
# perk upgrade from I→II→III always plays a higher arpeggio).  Cached
# because the shop menu is rare (5 perk levels × ~5 perks = ≤25 unique
# upgrade events per run) and the synth cost is non-trivial.
var _shop_purchase_confirm_stream: AudioStreamWAV
var _shop_level_up_streams: Dictionary = {}
# F004.B (#96) — 4 verb fire SFX streams (Bind / Cut / Echo / Wave).
# Lazy-initialised in their respective play_*() functions so _ready()
# stays cheap; the SFX are rare compared to footsteps/damage.  Cached
# after first play so subsequent calls reuse the synthesised stream.
# Each verb matches the visual motif of its windup VFX (Bind 螺旋 /
# Cut 斩 / Echo 撑 / Wave 涟漪) so the audio + visual tell are
# 1-shot cognitively.  See _generate_bind_sfx / _generate_cut_sfx /
# _generate_echo_sfx / _generate_wave_fire_sfx for timbre design.
var _bind_stream: AudioStreamWAV
var _cut_stream: AudioStreamWAV
var _echo_stream: AudioStreamWAV
var _wave_fire_stream: AudioStreamWAV
# T141 (#75) — Wave 命中 soft chime.  Cached on first play so we don't
# re-synthesise the 0.20s waveform on every hit.  Distinct from
# glass_break (noisy) — this is a clean high-frequency bell ping.
# T144 (#78) — Per wave_focus perk level (0-3) we keep 4 distinct
# streams in `_wave_hit_streams` keyed by int level.  Each level adds
# one higher harmonic on top of the base 1320Hz fundamental + 2.4x,
# so the player can *hear* the Wave radius grow (visual radius +
# 10/stack) as aural brightness +1 octave / stack.  Level 0 keeps
# the T141 signature (back-compat for saves / pre-T144 audio code).
var _wave_hit_streams: Dictionary = {}
# Minimum interval (s) between two wave_hit plays.  Prevents the
# SFX from stacking when wave hits 3-5 enemies in the same frame
# (the wave is AOE so a single cast can fan out across many targets).
const _WAVE_HIT_THROTTLE := 0.05
var _last_wave_hit_time_ms: int = -1

# T148 (#78) — Wave-combo "big AOE" chime tail.  Distinct from
# per-hit ping — fires once on a wave_combo (>=3 hits in a single
# cast, threshold defined in resonance_wave_ability.gd). 0.6s
# E6 + G#6 tritone (a small-major-third pair — not the harsh
# tritone we used for archive_storm, but a *sweeter* major-third
# stacked 6ths — gives "hero beat" rather than "danger beat")
# with a 0.6s decay envelope so the screen flash + this chime
# read as one event. Cached on first play (rare event, lazy
# init keeps _ready() cheap).
var _wave_combo_stream: AudioStreamWAV

# T153 (#79) — 存档槽位 jingle 区分。每个存档槽位 (0-4) 关联一个
# 上行 3 度五声音阶 (C5/E5/G5/C6/E6) 短 bell 音，让玩家在
# SaveLoadMenu 选择槽位时"听得出选的是哪个"。缓存按 slot_id
# 索引，因为每个槽位 jingle 都会在 save/load 时播放一次。
# 设计哲学：与存档槽位 1:1 映射，未来若加 slot 5+ 仍走
# 五声音阶上行模式（不会撞色也不会撞音）。amplitude 较低
# (0.10) 让 jingle 不抢 BGM / SFX 风头，0.25s 短促清晰。
const _SAVE_SLOT_MIDI_NOTES := [72, 76, 79, 84, 88]  # C5 / E5 / G5 / C6 / E6
var _save_slot_streams: Dictionary = {}

# F013 (#102) — Shop perk card SFX constants.  Per-level arpeggio base
# MIDI notes are intentionally 4 semitones apart (C4→D4→E4→F4) so the
# level-up chime always moves "up" by a major 2nd per level (perk
# I→II→III = "rising reward" feel) but never collides with verb fire
# SFX (Bind 240/360/480Hz low cluster, Cut 660Hz falling, Echo 660Hz
# bell, Wave 587Hz sustain).  4 levels cover perk 0=I (just bought) up
# through perk 3=IV (max in catalog).
const _SHOP_LEVEL_UP_LEVELS: int = 4
const _SHOP_LEVEL_UP_BASE_MIDI: Array = [60, 62, 64, 65]  # C4 / D4 / E4 / F4

# Cached BGM streams (T062)
var _music_streams: Dictionary = {}
var _current_music_player: AudioStreamPlayer = null
var _current_music_key: String = ""
# T239 (#157) — Active Music bus preview player (separate from the
# in-game _current_music_player; preview never touches _current_*).
# Used by SettingsMenu's "Preview" button to let the player test
# their Music bus volume slider without interrupting in-game BGM.
var _active_preview_player: AudioStreamPlayer = null

# F014 (#103) — Achievement unlock chime.  单 stream 即可 (不像 slot jingle
# 需要按 slot_id 区分), 用 G5 升 A5→C6→E6 三连音 + 三角波 + 0.4s 衰减
# 营造 "奖章落地" 的金属打击感.  amplitude 0.18 比 save_slot_jingle
# 0.10 稍大, 因为 achievement 是稀有事件 (14 个里触发一次), 值得
# 玩家"听得到".  与 F013 商店 purchase_confirm (C5+E5+G5 0.4s) 的
# 区别:  unlock 更高音域 (C6/E6 vs C5) + 4 个半音 (C6 1046, E6 1318,
# A6 1760) 暗示 "更稀有".  Lazy-init: 第一次成就解锁时合成并缓存.
# T208 (#126) — Per-achievement unique chimes.  之前 _unlock_chime_stream
# 是 1 个固定音色 (C6+E6+A6 金属三连音), 14 个成就共用同一段
# unlock 音效, 玩家听多了会"unlock 不分伯仲".  T208 让 14 成就
# 各自有独特 chord_midi (3-5 音) + duration + amp + decay 配方, 让
# "first_steps" 听感是 C 大调上行, "warden_slayer" 是 A 小调带增
# 四度, "silence_hunter" 是减七和弦 → 玩家解锁什么听就有什么音色
# (与 icon_hint 视觉分工一致: 14 视觉 + 14 听觉, 听觉冗余编码).
# 命名规则: key = achievement id, 与 data/achievements.json 一一对应.
# Default fallback (id == "" 或 id 不在 dict) 走原 C6+E6+A6 配方
# 保持向后兼容, 老调用方 play_unlock_chime() 不传 id 仍能工作.
const ACHIEVEMENT_CHIME_PRESETS := {
	# === first_steps: C 大调上行 4 音阶 (C5 E5 G5 C6) — 起步感 ===
	"first_steps": {"chord_midi": [72, 76, 79, 84], "duration": 0.5, "amp": 0.20, "decay": 5.0},
	# === voice_purifier: 纯五度 + 高八度 (C4 G4 C5) — 净化的"空" ===
	"voice_purifier": {"chord_midi": [60, 67, 72], "duration": 0.45, "amp": 0.20, "decay": 5.5},
	# === resonance_collector: G 大三 + 高八度 (G4 B4 D5 G5) — 收集的"满" ===
	"resonance_collector": {"chord_midi": [67, 71, 74, 79], "duration": 0.5, "amp": 0.20, "decay": 5.0},
	# === triple_voice: 3 音 (C4 E4 G4) — 三声齐鸣 ===
	"triple_voice": {"chord_midi": [60, 64, 67], "duration": 0.45, "amp": 0.20, "decay": 5.5},
	# === quadruple_voice: 4 音 (C4 E4 G4 B4 增三) — 升 1 度张力 ===
	"quadruple_voice": {"chord_midi": [60, 64, 67, 71], "duration": 0.5, "amp": 0.22, "decay": 5.0},
	# === quintuple_voice: 5 音全音阶 (C4 D4 E4 G4 A4) — 大师共鸣神秘 ===
	"quintuple_voice": {"chord_midi": [60, 62, 64, 67, 69], "duration": 0.55, "amp": 0.22, "decay": 4.5},
	# === first_cut: 三全音 (F#4 E6) — 锋利短促 0.35s ===
	"first_cut": {"chord_midi": [66, 78], "duration": 0.35, "amp": 0.22, "decay": 8.0},
	# === warden_slayer: A 小 + 增四度 (A3 C4 D#4 A#4) — 战胜压迫 ===
	"warden_slayer": {"chord_midi": [57, 60, 63, 70], "duration": 0.5, "amp": 0.22, "decay": 5.5},
	# === full_archive: G 大三 5 音 (G4 B4 D5 G5 B5) — 完整丰盈 ===
	"full_archive": {"chord_midi": [67, 71, 74, 79, 83], "duration": 0.6, "amp": 0.22, "decay": 4.0},
	# === persistent_resonance: D 小7 (D4 F4 A4 C5) — 持续柔和 ===
	"persistent_resonance": {"chord_midi": [62, 65, 69, 72], "duration": 0.55, "amp": 0.20, "decay": 4.5},
	# === long_road: C 小 (C4 Eb4 G4 C5) — 最长 0.65s 慢衰减 ===
	"long_road": {"chord_midi": [60, 63, 67, 72], "duration": 0.65, "amp": 0.20, "decay": 3.5},
	# === archive_master: C 大 5 音 (C4 E4 G4 C5 E5) — 大师级丰盈 amp 0.24 ===
	"archive_master": {"chord_midi": [60, 64, 67, 72, 76], "duration": 0.6, "amp": 0.24, "decay": 4.0},
	# === resonance_hoarder: A 小三 (A3 C4 E4 G4) — 积累的沉重 ===
	"resonance_hoarder": {"chord_midi": [57, 60, 64, 67], "duration": 0.5, "amp": 0.22, "decay": 5.0},
	# === silence_hunter: 减七 (C4 Eb4 Gb4 A4) — 黑暗低吟 ===
	"silence_hunter": {"chord_midi": [60, 63, 66, 69], "duration": 0.5, "amp": 0.22, "decay": 5.5},
	# T242 (#161) — Sextuple Voice 6/6 闭环: 第 15 成就 "sextuple_voice"
	# 解锁提示音 chord 接入. 14 → 15 成就 milestone 闭环 — 之前 14 preset
	# 14 成就, #159 T241 F013.E 加 Whisper 第 6 verb 时同步在 achievements.json
	# 加 sextuple_voice 第 15 成就, 但 ACHIEVEMENT_CHIME_PRESETS dict 仍 14 entry,
	# 玩家解锁 sextuple_voice 时走 default fallback (C6+E6+A6 老配方) — 0
	# 主题一致性, 0 6 verb 闭环 5+1 渐进听感. 配方 6 音全音阶 + 高八度
	# (C4 D4 E4 G4 A4 C5) 与 quintuple_voice 5 音全音阶 (C4 D4 E4 G4 A4)
	# 同源, +1 八度 (C5) 表 "闭环 + 提升" 语义. duration 0.65s (与 archive_master
	# 同档, 6 音最长维持听感), amp 0.24 (与 archive_master 同档, 6 音 6 声
	# 能量峰值), decay 4.0 (与 archive_master 同档, 6 音 0.65s 余韵).
	# 全音阶 (whole-tone) 6 音 0 半音冲突, 6 音 0 重复 8 度, 听感"漂浮、
	# 不着地、超脱" — 与 sextuple_voice "六声回响" 主题一致.
	"sextuple_voice": {"chord_midi": [60, 62, 64, 67, 69, 72], "duration": 0.65, "amp": 0.24, "decay": 4.0},
}
# T208 (#126) — Per-achievement cached chime streams.  Key = id.
# Lazy-init: 第一次某 id 解锁时合成并缓存.  Cache miss 安全: 未知
# id 走 _unlock_chime_stream (backward-compat) fallback.  15 成就
# 15 stream 一次性预热 ~3ms (与 F014 单 stream 同量级, T242 #161 +1 stream).
var _achievement_chime_streams: Dictionary = {}
var _unlock_chime_stream: AudioStreamWAV

# T208.B (#127) — 15 成就 → 9 BGM 主题 语义映射 (T242 #161 sextuple_voice
# 加入, 14 → 15 成就 milestone 闭环).  玩家解锁某成就时
# 不切换 BGM 主题 (会破坏当前房间听感), 但把 BGM "ducking" 一下让
# chime 听得更清楚, 然后再把 BGM 音量 lerp 回来.  语义映射供未来
# "the BGM 'matches' the unlock" 的特性用 (例如 hub_warm 成就解锁
# 之后 hub 主题里悄悄加一段铃铛 chord 暗示), 本轮只用作 logging
# + 留 API hook.  15 → 9 (允许 1 个 BGM 主题对应多个成就).
# 映射语义:  title_intro = 起步 (4 成就) / hub_warm = 温暖
# (3 成就) / archive_exploration = 探索 (2 成就) / archive_dawn
# = 胜利 (3 成就, T242 #161 +1) / whisper_hollow = 深度 (2 成就) /
# silence_void = 沉默 (1 成就).  Boss 主题 archive_boss / archive_boss_dual /
# archive_storm 故意不出现在 mapping 中 — Boss 战中 15 成就
# 不太可能解锁 (room 已经处于 "死战" 状态), 让 BGM 与成就
# 不撞色.
const ACHIEVEMENT_BGM_HINT := {
	# title_intro (4 成就) — 起步, 早期成就
	"first_steps": "title_intro",
	"voice_purifier": "title_intro",
	"resonance_collector": "title_intro",
	"persistent_resonance": "title_intro",
	# hub_warm (3 成就) — 温暖, 中心区域成就
	"triple_voice": "hub_warm",
	"quadruple_voice": "hub_warm",
	"quintuple_voice": "hub_warm",
	# archive_exploration (2 成就) — 探索, 战斗
	"first_cut": "archive_exploration",
	"warden_slayer": "archive_exploration",
	# archive_dawn (3 成就) — 胜利, 完整 (T242 #161 sextuple_voice 加入,
	# 6 verb 闭环 — "完整 6 声回响" 主题 = "archive_dawn" 胜利 + 完整
	# 主题 +1, 14→15 成就 milestone 闭环)
	"full_archive": "archive_dawn",
	"archive_master": "archive_dawn",
	"sextuple_voice": "archive_dawn",
	# whisper_hollow (2 成就) — 深度, 坚持
	"long_road": "whisper_hollow",
	"silence_hunter": "whisper_hollow",
	# silence_void (1 成就) — 沉默, 积累之重
	"resonance_hoarder": "silence_void",
}

# T208.B (#127) — BGM ducking for achievement chime layering.  与
# F014 / T208 在 SFX bus 上播放 chime 不同, ducking 在 Music bus
# 的 _current_music_player 上做 volume_db 短时下降 + 恢复.  让
# 14 成就 chime 听感 "在 BGM 之上" 而不 "取代 BGM".  -6 dB
# 持续 duration + 0.05s fade-in + 0.30s fade-out.  阈值:  -6 dB
# ≈ 音量减半, 玩家能清晰听到 chime 但 BGM 还在背景呼吸.
const _BGM_DUCK_DB := -6.0
const _BGM_DUCK_FADE_IN_S := 0.05
const _BGM_DUCK_FADE_OUT_S := 0.30
var _bgm_duck_tween: Tween = null

# F015 (#103) — SaveSlot 删除确认 click.  单 stream, 150Hz 方波 + 0.12s
# 衰减 → "嗒" 一声低 click, 与 save_slot_jingle 0.25s bell (C5..E6)
# 完全不同音色.  amplitude 0.20 比 jingle 0.10 强一些, 因为删除是
# "破坏" 语义, 提示音应比 "保存" 略重.  故意不与任何 verb SFX
# (Pulse/Bind/Cut/Echo/Wave 都在中高频) 撞色 → 走低音区
# 强调"删除 = 不可逆".
var _delete_confirm_stream: AudioStreamWAV

# F016 (#104) — Death lay-down "听见坠落" 低频 SFX (T075 0.4s
# 慢速低频).  75Hz 基频 (sub-bass 接近人声 lowest 男低) + 1.5x +
# 2.5x 谐波, exp(-t*4.0) 慢衰减 (与 T092 死亡 freeze 0.15s @ 0.2x
# 时长 + 1.0s fade-out 总 1.5s death animation 配合 — SFX 总长 0.4s
# 刚好铺满 lay-down 段).  与 F015 delete_confirm (150Hz 方波) 区别:
# delete 是 0.12s 短 click "嗒" 暗示"破坏性操作"; death 是 0.4s 长
# 嗡鸣 "呜——" 暗示"事件结束/失去意识".  amplitude 0.28 — 比 delete
# 0.20 强 (event 重要性 > 单次操作), 但仍 < verb fire 0.30-0.40
# (death 是一次性, verb fire 是玩家主动循环).  与 T092 死亡 red
# tint + T093 grayscale + T115 quote 4 段 death UX 段在听觉上同步:
# 玩家听见低频"呜" → 看屏红色 → 0.15s freeze → 0.3s grayscale
# → 0.5s lay-down → 1.0s fade-out 完整 loss-of-control 视听序列.
# 与 archive_storm BGM (T107 #60 64Hz sub-bass) 频段接近但音色
# 不同 (death 是单音 sustain, archive_storm 是 LFO 颤动), 避免
# Boss 战中死亡的 layer 频段冲突.
var _death_lay_down_stream: AudioStreamWAV

# F016.B (#108) — Death SFX idempotency guard. player.gd die() 入口
# 已经有 _is_dying 防止重入, 但万一未来引入多 death trigger (如
# ambient damage tick + 主动 kill) 同时调 play_death_lay_down,
# SFX bus 上会出现 2 个 0.4s 嗡鸣叠加, 玩家听见"加倍"嗡鸣很糟.
# 加 _death_sfx_playing 内部 flag, 与 player._is_dying 双重防御.
# 与 _music_final_playing 一样的 pattern: 进 _playing=true,
# 出时延迟 0.4s + 0.1s 缓冲 (略长于 SFX 时长 0.4s, 防止下次
# 调时 SFX 还没自然衰减就被截断).
var _death_sfx_playing: bool = false
const _DEATH_SFX_DURATION := 0.4
const _DEATH_SFX_GUARD_BUFFER := 0.1

# F013.B (#106) — Verb cooldown TAIL jingle.  与 T181 现有 ready
# jingle (verb 冷却结束 → 升 4 半音, 0.10s, 0.18 amp) 对偶, 这个
# family 是 verb 刚 cast 出去 / 刚进入冷却 → 降 4 半音 0.12s 0.18
# amp.  5 verb 共用 1 个 synth 函数, 只换 start_midi 起始音高
# (T181 ready 是 f0→f1 升 4 半音, TAIL 是 f1→f0 降 4 半音), 形
# 成"verb 锁了" vs "verb 解锁" 的对称音程感.  每 verb 5 stream
# cache (与 T181 ready 共用 5 verb 5 stream 模式), 5 verb pitch
# 范围 A4..C6 (与 T181 同 1.5 octave spread, 不撞色).  触发
# 位置: 5 verb _execute_*() 末尾 fire SFX 之后同帧, 让玩家听
# 见 "fire 重音" + "cooldown tail 琶音" 1 段 2 事件听觉序列.
# 防御:  6th verb 传未知 verb_name → 静默 no-op (与 T181 同).
var _verb_cooldown_tail_streams: Dictionary = {}

# T071 — Boss music override.  When non-empty, all play_music_track()
# calls are redirected to this key (transparently overriding the GFC
# state-machine routing).  Cleared by release_boss_music().
var _boss_override_key: String = ""
# Ref-count for active boss overrides (T067 — multiple bosses in
# the same room, e.g. archive_04 with 2 InkWardens).  Override
# stays active until count drops back to 0.
var _boss_override_count: int = 0

# Music presets: each track is a melancholic ambient pad + bell arpeggio + glass shimmer.
# MIDI numbers — A4 = 69, C4 = 60.  Chord = 3-note triad around root.
# Frequencies are derived via 440 * 2^((midi-69)/12).
#
# T121 #63 — 9 presets moved to `audio_presets.gd` (see AudioPresets
# const above).  Per-preset design notes (tempo, key, dissonance,
# volume ratios, LFO design philosophy) preserved verbatim in that
# file as long-form comments.  Code below reads them as
# `AudioPresets.MUSIC_PRESETS` and `AudioPresets.BOSS_MUSIC_TIER`.

func _ready() -> void:
	_setup_buses()
	_generate_placeholder_sfx()

func _setup_buses() -> void:
	_sfx_bus = AudioServer.get_bus_index("SFX")
	if _sfx_bus == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		_sfx_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_sfx_bus, "SFX")
	
	_music_bus = AudioServer.get_bus_index("Music")
	if _music_bus == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		_music_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_music_bus, "Music")
	
	_ambience_bus = AudioServer.get_bus_index("Ambience")
	if _ambience_bus == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		_ambience_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_ambience_bus, "Ambience")

func _generate_placeholder_sfx() -> void:
	_pulse_stream = _generate_pulse_sfx()
	_footstep_stream = _generate_footstep_sfx()
	_glass_break_stream = _generate_glass_break_sfx()
	_enemy_hum_stream = _generate_enemy_hum_sfx()
	_repair_stream = _generate_repair_sfx()
	# F004.B (#96) — 4 verb fire SFX streams are lazy-initialised in their
	# respective play_*() functions to keep _ready() cheap.  Each verb
	# gets its own timbre matching its visual motif:
	#   Bind = 220Hz low drone pull-in (0.40s, matches Bind 0.10s windup)
	#   Cut  = 1500Hz sharp slash (0.08s, matches Cut 0.04s windup)
	#   Echo = 1320Hz glass shield ping (0.15s, matches Echo 0.08s windup)
	#   Wave = 100Hz low bloom (0.30s, matches Wave 0.10s windup)
	# see play_bind() / play_cut() / play_echo() / play_wave_fire() below.
	# T141 (#75) — Wave hit chime (lazy-initialised in play_wave_hit()
	# to keep _ready() cheap; the sfx is rare compared to footsteps).

func _generate_pulse_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.3
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 440.0 * (1.0 + t * 2.0)  # Rising frequency
		var env := exp(-t * 8.0)  # Exponential decay
		var sample := sin(t * TAU * freq) * env * 0.3
		# Add harmonic
		sample += sin(t * TAU * freq * 2.5) * env * 0.15
		# Convert to 16-bit
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Bind fire SFX.
# Design: low 220Hz drone (E3) with descending pitch sweep (220→165Hz)
# over 0.40s, paired with a 2x soft harmonic.  The descending sweep
# reads as "pulling something toward you" — matching the Bind 螺旋
# windup VFX's "1.0×→0.85× spiral" contraction visual.  Slow decay
# (exp -4.0) lets the tail blend into the Bind hit chime naturally
# without abrupt cutoff.  Amplitude 0.32 matches the Bind verb's
# "mid-weight" intensity (heavier than Pulse's 0.30, lighter than
# the boss-override finales).  Used by bind_ability.gd when the
# bind_fired signal fires (T181 candidate) to close the 5 verb
# audio family loop (Bind has had play_bind_hit callers for a
# while; this is the missing fire counterpart).
func _generate_bind_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.40
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 220.0 * (1.0 - t * 0.25)  # 220 → 165Hz pull
		var env := exp(-t * 4.0)
		var sample := sin(t * TAU * freq) * env * 0.32
		sample += sin(t * TAU * freq * 2.0) * env * 0.12
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Cut fire SFX.
# Design: sharp 1500Hz transient with quick drop to 800Hz, paired
# with white-noise burst on the first 0.02s.  The "swoosh" feel
# matches the Cut streak windup VFX's "0.0×→1.0× slash" visual
# — a quick bright attack followed by a fast settling.  Very
# short (0.08s) so it doesn't overlap the Cut hit chime (which
# fires ~50ms later when the arc lands).  Amplitude 0.40 (highest
# of the 4 verb fire SFX) because Cut is the most "kinetic" verb
# in the family — the slash has to be heard over Bind/Wave.  Used
# by cut_ability.gd when the cut_fired signal fires.
func _generate_cut_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.08
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 1500.0 * (1.0 - t * 0.5)  # 1500 → 750Hz drop
		var env := exp(-t * 35.0)
		var sample := sin(t * TAU * freq) * env * 0.40
		# First 0.02s: noise burst for "whoosh"
		if t < 0.02:
			sample += randf_range(-1.0, 1.0) * env * 0.20
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Echo fire SFX.
# Design: clean 1320Hz (near E6) bell ping with 1.5x soft harmonic
# and a 0.15s decay.  Reuses the same fundamental as play_wave_hit
# (T141 #75) but with shorter decay — Echo's fire has to feel
# "instant" and "protective" while wave_hit can be longer.  Matches
# the Echo windup VFX's "0.5×→1.0× 球外撑" visual — a single
# rising-timbre note.  Amplitude 0.35 (mid-weight, like Pulse).
# Used by echo_ability.gd when the echo_fired signal fires.
func _generate_echo_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.15
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 18.0)
		var sample := sin(t * TAU * 1320.0) * env * 0.35
		sample += sin(t * TAU * 1320.0 * 1.5) * env * 0.12
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F004.B (#96) — Wave fire SFX.
# Design: low 100Hz (G2) bloom with a 220Hz perfect-fifth (B2)
# layered on top, slow decay (exp -3.0) over 0.30s.  The "wide
# low rumble + soft mid bell" timbre matches the Wave windup
# VFX's "3 环 ripple outward" visual — a deep omnidirectional
# wave.  Reuses the same 100/220Hz pairing as intro_ambience
# (T122 #64) for tonal continuity between the title screen
# drone and the Wave fire.  Amplitude 0.28 (lightest of the
# 4 verb fire SFX) because Wave is "soft omnidirectional" —
# the player should *feel* the AOE without it dominating the
# mix.  Used by resonance_wave_ability.gd when wave_fired
# signal fires.
func _generate_wave_fire_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.30
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 3.0)
		var sample := sin(t * TAU * 100.0) * env * 0.28
		sample += sin(t * TAU * 220.0) * env * 0.14
		# Soft 2x harmonic on the low note for "body"
		sample += sin(t * TAU * 200.0) * env * 0.08
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Pulse hit SFX.
# Design: 220Hz low thud with 1.0× exp(-t*22) decay over 0.18s.
# Matches the Pulse fire SFX's "low energy" register (Pulse fire is
# 440→1320Hz rising; Pulse hit drops back to a 220Hz thud for the
# "shockwave landed" moment).  Amplitude 0.30 (mid-weight, matches
# Pulse fire 0.30) so the cast is balanced fire-then-hit volume.
# Called from player.gd._on_pulse_hit when an enemy enters the
# expanding pulse ring.  Throttled by _VERB_HIT_THROTTLE (50ms)
# so a Pulse that hits 4 enemies in 0.05s doesn't stack 4 thuds.
#
# T181.B (#100) — `perk_level` 0..3 maps to pulse_focus purchase
# count (shop_catalog.json max_purchases=3).  Higher levels add
# extra mid-range overtones to the base 220Hz+440Hz pair, so each
# perk-stack sounds "rounder" / "more present" — mirroring the
# visible Pulse radius growth.  All harmonics decay at the same
# exp(-t * 22) envelope so they stay inside the 0.18s window:
#   level 0 (no perk) — 220Hz fundamental + 440Hz (2×) harmonic
#   level 1 — + 660Hz (3×, perfect-5th above 2×)
#   level 2 — + 880Hz (4×, octave above 2×, "wider bell")
#   level 3 — + 1100Hz (5×, major-3rd above 4×, "triumph")
# Clamp perk_level to [0, 3] to be safe against any caller passing
# a value outside the buyable range.
func _generate_pulse_hit_sfx(perk_level: int = 0) -> AudioStreamWAV:
	var safe_level: int = clampi(perk_level, 0, 3)
	var sample_rate := 44100
	var duration := 0.18
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 22.0)
		# Base: 220Hz fundamental + 440Hz (2×) harmonic
		var sample := sin(t * TAU * 220.0) * env * 0.30
		sample += sin(t * TAU * 440.0) * env * 0.12
		# T181.B per-level extra mid-range overtones
		var extra: float = 0.0
		match safe_level:
			1:
				extra = sin(t * TAU * 660.0) * 0.08
			2:
				extra = sin(t * TAU * 660.0) * 0.08 \
						+ sin(t * TAU * 880.0) * 0.06
			3:
				extra = sin(t * TAU * 660.0) * 0.08 \
						+ sin(t * TAU * 880.0) * 0.06 \
						+ sin(t * TAU * 1100.0) * 0.04
		sample += extra * env
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Bind hit SFX.
# Design: 165Hz low thunk with 1.0× exp(-t*18) decay over 0.22s.
# Matches the Bind fire SFX's 220→165Hz "pull" sweep — the hit
# drops to the *end* of the sweep at 165Hz for the "pulled target
# stuck" moment.  Slightly longer decay (0.22s) than Pulse hit
# (0.18s) because Bind is a "hold" verb (the pull keeps tension
# for ~0.6s in the windup VFX).  Amplitude 0.32 (matches Bind
# fire 0.32).  Called from player.gd._on_bind_hit.  Throttled by
# _VERB_HIT_THROTTLE.
func _generate_bind_hit_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.22
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 18.0)
		var sample := sin(t * TAU * 165.0) * env * 0.32
		# Soft 2x harmonic for "grab" body
		sample += sin(t * TAU * 330.0) * env * 0.10
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Cut hit SFX.
# Design: 2000Hz bright shing with 0.5× fast decay (exp -45, ~22ms
# perceptual "ping").  Matches the Cut fire SFX's 1500→750Hz slash
# — the hit jumps *above* the fire for the "sword landed bright"
# moment, then drops to silence fast (sharp attack, no tail).  The
# short 0.05s duration is intentionally MUCH shorter than Pulse
# (0.18s) or Bind (0.22s) hits because Cut's identity is "kinetic
# slash" — a long tail would feel like a "thump" not a "shing".
# Amplitude 0.38 (high, second only to Cut fire 0.40) so the
# landing reads above Pulse / Bind hits.  Called from
# player.gd._on_cut_hit.  Throttled by _VERB_HIT_THROTTLE.
#
# T181.B (#100) — `perk_level` 0..3 future-proof parameter (no
# shop perk for Cut yet, but the level-arg signature mirrors T144
# wave_hit_sfx so a future "cut_focus" perk (or any perk that
# stacks on Cut) can land without re-architecting).  Higher
# levels add extra high-frequency overtones (3.5×, 4.5×, 5.5×)
# to the base 2000Hz fundamental + 3× pair, so each perk-stack
# sounds "brighter" / "more ring-out":
#   level 0 (no perk) — 2000Hz + 6000Hz (3×)
#   level 1 — + 7000Hz (3.5×, perfect-5th above 3×)
#   level 2 — + 9000Hz (4.5×, octave above 3.5×, "wider ring")
#   level 3 — + 11000Hz (5.5×, tritone above 4.5×, "sword sings")
# All harmonics decay at the same exp(-t * 45) envelope so they
# stay inside the 0.05s window.  Clamp perk_level to [0, 3] for
# the same caller-safety rationale as pulse_hit_sfx above.
func _generate_cut_hit_sfx(perk_level: int = 0) -> AudioStreamWAV:
	var safe_level: int = clampi(perk_level, 0, 3)
	var sample_rate := 44100
	var duration := 0.05
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 45.0)
		# Base: 2000Hz fundamental + 6000Hz (3×) harmonic
		var sample := sin(t * TAU * 2000.0) * env * 0.38
		sample += sin(t * TAU * 6000.0) * env * 0.08
		# T181.B per-level extra high-frequency overtones
		var extra: float = 0.0
		match safe_level:
			1:
				extra = sin(t * TAU * 7000.0) * 0.05
			2:
				extra = sin(t * TAU * 7000.0) * 0.05 \
						+ sin(t * TAU * 9000.0) * 0.04
			3:
				extra = sin(t * TAU * 7000.0) * 0.05 \
						+ sin(t * TAU * 9000.0) * 0.04 \
						+ sin(t * TAU * 11000.0) * 0.03
		sample += extra * env
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Echo hit SFX.
# Design: 1980Hz glass tap with 0.5× fast decay (exp -38, ~26ms
# perceptual "tink").  Matches the Echo fire SFX's 1320Hz bell
# ping — the hit jumps *above* the fire for the "shield caught
# a hit" moment, with a very fast decay so it reads as "tap"
# not "ring".  Slightly longer decay than Cut (0.06s vs 0.05s)
# because glass rings longer than steel.  Amplitude 0.30 (mid,
# same as Echo fire 0.35 - 0.05 because the shield-already-popped
# fire volume is "set" — the hit can be slightly quieter).
# Called from player.gd._on_echo_hit.  Throttled by _VERB_HIT_THROTTLE.
#
# T181.B (#100) — `perk_level` 0..3 maps to echo_charm purchase
# count (shop_catalog.json max_purchases=1 — clamped at 1 by
# the shop UI, but the synth supports 0..3 for symmetry with
# Pulse/Wave perk-level audio scaling).  Higher levels add
# extra high-frequency overtones (3.4×, 4.4×, 5.4×) to the base
# 1980Hz + 2.4× pair, so each perk-stack sounds "brighter" /
# "more glass-resonant":
#   level 0 (no perk) — 1980Hz + 2.4× (= 4752Hz)
#   level 1 — + 3.4× (= 6732Hz, perfect-5th above 2.4×)
#   level 2 — + 4.4× (= 8712Hz, octave above 3.4×, "wide ring")
#   level 3 — + 5.4× (= 10692Hz, major-3rd above 4.4×, "shatter")
# All harmonics decay at the same exp(-t * 38) envelope so they
# stay inside the 0.06s window.  Clamp perk_level to [0, 3] for
# the same caller-safety rationale.
func _generate_echo_hit_sfx(perk_level: int = 0) -> AudioStreamWAV:
	var safe_level: int = clampi(perk_level, 0, 3)
	var sample_rate := 44100
	var duration := 0.06
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 38.0)
		# Base: 1980Hz fundamental + 2.4× (= 4752Hz) harmonic
		var sample := sin(t * TAU * 1980.0) * env * 0.30
		sample += sin(t * TAU * 1980.0 * 2.4) * env * 0.10
		# T181.B per-level extra high-frequency overtones
		var extra: float = 0.0
		match safe_level:
			1:
				extra = sin(t * TAU * 1980.0 * 3.4) * 0.06
			2:
				extra = sin(t * TAU * 1980.0 * 3.4) * 0.06 \
						+ sin(t * TAU * 1980.0 * 4.4) * 0.05
			3:
				extra = sin(t * TAU * 1980.0 * 3.4) * 0.06 \
						+ sin(t * TAU * 1980.0 * 4.4) * 0.05 \
						+ sin(t * TAU * 1980.0 * 5.4) * 0.04
		sample += extra * env
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T181 (#97 first half) — Verb cooldown "ready" jingle synth.
# Design: short ascending two-note bell (0→0.10s) at the start_midi
# frequency, with a 4-semitone ascent over the duration
# (e.g. A4=440Hz → C5=523Hz).  The two notes are mixed 50/50
# across the duration envelope so the "ascending" feel comes from
# a single sine sweeping up rather than two distinct notes (cleaner
# at 0.10s).  exp(-t*15) envelope (0.10s perceptual).  Amplitude
# 0.18 — the jingle is the quietest of the 5-verb family because
# it's a "status" cue, not a "moment" cue (fire=0.30-0.40, hit=
# 0.30-0.38, jingle=0.18).  All 5 verbs share the same synth —
# only start_midi differs (see _verb_cooldown_start_midi).
func _generate_verb_cooldown_jingle(start_midi: int) -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.10
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# A4=69.  midi → Hz: f = 440 * 2^((midi-69)/12)
	var f0: float = 440.0 * pow(2.0, float(start_midi - 69) / 12.0)
	var f1: float = 440.0 * pow(2.0, float(start_midi - 69 + 4) / 12.0)  # 4 semitones up
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Linear frequency ramp f0 → f1 across the duration
		var freq: float = f0 + (f1 - f0) * (t / duration)
		var env := exp(-t * 15.0)
		var sample := sin(t * TAU * freq) * env * 0.18
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F013.B (#106) — Verb cooldown TAIL jingle synth (降 4 半音 0.12s).
# 与 T181 现有 _generate_verb_cooldown_jingle (f0→f1 升 4 半音 0.10s
# exp(-t*15)) 对偶, 这个函数 f1→f0 降 4 半音 0.12s exp(-t*12) 略慢
# 衰减.  5 verb 共用 1 个 synth, start_midi 是 "TAIL 起点 MIDI"
# (verb 进入冷却瞬间的音高 = T181 ready 终点 = T181 起点 + 4 半音).
# 方向 reverse 暗示 "verb 刚锁住, 音高下沉"; amplitude 0.18 与 T181
# ready 一致, 不抢 verb fire SFX (0.30-0.40) 风头.  0.12s 比 T181
# ready 0.10s 长 0.02s, 因为 "进入冷却" 是 event start 需要更明显
# 一点 (T181 是 event end 短促即可).
func _generate_verb_cooldown_tail_jingle(start_midi: int) -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.12
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# A4=69.  midi → Hz: f = 440 * 2^((midi-69)/12)
	var f0: float = 440.0 * pow(2.0, float(start_midi - 69) / 12.0)
	var f1: float = 440.0 * pow(2.0, float(start_midi - 69 - 4) / 12.0)  # 4 semitones down
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Reverse ramp: f0 → f1 (降 4 半音)
		var freq: float = f0 + (f1 - f0) * (t / duration)
		var env := exp(-t * 12.0)  # 略慢衰减
		var sample := sin(t * TAU * freq) * env * 0.18  # 与 T181 ready 同 amplitude
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_footstep_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.15
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var noise := randf_range(-1.0, 1.0)
		var env := exp(-t * 20.0)
		var sample := noise * env * 0.15
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_glass_break_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.5
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var noise := randf_range(-1.0, 1.0)
		var env := exp(-t * 6.0)
		# High-frequency content for glass
		var ring := sin(t * TAU * 2000.0) * exp(-t * 15.0) * 0.2
		var sample := (noise * 0.3 + ring) * env * 0.25
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T141 (#75) — Wave hit "soft chime" SFX.
# Design: a clean high-frequency bell ping (~1320Hz fundamental, near E6)
# with a 2.4x harmonic, exponential decay over 0.20s.  Distinct from
# glass_break (which is noisy + 0.5s + 2000Hz ring) — this is a short
# "tink" that says "the wave touched a target" without dominating the
# mix.  Paired with the VFX hit_flash (Warm Parchment circle) so the
# player gets a matched visual + audio beat on every wave hit.
func _generate_wave_hit_sfx(perk_level: int = 0) -> AudioStreamWAV:
	# T144 (#78) — `perk_level` 0..3 maps to wave_focus purchase count.
	# Higher levels add one extra high harmonic on top of the base
	# fundamental + 2.4x pair, so each perk-stack sounds "brighter".
	#   level 0 (no perk) — 1320Hz + 2.4x (T141 baseline)
	#   level 1 — + 3.6x (perfect 5th above 2.4x)
	#   level 2 — + 5.0x (major 6th above 3.6x, ringing "big bell")
	#   level 3 — + 6.8x (minor 7th above 5.0x, "triumph" — almost bell-tower)
	# All harmonics decay at the same exp(-t * 14) envelope so they
	# remain in the same 0.20s window.  Clamp perk_level to [0, 3] to
	# be safe against any caller passing a value outside the buyable
	# range (max_purchases = 3 in shop_catalog.json).
	var safe_level: int = clampi(perk_level, 0, 3)
	var sample_rate := 44100
	var duration := 0.20
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 14.0)
		# Fundamental + 2.4x harmonic — detuned harmonic gives a
		# "metallic but soft" bell timbre (pure 2.0x would be octave-only
		# and feel "blunt"; 2.4x is a small-major-third above the octave
		# and adds the glassy shimmer without harshness).
		var fundamental := sin(t * TAU * 1320.0) * 0.45
		var harmonic := sin(t * TAU * 1320.0 * 2.4) * 0.15
		# Per-level extra high harmonics (T144).  Each added with
		# decreasing amplitude so they don't clip or dominate the base.
		var extra: float = 0.0
		match safe_level:
			1:
				extra = sin(t * TAU * 1320.0 * 3.6) * 0.10
			2:
				extra = sin(t * TAU * 1320.0 * 3.6) * 0.10 \
						+ sin(t * TAU * 1320.0 * 5.0) * 0.07
			3:
				extra = sin(t * TAU * 1320.0 * 3.6) * 0.10 \
						+ sin(t * TAU * 1320.0 * 5.0) * 0.07 \
						+ sin(t * TAU * 1320.0 * 6.8) * 0.05
		var sample := (fundamental + harmonic + extra) * env * 0.35
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T148 (#78) — Wave-combo tail chime.
# 0.6s decay envelope on a stacked-6th pair (E6 ≈ 1318.5Hz + G#6 ≈ 1661.2Hz
# — minor-3rd, NOT the harsh tritone used in archive_storm).  The chord
# is the "triumph" interval: evokes "the wave did something big".  The
# 0.6s duration matches ScreenShake.flash_color(0.18s) + the 0.4s shake
# roughly, so the audio + visual + tactile feedback are temporally
# aligned (the chime tail outlasts the flash, reinforcing the event).
# 0.15 amplitude (lower than per-hit 0.35) so a 0.4s long tone doesn't
# dominate over the BGM (the wave_combo is meant to be a *complement*
# to the Electric Violet flash, not a standalone fanfare).
func _generate_wave_combo_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.60
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Slower decay than per-hit (0.20s * 14 = 2.8), so the
		# 0.6s tail is fully audible but fades by t=0.5s.
		var env := exp(-t * 6.0)
		# E6 (1318.5Hz ≈ 1320Hz round) + G#6 (1661.2Hz) — minor 3rd.
		# Slight 0.5Hz LFO detune on the upper voice for "swell" feel.
		var lo := sin(t * TAU * 1318.5) * 0.5
		var hi := sin(t * TAU * (1661.2 + sin(t * 0.5) * 0.5)) * 0.4
		# 1.5x soft harmonic on the lo voice for the "bell body".
		var body := sin(t * TAU * 1318.5 * 1.5) * 0.2
		var sample := (lo + hi + body) * env * 0.35
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T153 (#79) — 生成存档槽位 jingle。每个 slot_id 对应一个 C5/E5/G5/
# C6/E6 上行 3 度五声音阶 (pentatonic 跳过 D/F/A/B 形成"无半音
# 张力"的愉快听感) 短 bell 音。基础公式: 0.25s 三角波 + 1.5x
# soft harmonic 制造 "bell body" + exp decay 0.5s 让尾音不抢。
# amplitude 0.10 — 比 per-hit wave (0.35) 弱，比 footstep (0.04)
# 强；定位是"按钮反馈"级：明显但不喧宾夺主。
# slot_id 超出 [0, 4] 范围时回退到 C5 (slot 0) — 防御性默认，
# 不抛错（因为槽位选择是高频 UI 事件，不能因为 jingle 失败
# 阻断玩家的 save/load 流程）。
func _generate_save_slot_jingle(slot_id: int) -> AudioStreamWAV:
	var sample_rate := 22050  # jingle 不需要 full 44.1k
	var duration := 0.25
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# Clamp slot_id 到 [0, 4]；越界回退到 slot 0
	var idx: int = slot_id
	if idx < 0 or idx >= _SAVE_SLOT_MIDI_NOTES.size():
		idx = 0
	var midi: int = _SAVE_SLOT_MIDI_NOTES[idx]
	var freq: float = _midi_to_hz(midi)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Bell body: fundamental + 1.5x soft harmonic
		var env := exp(-t * 8.0)  # ~0.5s decay
		# 三角波比纯正弦更"亮"，但比方波柔和；用 sin + sin(x/2)
		# 近似三角波
		var fundamental: float = sin(t * TAU * freq)
		var triangle: float = (2.0 / PI) * asin(clampf(fundamental, -1.0, 1.0))
		var body: float = sin(t * TAU * freq * 1.5) * 0.4
		var sample: float = (triangle * 0.6 + body) * env * 0.10
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F014 (#103) — Achievement unlock chime synth.  三个音的"金属奖章"感:
# C6 1046.50Hz + E6 1318.51Hz + A6 1760.00Hz 上行小三度 (C6→E6) +
# 纯五度 (E6→A6) 4 个半音, 三角波 + 1.5x/2x 谐波 overtones 模仿
# 真实金属 (铜/银) 的多模态共振.  0.4s 总时长, 衰减常数 6.0
# (比 save_slot_jingle 8.0 慢 → "rings" 更长, 强化"奖章" 仪式感).
# Amplitude 0.18, 比 save_slot_jingle 0.10 强 (achievement 是稀有
# 事件, 听感优先级高于日常存档) 但仍低于 verb fire 0.40 (那是
# 玩家主动操作的反馈, 优先级最高).  sample_rate 22050 (与 slot
# jingle 一致, chime 不需要 44.1k 的高频延伸).
#
# 与 F013 purchase_confirm (C5+E5+G5 0.4s 0.16amp) 的音色区别:
#  - 更高音域: C6/E6/A6 vs C5/E5/G5 (octave above)
#  - 不同泛音比例: 本函数 overtones 1.5x/2x vs F013 的 0.32amp
#  - 听觉印象:  unlock = "叮——" (金属奖章),  purchase = "哇——" (温暖和弦)
# 不会混淆.
func _generate_unlock_chime_sfx() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.4
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 6.0)  # ~0.5s decay
		# Fundamental C6 (1046.50Hz) + 1.5x + 2x overtones → 金属多模态
		var fundamental: float = sin(t * TAU * 1046.50)
		var overtone1: float = sin(t * TAU * 1318.51) * 0.5  # E6 (小三度)
		var overtone2: float = sin(t * TAU * 1760.00) * 0.3  # A6 (纯五度)
		var sample: float = (fundamental * 0.6 + overtone1 + overtone2) * env * 0.18
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T208 (#126) — Per-achievement unique chime synth (parameter-driven).
# 与 F014 单 _generate_unlock_chime_sfx (C6+E6+A6 固定) 不同, 本函数
# 接受 preset dict 包含 chord_midi 数组, 让 14 成就各自有独特 chord
# (3-5 音) + duration (0.35-0.65s) + amp (0.20-0.24) + decay (3.5-8.0)
# 配方.  合成方式: chord 内的每个 MIDI 转换为 Hz, 全部叠加为单
# AudioStreamWAV (与 F014 同样 sample_rate 22050 单声道), envelope
# 统一 exp(-t*decay), 振幅统一 preset.amp.  权重 = 1/n (n 越大每
# 音越弱, 整体不超 amp).  听感: first_steps (C5 E5 G5 C6 上行) vs
# silence_hunter (C4 Eb4 Gb4 A4 减七) → 14 成就 14 独特音色, 与
# icon_hint 视觉分工对齐.  波形生成与 F014 用同一个 sin + exp 模式,
# 不引入新依赖.
#
# Preset 字段约定 (ACHIEVEMENT_CHIME_PRESETS 一一对应):
#   chord_midi: Array[int]  — 3-5 个 MIDI 数字, A4=69
#   duration:   float       — 秒 (0.35-0.65, 7 桶平均 0.5)
#   amp:        float       — 整体振幅 (0.20-0.24)
#   decay:      float       — exp(-t*decay) 衰减常数 (3.5-8.0)
# Sample 计算: sample = (Σ sin(t*TAU*Hz_i) / N) * env * amp
# N = chord_midi.size(), 让总能量不超 amp 避免 14 成就 stream clip.
func _generate_achievement_chime_sfx(preset: Dictionary) -> AudioStreamWAV:
	var chord_midi: Array = preset.get("chord_midi", [72, 76, 79])
	var duration: float = float(preset.get("duration", 0.5))
	var amp: float = float(preset.get("amp", 0.20))
	var decay: float = float(preset.get("decay", 5.0))
	var sample_rate := 22050
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# Pre-compute per-note frequencies (MIDI → Hz via A4=69)
	var freqs: Array[float] = []
	for midi in chord_midi:
		freqs.append(440.0 * pow(2.0, (float(midi) - 69.0) / 12.0))
	var n: int = freqs.size()
	var inv_n: float = 1.0 / float(n)  # Equal weight per note
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * decay)
		var sum_sin: float = 0.0
		for freq in freqs:
			sum_sin += sin(t * TAU * freq)
		var sample: float = sum_sin * inv_n * env * amp
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F015 (#103) — Save slot delete confirm click synth.  设计目标:
# 一声低沉的"嗒", 警告玩家"这是破坏性操作, 不可逆".  与所有
# 其他 SFX (verb fire/hit, slot jingle, unlock chime 都在中高频)
# 反向而行, 走 150Hz 基频 + 1.5x + 3x 谐波, 全部 < 500Hz 暗示
# "沉重/下坠".  方波 (用 sign(sin) 近似) 比正弦更"硬", 0.12s
# 短衰减 (常数 25.0 → ~40ms perceptual) 让 click 干脆不拖沓.
# Amplitude 0.20, 比 save_slot_jingle 0.10 强一倍, 暗示
# 重要性 (删除 > 保存的语义).
#
# 与 F013 shop level_up arpeggio (3 音 0.30s sweep) 的区别:
#  - 单音短 click vs 三音长 arpeggio
#  - 低音区 150Hz vs 中音区 C4..F4
#  - "嗒" vs "叮——咚" 玩家听到第一声就知道是删除.
func _generate_delete_confirm_sfx() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.12
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 25.0)  # ~40ms decay (短促)
		# Square wave approximation via sign(sin) — 更"硬" 边沿
		var fundamental: float = 1.0 if sin(t * TAU * 150.0) >= 0.0 else -1.0
		var overtone1: float = sin(t * TAU * 225.0) * 0.4  # 1.5x
		var overtone2: float = sin(t * TAU * 450.0) * 0.2  # 3x
		var sample: float = (fundamental * 0.7 + overtone1 + overtone2) * env * 0.20
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F016 (#104) — Death lay-down "听见坠落" 0.4s 低频嗡鸣.  设计目标:
# 与 T092 死亡 freeze-frame (0.15s @ 0.2x scale) + T093 0.3s
# grayscale + T075 0.5s lay-down + 1.0s fade-out 总 1.5s death
# animation 视听序列在听觉上同步.  75Hz 基频 (sub-bass, D2) +
# 1.5x (D3 112.5Hz) + 2.5x (F3 187.5Hz) 谐波 → "呜——" 慢速
# 衰减暗示"失去意识".  exp(-t*4.0) 让 SFX 持续 0.4s 自然 fade
# (常数 4.0 比 delete 25.0 / verb fire 35.0 慢 ~7x, 与 lay-down
# 0.5s 完美匹配).  amplitude 0.28 — 比 delete 0.20 强 (一次性
# 事件 > 单次操作), 但仍 < verb fire 0.30-0.40 (death 是一次性,
# verb fire 是玩家主动循环).  与 F015 delete_confirm (150Hz
# 方波 0.12s click) 区别:  delete 是 "嗒" 暗示"破坏性操作";
# death 是 "呜——" 暗示"事件结束/失去意识".  故意不与任何 verb
# SFX 撞色 (Pulse/Bind/Cut/Echo/Wave 都在中高频), 走 sub-bass
# 区 — 玩家"听见"事件结束, 而不是"听见"玩家做了操作.
#
# 与 archive_storm BGM (T107 #60 64Hz sub-bass + LFO 颤动) 频
# 段接近但音色不同:  death 是单音 0.4s 慢衰减, archive_storm
# 是 30s 长 loop LFO 颤动, 避免 Boss 战中死亡时频段冲突.
func _generate_death_lay_down_sfx() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.4
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var env := exp(-t * 4.0)  # 0.4s 慢衰减 (与 lay-down 0.5s 完美匹配)
		# Sub-bass 75Hz 基频 + 1.5x (D3) + 2.5x (F3) 谐波 → 嗡鸣
		var fundamental: float = sin(t * TAU * 75.0)
		var overtone1: float = sin(t * TAU * 112.5) * 0.5  # 1.5x
		var overtone2: float = sin(t * TAU * 187.5) * 0.3  # 2.5x
		var sample: float = (fundamental * 0.6 + overtone1 + overtone2) * env * 0.28
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_enemy_hum_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 1.0
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 80.0 + sin(t * 2.0) * 10.0  # Subtle modulation
		var sample := sin(t * TAU * freq) * 0.08
		sample += sin(t * TAU * freq * 1.5) * 0.04
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.data = data
	return stream

func _generate_repair_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.6
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var freq := 660.0 * (1.0 - t * 0.3)  # Falling pitch for "resolution"
		var env := exp(-t * 4.0)
		var sample := sin(t * TAU * freq) * env * 0.2
		sample += sin(t * TAU * freq * 1.5) * env * 0.1
		# Add sparkle
		if t > 0.1 and t < 0.4:
			sample += sin(t * TAU * 3000.0) * exp(-(t - 0.25) * 20.0) * 0.05
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_damage_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.25
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		var noise := randf_range(-1.0, 1.0)
		var env := exp(-t * 12.0)
		# Low thud + sharp noise burst
		var thud := sin(t * TAU * 120.0) * exp(-t * 8.0) * 0.3
		var sample := (noise * 0.4 + thud) * env * 0.3
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)
	
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# Public API

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(stream: AudioStream) -> void:
	var existing := get_node_or_null("MusicPlayer") as AudioStreamPlayer
	if existing:
		existing.stop()
		existing.queue_free()
	var player := AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	player.stream = stream
	player.bus = "Music"
	add_child(player)
	player.play()

func play_pulse() -> void:
	if _pulse_stream:
		play_sfx(_pulse_stream)

# F004.B (#96) — 4 verb fire SFX public play_*() API.  Each lazy-
# generates the stream on first call (cached after that) so _ready()
# stays cheap and the audio synth happens only when the verb is
# actually used.  Future 6th verb access pattern: add a `_xxx_stream`
# field + `_generate_xxx_sfx()` + `play_xxx()` here; the bind_ability
# / cut_ability / echo_ability / resonance_wave_ability fire signal
# handlers are the call sites.  T181 candidate closes the loop by
# adding the actual `AudioManagerEnhanced.play_bind()` etc. callers
# in each ability's _execute_*() method (parallel to the F004 #94
# Pulse caller that landed in pulse_ability.gd).
func play_bind() -> void:
	if _bind_stream == null:
		_bind_stream = _generate_bind_sfx()
	if _bind_stream:
		play_sfx(_bind_stream)

func play_cut() -> void:
	if _cut_stream == null:
		_cut_stream = _generate_cut_sfx()
	if _cut_stream:
		play_sfx(_cut_stream)

func play_echo() -> void:
	if _echo_stream == null:
		_echo_stream = _generate_echo_sfx()
	if _echo_stream:
		play_sfx(_echo_stream)

func play_wave_fire() -> void:
	if _wave_fire_stream == null:
		_wave_fire_stream = _generate_wave_fire_sfx()
	if _wave_fire_stream:
		play_sfx(_wave_fire_stream)

func play_footstep() -> void:
	if _footstep_stream:
		play_sfx(_footstep_stream)

func play_glass_break() -> void:
	if _glass_break_stream:
		play_sfx(_glass_break_stream)

# T141 (#75) — Wave hit soft chime with throttle.
# Lazy-generates the stream on first call (kept out of _ready() so the
# initial audio setup stays cheap; the wave hit SFX is rare compared
# to footsteps/damage).  The 50ms throttle prevents SFX stacking
# when the wave's AOE hits 3-5 enemies in the same frame — without
# it, a 5-enemy wave would fire 5 overlapping chimes that smear into
# a 0.20s mush.  Time is taken from Time.get_ticks_msec() which is
# monotonic; the initial -1 sentinel guarantees the first hit always
# plays.
#
# T144 (#78) — The selected stream depends on the player's current
# `wave_focus` perk count (read from GameState at call time, NOT
# cached, so purchasing a perk mid-game is immediately reflected).
# The lookup is `O(1)` via the `_wave_hit_streams` dict; if the level
# was never played, we synthesise + cache it on the first call.  This
# keeps memory bounded: max 4 cached streams of 17640 bytes each
# (~70KB) regardless of how many wave hits happen during a session.
func play_wave_hit() -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_wave_hit_time_ms >= 0 \
			and now_ms - _last_wave_hit_time_ms < int(_WAVE_HIT_THROTTLE * 1000.0):
		return
	# T144 — Read current wave_focus perk level (0..3) so the SFX
	# timbre matches the visible Wave radius.  Guarded with has_method
	# for headless test contexts (GameState autoload may not be ready).
	var perk_level: int = 0
	if GameState and GameState.has_method("get_perk_count"):
		perk_level = clampi(int(GameState.get_perk_count("wave_focus")), 0, 3)
	if not _wave_hit_streams.has(perk_level):
		_wave_hit_streams[perk_level] = _generate_wave_hit_sfx(perk_level)
	var stream: AudioStreamWAV = _wave_hit_streams.get(perk_level)
	if stream:
		play_sfx(stream)
		_last_wave_hit_time_ms = now_ms

# T181 (#97 first half) — 4 verb hit chime streams (Pulse / Bind / Cut / Echo).
# Wave already has its own play_wave_hit() (T141 #75) above — this
# adds the missing 4 (Pulse coral thud, Bind violet thunk, Cut amber
# shing, Echo cyan ping).  Each hit chime is THROTTLED at 50ms
# (mirrors the wave_hit throttle rationale: a single cast that hits
# 3-5 enemies should not stack 5 overlapping chimes into a 0.20s mush).
# Each hit SFX is THEME-DERIVED from the corresponding fire SFX so the
# cast tells a "fire → hit" two-note story:
#   - Pulse: 220Hz low thud (1.0×) — the "shockwave landed"
#   - Bind:  165Hz low thunk (1.0×) — the "pulled target stuck"
#   - Cut:   2000Hz bright shing (0.5× fast decay) — the "sword landed"
#   - Echo:  1980Hz glass tap (0.5× fast decay) — the "shield caught a hit"
# The 5 verb hit family pairs with the 5 verb fire family
# (play_pulse / play_bind / play_cut / play_echo / play_wave_fire)
# to give every cast a complete "fire → hit" two-beat audio loop.
#
# T181.B (#100) — Pulse / Cut / Echo hit streams are now PER-LEVEL
# dictionaries (keyed by perk_level 0..3) so each shop perk-stack
# plays a brighter "rounder" variant.  Bind has no shop perk and
# keeps the single-stream pattern from #97.  Wave already has the
# per-level pattern (T144 #78).  Lookup is O(1) via the dict; on
# first call for a new level the stream is synthesised + cached,
# so memory is bounded at 4 streams per verb (~70KB / verb worst
# case — same as Wave's pre-existing pattern).  The perk count
# is read from GameState at play time (not cached) so purchasing
# a perk mid-game is immediately reflected in the next hit.
var _pulse_hit_streams: Dictionary = {}  # T181.B (#100) — perk_level 0..3
var _bind_hit_stream: AudioStreamWAV    # T181 (#97) — no shop perk, single stream
var _cut_hit_streams: Dictionary = {}    # T181.B (#100) — perk_level 0..3 (future-proof)
var _echo_hit_streams: Dictionary = {}   # T181.B (#100) — perk_level 0..3
const _VERB_HIT_THROTTLE := 0.05  # seconds (matches _WAVE_HIT_THROTTLE)
var _last_verb_hit_time_ms: int = -1

func play_pulse_hit(perk_level: int = 0) -> void:
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	# T181.B (#100) — Read pulse_focus perk level from GameState
	# (mirrors T144 wave_hit pattern).  The optional perk_level arg
	# lets callers override (e.g. test harnesses); default 0 = the
	# GameState read.
	var level: int = perk_level
	if level == 0 and GameState and GameState.has_method("get_perk_count"):
		level = clampi(int(GameState.get_perk_count("pulse_focus")), 0, 3)
	level = clampi(level, 0, 3)
	if not _pulse_hit_streams.has(level):
		_pulse_hit_streams[level] = _generate_pulse_hit_sfx(level)
	var stream: AudioStreamWAV = _pulse_hit_streams.get(level)
	if stream:
		play_sfx(stream)
		_last_verb_hit_time_ms = now_ms

func play_bind_hit() -> void:
	# T181.B (#100) — Bind has no shop perk, so this stays on the
	# single-stream pattern from #97.  The level-arg signature is
	# intentionally NOT added here — adding a no-op `perk_level: int
	# = 0` arg to Bind would suggest a perk exists when it doesn't.
	# If a future Bind perk is added (e.g. bind_grip), port this to
	# the per-level dict pattern (see Pulse / Cut / Echo above) the
	# same way T144 ported Wave.
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	if _bind_hit_stream == null:
		_bind_hit_stream = _generate_bind_hit_sfx()
	if _bind_hit_stream:
		play_sfx(_bind_hit_stream)
		_last_verb_hit_time_ms = now_ms

func play_cut_hit(perk_level: int = 0) -> void:
	# T181.B (#100) — Future-proof: Cut has no shop perk today,
	# but the level-arg signature matches Pulse / Echo so a future
	# "cut_focus" perk can land without re-architecting this path.
	# The GameState read returns 0 (no perk) for now, but the level
	# arg is honoured if a caller passes a non-zero value (e.g. a
	# test harness or a future verb-upgrade system).
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	var level: int = perk_level
	if level == 0 and GameState and GameState.has_method("get_perk_count"):
		# No Cut-specific shop perk in shop_catalog.json — leave
		# level at the caller-supplied value (or 0 if no arg given).
		pass
	level = clampi(level, 0, 3)
	if not _cut_hit_streams.has(level):
		_cut_hit_streams[level] = _generate_cut_hit_sfx(level)
	var stream: AudioStreamWAV = _cut_hit_streams.get(level)
	if stream:
		play_sfx(stream)
		_last_verb_hit_time_ms = now_ms

func play_echo_hit(perk_level: int = 0) -> void:
	# T181.B (#100) — Read echo_charm perk level from GameState
	# (mirrors T144 wave_hit pattern).  shop_catalog.json has
	# max_purchases=1 for echo_charm, so the level read is 0 or 1
	# in normal play — but the synth supports 0..3 for symmetry.
	var now_ms: int = Time.get_ticks_msec()
	if _last_verb_hit_time_ms >= 0 \
			and now_ms - _last_verb_hit_time_ms < int(_VERB_HIT_THROTTLE * 1000.0):
		return
	var level: int = perk_level
	if level == 0 and GameState and GameState.has_method("get_perk_count"):
		level = clampi(int(GameState.get_perk_count("echo_charm")), 0, 3)
	level = clampi(level, 0, 3)
	if not _echo_hit_streams.has(level):
		_echo_hit_streams[level] = _generate_echo_hit_sfx(level)
	var stream: AudioStreamWAV = _echo_hit_streams.get(level)
	if stream:
		play_sfx(stream)
		_last_verb_hit_time_ms = now_ms

# T181 (#97 first half) — 5 verb cooldown "ready" jingle.
# When a verb's cooldown finishes, the player needs a discrete audio
# cue so they can re-engage the chain without staring at the HUD.
# The 5 jingles are pentatonic and color-coded to match the verb
# theme (Coral Pulse / Muted Violet / Amber Voice / Glass Cyan /
# Pale Resonance) so the *pitch contour* is a secondary tell:
#   - Pulse: A4 → C5 (ascending major-3rd, "available now")
#   - Bind:  C5 → E5 (ascending major-3rd, "ready to pull")
#   - Cut:   E5 → G5 (ascending minor-3rd, "ready to slash")
#   - Echo:  G5 → A5 (ascending major-2nd, "ready to shield")
#   - Wave:  A5 → C6 (ascending major-3rd, "ready to bloom")
# All 5 share the same 0.10s duration + exp(-t*15) envelope so the
# family reads as one "verb ready" pattern.  Amplitude 0.18 (lowest
# of the 5-verb family) so the jingle never fights BGM / SFX.
var _verb_cooldown_streams: Dictionary = {}

func play_verb_cooldown_ready(verb_name: String) -> void:
	# Map verb name → MIDI start note (5 ascending pentatonic-ish
	# starting pitches, each exactly a major 3rd above the previous
	# so the 5 jingles spread across 1.5 octaves with no clashing
	# semitones).  See comment above the _verb_cooldown_streams
	# field for the pitch-per-verb rationale.
	var start_midi: int = _verb_cooldown_start_midi(verb_name)
	if start_midi < 0:
		return  # Unknown verb — silently no-op (future-proof for verb 6+)
	if not _verb_cooldown_streams.has(verb_name):
		_verb_cooldown_streams[verb_name] = _generate_verb_cooldown_jingle(start_midi)
	var stream: AudioStreamWAV = _verb_cooldown_streams.get(verb_name)
	if stream:
		play_sfx(stream)

func _verb_cooldown_start_midi(verb_name: String) -> int:
	# F013.C (#109) — whole-tone scale microtuning.  原 T181 (69/72/76/79/81)
	# 间隔 3/4/3/2 半音不均 → 新 (69/71/73/75/77) 严格 2 半音
	# 间隔.  详见 F013.C docblock 上方.  6th verb 续接可走 79.
	# A4=69, B4=71, C#5=73, D#5=75, F5=77, G5=79
	match verb_name:
		"pulse": return 69  # A4 → C#5 (ascending augmented-4th, microtuned)
		"bind":  return 71  # B4 → D#5 (ascending augmented-4th, microtuned)
		"cut":   return 73  # C#5 → F5 (ascending augmented-4th, microtuned)
		"echo":  return 75  # D#5 → G5 (ascending augmented-4th, microtuned)
		"wave":  return 77  # F5 → A5 (ascending augmented-4th, microtuned)
		_:       return -1  # Unknown verb — no-op

# F013.C (#109) — 5 verb 2-semitone microtuning 后的新音高表.
# T181 原始设计 (69/72/76/79/81 → 5 verb 间隔 3/4/3/2 半音不均
# 匀) 改为 whole-tone scale (69/71/73/75/77 → 5 verb 严格 2
# 半音间隔).  每个 verb 各 ±2 半音 fine-tuning 移位:
#   pulse 69 → 69 (0 shift, A4 锚点保留)
#   bind  72 → 71 (-1, C5→B4 微降让 bind 比 pulse 略低但仍在
#              同一 octave 体现 "anchor + second" 关系)
#   cut   76 → 73 (-3, E5→C#5 整体下移 3 半音到 whole-tone
#              scale 中段, 锐利 "shing" 音色通过高频保留)
#   echo  79 → 75 (-4, G5→D#5 大幅下移 4 半音让 echo "护盾"
#              语义与 pulse/bind 在中低区叠加和谐)
#   wave  81 → 77 (-4, A5→F5 顶 high 收回到 mid-high 让
#              wave "广域扩散" 音色不再刺耳)
# 整体 5 verb 从 "1.5 八度 wide spread" 收回 "1 个八度 tight
# spread" (69→77 = 8 半音 = 1 minor 6th), 5 jingle 在 BGM
# 之上更集中, 玩家耳朵更好辨认 "verb 解锁" 单一节奏模式.
# 6th verb 仍可走 79 (G5) 续接, scale 自然延伸.
# F013.B (#106) — Verb cooldown TAIL jingle (降 4 半音 0.12s).
# 与 T181 play_verb_cooldown_ready (升 4 半音 0.10s "verb 解锁")
# 对偶, 这个是 "verb 刚 cast 出去 / 刚进入冷却" 的尾音.  5 verb
# 共用 1 个 synth, 起始音高 = T181 ready 终点 = 起点 + 4 半音
# (Pulse: C5 72, Bind: E5 76, Cut: G5 79, Echo: A5 81, Wave: C6 84).
# Lazy-cached on first call (5 verb 都走这个 helper, 1 次 call 就
# 拿到对应 stream).  6th verb 传未知 verb_name → 静默 no-op
# (与 T181 ready 同 防御模式, 6th verb 添加只需 1 行 new match arm).
func play_verb_cooldown_tail(verb_name: String) -> void:
	var start_midi: int = _verb_cooldown_tail_start_midi(verb_name)
	if start_midi < 0:
		return  # Unknown verb — silently no-op (future-proof for verb 6+)
	if not _verb_cooldown_tail_streams.has(verb_name):
		_verb_cooldown_tail_streams[verb_name] = _generate_verb_cooldown_tail_jingle(start_midi)
	var stream: AudioStreamWAV = _verb_cooldown_tail_streams.get(verb_name)
	if stream:
		play_sfx(stream)

func _verb_cooldown_tail_start_midi(verb_name: String) -> int:
	# F013.B (#106) — 起始 MIDI = T181 ready 终点 (T181 起点 + 4 半音).
	# F013.C (#109) — 配合 READY whole-tone microtuning, TAIL 起
	# 点同步 = READY end = READY start + 4.  5 verb 落在
	# (73/75/77/79/81) 也是 whole-tone scale 2 半音间隔, 与
	# READY (69/71/73/75/77) 严格镜像.
	# A4=69, B4=71, C#5=73, D#5=75, F5=77, G5=79
	match verb_name:
		"pulse": return 73  # C#5 → A4 (descending augmented-4th, mirror of T181)
		"bind":  return 75  # D#5 → B4 (descending augmented-4th, mirror of T181)
		"cut":   return 77  # F5 → C#5 (descending augmented-4th, mirror of T181)
		"echo":  return 79  # G5 → D#5 (descending augmented-4th, mirror of T181)
		"wave":  return 81  # A5 → F5 (descending augmented-4th, mirror of T181)
		_:       return -1  # Unknown verb — no-op

# T148 (#78) — Wave-combo tail chime (fires once per combo event).
# Lazy-cached on first call.  Called from player.gd._on_wave_combo
# right after the ScreenShake.shake + flash_color so the audio
# reinforces the visual event.  No throttle — a wave_combo is a
# rare event (>=3 hits in a single cast) and we *want* it to be
# distinct from the per-hit pings.
func play_wave_combo() -> void:
	if _wave_combo_stream == null:
		_wave_combo_stream = _generate_wave_combo_sfx()
	if _wave_combo_stream:
		play_sfx(_wave_combo_stream)

# T153 (#79) — 公开播放存档槽位 jingle。SaveLoadMenu 在
# _on_overwrite / _on_load 时按 slot_id 调用。第一次播放生成
# 并缓存 stream（_save_slot_streams），后续直接复用——避免
# 每次 save/load 都重做 0.25s 波形合成。slot_id 越界在
# _generate_save_slot_jingle 内部被 clamp，不会抛错。
func play_save_slot_jingle(slot_id: int) -> void:
	if not _save_slot_streams.has(slot_id):
		_save_slot_streams[slot_id] = _generate_save_slot_jingle(slot_id)
	var stream: AudioStreamWAV = _save_slot_streams[slot_id]
	if stream:
		play_sfx(stream)

# F014 (#103) — 公开播放成就解锁 chime。AchievementNotification 在
# _on_achievement_unlocked 里调用一次。Lazy-init + 缓存 _unlock_chime_stream
# (单 stream 即可, 不像 save_slot 需按 slot_id 区分)。无节流 —
# 14 个成就 + 一次性信号, 一次 unlock 一次 chime 正是预期行为。
# 14 个成就里有 5 个 'best_stat_threshold' (历史最佳) 可能在同
# 一次 run 解锁多个 → 多次 chime 叠加, 听感是 "叮叮叮" 快击,
# 不抢 BGM (amplitude 0.18 vs BGM 默认 1.0) 也不抢 SFX bus。
# T208 (#126) — 新增 id_val 参数。14 成就各自有独特 chord + duration
# + amp + decay 配方 (ACHIEVEMENT_CHIME_PRESETS), 玩家解锁"first_steps"
# 听到 C 大调上行 4 音, 解锁"silence_hunter"听到减七和弦, 解锁什么
# 听就有什么音色。id_val == "" (老调用方) 或 id 不在 dict (未来
# 新增成就但忘了加 preset) 走原 C6+E6+A6 配方保持向后兼容。缓存
# _achievement_chime_streams dict 避免重复合成 (与 _unlock_chime_stream
# 单 stream 缓存同模式)。has_method 守卫: smoke test 跑在 SceneTree
# mode, AudioManagerEnhanced 早期版本可能无 play_unlock_chime 方法。
# T208.B (#127) — 与 BGM ducking 联动.  14 成就 chime 在 SFX bus
# 播放, 同时 BGM 在 Music bus 的 _current_music_player volume_db
# 短时下降到 (current_db + _BGM_DUCK_DB) 持续 duration + 0.05s
# fade-in + 0.30s fade-out.  听感:  chime "在 BGM 之上" 浮起,
# BGM 不消失但变弱, chime 结束 BGM 平滑滑回原音量.  14 → 9
# ACHIEVEMENT_BGM_HINT 语义映射 (title_intro/hub_warm/
# archive_exploration/archive_dawn/whisper_hollow/silence_void)
# 供未来 hub 主题 + 成就解锁联动 API 留 hook, 本轮只用作
# logging (headless 模式不打印).  Ducking 防御:  _bgm_duck_tween
# 复用同一个 Tween 引用, 反复 unlock 时 fade-in 不会重入叠加.
func play_unlock_chime(id_val: String = "") -> void:
	# T208.B — BGM ducking: 玩家听见 chime 的同时 BGM 短时变弱, 让
	# 14 成就 "浮在 BGM 之上" 而不取代.  只对 14 成就 + 老 fallback
	# 都生效 (duck 一样, hint 不同).  无 BGM 在播 → no-op (no
	# _current_music_player).  Re-entrant 安全:  同一 tween kill
	# 后重建, 防止 fade-in + restore 重叠.
	if id_val != "" and ACHIEVEMENT_CHIME_PRESETS.has(id_val):
		# 14 成就路径: 走独特 chime + ducking
		if not _achievement_chime_streams.has(id_val):
			var preset: Dictionary = ACHIEVEMENT_CHIME_PRESETS[id_val]
			_achievement_chime_streams[id_val] = _generate_achievement_chime_sfx(preset)
		var stream: AudioStreamWAV = _achievement_chime_streams[id_val]
		if stream:
			# T208.B — duck BGM during this specific chime's duration.
			# 重新从 dict 查 duration 而非用 cache miss block 里的局部
			# 变量 preset (cache hit 时 preset 超出作用域 — F018 #130
			# 修复 #128 T209 commit 引入的 scope 泄漏 SCRIPT ERROR)
			_duck_current_bgm_for_chime(ACHIEVEMENT_CHIME_PRESETS[id_val].get("duration", 0.5))
			play_sfx(stream)
		return
	# Fallback: 老路径 — 单 stream C6+E6+A6 金属三连音
	if _unlock_chime_stream == null:
		_unlock_chime_stream = _generate_unlock_chime_sfx()
	if _unlock_chime_stream:
		# T208.B — fallback chime 也走 ducking, 用 0.4s 默认 duration
		# (与 _generate_unlock_chime_sfx 的实际长度一致)
		_duck_current_bgm_for_chime(0.4)
		play_sfx(_unlock_chime_stream)

# T208.B (#127) — 14 成就 chime 与 BGM 联动 layering 的核心辅助.
# 在 _current_music_player 上做 volume_db 短时下降 + 自动恢复.
# 设计:
# - 捕获 duck 前 BGM 音量 (current_db), 让恢复时回到 duck 前
#   的值, 不破坏正在 fade-in/out 中的 BGM transition 状态.
# - 0.05s fade-in (几乎瞬时) + duration_s 持续 + 0.30s fade-out
#   (稍慢, 听感更 "滑回" 而非硬切).
# - Re-entrant 安全:  _bgm_duck_tween.kill() 然后重建, 防止
#   连续 2 次 unlock 时 fade-in 与 restore 重叠导致音量
#   反复变化.  无 BGM 在播 → no-op (test_smoke 场景
#   _current_music_player == null 不应崩).
# - 不抛错:  所有 path 都 gracefully 退出, smoke test 跑在
#   SceneTree mode 可能未注册 autoload.
func _duck_current_bgm_for_chime(duration_s: float) -> void:
	if not _current_music_player or not is_instance_valid(_current_music_player):
		return  # No BGM playing — no-op (title screen 等)
	# Kill any in-flight duck tween — re-entrant safety
	if _bgm_duck_tween and _bgm_duck_tween.is_valid():
		_bgm_duck_tween.kill()
	# Capture pre-duck volume_db (可能正在 fade-in/out, 不能假设 0)
	var pre_duck_db: float = _current_music_player.volume_db
	var target_ducked_db: float = pre_duck_db + _BGM_DUCK_DB
	# Build tween: fade-in (0.05s) → hold (duration_s) → fade-out (0.30s)
	_bgm_duck_tween = create_tween()
	_bgm_duck_tween.set_trans(Tween.TRANS_CUBIC)
	_bgm_duck_tween.set_ease(Tween.EASE_OUT)
	# Step 1: fade-in to ducked volume
	_bgm_duck_tween.tween_property(
		_current_music_player, "volume_db", target_ducked_db, _BGM_DUCK_FADE_IN_S
	)
	# Step 2: hold (chime 播放期间 BGM 保持 duck)
	_bgm_duck_tween.tween_interval(max(0.0, duration_s))
	# Step 3: fade-out back to pre-duck volume
	_bgm_duck_tween.tween_property(
		_current_music_player, "volume_db", pre_duck_db, _BGM_DUCK_FADE_OUT_S
	)

# F015 (#103) — 公开播放存档槽删除 click。SaveLoadMenu 在 _on_delete
# (玩家点"删"按钮) 时调用一次。Lazy-init + 缓存 _delete_confirm_stream
# (单 stream, 每次删除音一致 = "你刚刚删了一个存档")。走 SFX bus,
# 与 play_save_slot_jingle (C5..E6 bell) 走同一 bus 但音色完全分离
# (本 click 是 150Hz 方波低音, jingle 是三角波中高音) 玩家不会混淆。
func play_delete_confirm() -> void:
	if _delete_confirm_stream == null:
		_delete_confirm_stream = _generate_delete_confirm_sfx()
	if _delete_confirm_stream:
		play_sfx(_delete_confirm_stream)

# F016 (#104) — 公开播放死亡 lay-down "呜——" 低频嗡鸣.  player.gd
# 在 die() 入口 (红色 tint 之前) 调用一次.  Lazy-init + 缓存
# _death_lay_down_stream (单 stream, 死亡 SFX 永远一致音色 = "我
# 死的时候听到的是这声").  走 SFX bus, 与 play_delete_confirm
# (150Hz 方波 0.12s click) 走同一 bus 但音色完全分离 (本嗡鸣是
# 75Hz sub-bass 0.4s sustain, click 是 150Hz 方波 0.12s 短促)
# — 玩家不会混淆"破坏存档" vs "我死亡".  与 archive_storm BGM
# (T107 64Hz sub-bass LFO 30s loop) 频段接近但时长 + LFO 不同
# (0.4s 单音 vs 30s loop), 避免 Boss 战中死亡时频段冲突.
# F016.C (#111) — 全 7 房间 universal 覆盖: json_room (archive_01
# default) + room_archive_02/03/04 + hub_room + room_transition +
# room_door. 伤害汇聚点 GameState.take_damage → player.die() →
# play_death_lay_down() 单链路, 任何 room 都不应绕开 (smoke
# test_i021_t193_f016c_death_sfx_audit_smoke.gd 守住回归). 与
# F016.B _death_sfx_playing flag 形成 "调用方 + callee" 双重防御,
# 7 房间内任意 death trigger (敌人 / 陷阱 / 水 hazard / Boss)
# 在 0.5s 窗口内多次触发都不会 2x 嗡鸣叠加.
func play_death_lay_down() -> void:
	# F016.B (#108) — Idempotency guard. 如果上一次 SFX 还在 0.4s +
	# 0.1s 缓冲窗内, 直接 no-op, 防止多 trigger 叠加成 2x 嗡鸣. 与
	# player._is_dying 形成"调用方 + callee" 双重防御: 正常死亡
	# 路径 _is_dying 拦截重入, 这个 flag 拦截"调用方无 _is_dying
	# 但 SFX 仍然被调多次" 的边缘场景 (如 future: ambient damage
	# tick + 主动 kill 同一帧命中).
	if _death_sfx_playing:
		return
	if _death_lay_down_stream == null:
		_death_lay_down_stream = _generate_death_lay_down_sfx()
	if _death_lay_down_stream:
		_death_sfx_playing = true
		play_sfx(_death_lay_down_stream)
		# Timer 守护: 0.4s SFX 时长 + 0.1s 缓冲后清 flag
		var t := get_tree().create_timer(_DEATH_SFX_DURATION + _DEATH_SFX_GUARD_BUFFER)
		t.timeout.connect(func() -> void:
			_death_sfx_playing = false
		)

func play_repair() -> void:
	if _repair_stream:
		play_sfx(_repair_stream)

func start_enemy_hum(node: Node) -> AudioStreamPlayer:
	if not _enemy_hum_stream:
		return null
	var player := AudioStreamPlayer.new()
	player.stream = _enemy_hum_stream
	player.bus = "Ambience"
	player.volume_db = -12.0
	node.add_child(player)
	player.play()
	return player

func stop_enemy_hum(player: AudioStreamPlayer) -> void:
	if player:
		player.stop()
		player.queue_free()

func play_damage() -> void:
	var stream := _generate_damage_sfx()
	if stream:
		play_sfx(stream)

# F013 (#102) — Shop perk card "purchase confirmed" chime.
# Major-triad bell (C5 + E5 + G5 simultaneously) with a soft exp
# envelope (decay 3.5 — slower than _generate_repair_sfx's 4.0 so it
# "rings" rather than "thuds").  Volume 0.20 stays polite next to
# the BGM bed; sparkle 3rd harmonic at 2 octaves up gives the bell
# its "I just bought something" clarity.  Called from
# shop_menu._on_buy_pressed() on the success branch.
func play_shop_purchase_confirm() -> void:
	if _shop_purchase_confirm_stream == null:
		_shop_purchase_confirm_stream = _generate_shop_purchase_confirm_sfx()
	if _shop_purchase_confirm_stream:
		play_sfx(_shop_purchase_confirm_stream)

func _generate_shop_purchase_confirm_sfx() -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.4
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Major triad (C5/E5/G5) — bright "confirmation" chord
		var sample := sin(t * TAU * 523.25) * 0.12  # C5
		sample += sin(t * TAU * 659.26) * 0.10      # E5
		sample += sin(t * TAU * 783.99) * 0.08      # G5
		# Bell-like 2nd harmonic + 3rd-octave sparkle
		sample += sin(t * TAU * 1046.5) * 0.04
		if t > 0.05 and t < 0.30:
			sample += sin(t * TAU * 2093.0) * exp(-(t - 0.05) * 18.0) * 0.03
		var env := exp(-t * 3.5)  # slower decay than repair (4.0) → "rings"
		sample *= env
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# F013 (#102) — Shop perk card "level up" ascending arpeggio.
# Three sequential notes (base / +4 / +7 semitones → major triad) at
# 0.10s each, with brief overlap at the boundaries, so the player
# hears a clear "ascending reward" gesture.  level=0..3 picks the
# base MIDI from _SHOP_LEVEL_UP_BASE_MIDI (C4 / D4 / E4 / F4 — each
# upgrade of the same perk is a 1-semitone "up" from the previous).
# Volume 0.18 stays in the "polite reward" range, distinct from
# purchase_confirm (chord) so the two events are perceptually
# different.  Lazy-initialised per-level.
func play_shop_level_up(level: int = 0) -> void:
	var clamped_level: int = clampi(level, 0, _SHOP_LEVEL_UP_LEVELS - 1)
	if not _shop_level_up_streams.has(clamped_level):
		_shop_level_up_streams[clamped_level] = _generate_shop_level_up_sfx(clamped_level)
	var stream: AudioStreamWAV = _shop_level_up_streams.get(clamped_level)
	if stream:
		play_sfx(stream)

func _generate_shop_level_up_sfx(level: int) -> AudioStreamWAV:
	var sample_rate := 44100
	var duration := 0.30
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var base_midi: int = _SHOP_LEVEL_UP_BASE_MIDI[level]
	var base_hz: float = 440.0 * pow(2.0, (float(base_midi) - 69.0) / 12.0)
	var note_dur := 0.10
	var step_dur := 0.085  # slight overlap so the arpeggio "sweeps" not "stabs"

	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# Pick which note is sounding at time t (0, 1, 2)
		var step: int = int(t / step_dur)
		if step > 2:
			step = 2
		var step_t: float = t - float(step) * step_dur
		var note_midi: int = base_midi + [0, 4, 7][step]
		var note_hz: float = 440.0 * pow(2.0, (float(note_midi) - 69.0) / 12.0)
		# Per-note attack-decay envelope (short attack 0.01s, decay over note)
		var env: float = clampf(step_t / 0.01, 0.0, 1.0) * exp(-step_t * 5.0)
		var sample := sin(t * TAU * note_hz) * env * 0.18
		sample += sin(t * TAU * note_hz * 2.0) * env * 0.04  # 2nd harmonic body
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# T122 (#64) — Intro cutscene ambient bed.
# Plays an 8-second ultra-quiet dual-sine drone on the Ambience bus so
# the title-screen black-out / text-fade is not silent. Designed to
# sit *under* whatever BGM takes over after the cutscene ends
# (title_intro fades in 1.5s after cutscene_finished), so the
# ambience is a 1-shot that simply dies on its own rather than a
# loop. Two detuned sines (D2 + G2 perfect-5th) at ~0.04 amplitude
# modulated by a 0.15Hz LFO give a "breathing" feel that matches
# the visual fade-in rhythm (the player's eyes expect something
# organic, not silence). Sample rate 22050Hz keeps the synth
# under 1ms on the main thread.
func play_intro_ambience() -> void:
	var stream := _generate_intro_ambience()
	if stream:
		play_sfx(stream, "Ambience")

func _generate_intro_ambience() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 8.0  # matches IntroCutscene TOTAL_DURATION
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	# D2 + G2 perfect-5th = D minor opening gesture, no resolution
	var hz_root := 73.42  # D2
	var hz_fifth := 98.00  # G2
	for i in range(samples):
		var t := float(i) / float(sample_rate)
		# 0.15Hz LFO = 6.7s breath cycle, mirrors whisper_hollow's
		# "deep quiet" modulation so the cutscene pads feel like
		# the same room the rest of the game lives in.
		var lfo := 0.5 + 0.5 * sin(t * TAU * 0.15)
		var sample := sin(t * TAU * hz_root) * 0.04 * lfo
		sample += sin(t * TAU * hz_fifth) * 0.025 * lfo
		# Subtle second-harmonic gives the drone a tiny bit of "body"
		sample += sin(t * TAU * hz_root * 2.0) * 0.012 * lfo
		sample = clampf(sample, -1.0, 1.0)
		# ~12k headroom = ~ -9 dBFS, well below BGM so the cutscene
		# pad never competes with the upcoming title_intro fade-in.
		var s16 := int(sample * 12000.0)
		data.encode_s16(i * 2, s16)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

# ============================================================
# Procedural BGM (T062)
# ============================================================
# Three ambient themes synthesized at startup: title_intro / hub_warm /
# archive_exploration. Each is a layered ambient pad:
#   1) Bass drone (root + sub-octave)
#   2) Chord pad (3 sines) modulated by slow LFO
#   3) Bell-like arpeggio (8th notes, exp-decay envelope per note)
#   4) Glass shimmer (high-freq sine with subtle vibrato)
# All loops seamlessly because arp length divides the loop duration.

func _midi_to_hz(midi: int) -> float:
	return 440.0 * pow(2.0, (float(midi) - 69.0) / 12.0)

func _generate_music_track(key: String) -> AudioStreamWAV:
	if not AudioPresets.MUSIC_PRESETS.has(key):
		push_warning("AudioManagerEnhanced: unknown music key '%s'" % key)
		return null
	var preset: Dictionary = AudioPresets.MUSIC_PRESETS[key]
	var sample_rate := 22050  # ambient doesn't need full 44.1k
	var duration: float = preset["duration"]
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	# Precompute frequencies
	var root_hz := _midi_to_hz(preset["root_midi"])
	var chord_hz: Array[float] = []
	for n in preset["chord_midi"]:
		chord_hz.append(_midi_to_hz(n))
	var arp_hz: Array[float] = []
	for n in preset["arp_midi"]:
		arp_hz.append(_midi_to_hz(n))
	var shimmer_hz := _midi_to_hz(preset["shimmer_midi"])

	# Arpeggio timing — 8th notes
	var bpm: float = preset["bpm"]
	var arp_step_dur: float = 60.0 / bpm * 0.5
	var arp_len: int = arp_hz.size()

	var lfo_freq: float = preset["lfo_freq"]
	var lfo_depth: float = preset["lfo_depth"]
	var shimmer_mod: float = preset["shimmer_mod"]
	var arp_vol: float = preset["arp_volume"]
	var pad_vol: float = preset["pad_volume"]
	var bass_vol: float = preset["bass_volume"]
	var shimmer_vol: float = preset["shimmer_volume"]

	# Pre-multiply volume factors for inner loop speed
	var bass_root_vol := bass_vol
	var bass_sub_vol := bass_vol * 0.6

	for i in range(samples):
		var t := float(i) / float(sample_rate)

		# (1) Bass drone — root + sub-octave for body
		var bass := sin(t * TAU * root_hz) * bass_root_vol
		bass += sin(t * TAU * root_hz * 0.5) * bass_sub_vol

		# (2) Chord pad with slow LFO amplitude modulation
		var lfo := 1.0 - lfo_depth + lfo_depth * (0.5 + 0.5 * sin(t * TAU * lfo_freq))
		var pad := 0.0
		for hz in chord_hz:
			pad += sin(t * TAU * hz)
		pad *= pad_vol * lfo

		# (3) Bell arpeggio — 8th note steps with exp-decay envelope.
		# T114 — silence_void sets arp_midi to []; the empty arp case
		# is the natural extension of "no arpeggio" so we just skip
		# the envelope math instead of dividing by zero on
		# arp_idx % 0.
		var arp_note: float = 0.0
		if arp_len > 0:
			var arp_idx := int(t / arp_step_dur) % arp_len
			var arp_t_in_step := fmod(t, arp_step_dur) / arp_step_dur
			var arp_env := exp(-arp_t_in_step * 4.5)
			var arp_f := arp_hz[arp_idx]
			arp_note = sin(t * TAU * arp_f) * arp_env
			# 2x harmonic for bell-like timbre
			arp_note += sin(t * TAU * arp_f * 2.0) * arp_env * 0.35
			arp_note *= arp_vol

		# (4) Glass shimmer — high freq with subtle vibrato + slower LFO
		var shimmer_lfo := 0.5 + 0.5 * sin(t * TAU * (lfo_freq * 1.7))
		var vibrato := sin(t * 6.0) * shimmer_mod
		var shimmer := sin(t * TAU * shimmer_hz * (1.0 + vibrato))
		shimmer *= shimmer_lfo * shimmer_vol

		var sample := bass + pad + arp_note + shimmer
		sample = clampf(sample, -1.0, 1.0)
		# Leave headroom (~85% of int16 range) so mix bus doesn't clip when
		# multiple SFX play over BGM.
		var s16 := int(sample * 28000.0)
		data.encode_s16(i * 2, s16)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	stream.data = data
	return stream

func _ensure_music_stream(key: String) -> AudioStreamWAV:
	if _music_streams.has(key):
		return _music_streams[key]
	var stream := _generate_music_track(key)
	if stream:
		_music_streams[key] = stream
	return stream

## T066 — Pre-warm all preset streams to AudioStreamWAV cache.
## Call this once at app start (e.g. Title screen _ready) so that the
## first BGM switch after pressing Start incurs zero synthesis latency
## (each track is ~352800 samples = 16s @ 22050Hz, takes ~0.5-1.0s to
## generate on the main thread).  Subsequent calls are O(1) lookups.
##
## Iterates the full AudioPresets.MUSIC_PRESETS dictionary, so the 4 main themes
## (title_intro / hub_warm / archive_exploration / archive_dawn) plus
## the 3 boss variants (archive_boss / archive_boss_dual /
## archive_storm) and the silence_void "absence" theme are all
## cached automatically — no per-key call needed.  As of #61 (T114)
## there are 8 presets.
# T183 (#101) — Pre-warm all 4 verb hit SFX so the first hit
# after Title → Hub → Archive transition has zero synthesis
# latency.  Each verb hit SFX is lazy-init in its play_*_hit()
# function (the first call after game start spends 0.5-1.5 ms
# in the audio synth — usually invisible, but on a stutter
# frame right after a scene change it can read as a missed
# "thud" to the player).  Pre-warming during Title screen
# _ready moves that cost off the gameplay frame.  Total cost:
# 1 (Bind) + 4 (Pulse 0..3) + 4 (Cut 0..3) + 4 (Echo 0..3)
# = 13 AudioStreamWAV instances, ~10 ms total on the Title
# ready frame.  Subsequent play_*_hit() calls are O(1) lookups.
#
# Bind has only 1 stream (no shop perk).  Pulse / Cut / Echo
# each have 4 (perk_level 0..3) — Cut has no current perk so
# levels 1..3 are pre-emptively pre-warmed for future-proofing
# (a "cut_focus" perk can land without breaking pre-warm).
#
# Mirror pattern of T066 `prewarm_music_streams()` (9 BGM
# presets cached on Title ready).  Call this alongside it.
func prewarm_hit_sfx() -> void:
	# Bind: single stream (no perk)
	if _bind_hit_stream == null:
		_bind_hit_stream = _generate_bind_hit_sfx()
	# Pulse / Cut / Echo: perk_level 0..3 (4 streams each)
	for level in [0, 1, 2, 3]:
		if not _pulse_hit_streams.has(level):
			_pulse_hit_streams[level] = _generate_pulse_hit_sfx(level)
		if not _cut_hit_streams.has(level):
			_cut_hit_streams[level] = _generate_cut_hit_sfx(level)
		if not _echo_hit_streams.has(level):
			_echo_hit_streams[level] = _generate_echo_hit_sfx(level)

# T220 (#142) — F022 verb fire SFX prewarm bucket.  Mirrors the
# T181 hit-SFX prewarm bucket (#102 prewarm_hit_sfx) but for the
# fire side: 5 verb fire streams (_pulse_stream / _bind_stream /
# _cut_stream / _echo_stream / _wave_fire_stream) that previously
# lazy-generated on first play_*() call.  Fire SFX is the FIRST
# beat of the "fire → hit" two-beat loop (T181 #97 second half),
# so any 0.1s+ synth delay on the fire beat desyncs the pair
# visibly.  5 stream × ~3 ms synth (single 0.4-0.8s tone each
# @ 22050 Hz mono) = ~15 ms total.  Aggregator (prewarm_all_sfx)
# calls this AFTER prewarm_hit_sfx() so the fire / hit pair is
# ready in the same 7-bucket fan-out.  Pulse stream is non-lazy
# (set in _ready via _pulse_stream construction) so the guard
# is a defensive no-op for it; the other 4 do real work.
func prewarm_verb_fire_sfx() -> void:
	if _bind_stream == null:
		_bind_stream = _generate_bind_sfx()
	if _cut_stream == null:
		_cut_stream = _generate_cut_sfx()
	if _echo_stream == null:
		_echo_stream = _generate_echo_sfx()
	if _wave_fire_stream == null:
		_wave_fire_stream = _generate_wave_fire_sfx()

# T184 (#102) — Pre-warm F013 shop SFX (1 purchase_confirm + 4
# level_up arpeggios = 5 streams).  Shop is rare (≤25 events per
# run) but the synth is non-trivial (~5 ms total) and the first
# purchase after a long archive run can land on a stutter frame.
# Caching the streams means the first buy in the Hub is also
# instant.  Mirrors the "pre-warm rare events off the gameplay
# frame" philosophy of prewarm_hit_sfx() / prewarm_music_streams().
func prewarm_shop_sfx() -> void:
	if _shop_purchase_confirm_stream == null:
		_shop_purchase_confirm_stream = _generate_shop_purchase_confirm_sfx()
	for level in range(_SHOP_LEVEL_UP_LEVELS):
		if not _shop_level_up_streams.has(level):
			_shop_level_up_streams[level] = _generate_shop_level_up_sfx(level)

# T185.B (#103) — Pre-warm F014 unlock chime + F015 delete confirm
# click.  Both are "rare event" SFX (1 stream each): F014 fires once
# per achievement (14 events total per account lifetime), F015 fires
# on save-slot delete (0..1 per session).  Synth cost is small
# (~3 ms total) but the first unlock can land mid-fight where any
# stutter is jarring, and the first delete can land in the
# save-load menu right when the user is making a destructive
# decision.  Caching both ensures zero-latency response on the
# first event.  Aggregator (prewarm_all_sfx) calls this after
# shop so the pre-warm fan-out is order: music → hit → shop → misc.
func prewarm_misc_sfx() -> void:
	# I015 T221 (#143) — F014/F015/F016 lazy-init guard 清理.  prewarm
	# 是 "启动一次性预热" 而非 "每次 lazy 检查" 入口; 单 stream null
	# 守卫冗余 (prewarm_misc_sfx 由 title_screen._prewarm_bgm / hub_controller
	# / game_flow_controller 3 路任一跑, 跑完 stream 已 cache, public
	# 方法 play_unlock_chime / play_delete_confirm / play_death_lay_down
	# 内部 lazy 守卫保 idempotent).  3 stream 3 guard 全删, 直接
	# _generate_*_sfx() 1-line 调用, 与 T208 (14 成就 dict.has 守卫)
	# 0 冲突 — T208 走 Dict.has 多 key 守卫是必要, 3 单 stream 走
	# null 守卫是冗余 (单 stream 走 public 路径 lazy 即可).
	_unlock_chime_stream = _generate_unlock_chime_sfx()
	# T208 (#126) — Pre-warm 15 per-achievement unique chimes (T242 #161
	# +1 sextuple_voice, 14 → 15 成就 milestone 闭环).  之前只有 1 个
	# fallback _unlock_chime_stream, T208 加 id 各自的 chord 配方;
	# 一次性 15 stream 预热 ~5ms (chord 短 0.35-0.65s +
	# sample_rate 22050 单声道 = 单 stream 7-14k 字节, 15 stream 总
	# 内存 ~160KB 一次性分配).  玩家第一次解锁任意成就都 0 合成
	# 延迟 = "我听见成就解锁" 0 帧错位.  与 F014 单 stream 预热
	# 共用 _unlock_chime_stream 字段, 不破坏老 fallback 路径.
	# Loop 自动遍历 ACHIEVEMENT_CHIME_PRESETS.keys() 14 → 15 entry,
	# 0 触碰 0 副作用, 0 hardcode 数量.
	for ach_id in ACHIEVEMENT_CHIME_PRESETS.keys():
		if not _achievement_chime_streams.has(ach_id):
			var preset: Dictionary = ACHIEVEMENT_CHIME_PRESETS[ach_id]
			_achievement_chime_streams[ach_id] = _generate_achievement_chime_sfx(preset)
	_delete_confirm_stream = _generate_delete_confirm_sfx()
	# F016 (#104) — death_lay_down_stream 预热 (75Hz sub-bass
	# 0.4s 嗡鸣).  玩家第一次死亡时 0 合成延迟 = 与 T092 freeze
	# 帧时序精准同步的关键.  死亡事件比 unlock/delete 更稀有
	# (1 run 平均死 1-3 次 vs 14 成就分母更小), 但每次死亡都
	# 是 "emotional peak" — 0 延迟 SFX 比 0 延迟 click 更重要
	# (lay-down 与 freeze-frame 同帧 trigger, SFX 卡 0.1s
	# 玩家会感知 "我听见死亡比看见死亡晚一截" 的违和感).
	_death_lay_down_stream = _generate_death_lay_down_sfx()

# F013.B (#106) — Pre-warm 5 verb cooldown TAIL jingle streams
# (与 T181 现有 _verb_cooldown_streams 5 verb 5 stream 模式同).
# F013.C (#109) — 5 verb TAIL MIDI 改为 whole-tone scale
# (73/75/77/79/81, 严格 2 半音间隔, 配合 READY 同 microtuning).
# 玩家在 archive_01 第一次 cast pulse 时, 5 verb 5 stream 已经
# 全部 cache → fire SFX 0 延迟 + cooldown tail 0 延迟 (双 0).
# 5 stream 一次性预热 ~6 ms (与 prewarm_hit_sfx 12 stream ~15 ms
# 同量级).  Aggregator (prewarm_all_sfx) 调用此函数, 顺序:
# music → hit → shop → misc → verb_cooldown_tail (5 桶, 最后 1
# 桶, 因 cooldown tail 是 verb 自身事件, 与 verb fire SFX 紧
# 邻播放, 任何 verb cast 之前必须就绪).
func prewarm_verb_cooldown_tails() -> void:
	for verb_name in ["pulse", "bind", "cut", "echo", "wave"]:
		var start_midi: int = _verb_cooldown_tail_start_midi(verb_name)
		if start_midi < 0:
			continue  # Future verb 6+ safety
		if not _verb_cooldown_tail_streams.has(verb_name):
			_verb_cooldown_tail_streams[verb_name] = _generate_verb_cooldown_tail_jingle(start_midi)

# T220 (#142) — F022 verb cooldown READY jingle prewarm bucket.
# Mirrors prewarm_verb_cooldown_tails() (F013.B #106, 5 stream)
# but for the READY side: 5 verb _verb_cooldown_streams[verb_name]
# entries that previously lazy-generated on first play_verb_cooldown_
# ready(verb_name) call.  READY jingle fires when a verb comes off
# cooldown (T181, ascending pentatonic 0.10s "verb unlocked"), and
# is the audible "go" cue that pairs with the next cast's fire SFX.
# Caching the READY stream means the player gets a 0-synth-delay
# "verb ready" cue the moment a verb is usable, not 0.1s+ later.
# Uses _verb_cooldown_start_midi (NOT _verb_cooldown_tail_start_midi)
# so the READY pitch set (69/71/73/75/77 whole-tone) is preserved.
# 5 stream × ~2 ms = ~10 ms.  Aggregator calls this AFTER
# prewarm_verb_cooldown_tails() so both ends of the cooldown
# "ready → tail" loop are warmed in the same 7-bucket fan-out.
func prewarm_verb_cooldown_readys() -> void:
	for verb_name in ["pulse", "bind", "cut", "echo", "wave"]:
		var start_midi: int = _verb_cooldown_start_midi(verb_name)
		if start_midi < 0:
			continue  # Future verb 6+ safety
		if not _verb_cooldown_streams.has(verb_name):
			_verb_cooldown_streams[verb_name] = _generate_verb_cooldown_jingle(start_midi)

# T184 (#102) — Aggregator: prewarm BGM + 4 verb hits + shop SFX in
# one call.  Title / Hub / Archive scene _ready hooks invoke this
# so per-level streams are guaranteed cached even after long
# scene-change downtime (Godot's AudioStreamPlayer does not LRU
# evict user-side caches, but defensive re-prewarm is cheap and
# makes the "player sat in pause menu for 30 min" edge case
# trivially safe).  Idempotent — every helper guards its own
# cache.  Total cost: ~25 ms on the first call, <1 ms on the rest.
#
# T185.B (#103) — Aggregator extended with prewarm_misc_sfx() for
# F014 (achievement unlock chime) + F015 (save-slot delete click).
# Order: music → hit → shop → misc (4 buckets, 1 helper each).
# New total: ~28 ms (added ~3 ms for unlock_chime + delete_confirm).
#
# F013.B (#106) — Added 5th bucket prewarm_verb_cooldown_tails()
# for 5 verb cooldown TAIL jingle streams.  Total 5 buckets,
# ~34 ms.
#
# T220 (#142) — F022 — Extended to 7 buckets by appending
# prewarm_verb_fire_sfx() (5 verb fire SFX, ~15 ms) +
# prewarm_verb_cooldown_readys() (5 verb cooldown READY jingle,
# ~10 ms).  Final order:
#   music → hit → shop → misc → verb_cooldown_tail →
#   verb_fire → verb_cooldown_ready
# Total: 7 buckets, ~59 ms on first call, <1 ms on rest.  All
# "fire" + "hit" + "ready" + "tail" verb events are 0-synth-delay
# from session 1 frame 0.  Verb-fire is placed AFTER
# verb_cooldown_tails (verb-cooldown events precede cast in
# gameplay timing) so the aggregator walks the gameplay loop
# forward: BGM starts → first cast fires → cooldown completes →
# ready jingle → next cast fires.
func prewarm_all_sfx() -> void:
	prewarm_music_streams()
	prewarm_hit_sfx()
	prewarm_shop_sfx()
	prewarm_misc_sfx()
	# F013.B (#106) — 5 verb cooldown TAIL 5 stream 预热 (5 桶
	# aggregator 最后 1 步, ~6 ms 总成本 → 整 5 桶 ~34 ms)
	prewarm_verb_cooldown_tails()
	# T220 (#142) — F022 — 5 verb fire SFX 5 stream 预热 (~15 ms)
	# 第 6 桶.  fire SFX 在 tail 之后, 覆盖 "cast → tail → fire"
	# 完整时序.
	prewarm_verb_fire_sfx()
	# T220 (#142) — F022 — 5 verb cooldown READY jingle 5 stream
	# 预热 (~10 ms) 第 7 桶.  ready 在 fire 之后, 覆盖
	# "cooldown complete → ready jingle → next cast" 完整时序.
	prewarm_verb_cooldown_readys()

func prewarm_music_streams() -> void:
	for key in AudioPresets.MUSIC_PRESETS.keys():
		# Ensure each preset is generated and cached.  We don't
		# need the stream back; _ensure_music_stream stores it in
		# _music_streams as a side effect.
		_ensure_music_stream(key)

func play_music_track(key: String, fade_ms: int = 1500) -> void:
	# T071 — Boss override: if a boss theme is active, redirect any
	# non-boss key request (e.g. GFC's play_music_track("archive_exploration"))
	# to the boss track.  This makes the override transparently coexist
	# with the existing state-machine routing.
	if not _boss_override_key.is_empty() and key != _boss_override_key:
		key = _boss_override_key

	# No-op if same track already playing
	if _current_music_key == key and _current_music_player and is_instance_valid(_current_music_player):
		if _current_music_player.playing:
			return

	var stream := _ensure_music_stream(key)
	if not stream:
		return

	var new_player := AudioStreamPlayer.new()
	new_player.name = "MusicPlayer_%s" % key
	new_player.stream = stream
	new_player.bus = "Music"
	# Start silent, tween up to 0 dB
	new_player.volume_db = -80.0
	add_child(new_player)
	new_player.play()

	var fade_sec: float = max(0.05, float(fade_ms) / 1000.0)
	# F016.B (#108) — BGM transition smoothing. 之前用 linear tween,
	# crossfade 中段有"突然一个时间点能量最大" 的 harsh 听感.
	# 改成 TWEEN_TRANS_CUBIC + EASE_IN_OUT 让两端 (新 + 旧) 都是
	# 缓慢开始 + 中段加速 + 缓慢结束, 听觉上更"渐变", 玩家
	# 不会听到 crossfade 中点的"能量峰值".  set_parallel(true)
	# 让 fade_in 与 fade_out 同步走 (与原行为一致), cubic
	# ease_in_out 不会让并行 tween 错位.  影响范围:  所有 9
	# BGM 主题 (title_intro / hub_warm / archive_exploration /
	# archive_boss / archive_boss_dual / archive_dawn /
	# archive_storm / silence_void / whisper_hollow) +
	# 4 类 transition (新游戏 / 进房间 / Boss 阶段 2 / finale).
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(new_player, "volume_db", 0.0, fade_sec)

	var old_player := _current_music_player
	if old_player and is_instance_valid(old_player):
		tween.tween_property(old_player, "volume_db", -80.0, fade_sec)
		tween.chain().tween_callback(func() -> void:
			if is_instance_valid(old_player):
				old_player.queue_free()
		)

	_current_music_player = new_player
	_current_music_key = key

func stop_music(fade_ms: int = 1000) -> void:
	if not _current_music_player or not is_instance_valid(_current_music_player):
		return
	var old_player := _current_music_player
	var fade_sec: float = max(0.05, float(fade_ms) / 1000.0)
	# F016.B (#108) — BGM transition smoothing (与 play_music_track
	# 同步), 让 stop_music 的 fade-out 也走 cubic ease_in_out.
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(old_player, "volume_db", -80.0, fade_sec)
	tween.tween_callback(func() -> void:
		if is_instance_valid(old_player):
			old_player.queue_free()
	)
	_current_music_player = null
	_current_music_key = ""

func get_current_music_key() -> String:
	return _current_music_key

# T239 (#157) — Stop the active Music bus preview (if any). Called
# by SettingsMenu when the menu is hidden, so a 3s preview doesn't
# bleed into gameplay after the player closes the menu. Idempotent:
# safe to call when no preview is active.
func stop_music_preview() -> void:
	if _active_preview_player and is_instance_valid(_active_preview_player):
		_active_preview_player.stop()
		_active_preview_player.queue_free()
	_active_preview_player = null

# T239 (#157) — SettingsMenu Music bus volume preview button.
# Plays `key` through the Music bus for `duration_sec` seconds with
# a short fade-in / fade-out, *without* touching _current_music_player
# or _current_music_key. This is a "test your volume slider" feature:
# the player drags the Music slider, clicks "Preview", and hears 3s of
# a randomly chosen BGM theme at the current Music bus volume. Because
# the preview is a one-shot AudioStreamPlayer that's freed after the
# fade-out, it does not interrupt the in-game BGM (which keeps its
# own _current_music_player untouched).  Multiple consecutive previews
# kill the previous preview player (avoid 9 stacking players when the
# player spam-clicks the button).
func preview_music_track(key: String, duration_sec: float = 3.0, fade_ms: int = 250) -> void:
	var stream := _ensure_music_stream(key)
	if not stream:
		return
	# T239 — Kill any previous preview so spam-clicks don't stack.
	if _active_preview_player and is_instance_valid(_active_preview_player):
		_active_preview_player.stop()
		_active_preview_player.queue_free()
		_active_preview_player = null
	var preview := AudioStreamPlayer.new()
	preview.name = "MusicPreview_%s" % key
	preview.stream = stream
	preview.bus = "Music"
	# Start silent, tween up to 0 dB (same convention as play_music_track).
	preview.volume_db = -80.0
	add_child(preview)
	preview.play()
	_active_preview_player = preview
	var fade_sec: float = max(0.05, float(fade_ms) / 1000.0)
	# Fade in over fade_sec, hold for (duration_sec - 2 * fade_sec), then
	# fade out over fade_sec. We use a single chained tween so the
	# three phases happen in sequence without manual timer wiring.
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(preview, "volume_db", 0.0, fade_sec)
	# Hold phase: clamp to >= 0.0 in case the caller asked for a
	# duration shorter than 2 * fade_sec.
	var hold_sec: float = max(0.0, duration_sec - 2.0 * fade_sec)
	if hold_sec > 0.0:
		tween.tween_interval(hold_sec)
	tween.tween_property(preview, "volume_db", -80.0, fade_sec)
	tween.tween_callback(func() -> void:
		if is_instance_valid(preview):
			preview.queue_free()
		# Only null out if WE are still the active preview (a new
		# preview may have started during the fade-out — don't clobber it).
		if _active_preview_player == preview:
			_active_preview_player = null
	)

# ============================================================
# T117 — Finale music curve (silence_void → archive_dawn)
# ============================================================
# Auto-stitches the two-stage GAME_OVER_SUCCESS "resolution"
# curve: first silence_void (4s zero-amplitude — "the world
# empties out"), then archive_dawn (12.6s G major swell — "the
# world breathes back in").  Total perceived length: ~4s of
# silence then a slow 2.4s fade-in to archive_dawn.  This
# replaces the previous single-track "play_music_track
# (archive_dawn, 2400)" call in GFC GAME_OVER_SUCCESS, giving
# the success state its own audio signature (vs. GAME_OVER_FAILURE
# which only plays silence_void and never resolves).
#
# The crossfade is implemented as a chained play_music_track
# call driven by a Timer (so that Timer signals survive even
# when the GFC scene tree changes during the same beat).
# Specifically: phase 1 (silence_void, fade_in 0.4s) plays
# immediately, then after silence_void.duration (4.0s) plus
# the fade_in window, the second play_music_track (archive_dawn,
# fade_in 2.4s) fires.
#
# If the player dismisses the GAME_OVER_SUCCESS screen before
# the second phase fires (e.g. they pick "返回 hub"), the GFC
# scene transition will call play_music_track("hub_warm", 1200)
# which short-circuits the finale naturally — the Timer is
# still in flight but its callback will play archive_dawn on
# top of hub_warm for ~2.4s.  This is an acceptable artifact:
# the success fanfare resolving into hub_warm is the same
# semantic as a final fanfare-over-Hub-landing.  We do not
# defensively Timer.stop() because the cost (1-2s of audible
# archive_dawn leaking into hub) is smaller than the cost of
# tracking a "finale cancelled" flag across scene trees.
const FINALE_PHASE1_KEY := "silence_void"
const FINALE_PHASE2_KEY := "archive_dawn"
const FINALE_PHASE1_DURATION := 4.0   # matches silence_void.duration preset
const FINALE_PHASE1_FADE_MS := 400    # 0.4s fade-in to silence
const FINALE_PHASE2_FADE_MS := 2400  # 2.4s slow swell to archive_dawn

func play_music_finale() -> void:
	# T117 — fires the two-stage finale.
	# Step 1: silence_void (4s) with 0.4s fade-in.
	play_music_track(FINALE_PHASE1_KEY, FINALE_PHASE1_FADE_MS)
	# Step 2: schedule archive_dawn to begin after silence_void
	# loop has played out.
	var timer := get_tree().create_timer(FINALE_PHASE1_DURATION)
	timer.timeout.connect(func() -> void:
		# Re-check the world is still alive — if the player
		# already returned to hub/title, the GFC will have
		# routed to hub_warm or title_intro already.  In that
		# case we skip the finale phase 2 to avoid doubling
		# the BGM.  We use a simple heuristic: if the current
		# music key is still silence_void (i.e. we haven't
		# been preempted), play archive_dawn on top.
		if _current_music_key == FINALE_PHASE1_KEY:
			play_music_track(FINALE_PHASE2_KEY, FINALE_PHASE2_FADE_MS)
		# else: GFC has already routed to hub_warm / title_intro
		# during the silence phase; the success fanfare is
		# suppressed to honor the player's "return" choice.
	)

# ============================================================
# T071 — Boss music override
# ============================================================
# Used by elite enemies (InkWarden) to temporarily redirect the
# background music to a more intense variant while they are alive.
# Stacks cleanly with the GFC state-machine routing: the GFC keeps
# calling play_music_track("archive_exploration") as usual, but the
# override transparently swaps the track until the boss is defeated.
#
# Ref-counted (#38 T067) so multiple bosses in the same room
# (e.g. archive_04 with 2 InkWardens) each call request_boss_music()
# on _ready, and the override is only released after the LAST boss
# is purified.  Single request → single release still works.
#
# This pattern is idempotent — multiple request_boss_music() calls
# with the same key are safe (no re-trigger).  release_boss_music()
# restores the previous routing.

## Request a boss music override.  Ref-counted: each call increments
## the override count; the override stays active until an equal
## number of release_boss_music() calls are made.  If already in
## boss mode for the same key, this is a no-op (the existing track
## keeps playing).
##
## T080 — Intensity tier upgrade: if a boss with a HIGHER-tier key
## (e.g. archive_boss_dual = 2) requests while a lower-tier key
## (archive_boss = 1) is active, we upgrade the track with a
## short crossfade.  Lower-tier requests during a higher-tier
## override are pure ref-count bumps (don't downgrade).  Unknown
## keys fall back to no-op with a push_warning.
func request_boss_music(boss_key: String, fade_ms: int = 800) -> void:
	if not AudioPresets.MUSIC_PRESETS.has(boss_key):
		push_warning("AudioManagerEnhanced: unknown boss music key '%s'" % boss_key)
		return
	var new_tier: int = int(AudioPresets.BOSS_MUSIC_TIER.get(boss_key, 0))
	_boss_override_count += 1
	if _boss_override_key == "":
		# First request — start the override and play.
		_boss_override_key = boss_key
		play_music_track(boss_key, fade_ms)
		return
	# Already in boss mode.  Tier upgrade?
	var current_tier: int = int(AudioPresets.BOSS_MUSIC_TIER.get(_boss_override_key, 0))
	if new_tier > current_tier:
		# Switch to the more intense track.  Short crossfade
		# (300ms feels punchy for a mid-fight upgrade).  The
		# ref-count is already bumped above, so the
		# corresponding release won't accidentally clear the
		# override.
		_boss_override_key = boss_key
		play_music_track(boss_key, 300)
		# T165 (#85) — Brief 0.15s Glass Cyan screen flash on tier
		# upgrade so the player gets a clear "music just escalated"
		# cue, not just the audio crossfade.  peak_alpha 0.18 keeps
		# it as a quick vignette — not a full-screen bleach.  Layer
		# 256 is *above* the default 128 used by T097 hit flashes
		# (T163 layer param) so a simultaneous hit + tier-up stays
		# readable: the cyan tier-up vignette sits on top.
		if Engine.has_singleton("ScreenShake") or _has_screen_shake_autoload():
			ScreenShake.flash_color(
				Color("#69C7CE"),  # Glass Cyan per STYLE_GUIDE
				0.15,             # duration (fade-in + fade-out total)
				0.18,             # peak alpha
				256               # flash_layer: above hit-flash 128
			)
	# else: same or lower tier — pure ref bump, do nothing.

## Release the boss music override.  Ref-counted: decrements the
## override count and only clears the override / fades out the
## boss track when the count reaches 0.  Single request → single
## release still works (count goes 0→1 on request, 1→0 on release).
func release_boss_music(fade_ms: int = 1200) -> void:
	if _boss_override_count <= 0:
		return
	_boss_override_count -= 1
	if _boss_override_count > 0:
		# Other bosses still alive — keep boss music going.
		return
	# Last boss defeated — clear override and fade out.
	_boss_override_key = ""
	# If the boss track is still the active music, fade it out.
	# We don't auto-restore archive_exploration because the caller
	# (e.g. InkWarden._purify) usually triggers a room transition
	# whose GFC state change will pick the next track naturally.
	if _current_music_key != "" and _current_music_player and is_instance_valid(_current_music_player):
		stop_music(fade_ms)

## Returns true if a boss music override is currently active.
func is_boss_music_active() -> bool:
	return not _boss_override_key.is_empty()


# T165 (#85) — Defensive autoload probe before calling ScreenShake.  Both
# autoloads are listed in project.godot, so under normal gameplay this
# is always true; the guard exists so smoke tests / headless contexts
# (where the audio manager may be initialised before ScreenShake) can
# call request_boss_music() without crashing on a null reference.
func _has_screen_shake_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("ScreenShake")
