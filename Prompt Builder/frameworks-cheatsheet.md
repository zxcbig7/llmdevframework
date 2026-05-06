# Prompt Frameworks Cheatsheet

> 10 個主流框架對照表。每個含：縮寫展開、何時用、欄位、範例、強弱項。
> 不確定挑哪個 → 看本檔末尾的「決策表」或回 [`CLAUDE.md`](./CLAUDE.md) 的決策樹。

---

## 1. CO-STAR — 內容創作王者

**Context · Objective · Style · Tone · Audience · Response**

| 欄位 | 內容 |
|------|------|
| Context | 背景資訊 |
| Objective | 想達成什麼 |
| Style | 寫作風格（「像 Stripe 公告」） |
| Tone | 情感色調（「自信但不浮誇」） |
| Audience | 目標讀者 |
| Response | 輸出格式 |

**何時用**：blog、email、社群貼文、行銷文案，**只要受眾與口吻很重要的場景**。

**範例**：

```markdown
<context>我們是新創 B2B SaaS，剛拿到 A 輪</context>
<objective>寫一封 announcement email 給訂閱用戶</objective>
<style>像 Linear changelog 那樣簡潔自信</style>
<tone>感謝但不卑微，務實不浮誇</tone>
<audience>已付費 12 個月以上的核心用戶</audience>
<response>≤300 字，含 1 個 CTA 連到 product roadmap</response>
```

✅ 強：明寫 audience + tone 避免最常見「語氣錯位」失敗
❌ 弱：沒 multi-step 機制；簡單任務用顯得肥大

---

## 2. RISEN — 多步驟流程

**Role · Instructions · Steps · End Goal · Narrowing**

| 欄位 | 內容 |
|------|------|
| Role | 指派專家身份 |
| Instructions | 整體要求 |
| Steps | 編號步驟 |
| End Goal | 可量測的成功條件 |
| Narrowing | 限制與格式 |

**何時用**：code review、研究、流程化工作、計畫產出。

**範例**：

```markdown
<role>你是 senior React engineer，負責 production app code review</role>
<instructions>review 下列 PR，找出 performance + security + maintainability 問題</instructions>
<steps>
1. 先列出修改的檔案 + 大致目的
2. 對每個檔案掃 5 類問題：re-render、type safety、a11y、security、test coverage
3. 排嚴重度（critical / warn / info）
4. 給出 actionable 建議（不只說「不好」，要說「改成 X」）
</steps>
<end-goal>輸出可直接貼到 GitHub PR review 的 markdown</end-goal>
<narrowing>≤500 字、不超過 10 條建議、引用具體行號</narrowing>
```

✅ 強：Steps 防 AI 偷工；End Goal 鎖可量測產出
❌ 弱：簡單任務太重；沒 audience 控制

---

## 3. RISE-IE — 資料處理

**Role · Input · Steps · Expectation**

**何時用**：CSV 分析、檔案轉換、報告生成。

**範例**：

```markdown
<role>你是資料分析師</role>
<input>以下是 1000 筆訂單資料（CSV）</input>
<steps>
1. 計算每月營收
2. 找出 top 10 客戶
3. 標出客單價異常（> 3σ）的紀錄
</steps>
<expectation>輸出 markdown table + 1 段 ≤100 字摘要</expectation>
```

---

## 4. RISE-IX — 創作要對風格

**Role · Instructions · Steps · Examples**

**何時用**：創意寫作、要對某個風格、pattern matching 任務。

**範例**：

```markdown
<role>你是 SaaS 文案寫手</role>
<instructions>寫 5 個 hero headline 候選</instructions>
<steps>
1. 抓 product 核心價值
2. 各候選用不同 angle（功能 / 結果 / 對比 / 情感 / 數據）
</steps>
<examples>
參考好範例：
- 「Ship faster. Less stress.」（Linear）
- 「The web framework for production」（Next.js）
不要這種：「Revolutionary AI-powered solution for modern teams」（空話、贅字）
</examples>
```

✅ 強：examples 是最強的對齊機制
❌ 弱：要花時間找好範例

---

## 5. TIDD-EC — 高精度任務

**Task · Instructions · Do · Don't · Examples · Context**

**何時用**：code 生成、合規工作、品質要求高的輸出。

**範例**：

