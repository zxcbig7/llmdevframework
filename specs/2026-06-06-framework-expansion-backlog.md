---
title: 框架對帳 + 三項擴充（術語不亂猜 / Code 整合 / 全端缺口）待辦規格
status: draft
created: 2026-06-06
updated: 2026-06-06
modules: [llmdevframework]
---

# Framework Expansion Backlog

> 一份「待辦規格書」，不是單一功能。內含 1 個前置對帳 + 3 個擴充項，
> 每項可獨立執行。等有額度時，挑一項 → 走該項 Implementation Plan → 收尾更新 CodeMap。
> **執行前先讀 `prompt-principles/CLAUDE.md` 跑 self-check（root critical_note）。**

## Summary

盤點 LLMDevFramework source 與已安裝的 `~/.claude/` 之間的落差（drift），並把先前討論的三件事
（① 術語不亂猜 ② 公司 SQL/.bat code 整合 ③ 全端一天工作流缺口）登錄為可執行的 backlog。
目的：先有一份對齊現況、不重複既有能力的施工藍圖，再分批動工。

## Motivation / Why

- 框架是「跨 session 的權威源頭」，但 source ↔ `.claude` 已 drift（漏裝、孤兒、無 source 的指令），
  不先對帳就擴充，會在歪掉的地基上加東西。
- 三件事都是「天天踩 / 眼前業務」的真實需求，口頭討論 ≠ 規格（SDD `<fatal_implications>`），先落檔。
- 一次寫清楚範圍與驗收條件，之後執行時不必重新發想，省額度。

## Scope

### In Scope

- Item 0：自適應 Distribution 重設計（整包進 `.claude` + Router 自動讀 + Scaffolder 自動寫）← 最上層、吸收原 Phase 0
- Phase 0：框架 ↔ `.claude` 對帳（併入 Item 0 的安裝層執行）
- Item 1：術語不亂猜（Glossary domain + `/term` + 行為守則）
- Item 2：Code 整合 playbook（Code Integration domain + `/code-merge`）
- Item 3：全端工作流缺口 roadmap（登錄為未來 domain 的優先序 backlog）

### Out of Scope（本次只寫規格，不實作）

- 不寫任何 domain CLAUDE.md 正文、不建 slash command、不改 deploy.config.json
- 不修 drift（只登錄，執行階段才動手）
- 不更新 root CodeMap（各 Item 執行完才同步）

---

## Item 0 — 自適應 Distribution 重設計（最上層）

### Summary

讓整包框架「無腦放進 `~/.claude/` 就能用」：①整包進 `.claude`（路徑固定）→ ②全域 Router
自動依語言讀對的 domain 規範 → ③Scaffolder 半自動把 CLAUDE.md 寫進各專案 / 技術獨立的子資料夾。
目標：在**任何專案**工作時，框架自己知道該套哪個語言的規範，使用者不必手動挑 `/cmd-dev`、`/ps-dev`。

### 三層設計

| 層 | 目標對應 | 機制 |
|---|---|---|
| **安裝層 Install** | 整包無腦放 `.claude` 就能用 | 整個框架同步進 `~/.claude/llmdevframework/`，路徑固定（解掉現在 `{{FRAMEWORK_PATH}}` 偵測）；順手吸收原 Phase 0 對帳 |
| **Router 層** | 自動「抓」對的語言規範 | 全域 `~/.claude/CLAUDE.md` 放語言路由表（副檔名 + 專案特徵 → domain），每 session 必載，Claude 照表去讀 `~/.claude/llmdevframework/<domain>/CLAUDE.md` |
| **Scaffolder 層** | 自動「寫」CLAUDE.md 到各專案 / 子資料夾 | `/scaffold` 指令：偵測技術棧 → **若無 CLAUDE.md** → 列出將寫的檔給使用者確認 → 寫精簡 CLAUDE.md（reference 框架、不複製）+ 產 CodeMap；子資料夾只在技術獨立時補 nested CLAUDE.md |

### 決策鎖定（2026-06-06）

- **自動寫模式 = 半自動 + 寫前確認**：偵測到專案沒 CLAUDE.md 才動作，寫前列清單、使用者點頭才寫
- **不使用 hook** → 不撞公司 execution policy 鎖定；靠 `/scaffold` 手動觸發
- **不覆蓋既有 CLAUDE.md**：偵測到就跳過或詢問
- per-project CLAUDE.md 一律 **reference 指回框架**，框架一改全專案同步（DRY）

### 實作結果（2026-06-06 · 大部分 shipped）

