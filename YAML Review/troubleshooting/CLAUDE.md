# K8s 部署經驗庫（troubleshooting/）

<system_context>
公司內部 K8s 環境踩過的坑與 YAML 層級修法。
`/k8s-review` 指令會自動讀這資料夾所有 case，作為 audit checklist 的延伸。
無 kubectl 權限環境專用——所有修法 MUST 是 YAML 改寫。
</system_context>

<critical_notes>
- MUST 每撞一個新坑就寫一個 case file，不要靠記憶
- MUST case file 含「症狀 / 根因 / YAML 修法（diff）」三段，缺一不可
- MUST 檔名 kebab-case，描述症狀（不是描述修法）
- NEVER 在 case 裡放公司名 / 內網 hostname / token / 真實 namespace（用 `<company>` / `<internal-host>` 占位）
- NEVER 寫成「跑某指令排查」——這環境不能下指令
</critical_notes>

<file_map>
_template.md            - case 模板（複製來用）
*.md                    - 各 case file，檔名即症狀 slug
</file_map>

<paved_path>
**檔名規則**：`<symptom-slug>.md`，描述「使用者觀察到什麼」而非「修了什麼」

- ✅ `image-pull-backoff-private-registry.md`
- ✅ `pod-stuck-pending-no-storageclass.md`
- ❌ `add-imagepullsecret.md`（這是修法，不是症狀）

**case 結構**（嚴格遵守，`/k8s-review` 才能正確 parse）：

```markdown
---
symptom: <一句話症狀>
severity: critical | warn | info
tags: [security, network, storage, rbac, admission, helm, argocd]
last_seen: YYYY-MM-DD
---

# <症狀標題>

## 症狀
<使用者看到的現象 / 錯誤訊息 / event 字樣>

## 根因
<為何發生，公司環境的什麼限制觸發>

## 偵測訊號（YAML 層級）
<在 YAML 看到什麼模式就要警覺，給 `/k8s-review` 抓>
- 例如：`spec.template.spec.containers[*].image` 開頭是 `internal-registry.<company>.com/`
- 例如：缺少 `spec.template.spec.imagePullSecrets`

## YAML 修法
\`\`\`yaml
# Before
spec:
  template:
    spec:
      containers:
        - image: internal-registry.example.com/app:v1

# After
spec:
  template:
    spec:
      imagePullSecrets:
        - name: registry-cred
      containers:
        - image: internal-registry.example.com/app:v1
\`\`\`

## 相關
- 相關 case：[other-case.md](./other-case.md)
- 公司文件：<URL 或 wiki 路徑>
```

**分類 tag**

- `security`：PSS、securityContext、runAsUser
- `network`：NetworkPolicy、Service、Ingress、DNS
- `storage`：PVC、StorageClass、volume mount
- `rbac`：ServiceAccount、Role、Binding
- `admission`：Kyverno、Gatekeeper、OPA、required label
- `helm`：chart 結構、values 漂移
- `argocd`：sync policy、project、targetRevision
- `image`：registry、tag、pull secret
- `resource`：requests / limits / quota
</paved_path>

<patterns>
**何時該開新 case**

- 撞到第一次：先解決，事後 30 分鐘內補 case（趁記憶熱）
- 撞到第二次：表示第一次沒寫好，回去補偵測訊號
- 同一根因不同症狀：寫成兩個 case + 互相 cross-link

**何時該合併 case**

- 兩個 case 根因相同 + 修法相同 → 合併，症狀寫成 list
- 偵測訊號可以用同一個 YAML pattern 抓 → 合併
</patterns>

<common_tasks>
- 新增 case → 複製 `_template.md` 為 `<symptom-slug>.md`，填三段
- 過時 case → frontmatter 加 `deprecated: true` + `superseded_by: <new-case>`，**不要刪檔**（保留歷史）
- 翻舊案 → 用 grep 找 tag / 症狀關鍵字
</common_tasks>

<example>
（此資料夾刻意先空著，撞到坑再填。已有的 case 會列在這。）

- _template.md — case 模板
</example>

<fatal_implications>
- NEVER 直接寫指令排查步驟（環境不允許 kubectl）
- NEVER 把公司敏感資訊（registry URL、namespace、ingress hostname、token）寫進 case
- NEVER 刪除舊 case，只能標 deprecated
</fatal_implications>
