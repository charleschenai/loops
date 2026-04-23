#!/bin/bash
# Loops — Claude Code Plugin Installer
# Installs /evolve skill into Claude Code's plugin system.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/charleschenai/loops/main/install.sh | bash
#   # or after cloning:
#   bash install.sh

set -euo pipefail

PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/loops"
CACHE_DIR="$HOME/.claude/plugins/cache/loops"
SETTINGS="$HOME/.claude/settings.json"
REPO_URL="${LOOPS_REPO:-https://github.com/charleschenai/loops.git}"

echo "=== Loops Installer ==="

# Handle --uninstall
if [ "${1:-}" = "--uninstall" ]; then
    echo "Uninstalling loops plugin..."
    rm -rf "$PLUGIN_DIR" "$CACHE_DIR"
    echo "Removed plugin and cache."
    echo "Note: settings.json entries left in place (harmless). Remove manually if desired."
    exit 0
fi

# Handle --check
if [ "${1:-}" = "--check" ]; then
    echo "=== Loops Plugin Status ==="
    ok=true
    for f in .claude-plugin/marketplace.json plugin/.claude-plugin/plugin.json plugin/skills/evolve/SKILL.md; do
        if [ -f "$PLUGIN_DIR/$f" ]; then
            echo "  [ok] $f"
        else
            echo "  [MISSING] $f"
            ok=false
        fi
    done
    if [ -d "$CACHE_DIR" ]; then
        echo "  [ok] cache exists at $CACHE_DIR"
    else
        echo "  [info] no cache (will be created on next Claude Code start)"
    fi
    if [ -f "$SETTINGS" ] && grep -q '"loops@loops"' "$SETTINGS" 2>/dev/null; then
        echo "  [ok] settings.json has loops@loops"
    else
        echo "  [MISSING] loops@loops not in settings.json"
        ok=false
    fi
    if $ok; then
        version=$(grep '"version"' "$PLUGIN_DIR/plugin/.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*"version": *"//;s/".*//')
        echo "  Status: installed (v${version:-unknown})"
    else
        echo "  Status: BROKEN — run installer to fix"
    fi
    exit 0
fi

# 1. Clone or update the repo
if [ -d "$PLUGIN_DIR/.git" ]; then
    echo "Plugin already cloned at $PLUGIN_DIR, pulling latest..."
    cd "$PLUGIN_DIR" && git pull --ff-only 2>/dev/null || true
else
    echo "Cloning to $PLUGIN_DIR..."
    mkdir -p "$(dirname "$PLUGIN_DIR")"
    rm -rf "$PLUGIN_DIR"
    git clone "$REPO_URL" "$PLUGIN_DIR"
fi

# 2. Verify required files exist
for f in .claude-plugin/marketplace.json plugin/.claude-plugin/plugin.json plugin/skills/evolve/SKILL.md; do
    if [ ! -f "$PLUGIN_DIR/$f" ]; then
        echo "ERROR: Missing $f — clone may be corrupt"
        exit 1
    fi
done

# 3. Clear stale plugin cache (Claude Code reads from cache, not source)
if [ -d "$CACHE_DIR" ]; then
    echo "Clearing stale plugin cache..."
    rm -rf "$CACHE_DIR"
fi

# 4. Update settings.json
if [ ! -f "$SETTINGS" ]; then
    echo "Creating $SETTINGS..."
    mkdir -p "$(dirname "$SETTINGS")"
    cat > "$SETTINGS" << ENDJSON
{
  "enabledPlugins": {
    "loops@loops": true
  },
  "extraKnownMarketplaces": {
    "loops": {
      "source": {
        "source": "directory",
        "path": "$PLUGIN_DIR"
      }
    }
  }
}
ENDJSON
else
    if command -v python3 &>/dev/null; then
        python3 << PYEOF
import json

settings_path = "$SETTINGS"
plugin_dir = "$PLUGIN_DIR"

with open(settings_path, "r") as f:
    settings = json.load(f)

changed = False

if "enabledPlugins" not in settings:
    settings["enabledPlugins"] = {}
if "loops@loops" not in settings.get("enabledPlugins", {}):
    settings["enabledPlugins"]["loops@loops"] = True
    changed = True

if "extraKnownMarketplaces" not in settings:
    settings["extraKnownMarketplaces"] = {}
if "loops" not in settings.get("extraKnownMarketplaces", {}):
    settings["extraKnownMarketplaces"]["loops"] = {
        "source": {
            "source": "directory",
            "path": plugin_dir
        }
    }
    changed = True

if changed:
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("Updated settings.json")
else:
    print("settings.json already configured")
PYEOF
    else
        echo "WARNING: python3 not found — please add these entries to $SETTINGS manually:"
        echo '  "enabledPlugins": { "loops@loops": true }'
        echo '  "extraKnownMarketplaces": { "loops": { "source": { "source": "directory", "path": "'$PLUGIN_DIR'" } } }'
    fi
fi

echo ""
echo "=== Installed successfully ==="
echo "Restart Claude Code to pick up the skill."
echo "  /evolve [count] [target] — autonomous fix → clean → upgrade cycles"
echo ""
echo "To uninstall:  bash $PLUGIN_DIR/install.sh --uninstall"