```markdown
<task>把這段 raw SQL 轉成 ASP.NET Core EF Core LINQ</task>
<instructions>保留原查詢語意</instructions>
<do>
- 用 strongly-typed entity
- async method 加 Async 後綴
- 用 IQueryable 延遲執行
</do>
<dont>
- 不要用 raw SQL string
- 不要 .ToList() 後再 filter（會把整表載到記憶體）
- 不要省 CancellationToken
</dont>
<examples>
[1 個 good 範例 + 1 個 bad 範例]
</examples>
<context>專案用 EF Core 8、.NET 8、SQL Server</context>
```

✅ 強：明列 do/don't 是減少幻覺最有效手法
❌ 弱：寫起來最費力

---

## 6. RTF — 簡單任務

**Role · Task · Format**

**何時用**：一句話搞定的事，不需要繁複結構。

**範例**：

```markdown
<role>regex 專家</role>
<task>寫一個 regex 比對台灣手機號碼（09 開頭 10 碼）</task>
<format>JS 寫法 + 一句話解釋</format>
```

✅ 強：成本最低
❌ 弱：複雜任務 underspecified

---

## 7. RACE — 日常工作

**Role · Action · Context · Expect**

**何時用**：日常瑣事，速度優先；新手起步推薦。

**範例**：

```markdown
<role>email 助理</role>
<action>把以下英文 email 翻成繁中</action>
<context>對象是台灣的軟體業客戶</context>
<expect>保留專業詞英文（API、deployment）</expect>
```

✅ 強：四個欄位每個一句話，最易學
❌ 弱：複雜任務不夠用

---

## 8. APE — 極簡

**Action · Purpose · Expectation**

**何時用**：腦力激盪、快速一次性任務。

**範例**：

```markdown
<action>列 10 個 product naming 候選</action>
<purpose>我們在做 AI 程式碼審查工具，要好記又有專業感</purpose>
<expectation>每個含 1 句解釋，避免 AI / GPT / Code 開頭的爛大街命名</expectation>
```

✅ 強：零overhead
❌ 弱：沒 role / context，AI 會用 default 填空

---

## 9. CoT (Chain of Thought) — 複雜推理

**何時用**：debug、決策分析、數學、邏輯推理。

**範例**：

```markdown
<task>這段 code 有 race condition，找出來並解釋觸發條件</task>
<instruction>
**先 think step by step**：
1. 列出所有共享狀態
2. 列出所有 async 操作
3. 推演哪兩個操作交錯會出問題
4. 給出最小重現順序
5. 提出修法
每步驟先寫推理，再給結論。
</instruction>
[code]
```

✅ 強：複雜推理品質提升明顯
❌ 弱：簡單任務反而拖慢、輸出冗長

---

## 10. CoD (Chain of Density) — 摘要 / 壓縮

**何時用**：把長文壓縮成精華；逐輪提高資訊密度。

**範例**：

```markdown
<task>把以下 10 頁文章摘要成 200 字</task>
<process>
跑 3 輪：
- 輪 1：自由摘要 200 字
- 輪 2：找出輪 1 漏掉的 3 個關鍵概念，重寫 200 字加入
- 輪 3：再找漏掉的 3 個，重寫 200 字
最終輸出輪 3 版本。
</process>
```

✅ 強：壓縮品質遠勝一次寫成
❌ 弱：耗 token；非摘要任務不適用

---

## 決策表（懶人版）

| 你想... | 選 |
|---------|-----|
| 寫 email / 文案 / blog | **CO-STAR** |
| Code review / 多步驟流程 | **RISEN** |
| CSV / 資料轉換 | **RISE-IE** |
| 對特定風格寫東西 | **RISE-IX** |
| Code 生成 / 合規 | **TIDD-EC** |
| 一句話小任務 | **RTF** |
| 日常雜事 | **RACE** |
| 腦力激盪 | **APE** |
| 解 bug / 推理 | **CoT** |
| 文章摘要 | **CoD** |
| **真的不知道** | **通用 4 段（context / task / constraints / format）** |

---

## 進階：框架可組合

複雜需求可混合：

- **CO-STAR + STOKE**：對外溝通 + 需要領域知識（金融、醫療文案）
- **RISEN + TIDD-EC**：多步驟流程 + 高精度（生產級 code 重構）
- **RTF + CoT**：簡單任務但要解釋推理（教學情境）

> 組合不是萬能；**先選一個主框架，覺得不夠再補欄位**。
