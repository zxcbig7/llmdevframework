# Prompt Builder — 寫好 prompt 的個人工具箱

<system_context>
給「不確定怎麼問 AI」的使用者用的 prompt 改造工具箱。
不是元規範（那是 `prompt-principles/` 的事），而是**實戰工具**：把腦中模糊的需求結構化成 AI 看得懂的 prompt。
搭配 `/prompt-improve` slash command 一鍵改寫。
</system_context>

<critical_notes>
- MUST 區分清楚：本資料夾是「使用者寫 prompt」的工具；`prompt-principles/` 是「寫 CLAUDE.md / slash command」的元規範
- MUST 任何改寫優先用 XML tags（Claude 原生支援，比純文字段落輸出更穩）
- MUST 避開 4 大常見錯誤：vague / 缺 context / overload / 沒例子
- ALWAYS 給「為何選這框架」的理由，不要硬套
- NEVER 把所有 prompt 都套同一個框架——簡單任務 RTF 就夠，複雜任務再 CO-STAR / RISEN
- NEVER 一個 prompt 超過 300 字（80–200 字最佳，超過通常是雜訊不是訊號）
</critical_notes>

<file_map>
CLAUDE.md                  - 本檔（框架選用 + 5 品質維度 + 4 大錯誤）
frameworks-cheatsheet.md   - 10 個主流框架對照表 + 範例
prompt-improve-command.md  - `/prompt-improve` slash command
templates/                 - 即填即用模板
  ├── co-star.md           - 內容創作
  ├── risen.md             - 多步驟流程
  ├── tidd-ec.md           - 高精度（dos/don'ts）
  ├── rtf.md               - 簡單任務
  └── rise-ix.md           - 創作 + 範例
</file_map>

<paved_path>
## 使用流程

```text
腦中有個模糊需求
  ↓
跑 /prompt-improve <你的草稿>
  ↓
Claude 診斷品質（5 維度評分）+ 問 3–5 釐清問題
  ↓
你回答 → Claude 套合適框架 → 輸出結構化 prompt
  ↓
複製去用 / 再迭代
```

## 5 個品質維度（自我評分）

寫完 prompt 對照打分（1–5）：

| 維度 | 問自己 | 1 分 | 5 分 |
|------|--------|------|------|
| **Clarity** | 這需求換個人讀懂得了嗎？ | 「幫我寫個東西」 | 「寫一封 200 字 email 給...」 |
| **Specificity** | 有沒有具體可驗證的目標？ | 「寫好一點」 | 「每段 ≤3 句、含 1 個 CTA」 |
| **Context** | AI 知道背景嗎？ | 沒講受眾 / 場景 | 「對象是初學投資者，不懂專業術語」 |
| **Completeness** | 該給的限制都給了嗎？ | 沒講格式 / 長度 / 風格 | 「Markdown、≤500 字、條列為主」 |
| **Structure** | 用了 XML / 編號 / 段落？ | 一段流水帳 | `<context> <task> <format>` 分段 |

> 任一維度 ≤2 分 → 直接跑 `/prompt-improve` 重寫
> 全部 ≥4 分 → 直接送

## 4 大常見錯誤（先避開這個比學框架更重要）

### 1. Vague（模糊）

❌ Bad

```text
幫我整理一下這份報告
```

✅ Good

```text
把以下 3 頁報告濃縮成 5 個 bullet point，每點 ≤25 字，給 CFO 看。
```

Why：模糊 prompt → 模糊輸出。LLM 預測「最統計平均的回應」，沒給線索就給你最普通的版本。

---

### 2. 缺 Context（缺背景）

❌ Bad

```text
這段 code 怎麼優化？
[code]
```

✅ Good

```text
<context>
這段 code 是 React e-commerce 結帳頁的 cart context，目前每次 add to cart 整頁都會 re-render。
我們用 Zustand 管狀態，不能引入新的 lib。
</context>
<task>
找出造成多餘 re-render 的根因並提出修法（保留現有 API surface）。
</task>
[code]
```

Why：AI 沒讀心術，假設它知道你的 stack / 限制 / 目標 = hallucination 起點。

---

### 3. Overload（塞太多）

❌ Bad

```text
幫我設計一個 OAuth 系統，前端用 React 後端 ASP.NET，用 Google + GitHub login，要記住登入狀態，要 refresh token，要 SSO，要 RBAC，要 audit log，順便給我寫測試...
```

✅ Good（拆 prompt chain）

```text
Prompt 1：設計 OAuth flow（只到 token 取得，不含 RBAC）
Prompt 2：refresh token 機制
Prompt 3：RBAC 整合
...
```

Why：一個 prompt 包山包海 → AI 只會給你淺層通用答案；分階段給 → 每階段都深入。

---

### 4. 沒例子（少了 multi-shot）

❌ Bad

```text
寫得專業一點
```

✅ Good

