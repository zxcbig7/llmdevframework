---
title: 建立 PowerShell 腳本 domain（與 CMD Developer 並列）
status: shipped
created: 2026-06-06
updated: 2026-06-06
modules: [llmdevframework]
---

# PowerShell Scripting Domain

## Summary

新增 `PowerShell/` domain，制定 `.ps1` 腳本開發規範（execution policy、編碼/BOM、**亂碼與 CRLF 防治**、
版本差異、pipeline/物件思維），與現有 CMD Developer（`.bat`）**並列為 sibling**，並提供
「`.bat` vs `.ps1` 何時用哪個」選用決策。預留掛進 Item 0 Router，讓 `.ps1` 自動套用此規範。

## Motivation / Why

- PowerShell 是使用者預設 shell（全域偏好「CLI 預設 PowerShell」），框架的部署腳本
  （`install/update/uninstall.ps1`）全是 `.ps1`，卻無規範。
- CMD Developer 已蓋 `.bat`，但 `.ps1` 是**不同語言**（物件 pipeline、cmdlet），需獨立規範。
- 繁中環境的**編碼亂碼 + BOM + CRLF** 是反覆踩的坑（`scripts/README.md` 已記錄 5.1 BOM 問題），
  必須 codify 成硬規則，而非靠記憶。

## Scope

### In Scope

- 建 `PowerShell/CLAUDE.md`（`.ps1` 專屬規範，100–200 行）
- 「`.bat` vs `.ps1` 選用決策」表（放 `PowerShell/CLAUDE.md` 內）
- **編碼**（UTF-8 BOM 規則、亂碼防治）與 **CRLF 一致性**（`.gitattributes`）列為硬規則
- 更新 root `CLAUDE.md` `<file_map>` 加 `PowerShell/`
- 預留 Item 0 Router 條目（`.ps1` → `PowerShell/CLAUDE.md`）

### Out of Scope

- 不改 `CMD Developer/CLAUDE.md` 正文（僅加一行 cross-ref 指向選用決策）→ 維持 `/cmd-dev` 不變
- 不做跨平台 PowerShell 7 on Linux（先 **Windows-only**）
- 不實作 Item 0 Router 本身（只預留路由表條目）
- 不採 B（合併成 `Windows Scripting/`）；採 **A 並列**
- `/ps-dev` 指令本次**先不做**（見 Open Questions，先出規範，指令日後再補）

## User Stories / Use Cases

1. As Vic，我在寫 `.ps1` 時想要 Claude 自動套 PowerShell 規範（含編碼/CRLF 防治），so that 不再踩亂碼與 5.1 解析失敗的坑。
2. As Vic，面對一個自動化需求，想要快速判斷該寫 `.bat` 還是 `.ps1`，so that 選對工具不返工。
3. As 任何使用框架的人，未來 `.ps1` 一進 context 就自動路由到此 domain，so that 不必手動下指令。

## Acceptance Criteria

- [ ] `PowerShell/CLAUDE.md` 存在，100–200 行，XML tag 結構、繁中、MUST/NEVER 三段式
- [ ] 涵蓋 `.ps1` 專屬雷區：execution policy、編碼/BOM、亂碼防治、CRLF、`$ErrorActionPreference`、pipeline/物件 vs 文字、path/引號、5.1 vs 7+ 差異
- [ ] **編碼規則明確**：含非 ASCII 的 `.ps1` 存 **UTF-8 with BOM**（相容 5.1）；`Get-/Set-Content` 明確 `-Encoding`；console 亂碼處理（`chcp 65001` / `[Console]::OutputEncoding`）
- [ ] **CRLF 規則明確**：`.gitattributes` 標 `*.ps1 *.bat text eol=crlf`；說明 `core.autocrlf` 風險
- [ ] 有「`.bat` vs `.ps1` 選用決策」表
- [ ] 與 CMD Developer **無逐字重複**（共通坑用 cross-ref）
- [ ] root `CLAUDE.md` `<file_map>` 有 `PowerShell/` 條目
- [ ] **`/cmd-dev` 行為不受影響**（回歸確認）
- [ ] Router 表預留 `.ps1` 條目（待 Item 0 接上）
- [ ] 對照 `prompt-principles/CLAUDE.md` self-check 通過

## Module Interactions

