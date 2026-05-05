# Prompt Principles — 元規範

<system_context>
寫 CLAUDE.md / slash command / 任何 prompt 的元規則。
來源：Anthropic 官方 Claude 4 prompt engineering 12 技巧。
所有新文件 MUST 對照本檔自我檢查；現有文件迭代時逐步補齊。
</system_context>

<critical_notes>
- MUST 寫 prompt 時對照本檔 `<self-check>` 跑一次
- MUST 規則寫法用「NEVER X — ALWAYS Y instead — Why: Z」三段式（重要規則才需要，普通規則用單句）
- MUST 給 good/bad 對照範例（multi-shot）勝過純文字描述
- MUST 解釋「為何這樣做」而非只下命令（add context 原則）
- NEVER 只寫禁令不給替代方案（違反「Tell what TO do」原則）
- NEVER 用 vague 字眼（「good practice」「合理」「適當」）→ 必須具體可驗證
</critical_notes>

<file_map>
CLAUDE.md          - 本檔（元規範）
self-check.md      - 寫完 prompt 後跑的 12 點 checklist
</file_map>

<paved_path>
## 4 個基本原則（最重要，先記這 4 個）

1. **Be Explicit（明確）**
   - Claude 4 是 precise executor，不是 creative interpreter
   - 模糊指令 = 模糊輸出
   - 範例：❌「整理這份 code」 → ✅「依下列 5 步驟整理：1. 抽 function、2. 加 type、3. ...」

2. **Add Context（解釋 why）**
   - 講原因 → Claude 能在邊界情況做判斷
   - 範例：❌「不要用 any」 → ✅「不要用 any，因為會關閉 type checking 失去 IDE 提示。未知型別用 unknown + type guard」

3. **Examples 要嚴選**
   - Claude 學範例學得很細，垃圾範例 = 垃圾輸出
   - 提供 3–5 個多樣範例 > 一個範例
   - 必要時給「good vs bad」對照

4. **Tell what TO do（正向指令）**
   - ❌「don't use markdown」 → ✅「use flowing paragraphs」
   - ❌「不要寫太長」 → ✅「每段 ≤3 句、總字數 ≤200」

## 12 技巧（依重要性排序）

| #   | 技巧              | 何時用             | 怎麼套到 CLAUDE.md / slash command                            |
| --- | ----------------- | ------------------ | ------------------------------------------------------------- |
| 1   | Prompt Generator  | 不知道從哪寫起     | 用 Claude 產草稿，自己再修                                    |
| 2   | Explicit & Direct | 永遠               | 每條規則具體、可驗證、有編號                                  |
| 3   | Multi-shot 範例   | 規則複雜           | 給 3–5 個 good/bad 對照                                       |
| 4   | Chain of Thought  | 複雜任務           | slash command 加「先列步驟再執行」                            |
| 5   | XML Tagging       | 結構化 prompt      | `<system_context>` `<critical_notes>` `<patterns>` 等（已用） |
| 6   | Role Assignment   | slash command 開頭 | 「你是 X 領域 expert，你的目標是 Y」                          |
| 7   | Pre-filling       | 強制輸出格式       | 給範本開頭幾行，Claude 接續                                   |
| 8   | Prompt Chaining   | 多階段任務         | 拆 pass / step（SDD、proc-analyze 已用）                      |
| 9   | Long-Text 處理    | 吃大檔案           | 文件先放、問題後放、加 XML 包                                 |
| 10  | Templates         | 重複任務           | `{{variable}}` 變數化（已用）                                 |
| 11  | Prompt 改進工具   | 迭代               | Anthropic console 的 improve prompt                           |
| 12  | Extended Thinking | 真正困難問題       | slash command 加「think hard」「ultrathink」觸發              |
</paved_path>

<patterns>
## CLAUDE.md / slash command 寫法 pattern

### Role assignment 開頭（slash command 必加）

```markdown
你是 <領域> 的 <角色>，目標是 <一句話目標>。
你的回答 MUST <關鍵限制>。
```

範例：

```markdown
你是 Oracle PL/SQL static analyzer，目標是把 10K+ 行 procedure 摘要成結構化筆記。
你的回答 MUST 標行號、MUST 用繁體中文、NEVER 編造行號。
```

### 規則三段式（critical_notes 用）

```markdown
- NEVER 在 controller 寫 business logic
  ALWAYS 把邏輯移到 service layer
  Why: controller 該專心處理 HTTP 關注點，混業務邏輯會造成測試困難 + 重用性低
```

