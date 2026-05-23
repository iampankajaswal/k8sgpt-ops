# Local Testing Guide

This guide helps you test k8sgpt validation locally before running CI/CD pipelines.

## Prerequisites

1. **Kubernetes cluster access** - You need kubectl configured with access to your cluster
2. **k8sgpt CLI** - Install via `make install`
3. **LLM Backend** - OpenAI, Ollama, or another supported provider
4. **jq** - For JSON parsing (`brew install jq`)

## Quick Start

### 1. Initial Setup

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your credentials
# At minimum, set:
# - K8SGPT_BACKEND (e.g., openai)
# - K8SGPT_MODEL (e.g., gpt-4o)
# - OPENAI_API_KEY (your API key)

# Install and configure k8sgpt
make install
make setup
```

### 2. Verify Setup

```bash
make validate
```

This checks:
- k8sgpt is installed
- Authentication is configured
- kubectl can access the k8sgpt namespace

### 3. Run Full Test

```bash
make local-test
```

This will:
1. Clean up any existing test deployments
2. Deploy healthy application
3. Deploy broken application (ImagePullBackOff)
4. Wait for pods to stabilize
5. Run k8sgpt analysis
6. Display results

Expected output: Analysis should detect the broken deployment.

## Individual Test Steps

### Deploy Only Healthy App
```bash
make deploy-healthy
```

### Deploy Broken App (to trigger issues)
```bash
make deploy-broken
```

### Run Analysis on Current State
```bash
make analyze
```

### Cleanup Test Resources
```bash
make cleanup
```

## Using the Local Test Script

For more detailed output:

```bash
./scripts/local-test.sh
```

This provides:
- Color-coded output
- Timestamped reports
- Detailed error messages
- Resource status

## Testing Different Scenarios

### Scenario 1: Healthy Cluster
```bash
make cleanup
make deploy-healthy
sleep 10
make analyze
# Expected: No issues detected
```

### Scenario 2: Image Pull Failure
```bash
make deploy-broken
sleep 15
make analyze
# Expected: ImagePullBackOff detected
```

### Scenario 3: Multiple Issues
```bash
# Deploy multiple broken resources
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: oom-pod
  namespace: k8sgpt
spec:
  containers:
  - name: stress
    image: polinux/stress
    resources:
      limits:
        memory: "50Mi"
      requests:
        memory: "50Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "250M"]
EOF

make analyze
# Expected: Multiple issues detected
```

## Analyzing Existing Infrastructure

If you already have workloads in the `k8sgpt` namespace:

```bash
# Check current state
kubectl get pods -n k8sgpt

# Run analysis
make analyze

# Or with custom filters
K8SGPT_FILTERS=Pod,Service,Deployment,PVC make analyze
```

## Troubleshooting

### k8sgpt not authenticated
```bash
k8sgpt auth list
# If empty, run:
make setup
```

### No issues detected but you see failing pods
```bash
# Check pod status directly
kubectl get pods -n k8sgpt

# Wait longer for issues to manifest
sleep 30
make analyze
```

### API rate limits (OpenAI)
Consider using a local Ollama backend for testing:

```bash
# Install Ollama
brew install ollama

# Start Ollama
ollama serve

# In another terminal
ollama pull llama3

# Update .env
K8SGPT_BACKEND=ollama
K8SGPT_MODEL=llama3

# Reconfigure
make setup
```

## Advanced: Custom Analysis

### Analyze specific resource types
```bash
k8sgpt analyze \
  --namespace k8sgpt \
  --filter Pod,Service,Ingress \
  --explain \
  --output json
```

### Analyze all namespaces
```bash
k8sgpt analyze --explain --output json
```

### Get YAML output
```bash
k8sgpt analyze \
  --namespace k8sgpt \
  --explain \
  --output yaml
```

## CI/CD Integration Testing

To simulate the GitHub Actions workflow locally:

```bash
# 1. Create fresh namespace
kubectl delete namespace k8sgpt --ignore-not-found=true
kubectl create namespace k8sgpt

# 2. Deploy healthy app
kubectl apply -f examples/healthy.yaml

# 3. Simulate failure injection
kubectl apply -f examples/broken.yaml

# 4. Wait
sleep 20

# 5. Run validation (as CI would)
./scripts/analyze.sh

# Expected: Should exit 1 with error details
```

## Report Files

Analysis reports are saved with timestamps:
- `report-YYYYMMDD-HHMMSS.json` - Detailed JSON output

View a report:
```bash
jq '.' report-*.json | less
```

## Next Steps

Once local testing works:
1. Push changes to trigger GitHub Actions workflow
2. Use `workflow_dispatch` to test with/without failures
3. Integrate into PR validation gates

## Related Files

- [Makefile](../Makefile) - All automation commands
- [analyze.sh](../scripts/analyze.sh) - Core analysis script
- [k8sgpt-gate.yaml](../.github/workflows/k8sgpt-gate.yaml) - CI workflow
- [examples/](../examples/) - Test manifests
