cmake_minimum_required(VERSION 3.5)

project(cimnodes)

file(GLOB IMGUI_SOURCES
    ../cimgui/cimgui.cpp
    ../cimgui/imgui/imgui.cpp
    ../cimgui/imgui/imgui_draw.cpp
    ../cimgui/imgui/imgui_demo.cpp
    ../cimgui/imgui/imgui_widgets.cpp
    ../cimgui/imgui/imgui_tables.cpp
    cimnodes.cpp
    imnodes/imnodes.cpp
)

set(IMGUI_STATIC "no" CACHE STRING "Build as a static library")
set(CMAKE_CXX_STANDARD 11)

if (IMGUI_STATIC)
    add_library(cimnodes STATIC ${IMGUI_SOURCES})
else (IMGUI_STATIC)
    add_library(cimnodes SHARED ${IMGUI_SOURCES})
endif (IMGUI_STATIC)

add_definitions("-DIMGUI_USER_CONFIG=\"../cimconfig.h\"")
add_definitions("-DIMNODES_NAMESPACE=imnodes")
target_compile_definitions(cimnodes PUBLIC IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1)

target_include_directories(cimnodes PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/imnodes)
target_include_directories(cimnodes PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../cimgui/imgui)
target_include_directories(cimnodes PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../cimgui)
set_target_properties(cimnodes PROPERTIES PREFIX "")

install(TARGETS cimnodes
    RUNTIME DESTINATION  .
    LIBRARY DESTINATION  .
    ARCHIVE DESTINATION  .
)
