#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib-common.sh"
require_jq_or_exit

# Block ExitPlanMode if the plan doesn't mention "commit" (per user's CLAUDE.md preferences)

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

deny_with_reason "Please also plan for making small self-contained commits (per the user's preferences) or mention a different commit plan"
