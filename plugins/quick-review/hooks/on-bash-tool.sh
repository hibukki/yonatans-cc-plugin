#!/usr/bin/env bash
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

# --- If this was a git commit, handle it ---
command=$(echo "$input" | jq -r '.tool_input.command // ""')
commit_output=""

# Check if this is a git commit command (handles flags like: git --no-pager commit)
is_git_commit() {
  [[ "$1" =~ (^|[[:space:]])git[[:space:]].*commit([[:space:]]|$) ]] || [[ "$1" == *"git commit"* ]]
}

if is_git_commit "$command"; then
  commit_output=$(echo "$input" | "$SCRIPT_DIR/on-commit.sh" || true)

  # Reset write counter on commit
  session_id=$(echo "$input" | jq -r '.session_id')
  [[ -n "$session_id" && "$session_id" != "null" ]] && rm -f "/tmp/claude-writes-${session_id}"
fi

# --- Output additionalContext ---
combined="${inject_output}${commit_output}"
escaped=$(echo "$combined" | jq -Rs .)

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": ${escaped}
  }
}
EOF
