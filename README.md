# k8sgpt-ops

AI-powered Kubernetes diagnostics using k8sgpt integrated with CI/CD and cluster workflows.



## What this does
- Detects Kubernetes issues (CrashLoopBackOff, ImagePullBackOff, OOMKilled, etc.)
- Provides AI-based root cause analysis and remediation suggestions
- Outputs structured JSON/YAML for automation
- Integrates with CI/CD pipelines (GitHub Actions)
- Acts as a PR validation gate to catch deployment issues before production

## Quick Start

### Local Testing with Lightweight Model (3 minutes) ⚡

**Free, local, and only 637 MB!**

```bash
# 1. Start Ollama and pull lightweight model
ollama serve
ollama pull tinyllama  # Only 637 MB!

# 2. Setup (uses tinyllama by default)
cp .env.local-example .env
make install && make setup

# 3. Run full validation test
make local-test
```

**Alternative: Use OpenAI** (requires API key but best quality)
```bash
cp .env.example .env
# Edit .env with your OpenAI API key
make install && make setup && make local-test
```

See [LIGHTWEIGHT_SETUP.md](LIGHTWEIGHT_SETUP.md) for model options or [Local Testing Guide](docs/LOCAL_TESTING.md) for detailed instructions.

### CI/CD Integration

The project includes a GitHub Actions workflow that:
- ✅ Automatically validates Kubernetes manifests
- ✅ Detects issues before they reach production
- ✅ Posts analysis results as PR comments
- ✅ Supports failure injection for testing

Trigger manually:
```bash
gh workflow run k8sgpt-gate.yaml -f inject_failure=true
```

## Features

- **Automated Issue Detection**: Scans pods, deployments, services, and more
- **AI-Powered Analysis**: Uses LLMs (OpenAI, Ollama, Azure) for root cause analysis
- **CI/CD Ready**: GitHub Actions workflow included
- **Local Testing**: Full local validation before pushing
- **Flexible Backend**: Supports multiple LLM providers
- **Structured Output**: JSON/YAML for programmatic processing

## Project Structure

```
k8sgpt-ops/
├── .github/workflows/
│   ├── k8sgpt-gate.yaml              # Original CI workflow
│   └── k8sgpt-gate-improved.yaml     # Enhanced workflow with PR comments
├── scripts/
│   ├── analyze.sh                     # Core analysis script (improved)
│   ├── local-test.sh                  # Local testing script
│   └── install-k8sgpt.sh              # Installation helper
├── examples/
│   ├── healthy.yaml                   # Working deployment
│   └── broken.yaml                    # Failing deployment (test)
├── docs/
│   └── LOCAL_TESTING.md               # Detailed testing guide
├── Makefile                           # All common operations
└── .env.example                       # Configuration template
```

## Usage

### Test in your existing cluster

```bash
# Analyze current state
make analyze

# Deploy test applications
make deploy-healthy
make deploy-broken

# Cleanup
make cleanup
```

### Run validation script directly

```bash
export K8SGPT_NAMESPACE=k8sgpt
export K8SGPT_FILTERS=Pod,Deployment,Service
./scripts/analyze.sh
```

## 📸 Examples & Screenshots

See real terminal outputs and sample reports:
- [Terminal Output Examples](docs/examples/terminal-outputs.md) - Complete command outputs
- [Sample JSON Reports](docs/examples/sample-reports.md) - Analysis reports with explanations
- [Screenshots Guide](docs/screenshots/README.md) - Visual examples and ASCII diagrams
