#!/bin/bash
set -euo pipefail

input=$(cat)
new_text=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // ""')

# Check for comment patterns (// # /* * <!--)
if echo "$new_text" | grep -qE '(//\s*\w|#\s*\w|/\*|\*\s+\w|<!--)'; then
  cat <<'EOF'
{
  "systemMessage": "This is an automated message for adding comments: Try to have variable/function names that don't require comments, if possible. Especially avoid repeating code-logic in comments (which might lead to comment rot). What do you think about the comments in this case?"
}
EOF
fi

exit 0
