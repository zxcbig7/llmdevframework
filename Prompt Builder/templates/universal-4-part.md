# Universal 4-Part Template（萬用模板）

> 80% 日常需求用這個就夠。不知道挑哪個框架時的安全選擇。

```markdown
<context>
<!-- 背景：誰在做、為何做、相關限制 -->
<!-- 範例：B2B SaaS 後台儀表板，React 19 + TypeScript strict + Tailwind 4 -->
</context>

<task>
<!-- 具體要 AI 做什麼（一句話 + 可驗證標準）-->
<!-- 範例：寫一個 MetricCard component 顯示單一 KPI -->
</task>

<constraints>
<!-- 必做與不做 -->
- 必做：
  -
  -
- 不做：
  -
  -
- 限制：長度、tech stack、語言、避用詞
</constraints>

<format>
<!-- Markdown / JSON / table / code with comments / 純段落 -->
<!-- 範例：一個 .tsx 檔案，含 props interface + component，註解只在 WHY 不明顯處寫 -->
</format>
```

## 填寫提示

- **Context** 想不到寫什麼 → 假設 AI 完全沒看過你的專案，要寫多少才能讓它入門？
- **Task** 太抽象 → 加可驗證條件（「≤300 字」「3 個 bullet」「含程式碼範例」）
- **Constraints** 想不到 → 列你最怕 AI 給你什麼錯誤的版本，反過來寫成「不做」
- **Format** 沒想法 → 預設 Markdown；要餵下游程式才用 JSON
