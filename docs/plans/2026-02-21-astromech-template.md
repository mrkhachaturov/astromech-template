# Astromech Template Export Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a public `astromech-template` repo at `YOUR_GITHUB_USERNAME/astromech-template` — a clean, shareable version of this fleet with all personal data stripped and secrets replaced with env var placeholders.

**Architecture:** A bash export script (`tools/export-template.sh`) copies the source repo to `/tmp/astromech-template`, excludes personal/runtime files, overlays stub placeholders for personal workspace files, and scrubs any remaining personal strings. A `just sync-template` recipe makes re-syncing one command. The template ships with `.env.example` so new users know what to configure.

**Tech Stack:** Bash, rsync, git, sed

---

## What gets stripped vs kept

**Strip entirely:**
- `.openclaw/workspace-*/memory/` — daily session logs
- `.openclaw/workspace-*/MEMORY.md` — personal long-term memories
- `data/` — persistent container data
- `tools/wiki/` — local vector DB (too large, user builds their own)
- `.env` — real secrets

**Replace with stubs:**
- `.openclaw/workspace-*/USER.md` → blank placeholder
- `.openclaw/mcporter.json` → `YOUR_USERNAME` placeholder
- `.openclaw/workspace-*/config/mcporter.json` → same

**Keep as-is (no personal data confirmed):**
- All `SOUL.md`, `IDENTITY.md`, `AGENTS.md` files
- `config/*.json5` — tokens already use `${ENV_VAR}` pattern
- `compose/`, `dockerfiles/`, `justfile`, `.just/`
- `.github/assets/`, `README.md` (minus personal name in subtitle)

---

### Task 1: Create stub files

**Files:**
- Create: `tools/template-stubs/USER.md`
- Create: `tools/template-stubs/MEMORY.md`
- Create: `tools/template-stubs/mcporter.json`

**Step 1: Create USER.md stub**

```markdown
# USER.md — About Your Human

- **Name:** YOUR_NAME
- **What to call them:** YOUR_NAME
- **Pronouns:**
- **Timezone:** YOUR_TIMEZONE
- **Notes:**

## Context

_(Fill in as you go, or let global memory populate this automatically.)_

## Language

- Preferred language for replies:
```

**Step 2: Create MEMORY.md stub**

```markdown
# Memory

Long-term memory for this agent. Written automatically during sessions.
Delete this file to start fresh, or leave it — the agent will build it over time.
```

**Step 3: Create mcporter.json stub**

```json
{
  "mcpServers": {
    "globalmemory": {
      "baseUrl": "http://globalmemory-mcp:8765/mcp/astromech/sse/YOUR_USERNAME"
    }
  },
  "imports": []
}
```

**Step 4: Verify stubs exist**

```bash
ls /path/to/astromech/tools/template-stubs/
```
Expected: `USER.md  MEMORY.md  mcporter.json`

**Step 5: Commit**

```bash
git add tools/template-stubs/
git commit -m "chore: add template stub files for export"
```

---

### Task 2: Create .env.example

**Files:**
- Create: `.env.example`

**Step 1: Inspect the real .env to capture all required vars (without values)**

```bash
grep -E '^[A-Z_]+=|^# ' /path/to/astromech/.env | sed 's/=.*/=YOUR_VALUE_HERE/'
```

**Step 2: Write .env.example with all vars, values replaced with descriptive placeholders**

Content should follow pattern:
```bash
# OpenClaw auth
OPENCLAW_API_KEY=YOUR_OPENCLAW_API_KEY

# Telegram bot tokens (one per agent, get from @BotFather)
TELEGRAM_BOT_BBYODA_TOKEN=YOUR_BOT_TOKEN
TELEGRAM_BOT_R2D2_TOKEN=YOUR_BOT_TOKEN
# ... all agents
```

**Step 3: Commit**

```bash
git add .env.example
git commit -m "chore: add .env.example for template"
```

---

### Task 3: Write the export script

**Files:**
- Create: `tools/export-template.sh`

**Step 1: Write the script**

