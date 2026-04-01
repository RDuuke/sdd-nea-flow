#Requires -Version 5.1

<#
.SYNOPSIS
    NEA Flow installer for Windows
.DESCRIPTION
    Copies nea-flow skills to your AI coding assistant's skill directory.
.PARAMETER Agent
    Install for a specific agent (non-interactive).
    Valid values: opencode, amazonq, gemini-cli, codex, vscode, project-local, all-global, custom
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
    [ValidateSet('opencode', 'amazonq', 'gemini-cli', 'codex', 'vscode', 'claude-code', 'project-local', 'all-global', 'custom')]
    [string]$Agent,
    [ValidateSet('local', 'global')]
    [string]$Scope,
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
    'opencode'      = Join-Path (Get-Location) '.opencode\skills'
    'amazonq'       = Join-Path '.' '.amazonq\rules'
    'gemini-cli'    = Join-Path $env:USERPROFILE '.gemini\skills'
    'codex'         = Join-Path $env:USERPROFILE '.codex\skills'
    'vscode'        = Join-Path '.' '.vscode\skills'
    'project-local' = Join-Path '.' 'skills'
}

$MarkerBegin = '<!-- BEGIN:flow-nea -->'
$MarkerEnd = '<!-- END:flow-nea -->'
$OpenCodeMode = ''

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

function Get-Timestamp {
    return (Get-Date -Format 'HH:mm:ss')
}

function Write-Skill {
    param([string]$Name)
    Write-Host "  [$(Get-Timestamp)] [OK] $Name" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [$(Get-Timestamp)] [WARN] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [$(Get-Timestamp)] [ERR] $Message" -ForegroundColor Red
}

function Write-NextStep {
    param(
        [string]$ConfigFile,
        [string]$ExampleFile
    )
    Write-Host ''
    Write-Host 'Siguiente paso:' -ForegroundColor Yellow
    Write-Host "  Agrega el orquestador a tu $ConfigFile" -ForegroundColor White
    Write-Host "  Ver: $ExampleFile" -ForegroundColor Cyan
}

function Write-OpenSpecNote {
    Write-Host ''
    Write-Host 'Backend de persistencia recomendado: ' -ForegroundColor Yellow -NoNewline
    Write-Host 'OpenSpec' -ForegroundColor White
    Write-Host '  Si OpenSpec esta disponible, se usara automaticamente (recomendado)'
    Write-Host '  De lo contrario, usa artefactos locales en openspec/'
}

function Show-Usage {
    Write-Host 'Usage: .\install.ps1 [OPTIONS]'
    Write-Host ''
    Write-Host 'Options:'
    Write-Host '  -Agent NAME    Install for a specific agent (non-interactive)'
    Write-Host '  -Path DIR      Custom install path (use with -Agent custom)'
    Write-Host '  -Scope SCOPE   Scope for gemini-cli/codex (local or global)'
    Write-Host '  -Help          Show this help'
    Write-Host ''
    Write-Host 'Agents: opencode, amazonq, gemini-cli, codex, vscode, claude-code, project-local, all-global, custom'
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
        Write-Host '  Try: git clone https://github.com/RDuuke/sdd-nea-flow.git' -ForegroundColor Cyan
        Write-Host ''
        exit 1
    }
}

function Test-Checksums {
    $checksumFile = Join-Path $RepoDir 'checksums.sha256'
    if (-not (Test-Path $checksumFile)) {
        Write-Warn 'checksums.sha256 no encontrado - omitiendo verificacion de integridad'
        return
    }
    Write-Host '  Verificando integridad de archivos...' -ForegroundColor Blue
    $lines = Get-Content $checksumFile | Where-Object { $_ -and -not $_.StartsWith('#') }
    $failed = 0
    foreach ($line in $lines) {
        $parts = $line -split '\s+', 2
        if ($parts.Count -ne 2) { continue }
        $expectedHash = $parts[0]
        $filePath = Join-Path $RepoDir ($parts[1].TrimStart('*'))
        if (-not (Test-Path $filePath)) {
            Write-Warn "Archivo faltante: $($parts[1])"
            $failed++
            continue
        }
        $actualHash = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash.ToLower()
        if ($actualHash -ne $expectedHash) {
            $failed++
        }
    }
    if ($failed -eq 0) {
        Write-Skill 'Todos los checksums verificados OK'
    } else {
        Write-Warn "$failed archivo(s) no coinciden con checksums. Esperado si hiciste cambios locales."
    }
}

