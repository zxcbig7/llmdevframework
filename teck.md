# Claude Code 表現提升手法總整理

> 來源：Anthropic 官方 docs、社群文章、實戰 blog（2026 年）。重點放在**輸出到位**與**省 token**，附 sources 在文末。

---

## 0. 最高槓桿原則（記這 5 條就好）

1. **CLAUDE.md 是控制中心**——每 turn 都載入，>200 行就會稀釋 instruction adherence；保持精簡
2. **Skills > Commands > 寫進 CLAUDE.md**——只在「需要時」才載入的知識用 skill，不要塞進每次都讀的 CLAUDE.md
3. **`/context` 先診斷再優化**——不知道誰吃 token 就別亂改
4. **Subagent 處理大量 research / 平行任務**——保持主 context 乾淨
5. **Hooks 處理「每次都要做」的事**——CLAUDE.md 是 advisory，hooks 是 deterministic

---

## 1. `.claude` 資料夾完整解剖

### 階層

| 位置 | 用途 | 是否進 git |
|------|------|------------|
| `<repo>/.claude/` | 專案層級（team-shared） | ✅ commit |
| `<repo>/.claude/settings.local.json` | 個人覆寫專案設定 | ❌ gitignore |
| `<repo>/CLAUDE.local.md` | 個人覆寫專案 CLAUDE.md | ❌ gitignore |
| `~/.claude/` | 全域（machine-local） | N/A |

### 檔案 / 子目錄總覽

```text
.claude/
├── settings.json          # 權限（allow/deny）、env vars、hooks
├── settings.local.json    # 個人覆寫（不進 git）
├── CLAUDE.md              # 專案指令（自動載入）
├── rules/                 # 模組化 instruction（可 path-scope）
│   └── api-rules.md       # frontmatter 指定 paths 才載入
├── commands/              # 自訂 slash command（手動觸發）
│   └── review.md          # → /review
├── skills/                # 自動觸發的工作流（依 description 匹配）
│   └── security-review/
│       ├── SKILL.md
│       └── DETAILED_GUIDE.md
├── agents/                # subagent persona
│   └── code-reviewer.md
└── mcp.json               # MCP server 設定
```

### `settings.json` 範例

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "npm run lint" }]
      }
    ]
  }
}
```

> **省提示次數**：常用、安全的 read-only 指令進 allow，避免每次跳權限請求。

---

## 2. Skills vs Commands vs Subagents vs Hooks vs MCP

| 機制 | 觸發方式 | Context 影響 | 何時用 |
|------|----------|--------------|--------|
| **CLAUDE.md** | 自動、每次都載入 | 永久佔 context | 全專案永遠適用的 ≤200 行核心規則 |
| **Skill** | Claude 依 description 自動觸發 | 只在需要時載入 | 「有時才需要」的領域知識 / 工作流 |
| **Slash command** | 手動 `/name` | 只在執行時載入 | 重複性手動工作（review、deploy） |
| **Subagent** | Claude 委派 / 手動 | 獨立 context（不污染主對話） | 大量 research、平行任務、deep dive |
| **Hook** | 事件觸發（PostToolUse 等） | 不進 context | 必要每次執行（lint / format / 安全檢查） |
| **MCP server** | 暴露 tools 給 Claude | tool list 進 context | 連外部系統（DB、GitHub、Playwright） |

### 決策樹

```text
要做的事是什麼？
├── 全專案永遠遵守 → CLAUDE.md
├── 有時才需要的領域知識 → Skill
├── 我要主動觸發的工作 → Slash command
├── 需要獨立 context 的大型 research → Subagent
├── 必要每次執行（自動化）→ Hook
└── 連外部系統 → MCP
```

---

## 3. CLAUDE.md 寫作守則（最影響表現）

- **<200 行**：超過會稀釋 instruction adherence；>300 行 Claude 開始忽略指令
- **每行問自己**：「刪掉會不會讓 Claude 出錯？」否就刪
- **不要塞**：linter config、long docs、design history、會議記錄
- **要塞**：build/test/lint 指令、架構決策、非顯而易見的 gotcha、命名 / 路徑慣例
- **巢狀 CLAUDE.md**：子目錄專屬規則放子目錄；自動往上找
- **遷移到 `rules/`**：CLAUDE.md 變肥時，把不是「永遠適用」的規則切到 `rules/<name>.md` 加 path frontmatter

### Path-scoped rule 範例

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/handlers/**/*.ts"
---
# API Design Rules
只在編輯這些路徑的檔案時載入。
```

---

## 4. Skill 寫作守則

### 結構

```text
.claude/skills/<skill-name>/
├── SKILL.md           # 必要（含 frontmatter + body）
├── references/        # 進階知識（progressive disclosure）
├── scripts/           # 輔助腳本
└── examples/          # 範例
```

### SKILL.md frontmatter

```yaml
---
name: security-review
description: Comprehensive security audit. Use when reviewing code for SQL injection, XSS, CSRF, auth issues, or before merging PRs.
allowed-tools: Read, Grep, Glob
---
```

### 觸發品質：description 是關鍵

