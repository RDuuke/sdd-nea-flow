param(
  [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$targetPath = Resolve-Path $Target

$sourceOpencode = Join-Path $repoRoot ".opencode"
$sourceOpenSpec = Join-Path $repoRoot "openspec"

if (-not (Test-Path $sourceOpencode)) {
  throw "Missing .opencode in template repo."
}

if (-not (Test-Path $sourceOpenSpec)) {
  throw "Missing openspec in template repo."
}

New-Item -ItemType Directory -Path (Join-Path $targetPath ".opencode") -Force | Out-Null
Copy-Item -Recurse -Force (Join-Path $sourceOpencode "*") (Join-Path $targetPath ".opencode")

New-Item -ItemType Directory -Path (Join-Path $targetPath "openspec") -Force | Out-Null
Copy-Item -Recurse -Force (Join-Path $sourceOpenSpec "*") (Join-Path $targetPath "openspec")

Write-Output "OpenCode integration complete."
