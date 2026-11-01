#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ID="$(jq -r '.KPlugin.Id' metadata.json)"

if [[ -z "$ID" || "$ID" == "null" ]]; then
    echo "Unable to determine plasmoid ID." >&2
    exit 1
fi

kpackagetool6 --type Plasma/Applet --remove "$ID"
