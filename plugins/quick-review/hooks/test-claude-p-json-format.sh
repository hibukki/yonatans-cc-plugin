#!/usr/bin/env bash
set -euo pipefail

# TEST 3: Use --output-format json
# Theory: Maybe the output format affects behavior

LOG="/tmp/test-claude-p-json-format.log"

echo "$(date +%H:%M:%S) Starting json-format claude -p test" >> "$LOG"

RESULT=$(claude -p "Say exactly: JSON_FORMAT_SUCCESS" --output-format json 2>&1)
EXIT_CODE=$?

echo "$(date +%H:%M:%S) Exit code: $EXIT_CODE" >> "$LOG"
echo "$(date +%H:%M:%S) Result: $RESULT" >> "$LOG"

# Extract just the result text if it's JSON
if echo "$RESULT" | jq -e '.result' &>/dev/null; then
  TEXT=$(echo "$RESULT" | jq -r '.result')
else
  TEXT="$RESULT"
fi

jq -n --arg msg "[JSON FORMAT TEST] claude -p returned: $TEXT" '{"systemMessage": $msg}'
echo "$(date +%H:%M:%S) Done" >> "$LOG"
