# Brain Dump Template — 思緒不連貫時的鷹架

> 適合「腦中跳來跳去、寫出來缺主詞 / 缺前提 / 直接跳結論」的情境。
> 不是最終 prompt，是 **半成品**，寫完丟給 `/prompt-improve` 整理成連貫 prompt。

## 為何需要這個

人在腦中已經跑過好幾步推理才打字，文字常常只寫第 5 步：
- 「為何都被指派到 dnslocal=false 的 node?」 ← 跳過：哪個 deployment？你期待什麼？
- 「會出現 ns 對應 node 的可能?」 ← 跳過：主詞、為什麼問

這個模板強迫你把跳過的步驟補回來。

## 模板（複製填空）

```markdown
<doing>
<!-- 我現在在做什麼（一句話，主詞要寫出來）-->
<!-- 範例：我在公司部署 K8s，看 ArgoCD app 的 CD template -->
</doing>

<observed>
<!-- 我看到 / 遇到的事實（不下結論，只描述）-->
<!-- 範例：deployment template 寫了 nodeSelector: env=prod -->
</observed>

<expected>
<!-- 我預期會發生什麼 -->
<!-- 範例：以為 pod 會排到 dnslocal=true 的 node -->
</expected>

<actual>
<!-- 實際發生什麼 -->
<!-- 範例：pod 全部跑到 dnslocal=false 的 node -->
</actual>

<question>
<!-- 我具體想知道什麼（不要問「怎麼辦」，問「為什麼」或「有哪些做法」）-->
<!-- 範例：是什麼機制決定 nodeSelector 之外還會被加條件？-->
</question>

<tried>
<!-- 我已經試過 / 確認過什麼（避免 AI 重複建議）-->
<!-- 範例：kubectl get deployment 看過 yaml，nodeSelector 確實寫 env=prod -->
</tried>
```

## 填寫提示

- **doing 想不到主詞** → 想像在跟新同事介紹自己手上的工作
- **observed vs expected vs actual** 三段是核心：很多斷裂發生在「跳過 expected 直接講 actual」，AI 不知道你為什麼覺得這是問題
- **question 怕問錯** → 寫不出來代表你還沒想清楚問題本身，先停下來想
- **tried 沒有就空著** → 但有的話一定要寫，省彼此時間

## 哪些情境特別建議用

- 排查 bug、追原因（容易跳過 expected）
- 問 infra / 架構問題（容易省略 context）
- 一邊寫一邊發現新問題（容易主題漂移）
- 用語音轉文字後（轉出來常常斷句怪）

## 哪些情境不需要

- 簡單翻譯 / 格式轉換 → RTF 就夠
- 已經很清楚的需求 → 直接套 universal-4-part
- 探索性對話（聊想法、找方向）→ 保持模糊反而好

## 輸出後怎麼用

```text
1. 把填好的 brain-dump 內容整段丟給 AI
2. 加一句：「請依此整理成連貫 prompt，缺的東西反問我」
3. 或直接跑 /prompt-improve <貼上內容>
```

`/prompt-improve` 會偵測到 Coherence 維度低分時主動追問，不用你自己挑問題。
