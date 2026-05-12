# ─── Configuration ────────────────────────────────────────────────────────────
INSTALL_DIR     ?= $(CURDIR)/deps
STAMP_DIR       := $(INSTALL_DIR)/.stamps

PICO_SDK_PATH   := $(INSTALL_DIR)/pico-sdk
FREERTOS_PATH   := $(INSTALL_DIR)/FreeRTOS-Kernel

# Repos
PICO_SDK_URL                := https://github.com/raspberrypi/pico-sdk.git
PICO_EXAMPLES_URL           := https://github.com/raspberrypi/pico-examples.git
PICO_EXTRAS_URL             := https://github.com/raspberrypi/pico-extras.git
PICO_PLAYGROUND_URL         := https://github.com/raspberrypi/pico-playground.git
PICO_PROJECT_GENERATOR_URL  := https://github.com/raspberrypi/pico-project-generator.git
PICOTOOL_URL                := https://github.com/raspberrypi/picotool.git
OPENOCD_URL                 := https://github.com/raspberrypi/openocd.git
FREERTOS_URL                := https://github.com/FreeRTOS/FreeRTOS-Kernel.git

OPENOCD_BRANCH  := sdk-2.0.0

# Upload
PROBE_SERIAL    ?=
TARGET_ELF      ?=

# ─── Phony targets ────────────────────────────────────────────────────────────
.PHONY: help \
        download download-pico-sdk download-pico-examples download-pico-extras \
        download-pico-playground download-pico-project-generator \
        download-picotool download-openocd download-freertos \
        install install-picotool install-openocd \
        build-led build-led-freertos build-uart-hello \
        clean-led clean-led-freertos clean-uart-hello clean \
        upload \
        prereqs-deb prereqs-rhel \
        identify-board identify-probe identify-port \
        monitor \
        install-udev-rules

# ─── Default target ───────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

# ─── Help ─────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "pico-bootstrap — Makefile targets"
	@echo ""
	@echo "  Prerequisites (require sudo)"
	@echo "    prereqs-deb                 Install prerequisites (Debian/Ubuntu)"
	@echo "    prereqs-rhel                Install prerequisites (Fedora/RHEL/CentOS)"
	@echo ""
	@echo "  Setup"
	@echo "    download                    Download all upstream dependencies"
	@echo "    download-pico-sdk           Clone pico-sdk (master)"
	@echo "    download-pico-examples      Clone pico-examples"
	@echo "    download-pico-extras        Clone pico-extras"
	@echo "    download-pico-playground    Clone pico-playground"
	@echo "    download-pico-project-generator"
	@echo "    download-picotool           Clone picotool"
	@echo "    download-openocd            Clone openocd ($(OPENOCD_BRANCH))"
	@echo "    download-freertos           Clone FreeRTOS-Kernel"
	@echo "    install                     Build and install picotool + openocd"
	@echo "    install-picotool            Build and install picotool"
	@echo "    install-openocd             Build and install openocd"
	@echo ""
	@echo "  Build"
	@echo "    build-led                   Compile LED toggle (bare-metal)"
	@echo "    build-led-freertos          Compile LED toggle (FreeRTOS)"
	@echo "    build-uart-hello            Compile UART hello (Debug Probe serial, GP0/GP1)"
	@echo "    clean-led                   Remove LED toggle build dir"
	@echo "    clean-led-freertos          Remove FreeRTOS LED build dir"
	@echo "    clean-uart-hello            Remove UART hello build dir"
	@echo "    clean                       Remove all build dirs"
	@echo ""
	@echo "  Flash"
	@echo "    upload TARGET_ELF=<path>    Flash ELF via Debug Probe"
	@echo "                                PROBE_SERIAL=<serial>  (optional, use when multiple probes attached)"
	@echo "                                PICO_TARGET_CFG=rp2350.cfg  (for Pico2; default: rp2040.cfg)"
	@echo ""
	@echo "  Tools"
	@echo "    identify-board              List attached Pico/Pico2 boards by serial"
	@echo "    identify-probe              List attached Debug Probes by serial"
	@echo "    identify-port               Print /dev/ttyACM* for PROBE_SERIAL"
	@echo "    monitor                     Open serial monitor for PROBE_SERIAL (115200 baud)"
	@echo "                                MONITOR_BAUD=<baud>  (default: 115200)"
	@echo "    install-udev-rules          Install OpenOCD udev rules (requires sudo)"
	@echo ""
	@echo "  Variables (override on command line)"
	@echo "    INSTALL_DIR  (default: ./deps)"
	@echo ""

# ─── Prerequisites ────────────────────────────────────────────────────────────
prereqs-deb:
	sudo apt install -y cmake gcc-arm-none-eabi libnewlib-arm-none-eabi \
	    build-essential libstdc++-arm-none-eabi-newlib \
	    autoconf libtool pkg-config libusb-1.0-0-dev libhidapi-dev

