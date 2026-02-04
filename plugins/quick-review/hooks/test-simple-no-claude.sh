#!/usr/bin/env bash
set -euo pipefail

# TEST 5: Control - no claude -p at all, just sleep and output
# This should definitely work (confirms async delivery still works)

sleep 5
echo '{"systemMessage": "[CONTROL TEST] Simple async hook without claude -p - delivered after 5s"}'
