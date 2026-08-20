# Review 索引

> 已迁移至 docs/04-archive/review/，按 100 轮分片，查询接口：迭代区间表格。
> 当前迭代 315，见 review-301-400.md，含 315 锚点。
> ITERATION 315 同步校验：`ITERATION_COUNT.txt` 315 在 review-301-400.md 中可检索。
> 覆盖 1-800 区间，共 8 分片，每分片 ≤800 行且每行 ≤120（PowerShell Length）。
> 完整日志追溯：`git log --follow -- REVIEW_LOG.md`
> 与 `git log --follow -- REVIEW_LOG_ARCHIVE.md`（原 7246 行摘要为表格，逐行 wrap ≤120）。

## 分片导航

- [001-100](review-001-100.md) — 覆盖迭代 1-100（含 14 审查）
- [101-200](review-101-200.md) — 覆盖迭代 101-200（含 20 审查）
- [201-300](review-201-300.md) — 覆盖迭代 201-300（含 20 审查）
- [301-400](review-301-400.md) — 覆盖迭代 301-400（含 3 审查） ★当前
- [401-500](review-401-500.md) — 覆盖迭代 401-500（预留空区间）
- [501-600](review-501-600.md) — 覆盖迭代 501-600（预留空区间）
- [601-700](review-601-700.md) — 覆盖迭代 601-700（预留空区间）
- [701-800](review-701-800.md) — 覆盖迭代 701-800（预留空区间）

## 查询示例

- 定位审查 #315：`rg "#315" review-301-400.md`
- 定位迭代 065：`rg "#065" review-001-100.md`
- 区间查询：`rg "\| #3" review-301-400.md` 列出 300+ 审查
- 死链校验：`re.findall(r"\(docs/[^)]+\.md\)", idx)` 需 0 死链

## 迁移说明

- 原 REVIEW_LOG.md 4127 行 + REVIEW_LOG_ARCHIVE.md 3119 行共 7246 行，已按 100 轮分桶至 8 文件。
- 每文件 <800 行、每行 ≤120（PowerShell Length），符合 docs-lint.ps1 硬阈。
- 覆盖 1-800 区间，含当前 315，空区间（401-800）预留。
- 表格化范围：原超长行（峰值 11442）已按 `|` 切分为行级表格，`|` 分隔保持 Markdown 渲染。
- 摘要列：` | 迭代 | 审查 | 结论 | 链 | `，逐行 wrap ≤120 保留表格前缀。
- 旧锚点通过 docs/redirect-map.json 映射兼容（至少 8 条）。
- 历史保留：`git log --follow -- REVIEW_LOG.md` 可追踪迁移。

## 关联

- 总导航：[00-index.md](../../00-index.md)
- 根代理：[REVIEW_LOG.md](../../REVIEW_LOG.md)
- 归档代理：[REVIEW_LOG_ARCHIVE.md](../../REVIEW_LOG_ARCHIVE.md)
- 迭代计数：[ITERATION_COUNT.txt](../../ITERATION_COUNT.txt) 315
