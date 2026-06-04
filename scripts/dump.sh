#!/usr/bin/env bash
set -euo pipefail

PORT=${1:-/dev/ttyUSB0}
BAUD=${BAUD:-460800}
DIR=${2:-$(pwd)/dump}

mkdir -p "$DIR"

e() {
    esptool --chip esp32c3 --port "$PORT" --baud "$BAUD" read_flash "$@"
}

e 0x000000 0x008000 "$DIR/bootloader.bin"
e 0x008000 0x001000 "$DIR/partition-table.bin"
e 0x009000 0x005000 "$DIR/nvs.bin"
e 0x00e000 0x002000 "$DIR/otadata.bin"
e 0x010000 0x1e0000 "$DIR/app0.bin"
e 0x1f0000 0x1e0000 "$DIR/app1.bin"
e 0x3d0000 0x02f000 "$DIR/spiffs.bin"
e 0x3ff000 0x001000 "$DIR/coredump.bin"
