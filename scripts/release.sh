#!/usr/bin/env bash
# release.sh — Releases a new version.
#
# The release notes are what was written under "## [Unreleased]" in CHANGELOG.md during
# development. This script turns that section into the new version, bumps the plugin header and
# *_VERSION constant, runs every check, commits, tags and (on confirmation) pushes. CI then
# builds the zip and the GitHub Release.
#
# Usage:
#   ./scripts/release.sh          # suggests a version from the commit messages
#   ./scripts/release.sh 1.1.0    # uses the given version

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

CURRENT=$(header_version)
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
TODAY=$(date +%Y-%m-%d)

# ── Preconditions ────────────────────────────────────────────────────────────

if [ "$(git branch --show-current)" != "main" ]; then
    echo "❌ Julkaisu tehdään main-haarasta."
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Työhakemistossa on committoimattomia muutoksia."
    git status --short
    exit 1
fi

# Body of the [Unreleased] section: lines up to the next "## [" heading.
UNRELEASED=$(awk '/^## \[Unreleased\]/{found=1; next} found && /^## \[/{exit} found{print}' CHANGELOG.md)
if ! grep -qE '^[[:space:]]*[-*] ' <<< "$UNRELEASED"; then
    echo "❌ CHANGELOG.md:n [Unreleased]-osio on tyhjä tai puuttuu. Kirjaa muutokset sinne ensin."
    exit 1
fi

# ── Suggest a version from conventional commits since the last tag ───────────

suggest_version() {
    local major minor patch
    IFS='.' read -r major minor patch <<< "$CURRENT"

    local commits
    if [ -n "$LAST_TAG" ]; then
        commits=$(git log "${LAST_TAG}..HEAD" --pretty=format:"%s%n%b")
    else
        commits=$(git log --pretty=format:"%s%n%b")
    fi

    if grep -qE "BREAKING[ -]CHANGE|^[a-z]+(\(.+\))?!:" <<< "$commits"; then
        echo "$((major + 1)).0.0"
    elif grep -qE "^feat(\(.+\))?:" <<< "$commits"; then
        echo "${major}.$((minor + 1)).0"
    else
        echo "${major}.${minor}.$((patch + 1))"
    fi
}

SUGGESTED=$(suggest_version)

echo ""
echo "Nykyinen versio : $CURRENT"
echo "Viimeisin tagi  : ${LAST_TAG:-—}"
echo ""
echo "Commitit ${LAST_TAG:-alusta}..HEAD:"
if [ -n "$LAST_TAG" ]; then
    git log "${LAST_TAG}..HEAD" --pretty=format:"  %s"
else
    git log --pretty=format:"  %s" | head -20
fi
echo ""
echo ""
echo "[Unreleased]:"
echo "$UNRELEASED"
echo ""

if [ $# -ge 1 ]; then
    NEW_VERSION="$1"
else
    read -rp "Uusi versio [$SUGGESTED]: " INPUT_VERSION
    NEW_VERSION="${INPUT_VERSION:-$SUGGESTED}"
fi

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Versio '$NEW_VERSION' ei ole muotoa x.y.z"
    exit 1
fi

if git rev-parse -q --verify "refs/tags/v${NEW_VERSION}" > /dev/null; then
    echo "❌ Tagi v${NEW_VERSION} on jo olemassa"
    exit 1
fi

# ── Bump: header, constant, CHANGELOG ────────────────────────────────────────

echo ""
echo "Päivitetään versio → $NEW_VERSION"

V="$NEW_VERSION" perl -pi -e 's/^( \* Version:\s*).*/$1$ENV{V}/; s/(define\( \x27[A-Z0-9_]+_VERSION\x27, \x27)[^\x27]*/$1$ENV{V}/' "$PLUGIN_FILE"
V="$NEW_VERSION" D="$TODAY" perl -pi -e 's/^## \[Unreleased\].*$/## [Unreleased]\n\n## [$ENV{V}] - $ENV{D}/' CHANGELOG.md

./scripts/check-version.sh "$NEW_VERSION"

echo ""
echo "Ajetaan tarkistukset (composer check)..."
composer check --quiet || { echo "❌ Tarkistukset epäonnistuivat. Palauta muutokset: git checkout -- ."; exit 1; }

# ── Commit, tag, push ────────────────────────────────────────────────────────

echo ""
git diff --stat
echo ""
read -rp "Committoidaanko ja tagataanko v${NEW_VERSION}? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Peruutettu. Palauta muutokset: git checkout -- ."
    exit 0
fi

git add "$PLUGIN_FILE" CHANGELOG.md
git commit -q -m "chore: release ${NEW_VERSION}"
git tag "v${NEW_VERSION}"

echo ""
read -rp "Pushataanko GitHubiin? [y/N] " PUSH_CONFIRM
if [[ "$PUSH_CONFIRM" == "y" || "$PUSH_CONFIRM" == "Y" ]]; then
    git push origin main "v${NEW_VERSION}"
    echo "✅ v${NEW_VERSION} pushattu. CI rakentaa zipin ja GitHub Releasen."
else
    echo "✅ Commit ja tagi luotu paikallisesti. Pushaa: git push origin main v${NEW_VERSION}"
fi
