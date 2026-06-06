# render.md — 匯出 PNG/SVG（mmdc + Kroki fallback）

`.md` 裡的 mermaid GitHub/VSCode 會直接 render，**多數情況不用匯出**。
要靜態圖檔（投影片、PDF、不吃 mermaid 的地方）才走這裡。優先 mmdc，無 Node 用 Kroki。

---

## 方案 A · mmdc（本機渲染，需 Node）

### 安裝（一次）

```powershell
npm install -g @mermaid-js/mermaid-cli
mmdc --version   # 確認裝好
```

### 匯出單一 .mmd

```powershell
# SVG（向量、首選，清晰又小）
mmdc -i diagram.mmd -o diagram.svg -b transparent

# PNG（要點陣時，放大倍率 2 較清楚）
mmdc -i diagram.mmd -o diagram.png -b transparent -s 2
```

### 直接吃 .md（把檔內每個 mermaid 區塊轉成圖）

```powershell
# 產出 diagram-1.svg、diagram-2.svg…，並複製一份 .md 把區塊換成圖連結
mmdc -i notes.md -o notes-out.md
```

> 常用旗標：`-b transparent` 透明背景、`-s 2` 放大、`-t dark` 套深色、`-w 1200` 指定寬度。
> init block 的 themeVariables 仍會生效，`-t` 只在沒有 init 時當預設。

---

## 方案 B · Kroki API（無 Node 也能用）

把 mermaid 原始碼 POST 到 Kroki，回傳 SVG/PNG。需要對外網路。

```powershell
$src = Get-Content diagram.mmd -Raw
Invoke-WebRequest -Uri "https://kroki.io/mermaid/svg" `
  -Method Post -Body $src -ContentType "text/plain" `
  -OutFile diagram.svg
```

> 公司網路擋外網 → 可自架 Kroki（`docker run -p 8000:8000 yuzutech/kroki`），把 URL 換成 `http://localhost:8000/...`。
> 敏感圖**不要**送公開 Kroki（原始碼會離開內網）；自架或改用 mmdc。

---

## 一鍵腳本

`references/render-mermaid.ps1` 包好上面邏輯：mmdc 在就用 mmdc，否則 fallback Kroki。

```powershell
# 匯出單檔
./render-mermaid.ps1 -InputPath diagram.mmd -Format svg

# 匯出整個 .md 裡所有 mermaid 區塊（mmdc 路徑）
./render-mermaid.ps1 -InputPath notes.md -Format png
```

參數：`-InputPath`（.mmd 或 .md）、`-Format`（svg|png，預設 svg）、`-Scale`（PNG 放大，預設 2）、`-UseKroki`（強制走 Kroki）。