function Install-Skills {
    param(
        [string]$TargetDir,
        [string]$ToolName
    )

    Write-Host ''
    Write-Host "Instalando skills para $ToolName..." -ForegroundColor Blue

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
    $extraSkills = @('judgment-day', 'skill-registry', 'skill-creator')
    $skillDirs = @(Get-ChildItem -Path $SkillsSrc -Directory -Filter 'flow-nea-*') +
                 @($extraSkills | ForEach-Object {
                     $p = Join-Path $SkillsSrc $_
                     if (Test-Path $p) { Get-Item $p } }) |
                 Where-Object { $_ -ne $null }

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
    Write-Host "  $count skills instaladas" -ForegroundColor Green -NoNewline
    Write-Host " -> $TargetDir"
}

function Install-AmazonQPrompt {
    $amazonqPromptsDir = Join-Path $env:USERPROFILE '.aws\amazonq\prompts'
    $promptSrc = Join-Path $RepoDir 'examples\amazonq\amazonq-instructions.md'
    $promptTarget = Join-Path $amazonqPromptsDir 'amazonq-instructions.md'

    if (-not (Test-Path $promptSrc)) {
        Write-Err 'Missing examples\amazonq\amazonq-instructions.md'
        exit 1
    }

    New-Item -ItemType Directory -Path $amazonqPromptsDir -Force | Out-Null
    Copy-Item -Path $promptSrc -Destination $promptTarget -Force

    if (-not (Test-Path $promptTarget)) {
        Write-Warn 'No se pudo verificar el prompt de Amazon Q'
        return
    }

    Write-Skill 'amazonq prompt (amazonq-instructions.md)'
}

function Install-GeminiPrompt {
    $geminiDir = Join-Path $env:USERPROFILE '.gemini'
    $promptSrc = Join-Path $RepoDir 'examples\gemini-cli\GEMINI.md'
    $promptTarget = Join-Path $geminiDir 'GEMINI.md'

    if (-not (Test-Path $promptSrc)) {
        Write-Err 'Missing examples\gemini-cli\GEMINI.md'
        exit 1
    }

    New-Item -ItemType Directory -Path $geminiDir -Force | Out-Null

    $promptContent = Get-Content -Path $promptSrc -Raw
    if (Test-Path $promptTarget) {
        $current = Get-Content -Path $promptTarget -Raw
        if ($current -match 'ORQUESTADOR NEA FLOW') {
            Write-Warn 'Prompt de Gemini CLI ya existe en GEMINI.md'
            return
        }
        Add-Content -Path $promptTarget -Value "`n`n$promptContent"
    }
    else {
        Set-Content -Path $promptTarget -Value $promptContent
    }

    if (-not (Test-Path $promptTarget)) {
        Write-Warn 'No se pudo verificar el prompt de Gemini CLI'
        return
    }

    Write-Skill 'Gemini CLI prompt (GEMINI.md)'
}

function Install-CodexPrompt {
    $codexDir = Join-Path $env:USERPROFILE '.codex'
    $promptSrc = Join-Path $RepoDir 'examples\codex\agents.md'
    $promptTarget = Join-Path $codexDir 'agents.md'

    if (-not (Test-Path $promptSrc)) {
        Write-Err 'Missing examples\codex\agents.md'
        exit 1
    }

    New-Item -ItemType Directory -Path $codexDir -Force | Out-Null

    $promptContent = Get-Content -Path $promptSrc -Raw
    if (Test-Path $promptTarget) {
        $current = Get-Content -Path $promptTarget -Raw
        if ($current -match 'ORQUESTADOR NEA FLOW') {
            Write-Warn 'Prompt de Codex ya existe en agents.md'
            return
        }
        Add-Content -Path $promptTarget -Value "`n`n$promptContent"
    }
    else {
        Set-Content -Path $promptTarget -Value $promptContent
    }

    if (-not (Test-Path $promptTarget)) {
        Write-Warn 'No se pudo verificar el prompt de Codex'
        return
    }

    Write-Skill 'codex prompt (agents.md)'
}

function Resolve-ClaudeCodeDir {
    param([string]$InstallScope)
    if ($InstallScope -eq 'local') {
        return Join-Path (Get-Location) '.claude'
    }
    return Join-Path $env:USERPROFILE '.claude'
}

