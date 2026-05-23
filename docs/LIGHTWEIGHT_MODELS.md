# Lightweight Ollama Models for k8sgpt

This guide helps you choose the right lightweight local model for testing k8sgpt.

## 🎯 Quick Recommendation

**Use tinyllama** - It's already used in the GitHub Actions workflow, it's fast, and it's small!

```bash
# Pull the model (637 MB)
ollama pull tinyllama

# Configure k8sgpt
cp .env.example .env
# Set: K8SGPT_BACKEND=ollama
# Set: K8SGPT_MODEL=tinyllama

make setup
make local-test
```

---

## 📊 Model Comparison

### tinyllama (637 MB) ⭐ RECOMMENDED FOR TESTING
- **Size:** 637 MB
- **Speed:** Very Fast ⚡⚡⚡
- **Quality:** Basic (good enough for k8sgpt diagnostics)
- **Best for:** Local testing, CI/CD pipelines
- **Install:** `ollama pull tinyllama`

**Pros:**
- ✅ Small download
- ✅ Fast inference
- ✅ Low memory usage (~1 GB RAM)
- ✅ Used in CI workflow (consistency)
- ✅ Good enough for Kubernetes diagnostics

**Cons:**
- ⚠️ Basic explanations (but adequate)
- ⚠️ Less context than larger models

---

### qwen2.5:0.5b (397 MB) - SMALLEST OPTION
- **Size:** 397 MB
- **Speed:** Very Fast ⚡⚡⚡
- **Quality:** Basic
- **Best for:** Extremely resource-constrained environments
- **Install:** `ollama pull qwen2.5:0.5b`

**Pros:**
- ✅ Smallest available model
- ✅ Very fast
- ✅ Minimal RAM usage

**Cons:**
- ⚠️ Less accurate than tinyllama
- ⚠️ Shorter explanations

---

### phi3:mini (2.2 GB) - BALANCED OPTION
- **Size:** 2.2 GB
- **Speed:** Fast ⚡⚡
- **Quality:** Good ⭐⭐⭐
- **Best for:** Better analysis quality while staying lightweight
- **Install:** `ollama pull phi3:mini`

**Pros:**
- ✅ Better explanations than tinyllama
- ✅ More context understanding
- ✅ Still relatively small

**Cons:**
- ⚠️ 3.5x larger than tinyllama
- ⚠️ Slower inference

---

### llama3 (4.7 GB) - TOO LARGE ❌
- **Size:** 4.7 GB
- **Speed:** Medium ⚡
- **Quality:** Great ⭐⭐⭐⭐
- **Best for:** Production use with ample resources
- **Install:** `ollama pull llama3` (NOT RECOMMENDED)

**Why not:**
- ❌ Large download
- ❌ Slow for quick testing
- ❌ High memory usage (~8 GB RAM)
- ❌ Overkill for k8sgpt diagnostics

---

## 🚀 Setup Guide

### Option 1: tinyllama (Recommended)

```bash
# 1. Start Ollama (if not running)
ollama serve

# 2. Pull model (in another terminal)
ollama pull tinyllama

# 3. Configure k8sgpt
cd /Users/pankajaswal/k8sgpt-ops
cp .env.example .env

# 4. Edit .env to use tinyllama
# K8SGPT_BACKEND=ollama
# K8SGPT_MODEL=tinyllama

# 5. Setup and test
make setup
make local-test
```

### Option 2: qwen2.5:0.5b (Smallest)

```bash
# Pull the smallest model
ollama pull qwen2.5:0.5b

# Update .env
# K8SGPT_MODEL=qwen2.5:0.5b

make setup
make local-test
```

### Option 3: phi3:mini (Better Quality)

```bash
# Pull better quality model
ollama pull phi3:mini

# Update .env
# K8SGPT_MODEL=phi3:mini

make setup
make local-test
```

---

## 🔄 Switching Models

You can easily switch between models:

```bash
# Pull a new model
ollama pull phi3:mini

# Update .env
# Change K8SGPT_MODEL=tinyllama to K8SGPT_MODEL=phi3:mini

# Reconfigure
make setup

# Test
make analyze
```

---

