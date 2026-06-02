#!/usr/bin/env bash
# install-launchagents.sh — installe les LaunchAgents drobdi sur un nouvel hôte macOS.
# Usage : bash scripts/install-launchagents.sh
set -euo pipefail

DROBDI_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$DROBDI_ROOT/launchagents"
DEST="$HOME/Library/LaunchAgents"
ERRORS=0

log() { echo "[install-launchagents] $*"; }
err() { echo "[install-launchagents] ERROR: $*" >&2; ERRORS=$((ERRORS + 1)); }

for template in "$SRC"/*.plist; do
  name="$(basename "$template")"
  target="$DEST/$name"

  # Substitue __DROBDI_ROOT__ par le chemin absolu du repo
  sed "s|__DROBDI_ROOT__|$DROBDI_ROOT|g" "$template" > "$target"
  log "installé : $target"

  # Décharge si déjà chargé (ignore l'erreur si absent)
  launchctl unload "$target" 2>/dev/null || true
  launchctl load "$target"
  log "chargé   : $name"
done

if [[ $ERRORS -eq 0 ]]; then
  log "tous les LaunchAgents sont installés et actifs"
  echo ""
  launchctl list | grep drobdi
else
  err "$ERRORS erreur(s) — vérifier les logs ci-dessus"
  exit 1
fi
