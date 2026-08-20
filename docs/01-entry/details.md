# Voxglass Details

> 本文件为 README 入口详情（English），与 details.zh-CN.md 双语同步。
> 归属：docs/01-entry/details.md
> 当前迭代 315，详见 [changelog/index.md](../03-product/changelog/index.md)

## Overview

Voxglass is a 2D pixel art action-exploration game about
restoring voices in a flooded archive. This details file
contains the extended sections removed from slim README.

## Quick Start

- Install Godot 4.6.3, fresh import, run strict gate 11/11.
- See [iteration-guide](../02-guides/iteration-guide.md) for workflow.
- See [contributing-core](../02-guides/contributing-core.md) for conventions.

## System Requirements

- Godot 4.6.3, Windows/Linux, 480x270 internal.
- Python 3 for tools, PowerShell 7+ for docs-lint.

## Detailed Installation

Godot binary reassembly (historical archive):

```bash
cd godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip
unzip -o /tmp/godot_full.zip && chmod +x Godot_v4.6.3-stable_linux.x86_64
```

First import mandatory: `godot --headless --import --path .`

## Contributing

- Read [CONTRIBUTING.md](../../CONTRIBUTING.md) (proxy)
  and [contributing-core](../02-guides/contributing-core.md).
- Handbook §9.6 113 segments in 55 shards
  [handbook/polish-patterns/index.md](../handbook/polish-patterns/index.md).
- Follow iteration cadence N%5==0 review mode.

## Handbook Navigation

- Core: [contributing-core](../02-guides/contributing-core.md)
- Index: [handbook index](../handbook/polish-patterns/index.md)
- Shards: 55 files 9.6.01-08 etc, each <500 lines.

## High-frequency Art Refresh

Saya animation, Silent Merchant, Whisper HUD, Silence Mote,
Voice Bell art refreshed via built-in imagegen, chroma-key
removed, validated in Godot. See art_generation_manifest.md.

## Six-verb Windup Contract

All six verbs route via _verb_windup_vfx_base.gd:
- Ramp-in: quadratic ease-out activation tween.
- Ramp-out: fade_out_and_free() 0.05s exit.
- Motifs: Pulse contracts, Bind spirals, Cut sweeps,
  Echo expands, Wave ripples, Whisper converges.

## Save System Details

Five slots user://saves/slot_N.json store room/scene,
health/resonance/shards, rooms_completed, abilities,
perks, checkpoint, runtime, achievements. Continue resolves
scene map. Overwrite needs confirm, delete needs second
modal (T188).

## Achievements Details

15 achievements data-driven, see data/achievements.json.
M6 milestone includes notification card and stats panel.

## Game States Details

GameFlowController 6 states: TITLE, PLAYING, PAUSED,
ROOM_TRANSITION, GAME_OVER_SUCCESS, GAME_OVER_FAILURE.
BGM routing via AudioManagerEnhanced. Boss override
ref-counted tiered.

## BGM Details

9 themes: title_intro, hub_warm, archive_exploration,
archive_boss, archive_boss_dual, archive_dawn,
archive_storm, whisper_hollow, silence_void.
See [audio_presets.gd](../../src/scripts/audio_presets.gd).

## Roadmap & Changelog

- Roadmap: [roadmap/index.md](../03-product/roadmap/index.md) ITERATION 315
- Changelog: [changelog/index.md](../03-product/changelog/index.md) 13 shards
- Recent #314/#315 in changelog iter-301-350.md

## 关联

- 总导航：[00-index.md](../00-index.md)
- 中文详情：[details.zh-CN.md](details.zh-CN.md)
- 当前状态：[current-status.md](current-status.md)

