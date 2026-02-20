# Multi-Agent Sandbox Images Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement Docker Bake-based multi-agent sandbox system with per-agent Docker images for 11 Astromech agents.

**Architecture:** Separate Dockerfiles for each agent (modular approach), all inheriting from a base image. Docker Bake orchestrates builds with centralized configuration. Justfile provides user-friendly build commands.

**Tech Stack:** Docker Buildx Bake, Justfile, OpenClaw gateway configuration

---

## Task 1: Create Docker Bake Configuration

**Files:**
- Create: `dockerfiles/sandboxes/docker-bake.hcl`

**Step 1: Create docker-bake.hcl with base configuration**

```hcl
# dockerfiles/sandboxes/docker-bake.hcl

# Variables for version management
variable "VERSION" {
  default = "1"
}

variable "REGISTRY" {
  default = ""
}

# Common configuration inherited by all targets
target "_common" {
  context = "../.."
  args = {
    DEBIAN_FRONTEND = "noninteractive"
  }
}

# Base sandbox image (foundation)
target "base" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.base"
  tags = ["${REGISTRY}astromech-sbx-base:v${VERSION}"]
}

# Main/Yoda agent
target "yoda" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.yoda"
  tags = ["${REGISTRY}astromech-sbx-yoda:v${VERSION}"]
}

# R2D2 - Development agent
target "r2d2" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.r2d2"
  tags = ["${REGISTRY}astromech-sbx-r2d2:v${VERSION}"]
}

# BB8 - Reconnaissance agent
target "bb8" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.bb8"
  tags = ["${REGISTRY}astromech-sbx-bb8:v${VERSION}"]
}

# C3PO - Protocol agent
target "c3po" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.c3po"
  tags = ["${REGISTRY}astromech-sbx-c3po:v${VERSION}"]
}

# BB9E agent
target "bb9e" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.bb9e"
  tags = ["${REGISTRY}astromech-sbx-bb9e:v${VERSION}"]
}

# CB23 agent
target "cb23" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.cb23"
  tags = ["${REGISTRY}astromech-sbx-cb23:v${VERSION}"]
}

# R5D4 agent
target "r5d4" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.r5d4"
  tags = ["${REGISTRY}astromech-sbx-r5d4:v${VERSION}"]
}

# R4P17 agent
target "r4p17" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.r4p17"
  tags = ["${REGISTRY}astromech-sbx-r4p17:v${VERSION}"]
}

# D0 agent
target "d0" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.d0"
  tags = ["${REGISTRY}astromech-sbx-d0:v${VERSION}"]
}

# L337 agent
target "l337" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.l337"
  tags = ["${REGISTRY}astromech-sbx-l337:v${VERSION}"]
}

# K2S0 agent
target "k2s0" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.k2s0"
  tags = ["${REGISTRY}astromech-sbx-k2s0:v${VERSION}"]
}

# Build groups
group "default" {
  targets = ["base", "yoda", "r2d2", "bb8", "c3po", "bb9e", "cb23", "r5d4", "r4p17", "d0", "l337", "k2s0"]
}

group "base-only" {
  targets = ["base"]
}

group "new-agents" {
  targets = ["yoda", "bb9e", "cb23", "r5d4", "r4p17", "d0", "l337", "k2s0"]
}

group "existing-agents" {
  targets = ["r2d2", "bb8", "c3po"]
}
```

**Step 2: Verify Bake configuration syntax**

Run: `docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl --print`

Expected: JSON output showing all targets and their configurations (no syntax errors)

**Step 3: Commit**

```bash
git add dockerfiles/sandboxes/docker-bake.hcl
git commit -m "feat(sandbox): add Docker Bake configuration for multi-agent builds

- Define 12 build targets (base + 11 agents)
- Add VERSION and REGISTRY variables
- Create build groups: default, new-agents, existing-agents
- Centralize common build configuration

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Create Dockerfile.yoda (New Agent)

**Files:**
- Create: `dockerfiles/sandboxes/Dockerfile.yoda`

**Step 1: Create Dockerfile.yoda inheriting from base**

```dockerfile
# Yoda Sandbox - Main Agent
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

# Future: add yoda-specific tools here
# Example:
# RUN apt-get update && apt-get install -y nodejs npm

