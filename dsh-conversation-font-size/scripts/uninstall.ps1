# uninstall.ps1 — restore the original bundles that install.ps1 backed up.
# Usage:  powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1 [-DshRoot <path>]

param(
  [string]$DshRoot = ''
)
$ErrorActionPreference = 'Stop'

$root = $DshRoot.Trim()
if ($root -eq '') {
  $cand = Join-Path $env:APPDATA 'npm\node_modules\@deepseek-ai\dsh\node_modules\@deepseek-ai'
  if (Test-Path $cand) { $root = $cand }
}
if ($root -eq '' -or -not (Test-Path $root)) {
  throw "Could not auto-detect the dsh install. Pass -DshRoot <@deepseek-ai dir> explicitly."
}

$names = @('dsh-client-ui-conversation', 'dsh-client-ui-sidebar')
foreach ($n in $names) {
  $dst = Join-Path $root "$n\lib\client.js"
  $bak = "$dst.bak"
  if (Test-Path $bak) {
    Copy-Item $bak $dst -Force
    Remove-Item $bak -Force
    Write-Host "restored -> $dst"
  } elseif (Test-Path $dst) {
    Write-Host "no backup present for $n; nothing to restore."
  } else {
    Write-Host "target absent: $dst"
  }
}

Write-Host ''
Write-Host 'Done. Restart dsh web and hard-refresh (Ctrl+F5) to return to the original UI.'
