cmake_minimum_required(VERSION 3.13)

# pico_sdk_import.cmake is provided by the pico-bootstrap submodule
include(${CMAKE_CURRENT_LIST_DIR}/pico-bootstrap/cmake/pico_sdk_import.cmake)

project(@PROJECT_NAME@ C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(@PROJECT_NAME@ src/main.cpp)

target_link_libraries(@PROJECT_NAME@ pico_stdlib)

# UART stdio on GP0 (TX) / GP1 (RX) — routed to Debug Probe serial port
pico_enable_stdio_uart(@PROJECT_NAME@ 1)
pico_enable_stdio_usb(@PROJECT_NAME@ 0)

pico_add_extra_outputs(@PROJECT_NAME@)
