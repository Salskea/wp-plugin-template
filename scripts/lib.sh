#!/usr/bin/env bash
# Shared helpers for the scripts. Everything is derived from the main plugin file, so no script
# or workflow hardcodes the slug.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLUGIN_DIR"

# Main plugin file: the root PHP file with a "Plugin Name:" header.
PLUGIN_FILE=$(grep -l '^ \* Plugin Name:' ./*.php | head -1 | sed 's|^\./||')
if [ -z "$PLUGIN_FILE" ]; then
    echo "❌ Pääfileä (Plugin Name: -header) ei löydy hakemistosta $PLUGIN_DIR" >&2
    exit 1
fi
SLUG="${PLUGIN_FILE%.php}"

header_version() {
    grep -m1 '^ \* Version:' "$PLUGIN_FILE" | sed 's/.*Version:[[:space:]]*//' | tr -d '[:space:]'
}

constant_version() {
    grep -m1 -E "define\( '[A-Z0-9_]+_VERSION', '" "$PLUGIN_FILE" | sed -E "s/.*_VERSION', '([^']*)'.*/\1/"
}

# Newest released version in CHANGELOG.md ([Unreleased] is skipped).
changelog_version() {
    grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | sed -E 's/^## \[([^]]+)\].*/\1/'
}
