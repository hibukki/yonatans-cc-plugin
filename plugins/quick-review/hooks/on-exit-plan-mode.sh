#!/bin/bash
set -euo pipefail

# Find the most recently modified plan file in ~/.claude/plans/
PLANS_DIR="$HOME/.claude/plans"

if [[ ! -d "$PLANS_DIR" ]]; then
  exit 0  # No plans dir, allow
fi

# Get most recently modified .md file
PLAN_FILE=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1)

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
  exit 0  # No plan file found, allow
fi

# Check if plan contains "commit" (case-insensitive)
if grep -qi "commit" "$PLAN_FILE"; then
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
