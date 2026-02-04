#!/usr/bin/env bash
set -euo pipefail

# TEST: Output JSON BEFORE running claude -p
# Theory: Maybe the timing/order matters

LOG="/tmp/test-output-before.log"

echo "$(date +%H:%M:%S) Outputting JSON immediately..." >> "$LOG"

# Output JSON FIRST
echo '{"systemMessage": "[PRE-OUTPUT TEST] JSON was output before claude -p ran"}'

# Then run claude -p with all output to log
claude -p "Say: AFTER_OUTPUT_TEST" >> "$LOG" 2>&1

echo "$(date +%H:%M:%S) Done" >> "$LOG"
