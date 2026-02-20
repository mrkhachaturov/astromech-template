# Astromech Per-Agent Sandbox Quick Start

This guide shows you how to set up custom Docker sandbox images for different OpenClaw agents.

## Overview

Each agent can run in its own isolated Docker container with a tailored toolset:

- **R2D2**: Full development (Node.js, Python, build tools)
- **C3PO**: Communication/API (data processing, APIs)
- **BB8**: Minimal (read-only, maximum isolation)
- **Base**: Lightweight baseline

## Quick Start

### 1. Build Sandbox Images

```bash
# Build a specific agent sandbox
just build-sandbox r2d2 1

# Build all sandboxes with the same version
just build-sandboxes 1

# List built images
just list-sandboxes
```

### 2. Configure OpenClaw

Edit `.openclaw/openclaw.json`:

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

**See full example:** [`docs/examples/sandbox-config.json5`](./examples/sandbox-config.json5)

### 3. Start OpenClaw Gateway

```bash
# Start the gateway
just up-service gateway

# Verify configuration
just sandboxes::explain r2d2
```

### 4. Recreate Containers (After Config Changes)

```bash
# Recreate sandbox containers for specific agent
just recreate-sandbox r2d2

# Or recreate all containers
just recreate
```

## Available Commands

### Build Commands

```bash
# Build specific sandbox
just build-sandbox <agent-id> <version>
just build-sandbox r2d2 1

# Build all sandboxes
just build-sandboxes 1

# Rebuild from scratch (no cache)
just sandboxes::rebuild r2d2 1

# Quick shortcuts
just sandboxes::r2d2 1      # Build R2D2
just sandboxes::c3po 1      # Build C3PO
just sandboxes::bb8 1       # Build BB8
just sandboxes::base 1      # Build base
```

### Inspection Commands

```bash
# List all sandbox images
just list-sandboxes

# Show available profiles
just sandbox-profiles

# Inspect specific image
just sandboxes::inspect r2d2 1
```

### Version Management

```bash
# Tag with new version
just sandboxes::tag r2d2 1 2

# Tag as latest
just sandboxes::tag-latest r2d2 1
```

### Cleanup

```bash
# Remove specific version
just sandboxes::remove r2d2 1

# Remove all versions of an agent
just sandboxes::remove-all r2d2

# Prune unused images
just sandboxes::prune
```

### Gateway Integration

```bash
# Recreate sandbox containers (after image rebuild)
just recreate-sandbox r2d2

# Show effective sandbox configuration
just sandboxes::explain r2d2
```

## Sandbox Profiles

### R2D2 - Development & Engineering

**Toolset:**
- Node.js, npm
- Python 3, pip
- Build tools (gcc, g++, make)
- Git, jq, ripgrep, just
- jira-cli, todoist

**Use for:**
- Software development
- Building/compiling code
- Full-stack engineering

**Config:**
```jsonc
{
  "sandbox": {
    "docker": {
      "image": "astromech-r2d2:v1",
      "network": "bridge"  // Needs internet
    }
  }
}
```

### C3PO - Communication & Protocol

**Toolset:**
- Node.js, npm
- XML/YAML processors (xmlstarlet, yq)
- Git, jq, ripgrep, just
- jira-cli, todoist

**Use for:**
- API integrations
- Data transformation
- Communication tasks

**Config:**
```jsonc
{
  "sandbox": {
    "docker": {
      "image": "astromech-c3po:v1",
      "network": "bridge"
    },
    "workspaceAccess": "ro"  // Read-only
  }
}
```

### BB8 - Reconnaissance

**Toolset:**
- Minimal: bash, curl, jq, ripgrep, just

**Use for:**
- Read-only operations
- Data gathering
- Maximum isolation

**Config:**
```jsonc
{
  "sandbox": {
    "docker": {
      "image": "astromech-bb8:v1",
      "network": "none"  // No network
    },
    "workspaceAccess": "none"  // Isolated
  },
  "tools": {
    "allow": ["read", "grep"],
    "deny": ["*"]
  }
}
```

### Base - Minimal Baseline

**Toolset:**
- Bash, curl, git, jq, ripgrep, just

**Use for:**
- Custom agent toolsets
- Starting point for new profiles

## Customizing Sandbox Images

### 1. Create New Dockerfile

```bash
# Create new profile
cp dockerfiles/sandboxes/Dockerfile.base dockerfiles/sandboxes/Dockerfile.myagent

# Edit and add tools
vim dockerfiles/sandboxes/Dockerfile.myagent
```

### 2. Build Custom Image

```bash
just build-sandbox myagent 1
```

### 3. Configure in OpenClaw

```jsonc
{
  "agents": {
    "list": [
      {
        "id": "myagent",
        "sandbox": {
          "docker": {
            "image": "astromech-myagent:v1"
          }
        }
      }
    ]
  }
}
```

## Common Patterns

### Development Agent with Project Mount

```jsonc
{
  "sandbox": {
    "docker": {
      "image": "astromech-r2d2:v1",
      "network": "bridge",
      "binds": [
        "/home/user/project:/project:ro"  // Mount read-only
      ]
    }
  }
}
```

### Restricted Agent with Tool Limits

```jsonc
{
  "sandbox": {
    "mode": "all",
    "docker": {
      "image": "astromech-bb8:v1",
      "network": "none",
      "memory": "512m",
      "cpus": "0.5"
    }
  },
  "tools": {
    "allow": ["read"],
    "deny": ["*"]
  }
}
```

### Agent with Setup Command

```jsonc
{
  "sandbox": {
    "docker": {
      "image": "astromech-r2d2:v1",
      "network": "bridge",
      "setupCommand": "npm install -g typescript && pip install requests"
    }
  }
}
```

## Troubleshooting

### Container Not Using New Image

```bash
# Rebuild image
just build-sandbox r2d2 2

# Update config to use v2
vim .openclaw/openclaw.json

# Force recreate containers
just recreate-sandbox r2d2
```

### Check Running Container

```bash
# Find container
docker ps | grep astromech-sbx

# Check image
docker inspect <container-name> | jq '.[0].Config.Image'

# Exec into container
docker exec -it <container-name> bash
```

### Verify Sandbox Config

```bash
# From gateway container
docker exec -it astromech-gateway bash
openclaw sandbox explain --agent r2d2
```

## Next Steps

1. **Review examples:** See [`docs/examples/sandbox-config.json5`](./examples/sandbox-config.json5)
2. **Read full docs:** Check [`dockerfiles/sandboxes/README.md`](../dockerfiles/sandboxes/README.md)
3. **OpenClaw docs:** [Sandboxing](https://github.com/openclaw/openclaw/blob/main/docs/gateway/sandboxing.md)
4. **Multi-agent config:** [Multi-Agent Setup](https://github.com/openclaw/openclaw/blob/main/docs/tools/multi-agent-sandbox-tools.md)
