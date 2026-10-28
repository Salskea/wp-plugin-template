#!/usr/bin/env bash
# build-zip.sh — Builds the production zip: dist/<slug>-vX.Y.Z.zip
#
# Contains only what runs on the site: main file, uninstall.php, includes/, assets/, languages/,
# vendor/ without dev dependencies, README.md and CHANGELOG.md. The release workflow uses this
# same script, so a local zip matches the released one.
#
# The working tree's vendor/ is not touched; production dependencies are installed in a copy.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

VERSION=$(header_version)
ZIP_NAME="$SLUG-v$VERSION.zip"
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT
DEST="$BUILD_DIR/$SLUG"

echo "Rakennetaan $ZIP_NAME"

mkdir -p "$DEST" dist
cp "$PLUGIN_FILE" uninstall.php README.md CHANGELOG.md composer.json composer.lock "$DEST/"
cp -R includes "$DEST/"
for DIR in assets languages; do
    [ -d "$DIR" ] && cp -R "$DIR" "$DEST/"
done

composer install --working-dir="$DEST" --no-dev --prefer-dist --no-progress --quiet --optimize-autoloader
rm "$DEST/composer.json" "$DEST/composer.lock"
find "$DEST" -name '.DS_Store' -delete

rm -f "dist/$ZIP_NAME"
( cd "$BUILD_DIR" && zip -qr "$PLUGIN_DIR/dist/$ZIP_NAME" "$SLUG" )

echo "✅ dist/$ZIP_NAME"
