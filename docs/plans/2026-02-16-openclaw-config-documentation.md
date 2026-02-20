# OpenClaw Config Documentation Enhancement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add inline documentation (file paths + wiki queries) to all OpenClaw config files, making them self-documenting for both humans and AI.

**Architecture:** Enhance existing JSON5 config files with structured comments containing local doc paths (for IDE navigation) and wiki query commands (for AI semantic search). Three-tier hierarchy: major sections, subsections, individual settings. Three density levels based on complexity.

**Tech Stack:** JSON5 config files, OpenClaw wiki skill, git

---

## Prerequisites

**Before starting:**
- [ ] Verify wiki is up to date: `just wiki-latest`
- [ ] Note current OpenClaw version for documentation tracking
- [ ] All config files exist in `.openclaw/` and `.openclaw/config/`

---

## Phase 1: Foundation - Main Gateway File

### Task 1: Enhance Gateway Server Section

**Files:**
- Modify: `.openclaw/openclaw.json:39-98`

**Step 1: Query wiki for gateway documentation**

Run wiki queries to gather documentation paths:
```bash
just wiki-docs "gateway configuration port mode bind" --json
just wiki-docs "gateway authentication token mode" --json
just wiki-docs "gateway reload modes" --json
just wiki-docs "gateway remote connection" --json
```

Collect the file paths and line ranges from results.

**Step 2: Add documentation to Gateway section header**

Add to line 34 (before "gateway" section):
```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🌐 GATEWAY SERVER
// ═══════════════════════════════════════════════════════════════════════════
// Gateway infrastructure configuration (port, auth, networking, etc.)
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/configuration.md:360-395
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/index.md:68-116
// 🤖 Wiki: just wiki-docs "gateway configuration port mode bind"
// 🤖 Wiki: just wiki-docs "gateway reload modes"
```

**Step 3: Add docs to Server Settings subsection**

Update lines 40-45:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Server Settings
    // ─────────────────────────────────────────────────────────────────────────
    // Port precedence: --port → OPENCLAW_GATEWAY_PORT → gateway.port → 18789
    // Bind modes: loopback (local only) | lan (LAN) | tailnet | custom
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/index.md:68-116
    // 🤖 Wiki: just wiki-docs "gateway port bind precedence"
    "port": 18789,
    "mode": "local",
    "bind": "lan",
```

**Step 4: Add docs to Gateway Authentication subsection**

Update lines 58-63:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Gateway Authentication
    // ─────────────────────────────────────────────────────────────────────────
    // Controls how clients authenticate to this gateway instance
    // Auth modes: token | password | trusted-proxy
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md:1-61
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/security/index.md:436-469
    // 🤖 Wiki: just wiki-docs "gateway authentication token mode"
    // 🤖 Related: just wiki-docs "gateway security trusted proxies"
    "auth": {
      "mode": "token",
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    },
```

**Step 5: Add docs to remaining gateway subsections**

Add documentation comments to:
- Control UI (lines 48-55)
- Network Settings (lines 66-70)
- Remote Gateway Connection (lines 74-78)
- Config Reload Behavior (lines 81-86)
- HTTP Endpoints (lines 89-97)

Use the same pattern: brief description + file paths + wiki queries.

**Step 6: Verify all gateway wiki queries work**

Test each query returns relevant results:
```bash
just wiki-docs "gateway configuration port mode bind"
just wiki-docs "gateway authentication token mode"
just wiki-docs "gateway port bind precedence"
just wiki-docs "gateway security trusted proxies"
# etc. for all queries added
```

Check that scores are ≥ 0.7 and results are relevant.

**Step 7: Commit gateway section enhancement**

```bash
git add .openclaw/openclaw.json
git commit -m "docs(config): add documentation to gateway section

Add inline docs with file paths and wiki queries to all gateway
subsections: server settings, control UI, auth, network, remote,
reload, and HTTP endpoints.

- 📄 Docs: local file paths for humans
- 🤖 Wiki: query commands for AI assistants

Part of openclaw-config-documentation enhancement (Phase 1)"
```

---

### Task 2: Add Brief Docs to $include Directives

**Files:**
- Modify: `.openclaw/openclaw.json:109-154`

**Step 1: Query wiki for each config domain**

