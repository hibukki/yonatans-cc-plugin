#!/usr/bin/env bash
# Shared utilities for hook scripts

# Output a deny decision for PreToolUse hooks
# Usage: deny_with_reason "reason message"
deny_with_reason() {
  local reason="$1"
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "$reason"
  }
}
EOF
}
