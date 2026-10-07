# AwardsVoter-Ex — System & Architecture Overview

## Table of Contents

1. [Purpose](#purpose)
2. [High-Level Architecture](#high-level-architecture)
3. [Technology Stack](#technology-stack)
4. [Application Structure](#application-structure)
5. [OTP Supervision Tree](#otp-supervision-tree)
6. [Data Layer](#data-layer)
7. [Context Layer (Business Logic)](#context-layer-business-logic)
8. [Web Layer](#web-layer)
9. [Real-Time Communication](#real-time-communication)
10. [Asset Pipeline](#asset-pipeline)
11. [Deployment](#deployment)
12. [Development Tooling](#development-tooling)

---

## Purpose

**AwardsVoter-Ex** is an Elixir/Phoenix web application for hosting friendly awards prediction competitions. Users fill out a ballot predicting winners across categories for a real award show (Grammys, Emmys, VMAs, Billboard Awards, etc.), and then watch a live scoreboard update in real time as winners are announced. Admins manage shows and record winners through a separate admin interface.

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Browser                          │
│                                                         │
│   Phoenix LiveView (WebSocket)    HTTP (standard reqs)  │
└────────────┬───────────────────────────┬────────────────┘
             │                           │
             ▼                           ▼
┌─────────────────────────────────────────────────────────┐
│              Phoenix Application (Elixir/OTP)           │
│                                                         │
│  ┌───────────────┐   ┌───────────────────────────────┐  │
│  │   Web Layer   │   │       Context Layer            │  │
│  │               │   │                               │  │
│  │  Endpoint     │   │  Admin context                │  │
│  │  Router       │◀──│  Ballots context              │  │
│  │  Controllers  │   │                               │  │
│  │  LiveViews    │   │  ┌───────────┐ ┌───────────┐  │  │
│  │  Views        │   │  │ ShowTable │ │BallotTable│  │  │
│  └───────────────┘   │  │ (GenSrv)  │ │ (GenSrv)  │  │  │
│                      │  └─────┬─────┘ └─────┬─────┘  │  │
│                      │        │              │        │  │
│                      │  ┌─────▼──────────────▼─────┐  │  │
│                      │  │    DETS (on-disk store)   │  │  │
│                      │  └──────────────────────────┘  │  │
│                      │                               │  │
│                      │  ┌────────────────────────┐   │  │
│                      │  │  BackupServer (GenSrv)  │   │  │
│                      │  │  (optional, hourly S3)  │   │  │
│                      │  └────────────┬────────────┘   │  │
│                      └──────────────┼────────────────┘  │
└──────────────────────────────────── ┼──────────────────┘
                                      │
                                      ▼
                           ┌─────────────────────┐
                           │   AWS S3             │
                           │  awards-voter-backups│
                           │  (DETS file backups) │
                           └─────────────────────┘
```

---

## Technology Stack

### Backend

| Component             | Technology                  | Version    |
|-----------------------|-----------------------------|------------|
| Language              | Elixir                      | ~> 1.7     |
| Runtime               | Erlang/OTP                  |            |
| Web Framework         | Phoenix                     | ~> 1.5.4   |
| Real-time UI          | Phoenix LiveView            | ~> 0.13.0  |
| HTML helpers          | Phoenix HTML                | ~> 2.11    |
| Data validation       | Ecto (embedded schemas)     | ~> 3.x     |
| On-disk storage       | DETS (Erlang stdlib)        |            |
| Match specs           | ex2ms                       | ~> 1.0     |
| File storage client   | ex_aws + ex_aws_s3          | ~> 2.x     |
| HTTP client           | Hackney                     | ~> 1.9     |
| JSON codec            | Jason                       | ~> 1.0     |
| XML parsing           | sweet_xml                   | ~> 0.6     |
| Timezone support      | TZ                          | ~> 0.12.0  |
| Metrics               | telemetry / telemetry_metrics / telemetry_poller | ~> 0.4 |
| Dev dashboard         | Phoenix LiveDashboard       | ~> 0.2     |
| Web server            | Plug + Cowboy               | ~> 2.0     |

### Frontend

| Component        | Technology               | Version   |
|------------------|--------------------------|-----------|
| Real-time UI     | Phoenix LiveView (client)| ~> 0.13   |
| CSS framework    | Tailwind CSS             | ^2.0      |
| Tailwind plugins | @tailwindcss/forms, @tailwindcss/typography | ^0.2–0.3 |
| CSS processing   | PostCSS + Autoprefixer   | ^8.x      |
| Bundler          | Webpack                  | 4.41.5    |
| JS transpiler    | Babel                    | ^7.12     |
| Progress bar     | NProgress                | ^0.2.0    |
| Firebase SDK     | Firebase JS              | ^8.2.9    |

---

## Application Structure

```
lib/
├── context.ex                          # AwardsVoter.Context namespace entry
├── context/
│   ├── application.ex                  # OTP Application + supervision tree
│   ├── admin.ex                        # Admin context (show management)
│   ├── ballots.ex                      # Ballots context (voter ballot management)
│   ├── models/
│   │   ├── show.ex                     # Ecto embedded schema: Show
│   │   ├── category.ex                 # Ecto embedded schema: Category
│   │   ├── contestant.ex               # Ecto embedded schema: Contestant
│   │   ├── ballot.ex                   # Ecto embedded schema: Ballot
│   │   └── vote.ex                     # Ecto embedded schema: Vote
│   └── tables/
│       ├── show_table.ex               # GenServer: DETS-backed show store
│       ├── ballot_table.ex             # GenServer: DETS-backed ballot store
│       └── backup_server.ex            # GenServer: hourly S3 backup of DETS files
│
├── web.ex                              # AwardsVoter.Web namespace entry
└── web/
    ├── endpoint.ex                     # Phoenix Endpoint (HTTP + WebSocket)
    ├── router.ex                       # Route definitions
    ├── telemetry.ex                    # Telemetry metrics setup
    ├── channels/
    │   └── user_socket.ex              # Phoenix socket
    ├── controllers/
    │   ├── admin_controller.ex         # Show CRUD, JSON upload
    │   └── ballot_controller.ex        # Home page, ballot lookup
    ├── live/
    │   ├── new_ballot/
    │   │   └── ballot_new.ex           # LiveView: create a ballot
    │   ├── edit_ballot/
    │   │   └── ballot_edit.ex          # LiveView: edit a ballot (cast votes)
    │   ├── compre_ballots/
    │   │   └── ballot_compare.ex       # LiveView: side-by-side ballot comparison
    │   ├── summaries/
    │   │   ├── ballots_summary.ex      # LiveView: all ballots summary for a show
    │   │   └── ballots_scoreboard.ex   # LiveView: ranked real-time scoreboard
    │   ├── view_show/
    │   │   ├── admin_show_details.ex   # LiveView: admin show details
    │   │   ├── admin_category_details.ex
    │   │   └── admin_contestant_details.ex
    │   └── edit_show/
    │       ├── admin_show_edit.ex      # LiveView: admin edit show
    │       ├── edit_show_details_component.ex
    │       ├── edit_category_details_component.ex
    │       └── edit_contestant_details_component.ex
    ├── views/
    │   ├── admin_view.ex
    │   ├── ballot_view.ex
    │   ├── summaries_view.ex           # Helpers: num_correct/2, num_voted/1
    │   ├── layout_view.ex
    │   ├── error_view.ex
    │   └── error_helpers.ex
    └── templates/
        ├── layout/                     # root.html.leex, live.html.leex, app.html.eex
        ├── ballot/                     # home_page, get_ballot, new_ballot, edit_ballot, compare_ballots
        ├── admin/                      # index, view_show/*, edit_show/*
        └── summaries/                  # ballots_summary, scoreboard
```

---

## OTP Supervision Tree

```
AwardsVoter.Context.Application  (strategy: :one_for_one)
│
├── AwardsVoter.Context.Tables.ShowTable      ← GenServer wrapping DETS show store
│                                                (restart: :transient)
│
├── AwardsVoter.Context.Tables.BallotTable    ← GenServer wrapping DETS ballot store
│                                                (restart: :transient)
│
├── AwardsVoter.Context.Tables.BackupServer   ← GenServer for hourly S3 backup
│   (only started when :run_backups = true)      (restart: :transient)
│
├── AwardsVoter.Web.Telemetry                 ← Telemetry supervisor
│
├── {Phoenix.PubSub, name: AwardsVoter.PubSub} ← In-memory pub/sub bus
│
└── AwardsVoter.Web.Endpoint                  ← HTTP + WebSocket server (Cowboy)
```

DETS table GenServers are started before the web endpoint so they are available when the first request arrives. Each GenServer serialises access to its underlying `:dets` file.

---

## Data Layer

### Storage: DETS (not PostgreSQL)

Despite `postgrex` and `phoenix_ecto` being present in `mix.exs`, **the application does not use a PostgreSQL database**. `AwardsVoter.Repo` is commented out in the supervision tree. All persistent state is stored in **DETS** (Erlang's Disk-based External Term Storage) — two on-disk binary files:

| File              | Table name (config)  | Contents         |
|-------------------|----------------------|------------------|
| `show.dets`       | `:show` (prod)       | All award shows  |
| `ballot.dets`     | `:ballot` (prod)     | All voter ballots|

Ecto is used purely for **embedded schema definitions and changeset validation** — no database migrations or queries.

### Data Models

All schemas use `embedded_schema` (in-memory only, no DB table). The full object graph is serialised directly into DETS.

```
Show
├── id            : UUID (binary_id, manual)
├── name          : string  (required)
├── description   : string
├── air_datetime  : string  (ISO 8601)
├── voting_enabled? : boolean (default: false)
└── categories[]  : [Category]
      ├── id           : UUID
      ├── name         : string (required)
      ├── description  : string
      ├── winner       : Contestant | nil
      └── contestants[]: [Contestant]
            ├── id            : UUID
            ├── name          : string (required)
            ├── description   : string
            ├── image_url     : string
            ├── youtube_url   : string
            ├── spotify_url   : string
            ├── wiki_url      : string
            └── billboard_stats : string

Ballot
├── id          : UUID (auto-generated)
├── voter       : string (required) — voter's display name
├── ballot_name : string (required)
├── show_id     : string (required) — foreign key into ShowTable
└── votes[]     : [Vote]
      ├── id         : UUID
      ├── category   : Category (embedded snapshot)
      └── contestant : Contestant (embedded snapshot)
```

Because votes embed a snapshot of the `Category` and `Contestant` at time of voting, `Vote.is_winning_vote?/1` can determine correctness by comparing the embedded category's `winner` field to the voted `contestant`.

### S3 Backup

`BackupServer` runs on a `:one_hour` timer and uploads the raw `.dets` files to the `awards-voter-backups` S3 bucket (us-east-2). On startup, if a DETS file is missing or suspiciously small (≤ 5,464 bytes), it downloads the latest backup from S3 before opening the table. Files are organised under `prod/` or `dev/` S3 prefixes.

---

## Context Layer (Business Logic)

### `AwardsVoter.Context.Admin`

Handles all show management operations:

| Function | Description |
|---|---|
| `get_all_shows/0` | Returns all shows from ShowTable |
| `get_show_by_id/1` | Fetches a single show by UUID |
| `create_show/1` | Validates, assigns UUID, saves to ShowTable |
| `save_show/1` | Upserts an existing Show struct |
| `delete_show/1` | Removes a show by UUID |
| `set_category_winner/3` | Updates a category's winner within a show |
| `update_show_category/3` | Replaces a category's data within a show |
| `update_show_contestant/4` | Replaces a contestant's data within a show |
| `add_show_category/2` | Adds a new category to a show |
| `add_show_contestant/3` | Adds a contestant to a show's category |
| `remove_category_from_show/2` | Removes a category from a show |
| `remove_contestant_from_show/3` | Removes a contestant from a category |

### `AwardsVoter.Context.Ballots`

Handles all voter ballot operations:

| Function | Description |
|---|---|
| `create_ballot/1` | Validates, assigns UUID, saves to BallotTable |
| `get_ballot/1` | Fetches ballot by UUID |
| `save_ballot/1` | Upserts an existing Ballot struct |
| `find_ballot_by_voter_and_show/2` | Finds ballot by voter name + show ID |
| `fetch_ballots_for_show/1` | Returns all ballots for a given show |
| `count_correct_votes/1` | Counts votes matching the category winner |
| `create_vote/1` | Creates a Vote struct from a params map |

---

## Web Layer

### Routes

```
GET  /                              → BallotController.home
GET  /ballots/:id                   → BallotController.get_ballot
live /ballots/:show_id/new          → BallotNew
live /ballots/:id/edit              → BallotEdit
live /ballots/:first/:second        → BallotCompare
live /show/:id/scoreboard           → Scoreboard
live /show/:id/summary              → BallotsSummary

GET    /admin/                      → AdminController.admin_index (→ /admin/shows)
GET    /admin/shows                 → AdminController.list_shows
GET    /admin/shows/:id             → AdminController.get_show
live   /admin/shows/:id/edit        → AdminShowEdit
DELETE /admin/shows/:id             → AdminController.delete_show
POST   /admin/shows/json            → AdminController.upload_show_json

GET /dashboard                      → Phoenix.LiveDashboard (dev/test only)
```

### LiveViews and Their Responsibilities

| LiveView | Route | Purpose |
|---|---|---|
| `BallotNew` | `/ballots/:show_id/new` | Select voter name, create ballot |
| `BallotEdit` | `/ballots/:id/edit` | Cast/update votes per category |
| `BallotCompare` | `/ballots/:a/:b` | Side-by-side comparison of two ballots |
| `BallotsSummary` | `/show/:id/summary` | All ballots for a show; updates live on `winner_updated` / `ballot_updated` PubSub events |
| `Scoreboard` | `/show/:id/scoreboard` | Ranked leaderboard sorted by correct picks; live updates; time-gated to show air time |
| `AdminShowEdit` | `/admin/shows/:id/edit` | Full edit of show, categories, and contestants |
| `AdminShowDetails` | rendered via controller | Read-only admin view of show details |
| `AdminCategoryDetails` | component | Admin view of a single category |
| `AdminContestantDetails` | component | Admin view of a single contestant |

### Admin: Show Import via JSON

An admin can upload a structured JSON file to `POST /admin/shows/json` to bulk-create a show with all categories and contestants. Seed JSON files for several real shows are in `scripts/`:

- `grammys.json` — 62nd Grammy Awards
- `2020_emmys.json`
- `2020_vmas.json`
- `2020_billboard_awards.json`

Alternatively, `scripts/import_show_json.exs` can be run as a Mix script.

---

## Real-Time Communication

### Phoenix PubSub

Both the `BallotsSummary` and `Scoreboard` LiveViews subscribe to a per-show topic on mount:

```elixir
AwardsVoter.Web.Endpoint.subscribe("show:#{show_id}")
```

Events published on this topic:

| Event | Trigger | Handler behaviour |
|---|---|---|
| `winner_updated` | Admin sets a category winner | Re-fetches the show, re-renders category states |
| `ballot_updated` | Voter submits or edits a ballot | Re-fetches all ballots, re-sorts scoreboard |

This creates a fully real-time experience: as the award show progresses and the admin marks winners, all connected viewers' scores update instantly without a page refresh.

### Scoreboard Time-Gating

The `Scoreboard` LiveView hides individual ballot picks until the show's `air_datetime` passes (with a 10-minute buffer). This prevents voters from gaming their selections after results start being announced.

---

## Asset Pipeline

```
assets/
├── js/
│   └── app.js              # Entry point — Phoenix socket, LiveView, NProgress, Firebase
├── css/
│   └── phoenix.css         # Milligram base styles + custom layout overrides
├── tailwind.config.js      # Tailwind config with Forms + Typography plugins
├── postcss.config.js       # Autoprefixer
├── webpack.config.js       # Build config (see below)
└── .babelrc                # Babel preset-env config
```

Webpack bundles `assets/js/app.js` (plus any `vendor/*.js` files) into `priv/static/js/app.js`. CSS is extracted by `MiniCssExtractPlugin` into `priv/static/css/app.css`. Static files from `assets/static/` are copied directly to `priv/static/`.

| Command | Effect |
|---|---|
| `npm run watch` | Webpack dev mode with file watching |
| `npm run deploy` | Webpack production mode (minified) |
| `mix phx.digest` | Fingerprints static assets for cache-busting (production) |

---

## Deployment

The application is deployed to **Gigalixir** and served at `awards.akosua.xyz` over HTTPS (port 443, forced SSL with HSTS).

### Buildpacks (`.buildpacks`)

```
https://github.com/HashNuke/heroku-buildpack-elixir
https://github.com/gjaldon/heroku-buildpack-phoenix-static
https://github.com/gigalixir/gigalixir-buildpack-releases.git
```

1. **heroku-buildpack-elixir** — compiles the Elixir application
2. **heroku-buildpack-phoenix-static** — runs `npm install` and `npm run deploy` in `assets/`
3. **gigalixir-buildpack-releases** — packages the app as an OTP release

### Production Notes

- `run_backups: true` is set in the base config (overridable per environment); the `BackupServer` starts and handles hourly S3 uploads automatically.
- DETS files are stored on the Gigalixir node's local disk; S3 backups guard against data loss on container restarts.
- No PostgreSQL instance is required in production.

---

## Development Tooling

| Tool | Purpose |
|---|---|
| `credo` | Elixir code linting and style analysis (`.credo.exs`) |
| `dialyxir` | Static type analysis via Dialyzer |
| `ex_machina` | Test/dev data factories for Ecto schemas |
| `floki` | HTML parsing in tests |
| `phoenix_live_reload` | Hot-reload templates, JS, and CSS in dev |
| `mix setup` | `deps.get` + `npm install` in assets/ |
| `mix test --no-start` | Run ExUnit tests without starting the OTP app |
| `.iex.exs` | IEx session helpers for interactive development |
| `.tool-versions` | asdf version pinning for Elixir/Erlang/Node |
