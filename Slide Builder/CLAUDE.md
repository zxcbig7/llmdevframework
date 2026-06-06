# Slide Builder — 投影片製作 orchestrator 規範

<system_context>
投影片製作的調度層。不從零畫 slide，而是讀使用者素材 + brand kit，依需求路由到底層 skill：
要可編輯交付 → Anthropic pptx skill（.pptx）；要演講網頁 deck → guizang-ppt-skill（HTML）。
本檔是框架側的規範入口；實際工作流在 `SKILL.md`（可安裝成 reusable skill）。
</system_context>

<critical_notes>
- MUST 動手前先澄清「格式 + 受眾場景 + 時長 + 素材位置」四項（素材已完整可跳過）
  Why: 結構/格式定錯，後期翻修代價極高（Karpathy Think Before Coding）
- MUST 判斷路由後先講出「選哪條路 + 一句理由」再往下做
- MUST 委派底層 skill 生成，NEVER 繞過自己手刻 slide
  Why: 底層 skill 封裝了大量美學/版式教訓，手刻必然更差更慢
- NEVER 路由到 pptx 卻沒裝 pptx skill 還假裝產出 —— ALWAYS 先給安裝指令
- NEVER 把 brand.yaml 的任意 hex 硬塞進 guizang —— ALWAYS 映射到預設主題（保護美學）
- 預設繁體中文，technical terms 保留英文
</critical_notes>

<file_map>
CLAUDE.md            - 本檔（框架側規範入口）
SKILL.md             - orchestrator 工作流（複製到 ~/.claude/skills/slide-builder/ 成可安裝 skill）
brand-template.yaml  - brand kit 模板（複製到專案 slides/<deck>/brand.yaml 填寫）
references/
  └── routing.md     - pptx vs HTML 決策樹 + 能力對照 + brand→主題映射 + SVG 圖表原則

底層 skill（被路由的對象，不在本資料夾）：
~/.claude/skills/guizang-ppt-skill/  - HTML 網頁 deck（已安裝）
~/.claude/skills/pptx/               - Anthropic .pptx skill（需自 github.com/anthropics/skills 安裝）
</file_map>

<paved_path>
**資源資料夾約定**：`<專案>/slides/<deck-slug>/`
- `brand.yaml`（複製 `brand-template.yaml`）· `content/`（素材）· `images/`（`{頁號}-{語義}.ext`）· `outline.md`（大綱）· `output/`（產出）

**五步工作流**（細節見 `SKILL.md`）：
1. 需求澄清（四項）→ 2. 路由決策（讀 `references/routing.md`）→ 3. 載入 brand kit → 4. 委派底層 skill → 5. 自檢交付

**路由速查**：可編輯/數據/課件/企業範本 → pptx；演講/發布會/視覺/個人風格 → HTML。不明確就問「做完別人主要是 (a) 打開來改 (b) 你站著講」。

**brand kit 套用差異**：
- pptx → 任意 brand 色/字直接套，圖表用 SVG
- HTML → guizang 鎖預設，brand 色僅作映射依據（告知使用者）
</paved_path>

<common_tasks>
- 啟動 → 跑 slide-builder skill（先安裝：複製 `SKILL.md` 到 `~/.claude/skills/slide-builder/SKILL.md`），或在對話直接說「幫我做投影片」並指素材資料夾
- 安裝底層 pptx skill → 複製 `github.com/anthropics/skills` 的 `skills/pptx/` 到 `~/.claude/skills/pptx/`
- 新專案 deck → 建 `slides/<deck-slug>/`，複製 `brand-template.yaml` 成 `brand.yaml` 填寫
- 改路由邏輯 / 能力對照 → 改 `references/routing.md`
- 新增可路由的底層 skill → 在 `references/routing.md` 能力矩陣加一列 + `SKILL.md` Step 2 加訊號
</common_tasks>

<example>
- 路由決策樹 → `references/routing.md`, search:`決策樹`
- brand→主題映射 → `references/routing.md`, search:`預設主題映射`
- 工作流五步 → `SKILL.md`, search:`### Step 1`
</example>

<hatch>
- 只改既有 .pptx 一兩個字 → 直接改，不必走完整流程
- 素材已含完整大綱 + 明確格式 + brand.yaml → 跳過 Step 1 直接路由
- 使用者堅持要任意 hex 的 HTML deck → 改用 pptx 路由（pptx 才支援任意品牌色），或明說 guizang 限制讓他選預設
</hatch>

<fatal_implications>
- NEVER 假裝產出 .pptx（未裝 pptx skill 時）
- NEVER 把任意 hex 硬塞 guizang 破壞美學
- NEVER 把 secret / API key / 真實客戶敏感資料寫進 slide 或 brand.yaml
- NEVER 自己手刻 slide 繞過底層 skill
</fatal_implications>
