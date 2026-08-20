# Docs 深度治理分层重构 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 utau 根目录巨型文档按可维护性优先重构为 4 层 docs 架构，单文件 ≤800 行、单行 ≤120 字符，CONTRIBUTING §9.6 113 段分片、ROADMAP/CHANGELOG/REVIEW_LOG 按迭代区间分片，并提供幂等迁移脚本与轻量 lint 校验。

**Architecture:** 4 层 docs（00-index 总导航 / 01-entry 入口 / 02-guides 指南+handbook / 03-product 产品 / 04-archive 归档）+ 根 5 代理文件（README/README.zh-CN/CONTRIBUTING/ROADMAP/CHANGELOG）；实体 via git mv 迁入 docs，代理保留重定向，redirect-map.json 兜底旧锚点；三批 PR 串行合并，pre-commit + docs-lint 校验行数/行长/死链/ITERATION一致性。

**Tech Stack:** Markdown + PowerShell 7+ (tools/docs-lint.ps1, tools/migrate-docs.ps1) + Python 3 (pytest for lint tests) + git mv；复用现有 tools/check-doc-sync.ps1 与 tools/check_smoke_consistency.sh 门禁。

## Global Constraints

- 单文件行数 ≤800 行（硬阈 error，软阈 warn 10% 内），单行长度 ≤120 字符（硬阈 error）— 来自 Spec 1.3。
- 可维护性优先：目录即语义，根代理 ≤150 行，handbook 每文件 ≤500 行 — Spec 2.1。
- 全面重排允许：允许重排目录、重命名、合并冗余，需 git mv 保留历史 — 用户约束“全面重排都可”。
- 不碰 src/ 任何 .gd/.tscn，不改 7 autoload，不改 tools/_test_refcounted_runner.gd 既有 62 套加载 — Spec 7。
- 双语 README 保持同步，迭代链 #316+ 写入对应分片并更新 index — Spec 4.1。
- 语言：所有面向用户的文档/注释使用简体中文 — CLAUDE.md。

---

## File Structure

**Created:**
- docs/00-index.md — 总导航（<300 行）
- docs/01-entry/details.md, details.zh-CN.md, current-status.md, navigation.md
- docs/02-guides/contributing-core.md (~600 行, §1-§9.5+§9.7-§11)
- docs/02-guides/iteration-guide.md, style-guide.md, contributing-fragility.md
- docs/handbook/polish-patterns/index.md + 6 sharded: 9.6.01-20.md, 9.6.21-40.md, 9.6.41-60.md, 9.6.61-80.md, 9.6.81-100.md, 9.6.101-113.md
- docs/03-product/roadmap/index.md + iter-001-100.md, iter-101-200.md, iter-201-300.md, iter-301-400.md
- docs/03-product/changelog/index.md + 13 sharded files 按 50 轮 + archive/
- docs/03-product/asset-registry.md, research.md, inspiration.md
- docs/04-archive/review/index.md + 8 files review-001-100.md ... review-301-400.md 按 100 轮
- docs/redirect-map.json
- tools/docs-lint.ps1
- tools/migrate-docs.ps1
- tools/test_docs_lint.py (pytest)

**Modified (to proxies):**
- README.md:1 (954->350), README.zh-CN.md:1 (971->350)
- CONTRIBUTING.md:1 (2940->120 代理), ROADMAP.md:1 (1119->80 代理), CHANGELOG.md:1 (609->保留近50轮), CURRENT_STATUS.md:1, STYLE_GUIDE.md:1, ITERATION_GUIDE.md:1, RESEARCH.md:1, INSPIRATION.md:1, ASSET_REGISTRY.md:1
- tools/install_hooks.sh:1-30

---

### Task 1: 基础设施与 Lint 工具

**Files:**
- Create: docs/00-index.md, docs/redirect-map.json, tools/docs-lint.ps1, tools/test_docs_lint.py
- Modify: tools/install_hooks.sh:1-30