Run queries to understand each include:
```bash
just wiki-docs "auth profiles provider configuration" --json
just wiki-docs "logging configuration levels" --json
just wiki-docs "agent configuration overview" --json
just wiki-docs "channel bindings routing" --json
just wiki-docs "messages configuration" --json
just wiki-docs "commands slash configuration" --json
just wiki-docs "telegram channels configuration" --json
just wiki-docs "memory QMD configuration" --json
just wiki-docs "skills configuration load" --json
just wiki-docs "plugins MCP configuration" --json
```

**Step 2: Add one-line doc + wiki query to each $include**

Update authentication include (lines 107-109):
```json5
  // ─────────────────────────────────────────────────────────────────────────
  // 🔐 Authentication
  // ─────────────────────────────────────────────────────────────────────────
  // Model provider authentication profiles (Anthropic, Google, etc.)
  // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md
  // 🤖 Wiki: just wiki-docs "auth profiles provider configuration"
  "auth": { "$include": "./config/auth.json5" },
```

**Step 3: Apply same pattern to all $include directives**

For each include (logging, agents, bindings, messages, commands, channels, memory, skills, plugins):
- Add brief one-line description
- Add 1 primary doc file path
- Add 1 primary wiki query
- Keep it light (these are just pointers to the actual files)

**Step 4: Commit include documentation**

```bash
git add .openclaw/openclaw.json
git commit -m "docs(config): add brief docs to all \$include directives

Add one-line descriptions, doc paths, and wiki queries to all 10
config includes. These serve as quick references before diving into
the actual config files.

Part of openclaw-config-documentation enhancement (Phase 1)"
```

---

## Phase 2: Complex Files

### Task 3: Enhance config/agents.json5

**Files:**
- Modify: `.openclaw/config/agents.json5`

**Step 1: Query wiki for agent configuration topics**

```bash
just wiki-docs "agent configuration model fallbacks" --json
just wiki-docs "memory QMD configuration" --json
just wiki-docs "memory hybrid search weights" --json
just wiki-docs "sandbox configuration docker mode" --json
just wiki-docs "sandbox scope session agent" --json
just wiki-docs "subagents configuration" --json
just wiki-docs "context pruning compaction" --json
```

**Step 2: Add version header to file**

Add after line 6 (before opening brace):
```json5
// Documentation current as of: OpenClaw v2026.2.14
// Last reviewed: 2026-02-16
```

**Step 3: Enhance Model Configuration section (lines 16-26)**

Update to:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Model Configuration
    // ─────────────────────────────────────────────────────────────────────────
    // Primary model + fallback chain for when primary fails
    // Model selection order: primary → fallbacks (in order) → provider scan
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/models.md:42-91
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/configuration.md:97-142
    // 🤖 Wiki: just wiki-docs "agent configuration model fallbacks"
    // 🤖 Wiki: just wiki-docs "model selection order"
    "model": {
      "primary": "anthropic/claude-opus-4-6",
      "fallbacks": [
        "anthropic/claude-sonnet-4-20250514",
        "google/gemini-3-pro-preview",
        "google/gemini-3-flash-preview",
        "anthropic/claude-3-5-haiku-20241022"
      ]
    },
```

**Step 4: Enhance Memory Search section (lines 61-88)**

Update to:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Memory Search (Vector + Hybrid Search)
    // ─────────────────────────────────────────────────────────────────────────
    // QMD-based semantic search over workspace memory files
    // Combines vector embeddings with keyword search via RRF fusion
    // Provider precedence: configured → openai → gemini → voyage → local
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/memory.md:92-153
    // 🤖 Wiki: just wiki-docs "memory QMD configuration"
    // 🤖 Wiki: just wiki-docs "memory hybrid search weights"
    // 🤖 Related: just wiki-docs "memory embedding providers"
    "memorySearch": {
      "provider": "openai",
      // ... rest of config
```

**Step 5: Enhance Context Management section (lines 92-108)**

