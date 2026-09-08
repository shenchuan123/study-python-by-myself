# install.ps1 — drop-in install the two rebuilt bundles over a dsh install.
# Usage:  powershell -ExecutionPolicy Bypass -File scripts\install.ps1 [-DshRoot <path>]
# If -DshRoot is omitted it auto-detects the npm-global @deepseek-ai/dsh location.
# Original files are backed up as client.js.bak (restored by uninstall.ps1).

param(
  [string]$DshRoot = ''
)
$ErrorActionPreference = 'Stop'

# scripts\ -> package root
$pkgDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$root = $DshRoot.Trim()
if ($root -eq '') {
  $cand = Join-Path $env:APPDATA 'npm\node_modules\@deepseek-ai\dsh\node_modules\@deepseek-ai'
  if (Test-Path $cand) { $root = $cand }
}
if ($root -eq '' -or -not (Test-Path $root)) {
  throw "Could not auto-detect the dsh install. Pass -DshRoot <@deepseek-ai dir> explicitly."
}

$pairs = @(
  @{ src = (Join-Path $pkgDir 'bundles\ui-conversation\client.js'); dst = (Join-Path $root 'dsh-client-ui-conversation\lib\client.js') },
  @{ src = (Join-Path $pkgDir 'bundles\ui-sidebar\client.js');       dst = (Join-Path $root 'dsh-client-ui-sidebar\lib\client.js') }
)

foreach ($p in $pairs) {
  if (-not (Test-Path $p.src)) { throw "Missing bundle: $($p.src)" }
  if (-not (Test-Path $p.dst)) { throw "Target not found: $($p.dst). Is dsh installed there?" }
  $bak = "$($p.dst).bak"
  if (-not (Test-Path $bak)) { Copy-Item $p.dst $bak }
  Copy-Item $p.src $p.dst -Force
  Write-Host "installed -> $($p.dst)"
}

Write-Host ''
Write-Host 'Done. Restart the dsh web server and hard-refresh (Ctrl+F5) to see the font-size slider.'
Write-Host 'Original bundles were backed up next to each target as client.js.bak.'
