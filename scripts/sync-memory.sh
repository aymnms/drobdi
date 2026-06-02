#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Commit & push the curated OpenClaw memory to your private repo.
#
# Run this from the HOST (your Mac), where your normal git / GitHub auth lives.
# The repo's .gitignore guarantees only memory (workspace + sessions + the
# SQLite DB) is staged — credentials and .env are never committed.
#
# Usage:
#   ./scripts/sync-memory.sh                 # auto message with timestamp
#   ./scripts/sync-memory.sh "after sprint"  # custom message
#
# Note: sessions are appended live by the gateway. This is a best-effort
# snapshot; for a perfectly clean capture, run `docker compose stop` first.
# ---------------------------------------------------------------------------
set -euo pipefail

cd "$(dirname "$0")/.."   # repo root

msg="${1:-memory sync $(date '+%Y-%m-%d %H:%M')}"

git add -A

if git diff --cached --quiet; then
  echo "No memory changes to sync."
  exit 0
fi

git commit -m "$msg"
git push
echo "Memory synced: $msg"
