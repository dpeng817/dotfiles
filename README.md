# Dotfiles

My personal macOS configuration and development environment setup.

## New Machine Setup Checklist

### 1. System Preferences
- [ ] Set Caps Lock key to Escape (System Preferences > Keyboard > Modifier Keys)
- [ ] Set dock to auto-hide

### 2. Install Core Apps
- [ ] Install Homebrew
- [ ] Clone this repo: `git clone https://github.com/dpeng817/dotfiles.git ~/dotfiles`
- [ ] Install packages: `cd ~/dotfiles && brew bundle install`
- [ ] Install apps manually: Cursor, HomeRow, BetterTouchTool, Alfred, Firefox, Ghostty

### 3. Set Default Applications
- [ ] Set Firefox as default browser (Firefox > Preferences > General)
- [ ] Set Ghostty as default terminal (Terminal > Preferences > General)

### 4. Deploy Configurations
- [ ] Run deployment script: `./deploy.sh`
- [ ] Reload shell: `source ~/.zshrc`

### 5. Configure Individual Apps

All apps need to be configured with shortcuts pulled from https://github.com/dpeng817/qmk_firmware_holykeebs/blob/dpng_main/keyboards/keyball/keyball44/keymaps/dpng/keymap.c (keyball config)

#### Alfred
- [ ] Replace Spotlight with Alfred
- [ ] Import preferences (should be automatic after deploy script)
- [ ] Set Alfred hotkey (Cmd+Space)

#### HomeRow
- [ ] Open HomeRow and configure keyboard shortcuts

#### Firefox + Tridactyl
- [ ] Install Tridactyl extension
- [ ] Set up native messaging: `:native`
- [ ] Verify tridactyl-vim.sh script is working, and that tridactylrc correctly picked up vim as editor (go to a text box and do ctrl-i)

#### Cursor
- [ ] Settings should be imported automatically


## Repository Structure

```
dotfiles/
├── shell/           # Zsh configuration
├── terminal/        # Ghostty settings
├── browser/         # Firefox, Tridactyl, and scripts
├── cursor/          # Cursor settings and extensions
├── alfred/          # Alfred preferences
├── scripts/         # script for symlink writing and deployment
```

## Development vs New Machine

**For ongoing development:** Use `./link.sh` to create symlinks. Changes in apps automatically update the repo.

**For new machine setup:** Use `./deploy.sh` to copy files without symlinks. Follow the checklist above.