# theme.md — init block + 語義 classDef recipes

整體質感 = **base theme + themeVariables**（換配色/字型/線條）＋ **語義 classDef**（同類節點同色）。
配色主軸：**低飽和 fill（Tailwind 50/950）+ 高飽和 border（500/400）+ 深/淺文字**。全部用 hex。

---

## 1. init block 範本（貼在圖最上面）

### 淺色（一般文件，預設用這個）

```
%%{init: {'theme':'base','themeVariables':{
  'fontFamily':'ui-sans-serif, -apple-system, Segoe UI, Roboto, sans-serif',
  'fontSize':'14px',
  'primaryColor':'#eef2ff',
  'primaryTextColor':'#1e293b',
  'primaryBorderColor':'#6366f1',
  'lineColor':'#94a3b8',
  'secondaryColor':'#f1f5f9',
  'tertiaryColor':'#f8fafc',
  'noteBkgColor':'#fef9c3','noteTextColor':'#854d0e','noteBorderColor':'#eab308'
},'flowchart':{'curve':'basis','nodeSpacing':50,'rankSpacing':55,'htmlLabels':true}}}%%
```

### 深色（dark-mode 文件 / 終端預覽）

```
%%{init: {'theme':'base','themeVariables':{
  'darkMode':true,
  'fontFamily':'ui-sans-serif, system-ui, sans-serif',
  'fontSize':'14px',
  'background':'#0f172a',
  'primaryColor':'#1e293b',
  'primaryTextColor':'#e2e8f0',
  'primaryBorderColor':'#818cf8',
  'lineColor':'#475569',
  'secondaryColor':'#334155',
  'tertiaryColor':'#1e293b'
},'flowchart':{'curve':'basis','nodeSpacing':50,'rankSpacing':55}}}%%
```

> **單行版**（怕多行被某些 viewer 吃掉時用）：把上面壓成一行即可，內容相同。
> sequence/gantt 等沒有 `flowchart` 子設定，刪掉 `'flowchart':{...}` 那段即可。

---

## 2. 語義 classDef recipes（貼在圖尾）

固定 7 個語義 class，別自創。用法：`class a,b success;`（多節點）或 `node:::error`（inline）。

### 淺色（配淺色 init）

```
classDef primary  fill:#eef2ff,stroke:#6366f1,stroke-width:2px,color:#3730a3;
classDef success  fill:#ecfdf5,stroke:#10b981,stroke-width:2px,color:#065f46;
classDef warn     fill:#fffbeb,stroke:#f59e0b,stroke-width:2px,color:#92400e;
classDef error    fill:#fef2f2,stroke:#ef4444,stroke-width:2px,color:#991b1b;
classDef decision fill:#fefce8,stroke:#eab308,stroke-width:2px,color:#854d0e;
classDef accent   fill:#eff6ff,stroke:#3b82f6,stroke-width:2px,color:#1e40af;
classDef muted    fill:#f8fafc,stroke:#cbd5e1,stroke-width:1px,color:#64748b;
```

### 深色（配深色 init）

```
classDef primary  fill:#312e81,stroke:#818cf8,stroke-width:2px,color:#e0e7ff;
classDef success  fill:#064e3b,stroke:#34d399,stroke-width:2px,color:#d1fae5;
classDef warn     fill:#78350f,stroke:#fbbf24,stroke-width:2px,color:#fef3c7;
classDef error    fill:#7f1d1d,stroke:#f87171,stroke-width:2px,color:#fee2e2;
classDef decision fill:#713f12,stroke:#facc15,stroke-width:2px,color:#fef9c3;
classDef accent   fill:#1e3a8a,stroke:#60a5fa,stroke-width:2px,color:#dbeafe;
classDef muted    fill:#1e293b,stroke:#475569,stroke-width:1px,color:#94a3b8;
```

### 語義對應（何時用哪個）

| class | 用途 | 範例節點 |
|-------|------|---------|
| `primary` | 主流程 / 入口 / 核心模組 | 使用者送出、main()、API Gateway |
| `success` | 成功 / 完成 / 正常結束 | 寫入成功、200 OK、Deploy done |
| `error` | 失敗 / 例外 / 中止 | 回傳錯誤、500、Rollback |
| `warn` | 警告 / 需人工注意 | Rate limited、Retry、Deprecated |
| `decision` | 判斷 / 分支節點（菱形）| 驗證通過?、是否快取? |
| `accent` | 外部系統 / 第三方 / 重點 | Oracle DB、OAuth Provider、CDN |
| `muted` | 次要 / 背景 / 已棄用 | Log、Metrics、舊版相容層 |

---

## 3. themeVariables 常用鍵速查

只列最常調的；完整清單見 mermaid.js.org/config/theming.html。**只吃 hex**。

| 鍵 | 作用 | 備註 |
|----|------|------|
| `primaryColor` | 節點預設 fill | border/text 會由它自動衍生 |
| `primaryBorderColor` | 節點預設 border | 沒設會由 primaryColor 推導 |
| `primaryTextColor` | 節點預設文字 | 對比要夠 |
| `lineColor` | 邊 / 箭頭線 | 建議用中性灰（#94a3b8）|
| `secondaryColor`/`tertiaryColor` | subgraph 背景階層 | 拉開層次 |
| `fontFamily`/`fontSize` | 字型 | GitHub 可能改寫字型，size 通常吃 |
| `noteBkgColor` 等 | sequence 的 note 配色 | |
| `darkMode` | 深色模式總開關 | 深色 init 必加 `true` |

> 規則：**themeVariables 設「全圖預設與線條」，classDef 設「分類節點」**。兩者分工，不要互搶。
