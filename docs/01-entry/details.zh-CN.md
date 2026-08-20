# Voxglass 详情

> 本文件为 README 入口详情（中文），与 details.md 双语同步。
> 归属：docs/01-entry/details.zh-CN.md
> 当前迭代 315，详见 [changelog/index.md](../03-product/changelog/index.md)

## 概述

Voxglass 是一款 2D 像素动作探索游戏，在被淹没的档案馆中
修复被夺走的声音。本详情文件包含从精简 README 移出的扩展章节。

## 快速开始

- 安装 Godot 4.6.3，fresh import，跑通严格门禁 11/11。
- 见 [iteration-guide](../02-guides/iteration-guide.md) 了解流程。
- 见 [contributing-core](../02-guides/contributing-core.md) 了解约定。

## 系统要求

- Godot 4.6.3，Windows/Linux，480x270 内部分辨率。
- Python 3 工具链，PowerShell 7+ docs-lint。

## 详细安装

Godot 二进制重组（历史分卷）：

```bash
cd godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip
unzip -o /tmp/godot_full.zip && chmod +x Godot_v4.6.3-stable_linux.x86_64
```

首次 import 强制：`godot --headless --import --path .`

## 贡献指南

- 阅读 [CONTRIBUTING.md](../../CONTRIBUTING.md)（代理）
  与 [contributing-core](../02-guides/contributing-core.md)。
- Handbook §9.6 113 段 55 分片
  [handbook/polish-patterns/index.md](../handbook/polish-patterns/index.md)。
- 遵循迭代节奏 N%5==0 审查模式。

## 手册导航

- 核心：[contributing-core](../02-guides/contributing-core.md)
- 索引：[handbook index](../handbook/polish-patterns/index.md)
- 分片：55 文件 9.6.01-08 等，每文件 <500 行。

## 高频素材替换

Saya 动画、无声商贩、Whisper HUD、Silence Mote、
Voice Bell 美术已通过内置图像生成刷新，本地去背景后在
Godot 验收。见 art_generation_manifest.md。

## 六种能力 windup 契约

六种能力均经 _verb_windup_vfx_base.gd 共享生命周期：
- ramp-in：二次缓出激活 tween。
- ramp-out：fade_out_and_free() 0.05s 退出。
- 独立 motif：Pulse 收缩、Bind 内旋、Cut 横扫、
  Echo 外撑、Wave 涟漪、Whisper 汇聚。

## 存档系统详情

五个槽位持久化到 user://saves/slot_N.json，保存房间/场景、
生命/共鸣/碎片、rooms_completed、能力、永久升级、检查点、
运行时间、成就。Continu 映射场景。覆写需确认，删除需二次
弹窗（T188）。

## 成就系统详情

15 枚成就数据驱动，见 data/achievements.json。
M6 里程碑含通知卡与统计面板。

## 游戏状态机详情

GameFlowController 6 状态：TITLE、PLAYING、PAUSED、
ROOM_TRANSITION、GAME_OVER_SUCCESS、GAME_OVER_FAILURE。
BGM 经 AudioManagerEnhanced 路由，Boss 覆盖引用计数分级。

## BGM 详情

9 主题：title_intro、hub_warm、archive_exploration、
archive_boss、archive_boss_dual、archive_dawn、
archive_storm、whisper_hollow、silence_void。
见 [audio_presets.gd](../../src/scripts/audio_presets.gd)。

## 路线图与变更日志

- Roadmap：[roadmap/index.md](../03-product/roadmap/index.md) ITERATION 315
- Changelog：[changelog/index.md](../03-product/changelog/index.md) 13 分片
- 近期 #314/#315 见 changelog iter-301-350.md

## 关联

- 总导航：[00-index.md](../00-index.md)
- 英文详情：[details.md](details.md)
- 当前状态：[current-status.md](current-status.md)

