# 文档总导航

> 当前迭代 315（含 315），4 层架构入口。

## 入口

- [入口详情](docs/01-entry/details.md) | [中文详情](docs/01-entry/details.zh-CN.md) |
  [当前状态](docs/01-entry/current-status.md) | [导航](docs/01-entry/details.md)
## 指南

- [贡献核心](docs/02-guides/contributing-core.md) |
  [迭代指南](docs/02-guides/iteration-guide.md) | [视觉指南](docs/02-guides/style-guide.md) |
  [手册](handbook/polish-patterns/index.md)
## 产品

- [Roadmap](docs/03-product/roadmap/index.md) |
  [Changelog](docs/03-product/changelog/index.md) |
  [资产登记](docs/03-product/asset-registry.md) | [研究](docs/03-product/research.md) |
  [灵感](docs/03-product/inspiration.md)
## 归档

- [Review 索引](docs/04-archive/review/index.md) |
  [001-100](docs/04-archive/review/review-001-100.md) |
  [101-200](docs/04-archive/review/review-101-200.md) |
  [201-300](docs/04-archive/review/review-201-300.md) |
  [301-400](docs/04-archive/review/review-301-400.md) ★当前含 315 |
  [401-500](docs/04-archive/review/review-401-500.md) |
  [501-600](docs/04-archive/review/review-501-600.md) |
  [601-700](docs/04-archive/review/review-601-700.md) |
  [701-800](docs/04-archive/review/review-701-800.md)

## 校验

- ITERATION 315 见 docs/03-product/roadmap/iter-301-400.md 与 docs/03-product/changelog/iter-301-350.md
> 与 docs/04-archive/review/review-301-400.md（含 315 锚点）
- lint: `pwsh -File tools/docs-lint.ps1 -Path docs`
- 死链校验：`re.findall(r"\(docs/[^)]+\.md\)", idx)` 需 0 死链
