#!/bin/bash
set -euo pipefail

# Check if hookify is installed by looking in the plugin cache
if ! ls ~/.claude/plugins/cache/*/hookify 2>/dev/null | grep -q hookify; then
  cat <<'EOF'
{
  "systemMessage": "⚠️ This plugin includes hookify rules but hookify doesn't appear to be installed. To install: /plugin install hookify@claude-plugins-official"
}
EOF
  echo "⚠️ quick-review: hookify not detected. To install: /plugin install hookify@claude-plugins-official" >&2
fi

exit 0
