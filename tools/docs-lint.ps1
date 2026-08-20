param([string]$Path="docs",[int]$MaxLines=800,[int]$MaxLen=120)
$err=0
Get-ChildItem -Recurse -Filter *.md -Path $Path -ErrorAction SilentlyContinue | ForEach-Object {
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
if(Test-Path "ITERATION_COUNT.txt"){
  $c=Get-Content ITERATION_COUNT.txt -Raw
  $msg="ITERATION $c"
  Write-Output $msg
}
exit $err
