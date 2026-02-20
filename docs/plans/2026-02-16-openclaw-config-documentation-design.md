# OpenClaw Config Documentation Enhancement

**Date:** 2026-02-16
**Status:** Approved
**Purpose:** Make OpenClaw configuration self-documenting with inline references to local docs (for humans) and wiki queries (for AI)

---

## Overview

Enhance all OpenClaw configuration files (main `openclaw.json` + 10 modular `config/*.json5` includes) with inline documentation that:

1. **For humans:** Direct file paths to local OpenClaw docs (clickable in IDE)
2. **For AI assistants:** Wiki search queries using the `wiki-search` skill
3. **Self-documenting:** Config files become navigation hubs to learn OpenClaw

## Goals

- **Discoverability:** Browse config → discover OpenClaw features
- **Quick reference:** Need to configure X → docs right there
- **AI-friendly:** AI can query wiki without guessing commands
- **Maintainable:** Stays in sync with OpenClaw releases
- **Clean:** Informative without being overwhelming

## Non-Goals

- Replace official OpenClaw documentation
- Document every possible value or edge case
- Add docs to self-explanatory settings (ports, simple strings)
- Create new documentation (only reference existing)

---

## Design Decisions

### Audience: Hybrid (Human + AI)

**Human users need:**
- Quick access to relevant documentation
- Clickable file paths in their IDE
- Context about what settings control

**AI assistants need:**
- Actionable wiki queries to search semantics
- Context about related documentation topics
- Guidance on troubleshooting queries

### Format: Inline Comments with Emojis

**Emoji convention:**
- `📄 Docs:` = File path for humans (IDE clickable)
- `🤖 Wiki:` = Primary wiki query for AI
- `🤖 Related:` = Secondary/troubleshooting queries

**Why inline vs. separate doc:**
- Context exactly where you need it
- Single source of truth (config file)
- No file-switching to understand settings
- AI can see context without extra reads

### Scope: All Config Files

**Main file:** `openclaw.json`
- Gateway infrastructure sections
- Brief docs on each $include

**Modular includes (10 files):**
1. `config/auth.json5` - Authentication profiles
2. `config/logging.json5` - Logging configuration
3. `config/agents.json5` - Droid fleet (already well-commented, augment)
4. `config/bindings.json5` - Channel-to-agent routing
5. `config/channels.json5` - Telegram, etc.
6. `config/messages.json5` - Message behavior
7. `config/commands.json5` - Slash commands
8. `config/memory.json5` - QMD memory system
9. `config/skills.json5` - Skills loading/installation
10. `config/plugins.json5` - MCP plugins

---

## Documentation Pattern

### Three-Tier Hierarchy

```json5
// ═══════════════════════════════════════════════════════════════════════════
// 🔑 MAJOR SECTION HEADER (File or Top-Level Config Area)
// ═══════════════════════════════════════════════════════════════════════════
// One-line description of what this section controls
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/path/to/file.md:line-range
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/another/file.md
// 🤖 Wiki: just wiki-docs "primary search query"
// 🤖 Related: just wiki-docs "secondary related query"

{
  // ─────────────────────────────────────────────────────────────────────────
  // Subsection Name
  // ─────────────────────────────────────────────────────────────────────────
  // Brief explanation of this subsection's purpose
  // 📄 Docs: /path/to/astromech/tools/wiki/source/docs/specific/topic.md:42-58
  // 🤖 Wiki: just wiki-docs "focused subsection query"

  "setting": "value",

  // ─────────────────────────────────────────────────────────────────────────
  // Another Subsection
  // Brief inline note (no extra docs needed for simple settings)
  // ─────────────────────────────────────────────────────────────────────────
  "simpleSetting": true
}
```

### Documentation Density Levels

**Level 1 - Heavy (Complex/Critical):**
- Multiple file references
- 2-3 wiki queries (primary + related)
- Detailed inline explanations
- **Examples:** agents.defaults, gateway, sandbox, memory

**Level 2 - Medium (Important but straightforward):**
- 1-2 file references
- 1 primary wiki query
- Brief inline notes
- **Examples:** channels, bindings, skills, logging

**Level 3 - Light (Simple/self-explanatory):**
- Optional: 1 file reference OR 1 wiki query
- Minimal inline notes
- **Examples:** simple booleans, basic strings, obvious settings

### Path Format

**Always use absolute paths:**
```
📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md:1-61
```

**Include line ranges when available:**
- From wiki results: `"lines": "1-61"` → append `:1-61`
- Makes it easy to jump to exact section in IDE
- Omit if uncertain or if docs reorganized

**Base path for all docs:**
```
/path/to/astromech/tools/wiki/source/docs/
```

---

## Per-File Enhancement Strategy

### Main File: `openclaw.json`

**Current state:** Good header, $include list with emojis

