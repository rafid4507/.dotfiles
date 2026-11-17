#!/usr/bin/env bash
# Apply the system-level parts of this repo in one go.
# Usage: sudo bash scripts/apply-system.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$REPO/install.sh" --system
