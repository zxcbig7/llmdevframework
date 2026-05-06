#requires -Version 5.1
<#
LLMDevFramework deploy 共用函式。
被 install.ps1 / update.ps1 / uninstall.ps1 dot-source 載入。
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ----------------------------------------------------------------------------
# 路徑
# ----------------------------------------------------------------------------

function Get-FrameworkRoot {
    # 從本檔的父目錄推回 LLMDevFramework 根
    Split-Path -Parent $PSScriptRoot
}

function Get-ClaudeRoot {
    # 預設 ~/.claude（Windows: $env:USERPROFILE\.claude）
    $home_ = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' }
    if (-not (Test-Path $home_)) {
        New-Item -ItemType Directory -Path $home_ -Force | Out-Null
    }
    $home_
}

function Get-ManifestPath {
    Join-Path (Get-ClaudeRoot) '.llmdevframework.json'
}

function Get-DeployConfigPath {
    Join-Path $PSScriptRoot 'deploy.config.json'
}

# ----------------------------------------------------------------------------
# Manifest（記錄已部署的檔案，給 update / uninstall 用）
# ----------------------------------------------------------------------------

function Read-Manifest {
    $path = Get-ManifestPath
    if (-not (Test-Path $path)) { return $null }
    Get-Content -Path $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Write-Manifest {
    param([Parameter(Mandatory)] $Manifest)
    $path = Get-ManifestPath
    $json = $Manifest | ConvertTo-Json -Depth 10
    Set-Content -Path $path -Value $json -Encoding UTF8 -NoNewline
}

function New-Manifest {
    param([Parameter(Mandatory)][string] $FrameworkRoot)
    [pscustomobject]@{
        version       = '1.0.0'
        frameworkRoot = $FrameworkRoot
        installedAt   = (Get-Date).ToString('o')
        updatedAt     = (Get-Date).ToString('o')
        scope         = 'global'
        files         = @()
    }
}

# ----------------------------------------------------------------------------
# 部署 config 載入
# ----------------------------------------------------------------------------

function Read-DeployConfig {
    $path = Get-DeployConfigPath
    if (-not (Test-Path $path)) {
        throw "deploy.config.json 不存在於 $path"
    }
    Get-Content -Path $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

# ----------------------------------------------------------------------------
# 變形 transform：把 source 內 {{FRAMEWORK_PATH}} 換成實際路徑
# ----------------------------------------------------------------------------

function Invoke-Transform {
    param(
        [Parameter(Mandatory)][string] $Content,
        [Parameter(Mandatory)][string] $TransformName,
        [Parameter(Mandatory)][string] $FrameworkRoot
    )
    switch ($TransformName) {
        'substitute-framework-path' {
            # 路徑用 forward slash 確保跨平台 markdown 引用穩定
            $normalized = $FrameworkRoot.Replace('\', '/')
            return $Content.Replace('{{FRAMEWORK_PATH}}', $normalized)
        }
        'none' {
            return $Content
        }
        default {
            throw "未知的 transform: $TransformName"
        }
    }
}

# ----------------------------------------------------------------------------
# 檔案部署核心
# ----------------------------------------------------------------------------

function Get-FileMtime {
    param([Parameter(Mandatory)][string] $Path)
    if (-not (Test-Path $Path)) { return $null }
    (Get-Item $Path).LastWriteTimeUtc.ToString('o')
}

function Deploy-Item {
    <#
    .DESCRIPTION
    部署單一 item：
      - Read source、套 transform
      - 寫到 dest（必要時建立資料夾）
      - 回傳 deploy result（給 manifest 記錄用）
    #>
    param(
        [Parameter(Mandatory)] $Item,
        [Parameter(Mandatory)][string] $FrameworkRoot,
        [Parameter(Mandatory)][string] $ClaudeRoot,
        [switch] $DryRun,
        [switch] $Force
    )

    $srcPath = Join-Path $FrameworkRoot $Item.src
    $dstPath = Join-Path $ClaudeRoot $Item.dst

    if (-not (Test-Path $srcPath)) {
        Write-Warning "  ✗ source 不存在: $($Item.src)"
        return $null
    }

    $dstDir = Split-Path -Parent $dstPath
    if (-not (Test-Path $dstDir)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
    }

    # 衝突偵測（dest 已存在且不在 manifest 中 → user 自己放的，要小心）
    $existing = Test-Path $dstPath
    if ($existing -and -not $Force) {
        $manifest = Read-Manifest
        $tracked = $false
        if ($null -ne $manifest -and $null -ne $manifest.files) {
            $tracked = [bool]($manifest.files | Where-Object { $_.id -eq $Item.id })
        }
        if (-not $tracked) {
            Write-Warning "  ! dest 已存在且非本框架部署: $($Item.dst)（用 -Force 覆蓋）"
            return $null
        }
    }

    if ($DryRun) {
        Write-Host "  [dry-run] $($Item.src) → $($Item.dst)"
        return $null
    }

    # Read → transform → Write
    $content = Get-Content -Path $srcPath -Raw -Encoding UTF8
    $transformed = Invoke-Transform -Content $content -TransformName $Item.transform -FrameworkRoot $FrameworkRoot
    Set-Content -Path $dstPath -Value $transformed -Encoding UTF8 -NoNewline

    Write-Host "  ✓ $($Item.src) → $($Item.dst)" -ForegroundColor Green

    [pscustomobject]@{
        id            = $Item.id
        type          = $Item.type
        src           = $Item.src
        dst           = $Item.dst
        transform     = $Item.transform
        sourceMtime   = (Get-FileMtime $srcPath)
        deployedMtime = (Get-FileMtime $dstPath)
        deployedAt    = (Get-Date).ToString('o')
    }
}

function Remove-DeployedItem {
    param(
        [Parameter(Mandatory)] $Entry,
        [Parameter(Mandatory)][string] $ClaudeRoot,
        [switch] $DryRun
    )
    $dstPath = Join-Path $ClaudeRoot $Entry.dst
    if (-not (Test-Path $dstPath)) {
        Write-Host "  - 已不存在: $($Entry.dst)" -ForegroundColor DarkGray
        return
    }
    # 偵測使用者是否改過：deployedMtime 與當前 mtime 不一致
    $currentMtime = Get-FileMtime $dstPath
    if ($Entry.deployedMtime -and $currentMtime -ne $Entry.deployedMtime) {
        Write-Warning "  ! 你修改過 $($Entry.dst)，跳過（手動處理）"
        return
    }
    if ($DryRun) {
        Write-Host "  [dry-run] 刪除 $($Entry.dst)"
        return
    }
    Remove-Item -Path $dstPath -Force
    Write-Host "  ✓ 已刪除 $($Entry.dst)" -ForegroundColor Green
}

# ----------------------------------------------------------------------------
# 顯示
# ----------------------------------------------------------------------------

function Write-Header {
    param([string] $Title)
    Write-Host ''
    Write-Host "═══ $Title ═══" -ForegroundColor Cyan
}

function Write-Summary {
    param([int] $Ok, [int] $Skipped, [int] $Failed)
    Write-Host ''
    Write-Host "完成：成功 $Ok / 跳過 $Skipped / 失敗 $Failed" -ForegroundColor Cyan
}
