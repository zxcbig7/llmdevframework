# TIDD-EC Template — 高精度任務

> Code 生成、合規工作、品質要求高、要明列「絕對不能做」的事時必選。

```markdown
<task>
<!-- 一句話描述任務類型（轉檔、生成、改寫）-->
</task>

<instructions>
<!-- 主要指引：要保留什麼、要改什麼 -->
</instructions>

<do>
- <正向指令 1>
- <正向指令 2>
- <正向指令 3>
</do>

<dont>
- <禁令 1>
- <禁令 2>
- <禁令 3>
</dont>

<examples>
**Good 範例**：
\`\`\`
<好範例>
\`\`\`

**Bad 範例**（避免）：
\`\`\`
<壞範例>
\`\`\`
</examples>

<context>
<!-- 環境背景：tech stack、版本、約束 -->
</context>
```

## 填寫提示

- **Do/Don't 配對寫**：每個 don't 最好對應一個 do（「不要寫 raw SQL」配「用 EF Core LINQ」）。
- **Examples 是 TIDD-EC 最強武器**：給 1 good + 1 bad 比給 3 good 還有效。
- **Context** 寫具體版本（「.NET 8、EF Core 8.0.5」）避免 AI 用過時 API。
- 適合：把現有 code refactor 到符合公司 coding standards、生 boilerplate 但要避免常見坑。
