# 🎛️ Yayo Studio

**Creative Project Hub** — one dashboard for every project you're juggling. Games, music, code, writing, art — tracked, journaled, and wired straight into your AI toolchain.

Rails 8 · Hotwire · PostgreSQL · synthwave-84 by default 🌆

## What It Does

- **🗂 Projects, typed** — 10 built-in project types (🎮 Game, 🎵 Music, 💻 Code, ✍️ Writing, 🎨 Art, 🎯 Design, 🔧 System, 🎬 Video, 🤖 AI, 📁 Other), each with its own icon/color, ordered however you like
- **📓 Per-project journal** — timestamped entries with full-text search, right where the work lives
- **🗃 Asset tracking** — attach files/links to projects
- **🏷 Tags** — cross-project organization
- **🎨 Themes** — multiple UI themes (default: `synthwave-84`), switchable per user
- **🤖 AI harness discovery** — auto-detects locally installed AI CLIs and agent frameworks (Claude Code, Codex, OpenCode, OpenClaw, Aider, Copilot, Goose, Mentat, Hermes, and more via `HarnessRegistry`), connects them to projects, health-checks them, and launches them in-project
- **🔐 Auth** — sessions + registration

## Quick Start

```bash
# PostgreSQL running locally (or docker):
#   docker run -d -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 postgres:17-alpine

bundle install
bin/rails db:prepare   # creates, migrates, seeds (types, themes, demo user)
bin/rails server       # http://localhost:3000
```

If Postgres isn't on a local socket, point at it:

```bash
PGHOST=localhost PGUSER=yayo bin/rails db:prepare
```

## Testing

```bash
PGHOST=localhost PGUSER=yayo bin/rails test   # 83 tests
```

## Architecture

```
app/
├── models/          # Project, ProjectType, JournalEntry, Asset, Tag,
│                    # Theme, User, AiIntegration
├── controllers/     # dashboard, projects, journal_entries, assets,
│                    # ai_integrations, themes, sessions, registrations
└── javascript/      # importmap + Stimulus
lib/
└── harness_registry.rb   # AI CLI/agent discovery, per-harness launch
```

Seeds create the 10 project types, themes, a demo user, and auto-discovered
AI harness connections (detected from your `$PATH`).

## License

Apache-2.0 — see [LICENSE](LICENSE)

Made by synth with synthclaw