function Install-ClaudeCodePrompt {
    param([string]$InstallScope)

    $claudeMdSrc = Join-Path $RepoDir 'examples\claude-code\CLAUDE.md'
    $marker = 'FLOW-NEA ORCHESTRATOR'

    if (-not (Test-Path $claudeMdSrc)) {
        Write-Err 'Missing examples\claude-code\CLAUDE.md'
        exit 1
    }

    if ($InstallScope -eq 'local') {
        $claudeMdTarget = Join-Path (Get-Location) 'CLAUDE.md'
    }
    else {
        $claudeDir = Join-Path $env:USERPROFILE '.claude'
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
        $claudeMdTarget = Join-Path $claudeDir 'CLAUDE.md'
    }

    $content = Get-Content -Path $claudeMdSrc -Raw

    if ((Test-Path $claudeMdTarget) -and ((Get-Content -Path $claudeMdTarget -Raw) -like "*$MarkerBegin*")) {
        # Marcadores existen → reemplazar contenido entre ellos (idempotente)
        $current = Get-Content -Path $claudeMdTarget -Raw
        $pattern = [regex]::Escape($MarkerBegin) + '[\s\S]*?' + [regex]::Escape($MarkerEnd)
        $replacement = "$MarkerBegin`n$content`n$MarkerEnd"
        $updated = $current -replace $pattern, $replacement
        Set-Content -Path $claudeMdTarget -Value $updated -NoNewline
        Write-Skill "Instrucciones del orquestador actualizadas en $(Split-Path $claudeMdTarget -Leaf)"
        return
    }
    elseif ((Test-Path $claudeMdTarget) -and ((Get-Content -Path $claudeMdTarget -Raw) -match $marker)) {
        Write-Warn "Instrucciones del orquestador ya existen en $claudeMdTarget (sin marcadores)"
        Write-Warn "Para actualizaciones automaticas, envuelve la seccion con marcadores BEGIN/END"
        return
    }
    elseif (Test-Path $claudeMdTarget) {
        # Archivo existe, sin contenido flow-nea → agregar con marcadores
        Add-Content -Path $claudeMdTarget -Value "`n`n$MarkerBegin`n$content`n$MarkerEnd"
    }
    else {
        Set-Content -Path $claudeMdTarget -Value "$MarkerBegin`n$content`n$MarkerEnd"
    }

    if (-not (Test-Path $claudeMdTarget)) {
        Write-Warn "No se pudo verificar $claudeMdTarget"
        return
    }

    Write-Skill "$claudeMdTarget (instrucciones del orquestador)"
}

function Install-ClaudeCodeCommands {
    param([string]$TargetDir)

    $commandsSrc = Join-Path $RepoDir 'examples\claude-code\commands'
    $commandsTarget = Join-Path $TargetDir 'commands'

    if (-not (Test-Path $commandsSrc)) {
        Write-Warn 'Missing examples\claude-code\commands\'
        return
    }

    New-Item -ItemType Directory -Path $commandsTarget -Force | Out-Null
    $cmdFiles = Get-ChildItem -Path $commandsSrc -Filter '*.md'
    foreach ($file in $cmdFiles) {
        Copy-Item -Path $file.FullName -Destination $commandsTarget -Force
    }
    Write-Skill "$commandsTarget ($($cmdFiles.Count) commands)"
}

function Resolve-GeminiSkillsDir {
    param([string]$InstallScope)
    if ($InstallScope -eq 'local') {
        return Join-Path (Get-Location) '.gemini\skills'
    }
    return Join-Path $env:USERPROFILE '.gemini\skills'
}

function Resolve-CodexSkillsDir {
    param([string]$InstallScope)
    if ($InstallScope -eq 'local') {
        return Join-Path (Get-Location) '.codex\skills'
    }
    return Join-Path $env:USERPROFILE '.codex\skills'
}

function Install-OpenCodeAgentsMd {
    param([string]$TargetDir)
    $agentsSrc = Join-Path $RepoDir 'examples\opencode\AGENTS.md'
    if (-not (Test-Path $agentsSrc)) {
        Write-Warn 'Missing examples\opencode\AGENTS.md'
        return
    }
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Copy-Item -Path $agentsSrc -Destination (Join-Path $TargetDir 'AGENTS.md') -Force
    Write-Skill "AGENTS.md instalado en $TargetDir"
}

function Get-OpenCodeMode {
    if ($script:OpenCodeMode) { return $script:OpenCodeMode }
    Write-Host ''
    Write-Host '  Modo de agentes OpenCode:' -ForegroundColor White
    Write-Host '  1) Single model  — un modelo para todas las fases (simple, recomendado)'
    Write-Host '  2) Multi-model   — modelo distinto por fase (optimiza costos)'
    Write-Host ''
    $choice = Read-Host '  Opcion [1]'
    if ($choice -eq '2' -or $choice -eq 'multi') {
        $script:OpenCodeMode = 'multi'
    } else {
        $script:OpenCodeMode = 'single'
    }
    return $script:OpenCodeMode
}

