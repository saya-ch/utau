param([switch]$Force)
# tools/migrate-docs.ps1 — 幂等拆分 CONTRIBUTING §9.6 113 段（完整迁移，动态打包）
# 原始 CONTRIBUTING.md SHA: 1634137 (BASE) blob 087950e — 见 tools/migrate-docs.py 注释
# 实际 wrapping 与分片逻辑在 tools/migrate-docs.py 中实现，本脚本为 PowerShell 入口，确保持续可重放
# 用法: pwsh -File tools/migrate-docs.ps1 [-Force]
$ErrorActionPreference = "Stop"
$py = "python"
# 优先用 python，若不存在则试 python3
try { & $py --version 2>&1 | Out-Null } catch { $py = "python3" }

$argsList = @("tools/migrate-docs.py")
if ($Force) { $argsList += "--force" }

Write-Host "migrate-docs: invoking $py $($argsList -join ' ') — BASE 1634137, 113 segs, wrap 120, limit 500"
& $py @argsList
if ($LASTEXITCODE -ne 0) { throw "migrate-docs.py failed with $LASTEXITCODE" }

# 兼容旧占位逻辑：保留 core 与 handbook 幂等检查输出（供 review 追溯）
$src = "CONTRIBUTING.md"
$coreDst = "docs/02-guides/contributing-core.md"
$handbookDir = "docs/handbook/polish-patterns"
$redirect = "docs/redirect-map.json"
Write-Host "migrate-docs: core $coreDst exists? $(Test-Path $coreDst)"
Write-Host "migrate-docs: handbook shards $(@(Get-ChildItem -Path $handbookDir -Filter '9.6.*.md' -ErrorAction SilentlyContinue).Count) files"
Write-Host "migrate-docs: redirect $(if(Test-Path $redirect){ (Get-Content $redirect -Raw | ConvertFrom-Json).PSObject.Properties.Count } else {0}) mappings"
Write-Host "proxy CONTRIBUTING.md done (see git log --follow -- CONTRIBUTING.md for history, orig 1634137:087950e)"