- ❌ Vague：「Helps with tests」→ 鮮少觸發
- ✅ Specific：「Runs the project's pytest suite when the user asks to run, check, or verify tests」→ 可靠觸發

### Best practices

- **Start small**：先寫 1 個最小 skill（commit format、lint rule）
- **Skill 是資料夾不是檔案**：用 `references/` `scripts/` 做 progressive disclosure，主 SKILL.md 保持精簡
- **限制 tools**：security review 不需要 Write；用 `allowed-tools` 鎖死
- **不確定何時用 skill 而非 command**：自動觸發 → skill；手動觸發 → command

---

## 5. Subagent 設計守則

### YAML frontmatter

```yaml
---
name: code-reviewer
description: Expert code reviewer. Use after major changes for thorough review.
model: sonnet              # 或 haiku（read-only 工作）
tools: Read, Grep, Glob    # 鎖住權限
---
```

### 何時派 subagent

- 平行執行（同時掃 security + 生 test）
- 大量 research / 讀大檔（避免污染主 context）
- 獨立 context 的 deep dive

### Tip

- **Read-only agent 用 Haiku**：研究型工作不需要 Opus
- **保留 Sonnet/Opus 給架構決策**：依任務分模型省錢
- **Subagent 要簡潔不要全面**：Claude 看簡潔結構化指引比較有效率

---

## 6. Hooks 設計守則

### 何時用 hook（而非寫進 CLAUDE.md）

「必要每次執行、零例外」的事：

- Lint / format（PostToolUse on Edit|Write）
- Secret scan（PreToolUse on Write）
- 自動 commit / push 後通知
- Block 危險指令（PreToolUse on Bash）

