# Pull in pico_sdk_import.cmake from the SDK.
# PICO_SDK_PATH must be set (via env or CMake variable).

if (DEFINED ENV{PICO_SDK_PATH} AND (NOT PICO_SDK_PATH))
    set(PICO_SDK_PATH $ENV{PICO_SDK_PATH})
endif()

if (NOT PICO_SDK_PATH)
    message(FATAL_ERROR "PICO_SDK_PATH is not set. Pass -DPICO_SDK_PATH=<path> or set the environment variable.")
endif()

set(PICO_SDK_IMPORT "${PICO_SDK_PATH}/external/pico_sdk_import.cmake")
if (NOT EXISTS "${PICO_SDK_IMPORT}")
    message(FATAL_ERROR "pico_sdk_import.cmake not found at ${PICO_SDK_IMPORT}")
endif()

include(${PICO_SDK_IMPORT})
