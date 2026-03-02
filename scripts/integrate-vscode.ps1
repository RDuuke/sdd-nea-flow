param(
  [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$targetPath = Resolve-Path $Target

$sourceVscode = Join-Path $repoRoot "examples\vscode\.vscode"

if (-not (Test-Path $sourceVscode)) {
  throw "Missing examples/vscode/.vscode in template repo."
}

New-Item -ItemType Directory -Path (Join-Path $targetPath ".vscode") -Force | Out-Null
Copy-Item -Recurse -Force (Join-Path $sourceVscode "*") (Join-Path $targetPath ".vscode")

Write-Output "VS Code integration complete."
