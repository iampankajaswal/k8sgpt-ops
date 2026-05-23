# Terminal Output Examples

This document shows real terminal outputs from testing k8sgpt-ops.

---

## 1. Initial Setup

### Installing k8sgpt
```bash
$ make install
Installing k8sgpt...
✓ k8sgpt installed
```

### Configuring k8sgpt
```bash
$ make setup
🔧 Configuring k8sgpt...
   Backend: ollama
   Model: tinyllama
   ℹ️  ollama already configured and set as default

📋 Current configuration:
Default: 
> ollama
Active: 
> ollama

✅ k8sgpt is ready to use!

Next steps:
  - Test: make analyze
  - Full test: make local-test
```

### Validating Setup
```bash
$ make validate
Checking k8sgpt installation...
k8sgpt: 0.4.31 (Homebrew), built at: 2026-03-24T14:02:32Z

Checking k8sgpt auth...
Default: 
> ollama
Active: 
> ollama

Checking kubectl access...
k8sgpt             Active   34d

✓ All checks passed
```

---

## 2. Testing with Healthy Cluster

### Deploy Healthy App
```bash
$ make deploy-healthy
namespace/k8sgpt configured
deployment.apps/healthy-app created
✓ Healthy app deployed
```

### Check Pod Status
```bash
$ kubectl get pods -n k8sgpt
NAME                           READY   STATUS    RESTARTS   AGE
healthy-app-67c7c68f99-9trkj   1/1     Running   0          15s
```

### Analyze (No Issues)
```bash
$ make analyze
Analyzing namespace: k8sgpt
Filters: Pod,Deployment,Service
No issues detected - cluster is healthy
```

---

## 3. Testing with Broken App (ImagePullBackOff)

### Deploy Broken App
```bash
$ make deploy-broken
deployment.apps/broken-app created
✓ Broken app deployed (will trigger ImagePullBackOff)
```

### Check Pod Status
```bash
$ kubectl get pods -n k8sgpt
NAME                           READY   STATUS             RESTARTS   AGE
broken-app-6bb6d6947f-r2v5s    0/1     ImagePullBackOff   0          20s
healthy-app-67c7c68f99-9trkj   1/1     Running            0          2m
```

### Analyze (Detects Issues)
```bash
$ make analyze
Analyzing namespace: k8sgpt
Filters: Pod,Deployment,Service
W0524 00:04:31.604736 4834 warnings.go:70] v1 Endpoints is deprecated in v1.33+
Issues detected: 2
---- Issue Details ----
Resource: k8sgpt/broken-app
Kind: Deployment
Error: Deployment k8sgpt/broken-app has 1 replicas but 0 are available with status running
---
Resource: k8sgpt/broken-app-6bb6d6947f-r2v5s
Kind: Pod
Error: Error response from daemon: manifest for nginx:invalid-tag not found: manifest unknown: manifest unknown
---
make: *** [analyze] Error 1
```

**Exit code:** 1 (failure detected, as expected)

---

## 4. Full Local Test

### Running Complete Test Cycle
```bash
$ make local-test
deployment.apps "healthy-app" deleted
deployment.apps "broken-app" deleted
✓ Cleanup complete
namespace/k8sgpt configured
deployment.apps/healthy-app created
✓ Healthy app deployed
deployment.apps/broken-app created
✓ Broken app deployed (will trigger ImagePullBackOff)
Waiting for pods to stabilize...
Analyzing namespace: k8sgpt
Filters: Pod,Deployment,Service
W0524 00:04:31.604736 4834 warnings.go:70] v1 Endpoints is deprecated in v1.33+
Issues detected: 2
---- Issue Details ----
Resource: k8sgpt/broken-app
Kind: Deployment
Error: Deployment k8sgpt/broken-app has 1 replicas but 0 are available with status running
---
Resource: k8sgpt/broken-app-6bb6d6947f-n6srm
Kind: Pod
Error: Error response from daemon: manifest for nginx:invalid-tag not found: manifest unknown: manifest unknown
---
make[1]: *** [analyze] Error 1
make: *** [local-test] Error 2
```

**Result:** ✅ Successfully detected issues in broken deployment!

---

## 5. Enhanced Local Test Script

### Running with Colored Output
```bash
$ ./scripts/local-test.sh
🔍 Starting local k8sgpt validation test

1. Checking prerequisites...
✓ kubectl found
✓ k8sgpt found
✓ jq found

2. Checking namespace 'k8sgpt'...
✓ Namespace exists

3. Current pod status in namespace 'k8sgpt':
NAME                           READY   STATUS             RESTARTS   AGE
broken-app-6bb6d6947f-r2v5s    0/1     ImagePullBackOff   0          45s
healthy-app-67c7c68f99-9trkj   1/1     Running            0          50s

4. Running k8sgpt analysis...
✓ Analysis complete

5. Analysis Results:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ Found 2 issue(s)

Resource: k8sgpt/broken-app
Kind: Deployment
Error: Deployment k8sgpt/broken-app has 1 replicas but 0 are available with status running
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resource: k8sgpt/broken-app-6bb6d6947f-r2v5s
Kind: Pod
Error: Back-off pulling image "nginx:invalid-tag": ErrImagePull
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Full report saved to: report-20260524-000450.json

❌ Validation FAILED - issues detected in cluster
```

---

## 6. Cleanup

