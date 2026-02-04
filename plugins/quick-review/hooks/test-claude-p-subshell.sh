#!/usr/bin/env bash
set -euo pipefail

# TEST: Run claude -p in a completely separate subshell with all FDs closed
# Theory: Maybe claude -p leaks something to our stdout

LOG="/tmp/test-claude-p-subshell.log"

echo "$(date +%H:%M:%S) Starting subshell-isolated test" >> "$LOG"

# Run claude in a subshell that redirects ALL output away from us
(
  exec >/dev/null 2>&1
  claude -p "Say: SUBSHELL_TEST" > /tmp/subshell-result.txt 2>&1
)

RESULT=$(cat /tmp/subshell-result.txt 2>/dev/null || echo "NO RESULT")
echo "$(date +%H:%M:%S) Result: $RESULT" >> "$LOG"

# Output JSON - should be clean
echo '{"systemMessage": "[SUBSHELL TEST] claude -p ran in isolated subshell"}'
echo "$(date +%H:%M:%S) Done" >> "$LOG"
