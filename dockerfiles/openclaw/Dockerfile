###############################################################################
# OpenClaw Gateway – Docker Image
#
# IMPORTANT: Runtime installs are lost on container restart. All binaries
# needed by skills MUST be installed here at build time. If you add a skill
# that needs a new binary, update this Dockerfile and rebuild.
###############################################################################

FROM node:22-bookworm-slim

# Install system dependencies as root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    chromium \
    ca-certificates \
    tini \
    gnupg \
    sqlite3 \
    libsqlite3-dev \
    unzip \
    build-essential \
    cmake \
    jq \
  && rm -rf /var/lib/apt/lists/*

# Install 1Password CLI
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    tee /etc/apt/sources.list.d/1password.list && \
    mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
    mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
    apt-get update && apt-get install -y 1password-cli && \
    rm -rf /var/lib/apt/lists/*

# Pin OpenClaw version for reproducible builds — bump explicitly when upgrading
ARG OPENCLAW_VERSION=2026.2.19-2
RUN npm install -g openclaw@${OPENCLAW_VERSION}

# Install ClawHub CLI for skill management
RUN npm install -g clawhub

# Install Lobster workflow runtime
RUN npm install -g @clawdbot/lobster

# Install mcporter — MCP client CLI (lets agents call any MCP server)
RUN npm install -g mcporter

# Install Playwright for browser automation (click, navigate, snapshot, etc.)
# PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1: reuse system Chromium (already installed above)
# executablePath in browser config points to /usr/bin/chromium
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
RUN npm install -g playwright

# Clone brain-cli and add to PATH
RUN git clone --depth=1 https://github.com/bloomedai/brain-cli.git /opt/brain-cli \
  && chmod +x /opt/brain-cli/bin/* \
  && ln -s /opt/brain-cli/bin/brain /usr/local/bin/brain \
  && ln -s /opt/brain-cli/bin/brain-categorize /usr/local/bin/brain-categorize \
  && ln -s /opt/brain-cli/bin/brain-file /usr/local/bin/brain-file

# Install Bun (for QMD) - system-wide installation
ENV BUN_INSTALL="/usr/local"
RUN curl -fsSL https://bun.sh/install | bash && \
    ln -sf /usr/local/bin/bun /usr/bin/bun

# ═══════════════════════════════════════════════════════════════════════════
# QMD (Query Markdown) - TEMPORARILY DISABLED (2026-02-17)
# ═══════════════════════════════════════════════════════════════════════════
# Reason: QMD requires GPU for acceptable performance. On CPU-only systems,
# queries timeout (>60s) making it unusable in production.
#
# To re-enable:
# 1. Uncomment the sections below
# 2. Uncomment "backend": "qmd" in .openclaw/config/memory.json5
# 3. Rebuild image: just build
# ═══════════════════════════════════════════════════════════════════════════

# Install QMD CLI (for enhanced memory search)
# Use published package (has pre-built dist/), not GitHub source
# RUN bun install -g @tobilu/qmd

# Pre-download QMD models at build time (prevents first-run delays)
# Models are versioned and tied to QMD version (static, don't auto-update)
# Total size: ~2GB (embedding: 314MB, query-expansion: 1.2GB, reranker: ~700MB)
#
# XDG paths:
#   - XDG_CACHE_HOME: Set globally for shared model storage across agents
#   - XDG_CONFIG_HOME: Managed per-agent by OpenClaw at runtime (not set globally)
# ENV XDG_CACHE_HOME=/home/node/.cache
# COPY config/qmd-warmup.md /tmp/qmd-warmup/warmup.md
# RUN mkdir -p /home/node/.cache/qmd/models /home/node/.openclaw/qmd /home/node/.config \
#   && chown -R node:node /home/node/.cache /home/node/.openclaw /home/node/.config \
#   && HOME=/home/node XDG_CACHE_HOME=/home/node/.cache XDG_CONFIG_HOME=/home/node/.openclaw qmd collection add /tmp/qmd-warmup --name warmup --mask '**/*.md' \
#   && HOME=/home/node XDG_CACHE_HOME=/home/node/.cache XDG_CONFIG_HOME=/home/node/.openclaw qmd update \
#   && HOME=/home/node XDG_CACHE_HOME=/home/node/.cache XDG_CONFIG_HOME=/home/node/.openclaw qmd embed \
#   && echo "=== Running qmd query to download remaining models ===" \
#   && HOME=/home/node XDG_CACHE_HOME=/home/node/.cache XDG_CONFIG_HOME=/home/node/.openclaw qmd query 'download all three models' -c warmup \
#   && echo "=== Verifying all models downloaded ===" \
#   && ls -lh /home/node/.cache/qmd/models/ \
#   && rm -rf /tmp/qmd-warmup \
#   && chown -R node:node /home/node/.cache /home/node/.openclaw /home/node/.config

# Still create base directories even without QMD
RUN mkdir -p /home/node/.cache /home/node/.openclaw/qmd /home/node/.config \
  && chown -R node:node /home/node/.cache /home/node/.openclaw /home/node/.config

# Create OpenClaw directories owned by node
RUN mkdir -p /home/node/.openclaw/workspace /.clawhub \
  && chown -R node:node /home/node/.openclaw /.clawhub

# Copy skills manifest, workspace templates, and entrypoint
COPY config/skills-manifest.txt /opt/config/skills-manifest.txt
# COPY workspace-templates/ /opt/workspace-templates/
COPY --chown=node:node entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Source 1Password secrets in interactive docker exec sessions
RUN echo '[ -f /tmp/openclaw-env ] && set -a && . /tmp/openclaw-env && set +a' \
    >> /home/node/.bashrc

USER node

# TEMPORARY: Commented out to use env vars from compose instead of entrypoint
# ENTRYPOINT ["tini", "--"]
ENTRYPOINT ["tini", "--", "entrypoint.sh"]

