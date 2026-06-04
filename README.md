# Panda Breath Firmware

Captured firmware for the Panda Breath device. The `dump/` directory holds binary images read directly from flash; `scripts/` provides tools to back up and restore them using `esptool`.

**Device requirement:** ESP32-C3 with 4 MB flash. The partition layout and image offsets are fixed to 4 MB — a device with less flash will not work.

## Requirements

```bash
apt install esptool
```

Or:

```bash
pip install esptool
```

## Scripts

### `scripts/dump.sh` — read firmware from device

Reads all flash partitions from a connected device and saves them to a local directory.

```bash
scripts/dump.sh [port] [dir]
```

| Argument | Default | Description |
|---|---|---|
| `port` | `/dev/ttyUSB0` | Serial port the device is connected to |
| `dir` | `./dump` | Directory to write the binary files into |

The `BAUD` environment variable controls the transfer rate (default `460800`).

```bash
# Default port and output directory
scripts/dump.sh

# Custom port
scripts/dump.sh /dev/ttyACM0

# Custom port and output directory
scripts/dump.sh /dev/ttyACM0 ./my-backup
```

Partitions written: `bootloader.bin`, `partition-table.bin`, `nvs.bin`, `otadata.bin`, `app0.bin`, `app1.bin`, `spiffs.bin`, `coredump.bin`.

---

### `scripts/restore.sh` — write firmware to device

Erases flash and restores firmware from a local directory back to the device.

```bash
scripts/restore.sh <port> [--nvs] [--nvs-only] [--full] [dir]
```

| Argument | Default | Description |
|---|---|---|
| `port` | *(required)* | Serial port the device is connected to |
| `--nvs` | off | Also restore `nvs.bin` (Wi-Fi credentials and device binding) |
| `--nvs-only` | off | Restore `nvs.bin` only — skips firmware and erase_flash |
| `--full` | off | Restore everything: `nvs.bin`, `otadata.bin`, `spiffs.bin`, `coredump.bin` |
| `dir` | `./dump` | Directory containing the binary files to flash |

`--full` implies `--nvs`. `--nvs-only` writes only the NVS partition without erasing flash first, which is useful for updating credentials on a running device.

```bash
# Restore firmware only (bootloader + partition table + app0 + app1)
scripts/restore.sh /dev/ttyUSB0

# Restore firmware and NVS (Wi-Fi + binding)
scripts/restore.sh /dev/ttyUSB0 --nvs

# Restore NVS only (Wi-Fi + binding), leave firmware untouched
scripts/restore.sh /dev/ttyUSB0 --nvs-only

# Full restore including NVS, OTA data, SPIFFS, and core dump
scripts/restore.sh /dev/ttyUSB0 --full

# Restore from a specific directory
scripts/restore.sh /dev/ttyUSB0 ./my-backup
```

> **Warning:** `restore.sh` always runs `erase_flash` before writing, which wipes all existing data on the device.

---

### `scripts/reset.sh` — erase specific partitions

Erases individual partitions without touching the firmware, then resets the device.

```bash
scripts/reset.sh <port> [--nvs] [--spiffs]
```

| Argument | Default | Description |
|---|---|---|
| `port` | *(required)* | Serial port the device is connected to |
| `--nvs` | off | Erase the NVS partition (0x009000, 20 KB) — clears Wi-Fi credentials and device binding |
| `--spiffs` | off | Erase the SPIFFS partition (0x3d0000, 188 KB) |

The NVS partition stores Wi-Fi credentials and device binding information (e.g. pairing/registration state). Erasing it resets the device to an unconfigured state. At least one flag is required; flags can be combined.

```bash
# Erase NVS only (reset Wi-Fi and binding)
scripts/reset.sh /dev/ttyUSB0 --nvs

# Erase SPIFFS only
scripts/reset.sh /dev/ttyUSB0 --spiffs

# Erase both
scripts/reset.sh /dev/ttyUSB0 --nvs --spiffs
```
