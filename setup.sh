#!/bin/bash
set -e

# Usage: ./setup.sh "My Plugin Name" "my-plugin-name" "MY_PLUGIN_NAME"
# Renames all template placeholders and removes itself when done.

PLUGIN_TITLE="$1"   # "My Plugin Name"    → replaces "Plugin Name Here"
PLUGIN_SLUG="$2"    # "my-plugin-name"    → replaces "plugin-name"
PLUGIN_CONST="$3"   # "MY_PLUGIN_NAME"    → replaces "PLUGIN_NAME"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

usage() {
    echo "Usage: $0 \"Plugin Title\" \"plugin-slug\" \"PLUGIN_CONSTANT\""
    echo "Example: $0 \"My Awesome Plugin\" \"my-awesome-plugin\" \"MY_AWESOME_PLUGIN\""
    exit 1
}

[ $# -ne 3 ] && usage
[[ "$PLUGIN_SLUG" =~ [[:space:]] ]] && echo -e "${RED}Error: slug must not contain spaces${NC}" && exit 1
[[ "$PLUGIN_CONST" =~ [[:space:]] ]] && echo -e "${RED}Error: constant must not contain spaces${NC}" && exit 1
[[ "$PLUGIN_SLUG" =~ ^[a-z0-9-]+$ ]] || { echo -e "${RED}Error: slug must be lowercase letters, numbers and hyphens only${NC}"; exit 1; }
[[ "$PLUGIN_CONST" =~ ^[A-Z0-9_]+$ ]] || { echo -e "${RED}Error: constant must be uppercase letters, numbers and underscores only${NC}"; exit 1; }

# Derive all variants
PLUGIN_UNDERSCORE="${PLUGIN_SLUG//-/_}"
# awk, not sed: sed's \U is a GNU extension and BSD sed (macOS) emits a literal U
PLUGIN_CLASS=$(echo "$PLUGIN_SLUG" | awk -F- 'BEGIN{OFS="_"} {for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
# In a sed replacement & means "the whole match", so a title like "Foo & Bar"
# would reinsert the placeholder. Escape it (and / \) for the sed passes only.
PLUGIN_TITLE_SED=$(printf '%s' "$PLUGIN_TITLE" | sed 's/[&/\]/\\&/g')
TODAY=$(date +%Y-%m-%d)

echo -e "${YELLOW}Setting up WordPress plugin:${NC}"
echo "  Title:      $PLUGIN_TITLE"
echo "  Slug:       $PLUGIN_SLUG"
echo "  Underscore: $PLUGIN_UNDERSCORE"
echo "  Class:      $PLUGIN_CLASS"
echo "  Constant:   $PLUGIN_CONST"
echo "  Date:       $TODAY"
echo ""

# Replace placeholders in all text files (order matters: longest/most specific first)
echo -e "${GREEN}1. Replacing placeholders in files...${NC}"
find . -type f \( -name "*.php" -o -name "*.css" -o -name "*.js" -o -name "*.md" \
    -o -name "*.txt" -o -name "*.yml" -o -name "*.pot" -o -name "*.sh" \) \
    -not -path "./.git/*" \
    -not -name "setup.sh" | while read -r file; do
    sed -i '' \
        -e "s/Plugin Name Here/$PLUGIN_TITLE_SED/g" \
        -e "s/PLUGIN_NAME/$PLUGIN_CONST/g" \
        -e "s/Plugin_Name/$PLUGIN_CLASS/g" \
        -e "s/plugin_name/$PLUGIN_UNDERSCORE/g" \
        -e "s/plugin-name/$PLUGIN_SLUG/g" \
        -e "s/Plugin Author/$PLUGIN_TITLE_SED/g" \
        "$file"
done

# Rename files (sort -r processes deepest paths first to avoid conflicts)
echo -e "${GREEN}2. Renaming files...${NC}"
find . -name "*plugin-name*" -not -path "./.git/*" | sort -r | while read -r f; do
    newf="${f//plugin-name/$PLUGIN_SLUG}"
    if [ "$f" != "$newf" ]; then
        mv "$f" "$newf"
        echo "  renamed: $f → $newf"
    fi
done

# Update VERSION date
echo -e "${GREEN}3. Updating VERSION...${NC}"
printf '%s\n%s\n' "0.1.0" "$TODAY" > VERSION

# Reset CHANGELOG.md
echo -e "${GREEN}4. Resetting CHANGELOG.md...${NC}"
cat > CHANGELOG.md << EOF
# Changelog

All notable changes to $PLUGIN_TITLE will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - $TODAY

### Added
- Initial release
EOF

echo ""
echo -e "${GREEN}✅ Plugin setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Update plugin description and URIs in ${PLUGIN_SLUG}.php"
echo "  2. git add -A && git commit -m 'feat: initial plugin setup'"
echo "  3. Push to your git remote"
echo "  4. For Forgejo releases: add RELEASE_TOKEN secret in repo Settings → Secrets"
echo ""

# Self-destruct
rm -- "$0"
echo "setup.sh removed."
