#!/usr/bin/env bash

set -euo pipefail

ID=$(jq -r '.KPlugin.Id' metadata.json)

kpackagetool6 --type Plasma/Applet --remove $ID
