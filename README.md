# LLMDevFramework

個人化的 **Claude Code 開發框架**——把跨專案常用的開發守則、工作流程、slash command 集中在一個地方，讓 AI 在任何專案都能依照一致的標準產出。

> **Why**：Claude 在每個 session 重新開始，沒有記憶。把規範寫進 CLAUDE.md / slash command，等於把你的開發判斷外包給 AI 卻不失控。

---

## 快速使用

### 把這個 repo 當「全域規範」

把整個資料夾放在 `~/.claude/projects/<your-name>/LLMDevFramework/` 或任何位置，在新專案的 CLAUDE.md 用 file reference 引用：

```markdown
# 專案 CLAUDE.md
參考：`C:/Users/zxcbi/Desktop/MyDevWeb/LLMDevFramework/React & Typescript/CLAUDE.md`
```

### 啟用 slash command

```powershell
$base = "C:\Users\zxcbi\Desktop\MyDevWeb\LLMDevFramework"
$dst  = "C:\Users\zxcbi\.claude\commands"

Copy-Item "$base\sdd\sdd-command.md"                              "$dst\sdd.md"             -Force
Copy-Item "$base\YAML Review\k8s-review-command.md"               "$dst\k8s-review.md"      -Force
Copy-Item "$base\OracleSQL\proc-analysis\proc-analyze-command.md" "$dst\proc-analyze.md"    -Force
Copy-Item "$base\Prompt Builder\prompt-improve-command.md"        "$dst\prompt-improve.md"  -Force
```

之後任何專案 `/sdd`、`/k8s-review`、`/proc-analyze`、`/prompt-improve` 都可用。

---

## 結構

```text
LLMDevFramework/
├── README.md                     # 本檔
├── CLAUDE.md                     # 框架根規範（維護準則 + SDD 流程）
├── teck.md                       # Claude Code 表現提升手法總整理
│
├── prompt-principles/            # ★ 元規範（寫 CLAUDE.md / command 前先讀）
│   └── CLAUDE.md                 # Anthropic 12 prompt 技巧 + 4 原則 + self-check
│
├── Prompt Builder/               # ★ 寫好 prompt 的工具箱（給「不知怎麼問 AI」的時候用）
│   ├── CLAUDE.md                 # 5 品質維度 + 4 大錯誤 + 框架選擇樹
│   ├── frameworks-cheatsheet.md  # 10 個主流框架對照（CO-STAR / RISEN / TIDD-EC...）
│   ├── prompt-improve-command.md # /prompt-improve slash command
│   └── templates/                # 即填即用模板
│       ├── universal-4-part.md
│       ├── co-star.md
│       ├── risen.md
│       ├── tidd-ec.md
│       ├── rtf.md
│       └── rise-ix.md
│
├── sdd/                          # Spec-Driven Development 工作流
│   ├── CLAUDE.md                 # SDD 方法論
│   ├── sdd-command.md            # /sdd slash command
│   └── spec-template.md          # 規格文件模板
│
├── OracleSQL/                    # Oracle PL/SQL 開發守則
│   ├── CLAUDE.md                 # 命名 / bulk DML / exception / 安全
│   └── proc-analysis/            # 10K+ 行 procedure 分析工具
│       ├── CLAUDE.md             # 多 pass 分析方法論
│       ├── proc-analyze-command.md  # /proc-analyze slash command
│       ├── proc-template.md      # 筆記模板（含 3 張 Mermaid）
│       └── notes/                # 分析過的 procedure 筆記庫
│           └── INDEX.md
│
├── React & Typescript/           # React + TS strict mode 守則
│   └── CLAUDE.md
│
├── .Net Web API/                 # ASP.NET Core Web API 守則
│   └── CLAUDE.md
│
└── YAML Review/                  # K8s / Helm / ArgoCD / GitHub Actions
    ├── CLAUDE.md                 # YAML 通用規範
    ├── k8s-review-command.md     # /k8s-review slash command（無 kubectl 環境）
    └── troubleshooting/          # 公司內部部署坑經驗庫
        ├── CLAUDE.md             # 經驗庫結構規範
        └── _template.md          # case 模板
```

---

## 內建工具

### `/prompt-improve <模糊草稿>`

把模糊的 prompt 草稿改造成結構化、AI 看得懂的版本。給「題給 AI 的要求不夠好」時用。

**5 step 流程**：

1. 5 維度品質診斷（clarity / specificity / context / completeness / structure）
2. 一次問 3–5 個釐清問題
3. 從 10 個框架選一個（CO-STAR / RISEN / TIDD-EC / RTF / CoT...）並給選用理由
4. 用 XML tags 重寫，限 80–200 字
5. 列改動對照表 + 預估效果

**支援框架**：詳見 [`Prompt Builder/frameworks-cheatsheet.md`](./Prompt Builder/frameworks-cheatsheet.md)。

### `/sdd <一句話描述>`

Spec-Driven Development 啟動器。靈感來自 wu_pingju 的 SDD skill 與 GitHub spec-kit。

