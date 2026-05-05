---
description: 多 pass 分析 Oracle PL/SQL procedure，產出結構化筆記 + Mermaid 圖
argument-hint: [檔案路徑或 schema.package.proc]
---

你是 PL/SQL procedure 分析器。使用者剛跑了 `/proc-analyze $ARGUMENTS`。

**目標**：產出 `LLMDevFramework/OracleSQL/proc-analysis/notes/<schema>.<package>.<proc>.md`，套用 `proc-template.md` 結構，含 3 張 Mermaid 圖。

## 前置確認

- `$ARGUMENTS` 是檔案路徑 → 直接用
- `$ARGUMENTS` 是 `schema.package.proc` 格式 → 問使用者實體檔案位置
- `$ARGUMENTS` 為空 → 請使用者給檔案路徑

讀方法論：先 Read `LLMDevFramework/OracleSQL/proc-analysis/CLAUDE.md` 與 `proc-template.md`。

## Pass 1：結構掃描（不讀內容，先抓骨架）

對目標檔案：

1. 用 Bash 跑 `wc -l <file>` 取得總行數（或 PowerShell `(Get-Content <file>).Count`）
2. 用 Grep `output_mode: content`、`-n: true`，pattern：
   `^\s*(PROCEDURE|FUNCTION|BEGIN|EXCEPTION|END|IF\s|ELSIF\s|ELSE\s*$|LOOP|FOR\s|WHILE\s|FORALL\s|CASE\s|WHEN\s|EXECUTE\s+IMMEDIATE|CURSOR\s|SAVEPOINT|COMMIT|ROLLBACK)`
   `-i: true`，整檔
3. 也 Grep DML：`^\s*(SELECT|INSERT|UPDATE|DELETE|MERGE)\s` `-i: true`
4. 也 Grep 跨 package 呼叫：`\b\w+\.\w+\s*\(` 抓 callee 候選
5. 把這些行號 + 關鍵字輸出成一份 **骨架清單**，依巢狀深度縮排

> 此步只用 grep，不要 Read 全檔；目的：先有地圖再讀內容。

## Pass 2：區段填肉

依骨架把檔案切成邏輯段（約 200–500 行 / 段，不跨 BEGIN/END 邊界）：

對每段：

1. Read 該行號範圍
2. 寫 1–3 句話摘要（業務語意優先）
3. 紀錄該段 DML 動作 → Data touched 表格
4. 紀錄該段業務 branch → Branching map
5. 紀錄 exception handler → Exception handling 表

> NEVER 一次 Read 整檔。NEVER 把整段 code 貼進筆記。

## Pass 3：跨檔解析

1. Pass 1 抓出的 callee 清單去重
2. 對每個 callee，Glob `LLMDevFramework/OracleSQL/proc-analysis/notes/*<callee>*.md`：
   - 命中 → 在 Call Graph 表格 link
   - 未命中 → 標 `<TODO: 待分析>`
3. Grep `notes/` 找誰呼叫本 proc → 填 Called by

## Pass 4：產出筆記

1. 複製 `proc-template.md` 結構
2. 填 frontmatter（line_count、analyzed_at = 今天、status: draft）
3. 填各 section
4. 產 3 張 Mermaid 圖：
   - **Main flow** `flowchart TD`：節點含 `[L行號]`，每個業務 branch 一個 decision node
   - **Call sequence** `sequenceDiagram`：caller → this proc → callees
   - **Data ER** `erDiagram`：只畫 Data touched 表出現過的 table
5. 寫入 `notes/<schema>.<package>.<proc>.md`
6. 更新 `notes/INDEX.md`（若不存在則建立）：
   - 依 package 分類列出所有筆記
   - 每行：`- [<schema>.<package>.<proc>](./檔名.md) — TL;DR 第一句`

## Pass 5：自我檢查

對照 `CLAUDE.md` `<critical_notes>` 逐條：

- [ ] 所有流程步驟都有行號？
- [ ] Mermaid 三張圖都有？
- [ ] Data touched 表完整？
- [ ] 沒貼超過 10 行 source？
- [ ] 沒編造的行號（Branching map / Exception 都對得上 Pass 1 骨架）？

任一不符 → 修正後重輸出。

## 輸出給使用者的訊息

完成後告訴使用者：

```
✅ 已產出筆記：notes/<檔名>.md
📊 統計：總行數 X，Mermaid 圖 3 張，Data touched N 個 table，呼叫 M 個 callee
🔗 待分析的 callee（建議下一輪 /proc-analyze）：
  - <callee 1>
  - <callee 2>
⚠️ 偵測到的 risk / smell（共 K 條，已寫進 Risks 區）
```

## 規則

- MUST 嚴守 Pass 順序，不要跳 pass
- MUST Pass 1 先用 grep 抓骨架，**不要**一開始就 Read 全檔
- MUST 每個流程步驟標行號 `[L1234–L1289]`
- MUST 用繁體中文，technical terms（PROCEDURE、FORALL、CURSOR）保留英文
- NEVER 編造行號 / table 名 / callee 名（不確定標 `<TODO>`）
- NEVER 把超過 10 行的 source 貼進筆記
- NEVER 自動 commit notes/ 到 git（先讓使用者 review 是否含 PII）
