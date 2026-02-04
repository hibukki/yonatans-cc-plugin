#!/usr/bin/env bash
set -euo pipefail

# MINIMAL TEST: Does claude -p work in async hooks?
# This is the simplest possible hook that uses claude -p

LOG="/tmp/test-claude-p-minimal.log"
echo "$(date +%H:%M:%S) Starting minimal claude -p test" >> "$LOG"

# Run the simplest possible claude -p command
RESULT=$(claude -p "Say exactly: HELLO FROM SUBPROCESS" 2>&1)
EXIT_CODE=$?

echo "$(date +%H:%M:%S) Exit code: $EXIT_CODE" >> "$LOG"
echo "$(date +%H:%M:%S) Result length: ${#RESULT}" >> "$LOG"
echo "$(date +%H:%M:%S) Result: $RESULT" >> "$LOG"

# Output JSON with the result
# Using jq to properly escape the result
if command -v jq &>/dev/null; then
  jq -n --arg msg "[MINIMAL TEST] claude -p returned: $RESULT" '{"systemMessage": $msg}'
else
  # Fallback: simple JSON (may have escaping issues)
  echo "{\"systemMessage\": \"[MINIMAL TEST] claude -p returned: $RESULT\"}"
fi

echo "$(date +%H:%M:%S) JSON output complete" >> "$LOG"
