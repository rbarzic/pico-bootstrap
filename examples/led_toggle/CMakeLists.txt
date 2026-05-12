cmake_minimum_required(VERSION 3.13)

# Pull in Pico SDK (must be before project())
include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/pico_sdk_import.cmake)

project(led_toggle C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(led_toggle main.cpp)

target_link_libraries(led_toggle pico_stdlib)

# Generate .uf2, .hex, .bin, .dis alongside the ELF
pico_add_extra_outputs(led_toggle)