CMD ["sleep", "infinity"]
```

**Step 2: Commit**

```bash
git add dockerfiles/sandboxes/Dockerfile.yoda
git commit -m "feat(sandbox): add Dockerfile.yoda for main agent

Inherits from base image with minimal customization.
Ready for future tool additions.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Create Dockerfiles for 7 New Agents

**Files:**
- Create: `dockerfiles/sandboxes/Dockerfile.bb9e`
- Create: `dockerfiles/sandboxes/Dockerfile.cb23`
- Create: `dockerfiles/sandboxes/Dockerfile.r5d4`
- Create: `dockerfiles/sandboxes/Dockerfile.r4p17`
- Create: `dockerfiles/sandboxes/Dockerfile.d0`
- Create: `dockerfiles/sandboxes/Dockerfile.l337`
- Create: `dockerfiles/sandboxes/Dockerfile.k2s0`

**Step 1: Create Dockerfile.bb9e**

```dockerfile
# BB9E Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 2: Create Dockerfile.cb23**

```dockerfile
# CB23 Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 3: Create Dockerfile.r5d4**

```dockerfile
# R5D4 Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 4: Create Dockerfile.r4p17**

```dockerfile
# R4P17 Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 5: Create Dockerfile.d0**

```dockerfile
# D0 Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 6: Create Dockerfile.l337**

```dockerfile
# L337 Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 7: Create Dockerfile.k2s0**

```dockerfile
# K2S0 Sandbox
# Base toolset with room for future customization
FROM astromech-sbx-base:v1

CMD ["sleep", "infinity"]
```

**Step 8: Commit**

```bash
git add dockerfiles/sandboxes/Dockerfile.bb9e \
        dockerfiles/sandboxes/Dockerfile.cb23 \
        dockerfiles/sandboxes/Dockerfile.r5d4 \
        dockerfiles/sandboxes/Dockerfile.r4p17 \
        dockerfiles/sandboxes/Dockerfile.d0 \
        dockerfiles/sandboxes/Dockerfile.l337 \
        dockerfiles/sandboxes/Dockerfile.k2s0
git commit -m "feat(sandbox): add Dockerfiles for 7 new agents

Create minimal sandboxes for bb9e, cb23, r5d4, r4p17, d0, l337, k2s0.
All inherit from base image, ready for future customization.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Update Existing Dockerfiles to Use New Base Image

**Files:**
- Modify: `dockerfiles/sandboxes/Dockerfile.r2d2`
- Modify: `dockerfiles/sandboxes/Dockerfile.bb8`
- Modify: `dockerfiles/sandboxes/Dockerfile.c3po`

**Step 1: Update Dockerfile.r2d2 to inherit from base**

Change first line from `FROM debian:bookworm-slim` to:

```dockerfile
# R2D2 Sandbox - Development & Engineering Agent
# Full development toolchain: Node.js, Python, build tools
FROM astromech-sbx-base:v1