### 範例

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "npm run lint:fix" },
          { "type": "command", "command": "npm run typecheck" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "scripts/check-bash.sh" }
        ]
      }
    ]
  }
}
```

### 限制

- 預設 timeout 10 分鐘
- Hook 失敗不會 retry，會 skip 讓 Claude 繼續 → 不要把關鍵 gate 放 hook（用 deny permission）

---

## 7. 18 個 Token 省法（壓縮版）

### A. Pre-session 準備

1. **CLAUDE.md 鎖核心**：精簡到 <200 行
2. **預先 scope 任務**：寫完整 task spec 再開 session（檔案、目標、限制）
3. **餵檔前先剪枝**：刪 comment block、unused import、dead code，80 行勝 400 行
4. **大任務切小**：「refactor user model」「refactor auth routes」「update API tests」拆三 session
5. **Task brief template**：固定格式（context / goal / files / constraints / tasks）
6. **預先生 project map**：`tree` 後只貼相關段，不要 Claude 盲探

### B. Session 中

7. **抑制廢話**：「No explanations, just the code」「Skip the preamble」省 30–50% 輸出 token
8. **主動 `/compact`**：sub-task 完成就 compact，不要等爆 context
9. **Compact 前下 memory anchor**：「Note 我們決定用 optimistic locking」引導 summary
10. **不要叫它 reformat**：原始 prompt 就講要的格式，不要事後叫它轉 bullet list（雙倍 token）
11. **訊息簡短直接**：刪 padding、寒暄、重複背景；一則訊息一個主題
12. **批次提問**：相關問題合一個 prompt，不要拆多輪

### C. 程式碼處理

13. **用行號引用**：「`auth.ts` lines 42–58 修 race condition」不要再貼一次
14. **要 diff 不要全檔重寫**：300 行檔改 15 行，diff 只用 5% token
15. **先要最小實作**：「給我最小版本，先不處理 edge case」迭代加複雜度
16. **排除無關檔**：用 `.claudeignore` 永久排 `package-lock.json`、test suite、長 config

### D. Session 延長

17. **Session handoff prompt**：結束前要 <300 字摘要（做了什麼 / 關鍵決策 / 下一步 / 注意事項）下次接續
18. **Token 中途審計**：定期 `/context` 看誰吃 token，發現重複資訊就調整

---

## 8. 輸出品質提升（Anthropic 12 技巧 + Claude Code 補充）

來自 Anthropic 官方 prompt engineering（已整合到 `LLMDevFramework/prompt-principles/CLAUDE.md`）：

1. Prompt Generator
2. **Explicit & Direct**（每條規則具體可驗證）
3. **Multi-shot 範例**（3–5 個 good/bad 對照）
4. **Chain of Thought**（先列步驟再執行）
5. **XML Tagging**（`<system_context>` `<task>` `<rules>`）
6. **Role Assignment**（slash command 必加「你是 X，目標 Y」）
7. **Pre-filling**（給輸出格式開頭）
8. **Prompt Chaining**（拆 pass/step）
9. **Long-Text 順序**（文件先放、問題後放）
10. **Templates**（`{{var}}`）
11. Prompt 改進工具
12. **Extended Thinking**（`think` / `think hard` / `ultrathink`）

### Claude Code 額外觸發詞

- `think` < `think hard` < `think harder` < `ultrathink`：分配遞增的 thinking budget
- Plan mode（Shift+Tab）：先出計畫不動 code，省試錯 token
- `/clear` 兩個無關任務間清 context
- `/compact` sub-task 完成後檢查點

---

## 9. 快速啟動 checklist（新專案）

- [ ] `/init` 自動產 `CLAUDE.md` 起手
- [ ] 寫 `.claude/settings.json`：allow 常用 read-only / project script，deny `.env` / `secrets/`
- [ ] `~/.claude/CLAUDE.md` 放個人偏好（語言、命名慣例、回覆風格）
- [ ] 寫 1–2 個高頻 slash command（review、deploy、test）
- [ ] 加 1 個 hook（PostToolUse lint/format）
- [ ] 累積到一定規模再考慮：
  - 拆 CLAUDE.md 到 `rules/` + path scope
  - 加 skill（自動觸發的工作流）
  - 加 subagent（read-only research、平行任務）
  - 加 MCP server（外部系統整合）

---

## 10. 對你 LLMDevFramework 的應用建議

對照你已有的設置：

| 現有 | 對應機制 | 建議 |
|------|----------|------|
| `LLMDevFramework/CLAUDE.md` 等多個 | 全域 CLAUDE.md | OK，但檢查每個是否 <200 行 |
| `sdd-command.md` / `k8s-review-command.md` / `proc-analyze-command.md` | Slash command | ✅ 已有；可 promote 部分到 skill 讓自動觸發 |
| `troubleshooting/` 經驗庫 | 適合做成 skill | description 寫「當使用者要 audit K8s YAML 時觸發」就會自動帶入 |
| `prompt-principles/` | 元規範 | 應該維持為 reference，但本身不需每次載入 |
| `proc-analysis/notes/` | 大型筆記庫 | 用 subagent 讀，不要進主 context |

### 立即可做 3 件事

1. **檢查 CLAUDE.md 行數**：超 200 行的拆 `rules/` 加 path scope
2. **把 `/k8s-review` 升級成 skill**：description 寫「當看到 K8s YAML 部署問題時觸發」自動套
3. **加 hook**：PostToolUse 跑 markdownlint，避免每次寫 CLAUDE.md 都被 lint 警告

---

## Sources

### .claude 結構與 skills

- [Anatomy of the .claude/ Folder](https://blog.dailydoseofds.com/p/anatomy-of-the-claude-folder)
- [Claude Code Skills Folder: Location, Structure, and Setup](https://www.agensi.io/learn/claude-code-skills-folder-location-setup)
- [Claude Code Skills: A Practical Guide for 2026](https://dev.to/muhammad_moeed/claude-code-skills-a-practical-guide-for-2026-3f6p)
- [Where Are Claude Skills Stored? Paths for Mac, Windows, Linux](https://www.agensi.io/learn/where-are-claude-skills-stored)
- [The Complete Guide to Building Skills for Claude (Anthropic PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)
- [9 Best Claude Code Skills (and the One That Wins)](https://claudefa.st/blog/tools/skills/best-claude-code-skills)

### Token 優化

- [18 Claude Code Token Management Hacks | MindStudio](https://www.mindstudio.ai/blog/claude-code-token-management-hacks)
- [Claude Code Token Optimization: Stop the $1,600 Bill](https://buildtolaunch.substack.com/p/claude-code-token-optimization)
- [7 Practical Ways to Reduce Claude Code Token Usage | KDnuggets](https://www.kdnuggets.com/7-practical-ways-to-reduce-claude-code-token-usage)
- [Claude Code Context Window: Optimize Your Token Usage](https://claudefa.st/blog/guide/mechanics/context-management)
- [Reduce Claude Code token usage by 90% | Medium](https://medium.com/data-science-in-your-pocket/reduce-claude-code-token-usage-by-90-baa2a27b9ca3)

### Hooks / Subagents / MCP

- [Understanding Claude Code's Full Stack: MCP, Skills, Subagents, and Hooks](https://alexop.dev/posts/understanding-claude-code-full-stack/)
- [Create custom subagents | Claude Code Docs](https://code.claude.com/docs/en/sub-agents)
- [Best practices for Claude Code subagents | PubNub](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)
- [Inside Claude Code: Architecture Behind Tools, Memory, Hooks, and MCP](https://www.penligent.ai/hackinglabs/inside-claude-code-the-architecture-behind-tools-memory-hooks-and-mcp/)
- [Taming Claude Code: A Guide to CLAUDE.md and Hooks | Medium](https://medium.com/becoming-for-better/taming-claude-code-a-guide-to-claude-md-and-hooks-ed059879991c)

### Best practices 總覽

- [Best practices for Claude Code | Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Claude Code Best Practices: From Vibe Coding to Agentic Engineering](https://mcp.directory/blog/claude-code-best-practices)
- [Claude Code CLI: The Complete Guide — Hooks, MCP, Skills](https://blakecrosley.com/guides/claude-code)
- [A Guide to Claude Code 2.0 | sankalp's blog](https://sankalp.bearblog.dev/my-experience-with-claude-code-20-and-how-to-get-better-at-using-coding-agents/)
- [Understanding Claude Code: Skills vs Commands vs Subagents vs Plugins](https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins)
