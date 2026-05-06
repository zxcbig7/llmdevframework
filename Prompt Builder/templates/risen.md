# RISEN Template — 多步驟流程

> Code review、研究、計畫產出。涉及「依序執行 + 可驗收」時必選。

```markdown
<role>
<!-- 指派專家身份：senior X engineer / 資料科學家 / 法務顧問 -->
</role>

<instructions>
<!-- 整體要做什麼（一段話）-->
</instructions>

<steps>
1.
2.
3.
4.
5.
</steps>

<end-goal>
<!-- 可量測的成功條件：產出什麼、給誰看、達到什麼標準 -->
</end-goal>

<narrowing>
<!-- 限制與格式：長度、輸出格式、避用詞、必須包含的內容 -->
</narrowing>
```

## 填寫提示

- **Steps** 是 RISEN 的核心，**MUST 編號**——AI 才不會跳步驟。
- **End Goal** 要可驗收（「能直接貼到 GitHub PR」勝過「review 得很好」）。
- **Narrowing** 把所有「不要做的事」放這裡，避免 AI 越界。
- 步驟超過 7 個 → 拆成 prompt chain（一個 prompt 跑 4–5 步是上限）。
