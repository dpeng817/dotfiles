#!/bin/bash

# This script links the actual dotfiles to the home directory.
# For some applications, like Cursor, requires that the app exists.
set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

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

link_to_dotfiles() {
    local system_path="$1"
    local dotfiles_path="$2"
    local source="$DOTFILES_DIR/$dotfiles_path"
    
    local source_dir=$(dirname "$source")
    if [ ! -d "$source_dir" ]; then
        mkdir -p "$source_dir"
        log "Created dotfiles directory: $source_dir"
    fi
    
    if [ -e "$system_path" ] && [ ! -e "$source" ]; then
        cp -r "$system_path" "$source"
        log "Copied existing config $system_path to dotfiles repo"
    fi
    
    local system_dir=$(dirname "$system_path")
    if [ ! -d "$system_dir" ]; then
        mkdir -p "$system_dir"
        log "Created system directory: $system_dir"
    fi
    
    if [ -e "$system_path" ] && [ ! -L "$system_path" ]; then
        local backup_path="$BACKUP_DIR/$(basename "$system_path")"
        mv "$system_path" "$backup_path"
        warn "Backed up existing $system_path to $backup_path"
    elif [ -L "$system_path" ]; then
        rm "$system_path"
        log "Removed existing symlink at $system_path"
    fi
    
    ln -sf "$source" "$system_path"
    log "Linked $system_path -> $source"
}

log "Starting dotfiles symlink setup..."

link_to_dotfiles "$HOME/.zshrc" "shell/.zshrc"
link_to_dotfiles "$HOME/.vimrc" "vim/.vimrc"
link_to_dotfiles "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "terminal/ghostty/config"
link_to_dotfiles "$HOME/.tridactylrc" "browser/tridactylrc"
link_to_dotfiles "$HOME/tridactyl-vim.sh" "browser/tridactyl-vim.sh"
link_to_dotfiles "$HOME/Library/Application Support/Cursor/User/settings.json" "cursor/settings.json"
link_to_dotfiles "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences" "alfred/Alfred.alfredpreferences"

link_to_dotfiles "$HOME/.config/kanata/kanata.kbd" "kanata/kanata.kbd"

log "Symlink setup complete!"
log "Backup created at: $BACKUP_DIR"

echo ""
warn "The following apps require manual configuration:"
echo "  • HomeRow - No config file, settings stored in app"
echo "  • Alfred - Use Alfred's sync folder feature or export/import"
echo "  • BetterTouchTool - Export presets manually from the app"
echo "  • Homebrew packages - Run 'brew bundle dump' to create Brewfile"
echo "  • Kanata - Need to install karabiner-driverkit, set up launchdaemons"

echo ""
log "Next steps:"
echo "  1. Install packages: brew bundle install"
echo "  2. Install Cursor extensions: cat cursor/extensions.txt | xargs -L 1 cursor --install-extension"
echo "  3. Manually configure Alfred, BetterTouchTool, and HomeRow"