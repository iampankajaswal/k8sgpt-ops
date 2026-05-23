.PHONY: help install setup test analyze deploy-healthy deploy-broken cleanup local-test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install k8sgpt CLI
	@echo "Installing k8sgpt..."
	@if command -v brew >/dev/null 2>&1; then \
		brew tap k8sgpt-ai/k8sgpt || true; \
		brew install k8sgpt; \
	else \
		curl -sSL https://github.com/k8sgpt-ai/k8sgpt/releases/latest/download/k8sgpt_$$(uname -s)_$$(uname -m).tar.gz | tar -xz; \
		sudo mv k8sgpt /usr/local/bin/; \
	fi
	@echo "✓ k8sgpt installed"

setup: ## Configure k8sgpt with your provider
	@./scripts/setup-k8sgpt.sh

test: ## Run local validation test
	@./scripts/local-test.sh

analyze: ## Analyze current k8sgpt namespace
	@./scripts/analyze.sh

deploy-healthy: ## Deploy healthy test application
	@kubectl create namespace k8sgpt --dry-run=client -o yaml | kubectl apply -f -
	@kubectl apply -f examples/healthy.yaml
	@echo "✓ Healthy app deployed"

deploy-broken: ## Deploy broken test application
	@kubectl apply -f examples/broken.yaml
	@echo "✓ Broken app deployed (will trigger ImagePullBackOff)"

cleanup: ## Remove all test deployments
	@kubectl delete -f examples/healthy.yaml --ignore-not-found=true
	@kubectl delete -f examples/broken.yaml --ignore-not-found=true
	@echo "✓ Cleanup complete"

local-test: cleanup deploy-healthy deploy-broken ## Full local test cycle
	@echo "Waiting for pods to stabilize..."
	@sleep 15
	@make analyze

validate: ## Validate k8sgpt setup
	@echo "Checking k8sgpt installation..."
	@k8sgpt version
	@echo "\nChecking k8sgpt auth..."
	@k8sgpt auth list
	@echo "\nChecking kubectl access..."
	@kubectl get namespaces | grep k8sgpt
	@echo "\n✓ All checks passed"