Add docs about pruning and compaction:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Context Management
    // ─────────────────────────────────────────────────────────────────────────
    // Context pruning: removes old messages based on TTL or cache strategy
    // Compaction: triggers memory flush before context limit
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/memory.md:43-94
    // 🤖 Wiki: just wiki-docs "context pruning compaction"
    "contextPruning": {
      // ... config
```

**Step 6: Enhance Sandbox section (lines 152-162)**

Update to:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Sandbox Configuration
    // ─────────────────────────────────────────────────────────────────────────
    // Docker-based isolation for agent execution
    // Modes: off (disabled) | non-main (all except main) | all (all agents)
    // Scope: session (per-session) | agent (per-agent) | shared (one container)
    // Workspace access: ro (read-only) | rw (read-write)
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/cli/sandbox.md:1-57
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/sandboxing.md:111-161
    // 🤖 Wiki: just wiki-docs "sandbox configuration docker mode"
    // 🤖 Wiki: just wiki-docs "sandbox scope session agent shared"
    "sandbox": {
      "mode": "all",
      // ... rest
```

**Step 7: Enhance Subagents section (lines 134-148)**

Add documentation:
```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Subagents Configuration
    // ─────────────────────────────────────────────────────────────────────────
    // Settings for spawned subagents (parallel task execution)
    // Typically uses faster/cheaper models than primary agent
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/subagents.md
    // 🤖 Wiki: just wiki-docs "subagents configuration model"
    "subagents": {
      // ... config
```

**Step 8: Verify all queries return good results**

Test each query:
```bash
just wiki-docs "agent configuration model fallbacks"
just wiki-docs "memory QMD configuration"
# ... etc for all queries added
```

Check scores ≥ 0.7.

**Step 9: Commit agents.json5 enhancement**

```bash
git add .openclaw/config/agents.json5
git commit -m "docs(config): enhance agents.json5 with comprehensive documentation

Add inline docs to all major sections: model configuration, memory
search, context management, sandbox, and subagents.

Augments existing comments with:
- Local file paths for detailed docs
- Wiki queries for AI semantic search
- Version tracking header

Part of openclaw-config-documentation enhancement (Phase 2)"
```

---

### Task 4: Enhance config/channels.json5

**Files:**
- Create/Modify: `.openclaw/config/channels.json5`

**Step 1: Read current channels.json5 file**

```bash
cat .openclaw/config/channels.json5
```

Note the current structure and sections.

**Step 2: Query wiki for channel documentation**

```bash
just wiki-docs "telegram channels configuration" --json
just wiki-docs "telegram bot token setup" --json
just wiki-docs "channels dmPolicy pairing" --json
just wiki-docs "telegram groups requireMention" --json
```

**Step 3: Add file header with documentation**

Add at top of file:
```json5
// ═══════════════════════════════════════════════════════════════════════════
// 📡 TELEGRAM CHANNELS
// ═══════════════════════════════════════════════════════════════════════════
// Telegram bot configuration for DMs and groups
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/channels/telegram.md
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/configuration-reference.md:96-154
// 🤖 Wiki: just wiki-docs "telegram channels configuration"
// 🤖 Wiki: just wiki-docs "telegram groups requireMention"
```

**Step 4: Add docs to Telegram bot token section**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Bot Credentials
    // ─────────────────────────────────────────────────────────────────────────
    // Get bot token from @BotFather on Telegram
    // Token resolution: config → tokenFile → TELEGRAM_BOT_TOKEN env var
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/channels/telegram.md:1-68
    // 🤖 Wiki: just wiki-docs "telegram bot token setup"
    "enabled": true,
    "botToken": "${TELEGRAM_BOT_TOKEN}",
```

**Step 5: Add docs to DM policy section**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // DM Access Control
    // ─────────────────────────────────────────────────────────────────────────
    // Controls who can message the bot in direct messages
    // Policies: pairing (default, approval) | allowlist | open | disabled
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/channels/pairing.md
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/help/faq.md:793-822
    // 🤖 Wiki: just wiki-docs "channels dmPolicy pairing"
    "dmPolicy": "pairing",
```

**Step 6: Add docs to Groups section**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Group Configuration
    // ─────────────────────────────────────────────────────────────────────────
    // Per-group settings for requireMention, access control, topics
    // Privacy mode: bot must be admin OR privacy mode disabled to see all messages
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/channels/telegram.md:62-117
    // 🤖 Wiki: just wiki-docs "telegram groups configuration"
    // 🤖 Related: just wiki-verify "telegram requireMention behavior"
    "groups": {
      "*": { "requireMention": true }
    }
```

**Step 7: Verify queries and commit**

Test queries, then:
```bash
git add .openclaw/config/channels.json5
git commit -m "docs(config): enhance channels.json5 with Telegram documentation

Add comprehensive inline docs for Telegram configuration:
- Bot credentials and token resolution
- DM policies and pairing
- Group configuration and requireMention

Part of openclaw-config-documentation enhancement (Phase 2)"
```

---

### Task 5: Enhance config/memory.json5

**Files:**
- Create/Modify: `.openclaw/config/memory.json5`

**Step 1: Read current memory config**

```bash
cat .openclaw/config/memory.json5
```

**Step 2: Query wiki for memory documentation**

```bash
just wiki-docs "memory QMD configuration" --json
just wiki-docs "memory hybrid search" --json
just wiki-docs "memory paths collections" --json
just wiki-docs "memory embedding providers" --json
```

**Step 3: Add comprehensive file header**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🧠 MEMORY SYSTEM
// ═══════════════════════════════════════════════════════════════════════════
// QMD-based vector search over workspace memory files
// Hybrid search combines vector embeddings + keyword search (RRF fusion)
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/memory.md
// 🤖 Wiki: just wiki-docs "memory QMD configuration"
// 🤖 Wiki: just wiki-docs "memory hybrid search"
```

**Step 4: Document QMD paths and collections**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // QMD Paths and Collections
    // ─────────────────────────────────────────────────────────────────────────
    // Additional paths beyond default workspace memory/ directory
    // Collections are indexed separately with configurable update intervals
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/memory.md:230-295
    // 🤖 Wiki: just wiki-docs "memory paths collections"
    "qmd": {
      "paths": [
        // { "name": "docs", "path": "~/notes", "pattern": "**/*.md" }
      ]
    }
```

**Step 5: Document embedding providers**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Embedding Provider
    // ─────────────────────────────────────────────────────────────────────────
    // Provider precedence: configured → openai → gemini → voyage → local
    // Local uses node-llama-cpp (requires pnpm approve-builds)
    // Remote requires API keys from auth profiles or env vars
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/memory.md:92-127
    // 🤖 Wiki: just wiki-docs "memory embedding providers"
    // 🤖 Related: just wiki-docs "memory local vs remote"
```

**Step 6: Verify and commit**

```bash
git add .openclaw/config/memory.json5
git commit -m "docs(config): enhance memory.json5 with QMD documentation

Add comprehensive docs for memory system configuration:
- QMD paths and collections
- Embedding providers (local vs remote)
- Hybrid search setup

Part of openclaw-config-documentation enhancement (Phase 2)"
```

---

## Phase 3: Medium Complexity Files

### Task 6: Enhance config/bindings.json5

**Files:**
- Create/Modify: `.openclaw/config/bindings.json5`

**Step 1: Read current bindings config**

**Step 2: Query wiki**

```bash
just wiki-docs "channel bindings agent mapping" --json
just wiki-docs "bindings match precedence" --json
```

**Step 3: Add file header and documentation**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🔗 CHANNEL BINDINGS
// ═══════════════════════════════════════════════════════════════════════════
// Channel-to-agent routing configuration
// Bindings route incoming messages to specific agents based on channel, peer, etc.
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/multi-agent.md:176-243
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/channels/channel-routing.md:52-105
// 🤖 Wiki: just wiki-docs "channel bindings agent mapping"
// 🤖 Wiki: just wiki-docs "bindings match precedence"
```

**Step 4: Document binding precedence**

Add as comment in appropriate location:
```json5
    // Binding precedence (highest to lowest):
    // 1. Peer-specific (exact peer ID match)
    // 2. Guild/Team + role match
    // 3. Account-specific channel
    // 4. Channel-wide (accountId: "*")
    // 5. Default agent
```

**Step 5: Commit**

```bash
git add .openclaw/config/bindings.json5
git commit -m "docs(config): enhance bindings.json5 with routing documentation

Add docs for channel-to-agent routing:
- Binding precedence rules
- Multi-agent patterns
- Match criteria

Part of openclaw-config-documentation enhancement (Phase 3)"
```

---

### Task 7: Enhance config/skills.json5

**Files:**
- Create/Modify: `.openclaw/config/skills.json5`

**Step 1: Query wiki**

```bash
just wiki-docs "skills configuration load install" --json
just wiki-docs "skills allowBundled extraDirs" --json
```

**Step 2: Add documentation**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🛠️ SKILLS
// ═══════════════════════════════════════════════════════════════════════════
// Skills loading, installation, and per-skill configuration
// Skills are AgentSkills-compatible SKILL.md files
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/tools/skills-config.md
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/tools/skills.md
// 🤖 Wiki: just wiki-docs "skills configuration load install"
```

**Step 3: Document load section**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Skills Loading
    // ─────────────────────────────────────────────────────────────────────────
    // extraDirs: additional directories to scan for custom skills
    // watch: reload skills when SKILL.md files change
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/tools/skills-config.md:1-52
    // 🤖 Wiki: just wiki-docs "skills load extraDirs watch"
    "load": {
      "extraDirs": ["~/custom-skills"],
      "watch": true,
      "watchDebounceMs": 250
    }
```

**Step 4: Commit**

```bash
git add .openclaw/config/skills.json5
git commit -m "docs(config): enhance skills.json5 with loading documentation

Add docs for skills configuration:
- Loading from bundled and custom directories
- Installation preferences
- Watch mode

Part of openclaw-config-documentation enhancement (Phase 3)"
```

---

### Task 8: Enhance config/plugins.json5

**Files:**
- Create/Modify: `.openclaw/config/plugins.json5`

**Step 1: Query wiki**

```bash
just wiki-docs "plugins MCP configuration" --json
```

**Step 2: Add documentation**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🔌 PLUGINS
// ═══════════════════════════════════════════════════════════════════════════
// MCP plugin configuration and management
// Plugins extend OpenClaw with additional channels, tools, integrations
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/tools/plugin.md
// 🤖 Wiki: just wiki-docs "plugins MCP configuration"
```

**Step 3: Commit**

```bash
git add .openclaw/config/plugins.json5
git commit -m "docs(config): enhance plugins.json5 with MCP documentation

Add docs for plugin configuration and MCP integration.

Part of openclaw-config-documentation enhancement (Phase 3)"
```

---

### Task 9: Enhance config/logging.json5

**Files:**
- Create/Modify: `.openclaw/config/logging.json5`

**Step 1: Query wiki**

```bash
just wiki-docs "logging configuration levels" --json
just wiki-docs "logging file format JSONL" --json
```

**Step 2: Add documentation**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 📝 LOGGING
// ═══════════════════════════════════════════════════════════════════════════
// Log levels, file paths, and output formatting
// File logs are JSONL format, console output is TTY-aware
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/logging.md
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/logging.md
// 🤖 Wiki: just wiki-docs "logging configuration levels"
```

**Step 3: Document log levels**

```json5
    // ─────────────────────────────────────────────────────────────────────────
    // Log Level
    // ─────────────────────────────────────────────────────────────────────────
    // Levels: error | warn | info | debug | trace
    // Default: info (production), debug (development)
    // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/logging.md:1-72
    // 🤖 Wiki: just wiki-docs "logging levels configuration"
    "level": "info"
```

**Step 4: Commit**

```bash
git add .openclaw/config/logging.json5
git commit -m "docs(config): enhance logging.json5 with configuration documentation

Add docs for logging configuration:
- Log levels and when to use them
- File paths and rolling logs
- Console formatting

Part of openclaw-config-documentation enhancement (Phase 3)"
```

---

## Phase 4: Remaining Files

### Task 10: Enhance config/auth.json5

**Files:**
- Modify: `.openclaw/config/auth.json5:1-32`

**Step 1: Query wiki**

```bash
just wiki-docs "authentication profiles provider" --json
just wiki-docs "auth order fallbacks" --json
```

**Step 2: Replace/enhance header**

Replace lines 1-6 with:
```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🔐 AUTHENTICATION PROFILES
// ═══════════════════════════════════════════════════════════════════════════
// Model provider authentication profiles (Anthropic, Google, etc.)
// Actual secrets stored in ~/.openclaw/agents/<agentId>/agent/auth-profiles.json
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/oauth.md
// 🤖 Wiki: just wiki-docs "authentication profiles provider"
// 🤖 Wiki: just wiki-docs "auth mode token vs oauth"
```

**Step 3: Document profiles section**

Update lines 9-11:
```json5
  // ─────────────────────────────────────────────────────────────────────────
  // Authentication Profiles
  // ─────────────────────────────────────────────────────────────────────────
  // Define provider + mode pairs (token, api_key, oauth, setup-token)
  // Profile IDs format: <provider>:<descriptor>
  // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md:1-61
  // 🤖 Wiki: just wiki-docs "auth profiles mode"
  "profiles": {
```

**Step 4: Document order section**

Update lines 23-26:
```json5
  // ─────────────────────────────────────────────────────────────────────────
  // Profile Priority Order
  // ─────────────────────────────────────────────────────────────────────────
  // Defines order in which profiles are tried when authenticating
  // Used for fallback when primary profile fails or has rate limits
  // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/model-failover.md
  // 🤖 Wiki: just wiki-docs "auth order fallbacks"
  "order": {
```

**Step 5: Commit**

```bash
git add .openclaw/config/auth.json5
git commit -m "docs(config): enhance auth.json5 with authentication documentation

Add comprehensive docs for authentication profiles:
- Profile definitions (provider + mode)
- Profile priority order and fallbacks
- OAuth vs API key vs setup-token

Part of openclaw-config-documentation enhancement (Phase 4)"
```

---

### Task 11: Enhance config/messages.json5

**Files:**
- Create/Modify: `.openclaw/config/messages.json5`

**Step 1: Query wiki**

```bash
just wiki-docs "messages configuration" --json
just wiki-docs "message streaming behavior" --json
```

**Step 2: Add documentation**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 💬 MESSAGE SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
// Message behavior: streaming, typing indicators, formatting
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/configuration-reference.md
// 🤖 Wiki: just wiki-docs "messages configuration"
```

**Step 3: Commit**

```bash
git add .openclaw/config/messages.json5
git commit -m "docs(config): enhance messages.json5 with behavior documentation

Add docs for message behavior configuration.

Part of openclaw-config-documentation enhancement (Phase 4)"
```

---

### Task 12: Enhance config/commands.json5

**Files:**
- Create/Modify: `.openclaw/config/commands.json5`

**Step 1: Query wiki**

```bash
just wiki-docs "commands slash configuration" --json
```

**Step 2: Add documentation**

```json5
// ═══════════════════════════════════════════════════════════════════════════
// ⚡ COMMAND SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
// Slash commands configuration and permissions
// Documentation current as of: OpenClaw v2026.2.14
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/tools/slash-commands.md
// 🤖 Wiki: just wiki-docs "commands slash configuration"
```

**Step 3: Commit**

```bash
git add .openclaw/config/commands.json5
git commit -m "docs(config): enhance commands.json5 with slash command documentation

Add docs for command configuration.

Part of openclaw-config-documentation enhancement (Phase 4)"
```

---

## Phase 5: Validation & Documentation

### Task 13: Validate All File Paths

**Step 1: Create validation script**

Create: `tools/validate-config-docs.sh`
```bash
#!/usr/bin/env bash
# Validate all doc paths in OpenClaw config files

set -euo pipefail

BASE_PATH="/path/to/astromech/tools/wiki/source/docs"
ERRORS=0

echo "Validating config documentation paths..."

# Extract all 📄 Docs: paths from config files
grep -r "📄 Docs:" .openclaw/ | while IFS=: read -r file line_num content; do
  # Extract path from comment
  doc_path=$(echo "$content" | sed -n 's/.*📄 Docs: \([^:]*\).*/\1/p')

  if [[ -n "$doc_path" ]]; then
    if [[ ! -f "$doc_path" ]]; then
      echo "❌ Missing: $doc_path (referenced in $file:$line_num)"
      ((ERRORS++))
    else
      echo "✅ Valid: $doc_path"
    fi
  fi
done

if [[ $ERRORS -eq 0 ]]; then
  echo ""
  echo "✅ All documentation paths are valid!"
  exit 0
else
  echo ""
  echo "❌ Found $ERRORS invalid path(s)"
  exit 1
fi
```

**Step 2: Make script executable and run**

```bash
chmod +x tools/validate-config-docs.sh
./tools/validate-config-docs.sh
```

Fix any broken paths found.

**Step 3: Commit validation script**

```bash
git add tools/validate-config-docs.sh
git commit -m "tools: add config documentation path validator

Add script to validate all 📄 Docs: paths in config files.
Ensures file paths stay in sync with OpenClaw wiki structure.

Part of openclaw-config-documentation enhancement (Phase 5)"
```

---

### Task 14: Test All Wiki Queries

**Step 1: Create query testing script**

Create: `tools/test-wiki-queries.sh`
```bash
#!/usr/bin/env bash
# Test all wiki queries from config files

set -euo pipefail

echo "Testing wiki queries from config files..."
TOTAL=0
PASSED=0
FAILED=0

# Extract all 🤖 Wiki: queries
grep -r "🤖 Wiki:" .openclaw/ | while IFS= read -r line; do
  # Extract query
  query=$(echo "$line" | sed -n 's/.*just \(wiki-[^ ]*\) "\([^"]*\)".*/\1 "\2"/p')

  if [[ -n "$query" ]]; then
    ((TOTAL++))
    echo ""
    echo "Testing: $query"

    # Run query and check for results
    if just $query --json | jq -e '.results[0].score >= 0.7' > /dev/null 2>&1; then
      echo "  ✅ PASS (score ≥ 0.7)"
      ((PASSED++))
    else
      echo "  ❌ FAIL (score < 0.7 or no results)"
      ((FAILED++))
    fi
  fi
done

echo ""
echo "======================================"
echo "Total queries: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "======================================"

[[ $FAILED -eq 0 ]]
```

**Step 2: Run tests**

```bash
chmod +x tools/test-wiki-queries.sh
./tools/test-wiki-queries.sh
```

Review any failing queries and refine them.

**Step 3: Commit**

```bash
git add tools/test-wiki-queries.sh
git commit -m "tools: add wiki query testing script

Add script to test all 🤖 Wiki: queries from config files.
Validates that queries return relevant results (score ≥ 0.7).

Part of openclaw-config-documentation enhancement (Phase 5)"
```

---

### Task 15: Update CLAUDE.md Documentation

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add section about config documentation**

Add new section after the wiki section:
```markdown
## 📝 Config File Documentation

All OpenClaw configuration files now include inline documentation:

**For humans (📄 Docs:):**
- Direct file paths to local OpenClaw documentation
- Clickable in IDE for instant navigation
- Line ranges for precise location

**For AI (🤖 Wiki:):**
- Wiki query commands using `just wiki-docs "query"`
- Semantic search over OpenClaw knowledge base
- Related queries for troubleshooting

**Example:**
```json5
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md:1-61
// 🤖 Wiki: just wiki-docs "gateway authentication token mode"
```

**Files with inline docs:**
- `.openclaw/openclaw.json` (gateway infrastructure)
- `.openclaw/config/*.json5` (all 10 modular configs)

**Validation tools:**
- `tools/validate-config-docs.sh` - Check all doc paths exist
- `tools/test-wiki-queries.sh` - Test all wiki queries return good results
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: document inline config documentation system

Add section to CLAUDE.md explaining the inline documentation system
in OpenClaw config files, including usage for both humans and AI.

Part of openclaw-config-documentation enhancement (Phase 5)"
```

---

### Task 16: Create Final Summary Document

**Step 1: Create summary**

Create: `docs/openclaw-config-documentation-summary.md`
```markdown
# OpenClaw Config Documentation - Implementation Summary

**Completed:** 2026-02-16
**Status:** ✅ Complete

## Overview

Enhanced all 11 OpenClaw configuration files with inline documentation combining:
- 📄 Local file paths (for human IDE navigation)
- 🤖 Wiki queries (for AI semantic search)
- Version tracking and maintenance guidelines

## Files Enhanced

### Main File
- [x] `.openclaw/openclaw.json` - Gateway infrastructure + include directives

### Modular Configs (Complex)
- [x] `config/agents.json5` - Droid fleet, models, memory, sandbox
- [x] `config/channels.json5` - Telegram configuration
- [x] `config/memory.json5` - QMD memory system

### Modular Configs (Medium)
- [x] `config/bindings.json5` - Channel-to-agent routing
- [x] `config/skills.json5` - Skills loading and installation
- [x] `config/plugins.json5` - MCP plugins
- [x] `config/logging.json5` - Log levels and formatting

### Modular Configs (Simple)
- [x] `config/auth.json5` - Authentication profiles
- [x] `config/messages.json5` - Message behavior
- [x] `config/commands.json5` - Slash commands

## Validation Tools

- `tools/validate-config-docs.sh` - Validates all doc paths exist
- `tools/test-wiki-queries.sh` - Tests all wiki queries return good results

## Maintenance

**Update triggers:**
1. OpenClaw wiki updates (`just wiki-latest`)
2. Config schema changes
3. User confusion about settings

**Version tracking:**
Each file header includes:
```json5
// Documentation current as of: OpenClaw v2026.2.14
// Last reviewed: 2026-02-16
```

## Usage

**For humans:**
- Click 📄 Docs paths in IDE to read full documentation
- Paths are absolute and jump to specific line ranges

**For AI:**
- Copy 🤖 Wiki queries to search OpenClaw knowledge base
- Queries tested to return relevant results (score ≥ 0.7)
- Related queries for troubleshooting edge cases

## Statistics

- **Files enhanced:** 11
- **Doc paths added:** ~40
- **Wiki queries added:** ~50
- **Validation scripts:** 2

## Next Steps

1. Use configs for 1-2 weeks
2. Note what's helpful vs noise
3. Refine based on actual usage
4. Update on next OpenClaw release
5. Consider automation if maintenance becomes burdensome
```

**Step 2: Commit summary**

```bash
git add docs/openclaw-config-documentation-summary.md
git commit -m "docs: add implementation summary for config documentation

Summarize the complete enhancement of all OpenClaw config files
with inline documentation, validation tools, and maintenance strategy.

Part of openclaw-config-documentation enhancement (Phase 5)"
```

---

### Task 17: Final Validation & Cleanup

**Step 1: Run all validation**

```bash
# Validate paths
./tools/validate-config-docs.sh

# Test queries
./tools/test-wiki-queries.sh

# Check all files are formatted correctly
find .openclaw -name "*.json*" -exec echo "Checking {}" \; -exec cat {} > /dev/null \;
```

**Step 2: Review all commits**

```bash
git log --oneline | head -20
```

Ensure all commits are well-formed and follow conventions.

**Step 3: Create final summary commit**

```bash
git commit --allow-empty -m "docs(config): complete OpenClaw config documentation enhancement

All 11 OpenClaw configuration files now include comprehensive inline
documentation with local doc paths (for humans) and wiki queries
(for AI assistants).

Summary:
- Main openclaw.json: gateway infrastructure + include directives
- 10 modular config/*.json5 files fully documented
- 3 density levels based on complexity
- ~40 doc paths, ~50 wiki queries
- 2 validation tools (paths + queries)
- Version tracking in all files

This makes OpenClaw configs self-documenting navigation hubs that
serve both human operators and AI assistants.

Implementation phases:
1. Foundation (main file)
2. Complex files (agents, channels, memory)
3. Medium files (bindings, skills, plugins, logging)
4. Remaining files (auth, messages, commands)
5. Validation & documentation

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Completion Checklist

- [ ] All 11 config files enhanced with inline documentation
- [ ] All doc paths validated (exist and are readable)
- [ ] All wiki queries tested (return score ≥ 0.7)
- [ ] Validation tools created and working
- [ ] CLAUDE.md updated with new documentation section
- [ ] Summary document created
- [ ] All commits follow conventions
- [ ] Final validation passed

---

## Notes

- **DRY principle:** Reuse doc paths across related sections
- **YAGNI principle:** Only add docs that are genuinely helpful
- **TDD for queries:** Test each query returns good results before committing
- **Frequent commits:** One commit per file/phase for easy review

## Success Criteria

**Human users:**
- Can find relevant docs in <30 seconds
- IDE paths are clickable and accurate
- Discover features by browsing config

**AI assistants:**
- Wiki queries return relevant results
- Can self-serve configuration questions
- Less guessing about OpenClaw behavior

**Maintainability:**
- Paths stay in sync with wiki updates
- Queries remain relevant across versions
- Documentation doesn't become stale
