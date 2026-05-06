# LLMDevFramework — Deploy / Update / Uninstall Scripts

把 LLMDevFramework 的 slash commands 部署到 `~/.claude/`，讓所有專案都能用。

> ⚠️ **編碼注意**：本資料夾的 `.ps1` 檔為 **UTF-8 with BOM**。直接編輯後若用 Write tool 重存（無 BOM）→ Windows PowerShell 5.1 會解析失敗。修法：`$c = Get-Content <file> -Raw -Encoding UTF8; Set-Content <file> -Value $c -Encoding UTF8 -NoNewline`。

## 一鍵安裝

```powershell
cd C:\Users\zxcbi\Desktop\MyDevWeb\LLMDevFramework\scripts
.\install.ps1
```

完成後，**任何專案**打 `/sdd`、`/k8s-review`、`/proc-analyze`、`/prompt-improve` 都能用。

## 三個指令

| 指令 | 用途 |
|------|------|
| `install.ps1` | 首次安裝 |
| `update.ps1` | 拉本框架最新修改重新部署 |
| `uninstall.ps1` | 全部移除 |

每個都支援 `-DryRun`（看會做什麼但不執行）與 `-Force`（強制覆蓋）。

---

## 詳細用法

### `install.ps1` — 首次安裝

```powershell
.\install.ps1                # 預設：遇衝突跳過
.\install.ps1 -Force         # 強制覆蓋既有檔案（即使非本框架部署）
.\install.ps1 -DryRun        # 預演，不寫檔
```

做什麼：

1. 讀 `deploy.config.json` 取得部署清單
2. 對每個 item：
   - Read source 檔
   - 把 `{{FRAMEWORK_PATH}}` 替換成本框架實際路徑（自動偵測）
   - 寫到 `~/.claude/<dst>`
3. 寫 manifest 到 `~/.claude/.llmdevframework.json`（給 update / uninstall 用）

### `update.ps1` — 拉最新修改

```powershell
.\update.ps1                 # 安全更新（你改過的 dest 跳過）
.\update.ps1 -Force          # 強制覆蓋你的本地修改
.\update.ps1 -DryRun         # 預演
```

判斷邏輯：

| 情況 | 動作 |
|------|------|
| source mtime > manifest 紀錄 | 重部署 |
| dest 不存在 | 重部署 |
| dest mtime > 部署當下記錄（你改過）| 跳過 + 警告（用 `-Force` 覆蓋）|
| deploy.config 新增 item | 部署 |
| manifest 有但 deploy.config 移除（孤兒）| 警告，建議跑 uninstall.ps1 |

### `uninstall.ps1` — 移除

```powershell
.\uninstall.ps1              # 安全卸載（你改過的不刪）
.\uninstall.ps1 -Force       # 全部刪光
.\uninstall.ps1 -KeepManifest # 刪檔但保留 manifest（給 reinstall 用）
```

---

## 如何新增 / 修改部署項

只改一個地方：[`deploy.config.json`](./deploy.config.json)

```json
{
  "id": "cmd-new-thing",
  "type": "command",
  "src": "SubFolder/new-thing-command.md",
  "dst": "commands/new-thing.md",
  "transform": "substitute-framework-path",
  "description": "/new-thing — 描述"
}
```

新增後跑 `update.ps1`，新 item 會自動部署。

### Transform 種類

| transform | 動作 |
|-----------|------|
| `substitute-framework-path` | 把 source 內 `{{FRAMEWORK_PATH}}` 替換成本框架實際路徑 |
| `none` | 原封不動複製 |

要加新的 transform：改 [`lib.ps1`](./lib.ps1) 的 `Invoke-Transform` switch。

---

## 檔案結構

```text
scripts/
├── README.md              # 本檔
├── deploy.config.json     # 部署清單（單一真相）
├── lib.ps1                # 共用函式（manifest、transform、deploy core）
├── install.ps1            # 首次安裝
├── update.ps1             # 拉最新
└── uninstall.ps1          # 移除
```

部署後在 `~/.claude/`：

```text
~/.claude/
├── .llmdevframework.json  # manifest（追蹤已部署檔案）
└── commands/
    ├── sdd.md             # /sdd
    ├── k8s-review.md      # /k8s-review
    ├── proc-analyze.md    # /proc-analyze
    └── prompt-improve.md  # /prompt-improve
```

---

## 常見情境

### 我把框架移到別的資料夾了

直接在新位置跑 `install.ps1`——它會自動偵測新路徑、重寫 `{{FRAMEWORK_PATH}}` 替換、更新 manifest。

### 我手動改了 `~/.claude/commands/sdd.md` 想留著

跑 `update.ps1` 會偵測到並跳過。要永遠保留：把改動同步回 source（`sdd/sdd-command.md`），下次 update 就一致了。

### 我要把這個 setup 帶到新電腦

1. clone / copy 整個 LLMDevFramework 資料夾過去
2. 在新電腦跑 `.\install.ps1`
3. 完成。Manifest 內的路徑會自動指到新電腦的位置。

### 一個指令壞了，怎麼 rollback？

1. 在框架 source 改回正確版本
2. 跑 `update.ps1` 即重部署該檔
3. 或直接跑 `install.ps1 -Force` 全部覆蓋

---

## Manifest 結構

`~/.claude/.llmdevframework.json`：

```json
{
  "version": "1.0.0",
  "frameworkRoot": "C:/Users/zxcbi/Desktop/MyDevWeb/LLMDevFramework",
  "installedAt": "2026-05-07T...",
  "updatedAt": "2026-05-07T...",
  "scope": "global",
  "files": [
    {
      "id": "cmd-sdd",
      "type": "command",
      "src": "sdd/sdd-command.md",
      "dst": "commands/sdd.md",
      "transform": "substitute-framework-path",
      "sourceMtime": "...",
      "deployedMtime": "...",
      "deployedAt": "..."
    }
  ]
}
```

不要手改這個檔——讓 install / update / uninstall 維護就好。
