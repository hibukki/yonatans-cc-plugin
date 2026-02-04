#!/usr/bin/env bash
set -euo pipefail

# TEST 2: Write claude -p output to file instead of variable
# Theory: Maybe variable capture interferes with something

LOG="/tmp/test-claude-p-file.log"
OUTFILE="/tmp/claude-p-output-$$.txt"

echo "$(date +%H:%M:%S) Starting file-based claude -p test" >> "$LOG"

# Write to file instead of capturing in variable
claude -p "Say exactly: FILE_TEST_SUCCESS" > "$OUTFILE" 2>&1
EXIT_CODE=$?

echo "$(date +%H:%M:%S) Exit code: $EXIT_CODE" >> "$LOG"

RESULT=$(cat "$OUTFILE")
echo "$(date +%H:%M:%S) Result: $RESULT" >> "$LOG"

rm -f "$OUTFILE"

jq -n --arg msg "[FILE TEST] claude -p returned: $RESULT" '{"systemMessage": $msg}'
echo "$(date +%H:%M:%S) Done" >> "$LOG"
