# lib-common.sh - sourced by hook scripts

# Exit silently if jq is not installed (avoids errors on every hook call)
require_jq_or_exit() {
  command -v jq &>/dev/null || exit 0
}

# Output a deny decision for PreToolUse hooks
# Usage: deny_with_reason "reason message"
deny_with_reason() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
}
