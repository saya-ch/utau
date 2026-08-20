# Asset Registry

> 已迁移至 docs/03-product/asset-registry.md，本文件为代理（≤80 行）。

> 实体见 [docs/03-product/asset-registry.md](docs/03-product/asset-registry.md)，含完整 Asset Registry 内容。
> 当前迭代 315，见 [changelog](../03-product/changelog/index.md)

## 概览

- 素材账本 77 条目，ID/类型/状态/路径。
- 新资产必须追加。

## 迁移说明

- 原 ASSET_REGISTRY.md 已按 ≤120 wrap 迁入 docs/03-product/asset-registry.md。
- 单文件 <800 行、单行 ≤120 符合 lint。
- 历史：`git log --follow -- ASSET_REGISTRY.md` 可追溯。
- 生成：`python tools/migrate-docs.py --force` 幂等重建。

## 关联

- 实体：[docs/03-product/asset-registry.md](docs/03-product/asset-registry.md)
- 总导航：[docs/00-index.md](docs/00-index.md)
- 变更日志：[docs/03-product/changelog/index.md](docs/03-product/changelog/index.md)
