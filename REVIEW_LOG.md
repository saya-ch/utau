# Review Log

> 已迁移至 docs/04-archive/review/，本文件为代理（≤150 行），保留近 5 轮摘要与分片链接。

> 当前迭代 315 见 docs/04-archive/review/review-301-400.md，含 315 锚点。

## 概览

- 目标：按迭代区间分片，单文件 <800 行、单行 ≤120。
- 原 REVIEW_LOG.md 4127 行 + ARCHIVE 3119 行共 7246 行，已按 100 区间切分 8 文件。
- 表头：`| 迭代 | 审查 | 结论 | 链 |`，每审查一行，结论按当轮审计。

## 近 5 轮摘要 (295-315)

| 迭代 | 审查 | 结论 | 链 |
|---|---|---|---|
| #295 | #295 2026-07-23 | 可继续迭代·61/61 | [295](docs/04-archive/review/review-201-300.md#295) |
| #300 | #300 2026-07-24 | 已归档 | [300](docs/04-archive/review/review-201-300.md#300) |
| #305 | #305 2026-07-25 | 可继续迭代·61/61 | [305](docs/04-archive/review/review-301-400.md#305) |
| #310 | #310 2026-07-25 | 可继续迭代·61/61 | [310](docs/04-archive/review/review-301-400.md#310) |
| #315 | #315 2026-07-25 | 可继续迭代·61/61 | [315](docs/04-archive/review/review-301-400.md#315) |

## 分片导航

- [001-100](docs/04-archive/review/review-001-100.md) — 覆盖迭代 1-100
- [101-200](docs/04-archive/review/review-101-200.md) — 覆盖迭代 101-200
- [201-300](docs/04-archive/review/review-201-300.md) — 覆盖迭代 201-300
- [301-400](docs/04-archive/review/review-301-400.md) — 覆盖迭代 301-400 ★当前
- [401-500](docs/04-archive/review/review-401-500.md) — 覆盖迭代 401-500
- [501-600](docs/04-archive/review/review-501-600.md) — 覆盖迭代 501-600
- [601-700](docs/04-archive/review/review-601-700.md) — 覆盖迭代 601-700
- [701-800](docs/04-archive/review/review-701-800.md) — 覆盖迭代 701-800

## 查询示例

- 定位审查：`rg "#315" docs/04-archive/review/review-301-400.md`
- 区间过滤：`rg "\| #3" docs/04-archive/review/review-301-400.md`

## 迁移说明

- 旧锚 `REVIEW_LOG.md#315` 等通过 docs/redirect-map.json 映射至新分片。
- 历史保留：`git log --follow -- REVIEW_LOG.md` 可追踪迁移。
- 生成方式：`python tools/migrate-docs.py --force` 幂等重建分片。
- 校验：`pwsh -File tools/docs-lint.ps1 -Path docs/04-archive` 应 exit 0。

## 关联

- 索引：[docs/04-archive/review/index.md](docs/04-archive/review/index.md)
- 总导航：[docs/00-index.md](docs/00-index.md)
- 迭代计数：[ITERATION_COUNT.txt](ITERATION_COUNT.txt)
