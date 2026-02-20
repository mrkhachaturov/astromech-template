# Astromech Sandbox Images

Per-agent Docker sandbox images for OpenClaw. Each agent can run in its own isolated container with a tailored toolset.

## Image Naming Convention

```
astromech-sbx-{agent-id}:v{version}
```

**Examples:**
- `astromech-sbx-r2d2:v1`
- `astromech-sbx-c3po:v1`
- `astromech-sbx-bb8:v1`
- `astromech-sbx-yoda:v1`

## Available Sandbox Profiles

### Base (`Dockerfile.base`)
**Purpose:** Minimal baseline for simple agents
**Toolset:**
- bash, curl, git, jq, ripgrep
- just (command runner)

**Use for:** Lightweight agents with minimal tool requirements

---

### R2D2 (`Dockerfile.r2d2`)
**Purpose:** Full development and engineering agent
**Toolset:**
- All base tools
- Node.js + npm
- Python 3 + pip + venv
- build-essential (gcc, g++, make)
- sqlite3, vim, wget
- jira-cli, todoist

**Use for:**
- Software development tasks
- Building/compiling code
- Full-stack engineering work
- Project management integration

---

### C3PO (`Dockerfile.c3po`)
**Purpose:** Communication, API, and protocol agent
**Toolset:**
- All base tools
- Node.js + npm (for API interactions)
- xmlstarlet, yq (data format processing)
- sqlite3, file, groff
- jira-cli, todoist

**Use for:**
- API integrations
- Data transformation and processing
- Communication/messaging tasks
- Ticket and task management

---

### BB8 (`Dockerfile.bb8`)
**Purpose:** Ultra-minimal reconnaissance agent
**Toolset:**
- bash, curl, jq, ripgrep, file
- just (command runner)

**Use for:**
- Read-only operations
- Data gathering and reconnaissance
- Minimal attack surface scenarios
- Public-facing agents

---

## Building Images

### Using Docker Bake (Recommended)

```bash
# Build all sandboxes
just build-sandboxes 1

# Build specific agent
just build-sandbox yoda 1

# Build all new agents
just sandboxes::build-new 1

# Build existing agents only
just sandboxes::build-existing 1

# Build base image only
just sandboxes::build-base 1
```

### Manual Build

```bash
# Build with Bake directly
VERSION=1 docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl yoda

# Build all
VERSION=1 docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl default
```

## OpenClaw Configuration

Configure per-agent sandboxes in `.openclaw/openclaw.json`:

```jsonc
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "all",
        "scope": "agent",
        "docker": {
          "image": "astromech-sbx-base:v1",
          "containerPrefix": "astromech-sbx-"
        }
      }
    },
    "list": [
      {
        "id": "main",
        "name": "Yoda",
        "workspace": "~/.openclaw/workspace",
        "sandbox": {
          "docker": {
            "image": "astromech-sbx-yoda:v1",
            "network": "bridge"
          }
        }
      },
      {
        "id": "r2d2",
        "name": "R2D2 - Engineering Droid",
        "workspace": "~/.openclaw/workspaces/r2d2",
        "sandbox": {
          "docker": {
            "image": "astromech-sbx-r2d2:v1",
            "network": "bridge"
          }
        }
      }
    ]
  }
}
```

## Version Management

### Semantic Versioning

Use semantic versioning for sandbox images:

- `v1` → Major version (breaking toolset changes)
- `v1.1` → Minor version (new tools added)
- `v1.1.1` → Patch version (tool updates, security fixes)

### Rebuilding After Updates

When you update a Dockerfile and rebuild:

```bash
# Rebuild with new version
just build-sandbox r2d2 v2

# Update OpenClaw config to use v2
# Edit .openclaw/openclaw.json: "image": "astromech-r2d2:v2"

# Recreate containers
docker exec astromech-gateway openclaw sandbox recreate --agent r2d2
```

## Security Considerations

### Network Access

