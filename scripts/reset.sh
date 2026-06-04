#!/usr/bin/env bash
set -euo pipefail

BAUD=${BAUD:-460800}
SPIFFS=0
NVS=0

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <port> [--nvs] [--spiffs]" >&2
    exit 1
fi

PORT=$1; shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --nvs)    NVS=1;    shift ;;
        --spiffs) SPIFFS=1; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ $NVS -eq 0 && $SPIFFS -eq 0 ]]; then
    echo "Error: specify at least one of --nvs or --spiffs" >&2
    exit 1
fi

regions=()

if [[ $NVS -eq 1 ]]; then
    regions+=(0x009000 0x005000)
fi

if [[ $SPIFFS -eq 1 ]]; then
    regions+=(0x3d0000 0x02f000)
fi

# Erase all but the last region without resetting, let the last one hard-reset
last=$(( ${#regions[@]} - 2 ))
for (( i=0; i<last; i+=2 )); do
    esptool --chip esp32c3 --port "$PORT" --baud "$BAUD" --after no_reset \
        erase_region "${regions[i]}" "${regions[i+1]}"
done
esptool --chip esp32c3 --port "$PORT" --baud "$BAUD" \
    erase_region "${regions[last]}" "${regions[last+1]}"
