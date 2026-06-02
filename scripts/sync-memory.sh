#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# HOST-side fallback: commit & push drobdi-memory from the Mac.
# Normally the agent auto-syncs from inside the container via the cron.
# Use this script when the container is stopped or as a manual override.
#
# Usage:
#   ./scripts/sync-memory.sh                 # auto message with timestamp
#   ./scripts/sync-memory.sh "note"          # custom message
# ---------------------------------------------------------------------------
set -euo pipefail

MEMORY_REPO="$(dirname "$0")/../data/openclaw"

msg="${1:-memory sync $(date '+%Y-%m-%d %H:%M')}"

git -C "$MEMORY_REPO" add workspace/

if git -C "$MEMORY_REPO" diff --cached --quiet; then
  echo "No memory changes to sync."
  exit 0
fi

git -C "$MEMORY_REPO" commit -m "$msg"
git -C "$MEMORY_REPO" push
echo "Memory synced: $msg"
