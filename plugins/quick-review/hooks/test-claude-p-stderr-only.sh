#!/usr/bin/env bash
set -euo pipefail

# TEST 4: Redirect claude -p output to stderr, not capture it
# Theory: Maybe capturing stdout interferes with hook's stdout

LOG="/tmp/test-claude-p-stderr.log"

echo "$(date +%H:%M:%S) Starting stderr-redirect claude -p test" >> "$LOG"

# Run claude -p but send its output to stderr (and log), not our stdout
claude -p "Say exactly: STDERR_TEST_SUCCESS" >> "$LOG" 2>&1
EXIT_CODE=$?

echo "$(date +%H:%M:%S) Exit code: $EXIT_CODE" >> "$LOG"

# Output our JSON cleanly without any claude output mixed in
jq -n --arg msg "[STDERR TEST] claude -p completed with exit $EXIT_CODE - check $LOG for output" '{"systemMessage": $msg}'
echo "$(date +%H:%M:%S) Done" >> "$LOG"
