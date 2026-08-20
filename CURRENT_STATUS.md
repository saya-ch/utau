# Current Status

> 已迁移至 docs/01-entry/current-status.md，本文件为代理（≤80 行）。

> 实体见 [docs/01-entry/current-status.md](docs/01-entry/current-status.md)，含完整 Current Status 内容。
> 当前迭代 315，见 [changelog](../03-product/changelog/index.md)

## 概览

- 权威当前状态与已知缺口，见实体。
- 现代门禁 11/11 绿，实拍 6/6 绿。

## 迁移说明

- 原 CURRENT_STATUS.md 已按 ≤120 wrap 迁入 docs/01-entry/current-status.md。
- 单文件 <800 行、单行 ≤120 符合 lint。
- 历史：`git log --follow -- CURRENT_STATUS.md` 可追溯。
- 生成：`python tools/migrate-docs.py --force` 幂等重建。

## 关联

- 实体：[docs/01-entry/current-status.md](docs/01-entry/current-status.md)
- 总导航：[docs/00-index.md](docs/00-index.md)
- 变更日志：[docs/03-product/changelog/index.md](docs/03-product/changelog/index.md)
