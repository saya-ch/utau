param(
  [string[]]$Path=@("docs"),
  [int]$MaxLines=800,
  [int]$MaxLen=120,
  [string[]]$Exclude=@()
)
$err=0
# 支持逗号分隔的 Path 写法：docs/03-product,docs/01-entry
$allPaths = @()
foreach($p in $Path){
  $allPaths += $p -split ","
}
# 若 Exclude 未显式传参但需默认排除 superpowers（生成产物），可在此加入
# 默认不强制排除，保持全量校验能力；调用方可显式 -Exclude superpowers
foreach($base in $allPaths){
  $base = $base.Trim()
  if(-not $base){ continue }
  Get-ChildItem -Recurse -Filter *.md -Path $base -ErrorAction SilentlyContinue |
    Where-Object {
      $skip=$false
      foreach($ex in $Exclude){
        if($ex -and $_.FullName -like "*$ex*"){ $skip=$true; break }
        # 也支持相对路径匹配
        if($ex -and $_.FullName -like "*$($ex.Replace('/','\'))*"){ $skip=$true; break }
      }
      -not $skip
    } | ForEach-Object {
      $lines = @(Get-Content $_.FullName)
      if($lines.Count -gt $MaxLines){
        $msg="FAIL lines $($_.FullName) $($lines.Count)>$MaxLines line-length $MaxLen"
        Write-Output $msg
        $err=1
      }
      $i=0
      foreach($l in $lines){
        $i++
        if($l.Length -gt $MaxLen){
          $msg="FAIL len $($_.FullName):$i $($l.Length)>$MaxLen line-length"
          Write-Output $msg
          $err=1
        }
      }
    }
}
if(Test-Path "ITERATION_COUNT.txt"){
  $c=Get-Content ITERATION_COUNT.txt -Raw
  $msg="ITERATION $c"
  Write-Output $msg
}
exit $err
