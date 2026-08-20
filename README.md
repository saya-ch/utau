# Voxglass

A 2D pixel art action-exploration game about restoring lost
voices in a flooded underground archive.

> 🇨🇳 [简体中文版 README](./README.zh-CN.md) 可用。

## Status

The feature set has grown beyond the 60-second prototype:
Hub, five archive rooms, six sound verbs, five save slots,
six shop items, 15 achievements, procedural audio.
Modern fresh-import gate 11/11 PASS, Windows exports
succeeded, 6/6 viewport captures PASS. Not a release
candidate: playthrough, CI, signing, packaging remain.
See [CURRENT_STATUS.md](docs/01-entry/current-status.md)
for authoritative status.

## Current Build Contract

- **Five-room route:** New Game → archive_01 → Hub →
  archive_02/03/04 → locked archive_05 → GAME_OVER_SUCCESS.
- **Six verbs:** Pulse, Bind, Cut, Echo, Wave, Whisper.
- **Five saves:** user://saves/slot_N.json with room/state.
- **15 achievements:** full_archive, archive_master etc.
- **Evidence:** modern gate 11/11 green, captures 6/6.

## Tech

- Engine: Godot 4.6.3 fresh import verified
- Resolution: 480x270 internal, integer scale to 1920x1080
- Language: GDScript
- Audio: Procedural SFX + 9 BGM via AudioStreamWAV
  (see docs/03-product/changelog/index.md for BGM)
- Death: 1.5s lay-down, Hub respawn toggle
- Lighting: two-stage archive lighting M12 polish

## Project Structure

```
assets/        # Art, audio, design reference
src/           # Source code
  autoload/    # GameState, AudioManager
  scenes/      # Godot scenes (.tscn)
  scripts/     # GDScript logic
docs/          # Layered docs (see 00-index.md)
scripts/       # Python asset pipeline
data/          # JSON data
```

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | A/D or Arrow | Left Stick |
| Jump | Space or W | A Button |
| Pulse | J or Z | X Button |
| Bind | K or X | Y Button |
| Cut | L or C | Button 4 |
| Echo | Q or R | Button 5 |
| Wave | V | Button 6 |
| Whisper | T or 4 | Button 7 |
| Interact | E or Enter | B Button |
| Pause | ESC | Start |
| Save | Save Lantern / Pause → Save | — |
| Continue | Title → Continue | — |

## Screenshots

Six 1920x1080 mockups in docs/screenshots/ (asset
compositions). Real captures via capture_screenshots.py
6/6 PASS. See current-status for evidence path.

## Save System

Five slots user://saves/slot_N.json store room, vitals,
perks, checkpoint, runtime, achievements. Title shows
Continue when slot occupied. Pause → Save opens picker.

## Audio

Settings → Audio: Master/Music/SFX/Ambience buses.
Persist to user://settings.cfg.

## Development

See [ITERATION_GUIDE.md](docs/02-guides/iteration-guide.md)
for workflow and
[CONTRIBUTING.md](docs/02-guides/contributing-core.md)
for conventions. Use strict runtime gate 11/11.

### Historical Linux Recovery

godot/ is historical split archive, not current binary.
Install Godot 4.6.3 and pass executable to strict runner.
See [godot/README.md](godot/README.md) for reassembly.

## Development Roadmap

Backlog in [ROADMAP.md](docs/03-product/roadmap/index.md)
T001–TNNN. See roadmap shards for interval tables.

### Milestones

| Milestone | Status | Key Tasks | Notes |
|---|---|---|---|
| M1 Core loop | ✅ Historical | T001–T013 | 60s playable |
| M2 Second enemy | ✅ Historical | T017–T025 | NoteWisp |
| M3 Save & persistence | ✅ Historical | T022 T026 T070 | Save |
| M4 Player progression | ✅ Historical | T029–T034 | Resonance |
| M5 Hub + NPCs | ✅ Historical | T035 T036 | Hub |
| M6 Stats + achievements | ✅ Historical | T041 T059 | 15 ach |
| M7 Procedural BGM | ✅ Historical | T062 T071 | 9 themes |
| M8 Death + storefront | ✅ Historical | T074 T075 | death |
| M9 Storefront prep | ✅ Historical | T069 T072 | capsules |
| M10 Screenshots | ✅ Historical | T083 | mockups 6/6 |
| M11 Late content | ✅ Historical | T067 T068 | Archive 04 |
| M12 Final polish | ✅ Historical | T076 | lighting |

## 文档导航

- [入口详情](docs/01-entry/details.md) — 详细安装/贡献/handbook
- [中文详情](docs/01-entry/details.zh-CN.md) — 中文版详情
- [总导航](docs/00-index.md) — 4 层文档导航
- [Roadmap](docs/03-product/roadmap/index.md) — 迭代区间
- [Changelog](docs/03-product/changelog/index.md) — 50 轮分片
- [当前状态](docs/01-entry/current-status.md) — 权威状态
- [资产登记](docs/03-product/asset-registry.md) — 77 条目

> 最后更新：ITERATION 315 (#315 审查模式，见 changelog)

## 最近更新（近 2 轮摘要）

- #315 审查模式 5 维度审计 61/61 PASS
- #314 T371 9.6.113 硬度 polish 1:1 落地
- 更多见 [Changelog](docs/03-product/changelog/index.md)
  与 [details.md](docs/01-entry/details.md)

## 关联

- 中文版：[README.zh-CN.md](README.zh-CN.md)
- 贡献：[CONTRIBUTING.md](CONTRIBUTING.md)
- 迭代指南：[docs/02-guides/iteration-guide.md](docs/02-guides/iteration-guide.md)

