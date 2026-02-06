#!/usr/bin/env bash
set -euo pipefail

# Sync PostToolUse hook for git commits.
# Runs claude -p to review the commit and delivers via additionalContext.
#
# Why sync instead of async?
# Claude Code async hooks have a bug where output (systemMessage/additionalContext)
# is never delivered to the conversation, regardless of format.
# Tested: systemMessage, hookSpecificOutput.additionalContext, top-level additionalContext.
# None worked with async:true. All work with sync hooks.
# Bug report: TODO(link)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-common.sh"
require_jq_or_exit

BIG_COMMIT_THRESHOLD=100  # lines changed

# Read JSON input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only run on git commit commands
if ! echo "$COMMAND" | grep -qE '(^|[[:space:]])git[[:space:]].*commit([[:space:]]|$)'; then
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

# Run review in an isolated subshell to prevent claude stdout from corrupting hook JSON.
REVIEW_FILE="/tmp/review-${COMMIT_SHA}-$$.txt"
(
  exec >/dev/null 2>&1
  claude -p "Review commit $COMMIT_SHA" --agent quick-reviewer > "$REVIEW_FILE" 2>&1
)
REVIEW_EXIT_CODE=$?
REVIEW_OUTPUT=$(cat "$REVIEW_FILE" 2>/dev/null || echo "NO REVIEW OUTPUT")
rm -f "$REVIEW_FILE"

if [[ $REVIEW_EXIT_CODE -ne 0 ]]; then
  REVIEW="ERROR (exit code $REVIEW_EXIT_CODE): $REVIEW_OUTPUT"
else
  REVIEW="$REVIEW_OUTPUT"
fi

# Build the output message
OUTPUT="=== Review for commit ${COMMIT_SHA} ===

${REVIEW}

Use the prioritize-review-comments skill to decide which suggestions to implement."

# Large commit warning
if command -v bc &>/dev/null; then
  DIFF_LINES=$(count_commit_changes "$COMMIT_SHA")
  if [[ "$DIFF_LINES" -gt "$BIG_COMMIT_THRESHOLD" ]]; then
    OUTPUT="${OUTPUT}

Note: This was a large commit (${DIFF_LINES} lines changed). Smaller, self-contained commits are easier to review."
  fi
fi

# Deliver via hookSpecificOutput.additionalContext (confirmed working for sync PostToolUse)
jq -n --arg ctx "$OUTPUT" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ctx
  }
}'
