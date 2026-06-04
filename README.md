# Voxglass

A 2D pixel art action-exploration game about restoring lost voices in a flooded underground archive.

## Status

Work-in-progress vertical slice. Current milestone: playable 60-second room demonstrating "enter -> Pulse -> repair -> collect -> exit" core loop.

## Tech

- Engine: Godot 4.6.3 (verified — `config/features=4.4` retained for backward compat, parses clean on 4.6.3 per `REVIEW_LOG.md` #20)
- Resolution: 480x270 internal, integer-scale to 1920x1080
- Language: GDScript
- Audio: Procedural SFX (pulse / footstep / glass-break / enemy hum / repair / damage) + 5 procedural BGM themes (title_intro / hub_warm / archive_exploration / **archive_boss** for single InkWarden in archive_03 / **archive_boss_dual** for the two-Warden room `archive_04`) — all generated at runtime via `AudioStreamWAV` synthesis in `src/scripts/audio_manager_enhanced.gd` (no external audio files needed). Title screen pre-warms the BGM cache so the first scene switch is zero-latency. Per-bus volume (Master / Music / SFX / Ambience) configurable in-game via the Settings menu. Boss music override is ref-counted (T067) and supports intensity-tier upgrade (T080).
- **Death & respawn**: 1.5s lay-down + fade-out death animation (T075). After death, by default the player is teleported to the Hub safe-room (T079) — toggle "死亡后回 Hub 安全区" off in `Settings → Saves` for the classic "respawn at last Save Lantern" experience.
- Local Godot binary: `godot/Godot_v4.6.3-stable_linux.x86_64` (see `godot/README.md`)

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
| Music | `Music` | Procedural BGM (title_intro / hub_warm / archive_exploration / archive_boss) |
| SFX | `SFX` | Pulse / Bind / Cut / footstep / glass-break / damage / repair |
| Ambience | `Ambience` | Water / wind / room atmosphere hum |

Settings persist to `user://settings.cfg` across runs.

## Development

This project follows an iterative development process. See `ITERATION_GUIDE.md` for the full workflow.

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
| **M7 — Procedural BGM** | ✅ Shipped (#29, #31, #39) | T062, T063, T066, T071, T080 | 5 synthesized themes (incl. `archive_boss_dual` for `archive_04`) + scene routing + boss override + tier upgrade |
| **M8 — Death animation + Steam description** | ✅ Shipped (#36, #39) | T074, T075, T079 | Laying-down death, full English Steam copy, respawn-to-Hub by default + settings toggle |
| **M9 — Storefront readiness** | ✅ Shipped (#32, #34) | T069, T072, T073 | 3 Steam capsules (A047–A049), IntroCutscene, save deletion |
| **M10 — Marketing live on Steam** | 🔄 In progress | T074 (copy done), screenshot capture | 6 real in-game screenshots still pending |
| **M11 — Late-game content** | 📋 Backlog | T067, T068 | 4th archive room + second InkWarden, Hub shop NPC |
| **M12 — Final polish** | 📋 Backlog | T076 | 2nd-stage archive lighting (bell repair → warm color return) |

### Recent completed work

- **#39 (current)** — Death-to-Hub respawn policy (T079) + `archive_04` dual-boss BGM theme `archive_boss_dual` (T080) — settings toggle for classic mode
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
