<#
.SYNOPSIS
  從 .mmd 或 .md 匯出 Mermaid 圖檔。mmdc 優先，無 Node 時 fallback 到 Kroki API。
.EXAMPLE
  ./render-mermaid.ps1 -InputPath diagram.mmd -Format svg
  ./render-mermaid.ps1 -InputPath notes.md -Format png -Scale 2
  ./render-mermaid.ps1 -InputPath diagram.mmd -UseKroki   # 強制走 Kroki
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$InputPath,
  [ValidateSet('svg','png')][string]$Format = 'svg',
  [int]$Scale = 2,
  [string]$KrokiUrl = 'https://kroki.io',
  [switch]$UseKroki
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $InputPath)) { throw "找不到輸入檔：$InputPath" }
$item = Get-Item $InputPath
$base = [IO.Path]::Combine($item.DirectoryName, $item.BaseName)
$out  = "$base.$Format"

$hasMmdc = $null -ne (Get-Command mmdc -ErrorAction SilentlyContinue)

# --- mmdc 路徑（支援 .md 多區塊）---
if ($hasMmdc -and -not $UseKroki) {
  Write-Host "→ 用 mmdc 渲染 $InputPath" -ForegroundColor Cyan
  $args = @('-i', $InputPath, '-o', $out, '-b', 'transparent')
  if ($Format -eq 'png') { $args += @('-s', "$Scale") }
  & mmdc @args
  Write-Host "✓ 輸出：$out" -ForegroundColor Green
  return
}

# --- Kroki fallback（只吃單一 .mmd）---
if ($item.Extension -eq '.md') {
  throw "Kroki fallback 不支援 .md 多區塊；請先裝 mmdc（npm i -g @mermaid-js/mermaid-cli），或把單張圖存成 .mmd"
}

Write-Host "→ mmdc 不存在，改用 Kroki：$KrokiUrl" -ForegroundColor Yellow
$src = Get-Content $InputPath -Raw
$uri = "$KrokiUrl/mermaid/$Format"
try {
  Invoke-WebRequest -Uri $uri -Method Post -Body $src -ContentType 'text/plain' -OutFile $out
  Write-Host "✓ 輸出：$out" -ForegroundColor Green
} catch {
  throw "Kroki 渲染失敗（$uri）：$($_.Exception.Message)。檢查網路 / 改自架 Kroki / 改裝 mmdc。"
}
