# drobdi — infra OpenClaw (arm64 / M1)

Un gateway OpenClaw minimaliste : un seul container, l'image officielle multi-arch,
et la mémoire de l'agent versionnée dans des dépôts GitHub privés séparés.

**Objectif :** redéployer sur n'importe quelle machine en `git clone` → restaurer les secrets → `docker compose up`.

---

## Architecture — 3 dépôts distincts

```
drobdi/                          ← CE REPO (infra seule)
├── docker-compose.yml
├── .env.example / .env (ignoré)
├── scripts/sync-memory.sh       ← fallback host-side sync
└── data/
    └── openclaw/                ← monté → /home/node/.openclaw dans le container
        │   (ignoré entièrement par ce repo)
        ├── .git/                ← REPO drobdi-memory (github: aymnms/drobdi-memory)
        ├── workspace/           ← versionné dans drobdi-memory
        │   ├── MEMORY.md, SOUL.md, USER.md, AGENTS.md, …
        │   ├── memory/*.md
        │   ├── skills/
        │   ├── job-search/
        │   └── drobsidian/      ← REPO drobsidian (github: aymnms/drobsidian)
        │       └── .git/           vault Obsidian job search
        ├── .ssh/                ← deploy key (ignorée par tous les repos)
        ├── credentials/         ← ignoré — secrets provider
        ├── agents/              ← ignoré — sessions de conversation
        ├── memory/main.sqlite   ← ignoré — base Active Memory
        └── …                   ← ignoré — état runtime
```

| Repo | Remote | Contenu |
|------|--------|---------|
| `drobdi` | `aymnms/drobdi` | Infra : docker-compose, scripts, .env.example |
| `drobdi-memory` | `aymnms/drobdi-memory` | Workspace lean : Markdown brain, skills, notes |
| `drobsidian` | `aymnms/drobsidian` | Vault Obsidian job search |

---

## Ce qui est versionné vs ignoré

**`drobdi-memory` (lean — aucun binaire, aucun secret) :**
- Suivi : `workspace/*.md`, `workspace/memory/*.md`, `workspace/skills/`, `workspace/job-search/`
- Exclu : `memory/main.sqlite`, `agents/` (sessions), `credentials/`, `.ssh/`, `drobsidian/`, `state/`, venvs Python

**`drobsidian` :**
- Suivi : tout le vault Obsidian (candidatures, entreprises, offres, projets, tâches, sprints)
- Exclu : `.obsidian/workspace*`, cache, plugins data, `.trash/`

Le `.gitignore` de `drobdi` exclut `data/openclaw/` entièrement — les deux autres repos vivent à l'intérieur et gèrent leur propre tracking.

---

## Sync mémoire → GitHub

### Auto — launchd macOS

Un seul agent, toutes les heures, via `docker exec` — **aucun Full Disk Access requis**.

| Agent | Déclencheur | Scope | Log |
|-------|-------------|-------|-----|
| `com.drobdi.memory-sync` | toutes les heures | drobdi-memory + drobsidian | `/tmp/drobdi-memory-sync.log` |

```bash
launchctl list | grep drobdi         # vérifier l'état
cat /tmp/drobdi-memory-sync.log      # voir le dernier log
```

### Manuelle — alias zsh

```bash
drobdi   # sync les 3 repos (drobdi-memory + drobsidian + drobdi infra)
```

L'alias `drobdi` est défini dans `~/.zshrc` et équivaut à :
```bash
bash ~/Documents/drobdi/scripts/daily-sync-all.sh
```

### Depuis le container (agent autonome)

```bash
docker exec openclaw-gateway bash /home/node/.openclaw/scripts/git-sync.sh          # drobdi-memory seul
docker exec openclaw-gateway bash /home/node/.openclaw/scripts/daily-sync-container.sh  # drobdi-memory + drobsidian
```

### Deploy keys SSH

| Repo | Clé privée | Scope GitHub |
|------|-----------|--------------|
| drobdi-memory | `.ssh/drobdi_memory_deploy` | write sur `aymnms/drobdi-memory` |
| drobsidian | `.ssh/drobsidian_deploy` | write sur `aymnms/drobsidian` |

---

## Premier déploiement (nouvelle machine)

