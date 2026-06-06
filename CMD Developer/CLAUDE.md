# CMD (Batch) Developer 規範

<system_context>
Windows CMD batch script（`.bat` / `.cmd`）開發、review、debug 守則。
適用情境：Windows 11 + PowerShell 5.1（cp950 預設）環境下維護啟動腳本（如 `start.bat`）、CI 包裝腳本、快速 launcher。
PowerShell 能寫的優先寫 PowerShell；`.bat` 只在「雙擊執行」「相容老系統」「不能依賴 PS execution policy」時用。
</system_context>

<critical_notes>
- MUST 開頭用 `@echo off` + `setlocal EnableExtensions EnableDelayedExpansion`（除非有反例）
- MUST 換行用 `^`（不是 `\`、不是 `` ` ``）—— Why: cmd parser 不認其他續行符
- MUST 字串引號**只能用 `"`**（不認 `'`）—— Why: 單引號被視為一般字元
- MUST 引用變數預設用 `"%var%"`（含路徑必加引號）—— Why: 空白 / 特殊字元會撕裂指令
- MUST `for /f` 與 `if` 區塊內取變數用 `!var!`（delayed expansion）—— Why: `%var%` 在解析期就展開，迴圈裡會永遠拿初值
- MUST `.bat` / `.cmd` 存檔用 **CRLF（`\r\n`）** 行尾 —— Why: LF-only 在 cmd.exe 執行時整份 script 會被視為一行，所有指令串成一條爆掉；跨平台傳輸（Git、WSL、Mac）最容易踩到
- MUST 在 repo 根目錄 `.gitattributes` 加 `*.bat text eol=crlf` 與 `*.cmd text eol=crlf` —— Why: Git 預設會依 `core.autocrlf` 轉換，沒有明確設定就靠不住
- MUST 寫含中文 `.bat` 存檔用 **UTF-8 with BOM** 或乾脆全 ANSI（cp950）—— Why: PS 5.1 預設 cp950 解 UTF-8 無 BOM 會亂碼
- MUST script 結尾用 `endlocal` + `exit /b %errorlevel%`（非 `exit`）—— Why: 裸 `exit` 會關掉呼叫端 cmd 視窗
- NEVER 用 `if errorlevel N`（這是「≥N」不是「==N」）—— ALWAYS 用 `if %errorlevel% equ N` 或 `if %errorlevel% neq 0`
- NEVER 把 `%` 寫在 `.bat` 字串裡當文字 —— ALWAYS 用 `%%` 跳脫（指令列直接打才用單一 `%`）
- NEVER 用 `goto :eof` 退出整支 script —— `:eof` 在 function（`call :label`）內是返回，主流程用 `exit /b N`
- NEVER 在 batch 裡 hardcode 路徑 —— ALWAYS 用 `%~dp0`（script 自身目錄，含尾 `\`）
</critical_notes>

<file_map>
本資料夾內容：
CLAUDE.md              - 本檔（CMD batch 規範 + 雷區）
cmd-dev-command.md     - `/cmd-dev <write|review|debug> <args>` slash command
</file_map>

<paved_path>
**標準骨架**（複製即用）

```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ─── meta ──────────────────────────────────────────
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_NAME=%~n0"

rem ─── args ──────────────────────────────────────────
if "%~1"=="" (
    echo Usage: %SCRIPT_NAME% ^<arg1^> [arg2]
    exit /b 1
)
set "ARG1=%~1"

rem ─── main ──────────────────────────────────────────
call :do_work "%ARG1%" || goto :err
echo OK
endlocal & exit /b 0

:do_work
    rem 函式：%~1 是傳給函式的第一個參數
    pushd "%SCRIPT_DIR%" >nul || exit /b 1
    rem ... 邏輯 ...
    popd >nul
    exit /b 0

:err
    echo [ERROR] %SCRIPT_NAME% failed at line %~0 with code %errorlevel%>&2
    endlocal & exit /b 1
```

**長指令續行**

```bat
docker run --rm ^
    -v "%CD%:/workspace" ^
    -w /workspace ^
    -e "MSYS_NO_PATHCONV=1" ^
    myimage:tag ^
    bash -c "make build"
```

**呼叫 PowerShell**（從 .bat 跑 PS 片段）

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%CD%' -Filter *.log | Remove-Item"
```

> 注意：PS 那串內部用單引號（外層 cmd 的雙引號才不會打架）。

**錯誤碼判斷正確寫法**

```bat
some_command
if %errorlevel% neq 0 (
    echo failed >&2
    exit /b %errorlevel%
)
```
</paved_path>

<patterns>
### 雷區 1：`%` 跳脫
- batch 檔案內 → `%%` 才是字面 `%`（`for %%i in (...)`）
- 命令列直打 → 單一 `%`（`for %i in (...)`）

### 雷區 2：delayed expansion（`!var!` vs `%var%`）

❌ Bad
```bat
set count=0
for %%f in (*.txt) do (
    set /a count=%count%+1
    echo %count%
)
rem 永遠輸出 0 0 0...
```

