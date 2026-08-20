# Roadmap 索引

> 已迁移至 docs/03-product/roadmap/，按 100 轮分片，查询接口：迭代区间表格。
> 当前迭代 315，见 iter-301-400.md，含 ITERATION 315 锚点。
> ITERATION 315 同步校验：`ITERATION_COUNT.txt` 315 在 iter-301-400.md 中可检索。

## 分片导航

- [Iter 001-100](iter-001-100.md) — 覆盖迭代 1-100
- [Iter 101-200](iter-101-200.md) — 覆盖迭代 101-200
- [Iter 201-300](iter-201-300.md) — 覆盖迭代 201-300
- [Iter 301-400](iter-301-400.md) — 覆盖迭代 301-400

## 查询示例

- 定位迭代 #315：`rg "#315" iter-301-400.md`
- 定位任务 T371：`rg "T371" iter-301-400.md`
- 区间查询：`rg "\| #3" iter-301-400.md` 列出 300+ 迭代

## 迁移说明

- 原 ROADMAP.md 1119 行，含 85 行 >2000 字符（峰值 21612），已按表格 `| 迭代 | 任务 | 类型 | 状态 |` 切分。
- 每文件 <800 行、每行 ≤120（PowerShell Length），符合 docs-lint.ps1 硬阈。
- 表格化范围：原 1-32 行超长压缩行已转为行级表格，`|` 分隔保持 Markdown 渲染。
- 旧锚点通过 docs/redirect-map.json 映射兼容。
- 历史保留：`git log --follow -- ROADMAP.md` 可追踪迁移（BASE b0de52d）。

## 关联

- 总导航：[00-index.md](../../00-index.md)
- 根代理：[ROADMAP.md](../../ROADMAP.md)
- 迭代计数：[ITERATION_COUNT.txt](../../ITERATION_COUNT.txt)
