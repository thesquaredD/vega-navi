#!/usr/bin/env bash
# Launch the Jellyfin server binary directly with our forked web UI.
# Bypasses /Applications/Jellyfin.app's bundled webroot so we can deploy
# the fork to a user-writable location without fighting macOS App Management.
set -euo pipefail

APP="/Applications/Jellyfin.app"
BIN="$APP/Contents/MacOS/jellyfin"
FFMPEG="$APP/Contents/MacOS/ffmpeg"
WEBDIR="$HOME/jellyfin-web"
DATADIR="$HOME/Library/Application Support/jellyfin"

if [[ ! -x "$BIN" ]]; then
    echo "✖ jellyfin binary not found at $BIN — install with: brew install --cask jellyfin"
    exit 1
fi

if [[ ! -d "$WEBDIR" ]]; then
    echo "✖ webroot not found at $WEBDIR — run: npm run deploy"
    exit 1
fi

# Quit any running instance (the .app launcher or a previous run of this script)
osascript -e 'tell application "Jellyfin" to quit' 2>/dev/null || true
pkill -f "Contents/MacOS/jellyfin" 2>/dev/null || true
sleep 1

echo "→ Launching Jellyfin server with webroot=$WEBDIR"
exec "$BIN" \
    --webdir "$WEBDIR" \
    --ffmpeg "$FFMPEG" \
    --datadir "$DATADIR"
