# PL/SQL Procedure 分析方法論

<system_context>
讀懂 10K+ 行 Oracle PL/SQL procedure / package 並產出結構化筆記 + Mermaid 圖。
搭配 `/proc-analyze` slash command 自動跑多 pass 解析。
產出存到 `notes/`，逐漸累積成 PL/SQL 第二大腦。
</system_context>

<critical_notes>
- MUST 對 5K+ 行 procedure 跑多 pass 分析（不要一次塞進 context）
- MUST 每筆筆記套用 `proc-template.md` 結構，欄位齊全才算完成
- MUST 流程步驟一律標行號範圍 `L1234–L1289`，方便回查 source
- MUST 先掃 `notes/` 看 callee 有沒有現成筆記 → 有就 link，不重做
- NEVER 一段流程文字超過原 code 的 30%（要摘要不要逐行翻譯）
- NEVER 把整段 PL/SQL 貼進筆記（最多貼關鍵 5–10 行片段）
- NEVER 用未經驗證的猜測（不確定的標 `<TODO: 待確認>`，不要編）
</critical_notes>

<file_map>
CLAUDE.md                  - 本檔（方法論）
proc-template.md           - 筆記模板（複製到 notes/ 用）
proc-analyze-command.md    - `/proc-analyze` slash command 內容
notes/                     - 已分析的 procedure 筆記（檔名 = `<schema>.<package>.<proc>.md`）
notes/INDEX.md             - 所有筆記索引（依 package / 業務領域分類）
</file_map>

<paved_path>
**檔名規則**

- `<schema>.<package>.<proc>.md`，全小寫 + dot 分隔
- 範例：`erp.pkg_orders.create_order.md`、`hr.pkg_payroll.calc_monthly.md`
- 獨立 procedure（不在 package）→ `<schema>.<proc>.md`

**Frontmatter 必填**

```yaml
---
schema: erp
package: pkg_orders
procedure: create_order
type: procedure | function | trigger
params:
  in:  [p_customer_id, p_items]
  out: [p_order_id, p_status]
exceptions: [e_invalid_customer, no_data_found]
line_count: 12450
analyzed_at: YYYY-MM-DD
analyzed_by: claude
source_file: <相對路徑或 wiki link>
status: draft | reviewed | stale
---
```

**多 pass 分析流程**（`/proc-analyze` 自動跑）

1. **Pass 1 結構掃描**（grep + 行號收集）
   - 抓 `^\s*(PROCEDURE|FUNCTION|BEGIN|EXCEPTION|END|IF|ELSIF|LOOP|FOR|WHILE|FORALL|CASE|WHEN)`
   - 輸出骨架：每個區塊 + 起訖行號 + 巢狀深度
2. **Pass 2 區段填肉**
   - 依骨架，每次 Read 一段（200–500 行）→ 寫該段摘要
   - 標記 SQL DML 動作（哪些 table / R/W）
3. **Pass 3 跨檔解析**
   - 抓所有 `pkg_x.proc_y(...)` 呼叫
   - 掃 `notes/` 看 callee 是否已分析 → link，否則列入「待分析」清單
4. **Pass 4 輸出**
   - 套 `proc-template.md` 組合
   - 產 3 張 Mermaid 圖（main flow / call sequence / data ER）
   - 寫入 `notes/<檔名>.md`，更新 `notes/INDEX.md`

**摘要密度規範**

- Top-level flow：每步 1 句話 + 行號
- 第二層細節：每分支 2–3 句
- 第三層只在「有業務語意分支」時展開，純技術細節（cursor open/close、變數宣告）不展開
</paved_path>

<patterns>
**Mermaid 三圖規範**（固定樣式，不要自創）

**Main flow**：`flowchart TD`，節點文字含 `[L行號]`

```
flowchart TD
    Start[開始 L100]
    A[驗證 customer L120-145]
    B{有效?}
    C[建立 order L150-200]
    Err[拋 e_invalid_customer L148]
    A --> B
    B -->|yes| C
    B -->|no| Err
```

**Call sequence**：`sequenceDiagram`，跨 package 呼叫

```
sequenceDiagram
    participant C as Caller
    participant O as pkg_orders
    participant I as pkg_inventory
    C->>O: create_order(...)
    O->>I: reserve_stock(...)
    I-->>O: stock_id
    O-->>C: order_id
```

**Data ER**：`erDiagram`，只畫這支 proc 觸及的 table

```
erDiagram
    CUSTOMERS ||--o{ ORDERS : has
    ORDERS ||--|{ ORDER_ITEMS : contains
```

**Data touched 表格欄位**

| Table | 動作 | 條件 / WHERE | 行號 |
|-------|------|--------------|------|
| orders | INSERT | - | L150 |
| inventory | UPDATE | item_id IN (...) | L210 |
| audit_log | INSERT | - | L280 |

**Branching map 寫法**

不要把所有 IF 都列。只列「業務語意 branch」：

- ✅ `IF customer_status = 'BLOCKED'` → 業務分支
- ❌ `IF l_temp IS NULL` → 技術 null check，跳過
</patterns>

<common_tasks>
- 分析新 proc → `/proc-analyze <檔案路徑或 package.proc 名稱>`
- 找已分析 proc → 看 `notes/INDEX.md` 或 grep `notes/`
- 更新 stale 筆記 → 改 frontmatter `status: stale` → 重跑 `/proc-analyze` 覆蓋
- 比對兩支 proc 差異 → 先各自分析，再對照兩份 main flow Mermaid 圖
- 找 caller → grep `notes/` 找 call sequence 圖含此 proc 的筆記
</common_tasks>

<example>
- 筆記模板 → `proc-template.md`, search:`## Main Flow`
- Slash command → `proc-analyze-command.md`, search:`Pass 1`
- 範例筆記（待第一支分析後填）→ `notes/INDEX.md`
</example>

<hatch>
- 純 CRUD wrapper（< 200 行、單一 INSERT/UPDATE）→ 跳過完整模板，寫一段 TL;DR + Data touched 即可
- Legacy proc 看不懂 → 先寫 TL;DR + 標 `status: draft` + 列出 unknown 區塊行號，慢慢補
- proc 內含動態 SQL（`EXECUTE IMMEDIATE`）→ 把拼出的 SQL 模式列在「動態 SQL」附錄
- Trigger 無參數但有 `:NEW` / `:OLD` → frontmatter `params` 改寫該 trigger 觸發 table + event
</hatch>

<fatal_implications>
- NEVER 把含敏感資料（薪資、身分證、實際 customer id）的 sample 貼進筆記
- NEVER 把整支 proc 貼進筆記（重點是摘要，不是備份）
- NEVER 自動 commit 筆記到 public repo（先確認無 PII）
- NEVER 編造行號 → 不確定標 `<TODO: 行號待確認>`
</fatal_implications>
