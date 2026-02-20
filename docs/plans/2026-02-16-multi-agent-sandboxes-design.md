# Multi-Agent Sandbox Images Design

**Date:** 2026-02-16
**Status:** Approved
**Author:** Claude (brainstorming session)

## Overview

Implement Docker Bake-based multi-agent sandbox system with per-agent Docker images, enabling independent toolset customization for each of 11 agents in the Astromech fleet.

## Goals

1. **Per-agent isolation** - Each agent gets its own sandbox image
2. **Independent customization** - Agents can have different toolsets
3. **Consistent naming** - Clear `astromech-sbx-{agent}:v{version}` pattern
4. **Build efficiency** - Parallel builds via Docker Bake
5. **Maintainability** - Separate Dockerfiles for modularity

## Architecture

### Image Naming Convention

```
astromech-sbx-{agent-id}:v{version}
```

**Rationale:**
- `sbx-` prefix prevents confusion with gateway container (`astromech-gateway`)
- Clear indication these are sandbox images
- Matches OpenClaw sandbox container naming (`astromech-sbx-agent-{id}-{hash}`)

### Agent-to-Image Mapping

| Agent ID | Sandbox Image | Initial Dockerfile | Purpose |
|----------|---------------|-------------------|---------|
| **base** | `astromech-sbx-base:v1` | `Dockerfile.base` | Build foundation (not used directly by agents) |
| **main** (Yoda) | `astromech-sbx-yoda:v1` | `Dockerfile.yoda` | Main agent with base toolset |
| **r2d2** | `astromech-sbx-r2d2:v1` | `Dockerfile.r2d2` | Development agent (Node, Python, build tools) |
| **bb8** | `astromech-sbx-bb8:v1` | `Dockerfile.bb8` | Ultra-minimal reconnaissance |
| **c3po** | `astromech-sbx-c3po:v1` | `Dockerfile.c3po` | Communication/API agent |
| **bb9e** | `astromech-sbx-bb9e:v1` | `Dockerfile.bb9e` | New agent (base toolset) |
| **cb23** | `astromech-sbx-cb23:v1` | `Dockerfile.cb23` | New agent (base toolset) |
| **r5d4** | `astromech-sbx-r5d4:v1` | `Dockerfile.r5d4` | New agent (base toolset) |
| **r4p17** | `astromech-sbx-r4p17:v1` | `Dockerfile.r4p17` | New agent (base toolset) |
| **d0** | `astromech-sbx-d0:v1` | `Dockerfile.d0` | New agent (base toolset) |
| **l337** | `astromech-sbx-l337:v1` | `Dockerfile.l337` | New agent (base toolset) |
| **k2s0** | `astromech-sbx-k2s0:v1` | `Dockerfile.k2s0` | New agent (base toolset) |

### Dockerfile Structure

**Approach: Separate Dockerfiles with Base Image Inheritance**

```
dockerfiles/sandboxes/
├── Dockerfile.base    # Foundation image (debian:bookworm-slim + common tools)
├── Dockerfile.yoda    # FROM astromech-sbx-base:v1 + yoda-specific tools
├── Dockerfile.r2d2    # FROM astromech-sbx-base:v1 + dev stack
├── Dockerfile.bb8     # FROM astromech-sbx-base:v1 + minimal
├── Dockerfile.c3po    # FROM astromech-sbx-base:v1 + API/protocol tools
├── Dockerfile.bb9e    # FROM astromech-sbx-base:v1 (empty initially)
├── Dockerfile.cb23    # FROM astromech-sbx-base:v1 (empty initially)
├── Dockerfile.r5d4    # FROM astromech-sbx-base:v1 (empty initially)
├── Dockerfile.r4p17   # FROM astromech-sbx-base:v1 (empty initially)
├── Dockerfile.d0      # FROM astromech-sbx-base:v1 (empty initially)
├── Dockerfile.l337    # FROM astromech-sbx-base:v1 (empty initially)
└── Dockerfile.k2s0    # FROM astromech-sbx-base:v1 (empty initially)
```

