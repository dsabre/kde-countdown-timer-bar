#!/usr/bin/env bash

set -euo pipefail

# Build translations
./translate/build.sh

# Install plasmoid
kpackagetool6 --type Plasma/Applet --install .
# plasmapkg2 -i .
