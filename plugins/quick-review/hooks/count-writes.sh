#!/bin/bash
set -euo pipefail

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')

[[ -z "$session_id" || "$session_id" == "null" ]] && exit 0

COUNTER_FILE="/tmp/claude-writes-${session_id}"

count=0
[[ -f "$COUNTER_FILE" ]] && count=$(cat "$COUNTER_FILE")
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

if [[ "$count" -eq 5 ]]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Reminder: commit small self-contained changes"
  }
}
EOF
fi

exit 0
