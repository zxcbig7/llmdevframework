#requires -Version 5.1
<#
.SYNOPSIS
把 LLMDevFramework 部署到 ~/.claude/（slash commands + manifest）。

.DESCRIPTION
讀取 deploy.config.json，逐項：
  1. 載入 source 檔
  2. 套 transform（替換 {{FRAMEWORK_PATH}}）
  3. 寫到 ~/.claude/<dst>
  4. 寫入 manifest（~/.claude/.llmdevframework.json）

之後在任何專案打 /sdd、/k8s-review、/proc-analyze、/prompt-improve 都能用。

.PARAMETER Force
覆蓋既有檔案（即使非本框架部署）。預設碰到衝突會跳過並警告。

.PARAMETER DryRun
只顯示會做什麼，不實際寫檔。

.EXAMPLE
.\install.ps1
# 預設：部署到 ~/.claude/，遇衝突跳過

.EXAMPLE
.\install.ps1 -Force
# 強制覆蓋

.EXAMPLE
.\install.ps1 -DryRun
# 看會做什麼但不執行
#>

[CmdletBinding()]
param(
    [switch] $Force,
    [switch] $DryRun
)

. (Join-Path $PSScriptRoot 'lib.ps1')

$frameworkRoot = Get-FrameworkRoot
$claudeRoot    = Get-ClaudeRoot
$config        = Read-DeployConfig

Write-Header 'LLMDevFramework Install'
Write-Host "Framework root: $frameworkRoot"
Write-Host "Claude root:    $claudeRoot"
Write-Host "Items:          $($config.items.Count)"
if ($DryRun) { Write-Host '⚠ DryRun 模式：不會實際寫檔' -ForegroundColor Yellow }

$results = @()
$ok = 0; $skipped = 0; $failed = 0

Write-Header '部署檔案'
foreach ($item in $config.items) {
    try {
        $r = Deploy-Item -Item $item -FrameworkRoot $frameworkRoot -ClaudeRoot $claudeRoot -DryRun:$DryRun -Force:$Force
        if ($null -ne $r) {
            $results += $r
            $ok++
        } else {
            $skipped++
        }
    } catch {
        Write-Warning "  ✗ $($item.src) 失敗: $_"
        $failed++
    }
}

if (-not $DryRun) {
    $manifest = Read-Manifest
    if ($null -eq $manifest) {
        $manifest = New-Manifest -FrameworkRoot $frameworkRoot
    } else {
        $manifest.frameworkRoot = $frameworkRoot
        $manifest.updatedAt = (Get-Date).ToString('o')
    }
    # 合併：保留未在本次部署的舊 entry（理論上不會有，但保險）
    $existingById = @{}
    foreach ($f in $manifest.files) { $existingById[$f.id] = $f }
    foreach ($r in $results) { $existingById[$r.id] = $r }
    $manifest.files = @($existingById.Values)

    Write-Manifest -Manifest $manifest
    Write-Host ''
    Write-Host "Manifest 已寫入: $(Get-ManifestPath)" -ForegroundColor DarkCyan
}

Write-Summary -Ok $ok -Skipped $skipped -Failed $failed

if ($ok -gt 0 -and -not $DryRun) {
    Write-Host ''
    Write-Host '✅ 安裝完成。可用的 slash command：' -ForegroundColor Green
    foreach ($r in $results | Where-Object { $_.type -eq 'command' }) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($r.dst)
        Write-Host "   /$name"
    }
}
