# ─── Project configuration ────────────────────────────────────────────────────
PROJECT_NAME    := @PROJECT_NAME@

# Shared SDK installation — override to reuse across multiple projects
INSTALL_DIR     ?= $(HOME)/.pico-sdk

# Debug Probe serial (find with: make identify-probe)
PROBE_SERIAL    ?=

# rp2040.cfg for Pico, rp2350.cfg for Pico2
PICO_TARGET_CFG ?= rp2040.cfg

MONITOR_BAUD    ?= 115200

# ─── Pull in all pico-bootstrap targets ───────────────────────────────────────
PICO_BOOTSTRAP_DIR := pico-bootstrap
include $(PICO_BOOTSTRAP_DIR)/Makefile

# ─── Project build ────────────────────────────────────────────────────────────
BUILD_DIR := build

.PHONY: build clean flash monitor-project

build: download-pico-sdk
	@echo ">>> Configuring $(PROJECT_NAME)..."
	@cmake -S . -B $(BUILD_DIR) \
	       -DPICO_SDK_PATH=$(PICO_SDK_PATH) \
	       -DPROJECT_NAME=$(PROJECT_NAME)
	@echo ">>> Building $(PROJECT_NAME)..."
	@$(MAKE) -C $(BUILD_DIR)
	@echo ">>> Built: $(BUILD_DIR)/$(PROJECT_NAME).elf"

clean:
	@rm -rf $(BUILD_DIR)

flash: build install-openocd
	$(MAKE) upload \
	    TARGET_ELF=$(BUILD_DIR)/$(PROJECT_NAME).elf \
	    PROBE_SERIAL=$(PROBE_SERIAL) \
	    PICO_TARGET_CFG=$(PICO_TARGET_CFG)

monitor-project:
	$(MAKE) monitor PROBE_SERIAL=$(PROBE_SERIAL) MONITOR_BAUD=$(MONITOR_BAUD)
