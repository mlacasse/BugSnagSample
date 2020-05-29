# =============================================================================
# © You i Labs Inc. 2000-2019. All rights reserved.

if(IOS OR TVOS OR OSX)
    file(GLOB_RECURSE YI_PROJECT_SOURCE "src/*.cpp" "src/*.mm")
    file(GLOB_RECURSE YI_PROJECT_HEADERS "src/*.h")
else()
    file(GLOB_RECURSE YI_PROJECT_SOURCE "src/*.cpp")
    file(GLOB_RECURSE YI_PROJECT_HEADERS "src/*.h")
endif()

if(IOS OR TVOS)
    list(REMOVE_ITEM YI_PROJECT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src/mainDefault.mm")
elseif(OSX)
    list(REMOVE_ITEM YI_PROJECT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src/main.mm")
    list(REMOVE_ITEM YI_PROJECT_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src/AppDelegate.mm")
endif()