prereqs-rhel:
	@if command -v dnf >/dev/null 2>&1; then \
	    if ! rpm -q epel-release >/dev/null 2>&1; then \
	        echo ">>> Installing EPEL (needed on RHEL/CentOS for ARM toolchain)..."; \
	        sudo dnf install -y epel-release; \
	    fi; \
	    sudo dnf install -y cmake make gcc gcc-c++ \
	        arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ \
	        arm-none-eabi-newlib arm-none-eabi-binutils-cs \
	        autoconf libtool pkgconf libusb1-devel hidapi-devel; \
	else \
	    echo "ERROR: dnf not found — this target is for Fedora/RHEL/CentOS only." >&2; \
	    exit 1; \
	fi

# ─── Stamp dir ────────────────────────────────────────────────────────────────
$(STAMP_DIR):
	@mkdir -p $@

# ─── Download targets ─────────────────────────────────────────────────────────
download: download-pico-sdk download-pico-examples download-pico-extras \
          download-pico-playground download-pico-project-generator \
          download-picotool download-openocd download-freertos

download-pico-sdk: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/pico-sdk" ]; then \
	    echo ">>> Cloning pico-sdk..."; \
	    git clone $(PICO_SDK_URL) --branch master $(INSTALL_DIR)/pico-sdk; \
	    git -C $(INSTALL_DIR)/pico-sdk submodule update --init; \
	else \
	    echo ">>> pico-sdk already present, skipping."; \
	fi

download-pico-examples: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/pico-examples" ]; then \
	    echo ">>> Cloning pico-examples..."; \
	    git clone $(PICO_EXAMPLES_URL) --branch master $(INSTALL_DIR)/pico-examples; \
	else \
	    echo ">>> pico-examples already present, skipping."; \
	fi

download-pico-extras: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/pico-extras" ]; then \
	    echo ">>> Cloning pico-extras..."; \
	    git clone $(PICO_EXTRAS_URL) --branch master $(INSTALL_DIR)/pico-extras; \
	else \
	    echo ">>> pico-extras already present, skipping."; \
	fi

download-pico-playground: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/pico-playground" ]; then \
	    echo ">>> Cloning pico-playground..."; \
	    git clone $(PICO_PLAYGROUND_URL) --branch master $(INSTALL_DIR)/pico-playground; \
	else \
	    echo ">>> pico-playground already present, skipping."; \
	fi

download-pico-project-generator: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/pico-project-generator" ]; then \
	    echo ">>> Cloning pico-project-generator..."; \
	    git clone $(PICO_PROJECT_GENERATOR_URL) --branch master $(INSTALL_DIR)/pico-project-generator; \
	else \
	    echo ">>> pico-project-generator already present, skipping."; \
	fi

download-picotool: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/picotool" ]; then \
	    echo ">>> Cloning picotool..."; \
	    git clone $(PICOTOOL_URL) --branch master $(INSTALL_DIR)/picotool; \
	else \
	    echo ">>> picotool already present, skipping."; \
	fi

download-openocd: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/openocd" ]; then \
	    echo ">>> Cloning openocd ($(OPENOCD_BRANCH))..."; \
	    git clone $(OPENOCD_URL) --branch $(OPENOCD_BRANCH) --depth=1 --no-single-branch $(INSTALL_DIR)/openocd; \
	else \
	    echo ">>> openocd already present, skipping."; \
	fi

download-freertos: $(STAMP_DIR)
	@if [ ! -d "$(INSTALL_DIR)/FreeRTOS-Kernel" ]; then \
	    echo ">>> Cloning FreeRTOS-Kernel..."; \
	    git clone $(FREERTOS_URL) --branch main $(INSTALL_DIR)/FreeRTOS-Kernel; \
	else \
	    echo ">>> FreeRTOS-Kernel already present, skipping."; \
	fi

# ─── Install targets ──────────────────────────────────────────────────────────
install: install-picotool install-openocd

install-picotool: $(STAMP_DIR)/picotool-installed

$(STAMP_DIR)/picotool-installed: download-picotool download-pico-sdk
	@echo ">>> Building picotool..."
	@cmake -S $(INSTALL_DIR)/picotool \
	       -B $(INSTALL_DIR)/picotool/build \
	       -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
	       -DPICO_SDK_PATH=$(PICO_SDK_PATH)
	@$(MAKE) -C $(INSTALL_DIR)/picotool/build
	@$(MAKE) -C $(INSTALL_DIR)/picotool/build install
	@touch $@
	@echo ">>> picotool installed."

install-openocd: $(STAMP_DIR)/openocd-installed

$(STAMP_DIR)/openocd-installed: download-openocd
	@echo ">>> Building openocd..."
	@cd $(INSTALL_DIR)/openocd && ./bootstrap
	@cd $(INSTALL_DIR)/openocd && ./configure --prefix=$(INSTALL_DIR) --enable-cmsis-dap
	@$(MAKE) -C $(INSTALL_DIR)/openocd
	@$(MAKE) -C $(INSTALL_DIR)/openocd install
	@touch $@
	@echo ">>> openocd installed."

