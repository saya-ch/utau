# Task 6 报告 — Hook 与总体验收

> 日期: 2026-08-20 | 分支: docs-restructure/layered | 基线 HEAD: 737fca1

## 交付清单

- **修改**: `tools/install_hooks.sh` — 追加 docs-lint 幂等逻辑，创建/更新 `.githooks/pre-commit`，含 `pwsh -File tools/docs-lint.ps1 -Path docs`，`chmod +x`，`git config core.hooksPath .githooks`
- **新增**: `.githooks/pre-commit` — 含 F002 与 docs-lint 双校验，幂等，已 `chmod +x`
- **修改**: `tools/docs-lint.ps1` — 新增参数 `[string[]]$Exclude`，支持 `-Exclude superpowers`，支持逗号分隔多 Path，保持 `MaxLines=800, MaxLen=120` 硬阈
- **修改**: `docs/steam_store_description_en.md` — 18 处超长行 wrap 至 ≤120，每行 ≤120，文件 152 行 <800
- **修改**: `docs/superpowers/plans/2026-08-20-docs-governance-layered-restructure.md` — 397→419 行，超长 20 处 wrap 至 ≤120
- **修改**: `docs/superpowers/specs/2026-08-20-docs-governance-layered-restructure-design.md` — 182→191 行，超长 9 处 wrap
- **修改**: `docs/00-index.md` — 修复 `[手册](handbook/...)` → `[手册](docs/handbook/...)`，修复 `[导航]` 指向 `docs/01-entry/navigation.md`，补空白，保持 43 行、死链 0、含 ITERATION 315
- **新增**: `docs/01-entry/navigation.md` — 35 行，补齐 01-entry 缺失导航，ITERATION 315 同步
- **修改**: `tools/test_docs_lint.py` — 追加 `test_full_docs_green` 与 `test_iteration_count_sync`，总数 10

## 验证结果

### 1. 全量 lint

```bash
pwsh -File tools/docs-lint.ps1 -Path docs
# 输出: ITERATION 315
# EXIT: 0
```

- 修复前: FAIL 47 处（steam 18 + plans 20 + specs 9）
- 修复后: PASS 0 行长>120，0 文件>800
- 额外验证: `pwsh -File tools/docs-lint.ps1 -Path docs -Exclude superpowers` 同样 PASS

### 2. Pytest 全量

```bash
python -m pytest tools/test_docs_lint.py -v
# 10 passed in 2.95s
# test_lint_detects_long_line PASSED
# test_lint_detects_too_many_lines PASSED
# test_handbook_sharding PASSED (56 shards, 113 段, <500, 围栏闭合)
# test_roadmap_no_long_lines PASSED (≥5 文件, 315 在 301-400)
# test_readme_slim PASSED
# test_changelog_sharded PASSED (≥13)
# test_review_sharded PASSED (8 文件)
# test_no_dead_links_in_index PASSED (21 个 docs/ 链接均 exists, 含 handbook)
# test_full_docs_green PASSED
# test_iteration_count_sync PASSED (315 ∈ iter-301-400.md)
```

- TDD: `test_full_docs_green` 修复前 FAIL（预期），修复后 PASS；`test_iteration_count_sync` 始终 PASS

### 3. 死链 0

```python
re.findall(r"\(docs/[^)]+\.md\)", idx) # 22 个，结果均 exists
# 含 (docs/handbook/polish-patterns/index.md) True
# 含 (docs/01-entry/navigation.md) True
```

### 4. ITERATION 一致性

- `ITERATION_COUNT.txt:1` = 315
- `docs/03-product/roadmap/iter-301-400.md` 含 "315"
- `docs/03-product/changelog/iter-301-350.md` 含 315
- `docs/04-archive/review/review-301-400.md` 含 315
- `docs/00-index.md` 校验段同步

### 5. Hook 幂等

- `tools/install_hooks.sh` 含 `docs-lint` 幂等块：`grep -q "docs-lint"` 判断
- `.githooks/pre-commit` 内容:

```sh
#!/bin/sh
# T265 F002 self-test commit hook (do not remove — see tools/pre_commit_f002_check.sh)
bash tools/pre_commit_f002_check.sh || exit 1
# docs-lint hook (幂等 — see tools/docs-lint.ps1)
pwsh -File tools/docs-lint.ps1 -Path docs
```

- `git config core.hooksPath` = `.githooks`
- 重复执行 `bash tools/install_hooks.sh` 或 python 幂等逻辑不产生重复行（docs-lint 计数恒为 3，F002 计数 1）

### 6. 可选 check-doc-sync

- `tools/check-doc-sync.ps1` 不存在（已确认 `Test-Path` 为 False），跳过；手工校验 ITERATION 已通过

## 提交

```bash
git add tools/install_hooks.sh .githooks/pre-commit docs/00-index.md \
  tools/docs-lint.ps1 docs/steam_store_description_en.md \
  tools/test_docs_lint.py docs/superpowers/plans/ \
  docs/superpowers/specs/ docs/01-entry/navigation.md task-6-report.md
git commit -m "chore(docs): install pre-commit lint hook and final verification"
# 实际提交: ef9e24b (2026-08-20 18:39 +0800)
```

- 新 HEAD: ef9e24b（基于 737fca1）
- 变更统计: 10 files changed, 420 insertions(+), 113 deletions(-) — 0 改动 src/.gd/.tscn

## 关注点/Concerns

- **superpowers 归属**: 已通过 wrap 修复使其满足 ≤120，若未来视为生成产物可考虑默认 `Exclude superpowers`，当前 lint 已同时支持 `-Exclude` 参数，调用方可显式排除
- **steam 表格**: Screenshot Slot Plan 6 行已缩略为 `Title screen + CN typography` 等短语，保持 ≤120；若需完整原文可考虑在 `docs/steam_page.md` 保留长表，当前已满足 lint
- **navigation.md 新增**: 为补齐 4 层语义而新增，内容 <800 且 ≤120，已加入 index 死链校验
- **未改动 src/**: 符合全局约束，不碰 .gd/.tscn 与 7 autoload
- **.githooks vs .git/hooks**: 已同时保留 F002 与 docs-lint 于 .githooks，core.hooksPath 指向 .githooks；若开发者仍依赖 .git/hooks，需手动同步或重跑 install_hooks.sh

## 状态

- **status**: PASS — 全量绿灯，10/10 pytest，lint exit 0，死链 0，ITERATION 一致，hook 幂等
- **hash**: 737fca1 → ef9e24b
- **测试摘要**: 10 passed, 0 failed (pytest 2.95s)
- **分支**: docs-restructure/layered
- **验证命令**: `pwsh -File tools/docs-lint.ps1 -Path docs` exit 0, `python -m pytest tools/test_docs_lint.py -v` 10/10
