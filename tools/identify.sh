#!/usr/bin/env bash
# Identify Raspberry Pi Pico/Pico2 boards, Debug Probes, and their serial ports.
# Uses /sys rather than lsusb to avoid requiring root.
#
# Usage:
#   identify.sh board              — list attached Pico/Pico2 boards
#   identify.sh probe              — list attached Debug Probes
#   identify.sh all                — list both (default)
#   identify.sh port <serial>      — print /dev/ttyACM* for the probe with that serial
#                                    exits 1 if not found

set -euo pipefail

PICO_VID="2e8a"
PICO_BOOT_PID="0003"   # RP2040 bootsel / mass-storage
PICO2_BOOT_PID="000f"  # RP2350 bootsel
PICO_CDC_PID="000a"    # RP2040 USB serial (running firmware)
PICO2_CDC_PID="0009"   # RP2350 USB serial
DEBUG_PROBE_PID="000c" # Raspberry Pi Debug Probe

MODE="${1:-all}"

# ── Helpers ───────────────────────────────────────────────────────────────────

print_device() {
    local path="$1" label="$2"
    local vid pid serial product
    vid=$(cat "$path/idVendor"    2>/dev/null || true)
    pid=$(cat "$path/idProduct"   2>/dev/null || true)
    serial=$(cat "$path/serial"   2>/dev/null || echo "(no serial)")
    product=$(cat "$path/product" 2>/dev/null || echo "")
    printf "  %-28s  VID:PID %s:%s  serial: %s\n" "$label ($product)" "$vid" "$pid" "$serial"
}

# Walk sysfs upward from a tty device to find the parent USB device directory.
usb_parent_of_tty() {
    local node
    node=$(readlink -f "/sys/class/tty/$1/device" 2>/dev/null) || return 1
    while [ "$node" != "/" ]; do
        [ -f "$node/idVendor" ] && { echo "$node"; return 0; }
        node=$(dirname "$node")
    done
    return 1
}

# ── find_devices: board | probe ───────────────────────────────────────────────

find_devices() {
    local match_mode="$1"
    local found=0
    for dev in /sys/bus/usb/devices/*/; do
        local vid pid
        vid=$(cat "$dev/idVendor"  2>/dev/null || true)
        pid=$(cat "$dev/idProduct" 2>/dev/null || true)
        [ "$vid" = "$PICO_VID" ] || continue
        case "$match_mode" in
            board)
                case "$pid" in
                    "$PICO_BOOT_PID"|"$PICO_CDC_PID")   print_device "$dev" "Pico (RP2040)";  found=1 ;;
                    "$PICO2_BOOT_PID"|"$PICO2_CDC_PID") print_device "$dev" "Pico2 (RP2350)"; found=1 ;;
                esac ;;
            probe)
                case "$pid" in
                    "$DEBUG_PROBE_PID") print_device "$dev" "Debug Probe"; found=1 ;;
                esac ;;
        esac
    done
    [ "$found" -eq 1 ] || echo "  (none found)"
}

# ── port: find /dev/ttyACM* for a given probe serial ─────────────────────────

find_port() {
    local target_serial="$1"
    local found=""
    for tty in /sys/class/tty/ttyACM*; do
        [ -e "$tty" ] || continue
        local usb_dev
        usb_dev=$(usb_parent_of_tty "$(basename "$tty")") || continue
        local vid pid serial
        vid=$(cat "$usb_dev/idVendor"  2>/dev/null || true)
        pid=$(cat "$usb_dev/idProduct" 2>/dev/null || true)
        serial=$(cat "$usb_dev/serial" 2>/dev/null || true)
        if [ "$vid" = "$PICO_VID" ] && [ "$pid" = "$DEBUG_PROBE_PID" ] && [ "$serial" = "$target_serial" ]; then
            found="/dev/$(basename "$tty")"
            break
        fi
    done
    if [ -n "$found" ]; then
        echo "$found"
    else
        echo "ERROR: no serial port found for Debug Probe serial $target_serial" >&2
        exit 1
    fi
}

# ── Dispatch ──────────────────────────────────────────────────────────────────

case "$MODE" in
    board)
        echo "Pico / Pico2 boards:"
        find_devices board ;;
    probe)
        echo "Debug Probes:"
        find_devices probe ;;
    port)
        [ "${2:-}" != "" ] || { echo "Usage: identify.sh port <probe-serial>" >&2; exit 1; }
        find_port "$2" ;;
    all)
        echo "Pico / Pico2 boards:"
        find_devices board
        echo "Debug Probes:"
        find_devices probe ;;
    *)
        echo "Usage: identify.sh board | probe | all | port <serial>" >&2
        exit 1 ;;
esac
