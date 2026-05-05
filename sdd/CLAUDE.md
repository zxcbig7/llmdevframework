# SDD — Spec-Driven Development

<system_context>
新功能開發的標準起點。先寫規格，再寫 code。
靈感來自 wu_pingju 的 SDD skill：Plan mode 討論完方向 → 用 SDD 產出完整規格 → 空殼實作 → 逐步填肉。
</system_context>

<critical_notes>
- MUST 在「非 trivial 新功能」前跑一次 SDD（修一行 typo、改 CSS 不算）
- MUST 規格文件 commit 進 repo（`specs/` 資料夾），規格本身就是 deliverable
- MUST 規格獲使用者確認後才動 production code
- NEVER 跳過 stub 階段直接寫實作（stub 是 architecture 驗證點）
- NEVER 用過時規格繼續實作 → 偏離了就回頭改規格再走
</critical_notes>

<file_map>
sdd/CLAUDE.md           - 本檔（方法論 + 規則）
sdd/spec-template.md    - 規格模板（複製到專案 specs/ 用）
sdd/sdd-command.md      - `/sdd` slash command 內容（複製到 ~/.claude/commands/sdd.md）
</file_map>

<paved_path>
**規格存放位置**：當前專案 root 的 `specs/YYYY-MM-DD-<kebab-slug>.md`
- 範例：`specs/2026-05-05-user-oauth-login.md`
- 命名 slug 用 feature 而非 ticket 編號（人讀比較好找）

**規格生命週期**
1. **draft** — 撰寫中、待確認
2. **approved** — 使用者確認，可開始 stub
3. **implementing** — stub 完成，逐步實作
4. **shipped** — 功能上線
5. **superseded** — 被新規格取代（保留檔案，frontmatter 加 `superseded_by`）

**規格 frontmatter**（每份 spec 開頭）

```yaml
---
title: <一句話描述>
status: draft | approved | implementing | shipped | superseded
created: YYYY-MM-DD
updated: YYYY-MM-DD
modules: [frontend, backend, db, infra]
---
```
</paved_path>

<patterns>
**`/sdd` 互動流程**

Claude 必問三題（缺一不可）：

1. **一句話描述功能**：強迫使用者抽象，揭露範圍模糊處
2. **會互動的模組**：抓出跨層 / 跨服務影響面
3. **成功標準**：可驗收的條件（user 通常會說「你建議」）

回答完畢 → 產出 `specs/YYYY-MM-DD-<slug>.md`，套 `spec-template.md` 結構 → 等使用者「approved」字樣才進 stub。

**Stub 階段做什麼**
- Frontend：建 component 檔 + props interface + route，內容 `return <div>TODO</div>`
- Backend：建 controller method + service interface + DTO，body `throw new NotImplementedException()`
- DB：寫 migration（schema 確定）但不填 seed
- 跑一次 build → 驗證型別 / 路由連得起來

**從 stub → 實作**
- 一次填一個 layer（DB → repo → service → controller → UI）
- 每填一層跑一次 typecheck + 對照規格 acceptance criteria
- 偏離規格 → 改規格、不偷改 code
</patterns>

<common_tasks>
- 啟動 SDD → 在 Claude Code 跑 `/sdd <一句話描述>`（需先安裝指令，見下方）
- 安裝 `/sdd` 指令 → 複製 `sdd-command.md` 到 `C:\Users\zxcbi\.claude\commands\sdd.md`
- 新建規格 → 複製 `spec-template.md` 到專案 `specs/`，填 frontmatter + 各 section
- 規格作廢 → 改 status 為 `superseded`，frontmatter 加 `superseded_by: <new-spec-file>`
</common_tasks>

<example>
- 規格模板 → `sdd/spec-template.md`, search:`## Acceptance Criteria`
- Slash command 內容 → `sdd/sdd-command.md`, search:`三個釐清問題`
</example>

<hatch>
- Trivial change（typo、樣式微調、文案）→ 跳過 SDD，直接改
- 急 hotfix → 先修，事後補規格（在 `specs/` 加 `retroactive: true`）
- 純 refactor 無行為變化 → 寫 ADR（architecture decision record）取代 spec
</hatch>

<fatal_implications>
- NEVER 規格只有口頭討論沒寫檔（discussion ≠ spec）
- NEVER 規格寫完不給使用者看就動工
- NEVER 規格與實作脫節 → 真實情況更新到規格、不要默默偏離
</fatal_implications>
