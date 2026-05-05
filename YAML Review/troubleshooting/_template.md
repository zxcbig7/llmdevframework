---
symptom: <一句話描述使用者看到什麼>
severity: warn
tags: []
last_seen: YYYY-MM-DD
---

# <症狀標題>

## 症狀

<使用者觀察到的現象。能寫多具體寫多具體：>
<- Pod 狀態（Pending / CrashLoopBackOff / ImagePullBackOff / Error）>
<- Event 訊息（從 Argo / dashboard / log viewer 看到的字樣）>
<- HTTP 行為（503 / timeout / TLS handshake fail）>

## 根因

<為何發生。重點放在「公司環境的什麼限制」觸發了這個現象。>
<例：cluster 套用 PSS restricted profile，預設 runAsUser=0 被擋。>

## 偵測訊號（YAML 層級）

<列出 `/k8s-review` 應該在 YAML 看到什麼 pattern 就要警告。>
<這段是經驗庫對自動化最有價值的部分——寫得越具體，AI 抓得越準。>

- `<JSONPath / 欄位>` <條件>
- 例：`spec.template.spec.securityContext.runAsNonRoot` 不是 `true`
- 例：`spec.template.spec.containers[*].image` 不是 `<approved-registry>/*`

## YAML 修法

```yaml
# Before
<貼出有問題的 YAML 片段>

# After
<貼出修好的 YAML 片段>
```

## 相關

- 相關 case：
- 公司文件 / wiki：
- 外部參考：
