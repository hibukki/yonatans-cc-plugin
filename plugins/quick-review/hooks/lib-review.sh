#!/usr/bin/env bash
# Shared library for review-related hooks

# Source lib-common.sh to make require_jq_or_exit available to scripts that source us
# (the calling script should call require_jq_or_exit, not this library)
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"

# Get review directory for current session
get_review_dir() {
  local input="$1"
  local session_id=$(echo "$input" | jq -r '.session_id')
  if [[ -z "$session_id" || "$session_id" == "null" ]]; then
    echo "/tmp/claude-reviews-unknown"
  else
    echo "/tmp/claude-reviews-${session_id}"
  fi
}

# Check for completed reviews (.txt files) and return their content
# Also removes the files after reading
get_completed_reviews() {
  local review_dir="$1"
  local output=""

  if [[ -d "$review_dir" ]]; then
    for review_file in "$review_dir"/review-*.txt; do
      [[ -e "$review_file" ]] || continue

      local filename=$(basename "$review_file")
      local commit_sha="${filename#review-}"
      commit_sha="${commit_sha%.txt}"

      local review_content=$(cat "$review_file")
      output="${output}

=== Review ready for commit ${commit_sha}. Use the prioritize-review-comments skill to decide which ones to implement ===
<Review>
${review_content}
</Review>
"
      rm -f "$review_file"
    done
  fi

  echo "$output"
}

# Check for pending reviews (.tmp files) - still in progress
count_pending_reviews() {
  local review_dir="$1"

  if [[ -d "$review_dir" ]]; then
    find "$review_dir" -maxdepth 1 -name 'review-*.tmp' 2>/dev/null | wc -l | tr -d ' '
  else
    echo "0"
  fi
}
