# Voxglass

A 2D pixel art action-exploration game about restoring lost voices in a flooded underground archive.

> 🇨🇳 [简体中文版 README](./README.zh-CN.md) 可用。

## Status

Work-in-progress vertical slice. Current milestone: playable 60-second room demonstrating "enter -> Pulse -> repair -> collect -> exit" core loop.

## Tech

- Engine: Godot 4.6.3 (verified — `config/features=4.4` retained for backward compat, parses clean on 4.6.3 per `REVIEW_LOG.md` #20)
- Resolution: 480x270 internal, integer-scale to 1920x1080
- Language: GDScript
- Audio: Procedural SFX (pulse / footstep / glass-break / enemy hum / repair / damage) + 9 procedural BGM themes (`title_intro` / `hub_warm` / `archive_exploration` / `archive_boss` for single InkWarden in archive_03 / `archive_boss_dual` for the two-Warden room `archive_04` / `archive_dawn` for victory / hub return / `archive_storm` tier-3 boss phase-2 escalation — InkWarden half-health transition auto-switches / `whisper_hollow` for late-game Hub — switched automatically once 2 archive rooms are cleared, see `## BGM Palette` below / `silence_void` for GAME_OVER_FAILURE + finale phase 1, see `## Game States`) — all generated at runtime via `AudioStreamWAV` synthesis in `src/scripts/audio_manager_enhanced.gd` + the 9-preset data table in `src/scripts/audio_presets.gd` (no external audio files needed). Title screen pre-warms the BGM cache so the first scene switch is zero-latency. Per-bus volume (Master / Music / SFX / Ambience) configurable in-game via the Settings menu. Boss music override is ref-counted (T078) and supports intensity-tier upgrade (T080 / #59 T107).
- **Death & respawn**: 1.5s lay-down + fade-out death animation (T075). Opens with a 0.15s slow-mo + red-tint freeze-frame (T092 — `Engine.time_scale = 0.2`, `modulate` shifts to `Color(1.4, 0.45, 0.45)` for the "drained red" reading as the alpha decays), then the body folds. After death, by default the player is teleported to the Hub safe-room (T079) — toggle "死亡后回 Hub 安全区" off in `Settings → Saves` for the classic "respawn at last Save Lantern" experience.
- **Two-stage archive lighting** (M12 polish, T076): when a room's `voice_bell` is repaired, the scene's modulate eases from cold ink-teal to a warm amber over 0.8s (stage 1) and then to a full warm wash over 2s once the room completes (stage 2). All 4 archive rooms opt in via `"atmosphere": true` in their `data/rooms/archive_*.json` files.
- Local Godot binary: `godot/Godot_v4.6.3-stable_linux.x86_64` (see `godot/README.md` and the [Headless Godot Binary Setup](#headless-godot-binary-setup) section below for the first-time extraction + `--import` recipe)

## Project Structure

```
assets/        # Art, audio, and design reference assets
src/           # Source code
  autoload/    # GameState, AudioManager singletons
  scenes/      # Godot scene files (.tscn)
  scripts/     # GDScript logic
docs/          # Design docs (Steam page, etc.)
scripts/       # Python asset pipeline tools
```

## Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | A/D or Arrow Keys | Left Stick |
| Jump | Space or W | A Button |
| Pulse (push/shield-break) | J or Z | X Button |
| Bind (pull / stun / unlock gates) | K or X | Y Button |
| Cut (slice/sunder) | L or C | LB Button |
| Interact | E or Enter | B Button |
| Pause / Menu | ESC | Start Button |
| Save (auto + manual) | (walk onto a Save Lantern / Pause → 保存进度) | — |
| Continue from save | (Title screen → 继续修复, if a save exists) | — |
| Credits | (Title screen → 致谢 button) | — |

## Screenshots

6 营销截图位于 `docs/screenshots/`（1920x1080 PNG，480x270 内部 4x 整数倍缩放）：

1. `01_title_screen.png` — 标题屏（VOXGLASS + 4 按钮）
2. `02_hub_room.png` — Hub 安全区 + 4 扇门 + 墨守者剪影
3. `03_archive_01_pulse.png` — 第一档案房 + Saya + SilenceMote + Pulse 圆环
4. `04_archive_03_boss.png` — 第三档案房 + InkWarden Boss
5. `05_archive_04_double_boss.png` — 第四档案房「共鸣祭坛」+ 双 InkWarden
6. `06_shop_merchant.png` — 无声商贩 + 商店 UI + 5 个永久升级

> **沙箱说明**：本仓库 CI 沙箱无 Xvfb / Wayland / GL 上下文，Godot 4.6.3 headless 模式强制使用 dummy 渲染器，真实 `Viewport.get_texture().get_image()` 返回 null。**本轮 (#43) 用 `tools/generate_screenshot_mockups.py` 基于既有资产合成 6 张截图**作为 M10 营销上线最后阻塞解除。真实 capture 工具 (`tools/screenshot_capture.gd` + `tools/capture_screenshots_desktop.sh`) 在桌面环境（带 Xvfb / X11 / 真机）可直接使用。详见 `tools/README.md`。

## Save System

Three save slots are persisted to `user://saves/slot_N.json`. Each slot captures:

- `current_room` + `current_scene` (room id + .tscn path, so `Continue` reloads the right scene)
- `health` / `resonance` / `shards` and the `rooms_completed` set
- unlocked `abilities` (bind / cut) and the player's last `checkpoint_position`
- `run_time_seconds` (in-game timer)
- All `achievements` unlocked so far (also written-through to `user://achievements.json` on every unlock, independently of slots)

Title screen shows a `继续修复` button only when at least one slot is occupied. The pause menu's `保存进度` button opens the same slot picker in save mode. Achievement unlocks always persist to disk the instant they're earned.

## Game States

`GameFlowController` is a small state machine with six states. Every state transition routes a BGM `play_music_track` / `play_music_finale` call into `AudioManagerEnhanced`; see the [BGM state-machine map](./assets/voxglass-bgm-state-map.png) for the visual version, or read the table below.

| State | Trigger | BGM | Audio API | Notes |
|-------|---------|-----|-----------|-------|
| `TITLE` | Game boot / Continue button | `title_intro` | `play_music_track("title_intro", 1200)` | 16s D major hopeful pad; loops while the menu sits. |
| `PLAYING` | New Game / resume from pause / scene transition complete | `hub_warm` *or* `archive_exploration` *or* `whisper_hollow` | `play_music_track(scene_bgm_key, 800)` | The exact key is `scene.bgm_key` (or `hub_warm` for Hub). Boss rooms additionally call `request_boss_music` — see BOSS override below. |
| `PAUSED` | `pause_requested` signal (Esc / P) | _unchanged_ | _none_ | BGM continues during pause; the pause menu mutes SFX only. Time-scale returns to 1.0 on resume. |
| `ROOM_TRANSITION` | Room door triggered | _unchanged_ | _none_ | Fades to black for 0.4s; the next scene's `_ready` calls `play_music_track` once its `bgm_key` is known. |
| `GAME_OVER_SUCCESS` | Player completes the final room | `silence_void` → `archive_dawn` (4.0s + 12.6s) | `play_music_finale()` (T117) | Two-stage finale. Phase 1 silence = "the world is gone"; phase 2 dawn = "the world breathes back in". A `_current_music_key` guard inside `play_music_finale` makes phase 2 honor a player-initiated hub-return. |
| `GAME_OVER_FAILURE` | Player HP ≤ 0 | `silence_void` | `play_music_track("silence_void", 1200)` | 4s zero-amplitude loop matches the T093 cold-gray visual wash. Plays alongside T115 death-quote overlay + T116 InkWarden afterimage. |

### BGM Boss Override (orthogonal to state)

InkWarden (or any enemy in the `elite_enemies` group) calls `request_boss_music` when it enters the scene. The override is **ref-counted** and **tier-ranked** so multi-boss rooms don't lose their BGM when the first boss dies, and a phase-2 upgrade automatically supersedes phase-1:

| Boss event | Override key | Tier (vs current) | Effect |
|------------|--------------|------------------|--------|
| Single InkWarden enters | `archive_boss` (A minor 108 BPM) | 1 | Forces `play_music_track("archive_boss")` regardless of `PLAYING` state routing. |
| Second InkWarden in same room | `archive_boss_dual` (A minor 132 BPM) | 2 > 1 | Mid-fight cross-fade upgrade. |
| InkWarden Phase 2 | `archive_storm` (E minor 120 BPM) | 3 > 1, 2 | Most intense preset; sustained chaos. |
| Last boss dies / despawns | _cleared_ | 0 | Returns to the scene's `bgm_key` (`archive_exploration`). |

Boss music and finale music are orthogonal: if the player dies during a boss fight, `GAME_OVER_FAILURE` is reached *from* `PLAYING+boss_override`. The override is released by `release_boss_music()` *before* the GFC routes to `silence_void`, so the failure path is clean.

## BGM Palette

The 9 procedural BGM themes are intentionally spread across the major and minor modes so each room / event reads as a different "tonal room". The keys below are MIDI numbers (A4 = 69); the chord column lists the 3- or 4-note voicing layered on top of the root sine. See [`src/scripts/audio_presets.gd`](./src/scripts/audio_presets.gd) for the full data table and per-preset design notes.

| Key | Mood | Root | Chord (MIDI) | BPM | Loop | When it plays |
|-----|------|------|--------------|-----|------|---------------|
| `title_intro` | sparse / hopeful | D3 (50) | D maj — D4 F#4 A4 | 60 | 16.0s | TITLE state (game boot) |
| `hub_warm` | warm / bright | F2 (41) | F maj — F3 A3 C4 | 88 | 10.9s | Early Hub (`rooms_completed.size() < 2`) |
| `archive_exploration` | melancholic / deep | A2 (45) | A min — A3 C4 E4 | 72 | 13.3s | Archive rooms (PLAYING + RoomController) |
| `archive_boss` | tense / single boss | A1 (33) | A min + tritone — A2 C3 F#3 | 108 | 11.1s | First InkWarden in room (tier 1) |
| `archive_boss_dual` | frantic / dual boss | A1 (33) | A min + tritone + aug5 — A2 C3 F#3 G#3 | 132 | 8.7s | Second InkWarden in room (tier 2) |
| `archive_dawn` | bright / victory | G2 (43) | G maj — G3 B3 D4 | 76 | 12.6s | GAME_OVER_SUCCESS finale phase 2 + `full_archive` unlock |
| `archive_storm` | chaos / phase 2 | E1 (28) | E min + aug4 + raised 7th — E2 G#2 B2 D3 | 120 | 10.0s | InkWarden enters phase 2 (tier 3) |
| `whisper_hollow` | "deep quiet" / min7th | D3 (50) | D min 7 — F3 A3 C4 E4 | 50 | 16.0s | Late-game Hub (`rooms_completed.size() >= 2`, #64 T123) |
| `silence_void` | emptiness / absence | (no audio) | — | 60 | 4.0s | GAME_OVER_FAILURE + finale phase 1 |

### Tonal map philosophy

- **Major keys** (`title_intro` D / `hub_warm` F / `archive_dawn` G) read as "the world is intact / hopeful / bright". The Hub starts on F major (brightest), and `archive_dawn` is the only G major (the "rising resolution" of a fifth above hub_warm's F — the world *moving up* a step on victory).
- **Minor keys** (`archive_exploration` A / `archive_boss` A / `archive_boss_dual` A / `archive_storm` E / `whisper_hollow` D) read as "the archive is decayed / melancholy / dangerous". Three of the four share A minor so the boss-fight crossfade is harmonic; `archive_storm` breaks to E minor for harmonic *contrast* (chaos, not just more intensity) and `whisper_hollow` breaks to D minor for *distance* (deep quiet, distinct from the urgent exploration theme).
- **Dissonance ladder**: clean triad → +tritone → +tritone +aug5 → +aug4 +raised7th. Each tier-1 / 2 / 3 boss preset adds a new dissonant interval, so the boss-fight music *feels* the escalation as harmonic pressure, not just loudness.
- **Silence as a theme**: `silence_void` is the only "all amplitudes zero" preset — it is *not* a BGM, it is the deliberate *absence* of BGM. It bridges the failure state (4s of empty air matches the cold-gray visual wash) and the finale phase 1 (4s of "the world empties out" before `archive_dawn` resolves it).
- **Cutscene ambient bed** (T122): not a BGM preset, but a one-shot 8-second D2 + G2 dual-sine drone on the Ambience bus, generated on demand by `AudioManagerEnhanced.play_intro_ambience()` and triggered by `intro_cutscene.gd._play_sequence()`. It lives *under* the upcoming `title_intro` BGM so the cutscene never plays over a hard silence.

## Audio Controls

`Settings → Audio` menu exposes three independent volume sliders, each bound to its own Godot AudioServer bus:

| Slider | Bus | Contents |
|--------|-----|----------|
| Master | `Master` | Everything (BGM + SFX + ambience summed) |
| Music | `Music` | Procedural BGM (`title_intro` / `hub_warm` / `archive_exploration` / `archive_boss` / `archive_boss_dual` / `archive_dawn` / `archive_storm` / `whisper_hollow` + the silent `silence_void` slot) |
| SFX | `SFX` | Pulse / Bind / Cut / footstep / glass-break / damage / repair |
| Ambience | `Ambience` | Water / wind / room atmosphere hum |

Settings persist to `user://settings.cfg` across runs.

## Development

This project follows an iterative development process. See `ITERATION_GUIDE.md` for the full workflow. New contributors should also read [`CONTRIBUTING.md`](./CONTRIBUTING.md) — it covers repo layout, the 3-method Godot binary reassembly + `--import` recipe, the 7-suite smoke test list, commit format, iteration cadence, asset-registration rules, doc-sync checklist, troubleshooting, and where to record decisions.

### Headless Godot Binary Setup

The Godot 4.6.3 headless binary is shipped as a multi-part zip in `godot/`. On first
clone (or after a fresh sandbox) it must be reassembled and unzipped before any
`--headless` command will run. **Method A** uses `unzip`; **Method B** uses Python
`zipfile` as a fallback when `unzip` errors with `bad zipfile offset` (common in
containerized sandboxes where the multi-volume zip offset parser disagrees with
the data).

```bash
# Reassemble the 4 split volumes + main archive
cd godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip

# Method A — standard unzip (works on most distros)
unzip -o /tmp/godot_full.zip && chmod +x Godot_v4.6.3-stable_linux.x86_64

# Method B — Python zipfile fallback (sandboxed environments)
# Use this if `unzip` prints "bad zipfile offset" / "extra bytes at beginning".
# The Python standard library handles the multi-volume layout more leniently.
python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('.')" \
    && chmod +x Godot_v4.6.3-stable_linux.x86_64

# Verify
./Godot_v4.6.3-stable_linux.x86_64 --version   # 4.6.3.stable.official.7d41c59c4
```

> **First-run import cache is mandatory** — the `.godot/imported/*.ctex` cache is
> git-ignored, so the very first Godot run must regenerate it, otherwise every PNG
> fails to load and cascades into 8+ spurious `SCRIPT ERROR` lines:
>
> ```bash
> ./Godot_v4.6.3-stable_linux.x86_64 --headless --import --path /workspace
> ```

For deeper troubleshooting see [`godot/README.md`](./godot/README.md).

## Development Roadmap

We iterate hourly against a publicly visible backlog. The current backlog lives in [`ROADMAP.md`](./ROADMAP.md) with task IDs `T001`–`TNNN` and timestamps marking completion.

### Milestones

| Milestone | Status | Key Tasks | Notes |
|---|---|---|---|
| **M1 — Core loop vertical slice** | ✅ Shipped (#1–#14) | T001–T013 | 60s "enter room → Pulse → repair → collect → exit" playable |
| **M2 — Second enemy + room variety** | ✅ Shipped (#8–#15) | T017–T025, T017 left-facing fix | NoteWisp + Archive 02/03 variants |
| **M3 — Save & persistence** | ✅ Shipped (#12, #33) | T022, T026, T070 | Save Lantern + 3-slot disk save + Continue |
| **M4 — Player progression** | ✅ Shipped (#13–#15) | T029–T034 | Resonance shards, InkWarden elite, Bind ability, ability gates |
| **M5 — Hub + NPCs + Settings** | ✅ Shipped (#16, #24, #34) | T035, T036, T037, T048, T072 | Safe-zone Hub, dialogue system, 4-tab settings |
| **M6 — Player stats + achievements** | ✅ Shipped (#19, #28) | T041, T042, T059–T061 | 8 Steam-style achievements + notification card + 8-icon grid |
| **M7 — Procedural BGM** | ✅ Shipped (#29, #31, #39, #44, #59) | T062, T063, T066, T071, T080, T087, T107 | 7 synthesized themes (incl. `archive_boss_dual` for `archive_04` + `archive_dawn` for victory / hub return + `archive_storm` tier-3 InkWarden phase-2 escalation) + scene routing + boss override + tier upgrade |
| **M8 — Death animation + Steam description** | ✅ Shipped (#36, #39) | T074, T075, T079 | Laying-down death, full English Steam copy, respawn-to-Hub by default + settings toggle |
| **M9 — Storefront readiness** | ✅ Shipped (#32, #34) | T069, T072, T073 | 3 Steam capsules (A047–A049), IntroCutscene, save deletion |
| **M10 — Marketing live on Steam** | ✅ Shipped (#43) | T083 | 6 marketing screenshots composited from existing assets (real capture needs desktop env — see `tools/README.md`) |
| **M11 — Late-game content** | ✅ Shipped (#38, #41) | T067, T068 | 4th archive room + second InkWarden (Resonance Shrine) + Hub shop NPC (5 permanent perks) |
| **M12 — Final polish** | ✅ Shipped (#42) | T076 | 2nd-stage archive lighting (bell repair → 0.8s warm reflow) — all 4 archives opt-in via `atmosphere: true` |

### Recent completed work

- **#60 — Review #60 (this iteration)**: code quality / gameplay / asset / docs audit. Fixed 2 general (G001 README BGM 主题数 6 → 7 含 archive_storm / G002 Recent work 补 #59 archive_storm + CHANGELOG 同步 + _unlock_timestamps 补记)
- **#59 — 文档同步 + 第 7 主题 BGM archive_storm 落地**：补全 #57（成就时间戳 + CONTRIBUTING）和 #58（README 引用 + PauseMenu hover + 死亡回 Hub 端到端冒烟）两条本该在那两轮就追加的 CHANGELOG 段；T107 在 `audio_manager_enhanced.gd` `_MUSIC_PRESETS` 新增 `archive_storm` (E minor BPM 120 / 16-note chromatic arpeggio / G#6 shimmer / 0.66Hz LFO / 4-volume 全上抬) + `_BOSS_MUSIC_TIER["archive_storm"] = 3`（严格 > archive_boss_dual tier 2）；`ink_warden.gd:529` `_enter_phase_2()` 把 `request_boss_music("archive_boss_dual")` 替换为 `request_boss_music("archive_storm", 600)`；ASSET_REGISTRY A063 条目登记；`test_t107_archive_storm_smoke.gd` (198 行 10 项断言) PASS
- **#58 — README CONTRIBUTING 入口暴露 + PauseMenu hover 高亮 + T079 端到端冒烟**（本轮）：T113 英文 README 「## Development」节顶部加 `CONTRIBUTING.md` 链接 + 9 节内容简述，README.zh-CN.md 同步加中文版（仓库结构 / 3 种 Godot 拼合 / 7 冒烟测试套件 / 提交格式 / 迭代节奏 / 美术登记 / 文档同步 5 问 / 故障排查 / 决策记录）；T111 `pause_menu.gd._build_achievement_grid` 给每个 16x16 TextureRect 加 `mouse_filter=STOP` + `mouse_entered/exited` connect + `_on_slot_hover_in/out` 0.12s tween（scale 1.0→1.5x + self_modulate 灰→亮 1.4 + modulate 暖色 1.2,1.1,0.9，parallel 三套同步）让玩家 hover 时图标"亮起来"；T112 新建 `tools/test_t112_respawn_hub_e2e_smoke.gd` (213 行) 13 项集成断言覆盖 T079 端到端流程（GameState respawn_to_hub 字段 + API + 常量 + 双分支 + GFC._ready 顺序修复 + settings_menu.cfg 持久化 + .tscn toggle label），冒烟测试 7→8
- **#57 — 成就解锁时间戳 + CONTRIBUTING.md**：T109 `PlayerStats._unlock_timestamps: Dictionary` + `get_unlock_timestamp(id) / get_unlocked_achievements_sorted_by_time()` API + 重复 unlock 保留首次时间；PauseMenu 成就 grid tooltip "解锁于 MM-DD HH:MM" + LatestUnlock label；T110 新建 `CONTRIBUTING.md` (194 行) 9 大节新协作者指南
- **#48 — Death freeze-frame VFX + README godot binary 快速指引**（本轮）：T092 `player.die()` 开头 `Engine.time_scale = 0.2` + `sprite.modulate = Color(1.4, 0.45, 0.45)` 链入 tween 首位（`tween_interval(0.15)` → `_end_death_freeze_frame` 回调恢复 time_scale=1.0 → T075 既有 0.5s lay-down + 1.0s fade-out 红调衰减，"drained red" 而非 flashing red），`respawn_at()` 兜底重置 time_scale；T091 README 新增 "Headless Godot Binary Setup" 子节（方法 A unzip + 方法 B Python `zipfile` 完整命令 + first-run `--import` 强提醒 + godot/README.md 交叉链接），Tech 节 "Local Godot binary" / "Death & respawn" 行同步更新
- **#47 — Screen shake polish + decorative props**：T089 `src/autoload/screen_shake.gd` autoload（8 个预设含 BOSS_PHASE2 5.0/0.30s 新增最高强度，Timer 30Hz micro-shake + Tween quad ease-out 衰减）；T090 6 个程序化像素装饰物件 (A055-A060 hourglass 12x16 / wave_totem 12x24 / hanging_bell 8x10 / crystal_cluster 16x12 / standing_lantern 8x20 / sound_pillar 8x24) + 14 个 archive_01-04 装饰实例（z_index=-1 排在背景上、玩家下）
- **#46 — Boss 阶段 2 (InkWarden phase 2)**
- **#45 — Review #45 (this iteration)**: code quality / gameplay / asset / docs audit. Fixed 1 minor (L001: `ArchivistShadow` → `WardenShadow` node rename in `hub_room.tscn` to match its actual InkWarden silhouette content) + 4 general (G001 ASSET_REGISTRY A051 拆为 A051 portrait + A053 sprite / G002 README BGM 主题数 5 → 6 含 archive_dawn / G003 achievements.json full_archive 描述与 4 房间数对齐 / G004 Recent work 补 #40-#44)
- **#44 — T087 第 6 BGM 主题 archive_dawn + T086 Settings 重映射打磨**：G major 三和弦 BPM 76 / GAME_OVER_SUCCESS 自动切换 / full_archive 解锁主动触发；Settings 7 动作扩 (含 move_right/bind/cut) / 冲突 swap 检测 / ESC 取消 / 青色确认闪烁 / "恢复默认按键" 按钮
- **#43 — T083 营销截图 (M10 最后阻塞解除)**：`tools/screenshot_capture.gd` (真实 GDScript 抓帧工具，桌面环境可用) + `tools/generate_screenshot_mockups.py` (沙箱 fallback，Python+Pillow 合成 6 张 1920x1080 PNG) + `tools/README.md` (使用说明 + 沙箱限制说明)。README 新增 Screenshots 节
- **#42** — Final polish M12: archive_01 + archive_03 opt-in `atmosphere: true` (all 4 archives now have bell-repair warm reflow) + `godot/README.md` Python `zipfile` fallback command (F003)
- **#41 — Store NPC**: Hub `silent_merchant` + 5 permanent upgrades (heart_crystal / resonance_chime / pulse_focus / echo_charm / silence_breaker) — 跨 run 持久化
- **#40 — Review #40**: 87 PNG headers valid, 0 static errors, 0 runtime regressions, L001 `test_api.png` JPEG 伪装清理
- **#38 — 4th archive room** (Resonance Shrine, 2 InkWardens) + boss music ref-count
- **#36 — Death animation + Steam description**: 1.5s lay-down, full English Steam copy
- **#35 — Review**: 87 PNG headers valid, 0 static errors, 0 runtime regressions
- **#34 — Settings + Intro**: Saves tab with delete-all, 8s IntroCutscene
- **#33 — Save system**: 3-slot disk persistence + Continue + auto + manual
- **#32 — Steam capsules**: 616×353, 460×215, 1200×630 marketing art
- **#31 — BGM**: archive_boss theme + pre-warm cache + override
- **#30 — Review**: 84 PNGs valid, 8 achievement icons palette-verified
- **#29 — BGM core**: 3 synthesized themes + scene routing
- **#28 — Polish**: 8 achievement icons + Credits screen

### What to read next

- `ROADMAP.md` — full task list, current candidate pool, and "已完成" timestamps
- `CHANGELOG.md` — per-iteration changelog with what shipped and what was learned
- `REVIEW_LOG.md` — every 5th-iteration audit (code quality, gameplay, assets, docs, drift)
- `STYLE_GUIDE.md` — visual constitution; **all new art must inherit from this**
- `ASSET_REGISTRY.md` — material ledger; **all new assets must be appended here**

## Room Editor (JSON)

Rooms can now be defined in JSON under `data/rooms/`. See `data/rooms/README.md` for the full schema. To test a JSON room, open `src/scenes/json_room.tscn` and set the `room_id` export variable, or call `RoomLoader.load_room(room_id, parent_node)` from GDScript.

---

🇬🇧 **English** (this file) · 🇨🇳 [简体中文版](./README.zh-CN.md)