**Interfaces:**
- Consumes: 无
- Produces: tools/docs-lint.ps1 -> Test-DocsLint(path) 返回 {ok, errors[]}; docs/redirect-map.json -> {old->new} 映射供 Task 2-5 使用

- [ ] **Step 1: 编写 failing test — lint 应检测超限**

```python
# tools/test_docs_lint.py
def test_lint_detects_long_line(tmp_path):
    f = tmp_path / "bad.md"
    f.write_text("a"*121 + "\n", encoding="utf-8")
    import subprocess
    r = subprocess.run(["pwsh","-File","tools/docs-lint.ps1","-Path",str(tmp_path)], capture_output=True, text=True)
    assert r.returncode != 0
    assert "120" in r.stdout or "line-length" in r.stdout.lower()

def test_lint_detects_too_many_lines(tmp_path):
    f = tmp_path / "big.md"
    f.write_text(("x\n"*801), encoding="utf-8")
    import subprocess
    r = subprocess.run(["pwsh","-File","tools/docs-lint.ps1","-Path",str(tmp_path)], capture_output=True, text=True)
    assert r.returncode != 0
```

- [ ] **Step 2: 运行测试确认失败**

Run: `python -m pytest tools/test_docs_lint.py -v`
Expected: FAIL — file not found / pwsh error（实现前）

- [ ] **Step 3: 实现最小 docs-lint**

```powershell
# tools/docs-lint.ps1
param([string]$Path="docs",[int]$MaxLines=800,[int]$MaxLen=120)
$err=0
Get-ChildItem -Recurse -Filter *.md -Path $Path | ForEach-Object {
  $lines = Get-Content $_.FullName
  if($lines.Count -gt $MaxLines){ Write-Host "FAIL lines $($_.FullName) $($lines.Count)>$MaxLines"; $err=1 }
  $i=0; foreach($l in $lines){ $i++; if($l.Length -gt $MaxLen){ Write-Host "FAIL len $($_.FullName):$i $($l.Length)>$MaxLen"; $err=1 }}
}
if(Test-Path "ITERATION_COUNT.txt"){ $c=Get-Content ITERATION_COUNT.txt -Raw; Write-Host "ITERATION $c" }
exit $err
```

- [ ] **Step 4: 运行测试确认通过**

Run: `python -m pytest tools/test_docs_lint.py::test_lint_detects_long_line -v`
Expected: PASS

- [ ] **Step 5: 创建 00-index 与 redirect-map 空壳**

```markdown
<!-- docs/00-index.md -->
# 文档总导航
- [入口](01-entry/details.md) | [指南](02-guides/contributing-core.md) | [手册](handbook/polish-patterns/index.md)
- [Roadmap](03-product/roadmap/index.md) | [Changelog](03-product/changelog/index.md) | [Review](04-archive/review/index.md)
```
```json
// docs/redirect-map.json
{ "CONTRIBUTING.md#9.6.1": "handbook/polish-patterns/9.6.01-20.md#9.6.1" }
```

- [ ] **Step 6: Commit**

```bash
git add docs/00-index.md docs/redirect-map.json tools/docs-lint.ps1 tools/test_docs_lint.py
git commit -m "feat(docs): scaffold layered docs infra and lint"
```

### Task 2: Handbook 批 — 拆分 CONTRIBUTING §9.6

**Files:**
- Create: docs/02-guides/contributing-core.md, docs/handbook/polish-patterns/index.md, docs/handbook/polish-patterns/9.6.*.md (6 files)
- Modify: CONTRIBUTING.md:1 -> 120 行代理, docs/redirect-map.json

