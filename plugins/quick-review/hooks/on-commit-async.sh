#!/usr/bin/env bash
set -euo pipefail

# Async hook for git commits
# Runs in background via Claude Code's native async hook feature
# Returns review via additionalContext (delivered on next conversation turn)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-common.sh"
require_jq_or_exit

BIG_COMMIT_THRESHOLD=100  # lines changed

# Read JSON input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check if this is a git commit command
if ! echo "$COMMAND" | grep -qE '(^|[[:space:]])git[[:space:]].*commit([[:space:]]|$)'; then
  # Not a commit, exit silently
  exit 0
fi

# Reset write counter on commit
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[[ -n "$SESSION_ID" && "$SESSION_ID" != "null" ]] && rm -f "/tmp/claude-writes-${SESSION_ID}"

# Extract commit SHA from tool_response
# Git outputs commits like "[main abc1234] commit message"
STDOUT=$(echo "$INPUT" | jq -r '.tool_response.stdout // empty')
COMMIT_SHA=$(echo "$STDOUT" | grep -oE '\[[a-zA-Z0-9_/-]+ [a-f0-9]+\]' | grep -oE '[a-f0-9]{7,}' | head -1 || true)

if [[ -z "$COMMIT_SHA" ]]; then
  exit 0
fi

# Count total lines changed (insertions + deletions) in a commit
count_commit_changes() {
  local sha="$1"
  git show --stat "$sha" 2>/dev/null \
    | tail -1 \
    | grep -oE '[0-9]+ insertion|[0-9]+ deletion' \
    | grep -oE '[0-9]+' \
    | paste -sd+ - \
    | bc 2>/dev/null || echo "0"
}

# Run the review
REVIEW=$(claude -p "Review commit $COMMIT_SHA" --agent quick-reviewer 2>/dev/null || echo "Review failed or timed out")

# Build the output message
OUTPUT="=== Review for commit ${COMMIT_SHA} ===

${REVIEW}

Use the prioritize-review-comments skill to decide which suggestions to implement."

# Check if commit was large and add reminder
if ! command -v bc &>/dev/null; then
  OUTPUT="${OUTPUT}

Note: 'bc' is not installed. Install it to enable large commit warnings (brew install bc)."
else
  DIFF_LINES=$(count_commit_changes "$COMMIT_SHA")
  if [[ "$DIFF_LINES" -gt "$BIG_COMMIT_THRESHOLD" ]]; then
    OUTPUT="${OUTPUT}

Note: This was a large commit (${DIFF_LINES} lines changed). Smaller, self-contained commits are easier to review."
  fi
fi

# Return via systemMessage (delivered to Claude on next turn)
jq -n --arg output "$OUTPUT" '{
  "systemMessage": $output
}'
