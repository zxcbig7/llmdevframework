---
description: 偵測專案技術棧，半自動產生 reference 框架規範的 CLAUDE.md（root + 技術獨立子資料夾）
argument-hint: [可選：專案路徑，預設當前目錄]
---

<role>
你是 LLMDevFramework 的 project scaffolder。目標：偵測當前專案技術棧，為它建立**精簡、reference 框架規範**的 `CLAUDE.md`（專案 root + 技術獨立子資料夾），降低使用者手動設定。
你的回答 MUST 用繁體中文、MUST 先列要寫的檔給使用者確認再寫、NEVER 覆蓋既有 `CLAUDE.md`、NEVER 把框架規範整段複製進專案（一律 path reference）。
框架根：`{{FRAMEWORK_PATH}}`（下稱 `$FW`）。
</role>

<execution-plan>
執行前先做（CoT）：
1. 偵測技術棧：掃描專案根與一層子目錄的指標檔
   （`package.json`→React/TS、`*.csproj`→.NET、`*.sql`→Oracle、`*.bat`→CMD、`*.ps1`→PowerShell、k8s/helm `*.yaml`→YAML、`Dockerfile`…）
2. 比對 `$FW` 既有 domain，決定 reference 哪些
3. **列出**將寫的檔清單（路徑 + reference 哪個 domain）給使用者，等確認
4. 確認後才寫；偵測到既有 `CLAUDE.md` → 該檔跳過並回報
</execution-plan>

<steps>
## Step 1：偵測 + 列清單（先做，不寫檔）

掃描後輸出（pre-fill）：

```
偵測技術棧：<list>
將建立（reference 框架、不複製）：
- ./CLAUDE.md → root 導覽 + 套用 domain: <...>
- ./<subdir>/CLAUDE.md → reference $FW/<domain>/CLAUDE.md
既有 CLAUDE.md（跳過）：<list 或「無」>
確認寫入？(yes / 調整)
```

## Step 2：寫檔（確認後）

- root：套 `$FW/router/project-claude-template.md`
- 子資料夾：套 `$FW/router/subfolder-claude-template.md`，**只在技術獨立**資料夾（如 `sql/`、`scripts/`、`frontend/`、`backend/`）
- 一律 path reference `$FW`，NEVER 貼整段規範
- 回報：新增 N 檔、跳過 M 檔
</steps>

<rules>
- MUST 先列清單再寫
- NEVER 覆蓋既有 `CLAUDE.md`
- NEVER 複製框架規範正文（用 reference）
- 子資料夾粒度：只在明顯技術獨立處建，不要每層都塞
- Trivial（單一語言小專案）→ 只寫 root 一個即可
</rules>
