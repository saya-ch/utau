# Voxglass

A 2D pixel art action-exploration game about restoring lost voices in a flooded underground archive.

## Status

Work-in-progress vertical slice. Current milestone: playable 60-second room demonstrating "enter -> Pulse -> repair -> collect -> exit" core loop.

## Tech

- Engine: Godot 4.6.3 (verified — `config/features=4.4` retained for backward compat, parses clean on 4.6.3 per `REVIEW_LOG.md` #20)
- Resolution: 480x270 internal, integer-scale to 1920x1080
- Language: GDScript
- Audio: Procedural SFX (pulse / footstep / glass-break / enemy hum / repair / damage) + 6 procedural BGM themes (`title_intro` / `hub_warm` / `archive_exploration` / `archive_boss` for single InkWarden in archive_03 / `archive_boss_dual` for the two-Warden room `archive_04` / `archive_dawn` for victory / hub return) — all generated at runtime via `AudioStreamWAV` synthesis in `src/scripts/audio_manager_enhanced.gd` (no external audio files needed). Title screen pre-warms the BGM cache so the first scene switch is zero-latency. Per-bus volume (Master / Music / SFX / Ambience) configurable in-game via the Settings menu. Boss music override is ref-counted (T067) and supports intensity-tier upgrade (T080).
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

## Audio Controls

`Settings → Audio` menu exposes three independent volume sliders, each bound to its own Godot AudioServer bus:

| Slider | Bus | Contents |
|--------|-----|----------|
| Master | `Master` | Everything (BGM + SFX + ambience summed) |
| Music | `Music` | Procedural BGM (`title_intro` / `hub_warm` / `archive_exploration` / `archive_boss` / `archive_boss_dual` / `archive_dawn`) |
| SFX | `SFX` | Pulse / Bind / Cut / footstep / glass-break / damage / repair |
| Ambience | `Ambience` | Water / wind / room atmosphere hum |

Settings persist to `user://settings.cfg` across runs.

## Development

This project follows an iterative development process. See `ITERATION_GUIDE.md` for the full workflow.

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
| **M7 — Procedural BGM** | ✅ Shipped (#29, #31, #39, #44) | T062, T063, T066, T071, T080, T087 | 6 synthesized themes (incl. `archive_boss_dual` for `archive_04` + `archive_dawn` for victory / hub return) + scene routing + boss override + tier upgrade |
| **M8 — Death animation + Steam description** | ✅ Shipped (#36, #39) | T074, T075, T079 | Laying-down death, full English Steam copy, respawn-to-Hub by default + settings toggle |
| **M9 — Storefront readiness** | ✅ Shipped (#32, #34) | T069, T072, T073 | 3 Steam capsules (A047–A049), IntroCutscene, save deletion |
| **M10 — Marketing live on Steam** | ✅ Shipped (#43) | T083 | 6 marketing screenshots composited from existing assets (real capture needs desktop env — see `tools/README.md`) |
| **M11 — Late-game content** | ✅ Shipped (#38, #41) | T067, T068 | 4th archive room + second InkWarden (Resonance Shrine) + Hub shop NPC (5 permanent perks) |
| **M12 — Final polish** | ✅ Shipped (#42) | T076 | 2nd-stage archive lighting (bell repair → 0.8s warm reflow) — all 4 archives opt-in via `atmosphere: true` |

### Recent completed work

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
