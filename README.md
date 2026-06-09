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

# Method B-1 — `unzip -FF` strong-fallback (recommended for sandboxes / Python 3.14+)
# Use this if `unzip` prints "bad zipfile offset" or "extra bytes at beginning".
# `unzip -FF` re-compensates bad offsets and works even when standard `unzip` fails.
# Expected output: warnings about "bad zipfile offset" + "attempting to re-compensate",
# then `inflating: Godot_v4.6.3-stable_linux.x86_64` succeeds.
unzip -FF -o /tmp/godot_full.zip 2>&1 | tail -20 && chmod +x Godot_v4.6.3-stable_linux.x86_64

# Method B-2 — Python zipfile fallback (works for Python ≤ 3.13 ONLY)
# Use this if both standard `unzip` and `unzip -FF` are unavailable.
# ⚠️ Python 3.14+ standard `zipfile` library fails to extract multi-volume zip —
#    `_extract_member` raises `BadZipFile: Bad magic number for file header` (F003 #82).
#    On Python 3.14+ systems (e.g. fresh Ubuntu 25.04, CI 2026+ images) use B-1 instead.
python3 -c "import sys; print(sys.version_info[:2]); " \
    && python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('.')" \
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

- **#84 — T101 ResonanceWave 命中粒子层叠 8→12 (4 new visual layers) + T163 ScreenShake.flash_color / flash_grayscale 接受可选 [flash_layer] 参数 + F004 修复 3 套件 pre-existing stale-state 冒烟测试**：`resonance_wave_vfx.gd` 新增 14 常量 (`DEEP_SHADOW_RADIUS_RATIO=0.42` / `INNER_HALO_RADIUS_RATIO=0.55` / `OUTER_WISP_RADIUS_RATIO=1.18` / `OUTER_WISP_COUNT=12` / `SPARKLE_RADIUS_RATIO=0.70` / `SPARKLE_COUNT=6` 等) + 3 色常量 (`#65506A` Muted Violet / `#B7E7DD` Pale Resonance / `#F2B66E` Amber Voice 严格对齐 STYLE_GUIDE 限制色板) + `_draw()` 改写为 9 段 painter's order (deep_shadow→inner_halo→ring_fill→ring_stroke→8 prism_rays→12 outer_wisps→6 sparkle_stars 闪烁 alpha→center_core→bounce_flash), 4 新 layer 从 1 layer 静态环变 8 layer 多深度冲击波；`screen_shake.gd` `flash_color(..., flash_layer: int = 128)` + `flash_grayscale(..., flash_layer: int = 128)` 接受 canvas layer 索引 (默认 128 保持向后兼容, 上层 256 高于 HUD, 下层 64 低于 HUD), `_active_grayscale` + `_active_color_flash` 从单 `CanvasLayer` 引用重构为 `Dictionary` 按 layer_idx 分桶 (同 layer 后调用取消前调用 / 跨 layer 并行), `stop()` 迭代 `dict.keys()` 清掉 *所有* layer 上的活动 flash；F004 修复 (1) `test_t150_t147_t149_smoke.gd` `_handle_jump` 字符串窗口 1800 → 2500 char (T145 17 行 docblock + T147 4 行 + D001 注释让相关代码落在 char 1827-1900) + 新增 D001 sync 断言验证 `is_action_globally_blocked()` 是 `PlayerActionGate.is_blocked()` 的 thin delegate, (2) `test_t158_t156_f002_smoke.gd` F002.7 / F002.8 硬编码 `#81` → 动态 `ITERATION_COUNT.txt - 1` (含 file-not-found fallback), (3) 复用 (1) 顺带同步 T147 守卫与 #76 重命名; `test_t101_t163_f004_smoke.gd` 18 项新断言 PASS + 全 36/36 冒烟测试套件 PASS
- **#83 — T162 PlayerProfilePanel "最近 5 局详细" 列表 + T159 InkWarden phase 2 dissolve 0.25s 出 + 0.30s 入 tween**：`pause_menu.tscn` 在 `ProfileTrend20` 之后新增 `ProfileRecentTitle`（"✦ 最近 5 局 ✦" Amber Voice 9pt center）+ `ProfileRecentList` VBoxContainer；`pause_menu.gd` 新增 `@onready var _profile_recent_list` + 3 常量（`_PROFILE_RECENT_RUNS_MAX=5` 视觉密度上限 / `_COLOR_RECENT_RUN_NORMAL` Pale Resonance 沿用 trend 调色板 / `_COLOR_RECENT_RUN_LATEST` Amber Voice 高亮最近 1 局）+ 新方法 `_refresh_recent_runs_list()` 实现 5 个设计选择（最新 1 局 Amber Voice 高亮 / reversed order 最新在顶 / 每行 4 字段 `Run #N 房 X 净 Y 碎 Z 时 mm:ss` / 空 history 走"暂无 run 记录"占位 / dynamic child creation 防 stale data）；**与 T131 trend 5/10/20 行互补**：trend 给"宏观"平均指标，recent 给"具体"每局明细（"Run #5 净 0 死 3"立刻归因到"没找到 Pulse"）。`ink_warden.gd` 顶部新增 4 常量（`PHASE_2_DISSOLVE_OUT_TIME=0.25` / `PHASE_2_DISSOLVE_IN_TIME=0.30` / `PHASE_2_DISSOLVE_OUT_SCALE=1.15` / `PHASE_2_DISSOLVE_IN_START_SCALE=0.85`）；`_enter_phase_2()` sprite swap 段改写为 5 段 tween（snap reset / dissolve out 0.25s scale 1.0→1.15 + alpha 1.0→0.0 / snap start / dissolve in 0.30s scale 0.85→1.0 + alpha 0.0→1.0 / existing red flash + settle 完整保留），共 1.03s 视听序列与 T156 5 段完美嵌套（shake 中段 = dissolve 中段）。原来 1f sprite 硬切被替换为 0.55s 渐变，让 phase 2 进入"我正在失控进化"而非"突然换皮"的体感。`test_t162_t159_smoke.gd` 21 项断言 PASS
- **#82 — F003 4 文档同步 Python 3.14+ zipfile 兜底 + T160 PauseMenu "新成就!" Banner + T161 settings "还原所有推荐" 按钮 + D001 PlayerActionGate autoload 抽出**：`godot/README.md` + `README.md` + `README.zh-CN.md` + `CONTRIBUTING.md` 4 文档同步重写为 方法 B-1 `unzip -FF` 强容错（沙箱 / Python 3.14+ 推荐）+ 方法 B-2 Python `zipfile` 兜底（**仅 Python ≤ 3.13 有效**），实测复现 Python 3.14.4 `BadZipFile: Bad magic number for file header`；`pause_menu.tscn` 新增 `NewAchvBanner` Label（top center Amber Voice 10pt "✦ 新成就！✦"）+ `pause_menu.gd` 3 常量（`_BANNER_DURATION=0.8` / `_BANNER_FADE=0.4` / `_BANNER_RECENT_UNLOCK_WINDOW=5.0`）+ 双轨触发（menu 可见直接 animate + 不可见记 `_last_seen_unlock_ts` 5s 窗口内 ESC 补播）；`settings_menu.tscn` 新增 `RestoreAllButton`（Amber Voice 200×24）+ `settings_menu.gd` `_on_restore_all_pressed()` 3 阶段（按键 `InputMap.action_erase_events` + `_DEFAULT_BINDINGS` / 音量 4 slider 100% + `AudioServer.set_bus_volume_db` / autosave `SaveSystem.set_autosave_enabled/interval/slot` 推默认）+ amber 0.8s "✓ 已还原" toast；`src/autoload/player_action_gate.gd` 新建 22+80 行 Node autoload（4 public API: `register_player/unregister_player/is_blocked/get_player`）+ `is_blocked()` 复合 OR（`_is_dying` + `wave_ability.is_globally_blocking`）+ `project.godot` autoload 段注册 + `player.gd` `_ready/_exit_tree` register/unregister + `is_action_globally_blocked()` 改 thin delegate + `resonance_wave_ability.gd` `is_globally_blocking()` 头部加 D001 refactor 注释；`test_d001_t160_t161_f003_smoke.gd` 21 项断言 PASS
- **#81 — T158 EchoAbility 4 重击命中后慢动作 0.4s 0.85x time-scale + T156 ArchiveStorm 主摄像机 1f skybox rotate 0.5° 0.2s ease 收回 + F002 `check_smoke_consistency.sh` README 同步检查 hook 规则 ⑦**：`echo_ability.gd` 新增 `signal echo_multi_reflect(count: int)` + `const MULTI_REFLECT_THRESHOLD = 4` + 在 `_reflect_projectile` 末尾首次达到 4 emit 一次（同 cast 后续反弹不再 emit 防 spam）；`player.gd._ready` 用 `has_signal("echo_multi_reflect")` 守卫连 `_on_echo_multi_reflect` → 0.4s await × 0.85 time_scale，await 结束检查 `_is_dying` 避免覆盖 die() 的 1.0 重置；`screen_shake.gd` 新增 `punch_rotation(degrees=0.5, duration=0.2)` API（cam.rotation = deg_to_rad 立即设置 + tween 0.2s quad ease 收回，`stop()` 兜底归零 + kill tween）；`ink_warden.gd._enter_phase_2()` 顶部（shake_preset 之前）调 `ScreenShake.punch_rotation(0.5, 0.2)` 形成 5 段视听序列：sky 反应 → BOSS_PHASE2 震 → sprite swap → RepairVFX ring → BGM tier-up；`check_smoke_consistency.sh` 加 rule 7（README.md + README.zh-CN.md "Recent completed work" / "最近完成的工作" 段解析最新 #N 与 ITERATION_COUNT.txt 比对，滞后 ≥2 轮 FAIL 阻断 commit / 滞后 1 轮 WARN），根除 G001 第 4 次同类风险；`test_t158_t156_f002_smoke.gd` 28 项断言 PASS
- **#80 — Review #80 (this iteration)**: full code quality / gameplay / asset / docs audit; 0 SCRIPT ERROR + 0 runtime ERROR + 47 class_name 唯一 + 78 signal 完整 + 114 PNG 合法 + 6 autoload 一致 + 72 ASSET_REGISTRY 记录 + 32 冒烟测试套件 32/32 PASS + `check_smoke_consistency.sh` 6/6 规则 PASS；严重 0 / 一般 1（G001 README Recent work 补 #76-#79 4 轮已修）/ 轻微 0 / 信息 1
- **#79 — T152 0 数灰阶 + T153 槽位 jingle + T151 "最近" badge**：`pause_menu.gd` `_COLOR_ZERO_STAT` 暖灰 `#808389` + `_set_zero_aware_stat()` helper（6+4 行用 0 占位 "—"）；`audio_manager_enhanced.gd` `_SAVE_SLOT_MIDI_NOTES = [72,76,79,84,88]` pentatonic C5/E5/G5/C6/E6 + `_generate_save_slot_jingle()` 0.25s 三角波 bell body + `play_save_slot_jingle()` 公开 API（save/load 共享）；`save_load_menu.gd` `_find_most_recent_slot()` + `_format_recent_badge()` BBCode `[color=#B7E6DC]★ 最近[/color]` Pale Resonance + `_refresh_slots` 一次扫 5 槽定 most_recent_slot 下传 `_refresh_card` / `_refresh_list_row`；4 状态字符完整化（[·]/[—]/[✗]/[✓]）；`test_t152_t153_t151_smoke.gd` 19 项 PASS
- **#78 — T144 wave_focus 谐波 + T148 wave_combo chime tail + T154 灯反向闪**：`audio_manager_enhanced.gd` `_wave_hit_streams: Dictionary` 4 level 缓存（0=1320Hz 基频 2.4x 谐波 / 1=+3.6x / 2=+5.0x / 3=+6.8x 凯旋钟塔）按 `GameState.get_perk_count("wave_focus")` 路由；`play_wave_combo()` 0.6s E6+G#6 双音衰减 + `_on_wave_combo()` 末接；`save_lantern.gd` `flash_coral_pulse()` 0.15s Coral Pulse 反向闪 + `silenced_web.gd on_cut_triggered` 迭代 `save_lantern` group 触发；`test_t144_t148_t154_smoke.gd` 26 项 PASS
- **#77 — T150 5 动词 profile + T147 jump 阻塞 UX + T149 Echo parallax**：`player_stats.gd` `last_used_verb` 字段 + `record_ability_used` 入口首行刷新 + `reset_stats` 清空 + `pause_menu.tscn` ProfileLastVerb Label + `pause_menu.gd` match 5 动词 BBCode 调色板（pulse Coral / bind Violet / cut Amber / echo Cyan / wave Pale Resonance）；`hud.gd` `show_jump_blocked()` + `player.gd _handle_jump` 双层守卫（is_action_just_pressed 触发）；`echo_vfx.gd` PARALLAX 三常量（rotation 0.5 / radius 1.08 / alpha 0.55）+ PI/8 偏移 + 0.25 rad/s 副层旋转；`test_t150_t147_t149_smoke.gd` 22 项 PASS
- **#76 — T143 wave 4 状态提示 + T145 is_action_globally_blocked 重构 + T146 wave_combo 屏震**：`hud.gd` 4 verb 专属方法（charging / winding_up / active / blocked）+ `player.gd _handle_wave` 4 分支路由按生命周期排（active → winding_up → cooldown → cost-low）；`_is_wave_globally_blocking` 重命名为公开 `is_action_globally_blocked()` + OR `_is_dying` 守卫 + 4 verb handler 调用点 + `_handle_jump` 阻塞时清零 coyote+buffer timer 防死亡解除后"原地跳"；`resonance_wave_ability.gd` `wave_combo` signal（`@export wave_combo_threshold=3`）+ `_deactivate_wave` 末尾 emit；`player.gd _on_wave_combo` shake(4.0, 0.4) + flash_color(Electric Violet #8C5BFF, 0.18s, 0.30)；`test_t143_t145_t146_smoke.gd` 25 项 PASS + `test_t142` 重命名同步
- **#75 — Review #75 (this iteration)**: full code quality / gameplay / asset / docs audit; 0 SCRIPT ERROR + 0 runtime ERROR + 47 class_name 唯一 + 77 signal 完整 + 114 PNG 合法 + 6 autoload 一致 + 72 ASSET_REGISTRY 记录 + 28 冒烟测试全 PASS + 1 一般 (G001 README Recent work 补 #61-#75 15 轮已修) + 1 信息 (候选池继续走 polish 路线)
- **#75 — T130 hotfix (成就 13→14 同步) + T142 (5-verb 链防误触安全网) + T141 (wave 命中 audio cue)**：成就定义 `total_count`/`unlocked_count` 同步 13→14 + `achievements.json` `quintuple_voice` 入列；T142 `resonance_wave_ability.gd._try_fire()` 加 5 帧 verb-action-only 窗口（拒绝 `is_on_floor_only=true` 的 `is_dashing` 期间触发的"动画中波"）；T141 `resonance_wave_ability.gd` 命中路径 `AudioManagerEnhanced._sfx_bus_play("wave_hit", 0.4 + i*0.04, 1.05 + i*0.02)` 链入 `hit_count` 循环；新增 `tools/test_t130_achievement_sync_smoke.gd` 14 项断言 PASS
- **#74 — T103 第二半 (Wave 5-verb 对称) + T140 _handle_wave 失败提示走 verb 专属方法 + T139 成就计数 13→14**：player.gd `_handle_wave()` 5 路径完整 pulse / cut / bind / echo / wave（wave→resonance_wave 桥接）；T140 失败提示新增 `_wave_off_cooldown_prompt()` / `_wave_silenced_prompt()` / `_wave_already_active_prompt()` 3 个 verb-专属方法（更准确反馈而非泛化"无法释放"）；T139 A072 `quintuple_voice` 5-verb 一次完成成就落地；新增 `tools/test_t139_quintuple_voice_smoke.gd` + `tools/test_t140_wave_verb_prompts_smoke.gd` PASS
- **#73 — T103 第一半 (ResonanceWave 群体波) + T137 SaveLoadMenu 快速加载 + T138 PauseMenu 上次自动存档时间**：A070 `resonance_wave_vfx` (procedural vector pulse) + A071 wave 技能图标 (16x16 程序化像素) + `src/scripts/resonance_wave_ability.gd` (228 行 9 exports + 4 signals + 4 阶段生命周期 + 命中追踪) + `src/scripts/resonance_wave_vfx.gd` 8 层视觉组 + HUD `WaveRow` 第五冷却条（Electric Violet 主题色）；T137 `save_load_menu.gd` quick load card (slot 0 / 上次手动存档) 优先显示 + Ctrl+L 触发；T138 PauseMenu 新增"上次自动存档: N 分钟前"摘要；`test_t103_resonance_wave_smoke.gd` (31 项断言) + `test_t137_t138_quick_load_and_autosave_smoke.gd` (17 项) PASS
- **#72 — T136 SaveSystem 自动存档 60s + T135 PauseMenu 分享剪贴板**：SaveSystem `_autosave_timer` (60s 间隔 / 启用开关) + `last_autosave_at` 时间戳 + `pause_menu.cfg` 持久化 `autosave_enabled`；T135 PauseMenu 新增"分享"按钮 → DisplayServer.clipboard_set (成就摘要 + 4 段格式化文本 + run 编号 + 死亡次数)；`test_t135_share_smoke.gd` + `test_t136_autosave_smoke.gd` PASS
- **#71 — T134 settings 动态 SLOT_COUNT + T133 PauseMenu Quick Stats 摘要行**：settings_menu.cfg 新增 `save_slot_count` (1-10) + SaveSystem 启动时 clamp + 5→10 槽 UI 自动扩展；T133 PauseMenu 顶部"本次 Run" + "历史最佳"两行摘要（run 编号 / 死亡次数 / 修理数 / 收集数 / 房间数）；`test_t133_quick_stats_smoke.gd` + `test_t134_dynamic_slot_count_smoke.gd` PASS
- **#70 — Review #70 (D001-D003 严重问题修复)**: D001 `_autosave_timer` 改 Timer 节点 (单 timer / pause_mode=PROCESS) + SceneTree 改 `_autosave` async；D002 `get_run_id()` 改 Time.get_unix_time_from_system() + 文件名含 UTC 时间戳（避免碰撞）；D003 `_health_danger` 改 danger_threshold + beat/tween 同步 + 0.6s 渐显；ASSET_REGISTRY A068-A069 装饰物件登记；3 严重 / 0 一般 / 1 轻微 (L001) / 1 信息
- **#69 — T131 Run 趋势 + T132 备份/恢复 API**：PauseMenu 趋势卡（4 项 stats: run 数 / 平均修理 / 死亡数 / 收集率） + `SaveSystem.get_run_trend()` API；T132 备份/恢复（`backup_save()` → `user://backups/save_N.bak` / `restore_from_backup()` + 自动备份触发器 [manual save / settings delete]）；`test_t131_run_trend_smoke.gd` + `test_t132_backup_restore_smoke.gd` PASS
- **#68 — T129 存档健康度 + T130 历史最佳成就**：SaveSystem `get_save_health()` (per-slot 校验 / CRC32 + last_modified + run_id 摘要) + PauseMenu 存档 tab 健康度标签（健康 / 警告 / 损坏）；T130 历史最佳成就触发条件 (本次 run 修理数 ≥ 历史最高 修理数) + `_check_personal_best()` 钩子 + PauseMenu "本次 Run / 历史最佳" 双行显示；ASSET_REGISTRY A067 `personal_best` 成就登记；`test_t129_save_health_smoke.gd` + `test_t130_personal_best_smoke.gd` PASS
- **#67 — T127 Run 编号 + 历史最佳 + T128 SaveSystem CRC32**：GameState `current_run_id` (UTC yyyymmddhhmmss) + `SaveSystem` 每次 save 写入 `run_id` 字段 + PauseMenu 顶部 "Run #yyyymmddhhmmss"；T128 SaveSystem CRC32 校验（save 头 8 字节 + payload + checksum）+ `get_save_meta()` API + 自动修复损坏检测；`test_t127_run_id_smoke.gd` + `test_t128_crc32_smoke.gd` PASS
- **#66 — F003 smoke_consistency.sh + T126 Player Profile**：T125 `tools/check_smoke_consistency.sh` (6 条规则 144 行 bash: smoke_test_count >= 15 / README BGM 数 / ASSET_REGISTRY 总数 / PROJECT_NAME 一致 / headless 启动 0 错 / uid 已生成) 全 PASS；T126 PauseMenu Player Profile (3 卡片: Player Name / Total Playtime / Best Run Summary) + ProjectSettings 输入字段；`test_t126_player_profile_smoke.gd` PASS
- **#65 — Review #65 (D001-D004 修复轮)**：D001 `paused` SignalListener 重复（player.gd 重复监听）已重构为单连接 + 幂等检查；D002 `pause_menu.gd._build_achievement_grid` 16x16 texture 引用 orphan 修复（增加 GroupReferenceHolder 跟踪）；D003 `t134_dynamic_slot_count` 测试 UID 漏提交修复；D004 `_handle_wave` 在 is_dashing 状态触发造成动画穿插修复；44 class_name 零冲突 + 73 signal 完整 + 114 PNG 合法 + 65 ASSET_REGISTRY + 7 冒烟测试套件 14 测试全 PASS
- **#64 — T122 IntroCutscene ambient + T123 whisper_hollow 路由 + T124 BGM 9 主题色板文档**：IntroCutscene 8s → 12s (加 ambient layer 渐入 / 渐出 4s) + 文档同步；T123 audio_manager_enhanced.gd `route_for_scene()` 加 `intro_cutscene → whisper_hollow` 分支；T124 STYLE_GUIDE.md BGM 节扩展 9 主题色板表格（archive_calm / archive_boss / archive_boss_dual / archive_dawn / archive_storm / silence_void / whisper_hollow / finale / intro）；`test_t122_intro_ambient_smoke.gd` + `test_t123_whisper_routing_smoke.gd` PASS
- **#63 — T121 audio_presets.gd 重构 + T118 whisper_hollow + T120 README Game States 节**：T121 audio_presets.gd 新建 (8 BGM 主题常量 + tier 等级 + 调色板 + 路由映射 集中 5 段 → 1 段) audio_manager_enhanced.gd `_MUSIC_PRESETS` dict 抽取；T118 `whisper_hollow` BGM 主题 (F# minor BPM 64 / 全 5th + 7th / LFO 0.4Hz / 4-volume mute 主旋律) + `route_for_scene("whisper_hollow")` + PauseMenu 设置 routing 优先级；T120 README 新增 "Game States" 节 (intro / hub / archive / boss / death / respawn 6 状态 + BGM 主题映射表)；`test_t121_audio_presets_smoke.gd` + `test_t118_whisper_hollow_smoke.gd` PASS
- **#62 — T117 finale 曲式**：audio_manager_enhanced.gd `_MUSIC_PRESETS["finale"]` 落地 (C major → E minor 终止 + 16-note descending arpeggio + tier 4 + GameState._on_full_archive_collected 触发)；ASSET_REGISTRY A066 `finale_theme` 登记；`test_t117_finale_smoke.gd` PASS
- **#61 — T114 silence_void BGM + T115 死亡碑文 + T116 InkWarden 残影**：T114 silence_void BGM (D minor BPM 48 / drone + 0.18Hz LFO / 4-volume 全 mute 主体) + audio_manager_enhanced.gd `route_for_scene("silence_void")` + tier 1；T115 player.gd `die()` tween 链加 0.4s 灰调 wash 后的"墓志铭"字幕（font_size 8 → 6 fade-in）；T116 ink_warden.gd `phase_2_silhouette_remain()` (死亡后 2.5s 残影淡出) + `silhouette_alpha` tween (0.6 → 0) + z_index=10 顶层显示；ASSET_REGISTRY A064 `silence_void` + A065 `silhouette_remain` 登记；`test_t114_silence_void_smoke.gd` + `test_t115_death_inscription_smoke.gd` + `test_t116_silhouette_smoke.gd` PASS
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
