# Starting a new project with pico-bootstrap

This guide shows how to create a new Pico/Pico2 C++ project that reuses
pico-bootstrap as a git submodule for toolchain management.

---

## Quick way — use the scaffold target

From inside a clone of pico-bootstrap:

```bash
make scaffold PROJECT_NAME=my-blinky
```

This creates `../my-blinky/` with all files in place and pico-bootstrap
already added as a submodule. Skip to [Build and flash](#build-and-flash).

An optional `PROJECT_DIR` override places the project elsewhere:

```bash
make scaffold PROJECT_NAME=my-blinky PROJECT_DIR=~/projects/my-blinky
```

---

## Manual way

### 1. Create the project and add the submodule

```bash
mkdir my-blinky && cd my-blinky
git init
git submodule add https://github.com/rbarzic/pico-bootstrap.git pico-bootstrap
```

### 2. Copy and adapt the template files

```bash
cp pico-bootstrap/templates/Makefile       Makefile
cp pico-bootstrap/templates/CMakeLists.txt CMakeLists.txt
mkdir src
cp pico-bootstrap/templates/src/main.cpp  src/main.cpp
```

Replace the `@PROJECT_NAME@` placeholder with your actual project name:

```bash
PROJECT=my-blinky
sed -i "s/@PROJECT_NAME@/$PROJECT/g" Makefile CMakeLists.txt src/main.cpp
```

### 3. Create a .gitignore

```
build/
*.elf *.bin *.hex *.uf2 *.map
```

---

## Project layout after scaffolding

```
my-blinky/
├── Makefile              ← project Makefile (includes pico-bootstrap/Makefile)
├── CMakeLists.txt        ← CMake project definition
├── src/
│   └── main.cpp          ← application entry point
├── pico-bootstrap/       ← submodule (toolchain, examples, tools)
└── .gitignore
```

---

## Files to edit

| File | What to change |
|---|---|
| `Makefile` | `PROJECT_NAME`, `INSTALL_DIR`, `PICO_TARGET_CFG` (rp2040/rp2350) |
| `CMakeLists.txt` | Add sources, libraries, enable/disable stdio |
| `src/main.cpp` | Application code |

### Sharing the SDK across projects

Set `INSTALL_DIR` to a common location so all your projects reuse the same
SDK download (~2 GB) instead of each having their own copy:

```makefile
# Makefile
INSTALL_DIR ?= $(HOME)/.pico-sdk
```

Run `make download && make install` once; every subsequent project that
points to the same `INSTALL_DIR` skips the download.

### Choosing between Pico and Pico2

```makefile
# Makefile — Pico2 (RP2350)
PICO_TARGET_CFG ?= rp2350.cfg
```

Also set `PICO_PLATFORM` in `CMakeLists.txt` if you need RP2350-specific
SDK features:

```cmake
set(PICO_PLATFORM rp2350)   # before pico_sdk_init()
```

---

## Build and flash

```bash
cd my-blinky

# First time only — download and build the toolchain
make download
make install

# Build the project firmware
make build

# Identify the Debug Probe serial number
make identify-probe

# Flash
make flash PROBE_SERIAL=<serial>

# Open serial monitor (UART on GP0/GP1 via Debug Probe)
make monitor PROBE_SERIAL=<serial>
```

---

## Available targets (inherited from pico-bootstrap)

The project Makefile exposes its own `build`, `clean`, `flash`, and
`monitor-project` targets, plus everything from pico-bootstrap:
`download`, `install`, `identify-probe`, `identify-port`,
`install-udev-rules`, `prereqs-deb`, `prereqs-rhel`, etc.

Run `make help` for the full list.
