# syntax-pitfalls.md — 語法防呆清單

這些錯誤讓圖**直接壞掉 / render 失敗**，不只是醜。交付前逐項掃。good/bad 對照。

---

## 1. 節點文字含特殊字元 → 加引號

括號 `()`、方括號 `[]`、大括號 `{}`、冒號等在文字裡會被當語法。

```
❌  A[呼叫 fetch(url)]            ← 括號破壞解析
✅  A["呼叫 fetch(url)"]
```

## 2. 保留字 `end` → 大寫或加引號

小寫 `end` 是 subgraph/區塊的結束關鍵字，當 node 會錯亂。

```
❌  A --> end
✅  A --> End          或   A --> e1["end"]
```

## 3. node ID 別用 `o` / `x` 開頭

`A --o B`、`A --x B` 是「圓頭 / 叉頭」邊語法；node ID 以 o/x 開頭會被誤解析成那種邊。

```
❌  order --> x1            ← 可能被讀成 --x 1
✅  orderNode --> step1
```

## 4. 註解用 `%%` 不是 `%`

```
❌  % 這是註解             ← 單 % 破壞 render
✅  %% 這是註解
```

## 5. sequence 訊息裡的 `;` → 用 entity code

```
❌  A->>B: key;value
✅  A->>B: key#59;value      ← #59; 是分號
```

## 6. subgraph 標題含 HTML / 特殊字元 → 加引號

```
❌  subgraph 流程<br/>說明
✅  subgraph "流程<br/>說明"
```

## 7. `stroke-dasharray` 逗號 → 跳脫

style/classDef 裡的逗號會被當屬性分隔。

```
❌  style A stroke-dasharray: 5,5
✅  style A stroke-dasharray: 5 5      （空格）  或  5\,5（跳脫）
```

## 8. 邊標籤含特殊字元 → 加引號

```
❌  A -->|50% 命中| B
✅  A -->|"50% 命中"| B
```

## 9. flowchart 用 `-->` 不是 `->`（那是 sequence 的）

```
❌  graph TD  A -> B          ← flowchart 不吃單箭頭
✅  graph TD  A --> B
✅  sequenceDiagram  A->>B: hi  （sequence 才用 -> / ->>）
```

## 10. 方向關鍵字別寫錯

flowchart 用 `TD`/`TB`/`LR`/`RL`/`BT`；`graph` 與 `flowchart` 等價。
stateDiagram 用 `direction LR`（在圖內另起一行），不是寫在第一行。

```
❌  stateDiagram-v2 LR
✅  stateDiagram-v2
       direction LR
```

---

## 快速自查（交付前對照）

- [ ] 含 `()[]{}:;` 的節點 / 邊標籤文字都加了 `"..."`
- [ ] 沒有裸 `end` 當 node；沒有 `o`/`x` 開頭的 node ID
- [ ] 註解全是 `%%`；sequence 的 `;` 寫成 `#59;`
- [ ] subgraph 標題含特殊字元的有加引號
- [ ] classDef/style 的 `stroke-dasharray` 用空格或跳脫逗號
- [ ] flowchart 用 `-->`、sequence 用 `->>`，沒混用
- [ ] 方向關鍵字正確（flowchart 第一行 / stateDiagram 用 `direction`）

> 不確定能不能 render → 貼進 VSCode Mermaid preview 或 GitHub 草稿確認，再交付。
