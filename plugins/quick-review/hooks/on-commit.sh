#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-review.sh"

input=$(cat)
REVIEW_DIR=$(get_review_dir "$input")
mkdir -p "$REVIEW_DIR"

command=$(echo "$input" | jq -r '.tool_input.command // ""')
stdout=$(echo "$input" | jq -r '.tool_response.stdout // ""')

# Check if this is a git commit command (handles flags like: git --no-pager commit)
is_git_commit() {
  [[ "$1" =~ (^|[[:space:]])git[[:space:]].*commit([[:space:]]|$) ]] || [[ "$1" == *"git commit"* ]]
}

if ! is_git_commit "$command"; then
  exit 0
fi

# Extract commit SHA from output like "[main abc1234] commit message"
commit_sha=$(echo "$stdout" | grep -oE '\[[a-zA-Z0-9_/-]+ [a-f0-9]+\]' | grep -oE '[a-f0-9]{7,}' | head -1 || true)

if [[ -z "$commit_sha" ]]; then
  exit 0
fi

# Spawn background review
LOG="/tmp/hook-debug.log"
echo "$(date): Detected commit $commit_sha, spawning background review" >> "$LOG"
(
  claude -p "Review commit $commit_sha" \
    --agent quick-reviewer \
    2>>"$LOG" \
    > "$REVIEW_DIR/review-$commit_sha.tmp"

  mv "$REVIEW_DIR/review-$commit_sha.tmp" "$REVIEW_DIR/review-$commit_sha.txt"
  echo "$(date): Review for $commit_sha completed" >> "$LOG"
) </dev/null &

spawned_msg="[Spawned background review for commit $commit_sha]"

# Check commit size and warn if large
diff_lines=$(git show --stat "$commit_sha" | tail -1 | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | grep -oE '[0-9]+' | paste -sd+ - | bc 2>/dev/null || echo "0")
size_warning=""
if [[ "$diff_lines" -gt 100 ]]; then
  size_warning=" As you know, it is nice to have small self-contained commits."
fi

# Output
combined="${spawned_msg}${size_warning}"
escaped=$(echo "$combined" | jq -Rs .)
cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":${escaped}}}
EOF

exit 0
