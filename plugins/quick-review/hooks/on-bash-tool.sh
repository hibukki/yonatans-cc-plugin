#!/bin/bash
set -euo pipefail

# Debug: log that hook was called
echo "$(date): Hook called" >> /tmp/hook-debug.log

# Read JSON input from stdin
input=$(cat)
echo "$(date): Input received: $input" >> /tmp/hook-debug.log

# Extract the command that was run
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Check if this was a git commit command
if [[ "$command" == *"git commit"* ]]; then
  # Tell Claude to spawn the quick-reviewer agent in the background
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Debug: A git commit just completed. Please spawn the quick-review:quick-reviewer agent in the background (using the Task tool with run_in_background: true) to review the commit. Continue with your current work - the review will complete asynchronously."
  }
}
EOF
fi

# Exit successfully (don't block anything)
exit 0