**Enhancements:**
- Add docs/wiki to gateway section subsections:
  - Server settings (port, mode, bind)
  - Control UI
  - Authentication
  - Network (trustedProxies)
  - Remote gateway connection
  - Config reload behavior
  - HTTP endpoints
- Add brief docs/wiki comment above each $include line

**Example enhancement:**
```json5
// ─────────────────────────────────────────────────────────────────────────
// 🔐 Authentication
// ─────────────────────────────────────────────────────────────────────────
// Model provider authentication profiles (Anthropic, Google, etc.)
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/authentication.md
// 🤖 Wiki: just wiki-docs "auth profiles provider configuration"
"auth": { "$include": "./config/auth.json5" },
```

### `config/auth.json5`

**Documentation Level:** Heavy (Level 1)

**Key topics:**
- Authentication profiles (provider, mode)
- Profile order and fallback behavior
- OAuth vs API key vs setup-token

**Key docs:**
- `/tools/wiki/source/docs/gateway/authentication.md`
- `/tools/wiki/source/docs/concepts/oauth.md`

**Key queries:**
- `just wiki-docs "authentication profiles provider"`
- `just wiki-docs "auth order fallbacks"`

### `config/logging.json5`

**Documentation Level:** Medium (Level 2)

**Key topics:**
- Log levels (info, debug, trace)
- File paths and rolling logs
- Console formatting
- OTLP/OpenTelemetry (if configured)

**Key docs:**
- `/tools/wiki/source/docs/logging.md`
- `/tools/wiki/source/docs/gateway/logging.md`

**Key queries:**
- `just wiki-docs "logging configuration levels"`
- `just wiki-docs "logging file format JSONL"`

### `config/agents.json5`

**Documentation Level:** Heavy (Level 1)

**Current state:** Already well-commented

**Enhancement approach:** Augment existing
- Add file paths to existing section headers
- Add wiki queries for complex sections
- Keep existing detailed inline comments

**Key sections needing docs:**
- Model configuration (primary + fallbacks)
- Memory search (QMD, hybrid search, providers)
- Context management (pruning, compaction)
- Sandbox configuration
- Subagents configuration

**Key docs:**
- `/tools/wiki/source/docs/gateway/configuration.md:97-142`
- `/tools/wiki/source/docs/concepts/models.md`
- `/tools/wiki/source/docs/concepts/memory.md`
- `/tools/wiki/source/docs/cli/sandbox.md`
- `/tools/wiki/source/docs/gateway/sandboxing.md`

**Key queries:**
- `just wiki-docs "agent configuration model fallbacks"`
- `just wiki-docs "memory QMD configuration"`
- `just wiki-docs "memory hybrid search weights"`
- `just wiki-docs "sandbox configuration docker mode"`
- `just wiki-docs "subagents configuration"`

### `config/bindings.json5`

**Documentation Level:** Medium (Level 2)

**Key topics:**
- Channel-to-agent routing
- Binding precedence and matching
- Multi-agent patterns
- Per-peer overrides

**Key docs:**
- `/tools/wiki/source/docs/concepts/multi-agent.md:176-243`
- `/tools/wiki/source/docs/channels/channel-routing.md`

**Key queries:**
- `just wiki-docs "channel bindings agent mapping"`
- `just wiki-docs "bindings match precedence"`

### `config/channels.json5`

**Documentation Level:** Heavy (Level 1)

**Key topics:**
- Telegram bot configuration
- DM policies (pairing, allowlist, open)
- Group configuration (requireMention)
- Multi-account setup (if applicable)

**Key docs:**
- `/tools/wiki/source/docs/channels/telegram.md`
- `/tools/wiki/source/docs/gateway/configuration-reference.md:96-154`
- `/tools/wiki/source/docs/channels/pairing.md`

**Key queries:**
- `just wiki-docs "telegram channels configuration"`
- `just wiki-docs "telegram bot token setup"`
- `just wiki-docs "channels dmPolicy pairing"`
- `just wiki-docs "telegram groups requireMention"`
- `just wiki-verify "telegram requireMention behavior"` (if edge cases)

### `config/messages.json5`

**Documentation Level:** Medium (Level 2)

**Key topics:**
- Message streaming behavior
- Typing indicators
- Block streaming settings

**Key queries:**
- `just wiki-docs "messages configuration"`
- `just wiki-docs "message streaming behavior"`

### `config/commands.json5`

**Documentation Level:** Medium (Level 2)

**Key topics:**
- Slash commands configuration
- Command permissions
- Custom commands

**Key queries:**
- `just wiki-docs "commands slash configuration"`
- `just wiki-docs "commands permissions"`

### `config/memory.json5`

**Documentation Level:** Heavy (Level 1)

