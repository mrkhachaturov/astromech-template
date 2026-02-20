# OpenClaw Gateway Sandbox Setup

> Configuration guide for running OpenClaw gateway in Docker with isolated sandbox containers for agents

## Table of Contents

- [The Problem: Nested Containers](#the-problem-nested-containers)
- [The Solution: Host Symlink](#the-solution-host-symlink)
- [Step-by-Step Setup](#step-by-step-setup)
- [How It Works](#how-it-works)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## The Problem: Nested Containers

When **OpenClaw gateway runs in Docker** with sandbox mode enabled (`sandbox.mode: "all"`), there's a path translation issue when mounting agent workspaces into sandbox containers.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Host                                                        │
│                                                             │
│  /path/to/astromech/.openclaw/                        │
│  ├── workspace/         (main agent)                       │
│  ├── workspace-r2d2/    (r2d2 agent)                       │
│  └── workspace-bb8/     (bb8 agent)                        │
│                                                             │
│  ┌──────────────────────────────────────────────────┐      │
│  │ Gateway Container (astromech-gateway)            │      │
│  │                                                  │      │
│  │ Mount: /path/to/astromech/.openclaw         │      │
│  │    →   /home/node/.openclaw                      │      │
│  │                                                  │      │
│  │ Gateway sees:                                    │      │
│  │   /home/node/.openclaw/workspace-r2d2/          │      │
│  │                                                  │      │
│  │ When creating sandbox, gateway tells Docker:     │      │
│  │   "Mount /home/node/.openclaw/workspace-r2d2"    │      │
│  │                                                  │      │
│  └──────────────────────────────────────────────────┘      │
│                         ↓                                   │
│              ❌ Docker looks for this path ON HOST         │
│              ❌ /home/node/.openclaw/ doesn't exist!       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### What Happened Without Symlink

1. Gateway requests mount of `/home/node/.openclaw/workspace-r2d2`
2. Docker on host **cannot see paths inside gateway container**
3. Docker tries to find `/home/node/.openclaw/workspace-r2d2` on host
4. Path doesn't exist → Docker creates empty directory as root
5. Sandbox gets empty workspace without access to agent files

**Result**: Agent sees files through prompt injection, but CANNOT read/write through tools (read, write, exec).

---

## The Solution: Host Symlink

Create a **symbolic link** on the host so Docker can resolve gateway container paths:

```bash
sudo ln -s /path/to/astromech /home/node
```

### Why This Works

```
┌─────────────────────────────────────────────────────────────┐
│ Host                                                        │
│                                                             │
│  /home/node  →  /path/to/astromech  (symlink)        │
│                                                             │
│  Gateway requests: /home/node/.openclaw/workspace-r2d2      │
│           ↓                                                 │
│  Docker resolves: /path/to/astromech/.openclaw/workspace-r2d2  │
│           ↓                                                 │
│  ✅ Finds real directory!                                  │
│  ✅ Mounts into sandbox as /workspace with RW access       │
│                                                             │
│  ┌──────────────────────────────────────────────────┐      │
│  │ Sandbox Container (astromech-sbx-agent-r2d2-*)   │      │
│  │                                                  │      │
│  │ /workspace  ← /home/YOUR_USERNAME/.../workspace-r2d2  │      │
│  │                                                  │      │
│  │ ✅ AGENTS.md, SOUL.md, memory/ — all accessible  │      │
│  │ ✅ Agent can read and write files                │      │
│  │ ✅ UID 1000 (node) = UID 1000 (YOUR_USERNAME)          │      │
│  └──────────────────────────────────────────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Setup

### Prerequisites

1. **Socket Proxy** (provides controlled Docker socket access)
2. **Gateway image** built with Docker CLI (`/usr/bin/docker` available)
3. **Host user** with UID 1000 (default on most Linux systems)

### 1. Start Socket Proxy

Socket proxy provides controlled access to Docker socket:

```bash
docker compose up -d docker-socket-proxy
```

**Verify**:
```bash
docker ps | grep socket-proxy
# Should show running container
```

### 2. Create Host Symlink

```bash
sudo ln -s /path/to/astromech /home/node
```

**Verify**:
```bash
ls -la /home/ | grep node
# Output: lrwxrwxrwx  1 root root   27 ... node -> /path/to/astromech

# Test resolution
ls /home/node/.openclaw/workspace-r2d2/
# Should show AGENTS.md, SOUL.md, memory/, etc.
```

### 3. Start Gateway

```bash
docker compose up -d astromech-gateway
```

### 4. Check Logs

```bash
docker logs astromech-gateway -f
```

Expected output:
- `[gateway] gateway started`
- `[telegram] [r2d2] starting provider`
- On first agent message: sandbox container creation

---

## How It Works

### OpenClaw Configuration

In `.openclaw/config/agents.json5`:

```json5
{
  "defaults": {
    "sandbox": {
      "mode": "all",              // All agents in sandbox
      "scope": "agent",            // One sandbox per agent (not per session)
      "workspaceAccess": "rw",     // Read-write workspace access
      "docker": {
        "image": "astromech-sbx-base:v1",
        "network": "bridge",
        "containerPrefix": "astromech-sbx-"
      }
    }
  },

  "list": [
    {
      "id": "r2d2",
      "workspace": "/home/node/.openclaw/workspace-r2d2",  // Gateway path
      // ...
    }
  ]
}
```

### Docker Compose

In `compose/gateway.yml`:

```yaml
volumes:
  # Gateway sees config at /home/node/.openclaw
  - ${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw

  # Docker CLI binary for sandbox container management
  - /usr/bin/docker:/usr/bin/docker:ro

environment:
  # Gateway connects to Docker via socket proxy
  DOCKER_HOST: "tcp://docker-socket-proxy:2375"
```

### Sandbox Creation Process

1. **Agent receives message** → OpenClaw checks for sandbox existence
2. **Sandbox doesn't exist** → Gateway creates container via Docker API
3. **Gateway builds command**:
   ```bash
   docker create \
     --name astromech-sbx-agent-r2d2-<hash> \
     --workdir /workspace \
     -v /home/node/.openclaw/workspace-r2d2:/workspace \
     astromech-sbx-r2d2:v1
   ```
4. **Docker on host resolves** via symlink:
   - `/home/node/.openclaw/workspace-r2d2`
   - → `/path/to/astromech/.openclaw/workspace-r2d2`
5. **Sandbox starts** with mounted workspace
6. **Agent works** inside sandbox with full file access

### UID Mapping

| Context | User | UID | GID | Ownership |
|---------|------|-----|-----|-----------|
| Host | `YOUR_USERNAME` | 1000 | 1000 | file owner |
| Gateway | `node` | 1000 | 1000 | sees as own |
| Sandbox | `sandbox` | 1000 | 1000 | writes as YOUR_USERNAME |

**Important**: All use UID 1000, so permissions work correctly!

---

## Verification

### 1. Check Workspace in Gateway

```bash
docker exec astromech-gateway ls -la /home/node/.openclaw/workspace-r2d2/
```

Should show agent files: `AGENTS.md`, `SOUL.md`, `memory/`

### 2. Find Agent Sandbox Container

```bash
docker ps | grep astromech-sbx-agent-r2d2
```

If container doesn't exist, send a message to the agent via Telegram.

### 3. Check Workspace in Sandbox

```bash
SANDBOX=$(docker ps --filter "name=astromech-sbx-agent-r2d2" --format "{{.Names}}" | head -1)
docker exec $SANDBOX ls -la /workspace/
```

Should show the same files!

### 4. Verify Mount

```bash
docker inspect $SANDBOX --format '{{json .Mounts}}' | jq -r '.[] | "\(.Source) -> \(.Destination) (RW:\(.RW))"'
```

Expected output:
```
/home/node/.openclaw/workspace-r2d2 -> /workspace (RW:true)
```

### 5. Write Test

```bash
docker exec $SANDBOX sh -c "echo 'test' > /workspace/memory/test.txt && cat /workspace/memory/test.txt"
# Output: test

# Check on host
cat /path/to/astromech/.openclaw/workspace-r2d2/memory/test.txt
# Output: test

# Cleanup
rm /path/to/astromech/.openclaw/workspace-r2d2/memory/test.txt
```

### 6. Ask Agent

Send via Telegram:
```
/r2d2 ls memory/
```

Agent should show memory directory contents using exec tool.

---

## Troubleshooting

### Error: "spawn docker ENOENT"

**Cause**: Gateway cannot find `docker` binary.

**Solution**: Check mount in `compose/gateway.yml`:
```yaml
- /usr/bin/docker:/usr/bin/docker:ro
```

Recreate container:
```bash
docker compose up -d --force-recreate astromech-gateway
```

### Error: "exec failed: ls: cannot access '/home/node/.openclaw/workspace-r2d2/'"

**Cause**: Host symlink is missing or incorrect.

**Solution**:
```bash
# Check symlink
ls -la /home/node
# Should be: lrwxrwxrwx ... node -> /path/to/astromech

# If missing, create it
sudo ln -s /path/to/astromech /home/node

# Remove old sandbox containers
docker rm -f $(docker ps -aq --filter "name=astromech-sbx-agent")

# Sandbox will be recreated on next agent message
```

### Empty Workspace in Sandbox

**Cause**: Docker created empty directory before symlink was set.

**Solution**:
```bash
# Remove empty directories (if created)
sudo rm -rf /home/node/.openclaw

# Ensure symlink is set
sudo ln -s /path/to/astromech /home/node

# Recreate sandbox
docker rm -f $(docker ps -aq --filter "name=astromech-sbx-agent")
```

### Agent Cannot Write to Workspace

**Cause**: File permissions issue.

**Solution**:
```bash
# Check ownership
ls -la /path/to/astromech/.openclaw/workspace-r2d2/
# Should be: YOUR_USERNAME:YOUR_USERNAME (or UID/GID 1000)

# Fix permissions (if needed)
sudo chown -R YOUR_USERNAME:YOUR_USERNAME /path/to/astromech/.openclaw/workspace-r2d2/
```

### Socket Proxy Not Working

**Cause**: Insufficient permissions for Docker API.

**Solution**: Check `compose/socket-proxy.yml`:
```yaml
environment:
  EXEC: 1             # ← Required for docker exec
  ALLOW_START: 1      # ← Required for docker start
  ALLOW_STOP: 1       # ← Required for docker stop
  CONTAINERS: 1
  IMAGES: 1
  NETWORKS: 1
```

Recreate:
```bash
docker compose up -d --force-recreate docker-socket-proxy
```

---

## Summary

After setup:

✅ **Gateway** can create sandbox containers via socket proxy
✅ **Sandbox** gets access to agent workspace (read-write)
✅ **Agents** can read/write files via tools (read, write, exec)
✅ **Memory** persists between sessions (memory/ directory)
✅ **Git** works inside sandbox
✅ **UID mapping** is correct (sandbox writes as YOUR_USERNAME on host)

**Persistence**: Symlink and docker binary mount survive reboots!

---

**Documentation updated**: 2026-02-16
**OpenClaw version**: 2026.2.14
**Astromech version**: 2026.2.14