```bash
# 1. Cloner l'infra
git clone git@github.com:aymnms/drobdi.git
cd drobdi

# 2. Configurer l'env
cp .env.example .env
# Générer un token fort : openssl rand -hex 32
# Renseigner OPENCLAW_GATEWAY_TOKEN dans .env

# 3. Restaurer la mémoire (choisir UNE option)

# Option A — depuis les repos git (sans secrets)
git clone git@github.com:aymnms/drobdi-memory.git data/openclaw
git clone git@github.com:aymnms/drobsidian.git data/openclaw/workspace/drobsidian
# Puis restaurer les secrets hors-git (credentials/, .ssh/, auth-profiles.json)
# via archive chiffrée ou re-onboarding

# Option B — depuis une archive chiffrée complète (avec secrets)
tar -xzf /path/to/openclaw-state-full.tgz -C data
# L'archive inclut tout data/openclaw/, secrets compris

# 4. Démarrer
docker compose up -d
docker compose logs -f openclaw-gateway   # attendre "gateway running on 18789"

# 5. Vérifier
docker compose exec openclaw-gateway openclaw doctor
open http://127.0.0.1:18789
```

### Recréer la deploy key SSH sur une nouvelle machine
```bash
ssh-keygen -t ed25519 -f data/openclaw/.ssh/drobdi_memory_deploy \
  -C "drobdi-agent@openclaw" -N ""
chmod 700 data/openclaw/.ssh
chmod 600 data/openclaw/.ssh/drobdi_memory_deploy
ssh-keyscan -t ed25519 github.com > data/openclaw/.ssh/known_hosts
# Ajouter la clé publique sur GitHub :
# aymnms/drobdi-memory → Settings → Deploy keys → Add (Allow write access)
cat data/openclaw/.ssh/drobdi_memory_deploy.pub
```

### Réinstaller les LaunchAgents
Les plists sont versionnées dans `launchagents/`. Un seul script installe tout :
```bash
bash scripts/install-launchagents.sh
```
Il substitue le chemin du repo dans les plists, les copie dans `~/Library/LaunchAgents/` et les charge.

| Agent | Déclencheur | Log |
|-------|-------------|-----|
| `com.drobdi.memory-sync` | toutes les heures | `/tmp/drobdi-memory-sync.log` |
| `com.drobdi.daily-sync` | tous les jours à minuit | `/tmp/drobdi-daily-sync.log` |

> **Note** : `com.drobdi.daily-sync` requiert Full Disk Access pour `/bin/bash`
> (System Settings → Privacy & Security → Full Disk Access).

---

## Telegram

Le bot est configuré dans `data/openclaw/credentials/` (ignoré de git).

- **Avec archive complète restaurée** : rien à faire, le token est déjà là.
- **Re-onboarding depuis zéro** :
  ```bash
  docker compose exec openclaw-gateway openclaw channels add \
    --channel telegram --token "<bot-token>"
  ```
- **Verrouiller au seul user autorisé** (ton Telegram numeric ID) :
  ```bash
  # Trouver ton ID : envoie un message au bot, surveille les logs :
  docker compose logs -f openclaw-gateway | grep "from.id"
  # Puis configurer le dmPolicy allowlist dans l'UI Control (/:18789)
  ```

---

## Mise à jour d'OpenClaw

```bash
# Bumper le tag dans docker-compose.yml, puis :
docker compose pull
docker compose up -d
docker compose exec openclaw-gateway openclaw doctor
```

---

## Annexe — décisions et gotchas

**3 repos séparés au lieu d'un seul.** Le dépôt infra (`drobdi`) était à la racine
et incluait tout via `.gitignore` re-includes. Cela a causé une fuite d'un token
Anthropic OAuth dans les sessions de conversation (juin 2026). La refonte en 3 repos
isole clairement infra / mémoire / vault et supprime les sessions du tracking git.

**Sessions exclues de git.** Les fichiers `.jsonl` de session contiennent l'historique
brut des conversations, qui peut inclure des secrets envoyés comme messages.
Ils ne seront jamais commités.

**Deploy key à scope réduit.** La clé SSH du container n'a accès qu'au repo
`drobdi-memory` (deploy key, pas une clé de compte). Elle est stockée dans le
volume monté mais exclue de tous les repos.

**Le skill `jx76-gog` nécessite Go.** L'image officielle slim n'a pas Go. Si besoin,
créer un `Dockerfile` :
```dockerfile
FROM ghcr.io/openclaw/openclaw:2026.4.15
USER root
RUN apt-get update && apt-get install -y --no-install-recommends golang-go \
    && rm -rf /var/lib/apt/lists/*
USER node
```
Et remplacer `image:` par `build: .` dans `docker-compose.yml`.

**mem_limit: 4g** sur le gateway. Augmenter si nécessaire (Docker Desktop →
Settings → Resources).
