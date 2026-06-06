# {{PROJECT_NAME}}

<system_context>
TODO(scaffold)：一句話描述本專案。
技術棧：{{STACK}}
本專案套用 LLMDevFramework 規範；framework 根：`{{FRAMEWORK_PATH}}`（`$FW`）。
</system_context>

<paved_path>
依檔型自動套用對應 domain（細節見全域 Router）：
{{DOMAIN_REFS}}
例：`.ps1` → `$FW/PowerShell/CLAUDE.md`、`.sql` → `$FW/OracleSQL/CLAUDE.md`
</paved_path>

<critical_notes>
- 非 trivial 新功能 → 走 `/sdd`
- review code 前 → 先產 `CodeMap.md`
- TODO(scaffold)：專案專屬硬規則（命名、目錄、禁區）
</critical_notes>

<hatch>
- 與框架規範衝突 → 本檔（專案）優先，在此寫明覆蓋原因
</hatch>
