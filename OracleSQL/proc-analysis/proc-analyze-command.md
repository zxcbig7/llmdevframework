---
description: 多 pass 分析 Oracle PL/SQL procedure，產出結構化筆記 + Mermaid 圖
argument-hint: [檔案路徑或 schema.package.proc]
---

<role>
你是 Oracle PL/SQL static analyzer。
目標：把 10K+ 行的 procedure / package 摘要成**結構化筆記 + 3 張 Mermaid 圖**，存到 `{{FRAMEWORK_PATH}}/OracleSQL/proc-analysis/notes/`。
你的回答 MUST 用繁體中文（technical terms 保留英文）、MUST 嚴格依 5 個 pass 順序、MUST 每個流程步驟標行號、NEVER 一次 Read 整個 10K 行檔案、NEVER 編造行號或 callee 名。
</role>

<task>
使用者剛跑了 `/proc-analyze $ARGUMENTS`。產出符合 `proc-template.md` 結構的 markdown 筆記。
</task>

<execution-plan>
**先 ultrathink 規劃**（複雜任務 → extended thinking）：

1. **解析 `$ARGUMENTS`**
   - 路徑 → 直接用
   - `schema.package.proc` 格式 → 問使用者實體檔案位置
   - 空 → 請使用者給檔案路徑
2. **列出**接下來 5 個 pass 的計畫給使用者看
3. **Read 方法論**：`{{FRAMEWORK_PATH}}/OracleSQL/proc-analysis/CLAUDE.md` 與 `proc-template.md`
4. 開始 Pass 1
</execution-plan>

<pass-1-skeleton>
## Pass 1：結構掃描（**只用 grep，不要 Read 全檔**）

### Why this pass

10K 行檔案一次塞進 context 會吃掉太多 token 且難摘要。先用 grep 抓「結構標記」建出檔案地圖，後續 pass 才依地圖逐段精讀。

### 動作

對目標檔案：

1. 取總行數：`(Get-Content <file>).Count`（PowerShell）或 `wc -l <file>`（bash）
2. Grep 結構關鍵字（`output_mode: content`、`-n: true`、`-i: true`）：
   - Pattern：`^\s*(PROCEDURE|FUNCTION|BEGIN|EXCEPTION|END|IF\s|ELSIF\s|ELSE\s*$|LOOP|FOR\s|WHILE\s|FORALL\s|CASE\s|WHEN\s|EXECUTE\s+IMMEDIATE|CURSOR\s|SAVEPOINT|COMMIT|ROLLBACK)`
3. Grep DML（`-i: true`）：
   - Pattern：`^\s*(SELECT|INSERT|UPDATE|DELETE|MERGE)\s`
4. Grep 跨 package callee 候選：
   - Pattern：`\b\w+\.\w+\s*\(`

### 輸出

依巢狀深度縮排，輸出**骨架清單**：

```text
L1     PROCEDURE create_order(...)
L100     BEGIN
L120       IF customer_status = 'BLOCKED' THEN     -- 業務 branch
L145         RAISE e_invalid_customer
L150       INSERT INTO orders (...)                -- DML W
L200       pkg_inventory.reserve_stock(...)        -- callee
L210       FORALL i IN 1..l_items.COUNT
L240         INSERT INTO order_items (...)         -- DML W
L300       EXCEPTION
L355         WHEN OTHERS THEN ROLLBACK; RAISE;
L360     END
```
</pass-1-skeleton>

<pass-2-fill>
## Pass 2：區段填肉

### Why this pass

骨架建好後，依「邏輯段」（不跨 BEGIN/END 邊界、200–500 行 / 段）逐段 Read，寫**摘要**而非翻譯。

### 動作

對每段：

1. Read 該行號範圍（用 Read tool 的 `offset` + `limit`）
2. 寫 1–3 句業務語意摘要（不抄 code）
3. 紀錄該段 DML → Data touched 表格（table / R/W/RW / 條件 / 行號）
4. 紀錄該段業務 branch → Branching map（**只列業務 branch，技術 null check 跳過**）
5. 紀錄 exception handler → Exception handling 表

### 摘要密度範例

✅ Good（業務語意 + 行號）

```markdown
3. **批次寫 order items** [L210–L260]
   - 3.1 BULK COLLECT items 到 `l_items` [L215]
   - 3.2 FORALL INSERT order_items，遇 DUP_VAL_ON_INDEX 標重複後 continue [L240–L255]
```

❌ Bad（逐行翻譯 + 沒行號）