```bash
#!/usr/bin/env bash
# Export a clean astromech-template from this repo.
# Strips personal data, replaces with stubs, ready to push public.
#
# Usage: bash tools/export-template.sh [output-dir]
#   Default output: /tmp/astromech-template

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${1:-/tmp/astromech-template}"

echo "→ Exporting astromech-template to: $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"

# ── Copy repo, excluding personal/runtime files ──────────────────────────────
rsync -a --exclude='.git' \
  --exclude='.env' \
  --exclude='data/' \
  --exclude='tools/wiki/' \
  --exclude='tools/template-stubs/' \
  --exclude='.openclaw/workspace-*/memory/' \
  --exclude='.openclaw/workspace-*/MEMORY.md' \
  --exclude='.openclaw/workspace-*/USER.md' \
  --exclude='.openclaw/mcporter.json' \
  --exclude='.openclaw/workspace-*/config/mcporter.json' \
  "$SRC/" "$DEST/"

# ── Overlay stub files ────────────────────────────────────────────────────────
for workspace in "$DEST/.openclaw"/workspace-*/; do
  cp "$SRC/tools/template-stubs/USER.md"   "$workspace/USER.md"
  cp "$SRC/tools/template-stubs/MEMORY.md" "$workspace/MEMORY.md"
  if [ -d "$workspace/config" ]; then
    cp "$SRC/tools/template-stubs/mcporter.json" "$workspace/config/mcporter.json"
  fi
done

cp "$SRC/tools/template-stubs/mcporter.json" "$DEST/.openclaw/mcporter.json"

# ── Copy .env.example (not .env) ──────────────────────────────────────────────
cp "$SRC/.env.example" "$DEST/.env.example"

# ── Scrub personal name from README subtitle ──────────────────────────────────
sed -i "s/Your personal AI fleet/Your personal AI fleet/" "$DEST/README.md"

# ── Scrub any remaining local absolute paths from doc comments ────────────────
find "$DEST" -name "*.json5" -o -name "*.md" | \
  xargs sed -i 's|/path/to/astromech|/path/to/astromech|g' 2>/dev/null || true

echo "✓ Export complete: $DEST"
echo ""
echo "Next: cd $DEST && git init && git add . && git commit -m 'initial template'"
```

**Step 2: Make executable**

```bash
chmod +x /path/to/astromech/tools/export-template.sh
```

**Step 3: Commit**

```bash
git add tools/export-template.sh
git commit -m "chore: add export-template script"
```

---

### Task 4: Add justfile recipes

**Files:**
- Modify: `justfile`

**Step 1: Add two recipes — export and sync**

```just
# Export a clean template copy (strips personal data)
export-template dest="/tmp/astromech-template":
    bash tools/export-template.sh {{dest}}

# Sync latest changes to astromech-template public repo
sync-template: (export-template "/tmp/astromech-template")
    cd /tmp/astromech-template && \
        git add . && \
        git diff --staged --quiet || git commit -m "chore: sync from astromech" && \
        git push
```

**Step 2: Commit**

```bash
git add justfile
git commit -m "chore: add export-template and sync-template justfile recipes"
```

---

### Task 5: Run export and verify clean

**Step 1: Run the export**

```bash
just export-template /tmp/astromech-template
```

**Step 2: Verify no personal data leaked**

```bash
grep -r "ruben\|YOUR_NAME\|YOUR_USERNAME\|YOUR_TELEGRAM_USERNAME\|10\.08\.1987" \
  /tmp/astromech-template/.openclaw/ && echo "LEAK FOUND" || echo "✓ Clean"
```
Expected: `✓ Clean`

**Step 3: Verify stub files are in place**

```bash
cat /tmp/astromech-template/.openclaw/workspace-yoda/USER.md | head -5
cat /tmp/astromech-template/.openclaw/mcporter.json
```
Expected: `YOUR_NAME` and `YOUR_USERNAME` placeholders visible.

**Step 4: Verify .env not present, .env.example is**

```bash
ls /tmp/astromech-template/.env 2>/dev/null && echo "LEAK" || echo "✓ No .env"
ls /tmp/astromech-template/.env.example && echo "✓ .env.example present"
```

---

### Task 6: Initialize git and push to astromech-template

**Step 1: Init repo in export dir**

```bash
cd /tmp/astromech-template
git init
git branch -M main
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/astromech-template.git
```

**Step 2: First commit and push**

```bash
git add .
git commit -m "feat: initial astromech-template release

Personal AI fleet template powered by OpenClaw.
Customizable droid fleet with Star Wars character identities,
global memory, voice, and multi-agent orchestration."
git push -u origin main
```

**Step 3: Verify on GitHub**

Check `https://github.com/YOUR_GITHUB_USERNAME/astromech-template` — README should show "Your personal AI fleet."

---

### Task 7: Add .gitignore to template output

So users who fork it don't accidentally commit their own secrets.

**Files:**
- Check: `.gitignore` in source repo

**Step 1: Verify .gitignore covers the right patterns**

```bash
cat /path/to/astromech/.gitignore
```

Confirm it includes: `.env`, `data/`, `workspace-*/memory/`, `tools/wiki/`

If any are missing, add them and commit to source repo before next sync.

---

## Future syncing

After this initial setup, whenever SOUL.md files, IDENTITY.md, config, or compose files change:

```bash
just sync-template
```

That's it. One command, personal data stays home.
