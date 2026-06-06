# 前端資源網站 Catalog（React + TypeScript + Tailwind）

> 開發時找元件 / icon / template / 靈感的對照表。
> 標記說明：✅ 本專案（MyDevWebFrontend）採用　🟡 候選 / 視情況　🔍 靈感來源（貼進來改寫成 Tailwind，不直接 import）
> Stack 前提：React 19 + TS strict + Tailwind 4 + **antd 6（重量級 widget）** + **Tailwind + `cn()`（自訂 UI）**。詳見 `React & Typescript/CLAUDE.md` 的 `<paved_stack>`。

[TOC]

## 怎麼用這份清單（決策樹）

1. **要 Table / DatePicker / Form / Upload / Modal 這種「行為複雜、a11y 難寫」的 widget** → 先用 ✅ **antd 6**，不要自己造。
2. **要 layout / 卡片 / 按鈕 / hero / 自訂視覺** → 去「Copy-paste blocks」找 → 貼進來改成 Tailwind + `cn()`，**擁有 source code**，不新增 runtime dependency。
3. **要動效 / 行銷頁亮點** → 去「動效元件」找，配 `motion`（framer-motion）。
4. **要 icon** → ✅ **lucide-react**（預設）；多品牌 logo 用 react-icons / Simple Icons。
5. **要圖表 / dashboard** → Recharts / Tremor；資料表格用 `@tanstack/react-table`（已裝）。
6. **沒靈感** → 去「靈感 / 設計參考」。

---

## 1. 元件庫（installable，import 進來用）

| 資源 | 連結 | 何時用 |
|------|------|--------|
| ✅ **Ant Design (antd 6)** | https://ant.design | 重量級 widget：Table、Form、DatePicker、Upload、Modal、Cascader。企業後台首選，a11y 與行為已處理好 |
| 🟡 MUI (Material UI) | https://mui.com | 需要 Material Design 或超強 DataGrid（付費 X）時。bundle 較大（100–200KB gz） |
| 🟡 Mantine | https://mantine.dev | 100+ 元件 + 大量好用 hooks（`@mantine/hooks` 可單獨用），SSR 友善 |
| 🟡 Chakra UI | https://chakra-ui.com | 快速原型、style props 寫法 |
| 🟡 HeroUI（前 NextUI） | https://www.heroui.com | 想要現代感、Tailwind-native 的完整元件庫 |

> 原則：**一個專案只挑一個重量級元件庫**（這裡是 antd），避免多套 design system 打架與 bundle 膨脹。

## 2. Copy-paste 元件 / Blocks（Tailwind，貼上即擁有）🔍

> 這是 Hybrid 策略的主力來源：複製 markup → 貼進專案 → 改寫成 `cn()` + design-tokens。不裝成 dependency。

| 資源 | 連結 | 重點 |
|------|------|------|
| 🔍 **shadcn/ui** | https://ui.shadcn.com | 2026 事實標準。CLI 複製 Radix-based 元件進專案，full ownership、零 runtime。本專案不跑 CLI，但拿它的結構/變體當範本 |
| 🔍 **shadcn blocks / shadcnblocks** | https://www.shadcnblocks.com | 整段 section（hero、pricing、feature） |
| 🔍 **HyperUI** | https://www.hyperui.dev | 400+ 純 HTML+Tailwind snippet，無依賴，最適合直接貼 |
| 🔍 **Preline UI** | https://preline.co | 640+ 免費元件，Tailwind v4，HTML-first |
| 🔍 **DaisyUI** | https://daisyui.com | Tailwind plugin，30+ theme，語意化 class（`btn` `card`）。可選裝 |
| 🔍 **Flowbite** | https://flowbite.com | Tailwind 元件 + 互動 JS |
| 🔍 **Tailgrids** | https://tailgrids.com | 免費 + 付費，大量 marketing block |
| 🔍 Float UI / Meraki UI / Kometa | https://floatui.com · https://merakiui.com | 更多免費 Tailwind block |
| 🔍 **Headless UI** | https://headlessui.com | Tailwind 團隊出的 unstyled 行為元件（Menu/Dialog/Combobox），要自己上 style |
| 💰 **Tailwind Plus（前 Tailwind UI）** | https://tailwindcss.com/plus | 官方付費，品質天花板，可當付費靈感 |

## 3. 動效元件（Tailwind + Motion）🔍

| 資源 | 連結 | 重點 |
|------|------|------|
| 🔍 **Aceternity UI** | https://ui.aceternity.com | 200+ 炫砲 block（hero、bento、parallax、glow），shadcn 生態旗艦 |
| 🔍 **Magic UI** | https://magicui.design | 行銷微互動（animated beam、retro grid、neon），亮暗模式皆佳 |
| 🔍 **Motion Primitives** | https://motion-primitives.com | 乾淨的 motion 元件 |
| 🔍 **React Bits** | https://www.reactbits.dev | 互動 / 文字動效效果集 |
| 🔍 **Animate UI** | https://animate-ui.com | 動畫版 shadcn 元件 |
| ⚙️ **Motion（framer-motion）** | https://motion.dev | 上面這些的動畫引擎；要動效就裝它 |
| 📚 awesome-shadcn-ui | https://github.com/birobirobiro/awesome-shadcn-ui | shadcn 生態總匯整 |

## 4. Icons

