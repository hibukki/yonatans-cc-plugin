#!/usr/bin/env bash
set -euo pipefail

# TEST: Same as claude -p tests but with equivalent sleep duration instead
# Control to match timing of claude -p tests

sleep 6  # Similar to claude -p response time
echo '{"systemMessage": "[SLEEP TEST] 6-second sleep completed - no claude -p"}'