function Install-OpenCodeConfig {
    param([string]$TargetDir)
    $mode = Get-OpenCodeMode
    $configSrc = Join-Path $RepoDir "examples\opencode\opencode.$mode.json"
    if (-not (Test-Path $configSrc)) {
        $configSrc = Join-Path $RepoDir 'examples\opencode\opencode.json'
    }
    if (-not (Test-Path $configSrc)) {
        Write-Warn 'Missing opencode config source'
        return
    }
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    $configTarget = Join-Path $TargetDir 'opencode.json'

    $jqCmd = Get-Command jq -ErrorAction SilentlyContinue
    if ($jqCmd -and (Test-Path $configTarget)) {
        # Smart merge preservando modelos del usuario
        $newAgents = (& jq '.agent // {}' $configSrc) | Out-String
        $merged = (& jq --argjson new_agents $newAgents '
          (reduce ((.agent // {}) | to_entries[] |
            select(.key | test("^flow-nea-|^judgment-day|^skill-registry")) |
            select(.value.model)) as $e
            ({}; . + {($e.key): $e.value.model})) as $saved |
          .agent = (
            ((.agent // {}) | with_entries(select(.key | test("^flow-nea-|^judgment-day|^skill-registry") | not)))
            + $new_agents
          ) |
          reduce ($saved | to_entries[]) as $m (.;
            if .agent[$m.key] then .agent[$m.key].model = $m.value else . end
          )
        ' $configTarget) | Out-String
        Set-Content -Path $configTarget -Value $merged
        Write-Skill "opencode.json actualizado ($mode mode, modelos preservados)"
    } else {
        Copy-Item -Path $configSrc -Destination $configTarget -Force
        Write-Skill "opencode.json instalado ($mode mode)"
        Write-Warn "Edita el modelo en $configTarget (busca <your-provider/your-model>)"
    }
}

# ============================================================================
# Agent Install Dispatcher
# ============================================================================

function Install-ForAgent {
    param([string]$AgentName)

    switch ($AgentName) {
        'opencode' {
            $opencodeDir = Join-Path (Get-Location) '.opencode'
            Install-Skills -TargetDir $ToolPaths['opencode'] -ToolName 'OpenCode'
            Install-OpenCodeAgentsMd -TargetDir $opencodeDir
            Install-OpenCodeConfig -TargetDir $opencodeDir
            $commandsSrc = Join-Path $RepoDir 'examples\opencode\commands'
            if (Test-Path $commandsSrc) {
                $commandsTarget = Join-Path $opencodeDir 'commands'
                New-Item -ItemType Directory -Path $commandsTarget -Force | Out-Null
                $cmdFiles = Get-ChildItem -Path $commandsSrc -Filter '*.md' -ErrorAction SilentlyContinue
                foreach ($f in $cmdFiles) {
                    Copy-Item -Path $f.FullName -Destination $commandsTarget -Force
                }
                Write-Skill ".opencode\commands\ ($($cmdFiles.Count) commands)"
            }
        }
        'amazonq' {
            Install-Skills -TargetDir $ToolPaths['amazonq'] -ToolName 'Amazon Q'
            Install-AmazonQPrompt
            Write-Host ''
            Write-Warn 'Skills instaladas en .amazonq\rules\'
            Write-Warn 'Prompt instalado en %USERPROFILE%\.aws\amazonq\prompts\amazon-instructions.md'
            Write-Host 'Siguiente paso: abre Amazon Q y ejecuta /flow-nea-init' -ForegroundColor Yellow
        }
        'gemini-cli' {
            $installScope = $Scope
            if (-not $installScope) {
                $installScope = Read-Host 'Scope (local/global)'
            }
            if ($installScope -ne 'local' -and $installScope -ne 'global') {
                Write-Err 'Scope invalido. Usa local o global.'
                exit 1
            }
            $targetDir = Resolve-GeminiSkillsDir -InstallScope $installScope
            Install-Skills -TargetDir $targetDir -ToolName 'Gemini CLI'
            Install-GeminiPrompt
            Write-Host ''
            Write-Warn "Skills instaladas en $targetDir"
            Write-Warn 'Prompt instalado en %USERPROFILE%\.gemini\GEMINI.md'
            Write-Warn 'Asegura GEMINI_SYSTEM_MD=1 en %USERPROFILE%\.gemini\.env'
            Write-Host 'Siguiente paso: abre Gemini CLI y ejecuta /flow-nea-init' -ForegroundColor Yellow
        }
        'codex' {
            $installScope = $Scope
            if (-not $installScope) {
                $installScope = Read-Host 'Scope (local/global)'
            }
            if ($installScope -ne 'local' -and $installScope -ne 'global') {
                Write-Err 'Scope invalido. Usa local o global.'
                exit 1
            }
            $targetDir = Resolve-CodexSkillsDir -InstallScope $installScope
            Install-Skills -TargetDir $targetDir -ToolName 'Codex'
            Install-CodexPrompt
            Write-Host ''
            Write-Warn "Skills instaladas en $targetDir"
            Write-Warn 'Prompt instalado en %USERPROFILE%\.codex\agents.md'
            Write-Host 'Siguiente paso: abre Codex y ejecuta /flow-nea-init' -ForegroundColor Yellow
        }
        'claude-code' {
            $installScope = $Scope
            if (-not $installScope) {
                $installScope = Read-Host 'Scope (local/global)'
            }
            if ($installScope -ne 'local' -and $installScope -ne 'global') {
                Write-Err 'Scope invalido. Usa local o global.'
                exit 1
            }
            $claudeDir = Resolve-ClaudeCodeDir -InstallScope $installScope
            Install-Skills -TargetDir (Join-Path $claudeDir 'skills') -ToolName 'Claude Code'
            Install-ClaudeCodePrompt -InstallScope $installScope
            Install-ClaudeCodeCommands -TargetDir $claudeDir
            Write-Host ''
            Write-Warn "Skills instaladas en $claudeDir\skills\"
            Write-Warn "Comandos instalados en $claudeDir\commands\"
            if ($installScope -eq 'local') {
                Write-Warn 'Instrucciones del orquestador agregadas a .\CLAUDE.md'
            }
            else {
                Write-Warn "Instrucciones del orquestador agregadas a $claudeDir\CLAUDE.md"
            }
            Write-Host 'Siguiente paso: abre Claude Code y ejecuta /flow-nea-init' -ForegroundColor Yellow
        }
        'vscode' {
            Install-Skills -TargetDir $ToolPaths['vscode'] -ToolName 'VS Code (Copilot)'
            Write-NextStep '.github\copilot-instructions.md' 'examples\vscode\copilot-instructions.md'
            Write-Warn 'Skills instaladas en el proyecto actual (.vscode\skills\)'
        }
        'project-local' {
            Install-Skills -TargetDir $ToolPaths['project-local'] -ToolName 'Project-local'
            Write-Host ''
            Write-Warn 'Skills instaladas en .\skills\ - relativo a este proyecto'
        }
        'all-global' {
            Install-Skills -TargetDir $ToolPaths['opencode'] -ToolName 'OpenCode'
            Write-Host ''
            Write-Host 'Siguientes pasos:' -ForegroundColor Yellow
            Write-Host '  1. Agrega el agente orquestador a ' -NoNewline
            Write-Host "$env:APPDATA\opencode\opencode.json" -ForegroundColor White
            Write-Host '     Ver: examples\opencode\opencode.json' -ForegroundColor Cyan
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
    Write-Host "   3) Gemini CLI     (local o global)"
    Write-Host "   4) Codex          (local o global)"
    Write-Host "   5) VS Code        ($($ToolPaths['vscode']))"
    Write-Host '   6) Claude Code    (local o global)'
    Write-Host "   7) Project-local  ($($ToolPaths['project-local']))"
    Write-Host '   8) All global     (OpenCode)'
    Write-Host '   9) Custom path'
    Write-Host ''

    $choice = Read-Host 'Choice [1-9]'

    $agentMap = @{
        '1' = 'opencode'
        '2' = 'amazonq'
        '3' = 'gemini-cli'
        '4' = 'codex'
        '5' = 'vscode'
        '6' = 'claude-code'
        '7' = 'project-local'
        '8' = 'all-global'
        '9' = 'custom'
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
    Test-Checksums

    if ($Agent) {
        Install-ForAgent $Agent
    }
    else {
        Show-Menu
    }

    Write-Host ''
    Write-Host 'Listo!' -ForegroundColor Green -NoNewline
    Write-Host ' Empieza a usar NEA Flow con: ' -NoNewline
    Write-Host '/flow-nea-init' -ForegroundColor Cyan -NoNewline
    Write-Host ' en tu proyecto'

    Write-OpenSpecNote
    Write-Host ''
}
catch {
    Write-Host ''
    Write-Err "Installation failed: $_"
    Write-Host ''
    exit 1
}