**流程**：

1. Claude 一次問 3 題（涉及模組 / 成功標準 / 邊界顧慮）
2. 產出規格存到 `<project>/specs/YYYY-MM-DD-<slug>.md`
3. 等使用者 approve
4. 做 stub 實作（interface / 路由 / 函式簽名 + TODO）
5. 之後逐層填肉並對照規格驗收

**為何**：減少 vibe coding，提早抓邊界情況；規格本身就是 deliverable。

### `/k8s-review <檔案或資料夾>`

無 `kubectl` 權限環境專用的 K8s YAML 靜態 auditor。

**檢查 11 維度**：結構、image、resource、PSS security、networking、storage、RBAC、admission policy、Helm、ArgoCD、跨 env 一致性。

**輸出**：CRITICAL / WARN / INFO 分級 + YAML diff（before / after）。

**特色**：吃 `troubleshooting/` 經驗庫——撞到新坑就寫一個 case file，下次 audit 自動套用。

### `/proc-analyze <檔案或 schema.package.proc>`

10K+ 行 Oracle PL/SQL procedure 結構化分析。

**5-pass 流程**：

1. grep 抓骨架（不 Read 全檔）
2. 區段填肉（200–500 行 / 段）
3. 跨檔解析 callee（找已分析的 link）
4. 套模板輸出（含 3 張 Mermaid：flowchart / sequenceDiagram / erDiagram）
5. 自我檢查（行號 / 圖 / 摘要密度）

**產出**：`OracleSQL/proc-analysis/notes/<schema>.<package>.<proc>.md`，逐漸累積成 PL/SQL 第二大腦。

---

## 設計理念

### 1. XML semantic tags 結構化所有 CLAUDE.md

每份 CLAUDE.md 套用相同骨架：

```markdown
<system_context>     用途
<critical_notes>     硬性規則
<file_map>           子目錄結構
<paved_path>         標準作法
<patterns>           常見 pattern
<common_tasks>       任務指引
<example>            good/bad 對照
<hatch>              例外情境
<fatal_implications> 絕對禁止
```

來源：[How I Use Claude Code (Tyler Burnam)](https://tylerburnam.medium.com/how-i-use-claude-code-c73e5bfcc309)。

### 2. 100–200 行上限

CLAUDE.md 每 turn 都載入；超 200 行會稀釋 instruction adherence。

### 3. 12 prompt 技巧檢核

寫 / 改任何 CLAUDE.md 或 slash command 都對照 [`prompt-principles/CLAUDE.md`](./prompt-principles/CLAUDE.md) 的 12 點 self-check。

### 4. Multi-shot 對照範例優先

純文字描述 < good/bad code 對照。Claude 學範例學得很細。

### 5. 經驗累積 > 一次寫死

`troubleshooting/`、`proc-analysis/notes/` 都是空殼起手——撞到問題才填。隨時間長成個人化知識庫。

---

## 如何擴充

### 加新技術領域

1. 建子資料夾（例如 `Python/` 或 `Rust/`）
2. 複製其他子目錄的 CLAUDE.md 結構（XML 9 tag）
3. 在 root [`CLAUDE.md`](./CLAUDE.md) `<file_map>` 補上路徑

### 加新 slash command

1. 寫 `<feature>/<feature>-command.md`，**必含**：
   - frontmatter（`description` + `argument-hint`）
   - `<role>` 開場
   - 步驟編號 + CoT 觸發
   - good/bad 範例
   - `<output-format>` pre-fill
   - `<rules>` 結尾
2. 對照 [`prompt-principles/CLAUDE.md`](./prompt-principles/CLAUDE.md) self-check 跑一次
3. 複製到 `~/.claude/commands/<name>.md`

### 加新經驗 case（troubleshooting / notes）

撞到問題後 30 分鐘內寫——記憶最熱：

- YAML 部署：複製 `YAML Review/troubleshooting/_template.md`
- PL/SQL procedure：跑 `/proc-analyze` 自動產

---

## 維護規則

- **可重現的東西不寫進 memory**：code 結構、git history、檔案路徑都從 repo 直接讀
- **過時內容直接刪**：不留 deprecated 註解
- **規範衝突**：子目錄 CLAUDE.md 優先於 root；專案 root CLAUDE.md 優先於 LLMDevFramework

---

## 參考資源

完整 sources 列表見 [`teck.md`](./teck.md) 末尾。核心參考：

- [Anthropic Claude 4 Prompt Engineering 12 技巧](https://codelove.tw/@tony/post/3189Kx)
- [How I Use Claude Code (Tyler Burnam)](https://tylerburnam.medium.com/how-i-use-claude-code-c73e5bfcc309)
- [SDD Skill (wu_pingju)](https://www.threads.com/@wu_pingju/post/DTiQ8dWFHlw)
- [GitHub spec-kit](https://github.com/github/spec-kit)
- [Anatomy of the .claude/ Folder](https://blog.dailydoseofds.com/p/anatomy-of-the-claude-folder)

---

## License

個人使用框架，無 license。
