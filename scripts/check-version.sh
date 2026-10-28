#!/usr/bin/env bash
# check-version.sh — Checks that the version matches in every place it is written:
# plugin header, *_VERSION constant and the newest CHANGELOG.md release.
#
# Usage:
#   ./scripts/check-version.sh          # the three places agree
#   ./scripts/check-version.sh 1.2.0    # ...and equal 1.2.0 (release tag)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

HEADER=$(header_version)
CONSTANT=$(constant_version)
CHANGELOG=$(changelog_version)
EXPECTED="${1:-$HEADER}"

FAIL=0
for PAIR in "$PLUGIN_FILE Version:=$HEADER" \
            "$PLUGIN_FILE *_VERSION=$CONSTANT" \
            "CHANGELOG.md uusin versio=$CHANGELOG"; do
    NAME="${PAIR%%=*}"; VALUE="${PAIR#*=}"
    if [ "$VALUE" != "$EXPECTED" ]; then
        echo "❌ $NAME '$VALUE' != '$EXPECTED'"
        FAIL=1
    fi
done

if [ $FAIL -eq 1 ]; then
    echo "Versio pitää olla sama kaikissa kolmessa paikassa. Käytä ./scripts/release.sh."
    exit 1
fi

echo "✅ Versio $EXPECTED on sama kaikkialla."
