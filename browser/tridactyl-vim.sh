#!/bin/bash

# Tridactyl editor script for macOS Terminal with vim
# Usage: script.sh <filename> <line> <column>
# This script MUST be blocking - it waits for vim to exit before finishing

FILENAME="$1"
LINE="$2"
COLUMN="$3"

# Create a unique marker file to track when vim closes
MARKER_FILE="/tmp/tridactyl_vim_$_$(date +%s)"

# Create a wrapper script that vim will run
WRAPPER_SCRIPT=$(mktemp)
cat > "$WRAPPER_SCRIPT" << EOF
#!/bin/bash
# Remove the marker file when vim starts
rm -f "$MARKER_FILE" 2>/dev/null

# Run vim with cursor positioning
vim "$FILENAME" "+call cursor($LINE, $COLUMN)"

# Create marker file when vim exits
touch "$MARKER_FILE"

# Exit the shell cleanly (this will close the terminal without prompting)
exit 0
EOF

chmod +x "$WRAPPER_SCRIPT"

# Open Terminal and run vim through our wrapper
osascript << EOF
tell application "Terminal"
    activate
    set newTab to do script "bash '$WRAPPER_SCRIPT'; exit"
end tell
EOF

# Wait for vim to exit (marker file gets created)
while [ ! -f "$MARKER_FILE" ]; do
    sleep 0.1
done

# Clean up
rm -f "$MARKER_FILE" "$WRAPPER_SCRIPT"

# Return focus to browser
osascript -e 'tell application "Firefox" to activate' 2>/dev/null || \
osascript -e 'tell application "LibreWolf" to activate' 2>/dev/null || \
osascript -e 'tell application "Safari" to activate' 2>/dev/null