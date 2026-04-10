#!/bin/bash
set -e

# Usage: ./version-bump.sh <new-version> <type>
# Example: ./version-bump.sh 1.1.0 minor
# Types: major, minor, patch

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PLUGIN_DIR"

usage() {
    echo "Usage: $0 <new-version> <type>"
    echo "  $0 1.1.0 minor"
    exit 1
}

[ $# -ne 2 ] && usage
NEW_VERSION=$1
RELEASE_TYPE=$2
CURRENT_DATE=$(date +%Y-%m-%d)

if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: version must be x.y.z format${NC}"; exit 1
fi
if [[ ! "$RELEASE_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: type must be major, minor, or patch${NC}"; exit 1
fi

# Detect plugin files dynamically
MAIN_FILE=$(grep -rl "Plugin Name:" --include="*.php" . | grep -v vendor | grep -v ".git" | head -1)
if [ -z "$MAIN_FILE" ]; then
    echo -e "${RED}Error: could not find main plugin PHP file (looking for 'Plugin Name:' header)${NC}"; exit 1
fi
CONST_NAME=$(grep -m1 "define.*_VERSION" "$MAIN_FILE" | grep -o "'[A-Z_]*'" | head -1 | tr -d "'")
CLASS_FILE=$(find includes -name "class-*.php" 2>/dev/null | grep -v activator | grep -v deactivator | grep -v loader | grep -v i18n | head -1)

CURRENT_VERSION=$(head -1 VERSION)
echo -e "${YELLOW}Bumping $CURRENT_VERSION → $NEW_VERSION${NC}"
echo "  Main file:  $MAIN_FILE"
[ -n "$CONST_NAME"  ] && echo "  Constant:   $CONST_NAME"
[ -n "$CLASS_FILE"  ] && echo "  Class file: $CLASS_FILE"
echo ""

if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: working directory is not clean. Commit changes first.${NC}"
    git status --short; exit 1
fi

echo -e "${GREEN}1. Updating VERSION...${NC}"
printf '%s\n%s\n' "$NEW_VERSION" "$CURRENT_DATE" > VERSION

echo -e "${GREEN}2. Updating plugin header Version:...${NC}"
sed -i '' "s/^\( \* Version:.*\)$/\ * Version:           $NEW_VERSION/" "$MAIN_FILE"

if [ -n "$CONST_NAME" ]; then
    echo -e "${GREEN}3. Updating $CONST_NAME constant...${NC}"
    sed -i '' "s/define( '$CONST_NAME', '.*' );/define( '$CONST_NAME', '$NEW_VERSION' );/" "$MAIN_FILE"
fi

if [ -n "$CLASS_FILE" ]; then
    echo -e "${GREEN}4. Updating class version fallback in $CLASS_FILE...${NC}"
    sed -i '' "s/\(\$this->version = '\)[^']*\('; \)/\1$NEW_VERSION\2/" "$CLASS_FILE"
fi

echo -e "${GREEN}5. Adding CHANGELOG.md entry placeholder...${NC}"
TEMP=$(mktemp)
{
    head -7 CHANGELOG.md
    echo ""
    echo "## [$NEW_VERSION] - $CURRENT_DATE"
    echo ""
    echo "### Added"
    echo "- "
    echo ""
    tail -n +8 CHANGELOG.md
} > "$TEMP"
mv "$TEMP" CHANGELOG.md

echo ""
echo -e "${YELLOW}Please edit CHANGELOG.md to add release notes for $NEW_VERSION${NC}"
${EDITOR:-nano} CHANGELOG.md

echo ""
git diff --stat
echo ""
echo -e "${YELLOW}Commit and tag v$NEW_VERSION? (y/n)${NC}"
read -r CONFIRM
if [ "$CONFIRM" != "y" ]; then
    REVERT="VERSION CHANGELOG.md $MAIN_FILE"
    [ -n "$CLASS_FILE" ] && REVERT="$REVERT $CLASS_FILE"
    git checkout $REVERT
    echo -e "${RED}Aborted.${NC}"; exit 1
fi

FILES_TO_STAGE="VERSION CHANGELOG.md $MAIN_FILE"
[ -n "$CLASS_FILE" ] && FILES_TO_STAGE="$FILES_TO_STAGE $CLASS_FILE"

case $RELEASE_TYPE in
    major) PREFIX="feat!" ;;
    minor) PREFIX="feat" ;;
    patch) PREFIX="fix" ;;
esac

git add $FILES_TO_STAGE
git commit -m "$PREFIX: bump version to $NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "Release $NEW_VERSION"

echo ""
echo -e "${YELLOW}Push to remote? (y/n)${NC}"
read -r PUSH
if [ "$PUSH" = "y" ]; then
    git push origin main
    git push origin "v$NEW_VERSION"
    echo -e "${GREEN}✅ Version $NEW_VERSION pushed and tagged. CI/CD will build the release automatically.${NC}"
else
    echo -e "${YELLOW}Committed locally. Push manually when ready:${NC}"
    echo "  git push origin main && git push origin v$NEW_VERSION"
fi
