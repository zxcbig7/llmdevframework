# 手動安裝 LLMDevFramework Slash Commands

> 給**不能跑 `.ps1` 的環境**（PowerShell execution policy 鎖死、公司禁止執行腳本、無腳本權限）。
> 結果與 `install.ps1` 完全相同：把 5 個 slash command 部署到 `~/.claude/commands/`。
> 能跑腳本的環境請用 [README.md](./README.md) 的一鍵安裝。

## 原理（為什麼不能只是複製貼上）

部署 = 兩步，**第 2 步最常被漏**：

1. 把 framework 的 command 檔複製到 `~/.claude/commands/`
2. 把檔案內的 `{{FRAMEWORK_PATH}}` 佔位字串，**全部換成你放 LLMDevFramework 的實際路徑（用正斜線 `/`）**

漏了第 2 步，command 會抓不到框架的 CLAUDE.md → 功能不完整。

## 要複製的檔案（單一真相＝[deploy.config.json](./deploy.config.json)）

| 來源（framework 內）| 目的地（`~/.claude/commands/`）| 指令 |
|------|------|------|
| `sdd/sdd-command.md` | `sdd.md` | `/sdd` |
| `YAML Review/k8s-review-command.md` | `k8s-review.md` | `/k8s-review` |
| `OracleSQL/proc-analysis/proc-analyze-command.md` | `proc-analyze.md` | `/proc-analyze` |
| `Prompt Builder/prompt-improve-command.md` | `prompt-improve.md` | `/prompt-improve` |
| `CMD Developer/cmd-dev-command.md` | `cmd-dev.md` | `/cmd-dev` |

> `~` ＝ 家目錄。Windows 是 `C:\Users\<你>\`，即目的地為 `C:\Users\<你>\.claude\commands\`。

## 先確認兩個值

- **框架路徑**：你放 LLMDevFramework 的位置。本機是 `C:\Users\zxcbi\Desktop\Projects\LLMDevFramework`（工作電腦會不同，以實際為準）。
- **替換值**：把框架路徑的反斜線換成正斜線 → `C:/Users/zxcbi/Desktop/Projects/LLMDevFramework`。這就是 `{{FRAMEWORK_PATH}}` 要換成的字串。

---

## 方法 A：互動式 PowerShell（最快）

> 這是「**直接貼進 PowerShell 視窗執行的指令**」，不是 `.ps1` 腳本檔，所以 execution policy ＝ Restricted 也能跑。

把第一行 `$fw` 改成你的框架路徑，整段貼進 PowerShell：

```powershell
# 1) 路徑（只改這行）
$fw  = "C:\Users\zxcbi\Desktop\Projects\LLMDevFramework"

$dst = Join-Path $HOME ".claude\commands"
$sub = $fw.Replace('\', '/')          # {{FRAMEWORK_PATH}} 的替換值（正斜線）
New-Item -ItemType Directory -Path $dst -Force | Out-Null

# 2) 來源 → 目的檔名
$map = [ordered]@{
  "sdd\sdd-command.md"                              = "sdd.md"
  "YAML Review\k8s-review-command.md"               = "k8s-review.md"
  "OracleSQL\proc-analysis\proc-analyze-command.md" = "proc-analyze.md"
  "Prompt Builder\prompt-improve-command.md"        = "prompt-improve.md"
  "CMD Developer\cmd-dev-command.md"                = "cmd-dev.md"
}

# 3) 複製 + 替換佔位字串 + 寫出（UTF-8）
foreach ($src in $map.Keys) {
  $c = (Get-Content -Raw -Encoding UTF8 (Join-Path $fw $src)).Replace('{{FRAMEWORK_PATH}}', $sub)
  Set-Content -Path (Join-Path $dst $map[$src]) -Value $c -Encoding UTF8 -NoNewline
  Write-Host "  OK  $($map[$src])"
}
```

---

## 方法 B：純手動（連 PowerShell 都不能用時）

對「要複製的檔案」表的每一列：

1. 用文字編輯器（VS Code / Notepad）開啟來源檔，例如 `...\LLMDevFramework\sdd\sdd-command.md`。
2. **全文取代**：把所有 `{{FRAMEWORK_PATH}}` 換成你的替換值（正斜線版，如 `C:/Users/.../LLMDevFramework`）。
   - VS Code：`Ctrl+H` → 找 `{{FRAMEWORK_PATH}}` → 全部取代。
3. **另存新檔**到 `C:\Users\<你>\.claude\commands\` 下的對應檔名（如 `sdd.md`），編碼選 **UTF-8**。
4. 五個檔都做完。

> `.claude` 在家目錄；若沒有 `commands` 子資料夾就自己建一個。

---

## 驗證

```powershell
Get-ChildItem (Join-Path $HOME ".claude\commands")                                    # 應有 5 個 .md
Select-String -Path (Join-Path $HOME ".claude\commands\*.md") -Pattern '\{\{FRAMEWORK_PATH\}\}'  # 應無輸出
```

- 第一行列出 5 個檔。
- 第二行**無輸出** ＝ 佔位字串都換掉了；有輸出代表還有漏，回去補替換。
- 在 Claude Code 打 `/` 應看得到 `/sdd`、`/k8s-review`、`/proc-analyze`、`/prompt-improve`、`/cmd-dev`。

---

## 手動更新（框架改版後）

手動安裝**不會寫 manifest**（`~/.claude/.llmdevframework.json` 是給腳本做安全 diff 用的）。更新＝重做一次安裝：重跑方法 A，或把有改動的檔重新另存。

> 手動模式不偵測「你在 `~/.claude` 改過部署檔」——重做會直接覆蓋。手改過且想保留就先備份。

## 手動移除

```powershell
"sdd","k8s-review","proc-analyze","prompt-improve","cmd-dev" | ForEach-Object {
  Remove-Item (Join-Path $HOME ".claude\commands\$_.md") -ErrorAction SilentlyContinue
}
```

GUI：到 `C:\Users\<你>\.claude\commands\` 刪掉那 5 個 `.md`。若有 `.llmdevframework.json`（之前用腳本裝過）也可一併刪。

---

## 新增部署項

清單單一真相是 [deploy.config.json](./deploy.config.json)。框架日後新增 command 時，照同樣兩步（複製 + 替換佔位字串）把新檔加進 `~/.claude/commands/` 即可。
