# React + TypeScript 開發規範

<system_context>
React 18+ / 19 + TypeScript strict mode 前端開發守則。
適用於 Vite、Next.js、CRA 專案。預設 functional components + hooks。
統一技術選型見 `<paved_stack>`；找元件 / icon / template / 靈感見 `React & Typescript/frontend-resources.md`。
</system_context>

<critical_notes>
- MUST 開啟 tsconfig `strict: true`（含 noImplicitAny、strictNullChecks、strictFunctionTypes）
- MUST 加 `noUnusedLocals`、`noUnusedParameters`、`noImplicitReturns`、`noFallthroughCasesInSwitch`
- MUST 啟用 ESLint `react-hooks/exhaustive-deps` 並視為 error
- NEVER 用 `any`，未知型別用 `unknown` + type guard
- NEVER 用 class components（除非 ErrorBoundary 必要）
- NEVER 在 production code 用 `// @ts-ignore`，要改用 `// @ts-expect-error` + 原因
- ALWAYS 用 functional components + hooks
- ALWAYS 在 system boundary（API response、URL params）做 runtime validation（Zod）
</critical_notes>

<file_map>
src/components/         - 共用 UI 元件（PascalCase）
src/features/           - 功能模組（auth、dashboard...）
src/hooks/              - 共用 custom hooks（`useXxx.ts`）
src/lib/                - 純函式、utils、`cn()`
src/lib/api/            - 共用 axios client + SWR 信封 hook（`useApi`）+ 寫入 helper
src/types/              - 共用 type / interface
src/pages/ or app/      - 路由頁面
</file_map>

<paved_path>
- 命名：camelCase 變數 / 函式、PascalCase component / type、UPPER_SNAKE_CASE constant
- Boolean 變數加 `is` / `has` / `can` 前綴
- Component props 用 `interface`，union / utility type 用 `type`
- Interface 不加 `I` 前綴（`UserProfile` 非 `IUserProfile`）
- 所有 function 寫 explicit return type，arrow function 為主
- ID 等強約束值用 branded type：`type UserId = string & { __brand: 'UserId' }`
- API 邊界用 Zod schema，`z.infer<typeof Schema>` 推導型別
- 狀態管理優先 server state hook（SWR / React Query）+ useState/useReducer（local state）
</paved_path>

<paved_stack>
統一技術選型（一個決定，全專案照辦；資源對照見 `frontend-resources.md`）：

**Styling**
- ALWAYS 用 Tailwind utility + `cn()`（clsx + tailwind-merge）合併 className —— `cn()` 是唯一合併入口
  NEVER 手動字串拼接 className（`a + (x ? ' b' : '')`）—— Why: 條件 class 與 Tailwind 衝突解析交給 `cn()`，避免重複/失效
- 多 variant 元件用 `cva`（class-variance-authority）管理，不要一堆三元運算
- 顏色 / 圓角 / spacing 用 design-tokens（CSS var `var(--x)` / tokens.ts），NEVER hard-code 色票

**Components（Hybrid 策略）**
- 重量級 widget（Table、Form、DatePicker、Upload、Modal、Cascader）→ ALWAYS 用 antd
  Why: 行為 + a11y 複雜，自造易出錯
- layout / 卡片 / 按鈕 / 自訂視覺 → Tailwind + `cn()`，NEVER 為了排版硬塞 antd
- 複製型資源（shadcn / HyperUI / Aceternity）→ 貼進來改寫成 Tailwind，**不新增 runtime dependency**
- NEVER 同時引入第二個重量級元件庫（MUI/Chakra…）與 antd 並存

**Icons**
- 預設 `lucide-react`（functional UI icon 一律用它）
- 品牌 logo / lucide 沒有的 → react-icons（多套）或 Simple Icons，NEVER 為單一 icon 混搭多套風格

**Data layer**
- 讀取（server state）→ SWR 包成 `src/lib/api/useApi<T>`（統一拆信封）
- 寫入（POST/PUT/DELETE）→ `src/lib/api` 的 axios mutation helper
- 純非抓取 async（解析、計算）→ `useAsync`
- NEVER 在 component 各自 `axios.create()` —— ALWAYS 用 `src/lib/api/client`
  Why: baseURL / withCredentials / timeout / 攔截器要單點維護
- ALWAYS 在 API boundary 用 Zod 驗證 response（見 `<critical_notes>`）

**Forms**
- 複雜表單用 React Hook Form + `@hookform/resolvers` + Zod；簡單表單用受控 useState
</paved_stack>

<patterns>
**Props typing**
```ts
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  children?: React.ReactNode;
}
const Button = ({ label, onClick, variant = 'primary' }: ButtonProps): JSX.Element => { ... }
```

**Event handlers**
- `React.ChangeEvent<HTMLInputElement>` / `React.MouseEvent<HTMLButtonElement>`
- `React.FormEvent<HTMLFormElement>` for submit

**Hooks typing**
- `useState<User | null>(null)` 顯式標型
- `useRef<HTMLDivElement>(null)` for DOM ref
- Custom hook 回傳 `as const` tuple 或 named object

**Context**
- 預設值用 `null`，consumer 用 hook 包裝後拋錯（避免 optional chaining 蔓延）

**Effect**
- 寫 useEffect 前先問：能否用 derived state / event handler 取代？
- 有 subscription / timer 必須回傳 cleanup function
- exhaustive-deps 警告視為 error
</patterns>

<common_tasks>
- 加 component → `src/components/Xxx/Xxx.tsx` + `index.ts` re-export
- 加 hook → `src/hooks/useXxx.ts`，命名以 `use` 開頭
- 加 API 讀取 → `src/lib/api/useApi<T>(url)`；寫入 → `src/lib/api` mutation helper；配 Zod 驗證
- 加 route → 看專案路由系統（Next app router / React Router）
- 找元件 / icon / template / 動效 / 靈感 → `React & Typescript/frontend-resources.md`（先看決策樹）
</common_tasks>

<example>
- 強制 union state → `src/features/auth/AuthState.ts`, search:`type AuthState`
- Discriminated union → `src/lib/result.ts`, search:`type Result`
- Branded ID → `src/types/ids.ts`, search:`__brand`
</example>

<hatch>
- 第三方 library 沒有 type → 寫 `src/types/<lib>.d.ts` declare module
- 真的需要 escape → 用 `unknown` + type guard，不要 `any`
- 效能瓶頸才用 `memo` / `useMemo` / `useCallback`，不要預先優化
</hatch>

<fatal_implications>
- NEVER 在 render 中發 side effect（API call、setState）
- NEVER mutate props 或 state（用 immutable update）
- NEVER 把 secret / API key 寫進前端 code（用 env var 且只放 public 值）
- NEVER 用 array index 當 key（除非 list 完全靜態）
- NEVER 把整個 object 當 useEffect dep（會無限 loop）
</fatal_implications>
