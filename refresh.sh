#!/usr/bin/env bash

set -euo pipefail

./uninstall.sh
./install.sh
systemctl --user restart plasma-plasmashell
