#!/usr/bin/env bash
# Export a clean astromech-template from this repo.
# Strips personal data, replaces with stubs, ready to push public.
#
# Usage: bash tools/export-template.sh [output-dir]
#   Default output: dist/astromech-template

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${1:-"$SRC/dist/astromech-template"}"

echo "→ Exporting astromech-template to: $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"

# ── Copy repo, excluding personal/runtime files ──────────────────────────────
rsync -a --exclude='.git' \
  --exclude='.env' \
  --exclude='data/' \
  --exclude='dist/' \
  --exclude='archive/' \
  --exclude='references/' \
  --exclude='templates/' \
  --exclude='tools/wiki/' \
  --exclude='tools/template-stubs/' \
  --exclude='justfile' \
  --exclude='.just/' \
  --exclude='*.bak' \
  --exclude='*.bak.*' \
  --exclude='*.sqlite' \
  --exclude='*.sqlite-wal' \
  --exclude='*.sqlite-shm' \
  \
  --exclude='.openclaw/agents/' \
  --exclude='.openclaw/canvas/' \
  --exclude='.openclaw/credentials/' \
  --exclude='.openclaw/cron/' \
  --exclude='.openclaw/delivery-queue/' \
  --exclude='.openclaw/devices/' \
  --exclude='.openclaw/exec-approvals.json' \
  --exclude='.openclaw/identity/' \
  --exclude='.openclaw/logs/' \
  --exclude='.openclaw/media/' \
  --exclude='.openclaw/memory/' \
  --exclude='.openclaw/models_info/' \
  --exclude='.openclaw/op/' \
  --exclude='.openclaw/sandbox/' \
  --exclude='.openclaw/settings/' \
  --exclude='.openclaw/subagents/' \
  --exclude='.openclaw/telegram/' \
  --exclude='.openclaw/update-check.json' \
  --exclude='.openclaw/mcporter.json' \
  \
  --exclude='.openclaw/workspace-*/MEMORY.md' \
  --exclude='.openclaw/workspace-*/USER.md' \
  --exclude='.openclaw/workspace-*/config/mcporter.json' \
  --exclude='.openclaw/workspace-*/.openclaw/' \
  --exclude='.openclaw/workspace-*/.pi/' \
  --exclude='.openclaw/workspace-*/home/' \
  --exclude='.openclaw/workspace-*/media/' \
  --exclude='.openclaw/workspace-*/research/' \
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

# ── Fix .gitmodules: normalize wiki submodule URL to HTTPS (it's a public repo) ─
if [ -f "$DEST/.gitmodules" ]; then
  sed -i 's|git@github.com-openclaw-kb:YOUR_GITHUB_USERNAME/openclaw-kb.git|https://github.com/YOUR_GITHUB_USERNAME/openclaw-kb.git|g' "$DEST/.gitmodules"
fi

# ── Scrub personal data from all text files (not .gitmodules — URLs kept intact) ─
find "$DEST" \( \
  -name "*.md" -o -name "*.json5" -o -name "*.json" \
  -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.sh" -o -name "*.service" \
\) -print0 | \
  xargs -0 sed -i \
    -e "s/Your personal AI fleet/Your personal AI fleet/g" \
    -e "s/Tools you use yourself/Tools you use yourself/g" \
    -e "s/you use yourself/you use yourself/g" \
    -e "s/your/your/g" \
    -e "s/YOUR_NAME/YOUR_NAME/g" \
    -e "s/YOUR_LAST_NAME/YOUR_LAST_NAME/g" \
    -e "s/YOUR_NAME/YOUR_NAME/g" \
    -e "s/YOUR_TELEGRAM_USERNAME/YOUR_TELEGRAM_USERNAME/g" \
    -e "s/YOUR_GITHUB_USERNAME/YOUR_GITHUB_USERNAME/g" \
    -e "s/YOUR_USERNAME/YOUR_USERNAME/g" \
    -e 's|/path/to/astromech|/path/to/astromech|g' \
    -e 's|/path/to/astromech|/path/to/astromech|g' \
    -e 's|/home/YOUR_USERNAME|/home/YOUR_USERNAME|g' \
    -e 's|/home/YOUR_USERNAME|/home/YOUR_USERNAME|g' \
  2>/dev/null || true

echo "✓ Export complete: $DEST"
echo ""
echo "Next: cd \"$DEST\" && git init && git add . && git commit -m 'initial template'"