**✅ 已上線**
- Router 區塊注入 `~/.claude/CLAUDE.md`（marker 包夾、append、不動既有 Vic's Global Preferences）→ **自動 dispatch 生效**
- `/scaffold`、`/cmd-dev`、`/kg` 裝進 `~/.claude/commands/`（deploy.config 已登錄 `cmd-kg`、`cmd-scaffold`）
- 修好 4 個既有指令 stale 路徑：`sdd`/`k8s-review`/`prompt-improve`/`proc-analyze` 從 `MyDevWeb` → `Projects`
- `router/` source 五件套（CLAUDE.md、global-claude-block、scaffold-command、project/subfolder 模板）

**⚠️ 與原規劃差異（誠實記錄）**
- **未整包 copy 進 `~/.claude/llmdevframework/`**：bulk copy 被 permission 擋下，且複製會製造 source-of-truth drift。改為 **Router 直接指向實際框架 `C:/Users/zxcbi/Desktop/Projects/LLMDevFramework`** → 達成自動 dispatch 目標 + 維持單一真相。要真正可攜（換電腦）再用 `install.ps1` 搬整包並 repoint。

**⏳ 待補（非阻塞）**
- `scripts/lib.ps1` 自動化：tree-copy + Router 注入 transform（本輪手動執行）
- `deploy.config.json` 的 `type: skill`（mermaid-diagrams / slide-builder 仍需手動裝）
- `write-tutorial`/`research-note`/`code-review` 三個無 source 指令的去留決議

### 路由表（涵蓋現有 + 待建）

| 偵測訊號 | 路由到 |
|---|---|
| `.sql` / PL/SQL | `OracleSQL/CLAUDE.md` |
| `.bat` / `.cmd` | `CMD Developer/CLAUDE.md` |
| `.ps1` | `PowerShell/CLAUDE.md`（Item 3 P1，待建） |
| `.tsx` / `.ts` + `package.json` | `React & Typescript/CLAUDE.md` |
| `.cs` + `.csproj` | `.Net Web API/CLAUDE.md` |
| `.yaml`（k8s/helm/argo/gha） | `YAML Review/CLAUDE.md` |
| `.mmd` / mermaid | `Mermaid Diagrams/` skill |

### Dispatch 擴充：任務 → skill（不只語言 → domain）

Router 不只「副檔名 → domain」，也涵蓋「任務情境 → 該用哪個 skill/command」，由 Claude **主動判斷套用**，
不要求使用者手動挑。行為規則（寫進全域 `~/.claude/CLAUDE.md`）：

> **主動 dispatch**：偵測到對應情境就自套對的 skill/domain，並在回覆用一句話說「用了什麼、為什麼」；
> 只有「真正分岔且影響大」（架構選型、會動既有 code、有外部副作用、approve production 變更）才問使用者，其餘自行決定。

任務 → skill 對照（節錄）：

| 情境 | 自動套用 |
|---|---|
| 非 trivial 新功能 | `/sdd` |
| 任務模糊 / 編碼前 | `/kg` pre-flight |
| 「看 code / review」 | `code-review`（先產 CodeMap） |
| 10K+ 行 PL/SQL | `/proc-analyze` |
| 改 K8s/Helm/ArgoCD/GHA yaml | `/k8s-review` |
| 要畫圖 | `mermaid-diagrams`（待裝） |
| 做投影片 / 網頁 deck | `guizang-ppt-skill` |

### Deliverables

- **安裝層**：`scripts/` 部署模型升級——`deploy.config.json` + `lib.ps1` 從「只裝 commands」擴成「整包同步 domain 樹 + skill」進 `~/.claude/llmdevframework/`；路徑改固定值
- **Router 層**：框架內 `router/router-table.md`（單一真相）+ 部署時注入全域 `~/.claude/CLAUDE.md` 的 Router 區塊（小心不蓋掉既有 Vic's Global Preferences）
- **Scaffolder 層**：`router/scaffold-command.md`（`/scaffold` source）+ `router/project-claude-template.md` + `router/subfolder-claude-template.md`
- root `CLAUDE.md` `<file_map>` 加 `router/`
- 吸收原 Phase 0 對帳修復項（見下節）

### Acceptance Criteria

- [ ] 整包同步進 `~/.claude/llmdevframework/`，路徑固定、不需偵測 Desktop
- [ ] 全域 CLAUDE.md 有 Router 表；碰到 `.sql/.bat/.ps1/.cs/.tsx/.yaml` 會自動去讀對應 domain（不必手動下指令）
- [ ] `/scaffold` 能偵測技術棧 → 列將寫清單 → 確認後寫 root + 選擇性 nested CLAUDE.md（reference 框架）+ 產 CodeMap
- [ ] `/scaffold` 偵測到既有 CLAUDE.md 時不覆蓋（跳過或詢問）
- [ ] 全程不依賴 hook（execution policy 鎖死也能用）
- [ ] 注入全域 CLAUDE.md 的 Router 區塊不破壞既有內容（可重複執行、idempotent）