- **LLMDevFramework**：新增 `PowerShell/` 子目錄（比照 `CMD Developer/`）
- **CMD Developer/**：僅加一行 cross-ref（選用決策），正文不動
- **root CLAUDE.md**：`<file_map>` 加條目
- **Item 0 Router 表**：預留 `.ps1` → `PowerShell/CLAUDE.md`（Item 0 執行時接上）
- **無 frontend / backend / DB 涉及**

## API Design

不適用（純文件 / prompt 工程）。`/ps-dev` 指令本次不做；日後若做，介面比照
`CMD Developer/cmd-dev-command.md`：`/ps-dev [write|review|debug] [檔案/描述]`。

## Data Model

不適用。

## Edge Cases & Error Handling

- **繁中 `.ps1` 存成 UTF-8 無 BOM** → PS 5.1 解析亂碼/失敗 → 規則：非 ASCII 一律 UTF-8 **with BOM**；
  用 Write tool 重存會掉 BOM → 補救 `Set-Content -Encoding utf8BOM`（或 `$c=Get-Content -Raw -Encoding UTF8; Set-Content -Encoding utf8BOM`）
- **console 輸出中文亂碼** → `chcp 65001` + `[Console]::OutputEncoding = [Text.Encoding]::UTF8`
- **檔案被 git LF 化**（`core.autocrlf` / Linux clone）→ `.bat` 可能執行異常 → `.gitattributes` `eol=crlf` 鎖定
- **execution policy Restricted** → `.ps1` 跑不了 → fallback：互動式貼指令 / `-ExecutionPolicy Bypass` 的取捨與風險（比照 `MANUAL-INSTALL.md` 思路）
- **5.1 不支援的語法**（`?.`、三元 `? :`、`ForEach-Object -Parallel`）在 7+ 才有 → 規範標「目標版本」避免誤用
- **選用決策邊界**：簡單一次性/相容性優先 → `.bat`；要物件、結構化錯誤處理、REST、JSON → `.ps1`

## Non-Functional Requirements

- **Readability**：選用決策 + 編碼/CRLF 規則讓人 5 分鐘上手
- **Maintainability**：≤200 行；共通坑 cross-ref 不重複
- **Consistency**：文件風格與 CMD Developer 對稱（雷區式編排）
- **Compatibility**：預設相容 Windows PowerShell **5.1**（最低標），標注 7+ 專屬語法

## Open Questions（已拍板 2026-06-06）

- [x] `/ps-dev` **不做** → 改靠 Item 0 Router 偵測 `.ps1` 自動載入此規範（少一個手動指令，貼合「越少手動判斷」原則）
- [x] 選用決策**放 `PowerShell/CLAUDE.md` 內**（單檔、DRY）；CMD Developer 端用 cross-ref 一行指過來

## Implementation Plan

### Stub 階段（先做）

- [x] 建 `PowerShell/` 目錄
- [x] 建 `PowerShell/CLAUDE.md` 空殼（frontmatter tag + 各 section 標題 + `TODO`）
- [x] 更新 root `CLAUDE.md` `<file_map>` 加 `PowerShell/` 條目（順手補漏列的 CMD Developer）
- [x] 確認目錄結構

### 逐層實作

- [x] 寫 `PowerShell/CLAUDE.md` 正文（雷區、編碼/CRLF、選用決策、版本差異）
- [x] 跑 `prompt-principles` self-check（移除與 fatal_implications 重複且缺 ALWAYS 的 iex 條）
- [x] `CMD Developer/CLAUDE.md` 加 cross-ref 一行（指向選用決策）
- [x] 更新 `CodeMap.md`（File Index 加 PowerShell 行 + Dependency Graph 節點 + Coverage Assessment）
- [x] 對照 Acceptance Criteria 逐條驗收

## References

- 對稱 domain：`CMD Developer/CLAUDE.md`（`/cmd-dev`）
- 編碼坑來源：`scripts/README.md`（UTF-8 BOM 警告）、`scripts/MANUAL-INSTALL.md`（execution policy fallback）
- 安裝/文件模式：`specs/2026-05-20-karpathy-guidelines-import.md`
- 上層整合：`specs/2026-06-06-framework-expansion-backlog.md`（Item 0 Router、Item 3 P1）
- 文件風格：`prompt-principles/CLAUDE.md`
