#requires -Version 5.1
<#
.SYNOPSIS
從 ~/.claude/ 移除所有由 LLMDevFramework 部署的檔案。

.DESCRIPTION
讀 manifest 逐項刪除。若使用者修改過某個 dest（mtime 不一致），預設跳過並警告。

.PARAMETER Force
忽略「使用者修改了 dest」的警告，強制刪除。

.PARAMETER DryRun
只顯示會做什麼。

.PARAMETER KeepManifest
刪檔但保留 manifest（給 reinstall 用，預設會一起刪）。

.EXAMPLE
.\uninstall.ps1
# 安全卸載（保留你修改過的檔案）

.EXAMPLE
.\uninstall.ps1 -Force
# 全部刪光（包括你改過的）
#>

[CmdletBinding()]
param(
    [switch] $Force,
    [switch] $DryRun,
    [switch] $KeepManifest
)

. (Join-Path $PSScriptRoot 'lib.ps1')

$claudeRoot = Get-ClaudeRoot
$manifest   = Read-Manifest

if ($null -eq $manifest) {
    Write-Warning '沒有 manifest，沒東西可卸載。'
    exit 0
}

Write-Header 'LLMDevFramework Uninstall'
Write-Host "Claude root:    $claudeRoot"
Write-Host "Items 待移除:   $($manifest.files.Count)"
if ($DryRun) { Write-Host '⚠ DryRun 模式' -ForegroundColor Yellow }
if ($Force) { Write-Host '⚠ Force 模式：會強制刪除你修改過的檔案' -ForegroundColor Yellow }

$removed = 0; $kept = 0; $missing = 0
$keptEntries = @()

Write-Header '移除檔案'
foreach ($entry in $manifest.files) {
    $dstPath = Join-Path $claudeRoot $entry.dst

    if (-not (Test-Path $dstPath)) {
        Write-Host "  - 已不存在: $($entry.dst)" -ForegroundColor DarkGray
        $missing++
        continue
    }

    $currentMtime = Get-FileMtime $dstPath
    $userTouched  = ($entry.deployedMtime -and $currentMtime -ne $entry.deployedMtime)

    if ($userTouched -and -not $Force) {
        Write-Warning "  ! 你修改過 $($entry.dst)，保留不刪（用 -Force 強制刪）"
        $kept++
        $keptEntries += $entry
        continue
    }

    if ($DryRun) {
        Write-Host "  [dry-run] 刪除 $($entry.dst)"
        continue
    }

    try {
        Remove-Item -Path $dstPath -Force
        Write-Host "  ✓ 已刪除 $($entry.dst)" -ForegroundColor Green
        $removed++
    } catch {
        Write-Warning "  ✗ $($entry.dst) 失敗: $_"
    }
}

if (-not $DryRun) {
    if ($keptEntries.Count -gt 0 -and -not $Force) {
        # 保留 manifest 但只記錄被保留的 entries（讓下次 update 還能管理它們）
        $manifest.files = @($keptEntries)
        $manifest.updatedAt = (Get-Date).ToString('o')
        Write-Manifest -Manifest $manifest
        Write-Host ''
        Write-Host "Manifest 仍保留（追蹤你修改過的 $($kept) 個檔案）" -ForegroundColor DarkCyan
    } elseif (-not $KeepManifest) {
        $manifestPath = Get-ManifestPath
        if (Test-Path $manifestPath) {
            Remove-Item $manifestPath -Force
            Write-Host ''
            Write-Host '✓ Manifest 已刪除' -ForegroundColor Green
        }
    }
}

Write-Host ''
Write-Host "結果：" -ForegroundColor Cyan
Write-Host "  已刪除         : $removed"
Write-Host "  保留（你改過） : $kept"
Write-Host "  原本不存在     : $missing"