**Key topics:**
- QMD configuration and paths
- Embedding providers (OpenAI, Gemini, local)
- Hybrid search (vector + text weights)
- Collections and indexing
- Session memory (experimental)

**Key docs:**
- `/tools/wiki/source/docs/concepts/memory.md`

**Key queries:**
- `just wiki-docs "memory QMD configuration"`
- `just wiki-docs "memory hybrid search"`
- `just wiki-docs "memory paths collections"`
- `just wiki-docs "memory embedding providers"`

### `config/skills.json5`

**Documentation Level:** Medium (Level 2)

**Key topics:**
- Skills loading (bundled vs custom)
- Extra directories
- Installation preferences (Brew, npm)
- Per-skill configuration
- Watch mode

**Key docs:**
- `/tools/wiki/source/docs/tools/skills-config.md`
- `/tools/wiki/source/docs/tools/skills.md`

**Key queries:**
- `just wiki-docs "skills configuration load install"`
- `just wiki-docs "skills allowBundled extraDirs"`
- `just wiki-docs "skills install preferences"`

### `config/plugins.json5`

**Documentation Level:** Medium (Level 2)

**Key topics:**
- MCP plugin configuration
- Plugin installation
- Enabling/disabling plugins
- Plugin entries

**Key docs:**
- `/tools/wiki/source/docs/tools/plugin.md`

**Key queries:**
- `just wiki-docs "plugins MCP configuration"`
- `just wiki-docs "plugins install enable"`

---

## Wiki Query Selection Criteria

### Query Construction Patterns

**Pattern 1: Feature + Context**
```bash
just wiki-docs "<feature> <context> <specifics>"
```

Examples:
- `just wiki-docs "sandbox configuration docker mode"`
- `just wiki-docs "telegram groups requireMention"`
- `just wiki-docs "memory QMD configuration"`

**Pattern 2: Concept Overview**
```bash
just wiki-docs "<major concept> overview"
```

Examples:
- `just wiki-docs "authentication profiles overview"`
- `just wiki-docs "channel bindings routing"`

**Pattern 3: Troubleshooting/Verification**
```bash
just wiki-verify "<setting> behavior"
```

Examples:
- `just wiki-verify "requireMention groups"`
- `just wiki-verify "sandbox network isolation"`

### When to Include Multiple Queries

**Include 2-3 queries when:**
- Section is complex with multiple sub-concepts
- Common troubleshooting scenarios exist
- Related configuration in different files
- Example: Sandbox (mode + scope + Docker config)

**Stick to 1 query when:**
- Setting is straightforward
- Docs are comprehensive in one place
- No common edge cases
- Example: Simple boolean flags

### Query Scope Selection

**Use `wiki-docs` when:**
- Configuration questions (most common)
- User-facing features
- Setup and deployment

**Use `wiki-code` when:**
- Implementation details needed
- Debugging internal behavior
- Understanding lifecycle/flow

**Use `wiki-verify` when:**
- Docs might be unclear
- Behavior seems unexpected
- Need implementation + docs cross-reference

### Query Quality Criteria

For each query:
1. Run it manually during implementation
2. Verify score ≥ 0.7 for top results
3. Check that returned docs are actually relevant
4. If poor results, refine query terms
5. Document the final query in config file

---

## Maintenance Strategy

### Update Triggers

**1. OpenClaw wiki updates**
- Check: `just wiki-latest`
- Review changelog: `just wiki-since v2026.2.14`
- Update affected sections
- Re-test queries for new docs

**2. Config schema changes**
- New settings → query wiki, add docs
- Deprecated settings → mark with comment
- Renamed settings → update queries

**3. Documentation improvements**
- Better docs upstream → update paths
- New troubleshooting guides → add related queries

**4. User confusion**
- Section causes questions → add context
- Queries return poor results → refine

### Maintenance Workflow

```bash
# Check for new release
just wiki-latest

# See what changed
just wiki-since v2026.2.14

# Re-run affected queries
just wiki-docs "affected feature" --json

# Update paths and queries in config files
# Test that queries return good results
```

### Path Stability

**Update strategy:**
- Line range shifts <10 lines: update it
- Major restructuring: drop line range, keep file path
- File moves: update full path

### Query Stability

- Queries are semantic (more stable than paths)
- OpenClaw wiki uses query expansion
- `"tts"` → finds "text-to-speech", "voice", etc.
- Re-test queries after major releases

### Version Tracking

Add version comment to file headers:
```json5
// Documentation current as of: OpenClaw v2026.2.14
// Last reviewed: 2026-02-16
```

### Validation Checklist

Before committing:
- [ ] All file paths exist and are readable
- [ ] All wiki queries tested (score ≥ 0.7)
- [ ] Line ranges accurate or omitted
- [ ] Emojis consistent (📄 for paths, 🤖 for queries)
- [ ] No duplicate info between main and includes
- [ ] Comments reasonably formatted

