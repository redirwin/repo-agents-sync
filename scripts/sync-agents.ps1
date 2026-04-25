#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$source = Join-Path $root '.agents'
if (-not (Test-Path $source)) {
    Write-Error ".agents/ not found at repo root. Nothing to sync."
    exit 1
}

# Enforce: every file in .agents/commands/ (other than README.md) must start with "repo-".
# Rationale documented in README.md ("Naming conventions").
$commandsDir = Join-Path $source 'commands'
if (Test-Path $commandsDir) {
    $bad = Get-ChildItem -Path $commandsDir -Filter '*.md' -File |
           Where-Object { $_.Name -ne 'README.md' -and $_.Name -notlike 'repo-*' }
    if ($bad) {
        Write-Host "Command files must be named repo-<name>.md. Offending file(s):" -ForegroundColor Red
        foreach ($f in $bad) { Write-Host "  $($f.FullName)" -ForegroundColor Red }
        Write-Host "Rename each to repo-<name>.md and re-run. See README.md -> Naming conventions." -ForegroundColor Red
        exit 1
    }
}

$targets = @(
    @{ Tool = 'cursor'; Base = '.cursor';  Skills = 'skills'; Commands = 'commands';           Rules = 'rules' }
    @{ Tool = 'claude'; Base = '.claude';  Skills = 'skills'; Commands = 'commands';           Rules = 'rules' }
    @{ Tool = 'github'; Base = '.github';  Skills = 'skills'; Commands = 'prompts';            Rules = 'instructions' }
)

foreach ($t in $targets) {
    $baseDir = Join-Path $root $t.Base
    if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir | Out-Null }

    foreach ($pair in @(
        @{ Src = 'skills';   Dst = $t.Skills   }
        @{ Src = 'commands'; Dst = $t.Commands }
        @{ Src = 'rules';    Dst = $t.Rules    }
    )) {
        $srcDir = Join-Path $source $pair.Src
        $dstDir = Join-Path $baseDir $pair.Dst
        if (-not (Test-Path $srcDir)) { continue }

        $mustWipe = $Clean -or ($t.Tool -eq 'github' -and ($pair.Src -eq 'commands' -or $pair.Src -eq 'rules'))
        if ($mustWipe -and (Test-Path $dstDir)) {
            Remove-Item -Recurse -Force $dstDir
        }
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir | Out-Null }

        Copy-Item -Path (Join-Path $srcDir '*') -Destination $dstDir -Recurse -Force

        if ($t.Tool -eq 'github' -and ($pair.Src -eq 'commands' -or $pair.Src -eq 'rules')) {
            $readmePath = Join-Path $dstDir 'README.md'
            if (Test-Path $readmePath) { Remove-Item $readmePath -Force }
        }

        if ($t.Tool -eq 'github' -and $pair.Src -eq 'commands') {
            Get-ChildItem -Path $dstDir -Filter '*.md' -File | Where-Object { $_.Name -notlike '*.prompt.md' -and $_.Name -ne 'README.md' } | ForEach-Object {
                Rename-Item $_.FullName ($_.BaseName + '.prompt.md')
            }
        }
        if ($t.Tool -eq 'github' -and $pair.Src -eq 'rules') {
            Get-ChildItem -Path $dstDir -Filter '*.md' -File | Where-Object { $_.Name -notlike '*.instructions.md' -and $_.Name -ne 'README.md' } | ForEach-Object {
                Rename-Item $_.FullName ($_.BaseName + '.instructions.md')
            }
        }

        Write-Host ("  synced {0} -> {1}" -f $pair.Src, (Resolve-Path $dstDir -Relative))
    }
}

Write-Host "Agent config sync complete."
