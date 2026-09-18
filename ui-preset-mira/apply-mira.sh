#!/usr/bin/env bash
# ==============================================================================
# Apply Mira UI/UX Preset (shadcn preset b1ZzrZbpw) to Hermes Web Dashboard
# Replaces retro-brutalist fonts/notched shapes with modern Inter & smooth radius
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(hermes --version 2>/dev/null | grep 'Install directory:' | awk '{print $3}' || echo '/usr/local/lib/hermes-agent')"

if [ ! -d "$INSTALL_DIR/web" ]; then
    echo "[-] Hermes web directory not found at $INSTALL_DIR/web"
    exit 1
fi

echo "[*] Applying Mira UI/UX preset (shadcn b1ZzrZbpw) to $INSTALL_DIR/web..."

# Deploy modern style files
cp "$SCRIPT_DIR/index.css" "$INSTALL_DIR/web/src/index.css"
cp "$SCRIPT_DIR/utils.ts" "$INSTALL_DIR/web/src/lib/utils.ts"
cp "$SCRIPT_DIR/presets.ts" "$INSTALL_DIR/web/src/themes/presets.ts"

echo "[*] Building updated web dashboard distribution..."
if command -v npm >/dev/null 2>&1; then
    (cd "$INSTALL_DIR" && npm run build -w web)
    echo "[+] Web dashboard UI built successfully!"
else
    echo "[!] npm not found. Please install node/npm to build the updated web UI."
fi
