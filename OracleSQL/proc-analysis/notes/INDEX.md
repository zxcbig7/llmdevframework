# PL/SQL Procedure 筆記索引

由 `/proc-analyze` 自動維護。手動新增也可，但格式 MUST 一致。

## 使用方式

- 找已分析 proc：用瀏覽器 / VS Code 搜本檔
- 找特定 callee 的 caller：grep 此資料夾的 Call Graph 表格
- 標示 stale：把該行尾加 `[stale]`，並改該筆記 frontmatter `status: stale`

---

## 依 Package 分類

### `pkg_orders`

<!-- 範例：- [erp.pkg_orders.create_order](./erp.pkg_orders.create_order.md) — 建立訂單並鎖庫存 -->

### `pkg_inventory`

### `pkg_payroll`

### 其他 / 獨立 procedure

---

## 待分析（從其他筆記的 Call Graph 抓出）

<!-- 由 /proc-analyze Pass 3 自動補 -->

- _尚無_

---

## Stale 筆記（需重跑 /proc-analyze）

<!-- frontmatter status = stale 的筆記列在這 -->

- _尚無_
