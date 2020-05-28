# =============================================================================
# © You i Labs Inc. 2000-2019. All rights reserved.
cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

if(__yi_custom_platform_included)
    return()
endif()
set(__yi_custom_platform_included 1)

include(${YouiEngine_DIR}/cmake/Platform/YiIos.cmake)

macro(yi_configure_platform)
    cmake_parse_arguments(_ARGS "" "PROJECT_TARGET" "" ${ARGN})

    if(NOT _ARGS_PROJECT_TARGET)
        message(FATAL_ERROR "'yi_configure_platform' requires the PROJECT_TARGET argument be set")
    endif()

    _yi_configure_platform(PROJECT_TARGET ${_ARGS_PROJECT_TARGET})

    include(Modules/apple/YiConfigureFramework)

    # Upload dSYMs to New NewRelic
    #if(YI_UPLOAD_DSYM)
    #  add_custom_command(TARGET ${_ARGS_PROJECT_TARGET}
    #      POST_BUILD
    #      COMMAND /usr/bin/zip --recurse-paths --quiet "${CMAKE_CURRENT_SOURCE_DIR}/iOS_dSYM.zip" "${YI_BASE_OUTPUT_DIRECTORY}.dSYM"
    #      COMMAND curl -F dsym=@"${CMAKE_CURRENT_SOURCE_DIR}/iOS_dSYM.zip" -H "X-APP-LICENSE-KEY: AA216ffa362de5f23adaec2ab8c09d1db36102ea91" https://mobile-symbol-upload.newrelic.com/symbol
    #  )
    #endif()

    yi_configure_framework(TARGET ${_ARGS_PROJECT_TARGET}
        FRAMEWORK_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../bugsnag-cocoa/iOS/build/Debug/Bugsnag.framework"
        CODE_SIGN_IDENTITY ${YI_CODE_SIGN_IDENTITY}
        EMBEDDED
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

    target_include_directories(${PROJECT_NAME}
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${YI_PLATFORM_LOWER}/Libraries/AdobeMediaSDK/libs/Headers
    )
    target_include_directories(${PROJECT_NAME}
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${YI_PLATFORM_LOWER}/Libraries/AdobeMobileServicesSDK/AdobeMobileLibrary
    )

    target_link_libraries(${PROJECT_NAME} PRIVATE -lMediaSDK -L${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${YI_PLATFORM_LOWER}/Libraries/AdobeMediaSDK/libs/)
    target_link_libraries(${PROJECT_NAME} PRIVATE -lAdobeMobileLibrary -L${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${YI_PLATFORM_LOWER}/Libraries/AdobeMobileServicesSDK/AdobeMobileLibrary/)

    target_link_libraries(${PROJECT_NAME} PRIVATE -lsqlite3)

endmacro(yi_configure_platform)
