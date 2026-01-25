#!/bin/bash
set -euo pipefail

# Debug: log the full hook input
INPUT=$(cat)
echo "$INPUT" >> /tmp/claude/exit-plan-mode-debug.log 2>/dev/null || true

# Find the most recently modified plan file in ~/.claude/plans/
PLANS_DIR="$HOME/.claude/plans"

if [[ ! -d "$PLANS_DIR" ]]; then
  exit 0  # No plans dir, allow
fi

# Get most recently modified .md file
PLAN_FILE=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1 || true)

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
  exit 0  # No plan file found, allow
fi

# Validate filename looks like a plan file (e.g., "word-word-word.md" or "word-word.md")
PLAN_BASENAME=$(basename "$PLAN_FILE")
if [[ ! "$PLAN_BASENAME" =~ ^[a-z]+-[a-z]+(-[a-z]+)*\.md$ ]]; then
  exit 0  # Doesn't look like a standard plan file name, allow
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