**Base Image Philosophy:**
- `Dockerfile.base` defines common tools for ALL sandboxes
- Each agent inherits `FROM astromech-sbx-base:v1`
- Agent-specific tools added in each agent's Dockerfile
- Modular: edit one agent without affecting others

**Example Dockerfile Pattern:**

```dockerfile
# Dockerfile.yoda
FROM astromech-sbx-base:v1

# Future: add yoda-specific tools here
# RUN apt-get update && apt-get install -y nodejs
```

```dockerfile
# Dockerfile.r2d2
FROM astromech-sbx-base:v1

RUN apt-get update && apt-get install -y \
    nodejs npm python3 python3-pip build-essential \
    sqlite3 vim wget

RUN curl -sSL .../jira-cli... | tar xz ...
RUN curl -sSL .../todoist... | tar xz ...
```

## Docker Bake Configuration

### File: `dockerfiles/sandboxes/docker-bake.hcl`

**Key Features:**
- Centralized build configuration for all sandbox images
- Version variable for consistent tagging
- Build groups for batch operations
- Override file support for local customization

**Structure:**

```hcl
variable "VERSION" {
  default = "1"
}

target "_common" {
  context = "../.."
  args = {
    DEBIAN_FRONTEND = "noninteractive"
  }
}

target "base" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.base"
  tags = ["astromech-sbx-base:v${VERSION}"]
}

target "yoda" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.yoda"
  tags = ["astromech-sbx-yoda:v${VERSION}"]
}

# ... (repeat for all 11 agents)

group "default" {
  targets = ["base", "yoda", "r2d2", "bb8", "c3po", "bb9e", "cb23", "r5d4", "r4p17", "d0", "l337", "k2s0"]
}

group "new-agents" {
  targets = ["yoda", "bb9e", "cb23", "r5d4", "r4p17", "d0", "l337", "k2s0"]
}

group "existing-agents" {
  targets = ["r2d2", "bb8", "c3po"]
}
```

**Build Commands:**

```bash
# Build all sandboxes
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl

# Build specific agent
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl yoda

# Build all new agents
docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl new-agents

# Build with custom version
VERSION=2 docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl
```

## Justfile Integration

### Updated `.just/sandboxes.just`

**Changes:**
- Replace `docker build` with `docker buildx bake`
- Update image name filters from `astromech-*` to `astromech-sbx-*`
- Add new build groups (new-agents, existing-agents, base-only)
- Maintain backward compatibility with existing command interface

**Key Recipes:**

```just
# Build specific agent (unchanged interface)
build agent version:
    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        {{ agent }}

# Build all sandboxes (unchanged interface)
build-all version:
    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        default

# New: Build all new agents
build-new version:
    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        new-agents

# New: Build base image only
build-base version:
    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        base
```

**User-facing commands remain the same:**

```bash
just build-sandbox yoda 1
just build-sandboxes 1
just list-sandboxes
```

## OpenClaw Configuration Changes

### `.openclaw/openclaw.json` Updates

**1. Default sandbox image:**

```jsonc
"agents": {
  "defaults": {
    "sandbox": {
      "docker": {
        "image": "astromech-sbx-base:v1",  // Changed from "astromech-base:v1"
        "containerPrefix": "astromech-sbx-"
      }
    }
  }
}
```

**2. Per-agent image configuration:**

```jsonc
// Main agent (Yoda)
{
  "id": "main",
  "name": "Yoda",  // Changed from "Main"
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-yoda:v1"
    }
  }
}

// Existing agents (update naming)
{
  "id": "r2d2",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-r2d2:v1"  // Changed from "astromech-r2d2:v1"
    }
  }
}

// New agents (add sandbox config)
{
  "id": "bb9e",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-bb9e:v1"
    }
  }
}
```

### Migration Summary