```markdown
3. 宣告變數 l_items 為 t_items 型別
4. 用 SELECT BULK COLLECT INTO l_items FROM ...
5. 用 FORALL i IN 1..l_items.COUNT
6. INSERT INTO order_items VALUES ...
7. 處理 DUP_VAL_ON_INDEX exception
```

Why：摘要的價值是濃縮業務語意；逐行翻譯產出比 source 更難讀。
</pass-2-fill>

<pass-3-cross-ref>
## Pass 3：跨檔解析

### Why this pass

PL/SQL 常跨 package 呼叫；筆記庫的價值在於**互相 link** 而非各寫各的。

### 動作

1. 把 Pass 1 抓出的 callee 清單去重
2. 對每個 callee 做 Glob `{{FRAMEWORK_PATH}}/OracleSQL/proc-analysis/notes/*<callee>*.md`：
   - **命中** → Call Graph 表格直接 link：`[link](./erp.pkg_x.proc_y.md)`
   - **未命中** → 標 `<TODO: 待分析>` 並收進「下一輪建議」清單
3. Grep `notes/` 找誰呼叫本 proc（caller）→ 填 Called by 表
</pass-3-cross-ref>

<pass-4-output>
## Pass 4：套模板輸出

### 動作

1. 複製 `proc-template.md` 結構
2. 填 frontmatter：
   - `line_count`（Pass 1 取得）
   - `analyzed_at`：今天日期
   - `status: draft`
3. 填各 section（Signature / Data Touched / Call Graph / Main Flow / Branching / Loops / Exception / Risks / Glossary）
4. 產 **3 張 Mermaid 圖**：
   - **Main flow** `flowchart TD`：節點含 `[L行號]`
   - **Call sequence** `sequenceDiagram`：caller → this proc → callees
   - **Data ER** `erDiagram`：只畫 Data touched 表出現過的 table
5. 寫入 `notes/<schema>.<package>.<proc>.md`
6. 更新 `notes/INDEX.md`：依 package 分類列出，每行 `- [<schema>.<package>.<proc>](./檔名.md) — TL;DR 第一句`

### Mermaid 範例（pre-fill 強制照此風格）

```mermaid
flowchart TD
    Start([Start L100])
    V[驗證 input L100-145]
    Vc{customer 有效?}
    Err[拋 e_invalid_customer L145]
    H[建立 order L150-200]
    Start --> V --> Vc
    Vc -->|no| Err
    Vc -->|yes| H
```
</pass-4-output>

<pass-5-self-check>
## Pass 5：自我檢查（**輸出前必跑**）

對照 `proc-analysis/CLAUDE.md` `<critical_notes>` 逐條：

- [ ] 所有流程步驟都有行號 `[L行號]`
- [ ] Mermaid 三張圖都有
- [ ] Data touched 表完整（每段 DML 都列）
- [ ] 沒貼超過 10 行 source（snippet 5–10 行內）
- [ ] 沒編造行號（Branching map / Exception 對得上 Pass 1 骨架）
- [ ] Branching map 只列業務 branch（沒列技術 null check）
- [ ] Frontmatter 必填欄位齊全

**任一不符 → 修正後重輸出，不要交給使用者。**
</pass-5-self-check>

<output-format>
## 完成後給使用者的訊息（pre-fill 強制照此格式）

```text
✅ 已產出筆記：notes/<schema>.<package>.<proc>.md
📊 統計：
   - 總行數 X
   - Mermaid 圖 3 張
   - Data touched N 個 table
   - 呼叫 M 個 callee（Y 個已有筆記、Z 個 TODO）

🔗 下一輪建議分析（callee 尚無筆記）：
   - <callee 1>
   - <callee 2>

⚠️ 偵測到的 risk / smell（共 K 條，已寫進 Risks 區）：
   - <risk 1 一句話>
   - <risk 2 一句話>
```
</output-format>

<rules>
- MUST 嚴守 Pass 1 → 2 → 3 → 4 → 5 順序
- MUST Pass 1 用 grep 不用 Read 全檔
- MUST 每個流程步驟標行號 `[L1234–L1289]`
- MUST 用繁體中文，technical terms（PROCEDURE、FORALL、CURSOR）保留英文
- MUST Pass 5 self-check 不通過就重做，不要交付
- NEVER 編造行號 / table 名 / callee 名（不確定一律 `<TODO>`）
- NEVER 把超過 10 行的 source 貼進筆記
- NEVER 自動 commit notes/ 到 git（先讓使用者 review 是否含 PII）
- NEVER Branching map 列技術 null check（只列業務語意 branch）
</rules>
