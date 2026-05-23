# Quick Start - Local Testing

Get up and running with k8sgpt-ops in 5 minutes.

## Prerequisites Check

```bash
# Verify you have these installed
kubectl version --client        # Kubernetes CLI
k8sgpt version || echo "Need to install k8sgpt"
jq --version || brew install jq # JSON processor

# Verify cluster access
kubectl cluster-info
kubectl get namespace k8sgpt || echo "Namespace doesn't exist yet (that's ok)"
```

## Step 1: Configure Environment (2 min)

```bash
cd /Users/pankajaswal/k8sgpt-ops

# Copy environment template
cp .env.example .env

# Edit with your favorite editor
code .env  # or vim .env, nano .env, etc.
```

**Minimum required settings in `.env`:**
```bash
K8SGPT_BACKEND=openai
K8SGPT_MODEL=gpt-4o
OPENAI_API_KEY=sk-your-actual-key-here  # Get from https://platform.openai.com/api-keys
```

**Or use Ollama (free, local, lightweight):**
```bash
# Terminal 1: Start Ollama
brew install ollama
ollama serve

# Terminal 2: Pull lightweight model (only 637 MB!)
ollama pull tinyllama

# In .env:
K8SGPT_BACKEND=ollama
K8SGPT_MODEL=tinyllama  # Fast and lightweight!
# No API key needed!
```

**Other lightweight options:**
- `qwen2.5:0.5b` - 397 MB (smallest)
- `phi3:mini` - 2.2 GB (better quality)
- See [docs/LIGHTWEIGHT_MODELS.md](docs/LIGHTWEIGHT_MODELS.md) for details

## Step 2: Install & Setup (1 min)

```bash
# Install k8sgpt CLI
make install

# Configure with your provider
make setup

# Verify everything works
make validate
```

Expected output:
```
Checking k8sgpt installation...
k8sgpt version 0.3.x

Checking k8sgpt auth...
Default: openai
Active: openai

Checking kubectl access...
k8sgpt

✓ All checks passed
```

## Step 3: Run Your First Test (2 min)

```bash
# Full test cycle (deploys apps, analyzes, reports)
make local-test
```

This will:
1. ✅ Clean up any existing test resources
2. ✅ Deploy a healthy nginx deployment
3. ✅ Deploy a broken deployment (invalid image)
4. ✅ Wait for pods to stabilize
5. ✅ Run k8sgpt analysis
6. ✅ Show you the results

**Expected output:**
```
🔍 Starting local k8sgpt validation test

1. Checking prerequisites...
2. Checking namespace 'k8sgpt'...
3. Current pod status in namespace 'k8sgpt':
NAME                          READY   STATUS             RESTARTS   AGE
broken-app-xxxx               0/1     ImagePullBackOff   0          15s
healthy-app-xxxx              1/1     Running            0          20s

4. Running k8sgpt analysis...
✓ Analysis complete

5. Analysis Results:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ Found 1 issue(s)

Resource: broken-app-xxxx
Kind: Pod
Error: Back-off pulling image "nginx:invalid-tag"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Full report saved to: report-20260523-173045.json

❌ Validation FAILED - issues detected in cluster
```

## Step 4: Test Against Your Real Workloads

```bash
# Analyze your existing k8sgpt namespace
make analyze

# Or analyze with custom filters
K8SGPT_FILTERS=Pod,Service,Deployment,PVC make analyze

# Cleanup test resources when done
make cleanup
```

## Common Commands Reference

```bash
make install          # Install k8sgpt CLI
make setup            # Configure authentication
make validate         # Verify setup
make deploy-healthy   # Deploy working app only
make deploy-broken    # Deploy failing app only
make analyze          # Run analysis on current state
make cleanup          # Remove test deployments
make local-test       # Full test cycle
```

## Troubleshooting

### "k8sgpt not authenticated"
```bash
k8sgpt auth list
# If empty:
make setup
```

### "namespace k8sgpt not found"
```bash
kubectl create namespace k8sgpt
```

### "API rate limit exceeded" (OpenAI)
Switch to Ollama (lightweight):
```bash
# Terminal 1:
ollama serve

# Terminal 2: Pull tiny model (only 637 MB)
ollama pull tinyllama

# Update .env:
K8SGPT_BACKEND=ollama
K8SGPT_MODEL=tinyllama

# Reconfigure:
make setup
```

### "No issues detected but I see failing pods"
```bash
# Wait a bit longer for issues to manifest
sleep 30
make analyze

# Or check manually:
kubectl get pods -n k8sgpt
kubectl describe pod <failing-pod> -n k8sgpt
```

## What's Next?

1. **View detailed docs**: `cat docs/LOCAL_TESTING.md`
2. **Try different scenarios**: Edit `examples/broken.yaml` to test different failures
3. **Test CI/CD**: Push to trigger GitHub Actions workflow
4. **Customize**: Edit `scripts/analyze.sh` for your needs

## Quick Test Matrix

| Scenario | Command | Expected Result |
|----------|---------|-----------------|
| Healthy cluster | `make deploy-healthy && sleep 10 && make analyze` | ✅ No issues |
| Image pull failure | `make deploy-broken && sleep 15 && make analyze` | ❌ ImagePullBackOff |
| Full test | `make local-test` | ❌ Issues detected |
| Clean slate | `make cleanup && make analyze` | ✅ No resources |

## Getting Help

- **Local testing guide**: [docs/LOCAL_TESTING.md](docs/LOCAL_TESTING.md)
- **All improvements**: [docs/IMPROVEMENTS.md](docs/IMPROVEMENTS.md)
- **k8sgpt docs**: https://docs.k8sgpt.ai/
- **Project README**: [README.md](README.md)

---

🎉 **You're all set!** Start testing your Kubernetes clusters with AI-powered diagnostics.
