# drobdi — minimal OpenClaw

A deliberately small OpenClaw setup: one gateway container, the official
multi-arch image, and your AI memory versioned in this private repo.

Goal: redeploy on any machine with `git clone` → restore secrets → `docker compose up`.

---

## Architecture note (amd64 → arm64)

Your previous instance ran under **WSL/Windows (amd64)**. The target is a
**MacBook Pro M1 (arm64)**. This is fine: your memory is Markdown + SQLite + JSON,
which are architecture-independent. Only the container image differs, and
`ghcr.io/openclaw/openclaw` is multi-arch — Docker pulls the arm64 variant
automatically on the Mac.

---

## Repo layout

```
drobdi/
├── docker-compose.yml        # gateway + opt-in CLI sidecar
├── .env.example              # copy to .env, fill in
├── .env                      # gitignored — your real secrets
├── .gitignore                # deny-by-default; secrets can't leak
├── README.md
├── scripts/
│   └── sync-memory.sh        # host-side git sync
└── data/
    └── openclaw/             # bind-mounted to /home/node/.openclaw
        ├── workspace/        # VERSIONED — curated memory + persona files
        ├── memory/main.sqlite# VERSIONED — Active Memory DB
        ├── agents/main/
        │   ├── sessions/     # VERSIONED — conversation history
        │   └── agent/auth-profiles.json   # IGNORED — provider secrets
        ├── credentials/      # IGNORED — all secrets/tokens
        └── (logs, media, telegram, gogcli, ...)  # IGNORED — runtime state
```

### What is versioned vs ignored

Three buckets:

1. **Versioned (the "brain")** — pushed to GitHub, diffable:
   `workspace/` (MEMORY.md, USER.md, AGENTS.md, SOUL.md, IDENTITY.md,
   BOOTSTRAP.md, HEARTBEAT.md, TOOLS.md, `memory/*.md`, `skills/`),
   `memory/main.sqlite`, and `agents/main/sessions/` (your conversation history).

2. **Never committed (secrets)** — stay local only, transferred out-of-band:
   `credentials/`, `**/auth-profiles.json`, `gogcli/` keyring, `.env`.

3. **Ignored runtime state** — recreated on each machine: `logs/`, `media/`,
   `telegram/` (channel session), `canvas/`, `flows/`, `tasks/`, etc.

> The `.gitignore` is deny-by-default: anything under `data/openclaw/` is ignored
> unless explicitly re-included, so `git add -A` can never stage a credential.
> Conversation history is plaintext personal data — keep this repo **private**.

---

## A. One-time migration from the old (WSL) machine

1. **Stop the old gateway** so files aren't changing mid-copy. In the old
   project dir: `docker compose down`.