---

## Implementation Approach

### Migration Path

**Phase 1: Foundation**
1. Main `openclaw.json` gateway section
2. Prove the pattern works

**Phase 2: Complex Files**
3. `config/agents.json5` (augment existing)
4. `config/channels.json5`
5. `config/memory.json5`

**Phase 3: Medium Files**
6. `config/bindings.json5`
7. `config/skills.json5`
8. `config/plugins.json5`
9. `config/logging.json5`

**Phase 4: Remaining Files**
10. `config/auth.json5`
11. `config/messages.json5`
12. `config/commands.json5`

**Phase 5: Review & Refine**
- Use for 1-2 weeks
- Note helpful vs. noise
- Adjust based on actual usage
- Create follow-up improvements

### Success Criteria

**For humans:**
- Can find relevant docs in <30 seconds
- IDE file paths are clickable and correct
- Discover features by browsing config

**For AI:**
- Wiki queries return relevant results
- AI can self-serve configuration questions
- Less guessing about OpenClaw behavior

**For maintainability:**
- Paths stay in sync with wiki updates
- Queries remain relevant across versions
- Documentation doesn't become stale

---

## Examples

### Example 1: Gateway Authentication

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
// ─────────────────────────────────────────────────────────────────────────
"auth": {
  "mode": "token",
  "token": "${OPENCLAW_GATEWAY_TOKEN}"
}
```

### Example 2: Memory Search Configuration

```json5
// ─────────────────────────────────────────────────────────────────────────
// Memory Search (Vector + Hybrid Search)
// ─────────────────────────────────────────────────────────────────────────
// QMD-based semantic search over workspace memory files
// Combines vector embeddings with keyword search (RRF fusion)
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/concepts/memory.md:92-153
// 🤖 Wiki: just wiki-docs "memory QMD configuration"
// 🤖 Wiki: just wiki-docs "memory hybrid search weights"
// 🤖 Related: just wiki-verify "memory search providers"
// ─────────────────────────────────────────────────────────────────────────
"memorySearch": {
  "provider": "openai",
  "model": "text-embedding-3-small",
  "query": {
    "hybrid": {
      "enabled": true,
      "vectorWeight": 0.7,
      "textWeight": 0.3,
      "candidateMultiplier": 4
    }
  }
}
```

### Example 3: Sandbox Configuration

```json5
// ─────────────────────────────────────────────────────────────────────────
// Sandbox Configuration
// ─────────────────────────────────────────────────────────────────────────
// Docker-based isolation for agent execution
// Modes: off (disabled) | non-main (all except main agent) | all
// Scope: session (per-session container) | agent (per-agent) | shared
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/cli/sandbox.md:1-57
// 📄 Docs: /path/to/astromech/tools/wiki/source/docs/gateway/sandboxing.md:111-161
// 🤖 Wiki: just wiki-docs "sandbox configuration docker mode"
// 🤖 Wiki: just wiki-docs "sandbox scope session agent shared"
// ─────────────────────────────────────────────────────────────────────────
"sandbox": {
  "mode": "all",
  "scope": "agent",
  "workspaceAccess": "rw",
  "docker": {
    "image": "astromech-sbx-base:v1",
    "network": "bridge",
    "containerPrefix": "astromech-sbx-"
  }
}
```

---

## Risks & Mitigations

### Risk: Documentation bloat

**Mitigation:**
- Use 3 density levels
- Skip docs for obvious settings
- Maximum 2-3 queries per section

### Risk: Paths become stale

**Mitigation:**
- Track OpenClaw version in headers
- Check `just wiki-latest` regularly
- Drop line ranges if uncertain

### Risk: Queries return poor results

**Mitigation:**
- Test all queries during implementation
- Require score ≥ 0.7
- Refine or remove if not useful

### Risk: Too much maintenance

**Mitigation:**
- Start simple, add complexity only if useful
- Automate validation later if needed
- Accept some staleness for low-traffic sections

---

## Future Enhancements

**Potential improvements:**
1. Validation script for paths/queries
2. Pre-commit hook for format consistency
3. Bot to notify on wiki updates
4. Auto-generate query suggestions
5. Link to specific config examples in docs

**Not in scope for v1:**
- Keep it manual and simple initially
- Add automation only if maintenance burden is real

---

## Conclusion

This design creates **self-documenting configuration files** that serve both human operators and AI assistants. By embedding documentation directly in the config files, we reduce context-switching and create a navigable knowledge base.

The pattern is:
- **Simple:** File paths + wiki queries
- **Actionable:** Clickable in IDE, runnable by AI
- **Maintainable:** Track versions, test queries
- **Scalable:** 3 density levels adapt to complexity

Implementation will be phased, starting with the main file and most complex includes, then expanding based on actual usage patterns.
