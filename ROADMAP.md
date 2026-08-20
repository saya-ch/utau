# Roadmap

> 已迁移至 docs/03-product/roadmap/，本文件为代理（≤80 行），保留概览与分片链接。

> 当前迭代 315 见 iter-301-400.md，含 ITERATION 315 锚点。

## 概览

- 目标：按迭代区间分片，单文件 <800 行、单行 ≤120。
- 原 ROADMAP.md 1119 行，含 85 行 >2000 字符（峰值 21612），已表格化为区间表。
- 表头：`| 迭代 | 任务 | 类型 | 状态 |`，每迭代一行，状态按 ITERATION 315 划分。

## 分片导航

- [Iter 001-100](docs/03-product/roadmap/iter-001-100.md) — 覆盖迭代 1-100
- [Iter 101-200](docs/03-product/roadmap/iter-101-200.md) — 覆盖迭代 101-200
- [Iter 201-300](docs/03-product/roadmap/iter-201-300.md) — 覆盖迭代 201-300
- [Iter 301-400](docs/03-product/roadmap/iter-301-400.md) — 覆盖迭代 301-400（含当前 315）

## 当前迭代

- ITERATION 315：`T371 9.6.113 硬度` polish done（详见 iter-301-400.md）
- 下一迭代 316：doing，见同一文件
- 同步校验：`ITERATION_COUNT.txt` 315 与 iter-301-400.md 中 `315` 一致

## 查询示例

- 定位迭代：`rg "#315" docs/03-product/roadmap/iter-301-400.md`
- 定位任务：`rg "T371" docs/03-product/roadmap/iter-301-400.md`
- 区间过滤：`rg "\| #3" docs/03-product/roadmap/iter-301-400.md`

## 迁移说明

- 旧锚 `ROADMAP.md#iter-314` 等通过 docs/redirect-map.json 映射至新分片。
- 历史保留：`git log --follow -- ROADMAP.md` 可追踪迁移（BASE b0de52d）。
- 生成方式：`python tools/migrate-docs.py --force` 幂等重建分片。
- 校验：`pwsh -File tools/docs-lint.ps1 -Path docs/03-product/roadmap` 应 exit 0。

## 关联

- 索引：[docs/03-product/roadmap/index.md](docs/03-product/roadmap/index.md)
- 总导航：[docs/00-index.md](docs/00-index.md)
- 迭代计数：[ITERATION_COUNT.txt](ITERATION_COUNT.txt)
