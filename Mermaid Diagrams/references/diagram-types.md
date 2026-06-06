# diagram-types.md — 圖型選用決策 + pattern

先選對圖型，再套 `theme.md` 的 init + classDef。每型給「何時用 + 最小 pattern + 美化要點」。

---

## 選型決策表

| 你要表達 | 圖型 | 關鍵字 |
|----------|------|--------|
| 流程、決策分支、資料流向 | flowchart | `graph TD` / `flowchart LR` |
| 物件 / 服務間的互動時序 | sequence | `sequenceDiagram` |
| 資料表 / entity 關聯 | ER | `erDiagram` |
| 狀態機、生命週期 | state | `stateDiagram-v2` |
| 類別 / 模組 / 介面結構 | class | `classDiagram` |
| 系統邊界、容器、外部依賴 | C4 | `C4Context` |
| 專案時程、排期 | gantt | `gantt` |
| 概念發散、腦圖 | mindmap | `mindmap` |
| Git 分支歷史 | gitgraph | `gitGraph` |

---

## flowchart（最常用）

**何時**：流程、pipeline、決策樹、依賴圖（CodeMap 的 Dependency Graph 就用這個）。
**美化要點**：方向 `TD`（步驟多）/`LR`（階段少）；`curve:basis`；決策用菱形 `{}`；subgraph 分群；邊加標籤。

```
%%{init: {'theme':'base','themeVariables':{'lineColor':'#94a3b8'},'flowchart':{'curve':'basis'}}}%%
flowchart TD
  IN[請求進入] --> AUTH{已登入?}
  AUTH -->|否| REJ[401 拒絕]
  AUTH -->|是| SVC[業務處理]
  subgraph 資料層
    SVC --> DB[(寫入 DB)]
    SVC --> CACHE[(更新快取)]
  end
  DB --> OK[200 回應]
  class IN primary
  class OK success
  class REJ error
  class AUTH decision
  class DB,CACHE accent
  classDef primary  fill:#eef2ff,stroke:#6366f1,stroke-width:2px,color:#3730a3;
  classDef success  fill:#ecfdf5,stroke:#10b981,stroke-width:2px,color:#065f46;
  classDef error    fill:#fef2f2,stroke:#ef4444,stroke-width:2px,color:#991b1b;
  classDef decision fill:#fefce8,stroke:#eab308,stroke-width:2px,color:#854d0e;
  classDef accent   fill:#eff6ff,stroke:#3b82f6,stroke-width:2px,color:#1e40af;
```

> 節點形狀語義：`[]` 流程、`{}` 決策、`[()]` 資料庫圓柱、`([])` 起訖膠囊、`[[]]` 子程序。

## sequence

**何時**：API 呼叫順序、OAuth flow、服務間訊息往返。
**美化要點**：用 `autonumber`；`participant X as 顯示名`；分組用 `box`；批註用 `Note over`。

```
%%{init: {'theme':'base','themeVariables':{'fontSize':'14px'}}}%%
sequenceDiagram
  autonumber
  participant U as 使用者
  participant API as Gateway
  participant DB as Oracle
  U->>API: POST /login
  API->>DB: 查帳號
  DB-->>API: 使用者資料
  API-->>U: JWT
  Note over API,DB: 失敗則回 401
```

> sequence 不吃 flowchart 的 classDef；配色靠 init 的 themeVariables（actor/note 顏色）。

## ER

**何時**：資料表設計、schema 關聯。**美化要點**：關係基數寫清楚（`||--o{`）、欄位標 PK/FK。

```
erDiagram
  USER ||--o{ ORDER : places
  ORDER ||--|{ ORDER_ITEM : contains
  USER {
    int id PK
    string email
  }
```

## state

**何時**：狀態機、訂單/任務生命週期。**美化要點**：`direction LR`；複合狀態用巢狀；`[*]` 起訖。

```
stateDiagram-v2
  direction LR
  [*] --> Pending
  Pending --> Paid: 付款
  Paid --> Shipped: 出貨
  Shipped --> [*]
```

## class

**何時**：OOP 結構、模組關係。**美化要點**：標可見性（`+`/`-`）、關係用對的箭頭（`<|--` 繼承、`*--` 組合）。

```
classDiagram
  class UserService {
    -IUserRepository repo
    +GetUserAsync(id) User
  }
  UserService ..> IUserRepository
```

## C4 / gantt / mindmap（速覽）

- **C4Context**：`Person()`、`System()`、`Rel()` 畫系統邊界與外部依賴；適合架構總覽。
- **gantt**：`dateFormat YYYY-MM-DD` + `section`；任務寫 `:done/active/crit` 標狀態。
- **mindmap**：縮排即層級，根節點用 `root((中心))`；不吃 classDef，靠 init theme。

> 這三型較少用，需要時查 mermaid.js.org/syntax/ 對應頁；init block 一律照 `theme.md`。