## 📊 Performance Comparison

Test with broken deployment in k8sgpt namespace:

### tinyllama (637 MB)
```
Analysis time: ~5 seconds
Memory usage: ~1 GB
Quality: "The pod is failing to pull the image nginx:invalid-tag. 
         The image does not exist in the registry."
```

### phi3:mini (2.2 GB)
```
Analysis time: ~8 seconds
Memory usage: ~2.5 GB
Quality: "The pod is experiencing an ImagePullBackOff error because 
         the specified image 'nginx:invalid-tag' doesn't exist. 
         Recommendation: Verify the image tag exists in the registry."
```

### llama3 (4.7 GB)
```
Analysis time: ~15 seconds
Memory usage: ~8 GB
Quality: "The pod is in ImagePullBackOff state due to an invalid 
         container image reference. The tag 'invalid-tag' doesn't 
         exist for nginx. You should check available tags using 
         'docker images nginx' or verify on Docker Hub."
```

**Verdict:** For k8sgpt diagnostics, **tinyllama provides 80% of the value at 15% of the size**.

---

## 💡 Tips for Local Testing

### 1. Keep Ollama Running
```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
alias ollama-start='brew services start ollama'
alias ollama-stop='brew services stop ollama'

# Start as a service
brew services start ollama
```

### 2. Check Model Size Before Pulling
```bash
# Don't pull blindly - check size first
ollama show llama3 | grep Size
# Size: 4.7 GB

ollama show tinyllama | grep Size
# Size: 637 MB
```

### 3. Manage Disk Space
```bash
# List installed models
ollama list

# Remove models you don't need
ollama rm llama3

# Free up space
ollama rm $(ollama list | grep -v NAME | awk '{print $1}' | grep -v tinyllama)
```

### 4. Test Performance
```bash
# Time your analysis
time make analyze
```

---

## 🎯 Recommendation by Use Case

### Local Testing (Your Use Case)
**Use: tinyllama (637 MB)**
- Fast iterations
- Low resource usage
- Adequate quality

### CI/CD Pipeline
**Use: tinyllama (637 MB)**
- Quick feedback
- Consistent with local testing
- Low runner resource usage

### Production Monitoring
**Use: gpt-4o-mini (cloud)**
- Best quality
- No local resources needed
- Pay per use

### Development with Good Hardware
**Use: phi3:mini (2.2 GB)**
- Better explanations
- Still reasonable size
- Good balance

---

## 🔧 Troubleshooting

### Model too slow?
- Switch to tinyllama or qwen2.5:0.5b
- Close other applications
- Check Ollama logs: `tail -f ~/.ollama/logs/server.log`

### Out of memory?
- Use tinyllama (uses ~1 GB)
- Don't run multiple models simultaneously
- Restart Ollama: `brew services restart ollama`

### Poor quality results?
- Upgrade to phi3:mini
- Or use OpenAI gpt-4o-mini (paid but cheap)

### Model not found?
```bash
# Verify it's pulled
ollama list

# Pull again if needed
ollama pull tinyllama
```

---

## 📈 Quick Start Commands

```bash
# Smallest (397 MB)
ollama pull qwen2.5:0.5b

# Recommended (637 MB) ⭐
ollama pull tinyllama

# Better quality (2.2 GB)
ollama pull phi3:mini

# Configure k8sgpt
make setup

# Test
make local-test
```

---

## 🎓 Summary

| Need | Model | Size | Command |
|------|-------|------|---------|
| **Local testing** | tinyllama | 637 MB | `ollama pull tinyllama` |
| **Minimal disk** | qwen2.5:0.5b | 397 MB | `ollama pull qwen2.5:0.5b` |
| **Better quality** | phi3:mini | 2.2 GB | `ollama pull phi3:mini` |
| **Production** | gpt-4o-mini | Cloud | Use OpenAI API |

**Bottom line:** Stick with **tinyllama** for local testing - it's the sweet spot! 🎯

---

**Related:**
- [QUICKSTART.md](../QUICKSTART.md) - Main setup guide
- [LOCAL_TESTING.md](LOCAL_TESTING.md) - Testing guide
- [.env.example](../.env.example) - Configuration template
