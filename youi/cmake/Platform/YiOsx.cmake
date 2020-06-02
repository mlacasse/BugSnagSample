# =============================================================================
# © You i Labs Inc. 2000-2019. All rights reserved.
cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

if(__yi_custom_platform_included)
    return()
endif()
set(__yi_custom_platform_included 1)

include(${YouiEngine_DIR}/cmake/Platform/YiOsx.cmake)

macro(yi_configure_platform)
    cmake_parse_arguments(_ARGS "" "PROJECT_TARGET" "" ${ARGN})

    if(NOT _ARGS_PROJECT_TARGET)
        message(FATAL_ERROR "'yi_configure_platform' requires the PROJECT_TARGET argument be set")
    endif()

    _yi_configure_platform(PROJECT_TARGET ${_ARGS_PROJECT_TARGET})

    include(Modules/apple/YiConfigureFramework)

    # Upload dSYMs to Bugsnag
    add_custom_target(UploadDSYMs
        COMMAND ./bugsnag.rb -p osx -k e8fec3c046d6d0eed80c60d4d30690a2
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    )

    yi_configure_framework(TARGET ${_ARGS_PROJECT_TARGET}
        FRAMEWORK_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bugsnag-cocoa/OSX/build/Debug/Bugsnag.framework"
    )

    include(Modules/apple/YiFindFrameworkHelper)
    yi_find_framework_helper(FRAMEWORK "CoreTelephony")
    yi_find_framework_helper(FRAMEWORK "SystemConfiguration")
    yi_find_framework_helper(FRAMEWORK "libc++.tbd")
    yi_find_framework_helper(FRAMEWORK "libz.tbd")

    target_link_libraries(${_ARGS_PROJECT_TARGET}
        PRIVATE
        "-Obj-c"
        "-lc++"
        "-w"
    )

endmacro(yi_configure_platform)