# Install comprehensive development tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    wget \
    vim \
    sqlite3 \
  && rm -rf /var/lib/apt/lists/*

# Install jira-cli (same version as gateway)
RUN curl -sSL https://github.com/ankitpokhrel/jira-cli/releases/download/v1.7.0/jira_1.7.0_linux_x86_64.tar.gz \
    | tar xz --strip-components=2 -C /usr/local/bin jira_1.7.0_linux_x86_64/bin/jira

# Install todoist CLI (same version as gateway)
RUN curl -sSL https://github.com/sachaos/todoist/releases/download/v0.23.0/todoist_Linux_x86_64.tar.gz \
    | tar xz -C /usr/local/bin todoist

CMD ["sleep", "infinity"]
```

Remove duplicate installations of base tools (bash, curl, git, jq, ripgrep, just, ca-certificates) and user creation since base image provides them.

**Step 2: Update Dockerfile.bb8 to inherit from base**

Change first line from `FROM debian:bookworm-slim` to:

```dockerfile
# BB8 Sandbox - Minimal Reconnaissance Agent
# Ultra-minimal toolset for read-only operations and data gathering
FROM astromech-sbx-base:v1

# Install additional minimal tools not in base
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
  && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
```

Remove duplicate installations (bash, curl, jq, ripgrep, ca-certificates, just, user creation).

**Step 3: Update Dockerfile.c3po to inherit from base**

Change first line from `FROM debian:bookworm-slim` to:

```dockerfile
# C3PO Sandbox - Communication & Protocol Agent
# Focus: API interactions, text processing, data transformation
FROM astromech-sbx-base:v1

# Install communication and data processing tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    xmlstarlet \
    yq \
    sqlite3 \
    file \
    groff \
  && rm -rf /var/lib/apt/lists/*

# Install jira-cli (for ticket management)
RUN curl -sSL https://github.com/ankitpokhrel/jira-cli/releases/download/v1.7.0/jira_1.7.0_linux_x86_64.tar.gz \
    | tar xz --strip-components=2 -C /usr/local/bin jira_1.7.0_linux_x86_64/bin/jira

# Install todoist CLI (for task management)
RUN curl -sSL https://github.com/sachaos/todoist/releases/download/v0.23.0/todoist_Linux_x86_64.tar.gz \
    | tar xz -C /usr/local/bin todoist

CMD ["sleep", "infinity"]
```

Remove duplicate installations (bash, curl, git, jq, ripgrep, ca-certificates, just, user creation).

**Step 4: Commit**

```bash
git add dockerfiles/sandboxes/Dockerfile.r2d2 \
        dockerfiles/sandboxes/Dockerfile.bb8 \
        dockerfiles/sandboxes/Dockerfile.c3po
git commit -m "refactor(sandbox): update existing Dockerfiles to inherit from base

Update r2d2, bb8, c3po to FROM astromech-sbx-base:v1.
Remove duplicate tool installations.
Reduces duplication and ensures consistent base toolset.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Update Justfile Sandboxes Module

**Files:**
- Modify: `.just/sandboxes.just`

**Step 1: Update build recipe to use Docker Bake**

Replace the `build` recipe (lines 14-56) with:

```just
# Build a specific sandbox image
[doc('Build sandbox image (usage: just sandboxes::build <agent-id> <version>)')]
build agent version:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{source_directory()}}/.."

    echo "=== Building sandbox: astromech-sbx-{{ agent }}:v{{ version }} ==="
    echo ""

    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        {{ agent }}

    echo ""
    echo "✅ Built: astromech-sbx-{{ agent }}:v{{ version }}"
    echo ""
    echo "To use this image, update .openclaw/openclaw.json:"
    echo '  "agents": {'
    echo '    "list": [{'
    echo '      "id": "{{ agent }}",'
    echo '      "sandbox": {'
    echo '        "docker": {'
    echo '          "image": "astromech-sbx-{{ agent }}:v{{ version }}"'
    echo '        }'
    echo '      }'
    echo '    }]'
    echo '  }'
```

**Step 2: Update build-all recipe to use Docker Bake**

Replace the `build-all` recipe (lines 58-77) with:

```just
# Build all sandbox images with the same version
[doc('Build all sandbox images (usage: just sandboxes::build-all <version>)')]
build-all version:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{source_directory()}}/.."

    echo "=== Building all sandbox images (version: v{{ version }}) ==="
    echo ""

    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        default

    echo ""
    echo "✅ All sandbox images built successfully!"
    echo ""
    just sandboxes::list
```

**Step 3: Add new build-base recipe**

Add after `build-all`:

```just
# Build base image only
[doc('Build base sandbox image (usage: just sandboxes::build-base <version>)')]
build-base version:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{source_directory()}}/.."

    echo "=== Building base sandbox image: astromech-sbx-base:v{{ version }} ==="

    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        base

    echo ""
    echo "✅ Built: astromech-sbx-base:v{{ version }}"
```

**Step 4: Add new build-new recipe**

Add after `build-base`:

```just
# Build all new agents (yoda + 7 new)
[doc('Build new agent sandboxes (usage: just sandboxes::build-new <version>)')]
build-new version:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{source_directory()}}/.."

    echo "=== Building new agent sandboxes (version: v{{ version }}) ==="

    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        new-agents

    echo ""
    echo "✅ New agents built successfully!"
```

**Step 5: Add new build-existing recipe**

Add after `build-new`:

```just
# Build existing agents (r2d2, bb8, c3po)
[doc('Build existing agent sandboxes (usage: just sandboxes::build-existing <version>)')]
build-existing version:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{source_directory()}}/.."

    echo "=== Building existing agent sandboxes (version: v{{ version }}) ==="

    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        existing-agents

    echo ""
    echo "✅ Existing agents built successfully!"
```

**Step 6: Update rebuild recipe to use Docker Bake**

Replace the `rebuild` recipe (lines 79-104) with:

```just
# Rebuild a sandbox image (no cache)
[doc('Rebuild sandbox image from scratch (usage: just sandboxes::rebuild <agent-id> <version>)')]
rebuild agent version:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{source_directory()}}/.."

    echo "=== Rebuilding sandbox (no cache): astromech-sbx-{{ agent }}:v{{ version }} ==="

    VERSION={{ version }} docker buildx bake \
        -f dockerfiles/sandboxes/docker-bake.hcl \
        --no-cache \
        {{ agent }}

    echo ""
    echo "✅ Rebuilt: astromech-sbx-{{ agent }}:v{{ version }}"
```

**Step 7: Update list recipe to use new naming**

Replace the `list` recipe (lines 148-155) with:

```just
# List all astromech sandbox images
[doc('List all astromech sandbox images')]
list:
    @echo "=== Astromech Sandbox Images ==="
    @docker images --filter "reference=astromech-sbx-*" --format "table {{{{.Repository}}\t{{{{.Tag}}\t{{{{.Size}}\t{{{{.CreatedAt}}" | head -1
    @docker images --filter "reference=astromech-sbx-*" --format "{{{{.Repository}}\t{{{{.Tag}}\t{{{{.Size}}\t{{{{.CreatedAt}}" | sort
    @echo ""
    @echo "Total images: $(docker images --filter 'reference=astromech-sbx-*' -q | wc -l)"
```

**Step 8: Update remove recipe to use new naming**

Replace the `remove` recipe (lines 219-229) with:

```just
# Remove a specific sandbox image
[doc('Remove sandbox image (usage: just sandboxes::remove <agent-id> <version>)')]
remove agent version:
    #!/usr/bin/env bash
    set -euo pipefail

    IMAGE="astromech-sbx-{{ agent }}:v{{ version }}"

    echo "=== Removing sandbox image: $IMAGE ==="
    docker rmi "$IMAGE"
    echo "✅ Removed: $IMAGE"
```

**Step 9: Update remove-all recipe to use new naming**

Replace the `remove-all` recipe (lines 231-242) with:

```just
# Remove all sandbox images for an agent
[doc('Remove all versions of an agent sandbox (usage: just sandboxes::remove-all <agent-id>)')]
remove-all agent:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "=== Removing all astromech-sbx-{{ agent }} images ==="
    docker images --filter "reference=astromech-sbx-{{ agent }}" --format "{{{{.Repository}}:{{{{.Tag}}" | while read -r image; do
        echo "  Removing: $image"
        docker rmi "$image"
    done
    echo "✅ All astromech-sbx-{{ agent }} images removed"
```

**Step 10: Update prune recipe to use new naming**

Replace the `prune` recipe (lines 244-249) with:

```just
# Prune unused sandbox images
[doc('Remove dangling/unused sandbox images')]
prune:
    @echo "=== Pruning unused sandbox images ==="
    @docker image prune -f --filter "reference=astromech-sbx-*"
    @echo "✅ Pruned"
```

**Step 11: Update inspect recipe to use new naming**

Replace the `inspect` recipe (lines 179-213) with:

```just
# Inspect a sandbox image
[doc('Inspect sandbox image (usage: just sandboxes::inspect <agent-id> <version>)')]
inspect agent version:
    #!/usr/bin/env bash
    set -euo pipefail

    IMAGE="astromech-sbx-{{ agent }}:v{{ version }}"

    echo "=== Inspecting: $IMAGE ==="
    echo ""

    if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
        echo "❌ Error: Image not found: $IMAGE"
        echo ""
        echo "Build it first:"
        echo "  just sandboxes::build {{ agent }} {{ version }}"
        exit 1
    fi

    echo "📋 Image Details:"
    docker image inspect "$IMAGE" | jq -r '
        .[0] |
        "  ID: " + .Id[7:19] + "\n" +
        "  Created: " + .Created + "\n" +
        "  Size: " + (.Size / 1024 / 1024 | tostring) + " MB\n" +
        "  Architecture: " + .Architecture + "\n" +
        "  OS: " + .Os
    '

    echo ""
    echo "🏷️  Tags:"
    docker image inspect "$IMAGE" | jq -r '.[0].RepoTags[]' | sed 's/^/  /'

    echo ""
    echo "⚙️  Entrypoint: $(docker image inspect "$IMAGE" | jq -r '.[0].Config.Cmd | join(" ")')"
```

**Step 12: Update tag recipe to use new naming**

Replace the `tag` recipe (lines 110-125) with:

```just
# Tag an existing image with a new version
[doc('Tag sandbox image with new version (usage: just sandboxes::tag <agent-id> <old-version> <new-version>)')]
tag agent old_version new_version:
    #!/usr/bin/env bash
    set -euo pipefail

    OLD_IMAGE="astromech-sbx-{{ agent }}:v{{ old_version }}"
    NEW_IMAGE="astromech-sbx-{{ agent }}:v{{ new_version }}"

    echo "=== Tagging sandbox image ==="
    echo "From: $OLD_IMAGE"
    echo "To:   $NEW_IMAGE"

    docker tag "$OLD_IMAGE" "$NEW_IMAGE"

    echo "✅ Tagged: $NEW_IMAGE"
```

**Step 13: Update tag-latest recipe to use new naming**

Replace the `tag-latest` recipe (lines 127-142) with:

```just
# Tag image as latest
[doc('Tag sandbox image as latest (usage: just sandboxes::tag-latest <agent-id> <version>)')]
tag-latest agent version:
    #!/usr/bin/env bash
    set -euo pipefail

    IMAGE="astromech-sbx-{{ agent }}:v{{ version }}"
    LATEST="astromech-sbx-{{ agent }}:latest"

    echo "=== Tagging as latest ==="
    echo "From: $IMAGE"
    echo "To:   $LATEST"

    docker tag "$IMAGE" "$LATEST"

    echo "✅ Tagged: $LATEST"
```

**Step 14: Commit**

```bash
git add .just/sandboxes.just
git commit -m "refactor(sandbox): update justfile to use Docker Bake

Major changes:
- Replace docker build with docker buildx bake
- Add build-base, build-new, build-existing recipes
- Update all image references from astromech-* to astromech-sbx-*
- Maintain backward-compatible command interface

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Build Base Image

**Files:**
- Build: `astromech-sbx-base:v1`

**Step 1: Build base sandbox image**

Run: `just build-sandbox base 1`

Expected: Successful build output ending with "✅ Built: astromech-sbx-base:v1"

**Step 2: Verify base image exists**

Run: `docker images astromech-sbx-base`

Expected: Output showing `astromech-sbx-base:v1` with size ~150MB

**Step 3: Inspect base image tools**

Run: `docker run --rm astromech-sbx-base:v1 bash -c "which bash curl git jq rg just"`

Expected: Paths to all base tools printed (verifying they're installed)

---

## Task 7: Build All New Agent Images

**Files:**
- Build: `astromech-sbx-yoda:v1`
- Build: `astromech-sbx-bb9e:v1`
- Build: `astromech-sbx-cb23:v1`
- Build: `astromech-sbx-r5d4:v1`
- Build: `astromech-sbx-r4p17:v1`
- Build: `astromech-sbx-d0:v1`
- Build: `astromech-sbx-l337:v1`
- Build: `astromech-sbx-k2s0:v1`

**Step 1: Build all new agent images**

Run: `just sandboxes::build-new 1`

Expected: Successful parallel build output ending with "✅ New agents built successfully!"

**Step 2: Verify all new images exist**

Run: `docker images astromech-sbx-* | grep "v1"`

Expected: 9 images listed (base + 8 new agents)

---

## Task 8: Build Existing Agent Images

**Files:**
- Build: `astromech-sbx-r2d2:v1`
- Build: `astromech-sbx-bb8:v1`
- Build: `astromech-sbx-c3po:v1`

**Step 1: Build existing agent images**

Run: `just sandboxes::build-existing 1`

Expected: Successful build output ending with "✅ Existing agents built successfully!"

**Step 2: Verify all images exist**

Run: `just list-sandboxes`

Expected: 12 images total (base + 11 agents), all tagged v1

---

## Task 9: Update OpenClaw Configuration - Defaults

**Files:**
- Modify: `.openclaw/openclaw.json:131-140`

**Step 1: Update default sandbox image and container prefix**

In `agents.defaults.sandbox.docker`, change:

```json
"sandbox": {
  "mode": "all",
  "scope": "agent",
  "workspaceAccess": "none",
  "docker": {
    "image": "astromech-sbx-base:v1",
    "network": "bridge",
    "containerPrefix": "astromech-sbx-"
  }
}
```

**Step 2: Verify JSON syntax**

Run: `jq empty .openclaw/openclaw.json`

Expected: No output (valid JSON)

**Step 3: Commit**

```bash
git add .openclaw/openclaw.json
git commit -m "config(sandbox): update default sandbox image to astromech-sbx-base:v1

Update container prefix to astromech-sbx- for consistency.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Update OpenClaw Configuration - Main/Yoda Agent

**Files:**
- Modify: `.openclaw/openclaw.json:143-149`

**Step 1: Update main agent name and add sandbox config**

Change the main agent entry from:

```json
{
  "id": "main",
  "default": true,
  "name": "Main",
  "workspace": "/home/node/.openclaw/workspace",
  "agentDir": "/home/node/.openclaw/agents/main/agent"
}
```

To:

```json
{
  "id": "main",
  "default": true,
  "name": "Yoda",
  "workspace": "/home/node/.openclaw/workspace",
  "agentDir": "/home/node/.openclaw/agents/main/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-yoda:v1"
    }
  }
}
```

**Step 2: Verify JSON syntax**

Run: `jq empty .openclaw/openclaw.json`

Expected: No output (valid JSON)

**Step 3: Commit**

```bash
git add .openclaw/openclaw.json
git commit -m "config(sandbox): configure yoda sandbox for main agent

Rename main agent to 'Yoda' and assign astromech-sbx-yoda:v1 image.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 11: Update OpenClaw Configuration - Existing Agents

**Files:**
- Modify: `.openclaw/openclaw.json:150-189`

**Step 1: Update r2d2 agent sandbox image**

Change line 157 in the r2d2 agent config from:

```json
"image": "astromech-r2d2:v1"
```

To:

```json
"image": "astromech-sbx-r2d2:v1"
```

**Step 2: Update bb8 agent sandbox image**

Change line 168 in the bb8 agent config from:

```json
"image": "astromech-bb8:v1"
```

To:

```json
"image": "astromech-sbx-bb8:v1"
```

**Step 3: Update c3po agent sandbox image**

Change line 186 in the c3po agent config from:

```json
"image": "astromech-c3po:v1"
```

To:

```json
"image": "astromech-sbx-c3po:v1"
```

**Step 4: Verify JSON syntax**

Run: `jq empty .openclaw/openclaw.json`

Expected: No output (valid JSON)

**Step 5: Commit**

```bash
git add .openclaw/openclaw.json
git commit -m "config(sandbox): update existing agents to use sbx- naming

Update r2d2, bb8, c3po to use astromech-sbx-* image naming.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 12: Update OpenClaw Configuration - New Agents

**Files:**
- Modify: `.openclaw/openclaw.json:173-225`

**Step 1: Add sandbox config to bb9e agent**

In the bb9e agent entry (currently no sandbox config), add:

```json
{
  "id": "bb9e",
  "name": "bb9e",
  "workspace": "/home/node/.openclaw/workspace-bb9e",
  "agentDir": "/home/node/.openclaw/agents/bb9e/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-bb9e:v1"
    }
  }
}
```

**Step 2: Add sandbox config to cb23 agent**

```json
{
  "id": "cb23",
  "name": "cb23",
  "workspace": "/home/node/.openclaw/workspace-cb23",
  "agentDir": "/home/node/.openclaw/agents/cb23/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-cb23:v1"
    }
  }
}
```

**Step 3: Add sandbox config to r5d4 agent**

```json
{
  "id": "r5d4",
  "name": "r5d4",
  "workspace": "/home/node/.openclaw/workspace-r5d4",
  "agentDir": "/home/node/.openclaw/agents/r5d4/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-r5d4:v1"
    }
  }
}
```

**Step 4: Add sandbox config to r4p17 agent**

```json
{
  "id": "r4p17",
  "name": "r4p17",
  "workspace": "/home/node/.openclaw/workspace-r4p17",
  "agentDir": "/home/node/.openclaw/agents/r4p17/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-r4p17:v1"
    }
  }
}
```

**Step 5: Add sandbox config to d0 agent**

```json
{
  "id": "d0",
  "name": "d0",
  "workspace": "/home/node/.openclaw/workspace-d0",
  "agentDir": "/home/node/.openclaw/agents/d0/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-d0:v1"
    }
  }
}
```

**Step 6: Add sandbox config to l337 agent**

```json
{
  "id": "l337",
  "name": "l337",
  "workspace": "/home/node/.openclaw/workspace-l337",
  "agentDir": "/home/node/.openclaw/agents/l337/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-l337:v1"
    }
  }
}
```

**Step 7: Add sandbox config to k2s0 agent**

```json
{
  "id": "k2s0",
  "name": "k2s0",
  "workspace": "/home/node/.openclaw/workspace-k2s0",
  "agentDir": "/home/node/.openclaw/agents/k2s0/agent",
  "sandbox": {
    "docker": {
      "image": "astromech-sbx-k2s0:v1"
    }
  }
}
```

**Step 8: Verify JSON syntax**

Run: `jq empty .openclaw/openclaw.json`

Expected: No output (valid JSON)

**Step 9: Commit**

```bash
git add .openclaw/openclaw.json
git commit -m "config(sandbox): add sandbox images for 7 new agents

Configure bb9e, cb23, r5d4, r4p17, d0, l337, k2s0 with their
respective astromech-sbx-* images.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 13: Update Sandbox README

**Files:**
- Modify: `dockerfiles/sandboxes/README.md`

**Step 1: Update image naming convention section**

Change lines 6-14 to reflect new naming:

```markdown
## Image Naming Convention

```
astromech-sbx-{agent-id}:v{version}
```

**Examples:**
- `astromech-sbx-r2d2:v1`
- `astromech-sbx-c3po:v1`
- `astromech-sbx-bb8:v1`
- `astromech-sbx-yoda:v1`
```

**Step 2: Update build commands section**

Change lines 78-89 to use Bake:

```markdown
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
```

**Step 3: Update OpenClaw configuration example**

Update lines 102-164 with new naming:

```markdown
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
```

**Step 4: Add Docker Bake section**

Add new section after "Security Considerations":

```markdown
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
```

**Step 5: Commit**

```bash
git add dockerfiles/sandboxes/README.md
git commit -m "docs(sandbox): update README for Docker Bake and new naming

- Update image naming convention to astromech-sbx-*
- Add Docker Bake usage section
- Update build command examples
- Add override file documentation

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 14: Test Configuration End-to-End

**Files:**
- Test: All components working together

**Step 1: Verify all images are built**

Run: `just list-sandboxes`

Expected: 12 images listed (astromech-sbx-base, yoda, r2d2, bb8, c3po, bb9e, cb23, r5d4, r4p17, d0, l337, k2s0), all v1

**Step 2: Verify OpenClaw config is valid**

Run: `jq '.agents.list[] | {id: .id, image: .sandbox.docker.image}' .openclaw/openclaw.json`

Expected: JSON output showing all 11 agents with their corresponding astromech-sbx-* images

**Step 3: Test building a specific agent**

Run: `just build-sandbox yoda 1`

Expected: Quick cached build (already built), successful completion

**Step 4: Test rebuilding with no-cache**

Run: `just sandboxes::rebuild yoda 1`

Expected: Full rebuild from scratch, successful completion

**Step 5: Verify Bake configuration**

Run: `docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl --print | jq '.target | keys'`

Expected: JSON array with 12 targets: ["_common", "base", "bb8", "bb9e", "c3po", "cb23", "d0", "k2s0", "l337", "r2d2", "r4p17", "r5d4", "yoda"]

---

## Task 15: Clean Up Old Images (Optional)

**Files:**
- Remove: Old `astromech-*` images (without `sbx-`)

**Step 1: List old images**

Run: `docker images | grep "astromech-" | grep -v "astromech-sbx-"`

Expected: List of old images (astromech-base:v1, astromech-r2d2:v1, etc.)

**Step 2: Remove old images**

Run: `docker rmi astromech-base:v1 astromech-r2d2:v1 astromech-bb8:v1 astromech-c3po:v1`

Expected: Images removed successfully

**Step 3: Verify only new images remain**

Run: `docker images | grep "astromech-"`

Expected: Only astromech-sbx-* images listed

---

## Task 16: Create Final Commit and Push

**Files:**
- All modified and created files

**Step 1: Verify all changes are committed**

Run: `git status`

Expected: "nothing to commit, working tree clean" (or only untracked files from before this work)

**Step 2: Review commit history**

Run: `git log --oneline --graph -15`

Expected: Series of commits for this feature (Docker Bake config, Dockerfiles, justfile, openclaw.json updates, docs)

**Step 3: Optional: Create feature summary commit**

If you want a single reference point, create an empty commit:

```bash
git commit --allow-empty -m "feat(sandbox): complete multi-agent sandbox system

Implemented Docker Bake-based multi-agent sandbox architecture:
- 12 sandbox images (base + 11 agents)
- Separate Dockerfiles with base image inheritance
- Docker Bake configuration with build groups
- Updated justfile commands for Docker Bake
- OpenClaw configuration for all agents
- Consistent astromech-sbx-* naming convention

All 11 agents now have independent sandbox images ready for
tool customization.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 4: Push to remote (if applicable)**

Run: `git push origin main`

Expected: All commits pushed successfully

---

## Success Criteria Verification

Run these commands to verify all success criteria are met:

1. **All 12 images build successfully**
   ```bash
   just list-sandboxes | grep "v1" | wc -l
   ```
   Expected: `12`

2. **Justfile commands work**
   ```bash
   just build-sandbox yoda 1 && echo "SUCCESS"
   ```
   Expected: "SUCCESS"

3. **OpenClaw config is valid**
   ```bash
   jq '.agents.list | length' .openclaw/openclaw.json
   ```
   Expected: `11`

4. **Each agent has sandbox image configured**
   ```bash
   jq '[.agents.list[] | select(.sandbox.docker.image == null)] | length' .openclaw/openclaw.json
   ```
   Expected: `0` (no agents without sandbox images)

5. **Docker Bake configuration is valid**
   ```bash
   docker buildx bake -f dockerfiles/sandboxes/docker-bake.hcl --print >/dev/null && echo "VALID"
   ```
   Expected: "VALID"

---

## Next Steps

After completing this implementation plan:

1. **Test with OpenClaw Gateway:**
   - Start gateway: `docker compose up -d gateway`
   - Send message to an agent
   - Verify sandbox container uses correct image

2. **Customize Agent Toolsets:**
   - Edit a Dockerfile (e.g., `Dockerfile.bb9e`)
   - Add custom tools
   - Rebuild with new version: `just build-sandbox bb9e 2`
   - Update openclaw.json to use v2
   - Recreate sandbox: `just recreate-sandbox bb9e`

3. **Documentation:**
   - Update main README.md with sandbox setup instructions
   - Add agent customization guide
   - Document version upgrade process

4. **Monitoring:**
   - Track sandbox container creation
   - Monitor image sizes
   - Verify each agent uses correct image

---

## Troubleshooting

**Issue: Docker Bake not found**
```bash
docker buildx version
```
If not installed, follow: https://docs.docker.com/build/install-buildx/

**Issue: Image build fails with "base not found"**
```bash
# Build base first
just sandboxes::build-base 1
# Then build agents
just sandboxes::build-new 1
```

**Issue: OpenClaw doesn't use new image**
```bash
# Recreate sandbox containers
docker exec astromech-gateway openclaw sandbox recreate --agent <agent-id> --force
```

**Issue: Old containers still running**
```bash
# Stop and remove old containers
docker ps -a | grep "astromech-sbx-" | awk '{print $1}' | xargs docker rm -f
```
