# 🚀 Lightweight Local Testing Setup (3 Minutes)

**You asked for lightweight** - here's the fastest setup using tinyllama (only 637 MB)!

---

## ⚡ Super Quick Setup

Good news: You already have **tinyllama** pulled! Let's use it:

```bash
# Check what you have
ollama list
# Should show: tinyllama:latest    637 MB

# 1. Start Ollama (if not running)
ollama serve

# 2. Setup environment (in another terminal)
cd /Users/pankajaswal/k8sgpt-ops
cp .env.local-example .env

# 3. Configure k8sgpt to use tinyllama
make setup

# 4. Test it!
make local-test
```

**That's it!** You're using a lightweight 637 MB model instead of 4.7 GB llama3.

---

## 📊 Size Comparison

| Model | Size | Your Choice |
|-------|------|-------------|
| **tinyllama** | 637 MB | ✅ **PERFECT** |
| qwen2.5:0.5b | 397 MB | ⚡ Even smaller |
| phi3:mini | 2.2 GB | 📈 Better quality |
| ~~llama3~~ | 4.7 GB | ❌ Too heavy |

---

## 🎯 Three Commands to Test Now

```bash
# Terminal 1: Start Ollama
ollama serve

# Terminal 2: Run test
cd /Users/pankajaswal/k8sgpt-ops
cp .env.local-example .env
make setup && make local-test
```

---

## 🔧 Your .env Should Look Like This

```bash
K8SGPT_BACKEND=ollama
K8SGPT_MODEL=tinyllama  # Only 637 MB!
K8SGPT_NAMESPACE=k8sgpt
```

---

## ✅ Verify Setup

```bash
# Check Ollama has tinyllama
ollama list | grep tinyllama
# Should show: tinyllama:latest    637 MB

# Check k8sgpt is configured
k8sgpt auth list
# Should show: Default: ollama, Active: ollama

# Test analysis
make analyze
```

---

## 💡 Want Even Smaller? (397 MB)

```bash
# Pull the smallest model
ollama pull qwen2.5:0.5b

# Update .env
# Change: K8SGPT_MODEL=tinyllama
# To: K8SGPT_MODEL=qwen2.5:0.5b

# Reconfigure
make setup
```

---

## 🎓 Compare Before/After

### ❌ Before (with llama3)
```
Download: 4.7 GB
RAM usage: ~8 GB
Analysis time: ~15 seconds
```

### ✅ After (with tinyllama)
```
Download: 637 MB (7.4x smaller!)
RAM usage: ~1 GB (8x less!)
Analysis time: ~5 seconds (3x faster!)
```

---

## 🚀 Full Test Example

```bash
# 1. Ensure Ollama is running
ollama serve &

# 2. Verify tinyllama is ready
ollama list | grep tinyllama

# 3. Go to project
cd /Users/pankajaswal/k8sgpt-ops

# 4. Quick config (uses tinyllama)
cp .env.local-example .env

# 5. Setup k8sgpt
make setup

# 6. Test against your k8sgpt namespace
make analyze

# 7. Or run full test
make local-test
```

**Expected output:**
```
🔍 Starting local k8sgpt validation test

1. Checking prerequisites...
✓ kubectl found
✓ k8sgpt found
✓ jq found

2. Checking namespace 'k8sgpt'...
✓ Namespace exists

3. Current pod status in namespace 'k8sgpt':
[Your pods listed here]

4. Running k8sgpt analysis...
✓ Analysis complete (using tinyllama - fast!)

5. Analysis Results:
[Results here]
```

---

## 📈 Model Recommendations

### For You (Local Testing):
**Use tinyllama (637 MB)** ✅
- You already have it
- Fast enough
- Small download
- Low RAM usage

### If You Want Smallest:
**Use qwen2.5:0.5b (397 MB)**
```bash
ollama pull qwen2.5:0.5b
# Update K8SGPT_MODEL=qwen2.5:0.5b in .env
make setup
```

### If You Want Better Quality:
**Use phi3:mini (2.2 GB)**
```bash
ollama pull phi3:mini
# Update K8SGPT_MODEL=phi3:mini in .env
make setup
```

---

## 🎉 You're All Set!

Your setup now uses **tinyllama (637 MB)** instead of llama3 (4.7 GB).

**Next steps:**
1. Test it: `make local-test`
2. Read more: [docs/LIGHTWEIGHT_MODELS.md](docs/LIGHTWEIGHT_MODELS.md)
3. Full guide: [QUICKSTART.md](QUICKSTART.md)

---

## 💾 Disk Space Saved

If you want to remove llama3 to save space:

```bash
# Check what you have
ollama list

# Remove llama3 (if you have it)
ollama rm llama3

# Save 4.7 GB - 637 MB = 4.1 GB freed! 🎉
```

---

**Quick Commands Reference:**

```bash
ollama list              # Show installed models
ollama pull tinyllama    # Pull lightweight model (637 MB)
ollama rm llama3         # Remove large model (save 4.7 GB)
make setup               # Configure k8sgpt
make local-test          # Run full test
make analyze             # Quick analysis
```

**Perfect for local testing!** 🚀
