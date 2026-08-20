# 贡献指南

> 已迁移至 docs/02-guides/contributing-core.md 与 docs/handbook/polish-patterns/
> 本文件为代理与导航，旧内容已按 §9.6 113 段完整迁移至 55 个分片（动态打包，约 2-4 段/文件，完整保留原始内容），历史可追溯。
> 详细贡献流程请见核心指南与手册分片。
> 历史追溯：`git log --follow -- CONTRIBUTING.md`（原始 1634137:087950e）

## 快速导航

- [核心指南](docs/02-guides/contributing-core.md) — §1-§9.5 与 §9.7-§11
- [总索引](docs/00-index.md) — 全文档导航
- [Handbook 索引](docs/handbook/polish-patterns/index.md) — §9.6 113 段 55 分片导航（含 9.6.101 锚点）

### Handbook 分片（§9.6 113 段，55 文件，动态打包）

- 覆盖 9.6.1–9.6.113，共 55 分片，约 2-4 段/文件，每文件 <500 行且每行 ≤120
- 完整列表见 [index.md](docs/handbook/polish-patterns/index.md)
- 示例：[9.6.01-08](docs/handbook/polish-patterns/9.6.01-08.md) — 8 段
- 示例：[9.6.111-113](docs/handbook/polish-patterns/9.6.111-113.md) — 3 段

## 原章节映射

- §1 仓库结构 → [contributing-core.md#1](docs/02-guides/contributing-core.md)
- §2 首次启动 → [contributing-core.md#2](docs/02-guides/contributing-core.md)
- §3 质量自检 → [contributing-core.md#3](docs/02-guides/contributing-core.md)
- §4 提交格式 → [contributing-core.md#4](docs/02-guides/contributing-core.md)
- §5 迭代节奏 → [contributing-core.md#5](docs/02-guides/contributing-core.md)
- §6 美术登记 → [contributing-core.md#6](docs/02-guides/contributing-core.md)
- §7 文档同步 → [contributing-core.md#7](docs/02-guides/contributing-core.md)
- §8 故障排查 → [contributing-core.md#8](docs/02-guides/contributing-core.md)
- §9.1-§9.5 → [contributing-core.md#9.1](docs/02-guides/contributing-core.md)
- §9.6.* → handbook/polish-patterns/ 6 分片
- §10 联系方式 → [contributing-core.md#10](docs/02-guides/contributing-core.md)
- §11 Hook → [contributing-core.md#11](docs/02-guides/contributing-core.md)

## 迁移说明

- 旧 CONTRIBUTING.md 共 2940 行（原始 1634137:087950e），113 段 §9.6 已按动态打包拆分至 55 分片（2-4 段/文件，完整保留，wrapping 后 19321 行）
- 单文件 ≤800 行、单行 ≤120 字符（lint 硬阈，Markdown 感知换行：表格 `|`/引用 `>` 前缀保留，围栏行不折，围栏块内按空格折行）
- handbook 每文件 <500 行（实测最大 496 行，可维护性优先）
- 旧锚点通过 docs/redirect-map.json 113 条映射兼容（CONTRIBUTING.md#9.6.N → handbook/polish-patterns/9.6.XX-YY.md#9.6.N）
- 历史保留：`git log --follow -- CONTRIBUTING.md` 可追踪迁移（原始 blob 087950e at 1634137），migrate 脚本见 tools/migrate-docs.py

## 使用方式

- 新贡献者：先读核心指南，再按需查 handbook 分片
- 查询示例：`rg "9.6.42" docs/handbook/polish-patterns/`
- 迭代链 #316+ 写入对应分片并更新 index

---

> 语言：简体中文 | 目录即语义 | 根代理 ≤150 行

