#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib-common.sh"
require_jq_or_exit

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.p // ""')
new_text=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // ""')

# Only check package.json files
if [[ ! "$file_path" =~ package\.json$ ]]; then
  exit 0
fi

# Check for version specifier patterns (e.g. "lodash": "^4.17.0")
if echo "$new_text" | grep -qE '":\s*"[\^~]?[0-9]'; then
  deny_with_reason 'Use `npm install <pkg>` or `pnpm add <pkg>` instead of editing package.json directly.'
fi
