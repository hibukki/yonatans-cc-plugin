#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib-common.sh"
require_jq_or_exit

# Block ExitPlanMode if:
# 1. The plan doesn't mention "commit" (per user's CLAUDE.md preferences)
# 2. The plan hasn't been reviewed yet (once per plan file)

input=$(cat)

# Extract plan content from tool_input.plan
plan=$(echo "$input" | jq -r '.tool_input.plan // ""')

if [[ -z "$plan" ]]; then
  exit 0  # No plan content, allow
fi

# Check if plan contains "commit" (case-insensitive)
if ! echo "$plan" | grep -qi "commit"; then
  # Use this as an excuse to remind claude about lots of best-practices with plans, not only about commits
  deny_with_reason "Please use the plan-checklist skill and update the plan, then you can exit plan mode"
  exit 0
fi

# --- Plan review check (once per plan file) ---

# Find the most recently modified plan file
plans_dir="$HOME/.claude/plans"
if [[ ! -d "$plans_dir" ]]; then
  exit 0  # No plans directory, allow
fi

plan_file=$(ls -t "$plans_dir"/*.md 2>/dev/null | head -1)
if [[ -z "$plan_file" ]]; then
  exit 0  # No plan files, allow
fi

# Check if this plan has already been reviewed
marker="${plan_file}.reviewed"
if [[ -f "$marker" ]]; then
  exit 0  # Already reviewed, allow
fi

# Run sync plan review
SCRIPT_DIR="$(dirname "$0")"
AGENT_FILE="$SCRIPT_DIR/../agents/plan-reviewer.md"

review_output=$(claude -p "Review this plan file: $plan_file" --allowedTools 'Read,Grep,Glob' --agent "$AGENT_FILE" 2>&1) || true

# Create marker so we don't review again
touch "$marker"

# Deny with review feedback
deny_with_reason "Plan review feedback (you can now exit plan mode again to proceed):

$review_output"
