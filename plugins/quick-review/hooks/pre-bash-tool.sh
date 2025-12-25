#!/bin/bash

# Simple debug hook for PreToolUse on Bash
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "DEBUG: PreToolUse hook fired for Bash tool"
  }
}
EOF

exit 0
