# Oracle SQL / PL/SQL 開發規範

<system_context>
Oracle 19c+ SQL 與 PL/SQL 開發守則。
涵蓋 schema design、query 撰寫、PL/SQL package、performance tuning。
</system_context>

<critical_notes>
- MUST 大寫保留字（SELECT、FROM、WHERE…），小寫物件名與欄位名
- MUST 用 bind variables（`:p_id`），NEVER 字串拼接 SQL（避免 hard parse + SQL injection）
- MUST 所有 DML 包進 package procedure / function（同一段 SQL 重用以減少 parse）
- NEVER 在 production code 用 `SELECT *`，明列欄位
- NEVER 用 cursor FOR loop 做大量 INSERT/UPDATE/DELETE，改用 `BULK COLLECT` + `FORALL`
- NEVER 在 trigger 裡呼叫複雜業務邏輯（移到 package）
- ALWAYS 在 PL/SQL block 處理 exception（`WHEN OTHERS` 必須 log + re-raise，不可吞）
- ALWAYS 用 `%TYPE` / `%ROWTYPE` 綁定欄位型別，不要 hard-code `VARCHAR2(50)`
</critical_notes>

<file_map>
schema/tables/          - CREATE TABLE DDL
schema/indexes/         - 索引定義
schema/constraints/     - PK/FK/UNIQUE/CHECK
packages/               - PL/SQL package spec + body
views/                  - VIEW / MATERIALIZED VIEW
migrations/             - 版本化 schema 變更（Liquibase / Flyway）
proc-analysis/          - PL/SQL procedure 分析方法論 + `/proc-analyze` 指令 + 筆記庫
</file_map>

<paved_path>
**命名（小寫 + snake_case，物件名自我說明）**
- Table：複數名詞 `customers`、`order_items`
- Column：`customer_id`、`created_at`、`is_active`
- Primary key：`pk_<table>`；Foreign key：`fk_<table>_<ref>`
- Index：`ix_<table>_<col>`；Unique：`uk_<table>_<col>`
- Sequence：`seq_<table>`；Trigger：`trg_<table>_<event>`
- Package：`pkg_<domain>`（e.g. `pkg_orders`）
- Procedure / Function：動詞開頭 `get_active_customers`、`calculate_total`

**PL/SQL 變數前綴**
- `l_` 區域變數：`l_customer_id`
- `g_` package 全域變數：`g_default_status`
- `p_` 參數：`p_customer_id`（IN）、`p_result`（OUT）
- `c_` cursor：`c_active_customers`
- `k_` 常數（全大寫）：`K_MAX_RETRY`
- `t_` type / record：`t_customer_rec`
- `e_` user-defined exception：`e_invalid_status`

**Performance**
- Bulk operation：`BULK COLLECT INTO ... LIMIT 1000` + `FORALL`
- 避免 row-by-row（slow-by-slow）→ set-based SQL 優先
- 善用 `EXISTS` 取代 `IN`（大資料集）
- `ROWNUM` / `FETCH FIRST n ROWS` 限制結果
- Index：FK 一律建 index、查詢條件欄位建 index、低基數欄位用 bitmap
- `EXPLAIN PLAN FOR` + `DBMS_XPLAN.DISPLAY` 驗證執行計畫
</paved_path>

<patterns>
**Package 結構**
```sql
CREATE OR REPLACE PACKAGE pkg_orders AS
  PROCEDURE create_order(p_customer_id IN customers.id%TYPE,
                         p_order_id    OUT orders.id%TYPE);
  FUNCTION  get_total(p_order_id IN orders.id%TYPE) RETURN NUMBER;
END pkg_orders;
/
```

**Bulk collect + FORALL**
```sql
DECLARE
  TYPE t_ids IS TABLE OF orders.id%TYPE;
  l_ids t_ids;
BEGIN
  SELECT id BULK COLLECT INTO l_ids FROM orders WHERE status = 'PENDING';
  FORALL i IN 1..l_ids.COUNT
    UPDATE orders SET status = 'PROCESSED' WHERE id = l_ids(i);
END;
```

**Exception handling**
```sql
EXCEPTION
  WHEN no_data_found THEN
    log_error('pkg_orders.get_total', SQLERRM);
    RAISE;
  WHEN OTHERS THEN
    log_error('pkg_orders.get_total', SQLERRM);
    RAISE;
END;
```
</patterns>

<common_tasks>
- 加 table → `schema/tables/<name>.sql` + 對應 PK/FK/index 檔
- 加 package → spec + body 分檔（`pkg_x.pks` + `pkg_x.pkb`）
- 加 migration → `migrations/V<n>__<desc>.sql`，含 up / down
- Tune slow query → `EXPLAIN PLAN`、看 `cost` / `cardinality`、確認 index 命中
- **讀 / 整理 10K+ 行 procedure** → `/proc-analyze <檔案>`，產出筆記 + Mermaid 圖到 `proc-analysis/notes/`（細節見 `proc-analysis/CLAUDE.md`）
</common_tasks>

<example>
- Bulk DML pattern → `packages/pkg_batch.pkb`, search:`FORALL`
- Hierarchical query → `views/v_org_tree.sql`, search:`CONNECT BY`
- Merge upsert → `packages/pkg_sync.pkb`, search:`MERGE INTO`
- Pipelined function → `packages/pkg_report.pkb`, search:`PIPE ROW`
</example>

<hatch>
- 動態 SQL 不可避免時用 `DBMS_SQL` 或 `EXECUTE IMMEDIATE` + bind variable，NEVER 拼字串
- Legacy code 用 cursor for loop → 重構時改 bulk
- 跨 schema 查詢用 synonym + 明確 grant，不用 public synonym
</hatch>

<fatal_implications>
- NEVER `EXECUTE IMMEDIATE 'SELECT ... ' || p_user_input`（SQL injection）
- NEVER `WHEN OTHERS THEN NULL`（吞掉 exception）
- NEVER 在 trigger 裡 commit / rollback
- NEVER autonomous transaction 用於主流程（只用於 logging）
- NEVER drop / truncate production table 不留備份與 audit
- NEVER 在生產跑 DDL 不評估鎖表時間
</fatal_implications>