- **R2D2/C3PO**: Use `"network": "bridge"` for development tools requiring internet
- **BB8**: Use `"network": "none"` for maximum isolation
- **Base**: Default is `"none"`, enable only if needed

### Workspace Access

```jsonc
{
  "sandbox": {
    "workspaceAccess": "none",  // Isolated sandbox workspace (default)
    // "workspaceAccess": "ro", // Read-only agent workspace
    // "workspaceAccess": "rw", // Full read-write access
  }
}
```

### Tool Restrictions

Combine sandboxing with tool policy:

```jsonc
{
  "tools": {
    "allow": ["read", "grep"],
    "deny": ["exec", "write", "browser"]
  }
}
```

## Docker Bake

This project uses Docker Buildx Bake for efficient multi-image builds.

### Configuration

Build configuration is defined in `dockerfiles/sandboxes/docker-bake.hcl`.

**Features:**
- Centralized build configuration
- Parallel builds
- Build groups (default, new-agents, existing-agents)
- Version variables
- Override file support

### Build Groups

```bash
# All images (default)
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl default

# New agents only
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl new-agents

# Existing agents only
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl existing-agents

# Base image only
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl base
```

### Override Files

Create `docker-bake.override.hcl` for local customizations:

```hcl
target "yoda" {
  tags = ["astromech-sbx-yoda:v2", "astromech-sbx-yoda:latest"]
}
```

Then build with:

```bash
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl \
                    -f dockerfiles/sandboxes/docker-bake.override.hcl
```

## OpenClaw Container Lifecycle

### How OpenClaw starts sandbox containers

OpenClaw **always hardcodes `sleep infinity`** as the container command when it creates sandbox containers ([source](https://github.com/openclaw/openclaw/blob/main/src/agents/sandbox/docker.ts)):

```
docker create ... <image> sleep infinity
```

This means:

- The `CMD` in your Dockerfile is **always overridden** — OpenClaw never uses it
- `CMD ["sleep", "infinity"]` in child Dockerfiles is redundant (base image provides it, and OpenClaw overrides both anyway)
- `ENTRYPOINT` **does run**, with `sleep infinity` passed as `$@`

### Implications for Dockerfile design

**Standard sandboxes** (agents that only run exec tools):
- No `CMD` needed — base image has it, OpenClaw overrides it regardless
- No `ENTRYPOINT` needed — OpenClaw execs commands directly via `docker exec`

**Sandboxes with a background daemon** (e.g. l337 running `hvault start`):
- Add an `ENTRYPOINT` that starts the daemon in the background, then `exec "$@"`:

```dockerfile
ENTRYPOINT ["entrypoint.sh"]
# entrypoint.sh:
#   hvault start &
#   exec "$@"        ← this becomes: exec sleep infinity
```

- Do **not** try to use `CMD []` or default args — `$@` will always be `sleep infinity`

### CMD in base image

`Dockerfile.base` defines `CMD ["sleep", "infinity"]` as documentation of intent and as a fallback for running the base image standalone. Child Dockerfiles do not need to repeat it.

---

## Troubleshooting

### Container Not Using New Image

```bash
# Force recreate sandbox containers
docker exec astromech-gateway openclaw sandbox recreate --agent r2d2 --force
```

### Inspect Running Container

```bash
# Find container name
docker ps | grep astromech-sbx

# Exec into container
docker exec -it astromech-sbx-agent-r2d2-<hash> bash

# Check image
docker inspect astromech-sbx-agent-r2d2-<hash> | jq '.[0].Config.Image'
```

### Debug Sandbox Configuration

```bash
# From inside gateway container
docker exec -it astromech-gateway bash
openclaw sandbox explain --agent r2d2
```

## References

- [OpenClaw Sandboxing Docs](https://github.com/openclaw/openclaw/blob/main/docs/gateway/sandboxing.md)
- [Multi-Agent Configuration](https://github.com/openclaw/openclaw/blob/main/docs/tools/multi-agent-sandbox-tools.md)
- [Security Best Practices](https://github.com/openclaw/openclaw/blob/main/docs/gateway/security.md)