```text
風格參考：
範例 A：「Stripe announces support for...」（簡潔、自信、無贅字）
範例 B：「After months of work, we're shipping...」（有溫度、開發者語氣）
請依範例 A 的風格寫。
```

Why：「專業」每人定義不同；給範例 = 給定義。
</paved_path>

<patterns>
## 框架快速選擇（決策樹）

```text
你要做什麼？
├── 寫東西（信、文章、文案）→ CO-STAR（含 audience + tone）
├── 跑流程（多步驟、code review、計畫）→ RISEN（含 steps + 結束條件）
├── 處理資料（CSV → 報告、轉檔）→ RISE-IE（input → output）
├── 創作要對風格（要範例）→ RISE-IX 或 CREATE
├── 高精度要求（合規、code gen）→ TIDD-EC（明列 do/don't）
├── 簡單任務（一句話搞定）→ RTF（role + task + format）
├── 複雜推理（除錯、決策）→ CoT（chain of thought）
├── 摘要 / 壓縮 → CoD（chain of density）
└── 對外溝通（受眾為先）→ CO-STAR + STOKE 加 knowledge 欄
```

> 細節對照表見 [`frameworks-cheatsheet.md`](./frameworks-cheatsheet.md)。

## 通用 4 段萬用模板（不確定用哪個框架就用這個）

```markdown
<context>
背景：誰在做、為何做、相關限制
</context>

<task>
具體要 AI 做什麼（一句話 + 可驗證標準）
</task>

<constraints>
- 必做：...
- 不做：...
- 限制：長度、tech stack、語言、避用詞
</constraints>

<format>
輸出格式：Markdown / JSON / table / code with comments / 純段落
範例片段（可選）：...
</format>
```

> 80% 的日常需求這個框架就夠了；不夠再換 CO-STAR / RISEN。

## XML tags：給 Claude 用的最佳結構

Anthropic 訓練時就餵 XML 結構化的 prompt，Claude 對 tag 敏感度高於 markdown heading。

✅ Good（Claude 識別最強）

```markdown
<context>產品是 B2B SaaS</context>
<task>寫 landing page hero 文案</task>
<style>like Linear, like Vercel</style>
<format>標題 1 行 + 副標 1 行 + CTA 1 個</format>
```

❌ OK 但較弱

```markdown
## Context
產品是 B2B SaaS

## Task
寫 landing page hero 文案
...
```

Why：tag 觸發 Claude 內部的 pattern recognition layer，輸出結構更穩定。
</patterns>

<common_tasks>
- **想不到怎麼問** → `/prompt-improve <粗略草稿>`，Claude 會問你 3–5 題後重寫
- **要套特定框架** → 看 [`frameworks-cheatsheet.md`](./frameworks-cheatsheet.md) 找對應 → 複製 `templates/<framework>.md` 填空
- **prompt 太長想精簡** → 套 CoD（chain of density）逐輪壓縮
- **AI 老是答不到點** → 對照 5 個品質維度自評，找出最低分那項補強
</common_tasks>

<example>
## 完整改造範例

❌ Before（一句模糊）

```text
幫我寫個 React component
```

✅ After（套通用 4 段模板）

```markdown
<context>
B2B SaaS 後台儀表板，使用 React 19 + TypeScript strict + Tailwind 4。
團隊已有 design system（shadcn/ui），不引入新 lib。
</context>

<task>
寫一個 `MetricCard` component：顯示單一 KPI（標題 + 數值 + 趨勢箭頭 + 變化百分比）。
</task>

<constraints>
- Props 用 interface，名稱 PascalCase 不加 I 前綴
- 數值 > 1000 自動轉 1.2k 格式
- 趨勢箭頭：上升綠、下降紅、持平灰
- 不寫 inline style，用 Tailwind classes
- 必須能被 React.memo 包住（props 都是 primitive 或 stable ref）
</constraints>

<format>
- 一個 `.tsx` 檔案
- 含 props interface + component
- 註解只在 WHY 不明顯處寫
- 結尾附 1 個 usage example
</format>
```

兩者輸出品質差異：
- Before：通用 button / card 範例，跟你 stack 完全不合
- After：直接可用的 component，符合命名 / Tailwind / memo 要求
</example>

<hatch>
- **Trivial 任務**（一句話：「翻譯這段成英文」）→ 不用套框架
- **探索性對話**（聊想法、找方向）→ 反而要保留模糊性，AI 才會給多選項
- **已經很熟的領域** → 你的隱含 context 可以省，但 AI 不行——還是要寫出來
- **chat 多輪精修** → 第一輪給 4 段模板，後續修改用一句話即可（context 已建立）
</hatch>

<fatal_implications>
- NEVER 把 secret / API key / 真實 customer data 寫進 prompt
- NEVER 假設 AI 記得上一個 session 的 context（每個 session 重新開始）
- NEVER 為了套框架犧牲清楚——清楚 > 結構漂亮
- NEVER 在生產系統 prompt 沒做 evaluation 就上（個人用無妨，產品用要 A/B）
</fatal_implications>
