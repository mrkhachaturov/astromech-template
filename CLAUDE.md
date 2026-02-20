# Astromech Project Instructions

> **Self-hosted AI droid fleet powered by [OpenClaw](https://github.com/openclaw/openclaw)**
>
> Multi-agent system with Telegram/Alice channels, TTS voices, and automation skills.

---

## 🚧 Project Status: Active Restructuring

This project is undergoing **major infrastructure reorganization**. Directory structure, Docker setup, and configuration paths are being migrated to a new architecture.

---

## ✅ Current Active Structure

### Core Directories

#### `.openclaw/`
**NEW: Primary OpenClaw gateway directory**
- This directory is mounted into the OpenClaw gateway container
- Contains runtime configuration, skills, identities, and agent workspaces
- **This is the main working directory for the gateway**
- **Config split:** `openclaw.json` uses `$include` to import modular configs from `config/*.json5`
  - Main file = gateway infrastructure only
  - Modular files = auth, logging, agents, channels, memory, skills, plugins, etc.

#### `compose/`
**Docker Compose stack**
- Contains individual service compose files (`*.yml`)
- Root `docker-compose.yml` uses `include` directive to glob all files in this directory
- Each service gets its own compose file for modularity

#### `dockerfiles/`
**Docker image definitions**
- Contains Dockerfiles for:
  - OpenClaw gateway (custom image with jira-cli, todoist, jq, rg, just)
  - Sandbox containers
  - Other service images
- Images built here are referenced in compose files

#### `data/`
**Persistent data for bind mounts**
- Used for container volumes and bind mounts
- Subdirectories created per-service as needed
- Keeps persistent data organized outside containers

#### `tools/wiki/`
**OpenClaw knowledge base (vector DB)**
- ✅ **WORKING** - fully functional
- Self-updating vector database for OpenClaw documentation and source code
- Use via justfile commands (see below)
- Associated skill: `.claude/skills/wiki-search/SKILL.md`

#### `.just/`
**Justfile modules (sub-recipes)**
- **`wiki.just`** — ✅ **VERIFIED** - working correctly
- Other modules (`openclaw.just`, `firewall.just`, `secrets.just`, `tts.just`, `git.just`) — ⚠️ **need restructuring/verification** (may have incorrect paths)

#### `justfile` (root)
**Main task runner**
- ✅ Wiki-related recipes are **current and working**
- ⚠️ Other recipes may need path corrections due to restructuring

#### `docs/`
**Project documentation**
- Will contain architecture, deployment guides, and design docs
- Currently being populated during restructuring

---

### ⚠️ Requires Adaptation

#### `tools/manage-secrets` + `secrets/`
- **Status:** May have outdated file paths
- **Reason:** Many directories renamed/moved during restructuring
- **Action:** Verify paths before using

#### `tools/cleanup-voice-messages.sh`
- **Status:** May be removed in future
- **Action:** Consult user before relying on this

---

## 🗑️ Temporary/Deprecated Directories

**DO NOT use these by default** — they will be deleted after restructuring:

| Directory | Status | Notes |
|-----------|--------|-------|
| `archive/` | Old structure | Previous runtime/, configs, docs — **do not reference** |
| `references/` | Example code | Public GitHub example for Docker setup — temporary reference |
| `templates/` | To be moved | Will migrate to other directories, then deleted |
| `openclaw/` (no dot) | Temporary | Will be removed (content moving to `.openclaw/`) |

**Default behavior:**
- ❌ Do NOT search or reference these directories
- ❌ Do NOT use old patterns from archive/ for new code
- ❌ These are NOT production directories

**Exception:**
- ✅ User may explicitly ask to check archive/ for historical context
- ✅ Use only when user specifically requests it

---

## 📝 Special Notes

### README.md
- **Conceptually accurate** — project vision and goals are correct
- **Details outdated** — file paths, structure, setup instructions need updating
- **Action:** Will be rewritten after restructuring completes

---

## 🔧 Key Commands

### Wiki (OpenClaw knowledge base)
For OpenClaw questions, query the wiki using justfile commands:
- `just wiki-docs "question"` — configuration, features, setup
- `just wiki-code "question"` — implementation details

**Full command reference:** `.claude/skills/wiki-search/SKILL.md`

### Other Commands
⚠️ **Other justfile recipes are under review** — verify paths before using.

---

## 🎯 OpenClaw Integration

**For OpenClaw questions**, use the wiki:
- Configuration → `just wiki-docs "question"`
- Implementation → `just wiki-code "question"`
- Skills → `.claude/skills/wiki-search/SKILL.md`

**Wiki stats:**
- 10,447 chunks indexed
- 2,672 files from OpenClaw source
- Auto-syncs with upstream releases

---

## 🏗️ Architecture Overview

```
Docker Compose Stack (include-based)
├── OpenClaw Gateway (.openclaw/ mounted)
│   ├── Agents (personal, business)
│   ├── Skills (Jira, Todoist, TTS, etc.)
│   └── Channel bindings (Telegram, Alice)
├── Sidecars
│   ├── Alice adapter (WebSocket)
│   ├── SpeechKit TTS (mood-based R2D2 voices)
│   └── Edge TTS processor
└── Infrastructure
    ├── Docker socket proxy
    └── Secrets (1Password integration)
```

---

## 🚀 Work In Progress

This CLAUDE.md will be expanded as restructuring progresses. Current focus:
1. ✅ Wiki integration (complete)
2. 🚧 Docker compose modularization (in progress)
3. 🚧 `.openclaw/` directory structure (in progress)
4. ⏳ Justfile recipe verification (pending)
5. ⏳ Comprehensive architecture docs (pending)

---

**Last updated:** 2026-02-15 (restructuring phase)
