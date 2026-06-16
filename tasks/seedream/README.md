# Seedream 素材换血工程 — 迭代文件组织 (Voxglass Project)

> 本项目由自动化 Agent 驱动，每整点触发一次，每次执行一个"原子任务"。
> 规划阶段完成于 iteration #99（2026-06-12）。执行阶段预计 #100–#115。
> 所有文件均为规划文档，**不自动执行**；Agent 每轮读取对应任务文件并调用
> `scripts/pipeline_seedream.py::run_seedream_pipeline()` 来完成实际生成。

---

## 目录结构

```
/workspace/tasks/seedream/
├── README.md              ← 本文件（组织总览，阅读顺序 1）
│
├── 00_spec/
│   ├── prompt_template.md ← Prompt 模板：风格基座 + 世界观 + 色板约束
│   ├── matting_strategy.md← 抠图策略：白底/黑底/不抠 的类型判别表
│   ├── seed_management.md ← Seed 区间分配与跳跃重试规则
│   └── quality_gates.md   ← L1 自动校验 + L2 视觉评估门槛
│
├── 01_group_a_concept/    ← A 组：概念设定 + Steam 胶囊 (#100–#107)
│   ├── A075_moodboard.md
│   ├── A076_saya_concept.md
│   ├── A077_archive_scene.md
│   ├── A078_enemy_sheet.md
│   ├── A079_prop_sheet.md
│   ├── A080_ui_hud_kit.md
│   ├── A081_steam_feature_capsule.md
│   └── A082_steam_main_capsule.md
│
├── 02_group_b_sprites/    ← B 组：游戏内精灵升级 (#108–#113)
│   ├── A083_silence_mote.md
│   ├── A084_bell_broken.md
│   ├── A085_bell_repaired.md
│   ├── A086_npc_archivist.md
│   ├── A087_npc_tuner.md
│   └── A088_npc_silent_merchant.md
│
└── 03_group_c_optional/   ← C 组：装饰物件 + 备选图标 (#114–#115)
    ├── A089_hourglass.md
    ├── A090_wave_totem.md
    ├── A091_hanging_bell.md
    ├── A092_pulse_icon_alt.md
    ├── A093_echo_icon_alt.md
    └── A094_achievement_alt.md
```

## 每轮 Agent 的标准执行流程

```
1. 读取 ITERATION_COUNT.txt → 当前 N
2. 读取 SEEDREAM_MIGRATION_PLAN.md → 查找第 N 轮应执行的 Axxx
3. 打开 tasks/seedream/0X_group_<x>/A<xxx>_<name>.md
4. 按文件内 recipe 调用:
       run_seedream_pipeline(asset_type, style, subject, seed, output_dir,
                             version="5.0", fallback_to_pollinations=True,
                             **overrides)
5. 校验 result.status == "PASSED"；若 REJECTED，按文件内 retry_seed 再跑一次
6. 写入 ASSET_REGISTRY.md：追加一行 | A<xxx> | ... | （按现有表格格式）
7. 写入 ROADMAP.md：把 T<对应任务> 标记为 - [x]
8. 写入 CHANGELOG.md：追加一段 #N
9. ITERATION_COUNT.txt = N + 1
10. 同一次迭代只做 1 个 Axxx（原子化），剩余留给下一轮
```

## 素材类型 → 抠图/底色/尺寸速查（与 pipeline_seedream.py 对齐）

| 类型           | 生成尺寸 | 底色策略          | 抠图           | 描边      | 典型导出尺寸        |
|----------------|----------|-------------------|----------------|-----------|---------------------|
| character      | 1024²    | "isolated on white background" | rembg u2net | 2px Ink Navy | 64/128/256/512 |
| monster/enemy  | 1024²    | "isolated on white background" | rembg u2net | 2px Ink Navy | 64/128/256/512 |
| npc portrait   | 1024×1536 | "isolated on white background" | rembg u2net | 0px（圆形框游戏内叠加） | 128/256/512 |
| item/prop      | 512²     | "pure white background"        | rembg u2net | 1px black | 32/64/128/256 |
| skill-icon     | 512²     | "pure white background"        | rembg u2net | 1px black | 32/64/128 |
| achievement    | 256²     | "pure white background"        | rembg u2net | 1px black | 16/32/64 |
| background/env | 1920×1080 | "atmospheric natural background" | ❌ 不抠 | 0 | 480/960/1920 |
| tileset proxy  | 1024²    | "seamless texture"              | ❌ 不抠 | 0 | 128/256/512 |
| steam capsule  | 1200×630 / 616×353 | "cinematic composition inside image" | ❌ 不抠 | 0 | 原始尺寸 |
| effect/vfx     | 512²     | "pure black background"        | rembg u2net | 0 | 64/128/256 |

## 风格基座 / 色板约束（所有 prompt 必须包含，顺序固定）

```
风格基座（_STYLE 对应 key 选择其一）:
  - pixel-art
  - anime
  - concept
  - ui
  - background

Voxglass 世界观句（必须追加）:
  Voxglass style — melancholic resonance, flooded underground voice archive,
  cracked glass bells, living silence, warm waveform light.

色板句（必须追加）:
  Color palette: ink-navy #081426, archive-blue #12334A, deep-teal #1D6570,
  glass-cyan #69C7CE, pale-resonance #B7E7DD, muted-violet #65506A,
  coral-pulse #E86D5A, amber-voice #F2B66E, warm-parchment #E6D5B8.
  Cold colors dominate 75%, warm accents 10%.

技术后缀（_TECH_SUFFIX 按 asset_type 选择其一）
负提示词（_NEGATIVE_BASE + _NEGATIVE_EXTRA[style] 合并）
```

## Seed 区间与管理（见 00_spec/seed_management.md）

```
A 组 2001–2099     概念/胶囊
B 组 2101–2199     NPC/敌人/道具
C 组 2201–2299     装饰/图标备选
D 组 2301–2399     预留 future
RETRY 2400–2499    REJECTED 重试专用（每次 +100）
```

## 质量门槛

- **L1（自动）**：validate_asset() ok=True，内容占比 1–98%，中心偏移<30%
- **L2（视觉）**：evaluate_asset() total_score ≥ 14 且 verdict == "KEEP"
- **失败策略**：第 1 次失败 → seed += 100 跑到 RETRY 区间重试；
  第 2 次失败 → 标记 BLOCKED，下一轮再继续；
  连续 3 轮全失败 → 降级为 Pollinations flux-anime

## 完成标准

- [ ] A 组 8 张 (A075–A082) 全部 PASSED
- [ ] B 组 6 张 (A083–A088) 全部 PASSED
- [ ] ASSET_REGISTRY 有 14 条新增记录
- [ ] ROADMAP T183–T207 全部 - [x]
- [ ] ITERATION_COUNT 到达 #115 或更早完成
