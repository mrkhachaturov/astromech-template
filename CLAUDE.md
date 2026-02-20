# Astromech

> Self-hosted AI droid fleet powered by [OpenClaw](https://github.com/openclaw/openclaw)

---

## Structure

```
.openclaw/          # OpenClaw gateway directory (mounted into container)
├── openclaw.json   # Main config entry point ($include → config/*.json5)
├── config/         # Modular config files (auth, channels, agents, skills…)
├── hooks/          # Global hooks (e.g. memory injection)
├── skills/         # Global skills (e.g. globalmemory)
└── workspace-*/    # One directory per agent
    ├── SOUL.md     # Agent personality and purpose
    ├── IDENTITY.md # Agent system prompt identity
    ├── AGENTS.md   # Fleet-level shared instructions
    ├── TOOLS.md    # Available tools
    ├── HEARTBEAT.md # Heartbeat behavior
    ├── USER.md     # About you (fill this in)
    ├── MEMORY.md   # Agent long-term memory (auto-written)
    ├── config/     # Workspace config (mcporter.json, etc.)
    └── skills/     # Workspace-level skills

compose/            # Docker Compose services
dockerfiles/        # Docker image definitions
data/               # Persistent container data (gitignored)
.env                # Your secrets (copy from .env.example, gitignored)
```

---

## Getting Started

1. Copy `.env.example` → `.env` and fill in your values
2. Edit `.openclaw/workspace-*/USER.md` — tell each agent about yourself
3. Review `.openclaw/config/*.json5` — configure channels, agents, memory
4. Run: `docker compose up -d`

---

## OpenClaw Wiki

The wiki knowledge base is available as a git submodule:

```bash
git submodule update --init
```

Then query it from the OpenClaw CLI or use the included skill.
