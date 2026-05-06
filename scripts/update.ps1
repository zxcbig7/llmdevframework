#requires -Version 5.1
<#
.SYNOPSIS
把 LLMDevFramework 內最新的修改重新部署到 ~/.claude/。

.DESCRIPTION
讀 manifest（~/.claude/.llmdevframework.json）+ deploy.config.json，比對：
  - source mtime > manifest.sourceMtime         → 框架端有更新 → 重部署
  - dest mtime    > manifest.deployedMtime      → 你改過 dest（衝突）→ 跳過 + 警告
  - dest 不存在                                  → 重部署
  - manifest 沒有但 config 有                    → 新加的 item，部署

.PARAMETER Force
忽略「使用者修改了 dest」的警告，強制覆蓋。

.PARAMETER DryRun
只顯示會做什麼。

.EXAMPLE
.\update.ps1
# 拉最新框架修改

.EXAMPLE
.\update.ps1 -Force
# 強制覆蓋你的本地修改
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
$manifest      = Read-Manifest

if ($null -eq $manifest) {
    Write-Warning '尚未安裝過。請先跑 install.ps1。'
    exit 1
}

Write-Header 'LLMDevFramework Update'
Write-Host "Framework root: $frameworkRoot"
Write-Host "Claude root:    $claudeRoot"
Write-Host "Last installed: $($manifest.installedAt)"
Write-Host "Last updated:   $($manifest.updatedAt)"
if ($DryRun) { Write-Host '⚠ DryRun 模式' -ForegroundColor Yellow }

# 建立 manifest 索引
$byId = @{}
foreach ($f in $manifest.files) { $byId[$f.id] = $f }

$updated = 0; $upToDate = 0; $newItems = 0; $userModified = 0; $missing = 0; $failed = 0
$newResults = @()

Write-Header '檢查更新'
foreach ($item in $config.items) {
    $srcPath = Join-Path $frameworkRoot $item.src
    $dstPath = Join-Path $claudeRoot $item.dst

    if (-not (Test-Path $srcPath)) {
        Write-Warning "  ✗ source 不存在: $($item.src)"
        $missing++
        continue
    }

    $tracked = $byId[$item.id]
    $reason = $null

    if ($null -eq $tracked) {
        $reason = 'new (deploy.config 新增項)'
    } elseif (-not (Test-Path $dstPath)) {
        $reason = 'dest 已被刪除'
    } else {
        $currentSrcMtime  = Get-FileMtime $srcPath
        $currentDestMtime = Get-FileMtime $dstPath

        # 檢查使用者是否改過 dest
        $userTouched = ($tracked.deployedMtime -and $currentDestMtime -ne $tracked.deployedMtime)
        if ($userTouched -and -not $Force) {
            Write-Warning "  ! 你修改過 $($item.dst)，跳過（用 -Force 覆蓋）"
            $userModified++
            continue
        }

        # 檢查 source 是否更新
        if ($tracked.sourceMtime -and $currentSrcMtime -le $tracked.sourceMtime) {
            $upToDate++
            continue
        }
        $reason = 'source 已更新'
    }

    Write-Host "  → $($item.src) ($reason)" -ForegroundColor Yellow
    try {
        $r = Deploy-Item -Item $item -FrameworkRoot $frameworkRoot -ClaudeRoot $claudeRoot -DryRun:$DryRun -Force
        if ($null -ne $r) {
            $newResults += $r
            if ($null -eq $tracked) { $newItems++ } else { $updated++ }
        }
    } catch {
        Write-Warning "  ✗ 失敗: $_"
        $failed++
    }
}

# 偵測 manifest 有但 config 已移除的 item（孤兒）
$configIds = @{}
foreach ($i in $config.items) { $configIds[$i.id] = $true }
$orphans = @($manifest.files | Where-Object { -not $configIds.ContainsKey($_.id) })
if ($orphans.Count -gt 0) {
    Write-Header '孤兒 item（已從 deploy.config 移除）'
    foreach ($o in $orphans) {
        Write-Host "  ? $($o.dst)（建議跑 uninstall.ps1 清理）" -ForegroundColor DarkYellow
    }
}

if (-not $DryRun -and ($updated -gt 0 -or $newItems -gt 0)) {
    foreach ($r in $newResults) { $byId[$r.id] = $r }
    $manifest.files = @($byId.Values)
    $manifest.updatedAt = (Get-Date).ToString('o')
    $manifest.frameworkRoot = $frameworkRoot
    Write-Manifest -Manifest $manifest
}

Write-Host ''
Write-Host "結果：" -ForegroundColor Cyan
Write-Host "  已更新       : $updated"
Write-Host "  新增         : $newItems"
Write-Host "  已是最新     : $upToDate"
Write-Host "  你改過跳過   : $userModified  (要覆蓋用 -Force)"
Write-Host "  source 不存在: $missing"
Write-Host "  失敗         : $failed"
if ($orphans.Count -gt 0) {
    Write-Host "  孤兒 item    : $($orphans.Count)  (跑 uninstall.ps1 清掉)"
}
