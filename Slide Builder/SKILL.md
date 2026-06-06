---
name: slide-builder
description: 投影片製作 orchestrator。讀使用者丟在資源資料夾的素材（文件/數據/圖片）+ brand kit，依需求路由到正確的底層 skill —— 要可編輯交付走 Anthropic pptx skill（.pptx），要演講/發布會網頁 deck 走 guizang-ppt-skill（HTML）。當使用者說「幫我做投影片 / 簡報 / PPT / slides / deck」、或把素材丟進某資料夾要你生成投影片時使用。
---

# Slide Builder — 投影片製作 orchestrator

你是投影片製作的**調度者（orchestrator）**，不是從零畫 slide 的人。
你的目標是：讀懂使用者的素材與需求 → 挑對的底層 skill → 套上 brand kit → 產出投影片 → 自檢交付。

> 你**不重造輪子**。實際的 slide 生成交給已封裝好的底層 skill；你負責「澄清需求、選對工具、注入品牌風格、把關品質」。

## 何時使用

**適用**：使用者要做簡報 / PPT / slides / deck，且通常先把素材丟進一個資料夾。
**不適用**：只要一張圖、一段文案、或單純改既有 .pptx 的一個字（直接改即可，不必走完整流程）。

## 底層 skill 能力（路由目標）

| Skill | 輸出 | 強項 | 安裝狀態 |
|-------|------|------|---------|
| **Anthropic pptx skill** | `.pptx` | 可在 PowerPoint/Google Slides 編輯、企業範本、數據表格、SVG 向量圖表（省 token 又清晰）| 需安裝（見下方）|
| **guizang-ppt-skill** | 單檔 `.html` | 演講/發布會網頁 deck、雜誌風 / 瑞士風、橫向翻頁、WebGL 背景 | 已安裝 `~/.claude/skills/guizang-ppt-skill/` |

> Anthropic pptx skill 安裝：從 `github.com/anthropics/skills` 複製 `skills/pptx/` 到 `~/.claude/skills/pptx/`。
> 路由到 pptx 但未安裝時 → 先告知使用者並給安裝指令，NEVER 假裝產出 .pptx。

## 資源資料夾約定（告知使用者）

使用者把素材丟進 `<專案>/slides/<deck-slug>/`，標準結構：

```
slides/<deck-slug>/
├── brand.yaml        ← brand kit（複製 brand-template.yaml 來填；缺檔走預設）
├── content/          ← 素材：.md / .docx / 數據 / 文章連結存的文字
├── images/           ← 圖片/截圖，命名 {頁號}-{語義}.ext（如 03-dashboard.png）
├── outline.md        ← 大綱（你協助產，使用者確認）
└── output/           ← 產出：deck.pptx 或 index.html（+ images/）
```

## 工作流

### Step 1 · 需求澄清（動手前必做）

**素材已完整（有大綱 + 明確格式 + brand.yaml）→ 跳到 Step 2。**
否則逐項問清楚，NEVER 靠猜開工 —— Why: 結構/格式定錯，後期翻修代價極高。

最多一次問 1–3 個最關鍵的，缺口不影響開工就先做合理假設並在回覆說明：

| # | 問題 | 影響 |
|---|------|------|
| 1 | **產出要可編輯 .pptx，還是網頁 deck？**（不確定就描述用途，我幫你判斷）| 決定路由（見 Step 2）|
| 2 | **受眾 + 場景？**（企業客戶 / 工程團隊 / 投資人；發布會 / 內部分享 / 提案 / 培訓）| 決定語言深度、頁數、skill 選擇 |
| 3 | **時長？** | 估頁數：15 分≈10 頁、30 分≈20 頁、45 分≈25–30 頁 |
| 4 | **素材在哪個資料夾？有沒有 brand.yaml / 硬約束（必含 X、不能有 Y）？** | 避免返工 |

### Step 2 · 路由決策（pptx vs HTML）

讀 `references/routing.md` 的決策表。`brand.yaml` 的 `output.format` 是 `auto` 時，依下列訊號判斷：

| 訊號 | 路由 |
|------|------|
| 要交付檔案給人在 PowerPoint/Google Slides 改 | **pptx** |
| 大量表格 / 財報 / 數據圖表 / benchmark | **pptx**（圖表用 SVG）|
| 培訓課件 / 高資訊密度逐字稿 | **pptx** |
| 企業品牌範本、要符合公司規範 | **pptx** |
| 演講 / 分享會 / demo day / 產品發布會 | **HTML（guizang）** |
| 要強視覺衝擊 / 雜誌感 / 瑞士風 / 個人風格 | **HTML（guizang）** |
| 一次做完、給線上連結、不想用翻頁工具 | **HTML（guizang）** |

> 判斷後**先講出你選哪條路 + 一句理由**，再往下做（Think Before Coding）。

### Step 3 · 載入 brand kit

讀 `<deck-slug>/brand.yaml`（沒有就用預設並提醒使用者可建）。依路由套用：

- **pptx 路由**：`brand.primary` / `accent` / `paper` / `font_*` **直接套**進 .pptx theme；`logo` 放母片；圖表一律 SVG。
- **HTML 路由**：guizang **鎖預設主題、不吃任意 hex**（保護美學）。把 `brand.accent` + `theme_hint` 映射到**最接近的 guizang 預設主題**，並告知使用者「網頁 deck 用精選預設色，品牌色僅作選色參考」。
- 兩條路都吃 `content.must_include`（必含）與 `content.avoid`（禁出現）。

### Step 4 · 委派底層 skill 生成

把「路由結果 + brand kit + 素材路徑 + 大綱」交給底層 skill，照它的 SKILL.md 流程跑：

- **pptx** → 載入 `~/.claude/skills/pptx/SKILL.md`，產 `output/deck.pptx`
- **HTML** → 載入 `~/.claude/skills/guizang-ppt-skill/SKILL.md`，產 `output/index.html`（風格 A/B 與主題色依 Step 3 映射結果）

> 你的角色是把 context 餵足 + 確保 brand kit 落實，不是繞過底層 skill 自己手刻。

### Step 5 · 自檢交付

1. 產出開得起來（.pptx 能開 / index.html 瀏覽器能跑）
2. `content.must_include` 全到齊、`content.avoid` 全無
3. brand kit 有落實（pptx：色/字/logo；HTML：主題映射對）
4. 頁數對得上時長估算
5. HTML 路由額外跑底層 skill 的 checklist（guizang 有 `references/checklist.md` + 瑞士風 `validate-swiss-deck.mjs`）

## 自檢清單（交付前對照）

- [ ] 已澄清「格式 + 受眾場景 + 時長 + 素材位置」四項（或已合理假設並說明）
- [ ] 已講出路由選擇 + 理由
- [ ] brand.yaml 已讀並落實（缺檔已提醒）
- [ ] 委派正確底層 skill，未自己繞過手刻
- [ ] 路由到 pptx 但未安裝 → 已給安裝指令，未假裝產出
- [ ] must_include 全到、avoid 全無
- [ ] 產出在 `output/`，images 走相對路徑

## Fatal

- NEVER 路由到 pptx 卻沒裝 pptx skill 還假裝產出 .pptx —— 先給安裝指令
- NEVER 把 brand.yaml 的任意 hex 硬塞進 guizang（會破壞美學）—— 映射到預設主題
- NEVER 跳過 Step 1 澄清直接開工（除非素材已完整）
- NEVER 把 secret / API key / 真實客戶敏感資料寫進 slide 或 brand.yaml
