#!/usr/bin/env bash
# init.sh — Turns a fresh copy of the template into a new plugin. Run once, then commit.
#
# Usage:
#   ./scripts/init.sh <slug> "<Plugin Name>" <Vendor\\Namespace>
#
# Example:
#   ./scripts/init.sh acme-events "Acme Events" 'Acme\Events'
#
# Derived from the slug: constant prefix ACME_EVENTS, option/hook prefix acme_events.
# Composer package: acme/acme-events (vendor = first namespace segment, lowercased).

set -euo pipefail

if [ $# -ne 3 ]; then
    sed -n '4,11p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi

SLUG="$1"
NAME="$2"
NAMESPACE="$3"

if ! [[ "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "❌ Slug '$SLUG': vain pieniä kirjaimia, numeroita ja väliviivoja (esim. acme-events)."
    exit 1
fi
if ! [[ "$NAMESPACE" =~ ^[A-Z][A-Za-z0-9]*(\\[A-Z][A-Za-z0-9]*)+$ ]]; then
    echo "❌ Namespace '$NAMESPACE': muotoa Vendor\\Nimi (esim. 'Acme\\Events')."
    exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [ ! -f salskea-skeleton.php ]; then
    echo "❌ salskea-skeleton.php puuttuu: pohja on jo alustettu."
    exit 1
fi

CONST_PREFIX=$(tr 'a-z-' 'A-Z_' <<< "$SLUG")
SNAKE=$(tr '-' '_' <<< "$SLUG")
VENDOR=$(tr 'A-Z' 'a-z' <<< "${NAMESPACE%%\\*}")

# Plugin-facing README and CHANGELOG replace the template's own.
mv scripts/init/README.md README.md
mv scripts/init/CHANGELOG.md CHANGELOG.md
rm -r scripts/init scripts/init.sh

git mv -f salskea-skeleton.php "$SLUG.php" 2> /dev/null || mv salskea-skeleton.php "$SLUG.php"
git mv -f assets/salskea-skeleton.css "assets/$SLUG.css" 2> /dev/null || mv assets/salskea-skeleton.css "assets/$SLUG.css"

FILES=$(find . -type f \
    -not -path './.git/*' -not -path './vendor/*' -not -path './dist/*' \
    \( -name '*.php' -o -name '*.json' -o -name '*.md' -o -name '*.dist' -o -name '*.yml' -o -name '*.css' \))

# Most specific placeholders first. The namespace rule keeps the backslash count, so it covers
# both Salskea\Skeleton (PHP) and Salskea\\Skeleton (JSON).
export COMPOSER_NAME="$VENDOR/$SLUG" NAMESPACE CONST_PREFIX SNAKE SLUG NAME TODAY="$(date +%Y-%m-%d)"
# shellcheck disable=SC2086
perl -pi -e '
    s/\Qsalskea\/salskea-skeleton\E/$ENV{COMPOSER_NAME}/g;
    s/Salskea(\\+)Skeleton/join( $1, split( m{\\}, $ENV{NAMESPACE} ) )/ge;
    s/SALSKEA_SKELETON/$ENV{CONST_PREFIX}/g;
    s/salskea_skeleton/$ENV{SNAKE}/g;
    s/salskea-skeleton/$ENV{SLUG}/g;
    s/Salskea Skeleton/$ENV{NAME}/g;
    s/Salskean WordPress-lisäosapohja\./TODO: lyhyt kuvaus./g;
    s/\{\{DATE\}\}/$ENV{TODAY}/g;
' $FILES

composer update --lock --quiet
composer install --quiet

echo ""
echo "✅ $NAME ($SLUG) alustettu."
echo ""
echo "Seuraavaksi:"
echo "  1. Täydennä kuvaus: $SLUG.php (Description), composer.json ja README.md"
echo "  2. composer check"
echo "  3. git add -A && git commit -m \"feat: initial plugin structure\""
