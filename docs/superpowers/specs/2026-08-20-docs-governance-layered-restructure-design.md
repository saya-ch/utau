# 文档深度治理分层重构设计 — Voxglass (utau)

> 日期: 2026-08-20 | 状态: 待评审 | 分支策略: `docs-restructure/*` 三批 PR | 作者: OpenCode Brainstorming

## 1. 背景与目标

### 1.1 项目上下文
- 项目: Voxglass / `C:\Users\20655\Desktop\GitHub\utau`, Godot 4.6.3, 480×270 像素, 66 GDScript / 30 tscn / 7 autoload, 6
  动词 + 5 房间。
- 迭代: `ITERATION_COUNT.txt:1` 当前 315, 迭代链 §9.6 已累积 113 段 polish 模式 (#169 T251 → #314 T371), 89 环 polish 链。
- 约束: 用户要求「深度治理 + 全面重排都可 + 可维护性优先」, 单文件 <800 行、单行 <120 字符。

### 1.2 已量化痛点（2026-08-20 实测）
| 文件 | 行数 | 体积 | 超限项 |
|---|---|---|---|
| `CONTRIBUTING.md:1` | 2940 | 2.88 MB | 113 段 §9.6 单文件承载，§9.6.1-9.6.113 均在同一文件 |
| `ROADMAP.md:1` | 1119 | 847 KB
| 前 32 行含 32 处 >2000 字符，`ROADMAP.md:32` 达 21612 字符、`ROADMAP.md:34` 17481 字符，`ROADMAP.md:95` 13759 字符 |
| `REVIEW_LOG.md:1` | 4127 | 713 KB | 超 800 行 5 倍 |
| `REVIEW_LOG_ARCHIVE.md:1` | 3119 | 294 KB | 同上 |
| `CHANGELOG.md:1` | 609 | 752 KB | 单文件尚可但与 `CHANGELOG_ARCHIVE.md:1` 6040 行/1.38 MB 合计 6649 行 |
| `README.md:1` / `README.zh-CN.md:1` | 954 / 971 | 1.1 / 0.94 MB | 双语均超 800，内容重复率高 |
| `docs/:1` | 3 文件 322 行 | — | 入口缺失，无总导航 |

**判定**: 根目录扁平 + 单文件巨型化 + 超长行 + 归档未分片 = 可维护性红灯。

### 1.3 成功标准（可维护性优先）
- 任意 `docs/**` 或根代理文件: 行数 ≤800, 行长 ≤120 字符（`docs-lint.ps1` 校验）。
- `CONTRIBUTING §9.6` 113 段不再单文件承载，分片后每文件 ≤500 行。
- `ROADMAP` 超长行清零，时间线可按迭代区间检索。
- 根目录代理文件可一跳抵达实体，旧链接通过 `redirect-map.json` 兜底。

## 2. 架构设计（Section 1 已确认）

### 2.1 分层原则
目录即语义，代理与实体分离，历史可追溯。

```
utau/
├── README.md                    # 代理 ~300-350 行（精简，链向 docs/01-entry/details.md）
├── README.zh-CN.md              # 代理 同步
├── CONTRIBUTING.md              # 代理 ~120 行（导航+重定向）
├── ROADMAP.md                   # 代理 ~80 行（概览+链向 docs/03-product/roadmap/）
├── CHANGELOG.md                 # 近 50 轮保留 + 链向分片
├── CURRENT_STATUS.md            # 代理 → docs/01-entry/current-status.md
├── STYLE_GUIDE.md / ITERATION_GUIDE.md / RESEARCH.md / INSPIRATION.md  # 代理
└── docs/
    ├── 00-index.md              # 总导航（全文档地图，<300 行）
    ├── 01-entry/                # 入口层
    │   ├── details.md           # README 详情展开
    │   ├── current-status.md
    │   └── navigation.md
    ├── 02-guides/               # 指南层
    │   ├── contributing-core.md # §1-§9.5 + §9.7-§11 核心 (~600 行)
    │   ├── iteration-guide.md   # 来自 ITERATION_GUIDE.md:1
    │   ├── style-guide.md       # 来自 STYLE_GUIDE.md:1
    │   └── contributing-fragility.md # §9.5 入口
    ├── handbook/
    │   └── polish-patterns/     # 承接 §9.6 113 段
    │       ├── index.md         # §9.6 总览 + 分片索引
    │       ├── 9.6.01-9.6.20.md # 每 20 段一文件，共 6 文件，均 <500 行
    │       ├── 9.6.21-9.6.40.md
    │       ├── 9.6.41-9.6.60.md
    │       ├── 9.6.61-9.6.80.md
    │       ├── 9.6.81-9.6.100.md
    │       └── 9.6.101-9.6.113.md
    ├── 03-product/              # 产品层
    │   ├── roadmap/
    │   │   ├── index.md         # 时间线概览 + 进度可视化 (<400 行)
    │   │   ├── iter-001-100.md
    │   │   ├── iter-101-200.md
    │   │   ├── iter-201-300.md
    │   │   └── iter-301-315.md  # 当前，后续按 100 轮扩
    │   ├── changelog/
    │   │   ├── index.md
    │   │   ├── iter-001-050.md … iter-301-315.md (按 50 轮分片)
    │   │   └── archive/         # 承接 CHANGELOG_ARCHIVE.md:1 分片
    │   ├── asset-registry.md    # 来自 ASSET_REGISTRY.md:1 (精简后 <400 行，详情链 assets/)
    │   ├── research.md
    │   └── inspiration.md
    ├── 04-archive/              # 归档层
    │   └── review/
    │       ├── index.md
    │       ├── review-001-100.md … review-301-315.md (按 100 轮分片，来自 REVIEW_LOG.md:1 + REVIEW_LOG_ARCHIVE.md:1)
    │       └── archive-meta.md
    └── superpowers/specs/       # 本设计所在
        └── 2026-08-20-docs-governance-layered-restructure-design.md
```

### 2.2 根代理清单（5 代理 + 2 保留）
- 保留代理: `README.md:1`, `README.zh-CN.md:1`, `CONTRIBUTING.md:1`, `ROADMAP.md:1`, `CHANGELOG.md:1` — 永久保留，内容仅含标题、迁移声明、链向
  docs 实体。
- 迁移后根代理同步瘦身: `CURRENT_STATUS.md:1`→代理, `STYLE_GUIDE.md:1`→代理, `ITERATION_GUIDE.md:1`→代理,
  `RESEARCH.md:1`/`INSPIRATION.md:1`→代理, `ASSET_REGISTRY.md:1`→代理。
- 实体文件 `git mv` 迁入 docs，历史保留。

## 3. 组件与文件映射（Section 2 已确认）

### 3.1 CONTRIBUTING 拆分
- 源: `CONTRIBUTING.md:349` 起的 §9.6 113 段（`CONTRIBUTING.md:370` §9.6.1 至末尾约 113 段）。
- 目标:
  - `docs/02-guides/contributing-core.md` — 承载 §1-§9.5、§9.7-§11，约 600 行，负责贡献流程、门禁、测试约定。
  - `docs/handbook/polish-patterns/index.md` — §9.6 索引，含 113 段标题锚点表。
  - 6 个分片文件 — 每 20 段一文件，最后一片 13 段，均 <500 行，文件名即锚点区间便于检索。
  - 根 `CONTRIBUTING.md:1` — 重写为 120 行代理: 概述 + 指向 core 与 handbook 的链 + 迁移声明。

### 3.2 ROADMAP 分片
- 源: `ROADMAP.md:1` 1119 行，前 32 行超长块为历史迭代单行压缩。
- 重排: 将 `ROADMAP.md:1-32` 超长行按迭代区间拆为 Markdown 表格（列: 迭代/任务/类型/状态），每 100 轮一文件，超长行通过换行 + 表格化清零。
- 目标: `docs/03-product/roadmap/index.md` (进度总览) + 4 个 iter 分片，根 `ROADMAP.md:1` 代理。

### 3.3 REVIEW_LOG / CHANGELOG 归档分片
- `REVIEW_LOG.md:1` 4127 + `REVIEW_LOG_ARCHIVE.md:1` 3119 → `docs/04-archive/review/` 按 100 轮分片 8 文件 + index。
- `CHANGELOG.md:1` 609 + `CHANGELOG_ARCHIVE.md:1` 6040 → `docs/03-product/changelog/` 按 50 轮分片 13 文件 + index；根
  `CHANGELOG.md:1` 保留近 50 轮。
- `REVIEW_LOG.md:1` 顶部的审计维度说明移入 `docs/04-archive/review/index.md`。

### 3.4 README 双语精简
- `README.md:954` + `README.zh-CN.md:971` → 根各精简至 350 行以内（保留项目简介、快速开始、导航），详情展开迁入 `docs/01-entry/details.md` 与
  `docs/01-entry/details.zh-CN.md`，双语通过 `docs/00-index.md` 互链。

### 3.5 重定向与兼容
- 所有代理文件头部含 `> 已迁移: 旧路径 → 新路径` 块 + 相对链。
- 生成 `docs/redirect-map.json` — 旧锚点 (§9.6.x, ROADMAP 行锚) → 新文件+行号 映射，供脚本与后续 CI 使用。

## 4. 数据流与迭代工作流（Section 3 已确认）

### 4.1 新迭代写入路径
1. 开发者完成迭代 #316 → 写入对应分片:
   - ROADMAP → `docs/03-product/roadmap/iter-301-400.md`
   - CHANGELOG → `docs/03-product/changelog/iter-301-350.md`
   - REVIEW_LOG (若为审查轮) → `docs/04-archive/review/review-301-400.md`
2. 同步更新 `docs/00-index.md` 与各层 `index.md` 的“最近更新”段。
3. 更新 `ITERATION_COUNT.txt:1` 与分片末尾一致性校验。

### 4.2 自动化校验（C-lite）
- `tools/docs-lint.ps1` — 四项检查: 单文件行数 ≤800、单行 ≤120、index 链接有效(相对路径存在)、ITERATION_COUNT 与末分片一致。
- 触发: `pre-commit` 钩子 + 手动 `pwsh tools/docs-lint.ps1`。
- 规则分级: `warn` (超限 10% 内) → `error` (硬超限)，当前阶段以 warn 为主，避免阻塞迭代。

### 4.3 迁移脚本
- `tools/migrate-docs.ps1` — 幂等: 读取 `redirect-map.json`，执行 `git
  mv`、重写内部互链（CONTRIBUTING↔ROADMAP↔REVIEW_LOG↔CHANGELOG）、生成代理文件。
- 批量替换范围: `*.md` 与 `tools/*.ps1` 中硬编码路径，分 3 批提交便于 review。

## 5. 容错与验证（Section 4 已确认）

### 5.1 容错
- 幂等重跑: `migrate-docs.ps1` 可重复执行，已迁移项跳过。
- 旧锚点兜底: `redirect-map.json` 保留旧 `CONTRIBUTING.md:370` 等锚点 → 新文件行号，死链检测前优先查表。
- 超限策略: 软阈 warn 不阻断，硬阈 error 阻断 `pre-commit`，避免“修文档阻塞发版”。
- 回滚: 全量在分支 `docs-restructure/handbook` / `docs-restructure/product` / `docs-restructure/archive` 三批 PR，任一批可独立
  revert；`git log --follow` 保留历史。

### 5.2 测试与验证
- 自动化:
  - `tools/docs-lint.ps1` — 行数/行长/死链/ITERATION一致性。
  - 复用 `tools/check-doc-sync.ps1` / `tools/check_smoke_consistency.sh` 现有门禁，确保迭代链 89 环不受影响。
- 手工清单（每批 PR 合并前）:
  - [ ] 根 5 代理均可一跳抵达实体，无死链。
  - [ ] 每分片 `wc -l < 800` 且 `awk 'length>120'` 为空。
  - [ ] 双语 README 互链完整，`docs/00-index.md` 可导航至所有分片。
  - [ ] `ITERATION_COUNT.txt:1` 与末分片迭代号一致。
  - [ ] `git log --follow -- docs/handbook/polish-patterns/9.6.01-*.md` 可追溯原 `CONTRIBUTING.md:1` 历史。

### 5.3 风险与缓解
| 风险 | 缓解 |
|---|---|
| 批量替换误伤代码引用 | 仅改 `*.md` 与注释，`src/**/*.gd` 不触碰；`grep -r` 复核 |
| 分片后检索变难 | `docs/00-index.md` + 各 `index.md` + `redirect-map.json` 三重索引 |
| 迭代中途分片导致冲突 | 三批 PR 串行合并，每批合并后立即更新 `ITERATION_COUNT` 基线 |

## 6. 实施分批（供 writing-plans 细化）
- **Batch 1 — handbook**: 拆 §9.6 + `docs/handbook/**` + 根 CONTRIBUTING 代理 + `redirect-map.json`。
- **Batch 2 — product**: ROADMAP/CHANGELOG 分片 + README 精简 + 03-product 索引。
- **Batch 3 — archive**: REVIEW_LOG 归档分片 + 04-archive 索引 + `docs/00-index` 总导航 + `docs-lint.ps1` + pre-commit。

## 7. 不做之事（YAGNI）
- 不引入全量 CI `docs-guard.yml`（当前仅 pre-commit + 手动 lint，CI 后续按需）。
- 不重写文档内容语义，仅结构化与表格化超长行。
- 不改 `src/`、不改 `tools/_test_refcounted_runner.gd`、不改迭代工作流 §9.1。

## 8. 自检
- [x] 无 TBD/TODO 占位，阈值与路径均明确。
- [x] 架构 ↔ 组件 ↔ 数据流一致：分层、映射、分片粒度、校验均对齐 <800/<120。
- [x] 单设计可落地，无需二次分解（分批为实施节奏，非子项目）。
- [x] 无歧义：代理 vs 实体、分片粒度(20段/50轮/100轮)、校验分级均已定。

## 9. 待用户复审
> Spec 已写入 `docs/superpowers/specs/2026-08-20-docs-governance-layered-restructure-design.md` 并将提交。请复审后告知是否进入
> `writing-plans` 生成实施计划。
