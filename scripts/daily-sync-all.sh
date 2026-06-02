#!/usr/bin/env bash
# daily-sync-all.sh — host-side daily sync for all 3 repos
# Runs as launchd job (daily at 06:00).  Safe to run manually at any time.
# Continues on per-repo failure; exits non-zero if any repo failed.
set -uo pipefail

DROBDI_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MEMORY_REPO="$DROBDI_ROOT/data/openclaw"
DROBSIDIAN_REPO="$MEMORY_REPO/workspace/drobsidian"
KEY="$MEMORY_REPO/.ssh/drobdi_memory_deploy"
KNOWN="$MEMORY_REPO/.ssh/known_hosts"
TODAY=$(date '+%Y-%m-%d')
ERRORS=0

log() { echo "[daily-sync] $*"; }
err() { echo "[daily-sync] ERROR: $*" >&2; }

# ── helper: sync a repo that lives entirely on the host ──────────────────────
sync_host_repo() (
  set -euo pipefail
  local name="$1"
  local dir="$2"
  shift 2
  # remaining args are passed to GIT_SSH_COMMAND if needed
  local ssh_cmd="${SSH_CMD:-}"

  log "[$name] pulling..."
  if [[ -n "$ssh_cmd" ]]; then
    GIT_SSH_COMMAND="$ssh_cmd" git -C "$dir" pull --ff-only
  else
    git -C "$dir" pull --ff-only
  fi

  git -C "$dir" add -A

  if git -C "$dir" diff --cached --quiet; then
    log "[$name] nothing to commit"
    return 0
  fi

  if [[ -n "$ssh_cmd" ]]; then
    GIT_SSH_COMMAND="$ssh_cmd" git -C "$dir" commit -m "chore(sync): daily sync $TODAY"
    GIT_SSH_COMMAND="$ssh_cmd" git -C "$dir" push
  else
    git -C "$dir" commit -m "chore(sync): daily sync $TODAY"
    git -C "$dir" push
  fi
  log "[$name] pushed"
)

# ── 1. drobdi-memory — runs inside the container ─────────────────────────────
log "[drobdi-memory] syncing via docker exec..."
if docker exec openclaw-gateway bash /home/node/.openclaw/scripts/git-sync.sh; then
  log "[drobdi-memory] done"
else
  err "[drobdi-memory] sync failed"
  ERRORS=$((ERRORS + 1))
fi

# ── 2. drobsidian — host git, default SSH (uses ~/.ssh/config) ───────────────
if [[ -d "$DROBSIDIAN_REPO/.git" ]]; then
  if sync_host_repo "drobsidian" "$DROBSIDIAN_REPO"; then
    : # logged inside
  else
    err "[drobsidian] sync failed"
    ERRORS=$((ERRORS + 1))
  fi
else
  err "[drobsidian] repo not found at $DROBSIDIAN_REPO — skipping"
  ERRORS=$((ERRORS + 1))
fi

# ── 3. drobdi (infra) — host git, default SSH ────────────────────────────────
if [[ -d "$DROBDI_ROOT/.git" ]]; then
  if sync_host_repo "drobdi" "$DROBDI_ROOT"; then
    : # logged inside
  else
    err "[drobdi] sync failed"
    ERRORS=$((ERRORS + 1))
  fi
else
  err "[drobdi] repo not found at $DROBDI_ROOT — skipping"
  ERRORS=$((ERRORS + 1))
fi

# ── result ────────────────────────────────────────────────────────────────────
if [[ $ERRORS -eq 0 ]]; then
  log "all repos synced successfully"
else
  err "$ERRORS repo(s) failed — check output above"
  exit 1
fi
