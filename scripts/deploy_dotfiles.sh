#!/bin/bash

# This script copies dotfiles from the repo to their system locations.
# Use this to set up a new machine or restore configurations.

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-restore-backup-$(date +%Y%m%d-%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

if [ ! -d "$DOTFILES_DIR" ]; then
    error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
log "Created backup directory: $BACKUP_DIR"

deploy_from_dotfiles() {
    local system_path="$1"
    local dotfiles_path="$2"
    local source="$DOTFILES_DIR/$dotfiles_path"
    
    if [ ! -e "$source" ]; then
        warn "Source file not found: $source"
        return
    fi
    
    local system_dir=$(dirname "$system_path")
    if [ ! -d "$system_dir" ]; then
        mkdir -p "$system_dir"
        log "Created system directory: $system_dir"
    fi
    
    if [ -e "$system_path" ] || [ -L "$system_path" ]; then
        local backup_path="$BACKUP_DIR/$(basename "$system_path")"
        mv "$system_path" "$backup_path"
        warn "Backed up existing $system_path to $backup_path"
    fi
    
    cp -r "$source" "$system_path"
    log "Copied $source -> $system_path"
}

log "Starting dotfiles deployment..."

deploy_from_dotfiles "$HOME/.zshrc" "shell/.zshrc"
deploy_from_dotfiles "$HOME/.vimrc" "vim/.vimrc"
deploy_from_dotfiles "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "terminal/ghostty/config"
deploy_from_dotfiles "$HOME/.tridactylrc" "browser/tridactylrc"
deploy_from_dotfiles "$HOME/tridactyl-vim.sh" "browser/tridactyl-vim.sh"
deploy_from_dotfiles "$HOME/Library/Application Support/Cursor/User/settings.json" "cursor/settings.json"
deploy_from_dotfiles "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences" "alfred/Alfred.alfredpreferences"

# Make tridactyl-vim.sh executable
if [ -f "$HOME/tridactyl-vim.sh" ]; then
    chmod +x "$HOME/tridactyl-vim.sh"
    log "Made tridactyl-vim.sh executable"
fi

log "Deployment complete!"
log "Backup created at: $BACKUP_DIR"

echo ""
log "Next steps:"
echo "  1. Install Homebrew packages: brew bundle install"
echo "  2. Install Cursor extensions: cat $DOTFILES_DIR/cursor/extensions.txt | xargs -L 1 cursor --install-extension"
echo "  3. Manually configure Alfred, BetterTouchTool, and HomeRow"
echo "  4. Restart terminal/applications to pick up new configs"