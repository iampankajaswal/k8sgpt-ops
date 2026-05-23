#!/bin/bash
set -e

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "   Run: cp .env.local-example .env"
    exit 1
fi

source .env

BACKEND="${K8SGPT_BACKEND:-ollama}"
MODEL="${K8SGPT_MODEL:-tinyllama}"

echo "🔧 Configuring k8sgpt..."
echo "   Backend: $BACKEND"
echo "   Model: $MODEL"

# Check if already configured
if k8sgpt auth list 2>/dev/null | grep -A1 "^Default:" | grep -q "$BACKEND"; then
    echo "   ℹ️  $BACKEND already configured and set as default"
    echo ""
    echo "📋 Current configuration:"
    k8sgpt auth list
    echo ""
    echo "✅ k8sgpt is ready to use!"
    echo ""
    echo "Next steps:"
    echo "  - Test: make analyze"
    echo "  - Full test: make local-test"
    exit 0
fi

# Remove existing auth for this backend (if any) to reconfigure
k8sgpt auth remove --provider "$BACKEND" 2>/dev/null || true

# Add authentication based on backend type
case "$BACKEND" in
    ollama)
        echo "   Setting up Ollama (no API key needed)..."

        # Check if Ollama is running
        if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo "   ⚠️  Warning: Ollama doesn't appear to be running"
            echo "   Run: ollama serve"
            echo ""
            echo "   Continuing anyway..."
        fi

        # Check if model is pulled
        if ! ollama list 2>/dev/null | grep -q "$MODEL"; then
            echo "   ⚠️  Warning: Model '$MODEL' not found"
            echo "   Run: ollama pull $MODEL"
            echo ""
            echo "   Continuing anyway..."
        fi

        # Add auth without password
        if k8sgpt auth add --backend ollama --model "$MODEL" --baseurl http://localhost:11434/v1 2>&1 | grep -q "already exists"; then
            echo "   ℹ️  Ollama already configured, updating..."
            # Already exists, just set as default
            echo "   ✓ Ollama configuration verified"
        elif k8sgpt auth add --backend ollama --model "$MODEL" --baseurl http://localhost:11434/v1; then
            echo "   ✓ Ollama configured"
        else
            echo "   ❌ Failed to configure Ollama"
            exit 1
        fi
        ;;

    openai)
        if [ -z "$OPENAI_API_KEY" ]; then
            echo "   ❌ Error: OPENAI_API_KEY not set in .env"
            exit 1
        fi

        echo "   Setting up OpenAI..."
        if k8sgpt auth add --backend openai --model "$MODEL" --password "$OPENAI_API_KEY"; then
            echo "   ✓ OpenAI configured"
        else
            echo "   ❌ Failed to configure OpenAI"
            exit 1
        fi
        ;;

    azure)
        if [ -z "$AZURE_OPENAI_ENDPOINT" ]; then
            echo "   ❌ Error: AZURE_OPENAI_ENDPOINT not set in .env"
            exit 1
        fi

        echo "   Setting up Azure OpenAI..."
        if k8sgpt auth add --backend azure --model "$MODEL" --password "$AZURE_OPENAI_KEY" --baseurl "$AZURE_OPENAI_ENDPOINT"; then
            echo "   ✓ Azure OpenAI configured"
        else
            echo "   ❌ Failed to configure Azure OpenAI"
            exit 1
        fi
        ;;

    *)
        echo "   ❌ Error: Unknown backend '$BACKEND'"
        echo "   Supported: ollama, openai, azure"
        exit 1
        ;;
esac

# Set as default provider
echo "   Setting $BACKEND as default provider..."
if k8sgpt auth default --provider "$BACKEND"; then
    echo "   ✓ Default provider set"
else
    echo "   ❌ Failed to set default provider"
    exit 1
fi

# Verify configuration
echo ""
echo "📋 Current configuration:"
k8sgpt auth list

echo ""
echo "✅ k8sgpt configured successfully!"
echo ""
echo "Next steps:"
echo "  - Test: make analyze"
echo "  - Full test: make local-test"