| 資源 | 連結 | 重點 |
|------|------|------|
| ✅ **Lucide** (`lucide-react`) | https://lucide.dev | **預設 icon set**。1500+，feather 風格、tree-shaking 好、shadcn 生態預設 |
| 🟡 Heroicons | https://heroicons.com | Tailwind 官方 icon，outline/solid，數量少而精 |
| 🟡 Tabler Icons | https://tabler.io/icons | 5000+，24×24 / 2px stroke 一致性高 |
| 🟡 Phosphor | https://phosphoricons.com | 7700+、6 種 weight（含 duotone），變化最多 |
| 🟡 **react-icons**（已裝） | https://react-icons.github.io/react-icons | 一次涵蓋多套（含 `Lu`=Lucide、`Si`=Simple Icons）。多品牌 logo / 雜牌 icon 時用 |
| 🟡 Iconify | https://iconify.design | 35 萬+ icon、200+ 套，統一 API |
| 🟡 Simple Icons | https://simpleicons.org | 品牌 logo（GitHub、Google…） |

> 規則：UI functional icon **統一用 lucide-react**；只有 lucide 沒有的（品牌 logo、特殊 icon）才退回 react-icons，避免風格雜亂。

## 5. 圖表 / Dashboard / 資料

| 資源 | 連結 | 重點 |
|------|------|------|
| ✅ **TanStack Table**（已裝） | https://tanstack.com/table | Headless table，配 antd Table 或自畫皆可 |
| 🟡 **Recharts** | https://recharts.org | React 圖表首選，API 簡單 |
| 🟡 **Tremor** | https://www.tremor.so | Copy-paste 的 dashboard / chart 元件（KPI card、chart、table） |
| 🟡 visx / nivo / ECharts | https://airbnb.io/visx · https://nivo.rocks · https://echarts.apache.org | 進階 / 客製化圖表 |
| 🔍 **TailAdmin (React+TW4)** | https://github.com/TailAdmin/free-react-tailwind-admin-dashboard | 免費 admin template，抄 layout |
| 🔍 shadcn-admin / Tremor template | https://github.com/satnaing/shadcn-admin | dashboard 結構參考 |

## 6. Headless / 無樣式行為元件（自訂 design system 時）

| 資源 | 連結 | 重點 |
|------|------|------|
| 🟡 **Base UI** | https://base-ui.com | Radix 原班人馬新作，維護中、a11y 佳。需要 headless 時的首選 |
| 🟡 **React Aria (Adobe)** | https://react-spectrum.adobe.com/react-aria | a11y 最完整的 headless hooks/components |
| 🟡 Ariakit | https://ariakit.org | 另一套 headless |
| ⚠️ Radix UI | https://www.radix-ui.com | shadcn 底層，但**官方已宣布不再積極維護** → 新元件優先 Base UI / React Aria |

## 7. 靈感 / 設計參考 🔍

| 資源 | 連結 | 重點 |
|------|------|------|
| 🔍 Mobbin | https://mobbin.com | 真實 App / Web UI 截圖庫，找互動 pattern |
| 🔍 Land-book / Godly | https://land-book.com · https://godly.website | landing page 靈感 |
| 🔍 Dribbble / Behance | https://dribbble.com | 視覺靈感（注意別照抄不可行的設計） |
| 🔍 Vercel Templates | https://vercel.com/templates | 可跑的完整專案範本 |
| 📚 Refactoring UI | https://www.refactoringui.com | 非設計師也能變好看的實戰書 |
| 📚 web-design-guidelines（本機 skill） | `.claude/skills/web-design-guidelines/SKILL.md` | 專案內建的設計守則，做 UI 前先看 |

## 8. 工具 / Utilities

| 資源 | 連結 | 重點 |
|------|------|------|
| ✅ **cn()**（clsx + tailwind-merge） | `src/utils/clsx.tsx` | 合併 className 唯一入口。⚠️ `clsx` 尚未列入 package.json，建議 `npm install clsx` 補成顯式 dependency |
| 🟡 **cva**（class-variance-authority） | https://cva.style | 元件多 variant 時用它管理 class（取代一堆三元運算） |
| ⚙️ tweakcn | https://tweakcn.com | 視覺化調 shadcn/Tailwind theme，輸出 CSS variables |
| ⚙️ Realtime Colors | https://realtimecolors.com | 配色 + 即時預覽 |
| ⚙️ Tailwind Play | https://play.tailwindcss.com | 線上試 Tailwind |
| ⚙️ SVGR | https://react-svgr.com | SVG → React component |
| ⚙️ Iconify / Lottie | https://lottiefiles.com | 動畫素材 |
| 📖 Tailwind 官方文件 | https://tailwindcss.com/docs | v4 用 CSS-first `@theme`（本專案 `src/index.css` 已用） |

## 9. 表單 / 驗證 / 資料抓取

| 資源 | 連結 | 重點 |
|------|------|------|
| 🟡 **React Hook Form** | https://react-hook-form.com | 複雜表單；配 `@hookform/resolvers` + Zod |
| ✅ **Zod** | https://zod.dev | API boundary / URL params runtime validation（框架規範要求） |
| ✅ **SWR**（已裝） | https://swr.vercel.app | server-state 讀取（本專案資料抓取主力） |
| 🟡 TanStack Query | https://tanstack.com/query | SWR 的替代，功能更多（mutation/cache 管理強） |
| ✅ **axios**（已裝） | https://axios-http.com | HTTP client，寫入操作（POST/PUT/DELETE）用它 |

---

## 維護

- 新發現好用資源 → 加進對應分類，標好 ✅/🟡/🔍。
- 某資源在本專案落地（裝起來用了）→ 改標 ✅ 並在 `React & Typescript/CLAUDE.md` `<paved_stack>` 同步。
- 死連結 / 停止維護 → 直接刪或標 ⚠️（如 Radix）。
