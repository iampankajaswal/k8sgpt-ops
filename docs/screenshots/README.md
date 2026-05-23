# Screenshots & Visual Examples

This directory contains visual examples of k8sgpt-ops in action.

## 📸 How to Take Screenshots

If you want to capture your own terminal output:

### macOS
```bash
# Full screen
Cmd + Shift + 3

# Selected area
Cmd + Shift + 4

# Specific window
Cmd + Shift + 4, then Space, click window
```

### Linux
```bash
# Using gnome-screenshot
gnome-screenshot -a

# Using scrot
scrot -s screenshot.png
```

### Windows
```bash
# Using built-in
Win + Shift + S
```

---

## 📋 Suggested Screenshots to Capture

### 1. Setup Process
**File:** `01-setup.png`
```bash
make setup
```
Shows k8sgpt configuration with Ollama.

### 2. Validation Success
**File:** `02-validate.png`
```bash
make validate
```
Shows all checks passed.

### 3. Healthy Cluster
**File:** `03-healthy-cluster.png`
```bash
make deploy-healthy
kubectl get pods -n k8sgpt
make analyze
```
Shows "No issues detected".

### 4. Broken Deployment
**File:** `04-broken-deployment.png`
```bash
make deploy-broken
kubectl get pods -n k8sgpt
```
Shows ImagePullBackOff status.

### 5. Issue Detection
**File:** `05-issue-detection.png`
```bash
make analyze
```
Shows detected issues with details.

### 6. Full Test Output
**File:** `06-full-test.png`
```bash
make local-test
```
Shows complete test cycle with colored output.

### 7. Enhanced Test Script
**File:** `07-enhanced-script.png`
```bash
./scripts/local-test.sh
```
Shows colored output with emojis.

### 8. JSON Report
**File:** `08-json-report.png`
```bash
cat report.json | jq '.'
```
Shows formatted JSON report.

### 9. Make Help
**File:** `09-make-help.png`
```bash
make help
```
Shows all available commands.

### 10. GitHub Actions
**File:** `10-github-actions.png`
From GitHub Actions tab showing workflow run.

---

## 🎨 ASCII Diagrams

### Workflow Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                   k8sgpt-ops Workflow                       │
└─────────────────────────────────────────────────────────────┘

Developer                  Local Testing              GitHub Actions
    │                           │                           │
    │  1. Edit manifests        │                           │
    ├──────────────────────────>│                           │
    │                           │                           │
    │  2. make local-test       │                           │
    ├──────────────────────────>│                           │
    │                           │                           │
    │                      ┌────▼─────┐                     │
    │                      │  Deploy  │                     │
    │                      │  to k8s  │                     │
    │                      └────┬─────┘                     │
    │                           │                           │
    │                      ┌────▼─────┐                     │
    │                      │ k8sgpt   │                     │
    │                      │ Analyze  │                     │
    │                      └────┬─────┘                     │
    │                           │                           │
    │  3. Issues found?         │                           │
    │<──────NO/YES──────────────┤                           │
    │                           │                           │
    │  4. git push              │                           │
    ├───────────────────────────┼──────────────────────────>│
    │                           │                           │
    │                           │                      ┌────▼─────┐
    │                           │                      │   Run    │
    │                           │                      │ Workflow │
    │                           │                      └────┬─────┘
    │                           │                           │
    │                           │                      ┌────▼─────┐
    │                           │                      │ k8sgpt   │
    │                           │                      │ Validate │
    │                           │                      └────┬─────┘
    │                           │                           │
    │  5. PR status update      │                           │
    │<──────────────────────────┼───────────────────────────┤
    │   ✅ Pass / ❌ Fail       │                           │
    │                           │                           │
```

### Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    k8sgpt-ops Stack                         │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  User Terminal   │
│  (make commands) │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐       ┌──────────────────┐
│    Makefile      │──────>│  Shell Scripts   │
│  (automation)    │       │  (analyze.sh,    │
└──────────────────┘       │   setup.sh, etc) │
                           └────────┬─────────┘
                                    │
                                    ▼
                           ┌──────────────────┐
                           │   k8sgpt CLI     │
                           │  (analysis tool) │
                           └────────┬─────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                ▼                   ▼                   ▼
       ┌──────────────┐    ┌──────────────┐   ┌──────────────┐
       │  Ollama      │    │   OpenAI     │   │    Azure     │
       │ (tinyllama)  │    │   (gpt-4o)   │   │   OpenAI     │
       │  637 MB      │    │    Cloud     │   │    Cloud     │
       │   Local      │    │              │   │              │
       └──────┬───────┘    └──────┬───────┘   └──────┬───────┘
              │                   │                   │
              └───────────────────┴───────────────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │  Kubernetes API  │
                         │   (analyzes      │
                         │    resources)    │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │   JSON Report    │
                         │ (report.json)    │
                         └──────────────────┘
```

### Local Test Flow
```
make local-test
     │
     ├──> 1. Cleanup old resources
     │         kubectl delete deployment healthy-app broken-app
     │
     ├──> 2. Deploy healthy app
     │         kubectl apply -f examples/healthy.yaml
     │         Status: ✅ Running
     │
     ├──> 3. Deploy broken app
     │         kubectl apply -f examples/broken.yaml
     │         Status: ❌ ImagePullBackOff
     │
     ├──> 4. Wait for stabilization
     │         sleep 15
     │
     ├──> 5. Run k8sgpt analysis
     │         k8sgpt analyze --namespace k8sgpt
     │         │
     │         ├──> Query Ollama (tinyllama)
     │         │    "Analyze this error..."
     │         │
     │         └──> Generate recommendations
     │              "1. Check image tag..."
     │              "2. Use valid tag..."
     │
     └──> 6. Report results
           ┌───────────────────────────┐
           │ Issues detected: 2        │
           │ - Deployment: 0 replicas  │
           │ - Pod: ImagePullBackOff   │
           └───────────────────────────┘
           Exit code: 1 (failure)
```

