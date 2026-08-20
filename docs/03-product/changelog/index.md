# Changelog 索引

> 已迁移至 docs/03-product/changelog/，按 50 轮分片，查询接口：迭代区间表格。
> 当前迭代 315，见 iter-301-350.md，含 ITERATION 315 锚点。
> ITERATION 315 同步校验：`ITERATION_COUNT.txt` 315 在 iter-301-350.md 中可检索。

## 分片导航

- [Iter 001-050](iter-001-050.md) — 覆盖迭代 1-50
- [Iter 051-100](iter-051-100.md) — 覆盖迭代 51-100
- [Iter 101-150](iter-101-150.md) — 覆盖迭代 101-150
- [Iter 151-200](iter-151-200.md) — 覆盖迭代 151-200
- [Iter 201-250](iter-201-250.md) — 覆盖迭代 201-250
- [Iter 251-300](iter-251-300.md) — 覆盖迭代 251-300
- [Iter 301-350](iter-301-350.md) — 覆盖迭代 301-350 ★当前
- [Iter 351-400](iter-351-400.md) — 覆盖迭代 351-400
- [Iter 401-450](iter-401-450.md) — 覆盖迭代 401-450
- [Iter 451-500](iter-451-500.md) — 覆盖迭代 451-500
- [Iter 501-550](iter-501-550.md) — 覆盖迭代 501-550
- [Iter 551-600](iter-551-600.md) — 覆盖迭代 551-600
- [Iter 601-650](iter-601-650.md) — 覆盖迭代 601-650

## 查询示例

- 定位迭代 #315：`rg "#315" iter-301-350.md`
- 定位任务 T371：`rg "T371" iter-301-350.md`
- 区间查询：`rg "\| #3" iter-301-350.md` 列出 300+ 迭代

## 迁移说明

- 原 CHANGELOG.md 609 行 + CHANGELOG_ARCHIVE.md 6040 行共 6649 行，已按 50 区间切分 13 文件。
- 每文件 <800 行、每行 ≤120（PowerShell Length），符合 docs-lint.ps1 硬阈。
- 覆盖 1-650 区间，含当前 315，空区间（351-650）预留。
- 表格化范围：原超长行已按 `|` 切分为行级表格，`|` 分隔保持 Markdown 渲染。
- 旧锚点通过 docs/redirect-map.json 映射兼容。
- 历史保留：`git log --follow -- CHANGELOG.md` 可追踪迁移。

## 关联

- 总导航：[00-index.md](../../00-index.md)
- 根代理：[CHANGELOG.md](../../CHANGELOG.md)
- 迭代计数：[ITERATION_COUNT.txt](../../ITERATION_COUNT.txt) 315
