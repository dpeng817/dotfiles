#!/bin/bash

# This script restores dotfiles from a backup directory created by deploy.sh
# Usage: ./restore.sh [backup-directory]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to list available backups
list_backups() {
    log "Available backup directories:"
    find "$HOME" -maxdepth 1 -type d -name "dotfiles-restore-backup-*" | sort -r | while read backup; do
        local timestamp=$(basename "$backup" | sed 's/dotfiles-restore-backup-//')
        local readable_date=$(date -j -f "%Y%m%d-%H%M%S" "$timestamp" "+%B %d, %Y at %I:%M %p" 2>/dev/null || echo "$timestamp")
        echo "  $(basename "$backup") (Created: $readable_date)"
    done
}

# Function to restore a file from backup
restore_file() {
    local backup_file="$1"
    local system_path="$2"
    local filename=$(basename "$backup_file")
    
    if [ ! -e "$backup_file" ]; then
        warn "Backup file not found: $backup_file"
        return
    fi
    
    # Create backup of current file if it exists
    if [ -e "$system_path" ] || [ -L "$system_path" ]; then
        local current_backup="$system_path.pre-restore-$(date +%Y%m%d-%H%M%S)"
        mv "$system_path" "$current_backup"
        info "Backed up current $system_path to $current_backup"
    fi
    
    # Ensure parent directory exists
    local system_dir=$(dirname "$system_path")
    if [ ! -d "$system_dir" ]; then
        mkdir -p "$system_dir"
        log "Created system directory: $system_dir"
    fi
    
    # Copy the backup file to system location
    cp -r "$backup_file" "$system_path"
    log "Restored $filename -> $system_path"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main script
if [ $# -eq 0 ]; then
    info "No backup directory specified. Here are your options:"
    echo ""
    list_backups
    echo ""
    echo "Usage: $0 <backup-directory>"
    echo "Example: $0 ~/dotfiles-restore-backup-20241201-143022"
    exit 1
fi

BACKUP_DIR="$1"

# Handle different path formats
if [[ "$BACKUP_DIR" = ~* ]]; then
    # Handle ~ paths
    BACKUP_DIR="${BACKUP_DIR/#\~/$HOME}"
elif [[ "$BACKUP_DIR" = /* ]]; then
    # Already absolute path, use as-is
    :
elif [[ "$BACKUP_DIR" = dotfiles-restore-backup-* ]]; then
    # If it looks like a backup directory name, assume it's in HOME
    BACKUP_DIR="$HOME/$BACKUP_DIR"
else
    # Try to resolve relative path from current directory
    if [ -d "$BACKUP_DIR" ]; then
        BACKUP_DIR="$(cd "$BACKUP_DIR" && pwd)"
    else
        # If not found relative to current dir, try HOME
        if [ -d "$HOME/$BACKUP_DIR" ]; then
            BACKUP_DIR="$HOME/$BACKUP_DIR"
        fi
    fi
fi

if [ ! -d "$BACKUP_DIR" ]; then
    error "Backup directory not found: $BACKUP_DIR"
    echo ""
    list_backups
    exit 1
fi

log "Starting restore from: $BACKUP_DIR"
echo ""

# Map of backup filenames to their system paths
declare -A restore_map=(
    [".zshrc"]="$HOME/.zshrc"
    [".vimrc"]="$HOME/.vimrc"
    ["config"]="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    ["tridactylrc"]="$HOME/.tridactylrc"
    ["tridactyl-vim.sh"]="$HOME/tridactyl-vim.sh"
    ["settings.json"]="$HOME/Library/Application Support/Cursor/User/settings.json"
    ["Alfred.alfredpreferences"]="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences"
)

# Restore each file
for backup_filename in "${!restore_map[@]}"; do
    backup_file="$BACKUP_DIR/$backup_filename"
    system_path="${restore_map[$backup_filename]}"
    
    if [ -e "$backup_file" ]; then
        restore_file "$backup_file" "$system_path"
    else
        warn "No backup found for $backup_filename"
    fi
done

# Make tridactyl-vim.sh executable if restored
if [ -f "$HOME/tridactyl-vim.sh" ]; then
    chmod +x "$HOME/tridactyl-vim.sh"
    log "Made tridactyl-vim.sh executable"
fi

echo ""
log "Restore complete!"
info "Files have been restored from: $BACKUP_DIR"
echo ""
log "Next steps:"
echo "  1. Restart terminal/applications to pick up restored configs"
echo "  2. Verify configurations are working as expected"
echo "  3. Remove pre-restore backups if everything looks good"