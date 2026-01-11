#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-review.sh"

LOG="/tmp/hook-debug.log"

# Read JSON input from stdin
input=$(cat)
REVIEW_DIR=$(get_review_dir "$input")

# Ensure review directory exists
mkdir -p "$REVIEW_DIR"

echo "$(date): PostToolUse hook called" >> "$LOG"

# --- Check for and inject any completed reviews ---
inject_output=$(get_completed_reviews "$REVIEW_DIR")

# --- Output additionalContext ---
combined="${inject_output}"
escaped=$(echo "$combined" | jq -Rs .)

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": ${escaped}
  }
}
EOF

exit 0
