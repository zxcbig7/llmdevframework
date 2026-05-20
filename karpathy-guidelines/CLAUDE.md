# Karpathy Guidelines — LLM 編碼四原則

<system_context>
來源：Andrej Karpathy 對 LLM 輔助編碼常見陷阱的觀察，提煉為四條行為原則。
適用：所有非 trivial 編碼任務開始前，作為行為基準線。
目標：減少無謂的 diff、過度設計、靜默假設三大問題。
</system_context>

<critical_notes>
- MUST 動工前說出假設；不確定時問，不要靜默猜測
  Why: 靜默猜錯 = 做錯整件事，代價遠高於問一個問題
- MUST 只實作使用者要求的功能，不多不少
- NEVER 動不相關的 code（格式、命名、refactor）除非被明確要求
  Why: 每行改動都要能追溯到使用者請求，額外改動製造 noisy diff + 引入額外風險
- NEVER 替「可能的未來需求」預先設計 abstraction
  Why: 未來需求未確定，過早抽象增加複雜度卻沒有實際被使用
- MUST 把模糊任務轉成可驗收的成功標準，再開始執行
</critical_notes>

<paved_path>
## 1. Think Before Coding — 先想，再動手

**有歧義時，列出來讓使用者選，不要靜默選一個方向。**

✅ Good
```
使用者：「加一個 export 功能」
→ 先問：「你指的是 CSV 下載、API endpoint 還是背景排程 job？各有不同實作方向。」
```

❌ Bad
```
使用者：「加一個 export 功能」
→ 直接做了 CSV 下載（靜默假設，使用者其實要的是 API endpoint）
```

規則：
- 有多種合理解讀 → 列出讓使用者選，不自行決定
- 不確定就問；確定後再動工
- 主動說出 tradeoff（「做法 A 快但不支援大量資料；做法 B 需多 2 天」）

---

## 2. Simplicity First — 最小可解方案

**只解今天的問題，不解想像中的明天。**

Test：一個資深工程師看到這份 code，會不會說「這太複雜了」？

✅ Good
```ts
function applyDiscount(price: number, rate: number): number {
  return price * (1 - rate);
}
```

❌ Bad
```ts
// 使用者只要一個折扣計算，卻做了 Strategy pattern + 設定檔 + 預留擴充點
class DiscountStrategy { abstract apply(price: number): number; }
class ConfigurableDiscountEngine { ... }
```

規則：
- NEVER 加使用者沒要求的功能
- NEVER 為「只用一次」的 code 做 abstraction
- NEVER 加「萬一將來要…」的彈性設計
- NEVER 處理不可能發生的錯誤情境（framework / 型別系統已保證的邊界不用再 guard）
- 200 行能寫成 50 行時，重寫

---

## 3. Surgical Changes — 只動你該動的

**改動範圍 = 使用者請求的範圍，不多不少。**

Test：每一行改動都能直接追溯到使用者的請求嗎？

✅ Good
```
使用者：「修 email 驗證空字串的 bug」
→ 只改 email 驗證那一行條件
```

❌ Bad
```
使用者：「修 email 驗證空字串的 bug」
→ 改了驗證邏輯 + 順手改縮排 + 重寫旁邊的 username 驗證 + 加 type hint
（noisy diff，使用者難以 review，引入額外風險）
```

規則：
- NEVER 改不相關的 code、comment、格式
- NEVER refactor 沒壞掉的 code
- ALWAYS 沿用既有 code style（就算你有更好的寫法）
- 發現不相關的 dead code → 提到，但不刪（除非被要求）
- 你的改動造成的 orphan import/variable → 移除；改動前就存在的 dead code → 保留

---

## 4. Goal-Driven Execution — 先定終點，再出發

**把模糊指令轉成可驗收的目標，讓自己能獨立執行完。**

✅ Good
```
任務：「加 email 驗證」
轉換為：
1. 寫測試：輸入空字串 → 應回傳錯誤 → verify: 測試先失敗（TDD red）
2. 實作驗證邏輯 → verify: 測試通過
3. 補 edge case（null、whitespace）→ verify: 全部通過
```

❌ Bad
```
任務：「加 email 驗證」
→ 直接寫 code，沒有明確成功標準
→ 做完不知道算不算完成，需要頻繁問「這樣可以嗎？」
```

規則：
- 收到模糊任務 → 先轉成「目標 + verify 步驟」
- 每個步驟有明確驗收點（跑什麼 test、看什麼 output、測什麼行為）
- 清晰的標準讓自己能 loop 執行到完成，不必每步問使用者
</paved_path>

<hatch>
- Trivial change（typo、文案、一行 CSS）→ 不必跑完整四原則，直接做
- 使用者說「大膽做，不用問」→ 降低 Think Before Coding 的提問頻率，但 Simplicity First 和 Surgical Changes 仍維持
- 探索性 spike（「試試看能不能做」）→ Simplicity First 適度放寬，spike 不等於生產品質
</hatch>

<fatal_implications>
- NEVER 靜默猜測使用者意圖後直接實作（猜錯 = 整件事做錯，且沒機會被糾正）
- NEVER 在 PR diff 裡夾帶和任務無關的改動（無論改動多「合理」）
- NEVER 因為「很快就能加」就加進去（快不是加功能的理由）
</fatal_implications>
