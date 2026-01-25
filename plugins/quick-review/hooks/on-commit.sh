#!/usr/bin/env bash
set -euo pipefail

# Called by on-bash-tool.sh when a git commit is detected
# Input: JSON via stdin
# Output: message text to stdout (not JSON)

BIG_COMMIT_THRESHOLD=100  # lines changed

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-review.sh"
require_jq_or_exit

# Count total lines changed (insertions + deletions) in a commit
count_commit_changes() {
  local sha="$1"
  git show --stat "$sha" \
    | tail -1 \
    | grep -oE '[0-9]+ insertion|[0-9]+ deletion' \
    | grep -oE '[0-9]+' \
    | paste -sd+ - \
    | bc 2>/dev/null || echo "0"
}

input=$(cat)
REVIEW_DIR=$(get_review_dir "$input")
mkdir -p "$REVIEW_DIR"

stdout=$(echo "$input" | jq -r '.tool_response.stdout // ""')

# Git outputs commits like "[main abc1234] commit message" - extract the SHA
commit_sha=$(echo "$stdout" | grep -oE '\[[a-zA-Z0-9_/-]+ [a-f0-9]+\]' | grep -oE '[a-f0-9]{7,}' | head -1 || true)

if [[ -z "$commit_sha" ]]; then
  exit 0
fi

# Spawn background review (detached from stdin so it doesn't block)
LOG="/tmp/hook-debug.log"
echo "$(date): Detected commit $commit_sha, spawning background review" >> "$LOG"
(
  claude -p "Review commit $commit_sha" \
    --agent quick-reviewer \
    2>>"$LOG" \
    > "$REVIEW_DIR/review-$commit_sha.tmp"

  # Atomic rename: reviewers only see complete files
  mv "$REVIEW_DIR/review-$commit_sha.tmp" "$REVIEW_DIR/review-$commit_sha.txt"
  echo "$(date): Review for $commit_sha completed" >> "$LOG"
) </dev/null &

echo -n "[Spawned background review for commit $commit_sha]"

# Remind about small commits if this one is large
diff_lines=$(count_commit_changes "$commit_sha")
if [[ "$diff_lines" -gt "$BIG_COMMIT_THRESHOLD" ]]; then
  echo -n " As you know, it is nice to have small self-contained commits. This message was automatically triggered by the last commit, but it is only a reminder, use your own judgement."
fi
