#!/usr/bin/env bash

set -euo pipefail

ID=$(cat metadata.json |jq -r ".KPlugin.Id")

kpackagetool6 --type Plasma/Applet --remove $ID
