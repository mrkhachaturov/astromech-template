#!/bin/bash
# Script to manage Docker secrets using 1Password Service Account
# Reads secret definitions from .secrets files in secrets/

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="${SCRIPT_DIR}/../secrets"

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if 1Password CLI is available
check_op_cli() {
    if ! command -v op &> /dev/null; then
        print_status "$RED" "Error: 1Password CLI (op) is not installed or not in PATH"
        print_status "$YELLOW" "Install from: https://1password.com/downloads/command-line/"
        exit 1
    fi
}

# Function to prompt for service account token
setup_op_token() {
    if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
        print_status "$GREEN" "✓ OP_SERVICE_ACCOUNT_TOKEN already set"
        return 0
    fi

    if [[ -t 0 ]]; then
        # Interactive terminal
        read -sp "Enter 1Password service account token: " OP_SERVICE_ACCOUNT_TOKEN
        echo ""

        if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
            print_status "$RED" "Error: service account token is required"
            exit 1
        fi

        # Export token for this session
        export OP_SERVICE_ACCOUNT_TOKEN="$OP_SERVICE_ACCOUNT_TOKEN"
        print_status "$GREEN" "✓ Service account token set"
    else
        # Non-interactive
        print_status "$RED" "Error: OP_SERVICE_ACCOUNT_TOKEN must be set as environment variable (non-interactive mode)"
        exit 1
    fi
}

# Function to clean up token from environment
cleanup_op_token() {
    if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
        unset OP_SERVICE_ACCOUNT_TOKEN
        export OP_SERVICE_ACCOUNT_TOKEN=""
        print_status "$GREEN" "✓ Service account token removed from environment"
    fi
}

# Function to check if secret exists
secret_exists() {
    local secret_name=$1
    docker secret inspect "$secret_name" &>/dev/null
}

# Function to create or update secret from 1Password
create_secret_from_op() {
    local secret_name=$1
    local op_reference=$2
    local force_update=${3:-false}

    # Check if secret exists
    if secret_exists "$secret_name"; then
        if [[ "$force_update" != "true" ]]; then
            print_status "$BLUE" "  ⊙ $secret_name (already exists, skipping)"
            return 0
        else
            print_status "$YELLOW" "  → $secret_name (updating...)"
            # Remove old secret
            if ! docker secret rm "$secret_name" 2>/dev/null; then
                print_status "$RED" "  ✗ Failed to remove old secret: ${secret_name}"
                print_status "$RED" "    This secret may be in use by a running service"
                return 1
            fi
        fi
    else
        print_status "$YELLOW" "  → $secret_name (creating...)"
    fi

    # Fetch value from 1Password using op read
    local secret_value
    if ! secret_value=$(op read "$op_reference" 2>/dev/null); then
        print_status "$RED" "  ✗ Failed to fetch from 1Password: ${op_reference}"
        return 1
    fi

    # Create Docker secret
    if echo -n "$secret_value" | docker secret create "$secret_name" - &>/dev/null; then
        print_status "$GREEN" "  ✓ $secret_name"
        return 0
    else
        print_status "$RED" "  ✗ Failed to create Docker secret: ${secret_name}"
        return 1
    fi
}

