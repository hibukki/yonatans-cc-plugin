#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib-common.sh"
require_jq_or_exit

input=$(cat)
plan_content=$(echo "$input" | jq -r '.tool_input.plan // ""')

if [[ -z "$plan_content" ]]; then
  exit 0
fi

if ! echo "$plan_content" | grep -qi "commit"; then
  # Use this as an excuse to remind claude about best-practices, not only about commits
  deny_with_reason "Please use the plan-checklist skill and update the plan, then you can exit plan mode"
  exit 0
fi

plans_dir="$HOME/.claude/plans"
if [[ ! -d "$plans_dir" ]]; then
  exit 0
fi

plan_file=$(ls -t "$plans_dir"/*.md 2>/dev/null | head -1)
if [[ -z "$plan_file" ]]; then
  exit 0
fi

review_marker="${plan_file}.reviewed"
if [[ -f "$review_marker" ]]; then
  exit 0
fi

SCRIPT_DIR="$(dirname "$0")"
AGENT_FILE="$SCRIPT_DIR/../agents/plan-reviewer.md"

review_output=$(claude -p "Review this plan file: $plan_file" --allowedTools 'Read,Grep,Glob' --agent "$AGENT_FILE" 2>&1) || true

touch "$review_marker"

deny_with_reason "A plan-reviewer-claude has suggestions for this plan. Use the suggestions that are helpful for making a top-notch plan, even if the suggestions are small. Discard suggestions that are wrong, of course. You can also AskUserQuestion.
<Suggestions>
$review_output
</Suggestions>

If you want to call this reviewer again, you can launch the plan-reviewer subagent.
"
