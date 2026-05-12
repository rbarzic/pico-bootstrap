cmake_minimum_required(VERSION 3.13)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/pico_sdk_import.cmake)

project(uart_hello C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(uart_hello main.cpp)

target_link_libraries(uart_hello pico_stdlib)

# Route stdio to UART0 (GP0=TX, GP1=RX) — the Debug Probe UART bridge
pico_enable_stdio_uart(uart_hello 1)
pico_enable_stdio_usb(uart_hello 0)

pico_add_extra_outputs(uart_hello)
