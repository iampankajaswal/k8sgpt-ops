#!/bin/bash
set -e

NAMESPACE="${K8SGPT_NAMESPACE:-k8sgpt}"
OUTPUT_FILE="${OUTPUT_FILE:-report.json}"
FILTERS="${K8SGPT_FILTERS:-Pod,Deployment,Service}"

echo "Analyzing namespace: $NAMESPACE"
echo "Filters: $FILTERS"

# Run k8sgpt analysis with proper error handling
# Separate stderr (warnings) from stdout (JSON)
TEMP_OUTPUT="${OUTPUT_FILE}.tmp"
TEMP_STDERR="${OUTPUT_FILE}.stderr"

if ! k8sgpt analyze \
  --namespace "$NAMESPACE" \
  --filter "$FILTERS" \
  --explain \
  --output json > "$TEMP_OUTPUT" 2> "$TEMP_STDERR"; then
  echo "Error: k8sgpt analyze failed"
  cat "$TEMP_STDERR"
  cat "$TEMP_OUTPUT"
  rm -f "$TEMP_OUTPUT" "$TEMP_STDERR"
  exit 1
fi

# Show warnings but don't include them in JSON
if [ -s "$TEMP_STDERR" ]; then
  cat "$TEMP_STDERR" >&2
fi

# Move clean JSON to output file
mv "$TEMP_OUTPUT" "$OUTPUT_FILE"
rm -f "$TEMP_STDERR"

# Check if file has content
if [ ! -s "$OUTPUT_FILE" ]; then
  echo "No issues detected - cluster is healthy"
  exit 0
fi

# Check if results field exists
if ! jq -e '.results' "$OUTPUT_FILE" >/dev/null 2>&1; then
  echo "No issues detected - cluster is healthy"
  exit 0
fi

# Count issues safely
ISSUE_COUNT=$(jq '.results | length' "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo "Issues detected: $ISSUE_COUNT"

if [ "$ISSUE_COUNT" -gt 0 ]; then
  echo "---- Issue Details ----"
  jq -r '.results[] | "Resource: \(.name)\nKind: \(.kind)\nError: \(.error[0].Text)\n---"' "$OUTPUT_FILE" 2>/dev/null || cat "$OUTPUT_FILE"
  exit 1
fi

echo "Validation passed - no issues found"
exit 0
