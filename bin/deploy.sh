#!/usr/bin/env bash
# Build the VegaNAVI fork and stage the webroot at ~/jellyfin-web.
# Pair with bin/jellyfin-launch.sh to run the server pointed at it.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBROOT="$HOME/jellyfin-web"
LAUNCHER="$REPO_ROOT/bin/jellyfin-launch.sh"

cd "$REPO_ROOT"

echo "→ Building production bundle…"
npm run build:production

if [[ ! -d "$REPO_ROOT/dist" ]]; then
    echo "✖ build did not produce dist/ — aborting"
    exit 1
fi

echo "→ Stopping any running Jellyfin server…"
osascript -e 'tell application "Jellyfin" to quit' 2>/dev/null || true
pkill -f "Contents/MacOS/jellyfin" 2>/dev/null || true
sleep 1

echo "→ Replacing webroot at ${WEBROOT}…"
rm -rf "${WEBROOT}"
cp -R "$REPO_ROOT/dist" "${WEBROOT}"

echo "→ Relaunching server with custom webroot…"
nohup "$LAUNCHER" >/tmp/jellyfin-launch.log 2>&1 &
disown

sleep 2
if pgrep -f "Contents/MacOS/jellyfin" > /dev/null; then
    echo "✓ Deployed and running. Open Jellyfin Media Player or http://localhost:8096"
else
    echo "⚠ Server did not start — check /tmp/jellyfin-launch.log"
    exit 1
fi