✅ Good
```bat
setlocal EnableDelayedExpansion
set count=0
for %%f in (*.txt) do (
    set /a count=!count!+1
    echo !count!
)
```

Why: `%count%` 在 parse 區塊（整個 `for` 括弧）時就展開為當下值，迴圈 runtime 不再重算。

### 雷區 3：特殊字元跳脫
| 字元 | 內部跳脫 | 字串內（雙引號）|
|------|---------|----------------|
| `&`  | `^&`    | 不必跳脫       |
| `\|` | `^\|`   | 不必跳脫       |
| `<` `>` | `^<` `^>` | 不必跳脫 |
| `^`  | `^^`    | 不必跳脫       |
| `%`  | `%%`（檔案內） | 同左 |

### 雷區 4：檔名 / 路徑修飾子（`%~`）
| 寫法 | 意義 |
|------|------|
| `%~1`   | 去掉外層引號的 arg1 |
| `%~dp0` | script 自身的 drive+path（含尾 `\`） |
| `%~nx1` | arg1 的「檔名+副檔名」 |
| `%~f1`  | arg1 的絕對路徑 |
| `%~a1`  | arg1 的檔案屬性 |

### 雷區 5：encoding（PS 5.1 + cp950 環境）
- 寫含中文的 `.bat` → 存 UTF-8 BOM **或**全 ANSI（cp950）
- script 開頭可加 `chcp 65001 >nul` 切換到 UTF-8（會影響後續 console 輸出）
- 但 `chcp 65001` 後若 .bat 本身是 ANSI 字面字串，console 會反而亂碼 → encoding 與 chcp 要一致

### 雷區 6：傳參到 PowerShell
```bat
rem 變數含空白時要外層雙引號
powershell -NoProfile -Command "& { param($p) Write-Host $p }" -p "%~1"
```

### 雷區 7：相對路徑陷阱
- 雙擊 `.bat` 執行時 `cwd` 是 script 目錄
- 從別處 `call` 進來時 `cwd` 是呼叫者目錄
- ALWAYS 用 `pushd "%~dp0"` 鎖死，結束 `popd`

### 雷區 9：CRLF vs LF（跨平台傳輸）

❌ Bad：在 Mac/Linux 編輯後存成 LF，傳到 Windows 執行

```text
@echo off^Msetlocal^M...   ← cmd.exe 看到的是一行
```

結果：第一個指令後面的全部被當參數，或直接報「找不到指令」。

✅ Fix：

```ini
# .gitattributes
*.bat  text eol=crlf
*.cmd  text eol=crlf
```

VS Code 手動轉：右下角點 `LF` → 選 `CRLF`，或 `Ctrl+Shift+P` → `Change End of Line Sequence`。

PowerShell 批次轉（目錄內所有 .bat）：

```powershell
Get-ChildItem -Recurse -Filter *.bat | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content -replace "`r?`n", "`r`n" | Set-Content $_.FullName -NoNewline
}
```

### 雷區 8：`if defined` vs `if "%var%"==""`
```bat
if defined VAR ( echo set ) else ( echo unset )
rem 比 if "%VAR%"=="" 更穩（後者遇空格 / 特殊字元會炸）
```
</patterns>

<common_tasks>
- **寫新 .bat** → 用 `<paved_path>` 骨架起手 → 跑 `/cmd-dev write <一句話描述>`
- **review 既有 .bat** → 跑 `/cmd-dev review <檔案路徑>`（吃 `<patterns>` 8 雷區掃一遍）
- **debug 失敗 .bat** → 跑 `/cmd-dev debug <檔案> <錯誤訊息或 errorlevel>`
- **加 logging** → `>> "%~dp0\run.log" 2>&1`（stdout + stderr）
- **暫停看輸出** → 結尾 `pause`（雙擊執行時用）；CI 環境**不要**留 pause
- **檢查指令存在** → `where <cmd> >nul 2>&1 || ( echo missing & exit /b 1 )`
</common_tasks>

<example>
- 多服務啟動 → `Deployment-Infra/start.bat`, search:`minikube tunnel`
- CI 包裝範本 → 暫無，新增時補進這裡
</example>

<hatch>
- 一次性指令（沒人會再讀）→ 寫 PS one-liner 就好，別開 .bat
- 跨平台需求 / 物件處理 / REST → 改寫 `.ps1`（`.bat` vs `.ps1` 選用決策見 `PowerShell/CLAUDE.md` `<selection_guide>`）；.bat 不可移植
- 互動式 prompt（讀 user input）→ `set /p var=請輸入: ` 但要記得 `setlocal EnableDelayedExpansion`
</hatch>

<fatal_implications>
- NEVER 在 prod-critical script 裡用 `del /q /s /f` 配變數而不檢查（變數空時會掃整顆 disk）
- NEVER 用 `format` / `diskpart` 沒先 dry-run
- NEVER `.bat` 內存明文 password / token（無 secret 機制）
- NEVER 從不可信來源下載 `.bat` 直接雙擊（cmd 不像 PS 有 execution policy 防線）
- NEVER 在 batch 內呼叫自己（無限遞迴）—— 改用 `goto` 或 `call :label`
</fatal_implications>
