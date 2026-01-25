#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-review.sh"

# Check for uncommitted changes
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  cat <<EOF
{
  "decision": "block",
  "reason": "There are uncommitted changes. Please commit, stash, gitignore, or whatever fits the situation."
}
EOF
  exit 0
fi

input=$(cat)
review_dir=$(get_review_dir "$input")

# Check for completed reviews only
completed=$(get_completed_reviews "$review_dir")

if [[ -n "$completed" ]]; then
  escaped=$(echo "$completed" | jq -Rs .)
  cat <<EOF
{
  "decision": "block",
  "reason": ${escaped}
}
EOF
else
  echo '{"decision": "approve"}'
fi