### Dependencies

- Router 表要指到 `PowerShell/` 與 `Git Workflow/`（Item 3 P1）→ 兩者建好前，表內標 TODO；router 可先用現有 domain 上線，新 domain 完成再補表

### Open Questions

- [ ] 開發 / 安裝關係：Desktop 繼續當開發源、`install/update` 同步整包進 `.claude`（建議，延伸現有 `update.ps1`）vs 直接在 `.claude` 內開發？
- [ ] Scaffold 子資料夾粒度：只 root 一個 vs root + 技術獨立子資料夾（建議後者但保守，先只在明顯技術獨立的資料夾如 `sql/`、`scripts/`、`frontend/`）
- [ ] 全域 CLAUDE.md 的 Router 區塊由 install 自動注入/更新，怎麼標界線（如 `<!-- LLMDEVFRAMEWORK:ROUTER START/END -->`）才能安全 idempotent？

---

## Phase 0 — 框架 ↔ `.claude` 對帳與整合（併入 Item 0 安裝層）

### 對帳結果（2026-06-06 快照）

| 指令 / skill | 框架 source | deploy.config | `.claude` 實際 | 處置 |
|---|---|---|---|---|
| sdd / k8s-review / proc-analyze / prompt-improve | ✅ | ✅ | ✅ | 無 |
| **cmd-dev** | ✅ `CMD Developer/cmd-dev-command.md` | ✅ 已登錄 | ❌ 未安裝 | 跑 `update.ps1` 補裝；查為何漏 |
| **kg** | ✅ `karpathy-guidelines/karpathy-guidelines-command.md` | ❌ 未登錄 | ✅ 已裝 | 補登 deploy.config（納入 update/uninstall 管理）|
| **write-tutorial** | ❌ 無 | ❌ | ✅ 已裝 | 二選一：回灌成框架 source / 在 README 標為框架外 |
| **research-note** | ❌ 無 | ❌ | ✅ 已裝 | 同上 |
| **code-review** | ❌ 無（CodeMap 提到 skill，但無 command source）| ❌ | ✅ 已裝 | 釐清來源（內建？手動？），決定去留 |
| **mermaid-diagrams（skill）** | ✅ `Mermaid Diagrams/SKILL.md` | ❌ deploy 只支援 `type: command` | ❓ 未見於 `.claude/skills` | deploy.config 擴充 `type: skill` 或記錄為手動 |
| **slide-builder（skill）** | ✅ `Slide Builder/SKILL.md` | ❌ | ❓ 同上 | 同上 |
| guizang-ppt-skill | ❌（外部 git clone）| ❌ | ✅ 已 clone | 外部依賴，在 README 記錄來源即可 |

### Tasks

- [ ] 補裝 `cmd-dev`：`cd scripts; .\update.ps1 -DryRun` 確認，再正式跑
- [ ] `kg` 補進 `deploy.config.json` 的 items（id `cmd-kg`，src `karpathy-guidelines/karpathy-guidelines-command.md`，dst `commands/kg.md`）
- [ ] 處置 `write-tutorial` / `research-note` / `code-review`：回灌 source 或在 `scripts/README.md` 新增「框架外指令」清單記錄
- [ ] `deploy.config.json` + `lib.ps1` 擴充 `type: skill`（src 指向 SKILL.md 所在目錄，dst `skills/<name>/`），讓 mermaid-diagrams / slide-builder 可被部署管理
- [ ] scripts/ 加「對帳」能力：一個 `doctor` 模式或 README checklist，列出 source vs deploy.config vs `.claude` 三方差異
- [ ] CodeMap 補一張「框架 ↔ `.claude` 對應表」反映真實安裝狀態

### Acceptance Criteria

- [ ] `deploy.config.json` 與 `~/.claude/commands/` 完全對齊（無漏裝、無 manifest 外孤兒）
- [ ] 每個 `~/.claude/commands/*.md` 都能追溯到框架 source，或被明確標記為框架外
- [ ] skill 類型有部署管道，或在文件明確記錄為手動安裝
- [ ] CodeMap 反映真實安裝狀態

---

## Item 1 — 術語不亂猜（Glossary / Terminology Guardrail）

### Summary

讓 Claude 在任何專案、任何時候，遇到不確定的專有名詞 / 縮寫 / 系統代號 / 欄位表名 /
業務術語時，**不臆測**，而是標記、彙整、一次問使用者，確認後寫進可持久化的術語表，避免重問。

