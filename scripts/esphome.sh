#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ESPHOME_DIR="$SCRIPT_DIR/../esphome"
VENV="$ESPHOME_DIR/.venv"

if [[ ! -f "$ESPHOME_DIR/secrets.yaml" ]]; then
    cp "$ESPHOME_DIR/secrets.yaml.example" "$ESPHOME_DIR/secrets.yaml"
    echo "Created secrets.yaml from example — edit it to add WiFi credentials."
fi

if [[ ! -d "$VENV" ]]; then
    echo "Setting up ESPHome venv in $VENV ..."
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install --quiet --upgrade pip
    "$VENV/bin/pip" install --quiet esphome
    echo "Done."
fi

export IDF_CCACHE_ENABLE=1
export PLATFORMIO_BUILD_CACHE_DIR="$ESPHOME_DIR/.pio/build-cache"
exec "$VENV/bin/esphome" "$@"