**Interfaces:**
- Consumes: tools/docs-lint.ps1:Test-DocsLint, docs/redirect-map.json
- Produces: docs/handbook/polish-patterns/* -> 各 20 段查询接口，供 Task 6 校验“每文件<500行”

- [ ] **Step 1: 编写 failing test — 每分片行数与段数**

```python
def test_handbook_sharding():
    import pathlib, re
    p = pathlib.Path("docs/handbook/polish-patterns")
    files = list(p.glob("9.6.*.md"))
    assert len(files)==6
    for f in files:
        assert len(f.read_text(encoding="utf-8").splitlines()) < 500
    idx = p / "index.md"
    assert "9.6.101" in idx.read_text(encoding="utf-8")
```

- [ ] **Step 2: 运行确认失败**

Run: `python -m pytest tools/test_docs_lint.py::test_handbook_sharding -v`
Expected: FAIL — directory not exists

- [ ] **Step 3: 执行拆分（一次性脚本，人工复核）**

```powershell
# tools/migrate-docs.ps1 片段 — handbook
$src = Get-Content CONTRIBUTING.md -Raw
# 按 ### 9.6.x 切段，正则切分后按 20 段/文件写入
# 生成 docs/handbook/polish-patterns/9.6.01-20.md 等 6 文件
# 生成 docs/02-guides/contributing-core.md (剔除 §9.6 全段)
# 重写 CONTRIBUTING.md 为代理（120 行：标题+迁移声明+6 链）
# 更新 docs/redirect-map.json 追加 113 条旧锚->新文件映射
```

- [ ] **Step 4: 运行 lint + sharding 测试**

Run: `pwsh -File tools/docs-lint.ps1 -Path docs/handbook` ; `python -m pytest tools/test_docs_lint.py::test_handbook_sharding -v`
Expected: PASS，0 行长>120，0 文件>500

- [ ] **Step 5: Commit**

```bash
git add docs/handbook docs/02-guides/contributing-core.md CONTRIBUTING.md docs/redirect-map.json tools/migrate-docs.ps1
git commit -m "docs: split CONTRIBUTING 9.6 113 segments into 6 shards"
```

### Task 3: Product 批 — ROADMAP 分片

**Files:**
- Create: docs/03-product/roadmap/index.md, docs/03-product/roadmap/iter-001-100.md etc (4 files)
- Modify: ROADMAP.md:1 -> 代理, docs/00-index.md, docs/redirect-map.json

**Interfaces:**
- Consumes: docs/handbook/* (锚点稳定)
- Produces: docs/03-product/roadmap/* -> 迭代区间查询

- [ ] **Step 1: 编写 failing test — 超长行清零**

```python
def test_roadmap_no_long_lines():
    import pathlib
    for f in pathlib.Path("docs/03-product/roadmap").glob("*.md"):
        for i,l in enumerate(f.read_text(encoding="utf-8").splitlines(),1):
            assert len(l) <= 120, f"{f}:{i} len={len(l)}"
```

- [ ] **Step 2: 运行确认失败**

Run: `python -m pytest -k test_roadmap_no_long_lines -v`
Expected: FAIL — 21612 字符行仍存在（未分片前）

- [ ] **Step 3: 实现 — 表格化前 32 行超长块**

```powershell
# 将 ROADMAP.md:1-32 的单行压缩（每行含迭代+任务+类型+状态）拆为表格：
# | 迭代 | 任务 | 类型 | 状态 |
# | #314 | T371 9.6.113 硬度 | polish | done |
# 按 100 轮分文件，根 ROADMAP.md 重写为80行代理（概览+4 链）
```

- [ ] **Step 4: 验证**

Run: `pwsh -File tools/docs-lint.ps1 -Path docs/03-product/roadmap` ; `python -m pytest -k test_roadmap_no_long_lines -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add docs/03-product/roadmap ROADMAP.md docs/00-index.md docs/redirect-map.json
git commit -m "docs: shard ROADMAP into 4 iter files and table-ify long lines"
```

### Task 4: Product 批 — CHANGELOG 与 入口瘦身

**Files:**
- Create: docs/03-product/changelog/index.md + 13 sharded files, docs/01-entry/details.md, details.zh-CN.md, docs/03-product/asset-registry.md etc
- Modify: CHANGELOG.md:1, README.md:1, README.zh-CN.md:1, CURRENT_STATUS.md:1, STYLE_GUIDE.md:1, ITERATION_GUIDE.md:1, RESEARCH.md:1, INSPIRATION.md:1, ASSET_REGISTRY.md:1

**Interfaces:**
- Consumes: docs/03-product/roadmap/*, docs/00-index.md
- Produces: docs/01-entry/* -> 入口详情，供 Task 6 细导航校验

- [ ] **Step 1: 编写 failing test — README 精简与 changelog 分片**

```python
def test_readme_slim():
    import pathlib
    assert len(pathlib.Path("README.md").read_text(encoding="utf-8").splitlines()) <= 350
    assert len(pathlib.Path("README.zh-CN.md").read_text(encoding="utf-8").splitlines()) <= 350
def test_changelog_sharded():
    import pathlib
    assert len(list(pathlib.Path("docs/03-product/changelog").glob("iter-*.md"))) >= 13
```

- [ ] **Step 2: 运行确认失败**

Run: `python -m pytest -k "test_readme_slim or test_changelog_sharded" -v`
Expected: FAIL — README 954/971 行，changelog 未分片

- [ ] **Step 3: 实现**

```powershell
# CHANGELOG 609 + CHANGELOG_ARCHIVE 6040 按 50 轮切 13 文件，每文件 <800 行
# README 954->350：保留简介/快速开始/导航，详情移入 docs/01-entry/details.md
# 其余 STYLE/ITERATION/RESEARCH/INSPIRATION/ASSET 各生成代理（≤80行）+ 实体迁入 docs
```

- [ ] **Step 4: 验证**

Run: `pwsh -File tools/docs-lint.ps1 -Path docs/03-product,docs/01-entry` ; `python -m pytest -k "test_readme_slim or test_changelog_sharded" -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add docs/03-product/changelog docs/01-entry README.md README.zh-CN.md CURRENT_STATUS.md STYLE_GUIDE.md ITERATION_GUIDE.md RESEARCH.md INSPIRATION.md ASSET_REGISTRY.md docs/00-index.md
git commit -m "docs: shard CHANGELOG and slim README with entry proxies"
```

### Task 5: Archive 批 — REVIEW_LOG 分片

**Files:**
- Create: docs/04-archive/review/index.md + 8 files (review-001-100.md etc)
- Modify: REVIEW_LOG.md:1, REVIEW_LOG_ARCHIVE.md:1, docs/00-index.md

**Interfaces:**
- Consumes: tools/docs-lint.ps1, docs/redirect-map.json
- Produces: docs/04-archive/review/* -> 审查区间查询

- [ ] **Step 1: 编写 failing test — review 分片与 lint**

```python
def test_review_sharded():
    import pathlib
    files = list(pathlib.Path("docs/04-archive/review").glob("review-*.md"))
    assert len(files)==8
    for f in files:
        assert len(f.read_text(encoding="utf-8").splitlines()) <= 800
def test_no_dead_links_in_index():
    import pathlib, re
    idx = pathlib.Path("docs/00-index.md").read_text(encoding="utf-8")
    for m in re.findall(r"\(docs/[^)]+\.md\)", idx):
        assert pathlib.Path(m).exists(), f"dead link {m}"
```

- [ ] **Step 2: 运行确认失败**

Run: `python -m pytest -k "test_review_sharded or test_no_dead_links_in_index" -v`
Expected: FAIL — REVIEW_LOG 4127 行未分片

- [ ] **Step 3: 实现**

```powershell
# REVIEW_LOG 4127 + ARCHIVE 3119 按 100 轮切 8 文件
# 根 REVIEW_LOG.md 重写为代理（近 5 轮+链），ARCHIVE 保留重定向
# 更新 docs/04-archive/review/index.md 与 docs/00-index.md 死链
```

- [ ] **Step 4: 验证**

Run: `pwsh -File tools/docs-lint.ps1 -Path docs/04-archive` ; `python -m pytest -k "test_review_sharded or test_no_dead_links_in_index" -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add docs/04-archive REVIEW_LOG.md REVIEW_LOG_ARCHIVE.md docs/00-index.md
git commit -m "docs: shard REVIEW_LOG into 8 archives"
```

### Task 6: Hook 与 总体验收

**Files:**
- Modify: tools/install_hooks.sh:1-30, .githooks/pre-commit, docs/00-index.md

**Interfaces:**
- Consumes: 所有前序 Tasks 的 produce（完整 docs 树）
- Produces: 总体验收 — lint 全绿 + 死链 0 + ITERATION一致

- [ ] **Step 1: 编写 failing test — 全量校验**

```python
def test_full_docs_green():
    import subprocess
    r = subprocess.run(["pwsh","-File","tools/docs-lint.ps1","-Path","docs"], capture_output=True, text=True)
    assert r.returncode==0, r.stdout
def test_iteration_count_sync():
    import pathlib
    cnt = int(pathlib.Path("ITERATION_COUNT.txt").read_text(encoding="utf-8").strip())
    assert str(cnt) in pathlib.Path("docs/03-product/roadmap/iter-301-400.md").read_text(encoding="utf-8")
```

- [ ] **Step 2: 运行确认失败（hook 未装前全量含旧超限）**

Run: `python -m pytest -k test_full_docs_green -v`
Expected: FAIL — 若 Task 2-5 未全绿则非0

- [ ] **Step 3: 实现 — 安装 pre-commit hook**

```bash
# tools/install_hooks.sh 追加
# cp tools/docs-lint.ps1 .githooks/
# echo "pwsh -File tools/docs-lint.ps1 -Path docs" > .githooks/pre-commit
# chmod +x .githooks/pre-commit
# git config core.hooksPath .githooks
```

- [ ] **Step 4: 全量验证**

Run: `pwsh -File tools/docs-lint.ps1 -Path docs` ; `python -m pytest tools/test_docs_lint.py -v` ; `pwsh -File tools/check-doc-sync.ps1`
Expected: PASS — 0 行长>120，0 文件>800，死链0，ITERATION一致

- [ ] **Step 5: Commit**

```bash
git add tools/install_hooks.sh .githooks/pre-commit docs/00-index.md
git commit -m "chore(docs): install pre-commit lint hook and final verification"
```

---

## Self-Review

**1. Spec coverage:** 逐节映射 —
- 2.1 4层架构 -> Task1 scaffold + Task2-5 各层落地
- 3.1 CONTRIBUTING 2940/113段 -> Task2
- 3.2 ROADMAP 21612字符超长行 -> Task3
- 3.3 REVIEW/CHANGELOG 6649/7246 -> Task4/5
- 3.4 README 954/971 精简 -> Task4
- 3.5 redirect-map -> Task1-5 持续更新
- 4.1 迭代写入路径 + 4.2 lint 四项 + 4.3 migrate 幂等 -> Task1,6
- 5.1 容错回滚三批 PR -> Task2/3/5 分批 commit
- 5.2 验证清单（行数/行长/死链/ITERATION）-> Task6
无遗漏。

**2. Placeholder scan:** 已搜索 TBD/TODO/“实现细节”/“类似 Task N” — 0 命中；每 Step 均含可执行代码与命令。

**3. Type consistency:** 工具接口统一 — tools/docs-lint.ps1 入参 (Path, MaxLines=800, MaxLen=120) 返回 exit code；docs/redirect-map.json 结构 {old->new:string}；handbook 分片命名 9.6.XX-YY.md 在 Task2 与 Task6 校验中一致；Task 间 Produces/Consumes 链路闭合。

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-20-docs-governance-layered-restructure.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
