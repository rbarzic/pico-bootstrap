cmake_minimum_required(VERSION 3.13)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/pico_sdk_import.cmake)

project(led_toggle_rtos C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

# FreeRTOS-Kernel — path provided via -DFREERTOS_KERNEL_PATH=...
if (NOT DEFINED FREERTOS_KERNEL_PATH)
    message(FATAL_ERROR "FREERTOS_KERNEL_PATH is not set. Pass -DFREERTOS_KERNEL_PATH=<path>")
endif()

# Use the RP2040 SMP port
set(FREERTOS_PORT GCC_RP2040 CACHE STRING "")
add_library(freertos_config INTERFACE)
target_include_directories(freertos_config SYSTEM INTERFACE ${CMAKE_CURRENT_LIST_DIR})

add_subdirectory(${FREERTOS_KERNEL_PATH} FreeRTOS-Kernel)

add_executable(led_toggle_rtos main.cpp)

target_link_libraries(led_toggle_rtos
    pico_stdlib
    FreeRTOS-Kernel
    FreeRTOS-Kernel-Heap4
)

pico_add_extra_outputs(led_toggle_rtos)
