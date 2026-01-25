#!/usr/bin/env bash
set -euo pipefail

# Block ExitPlanMode if the plan doesn't mention "commit" (per user's CLAUDE.md preferences)

# Read hook input (contains tool_input.plan with the plan content)
input=$(cat)

# Extract plan content from tool_input.plan
plan=$(echo "$input" | jq -r '.tool_input.plan // ""')

if [[ -z "$plan" ]]; then
  exit 0  # No plan content, allow
fi

# Check if plan contains "commit" (case-insensitive)
if echo "$plan" | grep -qi "commit"; then
  exit 0  # Found "commit", allow
fi

# Block and ask Claude to add commits to the plan
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Please also plan for making small self-contained commits (per the user's preferences) or mention a different commit plan"
  }
}
EOF
