#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="k8sgpt"
REPORT_FILE="report-$(date +%Y%m%d-%H%M%S).json"

echo -e "${YELLOW}🔍 Starting local k8sgpt validation test${NC}\n"

# Check prerequisites
echo "1. Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}Error: kubectl not found${NC}"; exit 1; }
command -v k8sgpt >/dev/null 2>&1 || { echo -e "${RED}Error: k8sgpt not found. Run 'make install'${NC}"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "${RED}Error: jq not found. Install with 'brew install jq'${NC}"; exit 1; }

# Verify namespace exists
echo "2. Checking namespace '$NAMESPACE'..."
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}Creating namespace $NAMESPACE${NC}"
    kubectl create namespace "$NAMESPACE"
fi

# Get current pod status
echo -e "\n3. Current pod status in namespace '$NAMESPACE':"
kubectl get pods -n "$NAMESPACE" 2>/dev/null || echo "No pods found"

# Run k8sgpt analysis
echo -e "\n4. Running k8sgpt analysis..."
TEMP_REPORT="${REPORT_FILE}.tmp"
TEMP_STDERR="${REPORT_FILE}.stderr"

if k8sgpt analyze \
    --namespace "$NAMESPACE" \
    --explain \
    --output json > "$TEMP_REPORT" 2> "$TEMP_STDERR"; then
    echo -e "${GREEN}✓ Analysis complete${NC}"
else
    echo -e "${RED}✗ Analysis failed${NC}"
    cat "$TEMP_STDERR"
    cat "$TEMP_REPORT"
    rm -f "$TEMP_REPORT" "$TEMP_STDERR"
    exit 1
fi

# Show warnings (if any) but keep JSON clean
if [ -s "$TEMP_STDERR" ]; then
    cat "$TEMP_STDERR" >&2
fi
mv "$TEMP_REPORT" "$REPORT_FILE"
rm -f "$TEMP_STDERR"

# Parse and display results
echo -e "\n5. Analysis Results:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -s "$REPORT_FILE" ]; then
    echo -e "${YELLOW}⚠ No issues detected or empty report${NC}"
    exit 0
fi

# Check if results field exists and has items
if ! jq -e '.results' "$REPORT_FILE" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ No issues detected${NC}"
    rm -f "$REPORT_FILE"
    exit 0
fi

ISSUE_COUNT=$(jq '.results | length' "$REPORT_FILE" 2>/dev/null || echo "0")

if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No issues detected - cluster is healthy!${NC}"
    rm -f "$REPORT_FILE"
    exit 0
fi

echo -e "${RED}✗ Found $ISSUE_COUNT issue(s)${NC}\n"

# Display detailed issues
jq -r '.results[] |
    "Resource: \(.name // "unknown")",
    "Kind: \(.kind // "unknown")",
    "Error: \(.error[0].Text // "No description")",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
' "$REPORT_FILE" 2>/dev/null || {
    echo -e "${YELLOW}Could not parse results. Raw output:${NC}"
    cat "$REPORT_FILE"
}

echo -e "\n📄 Full report saved to: $REPORT_FILE"
echo -e "\n${RED}❌ Validation FAILED - issues detected in cluster${NC}"
exit 1
