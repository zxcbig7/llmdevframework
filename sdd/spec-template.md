---
title: <一句話描述功能>
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
modules: [frontend, backend, db, infra]
---

# <Feature Name>

## Summary

<2–3 句講清楚這個功能在做什麼、為誰做、解決什麼問題。>

## Motivation / Why

<為何現在需要這個功能。背後的痛點 / 商業需求 / 技術 driver。>

## Scope

### In Scope

- <明確會做的事，列點>

### Out of Scope

- <明確不做的事，避免 scope creep>

## User Stories / Use Cases

1. As a <role>, I want to <action>, so that <benefit>.
2. ...

## Acceptance Criteria

可驗收、可測試的條件。

- [ ] <條件 1，e.g. 使用者輸入 email + 密碼點 login，成功後導到 /dashboard>
- [ ] <條件 2>
- [ ] <條件 3>

## Module Interactions

涉及的模組 / 層 / 服務，以及彼此呼叫關係。

- **Frontend**：<哪些 component / route>
- **Backend**：<哪些 controller / service / endpoint>
- **DB**：<哪些 table / 新欄位 / migration>
- **Infra / 第三方**：<外部 API、queue、cache、auth provider>

## API Design

### Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST   | /api/xxx | ... | JWT |

### Request / Response Schema

```ts
// Request
type XxxRequest = { ... }

// Response
type XxxResponse = { ... }
```

## Data Model

```sql
CREATE TABLE xxx (
  id NUMBER PRIMARY KEY,
  ...
);
```

## Edge Cases & Error Handling

- <情境 1：使用者點兩次 submit → 用 idempotency key>
- <情境 2：第三方 API timeout → retry 3 次後 fallback>
- <情境 3：權限不足 → 回 403 + 標準 ProblemDetails>

## Non-Functional Requirements

- **Performance**：<e.g. p95 < 500ms>
- **Security**：<e.g. 所有 endpoint 需 JWT、敏感欄位 mask log>
- **Observability**：<要 log 什麼、加什麼 metric>

## Open Questions

- [ ] <尚未決定的事，等 stakeholder 回應>

## Implementation Plan

### Stub 階段（先做）

- [ ] <建 component / interface / route，邏輯留 TODO>
- [ ] 跑 build / typecheck 確認結構連得起來

### 逐層實作

- [ ] DB schema + migration
- [ ] Repository / DAL
- [ ] Service layer 業務邏輯
- [ ] Controller / API endpoint
- [ ] Frontend integration
- [ ] Tests（unit + integration）

## References

- 相關 issue / PR / 設計討論：
- 受影響的既有規格：
