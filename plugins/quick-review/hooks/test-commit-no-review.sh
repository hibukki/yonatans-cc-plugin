#!/usr/bin/env bash
set -euo pipefail

# Test hook: Same as on-commit-async but without claude -p
# Tests if the issue is with claude -p or something else

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-common.sh"
require_jq_or_exit

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check if this is a git commit command
if ! echo "$COMMAND" | grep -qE '(^|[[:space:]])git[[:space:]].*commit([[:space:]]|$)'; then
  exit 0
fi

# Extract commit SHA from tool_response
STDOUT=$(echo "$INPUT" | jq -r '.tool_response.stdout // empty')
COMMIT_SHA=$(echo "$STDOUT" | grep -oE '\[[a-zA-Z0-9_/-]+ [a-f0-9]+\]' | grep -oE '[a-f0-9]{7,}' | head -1 || true)

if [[ -z "$COMMIT_SHA" ]]; then
  exit 0
fi

# Skip claude -p, just return a message
OUTPUT="[DEBUG test-commit-no-review] Commit detected: $COMMIT_SHA. This message proves async delivery works for commit hooks WITHOUT claude -p."

echo "{\"systemMessage\": \"$OUTPUT\"}"
