---
title: 引入 Andrej Karpathy 四原則至 LLMDevFramework
status: shipped
created: 2026-05-20
updated: 2026-05-20
modules: [llmdevframework]
---

# Karpathy Guidelines Import

## Summary

將 Andrej Karpathy 觀察 LLM 編碼常見陷阱所提出的四原則（Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven Execution）整合進 LLMDevFramework，產出：
1. `karpathy-guidelines/CLAUDE.md`：永久守則，讓 Claude 在 LLMDevFramework 內工作時自動遵守
2. `~/.claude/commands/karpathy-guidelines.md`：slash command，在任意專案中可以 `/karpathy-guidelines` 觸發對話前的原則審閱

## Motivation / Why

LLMDevFramework 是 Claude Code 全局守則的源頭，適合整合通用行為原則。Karpathy 四原則與現有 `~/.claude/CLAUDE.md` 全域風格（「不做多餘的事、只在 WHY 不明顯時寫 comment」）高度一致，應系統化整合而非各專案重複貼上。

## Scope

### In Scope

- 建立 `karpathy-guidelines/` 子目錄及 `CLAUDE.md`（四原則，中文化，符合框架文件風格）
- 建立 `karpathy-guidelines/karpathy-guidelines-command.md`（slash command 原始內容）
- 安裝 slash command 到 `~/.claude/commands/karpathy-guidelines.md`
- 更新 LLMDevFramework 根目錄 `CLAUDE.md` 的 `<file_map>` 區塊加入新子目錄

### Out of Scope

- 修改各技術棧子目錄的 CLAUDE.md（OracleSQL、React & Typescript 等）
- 修改 `~/.claude/CLAUDE.md` 全域設定（僅新增 command，不改現有內容）
- 自動在所有專案中強制套用（使用者需手動 `/karpathy-guidelines` 觸發）

## User Stories / Use Cases

1. As a developer using LLMDevFramework，I want Claude to automatically follow the four Karpathy principles when helping me write framework docs, so that the guidelines produced are minimal, precise, and assumption-free.
2. As a developer in any project, I want to run `/karpathy-guidelines` before a non-trivial task, so that Claude reviews the upcoming work against the four principles and surfaces assumptions before coding.

## Acceptance Criteria

- [ ] `karpathy-guidelines/CLAUDE.md` 存在，包含四原則，使用 XML tag 結構，繁體中文，100–200 行
- [ ] 四原則有具體 good/bad 對照範例（non-functional 原則不是只有文字描述）
- [ ] 原則與 `~/.claude/CLAUDE.md` 全域規則無逐字重複（互補而非 copy-paste）
- [ ] `karpathy-guidelines/karpathy-guidelines-command.md` 存在，可複製為 slash command
- [ ] `~/.claude/commands/karpathy-guidelines.md` 安裝完成，`/karpathy-guidelines` 可觸發
- [ ] Slash command 有 role assignment、CoT 觸發、pre-fill 回報格式
- [ ] LLMDevFramework 根目錄 `CLAUDE.md` `<file_map>` 中有 `karpathy-guidelines/` 條目
- [ ] 對照 `prompt-principles/CLAUDE.md` self-check 的相關項目通過

## Module Interactions

- **LLMDevFramework**：新增 `karpathy-guidelines/` 子目錄（比照 `sdd/`、`OracleSQL/` 模式）
- **~/.claude/commands/**：安裝 slash command 檔案（比照 sdd-command.md 的安裝模式）
- **無 DB / Backend / Frontend 涉及**

## API Design

不適用（純文件 / prompt 工程）。

Slash command 介面：

```
/karpathy-guidelines [可選：任務描述]
```

觸發後，Claude 會依四原則對即將開始的任務做一輪 pre-flight 審閱，輸出格式：

```
## Karpathy Pre-Flight
- Think Before Coding：<假設盤點 / 需要釐清的問題>
- Simplicity First：<範圍確認 / scope creep 風險>
- Surgical Changes：<影響範圍評估>
- Goal-Driven Execution：<可驗證的成功標準草稿>
```

## Data Model

不適用。

## Edge Cases & Error Handling

- 四原則與現有全域 CLAUDE.md 規則衝突 → 以「最嚴格的那條」為準，不重複列出相同規則，僅在 `karpathy-guidelines/CLAUDE.md` 用 cross-reference 指向全域設定
- 使用者在 trivial 任務（typo 修正、樣式微調）觸發 `/karpathy-guidelines` → slash command 內需有 hatch 說明可跳過，不強制跑完整流程
- Slash command 被複製到 `~/.claude/commands/` 但規則描述已過時 → `karpathy-guidelines/CLAUDE.md` 是 source of truth，command 需指引使用者定期與原始碼同步

## Non-Functional Requirements

- **Readability**：每個原則的 bad/good 對照讓不熟 Karpathy 的讀者 5 分鐘看懂
- **Maintainability**：`karpathy-guidelines/CLAUDE.md` 不超過 200 行（LLMDevFramework 規範）
- **Consistency**：文件風格（XML tag、MUST/NEVER、三段式規則）與其他子目錄一致

## Open Questions

- [x] Slash command 名稱：決定用 `kg`（縮寫），安裝路徑 `~/.claude/commands/kg.md`

## Implementation Plan

### Stub 階段（先做）

- [ ] 建立 `karpathy-guidelines/` 目錄
- [ ] 建立 `karpathy-guidelines/CLAUDE.md`（空殼：frontmatter tag + 各 section 標題，內容留 TODO）
- [ ] 建立 `karpathy-guidelines/karpathy-guidelines-command.md`（空殼：role + TODO）
- [ ] 更新根目錄 `CLAUDE.md` `<file_map>` 加入 `karpathy-guidelines/` 條目
- [ ] 確認目錄結構正確

### 逐層實作

- [ ] 撰寫 `karpathy-guidelines/CLAUDE.md` 完整四原則（中文化、good/bad 對照）
- [ ] 對照 `prompt-principles/self-check.md` 跑 self-check
- [ ] 撰寫 `karpathy-guidelines-command.md`（role、四原則 checklist、pre-fill 輸出格式）
- [ ] 安裝 slash command 到 `~/.claude/commands/karpathy-guidelines.md`
- [ ] 對照 Acceptance Criteria 逐條驗收

## References

- 來源 repo：https://github.com/multica-ai/andrej-karpathy-skills
- 方法論風格參考：`prompt-principles/CLAUDE.md`
- 安裝模式參考：`sdd/CLAUDE.md`（`sdd-command.md` → `~/.claude/commands/sdd.md`）