> 一般規則一行 NEVER/ALWAYS 即可；重要的、容易違反的、有歷史教訓的才展開三段式。

### Good/Bad 對照範例

```markdown
**範例：variable naming**

✅ Good
\`\`\`ts
const isUserActive = user.status === 'active';
\`\`\`

❌ Bad
\`\`\`ts
const x = user.status === 'active';  // 看不出語意
\`\`\`

Why：boolean 變數加 is/has/can 前綴讓 reader 一眼看出是判斷
```

### Chain of Thought 觸發句（slash command）

```markdown
## 執行前必做

1. 先**列出**你要走的 N 個步驟（列出來，不要直接做）
2. 確認步驟覆蓋所有 critical_notes
3. 再開始執行

執行時每完成一步驟，**回報該步驟結果再進下一步**。
```

### Long-Text 處理（讀大檔）

```markdown
## 讀檔順序

1. 先讀檔案（用 Read tool 或 grep）
2. 把讀到的內容**包進 <document> 標籤**，clearly 標檔名
3. 用 <task> 標籤寫你要做的事
4. 引用時先 quote 再分析（"先抓出與問題相關的 5 行 → 再解釋"）
```

### Pre-filling 強制格式

```markdown
完成後輸出格式（必照此開頭）：

\`\`\`
## 檢查結果摘要
- 檔案數：
- CRITICAL：
- WARN：
- INFO：

## CRITICAL（部署前必修）
...
\`\`\`
```

### Extended Thinking 觸發

```markdown
這是複雜任務。**先 ultrathink** 規劃整體策略，再開始執行。
```

> Claude Code 支援 `think` / `think hard` / `ultrathink` 觸發詞，分配的 thinking budget 不同。
</patterns>

<example>
**重寫前後對照**

❌ Before（vague + 純禁令 + 沒 why）：

```markdown
- 不要用 any
- 不要在 effect 裡 setState
- 命名要好
```

✅ After（明確 + 正向 + 有 why + 有範例）：

```markdown
- NEVER 用 `any`，ALWAYS 用 `unknown` + type guard
  Why: any 關閉整段 type checking，unknown 強制收縮型別
  範例: `function parse(x: unknown) { if (typeof x === 'string') ... }`

- NEVER 在 useEffect 裡呼叫 setState 造成依賴循環
  ALWAYS 先想能否用 derived state（直接 const x = computeFrom(props)）
  Why: setState 在 effect 觸發 re-render → 再觸發 effect → 無限 loop

- ALWAYS 變數命名能自我說明：boolean 加 is/has/can、function 動詞開頭
  範例: `isLoading`、`hasPermission`、`fetchUser`
```
</example>

<self-check>
## 寫完 prompt / CLAUDE.md 跑一次（12 點 checklist）

對照本檔產生的文件 / 改動：

- [ ] **#1 明確**：每條規則具體可驗證，沒有「good」「合理」「適當」這類模糊字
- [ ] **#2 編號**：步驟流程有編號，方便對照
- [ ] **#3 範例**：複雜規則至少有 1 組 good/bad 對照
- [ ] **#4 CoT**：slash command 有要求 Claude 先列步驟再執行
- [ ] **#5 XML**：用 `<system_context>` 等 tag 結構化（CLAUDE.md 必）
- [ ] **#6 Role**：slash command 開頭有「你是 X，目標 Y」
- [ ] **#7 Pre-fill**：要求輸出格式時給開頭模板
- [ ] **#8 Chaining**：複雜任務拆 pass / step
- [ ] **#9 Long-text**：讀大檔的指令說明檔案放前、任務放後
- [ ] **#10 Template**：重複欄位用 `{{var}}` 或固定 schema
- [ ] **#11 Why**：critical_notes 解釋為何（不只下令）
- [ ] **#12 Thinking**：困難任務允許 `ultrathink`
</self-check>

<hatch>
- Trivial change（修錯字、補一條範例）→ 不必跑完整 12 點 self-check，挑相關項即可
- 已有文件迭代 → 一次套 1–2 個技巧不要全改，避免改壞
- 純規範說明（沒互動）→ #4 CoT、#6 Role、#12 Thinking 跳過
</hatch>

<fatal_implications>
- NEVER 違反「Tell what TO do」：寫 NEVER 必須配 ALWAYS（除非是絕對禁令如 fatal_implications）
- NEVER 抄這 12 技巧的字面卻不檢查實際 prompt 是否套用
- NEVER 把 self-check 當形式（每點都要實際對照文件）
</fatal_implications>
