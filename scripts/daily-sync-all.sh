#!/usr/bin/env bash
# daily-sync-all.sh — fallback manuel pour synchroniser les 3 repos depuis l'hôte.
# La sync automatique (launchd) passe par daily-sync-container.sh via docker exec.
# Utile pour inclure drobdi (infra) ou en cas d'indisponibilité du container.
set -uo pipefail

DROBDI_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MEMORY_REPO="$DROBDI_ROOT/data/openclaw"
DROBSIDIAN_REPO="$MEMORY_REPO/workspace/drobsidian"
MEMORY_KEY="$MEMORY_REPO/.ssh/drobdi_memory_deploy"
DROBSIDIAN_KEY="$MEMORY_REPO/.ssh/drobsidian_deploy"
KNOWN="$MEMORY_REPO/.ssh/known_hosts"
TODAY=$(date '+%Y-%m-%d')
ERRORS=0

log() { echo "[daily-sync] $*"; }
err() { echo "[daily-sync] ERROR: $*" >&2; }

sync_host_repo() (
  set -euo pipefail
  local name="$1" dir="$2"
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

# ── 1. drobdi-memory — deploy key (host paths override core.sshCommand) ──────
MEMORY_SSH="ssh -i $MEMORY_KEY -o UserKnownHostsFile=$KNOWN -o StrictHostKeyChecking=yes -F /dev/null"
if SSH_CMD="$MEMORY_SSH" sync_host_repo "drobdi-memory" "$MEMORY_REPO"; then :
else err "[drobdi-memory] sync failed"; ERRORS=$((ERRORS + 1)); fi

# ── 2. drobsidian — deploy key (host paths override core.sshCommand) ─────────
DROBSIDIAN_SSH="ssh -i $DROBSIDIAN_KEY -o UserKnownHostsFile=$KNOWN -o StrictHostKeyChecking=yes -F /dev/null"
if [[ -d "$DROBSIDIAN_REPO/.git" ]]; then
  if SSH_CMD="$DROBSIDIAN_SSH" sync_host_repo "drobsidian" "$DROBSIDIAN_REPO"; then :
  else err "[drobsidian] sync failed"; ERRORS=$((ERRORS + 1)); fi
else
  err "[drobsidian] not found at $DROBSIDIAN_REPO — skipping"
  ERRORS=$((ERRORS + 1))
fi

# ── 3. drobdi (infra) — SSH de compte (changes intentionnels seulement) ──────
if [[ -d "$DROBDI_ROOT/.git" ]]; then
  if sync_host_repo "drobdi" "$DROBDI_ROOT"; then :
  else err "[drobdi] sync failed"; ERRORS=$((ERRORS + 1)); fi
else
  err "[drobdi] not found at $DROBDI_ROOT — skipping"
  ERRORS=$((ERRORS + 1))
fi

if [[ $ERRORS -eq 0 ]]; then
  log "all repos synced successfully"
else
  err "$ERRORS repo(s) failed — check output above"
  exit 1
fi
