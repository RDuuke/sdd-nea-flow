#Requires -Version 5.1

<#
.SYNOPSIS
    NEA Flow installer for Windows
.DESCRIPTION
    Copies nea-flow skills to your AI coding assistant's skill directory.
.PARAMETER Agent
    Install for a specific agent (non-interactive).
    Valid values: opencode, amazonq, vscode, project-local, all-global, custom
.PARAMETER Path
    Custom install path (use with -Agent custom)
.PARAMETER Help
    Show help
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -Agent opencode
.EXAMPLE
    .\install.ps1 -Agent custom -Path C:\my\skills
#>

[CmdletBinding()]
param(
    [ValidateSet('opencode', 'amazonq', 'vscode', 'project-local', 'all-global', 'custom')]
    [string]$Agent,
    [string]$Path,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# ============================================================================
# Path Resolution
# ============================================================================

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoDir = Split-Path -Parent $ScriptRoot
$SkillsSrc = Join-Path $RepoDir 'skills'

$ToolPaths = @{
    'opencode'      = Join-Path $env:APPDATA 'opencode\skills'
    'amazonq'       = Join-Path '.' '.amazonq\rules'
    'vscode'        = Join-Path '.' '.vscode\skills'
    'project-local' = Join-Path '.' 'skills'
}

# ============================================================================
# Display Helpers
# ============================================================================

function Write-Header {
    Write-Host ''
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '     NEA Flow - Installer (Windows)     ' -ForegroundColor Cyan
    Write-Host '  Spec-Driven Development for AI Agents ' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host "  Detected: Windows (PowerShell $($PSVersionTable.PSVersion))" -ForegroundColor White
    Write-Host ''
}

function Write-Skill {
    param([string]$Name)
    Write-Host "  [OK] $Name" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [ERR] $Message" -ForegroundColor Red
}

function Write-NextStep {
    param(
        [string]$ConfigFile,
        [string]$ExampleFile
    )
    Write-Host ''
    Write-Host 'Next step:' -ForegroundColor Yellow
    Write-Host "  Add the orchestrator to your $ConfigFile" -ForegroundColor White
    Write-Host "  See: $ExampleFile" -ForegroundColor Cyan
}

function Write-OpenSpecNote {
    Write-Host ''
    Write-Host 'Recommended persistence backend: ' -ForegroundColor Yellow -NoNewline
    Write-Host 'OpenSpec' -ForegroundColor White
    Write-Host '  If OpenSpec is available, it will be used automatically (recommended)'
    Write-Host '  Otherwise it falls back to local artifacts in openspec/'
}

function Show-Usage {
    Write-Host 'Usage: .\install.ps1 [OPTIONS]'
    Write-Host ''
    Write-Host 'Options:'
    Write-Host '  -Agent NAME    Install for a specific agent (non-interactive)'
    Write-Host '  -Path DIR      Custom install path (use with -Agent custom)'
    Write-Host '  -Help          Show this help'
    Write-Host ''
    Write-Host 'Agents: opencode, amazonq, vscode, project-local, all-global, custom'
}

# ============================================================================
# Install Functions
# ============================================================================

function Test-SourceTree {
    $missing = 0
    $skillDirs = Get-ChildItem -Path $SkillsSrc -Directory -Filter 'flow-nea-*'
    foreach ($skillDir in $skillDirs) {
        $skillFile = Join-Path $skillDir.FullName 'SKILL.md'
        if (-not (Test-Path $skillFile)) {
            Write-Err "Missing: $($skillDir.Name)\SKILL.md"
            $missing++
        }
    }
    if (-not (Test-Path (Join-Path $SkillsSrc '_shared'))) {
        Write-Err 'Missing: _shared/ directory'
        $missing++
    }
    if ($missing -gt 0) {
        Write-Host ''
        Write-Host 'Source validation failed. Is this a complete clone of the repository?' -ForegroundColor Red
        Write-Host '  Try: git clone https://github.com/Gentleman-Programming/tdd-nea-flow.git' -ForegroundColor Cyan
        Write-Host ''
        exit 1
    }
}

function Install-Skills {
    param(
        [string]$TargetDir,
        [string]$ToolName
    )

    Write-Host ''
    Write-Host "Installing skills for $ToolName..." -ForegroundColor Blue

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    # Copy shared convention files (_shared/)
    $sharedSrc = Join-Path $SkillsSrc '_shared'
    $sharedTarget = Join-Path $TargetDir '_shared'

    if (Test-Path $sharedSrc) {
        New-Item -ItemType Directory -Path $sharedTarget -Force | Out-Null
        $sharedFiles = Get-ChildItem -Path $sharedSrc -Filter '*.md'
        $sharedCount = 0
        foreach ($file in $sharedFiles) {
            Copy-Item -Path $file.FullName -Destination $sharedTarget -Force
            $sharedCount++
        }
        if ($sharedCount -gt 0) {
            Write-Skill "_shared ($sharedCount convention files)"
        } else {
            Write-Warn '_shared directory found but no .md files to copy'
        }
    }

    $count = 0
    $skillDirs = Get-ChildItem -Path $SkillsSrc -Directory -Filter 'flow-nea-*'

    foreach ($skillDir in $skillDirs) {
        $skillName = $skillDir.Name
        $skillFile = Join-Path $skillDir.FullName 'SKILL.md'

        if (-not (Test-Path $skillFile)) {
            Write-Warn "Skipping $skillName (SKILL.md not found in source)"
            continue
        }

        $targetSkillDir = Join-Path $TargetDir $skillName
        New-Item -ItemType Directory -Path $targetSkillDir -Force | Out-Null

        $targetFile = Join-Path $targetSkillDir 'SKILL.md'
        Copy-Item -Path $skillFile -Destination $targetFile -Force

        Write-Skill $skillName
        $count++
    }

    Write-Host ''
    Write-Host "  $count skills installed" -ForegroundColor Green -NoNewline
    Write-Host " -> $TargetDir"
}

function Install-AmazonQAgent {
    $amazonqDir = Join-Path '.' '.amazonq'
    $agentSrc = Join-Path $RepoDir 'examples\amazonq\agent.js'
    $agentTarget = Join-Path $amazonqDir 'agent.js'

    if (-not (Test-Path $agentSrc)) {
        Write-Err 'Missing examples\amazonq\agent.js'
        exit 1
    }

    New-Item -ItemType Directory -Path $amazonqDir -Force | Out-Null
    Copy-Item -Path $agentSrc -Destination $agentTarget -Force
    Write-Skill 'amazonq agent.js'
}

# ============================================================================
# Agent Install Dispatcher
# ============================================================================

function Install-ForAgent {
    param([string]$AgentName)

    switch ($AgentName) {
        'opencode' {
            Install-Skills -TargetDir $ToolPaths['opencode'] -ToolName 'OpenCode'
            Write-Host ''
            Write-Host 'ACTION REQUIRED:' -ForegroundColor Yellow
            Write-Host '  Copy the agent block from:' -ForegroundColor White
            Write-Host '    examples\opencode\opencode.json' -ForegroundColor Cyan
            Write-Host '  Into your:' -ForegroundColor White
            Write-Host "    $env:APPDATA\opencode\opencode.json" -ForegroundColor Cyan
        }
        'amazonq' {
            Install-Skills -TargetDir $ToolPaths['amazonq'] -ToolName 'Amazon Q'
            Install-AmazonQAgent
            Write-Host ''
            Write-Warn 'Skills installed in .amazonq\rules\'
        }
        'vscode' {
            Install-Skills -TargetDir $ToolPaths['vscode'] -ToolName 'VS Code (Copilot)'
            Write-NextStep '.github\copilot-instructions.md' 'examples\vscode\copilot-instructions.md'
            Write-Warn 'Skills installed in current project (.vscode\skills\)'
        }
        'project-local' {
            Install-Skills -TargetDir $ToolPaths['project-local'] -ToolName 'Project-local'
            Write-Host ''
            Write-Warn 'Skills installed in .\skills\ - relative to this project'
        }
        'all-global' {
            Install-Skills -TargetDir $ToolPaths['opencode'] -ToolName 'OpenCode'
            Write-Host ''
            Write-Host 'Next steps:' -ForegroundColor Yellow
            Write-Host '  1. Add orchestrator agent to ' -NoNewline
            Write-Host "$env:APPDATA\opencode\opencode.json" -ForegroundColor White
            Write-Host '     See: examples\opencode\opencode.json' -ForegroundColor Cyan
        }
        'custom' {
            $customPath = $Path
            if (-not $customPath) {
                $customPath = Read-Host 'Enter target path'
            }
            if (-not $customPath) {
                Write-Err 'No path provided'
                exit 1
            }
            Install-Skills -TargetDir $customPath -ToolName 'Custom'
        }
        default {
            Write-Err "Unknown agent: $AgentName"
            Write-Host ''
            Show-Usage
            exit 1
        }
    }
}

# ============================================================================
# Interactive Menu
# ============================================================================

function Show-Menu {
    Write-Host 'Select your AI coding assistant:' -ForegroundColor White
    Write-Host ''
    Write-Host "   1) OpenCode       ($($ToolPaths['opencode']))"
    Write-Host "   2) Amazon Q       (.amazonq\rules)"
    Write-Host "   3) VS Code        ($($ToolPaths['vscode']))"
    Write-Host "   4) Project-local  ($($ToolPaths['project-local']))"
    Write-Host '   5) All global     (OpenCode)'
    Write-Host '   6) Custom path'
    Write-Host ''

    $choice = Read-Host 'Choice [1-6]'

    $agentMap = @{
        '1' = 'opencode'
        '2' = 'amazonq'
        '3' = 'vscode'
        '4' = 'project-local'
        '5' = 'all-global'
        '6' = 'custom'
    }

    if ($agentMap.ContainsKey($choice)) {
        Install-ForAgent $agentMap[$choice]
    }
    else {
        Write-Err 'Invalid choice'
        exit 1
    }
}

# ============================================================================
# Main
# ============================================================================

try {
    if ($Help) {
        Show-Usage
        exit 0
    }

    Write-Header
    Test-SourceTree

    if ($Agent) {
        Install-ForAgent $Agent
    }
    else {
        Show-Menu
    }

    Write-Host ''
    Write-Host 'Done!' -ForegroundColor Green -NoNewline
    Write-Host ' Start using NEA Flow with: ' -NoNewline
    Write-Host '/flow-nea-init' -ForegroundColor Cyan -NoNewline
    Write-Host ' in your project'

    Write-OpenSpecNote
    Write-Host ''
}
catch {
    Write-Host ''
    Write-Err "Installation failed: $_"
    Write-Host ''
    exit 1
}
