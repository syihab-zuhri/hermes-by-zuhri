#!/usr/bin/env bash
# ==============================================================================
# hermes-by-zuhri Setup & Bootstrap Script
# Deploys OMP execution rigor, SOUL.md, custom skills, and config to Hermes Agent
# ==============================================================================

set -euo pipefail

HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================="
echo "   Hermes Agent Setup (OMP Enhanced Edition by Zuhri)   "
echo "========================================================="

# 1. Check Hermes installation
if ! command -v hermes >/dev/null 2>&1; then
    echo "[-] Hermes Agent CLI not found in PATH."
    echo "[*] Installing Hermes Agent via official installer..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v hermes >/dev/null 2>&1; then
    echo "[!] Hermes installed but not yet available in current session PATH."
    echo "    Please reload your shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi

echo "[+] Hermes CLI detected: $(hermes --version 2>/dev/null || echo 'active')"

# 2. Ensure ~/.hermes directories exist
mkdir -p "$HERMES_DIR"
mkdir -p "$HERMES_DIR/skills/autonomous-ai-agents"
mkdir -p "$HERMES_DIR/skills/software-development"

# 3. Deploy SOUL.md (Core Identity & OMP Rigor)
echo "[*] Deploying SOUL.md to $HERMES_DIR/SOUL.md..."
if [ -f "$HERMES_DIR/SOUL.md" ]; then
    cp "$HERMES_DIR/SOUL.md" "$HERMES_DIR/SOUL.md.backup.$(date +%Y%m%d_%H%M%S)"
fi
cp "$REPO_DIR/SOUL.md" "$HERMES_DIR/SOUL.md"
echo "[+] SOUL.md deployed successfully."

# 4. Deploy Custom Skills
echo "[*] Deploying OMP and Custom Skills to $HERMES_DIR/skills/..."
cp -r "$REPO_DIR/skills/autonomous-ai-agents/"* "$HERMES_DIR/skills/autonomous-ai-agents/"
cp -r "$REPO_DIR/skills/software-development/"* "$HERMES_DIR/skills/software-development/"
echo "[+] Skills deployed: omp-workflows, agentic-coding-discipline, shadcn-ui, and more."

# 5. Apply Recommended Extended Context & Guardrails
echo "[*] Applying OMP configuration settings..."
hermes config set compression.threshold 0.8 || true
hermes config set compression.protect_last_n 40 || true
hermes config set display.busy_input_mode interrupt || true
hermes config set tool_loop_guardrails.warnings_enabled true || true

# 6. Check Environment file
if [ ! -f "$HERMES_DIR/.env" ]; then
    echo "[*] Creating default $HERMES_DIR/.env from template..."
    cp "$REPO_DIR/config/.env.example" "$HERMES_DIR/.env"
    echo "[!] Please edit $HERMES_DIR/.env and insert your API keys."
fi

# 7. Web Dashboard Information
echo "========================================================="
echo "                  Setup Complete!                        "
echo "========================================================="
echo "To start chatting with Hermes in terminal:"
echo "  hermes"
echo ""
echo "To launch the Web Dashboard:"
echo "  hermes dashboard --skip-build --no-open --port 9119"
echo "  Then open: http://localhost:9119 in your browser."
echo ""
echo "OMP Execution Modes Available:"
echo "  - Vibe Mode: Fast, unceremonious direct coding"
echo "  - Autonomous Loop Mode: Iterate tests via python3 loop_runner.py"
echo "  - Advisor Mode: Subagent second-model peer review"
echo "  - Extended Context: 512K context window optimized"
echo "========================================================="
