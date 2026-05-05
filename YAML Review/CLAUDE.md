# YAML Review 規範

<system_context>
YAML 檔案 review 與撰寫守則。
涵蓋 Kubernetes manifests、Helm chart、ArgoCD Application、GitHub Actions workflow、Docker Compose、cert-manager / external-secrets 等 CRD。
</system_context>

<critical_notes>
- MUST 縮排用 2 spaces，NEVER tab
- MUST 檔案結尾保留一行空行（POSIX）
- MUST 用 `---` 分隔多 document，每份開頭明確 `apiVersion` + `kind`
- MUST 字串含特殊字元（`:`、`@`、`#`、開頭數字）一律加引號
- MUST 所有 secret / token / password 走 SealedSecret / ExternalSecret / sealed-secrets / SOPS，NEVER 明文
- MUST K8s resource 都加 `metadata.labels`（至少 `app`、`environment`）方便 selector
- NEVER commit kubeconfig、`.env`、private key、cloudflared credentials
- NEVER 在 Helm values 寫死 image tag 為 `latest`（image pull 不可重現）
- ALWAYS 加 `resources.requests` + `limits`（CPU、memory），避免 noisy neighbor
- ALWAYS 跑 `kubectl --dry-run=client -o yaml` 或 `helm lint` / `kubeval` 驗證
</critical_notes>

<file_map>
本資料夾內容：
k8s-review-command.md   - `/k8s-review` slash command（複製到 ~/.claude/commands/k8s-review.md）
troubleshooting/        - 公司內部 K8s 部署經驗庫（撞到坑就補 case）
troubleshooting/CLAUDE.md - 經驗庫結構規範
troubleshooting/_template.md - case 模板

審查目標 YAML 通常擺放位置：
infra/                  - 共用 cluster 層級資源（namespace、CRD、ClusterIssuer）
charts/<name>/          - Helm chart（Chart.yaml + templates/ + values*.yaml）
argocd/                 - ArgoCD Application / AppProject
.github/workflows/      - GitHub Actions（檔名 kebab-case，e.g. `build-frontend.yml`）
docker-compose*.yml     - 本機開發 / 整合測試
</file_map>

<paved_path>
**通用**

- 鍵名 kebab-case（K8s 慣例）；Helm template 變數 camelCase（Go template 慣例）
- 多環境分檔：`values.yaml`（共通）+ `values-dev.yaml` / `values-stg.yaml` / `values-prod.yaml`
- ConfigMap / Secret 名加 hash 後綴或用 `helm.sh/hook` 觸發 rollout
- Image tag 用 immutable tag（git SHA / semver `V.X.X.X.X.X`），prod 禁 `latest`

**Kubernetes manifest 結構**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mydevweb-frontend
  namespace: prod
  labels:
    app: mydevweb-frontend
    environment: prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mydevweb-frontend
  template:
    metadata:
      labels:
        app: mydevweb-frontend
        environment: prod
    spec:
      containers:
        - name: app
          image: zxcbig7/mydevweb-frontend:V.1.0.0.0.0
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits:   { cpu: 500m, memory: 512Mi }
          livenessProbe:
            httpGet: { path: /healthz, port: 80 }
          readinessProbe:
            httpGet: { path: /readyz, port: 80 }
