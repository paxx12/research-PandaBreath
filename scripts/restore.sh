#!/usr/bin/env bash
set -euo pipefail

BAUD=${BAUD:-460800}
FULL=0
NVS=0
NVS_ONLY=0

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <port> [--nvs] [--nvs-only] [--full] [dir]" >&2
    exit 1
fi

PORT=$1; shift
DIR=$(pwd)/dump

while [[ $# -gt 0 ]]; do
    case $1 in
        --full)     FULL=1;     shift ;;
        --nvs)      NVS=1;      shift ;;
        --nvs-only) NVS_ONLY=1; shift ;;
        *) DIR=$1; shift ;;
    esac
done

if [[ $NVS_ONLY -eq 1 ]]; then
    esptool --chip esp32c3 --port "$PORT" --baud "$BAUD" --after hard_reset write_flash \
        0x009000 "$DIR/nvs.bin"
    exit 0
fi

args=(
    0x000000 "$DIR/bootloader.bin"
    0x008000 "$DIR/partition-table.bin"
)

if [[ $NVS -eq 1 || $FULL -eq 1 ]]; then
    args+=(0x009000 "$DIR/nvs.bin")
fi

if [[ $FULL -eq 1 ]]; then
    args+=(
        0x00e000 "$DIR/otadata.bin"
    )
fi

args+=(
    0x010000 "$DIR/app0.bin"
    0x1f0000 "$DIR/app1.bin"
)

if [[ $FULL -eq 1 ]]; then
    args+=(
        0x3d0000 "$DIR/spiffs.bin"
        0x3ff000 "$DIR/coredump.bin"
    )
fi

esptool --chip esp32c3 --port "$PORT" --baud "$BAUD" --after no_reset erase_flash
esptool --chip esp32c3 --port "$PORT" --baud "$BAUD" --after hard_reset write_flash "${args[@]}"
