# Panda Breath — ESP32-C3 GPIO Map

Derived from boot log GPIO configuration messages (`logs/panda_breath_boot.log`, lines 63–96).

## Sensors

| GPIO | Sensor | Notes |
|------|--------|-------|
| GPIO 0 | Chamber temperature (NTC) | ADC1_CH0. B=3950, 100 kΩ @ 25 °C. |
| GPIO 1 | PTC heater sensor | ADC1_CH1. B=3950, 100 kΩ @ 25 °C. |

Both pins show `InputEn:0 OutputEn:0` — the ESP-IDF ADC driver claims them directly without going through the GPIO matrix.

Both sensors use a 100 kΩ voltage-divider (DOWNSTREAM) feeding the NTC platform with B=3950.

## Buttons & LEDs

Each mode button has a corresponding indicator LED. All buttons are active-low with internal pullup.

| Mode | Button GPIO | LED GPIO |
|------|-------------|----------|
| Filament Drying | GPIO 2 | GPIO 4 |
| Heating On (Force) | GPIO 10 | GPIO 5 |
| Heating Auto | GPIO 8 | GPIO 6 |
| Power Off | GPIO 9 | GPIO 21 |

## Fan & Heater

| GPIO | Function | Notes |
|------|----------|-------|
| GPIO 3 | **Fan on/off** | Push-pull output, drives enclosure fan directly. |
| GPIO 7 | **Zero-crossing detector** | Input with interrupt — detects 50/60 Hz mains zero crossings for SSR phase control. |
| GPIO 18 | **PTC heater SSR control** | Output to solid-state relay switching the PTC heating element. Paired with GPIO 7 zero-crossing for phase-accurate switching. |

## UART

GPIO 20/21 are UART0, wired to a CH342 USB-to-serial bridge. Used only for flashing and the ESPHome logger — there is no application-level serial communication with the printer.

GPIO 21 is the **Power On LED**. Logger set to `level: NONE` so GPIO 21 is free for direct LED control.

## Unknowns

| GPIO | Direction | Notes |
|------|-----------|-------|
| 11–17 | — | Internal SPI flash — hardwired to flash chip, must not be reconfigured. |
| 19 | Input | **Power Off LED** (candidate) — USB D+ pad repurposed. Configured as binary sensor; function unconfirmed. |
