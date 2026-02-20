# Sandbox Configuration Complete ✅

**Date:** 2026-02-16
**Status:** Configured and ready

## What Was Done

### 1. Built Base Sandbox Image

```bash
Image: astromech-base:v1
Size: 265MB
Created: 2026-02-16 16:17:48 MSK
```

**Toolset:**
- bash, curl, git, jq, ripgrep
- just (command runner)
- ca-certificates

### 2. Configured OpenClaw Sandboxing

**Location:** `.openclaw/openclaw.json`

Added global sandbox configuration at `agents.defaults.sandbox`:

```json
{
  "sandbox": {
    "mode": "all",
    "scope": "agent",
    "workspaceAccess": "none",
    "docker": {
      "image": "astromech-base:v1",
      "network": "bridge",
      "containerPrefix": "astromech-sbx-"
    }
  }
}
```

### Configuration Explanation

| Setting | Value | Description |
|---------|-------|-------------|
| `mode` | `"all"` | All sessions run in sandbox (including main) |
| `scope` | `"agent"` | One container per agent (11 agents = 11 containers) |
| `workspaceAccess` | `"none"` | Isolated sandbox workspace (agents can't access host workspace) |
| `image` | `"astromech-base:v1"` | Use the base sandbox image for all agents |
| `network` | `"bridge"` | Containers have internet access |
| `containerPrefix` | `"astromech-sbx-"` | Container naming pattern |

## Agents Using This Configuration

All 11 agents will use the base sandbox:

1. **main** - Main agent (BB-Yoda)
2. **r2d2** - R2D2 Bot
3. **bb8** - BB8 Bot
4. **bb9e** - BB9E Bot
5. **c3po** - C3PO Bot
6. **cb23** - CB23 Bot
7. **r5d4** - R5D4 Bot
8. **r4p17** - R4P17 Bot
9. **d0** - D0 Bot
10. **l337** - L337 Bot
11. **k2s0** - K2S0 Bot

Each agent will get its own isolated container with the base toolset.

## Container Naming Pattern

When OpenClaw creates sandbox containers, they will be named:
```
astromech-sbx-agent-{agent-id}-{hash}
```

Examples:
- `astromech-sbx-agent-r2d2-a1b2c3d4`
- `astromech-sbx-agent-bb8-e5f6g7h8`
- `astromech-sbx-agent-main-i9j0k1l2`

## What Happens Next

When you start/restart the OpenClaw gateway:

1. **Containers created on-demand** - Sandbox containers are created lazily when an agent receives its first message
2. **Persistent containers** - Containers stay running between sessions (unless manually removed)
3. **Isolated workspaces** - Each agent has its own sandbox workspace under `~/.openclaw/sandboxes/`

## Verification Commands

### Check if gateway is running
```bash
docker ps | grep astromech-gateway
```

### List sandbox containers (after gateway starts)
```bash
docker ps | grep astromech-sbx
```

### View sandbox configuration for specific agent
```bash
# Requires gateway to be running
docker exec astromech-gateway openclaw sandbox explain --agent r2d2
```

### List all OpenClaw sandbox containers
```bash
# Requires gateway to be running
docker exec astromech-gateway openclaw sandbox list
```

## Starting the Gateway

```bash
# Start gateway service
just up-service gateway

# Check logs
docker logs -f astromech-gateway

# Check status
just ps
```

## Testing Sandboxes

1. **Start gateway:** `just up-service gateway`
2. **Send message** to any bot via Telegram
3. **Container created** automatically on first message
4. **Verify:** `docker ps | grep astromech-sbx`

Expected output:
```
astromech-sbx-agent-r2d2-a1b2c3d4   astromech-base:v1   ...
```

## Customizing Per-Agent

If you want specific agents to use different images (e.g., r2d2 with dev tools):

1. **Build custom image:**
   ```bash
   just build-sandbox r2d2 1
   ```

2. **Override in config** (`.openclaw/openclaw.json`):
   ```json
   {
     "agents": {
       "list": [
         {
           "id": "r2d2",
           "sandbox": {
             "docker": {
               "image": "astromech-r2d2:v1"
             }
           }
         }
       ]
     }
   }
   ```

3. **Recreate container:**
   ```bash
   just recreate-sandbox r2d2
   ```

## Workspace Isolation

With `workspaceAccess: "none"`:

- Agents run in isolated sandbox workspaces
- Cannot access host filesystem
- Each agent has its own `/workspace` inside the container
- Host agent workspace: `/home/node/.openclaw/workspace-{agent-id}/`
- Sandbox workspace: `~/.openclaw/sandboxes/agent-{agent-id}/`

**To grant workspace access:**

```json
"sandbox": {
  "workspaceAccess": "ro"  // Read-only access to agent workspace
  // or
  "workspaceAccess": "rw"  // Full read-write access
}
```

## Network Access

Currently set to `"bridge"` (internet access).

**To disable network (maximum isolation):**

```json
"sandbox": {
  "docker": {
    "network": "none"
  }
}
```

Useful for public-facing agents or when you want to restrict outbound connections.

## Container Resources

Default resources (no limits set). To add resource constraints:

```json
"sandbox": {
  "docker": {
    "image": "astromech-base:v1",
    "network": "bridge",
    "memory": "512m",      // Memory limit
    "cpus": "1",           // CPU limit
    "pidsLimit": 256       // Process limit
  }
}
```

## Troubleshooting

### Container not created
- Check gateway logs: `docker logs astromech-gateway`
- Send a message to the agent via Telegram
- Containers are created on first message, not at startup

### Image not found
```bash
# Rebuild base image
just build-sandbox base 1

# Verify image exists
just list-sandboxes
```

### Config not applied
```bash
# Recreate gateway container
just recreate-service gateway

# Recreate sandbox containers
docker exec astromech-gateway openclaw sandbox recreate --all --force
```

### Check sandbox status
```bash
# From gateway container
docker exec astromech-gateway openclaw sandbox explain --agent r2d2
```

## Next Steps

1. ✅ **Base image built** - `astromech-base:v1`
2. ✅ **Config updated** - `agents.defaults.sandbox` configured
3. ⏭️ **Start gateway** - `just up-service gateway`
4. ⏭️ **Test with Telegram** - Send message to any bot
5. ⏭️ **Verify containers** - `docker ps | grep astromech-sbx`
6. ⏭️ **Monitor behavior** - Check if tools work correctly in sandbox

## References

- **OpenClaw Sandbox Docs:** `tools/wiki/source/docs/gateway/sandboxing.md`
- **Multi-Agent Config:** `tools/wiki/source/docs/tools/multi-agent-sandbox-tools.md`
- **Quick Start Guide:** `docs/sandbox-quickstart.md`
- **Example Config:** `docs/examples/sandbox-config.json5`