# ─── Build targets ────────────────────────────────────────────────────────────
LED_BUILD_DIR       := examples/led_toggle/build
LED_RTOS_BUILD_DIR  := examples/led_toggle_rtos/build

build-led: download-pico-sdk
	@echo ">>> Configuring LED toggle (bare-metal)..."
	@cmake -S examples/led_toggle \
	       -B $(LED_BUILD_DIR) \
	       -DPICO_SDK_PATH=$(PICO_SDK_PATH)
	@echo ">>> Building LED toggle..."
	@$(MAKE) -C $(LED_BUILD_DIR)
	@echo ">>> Built: $(LED_BUILD_DIR)/led_toggle.elf"

build-led-freertos: download-pico-sdk download-freertos
	@echo ">>> Configuring LED toggle (FreeRTOS)..."
	@cmake -S examples/led_toggle_rtos \
	       -B $(LED_RTOS_BUILD_DIR) \
	       -DPICO_SDK_PATH=$(PICO_SDK_PATH) \
	       -DFREERTOS_KERNEL_PATH=$(FREERTOS_PATH)
	@echo ">>> Building LED toggle (FreeRTOS)..."
	@$(MAKE) -C $(LED_RTOS_BUILD_DIR)
	@echo ">>> Built: $(LED_RTOS_BUILD_DIR)/led_toggle_rtos.elf"

clean-led:
	@rm -rf $(LED_BUILD_DIR)

clean-led-freertos:
	@rm -rf $(LED_RTOS_BUILD_DIR)

UART_HELLO_BUILD_DIR := examples/uart_hello/build

build-uart-hello: download-pico-sdk
	@echo ">>> Configuring UART hello..."
	@cmake -S examples/uart_hello \
	       -B $(UART_HELLO_BUILD_DIR) \
	       -DPICO_SDK_PATH=$(PICO_SDK_PATH)
	@echo ">>> Building UART hello..."
	@$(MAKE) -C $(UART_HELLO_BUILD_DIR)
	@echo ">>> Built: $(UART_HELLO_BUILD_DIR)/uart_hello.elf"

clean-uart-hello:
	@rm -rf $(UART_HELLO_BUILD_DIR)

clean: clean-led clean-led-freertos clean-uart-hello

# ─── Upload target ────────────────────────────────────────────────────────────
OPENOCD_BIN     := $(INSTALL_DIR)/bin/openocd
OPENOCD_SCRIPTS := $(INSTALL_DIR)/share/openocd/scripts
# rp2040.cfg for Pico, rp2350.cfg for Pico2
PICO_TARGET_CFG ?= rp2040.cfg

upload: install-openocd
	@if [ -z "$(TARGET_ELF)" ]; then \
	    echo "ERROR: TARGET_ELF is not set. Usage: make upload TARGET_ELF=<path/to/fw.elf>"; \
	    exit 1; \
	fi
	@echo ">>> Flashing $(TARGET_ELF)..."
	$(OPENOCD_BIN) \
	    -s $(OPENOCD_SCRIPTS) \
	    -f interface/cmsis-dap.cfg \
	    $(if $(PROBE_SERIAL),-c "adapter serial $(PROBE_SERIAL)") \
	    -f target/$(PICO_TARGET_CFG) \
	    -c "adapter speed 5000" \
	    -c "program $(TARGET_ELF) verify reset exit"

MONITOR_BAUD ?= 115200

# ─── Identify helpers ─────────────────────────────────────────────────────────
identify-board:
	@bash tools/identify.sh board

identify-probe:
	@bash tools/identify.sh probe

identify-port:
	@if [ -z "$(PROBE_SERIAL)" ]; then \
	    echo "ERROR: PROBE_SERIAL is not set. Usage: make identify-port PROBE_SERIAL=<serial>"; \
	    exit 1; \
	fi
	@bash tools/identify.sh port $(PROBE_SERIAL)

monitor:
	@if [ -z "$(PROBE_SERIAL)" ]; then \
	    echo "ERROR: PROBE_SERIAL is not set. Usage: make monitor PROBE_SERIAL=<serial>"; \
	    exit 1; \
	fi
	$(eval PORT := $(shell bash tools/identify.sh port $(PROBE_SERIAL)))
	@echo ">>> Opening monitor on $(PORT) at $(MONITOR_BAUD) baud  (Ctrl-A K to quit)"
	@screen $(PORT) $(MONITOR_BAUD)

# ─── udev rules (requires sudo) ───────────────────────────────────────────────
install-udev-rules:
	@echo ">>> Installing OpenOCD udev rules..."
	sudo cp $(INSTALL_DIR)/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/
	sudo udevadm control --reload-rules
	sudo udevadm trigger
	@echo ">>> Done. Unplug and replug the Debug Probe, then verify: groups \$$USER | grep plugdev"
	@if ! groups $$USER | grep -qw plugdev; then \
	    echo "WARNING: $$USER is not in the plugdev group."; \
	    echo "         Run: sudo usermod -aG plugdev $$USER  then log out and back in."; \
	fi
