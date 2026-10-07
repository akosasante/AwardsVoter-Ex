# AwardsVoter-Ex — Upgrade Plan

> Written: March 2026  
> Context: Returning to this project after ~5 years. The app last ran in production circa Sep 2020.  
> Immediate goal: Get the Oscars 2026 running on Gigalixir tonight (see [Tonight's Checklist](#tonights-checklist-oscars-2026)).  
> Longer-term goal: Modernise the stack and move to a sustainable, low-maintenance deployment.

---

## Table of Contents

1. [Tonight's Checklist (Oscars 2026)](#tonights-checklist-oscars-2026)
2. [Phase 1 — Foundation & Security](#phase-1--foundation--security)
3. [Phase 2 — Storage Migration (DETS → SQLite)](#phase-2--storage-migration-dets--sqlite)
4. [Phase 3 — Deployment Migration (Gigalixir → DO + Docker)](#phase-3--deployment-migration-gigalixir--do--docker)
5. [Phase 4 — Framework Modernisation (Phoenix 1.5 → 1.7+)](#phase-4--framework-modernisation-phoenix-15--17)
6. [Phase 5 — Feature & UX Improvements](#phase-5--feature--ux-improvements)
7. [What to Skip / Not Worth Doing](#what-to-skip--not-worth-doing)

---

## Tonight's Checklist (Oscars 2026)

Keep existing stack (DETS + S3 + Gigalixir). Minimum viable changes to get a working deploy.

- [ ] **Update `elixir_buildpack.config`** to match `.tool-versions`:
  ```
  elixir_version=1.16.3
  erlang_version=26.2.5
  ```
- [ ] **Update `phoenix_static_buildpack.config`** — node `11.0.0` is ancient; use `18.x`:
  ```
  node_version=18.20.0
  ```
- [ ] **Create `scripts/oscars_2026.json`** with this year's nominees (all categories, contestant names, descriptions, image URLs). Follow the same shape as `scripts/grammys.json`.
- [ ] **Verify Gigalixir git remote is set**: `git remote -v` — should show `gigalixir` pointing to `https://git.gigalixir.com/awards-voter.git`; if not, add it.
- [ ] **Push and deploy**: `git push gigalixir main`
- [ ] **Log in to admin** at `awards.akosua.xyz/admin/shows/json`, upload `oscars_2026.json`
- [ ] **Enable voting** on the show (`voting_enabled?: true`) via the admin edit UI
- [ ] **Set `air_datetime`** on the show so the scoreboard time-gate works correctly

**Known risk:** If the DETS files in Gigalixir's ephemeral storage are missing/empty on first boot, `BackupServer` will attempt to download from S3. The S3 bucket is `awards-voter-backups`. Verify the bucket still exists and the IAM credentials in Gigalixir config are still valid before the show starts.

---

## Phase 1 — Foundation & Security

Low-risk, high-value changes. Do these before the next major event regardless of other phases.

### 1.1 — Fix the hardcoded `SECRET_KEY_BASE`

The current value in `config/config.exs` is committed to a public GitHub repo:

```elixir
# config/config.exs — REMOVE THIS
secret_key_base: "<redacted: old key, rotated>"
```

**Fix:**
1. Add `SECRET_KEY_BASE` to Gigalixir config vars (generate with `mix phx.gen.secret`)
2. Update `config/prod.exs` to read from env:
   ```elixir
   secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
   ```
3. Add a `config/runtime.exs` for env-based config (Phoenix 1.6+ convention)

### 1.2 — Add admin authentication

`/admin/*` routes are completely open — no authentication at all. Anyone who finds the URL can create, edit, or delete shows, or mark winners.

**Options (easiest to hardest):**
- `Plug.BasicAuth` with a username/password from env vars — simplest, good enough for a private tool
- Firebase Auth check on admin routes (already have Firebase set up)
- A proper `admin_token` session approach

### 1.3 — Update GitHub Actions CI

The CI workflow uses `elixir:1.9.1-slim` and `actions/checkout@v1`. Neither is current.

```yaml
# Update to:
- uses: actions/checkout@v4
- uses: erlef/setup-beam@v1
  with:
    elixir-version: '1.16.3'
    otp-version: '26.2.5'
```

### 1.4 — Fix `run_backups` config

`run_backups: true` is set in `config/config.exs` (base config), meaning it's `true` in all environments unless overridden. It's only explicitly set to `false` in dev and test. This is fine for now but fragile — the base config should default to `false` and production should opt in explicitly.

---

## Phase 2 — Storage Migration (DETS → SQLite)

**Why:** DETS is operationally fragile — data is serialized with Elixir module atoms, so any module rename or struct change silently breaks deserialization (as happened with the 2020 → current codebase). SQLite gives you proper schema migrations, standard Ecto queries, and a single portable file.

**Why not PostgreSQL:** Overkill for this app. SQLite is sufficient for tens of thousands of records, simpler to deploy (no separate DB service), and can be backed up the same way as DETS files currently are.

### 2.1 — Add `ecto_sqlite3`

```elixir
# mix.exs
{:ecto_sqlite3, "~> 0.15"}
```

Uncomment `AwardsVoter.Repo` in `application.ex` and `config/dev.exs`. Add SQLite config:

```elixir
config :awards_voter, AwardsVoter.Repo,
  database: "priv/awards_voter.db",
  pool_size: 5
```

### 2.2 — Write Ecto migrations

Replace embedded schemas with proper database-backed schemas. The data model maps cleanly:

```
shows          — id (uuid), name, description, air_datetime, voting_enabled
categories     — id (uuid), show_id (fk), name, description, order_index
contestants    — id (uuid), category_id (fk), name, description, image_url,
                 youtube_url, spotify_url, wiki_url, billboard_stats
ballots        — id (uuid), voter (firebase_uid), ballot_name, show_id (fk), inserted_at
votes          — id (uuid), ballot_id (fk), category_id (fk), contestant_id (fk)
winners        — category_id (fk), contestant_id (fk)  [or winner_id column on categories]
```

Note: `Vote` currently embeds a full snapshot of `Category` and `Contestant` at vote time. With proper foreign keys, `is_winning_vote?` becomes a join query instead — simpler and more correct.

### 2.3 — Replace GenServer table modules

`ShowTable` and `BallotTable` GenServers exist purely to serialise access to DETS. With SQLite + Ecto, they go away entirely. All context functions (`Admin`, `Ballots`) call `Repo` directly.

### 2.4 — Replace S3 backup with Cloudflare R2

`ex_aws_s3` can stay — R2 has an S3-compatible API. Change `BackupServer` to:
- Back up the SQLite `.db` file instead of DETS `.dets` files
- Point to R2 endpoint instead of AWS S3 (free up to 10GB, no egress fees)
- Or drop `BackupServer` entirely if deploying to DO with a Docker volume (the file persists across restarts)

### 2.5 — Data migration script

The existing DETS data on the production S3 bucket uses old module paths (`Elixir.AwardsVoter.Context.Admin.Shows.Show` etc.) and **cannot be loaded by the current codebase**. Options:
- **Start fresh** — acceptable since shows can be re-imported from JSON scripts
- **Manual reconstruction** — read the DETS binary with the old module names loaded (requires temporarily reverting module names), export to JSON, re-import

---

## Phase 3 — Deployment Migration (Gigalixir → DO + Docker)

**Why:** Gigalixir's free tier is limited, ephemeral storage means DETS files don't survive restarts (hence the S3 backup complexity), and you already have infrastructure and a proven Docker deploy pattern on your DO droplet from TradeMachineEx.

**Target:** `akosua-general-dev` DO droplet, same approach as TradeMachine — Docker image → GHCR → SSH deploy via GitHub Actions.

### 3.1 — Write a `Dockerfile`

Multi-stage build: builder stage compiles Elixir + assets, runtime stage is a minimal image with the OTP release. Reference the TradeMachineEx `Dockerfile`.

Key differences from TradeMachine:
- No PostgreSQL service needed (SQLite is in the image/volume)
- Mount a Docker volume at `/app/priv/` so the SQLite file persists across container restarts
- No database migrations to run on startup (or a simple `Repo.migrate()` in application startup)

### 3.2 — Write GitHub Actions deploy workflow

Copy the TradeMachineEx `deploy.yml` pattern:
- Build Docker image on push to `main` → push to GHCR
- SSH to DO droplet → `docker pull` → `docker compose up -d`
- Health check + rollback on failure

Required GitHub secrets to add:
- `DIGITALOCEAN_HOST`, `DIGITALOCEAN_USERNAME`, `DIGITALOCEAN_SSH_KEY`
- `SECRET_KEY_BASE`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (or R2 equivalents)

### 3.3 — `docker-compose.prod.yml`

```yaml
services:
  app:
    image: ${IMAGE_TAG}
    ports:
      - "4000:4000"
    volumes:
      - awards_data:/app/priv/data    # SQLite file lives here
    environment:
      - SECRET_KEY_BASE
      - AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  awards_data:
```

### 3.4 — Add a `/health` endpoint

Required for the Docker health check and post-deploy verification (same as TradeMachine).

```elixir
# router.ex
get "/health", HealthController, :index
```

### 3.5 — DNS cutover

Update `awards.akosua.xyz` CNAME from `awards.akosua.xyz.gigalixirdns.com` to point at the DO droplet IP. Can be done with zero downtime if TLS is set up first (Let's Encrypt via Caddy or nginx-proxy).

---

## Phase 4 — Framework Modernisation (Phoenix 1.5 → 1.7+)

**Why:** Phoenix 1.5 is from 2020. LiveView 0.13 is from the same era. The current templates use `.leex` (deprecated). Webpack + `hard-source-webpack-plugin` is replaced by `esbuild`. Many LiveView patterns have improved.

This is the biggest change and should be its own dedicated effort — **do this after Phases 1–3 are stable**.

### 4.1 — Upgrade Phoenix to 1.7+

- Phoenix 1.7 introduced `verified routes` (`~p"/path"`) replacing `Routes.x_path/2` helpers
- LiveView function components replace module-level `render/1` + separate template files (`.leex` / `.heex`)
- `Phoenix.Component` replaces `Phoenix.LiveComponent` for stateless components
- `Phoenix.HTML` form helpers updated

### 4.2 — Replace Webpack with esbuild

Phoenix 1.6+ ships with `esbuild` by default. Removes the entire `hard-source-webpack-plugin`, `babel-loader`, `mini-css-extract-plugin` chain. Significantly faster builds.

### 4.3 — Upgrade Tailwind integration

Phoenix 1.7 handles Tailwind via `tailwind` hex package (standalone CLI, no PostCSS/Node required). Removes `postcss`, `autoprefixer`, `@tailwindcss/forms` as Node deps.

### 4.4 — Migrate templates

Convert `.leex` templates to `~H` sigil-based `render/1` functions within LiveView modules, or to separate `.html.heex` files. The `.leex` format is fully removed in Phoenix 1.7.

### 4.5 — Upgrade LiveView

LiveView 0.13 → 0.20+ includes:
- `handle_params/3` improvements
- `push_navigate/2` replaces `push_redirect/2`
- Streams API for large lists (useful for scoreboard/summary views)
- `assign_new/3` signature unchanged — low migration cost here

---

## Phase 5 — Feature & UX Improvements

Nice-to-haves once the foundation is stable.

### 5.1 — Show management improvements
- **Show list on home page** should show upcoming shows, not just `voting_enabled?` ones — voters need to create their ballot before voting opens
- **Admin: duplicate show** — useful for recurring shows (Grammys, Oscars) to avoid re-uploading JSON every year
- **Show status field** — `draft | upcoming | voting_open | results_in | archived` instead of the single `voting_enabled?` boolean

### 5.2 — Ballot improvements
- `airtime_is_valid/1` is duplicated across `BallotController`, `BallotEdit`, and `Scoreboard` — centralise in a context function
- Allow voters to update their ballot name
- Show running score on the `BallotEdit` view as winners come in

### 5.3 — Contestant data quality
- `billboard_stats` field exists but appears unused in templates — audit and either wire it up or remove it
- `spotify_url` currently links to playlists rather than artist/track pages — review for accuracy

### 5.4 — Scoreboard enhancements
- Tie-breaking (currently sorts by correct picks, then total voted — could add a tiebreaker by submission time)
- Display voter's correct picks vs total picks (e.g. "7/23") alongside rank

---

## What to Skip / Not Worth Doing

- **Firebase for backend auth:** Firebase Auth works fine as a client-side voter identity mechanism. Adding Firebase Admin SDK to verify tokens server-side adds complexity with minimal gain for a private tool — `Plug.BasicAuth` for admin is sufficient.
- **PostgreSQL:** SQLite is genuinely enough here. Resist the urge to add a DB service.
- **Full test coverage rewrite:** The existing tests cover basic DETS table logic. Writing comprehensive tests for new SQLite-backed contexts is worthwhile, but don't block upgrades waiting for 100% coverage.
- **The old DO DETS data:** The `ballots` and `shows` files at `/opt/Apps/awards_predictor` use old module namespaces and cannot be loaded by the current code. Don't try to migrate them — re-import shows from JSON and accept that 2020 ballot history is lost.
