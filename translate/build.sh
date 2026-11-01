#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

DOMAIN="plasma_applet_com.dsabre.countdowntimerbar"
LOCALE="it"

echo "[translate] Updating translations..."

"$SCRIPT_DIR/update.sh"

echo "[translate] Compiling Italian catalog..."

SOURCE="$SCRIPT_DIR/$LOCALE.po"
DEST="$ROOT_DIR/contents/locale/$LOCALE/LC_MESSAGES/$DOMAIN.mo"

mkdir -p "$(dirname "$DEST")"

msgfmt --check -o "$DEST" "$SOURCE"

echo "[translate] Build completed successfully"
