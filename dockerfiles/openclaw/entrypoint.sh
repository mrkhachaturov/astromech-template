#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Secrets Management — 1Password CLI
###############################################################################
# Reads secrets from 1Password using op CLI and exports as environment variables
###############################################################################

# Check if OP_SERVICE_ACCOUNT_TOKEN is set
if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
  echo "[entrypoint] Loading secrets from 1Password ..."

  # Define secret mappings: 1Password reference -> ENV var name
  declare -A op_secret_refs=(
    ["op://Openclaw/openclaw-gateway/OPENCLAW_GATEWAY_TOKEN"]="OPENCLAW_GATEWAY_TOKEN"
    ["op://Openclaw/openclaw-gateway/WEBHOOK_TOKEN"]="WEBHOOK_TOKEN"
    ["op://Openclaw/telegram_bot/r2d2"]="TELEGRAM_BOT_R2D2_TOKEN"
    ["op://Openclaw/telegram_bot/bb8"]="TELEGRAM_BOT_BB8_TOKEN"
    ["op://Openclaw/telegram_bot/bb9e"]="TELEGRAM_BOT_BB9E_TOKEN"
    ["op://Openclaw/telegram_bot/c3po"]="TELEGRAM_BOT_C3PO_TOKEN"
    ["op://Openclaw/telegram_bot/cb23"]="TELEGRAM_BOT_CB23_TOKEN"
    ["op://Openclaw/telegram_bot/r5d4"]="TELEGRAM_BOT_R5D4_TOKEN"
    ["op://Openclaw/telegram_bot/r4p17"]="TELEGRAM_BOT_R4P17_TOKEN"
    ["op://Openclaw/telegram_bot/d0"]="TELEGRAM_BOT_D0_TOKEN"
    ["op://Openclaw/telegram_bot/l337"]="TELEGRAM_BOT_L337_TOKEN"
    ["op://Openclaw/telegram_bot/k2s0"]="TELEGRAM_BOT_K2S0_TOKEN"
    ["op://Openclaw/opencalw-openai/OPENAI_API_KEY"]="OPENAI_API_KEY"
    ["op://Openclaw/openclaw-google-llm/GEMINI_API_KEY"]="GEMINI_API_KEY"
    ["op://Openclaw/openclaw-perplexity/PERPLEXITY_API_TOKEN"]="PERPLEXITY_API_KEY"
    ["op://Openclaw/telegram_bot/rk_tg_user_Id"]="RK_TG_USER_ID"
    ["op://Openclaw/openclaw_whoop_cli/CLIENT_ID"]="WHOOP_CLIENT_ID"
    ["op://Openclaw/openclaw_whoop_cli/CLIENT_SECRET"]="WHOOP_CLIENT_SECRET"
    ["op://Openclaw/openclaw-hae-vault/BEARER_TOKEN"]="HVAULT_BEARER_TOKEN"
    
  )

  # Env file lets docker exec sessions source the same secrets (via ~/.bashrc)
  ENV_FILE="/tmp/openclaw-env"
  : > "$ENV_FILE" && chmod 600 "$ENV_FILE"

  for op_ref in "${!op_secret_refs[@]}"; do
    env_var="${op_secret_refs[$op_ref]}"

    # Read secret from 1Password
    if secret_value=$(op read "$op_ref" 2>/dev/null); then
      # Export for current process tree (inherited by exec'd command)
      declare -x "$env_var=$secret_value"
      # Write to env file for docker exec sessions — printf %q quotes safely, no value in logs
      printf '%s=%q\n' "$env_var" "$secret_value" >> "$ENV_FILE"
      echo "[entrypoint]   ✓ Loaded $env_var"
    else
      echo "[entrypoint]   ⊙ Skipped $env_var (failed to read from 1Password)"
    fi
  done

  echo "[entrypoint] ✅ Secrets loaded from 1Password"
else
  echo "[entrypoint] ⚠️  OP_SERVICE_ACCOUNT_TOKEN not set — skipping secrets"
fi

###############################################################################
# Seed workspace templates (no-clobber — won't overwrite existing files)
###############################################################################
MANIFEST="/opt/config/skills-manifest.txt"
WORKDIR="/home/node/.openclaw/workspace"
TEMPLATES="/opt/workspace-templates"

# Commented out: letting OpenClaw generate workspace files itself
# if [[ -d "$TEMPLATES" ]]; then
#   echo "[entrypoint] Seeding workspace templates ..."
#   cp -rn "$TEMPLATES"/. "$WORKDIR"/
# fi

###############################################################################
# Install ClawHub skills from the manifest (if present)
###############################################################################
if [[ -f "$MANIFEST" ]]; then
  echo "[entrypoint] Installing ClawHub skills from manifest ..."
  while IFS= read -r line; do
    # Skip blank lines and comments
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue

    # Skip if already installed
    if [[ -d "$WORKDIR/skills/$line" ]]; then
      echo "[entrypoint]   ✓ $line (already installed)"
      continue
    fi

    echo "[entrypoint]   → installing $line"
    clawhub install "$line" --workdir "$WORKDIR" || {
      echo "[entrypoint] WARNING: Failed to install $line — continuing"
    }
  done < "$MANIFEST"
  echo "[entrypoint] Skill installation complete."
else
  echo "[entrypoint] No skills manifest found — skipping skill install."
fi

###############################################################################
# Hand off to the real command (CMD from docker-compose)
###############################################################################
exec "$@"
