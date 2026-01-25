#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib-common.sh"

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.p // ""')
new_text=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // ""')

# Only check pyproject.toml files
if [[ ! "$file_path" =~ pyproject\.toml$ ]]; then
  exit 0
fi

# Check for version specifier patterns (e.g. requests>=2.0, numpy==1.24)
if echo "$new_text" | grep -qE '[>=<~]=?\s*[0-9]'; then
  deny_with_reason 'Use `uv add <pkg>` instead of editing pyproject.toml directly.'
fi
