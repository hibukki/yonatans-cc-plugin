#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib-common.sh"
require_jq_or_exit

# Read input from stdin
input=$(cat)

# Get transcript path
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Get the last assistant message from the transcript
# The transcript is JSONL format with entries containing type/message fields
last_assistant_text=$(tail -100 "$transcript_path" | \
  jq -s '[.[] | select(.type == "assistant")] | last | .message.content |
         if type == "array" then
           [.[] | select(.type == "text") | .text] | join("")
         else . end // ""' -r 2>/dev/null || echo "")

# Check if it ends with "?" (but not "? " - trailing space is the escape hatch)
if [[ "$last_assistant_text" == *"?" ]]; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "Consider using the AskUserQuestion tool to ask the user questions. You are getting this automated reminder because your last message ended with \"?\". You can avoid this reminder by ending with \"? \" (with a trailing space) if you intentionally want to end with a question mark without using AskUserQuestion."
}
EOF
else
  echo '{"decision": "approve"}'
fi