### CI/CD Pipeline Flow
```
GitHub Push
     │
     ▼
┌────────────────┐
│ GitHub Actions │
│   Triggered    │
└────┬───────────┘
     │
     ├──> 1. Setup Environment
     │    - Install kubectl, kind, k8sgpt
     │    - Start Ollama
     │    - Pull tinyllama model
     │
     ├──> 2. Create kind cluster
     │    - kind create cluster
     │    - Wait for ready
     │
     ├──> 3. Configure k8sgpt
     │    - k8sgpt auth add --backend ollama
     │    - k8sgpt auth default
     │
     ├──> 4. Deploy test workloads
     │    - kubectl apply healthy.yaml
     │    - kubectl apply broken.yaml (if testing)
     │
     ├──> 5. Run validation
     │    - k8sgpt analyze
     │    - Generate report.json
     │
     ├──> 6. Parse results
     │    - jq extract issues
     │    - Count problems
     │
     ├──> 7. Post PR comment
     │    ┌──────────────────────────┐
     │    │ k8sgpt Analysis Report   │
     │    │ ❌ 2 issues detected     │
     │    │ - Deployment error       │
     │    │ - Pod ImagePullBackOff   │
     │    └──────────────────────────┘
     │
     └──> 8. Set status
          ✅ Pass (if no issues)
          ❌ Fail (if issues found)
```

### Model Comparison
```
┌────────────────────────────────────────────────────────┐
│              LLM Model Comparison                      │
└────────────────────────────────────────────────────────┘

┌──────────────┬──────────┬──────────┬──────────┬────────┐
│    Model     │   Size   │  Speed   │ Quality  │  Cost  │
├──────────────┼──────────┼──────────┼──────────┼────────┤
│ qwen2.5:0.5b │  397 MB  │   ⚡⚡⚡   │    ⭐⭐   │  FREE  │
│              │          │ 2-3 sec  │  Basic   │  Local │
├──────────────┼──────────┼──────────┼──────────┼────────┤
│  tinyllama   │  637 MB  │   ⚡⚡⚡   │   ⭐⭐⭐  │  FREE  │
│  (RECOMMEND) │          │ 4-5 sec  │   Good   │  Local │
├──────────────┼──────────┼──────────┼──────────┼────────┤
│  phi3:mini   │  2.2 GB  │    ⚡⚡   │  ⭐⭐⭐⭐ │  FREE  │
│              │          │ 7-8 sec  │  Better  │  Local │
├──────────────┼──────────┼──────────┼──────────┼────────┤
│   llama3     │  4.7 GB  │    ⚡    │ ⭐⭐⭐⭐⭐│  FREE  │
│              │          │ 12-15sec │   Best   │  Local │
├──────────────┼──────────┼──────────┼──────────┼────────┤
│  gpt-4o-mini │  Cloud   │   ⚡⚡⚡   │ ⭐⭐⭐⭐⭐│  PAID  │
│              │    -     │ 2-3 sec  │Excellent │ $0.01  │
└──────────────┴──────────┴──────────┴──────────┴────────┘

         ▲                                        ▲
         │                                        │
    Best for                                  Best for
     local                                   production
    testing                                 (if budget)
```

---

## 📊 Sample Terminal Session

### Complete Session Example
```
$ cd k8sgpt-ops

$ make setup
🔧 Configuring k8sgpt...
   Backend: ollama
   Model: tinyllama
✅ k8sgpt is ready to use!

$ make validate
✓ k8sgpt installed
✓ Authentication configured
✓ kubectl access verified
✓ All checks passed

$ make local-test
deployment.apps "healthy-app" deleted
deployment.apps "broken-app" deleted
✓ Cleanup complete
✓ Healthy app deployed
✓ Broken app deployed
Waiting for pods to stabilize...

Analyzing namespace: k8sgpt
Issues detected: 2
---- Issue Details ----
Resource: k8sgpt/broken-app
Kind: Deployment
Error: 0 replicas available
---
Resource: k8sgpt/broken-app-xyz
Kind: Pod
Error: ImagePullBackOff
---

$ make cleanup
✓ Cleanup complete
```

---

## 🎯 Contributing Screenshots

To add your screenshots:

1. Take screenshots following the naming convention above
2. Save as PNG files in this directory
3. Add descriptions to this README
4. Commit with message: `docs: add screenshots for [feature]`

Example:
```bash
# Take screenshot
# Save to docs/screenshots/01-setup.png

# Add to git
git add docs/screenshots/01-setup.png
git commit -m "docs: add setup process screenshot"
git push
```

---

## 📝 Notes

- **Format:** PNG (preferred) or JPG
- **Size:** Max 2 MB per image
- **Resolution:** Readable text (at least 1920x1080)
- **Privacy:** No sensitive data (API keys, IPs, etc.)
- **Naming:** Use descriptive names with numbers

---

**Last Updated:** 2026-05-24
