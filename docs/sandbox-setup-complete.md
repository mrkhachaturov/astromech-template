# Per-Agent Sandbox Setup - Complete ✅

The per-agent sandbox infrastructure for Astromech has been successfully implemented!

## What Was Created

### 1. Sandbox Docker Images (4 profiles)

**Location:** `dockerfiles/sandboxes/`

- ✅ **Dockerfile.base** - Minimal baseline (bash, curl, git, jq, ripgrep, just)
- ✅ **Dockerfile.r2d2** - Full development (Node.js, Python, build tools, jira-cli, todoist)
- ✅ **Dockerfile.c3po** - Communication/API (Node.js, XML/YAML processors, jira-cli, todoist)
- ✅ **Dockerfile.bb8** - Ultra-minimal (read-only operations, maximum isolation)

**Naming Convention:** `astromech-{agent-id}:v{version}`

### 2. Justfile Module

**Location:** `.just/sandboxes.just`

Complete set of recipes for building, managing, and inspecting sandbox images.

**Key Learnings:**
- Module recipes execute with working directory = module directory (`.just/`)
- Use `source_directory()` (not `justfile_directory()`) to get module's directory
- Navigate to project root with: `cd "{{source_directory()}}/.."`

### 3. Documentation

- ✅ **`dockerfiles/sandboxes/README.md`** - Comprehensive sandbox documentation
- ✅ **`docs/sandbox-quickstart.md`** - Quick start guide with examples
- ✅ **`docs/examples/sandbox-config.json5`** - Full configuration example with 3 agent types

## Available Commands

### Quick Commands
```bash
# Build specific sandbox
just build-sandbox r2d2 1

# Build all sandboxes
just build-sandboxes 1

# List profiles
just sandbox-profiles

# List built images
just list-sandboxes
```

### Full Command List
```bash
# Build & Rebuild
just sandboxes::build <agent> <version>
just sandboxes::build-all <version>
just sandboxes::rebuild <agent> <version>

# Version Management
just sandboxes::tag <agent> <old-ver> <new-ver>
just sandboxes::tag-latest <agent> <version>

# Inspection
just sandboxes::list
just sandboxes::profiles
just sandboxes::inspect <agent> <version>

# Cleanup
just sandboxes::remove <agent> <version>
just sandboxes::remove-all <agent>
just sandboxes::prune

# Gateway Integration (requires gateway running)
just sandboxes::recreate <agent>
just sandboxes::explain <agent>

# Quick Shortcuts
just sandboxes::r2d2 <version>
just sandboxes::c3po <version>
just sandboxes::bb8 <version>
just sandboxes::base <version>
```

## Next Steps

### 1. Build Initial Images

```bash
# Build version 1 of all sandboxes
just build-sandboxes 1

# Verify
just list-sandboxes
```

### 2. Configure OpenClaw

Edit `.openclaw/openclaw.json` to configure per-agent sandboxes:

```jsonc
{
  "agents": {
    "list": [
      {
        "id": "r2d2",
        "name": "R2D2 - Engineering Droid",
        "workspace": "~/.openclaw/workspaces/r2d2",
        "sandbox": {
          "mode": "all",
          "scope": "agent",
          "docker": {
            "image": "astromech-r2d2:v1",
            "network": "bridge"
          }
        }
      }
    ]
  }
}
```

**See full example:** `docs/examples/sandbox-config.json5`

### 3. Start Gateway & Verify

```bash
# Start gateway
just up-service gateway

# Verify sandbox config
just sandboxes::explain r2d2

# Test the agent (send a message via Telegram/Alice)
```

### 4. Iterate on Toolsets

As you determine what tools each agent needs:

1. Edit the Dockerfile (e.g., `dockerfiles/sandboxes/Dockerfile.r2d2`)
2. Rebuild with new version: `just build-sandbox r2d2 2`
3. Update config: `.openclaw/openclaw.json` → `"image": "astromech-r2d2:v2"`
4. Recreate containers: `just recreate-sandbox r2d2`

## Technical Details

### OpenClaw Sandbox Configuration

Per the OpenClaw wiki research:

- **Per-agent images**: Set via `agents.list[].sandbox.docker.image`
- **Container scope**: Use `scope: "agent"` for one container per agent
- **Network access**:
  - `"none"` (default) - no network, maximum isolation
  - `"bridge"` - internet access for package installs
- **Workspace access**:
  - `"none"` (default) - isolated sandbox workspace
  - `"ro"` - read-only agent workspace
  - `"rw"` - full read-write access
- **Setup command**: Runs once after container creation
- **Binds**: Custom host directory mounts

### Justfile Module Best Practices

From Context7 `just` documentation:

1. **Module working directory**: Recipes execute in module's directory
2. **`source_directory()`**: Returns directory of current source file (the module)
3. **`justfile_directory()`**: Returns directory of MAIN justfile (not module)
4. **Path handling**: Use `cd "{{source_directory()}}/.."` to navigate to project root from module

## References

- OpenClaw Sandboxing: https://github.com/openclaw/openclaw/blob/main/docs/gateway/sandboxing.md
- Multi-Agent Config: https://github.com/openclaw/openclaw/blob/main/docs/tools/multi-agent-sandbox-tools.md
- Just Documentation: https://github.com/casey/just

## Files Created

```
dockerfiles/sandboxes/
├── Dockerfile.base
├── Dockerfile.r2d2
├── Dockerfile.c3po
├── Dockerfile.bb8
└── README.md

.just/
└── sandboxes.just (NEW)

docs/
├── sandbox-quickstart.md
└── examples/
    └── sandbox-config.json5
```

**Main justfile updated:** Added `mod sandboxes` and convenience shortcuts

---

**Status:** ✅ Complete and tested
**Date:** 2026-02-16
