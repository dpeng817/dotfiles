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

#### BetterTouchTool
- [ ] Install 3.581 (the last version that you have a license for)
- [ ] Create opt-cmd-y shortcut for opening/closing ghostty. Add a keyboard shortcut which executes a terminal command, and paste the following:
```bash
osascript -e 'tell application "System Events"
    if exists (process "Ghostty") then
        if frontmost of process "Ghostty" then
            set visible of process "Ghostty" to false
        else
            tell application "Ghostty" to activate
        end if
    else
        tell application "Ghostty" to activate
    end if
end tell'
```

#### Cursor
- [ ] Settings should be imported automatically

#### Kanata (Homerow Mods)

Kanata provides homerow mods and custom shortcuts on the built-in MacBook keyboard.

Features
- **Homerow mods**: A=Cmd, S=Alt, D=Ctrl, F=Shift (tap for letter, hold for modifier)
- **Caps Lock**: Escape on tap, Control on hold
- **Custom shortcuts**: W=Screenshot, E=Alfred, R=HomeRow, Y=Ghostty, X=Scroll, C=Search

Setup

1. **Install Karabiner-DriverKit** (required):
   - Download from: https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases
   - Install the .pkg file
   - System Settings → Privacy & Security → Allow "Fumihiko Takayama"
   - **Restart your Mac**

2. **Install and run**:
   ```bash
   brew install kanata
   ./deploy.sh  # Copies kanata config to ~/.config/kanata/
   sudo kanata --cfg ~/.config/kanata/kanata.kbd
   ```

3. **Grant permissions**:
   - System Settings → Privacy & Security → Input Monitoring
   - Add `/opt/homebrew/bin/kanata` and enable it



## Repository Structure

```
dotfiles/
├── shell/           # Zsh configuration
├── terminal/        # Ghostty settings
├── browser/         # Firefox, Tridactyl, and scripts
├── cursor/          # Cursor settings and extensions
├── alfred/          # Alfred preferences
├── scripts/         # script for symlink writing and deployment
├── kanata/          # Kanata config 
```

## Development vs New Machine

**For ongoing development:** Use `./setup_symlinks.sh` to create symlinks. Changes in apps automatically update the repo.

**For new machine setup:** Use `./deploy_dotfiles.sh` to copy files without symlinks. Follow the checklist above.

**To restore from backup:** Use `./restore_from_backup.sh` to restore files from a backup.

## Builtin Keyboard Remapping Setup

### Install Kanata and Karabiner-DriverKit

1. **Install Karabiner-DriverKit** (required for Kanata on macOS):
   ```bash
   brew install --cask karabiner-driverkit
   ```

2. **Install Kanata**:
   ```bash
   cargo install kanata
   ```

3. **Grant necessary permissions**:
   - Open **System Preferences** → **Security & Privacy** → **Privacy**
   - Add Kanata to **Input Monitoring**: `/Users/$(whoami)/.cargo/bin/kanata`
   - Add Kanata to **Accessibility** permissions as well

### Configure Launch Daemons

4. **Set up Karabiner-DriverKit daemon**:
   ```bash
   # Create the plist file
   sudo tee /Library/LaunchDaemons/com.karabiner.virtualhiddevice.daemon.plist > /dev/null << 'EOF'
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.karabiner.virtualhiddevice.daemon</string>
       <key>ProgramArguments</key>
       <array>
           <string>/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon</string>
       </array>
       <key>RunAtLoad</key>
       <true/>
       <key>KeepAlive</key>
       <true/>
       <key>StandardOutPath</key>
       <string>/var/log/karabiner-daemon.log</string>
       <key>StandardErrorPath</key>
       <string>/var/log/karabiner-daemon.error.log</string>
       <key>UserName</key>
       <string>root</string>
       <key>GroupName</key>
       <string>wheel</string>
       <key>ProcessType</key>
       <string>Interactive</string>
   </dict>
   </plist>
   EOF
   
   # Set permissions and load
   sudo chown root:wheel /Library/LaunchDaemons/com.karabiner.virtualhiddevice.daemon.plist
   sudo chmod 644 /Library/LaunchDaemons/com.karabiner.virtualhiddevice.daemon.plist
   sudo launchctl load /Library/LaunchDaemons/com.karabiner.virtualhiddevice.daemon.plist
   ```

5. **Set up Kanata daemon**:
   ```bash
   # Create the plist file (replace 'yourusername' with your actual username)
   sudo tee /Library/LaunchDaemons/com.kanata.daemon.plist > /dev/null << EOF
   <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.kanata.daemon</string>

        <key>ProgramArguments</key>
        <array>
            <string>/Users/christopherdecarolis/.cargo/bin/kanata</string>
            <string>--cfg</string>
            <string>/Users/christopherdecarolis/.config/kanata/kanata.kbd</string>
        </array>

        <key>RunAtLoad</key>
        <true/>

        <key>KeepAlive</key>
        <true/>

        <key>StandardOutPath</key>
        <string>/var/log/kanata-daemon.log</string>

        <key>StandardErrorPath</key>
        <string>/var/log/kanata-daemon.error.log</string>

        <key>UserName</key>
        <string>root</string>

        <key>GroupName</key>
        <string>wheel</string>

        <key>ProcessType</key>
        <string>Interactive</string>

        <key>EnvironmentVariables</key>
        <dict>
            <key>PATH</key>
            <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/christopherdecarolis/.cargo/bin</string>
        </dict>
    </dict>
    </plist>
    EOF

   
   # Set permissions and load
   sudo chown root:wheel /Library/LaunchDaemons/com.kanata.daemon.plist
   sudo chmod 644 /Library/LaunchDaemons/com.kanata.daemon.plist
   sudo launchctl load /Library/LaunchDaemons/com.kanata.daemon.plist
   ```

6. **Configure sudoers for passwordless kanata execution** (if using LaunchAgent instead):
   ```bash
   sudo visudo
   # Add line: yourusername ALL=(ALL) NOPASSWD: /Users/yourusername/.cargo/bin/kanata
   ```

### Managing the Services

```bash
# Check status
sudo launchctl list | grep karabiner
sudo launchctl list | grep kanata

# View logs
tail -f /var/log/karabiner-daemon.log
tail -f /var/log/kanata-daemon.log

# Restart services
sudo launchctl unload /Library/LaunchDaemons/com.kanata.daemon.plist
sudo launchctl load /Library/LaunchDaemons/com.kanata.daemon.plist
```

### Configuration

- Kanata configuration is stored in `~/.config/kanata/kanata.kbd`
- The default config maps Caps Lock to Escape
- Customize the config based on your QMK keymap preferences
- After making config changes, restart the Kanata daemon to apply them