2. **Archive the full state dir** (this carries your memory *and* secrets/auth
   so you don't have to re-onboard). On the old box, from
   `C:\Users\aymnms\Documents\drobdi\`:
   ```bash
   tar -czf openclaw-state-full.tgz -C data openclaw
   ```
   Encrypt it before moving it (it contains API keys, OAuth tokens, the Telegram
   token). Transfer to the Mac via a secure channel (USB / AirDrop / scp), then
   **delete the archive** once restored.

3. **Trim the fat.** The old setup carried things this minimal stack drops:
   Open-WebUI (~6.7 GB, redundant with the Control UI) and a custom 5.9 GB
   gateway build. You don't migrate those — only the state dir above.

---

## B. First boot on the Mac

1. Install **Docker Desktop for Mac (Apple Silicon)**.

2. Put this repo in place and restore state:
   ```bash
   git clone git@github.com:<you>/drobdi.git
   cd drobdi
   mkdir -p data
   tar -xzf /path/to/openclaw-state-full.tgz -C data   # restores data/openclaw
   ```
   (On the very first migration the repo is empty of memory; the restore above
   provides it. On later machines, `git clone` already brings the memory.)

3. **Remove the old nested git repo** in the workspace (it had no remote; the
   project repo tracks these files directly now):
   ```bash
   rm -rf data/openclaw/workspace/.git
   ```

4. Configure env:
   ```bash
   cp .env.example .env
   # set OPENCLAW_GATEWAY_TOKEN — generate one with: openssl rand -hex 32
   ```

5. (Optional) Confirm the arm64 image exists:
   ```bash
   docker manifest inspect ghcr.io/openclaw/openclaw:2026.4.15 | grep -i arm64
   ```

6. Start it:
   ```bash
   docker compose up -d
   docker compose logs -f openclaw-gateway   # expect: gateway running on 18789
   ```
   If you hit `EACCES` on `/home/node/.openclaw`, fix ownership to uid 1000:
   `sudo chown -R 1000:1000 data/openclaw` (usually unnecessary on Docker Desktop).

7. Apply any config migrations and verify:
   ```bash
   docker compose run --rm openclaw-cli doctor
   ```

8. Open `http://127.0.0.1:18789`, paste your `OPENCLAW_GATEWAY_TOKEN`.

---

## C. Telegram

You already have a bot — **don't paste its token anywhere public.**

- If you restored the full state archive, the Telegram channel is already
  configured (token in `data/openclaw/credentials/`, allowlist preserved).
  Verify: `docker compose run --rm openclaw-cli channels list`.

- If you're starting clean (no restored secrets), add it via the sidecar — the
  token is written to `data/openclaw/credentials/` (gitignored):
  ```bash
  docker compose run --rm openclaw-cli channels add --channel telegram --token "<bot-token>"
  ```

- Lock the bot to you only: find your numeric Telegram user ID by messaging the
  bot and watching `docker compose logs -f openclaw-gateway` for `from.id`, then
  set the DM policy to allowlist:
  ```bash
  docker compose run --rm openclaw-cli configure --section channels
  # dmPolicy = allowlist ; add your numeric id to allowFrom
  ```

---

## D. Memory → GitHub sync strategy

**Recommended: host-side git, scheduled.** Because this repo *is* the bind-mount
directory, your Mac can commit and push the live memory directly — no SSH keys
inside the container, no git hooks, clean trust boundary.

- **Manual** (full control):
  ```bash
  ./scripts/sync-memory.sh "after today's sprint"
  ```

- **Scheduled** (keeps GitHub current automatically). Example macOS launchd agent
  at `~/Library/LaunchAgents/com.drobdi.memory-sync.plist` running every 6h:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <plist version="1.0"><dict>
    <key>Label</key><string>com.drobdi.memory-sync</string>
    <key>ProgramArguments</key>
    <array>
      <string>/bin/bash</string>
      <string>-lc</string>
      <string>cd /Users/&lt;you&gt;/drobdi &amp;&amp; ./scripts/sync-memory.sh</string>
    </array>
    <key>StartInterval</key><integer>21600</integer>
    <key>RunAtLoad</key><true/>
  </dict></plist>
  ```
  Load it: `launchctl load ~/Library/LaunchAgents/com.drobdi.memory-sync.plist`

**Not recommended:** having the agent (inside the container) push to GitHub, or a
git hook. Both add complexity and expose credentials to the container, and the
agent could commit things you didn't intend. Keep pushes on the host.

> Sessions are written live, so a scheduled commit is a best-effort snapshot.
> For a perfectly clean capture, `docker compose stop` before syncing.

---

## E. Redeploy on a brand-new machine

```bash
git clone git@github.com:<you>/drobdi.git
cd drobdi
cp .env.example .env          # set OPENCLAW_GATEWAY_TOKEN

# Restore secrets — choose ONE:
#  (a) extract your encrypted secrets archive into ./data/openclaw   (no re-auth)
#  (b) re-onboard:
#        docker compose run --rm openclaw-cli onboard
#        docker compose run --rm openclaw-cli channels add --channel telegram --token "<token>"

docker compose up -d
docker compose run --rm openclaw-cli doctor
```

You're back in a few minutes: memory + history from git, secrets restored or
re-authed. This is the portability payoff.

---

## Appendix — decisions & gotchas

**Open-WebUI dropped.** It was ~6.7 GB and redundant with OpenClaw's own Control
UI (`:18789`), and both containers were OOM-killed (exit 137) together. Re-add it
only if you specifically use it as a separate local-model chat UI.

**The `jx76-gog` skill needs Go.** Your old gateway was a custom build (node:24-
bookworm) with Go baked in. The official slim image has no Go, so that skill won't
run as-is. If you need it, swap `image:` for a tiny build. Create `Dockerfile`:
```dockerfile
FROM ghcr.io/openclaw/openclaw:2026.4.15
USER root
RUN apt-get update && apt-get install -y --no-install-recommends golang-go \
    && rm -rf /var/lib/apt/lists/*
USER node
```
then in `docker-compose.yml` replace the gateway's `image:` line with `build: .`
(keep the same tag for the CLI). You'll also need `GOG_KEYRING_PASSWORD` in `.env`
and the (gitignored) `gogcli/` credentials. Otherwise, drop the skill for a truly
minimal setup.

**Obsidian vault (`workspace/drobsidian/`)** is its own git repo. This repo ignores
it to avoid nested-repo mess. Keep versioning it separately (its own remote), or
add it as a git submodule if you want one clone to pull both.

**Updating OpenClaw.** Bump the image tag in `docker-compose.yml`, then:
```bash
docker compose pull
docker compose up -d
docker compose run --rm openclaw-cli doctor   # applies config migrations
```

**Memory / OOM.** `mem_limit: 4g` is set on the gateway. Raise it (and Docker
Desktop → Settings → Resources) if needed. Running only the gateway already
removes most of the pressure that caused the old exit-137 crashes.
