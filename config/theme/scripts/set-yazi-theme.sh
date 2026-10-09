#!/bin/bash
set -euo pipefail

THEME=$1
MODE=$2

ln -sfn ../../theme/$THEME/yazi/$MODE ~/.config/yazi/flavors/theme.yazi
