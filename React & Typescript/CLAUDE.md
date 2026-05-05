# React + TypeScript 開發規範

<system_context>
React 18+ / 19 + TypeScript strict mode 前端開發守則。
適用於 Vite、Next.js、CRA 專案。預設 functional components + hooks。
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
src/lib/                - 純函式、API client、utils
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
- 狀態管理優先 React Query（server state）+ useState/useReducer（local state）
</paved_path>

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
- 加 API call → `src/lib/api/`，配 Zod schema 驗證 response
- 加 route → 看專案路由系統（Next app router / React Router）
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