```

**Helm**

- `Chart.yaml` 必填 `apiVersion: v2`、`name`、`version`（chart 版本，semver）、`appVersion`（應用版本）
- 模板用 `{{ .Values.x }}` 引用，**不要**在模板裡寫死值
- 用 `_helpers.tpl` 集中放 label / name template
- `helm lint` + `helm template` 必跑

**ArgoCD Application**

- `spec.project` 明確指定，不要用 default
- `syncPolicy.automated.prune: true` + `selfHeal: true`（看環境決定）
- `source.targetRevision` 用 tag 或 branch，prod 禁 `HEAD`

**GitHub Actions**

- `permissions:` 一律明寫（principle of least privilege），預設 `read-all`，需要寫 token 才開
- `secrets.GITHUB_TOKEN` / `secrets.XXX` 走 secret，NEVER 寫死
- `runs-on:` 鎖版本（`ubuntu-24.04` 不寫 `ubuntu-latest`）
- Reusable workflow 用 `workflow_call`，避免複製貼上
- Job timeout 設定 `timeout-minutes`，避免 hang 住吃 quota
</paved_path>

<patterns>
**Review checklist（看到 YAML PR 必查）**

- [ ] `apiVersion` + `kind` 正確且非 deprecated（K8s 1.29+ 已移除多個 v1beta1）
- [ ] `metadata.namespace` 明確（沒設等於 `default`，常出包）
- [ ] Image tag 不是 `latest`、不是 mutable
- [ ] `resources.requests` + `limits` 都有
- [ ] `livenessProbe` + `readinessProbe` 都有（exec / httpGet / tcpSocket）
- [ ] Secret / token 不在明文
- [ ] Label / selector 一致（`spec.selector.matchLabels` ⊆ `spec.template.metadata.labels`）
- [ ] Service `targetPort` 對得到 container `containerPort`
- [ ] Ingress `host` / TLS secret 對得到 cert-manager Certificate
- [ ] Helm values 在所有環境（dev/stg/prod）都有對應檔且 key 一致

**多 document 分隔**

```yaml
---
apiVersion: v1
kind: ConfigMap
...
---
apiVersion: v1
kind: Service
...
```

**字串引號規則**

- 數字開頭、含 `:` `@` `#` `*` `&` `?` → 加引號
- 布林字串 `"yes"` `"no"` `"true"` `"false"` → 加引號（避免 YAML 1.1 自動轉 bool）
- Tag 版本 `"V.1.0.0.0.0"` → 加引號
</patterns>

<common_tasks>
- 加新 K8s resource → 確認 namespace + label + resources + probe + image tag
- 加 Helm chart → `helm create <name>` → 改 `values.yaml` + templates → `helm lint`
- 加 ArgoCD App → 寫 `Application` CR → `kubectl apply -n argocd -f xxx.yaml`
- 加 GH Action workflow → 從 reusable workflow 起手，明寫 `permissions` + `timeout-minutes`
- Review YAML PR → 對照 `<patterns>` checklist 一條一條過
- **無 kubectl 環境 audit YAML** → 跑 `/k8s-review <檔案或資料夾>`（吃 `troubleshooting/` 經驗庫）
- **撞到新部署坑** → 30 分鐘內補 `troubleshooting/<symptom-slug>.md`（複製 `_template.md`）
</common_tasks>

<example>
- Frontend Deployment → `charts/mydevweb-frontend/templates/deployment.yaml`, search:`livenessProbe`
- ArgoCD Application → `argocd/mydevweb-prod.yaml`, search:`syncPolicy`
- GitHub Actions tag deploy → `.github/workflows/release.yml`, search:`workflow_call`
- ClusterSecretStore → `infra/cluster-secret-store.yaml`, search:`SecretStore`
- Cert-manager Issuer → `infra/cluster-issuer.yaml`, search:`acme`
</example>

<hatch>
- 開發 / spike 階段 image 可用 mutable tag（如 `dev`），但 prod merge 前必改
- Legacy chart 用舊 apiVersion 一時改不動 → 加 `# TODO: migrate to apps/v1` 標記 + 開 issue
- 跨 env 微小差異 → 用 `values-<env>.yaml` 覆蓋；差異大 → 拆兩個 chart
</hatch>

<fatal_implications>
- NEVER commit 明文 secret / token / kubeconfig / private key
- NEVER `imagePullPolicy: Always` + `image: xxx:latest` 用於 prod（不可追溯）
- NEVER ArgoCD `automated.prune: true` 開在共用 namespace 沒先想清楚（會刪掉手動建的資源）
- NEVER GitHub Actions 用 `pull_request_target` + checkout PR code 不加防護（RCE 風險）
- NEVER K8s `hostNetwork: true` / `privileged: true` / `runAsUser: 0` 沒明確理由
- NEVER 用 `kubectl apply -f` 部署到 prod（要走 GitOps / ArgoCD）
</fatal_implications>
