param([switch]$Force)
# tools/migrate-docs.ps1 — 幂等拆分 CONTRIBUTING §9.6 113 段 + ROADMAP 按 100 轮分片 + CHANGELOG 按 50 轮分片 + 入口瘦身
# 原始 CONTRIBUTING.md SHA: 1634137 (BASE) blob 087950e；ROADMAP BASE b0de52d — 见 tools/migrate-docs.py 注释
# 实际 wrapping 与分片逻辑在 tools/migrate-docs.py 中实现，本脚本为 PowerShell 入口，确保持续可重放
# 用法: pwsh -File tools/migrate-docs.ps1 [-Force]
# 幂等：重复运行不覆写已合规分片，--Force 强制重建
# 新增：_migrate_changelog (13 shards 50/桶) + _migrate_entry (README slim 350 + details) + _migrate_proxies (6 files) + 00-index/redirect
$ErrorActionPreference = "Stop"
$py = "python"
# 优先用 python，若不存在则试 python3
try { & $py --version 2>&1 | Out-Null } catch { $py = "python3" }

$argsList = @("tools/migrate-docs.py")
if ($Force) { $argsList += "--force" }

Write-Host "migrate-docs: invoking $py $($argsList -join ' ') — BASE 1634137, 113 segs, wrap 120, limit 500 + review 8 shards"
& $py @argsList
if ($LASTEXITCODE -ne 0) { throw "migrate-docs.py failed with $LASTEXITCODE" }

# 兼容旧占位逻辑：保留 core 与 handbook 幂等检查输出（供 review 追溯）
$src = "CONTRIBUTING.md"
$coreDst = "docs/02-guides/contributing-core.md"
$handbookDir = "docs/handbook/polish-patterns"
$redirect = "docs/redirect-map.json"
$roadmapDir = "docs/03-product/roadmap"
$changelogDir = "docs/03-product/changelog"
$entryDir = "docs/01-entry"
$reviewDir = "docs/04-archive/review"
Write-Host "migrate-docs: core $coreDst exists? $(Test-Path $coreDst)"
Write-Host "migrate-docs: handbook shards $(@(Get-ChildItem -Path $handbookDir -Filter '9.6.*.md' -ErrorAction SilentlyContinue).Count) files"
Write-Host "migrate-docs: roadmap shards $(@(Get-ChildItem -Path $roadmapDir -Filter 'iter-*.md' -ErrorAction SilentlyContinue).Count) files"
Write-Host "migrate-docs: changelog shards $(@(Get-ChildItem -Path $changelogDir -Filter 'iter-*.md' -ErrorAction SilentlyContinue).Count) files (expect 13)"
Write-Host "migrate-docs: review shards $(@(Get-ChildItem -Path $reviewDir -Filter 'review-*.md' -ErrorAction SilentlyContinue).Count) files (expect 8)"
Write-Host "migrate-docs: entry details $(Test-Path "$entryDir/details.md") / $(Test-Path "$entryDir/details.zh-CN.md")"
Write-Host "migrate-docs: redirect $(if(Test-Path $redirect){ (Get-Content $redirect -Raw | ConvertFrom-Json).PSObject.Properties.Count } else {0}) mappings"
Write-Host "proxy CONTRIBUTING.md done (see git log --follow -- CONTRIBUTING.md for history, orig 1634137:087950e)"
Write-Host "proxy ROADMAP.md done (see git log --follow -- ROADMAP.md for history, orig b0de52d)"
Write-Host "proxy CHANGELOG.md done (see git log --follow -- CHANGELOG.md for history, recent 50)"
Write-Host "proxy REVIEW_LOG.md done (see git log --follow -- REVIEW_LOG.md for history, 7246 -> 8 shards)"
Write-Host "proxy README slim done (EN $(if(Test-Path 'README.md'){(Get-Content 'README.md').Count} else {0}) lines, CN $(if(Test-Path 'README.zh-CN.md'){(Get-Content 'README.zh-CN.md').Count} else {0}) lines, expect ≤350)"
Write-Host "roadmap index exists? $(Test-Path "$roadmapDir/index.md")"
Write-Host "changelog index exists? $(Test-Path "$changelogDir/index.md")"
Write-Host "review index exists? $(Test-Path "$reviewDir/index.md")"
Write-Host "00-index exists? $(Test-Path "docs/00-index.md")"
