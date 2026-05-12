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
| `build-uart-hello` | Compile UART hello (Debug Probe serial, GP0/GP1) |
| `clean-led` | Remove LED toggle build directory |
| `clean-led-freertos` | Remove FreeRTOS LED build directory |
| `clean-uart-hello` | Remove UART hello build directory |
| `clean` | Remove all example build directories |
| `upload TARGET_ELF=<path>` | Flash ELF via Debug Probe |
| `identify-board` | List attached Pico/Pico2 by USB serial |
| `identify-probe` | List attached Debug Probes by USB serial |
| `identify-port` | Print `/dev/ttyACM*` for `PROBE_SERIAL` |
| `monitor` | Open serial monitor for `PROBE_SERIAL` at 115200 baud |
| `install-udev-rules` | Install OpenOCD udev rules (requires sudo) |
| `prereqs-deb` | Install prerequisites on Debian/Ubuntu (requires sudo) |
| `prereqs-rhel` | Install prerequisites on Fedora/RHEL/CentOS (requires sudo) |

---

## Variables

| Variable | Default | Description |
|---|---|---|
| `INSTALL_DIR` | `./deps` | Where upstream repos are cloned and tools installed |
| `TARGET_ELF` | _(required for upload)_ | Path to the `.elf` to flash |
| `PROBE_SERIAL` | _(empty = first found)_ | USB serial of the Debug Probe to use |
| `PICO_TARGET_CFG` | `rp2040.cfg` | OpenOCD target config; use `rp2350.cfg` for Pico2 |
| `MONITOR_BAUD` | `115200` | Baud rate for the `monitor` target |

---

## Starting a new project

Use the scaffold target to create a ready-to-build project with
pico-bootstrap already wired in as a submodule:

```bash
make scaffold PROJECT_NAME=my-blinky
cd ../my-blinky
make download && make install
make build
make flash PROBE_SERIAL=<serial>
```

See [docs/new-project.md](docs/new-project.md) for the full guide,
manual setup instructions, SDK sharing across projects, and Pico2 notes.

---

## Examples

| Example | Build target | ELF path | Description |
|---|---|---|---|
| LED toggle | `build-led` | `examples/led_toggle/build/led_toggle.elf` | Bare-metal GPIO25 blink, 500 ms |
| LED toggle (FreeRTOS) | `build-led-freertos` | `examples/led_toggle_rtos/build/led_toggle_rtos.elf` | Same blink via a FreeRTOS task |
| UART hello | `build-uart-hello` | `examples/uart_hello/build/uart_hello.elf` | Prints a counter over UART0 (GP0/GP1) at 115200 baud, echoes received chars |

Flash and monitor the UART example:
```bash
make build-uart-hello
make upload TARGET_ELF=examples/uart_hello/build/uart_hello.elf PROBE_SERIAL=<serial>
make monitor PROBE_SERIAL=<serial>   # auto-detects /dev/ttyACM*, Ctrl-A K to quit
```
