#!/usr/bin/env bash
# Legacy entry point. Kept so old muscle memory still works.
# The real implementation is setup-login-theme.sh (stable Breeze + blur).
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-login-theme.sh" "$@"