# Function to load secrets from .secrets files
load_secrets_from_files() {
    local service_filter=${1:-}
    declare -gA SECRET_REFS

    # Find all .secrets files (or specific service file)
    local secrets_files=()
    if [[ -n "$service_filter" ]]; then
        local target_file="$SECRETS_DIR/${service_filter}.secrets"
        if [[ ! -f "$target_file" ]]; then
            print_status "$RED" "Error: Service file not found: ${service_filter}.secrets"
            print_status "$YELLOW" "Available services:"
            for f in "$SECRETS_DIR"/*.secrets; do
                [[ -f "$f" ]] && print_status "$YELLOW" "  - $(basename "$f" .secrets)"
            done
            return 1
        fi
        secrets_files=("$target_file")
    else
        while IFS= read -r -d '' file; do
            secrets_files+=("$file")
        done < <(find "$SECRETS_DIR" -name "*.secrets" -print0 2>/dev/null)
    fi

    if [[ ${#secrets_files[@]} -eq 0 ]]; then
        print_status "$RED" "Error: No .secrets files found in $SECRETS_DIR"
        return 1
    fi

    print_status "$GREEN" "Found ${#secrets_files[@]} secrets file(s):"
    for file in "${secrets_files[@]}"; do
        print_status "$GREEN" "  - $(basename "$file")"
    done
    echo ""

    # Parse each .secrets file
    for secrets_file in "${secrets_files[@]}"; do
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue

            # Remove leading/trailing whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)

            if [[ -n "$key" && -n "$value" ]]; then
                SECRET_REFS["$key"]="$value"
            fi
        done < "$secrets_file"
    done

    if [[ ${#SECRET_REFS[@]} -eq 0 ]]; then
        print_status "$RED" "Error: No valid secrets found in .secrets files"
        return 1
    fi

    print_status "$YELLOW" "Total secrets to process: ${#SECRET_REFS[@]}"
    echo ""
}

# Function to create all secrets
cmd_create() {
    local force_update=${1:-false}
    local service_filter=${2:-}

    print_status "$GREEN" "=== Docker Secrets Creation ==="
    if [[ -n "$service_filter" ]]; then
        print_status "$BLUE" "Service filter: ${service_filter}.secrets"
    fi
    if [[ "$force_update" == "true" ]]; then
        print_status "$YELLOW" "Mode: Force update (rotate secrets)"
    else
        print_status "$YELLOW" "Mode: Skip existing secrets"
    fi
    echo ""

    # Check prerequisites
    check_op_cli
    setup_op_token
    load_secrets_from_files "$service_filter"

    echo ""
    print_status "$GREEN" "=== Processing Secrets ==="

    # Track stats
    local created=0
    local skipped=0
    local failed=0
    local failed_secrets=()

    for secret_name in "${!SECRET_REFS[@]}"; do
        local op_reference="${SECRET_REFS[$secret_name]}"

        if create_secret_from_op "$secret_name" "$op_reference" "$force_update"; then
            if secret_exists "$secret_name"; then
                if [[ "$force_update" == "true" ]]; then
                    created=$((created + 1))
                else
                    # Check if we actually created it or skipped it
                    # If force_update is false and it existed, we skipped it
                    skipped=$((skipped + 1))
                fi
            else
                created=$((created + 1))
            fi
        else
            failed=$((failed + 1))
            failed_secrets+=("$secret_name")
        fi
    done

    echo ""
    print_status "$GREEN" "=== Summary ==="
    print_status "$GREEN" "Created/Updated: $created"
    print_status "$BLUE" "Skipped: $skipped"
    if [[ $failed -gt 0 ]]; then
        print_status "$RED" "Failed: $failed"
        print_status "$RED" "Failed secrets:"
        for secret in "${failed_secrets[@]}"; do
            print_status "$RED" "  - ${secret}"
        done
        return 1
    else
        print_status "$GREEN" "✅ All secrets processed successfully!"
    fi
}

# Function to list all secrets
cmd_list() {
    local service_filter=${1:-}
    load_secrets_from_files "$service_filter"

    print_status "$GREEN" "=== Docker Secrets (managed by Astromech) ==="
    if [[ -n "$service_filter" ]]; then
        print_status "$BLUE" "Service filter: ${service_filter}.secrets"
    fi
    echo ""

    local found=0
    for secret_name in "${!SECRET_REFS[@]}"; do
        if secret_exists "$secret_name"; then
            created_at=$(docker secret inspect "$secret_name" --format '{{.CreatedAt}}' 2>/dev/null)
            updated_at=$(docker secret inspect "$secret_name" --format '{{.UpdatedAt}}' 2>/dev/null)
            print_status "$GREEN" "  ✓ $secret_name"
            print_status "$BLUE" "    Created: $created_at"
            found=$((found + 1))
        else
            print_status "$RED" "  ✗ $secret_name (not created yet)"
        fi
    done

    echo ""
    if [[ $found -eq 0 ]]; then
        print_status "$YELLOW" "No secrets found. Run 'just secrets-create' to create them."
    else
        print_status "$GREEN" "Total: $found secret(s)"
    fi
}

# Function to remove all secrets
cmd_remove() {
    local service_filter=${1:-}
    load_secrets_from_files "$service_filter"

    print_status "$RED" "=== Remove Docker Secrets ==="
    if [[ -n "$service_filter" ]]; then
        print_status "$YELLOW" "This will remove secrets from ${service_filter}.secrets"
    else
        print_status "$YELLOW" "This will remove all secrets managed by Astromech."
    fi
    echo ""

    # Find secrets that exist
    local existing_secrets=()
    for secret_name in "${!SECRET_REFS[@]}"; do
        if secret_exists "$secret_name"; then
            existing_secrets+=("$secret_name")
        fi
    done

    if [[ ${#existing_secrets[@]} -eq 0 ]]; then
        print_status "$YELLOW" "No secrets found to remove."
        return 0
    fi

    print_status "$YELLOW" "Secrets to remove:"
    for secret in "${existing_secrets[@]}"; do
        echo "  - $secret"
    done
    echo ""

    if [[ -t 0 ]]; then
        read -p "Are you sure? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_status "$YELLOW" "Aborted."
            return 0
        fi
    else
        print_status "$RED" "Running in non-interactive mode - use 'yes | just secrets-remove' to force"
        return 1
    fi

    echo ""
    for secret in "${existing_secrets[@]}"; do
        if docker secret rm "$secret" &>/dev/null; then
            print_status "$GREEN" "  ✓ Removed: $secret"
        else
            print_status "$RED" "  ✗ Failed: $secret"
        fi
    done

    echo ""
    print_status "$GREEN" "✅ All secrets removed."
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 <command> [service]

Commands:
  create [service]    Create secrets (skip existing)
  rotate [service]    Rotate secrets (force update)
  list [service]      List Docker secrets
  remove [service]    Remove Docker secrets (interactive)

Parameters:
  service            Optional: anthropic, telegram, yandex, jira, todoist, openclaw
                     If omitted, processes all services

Examples:
  $0 create                 # Create all secrets, skip existing
  $0 create anthropic       # Create only anthropic.secrets
  $0 rotate telegram        # Rotate only telegram.secrets
  $0 list yandex            # List only yandex.secrets
  $0 remove jira            # Remove only jira.secrets

EOF
}

# Main function
main() {
    local command=${1:-}
    local service=${2:-}

    case "$command" in
        create)
            cmd_create false "$service"
            ;;
        rotate)
            cmd_create true "$service"
            ;;
        list)
            cmd_list "$service"
            ;;
        remove)
            cmd_remove "$service"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# Run main function and ensure cleanup on exit
trap cleanup_op_token EXIT
main "$@"