| Agent | Before | After |
|-------|--------|-------|
| main (Yoda) | `astromech-base:v1` | `astromech-sbx-yoda:v1` |
| r2d2 | `astromech-r2d2:v1` | `astromech-sbx-r2d2:v1` |
| bb8 | `astromech-bb8:v1` | `astromech-sbx-bb8:v1` |
| c3po | `astromech-c3po:v1` | `astromech-sbx-c3po:v1` |
| bb9e | *(none)* | `astromech-sbx-bb9e:v1` |
| cb23 | *(none)* | `astromech-sbx-cb23:v1` |
| r5d4 | *(none)* | `astromech-sbx-r5d4:v1` |
| r4p17 | *(none)* | `astromech-sbx-r4p17:v1` |
| d0 | *(none)* | `astromech-sbx-d0:v1` |
| l337 | *(none)* | `astromech-sbx-l337:v1` |
| k2s0 | *(none)* | `astromech-sbx-k2s0:v1` |

## Benefits

1. **Complete isolation** - Each agent can have unique toolset
2. **Independent evolution** - Update one agent's tools without affecting others
3. **Clear organization** - One Dockerfile per agent, easy to find
4. **Build efficiency** - Docker Bake parallelizes builds
5. **Version control friendly** - Small, focused diffs per agent
6. **Override support** - Local dev customizations via `docker-bake.override.hcl`
7. **Backward compatible** - Existing justfile commands work unchanged

## Trade-offs

**Chosen Approach: Separate Dockerfiles**

✅ **Pros:**
- Easier to navigate (find Dockerfile for specific agent)
- More modular (edit one agent, affect only that agent)
- Git-friendly (smaller, focused diffs)
- Clear separation of concerns

⚠️ **Cons:**
- More files to manage (12 Dockerfiles total)
- Initial duplication (new agents start with same base content)

**Rejected Approach: Single Dockerfile with multi-stage builds**

Would reduce file count but:
- Large single file (200+ lines for 11 agents)
- Harder to navigate and understand
- Larger git diffs when changing one agent
- Less modular

## Future Extensibility

**Adding a new agent:**

1. Create `Dockerfile.{agent-id}` in `dockerfiles/sandboxes/`
2. Add target to `docker-bake.hcl`
3. Add agent config to `.openclaw/openclaw.json`
4. Build: `just build-sandbox {agent-id} 1`

**Customizing an agent's toolset:**

1. Edit `dockerfiles/sandboxes/Dockerfile.{agent-id}`
2. Add `RUN apt-get install -y {tools}`
3. Rebuild: `just build-sandbox {agent-id} 2` (new version)
4. Update `.openclaw/openclaw.json` to use `v2`
5. Recreate containers: `just recreate-sandbox {agent-id}`

**Updating base toolset:**

1. Edit `dockerfiles/sandboxes/Dockerfile.base`
2. Rebuild base: `just sandboxes::build-base 2`
3. Rebuild affected agents: `just sandboxes::build-new 2`
4. Update `.openclaw/openclaw.json` image versions
5. Recreate all containers

## Migration Path

**Phase 1: Infrastructure Setup**
- Create `docker-bake.hcl`
- Update `.just/sandboxes.just` to use Bake
- Create 8 new Dockerfiles (yoda + 7 new agents)
- Update existing Dockerfiles to inherit from base

**Phase 2: Build Images**
- Build base image
- Build all agent images
- Verify image names and tags

**Phase 3: OpenClaw Configuration**
- Update `.openclaw/openclaw.json` with new image names
- Add sandbox configs for new agents
- Update main agent name to "Yoda"

**Phase 4: Testing**
- Recreate sandbox containers
- Verify each agent uses correct image
- Test adding custom tools to one agent

## Success Criteria

- [ ] All 12 images build successfully via Docker Bake
- [ ] Justfile commands work with new Bake-based system
- [ ] OpenClaw gateway uses correct sandbox images per agent
- [ ] Each agent can be customized independently
- [ ] Build performance matches or exceeds previous system
- [ ] Documentation updated (README, sandbox docs)

## Open Questions

None - design approved.

## References

- [Docker Bake Documentation](https://docs.docker.com/build/bake/)
- [OpenClaw Multi-Agent Sandbox Docs](https://github.com/openclaw/openclaw/blob/main/docs/tools/multi-agent-sandbox-tools.md)
- Existing implementation: `dockerfiles/sandboxes/README.md`
- Existing justfile: `.just/sandboxes.just`
