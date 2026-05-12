# pico-bootstrap

Makefile-based bootstrap for Raspberry Pi **Pico** and **Pico2** (RP2040 / RP2350) C++ development with a [Debug Probe](https://www.raspberrypi.com/products/debug-probe/).

Handles downloading and building the full SDK toolchain, compiling example firmware, and flashing via OpenOCD. Designed to be reused as a **git submodule** in other projects.

---

## Prerequisites

**Debian / Ubuntu**
```bash
sudo apt install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi \
                 build-essential libstdc++-arm-none-eabi-newlib \
                 autoconf libtool pkg-config libusb-1.0-0-dev \
                 libhidapi-dev
```

**Fedora**
```bash
sudo dnf install cmake make gcc gcc-c++ \
                 arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ \
                 arm-none-eabi-newlib arm-none-eabi-binutils-cs \
                 autoconf libtool pkgconf \
                 libusb1-devel hidapi-devel
```

**RHEL 9 / CentOS Stream 9** — enable EPEL first:
```bash
sudo dnf install epel-release
sudo dnf install cmake make gcc gcc-c++ \
                 arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ \
                 arm-none-eabi-newlib arm-none-eabi-binutils-cs \
                 autoconf libtool pkgconf \
                 libusb1-devel hidapi-devel
```

Or use the Makefile targets (still require sudo):
```bash
make prereqs-deb    # Debian / Ubuntu
make prereqs-rhel   # Fedora / RHEL / CentOS
```

---

## Quickstart

```bash
# 1. Download all upstream dependencies into ./deps
make download

# 2. Build and install picotool + openocd into ./deps
make install

# 3. Compile the bare-metal LED example
make build-led

# 4. Flash it (identify your probe serial first)
make identify-probe
make upload TARGET_ELF=examples/led_toggle/build/led_toggle.elf PROBE_SERIAL=<serial>
```

---

## Target reference

| Target | Description |
|---|---|
| `download` | Clone all upstream dependencies |
| `download-pico-sdk` | Clone pico-sdk + init submodules |
| `download-pico-examples` | Clone pico-examples |
| `download-pico-extras` | Clone pico-extras |
| `download-pico-playground` | Clone pico-playground |
| `download-pico-project-generator` | Clone pico-project-generator |
| `download-picotool` | Clone picotool |
| `download-openocd` | Clone openocd (`sdk-2.0.0`) |
| `download-freertos` | Clone FreeRTOS-Kernel |
| `install` | Build and install picotool + openocd |
| `install-picotool` | Build and install picotool only |
| `install-openocd` | Build and install openocd only |
| `build-led` | Compile LED toggle (bare-metal) |
| `build-led-freertos` | Compile LED toggle (FreeRTOS) |
| `clean-led` | Remove LED toggle build directory |
| `clean-led-freertos` | Remove FreeRTOS LED build directory |
| `clean` | Remove all example build directories |
| `upload TARGET_ELF=<path>` | Flash ELF via Debug Probe |
| `identify-board` | List attached Pico/Pico2 by USB serial |
| `identify-probe` | List attached Debug Probes by USB serial |

---

## Variables

| Variable | Default | Description |
|---|---|---|
| `INSTALL_DIR` | `./deps` | Where upstream repos are cloned and tools installed |
| `TARGET_ELF` | _(required for upload)_ | Path to the `.elf` to flash |
| `PROBE_SERIAL` | _(empty = first found)_ | USB serial of the Debug Probe to use |
| `PICO_TARGET_CFG` | `rp2040.cfg` | OpenOCD target config; use `rp2350.cfg` for Pico2 |

---

## Submodule usage

```bash
# In your project
git submodule add https://github.com/rbarzic/pico-bootstrap.git pico-bootstrap
```

```makefile
# In your project's Makefile — share a common SDK installation
INSTALL_DIR ?= $(HOME)/.pico-sdk
include pico-bootstrap/Makefile
```

---

## Examples

| Example | Path | Description |
|---|---|---|
| LED toggle | `examples/led_toggle/` | Bare-metal GPIO blink, 500 ms |
| LED toggle (RTOS) | `examples/led_toggle_rtos/` | Same, via a FreeRTOS task |
