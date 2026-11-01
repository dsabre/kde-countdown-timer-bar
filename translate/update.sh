#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

DOMAIN="plasma_applet_com.dsabre.countdowntimerbar"
POT_FILE="$SCRIPT_DIR/$DOMAIN.pot"
PO_FILE="$SCRIPT_DIR/it.po"

echo "[translate] Extracting QML strings..."

mapfile -d '' QML_FILES < <(
    find "$ROOT_DIR/contents" -type f -name '*.qml' -print0
)

if [[ ${#QML_FILES[@]} -eq 0 ]]; then
    echo "[translate] No QML files found"
    exit 1
fi

xgettext \
    --language=JavaScript \
    --keyword=i18n:1 \
    --from-code=UTF-8 \
    --package-name="Countdown Timer Bar" \
    --package-version="2.0" \
    --output="$POT_FILE" \
    "${QML_FILES[@]}"

echo "[translate] Updating Italian catalog..."

msgmerge \
    --update \
    --backup=none \
    "$PO_FILE" \
    "$POT_FILE"

echo "[translate] Extraction completed"
