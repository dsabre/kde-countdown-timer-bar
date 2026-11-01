#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOMAIN="plasma_applet_com.dsabre.countdowntimerbar"

"$SCRIPT_DIR/update.sh"

for SOURCE in "$SCRIPT_DIR"/*.po; do
    LOCALE="$(basename "$SOURCE" .po)"
    DEST="$ROOT_DIR/contents/locale/$LOCALE/LC_MESSAGES/$DOMAIN.mo"

    mkdir -p "$(dirname "$DEST")"

    msgfmt --check -o "$DEST" "$SOURCE"

    echo "Compiled: $LOCALE"
done
