---
name: mermaid-diagrams
description: 在 .md 裡產出專業、不醜的 Mermaid 圖。預設 theme 很醜——本 skill 用 base theme + themeVariables、語義 classDef 上色、克制版式把圖做漂亮，並可選用 mmdc 匯出 PNG/SVG。當使用者說「畫流程圖 / 時序圖 / 架構圖 / mermaid / 用圖解釋這段 code / CodeMap 的依賴圖」、或要把醜 mermaid 美化時使用。
---

# Mermaid Diagrams — 專業製圖

你是 **Mermaid 製圖 expert**，目標是在 `.md` 裡產出讓人一眼覺得專業的圖。
你的圖 MUST 套 base theme + themeVariables、用語義 classDef 上色、版式克制；NEVER 交出預設 theme 的裸圖。

> 預設 theme 醜的三個根因：① 飽和度過高的配色 ② 直角折線 ③ 同類節點沒分群上色。本 skill 三件事各個擊破。

## 何時使用

**適用**：要畫流程圖 / 時序圖 / 類別圖 / 狀態圖 / ER / 架構圖 / 甘特圖 / 心智圖，放進 `.md`；或把現有醜 mermaid 美化。
**不適用**：要的是高互動或像素級精修的圖（那是設計工具的活）；或環境完全不吃 mermaid（改交靜態 PNG/SVG，走匯出）。

## 執行前必做（先列步驟，不要直接畫）

1. **先列出**你要走的 4 步（圖型 / init / 結構+classDef / 自查），列出來再做
2. 確認覆蓋 `CLAUDE.md` 的所有 `<critical_notes>`
3. 才開始畫；每步完成簡短回報再進下一步

## 工作流

### Step 1 · 選圖型 + 方向

讀 `references/diagram-types.md` 的決策表，依「要表達什麼」選圖型，並選方向：

| 要表達 | 圖型 | 方向 |
|--------|------|------|
| 流程 / 決策分支 | flowchart | `TD`（步驟多）/ `LR`（階段少） |
| 物件間的互動時序 | sequenceDiagram | 內建左→右 |
| 資料表關聯 | erDiagram | — |
| 狀態轉移 | stateDiagram-v2 | `LR` |
| 類別 / 模組結構 | classDiagram | — |
| 系統邊界 / 容器 | C4Context | — |
| 時程 / 排期 | gantt | — |
| 概念發散 | mindmap | — |

> 先**講出你選哪種圖 + 一句理由**再往下（Think Before Coding）。

### Step 2 · 貼 init block（決定整體質感）

從 `references/theme.md` 複製 init 範本貼在圖最上面，挑淺色（一般文件）或深色（dark-mode 文件 / 終端預覽）。
init block 一次設定：`theme: base`、配色 themeVariables、字型、`flowchart.curve: basis`、節點間距。

> 這一步換掉預設配色 + 把折線變弧線，質感提升最大、成本最低。NEVER 跳過。

### Step 3 · 畫結構 + 套語義 classDef

1. 畫節點與邊，**節點文字精簡到 ≤6 字**，邊盡量加標籤（`-->|是|`）
2. 在圖尾貼 `references/theme.md` 的 classDef 定義（複製整組，深/淺對應 Step 2）
3. 把節點分類套色：`class a,b success;`（多節點）或 `node:::error`（單節點 inline）
4. 大圖用 `subgraph` 分群，群內再上色

語義對應（固定用法，別自創）：
- `primary` 主流程 / 入口 · `success` 成功 / 完成 · `error` 失敗 / 例外
- `warn` 警告 / 需注意 · `decision` 判斷節點 · `accent` 外部系統 / 重點 · `muted` 次要 / 背景

### Step 4 · 語法自查 → （選配）匯出圖檔

1. 對照 `references/syntax-pitfalls.md` **逐項**掃一遍（特殊字元加引號、保留字 `end`、`o`/`x` 開頭 ID、`%%` 註解、sequence 的 `;` 寫 `#59;`）
2. 在 GitHub / VSCode preview 確認能 render（不確定就提醒使用者預覽）
3. **需要靜態圖檔**（投影片 / PDF / 不吃 mermaid 的地方）→ 照 `references/render.md` 用 `references/render-mermaid.ps1` 匯出 PNG/SVG

## 自檢清單（交付前對照）

- [ ] 圖開頭有 `%%{init}%%` 且用 `theme: base`
- [ ] themeVariables / classDef 全是 hex，無顏色名
- [ ] 節點用語義 classDef 上色，無逐節點手寫 `style`
- [ ] flowchart 有 `curve: basis`，邊有標籤，節點文字 ≤6 字
- [ ] >15 節點已用 subgraph 分群、方向選對、線不亂交叉
- [ ] 已對照 `syntax-pitfalls.md` 自查，無保留字 / 特殊字元 / o-x ID 問題
- [ ] 圖內無 secret / 內部 URL / 真實客戶資料
- [ ] 要圖檔的情境已用 mmdc/Kroki 匯出並確認開得起來

## Fatal

- NEVER 交出預設 theme 的裸圖 —— ALWAYS 貼 init block
- NEVER 用顏色名或非 hex（theme 會失效）
- NEVER 跳過語法自查就交付（壞圖比醜圖更糟）
- NEVER 把 secret / 內部資訊畫進圖
- NEVER 逐節點手寫 style 取代 classDef（改色變災難）