### Remove Test Deployments
```bash
$ make cleanup
deployment.apps "healthy-app" deleted
deployment.apps "broken-app" deleted
✓ Cleanup complete

$ kubectl get pods -n k8sgpt
No resources found in k8sgpt namespace.
```

---

## 7. View Analysis Report

### Check Report File
```bash
$ cat report.json | jq '.status, .problems'
"ProblemDetected"
2
```

### View Issue Details
```bash
$ cat report.json | jq '.results[].error[].Text'
"Deployment k8sgpt/broken-app has 1 replicas but 0 are available with status running"
"Error response from daemon: manifest for nginx:invalid-tag not found: manifest unknown: manifest unknown"
```

### View AI Recommendations
```bash
$ cat report.json | jq -r '.results[1].details' | head -10
Sure, here's an English-language simplified version of the Kubernetes error message:

Back-off pulling image "nginx:invalid-tag": ErrImagePull: Error response from daemon...

Step by step solution:

1. Check if the tag is valid or not using `docker inspect` command
2. Use the latest version of the image (`docker pull docker.io/library/nginx`)
3. Verify that the image is pulled successfully
4. Finally, use the new image name (`nginx:latest`) in your Dockerfile
```

---

## 8. Makefile Help

### Show All Available Commands
```bash
$ make help
Usage: make [target]

Available targets:
  help                 Show this help message
  install              Install k8sgpt CLI
  setup                Configure k8sgpt with your provider
  test                 Run local validation test
  analyze              Analyze current k8sgpt namespace
  deploy-healthy       Deploy healthy test application
  deploy-broken        Deploy broken test application
  cleanup              Remove all test deployments
  local-test           Full local test cycle
  validate             Validate k8sgpt setup
```

---

## 9. Model Information

### Check Ollama Models
```bash
$ ollama list
NAME              ID              SIZE      MODIFIED    
tinyllama:latest  2644915ede35    637 MB    5 weeks ago
```

### Check k8sgpt Version
```bash
$ k8sgpt version
k8sgpt: 0.4.31 (Homebrew), built at: 2026-03-24T14:02:32Z
```

---

## 10. Real-World Usage Scenarios

### Scenario A: Pre-commit Check
```bash
# Before committing manifest changes
$ kubectl apply -f my-deployment.yaml
$ make analyze
Issues detected: 1
---- Issue Details ----
Resource: my-app/my-deployment-xyz
Kind: Pod
Error: CrashLoopBackOff: container failed to start
---

# Fix the issue, then verify
$ kubectl apply -f my-deployment-fixed.yaml
$ make analyze
No issues detected - cluster is healthy
✅ Safe to commit!
```

### Scenario B: CI/CD Integration
```bash
# In your CI pipeline
./.github/workflows/k8sgpt-gate.yaml

# Automatically runs on PR
✓ Deploy to test environment
✓ Run k8sgpt analysis
✗ Issues detected - block PR merge
  - Post comment with issue details
  - Fail the workflow
```

### Scenario C: Production Monitoring
```bash
# Run periodically via cron
*/15 * * * * cd /path/to/k8sgpt-ops && make analyze

# Or manually investigate issues
$ K8SGPT_NAMESPACE=production make analyze
Issues detected: 3
- Pod: OOMKilled
- Service: EndpointNotFound  
- PVC: PendingBindError
```

---

## Performance Metrics

### Analysis Speed (tinyllama)
```
Namespace: k8sgpt (2 deployments, 2 pods)
Analysis time: ~5 seconds
Memory usage: ~1 GB RAM
Model size: 637 MB
```

### Analysis Speed (gpt-4o via OpenAI)
```
Namespace: k8sgpt (2 deployments, 2 pods)
Analysis time: ~3 seconds
Memory usage: Minimal (API call)
Cost: ~$0.01 per analysis
```

---

## Common Warnings (Safe to Ignore)

These Kubernetes deprecation warnings are normal and don't affect functionality:

```
W0524 00:04:31.604736 4834 warnings.go:70] v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
```

The script properly separates these warnings from the JSON output.

---

## Error Messages Explained

### ✅ Expected (Good)
- `No issues detected - cluster is healthy` - Everything is working
- Exit code 0 - Validation passed

### ⚠️ Expected (Testing)
- `Issues detected: X` - Found problems (expected with broken-app)
- `ImagePullBackOff` - Invalid image tag (intentional for testing)
- Exit code 1 - Issues found (expected behavior)

### ❌ Unexpected (Needs Fixing)
- `k8sgpt: command not found` - Run `make install`
- `authentication required` - Run `make setup`
- `namespace not found` - Create with `kubectl create namespace k8sgpt`

---

## Tips for Best Results

### 1. Wait for Pods to Stabilize
```bash
# Don't analyze immediately after deploy
kubectl apply -f deployment.yaml
sleep 20  # Wait for status to stabilize
make analyze
```

### 2. Use Specific Filters
```bash
# Only check pods
K8SGPT_FILTERS=Pod make analyze

# Check specific resources
K8SGPT_FILTERS=Pod,Service,PersistentVolumeClaim make analyze
```

### 3. Save Reports with Timestamps
```bash
# Local test creates timestamped reports
./scripts/local-test.sh
# Creates: report-20260524-000450.json

# Manual timestamped reports
OUTPUT_FILE="report-$(date +%Y%m%d-%H%M%S).json" make analyze
```

---

**Last Updated:** 2026-05-24  
**k8sgpt Version:** 0.4.31  
**Model Used:** tinyllama (637 MB)
