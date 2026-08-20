# Style Guide

> 已迁移至 docs/02-guides/style-guide.md，本文件为代理（≤80 行）。

> 实体见 [docs/02-guides/style-guide.md](docs/02-guides/style-guide.md)，含完整 Style Guide 内容。
> 当前迭代 315，见 [changelog](../03-product/changelog/index.md)

## 概览

- 视觉宪法：色板、光照、形状、像素规格。
- 所有新素材必须继承。

## 迁移说明

- 原 STYLE_GUIDE.md 已按 ≤120 wrap 迁入 docs/02-guides/style-guide.md。
- 单文件 <800 行、单行 ≤120 符合 lint。
- 历史：`git log --follow -- STYLE_GUIDE.md` 可追溯。
- 生成：`python tools/migrate-docs.py --force` 幂等重建。

## 关联

- 实体：[docs/02-guides/style-guide.md](docs/02-guides/style-guide.md)
- 总导航：[docs/00-index.md](docs/00-index.md)
- 变更日志：[docs/03-product/changelog/index.md](docs/03-product/changelog/index.md)