### 三層設計

- **Layer 1 行為守則**（永遠載入）
  > NEVER 自創或臆測專有名詞、縮寫、系統代號、欄位/表名、業務術語 — ALWAYS 標
  > `⚠️UNKNOWN: <原文>` 收集成清單，一次問使用者，確認後寫進該專案 `docs/glossary.md` —
  > Why: 錯的術語會擴散進文件與 code，事後極難回收
- **Layer 2 持久化術語表**：`docs/glossary.md`（每專案），欄位 `術語 | 全稱 | 定義 | 來源 | 確認日`；已確認的下次直接查、不重問
- **Layer 3 觸發指令 `/term`**：掃一份文件 / 一段 code → 抽候選術語 → 比對既有 glossary →
  未知的批次列表問（不逐個打斷）→ 使用者確認 → 寫回術語表 → 回報已記錄項

### Deliverables

- `Glossary/CLAUDE.md`（domain 規範：三段式守則 + `⚠️UNKNOWN` 標記格式 + 術語表 schema + `/term` 流程）
- `Glossary/glossary-template.md`（術語表模板）
- `Glossary/term-command.md`（`/term` slash command source）
- `deploy.config.json` 新增 `cmd-term`
- root `CLAUDE.md`：`<critical_notes>` 加「不猜術語」、`<file_map>` 加 `Glossary/`

### `/term` 互動流程

1. 吃輸入：檔案路徑 / 資料夾 / 編輯器選取
2. 抽候選：縮寫、英數代號、非通用名詞、未定義的大寫詞
3. 比對既有 `docs/glossary.md`，已知略過
4. 未知項批次列出問使用者（一次問完）
5. 使用者確認 → 寫進 glossary（含來源檔、確認日）
6. 回報：本次新增 N 筆、仍待確認 M 筆

### Acceptance Criteria

- [ ] `Glossary/CLAUDE.md` 存在，含三段式守則 + `⚠️UNKNOWN` 標記格式 + 術語表 schema，100–200 行
- [ ] `/term` 能掃文件、列未知詞、批次問、寫回術語表，且已知詞不重問
- [ ] `glossary-template.md` 欄位齊全（術語 / 全稱 / 定義 / 來源 / 確認日）
- [ ] root `CLAUDE.md` 有「不猜術語」critical_note，`<file_map>` 有 `Glossary/`
- [ ] 對照 `prompt-principles` self-check 通過

### Open Questions

- [ ] 要不要同時寫進 `~/.claude/CLAUDE.md` 讓**所有專案無腦全域生效**？（vs 只當框架能力 opt-in）
- [ ] 術語表位置：每專案 `docs/glossary.md`（建議）vs 框架集中？跨專案共用術語另設一份？
- [ ] 「候選術語」抽取規則要多嚴？太鬆會狂問、太緊會漏（建議：縮寫 + 代號優先，通用英文詞放過）

---

## Item 2 — Code 整合 Playbook（Code Integration）

### Summary

把公司散落的 SQL / `.bat`（未來含 PowerShell）code 整合的標準流程 codify 成 orchestrator domain：
拿到一坨檔案，**先盤點→依賴圖→評估，再決定怎麼搬**，而不是上來就改。串接既有
`/proc-analyze`、`/cmd-dev`、CodeMap、Mermaid、`/sdd`。

### 整合 6 步流程

1. **盤點 Inventory**：掃目標資料夾，列出所有 `.sql/.bat/.ps1`，每檔用途、輸入/輸出、呼叫對象 → inventory 表
2. **分類去重 Classify & Dedup**：依功能分組，標出重複 / 近似邏輯
3. **依賴圖 Dependency Graph**：Mermaid 畫跨檔 / 跨 schema 依賴，標 entry points
4. **標準化評估 Standardize**：對照 `OracleSQL` / `CMD Developer` /（未來）PowerShell 規範，列不合規處
5. **遷移規格 Migration Spec**：走 `/sdd` 出規格（搬到哪、命名、目錄、相容期、回退方案）
6. **逐檔搬 + 驗收 Migrate**：一檔一檔搬，對照規格 acceptance

> 單一大型檔 hand-off：SQL → `/proc-analyze`、`.bat` → `/cmd-dev`。

### Deliverables

- `Code Integration/CLAUDE.md`（6 步流程 + 明確 hand-off 既有指令 + NEVER 先改 code 守則）
- `Code Integration/inventory-template.md`（盤點表：`檔名 | 類型 | 用途 | I/O | 呼叫對象 | 重複度 | 處置`）
- `Code Integration/code-merge-command.md`（`/code-merge` source）
- `deploy.config.json` 新增 `cmd-code-merge`
- root `CLAUDE.md` `<file_map>` 加 `Code Integration/`

### Acceptance Criteria

- [ ] `Code Integration/CLAUDE.md` 定義 6 步流程，明確標出 hand-off 給 `/proc-analyze`、`/cmd-dev`
- [ ] `inventory-template.md` 欄位可直接填
- [ ] `/code-merge` 給一個資料夾路徑 → 產出 inventory 表 + 依賴圖 + 不合規清單，並**停在**「要不要進 `/sdd` 遷移規格」這一步
- [ ] 守則含：NEVER 在盤點 + 依賴圖完成前改任何 code（呼應 SDD / CodeMap 精神）

### Open Questions（需使用者先定義，否則規格不精準）

- [ ] 「整合」的具體目標是什麼？合併進單一 repo？去重？統一命名？建 CI/部署？— 不同目標，流程第 4–6 步差很多
- [ ] 範圍含不含 PowerShell？（取決於 Item 3 的 PowerShell 規範是否先做）
- [ ] 目標 code 量級？（幾十檔 vs 幾百檔，影響盤點要不要自動化）

---

## Item 3 — 全端工作流缺口 Roadmap（backlog，非單一功能）

### Summary

把「全端工程師一天」對照框架後缺的領域，登錄為優先序 backlog，避免遺忘。
每項日後挑出來時各自走一次 `/sdd` 出完整規格，本 Item 只負責「登錄 + 排序」。

### 缺口清單（優先序：使用者確認 2026-06-06）

| 排序 | 缺口 | 預計產出 | 為何 |
|---|---|---|---|
| **P1 · 本輪** | PowerShell 腳本規範 | `PowerShell/CLAUDE.md`（+ `/ps-dev`?） | 你預設 shell；CMD 已有對應規範，CodeMap 已標此缺 |
| **P1 · 本輪** | Git / Release 規範 | `Git Workflow/CLAUDE.md` | commit/PR/branch + tag-based deploy `V.X.X.X.X.X`，天天用 |
| 後續 backlog | Testing 規範 | React `<patterns>` 加 Vitest/Testing Library；`.Net` 加 WebApplicationFactory | CodeMap 已標前後端 testing 皆缺 |
| 後續 backlog | Auth（OAuth2 / JWT）pattern | `.Net Web API` 內新增 auth 區塊 | 你 stack 明確有 Google OAuth + JWT，卻無規範 |
| 後續 backlog | Debugging / 根因分析 | `Debugging/CLAUDE.md`（+ `/rca`?） | 讀 log / stack trace 的標準流程 |
| 後續 backlog | ADR / 週報 / 交接 | `Docs/` 模板集 | 日常溝通與決策記錄產出 |

> 本輪只建 **PowerShell** 與 **Git / Release** 兩個 domain；各自開 `specs/YYYY-MM-DD-<slug>.md` 走完整 SDD。
> 後續 backlog 四項維持登錄、不動，日後挑出時再排序 + 開 SDD。

### Acceptance Criteria

- [x] 清單登錄完成、使用者確認優先序（2026-06-06：P1 = PowerShell + Git/Release）
- [ ] 每項日後執行時各自開 `specs/YYYY-MM-DD-<slug>.md` 走完整 SDD

---

## 執行順序建議

1. **Item 3 P1 的 domain**（PowerShell / Git Workflow）— 先建好，Router 才有目的地可指
2. **Item 0**（自適應 Distribution）— 安裝層 → Router → Scaffolder；地基中的地基，吸收原 Phase 0 對帳
3. **Item 1**（術語不亂猜）— 天天踩，且是 Item 2 的前置（整合別人 code 必遇未知術語）；建好後掛進 Router
4. **Item 2**（Code 整合）— 眼前業務；建議先答 Open Questions 再動工

> 順序邏輯：Router 要指到 domain，所以 **domain 先於 Router**；但 Router/Scaffolder 是「無腦可用」的核心體驗，排在功能性 domain（Item 1/2）之前。

## References

- 對帳來源：`scripts/deploy.config.json`、`scripts/README.md`、`scripts/MANUAL-INSTALL.md`、`~/.claude/commands/`
- 規格模板：`sdd/spec-template.md`
- 安裝模式參考：`specs/2026-05-20-karpathy-guidelines-import.md`
- 既有可串接能力：`/proc-analyze`、`/cmd-dev`、`Mermaid Diagrams/`、`sdd/`
- 框架地圖：`CodeMap.md`
